library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package sim_components is

  -- Clock / Reset Block
  component clockreset is
    generic (
      HOLD_RESET : time := 1 us;
      CLK_MHZ : integer := 25);
    port (
      rst : out std_logic;
      clk : out std_logic);
  end component clockreset;

  -- Compute gain for a multi-stage CORDIC
  function cordic_gain (stage_count : integer) return real;

  component cordic_stage is
    generic (
      STAGE_NUM : integer;
      ANG_BITS  : integer;
      DATA_BITS : integer
      );
    port (
      rst     : in std_logic;
      clk     : in std_logic;
      ang_in  : in signed(ANG_BITS - 1 downto 0);
      x_in    : in signed(DATA_BITS - 1 downto 0);
      y_in    : in signed(DATA_BITS - 1 downto 0);
      ang_out : out signed(ANG_BITS - 1 downto 0);
      x_out   : out signed(DATA_BITS - 1 downto 0);
      y_out   : out signed(DATA_BITS - 1 downto 0)
      );  
  end component cordic_stage;

  component cordic is
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
  end component cordic;

  component dac is
    generic (
      DATA_BITS : integer := 16);
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      data_in  : in  unsigned(DATA_BITS - 1 downto 0);
      data_out : out std_logic);
  end component dac;

end package sim_components;

package body sim_components is

  function cordic_gain (stage_count : integer) return real is

    -- A simple counter
    variable i : integer;

    -- Initial value
    variable gain : real := 1.0;

    -- Iterative power
    variable pow : integer := 0;

    variable q : real;

  begin

    for i in 0 to stage_count - 1 loop
      gain := gain * SQRT(1.0 + (2.0 ** pow));
      pow := pow - 2;
    end loop;  -- i

    return gain;
    
  end function;

end package body sim_components;
