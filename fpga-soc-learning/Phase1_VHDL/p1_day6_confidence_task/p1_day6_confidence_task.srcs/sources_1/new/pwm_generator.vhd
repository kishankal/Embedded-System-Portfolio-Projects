library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
    generic (
        PERIOD : integer := 100
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        duty_cycle: in  integer range 0 to PERIOD;
        pwm_out   : out std_logic
    );
end pwm_generator;

architecture behavioral of pwm_generator is

    signal counter : integer range 0 to PERIOD-1 := 0;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            pwm_out <= '0';
        elsif rising_edge(clk) then
            if counter < PERIOD-1 then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;
            
            if counter < duty_cycle then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;
        end if;
    end process;

end behavioral;