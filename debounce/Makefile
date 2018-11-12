VHDL_OBJS += sim_components.o
VHDL_OBJS += clock.o
VHDL_OBJS += clockreset.o
VHDL_OBJS += debounce.o
VHDL_OBJS += testbench.o
VHDL_TOP = testbench
SIM_LEN = 100us

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
