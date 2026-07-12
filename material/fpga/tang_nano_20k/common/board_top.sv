`timescale 1ns / 1ps

// ============================================================================
//  board_top - FIXED board wrapper (CSE140). Students never edit this.
//
//  Hands board_glue a clean, ACTIVE-HIGH world:
//     clk         system clock (27 MHz crystal, or 108 MHz via PLL - see SYS_HZ)
//     rst         1 = reset asserted (power-on, or PLL not locked)
//     btn[1:0]    1 = pressed (synced + debounced; btn[0]=S1, btn[1]=S2)
//     led[5:0]    drive 1 to light an LED (LEDs are active-low in hardware)
//     rx / tx     serial (rx is synchronized to clk)
//     gpio_*      per-pin output value / output-enable / input
//
//  Clocking: SYS_HZ = 27 MHz uses the crystal directly; anything else runs
//  everything on a 108 MHz PLL (108 = 27 x 4, which divides cleanly to 2 Mbaud).
//  The UART designs need the PLL; fpga.mk sets SYS_HZ for them.
//
//  Port names/widths below MUST match board.cst exactly.
// ============================================================================
module board_top #(
    parameter int unsigned SYS_HZ = 27_000_000
) (
    input  logic       clk,      // 27 MHz (pin 4)
    input  logic [1:0] btn_n,    // active-low buttons: [0]=S1, [1]=S2
    output logic [5:0] led_n,    // active-low LEDs
    input  logic       uart_rx,  // bridge -> FPGA
    output logic       uart_tx,  // FPGA  -> bridge
    inout  logic [5:0] gpio      // bidirectional header IO (see board.cst)
);

  // ---- System clock: 27 MHz crystal, or 108 MHz PLL ----------------------
  logic clk_sys, locked;
  if (SYS_HZ == 27_000_000) begin : g_direct
    always_comb begin
      clk_sys = clk;
      locked  = 1'b1;
    end
  end else begin : g_pll
    // Gowin rPLL primitive: f_out = 27 MHz * (FBDIV_SEL+1)/(IDIV_SEL+1) = 108 MHz.
    rPLL #(
        .DEVICE   ("GW2A-18C"),
        .FCLKIN   ("27"),
        .IDIV_SEL (0),
        .FBDIV_SEL(3),
        .ODIV_SEL (8)
    ) i_pll (
        .CLKIN  (clk),
        .CLKOUT (clk_sys),
        .LOCK   (locked),
        .CLKFB  (1'b0),
        .RESET  (1'b0),
        .RESET_P(1'b0),
        .FBDSEL (6'b0), .IDSEL (6'b0), .ODSEL (6'b0),
        .PSDA   (4'b0), .DUTYDA(4'b0), .FDLY (4'b0),
        .CLKOUTP(),     .CLKOUTD(),    .CLKOUTD3()
    );
  end

  // ---- Buttons: 2-FF sync + debounce -> active-high `button` --------------
  // A reading is accepted only after it holds steady ~2^16 clocks, so a press
  // registers as a single clean edge.
  logic [1:0]  button_sync_0, button_sync_1, button;
  logic [15:0] debounce_count[2];
  always_ff @(posedge clk_sys) begin
    button_sync_0 <= ~btn_n;   // active-low pin -> active-high
    button_sync_1 <= button_sync_0;
  end
  for (genvar i = 0; i < 2; i++) begin : g_debounce
    always_ff @(posedge clk_sys) begin
      if (button_sync_1[i] == button[i]) begin
        debounce_count[i] <= '0;
      end else begin
        debounce_count[i] <= debounce_count[i] + 16'd1;
        if (&debounce_count[i]) button[i] <= button_sync_1[i];
      end
    end
  end

  // ---- Reset: power-on hold + wait-for-PLL-lock ---------------------------
  // S2 is intentionally NOT a reset: on some board revisions that pin is held
  // low, which would keep every design in reset.
  logic [15:0] power_on_count = '0;
  logic        power_on_done, rst;
  always_ff @(posedge clk_sys)
    if (!power_on_done) power_on_count <= power_on_count + 16'd1;
  always_comb begin
    power_on_done = &power_on_count;
    rst           = !power_on_done | !locked;
  end

  // ---- Synchronize the async UART input to clk_sys ------------------------
  logic rx_sync_0, rx_sync_1;
  always_ff @(posedge clk_sys) begin
    if (rst) {rx_sync_1, rx_sync_0} <= 2'b11;
    else     {rx_sync_1, rx_sync_0} <= {rx_sync_0, uart_rx};
  end

  // ---- GPIO tristate (assign is required for an inout) --------------------
  logic [5:0] gpio_o, gpio_oe, gpio_i;
  for (genvar i = 0; i < 6; i++) begin : g_gpio
    assign gpio[i] = gpio_oe[i] ? gpio_o[i] : 1'bz;
  end
  always_comb gpio_i = gpio;

  // ---- The one per-design file --------------------------------------------
  logic [5:0] led;
  logic       tx;
  board_glue u_glue (
      .clk    (clk_sys),
      .rst    (rst),
      .btn    (button),
      .led    (led),
      .rx     (rx_sync_1),
      .tx     (tx),
      .gpio_o (gpio_o),
      .gpio_oe(gpio_oe),
      .gpio_i (gpio_i)
  );

  // ---- Clean active-high world -> hardware pins ---------------------------
  always_comb begin
    led_n   = ~led;
    uart_tx = tx;
  end

endmodule
