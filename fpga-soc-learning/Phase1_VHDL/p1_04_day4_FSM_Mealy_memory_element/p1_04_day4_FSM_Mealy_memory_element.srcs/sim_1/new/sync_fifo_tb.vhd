library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo_tb is
end sync_fifo_tb;

architecture behavioral of sync_fifo_tb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal wr_en    : std_logic := '0';
    signal rd_en    : std_logic := '0';
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    signal full     : std_logic;
    signal empty    : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.sync_fifo
        generic map (
            DATA_WIDTH => 8,
            DEPTH      => 16
        )
        port map (
            clk      => clk,
            reset    => reset,
            wr_en    => wr_en,
            rd_en    => rd_en,
            data_in  => data_in,
            data_out => data_out,
            full     => full,
            empty    => empty
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_process: process
    begin
        -- Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        -- Test 1: Write 5 values, then read 5 values
        report "TEST 1: Write 5 values, read 5 values";
        
        for i in 0 to 4 loop
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i*10, 8));
            wait for clk_period;
        end loop;
        wr_en <= '0';
        
        wait for 10 ns;
        
        for i in 0 to 4 loop
            rd_en <= '1';
            wait for clk_period;
        end loop;
        rd_en <= '0';

        -- Test 2: Fill FIFO until full
        report "TEST 2: Fill FIFO until full";
        
        for i in 0 to 15 loop
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 8));
            wait for clk_period;
        end loop;
        wr_en <= '0';
        
        wait for 10 ns;
        -- Expected: full = '1'

        -- Test 3: Empty FIFO
        report "TEST 3: Empty FIFO";
        
        for i in 0 to 15 loop
            rd_en <= '1';
            wait for clk_period;
        end loop;
        rd_en <= '0';
        
        wait for 10 ns;
        -- Expected: empty = '1'

        -- Test 4: Simultaneous read and write
        report "TEST 4: Simultaneous read and write";
        
        -- Write some data first
        wr_en <= '1';
        data_in <= "10101010";
        wait for clk_period;
        data_in <= "11110000";
        wait for clk_period;
        wr_en <= '0';
        
        wait for 10 ns;
        
        -- Read and write at same time
        wr_en <= '1';
        rd_en <= '1';
        data_in <= "11001100";
        wait for clk_period;
        wr_en <= '0';
        rd_en <= '0';
        
        wait for 10 ns;

        -- Test 5: Read from empty FIFO (should not break)
        report "TEST 5: Read from empty FIFO";
        
        rd_en <= '1';
        wait for clk_period;
        rd_en <= '0';
        
        wait for 10 ns;

        -- Test 6: Write to full FIFO (should not break)
        report "TEST 6: Write to full FIFO";
        
        -- Fill FIFO first
        for i in 0 to 15 loop
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 8));
            wait for clk_period;
        end loop;
        wr_en <= '0';
        
        wait for 10 ns;
        
        -- Try to write when full
        wr_en <= '1';
        data_in <= "11111111";
        wait for clk_period;
        wr_en <= '0';
        
        wait for 10 ns;

        wait for 20 ns;
        report "SIMULATION COMPLETE!";
        wait;
    end process;

end behavioral;