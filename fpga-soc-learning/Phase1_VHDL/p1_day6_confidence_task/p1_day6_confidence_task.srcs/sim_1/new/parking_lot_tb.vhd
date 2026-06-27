library ieee;
use ieee.std_logic_1164.all;

entity parking_lot_tb is
end parking_lot_tb;

architecture behavioral of parking_lot_tb is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal entry     : std_logic := '0';
    signal exit_car  : std_logic := '0';
    signal available : integer range 0 to 10;
    signal full      : std_logic;
    signal empty     : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.parking_lot
        port map (
            clk       => clk,
            reset     => reset,
            entry     => entry,
            exit_car  => exit_car,
            available => available,
            full      => full,
            empty     => empty
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

        -- Test 1: 3 cars enter
        report "Test 1: 3 cars enter";
        entry <= '1';
        wait for clk_period;
        entry <= '0';
        wait for clk_period;
        entry <= '1';
        wait for clk_period;
        entry <= '0';
        wait for clk_period;
        entry <= '1';
        wait for clk_period;
        entry <= '0';
        wait for clk_period;
        -- Expected: available = 7

        -- Test 2: 2 cars exit
        report "Test 2: 2 cars exit";
        exit_car <= '1';
        wait for clk_period;
        exit_car <= '0';
        wait for clk_period;
        exit_car <= '1';
        wait for clk_period;
        exit_car <= '0';
        wait for clk_period;
        -- Expected: available = 9

        -- Test 3: Fill lot to full
        report "Test 3: Fill lot to full";
        for i in 0 to 8 loop
            entry <= '1';
            wait for clk_period;
            entry <= '0';
            wait for clk_period;
        end loop;
        -- Expected: available = 0, full = 1

        -- Test 4: Empty lot
        report "Test 4: Empty lot";
        for i in 0 to 9 loop
            exit_car <= '1';
            wait for clk_period;
            exit_car <= '0';
            wait for clk_period;
        end loop;
        -- Expected: available = 10, empty = 1

        wait for 20 ns;
        report "SIMULATION COMPLETE!";
        wait;
    end process;

end behavioral;