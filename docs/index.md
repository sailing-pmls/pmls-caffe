```eval_rst
.. toctree::
   :hidden:
   :maxdepth: 2
   
   self
   history
   installation
   performance
   docker
   distributed-guide
   multigpu-guide
```

# Home

Poseidon is a scalable open-source framework for large-scale distributed deep learning on CPU/GPU clusters. 
Initially released on January 2015 along with Petuum v1.0 as an application under the **Bösen** parameter server, we are now refactoring it as a stand-alone application for users who are primarily interested in deep learning. 

**If you are coming from the main Petuum wiki, please note that Poseidon is installed separately from the other Petuum applications. Do continue to follow this wiki for instructions.**

Poseidon builds upon the [Caffe framework](http://caffe.berkeleyvision.org/), and extends it with distributed, multi-machine capability. If you have a cluster with multiple GPU-equipped machines, you can now take advantage of all of them while still enjoying the familiar interface of Caffe!

## News
(New) CUDA 7.5 and cudnn R3 are supported!

(New) New updates on the performance of accelerating the training of AlexNet and GoogLeNet!

## Quick Start

We provide a [quick start script](https://github.com/petuum/poseidon/blob/master/install.sh) to help you try Poseidon! This script will automatically clone the Poseidon project from Github and install it on your machine.
After installation, follow the [setup guide](distributed-guide.md) to setup your model and training!

If you have trouble using the quick start script, check our detailed [installation guide](installation.md).
After installation, please check the [setup guide](distributed-guide.m) for you to setup your neural network models and start your training on clusters or on multiple GPUs.

## Docker 

If you are a Docker user, we also have a [Poseidon image](https://hub.docker.com/r/zhisbug/poseidon/) on the Docker Hub. Check our instructions on [how to run Poseidon inside Docker](docker.md).

## Overview
Poseidon is a scalable system architecture as a general purpose solution for any single-machine DL framework to be efficiently distributed on GPU clusters with commodity Ethernet, by leveraging the Petuum
framework [28] as well as three components: (i) a three-level hybrid architecture that allows Poseidon to support both CPU-only clusters as well as GPU-equipped clusters, as the following figure shows; (ii) a distributed wait-free backpropagation (DWBP) algorithm to improve GPU utilization and to balance communication, and (iii) a dedicated structure-aware communication protocol (SACP) to minimize communication overheads.

![Poseidon](https://farm8.staticflickr.com/7753/26944318616_a1acd42280.jpg)

Poseidon enjoys speedups from the communication and bandwidth management features of Bösen, and further exploits sufficient factor compression for efficient inter-machine synchronization. Poseidon retains the familiar Caffe interfaces, so experienced Caffe users can get started with little effort.

We disclose the system architecture of Poseidon and several distributing strategies for fast parallelization of deep learning in the following arXiv paper:

Hao Zhang, Zhiting Hu, Jinliang Wei, Pengtao Xie, Gunhee Kim, Qirong Ho, Eric Xing. [Poseidon: A System Architecture for Efficient GPU-based Deep Learning on Multiple Machines](http://arxiv.org/abs/1512.06216). In arXiv, 2015. 

## Performance at a Glance

* By training on 1.2m images using a 60m-parameter network (Alexnet), Petuum can identify objects in an image (e.g. panda, desk, chime) with 80% accuracy, the same high standard as the original Caffe. Thanks to distributed learning, Petuum finishes training in far less time than Caffe - under 24 hours, using 8 machines with a Tesla K20 GPU each, connected over commodity ethernet. This is a 5-7x speedup over the original Caffe, and even more speedup is possible using more machines.

* Poseidon achieves competitive results on the largest image classification dataset: ImageNet 22K, which includes 14,197,087 labeled images (near 3TB) from 21,841 categories. Compared to previous state-of-the-art results, we achieve a top-1 training accuracy 41% and test accuracy 23.7%, but use only 13% training workers and  30% training time.

For more detailed performance report, please refer to the [performance](performance.md) page.
