`timescale 1ns/1ps

module tb_uart_tx;

  localparam 
    CLKS_PER_BIT   = 4, // 200_000_000/9600
    N_WORDS        = 2,
    BITS_PER_WORD  = 8,
    W_PACKET       = BITS_PER_WORD + 5,
    DATA_WIDTH     = N_WORDS * BITS_PER_WORD;

  typedef logic [N_WORDS-1:0][BITS_PER_WORD-1:0] data_t;
  data_t s_data, rx_data;

  logic clk = 0, rstn = 0, tx, s_valid = 0, s_ready;
  initial forever #1 clk = !clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  uart_tx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .N_WORDS       (N_WORDS),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_PACKET      (W_PACKET)
  ) dut (.*);

  vip_uart_tx #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .N_WORDS        (N_WORDS),
    .BITS_PER_WORD  (BITS_PER_WORD),
    .PACKET_SIZE_TX (W_PACKET)
  ) vip_tx (
    .clk  (clk),
    .rstn (rstn),
    .tx   (tx)
  );

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk(2);
    rstn = 1;
    posedge_clk(5);

    repeat (10) begin
      posedge_clk($urandom_range(1,20));
      wait (s_ready);

      posedge_clk;
      s_data  = DATA_WIDTH'($urandom());
      s_valid = 1'b1;

      vip_tx.recv_packet(rx_data);

      posedge_clk;
      s_valid = 1'b0;

      wait (s_ready);
      wait fork;

      if (rx_data == s_data) $display("OK, %b", rx_data);
      else $error("Sent %b, got %b", s_data, rx_data);
    end
    $finish();
  end

endmodule
