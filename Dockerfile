FROM ubuntu:trusty

MAINTAINER M.R. Siavash Katebzadeh <mr.katebzadeh@gmail.com>

LABEL Description="Docker image for Omnet++ version 4.2.2 and ib_flit_sim."

RUN apt-get update

# General dependencies
RUN apt-get install -y \
    build-essential \
    g++-multilib=4:4.* \
    gdb \
    bison \
    flex \
    perl \
    python-pip \
    libxml2-dev \
    zlib1g-dev \
    default-jre \
    doxygen \
    graphviz \
    openssh-server \
    xvfb


RUN pip install compiledb

# sshd
RUN mkdir /var/run/sshd
RUN echo 'root:hi' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

# Create working directory
VOLUME ["/opt/ib"]
WORKDIR /opt/ib
#COPY ./mlx /opt/omnetpp/mlx

ENV DISPLAY :0

# Set path for compilation
ENV PATH $PATH:/opt/ib/sim/omnetpp/bin


ENV d /opt/ib/sim

ENV NEDPATH $d/src:$d/examples

#ENTRYPOINT service ssh restart && bash
ENTRYPOINT bash

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt
