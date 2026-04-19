`timescale 1ns/1ps

module tb_not_gate;
  logic i, o;

  not_gate dut (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    repeat (10) begin
      #1;
      i = 1'($urandom);
      #1ps;
      assert (o == !i) else $error("!%0b != %0b", i, o);
    end

    $finish;
  end
endmodule
