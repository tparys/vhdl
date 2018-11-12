library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.common_pkg.all;
use work.cordic_pkg.all;

entity cordic is
  generic (
    STAGE_COUNT : integer;
    ANG_BITS    : integer;
    DATA_BITS   : integer);
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    ang_in : in  signed(ANG_BITS - 1 downto 0);
    x_in   : in  signed(DATA_BITS - 1 downto 0);
    y_in   : in  signed(DATA_BITS - 1 downto 0);
    x_out  : out signed(DATA_BITS - 1 downto 0);
    y_out  : out signed(DATA_BITS - 1 downto 0));
end entity cordic;

architecture default of cordic is

  -- Make intermediate signals for CORDIC stages
  type ang_chain is array(natural range <>) of signed(ANG_BITS - 1 downto 0);
  type data_chain is array(natural range <>) of signed(DATA_BITS - 1 downto 0);
  signal ang_buffers : ang_chain(STAGE_COUNT downto 0);
  signal x_buffers : data_chain(STAGE_COUNT downto 0);
  signal y_buffers : data_chain(STAGE_COUNT downto 0);

  signal offset180 : signed(ANG_BITS - 1 downto 0) := ('1', others => '0');

begin  -- architecture default

  -- Handle angles in 2nd & 3rd quadrants
  process (clk, rst) is
  begin  -- process
    if rst = '1' then

      ang_buffers(0) <= to_signed(0, ANG_BITS);
      x_buffers(0) <= to_signed(0, DATA_BITS);
      y_buffers(0) <= to_signed(0, DATA_BITS);

    elsif clk'event and clk = '1' then  -- rising clock edge

      if ang_in(ANG_BITS - 1) = ang_in(ANG_BITS - 2) then

        -- Keep input in 1st or 4th quadrant
        ang_buffers(0) <= ang_in;
        x_buffers(0) <= x_in;
        y_buffers(0) <= y_in;
      
      else

        -- Rotate 180 deg to be in 1st or 4th quadrant
        ang_buffers(0) <= ang_in + offset180;
        x_buffers(0) <= 0 - x_in;
        y_buffers(0) <= 0 - y_in;
        
      end if;
    end if;
  end process;

  -- Generate each stage in sequence
  gen: for STAGE in 0 to STAGE_COUNT - 1 generate
    c : cordic_stage
      generic map (
        STAGE_NUM => STAGE,
        ANG_BITS  => ANG_BITS,
        DATA_BITS => DATA_BITS)
      port map (
        clk      => clk,
        rst      => rst,
        ang_in   => ang_buffers(STAGE),
        x_in     => x_buffers(STAGE),
        y_in     => y_buffers(STAGE),
        ang_out  => ang_buffers(STAGE + 1),
        x_out    => x_buffers(STAGE + 1),
        y_out    => y_buffers(STAGE + 1));
  end generate gen;

  -- End the chain
  x_out <= x_buffers(STAGE_COUNT);
  y_out <= y_buffers(STAGE_COUNT);

end architecture default;
