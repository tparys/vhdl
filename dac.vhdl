library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac is
  generic (
    DATA_BITS : integer := 16);
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    data_in  : in  unsigned(DATA_BITS - 1 downto 0);
    data_out : out std_logic);
end entity dac;

architecture default of dac is

  signal data_reg : unsigned(DATA_BITS - 1 downto 0) := to_unsigned(0, DATA_BITS);
  signal counter : unsigned(DATA_BITS downto 0) := to_unsigned(0, DATA_BITS + 1);
  
begin  -- architecture default

  process (clk, rst) is
  begin  -- process
    if rst = '1' then

      -- Reset
      data_reg <= to_unsigned(0, DATA_BITS);
      counter <= to_unsigned(0, DATA_BITS + 1);

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Register input value
      data_reg <= data_in;

      -- Increment counter, keeping overflow bit
      counter <= ('0' & counter(DATA_BITS - 1 downto 0)) +
                 ('0' & data_reg);

    end if;
  end process;

  -- Route overflow bit as output
  data_out <= counter(DATA_BITS);

end architecture default;
