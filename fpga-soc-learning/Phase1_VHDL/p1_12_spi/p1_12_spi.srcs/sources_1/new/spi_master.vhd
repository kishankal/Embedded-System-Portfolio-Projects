-- ============================================================
-- PROJECT  : Stage 4 RTL Project 3 - SPI Master
-- BOARD    : PYNQ-Z2 (xc7z020clg400-1)
-- TOOL     : Vivado 2025.2
-- ============================================================
--
-- SPI MODE 0 (CPOL=0, CPHA=0):
--   Clock idle = LOW
--   Data sampled on RISING edge
--   Data shifted on FALLING edge
--   MSB transmitted first
--
-- TRANSACTION SEQUENCE:
--   1. CS goes LOW  (slave selected)
--   2. 8 SCLK pulses generated
--      - Falling edge: shift out MOSI bit
--      - Rising edge:  sample MISO bit
--   3. CS goes HIGH (slave deselected)
--   4. spi_done pulses HIGH for 1 clock
--
-- CLOCK DIVIDER:
--   SPI_CLK_DIV = System_Clock / (2 x SPI_Freq)
--   100MHz / (2 x 1MHz) = 50
--   Counter 0 to SPI_CLK_DIV-1 = half period LOW
--   Counter SPI_CLK_DIV to 2xSPI_CLK_DIV-1 = half period HIGH
--
-- FSM STATES:
--   IDLE     : wait for spi_start
--   CS_LOW   : assert CS, wait 1 SPI clock
--   TRANSFER : generate 8 SCLK pulses, shift MOSI, sample MISO
--   CS_HIGH  : deassert CS, output data, pulse spi_done
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    generic (
        -- SPI clock divider
        -- SPI_CLK_DIV = System_Clock / (2 x SPI_Frequency)
        -- Default: 100MHz / (2 x 1MHz) = 50
        SPI_CLK_DIV : integer := 50
    );
    port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        spi_start : in  STD_LOGIC;
        mosi_data : in  STD_LOGIC_VECTOR(7 downto 0);
        miso      : in  STD_LOGIC;
        sclk      : out STD_LOGIC;
        mosi      : out STD_LOGIC;
        cs        : out STD_LOGIC;
        miso_data : out STD_LOGIC_VECTOR(7 downto 0);
        spi_done  : out STD_LOGIC
    );
end entity spi_master;

architecture Behavioral of spi_master is

    -- FSM states
    type t_state is (IDLE, CS_LOW, TRANSFER, CS_HIGH);
    signal state : t_state := IDLE;

    -- Clock divider counter
    -- Counts 0 to SPI_CLK_DIV-1 for each half period
    signal clk_div_cnt : integer range 0 to SPI_CLK_DIV - 1 := 0;

    -- SPI clock enable - pulses at SPI frequency
    -- HIGH = time to toggle SCLK
    signal sclk_en : STD_LOGIC := '0';

    -- Internal SCLK signal
    signal sclk_int : STD_LOGIC := '0';

    -- Bit counter - counts 0 to 7 (8 bits per transfer)
    signal bit_cnt : integer range 0 to 7 := 0;

    -- Shift register for TX data (loaded from mosi_data)
    signal tx_shift : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Shift register for RX data (builds up received bits)
    signal rx_shift : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Internal CS signal
    signal cs_int : STD_LOGIC := '1';  -- idle HIGH

    -- Transfer phase flag
    -- '0' = first half of bit period (SCLK LOW  → shift MOSI)
    -- '1' = second half of bit period (SCLK HIGH → sample MISO)
    signal sclk_phase : STD_LOGIC := '0';

