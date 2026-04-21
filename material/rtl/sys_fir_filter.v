`timescale 1ns/1ps

module sys_fir_filter #(
    parameter
      RETIMED        = 1,
      CLKS_PER_BIT   = 4,
      BITS_PER_WORD  = 8,
      PACKET_SIZE_TX = BITS_PER_WORD+5,
      WIDTH          = 8,
      N              = 5,
      W_K            = 3,
    parameter logic [(N+1)*W_K-1:0] K = {
      8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6
    },
    localparam W_Y = WIDTH + W_K + $clog2(N)
  )(
    input  wire clk, rstn, rx,
    output wire tx
  );

  wire valid;
  wire [WIDTH-1:0] data_rx, data_tx;
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
    .RETIMED (RETIMED),
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

  // Quantization
  assign data_tx = y[W_Y-1 -: WIDTH];

  uart_tx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .PACKET_SIZE   (PACKET_SIZE_TX),
    .W_OUT         (WIDTH)
  ) u_tx (
    .clk    (clk),
    .rstn   (rstn),
    .s_valid(valid),
    .s_data (data_tx),
    .tx     (tx),
    .s_ready()
  );

endmodule