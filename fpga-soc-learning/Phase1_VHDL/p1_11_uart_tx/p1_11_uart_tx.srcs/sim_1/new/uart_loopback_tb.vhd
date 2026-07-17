-- ============================================================
-- TESTBENCH: uart_loopback_tb
-- Connects uart_tx output directly to uart_rx input
-- Sends 3 bytes and verifies RX receives identical bytes
-- This proves TX and RX work correctly together
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_loopback_tb is
end entity uart_loopback_tb;

architecture Behavioral of uart_loopback_tb is

    constant CLKS_PER_BIT : integer := 10;
    constant CLK_PERIOD   : time    := 10 ns;

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '0';
    signal tx_start : STD_LOGIC := '0';
    signal data_in  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx       : STD_LOGIC;
    signal tx_busy  : STD_LOGIC;
    signal rx_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_done  : STD_LOGIC;

begin

    -- TX instance
    TX_INST: entity work.uart_tx
        generic map (CLKS_PER_BIT => CLKS_PER_BIT)
        port map (
            clk      => clk,
            rst      => rst,
            tx_start => tx_start,
            data_in  => data_in,
            tx       => tx,
            tx_busy  => tx_busy
        );

    -- RX instance - rx connected directly to tx (loopback)
    RX_INST: entity work.uart_rx
        generic map (CLKS_PER_BIT => CLKS_PER_BIT)
        port map (
            clk     => clk,
            rst     => rst,
            rx      => tx,      -- loopback: tx wire goes to rx input
            rx_data => rx_data,
            rx_done => rx_done
        );

    -- Clock
    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 5;

        -- ── Send byte 1: 0x55 ────────────────────────────────
        data_in  <= x"55";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        -- Wait for RX to complete
        wait until rx_done = '1';
        wait for CLK_PERIOD;

        assert rx_data = x"55"
            report "FAIL: Loopback 0x55 - got " &
                   integer'image(to_integer(unsigned(rx_data)))
            severity ERROR;
        report "PASS: Loopback 0x55 received correctly" severity NOTE;

        wait for CLK_PERIOD * 20;

        -- ── Send byte 2: 0xA3 ────────────────────────────────
        data_in  <= x"A3";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        wait until rx_done = '1';
        wait for CLK_PERIOD;

        assert rx_data = x"A3"
            report "FAIL: Loopback 0xA3 - got " &
                   integer'image(to_integer(unsigned(rx_data)))
            severity ERROR;
        report "PASS: Loopback 0xA3 received correctly" severity NOTE;

        wait for CLK_PERIOD * 20;

        -- ── Send byte 3: 0xFF ────────────────────────────────
        data_in  <= x"FF";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        wait until rx_done = '1';
        wait for CLK_PERIOD;

        assert rx_data = x"FF"
            report "FAIL: Loopback 0xFF - got " &
                   integer'image(to_integer(unsigned(rx_data)))
            severity ERROR;
        report "PASS: Loopback 0xFF received correctly" severity NOTE;

        wait for CLK_PERIOD * 20;

        report "UART LOOPBACK TEST COMPLETE - All bytes match!" severity NOTE;
        wait;
    end process;

end architecture Behavioral;