`timescale 1ns/1ps

module tb_multiply;
  localparam W = 8;

  logic [W-1:0]   a, b;
  logic [2*W-1:0] p_unsigned, p_signed, p_manual;
  logic [2*W-1:0] exp_u;
  int             exp_s;

  multiply #(.W(W)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    repeat (40) begin
      #1;
      a = W'($urandom); b = W'($urandom);
      exp_u = a * b;                          // unsigned product
      exp_s = $signed(a) * $signed(b);        // signed product
      #1ps;
      assert (p_unsigned == exp_u)
        else $error("uns a=%0d b=%0d got=%0d exp=%0d", a, b, p_unsigned, exp_u);
      assert (int'($signed(p_signed)) == exp_s)
        else $error("sgn %0d*%0d got=%0d exp=%0d", $signed(a), $signed(b), $signed(p_signed), exp_s);
      assert (p_manual == p_signed)
        else $error("manual != signed: %0d vs %0d", p_manual, p_signed);
    end

    $finish;
  end
endmodule
