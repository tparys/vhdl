library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cordic_pkg is

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

  component dac is
    generic (
      DATA_BITS : integer := 16);
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      data_in  : in  unsigned(DATA_BITS - 1 downto 0);
      data_out : out std_logic);
  end component dac;

end package cordic_pkg;
