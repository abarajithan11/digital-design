`timescale 1ns/1ps

module tb_uart_rx;

  localparam 
    CLKS_PER_BIT   = 4, // 200_000_000/9600
    W_OUT          = 16,
    BITS_PER_WORD  = 8,
    NUM_WORDS      = W_OUT / BITS_PER_WORD,
    DATA_WIDTH     = NUM_WORDS * BITS_PER_WORD;

  logic clk = 0, rstn = 0, rx, m_valid;
  typedef logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] data_t;
  data_t m_data, data;

  initial forever #1 clk = !clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .W_OUT         (W_OUT),
    .BITS_PER_WORD (BITS_PER_WORD)
  ) dut (.*);

  vip_uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (BITS_PER_WORD),
    .W_OUT         (W_OUT)
  ) vip_rx (
    .clk (clk),
    .rx  (rx)
  );

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk(2);
    rstn = 1;
    posedge_clk(5);

    repeat (10) begin
      data = DATA_WIDTH'($urandom());
      vip_rx.send_packet(data);
      posedge_clk($urandom_range(1,100));
    end
    $finish();
  end

  initial forever begin
    posedge_clk;
    if (m_valid) begin
      assert (m_data == data) $display("OK, %b", m_data);
      else $error("Sent %b, got %b", data, m_data);
    end
  end

endmodule