library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_ram is
    port (
        clk        : in  std_logic;
        
        -- Port A
        we_a       : in  std_logic;
        address_a  : in  std_logic_vector(3 downto 0);
        data_in_a  : in  std_logic_vector(7 downto 0);
        data_out_a : out std_logic_vector(7 downto 0);
        
        -- Port B
        we_b       : in  std_logic;
        address_b  : in  std_logic_vector(3 downto 0);
        data_in_b  : in  std_logic_vector(7 downto 0);
        data_out_b : out std_logic_vector(7 downto 0)
    );
end dual_port_ram;

architecture behavioral of dual_port_ram is

    type ram_type is array (0 to 15) of std_logic_vector(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

begin

    -- Port A operations
    process(clk)
    begin
        if rising_edge(clk) then
            if we_a = '1' then
                ram(to_integer(unsigned(address_a))) <= data_in_a;
            end if;
            data_out_a <= ram(to_integer(unsigned(address_a)));
        end if;
    end process;

    -- Port B operations
    process(clk)
    begin
        if rising_edge(clk) then
            if we_b = '1' then
                ram(to_integer(unsigned(address_b))) <= data_in_b;
            end if;
            data_out_b <= ram(to_integer(unsigned(address_b)));
        end if;
    end process;

end behavioral;