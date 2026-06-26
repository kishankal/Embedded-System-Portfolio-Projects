library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo is
    generic (
        DATA_WIDTH : integer := 8;
        DEPTH      : integer := 16
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        wr_en    : in  std_logic;
        rd_en    : in  std_logic;
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        full     : buffer  std_logic;
        empty    : buffer  std_logic
    );
end sync_fifo;

architecture behavioral of sync_fifo is

    -- Memory array
    type ram_type is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    
    -- Pointers
    signal wr_ptr : integer range 0 to DEPTH-1 := 0;
    signal rd_ptr : integer range 0 to DEPTH-1 := 0;
    
    -- Count
    signal count : integer range 0 to DEPTH := 0;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            
        elsif rising_edge(clk) then
            
            -- Write operation
            if wr_en = '1' and full = '0' then
                ram(wr_ptr) <= data_in;
                if wr_ptr = DEPTH-1 then
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
                count <= count + 1;
            end if;
            
            -- Read operation
            if rd_en = '1' and empty = '0' then
                data_out <= ram(rd_ptr);
                if rd_ptr = DEPTH-1 then
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
                end if;
                count <= count - 1;
            end if;
            
            -- Simultaneous read and write
            if wr_en = '1' and rd_en = '1' and full = '0' and empty = '0' then
                count <= count;  -- Count stays same
            end if;
            
        end if;
    end process;

    -- Status flags
    full <= '1' when count = DEPTH else '0';
    empty <= '1' when count = 0 else '0';

end behavioral;