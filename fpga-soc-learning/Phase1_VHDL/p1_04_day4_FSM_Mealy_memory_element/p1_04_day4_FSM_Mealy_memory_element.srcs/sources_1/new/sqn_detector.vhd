library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sqn_detector is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic;
        detected : out std_logic
    );
end sqn_detector;

architecture behavioral of sqn_detector is

    type state_type is (s0, s1, s10);
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

    process(current_state, data_in)
    begin
        next_state <= current_state;
        detected <= '0';
        
        case current_state is
            when s0 =>
                if data_in = '1' then
                    next_state <= s1;
                end if;
                
            when s1 =>
                if data_in = '0' then
                    next_state <= s10;
                end if;
                
            when s10 =>
                if data_in = '1' then
                    next_state <= s1;
                    detected <= '1';
                else
                    next_state <= s0;
                end if;
        end case;
    end process;

end behavioral;