module not_gate (
  input  logic i,
  output logic o
);
  always_comb o = !i;
endmodule