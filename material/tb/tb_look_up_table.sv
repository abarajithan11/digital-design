`timescale 1ns/1ps

module tb_look_up_table;
  localparam W = 4, F = 4;

  logic [W-1:0] in, out;
  longint       x2, x3, num, exp;

  look_up_table #(.W(W), .F(F)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int i = 0; i < 2**W; i++) begin
      #1;
      in  = W'(i);
      x2  = longint'(in) * longint'(in);
      x3  = x2 * longint'(in);
      num = ((x2 << F) << 1) + (x2 << F) - (x3 << 1);   // 3*x^2*2^F - 2*x^3
      exp = num >>> (2*F);
      #1ps;
      assert (out == W'(exp))
        else $error("in=%0d out=%0d exp=%0d", in, out, exp);
    end

    $finish;
  end
endmodule
