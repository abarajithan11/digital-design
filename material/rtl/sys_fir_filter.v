`timescale 1ns/1ps

module sys_fir_filter #(
    parameter
      CLKS_PER_BIT   = 4,
      BITS_PER_WORD  = 8,
      PACKET_SIZE_TX = BITS_PER_WORD+5,
      WIDTH          = 8,
      FRAC           = 7,
      N              = 100,
      W_K            = 4,
    parameter [(N+1)*W_K-1:0] K = {
      `include "data/coef.svh"
    },
    localparam W_Y = WIDTH + W_K + $clog2(N+1)
  )(
    input  wire clk, rstn, rx,
    output wire tx
  );

  wire valid;
  wire [WIDTH-1:0] data_rx;
  wire [W_Y-1:0] y;

  uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_OUT         (WIDTH)
  ) u_rx (
    .clk    (clk),
    .rstn   (rstn),
    .rx     (rx),
    .m_valid(valid),
    .m_data (data_rx)
  );

  fir_filter #(
    .N       (N),
    .W_X     (WIDTH),
    .W_K     (W_K),
    .K       (K)
  ) u_fir (
    .clk  (clk),
    .rstn (rstn),
    .en   (valid),
    .x    (data_rx),
    .y    (y)
  );

  wire [W_Y-1:0] y_shift;
  wire [WIDTH-1:0] y_q;

  localparam [WIDTH-1:0] MAX_Q = {1'b0, {(WIDTH-1){1'b1}}};
  localparam [WIDTH-1:0] MIN_Q = {1'b1, {(WIDTH-1){1'b0}}};

  localparam [W_Y-1:0] MAX_Q_EXT = {{(W_Y-WIDTH){1'b0}}, MAX_Q};
  localparam [W_Y-1:0] MIN_Q_EXT = {{(W_Y-WIDTH){1'b1}}, MIN_Q};

  assign y_shift = $signed(y) >>> FRAC;
  assign y_q =  ($signed(y_shift) > $signed(MAX_Q_EXT)) ? MAX_Q :
                ($signed(y_shift) < $signed(MIN_Q_EXT)) ? MIN_Q : y_shift[WIDTH-1:0];

  uart_tx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .PACKET_SIZE   (PACKET_SIZE_TX),
    .W_OUT         (WIDTH)
  ) u_tx (
    .clk    (clk),
    .rstn   (rstn),
    .s_valid(valid),
    .s_data (y_q),
    .tx     (tx),
    .s_ready()
  );

endmodule
