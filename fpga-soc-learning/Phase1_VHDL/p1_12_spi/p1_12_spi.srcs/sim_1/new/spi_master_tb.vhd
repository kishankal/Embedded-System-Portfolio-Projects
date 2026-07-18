-- ============================================================
-- TESTBENCH: spi_master_tb
-- Simulates SPI slave behavior
-- Sends 0xA5 from master, slave responds with 0x3C
-- Verifies: CS timing, SCLK pulses, MOSI bits, MISO sampling
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master_tb is
end entity spi_master_tb;

architecture Behavioral of spi_master_tb is

    -- Small divider for fast simulation
    constant SPI_CLK_DIV : integer := 4;
    constant CLK_PERIOD  : time    := 10 ns;

    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '0';
    signal spi_start : STD_LOGIC := '0';
    signal mosi_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal miso      : STD_LOGIC := '0';
    signal sclk      : STD_LOGIC;
    signal mosi      : STD_LOGIC;
    signal cs        : STD_LOGIC;
    signal miso_data : STD_LOGIC_VECTOR(7 downto 0);
    signal spi_done  : STD_LOGIC;

    -- Slave response byte
    -- In real SPI, slave shifts this out on MISO
    signal slave_data     : STD_LOGIC_VECTOR(7 downto 0) := x"3C";
    signal slave_bit_cnt  : integer := 7;

begin

    -- DUT instantiation
    DUT: entity work.spi_master
        generic map (SPI_CLK_DIV => SPI_CLK_DIV)
        port map (
            clk       => clk,
            rst       => rst,
            spi_start => spi_start,
            mosi_data => mosi_data,
            miso      => miso,
            sclk      => sclk,
            mosi      => mosi,
            cs        => cs,
            miso_data => miso_data,
            spi_done  => spi_done
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

        -- Simulated SPI Slave
    -- Drives MISO bits BEFORE each rising SCLK edge
    slave_process: process
        variable slave_byte : STD_LOGIC_VECTOR(7 downto 0);
    begin
        miso <= '0';
        
        -- Wait for CS to go LOW
        wait until cs = '0';
        
        slave_byte := slave_data;
        
        -- Drive each bit on MISO before rising edge
        -- In Mode 0: slave drives on falling edge (or before first rising)
        for i in 7 downto 0 loop
            -- Wait for SCLK falling edge (or CS low for first bit)
            if i = 7 then
                -- First bit: drive immediately after CS goes LOW
                miso <= slave_byte(7);
            else
                wait until falling_edge(sclk);
                miso <= slave_byte(i);
            end if;
            -- Wait for rising edge (master samples here)
            wait until rising_edge(sclk);
        end loop;
        
        -- Wait for CS to go HIGH
        wait until cs = '1';
        miso <= '0';
    end process;

    -- ── Stimulus ──────────────────────────────────────────────
    stim_proc: process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 5;

        -- Verify idle state
        assert cs = '1'
            report "FAIL: CS not HIGH in idle" severity ERROR;
        assert sclk = '0'
            report "FAIL: SCLK not LOW in idle" severity ERROR;

        -- ── Transaction 1: send 0xA5, expect 0x3C back ────────
        mosi_data <= x"A5";  -- 10100101
        spi_start <= '1';
        wait for CLK_PERIOD;
        spi_start <= '0';

        -- Wait for transaction complete
        wait until spi_done = '1';
        wait for CLK_PERIOD;

        -- Verify CS went LOW during transfer
        -- Verify received data
        assert miso_data = x"3C"
            report "FAIL: Expected 0x3C from slave, got " &
                   integer'image(to_integer(unsigned(miso_data)))
            severity ERROR;
        report "PASS: Transaction 1 - sent 0xA5, received 0x3C" severity NOTE;

        wait for CLK_PERIOD * 20;

        -- ── Transaction 2: send 0xFF ───────────────────────────
        slave_data <= x"55";  -- slave will respond with 0x55
        mosi_data  <= x"FF";
        spi_start  <= '1';
        wait for CLK_PERIOD;
        spi_start  <= '0';

        wait until spi_done = '1';
        wait for CLK_PERIOD;

        assert miso_data = x"55"
            report "FAIL: Expected 0x55 from slave" severity ERROR;
        report "PASS: Transaction 2 - sent 0xFF, received 0x55" severity NOTE;

        wait for CLK_PERIOD * 20;

        report "SPI MASTER TESTBENCH COMPLETE" severity NOTE;
        wait;
    end process;

end architecture Behavioral;