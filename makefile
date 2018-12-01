PROJECT=dvi
BOARD=ulx3s
FPGA_SIZE=85
FPGA_CHIP=lfe5u-$(FPGA_SIZE)f
# https://github.com/ldoolitt/vhd2vl
VHDL2VL=/mt/scratch/tmp/openfpga/vhd2vl/src/vhd2vl
# https://github.com/YosysHQ/yosys
YOSYS=/mt/scratch/tmp/openfpga/yosys/yosys
# https://github.com/YosysHQ/nextpnr
NEXTPNR-ECP5=/mt/scratch/tmp/openfpga/nextpnr/nextpnr-ecp5
# https://github.com/SymbiFlow/prjtrellis
TRELLIS=/mt/scratch/tmp/openfpga/prjtrellis
ECPPACK=$(TRELLIS)/libtrellis/ecppack
TRELLISDB=$(TRELLIS)/database
LIBTRELLIS=$(TRELLIS)/libtrellis
BIT2SVF=$(TRELLIS)/tools/bit_to_svf.py
BASECFG=$(TRELLIS)/misc/basecfgs/empty_$(FPGA_CHIP).config
TINYFPGASP=tinyfpgasp
FLEAFPGA_JTAG=FleaFPGA-JTAG 
OPENOCD=openocd_ft232r
UJPROG=ujprog
DIAMOND_BASE := /usr/local/diamond
DIAMOND_BIN :=  $(shell find ${DIAMOND_BASE}/ -maxdepth 2 -name bin | sort -rn | head -1)
DIAMONDC := $(shell find ${DIAMOND_BIN}/ -name diamondc)
DDTCMD := $(shell find ${DIAMOND_BIN}/ -name ddtcmd)
FPGA_CHIP_UPPERCASE := $(shell echo $(FPGA_CHIP) | tr '[:lower:]' '[:upper:]')

# design files
CONSTRAINTS=ulx3s_v20_segpdi.lpf
TOP_MODULE=top_dvitest_lpf
VERILOG_FILES=$(TOP_MODULE).v DVI_test.v TMDS_encoder.v OBUFDS.v clock.v
# implicit list of *.vhd VHDL files to be converted to verilog *.v
# files here are list as *.v but user should
# edit original source which has *.vhd extension (vhdl_blink.vhd)
VHDL_TO_VERILOG_FILES=vhdl_blink.v

ifeq ($(FPGA_SIZE), 12)
  FPGA_K=25
else
  FPGA_K=$(FPGA_SIZE)
endif

ifeq ($(FPGA_CHIP), lfe5u-12f)
  CHIP_ID=0x21111043
endif
ifeq ($(FPGA_CHIP), lfe5u-25f)
  CHIP_ID=0x41111043
endif
ifeq ($(FPGA_CHIP), lfe5u-45f)
  CHIP_ID=0x41112043
endif
ifeq ($(FPGA_CHIP), lfe5u-85f)
  CHIP_ID=0x41113043
endif

#all: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).vme $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf
all: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf

# VHDL to VERILOG conversion
%.v: %.vhd
	$(VHDL2VL) $< $@

#*.v: *.vhdl
#	$(VHDL2VL) $< $@

$(PROJECT).ys: makefile
	./ysgen.sh $(VERILOG_FILES) $(VHDL_TO_VERILOG_FILES) > $@
	echo "hierarchy -top ${TOP_MODULE}" >> $@
	echo "synth_ecp5 -noccu2 -nomux -nodram -json ${PROJECT}.json" >> $@

$(PROJECT).json: $(PROJECT).ys $(VERILOG_FILES) $(VHDL_TO_VERILOG_FILES)
	$(YOSYS) $(PROJECT).ys 

$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config: $(PROJECT).json $(BASECFG)
	$(NEXTPNR-ECP5) --$(FPGA_K)k --json $(PROJECT).json --lpf $(CONSTRAINTS) --basecfg $(BASECFG) --textcfg $@

$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config
	LANG=C LD_LIBRARY_PATH=$(LIBTRELLIS) $(ECPPACK) --db $(TRELLISDB) --input $< --bit $@

# dummy file needed for xsltproc
DTD_FILE=IspXCF.dtd
$(DTD_FILE):
	touch $(DTD_FILE)

# generate XCF programming file for DDTCMD
$(BOARD)_$(FPGA_SIZE)f.xcf: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit $(BOARD)_sram.xml xcf.xsl $(DTD_FILE)
	xsltproc \
	  --stringparam FPGA_CHIP $(FPGA_CHIP_UPPERCASE) \
	  --stringparam CHIP_ID $(CHIP_ID) \
	  --stringparam BITSTREAM_FILE $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit \
	  xcf.xsl $(BOARD)_sram.xml > $@

# run DDTCMD to generate VME file
$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).vme: $(BOARD)_$(FPGA_SIZE)f.xcf $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
	LANG=C ${DDTCMD} -oft -fullvme -if $(BOARD)_$(FPGA_SIZE)f.xcf -nocompress -noheader -of $@

# run DDTCMD to generate SVF file
#$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf: $(BOARD)_$(FPGA_SIZE)f.xcf $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
#	LANG=C ${DDTCMD} -oft -svfsingle -revd -maxdata 8 -if $(BOARD)_$(FPGA_SIZE)f.xcf -of $@

# generate SVF file by prjtrellis python script
#$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
#	$(BIT2SVF) $< $@

$(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config
	LD_LIBRARY_PATH=$(LIBTRELLIS) $(ECPPACK) --db $(TRELLISDB) $< --freq 62.0 --svf-rowsize 8000 --svf $@

# program SRAM  with ujrprog (temporary)
program: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
	$(UJPROG) $<

# program SRAM  with FleaFPGA-JTAG (temporary)
program_flea: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).vme
	$(FLEAFPGA_JTAG) $<

# program FLASH with tinyfpgasp bootloader (permanently)
program_flash: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
	$(TINYFPGASP) -w $<

# generate chip-specific openocd programming file
$(BOARD)_$(FPGA_SIZE)f.ocd: makefile ecp5-ocd.sh
	./ecp5-ocd.sh $(CHIP_ID) $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf > $@

# program SRAM with OPENOCD using onboard ft231y (temporary)
program_ocd: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf $(BOARD)_$(FPGA_SIZE)f.ocd
	$(OPENOCD) --file=ft231x.ocd --file=$(BOARD)_$(FPGA_SIZE)f.ocd

# program SRAM with OPENOCD with jtag pass-thru to another board
program_ocd_thru: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf $(BOARD)_$(FPGA_SIZE)f.ocd
	$(OPENOCD) --file=ft231x2.ocd --file=$(BOARD)_$(FPGA_SIZE)f.ocd

# program SRAM with OPENOCD with external ft232r module
program_ft232r: $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf $(BOARD)_$(FPGA_SIZE)f.ocd
	$(OPENOCD) --file=ft232r.ocd --file=$(BOARD)_$(FPGA_SIZE)f.ocd

JUNK = *~
JUNK += $(PROJECT).ys
JUNK += $(PROJECT).json
JUNK += $(VHDL_TO_VERILOG_FILES)
JUNK += $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).config
JUNK += $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).bit
JUNK += $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).vme
JUNK += $(BOARD)_$(FPGA_SIZE)f_$(PROJECT).svf
JUNK += $(BOARD)_$(FPGA_SIZE)f.xcf
JUNK += $(BOARD)_$(FPGA_SIZE)f.ocd
JUNK += $(DTD_FILE)

clean:
	rm -f $(JUNK)
