# Project Trellis DVI

Simple verilog video example 
from [fpga4fun](https://www.fpga4fun.com/HDMI.html) shows
color test picture on DVI monitor.
It works on ULX3S with latest prjtrellis and specific branch of yosys.

get prjtrellis (it should autmatically pull its latest database) and compile

    git clone https://github.com/SymbiFlow/prjtrellis
    cd prjtrellis/libtrellis
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

In case of some errors, delete "CMakeCache.txt", change something like
quoting last arg in file "CMakeLists.txt" around line 123:

    -    STRING(REGEX REPLACE "[^0-9]" "" boost_py_version ${version})
    +    STRING(REGEX REPLACE "[^0-9]" "" boost_py_version "${version}")

If some older python file is missing, as a quick'n'drty fix just symlink
to the newer file that's currently installed:

    cd /usr/lib/x86_64-linux-gnu
    ln -s libpython3.7m.so libpython3.6m.so

To force-recompile existing nextpnr with newer prjtrellis database:

    cd nextpnr
    touch ecp5/trellis_import.py
    make clean
    make
