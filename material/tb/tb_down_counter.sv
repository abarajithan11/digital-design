`timescale 1ns/1ps

module tb_down_counter;
  localparam WIDTH = 8;

  logic clk = 0;
  logic rstn = 0;
  logic en = 0;
  logic clear = 0;
  logic [WIDTH-1:0] max_in = 0;
  logic [WIDTH-1:0] count = 0;
  logic last, last_clk;

  initial forever #1ns clk = ~clk;

  down_counter #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    // hold reset for a couple cycles
    repeat (2) @(posedge clk);
    #1ps rstn = 1;

    // load max = 5
    @(posedge clk);
    #1ps max_in = 8'd5; clear  = 1;

    @(posedge clk);
    #1ps clear  = 0;

    // count down through full cycle: 5,4,3,2,1,0,5,4,...
    #1ps en = 1;
    repeat (8) @(posedge clk);

    // pause counting
    #1ps en = 0;
    repeat (3) @(posedge clk);

    // continue counting
    #1ps en = 1;
    repeat (4) @(posedge clk);

    // load a new max = 3 while running
    #1ps max_in = 8'd3;
         clear  = 1;
         en     = 0;

    @(posedge clk);
    #1ps clear  = 0;

    // count again with new max
    #1ps en = 1;
    repeat (6) @(posedge clk);

    // async reset in the middle
    #1ps rstn = 0;
    @(posedge clk);
    #1ps rstn = 1;

    // reload after reset
    @(posedge clk);
    #1ps max_in = 8'd2;
         clear  = 1;

    @(posedge clk);
    #1ps clear  = 0;
         en     = 1;

    repeat (5) @(posedge clk);

    $finish;
  end

endmodule