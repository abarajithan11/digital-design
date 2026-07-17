`timescale 1ns/1ps

module tb_flip_flop;
  logic i, o, o_exp, clk=0, rstn=0;
  flip_flop dut (.*);

  initial forever #1ns clk = !clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk; rstn = 1;

    posedge_clk; i = 1;
    posedge_clk; i = 0;
    posedge_clk; i = 1; rstn = 1;
    posedge_clk;

    repeat (10) begin
      i = 1'($urandom);
      o_exp = i;

      posedge_clk;
      assert (o == o_exp) else $error("o:%0b != o_exp:%0b", o, o_exp);
    end

    $finish;
  end
endmodule
