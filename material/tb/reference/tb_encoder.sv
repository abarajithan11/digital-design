`timescale 1ns/1ps

module tb_encoder;
  localparam N = 3, M = 2**N;

  logic [M-1:0] onehot;
  logic [N-1:0] code;

  encoder #(.N(N)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int i = 0; i < M; i++) begin
      #1;
      onehot = M'(1) << i;
      #1ps;
      assert (code == N'(i))
        else $error("onehot=%b code=%0d exp=%0d", onehot, code, i);
    end

    $finish;
  end
endmodule
