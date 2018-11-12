library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.i2c_slave_pkg.all;

entity i2c_slave is
  generic (
    I2C_ADDRESS : std_logic_vector(6 downto 0) := "0101111";
    REG_COUNT   : integer := 16);
  port (
    rst     : in    std_logic;
    scl     : inout std_logic;
    sda     : inout std_logic;
    reg_in  : in    byte_vector(REG_COUNT - 1 downto 0);
    reg_out : out   byte_vector(REG_COUNT - 1 downto 0));
end entity i2c_slave;

architecture impl of i2c_slave is

  signal sclr : std_logic;
  signal sdar : std_logic;

  signal start_detect : std_logic := '0';
  signal start_resetter : std_logic := '0';
  signal start_rst : std_logic;

  signal stop_detect : std_logic := '0';
  signal stop_resetter : std_logic := '0';
  signal stop_rst : std_logic;

  signal bit_counter : integer range 0 to 8 := 0;
  signal lsb_bit : std_logic;
  signal ack_bit : std_logic;

  signal input_shift : std_logic_vector(7 downto 0) := (others => '0');
  signal address_detect : std_logic;
  signal read_write_bit : std_logic;
  signal master_ack : std_logic := '0';

  type state_t is (STATE_IDLE, STATE_DEV_ADDR, STATE_READ,
                   STATE_IDX_PTR, STATE_WRITE);
  signal state : state_t := STATE_IDLE;
  signal state_dbug : integer range 0 to 5;
  signal write_strobe : std_logic;

  signal index_pointer : integer range 0 to 255 := 0;

  signal output_shift : std_logic_vector(7 downto 0) := (others => '0');

  signal output_control : std_logic := '1';

begin

  -- GTKwave won't display enumerations
  with state select
    state_dbug <=
    1 when STATE_IDLE,
    2 when STATE_DEV_ADDR,
    3 when STATE_READ,
    4 when STATE_IDX_PTR,
    5 when STATE_WRITE,
    0 when others;

  -- Output drivers

  scl <= 'Z';
  sda <= 'Z';

  -- Resolve pullups

  sclr <= to_x01(scl);
  sdar <= to_x01(sda);

  -- Start Detection

  start_rst <= rst or start_resetter;

  process (sdar, start_rst) is
  begin
    if start_rst = '1' then
      start_detect <= '0';
    elsif falling_edge(sdar) then
      start_detect <= sclr;
    end if;
  end process;

  process (sclr) is
  begin
    if rising_edge(sclr) then
      start_resetter <= start_detect;
    end if;
  end process;

  -- Stop Detection

  stop_rst <= rst or stop_resetter;

  process (sdar, stop_rst) is
  begin
    if stop_rst = '1' then
      stop_detect <= '0';
    elsif rising_edge(sdar) then
      stop_detect <= sclr;
    end if;
  end process;

  process (sclr) is
  begin
    if rising_edge(sclr) then
      stop_resetter <= stop_detect;
    end if;
  end process;

  -- Latching input data

  lsb_bit <= not start_detect when bit_counter = 7 else '0';
  ack_bit <= not start_detect when bit_counter = 8 else '0';

  process (sclr) is
  begin
    if falling_edge(sclr) then
      if ack_bit = '1' or start_detect = '1' then
        bit_counter <= 0;
      else
        bit_counter <= bit_counter + 1;
      end if;
    end if;
  end process;

  address_detect <= '1' when input_shift(7 downto 1) = I2C_ADDRESS else '0';
  read_write_bit <= input_shift(0);

  process (sclr) is
  begin
    if rising_edge(sclr) then
      if ack_bit = '0' then
        input_shift <= input_shift(6 downto 0) & sdar;
      end if;
    end if;
  end process;

  process (sclr) is
  begin
    if rising_edge(sclr) then
      if ack_bit = '1' then
        master_ack <= not sdar;
      end if;
    end if;
  end process;
  
  -- State Machine

  write_strobe <= ack_bit when state = STATE_WRITE else '0';

  process (sclr, rst) is
  begin
    if rst = '1' then
      state <= STATE_IDLE;
    elsif falling_edge(sclr) then
      if start_detect = '1' then
        state <= STATE_DEV_ADDR;
      elsif ack_bit = '1' then
        case state is

          when STATE_DEV_ADDR =>
            if address_detect = '0' then
              state <= STATE_IDLE;
            elsif read_write_bit = '1' then
              state <= STATE_READ;
            else
              state <= STATE_IDX_PTR;
            end if;

          when STATE_READ =>
            if master_ack = '1' then
              state <= STATE_READ;
            else
              state <= STATE_IDLE;
            end if;

          when STATE_IDX_PTR =>
            state <= STATE_WRITE;

          when STATE_WRITE =>
            state <= STATE_WRITE;

          when others =>
            state <= STATE_IDLE;

        end case;
      end if;
    end if;
  end process;

  -- Register transfers

  process (sclr, rst) is
  begin
    if rst = '1' then
      index_pointer <= 0;
    elsif falling_edge(sclr) then
      if stop_detect = '1' then
        index_pointer <= 0;
      elsif ack_bit = '1' then
        if state = STATE_IDX_PTR then
          index_pointer <= to_integer(unsigned(input_shift));
          report "Setting index pointer to " & integer'image(to_integer(unsigned(input_shift))) severity note;
        else
          index_pointer <= index_pointer + 1;
        end if;
      end if;
    end if;
  end process;

  reg_gen: for i in 0 to REG_COUNT - 1 generate

    process (sclr, rst) is
    begin
      if rst = '1' then
        reg_out(i) <= (others => '0');
      elsif falling_edge(sclr) then
        if write_strobe = '1' and index_pointer = i then
          reg_out(i) <= input_shift;
        end if;
      end if;
    end process;
    
  end generate reg_gen;

  process (sclr) is
  begin
    if falling_edge(sclr) then
      if lsb_bit = '1' then
        output_shift <= x"ff";
        for i in 0 to REG_COUNT - 1 loop
          if index_pointer = i then
            output_shift <= reg_in(index_pointer);
          end if;
        end loop;
      else
        output_shift <= output_shift(6 downto 0) & '0';
      end if;
    end if;
  end process;

  -- Output driver

  sda <= 'Z' when output_control = '1' else '0';

  process (sclr, rst) is
  begin
    if rst = '1' then
      output_control <= '1';
    elsif falling_edge(sclr) then

      -- Default state - driver off
      output_control <= '1';

      if start_detect = '0' then
        case state is

          when STATE_DEV_ADDR =>
            if lsb_bit = '1' then
              output_control <= not address_detect;
            end if;

          when STATE_READ =>
            if ack_bit = '1' then
              if master_ack = '1' then
                output_control <= output_shift(7);
              end if;
            else
              output_control <= output_shift(7);
            end if;

          when STATE_IDX_PTR =>
            if lsb_bit = '1' then
              output_control <= '0';
            end if;

          when STATE_WRITE =>
            if lsb_bit = '1' then
              output_control <= '0';
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

end architecture impl;
