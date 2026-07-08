`timescale 1ns/1ps

module tb_decoder;
  localparam N = 3, M = 2**N;

  logic [N-1:0] code;
  logic [M-1:0] onehot;

  decoder #(.N(N)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int i = 0; i < M; i++) begin
      #1;
      code = N'(i);
      #1ps;
      assert (onehot == (M'(1) << i))
        else $error("code=%0d onehot=%b", code, onehot);
    end

    $finish;
  end
endmodule
