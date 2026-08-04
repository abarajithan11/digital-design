`timescale 1ns/1ps

// AXI-Stream sink VIP (subordinate). Drains m_valid/m_data with random m_ready
// backpressure and collects `n` words. Registered ready avoids races.
module vip_axis_sink #(
    parameter WORD_W = 8, PROB_READY = 40
) (
    input  logic              clk,
    input  logic              m_valid,
    input  logic [WORD_W-1:0] m_data,
    output logic              m_ready = 0
);
  logic m_ready_d = 0;
  always_ff @(posedge clk) m_ready <= m_ready_d;

  // Every wait lands 1ps past the edge, so the task writes m_ready_d between
  // edges (never racing the always_ff above) and samples the handshake after
  // the DUT's outputs have settled.
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  task automatic pull(output logic [WORD_W-1:0] q[$], input int n);
    q = {};
    while (q.size() < n) begin
      m_ready_d = 0;                                         // random backpressure
      while ($urandom_range(0, 99) >= PROB_READY) posedge_clk();
      m_ready_d = 1;
      posedge_clk();
      if (m_valid && m_ready) q.push_back(m_data);           // accepted on the next edge
    end
    m_ready_d = 0;
  endtask
endmodule
