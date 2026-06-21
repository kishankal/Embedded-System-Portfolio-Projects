library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder_tb is
end full_adder_tb;

architecture sim of full_adder_tb is
    signal a_tb, b_tb, cin_tb, sum_tb, cout_tb : STD_LOGIC;

    component full_adder
        Port ( a    : in  STD_LOGIC;
               b    : in  STD_LOGIC;
               cin  : in  STD_LOGIC;
               sum  : out STD_LOGIC;
               cout : out STD_LOGIC);
    end component;
begin
    UUT: full_adder port map (a => a_tb, b => b_tb, cin => cin_tb, sum => sum_tb, cout => cout_tb);

    stim_proc: process
    begin
        a_tb<='0'; b_tb<='0'; cin_tb<='0'; wait for 10 ns;
        a_tb<='0'; b_tb<='0'; cin_tb<='1'; wait for 10 ns;
        a_tb<='0'; b_tb<='1'; cin_tb<='0'; wait for 10 ns;
        a_tb<='0'; b_tb<='1'; cin_tb<='1'; wait for 10 ns;
        a_tb<='1'; b_tb<='0'; cin_tb<='0'; wait for 10 ns;
        a_tb<='1'; b_tb<='0'; cin_tb<='1'; wait for 10 ns;
        a_tb<='1'; b_tb<='1'; cin_tb<='0'; wait for 10 ns;
        a_tb<='1'; b_tb<='1'; cin_tb<='1'; wait for 10 ns;
        wait;
    end process;
end sim;