library ieee;
use ieee.std_logic_1164.all;

entity clockreset is
  generic (
    HOLD_RESET : time := 1 us;
    CLK_MHZ : integer := 25);
  port (
    rst : out std_logic;
    clk : out std_logic);
end entity clockreset;

architecture sim of clockreset is

  constant clk_period : time := 1 us / CLK_MHZ;

begin

  -- Reset Block
  process is
  begin
    rst <= '1';
    wait for HOLD_RESET;
    rst <= '0';
    wait;
  end process;

  -- Clock Generator
  process is
  begin  -- process
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

end architecture sim;
