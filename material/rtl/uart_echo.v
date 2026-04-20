`timescale 1ns/1ps

module uart_echo #(
    parameter 
      CLKS_PER_BIT   = 4,
      BITS_PER_WORD  = 8,
      PACKET_SIZE_TX = BITS_PER_WORD+5,
      W_OUT          = 24
  )(
    input  wire clk, rstn, rx,
    output wire tx
  );
  wire valid;
  wire [W_OUT-1:0] data;

  uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_OUT         (W_OUT)
  ) u_rx (
    .clk    (clk),
    .rstn   (rstn),
    .rx     (rx),
    .m_valid(valid),
    .m_data (data)
  );

  uart_tx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .PACKET_SIZE   (PACKET_SIZE_TX),
    .W_OUT         (W_OUT)
  ) u_tx (
    .clk    (clk),
    .rstn   (rstn),
    .s_valid(valid),
    .s_data (data),
    .tx     (tx),
    .s_ready()
  );

endmodule