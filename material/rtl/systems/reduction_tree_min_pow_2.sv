module reduction_tree_min #(
  parameter int N   = 8, W_X = 8,
  localparam int DEPTH = $clog2(N)
)(
  input  logic clk, rstn, cen,
  input  logic [N-1:0][W_X-1:0]    x,
  output logic        [W_X-1:0]    y
);
  genvar stage, node, i;
  logic [DEPTH:0][N-1:0][W_X-1:0] tree;

  for (i = 0; i < N; i++)
    always_comb tree[0][i] = x[i];

  // Each stage contains exactly half as many nodes
  for (stage = 0; stage < DEPTH; stage++) begin : gen_stage

    localparam int NUM_NODES = N >> (stage + 1);

    for (node = 0; node < NUM_NODES; node++) begin : gen_node

      logic [W_X-1:0] left, right;
      always_comb begin
        left = tree[stage][2*node];
        right = tree[stage][2*node+1];
      end
      always_ff @(posedge clk or negedge rstn)
        if (!rstn)    tree[stage+1][node] <= '0;
        else if (cen) tree[stage+1][node] <=
                          $signed(left) < $signed(right)
                        ? left : right;
    end
  end
  always_comb y = tree[DEPTH][0];

endmodule