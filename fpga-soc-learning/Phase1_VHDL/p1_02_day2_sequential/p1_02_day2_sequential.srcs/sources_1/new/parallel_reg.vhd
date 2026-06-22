library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity parallel_load_reg is
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC;
           load    : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(3 downto 0);
           q       : out STD_LOGIC_VECTOR(3 downto 0));
end parallel_load_reg;

architecture Behavioral of parallel_load_reg is
    signal temp : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                temp <= "0000";
            elsif load = '1' then
                temp <= data_in;
            end if;
        end if;
    end process;
    q <= temp;
end Behavioral;