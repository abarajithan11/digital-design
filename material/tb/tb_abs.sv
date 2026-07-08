`timescale 1ns/1ps

module tb_abs;
  localparam W = 8;

  logic [W-1:0] a, y, exp;

  abs #(.W(W)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    repeat (40) begin
      #1;
      a = W'($urandom);
      exp = ($signed(a) < 0) ? W'(-$signed(a)) : a;
      #1ps;
      assert (y == exp)
        else $error("a=%0d y=%0d exp=%0d", $signed(a), y, exp);
    end

    #1 a = W'(1 << (W-1));   // most-negative: |MIN| = 2**(W-1)
    #1ps assert (y == (W'(1) << (W-1))) else $error("abs(MIN) y=%0d", y);

    $finish;
  end
endmodule
