library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

package i2c_sim is

  constant I2C_PERIOD : time := 10 us;   -- 100 kHz

  -- Write start bit to I2C bus
  procedure i2c_write_start_bit (
    signal scl : inout std_logic;
    signal sda : inout std_logic);

  -- Write stop bit to I2C bus
  procedure i2c_write_stop_bit (
    signal scl : inout std_logic;
    signal sda : inout std_logic);

  -- Write data bit to I2C bus
  procedure i2c_write_data_bit (
    signal scl : inout std_logic;
    signal sda : inout std_logic;
    constant data : in std_logic);

  -- Write 8 bit data to I2C bus
  procedure i2c_write_byte (
    signal scl : inout std_logic;
    signal sda : inout std_logic;
    constant data : in std_logic_vector(7 downto 0));

  -- Read data bit from I2C bus
  procedure i2c_read_data_bit (
    signal scl  : inout std_logic;
    signal sda  : inout std_logic;
    signal data : out std_logic);

  -- Read 8 bit data from I2C bus
  procedure i2c_read_byte (
    signal scl  : inout std_logic;
    signal sda  : inout std_logic;
    signal data : inout std_logic_vector(7 downto 0));
  
end package i2c_sim;

package body i2c_sim is

  -- Write start bit to I2C bus
  procedure i2c_write_start_bit (
    signal scl : inout std_logic;
    signal sda : inout std_logic) is
  begin

    -- Initial Transition
    sda <= 'Z';
    wait for I2C_PERIOD / 2;
    scl <= 'Z';

    -- First transition
    wait for I2C_PERIOD / 2;
    sda <= '0';

    -- Second transition
    wait for I2C_PERIOD / 2;
    scl <= 'Z';

  end procedure i2c_write_start_bit;
    
  -- Write stop bit to I2C bus
  procedure i2c_write_stop_bit (
    signal scl : inout std_logic;
    signal sda : inout std_logic) is
  begin

    -- Initial state
    scl <= '0';
    sda <= '0';

    -- First transition
    wait for I2C_PERIOD / 2;
    scl <= 'Z';

    -- Second transition
    wait for I2C_PERIOD / 2;
    sda <= 'Z';

  end procedure i2c_write_stop_bit;

  -- Write data bit to I2C bus
  procedure i2c_write_data_bit (
    signal scl : inout std_logic;
    signal sda : inout std_logic;
    constant data : in std_logic) is
  begin

    -- Start of data bit
    if data = '0' then
      sda <= '0';
    else
      sda <= 'Z';
    end if;

    -- Clock
    scl <= '0';
    wait for I2C_PERIOD / 4;
    scl <= 'Z';
    wait for I2C_PERIOD / 2;
    scl <= '0';
    wait for I2C_PERIOD / 4;
    scl <= 'Z';

    -- End of data bit
    sda <= 'Z';

  end procedure i2c_write_data_bit;

  -- Write 8 bit data to I2C bus
  procedure i2c_write_byte (
    signal scl : inout std_logic;
    signal sda : inout std_logic;
    constant data : in std_logic_vector(7 downto 0)) is
  begin

    -- Fire off data bits MSB first
    for i in 7 downto 0 loop
      i2c_write_data_bit(scl, sda, data(i));
    end loop;

    -- Sense ACK
    scl <= '0';
    wait for I2C_PERIOD / 4;
    scl <= 'Z';
    wait for I2C_PERIOD / 4;
    assert sda = '0' report "I2C write not acknowledged" severity error;
    wait for I2C_PERIOD / 4;
    scl <= '0';
    wait for I2C_PERIOD / 4;
    

  end procedure i2c_write_byte;

  -- Read data bit from I2C bus
  procedure i2c_read_data_bit (
    signal scl  : inout std_logic;
    signal sda  : inout std_logic;
    signal data : out std_logic) is
  begin

    -- Not driving data
    sda <= 'Z';

    -- Clock
    scl <= '0';
    wait for I2C_PERIOD / 4;
    scl <= 'Z';
    wait for I2C_PERIOD / 4;
    data <= to_x01(sda);
    wait for I2C_PERIOD / 4;
    scl <= '0';
    wait for I2C_PERIOD / 4;
    scl <= 'Z';

  end procedure i2c_read_data_bit;

  -- Read 8 bit data from I2C bus
  procedure i2c_read_byte (
    signal scl  : inout std_logic;
    signal sda  : inout std_logic;
    signal data : inout std_logic_vector(7 downto 0)) is
  begin

    -- Fire off data bits MSB first
    i2c_read_data_bit(scl, sda, data(7));
    i2c_read_data_bit(scl, sda, data(6));
    i2c_read_data_bit(scl, sda, data(5));
    i2c_read_data_bit(scl, sda, data(4));
    i2c_read_data_bit(scl, sda, data(3));
    i2c_read_data_bit(scl, sda, data(2));
    i2c_read_data_bit(scl, sda, data(1));
    i2c_read_data_bit(scl, sda, data(0));

    -- Send ACK
    i2c_write_data_bit(scl, sda, '0');

    --report "I2C READ=" & integer'image(to_integer(unsigned(data)));
    report "I2C READ=0x" & to_hstring(unsigned(data));

  end procedure i2c_read_byte;


end package body i2c_sim;
