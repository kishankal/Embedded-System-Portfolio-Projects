library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity up_down_counter is
    Port ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           up_down  : in  STD_LOGIC;  -- '1' = count up, '0' = count down
           q        : out STD_LOGIC_VECTOR(3 downto 0));
end up_down_counter;

architecture Behavioral of up_down_counter is
    signal temp : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                temp <= "0000";
            elsif up_down = '1' then
                temp <= std_logic_vector(unsigned(temp) + 1);  -- Count up
            else
                temp <= std_logic_vector(unsigned(temp) - 1);  -- Count down
            end if;
        end if;
    end process;
    q <= temp;
end Behavioral;