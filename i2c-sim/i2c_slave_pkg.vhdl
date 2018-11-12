library ieee;
use ieee.std_logic_1164.all;
library work;

package i2c_slave_pkg is

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

end package i2c_slave_pkg;
