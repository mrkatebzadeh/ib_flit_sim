#!/bin/sh

CW=$(pwd)
echo "Making Omnet++"
cd omnetpp
NO_TCL=1 xvfb-run ./configure
make -j 4

cd ${CW}
make makefiles
make -Bnwk | compiledb -o compile_commands.json
