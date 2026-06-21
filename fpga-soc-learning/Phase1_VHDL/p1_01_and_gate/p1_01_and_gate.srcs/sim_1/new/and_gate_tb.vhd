library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity and_gate_tb is
end and_gate_tb;

architecture sim of and_gate_tb is
    signal a_tb, b_tb, y_tb : STD_LOGIC;

    component and_gate
        Port ( a : in  STD_LOGIC;
               b : in  STD_LOGIC;
               y : out STD_LOGIC);
    end component;
begin
    UUT: and_gate port map (a => a_tb, b => b_tb, y => y_tb);

    stim_proc: process
    begin
        a_tb <= '0'; b_tb <= '0'; wait for 10 ns;
        a_tb <= '0'; b_tb <= '1'; wait for 10 ns;
        a_tb <= '1'; b_tb <= '0'; wait for 10 ns;
        a_tb <= '1'; b_tb <= '1'; wait for 10 ns;
        wait;
    end process;
end sim;