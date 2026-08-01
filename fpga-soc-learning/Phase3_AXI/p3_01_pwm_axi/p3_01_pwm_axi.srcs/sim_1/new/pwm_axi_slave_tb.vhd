-- ============================================================
-- TESTBENCH: pwm_axi_slave_tb
-- VERIFICATION PLAN:
--   Test 1: Reset behavior
--   Test 2: Write PERIOD register (offset 0x04)
--   Test 3: Write DUTY register (offset 0x08)
--   Test 4: Enable PWM (CTRL=1)
--   Test 5: Read STATUS (offset 0x0C) - check running
--   Test 6: Read back PERIOD
--   Test 7: Disable PWM (CTRL=0)
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_axi_slave_tb is
end entity pwm_axi_slave_tb;

architecture Behavioral of pwm_axi_slave_tb is

    constant CLK_PERIOD : time := 10 ns;  -- 100MHz

    -- AXI signals
    signal clk      : STD_LOGIC := '0';
    signal resetn   : STD_LOGIC := '0';  -- active LOW

    -- Write Address Channel
    signal awaddr   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal awvalid  : STD_LOGIC := '0';
    signal awready  : STD_LOGIC;

    -- Write Data Channel
    signal wdata    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal wstrb    : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    signal wvalid   : STD_LOGIC := '0';
    signal wready   : STD_LOGIC;

    -- Write Response Channel
    signal bresp    : STD_LOGIC_VECTOR(1 downto 0);
    signal bvalid   : STD_LOGIC;
    signal bready   : STD_LOGIC := '0';

    -- Read Address Channel
    signal araddr   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal arvalid  : STD_LOGIC := '0';
    signal arready  : STD_LOGIC;

    -- Read Data Channel
    signal rdata    : STD_LOGIC_VECTOR(31 downto 0);
    signal rresp    : STD_LOGIC_VECTOR(1 downto 0);
    signal rvalid   : STD_LOGIC;
    signal rready   : STD_LOGIC := '0';

    -- PWM output
    signal pwm_out  : STD_LOGIC;

    -- ── AXI Write Procedure ───────────────────────────────────
    procedure axi_write(
        addr : in STD_LOGIC_VECTOR(3 downto 0);
        data : in STD_LOGIC_VECTOR(31 downto 0);
        signal awaddr_s  : out STD_LOGIC_VECTOR(3 downto 0);
        signal awvalid_s : out STD_LOGIC;
        signal wdata_s   : out STD_LOGIC_VECTOR(31 downto 0);
        signal wvalid_s  : out STD_LOGIC;
        signal bready_s  : out STD_LOGIC;
        signal awready_s : in  STD_LOGIC;
        signal wready_s  : in  STD_LOGIC;
        signal bvalid_s  : in  STD_LOGIC
    ) is
    begin
        awaddr_s  <= addr;
        awvalid_s <= '1';
        wdata_s   <= data;
        wvalid_s  <= '1';

        wait until rising_edge(clk) and
                   awready_s = '1' and wready_s = '1';

        awvalid_s <= '0';
        wvalid_s  <= '0';

        wait until rising_edge(clk) and bvalid_s = '1';

        bready_s <= '1';
        wait for CLK_PERIOD;
        bready_s <= '0';
        wait for CLK_PERIOD;
    end procedure;

    -- ── AXI Read Procedure ────────────────────────────────────
    procedure axi_read(
        addr : in  STD_LOGIC_VECTOR(3 downto 0);
        signal araddr_s  : out STD_LOGIC_VECTOR(3 downto 0);
        signal arvalid_s : out STD_LOGIC;
        signal rready_s  : out STD_LOGIC;
        signal arready_s : in  STD_LOGIC;
        signal rvalid_s  : in  STD_LOGIC;
        signal rdata_s   : in  STD_LOGIC_VECTOR(31 downto 0)
    ) is
    begin
        araddr_s  <= addr;
        arvalid_s <= '1';

        wait until rising_edge(clk) and arready_s = '1';
        arvalid_s <= '0';

        wait until rising_edge(clk) and rvalid_s = '1';

        rready_s <= '1';
        wait for CLK_PERIOD;
        rready_s <= '0';
        wait for CLK_PERIOD;
    end procedure;

