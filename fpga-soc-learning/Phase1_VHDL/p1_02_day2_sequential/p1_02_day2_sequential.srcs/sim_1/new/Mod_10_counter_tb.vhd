library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mod10_counter_tb is
end mod10_counter_tb;

architecture sim of mod10_counter_tb is

    signal clk_tb   : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '0';
    signal q_tb     : STD_LOGIC_VECTOR(3 downto 0);

    component mod10_counter
        Port ( clk   : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               q     : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin

    UUT: mod10_counter port map (
        clk   => clk_tb,
        reset => reset_tb,
        q     => q_tb
    );

    -- Clock generation: 10 ns period
    clk_process: process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Test 1: Reset at start
        reset_tb <= '1';
        wait for 10 ns;
        
        -- Test 2: Start counting from 0
        reset_tb <= '0';
        wait for 10 ns;  -- Count = 1
        wait for 10 ns;  -- Count = 2
        wait for 10 ns;  -- Count = 3
        wait for 10 ns;  -- Count = 4
        wait for 10 ns;  -- Count = 5
        wait for 10 ns;  -- Count = 6
        wait for 10 ns;  -- Count = 7
        wait for 10 ns;  -- Count = 8
        wait for 10 ns;  -- Count = 9
        wait for 10 ns;  -- Count = 0 (reset)
        wait for 10 ns;  -- Count = 1
        wait for 10 ns;  -- Count = 2
        
        -- Test 3: Reset during counting
        reset_tb <= '1';
        wait for 10 ns;
        
        -- Test 4: Continue after reset
        reset_tb <= '0';
        wait for 10 ns;  -- Count = 1
        wait for 10 ns;  -- Count = 2
        wait for 10 ns;  -- Count = 3
        wait for 10 ns;  -- Count = 4
        wait for 10 ns;  -- Count = 5
        wait for 10 ns;  -- Count = 6
        wait for 10 ns;  -- Count = 7
        wait for 10 ns;  -- Count = 8
        wait for 10 ns;  -- Count = 9
        wait for 10 ns;  -- Count = 0 (reset)
        
        -- Test 5: Another reset
        reset_tb <= '1';
        wait for 10 ns;
        
        reset_tb <= '0';
        wait for 10 ns;  -- Count = 1
        
        wait;
    end process;

end sim;