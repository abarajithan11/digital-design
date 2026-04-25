`timescale 1ns/1ps

module fir_filter_naive #(
  parameter N = 5, W_X = 8, W_K = 4,
  parameter logic [(N+1)*W_K-1:0] K = {
    4'sd1, 4'sd2, 4'sd3, 4'sd4, 4'sd5, 4'sd6
    },//'{default:0},
  
  localparam W_Y = W_X + W_K + $clog2(N+1)
  )(
    input  clk, rstn, en,
    input  logic [W_X-1:0] x,
    output logic [W_Y-1:0] y
  );

  logic [N:0][W_K-1:0] k_arr;
  always_comb k_arr = K;

  genvar n;
  localparam W_M = W_X + W_K;
  logic [N  :0][W_M-1:0] m;
  logic [N  :0][W_Y-1:0] a;
  logic [N  :0][W_X-1:0] z;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)   z[N:1] <= '0;
    else if (en) z[N:1] <= z[N-1:0];
  end
  
  always_comb begin
    z[0] = x;

    y = 0;
    for (int n=0; n < N+1; n=n+1)
      y = $signed(y) + $signed(k_arr[n]) * $signed(z[n]);
  end

endmodule
