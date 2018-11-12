export GHDL_OPTS = --std=08 --workdir=$(WORK_DIR)
MODULE_OBJ= $(MODULE_SRC:%.vhdl=$(WORK_DIR)/%.o)
WAVE_OUT ?= wave.vcd

.phony: all

# Build anything we can ...
all: $(MODULE_DEPS) $(MODULE_OBJ) $(MODULE_TOP)

# Build 

# Rule to build VHDL to the work directory
$(WORK_DIR)/%.o: %.vhdl
	ghdl -a $(GHDL_OPTS) $<

# Build modules
modules/%:
	cd $(BUILD_DIR)/../$@ && make -f module-build.mk

# Elaborate top level entity
$(MODULE_TOP): $(MODULE_DEPS) $(MODULE_OBJ) 
	ghdl -e $(GHDL_OPTS) $@

# Simulate
sim: $(MODULE_TOP)
	./$(MODULE_TOP) --stop-time=$(SIM_LEN) --vcd=$(WAVE_OUT)
	gtkwave $(WAVE_OUT)

# Cleanup rule
clean:
	rm -f *.o *.cf $(WAVE_OUT) $(MODULE_TOP)
