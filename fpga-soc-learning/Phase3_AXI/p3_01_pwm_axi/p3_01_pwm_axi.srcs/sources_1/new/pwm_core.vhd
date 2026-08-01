-- ============================================================
-- PROJECT  : Phase 3 - PWM Generator Core
-- BOARD    : PYNQ-Z2 (xc7z020clg400-1)
-- TOOL     : Vivado 2025.2
-- ============================================================
--
-- PURPOSE:
--   Pure PWM hardware logic - no AXI here
--   This is the "functional core" that does the real work
--   AXI wrapper (next file) will control this via registers
--
-- HOW IT WORKS:
--   Counter counts 0 to (period-1)
--   When counter < duty  → pwm_out = 1 (ON)
--   When counter >= duty → pwm_out = 0 (OFF)
--
-- EXAMPLE:
--   period = 1000, duty = 250
--   Counter 0-249   → pwm_out = 1 (25% on)
--   Counter 250-999 → pwm_out = 0 (75% off)
--   → 25% duty cycle PWM
--
-- PORTS:
--   clk     : system clock (100MHz on PYNQ-Z2)
--   rst     : synchronous reset active HIGH
--   enable  : 1=run, 0=stop (from CTRL register)
--   period  : total period in clock cycles (from PERIOD register)
--   duty    : on-time in clock cycles (from DUTY register)
--   pwm_out : PWM output signal
--   running : status flag (1=counter running)
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_core is
    port (
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        enable  : in  STD_LOGIC;
        period  : in  STD_LOGIC_VECTOR(31 downto 0);
        duty    : in  STD_LOGIC_VECTOR(31 downto 0);
        pwm_out : out STD_LOGIC;
        running : out STD_LOGIC
    );
end entity pwm_core;

architecture Behavioral of pwm_core is

    -- Internal counter
    -- Counts 0 to (period-1) then wraps back to 0
    signal counter : unsigned(31 downto 0) := (others => '0');

    -- Internal PWM output signal
    signal pwm_int : STD_LOGIC := '0';

begin

    -- Connect internal signals to output ports
    pwm_out <= pwm_int;
    running <= enable;  -- running when enabled

    -- ──────────────────────────────────────────────────────────
    -- PWM Counter and Output Logic
    -- ──────────────────────────────────────────────────────────
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset: counter to zero, output off
                counter <= (others => '0');
                pwm_int <= '0';

            elsif enable = '1' then
                -- Counter running

                -- Check if counter reached end of period
                if counter >= unsigned(period) - 1 then
                    -- Wrap back to zero
                    counter <= (others => '0');
                else
                    -- Increment counter
                    counter <= counter + 1;
                end if;

                -- PWM output logic
                -- ON when counter < duty
                -- OFF when counter >= duty
                if counter < unsigned(duty) then
                    pwm_int <= '1';  -- ON phase
                else
                    pwm_int <= '0';  -- OFF phase
                end if;

            else
                -- Disabled: stop counter, output off
                counter <= (others => '0');
                pwm_int <= '0';
            end if;
        end if;
    end process;

end architecture Behavioral;