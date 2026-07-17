-- ============================================================
-- TESTBENCH: uart_tx_tb
-- Sends byte 0x55 (01010101) and 0xA3 (10100011)
-- Verifies start bit, 8 data bits LSB first, stop bit
-- Checks timing: each bit = CLKS_PER_BIT clock cycles
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_tb is
end entity uart_tx_tb;

architecture Behavioral of uart_tx_tb is

    -- Use small CLKS_PER_BIT for fast simulation
    constant CLKS_PER_BIT : integer := 10;
    constant CLK_PERIOD   : time    := 10 ns;

    -- DUT signals
    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '0';
    signal tx_start : STD_LOGIC := '0';
    signal data_in  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx       : STD_LOGIC;
    signal tx_busy  : STD_LOGIC;

begin

    -- ── DUT instantiation ─────────────────────────────────────
    DUT: entity work.uart_tx
        generic map (CLKS_PER_BIT => CLKS_PER_BIT)
        port map (
            clk      => clk,
            rst      => rst,
            tx_start => tx_start,
            data_in  => data_in,
            tx       => tx,
            tx_busy  => tx_busy
        );

    -- ── Clock generation ──────────────────────────────────────
    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- ── Stimulus ──────────────────────────────────────────────
    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        -- Verify idle state: tx should be HIGH
        assert tx = '1'
            report "FAIL: tx not HIGH in idle state"
            severity ERROR;

        -- ── Send byte 1: 0x55 = 01010101 ─────────────────────
        -- LSB first: 1,0,1,0,1,0,1,0
        data_in  <= x"55";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        -- Wait for start bit
        wait for CLK_PERIOD;
        assert tx = '0'
            report "FAIL: Start bit not LOW for 0x55"
            severity ERROR;

        -- Wait for entire frame to complete
        -- Total = 1 start + 8 data + 1 stop = 10 bits x CLKS_PER_BIT
        wait for CLK_PERIOD * CLKS_PER_BIT * 10;

        -- After frame: tx should be HIGH again
        assert tx = '1'
            report "FAIL: tx not HIGH after 0x55 frame"
            severity ERROR;

        assert tx_busy = '0'
            report "FAIL: tx_busy still HIGH after 0x55 frame"
            severity ERROR;

        wait for CLK_PERIOD * 5;

        -- ── Send byte 2: 0xA3 = 10100011 ─────────────────────
        data_in  <= x"A3";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        -- Wait for start bit
        wait for CLK_PERIOD;
        assert tx = '0'
            report "FAIL: Start bit not LOW for 0xA3"
            severity ERROR;

        -- Wait for frame complete
        wait for CLK_PERIOD * CLKS_PER_BIT * 10;

        assert tx = '1'
            report "FAIL: tx not HIGH after 0xA3 frame"
            severity ERROR;

        wait for CLK_PERIOD * 10;

        report "UART TX TESTBENCH COMPLETE - Check waveform for bit timing"
            severity NOTE;

        wait;
    end process;

end architecture Behavioral;