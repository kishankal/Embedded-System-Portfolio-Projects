
-- Design:
-- Counter starts at 10 (available spaces)
-- Entry decreases count by 1
-- Exit increases count by 1
-- FULL when count = 0
-- EMPTY when count = 10
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parking_lot is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        entry     : in  std_logic;
        exit_car  : in  std_logic;
        available : out integer range 0 to 10;
        full      : out std_logic;
        empty     : out std_logic
    );
end parking_lot;

architecture behavioral of parking_lot is

    signal count : integer range 0 to 10 := 10;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            count <= 10;
        elsif rising_edge(clk) then
            if entry = '1' and count > 0 then
                count <= count - 1;
            elsif exit_car = '1' and count < 10 then
                count <= count + 1;
            end if;
        end if;
    end process;

    available <= count;
    full <= '1' when count = 0 else '0';
    empty <= '1' when count = 10 else '0';

end behavioral;