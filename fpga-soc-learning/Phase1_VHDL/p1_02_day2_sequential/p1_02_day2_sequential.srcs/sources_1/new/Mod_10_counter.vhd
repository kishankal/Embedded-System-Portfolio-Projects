library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mod10_counter is
    Port ( clk   : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           q     : out STD_LOGIC_VECTOR(3 downto 0));
end mod10_counter;

architecture Behavioral of mod10_counter is
    signal temp : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                temp <= "0000";
            elsif temp = "1001" then  -- When count reaches 9
                temp <= "0000";       -- Reset to 0
            else
                temp <= std_logic_vector(unsigned(temp) + 1);
            end if;
        end if;
    end process;
    q <= temp;
end Behavioral;