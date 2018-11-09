# Project Trellis DVI

Simple verilog video example 
from [fpga4fun](https://www.fpga4fun.com/HDMI.html) shows
color test picture on DVI monitor.
It works on ULX3S with latest prjtrellis and specific branch of yosys.

get prjtrellis, pull its latest database and compile

    git clone https://github.com/SymbiFlow/prjtrellis
    cd prjtrellis
    ./download-latest-db.sh
    cd libtrellis
    cmake -DCMAKE_INSTALL_PREFIX=/usr .
    make

get yosys, get the ECP5 branch and compile

    git clone https://github.com/YosysHQ/yosys
    cd yosys
    git remote add dave https://github.com/daveshah1/yosys
    git pull dave
    git checkout ecp5_bb
    make config-gcc
    make 

get fresh nextpnr

    git clone https://github.com/YosysHQ/nextpnr
    cd nextpnr
    cmake -DARCH=ecp5 -DTRELLIS_ROOT=/path/to/prjtrellis .
    make

or recompile existing nextpnr

    cd nextpnr
    touch ecp5/trellis_import.py
    make clean
    make
