library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sim_components.all;

-- Top Level Sim 
entity testbench is
end entity testbench;

-- Wiring up the bits
architecture sim of testbench is

  signal rst : std_logic;
  signal clk : std_logic;

  signal sig1 : std_logic;
  signal sig2 : std_logic;
  signal deb1 : std_logic;
  signal deb2 : std_logic;
      
begin  -- architecture sim

  cr : clockreset
    generic map (
      FREQ_BASE => FREQ_MHZ,
      FREQ_VALUE => 100)
    port map (
      rst => rst,
      clk => clk);

  -- Signal gen 1
  g1: clock
    generic map (
      FREQ_BASE  => FREQ_KHZ,
      FREQ_VALUE => 115)
    port map (
      clk => sig1);

  -- Signal gen 2
  g2: clock
    generic map (
      FREQ_BASE  => FREQ_KHZ,
      FREQ_VALUE => 714)
    port map (
      clk => sig2);

  -- Debounce 1
  d1: debounce
    generic map (
      COUNT_BITS => 7)
    port map (
      clk      => clk,
      data_in  => sig1,
      data_out => deb1);
    
  -- Debounce 2
  d2: debounce
    generic map (
      COUNT_BITS => 7)
    port map (
      clk      => clk,
      data_in  => sig2,
      data_out => deb2);

end architecture sim;
