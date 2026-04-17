`timescale 1ns/1ps

module tb_adder;
  localparam int WIDTH = 8;

  logic [WIDTH-1:0] a, b, sum;
  logic carry_out;
  logic [WIDTH:0] exp;

  adder #(.WIDTH(WIDTH)) dut (.*);

  string vcd_path;

  task automatic check(input logic [WIDTH-1:0] ai, input logic [WIDTH-1:0] bi);
    begin
      a = ai;
      b = bi;
      #1;
      exp = ai + bi;

      if ({carry_out, sum} !== exp) begin
        $error("Mismatch: a=%0d b=%0d got={carry=%0d,sum=%0d} exp=%0d", ai, bi, carry_out, sum, exp);
        $fatal(1);
      end
    end
  endtask

  initial begin
    if (!$value$plusargs("VCD=%s", vcd_path)) begin
      vcd_path = "adder.vcd";
    end
    $dumpfile(vcd_path);
    $dumpvars(0, tb_adder);

    for (int i = 0; i < 2** WIDTH; i++) begin
      for (int j = 0; j < 2** WIDTH; j++) begin
        check(i[WIDTH-1:0], j[WIDTH-1:0]);
      end
    end

    $display("PASS: adder exhaustive test completed.");
    $finish;
  end
endmodule