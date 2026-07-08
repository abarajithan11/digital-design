`timescale 1ns/1ps

module up_counter #(parameter WIDTH = 8)(
  input  logic clk, rstn, incr,
  output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rstn) begin
    if      (!rstn) count <= 0;
    else if (incr)  count <= count + WIDTH'(1'b1);
  end
endmodule