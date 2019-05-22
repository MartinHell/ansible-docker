# Dockerfile for building Ansible image for Ubuntu 16.04 (Xenial), with as few additional software as possible.
#
# @see https://launchpad.net/~ansible/+archive/ubuntu/ansible
#
# Version  1.0
#

# pull base image
FROM ubuntu:18.04

MAINTAINER Martin <martin@hellstrom.it> 


RUN echo "===> Adding gnupg2..." && \
    apt-get update && \
    apt-get install -y gnupg2 software-properties-common && \
    echo "===> Adding Ansible's PPA..."  && \
    add-apt-repository ppa:ansible/ansible-2.8    && \
    DEBIAN_FRONTEND=noninteractive  apt-get update  && \
    \
    \
    echo "===> Installing Ansible..."  && \
    apt-get install -y ansible  && \
    \
    \
    echo "===> Installing Packer..." && \
    apt-get install -y unzip && \
    wget https://releases.hashicorp.com/packer/1.4.1/packer_1.4.1_linux_amd64.zip && \
    unzip packer_1.4.1_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    \
    echo "===> Install packer-builder-vsphere" && \
    wget https://github.com/jetbrains-infra/packer-builder-vsphere/releases/download/v2.3/packer-builder-vsphere-iso.linux && \
    chmod +x packer-builder-vsphere-iso.linux && \
    mv packer-builder-vsphere-iso.linux /usr/local/bin/ && \
    \    
    echo "===> Installing handy tools (not absolutely required)..."  && \
    apt-get install -y python-pip              && \
    pip install --upgrade pywinrm              && \
    apt-get install -y sshpass openssh-client  && \
    apt-get install -y python-netaddr && \
    \
    \
    echo "===> Removing Ansible PPA..."  && \
    rm -rf /var/lib/apt/lists/*  /etc/apt/sources.list.d/ansible.list  && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    echo 'localhost' > /etc/ansible/hosts

RUN sed -i 's/#remote_user.*/remote_user = ubuntu/g' /etc/ansible/ansible.cfg && \
    sed -i 's/#host_key_checking.*/host_key_checking = False/g' /etc/ansible/ansible.cfg && \
    sed -i 's/#ssh_args.*/ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=\/dev\/null/g' /etc/ansible/ansible.cfg

# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
