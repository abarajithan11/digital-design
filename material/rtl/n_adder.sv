`timescale 1ns/1ps

module n_adder #(
  parameter N=8
)(
  input  logic signed [N-1:0] A, B,
  input  logic ci,
  output logic signed [N-1:0] S,
  output logic co
);
  logic [N:0] C;
  genvar i; 
  
  for (i=0; i<N; i=i+1) begin:add
    // full_adder fa (A[i],B[i],C[i],C[i+1],S[i]);
    full_adder fa (
      .a    (A[i  ]),
      .b    (B[i  ]),
      .ci   (C[i  ]),
      .co   (C[i+1]),
      .sum  (S[i  ])
    );
  end

  always_comb begin
    C[0] = ci;
    co = C[N];
  end

endmodule