# ------------------------------------------------------------
# User config
# ------------------------------------------------------------
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# HDL sources for cocotb
VERILOG_SOURCES += $(PWD)/top.sv

# cocotb settings
COCOTB_TOPLEVEL = top
COCOTB_TEST_MODULES = test_top
# FPGA build settings
filename = top
pcf_file = ../common/iceBlinkPico.pcf

# ------------------------------------------------------------
# cocotb simulator include
# ------------------------------------------------------------
include $(shell cocotb-config --makefiles)/Makefile.sim

# ------------------------------------------------------------
# FPGA Build Targets
# ------------------------------------------------------------

# Build the FPGA bitstream
fpga-build:
	yosys -p "synth_ice40 -top $(filename) -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

# Program ICE40 (SRAM)
prog:
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

# Clean FPGA build artifacts
fpga-clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin
