# ******* project, board and chip name *******
PROJECT ?= dvi
BOARD ?= ulx3s
FPGA_SIZE ?= 25

# ******* design files *******
CONSTRAINTS ?= ulx3s_v20_segpdi.lpf
TOP_MODULE ?= top_dvitest_lpf
VERILOG_FILES ?= $(TOP_MODULE).v DVI_test.v TMDS_encoder.v OBUFDS.v clock.v
# implicit list of *.vhd VHDL files to be converted to verilog *.v
# files here are list as *.v but user should
# edit original source which has *.vhd extension (vhdl_blink.vhd)
VHDL_TO_VERILOG_FILES ?= vhdl_blink.v

# synthesis options
YOSYS_OPTIONS = -noccu2

include scripts/ulx3s_trellis.mk
