`timescale 1ns/1ps

// AXI-Stream source VIP (master). Drives s_valid/s_data with random idle gaps
// and waits for s_ready, so it exercises backpressure. Outputs are registered
// so they never race the DUT's sampling edge. Style: abarajithan11/axis_vip.
module vip_axis_source #(
    parameter WORD_W = 8, PROB_VALID = 70
) (
    input  logic              clk,
    input  logic              s_ready,
    output logic              s_valid = 0,
    output logic [WORD_W-1:0] s_data  = 'x
);
  logic              s_valid_d = 0;
  logic [WORD_W-1:0] s_data_d  = 'x;
  always_ff @(posedge clk) begin
    s_valid <= s_valid_d;
    s_data  <= s_data_d;
  end

  task automatic push(input logic [WORD_W-1:0] q[$]);
    foreach (q[i]) begin
      s_valid_d = 0; s_data_d = 'x;                          // idle gap
      while ($urandom_range(0, 99) >= PROB_VALID) @(posedge clk);
      s_valid_d = 1; s_data_d = q[i];                        // present a word
      @(posedge clk);
      while (!s_ready) @(posedge clk);                       // hold until accepted
    end
    s_valid_d = 0; s_data_d = 'x;
  endtask

  task automatic random_queue(output logic [WORD_W-1:0] q[$], input int n);
    q = {};
    repeat (n) q.push_back(WORD_W'($urandom));
  endtask
endmodule
