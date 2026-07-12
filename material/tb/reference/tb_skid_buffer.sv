`timescale 1ns/1ps

module tb_skid_buffer;
  localparam int WIDTH = 8, NUM_WORDS = 500;

  logic clk = 0, rstn = 0;
  initial forever #1ns clk = ~clk;

  logic s_valid, s_ready, m_valid, m_ready;
  logic [WIDTH-1:0] s_data, m_data;

  vip_axis_source #(.WORD_W(WIDTH), .PROB_VALID(70)) src (.*);
  skid_buffer       #(.WIDTH(WIDTH)) dut (.*);
  vip_axis_sink   #(.WORD_W(WIDTH), .PROB_READY(40)) snk (.*);

  logic [WIDTH-1:0] tx[$], rx[$];

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;
    repeat (5) @(posedge clk);
    #1ps rstn = 1;

    src.random_queue(tx, NUM_WORDS);
    fork
      src.push(tx);             // stream in with random valid gaps
      snk.pull(rx, NUM_WORDS);  // drain with random ready backpressure
    join

    if (rx == tx)
      $display("PASS: skid_buffer passed %0d words in order (no loss/dup).", NUM_WORDS);
    else begin
      $display("FAIL: mismatch. sent[0:7]=%p recv[0:7]=%p", tx[0:7], rx[0:7]);
      $fatal(1, "skid_buffer test failed");
    end
    $finish();
  end
endmodule
