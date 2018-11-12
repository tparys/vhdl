library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sim_components.all;

entity clock is
  generic (
    FREQ_BASE  : time := FREQ_MHZ;
    FREQ_VALUE : integer := 1);
  port (
    clk : out std_logic);
end entity clock;

architecture sim of clock is

  signal clk_period : time := FREQ_BASE / FREQ_VALUE;

begin

  -- Clock Generator
  process is
  begin  -- process
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

end architecture sim;
