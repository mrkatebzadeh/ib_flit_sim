FROM ubuntu:trusty

MAINTAINER M.R. Siavash Katebzadeh <mr.katebzadeh@gmail.com>

LABEL Description="Docker image for Omnet++ version 4.2.2 and ib_flit_sim."

RUN apt-get update

# General dependencies
RUN apt-get install -y \
    git \
    wget \
    vim \
    build-essential \
    g++-multilib=4:4.* \
    gdb \
    bison \
    flex \
    perl \
    qt5-default \
    python-pip \
    tcl-dev \
    tk-dev \
    libxml2-dev \
    zlib1g-dev \
    default-jre \
    doxygen \
    graphviz \
    openssh-server \
    xvfb

# QT
RUN apt-get install -y \
    libopenscenegraph-dev \
    openscenegraph-plugin-osgearth \
    libosgearth-dev \
    qt5-default \
    libxml2-dev \
    zlib1g-dev \
    default-jre \
    libwebkitgtk-3.0-0


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
RUN mkdir -p /opt/omnetpp/omnetpp-4.2.2
RUN mkdir -p /opt/omnetpp/mlx
WORKDIR /opt/omnetpp
COPY . .

ENV DISPLAY :0
# Omnet++ source is already in repository. Copy it to container
RUN git clone https://github.com/mrkatebzadeh/omnetpp omnetpp-4.2.2/

# Set path for compilation
ENV PATH $PATH:/opt/omnetpp/omnetpp-4.2.2/bin

# Configure and compile Omnet++
RUN cd omnetpp-4.2.2 && git pull && \
    NO_TCL=1 xvfb-run ./configure && \
    make

# Ib_flit_sim source is already in repository. Copy it to container
#RUN git clone https://github.com/mrkatebzadeh/ib_flit_sim /opt/omnetpp/ib_flit_sim/

ENV d /opt/omnetpp/mlx

RUN cd /opt/omnetpp/mlx && git pull && d=`pwd` \
    make makefiles; \
    make; make MODE=release; make -Bnwk | compiledb -o compile_commands.json;

ENV NEDPATH $d/src:$d/examples

ENTRYPOINT service ssh restart && bash

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt
