`timescale 1ns/1ps

// Round a signed value after a right shift (divide by 2**SHIFT).
//   mode 0: truncate       (floor, toward -inf)
//   mode 1: nearest        (ties away from -inf, "round half up")
//   mode 2: nearest-even   (ties to the even result, "banker's rounding")
module rounding #(
  parameter W     = 8,
  parameter SHIFT = 2
)(
  input  logic [W-1:0] a,
  input  logic [1:0]   mode,
  output logic [W-1:0] f
);
  localparam [SHIFT-1:0] HALF = 1 << (SHIFT-1);

  logic [W-1:0]     trunc;
  logic [SHIFT-1:0] drop;   // bits shifted out (the remainder)
  logic             inc;

  always_comb begin
    trunc = $signed(a) >>> SHIFT;
    drop  = a[SHIFT-1:0];

    unique case (mode)
      2'd0:    inc = 1'b0;
      2'd1:    inc = (drop >= HALF);
      2'd2:    inc = (drop > HALF) || (drop == HALF && trunc[0]);
      default: inc = 1'b0;
    endcase

    f = trunc + W'(inc);
  end
endmodule
