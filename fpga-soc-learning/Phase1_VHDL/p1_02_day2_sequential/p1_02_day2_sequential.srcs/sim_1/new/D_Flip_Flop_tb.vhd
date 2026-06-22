library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dff_sync_tb is
end dff_sync_tb;

architecture sim of dff_sync_tb is

    signal clk_tb, reset_tb, d_tb, q_tb : STD_LOGIC;

    component dff_sync
        Port ( clk   : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               d     : in  STD_LOGIC;
               q     : out STD_LOGIC);
    end component;

begin

    UUT: dff_sync port map (clk => clk_tb, reset => reset_tb, d => d_tb, q => q_tb);

    -- clock generation
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
        reset_tb <= '1'; d_tb <= '0'; wait for 20 ns;
        reset_tb <= '0'; d_tb <= '1'; wait for 20 ns;
        reset_tb <= '0'; d_tb <= '0'; wait for 20 ns;
        reset_tb <= '1'; d_tb <= '1'; wait for 20 ns;
        wait;
    end process;

end sim;