module reduction_tree_min_explicit #(
    parameter  N   = 8,
    parameter  W_X = 8,
    localparam DEPTH = $clog2(N)
  )(
    input  logic clk, rstn, cen,
    input  logic [N-1:0][W_X-1:0] x,
    output logic        [W_X-1:0] y
  );

  genvar stage, node;
  logic [DEPTH:0][N-1:0][W_X-1:0] tree;

  always_comb begin
    for (int i = 0; i < N; i++)
      tree[0][i] = x[i];
    y = tree[DEPTH][0];
  end

  for (stage = 0; stage < DEPTH; stage++) begin : gen_stage
    localparam int STAGE_SIZE      = (N + 2**stage - 1) / 2**stage;
    localparam int NEXT_STAGE_SIZE = (STAGE_SIZE + 1) / 2;

    for (node = 0; node < NEXT_STAGE_SIZE; node++) begin : gen_node
      always_ff @(posedge clk or negedge rstn) begin

        int idx_left, idx_right;
        logic [W_X-1:0] val_left, val_right, result;
        
        if (!rstn) begin
          tree[stage+1][node] <= '0;
        end else if (cen) begin
          idx_left  = 2 * node;
          idx_right = idx_left + 1;

          if (idx_right < STAGE_SIZE) begin
            val_left  = tree[stage][idx_left];
            val_right = tree[stage][idx_right];
            if ($signed(val_left) < $signed(val_right)) result = val_left;
            else                                        result = val_right;
            tree[stage+1][node] <= result;
          end else begin
            tree[stage+1][node] <= tree[stage][idx_left];
          end
        end
      end
    end
  end
endmodule
