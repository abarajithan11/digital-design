`timescale 1ns/1ps

module fir_filter #(
  parameter RETIMED = 1, N = 5, W_X = 8, W_K = 3,
  parameter logic [(N+1)*W_K-1:0] K = {
    8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6
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
  logic [N-1:0][W_Y-1:0] z;

  always_comb begin    
    for (int i=0; i<N+1; i=i+1)
      m[i] = $signed(x) * $signed(k_arr[N-i]);

    a[0] = W_Y'($signed(m[0]));
    for (int i=1; i<N+1; i=i+1)
      a[i] =  W_Y'($signed(m[i]) + $signed(z[i-1]));
    
    y = a[N];
  end

  for (n=0; n<N; n=n+1) begin
    always_ff @(posedge clk or negedge rstn) begin    
      if (!rstn)   z[n] <= '0;
      else if (en) z[n] <= a[n];
    end
  end

endmodule