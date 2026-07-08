`timescale 1ns/1ps

module tb_sign_ext;
  localparam W_IN = 4, W_OUT = 8;

  logic [W_IN-1:0]  a;
  logic [W_OUT-1:0] y_concat, y_cast, exp;

  sign_ext #(.W_IN(W_IN), .W_OUT(W_OUT)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int i = 0; i < 2**W_IN; i++) begin
      #1;
      a   = W_IN'(i);
      exp = W_OUT'($signed(a));
      #1ps;
      assert (y_concat == exp && y_cast == exp && y_concat == y_cast)
        else $error("a=%b concat=%b cast=%b exp=%b", a, y_concat, y_cast, exp);
    end

    $finish;
  end
endmodule
