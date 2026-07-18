`timescale 1ns/1ps

// End-to-end test of the FPGA board_glue for the CPU: stream a program image in
// over UART, press the "run" button, then read the data RAM back out - all
// through the real uart_rx/uart_tx, exactly as py/fpga_program_cpu.py does on
// hardware.  Runs the classic sum(1..10) program and checks dmem[4] == 55.
//
// The UART is 16 bits wide, so each send/recv is one whole word (uart_rx/uart_tx
// pack the two bytes).  The image is all imem words followed by all dmem words.
module tb_cpu_fpga;

  localparam int ADDR_W       = 6;
  localparam int MEM_ROWS     = 1 << ADDR_W;
  localparam int CLKS_PER_BIT = 4;            // fast in sim; 54 on hardware
  localparam int PACKET_TX    = 10;
  localparam int WATCH_ADDR   = 4;

  // Opcodes (must match cpu.sv's enum order).
  localparam logic [3:0] LOAD=0, STORE=1, MOVE=2, ADD=3, SUB=4, MUL=5, JNZ=6;

  logic clk = 0, rst = 1;
  logic [1:0] btn = 2'b00;
  logic [5:0] led, gpio_o, gpio_oe;
  logic [5:0] gpio_i = '0;
  logic rx, tx;

  initial forever #1 clk = ~clk;

  board_glue #(
    .ADDR_W      (ADDR_W),
    .CLKS_PER_BIT(CLKS_PER_BIT),
    .PACKET_SIZE (PACKET_TX),
    .CPU_HALF    (2),                          // ~4 fast clks per CPU step in sim
    .WATCH_ADDR  (WATCH_ADDR),
    .RUN_CYCLES  (MEM_ROWS)
  ) dut (
    .clk(clk), .rst(rst), .btn(btn), .led(led),
    .rx(rx), .tx(tx), .gpio_o(gpio_o), .gpio_oe(gpio_oe), .gpio_i(gpio_i)
  );

  // 16-bit-wide UART VIPs: one packet == one word.
  vip_uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT), .BITS_PER_WORD(8), .W_OUT(16))
    vip_rx (.clk(clk), .rx(rx));
  vip_uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT), .BITS_PER_WORD(8), .W_OUT(16),
                .PACKET_SIZE_TX(PACKET_TX))
    vip_tx (.clk(clk), .rstn(~rst), .tx(tx));

  logic [15:0] imem [MEM_ROWS];
  logic [15:0] dmem [MEM_ROWS];
  logic [15:0] result [MEM_ROWS];

  initial begin
    for (int i = 0; i < MEM_ROWS; i++) begin imem[i] = '0; dmem[i] = '0; end

    // sum(1..10): dmem[WATCH_ADDR=4] should end up 55 (so the LEDs can show it).
    dmem[0] = 16'd0;
    dmem[1] = 16'd1;
    dmem[2] = 16'd10;
    imem[0] = {8'h02,        4'h2, LOAD};   // r2 (counter) = N = 10
    imem[1] = {8'h01,        4'h1, LOAD};   // r1 (one)     = 1
    imem[2] = {8'h00,        4'h0, LOAD};   // r0 (sum)     = 0
    imem[3] = {4'h2,  4'h0,  4'h0, ADD};    // r0 += r2
    imem[4] = {4'h1,  4'h2,  4'h2, SUB};    // r2 -= r1
    imem[5] = {8'h03,        4'h2, JNZ};    // loop while r2 != 0
    imem[6] = {8'h04,        4'h0, STORE};  // dmem[4] = r0

    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_fpga);

    repeat (10) @(posedge clk);
    rst = 0;

    // ---- LOAD: all imem words, then all dmem words (no echo) -----------------
    for (int r = 0; r < MEM_ROWS; r++) vip_rx.send_packet(imem[r]);
    for (int r = 0; r < MEM_ROWS; r++) vip_rx.send_packet(dmem[r]);

    // ---- Press S1 to run ----------------------------------------------------
    repeat (20) @(posedge clk);
    btn[0] = 1'b1;
    repeat (40) @(posedge clk);
    btn[0] = 1'b0;

    // ---- DUMP: read dmem back, one word per row -----------------------------
    for (int r = 0; r < MEM_ROWS; r++) vip_tx.recv_packet(result[r]);

    $display("dmem[0..4] = %0d %0d %0d %0d %0d",
             result[0], result[1], result[2], result[3], result[4]);
    assert (result[4] == 16'd55)
      $display("PASS: CPU-on-FPGA sum(1..10) = %0d", result[4]);
      else $fatal(1, "FAIL: dmem[4] = %0d (expected 55)", result[4]);
    $finish;
  end

  initial begin
    #(`SIM_MAX_TIME);
    $fatal(1, "Timeout at %0t", $time);
  end
endmodule
