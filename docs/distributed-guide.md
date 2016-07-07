# Setup Guide: Distributed Learning of Neural Networks

## Data Preparation
Data can be in different format, such as LevelDB, LMDB or image files, which is specified in the model configuration files (see below for more details). We take the CIFAR-10 dataset for example.

Caffe has already provided scripts for downloading and converting CIFAR-10 data. Simply run the following commands:

    # download dataset
    sh data/cifar10/get_cifar10.sh

    # convert to leveldb format
    sh examples/cifar10/create_cifar10.sh

The script creates the leveldb dataset directories `examples/cifar10/cifar10_test_leveldb` and `examples/cifar10/cifar10_train_leveldb`, and the data set image mean `examples/cifar10/mean.binaryproto`.

## Data Partitioning
In the distributed setting you sometimes need to partition the whole dataset into M pieces, where M is the total number of clients (machines). Each client will be in charge of one piece. (Note: You can skip this step if you are using one client or multiple clients with a shared file system.)

To partition the CIFAR-10 LevelDB training data, use the script `scripts/partition_data.sh`: edit the script to change the `DB_PATH` and `NUM_PARTITIONS` to the path of CIFAR-10 training LevelDB (i.e. `examples/cifar10/cifar10_train_leveldb`) and number of partitions (e.g. 2), respectively; then run the command:

    sh scripts/partition_data.sh

After that there should be NUM_PARTITIONS partitioned datasets, `cifar10_leveldb_train_k` (k is the index), in the same location as CIFAR-10 training LevelDB. Now you can distribute the leveldb to the clients (client k will read data from cifar10_leveldb_train_k, so make sure the index k is consistent with the client id you specified in `$PETUUM_ROOT/machinefiles/localserver`).

**Repeat this process for the test data `examples/cifar10/cifar10_test_leveldb`.**

## Running the Caffe Application
### Model Training
Training a Neural Network involves several configuration files. Some examples have been provided in `./examples/`, **but you will need to configure them for your environment**. We shall explain how to do so, using the CIFAR-10 image classification task as a running example:

* Network definition file: `./examples/cifar10/cifar10_quick_train_test.prototxt`

  - This defines the model architecture by specifying neural layers one by one. Please refer to [Caffe Layer Tutorial](http://caffe.berkeleyvision.org/tutorial/layers.html) for the details of neural layer definition.

  - The grammar is almost the same with that of original Caffe, except that we introduce an addition parameter for data layers (specifically, for data layers with type `DATA` and `IMAGE_DATA`), i.e., `shared_file_system`. If clients share a file system and access the same data copy, set `shared_file_system` to `true`, and the clients will read the data you specified in `source`; Otherwise (and by default), `shared_file_system` is set to `false`, and client k will append `_k` to the `source` and read the corresponding data piece. For example, if you set:

            source: "POSEIDON_ROOT/examples/cifar10/cifar10_train_leveldb"
            shared_file_system: false

        then client 0 will read training data from `POSEIDON_ROOT/examples/cifar10/cifar10_train_leveldb_0`.

        LevelDB does not support concurrent access by multiple clients. So if your data is stored in LevelDB and you are using more than one clients, you should set `shared_file_system` to `false`, and partition/distribute the dataset (refer to the *Data Partitioning* section).

  - **Note that since we are running in the distributed setting, *absolute path* is required when specifying the paths of `source` and `mean_file`. Replace `POSEIDON_ROOT` according to your setting.**

* Solver configuration file: `./examples/cifar10/cifar10_quick_solver.prototxt`
  - This specifies the optimization configuration for model training, including the GPU/CPU modes, solver type, and learning rate, etc. The grammer is exactly the same with original Caffe, and please refer to [Caffe Solver Tutorial](http://caffe.berkeleyvision.org/tutorial/solver.html) for the details.
  - **Note: GPU mode is the default - if you are using CPU mode, you will need to change `solver mode: GPU` to `solver mode: CPU`**
  - Again, make sure to use absolute paths when specifying the paths of `net`, `snapshot_prefix`. (Replace `POSEIDON_ROOT` according to your setting.) 

* Execution script: `./examples/cifar10/run_local.py`
  - Some system parameters are specified in the script:
    * `solver`: (absolute) path of the solver configuration file.
    * `num_table_threads`: equal to the number of worker threads per client + 1 (*currently does not support multiple GPU on single machine, so set to `1` if using GPU.* Will support multi-GPU per single machine soon.)
    * `table_staleness`: staleness of parameter server tables (suggest value: 0)
    * `num_rows_per_table`: number of rows per ps table. It is related to table partition in the parameter server. Simply set it to `1` if the model size is not too big (e.g. #param <= 250M). 
    * `svb`: true to use sufficient vector broadcast (SVB, can reduce communication cost of fully-connected layers. Not recommended for small NN).
  - Replace `POSEIDON_ROOT` according to your setting.

To start training, specify the paths in above files according to your setting, then run:

    python examples/cifar10/train_cifar10.py


### Output
When training a model, you will see output like this:
    
    I1126 20:40:16.731869 29444 solver.cpp:294] Iteration 100, loss: 1.64066, time: 141.762
    I1126 20:40:16.731956 29444 solver.cpp:318]     Train net output #0: loss = 1.64066 (* 1 = 1.64066 loss)
    ...
    I1126 20:42:27.374675 29444 solver.cpp:456] Iteration 200, Testing net (#0)
    I1126 20:42:27.375102 29444 solver.cpp:486]     Test net output #0: accuracy = 0.4592
    I1126 20:42:27.375174 29444 solver.cpp:486]     Test net output #1: loss = 1.49516 (* 1 = 1.49516 loss)
