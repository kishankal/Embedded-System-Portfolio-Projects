library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity up_down_counter_tb is
end up_down_counter_tb;

architecture sim of up_down_counter_tb is

    signal clk_tb     : STD_LOGIC := '0';
    signal reset_tb   : STD_LOGIC := '0';
    signal up_down_tb : STD_LOGIC := '1';
    signal q_tb       : STD_LOGIC_VECTOR(3 downto 0);

    component up_down_counter
        Port ( clk      : in  STD_LOGIC;
               reset    : in  STD_LOGIC;
               up_down  : in  STD_LOGIC;
               q        : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin

    UUT: up_down_counter port map (
        clk     => clk_tb,
        reset   => reset_tb,
        up_down => up_down_tb,
        q       => q_tb
    );

    -- 10 ns clock
    clk_tb <= not clk_tb after 5 ns;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        reset_tb <= '1'; up_down_tb <= '1'; wait for 10 ns;
        
        -- Count up
        reset_tb <= '0'; up_down_tb <= '1'; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns;  -- Up to 15
        
        -- Count down
        up_down_tb <= '0';
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        wait for 10 ns; wait for 10 ns; wait for 10 ns; wait for 10 ns;
        
        -- Reset
        reset_tb <= '1'; wait for 10 ns;
        reset_tb <= '0'; wait;
    end process;

end sim;