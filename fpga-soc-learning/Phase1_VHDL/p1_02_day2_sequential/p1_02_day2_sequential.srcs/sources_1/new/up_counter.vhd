library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity up_counter is
    Port ( clk   : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           q     : out STD_LOGIC_VECTOR(3 downto 0));
end up_counter;

architecture Behavioral of up_counter is
    signal temp : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                temp <= "0000";
            else
                temp <= std_logic_vector(unsigned(temp) + 1);
            end if;
        end if;
    end process;
    q <= temp;
end Behavioral;