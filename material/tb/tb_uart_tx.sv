`timescale 1ns/1ps

module tb_uart_tx;

  localparam 
    CLKS_PER_BIT   = 4, // 200_000_000/9600
    W_OUT          = 16,
    BITS_PER_WORD  = 8,
    PACKET_SIZE    = BITS_PER_WORD + 5,
    NUM_WORDS      = W_OUT / BITS_PER_WORD,
    DATA_WIDTH     = NUM_WORDS * BITS_PER_WORD;

  typedef logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] data_t;
  data_t s_data, rx_data;

  logic clk = 0, rstn = 0, tx, s_valid = 0, s_ready;
  initial forever #1 clk = !clk;

  uart_tx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .PACKET_SIZE   (PACKET_SIZE),
    .W_OUT         (W_OUT)
  ) dut (.*);

  vip_uart_tx #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (BITS_PER_WORD),
    .W_OUT          (W_OUT),
    .PACKET_SIZE_TX (PACKET_SIZE)
  ) vip_tx (
    .clk  (clk),
    .rstn (rstn),
    .tx   (tx)
  );

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    repeat (2) @(posedge clk) #1ps;
    rstn = 1;
    repeat (5) @(posedge clk) #1ps;

    repeat (10) begin
      repeat ($urandom_range(1,20)) @(posedge clk);
      wait (s_ready);

      @(posedge clk) #1ps;
      s_data  = DATA_WIDTH'($urandom());
      s_valid = 1'b1;

      vip_tx.recv_packet(rx_data);

      @(posedge clk) #1ps;
      s_valid = 1'b0;

      wait (s_ready);
      wait fork;

      if (rx_data == s_data) $display("OK, %b", rx_data);
      else $error("Sent %b, got %b", s_data, rx_data);
    end
    $finish();
  end

endmodule