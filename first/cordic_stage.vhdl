library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_stage is
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
end entity cordic_stage;

architecture default of cordic_stage is

  -- Half the value of tan(rotation) at each step
  constant rot_tan : real := 2.0 ** (-1.0 * real(STAGE_NUM));

  -- Compute the rotation angle
  constant rot_ang : real := ARCTAN(rot_tan);

  -- Convert to angle
  constant rot_int : integer := integer(rot_ang * (2.0 ** (ANG_BITS - 1)) / MATH_PI);

  -- And to a signal that we can +/-
  signal rot : signed(ANG_BITS - 1 downto 0) := to_signed(rot_int, ANG_BITS);

  -- Register internal values
  signal ang_reg : signed(ANG_BITS - 1 downto 0) := to_signed(0, ANG_BITS);
  signal x_reg : signed(DATA_BITS - 1 downto 0) := to_signed(0, DATA_BITS);
  signal y_reg : signed(DATA_BITS - 1 downto 0) := to_signed(0, DATA_BITS);

begin  -- architecture default

  process (clk, rst) is
  begin
    if rst = '1' then

      -- Async reset
      ang_reg <= to_signed(0, ANG_BITS);
      x_reg <= to_signed(0, DATA_BITS);
      y_reg <= to_signed(0, DATA_BITS);

    elsif clk'event and clk = '1' then  -- rising clock edge

      if ang_in(ANG_BITS - 1) = '1' then

        -- Remaining angle is positive, rotate negative
        ang_reg <= ang_in + rot;
        x_reg <= x_in + shift_right(y_in, STAGE_NUM);
        y_reg <= y_in - shift_right(x_in, STAGE_NUM);

      else

        -- Remaining angle is negative, rotate positive
        ang_reg <= ang_in - rot;
        x_reg <= x_in - shift_right(y_in, STAGE_NUM);
        y_reg <= y_in + shift_right(x_in, STAGE_NUM);

      end if;

    end if;
  end process;

  -- Route outputs
  ang_out <= ang_reg;
  x_out <= x_reg;
  y_out <= y_reg;

end architecture default;
