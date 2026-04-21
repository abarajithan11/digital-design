`timescale 1ns/1ps

module tb_sys_fir_filter;

  timeunit 1ns/1ps;
  localparam  CLKS_PER_BIT     = 4,
              BITS_PER_WORD    = 8,
              WIDTH            = 8,
              W_K              = 4,
              N                = 3,
              W_Y              = WIDTH + W_K + $clog2(N),
              PACKET_SIZE_TX   = BITS_PER_WORD+5,
              N_WORDS          = WIDTH/BITS_PER_WORD,
              NUM_EXP          = 10;

  typedef logic [N_WORDS-1:0][BITS_PER_WORD-1:0] data_t;
  localparam logic [N:0][W_K-1:0] K = {4'd1, 4'd2, 4'd3, 4'd4};

  logic clk = 0, rstn = 0, rx, tx;
  data_t s_data, m_data;
  logic [W_Y-1:0] y_exp = 0;
  logic [WIDTH-1:0] m_exp = 0;

  logic [WIDTH-1:0] zq [$];
  initial repeat(N+1) zq.push_back('0);

  initial forever #1 clk = !clk;

  sys_fir_filter #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (BITS_PER_WORD),
    .PACKET_SIZE_TX (PACKET_SIZE_TX),
    .WIDTH          (WIDTH),
    .N              (N),
    .W_K            (W_K),
    .K              (K)
  ) dut (.*);

  vip_uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_OUT         (WIDTH)
  ) vip_rx (.*);

  vip_uart_tx #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (BITS_PER_WORD),
    .W_OUT          (WIDTH),
    .PACKET_SIZE_TX (PACKET_SIZE_TX)
  ) vip_tx (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;
    assert (WIDTH == BITS_PER_WORD);

    repeat (2) @(posedge clk) #1ps;
    rstn = 1;

    repeat (NUM_EXP) begin
      for (int iw = 0; iw < N_WORDS; iw++)
        s_data[iw] = BITS_PER_WORD'($urandom_range(2**BITS_PER_WORD - 1));

      zq.push_front(s_data[0]);
      zq.pop_back();

      y_exp = 0;
      for (int i = 0; i < N+1; i += 1)
        y_exp = $signed(y_exp) + $signed(zq[i]) * $signed(K[i]);
      m_exp = y_exp[W_Y-1 -: WIDTH];

      fork
        vip_rx.send_packet(s_data);
        vip_tx.recv_packet(m_data);
      join

      assert (m_data == m_exp) $display("Outputs match: %p", m_data);
      else $error("Expected: %p != Output: %p", m_exp, m_data);

      repeat ($urandom_range(1,20)) @(posedge clk);
    end
    $finish();
  end

endmodule