# ******* project, board and chip name *******
PROJECT = dvi
BOARD = ulx3s
# 12 25 45 85
FPGA_SIZE = 25

# ******* design files *******
CONSTRAINTS = constraints/ulx3s_v20_segpdi.lpf
TOP_MODULE = top_vgatest
TOP_MODULE_FILE = hdl/$(TOP_MODULE).v

CLK0_NAME = clk_25_250_125_25_100
CLK0_FILE_NAME = clocks/$(CLK0_NAME).v
CLK0_OPTIONS = \
  --input=25 \
  --output=250 \
  --s1=125 \
  --p1=0 \
  --s2=25 \
  --p2=0 \
  --s3=100 \
  --p3=0

VERILOG_FILES = \
  $(TOP_MODULE_FILE) \
  $(CLK0_FILE_NAME) \
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
