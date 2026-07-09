// Binary encoder: one-hot input -> index of the set bit.
module encoder #(
  parameter N = 3
)(
  input  logic [2**N-1:0] onehot,
  output logic [N-1:0]    code
);
  always_comb begin
    code = '0;
    for (int i = 0; i < 2**N; i++)
      if (onehot[i]) code = N'(i);
  end
endmodule
