library ieee;
use ieee.std_logic_1164.all;

entity sqn_detector_tb is
end sqn_detector_tb;

architecture behavioral of sqn_detector_tb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal data_in  : std_logic := '0';
    signal detected : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.sqn_detector
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            detected => detected
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

        -- Test case 1: All zeros, no pattern
        data_in <= '0';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;

        -- Test case 2: Pattern 101 should detect
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;

        -- Test case 3: Overlapping pattern 10101
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;

        -- Test case 4: Pattern 1001 should not detect
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;

        -- Test case 5: Pattern 1101 detects at the end
        data_in <= '1';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;

        -- Test case 6: Random sequence 101101
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;
        data_in <= '0';
        wait for clk_period;
        data_in <= '1';
        wait for clk_period;

        wait for 20 ns;
        wait;
    end process;

end behavioral;