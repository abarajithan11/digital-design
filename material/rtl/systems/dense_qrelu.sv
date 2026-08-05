module dense_qrelu #(
  parameter int N_IN         = 2,
  parameter int N_OUT        = 2,
  parameter int W_X          = 4,
  parameter int W_K          = 4,
  parameter int W_B          = 8,
  parameter int W_ACC        = 20,
  parameter int REG_INTERVAL = 1,
  parameter int SHIFT        = 4,
  parameter bit RELU         = 1'b1,
  parameter logic signed [N_OUT*N_IN*W_K-1:0] K = 16'h2d97,
  parameter logic signed      [N_OUT*W_B-1:0] B = 16'h03fb
  )(
  input  logic clk, rstn, cen,
  input  logic signed [N_IN-1:0][W_X-1:0] x,
  output logic signed [N_OUT-1:0][W_X-1:0] y
  );

  localparam int W_PRODUCT = W_X + W_K;
  localparam int W_SUM     = W_PRODUCT + $clog2(N_IN);

  logic signed [N_OUT-1:0][N_IN-1:0][W_PRODUCT-1:0] terms;
  logic signed [N_OUT-1:0][N_IN-1:0][W_K      -1:0] weights;
  logic signed [N_OUT-1:0]          [W_B      -1:0] biases;
  logic signed [N_OUT-1:0]          [W_SUM    -1:0] sum;
  logic signed [N_OUT-1:0]          [W_ACC    -1:0] acc;

  always_comb begin
    weights = K;
    biases  = B;
    for (int o = 0; o < N_OUT; o++) begin
      logic signed [W_ACC-1:0] acc_sum, acc_bias;

      for (int i = 0; i < N_IN; i++)
        terms[o][i] = $signed(weights[o][i]) * $signed(x[i]);
      acc_sum  = W_ACC'($signed(sum[o]));
      acc_bias = W_ACC'($signed(biases[o]));
      acc[o] = acc_sum + acc_bias;
    end
  end

  for (genvar o = 0; o < N_OUT; o++) begin : gen_output
    reduction_tree_add #(
      .N            (N_IN),
      .W_X          (W_PRODUCT),
      .W_Y          (W_SUM),
      .REG_INTERVAL (REG_INTERVAL)
    ) add_tree (
      .clk, .rstn, .cen,
      .x (terms[o]),
      .y (sum[o])
    );

    quant_relu #(
      .W_ACC(W_ACC),
      .W_Y  (W_X),
      .SHIFT(SHIFT),
      .RELU (RELU)
    ) quant (
      .acc (acc[o]),
      .y   (y[o])
    );
  end
endmodule
