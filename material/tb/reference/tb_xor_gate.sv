`timescale 1ns/1ps

module tb_xor_gate;
  logic a, b, y;

  xor_gate dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;
    for (int i = 0; i < 4; i++) begin
      {a, b} = i[1:0];
      #1;
      assert (y == (a ^ b));
    end
    $finish;
  end
endmodule
