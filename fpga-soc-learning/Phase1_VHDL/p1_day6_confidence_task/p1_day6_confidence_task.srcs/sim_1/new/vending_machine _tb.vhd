library ieee;
use ieee.std_logic_1164.all;

entity vending_machine_tb is
end vending_machine_tb;

architecture behavioral of vending_machine_tb is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal coin_5    : std_logic := '0';
    signal coin_10   : std_logic := '0';
    signal coin_25   : std_logic := '0';
    signal dispense  : std_logic;
    signal change_5  : std_logic;
    signal change_10 : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.vending_machine
        port map (
            clk       => clk,
            reset     => reset,
            coin_5    => coin_5,
            coin_10   => coin_10,
            coin_25   => coin_25,
            dispense  => dispense,
            change_5  => change_5,
            change_10 => change_10
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

        -- Test 1: Insert 25¢ + 5¢ = 30¢ (should dispense)
        report "Test 1: 25¢ + 5¢";
        coin_25 <= '1';
        wait for clk_period;
        coin_25 <= '0';
        wait for clk_period;
        coin_5 <= '1';
        wait for clk_period;
        coin_5 <= '0';
        wait for clk_period;
        -- Expected: dispense = 1

        -- Test 2: Insert 10¢ + 10¢ + 10¢ = 30¢ (should dispense)
        report "Test 2: 10¢ + 10¢ + 10¢";
        coin_10 <= '1';
        wait for clk_period;
        coin_10 <= '0';
        wait for clk_period;
        coin_10 <= '1';
        wait for clk_period;
        coin_10 <= '0';
        wait for clk_period;
        coin_10 <= '1';
        wait for clk_period;
        coin_10 <= '0';
        wait for clk_period;
        -- Expected: dispense = 1

        -- Test 3: 25¢ + 10¢ = 35¢ (should dispense + 5¢ change)
        report "Test 3: 25¢ + 10¢ (5¢ change)";
        coin_25 <= '1';
        wait for clk_period;
        coin_25 <= '0';
        wait for clk_period;
        coin_10 <= '1';
        wait for clk_period;
        coin_10 <= '0';
        wait for clk_period;
        -- Expected: dispense = 1, change_5 = 1

        -- Test 4: 25¢ + 25¢ = 50¢ (should dispense + 20¢ change)
        report "Test 4: 25¢ + 25¢ (20¢ change)";
        coin_25 <= '1';
        wait for clk_period;
        coin_25 <= '0';
        wait for clk_period;
        coin_25 <= '1';
        wait for clk_period;
        coin_25 <= '0';
        wait for clk_period;
        -- Expected: dispense = 1, change_10 = 1, change_5 = 1

        wait for 20 ns;
        report "SIMULATION COMPLETE!";
        wait;
    end process;

end behavioral;