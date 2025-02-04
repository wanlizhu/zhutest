#!/bin/bash

cd ~/wzhutest
mkdir -p build
cd build
cmake ..
make
./wzhutest