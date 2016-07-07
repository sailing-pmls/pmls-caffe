# Setup Guide: Multi GPU Training of Neural Networks

Poseidon also supports multi-GPU training of neural networks on one machine. If you want to use this feature, make sure you have successfully installed Poseidon by following our [installation guide](https://github.com/petuum/poseidon/wiki/Installation-Guide) and you also have prior knowledge about how to start a training instance under Poseidon by reading our [setup guide](https://github.com/petuum/poseidon/wiki/Setup-Guide:-Distributed-Learning-of-Neural-Networks) for distributed training. 

## Multi-GPU Training

To enable multiple-GPU training, one need to specify the GPU device IDs in the starting script.
For example, suppose you are going to train GoogleNet using 2 machines, each of which has two GPUs with device ID 0 and 1, in total 4 GPUs.

1. First set the machine IPs and ports in the `localserver`.

2. Then specify `device = [0, 1]` in `examples/googlenet/run_local.py`, or if you prefer bash script, specify device IDs as `device="0,1"` and set `num_app_threads=2` in `example/googlenet/train_googlent.sh`.
 
3. Start the script.

The log will show both GPUs are enabled for training in every machine.

<!---
## Sufficient Vector Broadcast (SVB)

The system enables SVB for synchronization of fully-connected layers (by setting `svb=true` in the running script), which reduces communication cost. Assume the weights of a fully-connected layer is a `MxN` matrix `W`, where `M` is the dimension of the input of the layer, and `N` is the output dimension. The gradient of `W` is also a `MxN` matrix.
-->
