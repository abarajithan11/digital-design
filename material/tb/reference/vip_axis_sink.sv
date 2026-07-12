`timescale 1ns/1ps

// AXI-Stream sink VIP (slave). Drains m_valid/m_data with random m_ready
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

  task automatic pull(output logic [WORD_W-1:0] q[$], input int n);
    q = {};
    while (q.size() < n) begin
      m_ready_d = 0;                                         // random backpressure
      while ($urandom_range(0, 99) >= PROB_READY) @(posedge clk);
      m_ready_d = 1;
      @(posedge clk);
      if (m_valid && m_ready) q.push_back(m_data);           // accepted this edge
    end
    m_ready_d = 0;
  endtask
endmodule
