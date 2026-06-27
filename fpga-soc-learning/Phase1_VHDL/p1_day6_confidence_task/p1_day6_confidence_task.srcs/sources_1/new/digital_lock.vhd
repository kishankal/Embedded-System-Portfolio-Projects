library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_lock is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        digit1   : in  std_logic_vector(3 downto 0);
        digit2   : in  std_logic_vector(3 downto 0);
        digit3   : in  std_logic_vector(3 downto 0);
        digit4   : in  std_logic_vector(3 downto 0);
        enter    : in  std_logic;
        lock_open: out std_logic
    );
end digital_lock;

architecture behavioral of digital_lock is

    constant PASS1 : std_logic_vector(3 downto 0) := "0001";  -- 1
    constant PASS2 : std_logic_vector(3 downto 0) := "0010";  -- 2
    constant PASS3 : std_logic_vector(3 downto 0) := "0011";  -- 3
    constant PASS4 : std_logic_vector(3 downto 0) := "0100";  -- 4

    signal correct : std_logic := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            lock_open <= '0';
        elsif rising_edge(clk) then
            if enter = '1' then
                if digit1 = PASS1 and digit2 = PASS2 and 
                   digit3 = PASS3 and digit4 = PASS4 then
                    lock_open <= '1';
                else
                    lock_open <= '0';
                end if;
            end if;
        end if;
    end process;

end behavioral;