`timescale 1ns/1ps
// sub=1 : invert B and inject carry-in 1  ->  A + (~B) + 1 = A - B
module n_add_sub #(
  parameter N = 8
)(
  input  logic [N-1:0] A, B,
  input  logic         sub,
  output logic [N-1:0] S,
  output logic         co
);
  logic [N:0]   C;
  logic [N-1:0] Y;

  always_comb C[0] = sub;

  genvar i;
  for (i = 0; i < N; i = i + 1) begin : add
    always_comb Y[i] = B[i] ^ sub;
    full_adder fa (
      .a   (A[i  ]),
      .b   (Y[i]),
      .ci  (C[i  ]),
      .co  (C[i+1]),
      .sum (S[i  ])
    );
  end

  always_comb co = C[N];
endmodule
