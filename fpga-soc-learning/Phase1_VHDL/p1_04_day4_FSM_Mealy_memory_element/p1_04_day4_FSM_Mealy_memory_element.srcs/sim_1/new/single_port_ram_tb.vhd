library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_ram_tb is
end single_port_ram_tb;

architecture behavioral of single_port_ram_tb is

    signal clk      : std_logic := '0';
    signal we       : std_logic := '0';
    signal address  : std_logic_vector(3 downto 0) := (others => '0');
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: entity work.single_port_ram
        port map (
            clk      => clk,
            we       => we,
            address  => address,
            data_in  => data_in,
            data_out => data_out
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
        -- Test 1: Write data to address 0
        we <= '1';
        address <= "0000";
        data_in <= "10101010";
        wait for clk_period;

        -- Test 2: Read from address 0
        we <= '0';
        address <= "0000";
        wait for clk_period;
        -- Expected: data_out = "10101010"

        -- Test 3: Write data to address 5
        we <= '1';
        address <= "0101";
        data_in <= "11110000";
        wait for clk_period;

        -- Test 4: Read from address 5
        we <= '0';
        address <= "0101";
        wait for clk_period;
        -- Expected: data_out = "11110000"

        -- Test 5: Write to address 10
        we <= '1';
        address <= "1010";
        data_in <= "00001111";
        wait for clk_period;

        -- Test 6: Read from address 10
        we <= '0';
        address <= "1010";
        wait for clk_period;
        -- Expected: data_out = "00001111"

        -- Test 7: Read from address 0 again (should still be "10101010")
        we <= '0';
        address <= "0000";
        wait for clk_period;
        -- Expected: data_out = "10101010"

        -- Test 8: Write to address 0 with new data
        we <= '1';
        address <= "0000";
        data_in <= "01010101";
        wait for clk_period;

        -- Test 9: Read from address 0 (should be new data)
        we <= '0';
        address <= "0000";
        wait for clk_period;
        -- Expected: data_out = "01010101"

        wait for 20 ns;
        wait;
    end process;

end behavioral;