`timescale 1ns / 1ps

module reduction_tree_min #(
    parameter  N = 8, W_X = 8,
    localparam DEPTH = $clog2(N), N_PAD = 2**DEPTH
  )(
    input  logic clk, rstn, cen,
    input  logic [N-1:0][W_X-1:0] x,
    output logic        [W_X-1:0] y
  );

  // Pad with the largest positive value so padded lanes never become the min
  localparam logic [W_X-1:0] MAX_VAL = {1'b0, {(W_X-1){1'b1}}};

  genvar n, d, a;
  logic [N_PAD-1:0][W_X-1:0] x_pad ;
  logic [DEPTH:0][N_PAD-1:0][W_X-1:0] tree;

  always_comb begin

    // padding
    x_pad[N-1:0] = x;
    for (int i = 0; i < N_PAD; i = i + 1) begin
      if (i >= N) x_pad[i] = MAX_VAL;
      tree[0][i] = x_pad[i];
    end

    y = tree[DEPTH][0];
  end

  // Reduction tree
  for (d = 0; d < DEPTH; d = d + 1)
    for (a = 0; a < N_PAD/2**(d+1); a = a + 1)
      always_ff @(posedge clk or negedge rstn)
        if (!rstn) tree[d+1][a] <= 0;
        else if (cen) tree[d+1][a] <= ($signed(tree[d][2*a]) < $signed(tree[d][2*a+1]))
                                    ? tree[d][2*a]
                                    : tree[d][2*a+1];

endmodule