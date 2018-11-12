VHDL_OBJS += sim_components.o
VHDL_OBJS += clock.o
VHDL_OBJS += clockreset.o
VHDL_OBJS += i2c_sim.o i2c_slave.o
VHDL_OBJS += testbench.o
VHDL_TOP = testbench
SIM_LEN = 2000us
GHDL_OPTS = --std=08

.phony: all

all: $(VHDL_TOP)

$(VHDL_TOP): $(VHDL_OBJS)
	ghdl -e $(GHDL_OPTS) $@

%.o: %.vhdl
	ghdl -a $(GHDL_OPTS) $<

clean:
	rm -rf *.o *.cf *.vcd ${VHDL_TOP}

sim: $(VHDL_TOP) $(VHDL_OBJS)
	./$(VHDL_TOP) --stop-time=$(SIM_LEN) --vcd=wave.vcd
	gtkwave wave.vcd
