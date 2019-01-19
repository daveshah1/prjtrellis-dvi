# ******* project, board and chip name *******
PROJECT = dvi
BOARD = ulx3s
# 12 25 45 85
FPGA_SIZE = 12

# ******* design files *******
CONSTRAINTS = constraints/ulx3s_v20_segpdi.lpf
TOP_MODULE = top_vgatest
TOP_MODULE_FILE = hdl/$(TOP_MODULE).v
VERILOG_FILES = \
  $(TOP_MODULE_FILE) \
  clocks/trellis/clk_25_125_250_25_83.v \
  hdl/fake_differential.v

# *.vhd those files will be converted to *.v files with vhdl2vl (warning overwriting/deleting)
VHDL_FILES = \
  hdl/blink.vhd \
  hdl/vga.vhd \
  hdl/vga2dvid.vhd \
  hdl/tmds_encoder.vhd

# synthesis options
#YOSYS_OPTIONS = -noccu2

include scripts/ulx3s_trellis.mk
