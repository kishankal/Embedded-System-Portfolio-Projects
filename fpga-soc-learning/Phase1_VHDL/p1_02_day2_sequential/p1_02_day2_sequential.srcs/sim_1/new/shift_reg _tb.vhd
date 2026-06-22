library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg_tb is
end shift_reg_tb;

architecture sim of shift_reg_tb is

    signal clk_tb, sin_tb : STD_LOGIC;
    signal q_tb           : STD_LOGIC_VECTOR(3 downto 0);

    component shift_reg
        Port ( clk : in  STD_LOGIC;
               sin : in  STD_LOGIC;
               q   : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin

    UUT: shift_reg port map (clk => clk_tb, sin => sin_tb, q => q_tb);

    -- 10 ns clock
    clk_process: process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    -- Simple stimulus
    stim_proc: process
    begin
        -- Shift in: 1 0 1 0 1 1 1 1
        sin_tb <= '1'; wait for 10 ns;
        sin_tb <= '0'; wait for 10 ns;
        sin_tb <= '1'; wait for 10 ns;
        sin_tb <= '0'; wait for 10 ns;
        sin_tb <= '1'; wait for 10 ns;
        sin_tb <= '1'; wait for 10 ns;
        sin_tb <= '1'; wait for 10 ns;
        sin_tb <= '1'; wait for 10 ns;
        
        wait;
    end process;

end sim;