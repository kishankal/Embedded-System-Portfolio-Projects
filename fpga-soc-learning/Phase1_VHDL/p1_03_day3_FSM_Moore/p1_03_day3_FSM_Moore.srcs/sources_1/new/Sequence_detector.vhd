library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seq_detector_101 is
    Port ( clk    : in  STD_LOGIC;
           reset  : in  STD_LOGIC;
           input  : in  STD_LOGIC;
           output : out STD_LOGIC);
end seq_detector_101;

architecture Behavioral of seq_detector_101 is
    type state_type is (S0, S1, S2, S3);
    signal current_state, next_state : state_type;
begin
    -- State register
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= S0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Next state logic
    process(current_state, input)
    begin
        case current_state is
            when S0 =>  -- IDLE
                if input = '1' then
                    next_state <= S1;
                else
                    next_state <= S0;
                end if;
                
            when S1 =>  -- Got '1'
                if input = '0' then
                    next_state <= S2;
                else
                    next_state <= S1;
                end if;
                
            when S2 =>  -- Got '10'
                if input = '1' then
                    next_state <= S3;
                else
                    next_state <= S0;
                end if;
                
            when S3 =>  -- Got '101' - DETECTED!
                if input = '1' then
                    next_state <= S1;  -- Overlapping detection
                else
                    next_state <= S0;
                end if;
        end case;
    end process;
    
    -- Output logic (Moore)
    process(current_state)
    begin
        case current_state is
            when S3 => output <= '1';
            when others => output <= '0';
        end case;
    end process;
end Behavioral;