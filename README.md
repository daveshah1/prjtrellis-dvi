# Project Trellis DVI

Simple verilog DVI video example.
It works with latest prjtrellis and specific branch of yosys.

in yosys, get the branch

    git remote add dave https://github.com/daveshah1/yosys
    git pull dave
    git checkout ecp5_bb

rebuild nextpnr

    touch ecp5/trellis_import.py
    make clean
    make
