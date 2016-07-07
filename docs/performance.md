# Performance
We will frequently update this section for the latest performance we achieved.

## AlexNet on ILSVRC 2012 (Distributed GPU Training)

* **Objective**: We train the [AlexNet](http://papers.nips.cc/paper/4824-imagenet-classification-with-deep-convolutional-neural-networks) using ILSVRC 2012 Dataset.

* **Environment**: The throughput is measured on a distributed GPU cluster, every node of which is equipped with one K20 GPU card and 40 Gigabit Ethernet (GbE). Training data are partitioned and saved on local HDD of each node. CuDNN-R2 is enabled. 

* **Setting**: See the net [prototxt](https://github.com/petuum/poseidon/blob/master/models/bvlc_alexnet/train_val.prototxt) and [solver](https://github.com/petuum/poseidon/blob/master/models/bvlc_alexnet/solver.prototxt). The training script and PS settings are provided [here](https://github.com/petuum/poseidon/blob/master/examples/imagenet/train_imagenet.sh). 

### Throughput
The following figure shows Poseidon's speedup of throughput when training AlexNet using different settings of staleness values and number of nodes. When using 1 node, the performance of the original Caffe is reported. The throughput is evaluated with cuDNN R2 and CUDA 6.5.

<img src="https://farm1.staticflickr.com/655/23652620546_735317807d_b.jpg" height="300"> 

### Convergence

On our cluster, when training AlexNet with 8 nodes, Poseidon takes only 1 day to converge (compared to 5 - 7 days on the single machine Caffe), and achieves 56.5% top-1 accuracy on the validation set. 

The following figures show how the validation error decreases along with training time and iterations. When using 1 node, the performance of the original Caffe is reported.

<img src="https://farm6.staticflickr.com/5783/23566639776_d0b1fa2cfe_b.jpg" height="300"> 

## GoogLeNet on ILSVRC 2012 (Distributed GPU Training)

* **Objective**: We train the [GoogLeNet](http://arxiv.org/pdf/1409.4842.pdf) using ILSVRC 2012 Dataset.

* **Environment**: The throughput is measured on a distributed GPU cluster, every node of which is equipped with one K20 GPU card and 40 Gigabit Ethernet (GbE). Training data are partitioned and saved on local HDD of each node. CuDNN-R2 is enabled. 

* **Setting**: See the net [prototxt](https://github.com/petuum/poseidon/blob/master/models/bvlc_googlenet/train_test.prototxt) and [solver](https://github.com/petuum/poseidon/blob/master/models/bvlc_googlenet/quick_solver.prototxt). The training script and PS settings are provided [here](https://github.com/petuum/poseidon/blob/master/examples/googlenet/train_googlenet.sh). 

### Throughput
The following figure shows Poseidon's speedup of throughput when training GoogLeNet using different settings of staleness values and number of nodes, compared to single machine Caffe. The throughput is evaluated with cuDNN R2 and CUDA 6.5.

<img src="https://farm1.staticflickr.com/568/23652620196_1bd337102f_b.jpg" height="300">

### Convergence

When training GoogLeNet with 8 nodes, Poseidon takes less than 48 hours to achieve 50% top-1 accuracy, and less than 75 hours to achieves 57% top-1 accuracy, and finally achieve 67.1% top-1 accuracy, enjoys about 4 times speedup compared to single machine Caffe, which usually takes 15- 20 days to converge, as shown in the following figures. 

<img src="https://farm6.staticflickr.com/5632/23224763069_3f5ca5c4e1_b.jpg" height="300">

## ImageNet 22K (Distributed GPU Training)

* **Objective and dataset**: We train a CNN using all available images in ImageNet, including 14,197,087 labeled images from 21,841 categories. We randomly split the whole set into two parts, and use the first 7.1 million of images for training and remained for test. The whole data size is about 3.2Tb with 1.6Tb of training and 1.6Tb as test.

* **Environment**: We train the CNN with fully data-parallelism on a GPU cluster with 8 nodes, of which every node is equipped with one K20 GPU card and 40 Gigabit Ethernet (GbE). Training data are partitioned and saved on local HDD of each node. CuDNN-R2 is enabled. 

* **Settings**: The network and solver configurations will be released soon. 

### Convergence

The following table compares our result to those of previous work on ImageNet 22K, in terms of experimental settings, machine resources, training time used, and train/test accuracy. It's worth mentioning that the prediction performance primarily depends on what kind of CNN structure you choose, thus could be substantially improved if choosing a different or improved model. 
 
| Framework | Data (train/test) | # machines/cores | Time | Train accuracy | Test accuracy |
| :---:|:---:| :---:|:---:|:---:| :---:|
| _Poseidon_ | 7.1M / 7.1M | 8 / 8 GPUs | 3 days  | 41% | 23.7% |
| _Adam_ | 7.1M / 7.1M | 62 machines / ? | 10 days | N/A | 29.8% |
| _Le et al., w/ pretrain_ | 7.1M+10M unlabeled images / 7.1M | 1000 / 16000 cores | 3 days | N/A | 15.8% |
| _MxNet_ | 14.2M / No test | 1 / 4 GPUs | 8.5 days | 37.19% | N/A |

<!---
Note that at this point complete fair comparison between different framework is not possible because the experiment protocol of ImageNet 22K is not standardized, all the source codes are not fully available yet, and large variations exist in system configurations, models, and implementation details.
However, it is clear that Poseidon achieves a competitive test accuracy 23.7% with the state-of-the-arts with shorter training time and less machine resources.
Compared to Microsoft Adam, we only use 30% training time and 13% machines to achieve 23.7% accuracy with a same sized model.
# Tips and Tricks
1. As CNNs are highly non-convex. In most cases, we suggest to set the staleness value to 0.

2. If your bandwidth is limited, please turn on svb to enjoy the communication optimization!
-->
