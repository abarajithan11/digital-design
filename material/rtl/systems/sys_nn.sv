import nn_weights_pkg::*;

module sys_nn #(
  parameter int CLKS_PER_BIT = 4,
  parameter int PACKET_GAP_CLKS = CLKS_PER_BIT * 20_000
  )(
  input  logic clk, rstn, rx,
  output logic tx
  );

  localparam int W_INPUT  = N_IN * W_X;
  localparam int W_OUTPUT = N_OUT * W_X;
  localparam int W_UART_INPUT = ((W_INPUT + 7) / 8) * 8;

  logic rx_valid, rx_ready;
  logic nn_valid, nn_ready, out_valid, tx_ready;
  logic [W_UART_INPUT-1:0] rx_bits, nn_bits;
  logic signed [N_OUT-1:0][W_X-1:0] scores;

  uart_rx #(
    .CLKS_PER_BIT (CLKS_PER_BIT),
    .W_OUT        (W_UART_INPUT),
    .PACKET_GAP_CLKS (PACKET_GAP_CLKS)
  ) rx_inst (
    .clk, .rstn, .rx,
    .m_valid (rx_valid),
    .m_data  (rx_bits)
  );

  skid_buffer #(
    .WIDTH (W_UART_INPUT)
  ) input_buffer (
    .clk, .rstn,
    .s_valid (rx_valid),
    .s_ready (rx_ready),
    .s_data  (rx_bits),
    .m_valid (nn_valid),
    .m_ready (nn_ready),
    .m_data  (nn_bits)
  );

  nn network (
    .clk, .rstn,
    .s_valid (nn_valid),
    .s_ready (nn_ready),
    .s_data  (nn_bits[W_INPUT-1:0]),
    .m_valid (out_valid),
    .m_ready (tx_ready),
    .m_data  (scores)
  );

  uart_tx #(
    .CLKS_PER_BIT (CLKS_PER_BIT),
    .W_OUT       (W_OUTPUT)
  ) tx_inst (
    .clk, .rstn,
    .s_valid (out_valid),
    .s_data  (scores),
    .tx,
    .s_ready (tx_ready)
  );
endmodule