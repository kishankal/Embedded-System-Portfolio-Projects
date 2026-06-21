library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xor_gate is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           y : out STD_LOGIC);
end xor_gate;

architecture Behavioral of xor_gate is
begin
    y <= a xor b;
end Behavioral;