module tb_uart_echo;

  timeunit 1ns/1ps;
  localparam CLKS_PER_BIT     = 4,
             BITS_PER_WORD    = 8,
             W_OUT            = 24,
             N_WORDS          = W_OUT/BITS_PER_WORD,
             PACKET_SIZE_TX   = BITS_PER_WORD+5,
             NUM_EXP          = 10;

  typedef logic [N_WORDS-1:0][BITS_PER_WORD-1:0] data_t;
  logic clk = 0, rstn = 0, rx, tx;
  data_t s_data, m_data;

  initial forever #1 clk = !clk;

  uart_echo #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (BITS_PER_WORD),
    .PACKET_SIZE_TX (PACKET_SIZE_TX),
    .W_OUT          (W_OUT)
  ) dut (.*);

  vip_uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_OUT         (W_OUT)
  ) vip_rx (
    .clk (clk),
    .rx  (rx)
  );

  vip_uart_tx #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (BITS_PER_WORD),
    .W_OUT          (W_OUT),
    .PACKET_SIZE_TX (PACKET_SIZE_TX)
  ) vip_tx (
    .clk  (clk),
    .rstn (rstn),
    .tx   (tx)
  );

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;
    assert (W_OUT % BITS_PER_WORD == 0);

    repeat (2) @(posedge clk) #1ps;
    rstn = 1;

    repeat (NUM_EXP) begin
      for (int iw = 0; iw < N_WORDS; iw++)
        s_data[iw] = BITS_PER_WORD'($urandom_range(2**BITS_PER_WORD - 1));

      fork
        vip_rx.send_packet(s_data);
        vip_tx.recv_packet(m_data);
      join

      assert (s_data == m_data) $display("Outputs match: %p", m_data);
      else $error("Expected: %p != Output: %p", s_data, m_data);

      repeat ($urandom_range(1,20)) @(posedge clk);
    end
    $finish();
  end

endmodule