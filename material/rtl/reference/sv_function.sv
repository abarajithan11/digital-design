// A SystemVerilog function is just combinational logic. Here it evaluates the
// smoothstep s-curve  y = 3u^2 - 2u^3  in fixed point, where the W-bit input and
// output represent u = in/2^W and y in [0,1). Rearranged to integers:
//   out = floor( (3*x^2*2^W - 2*x^3) / 2^(2W) )
module sv_function #(
  parameter W = 8,
  parameter F = W          // fractional bits: value = x / 2^F
)(
  input  logic [W-1:0] in,
  output logic [W-1:0] out
);
  localparam WA = 3*W + F + 2;   // wide enough to hold 3*x^2*2^F

  function automatic logic [W-1:0] scurve (input logic [W-1:0] x);
    logic [WA-1:0] u;
    u = WA'(x);
    // 2^F * (3u^2 - 2u^3) with u = x/2^F, kept in integers (tool optimizes)
    scurve = W'((3*u*u*(2**F) - 2*u*u*u) >> (2*F));
  endfunction

  always_comb out = scurve(in);
endmodule