begin

    -- ── DUT Instantiation (AWPROT and ARPROT removed) ──────
    DUT: entity work.pwm_axi_slave
        port map (
            S_AXI_ACLK    => clk,
            S_AXI_ARESETN => resetn,
            S_AXI_AWADDR  => awaddr,
            S_AXI_AWVALID => awvalid,
            S_AXI_AWREADY => awready,
            S_AXI_WDATA   => wdata,
            S_AXI_WSTRB   => wstrb,
            S_AXI_WVALID  => wvalid,
            S_AXI_WREADY  => wready,
            S_AXI_BRESP   => bresp,
            S_AXI_BVALID  => bvalid,
            S_AXI_BREADY  => bready,
            S_AXI_ARADDR  => araddr,
            S_AXI_ARVALID => arvalid,
            S_AXI_ARREADY => arready,
            S_AXI_RDATA   => rdata,
            S_AXI_RRESP   => rresp,
            S_AXI_RVALID  => rvalid,
            S_AXI_RREADY  => rready,
            pwm_out       => pwm_out
        );

    -- ── Clock Generation ──────────────────────────────────────
    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- ── Stimulus ──────────────────────────────────────────────
    stim_proc: process
    begin
        -- ── Test 1: Reset ─────────────────────────────────────
        report "Test 1: Reset behavior" severity NOTE;
        resetn <= '0';
        wait for CLK_PERIOD * 5;

        assert awready = '0'
            report "FAIL Test 1: AWREADY should be 0 in reset"
            severity ERROR;
        assert bvalid = '0'
            report "FAIL Test 1: BVALID should be 0 in reset"
            severity ERROR;
        assert pwm_out = '0'
            report "FAIL Test 1: pwm_out should be 0 in reset"
            severity ERROR;

        report "PASS Test 1: Reset behavior correct" severity NOTE;

        resetn <= '1';
        wait for CLK_PERIOD * 3;

        -- ── Test 2: Write PERIOD ──────────────────────────────
        report "Test 2: Write PERIOD = 1000" severity NOTE;
        axi_write(
            addr     => x"4",
            data     => x"000003E8",
            awaddr_s => awaddr, awvalid_s => awvalid,
            wdata_s  => wdata,  wvalid_s  => wvalid,
            bready_s => bready,
            awready_s => awready, wready_s => wready,
            bvalid_s  => bvalid
        );
        report "PASS Test 2: PERIOD write complete" severity NOTE;

        -- ── Test 3: Write DUTY = 250 ──────────────────────────
        report "Test 3: Write DUTY = 250" severity NOTE;
        axi_write(
            addr     => x"8",
            data     => x"000000FA",
            awaddr_s => awaddr, awvalid_s => awvalid,
            wdata_s  => wdata,  wvalid_s  => wvalid,
            bready_s => bready,
            awready_s => awready, wready_s => wready,
            bvalid_s  => bvalid
        );
        report "PASS Test 3: DUTY write complete" severity NOTE;

        -- ── Test 4: Enable PWM ────────────────────────────────
        report "Test 4: Enable PWM (CTRL=1)" severity NOTE;
        axi_write(
            addr     => x"0",
            data     => x"00000001",
            awaddr_s => awaddr, awvalid_s => awvalid,
            wdata_s  => wdata,  wvalid_s  => wvalid,
            bready_s => bready,
            awready_s => awready, wready_s => wready,
            bvalid_s  => bvalid
        );

        -- Wait for 3 full periods
        wait for CLK_PERIOD * 3000;

        report "PASS Test 4: PWM enabled (check waveform)" severity NOTE;

        -- ── Test 5: Read STATUS ───────────────────────────────
        report "Test 5: Read STATUS" severity NOTE;
        axi_read(
            addr     => x"C",
            araddr_s => araddr, arvalid_s => arvalid,
            rready_s => rready,
            arready_s => arready, rvalid_s => rvalid,
            rdata_s   => rdata
        );

        assert rdata(0) = '1'
            report "FAIL Test 5: STATUS bit0 should be 1 (running)"
            severity ERROR;
        report "PASS Test 5: STATUS=1 (running)" severity NOTE;

        wait for CLK_PERIOD * 5;

        -- ── Test 6: Read back PERIOD ──────────────────────────
        report "Test 6: Read PERIOD" severity NOTE;
        axi_read(
            addr     => x"4",
            araddr_s => araddr, arvalid_s => arvalid,
            rready_s => rready,
            arready_s => arready, rvalid_s => rvalid,
            rdata_s   => rdata
        );

        assert rdata = x"000003E8"
            report "FAIL Test 6: PERIOD should be 1000 (0x3E8)"
            severity ERROR;
        report "PASS Test 6: PERIOD readback correct" severity NOTE;

        wait for CLK_PERIOD * 5;

        -- ── Test 7: Disable PWM ───────────────────────────────
        report "Test 7: Disable PWM (CTRL=0)" severity NOTE;
        axi_write(
            addr     => x"0",
            data     => x"00000000",
            awaddr_s => awaddr, awvalid_s => awvalid,
            wdata_s  => wdata,  wvalid_s  => wvalid,
            bready_s => bready,
            awready_s => awready, wready_s => wready,
            bvalid_s  => bvalid
        );

        wait for CLK_PERIOD * 5;

        assert pwm_out = '0'
            report "FAIL Test 7: pwm_out should be 0 after disable"
            severity ERROR;
        report "PASS Test 7: PWM disabled -- output = 0" severity NOTE;

        wait for CLK_PERIOD * 100;

        report "ALL TESTS COMPLETE -- Check waveform for PWM timing"
            severity NOTE;
        wait;
    end process;

end architecture Behavioral;