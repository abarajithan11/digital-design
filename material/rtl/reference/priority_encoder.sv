// Priority encoder: `code` = index of the most-significant set bit of `in`.
// The `found` flag keeps the first (highest) hit and ignores lower ones, making
// the priority explicit (unlike a one-hot encoder, `in` may have several bits set).
module priority_encoder #(
  parameter N = 3
)(
  input  logic [2**N-1:0] in,
  output logic [N-1:0]    code
);
  logic found;
  always_comb begin
    code  = '0;
    found = 1'b0;
    for (int i = 2**N-1; i >= 0; i--)
      if (in[i] && !found) begin
        code  = N'(i);
        found = 1'b1;
      end
  end
endmodule