begin

    -- Connect internal signals to output ports
    sclk <= sclk_int;
    cs   <= cs_int;

    -- ─────────────────────────────────────────────────────────
    -- Clock Divider - generates SPI clock enable pulse
    -- Toggles every SPI_CLK_DIV system clock cycles
    -- ─────────────────────────────────────────────────────────
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                clk_div_cnt <= 0;
                sclk_en     <= '0';
            else
                if clk_div_cnt = SPI_CLK_DIV - 1 then
                    clk_div_cnt <= 0;
                    sclk_en     <= '1';  -- pulse for 1 system clock
                else
                    clk_div_cnt <= clk_div_cnt + 1;
                    sclk_en     <= '0';
                end if;
            end if;
        end if;
    end process;

    -- ─────────────────────────────────────────────────────────
    -- SPI Master FSM
    -- Advances only when sclk_en is HIGH (at SPI clock rate)
    -- ─────────────────────────────────────────────────────────
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state      <= IDLE;
                cs_int     <= '1';
                sclk_int   <= '0';
                mosi       <= '0';
                miso_data  <= (others => '0');
                spi_done   <= '0';
                bit_cnt    <= 0;
                sclk_phase <= '0';
                tx_shift   <= (others => '0');
                rx_shift   <= (others => '0');

            else
                -- Default: spi_done LOW
                spi_done <= '0';

                case state is

                    -- ─────────────────────────────────────────
                    -- IDLE: wait for spi_start
                    -- CS=HIGH, SCLK=LOW
                    -- ─────────────────────────────────────────
                    when IDLE =>
                        cs_int     <= '1';   -- deasserted
                        sclk_int   <= '0';   -- idle LOW (Mode 0)
                        sclk_phase <= '0';
                        bit_cnt    <= 7;     -- start from MSB (bit 7)

                        if spi_start = '1' then
                            -- Latch TX data and begin
                            tx_shift <= mosi_data;
                            rx_shift <= (others => '0');
                            state    <= CS_LOW;
                        end if;

                    -- ─────────────────────────────────────────
                    -- CS_LOW: assert CS, drive first MOSI bit
                    -- Wait 1 SPI clock period before transfer
                    -- ─────────────────────────────────────────
                    when CS_LOW =>
                        if sclk_en = '1' then
                            cs_int <= '0';  -- select slave

                            -- Drive MSB on MOSI before first clock
                            mosi  <= tx_shift(7);
                            state <= TRANSFER;
                        end if;

                    -- ─────────────────────────────────────────
                    -- TRANSFER: generate 8 SPI clock pulses
                    -- Each pulse has 2 phases:
                    --   Phase 0: SCLK LOW  - shift out MOSI
                    --   Phase 1: SCLK HIGH - sample MISO
                    -- ─────────────────────────────────────────
                    when TRANSFER =>
                        if sclk_en = '1' then
                            if sclk_phase = '0' then
                                -- ── Phase 0: SCLK goes HIGH ──────
                                -- Rising edge - sample MISO
                                sclk_int <= '1';

                                -- Sample MISO into RX shift register
                                -- MSB first: shift left, insert at bit 0
                                rx_shift <= rx_shift(6 downto 0) & miso;

                                sclk_phase <= '1';

                            else
                                -- ── Phase 1: SCLK goes LOW ───────
                                -- Falling edge - shift out next MOSI
                                sclk_int <= '0';

                                if bit_cnt > 0 then
                                    -- More bits - shift TX register left
                                    -- Next bit (bit_cnt-1) goes to MOSI
                                    tx_shift <= tx_shift(6 downto 0) & '0';
                                    mosi     <= tx_shift(6); -- next MSB
                                    bit_cnt  <= bit_cnt - 1;
                                else
                                    -- All 8 bits done
                                    state <= CS_HIGH;
                                end if;

                                sclk_phase <= '0';
                            end if;
                        end if;

                    -- ─────────────────────────────────────────
                    -- CS_HIGH: deassert CS
                    -- Output received data, pulse spi_done
                    -- ─────────────────────────────────────────
                    when CS_HIGH =>
                        if sclk_en = '1' then
                            cs_int    <= '1';      -- deselect slave
                            sclk_int  <= '0';      -- clock idle LOW
                            miso_data <= rx_shift; -- output received byte
                            spi_done  <= '1';      -- pulse done
                            state     <= IDLE;
                        end if;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end architecture Behavioral;