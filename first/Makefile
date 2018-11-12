# Testbench sources
MODULE_SRC = cordic_pkg.vhdl cordic_stage.vhdl cordic.vhdl dac.vhdl testbench.vhdl
MODULE_TOP = testbench
MODULE_DEPS = modules/common
SIM_LEN = 1000us

# Common ghdl build
export WORK_DIR ?= $(PWD)
export BUILD_DIR = $(PWD)/../build
include $(BUILD_DIR)/build.mk
