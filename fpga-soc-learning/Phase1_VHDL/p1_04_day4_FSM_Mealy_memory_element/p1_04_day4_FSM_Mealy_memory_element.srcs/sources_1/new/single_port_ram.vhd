library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_ram is
    port (
        clk      : in  std_logic;
        we       : in  std_logic;          -- Write Enable
        address  : in  std_logic_vector(3 downto 0);  -- 16 locations
        data_in  : in  std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0)
    );
end single_port_ram;

architecture behavioral of single_port_ram is

    -- Define memory array: 16 locations x 8 bits
    type ram_type is array (0 to 15) of std_logic_vector(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                -- Write operation
                ram(to_integer(unsigned(address))) <= data_in;
                data_out <= (others => '0');  -- Optional: don't care on write
            else
                -- Read operation
                data_out <= ram(to_integer(unsigned(address)));
            end if;
        end if;
    end process;

end behavioral;