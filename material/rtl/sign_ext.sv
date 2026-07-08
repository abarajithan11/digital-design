`timescale 1ns/1ps

// Sign-extend W_IN bits to W_OUT bits, two equivalent ways:
//   y_concat : manually replicate the sign bit
//   y_cast   : let $signed()/width-cast do it
module sign_ext #(
  parameter W_IN  = 4,
  parameter W_OUT = 8
)(
  input  logic [W_IN-1:0]  a,
  output logic [W_OUT-1:0] y_concat,
  output logic [W_OUT-1:0] y_cast
);
  always_comb begin
    y_concat = {{(W_OUT-W_IN){a[W_IN-1]}}, a};
    y_cast   = W_OUT'($signed(a));
  end
endmodule
