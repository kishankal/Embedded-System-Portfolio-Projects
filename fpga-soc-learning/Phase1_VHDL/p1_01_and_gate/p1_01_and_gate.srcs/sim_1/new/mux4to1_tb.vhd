library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1_tb is
end mux4to1_tb;

architecture sim of mux4to1_tb is
    signal i0_tb, i1_tb, i2_tb, i3_tb, y_tb : STD_LOGIC;
    signal sel_tb : STD_LOGIC_VECTOR(1 downto 0);

    component mux4to1
        Port ( i0  : in  STD_LOGIC;
               i1  : in  STD_LOGIC;
               i2  : in  STD_LOGIC;
               i3  : in  STD_LOGIC;
               sel : in  STD_LOGIC_VECTOR(1 downto 0);
               y   : out STD_LOGIC);
    end component;
begin
    UUT: mux4to1 port map (i0 => i0_tb, i1 => i1_tb, i2 => i2_tb, i3 => i3_tb,
                            sel => sel_tb, y => y_tb);

    stim_proc: process
    begin
        sel_tb <= "00"; i0_tb<='1'; i1_tb<='0'; i2_tb<='0'; i3_tb<='0'; wait for 10 ns;
        sel_tb <= "01"; i0_tb<='0'; i1_tb<='1'; i2_tb<='0'; i3_tb<='0'; wait for 10 ns;
        sel_tb <= "10"; i0_tb<='0'; i1_tb<='0'; i2_tb<='1'; i3_tb<='0'; wait for 10 ns;
        sel_tb <= "11"; i0_tb<='0'; i1_tb<='0'; i2_tb<='0'; i3_tb<='1'; wait for 10 ns;
        wait;
    end process;
end sim;