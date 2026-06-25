library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seq_detector_101_tb is
end seq_detector_101_tb;

architecture sim of seq_detector_101_tb is

    signal clk_tb    : STD_LOGIC := '0';
    signal reset_tb  : STD_LOGIC := '0';
    signal input_tb  : STD_LOGIC := '0';
    signal output_tb : STD_LOGIC;

    component seq_detector_101
        Port ( clk    : in  STD_LOGIC;
               reset  : in  STD_LOGIC;
               input  : in  STD_LOGIC;
               output : out STD_LOGIC);
    end component;

begin

    UUT: seq_detector_101 port map (
        clk    => clk_tb,
        reset  => reset_tb,
        input  => input_tb,
        output => output_tb
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
        -- Reset
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';
        
        -- Test 1: "101" detection
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '0'; wait for 10 ns;  -- S2
        input_tb <= '1'; wait for 10 ns;  -- S3 (DETECTED!)
        
        -- Test 2: "1010" - overlapping detection
        input_tb <= '0'; wait for 10 ns;  -- S0
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '0'; wait for 10 ns;  -- S2
        input_tb <= '1'; wait for 10 ns;  -- S3 (DETECTED!)
        input_tb <= '0'; wait for 10 ns;  -- S0
        input_tb <= '1'; wait for 10 ns;  -- S1
        
        -- Test 3: "1110101" - multiple patterns
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '0'; wait for 10 ns;  -- S2
        input_tb <= '1'; wait for 10 ns;  -- S3 (DETECTED!)
        input_tb <= '0'; wait for 10 ns;  -- S0
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '0'; wait for 10 ns;  -- S2
        
        -- Test 4: "1101" - pattern detection
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '1'; wait for 10 ns;  -- S1
        input_tb <= '0'; wait for 10 ns;  -- S2
        input_tb <= '1'; wait for 10 ns;  -- S3 (DETECTED!)
        
        -- Test 5: Reset during operation
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';
        input_tb <= '1'; wait for 10 ns;  -- S1
        
        wait;
    end process;

end sim;