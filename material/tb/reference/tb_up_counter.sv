`timescale 1ns/1ps

module tb_up_counter;
  localparam WIDTH = 8;
  logic clk=0, rstn=0, incr;
  logic [WIDTH-1:0] count;

  initial forever #1ns clk = ~clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  up_counter #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk;    rstn = 1;
    posedge_clk(2); incr = 1;
    posedge_clk;    rstn = 0; incr = 1;
    posedge_clk(4); incr = 0;
    posedge_clk(4); rstn = 1;

    $finish();
  end
endmodule