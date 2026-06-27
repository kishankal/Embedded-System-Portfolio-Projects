library ieee;
use ieee.std_logic_1164.all;

entity pwm_generator_tb is
end pwm_generator_tb;

architecture behavioral of pwm_generator_tb is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal duty_cycle: integer := 0;
    signal pwm_out   : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.pwm_generator
        generic map (
            PERIOD => 10
        )
        port map (
            clk       => clk,
            reset     => reset,
            duty_cycle=> duty_cycle,
            pwm_out   => pwm_out
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_process: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        -- Test 1: 25% duty cycle
        report "Test 1: 25% duty cycle";
        duty_cycle <= 2;
        wait for 100 ns;

        -- Test 2: 50% duty cycle
        report "Test 2: 50% duty cycle";
        duty_cycle <= 5;
        wait for 100 ns;

        -- Test 3: 75% duty cycle
        report "Test 3: 75% duty cycle";
        duty_cycle <= 7;
        wait for 100 ns;

        -- Test 4: 100% duty cycle
        report "Test 4: 100% duty cycle";
        duty_cycle <= 10;
        wait for 100 ns;

        -- Test 5: 0% duty cycle
        report "Test 5: 0% duty cycle";
        duty_cycle <= 0;
        wait for 100 ns;

        wait for 20 ns;
        report "SIMULATION COMPLETE!";
        wait;
    end process;

end behavioral;