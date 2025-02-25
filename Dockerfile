FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update \
    && apt install -y wget bzip2 make unzip cppcheck

RUN apt install -y git cmake ninja-build gperf \
    ccache dfu-util device-tree-compiler  \
    python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 python3-venv

# Create a non-root user named "ubuntu"
# But put in root group since GitHub actions needs permissions
# to create tmp files.
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo \
    -u 1001 ubuntu

RUN mkdir /home/ubuntu/workspace \
    && cd /home/ubuntu/workspace \
    && mkdir temp_manifest_dir \
    && python3 -m venv ./.venv \
    && . ./.venv/bin/activate \
    && pip install west \
    && echo ". /home/ubuntu/workspace/.venv/bin/activate" >> /home/ubuntu/workspace/.bashrc

# Install Zephyr RTOS SDK
RUN cd ~ \
    && wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.0/zephyr-sdk-0.17.0_linux-x86_64.tar.xz \
    && wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.0/sha256.sum | shasum --check --ignore-missing \
    && tar xvf zephyr-sdk-0.17.0_linux-x86_64.tar.xz \
    && cd zephyr-sdk-0.17.0 

RUN cd ~/zephyr-sdk-0.17.0 \
    && yes | ./setup.sh

# Copy manifest file to the temp directory (Manifest file of the CURRENT project)
# With all dependensys
COPY west.yml /home/ubuntu/workspace/temp_manifest_dir/west.yml

RUN cd  /home/ubuntu/workspace/ && . ./.venv/bin/activate \
    && cd ./temp_manifest_dir && west init --local \
    && west update

RUN cd /home/ubuntu/workspace && . ./.venv/bin/activate \
    && west zephyr-export \
    && west packages pip --install

RUN cd /home/ubuntu/workspace/ && rm -rf ./temp_manifest_dir || true

USER ubuntu
WORKDIR /home/ubuntu/workspace