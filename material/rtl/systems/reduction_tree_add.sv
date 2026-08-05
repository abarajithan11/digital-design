module reduction_tree_add #(
  parameter int N            = 8,
  parameter int W_X          = 8,
  parameter int W_Y          = W_X + $clog2(N),
  parameter int REG_INTERVAL = 1,
  localparam int DEPTH       = $clog2(N)
  )(
  input  logic clk, rstn, cen,
  input  logic signed [N-1:0][W_X-1:0] x,
  output logic signed              [W_Y-1:0] y
  );

  localparam int N_PAD = 2**DEPTH;

  genvar stage, node;
  logic signed [N_PAD-1:0][W_Y-1:0] tree [DEPTH:0];

  always_comb begin
    for (int i = 0; i < N_PAD; i++)
      tree[0][i] = i < N ? W_Y'($signed(x[i])) : '0;
  end

  always_comb y = tree[DEPTH][0];

  for (stage = 0; stage < DEPTH; stage++) begin : g_stage
    localparam int NUM_NODES       = N_PAD >> (stage + 1);
    localparam int STAGE_WIDTH      = ((W_X + stage) < W_Y) ? W_X + stage : W_Y;
    localparam int NEXT_STAGE_WIDTH = ((W_X + stage + 1) < W_Y) ?
                                      W_X + stage + 1 : W_Y;

    for (node = 0; node < NUM_NODES; node++) begin : g_node
      logic signed [NEXT_STAGE_WIDTH-1:0] result;
      always_comb
        result = NEXT_STAGE_WIDTH'($signed(tree[stage][2*node][STAGE_WIDTH-1:0]))
               + NEXT_STAGE_WIDTH'($signed(tree[stage][2*node+1][STAGE_WIDTH-1:0]));

      localparam INSERT_REG = ((stage + 1) % REG_INTERVAL) == 0 || (stage + 1) == DEPTH;

      if (INSERT_REG) begin : gen_reg
        always_ff @(posedge clk or negedge rstn) begin
          if (!rstn)
            tree[stage+1][node] <= '0;
          else if (cen)
            tree[stage+1][node] <= W_Y'($signed(result));
        end
      end else begin : gen_comb
        always_comb
          tree[stage+1][node] = W_Y'($signed(result));
      end
    end
  end
endmodule
