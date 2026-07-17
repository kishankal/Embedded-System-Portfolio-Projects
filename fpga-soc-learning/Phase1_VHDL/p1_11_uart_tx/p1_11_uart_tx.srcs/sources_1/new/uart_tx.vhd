-- ============================================================
-- PROJECT  : Stage 4 RTL Project 1 - UART Transmitter
-- BOARD    : PYNQ-Z2 (xc7z020clg400-1)
-- TOOL     : Vivado 2025.2
-- ============================================================
--
-- UART FRAME FORMAT (8N1):
--   [IDLE=1][START=0][D0][D1][D2][D3][D4][D5][D6][D7][STOP=1][IDLE=1]
--   LSB transmitted first
--   Baud rate = CLK_FREQ / CLKS_PER_BIT
--
-- FSM STATES:
--   IDLE     : tx=1, waiting for tx_start
--   START    : tx=0 for 1 bit period (start bit)
--   DATA     : tx=data bits D0-D7, one per bit period
--   STOP     : tx=1 for 1 bit period (stop bit)
--   CLEANUP  : tx_busy cleared, return to IDLE
--
-- BAUD RATE CALCULATION:
--   CLK_FREQ    = 100,000,000 (100MHz on PYNQ-Z2)
--   BAUD_RATE   = 115200
--   CLKS_PER_BIT = 100000000 / 115200 = 868 clocks per bit
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    generic (
        -- Number of clock cycles per UART bit
        -- 100MHz / 115200 baud = 868
        CLKS_PER_BIT : integer := 868
    );
    port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        tx_start : in  STD_LOGIC;  -- pulse high to start TX
        data_in  : in  STD_LOGIC_VECTOR(7 downto 0);  -- byte to send
        tx       : out STD_LOGIC;  -- serial output
        tx_busy  : out STD_LOGIC   -- high while transmitting
    );
end entity uart_tx;

architecture Behavioral of uart_tx is

    -- FSM state definition
    type t_state is (IDLE, START, DATA, STOP, CLEANUP);
    signal state : t_state := IDLE;

    -- Clock counter - counts up to CLKS_PER_BIT
    signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0;

    -- Bit index - which data bit we are currently sending (0 to 7)
    signal bit_index : integer range 0 to 7 := 0;

    -- Internal copy of data to send
    -- Latched when tx_start is detected
    signal tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Internal tx signal (need to read it back in DATA state)
    signal tx_int  : STD_LOGIC := '1';

begin

    -- Connect internal signal to output port
    tx <= tx_int;

    -- ─────────────────────────────────────────────────────────
    -- UART TX FSM
    -- Runs on every rising clock edge
    -- ─────────────────────────────────────────────────────────
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Synchronous reset - return to idle state
                state     <= IDLE;
                tx_int    <= '1';  -- UART idle line = HIGH
                tx_busy   <= '0';
                clk_count <= 0;
                bit_index <= 0;
                tx_data   <= (others => '0');

            else
                case state is

                    -- ─────────────────────────────────────────
                    -- IDLE: wait for tx_start pulse
                    -- ─────────────────────────────────────────
                    when IDLE =>
                        tx_int    <= '1';  -- line idle = HIGH
                        tx_busy   <= '0';
                        clk_count <= 0;
                        bit_index <= 0;

                        if tx_start = '1' then
                            -- Latch data and start transmission
                            tx_data <= data_in;
                            tx_busy <= '1';
                            state   <= START;
                        end if;

                    -- ─────────────────────────────────────────
                    -- START: send start bit (LOW) for 1 bit period
                    -- ─────────────────────────────────────────
                    when START =>
                        tx_int <= '0';  -- start bit = LOW

                        if clk_count < CLKS_PER_BIT - 1 then
                            clk_count <= clk_count + 1;
                        else
                            -- One bit period complete
                            clk_count <= 0;
                            state     <= DATA;
                        end if;

                    -- ─────────────────────────────────────────
                    -- DATA: send 8 data bits, LSB first
                    -- Each bit held for 1 bit period
                    -- ─────────────────────────────────────────
                    when DATA =>
                        -- Output current bit (LSB first = bit_index 0 first)
                        tx_int <= tx_data(bit_index);

                        if clk_count < CLKS_PER_BIT - 1 then
                            clk_count <= clk_count + 1;
                        else
                            clk_count <= 0;

                            if bit_index < 7 then
                                -- More bits to send
                                bit_index <= bit_index + 1;
                            else
                                -- All 8 bits sent - move to stop bit
                                bit_index <= 0;
                                state     <= STOP;
                            end if;
                        end if;

                    -- ─────────────────────────────────────────
                    -- STOP: send stop bit (HIGH) for 1 bit period
                    -- ─────────────────────────────────────────
                    when STOP =>
                        tx_int <= '1';  -- stop bit = HIGH

                        if clk_count < CLKS_PER_BIT - 1 then
                            clk_count <= clk_count + 1;
                        else
                            clk_count <= 0;
                            state     <= CLEANUP;
                        end if;

                    -- ─────────────────────────────────────────
                    -- CLEANUP: clear busy flag, return to IDLE
                    -- ─────────────────────────────────────────
                    when CLEANUP =>
                        tx_busy <= '0';
                        state   <= IDLE;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end architecture Behavioral;