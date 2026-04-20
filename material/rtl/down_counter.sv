`timescale 1ns/1ps

module down_counter #(parameter WIDTH = 8)(
  input  logic clk, rstn, en, clear,
  input  logic [WIDTH-1:0] max_in,
  output logic [WIDTH-1:0] count,
  output logic last, last_clk
);
  logic [WIDTH-1:0] max;
  wire  [WIDTH-1:0] count_next = last ? max : count - 1;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) {count, max, last} <= '0;
    else if (clear) begin
      count  <= max_in;
      max    <= max_in;
      last   <= max_in == 0;
    end
    else if (en) begin
      last   <= count_next == 0;
      count  <= count_next;
    end
  end

  always_comb last_clk = en && last && rstn && !clear;

endmodule