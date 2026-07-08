`timescale 1ns/1ps

module tb_priority_encoder;
  localparam N = 3, M = 2**N;

  logic [M-1:0] in;
  logic [N-1:0] code, exp;

  priority_encoder #(.N(N)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    repeat (30) begin
      #1;
      in  = M'($urandom);
      exp = '0;
      for (int i = 0; i < M; i++)
        if (in[i]) exp = N'(i);   // reference: index of MSB set (0 if none)
      #1ps;
      assert (code == exp)
        else $error("in=%b code=%0d exp=%0d", in, code, exp);
    end

    $finish;
  end
endmodule
