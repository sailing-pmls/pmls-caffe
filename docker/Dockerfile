FROM nvidia/cuda:7.5-cudnn4-devel-centos7
MAINTAINER Valentin Tolmer "valentin.tolmer@gmail.com"

# Repository for recent packages
#
# Needed for gflags-devel, among others
RUN yum -y install epel-release && yum clean all

# You may need to change the driver version
ENV CUDA_DRIVER_VERSION=352.55
RUN yum -y install \
    xorg-x11-drv-nvidia-libs-$CUDA_DRIVER_VERSION \
    yum-versionlock \
    && yum -y install \
    xorg-x11-drv-nvidia-$CUDA_DRIVER_VERSION \
    xorg-x11-drv-nvidia-devel-$CUDA_DRIVER_VERSION \
    xorg-x11-drv-nvidia-gl-$CUDA_DRIVER_VERSION \
    cuda-drivers-$CUDA_DRIVER_VERSION \
    && yum clean all \
    && yum versionlock \
    cuda-drivers \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-devel \
    xorg-x11-drv-nvidia-gl \
    xorg-x11-drv-nvidia-libs

# Common needed packages
RUN yum -y install \
    autoconf \
    automake \
    boost-devel \
    cuda-runtime-7-5 \
    libtool \
    bzip2 \
    git \
    gflags-devel \
    glog-devel \
    hdf5-devel \
    leveldb-devel \
    lmdb-devel \
    libuuid-devel \
    make \
    numactl-devel \
    opencv-devel \
    openblas-devel \
    protobuf-devel \
    psmisc \
    snappy-devel \
    wget \
    which \
    && yum clean all

# Install cudnn 3
RUN curl -fsSL http://developer.download.nvidia.com/compute/redist/cudnn/v3/cudnn-7.0-linux-x64-v3.0-prod.tgz -O && \
      tar -xzf cudnn-7.0-linux-x64-v3.0-prod.tgz -C /usr/local && \
      rm cudnn-7.0-linux-x64-v3.0-prod.tgz && \
      ldconfig

# Install Poseidon & Bosen dependencies
RUN yum -y install \
    binutils-devel \
    libstdc++-static \
    openssh-server \
    popt-devel \
    python-devel \
    && yum remove -y gflags-devel boost \
    && yum clean all

# Setup the ssh service
RUN mkdir /var/run/sshd

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#StrictModes yes/StrictModes no/' /etc/ssh/sshd_config && \
    sed -i 's@HostKey .*@HostKey /root/.ssh/ssh_host_rsa_key@' /etc/ssh/sshd_config

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && rm -rf /root/.ssh/*

# Clone Poseidon Project and build the 3rd_party dependencies first
RUN git clone --recursive https://github.com/nitnelave/poseidon.git && \
    cd poseidon && \
    cp Makefile.config.example Makefile.config && \
    echo "USE_CUDNN := 1" >> Makefile.config && \
    sed -i 's/BLAS := atlas/BLAS := open/g' Makefile.config && \
    echo 'BLAS_INCLUDE := /usr/include/openblas' >> Makefile.config && \
    echo 'BLAS_LIB := /usr/lib64' >> Makefile.config

# Build the third_party
RUN cd /poseidon && make -j$(nproc) -C third_party

# Build Poseidon
RUN cd /poseidon && make all -j$(nproc)

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
