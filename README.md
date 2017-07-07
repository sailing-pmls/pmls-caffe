# PMLS-Caffe: Distributed Deep Learning Framework on Petuum

PMLS-Caffe (formerly Poseidon) is a scalable open-source framework for large-scale distributed deep learning on CPU/GPU clusters. It is initially released in January 2015 along with PMLS v1.0 as an application under the Bösen parameter server.

PMLS-Caffe builds upon the Caffe (http://caffe.berkeleyvision.org/) CNN libraries and the PMLS distributed ML framework (http://sailing-lab.wixsite.com/sailing-pmls) as a starting point, but goes further by implementing three key contributions for efficient CNN training on clusters of GPU-equipped machines: (i) a three-level hybrid architecture that allows PMLS-Caffe to support both CPU-only clusters as well as GPU-equipped clusters, (ii) a distributed wait-free backpropagation (DWBP) algorithm to improve GPU utilization and to balance communication, and (iii) a dedicated structure-aware communication protocol (SACP) to minimize communication overheads.

PMLS-Caffe's design philosophy is rooted on efficiently harnessing multiple, distributed GPUs on commodity hardware and Ethernet, in order to maximize the speedup with a fully data parallel scheme for distributed deep learning. We empirically evaluate PMLS-Caffe regarding of throughput, convergence and accuracy on the image classification tasks with multiple standard datasets, and show that PMLS-Caffe is able to achieve state-of-the-art speedups in accelerating the training of modern CNN structures, at the same time guarantee the correct convergence. 

PMLS-Caffe inherits many functionalities and benefits of PMLS, including the Sufficient Factor Broadcasting (SFB), managed communication and bandwidth management in the [Bösen parameter server](https://github.com/sailing-pmls/bosen), etc. Moreover, most of the Caffe interfaces are kept unchanged.

Please consult the [documentation page](http://docs.petuum.com/projects/petuum-poseidon) for more details on how to setup PMLS-Caffe on your clusters and start training your model. We also disclose the system architecture of PMLS-Caffe and several distributing strategies for fast parallelization of deep learning in the following arXiv paper: 
