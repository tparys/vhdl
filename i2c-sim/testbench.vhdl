library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sim_components.all;
use work.i2c_sim.all;

-- Top Level Sim 
entity testbench is
end entity testbench;

-- Wiring up the bits
architecture sim of testbench is

  constant REG_COUNT : integer := 4;

  signal rst : std_logic;
  signal clk : std_logic;
  signal scl : std_logic;
  signal sda : std_logic;
  signal data : std_logic_vector(7 downto 0) := x"ff";
  signal regs : byte_vector(REG_COUNT - 1 downto 0);
  signal reg0 : std_logic_vector(7 downto 0);
  signal reg1 : std_logic_vector(7 downto 0);
  signal reg2 : std_logic_vector(7 downto 0);
  signal reg3 : std_logic_vector(7 downto 0);
  
begin  -- architecture sim

  cr : clockreset
    generic map (
      FREQ_BASE => FREQ_HZ,
      FREQ_VALUE => 1)
    port map (
      rst => rst,
      clk => clk);

  slave : i2c_slave
    generic map (
      I2C_ADDRESS => "0100000",
      REG_COUNT => REG_COUNT
    )
    port map (
      rst     => rst,
      scl     => scl,
      sda     => sda,
      reg_in  => regs,
      reg_out => regs);

  -- GTK Wave doesn't display vectors of vectors
  reg0 <= regs(0);
  reg1 <= regs(1);
  reg2 <= regs(2);
  reg3 <= regs(3);

  -- Pull ups
  scl <= 'H';
  sda <= 'H';

  -- Test writes
  process is
  begin

    scl <= 'Z';
    sda <= 'Z';

    -- LSB of address (0=write, 1=read)

    ----
    -- Write Data to Registers
    --

    -- Start write to 0x20
    i2c_write_start_bit(scl, sda);
    i2c_write_byte(scl, sda, x"40");

    -- Index pointer
    i2c_write_byte(scl, sda, x"00");

    -- Data
    i2c_write_byte(scl, sda, x"aa");
    i2c_write_byte(scl, sda, x"bb");
    i2c_write_byte(scl, sda, x"cc");

    -- End of operation
    i2c_write_stop_bit(scl, sda);

    ----
    -- Read Data from Registers
    --

    -- Start write to 0x20
    wait for 100 us;
    i2c_write_start_bit(scl, sda);
    i2c_write_byte(scl, sda, x"40");

    -- Index pointer
    i2c_write_byte(scl, sda, x"00");

    -- Restart transaction, reading from 0x20
    wait for 100 us;
    i2c_write_start_bit(scl, sda);
    i2c_write_byte(scl, sda, x"41");

    -- Read data
    i2c_read_byte(scl, sda, data);
    i2c_read_byte(scl, sda, data);
    i2c_read_byte(scl, sda, data);
    i2c_read_byte(scl, sda, data);
    i2c_read_byte(scl, sda, data);

    -- All done
    i2c_write_stop_bit(scl, sda);

    wait;
  end process;

end architecture sim;
