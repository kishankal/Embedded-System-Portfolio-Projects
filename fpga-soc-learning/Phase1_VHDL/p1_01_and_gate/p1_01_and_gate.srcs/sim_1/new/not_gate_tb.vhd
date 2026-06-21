library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity not_gate_tb is
end not_gate_tb;

architecture sim of not_gate_tb is
    signal a_tb, y_tb : STD_LOGIC;

    component not_gate
        Port ( a : in  STD_LOGIC;
               y : out STD_LOGIC);
    end component;
begin
    UUT: not_gate port map (a => a_tb, y => y_tb);

    stim_proc: process
    begin
        a_tb <= '0'; wait for 10 ns;
        a_tb <= '1'; wait for 10 ns;
        wait;
    end process;
end sim;