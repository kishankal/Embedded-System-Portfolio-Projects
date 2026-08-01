--------------------------------------------------------------------------------
-- pwm_axi_slave.vhd
-- AXI4-Lite slave with PWM output
-- Supports three 32-bit registers:
--   Offset 0x00 : CTRL   (bit0 = enable)
--   Offset 0x04 : PERIOD (full 32-bit period)
--   Offset 0x08 : DUTY   (full 32-bit duty)
--   Offset 0x0C : STATUS (read-only, bit0 = running)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_axi_slave is
  generic (
    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 4
  );
  port (
    -- Global AXI signals
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;

    -- Write address channel
    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;

    -- Write data channel
    S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;

    -- Write response channel
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;

    -- Read address channel
    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;

    -- Read data channel
    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;

    -- PWM output
    pwm_out       : out std_logic
  );
end entity pwm_axi_slave;

architecture Behavioral of pwm_axi_slave is

  -- Register array
  signal ctrl_reg  : std_logic_vector(31 downto 0) := (others => '0');
  signal period_reg: std_logic_vector(31 downto 0) := (others => '0');
  signal duty_reg  : std_logic_vector(31 downto 0) := (others => '0');

  -- Internal signals for PWM core
  signal enable   : std_logic;
  signal running  : std_logic;
  signal rst_hi   : std_logic;

  -- Write FSM
  type t_wr_state is (IDLE, WDATA, RESP);
  signal wr_state : t_wr_state := IDLE;
  signal wr_addr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);

  -- Read handshake signals
  signal ar_ready : std_logic;
  signal r_valid  : std_logic;
  signal rd_data  : std_logic_vector(31 downto 0);

begin

  -- Enable = bit 0 of ctrl_reg
  enable <= ctrl_reg(0);

  -- Invert reset polarity for PWM core (active-high)
  rst_hi <= not S_AXI_ARESETN;

  -- ------------------------------------------------------------------
  -- Instantiate PWM core (all ports connected)
  -- ------------------------------------------------------------------
  pwm_core_inst : entity work.pwm_core
    port map (
      clk     => S_AXI_ACLK,
      rst     => rst_hi,
      enable  => enable,
      period  => period_reg,
      duty    => duty_reg,
      pwm_out => pwm_out,
      running => running
    );

  -- ------------------------------------------------------------------
  -- Write address and data handling
  -- ------------------------------------------------------------------
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        wr_state <= IDLE;
        wr_addr  <= (others => '0');
        ctrl_reg <= (others => '0');
        period_reg <= (others => '0');
        duty_reg   <= (others => '0');
        S_AXI_AWREADY <= '0';
        S_AXI_WREADY  <= '0';
        S_AXI_BVALID  <= '0';
        S_AXI_BRESP   <= "00";
      else
        -- Default assignments
        S_AXI_AWREADY <= '0';
        S_AXI_WREADY  <= '0';
        S_AXI_BVALID  <= '0';

        case wr_state is
          when IDLE =>
            -- Accept both address and data if valid
            if S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then
              wr_addr <= S_AXI_AWADDR;
              -- Store the write data (will be written later in RESP)
              -- For now, we'll decode and update registers immediately
              -- or we can do it in RESP; we'll do it here for simplicity.
              -- Decode address and update register
              case S_AXI_AWADDR(3 downto 0) is
                when x"0" => ctrl_reg   <= S_AXI_WDATA;
                when x"4" => period_reg <= S_AXI_WDATA;
                when x"8" => duty_reg   <= S_AXI_WDATA;
                when others => null;  -- ignored but still respond
              end case;
              -- Move to response state
              wr_state <= RESP;
              S_AXI_AWREADY <= '1';
              S_AXI_WREADY  <= '1';
            else
              -- If only one is valid, we could wait, but simple design
              -- requires both in same cycle.
              null;
            end if;

          when RESP =>
            -- Provide write response
            S_AXI_BVALID <= '1';
            S_AXI_BRESP  <= "00";  -- OKAY
            if S_AXI_BREADY = '1' then
              S_AXI_BVALID <= '0';
              wr_state <= IDLE;
            end if;

          when others =>
            wr_state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  -- ------------------------------------------------------------------
  -- Read logic
  -- ------------------------------------------------------------------
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        ar_ready <= '0';
        r_valid  <= '0';
        rd_data  <= (others => '0');
        S_AXI_RRESP <= "00";
      else
        ar_ready <= '0';
        r_valid  <= '0';

        if S_AXI_ARVALID = '1' then
          -- Decode read address
          case S_AXI_ARADDR(3 downto 0) is
            when x"0" => rd_data <= ctrl_reg;
            when x"4" => rd_data <= period_reg;
            when x"8" => rd_data <= duty_reg;
            when x"C" => rd_data(0) <= running;
                         rd_data(31 downto 1) <= (others => '0');
            when others => rd_data <= (others => '0');
          end case;
          ar_ready <= '1';
          r_valid  <= '1';
          S_AXI_RRESP <= "00";
        elsif S_AXI_RREADY = '1' and r_valid = '1' then
          r_valid <= '0';   -- clear when read accepted
        end if;
      end if;
    end if;
  end process;

  -- Output assignments
  S_AXI_ARREADY <= ar_ready;
  S_AXI_RVALID  <= r_valid;
  S_AXI_RDATA   <= rd_data;

end Behavioral;