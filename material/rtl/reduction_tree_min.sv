`timescale 1ns / 1ps

module reduction_tree_min #(
    parameter  N   = 8,
    parameter  W_X = 8,
    localparam DEPTH = $clog2(N)
  )(
    input  logic clk, rstn, cen,
    input  logic [N-1:0][W_X-1:0] x,
    output logic        [W_X-1:0] y
  );

  typedef logic [W_X-1:0] data_t;

  function automatic data_t min(input data_t a, input data_t b);
    return ($signed(a) < $signed(b)) ? a : b;
  endfunction 

  genvar level, pos;
  logic [DEPTH:0][N-1:0][W_X-1:0] tree;

  always_comb begin
    for (int i = 0; i < N; i++)
      tree[0][i] = x[i];
    y = tree[DEPTH][0];
  end

  for (level = 0; level < DEPTH; level++) begin : gen_d
    localparam CURR_N = (N + 2**level - 1) / 2**level;
    localparam NEXT_N = (CURR_N + 1) / 2;

    for (pos = 0; pos < NEXT_N; pos++) begin : gen_a
      always_ff @(posedge clk or negedge rstn) begin

        int i_left, i_right;
        logic [W_X-1:0] vl, vr;
        
        if (!rstn) tree[level+1][pos] <= '0;
        else if (cen) begin
          i_left = 2*pos;
          i_right = i_left + 1;

          if (i_right < CURR_N) begin
            vl = tree[level][i_left];
            vr = tree[level][i_right];
            tree[level+1][pos] <= min(vl, vr);
          end else begin
            tree[level+1][pos] <= tree[level][i_left];
          end
        end
      end
    end
  end
endmodule