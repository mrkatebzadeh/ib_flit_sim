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
# Omnet++ source is already in repository. Copy it to container
#RUN git clone https://github.com/mrkatebzadeh/omnetpp omnetpp-4.2.2/

# Set path for compilation
ENV PATH $PATH:/opt/ib/sim/omnetpp/bin

# Configure and compile Omnet++
#RUN cd omnetpp-4.2.2 && git pull && \
#    NO_TCL=1 xvfb-run ./configure && \
#    make -j 4

# Ib_flit_sim source is already in repository. Copy it to container
#RUN git clone https://github.com/mrkatebzadeh/ib_flit_sim /opt/omnetpp/ib_flit_sim/

ENV d /opt/ib/sim

#RUN cd /opt/omnetpp/mlx && d=`pwd` \
#    make makefiles; \
#    make -j 4; make MODE=release; make -Bnwk | compiledb -o compile_commands.json;

ENV NEDPATH $d/src:$d/examples

ENTRYPOINT service ssh restart && bash

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt
