// uart_echo - receive a word and send it straight back.
//
// A skid_buffer sits between rx and tx so the transmitter can backpressure the
// receiver (uart_tx.s_ready): a word arriving while tx is still shifting out the
// previous one waits in the buffer instead of being dropped.
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
  wire             rx_valid, fifo_valid, fifo_ready, tx_ready;
  wire [W_OUT-1:0] rx_data, fifo_data;

  uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_OUT         (W_OUT)
  ) u_rx (
    .clk    (clk),
    .rstn   (rstn),
    .rx     (rx),
    .m_valid(rx_valid),
    .m_data (rx_data)
  );

  skid_buffer #(
    .WIDTH(W_OUT)
  ) u_fifo (
    .clk    (clk),
    .rstn   (rstn),
    .s_valid(rx_valid),
    .s_ready(fifo_ready),
    .s_data (rx_data),
    .m_valid(fifo_valid),
    .m_ready(tx_ready),
    .m_data (fifo_data)
  );

  uart_tx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .PACKET_SIZE   (PACKET_SIZE_TX),
    .W_OUT         (W_OUT)
  ) u_tx (
    .clk    (clk),
    .rstn   (rstn),
    .s_valid(fifo_valid),
    .s_data (fifo_data),
    .tx     (tx),
    .s_ready(tx_ready)
  );

endmodule
