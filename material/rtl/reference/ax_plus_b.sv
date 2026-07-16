module ax_plus_b #(
  parameter W=8
)(
  input clk, rstn,
  input  logic [W-1:0] x,
  input  logic [W-1:0] a,
  input  logic [W-1:0] b,
  output logic [W-1:0] y
);

  localparam WS = 2*W+1;
  logic [2*W-1:0] mul;
  logic [WS-1 :0] sum;
  logic [W-1  :0] b_1;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      {mul, y, b_1, sum} <= '0;
    end else begin
      mul <= $signed(a) * $signed(x);
      b_1 <= b;
      sum <= WS'($signed(mul)) + WS'($signed(b_1));
      y   <= W'(sum);
    end
  end
  
endmodule