library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_ram_tb is
end dual_port_ram_tb;

architecture behavioral of dual_port_ram_tb is

    signal clk        : std_logic := '0';
    signal wea        : std_logic := '0';
    signal address_a  : std_logic_vector(3 downto 0) := (others => '0');
    signal data_in_a  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out_a : std_logic_vector(7 downto 0);
    signal web        : std_logic := '0';
    signal address_b  : std_logic_vector(3 downto 0) := (others => '0');
    signal data_in_b  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out_b : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Correctly instantiate the DUT
    uut: entity work.dual_port_ram
        port map (
            clk        => clk,
            wea        => wea,
            address_a  => address_a,
            data_in_a  => data_in_a,
            data_out_a => data_out_a,
            web        => web,
            address_b  => address_b,
            data_in_b  => data_in_b,
            data_out_b => data_out_b
        );

    -- Clock generation process (CORRECT way)
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process (CORRECT way)
    stim_process: process
    begin
        -- Reset
        wea <= '0';
        web <= '0';
        wait for 20 ns;

        -- Test 1: Write to Port A, Read from Port B
        report "TEST 1: Write addr 0 from Port A, Read from Port B";
        wea <= '1';
        address_a <= "0000";
        data_in_a <= "10101010";
        web <= '0';
        address_b <= "0000";
        wait for clk_period;
        
        wea <= '0';
        wait for clk_period;
        wait for clk_period;

        -- Test 2: Write to Port B, Read from Port A
        report "TEST 2: Write addr 5 from Port B, Read from Port A";
        web <= '1';
        address_b <= "0101";
        data_in_b <= "11110000";
        wea <= '0';
        address_a <= "0101";
        wait for clk_period;
        
        web <= '0';
        wait for clk_period;
        wait for clk_period;

        -- Test 3: Multiple writes to same address
        report "TEST 3: Multiple writes to addr 7";
        wea <= '1';
        address_a <= "0111";
        data_in_a <= "10101010";
        wait for clk_period;
        data_in_a <= "10111011";
        wait for clk_period;
        data_in_a <= "11001100";
        wait for clk_period;
        wea <= '0';
        wait for clk_period;
        wait for clk_period;

        -- Test 4: Simultaneous writes
        report "TEST 4: Simultaneous writes";
        wea <= '1';
        address_a <= "1000";
        data_in_a <= "00001111";
        web <= '1';
        address_b <= "1001";
        data_in_b <= "11110000";
        wait for clk_period;
        
        wea <= '0';
        web <= '0';
        wait for clk_period;
        wait for clk_period;

        wait for 20 ns;
        report "SIMULATION COMPLETE!";
        wait;
    end process;

end behavioral;