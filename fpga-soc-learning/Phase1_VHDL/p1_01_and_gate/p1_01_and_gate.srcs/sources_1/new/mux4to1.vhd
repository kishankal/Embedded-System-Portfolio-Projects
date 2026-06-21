library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1 is
    Port ( i0  : in  STD_LOGIC;
           i1  : in  STD_LOGIC;
           i2  : in  STD_LOGIC;
           i3  : in  STD_LOGIC;
           sel : in  STD_LOGIC_VECTOR(1 downto 0);
           y   : out STD_LOGIC);
end mux4to1;

architecture Behavioral of mux4to1 is
begin
    process(i0, i1, i2, i3, sel)
    begin
        case sel is
            when "00" => y <= i0;
            when "01" => y <= i1;
            when "10" => y <= i2;
            when "11" => y <= i3;
            when others => y <= '0';
        end case;
    end process;
end Behavioral;