# Testbench sources
MODULE_SRC = i2c_slave_pkg.vhdl i2c_sim.vhdl i2c_slave.vhdl testbench.vhdl
MODULE_TOP = testbench
MODULE_DEPS = modules/common
SIM_LEN = 2000us

# Common ghdl build
export WORK_DIR ?= $(PWD)
export BUILD_DIR = $(PWD)/../build
include $(BUILD_DIR)/build.mk
