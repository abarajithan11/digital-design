`timescale 1ns/1ps

module fir_filter #(
  parameter N = 5, W_X = 8, W_K = 3,
  parameter logic [(N+1)*W_K-1:0] K = {
    8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6
    },//'{default:0},
  
  localparam W_Y = W_X + W_K + $clog2(N)
  )(
    input  clk, rstn,
    input  logic [W_X-1:0] x,
    output logic [W_Y-1:0] y
  );
  logic [N:0][W_X-1:0] z;
  logic [N:0][W_K-1:0] k_arr;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) z[N:1] <= '0;
    else       z[N:1] <= z[N-1:0];
  end
  
  always_comb begin
    k_arr = K;
    z[0] = x;

    y = 0;
    for (int n=0; n < N+1; n=n+1)
      y = $signed(y) + $signed(k_arr[n]) * $signed(z[n]);
  end
endmodule