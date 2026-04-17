`timescale 1ns/1ps

module adder #(
  parameter WIDTH = 8
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH-1:0] sum,
  output logic carry_out
);
  always_comb {carry_out, sum} = a + b;
endmodule
