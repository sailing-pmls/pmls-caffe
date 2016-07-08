# Running Poseidon in Docker

If you are a Docker user, we have also built an image for Poseidon and uploaded it to the Docker hub. Check our [Poseidon image](https://hub.docker.com/r/zhisbug/poseidon/) in the Docker hub. 

The source code of this docker image could be found here: [Docker image source](https://github.com/petuum/poseidon/blob/master/docker/Dockerfile).

## Setup the Docker image

### Step 1: Check the NVIDIA driver version
First of all, make sure the NVIDIA driver version in the [Dockerfile](https://github.com/petuum/poseidon/blob/master/docker/Dockerfile) (line 10) matches your local driver version. 
If yes, you can directly clone the Docker image from [the Docker Hub](https://hub.docker.com/r/zhisbug/poseidon/) without the need to rebuild the image;
Otherwise, please modify the driver version accordingly and rebuild the Docker image following our instructions in Step 2.  

### Step 2: Build the Docker image

Please make sure you have successfully installed and setup Docker on your machine.

To build the image:

    cd docker
    docker build -t poseidon .

You will need to wait for 15 - 20 minutes before it finishes.

### Step 3: Setup SSH

This is an SSH docker, so you will need to setup the keys. The easiest is to have a key shared by all the instances (if you want to run multiple instances) to enable password-less SSH.

You need a server key as well as a client key. Once you setup all that in a folder, you should have the following files:

*  authorized_keys
*  id_rsa
*  id_rsa.pub
*  ssh_host_rsa_key
*  ssh_host_rsa_key.pub

In the authorized_keys file, simply put the content of the id_rsa.pub and your own key. Now you can mount that folder as /root/.ssh, and you should be set. Make sure the permissions are 700.

### Step 4: Start a Poseidon container from Docker

You can start a container for Poseidon by the following example command:

    docker run -itd -v [/path/to/your/ssh/folder]:/root/.ssh $(for device in $(ls /dev/nvidia*); do echo -n "--device $device "; done) --name [Container Name] [Image Name]

*  `/path/to/your/ssh/folder`: The path where you place your SSH keys. In Ubuntu, it is usually `/home/[username]/.ssh`;

*  `Container Name`: The container name. For example: `poseidon0, poseidon1`, ...;

*  `Image Name`: If you directly clone the image from our Docker hub, set the `Image Name` to `zhisbug/poseidon`; If you build the Docker image by yourself, set the `Image Name` to be `poseidon`;


## Host file for multiple containers

Dockers allows you to run multiple containers and test Poseidon in a distributed settint, even if you do not have a cluster at all. If you want to run with more than one docker locally to run some tests, you can start several instances of the docker. If they are named poseidon0, poseidon1, etc, you can use the generate_hostfile.sh script provided.

## Acknowledgement

This docker image is adopted from the [original version](https://github.com/nitnelave/docker-ml/tree/master/docker-poseidon) by Valentin Tolmer. 
