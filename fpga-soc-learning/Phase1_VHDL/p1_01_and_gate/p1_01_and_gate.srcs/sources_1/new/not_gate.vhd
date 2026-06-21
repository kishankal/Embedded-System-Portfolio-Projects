library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity not_gate is
    Port ( a : in  STD_LOGIC;
           y : out STD_LOGIC);
end not_gate;

architecture Behavioral of not_gate is
begin
    y <= not a;
end Behavioral;