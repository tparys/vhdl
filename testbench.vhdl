library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.sim_components.all;

-- Top Level Sim 
entity testbench is
end entity testbench;

-- Wiring up the bits
architecture sim of testbench is

  signal rst : std_logic;
  signal clk1mhz : std_logic;
  signal clk25mhz : std_logic;

  signal ang : signed(15 downto 0) := to_signed(0, 16);
  signal x_in : signed(15 downto 0) := to_signed(19800, 16);
  signal y_in : signed(15 downto 0) := to_signed(0, 16);

  signal x_rot : signed(15 downto 0);
  signal x_abs : unsigned(15 downto 0);

  signal dac_out : std_logic;

begin  -- architecture sim

  cr1 : clockreset
    generic map (
      CLK_MHZ => 1)
    port map (
      rst => rst,
      clk => clk1mhz);

  cr2 : clockreset
    generic map (
      CLK_MHZ => 25)
    port map (
      clk => clk25mhz);

  -- purpose: Provide a rotating angle
  process (clk1mhz, rst) is
  begin  -- process
    if rst = '1' then
      ang <= to_signed(0, 16);
    elsif clk1mhz'event and clk1mhz = '1' then  -- rising clock edge
      ang <= ang + 64;
    end if;
  end process;

  c0 : cordic
    generic map (
      STAGE_COUNT => 16,
      ANG_BITS  => 16,
      DATA_BITS => 16)
    port map (
      clk      => clk1mhz,
      rst      => rst,
      ang_in   => ang,
      x_in     => x_in,
      y_in     => y_in,
      y_out    => x_rot
      );

  -- purpose: Convert signed x_out to unsigned for DAC
  process (clk1mhz, rst) is
  begin  -- process
    if rst = '1' then

      x_abs <= to_unsigned(0, 16);
      
    elsif clk1mhz'event and clk1mhz = '1' then  -- rising clock edge

      x_abs <= unsigned(x_rot) + 32768;

    end if;
  end process;

  mydac : dac
    generic map (
      DATA_BITS => 16)
    port map (
      clk      => clk25mhz,
      rst      => rst,
      data_in  => x_abs,
      data_out => dac_out);

end architecture sim;
