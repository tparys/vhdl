library ieee;
use ieee.std_logic_1164.all;
library work;

package sim_components is

  -- Clock Time Bases
  constant FREQ_HZ  : time := 1000 ms;
  constant FREQ_KHZ : time := 1 ms;
  constant FREQ_MHZ : time := 1 us;

  -- Clock
  component clock is
    generic (
      FREQ_BASE  : time;
      FREQ_VALUE : integer);
    port (
      clk : out std_logic);
  end component clock;

  -- Clock / Reset Block
  component clockreset is
    generic (
      HOLD_RESET : time := 1 us;
      FREQ_BASE  : time;
      FREQ_VALUE : integer);
    port (
      rst : out std_logic;
      clk : out std_logic);
  end component clockreset;

  component debounce is
    generic (
      COUNT_BITS : integer := 4
      );
    port (
      clk      : in  std_logic;
      data_in  : in  std_logic;
      data_out : out std_logic
      );
  end component debounce;

end package sim_components;
