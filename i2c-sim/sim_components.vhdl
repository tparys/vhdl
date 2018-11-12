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

  type byte_vector is array (integer range <>) of std_logic_vector(7 downto 0);

  component i2c_slave is
    generic (
      I2C_ADDRESS : std_logic_vector(6 downto 0) := "0101111";
      REG_COUNT   : integer := 16);
    port (
      rst     : in    std_logic;
      scl     : inout std_logic;
      sda     : inout std_logic;
      reg_in  : in    byte_vector(REG_COUNT - 1 downto 0);
      reg_out : out   byte_vector(REG_COUNT - 1 downto 0));
  end component i2c_slave;

end package sim_components;
