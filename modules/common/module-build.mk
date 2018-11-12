WORK_DIR ?= $(PWD)
MODULE_DIR = $(PWD)
MODULE_SRC = common_pkg.vhdl clockreset.vhdl clock.vhdl

include $(BUILD_DIR)/build.mk
