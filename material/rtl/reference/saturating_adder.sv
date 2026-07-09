// Signed adder that clamps to the representable range instead of wrapping.
module saturating_adder #(
  parameter W = 8
)(
  input  logic [W-1:0] a, b,
  output logic [W-1:0] s
);
  localparam [W-1:0] MAX = {1'b0, {(W-1){1'b1}}};   // 0111...1
  localparam [W-1:0] MIN = {1'b1, {(W-1){1'b0}}};   // 1000...0

  logic [W:0] sum_ext;   // one extra bit holds the true sum
  logic overflow, negative;

  always_comb begin
    sum_ext = $signed(a) + $signed(b);

    overflow = (sum_ext[W] != sum_ext[W-1]); // signed overflow: true sign (bit W) differs from the W-bit result's sign
    negative = sum_ext[W];                   // sign of the true (W+1-bit) sum

    if (overflow) s = negative ? MIN : MAX;
    else          s = sum_ext[W-1:0];
  end
endmodule