For each training iteration, `loss` is the training function evalued at thread 0 on client 0. For the output of the testing phase, score 0 is the accuracy, and score 1 is the testing loss function. Again, both scores are evaluated at thread 0 on client 0.

After the training is completed, there will be some output files in `output/cifar10/`. Among the files, `cifar-netoutputs` records the loss and accuracy scores of each iteration, where the values are averaged across all threads, and thus more accurate than the outputs on the fly.

### Terminating model training

Th Caffe app runs in the background, and outputs its progress to standard error. If you need to terminate the app before it finishes, just run

    ./scripts/kill_caffe.py <petuum_ps_hostfile>

## Feature Extraction

A trained Neural Network model can be used to extract features from images. Here we will use the pre-trained [BVLC Reference CaffeNet](http://caffe.berkeleyvision.org/model_zoo.html) for demonstration.

Run the following command to download the pre-trained model:

    ./scripts/download_model_binary.py models/bvlc_reference_caffenet

Then prepare data and other input files as follows:
    
    # 1. Make a temporary folder to store things into
    mkdir examples/_temp
    # 2. Generate a list of the files to process
    find `pwd`/examples/images -type f -exec echo {} \; > examples/_temp/temp.txt
    # 3. Add line number to the end of each line, so that we can know 
    # which image each extracted feature corresponds to
    cat examples/_temp/temp.txt | awk '{printf("%s %d\n", $0, NR)}' > examples/_temp/file_list.txt
    # 4. Download the mean image of the ILSVRC dataset. We will subtract 
    # the mean image from the dataset
    sh data/ilsvrc12/get_ilsvrc_aux.sh
    # 5. Copy the network definition
    cp examples/feature_extraction/imagenet_val.prototxt examples/_temp

Note: The above commands assume you are using one client, or multiple clients with shared file system. if you are using multiple clients which do not share file systems with each other, then you need to partition the image data across the clients, run the above commands on each client, rename `./examples/_temp/file_list.txt` on each client c to `examples/_temp/file_list.txt_c` where `c` is the client index, and set `shared_file_system` to `false` in `examples/_temp/imagenet_val.prototxt`.

Edit `examples/_temp/imagenet_val.prototxt` to change the paths for your setting. Specifically, on the lines with `source:` and `mean_file:`, replace `POSEIDON_ROOT` with the full path to `bosen/app/caffe/`. Now we can start extracting features by running:

    sh scripts/extract_features.sh

The features are stored to LevelDBs `examples/_temp/features_c_t`, where `c` is the index of client while `t` is the index of thread. I.e., the features extracted by different threads are stored in seperate LevelDBs. You can read the records using data structure `Datum`, where `Datum::float_data` is the features and `Datum::label` is the corresponding image id (i.e. the line number you added to `file_list.txt`).

After finishing the extaction, run

    ./scripts/kill_feature_extractor.py ../../machinefiles/localserver

to terminate the app.
