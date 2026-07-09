// One W x W multiply, three ways, all to a 2W-bit product:
//   p_unsigned : plain a*b            (operands treated as unsigned)
//   p_signed   : $signed(a)*$signed(b)(tool sign-extends for us)
//   p_manual   : sign-extend both to 2W by hand, multiply, keep low 2W bits
// p_signed and p_manual match; p_unsigned differs whenever a bit MSB is set.
module multiply #(
  parameter W = 8
)(
  input  logic [W-1:0]   a, b,
  output logic [2*W-1:0] p_unsigned,
  output logic [2*W-1:0] p_signed,
  output logic [2*W-1:0] p_manual
);
  logic [2*W-1:0] a_ext, b_ext;

  always_comb begin
    p_unsigned = a * b;

    p_signed   = $signed(a) * $signed(b);

    a_ext      = {{W{a[W-1]}}, a};
    b_ext      = {{W{b[W-1]}}, b};
    p_manual   = $signed(a_ext) * $signed(b_ext);
  end
endmodule
