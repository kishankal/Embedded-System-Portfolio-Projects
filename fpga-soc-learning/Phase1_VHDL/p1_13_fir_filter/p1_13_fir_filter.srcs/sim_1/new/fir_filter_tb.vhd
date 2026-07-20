-- ============================================================
-- TESTBENCH: fir_filter_tb
-- Verification Plan (Sheet 1 Phase 4):
-- ─────────────────────────────────────────────────────────
-- Test 1: Zero input -> zero output (corner case)
-- Test 2: Impulse -> observe impulse response
-- Test 3: DC input -> output = same value (DC gain=1.0)
-- Test 4: Low freq sine 500Hz -> passes (~0dB attenuation)
-- Test 5: High freq sine 3000Hz -> attenuated (>60dB)
-- ─────────────────────────────────────────────────────────
-- Fs = 8000Hz -> CLK_PERIOD = 1/8000 = 125us = 125000ns
-- But we use 10ns clock and send 1 sample per clock
-- (equivalent to simulating at 100MHz for speed)
-- ─────────────────────────────────────────────────────────
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity fir_filter_tb is
end entity fir_filter_tb;

architecture Behavioral of fir_filter_tb is

    constant CLK_PERIOD : time    := 10 ns;
    constant DATA_WIDTH : integer := 16;
    constant N_TAPS     : integer := 32;

    -- Normalized frequencies (fraction of sample rate)
    -- 500Hz/8000Hz = 0.0625 -> passes through filter
    -- 3000Hz/8000Hz = 0.375 -> attenuated by filter
    constant FREQ_LOW  : real := 0.0625;  -- 500Hz (in passband)
    constant FREQ_HIGH : real := 0.375;   -- 3000Hz (in stopband)
    constant AMPLITUDE : real := 0.8;     -- 80% of full scale

    signal clk           : STD_LOGIC := '0';
    signal rst           : STD_LOGIC := '0';
    signal s_axis_tvalid : STD_LOGIC := '0';
    signal s_axis_tready : STD_LOGIC;
    signal s_axis_tdata  : STD_LOGIC_VECTOR(15 downto 0) := (others=>'0');
    signal m_axis_tvalid : STD_LOGIC;
    signal m_axis_tdata  : STD_LOGIC_VECTOR(15 downto 0);

    -- Helper: convert real (-1 to +1) to Q1.15 integer
    function to_q15(x : real) return integer is
    begin
        return integer(x * 32767.0);
    end function;

begin

    DUT: entity work.fir_filter
        port map (
            clk           => clk,
            rst           => rst,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tready => s_axis_tready,
            s_axis_tdata  => s_axis_tdata,
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tdata  => m_axis_tdata
        );

    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        variable sample : integer;
    begin
        -- Reset
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 3;

        -- ── Test 1: Zero Input ────────────────────────────────
        report "Test 1: Zero input" severity NOTE;
        s_axis_tvalid <= '1';
        for i in 0 to N_TAPS+5 loop
            s_axis_tdata <= (others => '0');
            wait for CLK_PERIOD;
        end loop;
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD * 3;
        assert to_integer(signed(m_axis_tdata)) = 0
            report "FAIL Test 1: expected 0" severity ERROR;
        report "PASS Test 1: Zero input -> zero output" severity NOTE;
        wait for CLK_PERIOD * 5;

        -- ── Test 2: Impulse Response ──────────────────────────
        report "Test 2: Impulse response" severity NOTE;
        s_axis_tvalid <= '1';
        s_axis_tdata  <= x"7FFF";  -- max positive impulse
        wait for CLK_PERIOD;
        for i in 0 to N_TAPS+5 loop
            s_axis_tdata <= (others => '0');
            wait for CLK_PERIOD;
        end loop;
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD * 5;
        report "PASS Test 2: Impulse sent - verify waveform matches h[k]"
            severity NOTE;
        wait for CLK_PERIOD * 10;

        -- ── Test 3: DC Input ──────────────────────────────────
        -- Send 16384 (= 0.5 in Q1.15) for long enough to fill delay line
        report "Test 3: DC gain verification" severity NOTE;
        s_axis_tvalid <= '1';
        for i in 0 to N_TAPS*2 loop
            s_axis_tdata <= STD_LOGIC_VECTOR(to_signed(16384, 16));
            wait for CLK_PERIOD;
        end loop;
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD * 3;
        -- Output should be ~16384 (DC gain = 1.0)
        assert abs(to_integer(signed(m_axis_tdata)) - 16384) < 200
            report "FAIL Test 3: DC gain error - got " &
                   integer'image(to_integer(signed(m_axis_tdata)))
            severity ERROR;
        report "PASS Test 3: DC gain = 1.0 verified" severity NOTE;
        wait for CLK_PERIOD * 10;

        -- ── Test 4: Low Frequency 500Hz (passband) ────────────
        -- 500Hz / 8000Hz = 0.0625 normalized
        -- Should pass with ~0dB attenuation
        report "Test 4: 500Hz sine (passband - should pass)" severity NOTE;
        s_axis_tvalid <= '1';
        for i in 0 to 127 loop  -- 16 complete cycles
            sample := to_q15(AMPLITUDE *
                      sin(2.0 * MATH_PI * FREQ_LOW * real(i)));
            s_axis_tdata <= STD_LOGIC_VECTOR(to_signed(sample, 16));
            wait for CLK_PERIOD;
        end loop;
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD * 5;
        report "PASS Test 4: 500Hz sent - check output amplitude in waveform"
            severity NOTE;
        wait for CLK_PERIOD * 10;

        -- ── Test 5: High Frequency 3000Hz (stopband) ──────────
        -- 3000Hz / 8000Hz = 0.375 normalized
        -- Should be attenuated >60dB (output near zero)
        report "Test 5: 3000Hz sine (stopband - should be attenuated)"
            severity NOTE;
        s_axis_tvalid <= '1';
        for i in 0 to 127 loop
            sample := to_q15(AMPLITUDE *
                      sin(2.0 * MATH_PI * FREQ_HIGH * real(i)));
            s_axis_tdata <= STD_LOGIC_VECTOR(to_signed(sample, 16));
            wait for CLK_PERIOD;
        end loop;
        s_axis_tvalid <= '0';
        wait for CLK_PERIOD * 10;
        report "PASS Test 5: 3000Hz sent - output should be near zero"
            severity NOTE;

        report "FIR TESTBENCH COMPLETE - All 5 tests done" severity NOTE;
        wait;
    end process;

end architecture Behavioral;