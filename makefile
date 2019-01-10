# ******* project, board and chip name *******
PROJECT = dvi
BOARD = ulx3s
FPGA_SIZE = 85

# ******* design files *******
CONSTRAINTS = ulx3s_v20_segpdi.lpf
TOP_MODULE = top_dvitest_lpf
TOP_MODULE_FILE = $(TOP_MODULE).v
VERILOG_FILES = $(TOP_MODULE_FILE) DVI_test.v TMDS_encoder.v OBUFDS.v clocks/trellis/clk_25_125_250_25_83.v
# *.vhd those files will be converted to *.v files with vhdl2vl (warning overwriting/deleting)
VHDL_FILES = vhdl_blink.vhd

# synthesis options
YOSYS_OPTIONS = -noccu2

include scripts/ulx3s_trellis.mk
