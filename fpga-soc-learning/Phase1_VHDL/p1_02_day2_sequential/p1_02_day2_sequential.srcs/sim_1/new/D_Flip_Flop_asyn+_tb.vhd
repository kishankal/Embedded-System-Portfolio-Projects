library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dff_async_tb is
end dff_async_tb;

architecture sim of dff_async_tb is

    signal clk_tb, reset_tb, d_tb, q_tb : STD_LOGIC;

    component dff_async
        Port ( clk   : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               d     : in  STD_LOGIC;
               q     : out STD_LOGIC);
    end component;

begin

    UUT: dff_async port map (clk => clk_tb, reset => reset_tb, d => d_tb, q => q_tb);

    -- clock generation: 10ns period
    clk_process: process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    -- stimulus
    stim_proc: process
    begin
        -- Test 1: reset active at start, d=0 -> q should be 0
        reset_tb <= '1'; d_tb <= '0';
        wait for 20 ns;

        -- Test 2: release reset, load d=1 on next clock edge -> q becomes 1
        reset_tb <= '0'; d_tb <= '1';
        wait for 10 ns;   -- one clock edge passes, q should now be '1'

        -- Test 3: THE KEY TEST - assert reset mid-cycle, NOT at an edge
        reset_tb <= '1';
        wait for 3 ns;    -- only 3ns into the cycle, clk has NOT reached its edge yet
                          -- if q becomes '0' here, that proves reset is async

        -- Test 4: release reset, load d=0 on next edge
        reset_tb <= '0'; d_tb <= '0';
        wait for 10 ns;

        -- Test 5: load d=1 normally
        d_tb <= '1';
        wait for 10 ns;

        wait;
    end process;

end sim;