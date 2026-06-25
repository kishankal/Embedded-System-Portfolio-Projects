library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity traffic_light is
    Port ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           red      : out STD_LOGIC;
           green    : out STD_LOGIC;
           yellow   : out STD_LOGIC);
end traffic_light;

architecture Behavioral of traffic_light is
    -- State encoding
    type state_type is (RED_STATE, GREEN_STATE, YELLOW_STATE);
    signal current_state, next_state : state_type;
    
    -- Timer signals
    signal timer : INTEGER range 0 to 15 := 0;
    signal timer_done : STD_LOGIC := '0';
    
    -- Timing constants (in clock cycles)
    constant RED_TIME    : INTEGER := 10;   -- 10 seconds
    constant GREEN_TIME  : INTEGER := 15;   -- 15 seconds
    constant YELLOW_TIME : INTEGER := 5;    -- 5 seconds
    
begin
    -- State register process
    state_register: process(clk, reset)
    begin
        if reset = '1' then
            current_state <= RED_STATE;
            timer <= 0;
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            -- Timer logic
            if timer_done = '1' then
                timer <= 0;
            else
                timer <= timer + 1;
            end if;
        end if;
    end process;
    
    -- Next state logic
    next_state_logic: process(current_state, timer_done)
    begin
        case current_state is
            when RED_STATE =>
                if timer_done = '1' then
                    next_state <= GREEN_STATE;
                else
                    next_state <= RED_STATE;
                end if;
                
            when GREEN_STATE =>
                if timer_done = '1' then
                    next_state <= YELLOW_STATE;
                else
                    next_state <= GREEN_STATE;
                end if;
                
            when YELLOW_STATE =>
                if timer_done = '1' then
                    next_state <= RED_STATE;
                else
                    next_state <= YELLOW_STATE;
                end if;
        end case;
    end process;
    
    -- Timer done logic
    timer_done_logic: process(current_state, timer)
    begin
        case current_state is
            when RED_STATE =>
                if timer = RED_TIME - 1 then
                    timer_done <= '1';
                else
                    timer_done <= '0';
                end if;
                
            when GREEN_STATE =>
                if timer = GREEN_TIME - 1 then
                    timer_done <= '1';
                else
                    timer_done <= '0';
                end if;
                
            when YELLOW_STATE =>
                if timer = YELLOW_TIME - 1 then
                    timer_done <= '1';
                else
                    timer_done <= '0';
                end if;
        end case;
    end process;
    
    -- Output logic (Moore - depends only on current state)
    output_logic: process(current_state)
    begin
        case current_state is
            when RED_STATE =>
                red <= '1';
                green <= '0';
                yellow <= '0';
                
            when GREEN_STATE =>
                red <= '0';
                green <= '1';
                yellow <= '0';
                
            when YELLOW_STATE =>
                red <= '0';
                green <= '0';
                yellow <= '1';
        end case;
    end process;
    
end Behavioral;