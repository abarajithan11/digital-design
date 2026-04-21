`timescale 1ns/1ps

module tb_reduction_tree_min;
  logic clk = 0, rstn = 0, cen = 0;
  initial forever #1ns clk = ~clk;

  parameter N = 5, W_X = 8, N_EXP = 20;
  localparam LATENCY = $clog2(N);

  int i;
  logic [N-1:0][W_X-1:0] x;
  logic        [W_X-1:0] y, y_exp;

  reduction_tree_min #(.N(N), .W_X(W_X)) dut (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    @(posedge clk) #1ps rstn = 1;

    // Manual checking
    @(posedge clk) #1ps  x = '{ 8'd7,   8'd2,   8'd9,  8'd4,  8'd1}; cen = 1;
    repeat(LATENCY-1) @(posedge clk);

    @(posedge clk) #1ps  x = '{-8'sd3,  8'd12, -8'sd1, 8'd5,  8'd0}; cen = 1;
    repeat(LATENCY-1) @(posedge clk);

    // Self-checking
    repeat(N_EXP) begin
      for (i = 0; i < N; i = i + 1) x[i] = W_X'($urandom);

      y_exp = x[0];
      for (i = 1; i < N; i = i + 1)
        if ($signed(x[i]) < $signed(y_exp))
          y_exp = x[i];

      @(posedge clk) #1ps cen = 1;
      repeat(LATENCY-1) @(posedge clk);
      @(posedge clk) #1ps cen = 0;

      assert (y == y_exp)
        else $error("Mismatch: y=%0d expected=%0d x=%p",
                    $signed(y), $signed(y_exp), x);
    end
    $finish();
  end
endmodule