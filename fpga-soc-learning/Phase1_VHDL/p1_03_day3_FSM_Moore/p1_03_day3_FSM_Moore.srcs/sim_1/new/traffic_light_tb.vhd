library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity traffic_light_tb is
end traffic_light_tb;

architecture sim of traffic_light_tb is

    signal clk_tb    : STD_LOGIC := '0';
    signal reset_tb  : STD_LOGIC := '0';
    signal red_tb    : STD_LOGIC;
    signal green_tb  : STD_LOGIC;
    signal yellow_tb : STD_LOGIC;

    component traffic_light
        Port ( clk    : in  STD_LOGIC;
               reset  : in  STD_LOGIC;
               red    : out STD_LOGIC;
               green  : out STD_LOGIC;
               yellow : out STD_LOGIC);
    end component;

begin

    UUT: traffic_light port map (
        clk    => clk_tb,
        reset  => reset_tb,
        red    => red_tb,
        green  => green_tb,
        yellow => yellow_tb
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
        wait for 20 ns;
        reset_tb <= '0';
        
        -- Run for enough time to see all states
        wait for 100 ns;  -- RED
        wait for 150 ns;  -- GREEN
        wait for 50 ns;   -- YELLOW
        wait for 100 ns;  -- RED again
        
        -- Test reset during operation
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        
        wait for 100 ns;  -- RED
        wait for 150 ns;  -- GREEN
        wait for 50 ns;   -- YELLOW
        
        wait;
    end process;

end sim;