-- ============================================================
-- TESTBENCH: uart_rx_tb
-- Generates UART serial frame manually and feeds to RX
-- Verifies received byte matches transmitted byte
-- Tests: 0x37, 0xA5
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
end entity uart_rx_tb;

architecture Behavioral of uart_rx_tb is

    constant CLKS_PER_BIT : integer := 10;
    constant CLK_PERIOD   : time    := 10 ns;
    constant BIT_PERIOD   : time    := CLK_PERIOD * CLKS_PER_BIT;

    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';
    signal rx      : STD_LOGIC := '1';  -- idle HIGH
    signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_done : STD_LOGIC;

    -- Task to send one UART byte
    procedure send_byte(
        data : in STD_LOGIC_VECTOR(7 downto 0);
        signal rx_sig : out STD_LOGIC
    ) is
    begin
        -- Start bit
        rx_sig <= '0';
        wait for BIT_PERIOD;

        -- 8 data bits LSB first
        for i in 0 to 7 loop
            rx_sig <= data(i);
            wait for BIT_PERIOD;
        end loop;

        -- Stop bit
        rx_sig <= '1';
        wait for BIT_PERIOD;
    end procedure;

begin

    -- DUT
    DUT: entity work.uart_rx
        generic map (CLKS_PER_BIT => CLKS_PER_BIT)
        port map (
            clk     => clk,
            rst     => rst,
            rx      => rx,
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
        wait for CLK_PERIOD * 2;

        -- Send 0x37 = 00110111
        send_byte(x"37", rx);
        wait for CLK_PERIOD * 2;

        -- Verify received byte
        assert rx_data = x"37"
            report "FAIL: Expected 0x37, got " &
                   integer'image(to_integer(unsigned(rx_data)))
            severity ERROR;
        assert rx_done = '1'
            report "FAIL: rx_done not pulsed for 0x37"
            severity ERROR;

        wait for CLK_PERIOD * 10;

        -- Send 0xA5 = 10100101
        send_byte(x"A5", rx);
        wait for CLK_PERIOD * 2;

        assert rx_data = x"A5"
            report "FAIL: Expected 0xA5, got " &
                   integer'image(to_integer(unsigned(rx_data)))
            severity ERROR;

        wait for CLK_PERIOD * 10;

        report "UART RX TESTBENCH COMPLETE" severity NOTE;
        wait;
    end process;

end architecture Behavioral;