module vector_mac #(
  parameter int N            = 8,
  parameter int W_X          = 4,
  parameter int W_K          = 4,
  parameter int W_B          = 8,
  parameter int W_ACC        = W_X + W_K + $clog2(N) + 1,
  parameter int REG_INTERVAL = 1,
  parameter logic signed [N*W_K-1:0] K = 32'h2d97a6e3,
  parameter logic signed   [W_B-1:0] B = 8'h3b
  )(
  input  logic clk, rstn, cen,
  input  logic signed [N-1:0][W_X-1:0] x,
  output logic signed          [W_ACC-1:0] y
  );

  localparam int W_PRODUCT = W_X + W_K;
  localparam int W_SUM     = W_PRODUCT + $clog2(N);

  logic signed [N-1:0][W_PRODUCT-1:0] terms;
  logic signed [N-1:0][W_K-1:0] weights;
  logic signed              [W_SUM-1:0] sum;

  always_comb begin
    logic signed [W_ACC-1:0] acc_sum, acc_bias;

    weights = K;
    for (int i = 0; i < N; i++)
      terms[i] = $signed(weights[i]) * $signed(x[i]);
    acc_sum  = W_ACC'($signed(sum));
    acc_bias = W_ACC'($signed(B));
    y = acc_sum + acc_bias;
  end

  reduction_tree_add #(
    .N(N),
    .W_X(W_PRODUCT),
    .W_Y(W_SUM),
    .REG_INTERVAL(REG_INTERVAL)
  ) add_tree (
    .clk, .rstn, .cen,
    .x (terms),
    .y (sum)
  );
endmodule
