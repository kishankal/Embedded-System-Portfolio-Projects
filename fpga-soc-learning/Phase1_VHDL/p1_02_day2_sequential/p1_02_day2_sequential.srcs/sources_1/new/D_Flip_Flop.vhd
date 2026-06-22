library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dff_sync is
    Port ( clk   : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           d     : in  STD_LOGIC;
           q     : out STD_LOGIC);
end dff_sync;

architecture Behavioral of dff_sync is
begin
    process(clk)
    begin   
        if rising_edge(clk) then
            if reset = '1' then
                q <= '0';
            else
                q <= d;
            end if;
        end if;
    end process; 
    -- write your process block here
end Behavioral;