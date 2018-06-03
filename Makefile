VHDL_OBJS += sim_components.o
VHDL_OBJS += clockreset.o
VHDL_OBJS += cordic_stage.o
VHDL_OBJS += cordic.o
VHDL_OBJS += dac.o
VHDL_OBJS += testbench.o
VHDL_TOP = testbench
SIM_LEN = 1000us

.phony: all

all: $(VHDL_TOP)

$(VHDL_TOP): $(VHDL_OBJS)
	ghdl -e $@

%.o: %.vhdl
	ghdl -a $<

clean:
	rm -rf *.o *.cf *.vcd

sim: $(VHDL_TOP) $(VHDL_OBJS)
	./$(VHDL_TOP) --stop-time=$(SIM_LEN) --vcd=wave.vcd
	gtkwave wave.vcd
