`timescale 1ns/1ps

module tb_saturating_adder;
  localparam W = 8;
  localparam int MAX =  (1 << (W-1)) - 1;
  localparam int MIN = -(1 << (W-1));

  logic [W-1:0] a, b, s;
  int           full, exp;

  saturating_adder #(.W(W)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    repeat (40) begin
      #1;
      a = W'($urandom); b = W'($urandom);
      full = int'($signed(a)) + int'($signed(b));
      if      (full > MAX) exp = MAX;
      else if (full < MIN) exp = MIN;
      else                 exp = full;
      #1ps;
      assert (int'($signed(s)) == exp)
        else $error("a=%0d b=%0d s=%0d exp=%0d", $signed(a), $signed(b), $signed(s), exp);
    end

    // saturation edge cases
    #1 a = W'(MAX); b = W'(MAX); #1ps assert (int'($signed(s)) == MAX) else $error("+sat");
    #1 a = W'(MIN); b = W'(MIN); #1ps assert (int'($signed(s)) == MIN) else $error("-sat");

    $finish;
  end
endmodule
