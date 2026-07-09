module shifter #(
  parameter W           = 8,
  parameter SHIFT_CONST = 2
)(
  input  logic [W-1:0]         a,
  input  logic [2:0]           sel,
  input  logic [$clog2(W)-1:0] shift_var,
  output logic [W-1:0]         f
);
  localparam C = SHIFT_CONST;

  always_comb begin
    unique case (sel)
      3'd0:    f = $signed(a) <<< C;          // arithmetic left  (= logical)
      3'd1:    f = $signed(a) >>> C;          // arithmetic right (sign-extend)
      3'd2:    f = a << C;                    // logical left
      3'd3:    f = a >> C;                    // logical right
      3'd4:    f = (a << C) | (a >> (W - C)); // rotate left
      3'd5:    f = (a >> C) | (a << (W - C)); // rotate right
      3'd6:    f = $signed(a) <<< shift_var;  // arithmetic left by variable
      default: f = a;
    endcase
  end
endmodule
