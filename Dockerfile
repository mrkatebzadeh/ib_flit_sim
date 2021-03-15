FROM omnetpp/omnetpp-gui:u18.04-5.5.1

LABEL maintainer="M.R. Siavash Katebzadeh <mr.katebzadeh@gmail.com>"

LABEL Description="Docker image for Omnet++ version 4.2.2 and ib_flit_sim."

RUN apt-get update

# General dependencies
RUN apt-get install -y \
    build-essential \
    gdb \
    bison \
    flex \
    perl \
    python3-pip \
    libxml2-dev \
    zlib1g-dev \
    default-jre \
    doxygen \
    graphviz \
    openssh-server \
    xvfb

RUN apt-get clean && \
    rm -rf /var/lib/apt

RUN pip3 install compiledb
RUN pip3 install seaborn


RUN echo 'root:hi' | chpasswd
RUN cd /root/omnetpp && make -j 4 MODE=debug
# Create working directory
VOLUME ["/opt/ib"]
WORKDIR /opt/ib
#COPY ./mlx /opt/omnetpp/mlx

ENV DISPLAY :0

# Set path for compilation
ENV PATH $PATH:/opt/ib/sim/omnetpp/bin


ENV d /opt/ib/sim

ENV NEDPATH $d/src:$d/examples

USER root
#ENTRYPOINT service ssh restart && bash
#ENTRYPOINT bash

# Cleanup
