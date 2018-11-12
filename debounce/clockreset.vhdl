library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sim_components.all;

entity clockreset is
  generic (
    HOLD_RESET : time := 1 us;
    FREQ_BASE  : time := FREQ_MHZ;
    FREQ_VALUE : integer := 1);
  port (
    rst : out std_logic;
    clk : out std_logic);
end entity clockreset;

architecture sim of clockreset is

begin

  -- Reset Block
  process is
  begin
    rst <= '1';
    wait for HOLD_RESET;
    rst <= '0';
    wait;
  end process;

  clk_inst: clock
    generic map (
      FREQ_BASE  => FREQ_BASE,
      FREQ_VALUE => FREQ_VALUE)
    port map (
      clk => clk);

end architecture sim;
