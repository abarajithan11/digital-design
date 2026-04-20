`timescale 1ns/1ps

module tb_flip_flop;
  logic i, o, o_exp, clk=0, rstn=0;
  flip_flop dut (.*);

  initial forever #1ns clk = !clk;

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    @(posedge clk);
    #1ps; rstn = 1;

    @(posedge clk); i = 1;
    @(posedge clk); i = 0; 
    @(posedge clk); i = 1; rstn = 1;
    @(posedge clk);

    repeat (10) begin
      i = 1'($urandom);
      o_exp = i;

      @(posedge clk);
      #1ps; assert (o == o_exp) else $error("o:%0b != o_exp:%0b", o, o_exp);
    end

    $finish;
  end
endmodule
