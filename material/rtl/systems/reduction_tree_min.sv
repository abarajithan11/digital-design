module reduction_tree_min #(
    parameter int N   = 8, W_X = 8,
    localparam int DEPTH = $clog2(N)
  )(
    input  logic clk, rstn, cen,
    input  logic [N-1:0][W_X-1:0] x,
    output logic        [W_X-1:0] y
  );

  localparam int N_PAD = 2**DEPTH;
  localparam logic [W_X-1:0] MAX = (W_X'(1) << (W_X-1)) - 1'b1;

  genvar stage, node;
  logic [DEPTH:0][N_PAD-1:0][W_X-1:0] tree;

  always_comb begin
    for (int i = 0; i < N_PAD; i++)
      tree[0][i] = i < N ? x[i] : MAX;
  end

  for (stage = 0; stage < DEPTH; stage++) begin : g_stage
    localparam int NUM_NODES = N_PAD >> (stage + 1);

    for (node = 0; node < NUM_NODES; node++) begin : g_node
      logic [W_X-1:0] left, right;

      always_comb begin
        left  = tree[stage][2*node];
        right = tree[stage][2*node+1];
      end

      always_ff @(posedge clk or negedge rstn)
        if (!rstn)     tree[stage+1][node] <= '0;
        else if (cen)  tree[stage+1][node] <=
            $signed(left) < $signed(right)
              ? left : right;
    end
  end

  always_comb y = tree[DEPTH][0];

endmodule
