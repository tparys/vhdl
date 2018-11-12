library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
  generic (
    COUNT_BITS : integer := 4
  );
  port (
    clk      : in  std_logic;
    data_in  : in  std_logic;
    data_out : out std_logic
  );
end entity debounce;

architecture impl of debounce is

  signal reg_in : std_logic_vector(1 downto 0) := (others => '0');

  signal reg_out : std_logic := '0';

  signal count : unsigned(COUNT_BITS downto 0) :=
    to_unsigned(0, COUNT_BITS + 1);

begin  -- architecture rtl

  process (clk) is
  begin
    if clk'event and clk = '1' then  -- rising clock edge

      -- Register inputs
      reg_in <= reg_in(0) & data_in;

      -- Detect edges
      if reg_in(0) /= reg_in(1) then

        -- Reset counter
        count <= to_unsigned(0, COUNT_BITS + 1);

      elsif count(COUNT_BITS) = '0' then

        -- Unstable input
        count <= count + 1;

      else

        -- Stable input
        reg_out <= reg_in(0);

      end if;
    end if;
  end process;

  data_out <= reg_out;

end architecture impl;
