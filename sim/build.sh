#!/bin/sh

#CW=$(pwd)
#echo "Making Omnet++"
#cd omnetpp
#NO_TCL=0 xvfb-run ./configure
#make -j 4

#cd ${CW}
make makefiles
#make -Bnwk | compiledb -o compile_commands.json
#make MODE=release
make -j4 MODE=debug CC=gcc CXX=g++
#make -j 4