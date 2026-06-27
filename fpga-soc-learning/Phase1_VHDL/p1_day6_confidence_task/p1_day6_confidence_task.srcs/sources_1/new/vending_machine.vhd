library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vending_machine is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        coin_5    : in  std_logic;
        coin_10   : in  std_logic;
        coin_25   : in  std_logic;
        dispense  : out std_logic;
        change_5  : out std_logic;
        change_10 : out std_logic
    );
end vending_machine;

architecture behavioral of vending_machine is

    type state_type is (s0, s5, s10, s15, s20, s25, s30);
    signal current_state, next_state : state_type;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= s0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, coin_5, coin_10, coin_25)
    begin
        next_state <= current_state;
        dispense <= '0';
        change_5 <= '0';
        change_10 <= '0';
        
        case current_state is
            when s0 =>
                if coin_5 = '1' then
                    next_state <= s5;
                elsif coin_10 = '1' then
                    next_state <= s10;
                elsif coin_25 = '1' then
                    next_state <= s25;
                end if;
                
            when s5 =>
                if coin_5 = '1' then
                    next_state <= s10;
                elsif coin_10 = '1' then
                    next_state <= s15;
                elsif coin_25 = '1' then
                    next_state <= s30;
                    dispense <= '1';
                end if;
                
            when s10 =>
                if coin_5 = '1' then
                    next_state <= s15;
                elsif coin_10 = '1' then
                    next_state <= s20;
                elsif coin_25 = '1' then
                    next_state <= s30;
                    dispense <= '1';
                    change_5 <= '1';
                end if;
                
            when s15 =>
                if coin_5 = '1' then
                    next_state <= s20;
                elsif coin_10 = '1' then
                    next_state <= s25;
                elsif coin_25 = '1' then
                    next_state <= s0;
                    dispense <= '1';
                    change_10 <= '1';
                end if;
                
            when s20 =>
                if coin_5 = '1' then
                    next_state <= s25;
                elsif coin_10 = '1' then
                    next_state <= s30;
                    dispense <= '1';
                elsif coin_25 = '1' then
                    next_state <= s0;
                    dispense <= '1';
                    change_10 <= '1';
                    change_5 <= '1';
                end if;
                
            when s25 =>
                if coin_5 = '1' then
                    next_state <= s30;
                    dispense <= '1';
                elsif coin_10 = '1' then
                    next_state <= s0;
                    dispense <= '1';
                    change_5 <= '1';
                elsif coin_25 = '1' then
                    next_state <= s0;
                    dispense <= '1';
                    change_10 <= '1';
                    change_10 <= '1';
                end if;
                
            when s30 =>
                next_state <= s0;
                dispense <= '1';
                
        end case;
    end process;

end behavioral;