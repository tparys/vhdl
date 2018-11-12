# Testbench sources
MODULE_SRC = debounce.vhdl testbench.vhdl
MODULE_TOP = testbench
MODULE_DEPS = modules/common
SIM_LEN = 100us

# Common ghdl build
export WORK_DIR ?= $(PWD)
export BUILD_DIR = $(PWD)/../build
include $(BUILD_DIR)/build.mk
