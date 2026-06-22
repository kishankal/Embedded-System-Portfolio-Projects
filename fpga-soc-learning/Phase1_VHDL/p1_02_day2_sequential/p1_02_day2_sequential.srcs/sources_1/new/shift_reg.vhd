library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg is
    Port ( clk      : in  STD_LOGIC;
           sin      : in  STD_LOGIC;                     -- serial input bit
           q        : out STD_LOGIC_VECTOR(3 downto 0));  -- 4-bit output
end shift_reg;

architecture Behavioral of shift_reg is
    signal temp : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- shift logic here using temp
            temp(3) <= temp(2);
            temp(2) <= temp(1);
            temp(1) <= temp(0);
            temp(0) <= sin;
        end if;
    end process;
    q <= temp;
    
end Behavioral;