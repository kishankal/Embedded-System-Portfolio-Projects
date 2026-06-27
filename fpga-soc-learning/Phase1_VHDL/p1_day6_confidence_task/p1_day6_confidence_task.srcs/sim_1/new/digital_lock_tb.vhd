library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_lock_tb is
end digital_lock_tb;

architecture behavioral of digital_lock_tb is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal digit1    : std_logic_vector(3 downto 0) := "0000";
    signal digit2    : std_logic_vector(3 downto 0) := "0000";
    signal digit3    : std_logic_vector(3 downto 0) := "0000";
    signal digit4    : std_logic_vector(3 downto 0) := "0000";
    signal enter     : std_logic := '0';
    signal lock_open : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.digital_lock
        port map (
            clk       => clk,
            reset     => reset,
            digit1    => digit1,
            digit2    => digit2,
            digit3    => digit3,
            digit4    => digit4,
            enter     => enter,
            lock_open => lock_open
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

        -- Test 1: Wrong password
        report "Test 1: Wrong password 4321";
        digit1 <= "0100";  -- 4
        digit2 <= "0011";  -- 3
        digit3 <= "0010";  -- 2
        digit4 <= "0001";  -- 1
        enter <= '1';
        wait for clk_period;
        enter <= '0';
        wait for clk_period;
        -- Expected: lock_open = 0

        -- Test 2: Correct password
        report "Test 2: Correct password 1234";
        digit1 <= "0001";  -- 1
        digit2 <= "0010";  -- 2
        digit3 <= "0011";  -- 3
        digit4 <= "0100";  -- 4
        enter <= '1';
        wait for clk_period;
        enter <= '0';
        wait for clk_period;
        -- Expected: lock_open = 1

        -- Test 3: Reset after correct password
        report "Test 3: Reset lock";
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;
        -- Expected: lock_open = 0

        wait for 20 ns;
        report "SIMULATION COMPLETE!";
        wait;
    end process;

end behavioral;