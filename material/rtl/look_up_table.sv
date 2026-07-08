`timescale 1ns/1ps

// Same smoothstep s-curve as sv_function, implemented as LUTs
module look_up_table #(
  parameter W = 4,
  parameter F = W  // fractional bits: value = x / 2^F
)(
  input  logic [W-1:0] in,
  output logic [W-1:0] out
);
  localparam WA = 3*W + F + 2;

  function automatic logic [W-1:0] scurve (input logic [W-1:0] x);
    logic [WA-1:0] u;
    u = WA'(x);
    // 2^F * (3u^2 - 2u^3) with u = x/2^F, kept in integers (tool optimizes)
    scurve = W'((3*u*u*(2**F) - 2*u*u*u) / 2**(2*F));
  endfunction

  logic [2**W-1:0][W-1:0] lut;
  for (genvar i = 0; i < 2**W; i++) begin : fill
    always_comb lut[i] = scurve(W'(i));   // constant-folds to a ROM entry
  end

  always_comb out = lut[in];
endmodule
