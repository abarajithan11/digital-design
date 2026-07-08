`timescale 1ns/1ps

// Binary decoder: drive the one output selected by `code` (inverse of encoder).
module decoder #(
  parameter N = 3
)(
  input  logic [N-1:0]    code,
  output logic [2**N-1:0] onehot
);
  always_comb begin
    onehot       = '0;
    onehot[code] = 1'b1;
  end
endmodule
