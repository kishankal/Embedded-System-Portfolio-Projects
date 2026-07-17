-- ============================================================
-- PROJECT  : Stage 4 RTL Project 1 - UART Receiver
-- BOARD    : PYNQ-Z2 (xc7z020clg400-1)
-- TOOL     : Vivado 2025.2
-- ============================================================
--
-- UART RX OPERATION:
--   1. Wait for falling edge on rx (start bit detection)
--   2. Wait half bit period to reach MIDDLE of start bit
--   3. Verify rx still LOW (valid start bit, not noise)
--   4. Sample each data bit at MIDDLE of bit period
--   5. After 8 data bits, sample stop bit
--   6. Pulse rx_done for 1 clock with received byte
--
-- WHY SAMPLE AT MIDDLE?
--   Bit period = CLKS_PER_BIT clocks
--   Sample at CLKS_PER_BIT/2 = middle of bit
--   Maximum noise margin from bit transition edges
--   Tolerates small baud rate mismatch between TX and RX
--
-- FSM STATES:
--   IDLE    : waiting for start bit (rx falling edge)
--   START   : verify start bit at middle
--   DATA    : sample 8 data bits at middle of each bit
--   STOP    : wait for stop bit, pulse rx_done
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        CLKS_PER_BIT : integer := 868  -- 100MHz / 115200
    );
    port (
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        rx      : in  STD_LOGIC;
        rx_data : out STD_LOGIC_VECTOR(7 downto 0);
        rx_done : out STD_LOGIC   -- pulses HIGH 1 clock when byte received
    );
end entity uart_rx;

architecture Behavioral of uart_rx is

    -- FSM states
    type t_state is (IDLE, START, DATA, STOP);
    signal state : t_state := IDLE;

    -- Clock counter
    signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0;

    -- Bit index (0 to 7)
    signal bit_index : integer range 0 to 7 := 0;

    -- Internal received data register
    signal rx_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state     <= IDLE;
                clk_count <= 0;
                bit_index <= 0;
                rx_reg    <= (others => '0');
                rx_data   <= (others => '0');
                rx_done   <= '0';

            else
                -- Default: rx_done LOW (only pulses for 1 clock)
                rx_done <= '0';

                case state is

                    -- ─────────────────────────────────────────
                    -- IDLE: watch for falling edge (start bit)
                    -- rx line idle = HIGH
                    -- Start bit = LOW
                    -- ─────────────────────────────────────────
                    when IDLE =>
                        clk_count <= 0;
                        bit_index <= 0;

                        if rx = '0' then
                            -- Falling edge detected - possible start bit
                            state <= START;
                        end if;

                    -- ─────────────────────────────────────────
                    -- START: wait to middle of start bit
                    -- Then verify it is still LOW (not noise)
                    -- ─────────────────────────────────────────
                    when START =>
                        -- Wait until middle of start bit
                        if clk_count = (CLKS_PER_BIT - 1) / 2 then
                            if rx = '0' then
                                -- Valid start bit confirmed
                                clk_count <= 0;
                                state     <= DATA;
                            else
                                -- Was noise - return to idle
                                state <= IDLE;
                            end if;
                        else
                            clk_count <= clk_count + 1;
                        end if;

                    -- ─────────────────────────────────────────
                    -- DATA: sample 8 bits at MIDDLE of each bit
                    -- Wait full bit period between samples
                    -- ─────────────────────────────────────────
                    when DATA =>
                        if clk_count < CLKS_PER_BIT - 1 then
                            clk_count <= clk_count + 1;
                        else
                            -- At middle+full_period = middle of next bit
                            clk_count <= 0;

                            -- Sample current bit into register
                            -- LSB first: bit 0 received first
                            rx_reg(bit_index) <= rx;

                            if bit_index < 7 then
                                bit_index <= bit_index + 1;
                            else
                                -- All 8 bits received
                                bit_index <= 0;
                                state     <= STOP;
                            end if;
                        end if;

                    -- ─────────────────────────────────────────
                    -- STOP: wait for stop bit (HIGH)
                    -- Then output received byte and pulse rx_done
                    -- ─────────────────────────────────────────
                    when STOP =>
                        if clk_count < CLKS_PER_BIT - 1 then
                            clk_count <= clk_count + 1;
                        else
                            -- Stop bit period complete
                            -- Output received data
                            rx_data   <= rx_reg;
                            rx_done   <= '1';  -- pulse for 1 clock
                            clk_count <= 0;
                            state     <= IDLE;
                        end if;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end architecture Behavioral;