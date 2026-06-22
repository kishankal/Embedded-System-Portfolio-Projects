library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity parallel_load_reg_tb is
end parallel_load_reg_tb;

architecture sim of parallel_load_reg_tb is

    signal clk_tb     : STD_LOGIC := '0';
    signal reset_tb   : STD_LOGIC := '0';
    signal load_tb    : STD_LOGIC := '0';
    signal data_in_tb : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal q_tb       : STD_LOGIC_VECTOR(3 downto 0);

    component parallel_load_reg
        Port ( clk     : in  STD_LOGIC;
               reset   : in  STD_LOGIC;
               load    : in  STD_LOGIC;
               data_in : in  STD_LOGIC_VECTOR(3 downto 0);
               q       : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin

    UUT: parallel_load_reg port map (
        clk     => clk_tb,
        reset   => reset_tb,
        load    => load_tb,
        data_in => data_in_tb,
        q       => q_tb
    );

    -- Clock: 10 ns period
    clk_process: process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Test 1: Reset at start
        reset_tb <= '1';
        data_in_tb <= "1010";
        load_tb <= '1';
        wait for 10 ns;
        
        -- Test 2: Release reset, load 1010
        reset_tb <= '0';
        data_in_tb <= "1010";
        load_tb <= '1';
        wait for 10 ns;
        
        -- Test 3: Hold value (load=0)
        reset_tb <= '0';
        data_in_tb <= "1111";
        load_tb <= '0';
        wait for 10 ns;
        
        -- Test 4: Load 0101
        reset_tb <= '0';
        data_in_tb <= "0101";
        load_tb <= '1';
        wait for 10 ns;
        
        -- Test 5: Load 1100
        reset_tb <= '0';
        data_in_tb <= "1100";
        load_tb <= '1';
        wait for 10 ns;
        
        -- Test 6: Hold again
        reset_tb <= '0';
        data_in_tb <= "1001";
        load_tb <= '0';
        wait for 10 ns;
        
        -- Test 7: Reset during operation
        reset_tb <= '1';
        data_in_tb <= "0110";
        load_tb <= '1';
        wait for 10 ns;
        
        -- Test 8: Release reset and load new data
        reset_tb <= '0';
        data_in_tb <= "0110";
        load_tb <= '1';
        wait for 10 ns;
        
        wait;
    end process;

end sim;