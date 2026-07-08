`timescale 1ns/1ps

// Absolute value: negate when negative. Output is unsigned so |MIN| = 2**(W-1)
// fits (it would overflow a signed W-bit result).
module abs #(
  parameter W = 8
)(
  input  logic [W-1:0] a,
  output logic [W-1:0] y
);
  always_comb
    if ($signed(a) < 0) y = -$signed(a);
    else                y =  a;
endmodule
