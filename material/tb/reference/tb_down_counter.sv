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
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  down_counter #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    // hold reset for a couple cycles
    posedge_clk(2); rstn = 1;

    // load max = 5
    posedge_clk; max_in = 8'd5; clear = 1;
    posedge_clk; clear = 0;

    // count down through full cycle: 5,4,3,2,1,0,5,4,...
    en = 1;
    posedge_clk(8);

    // pause counting
    en = 0;
    posedge_clk(3);

    // continue counting
    en = 1;
    posedge_clk(4);

    // load a new max = 3 while running
    max_in = 8'd3;
    clear  = 1;
    en     = 0;
    posedge_clk; clear = 0;

    // count again with new max
    en = 1;
    posedge_clk(6);

    // async reset in the middle
    rstn = 0;
    posedge_clk; rstn = 1;

    // reload after reset
    posedge_clk; max_in = 8'd2;
          clear  = 1;
    posedge_clk; clear  = 0;
          en     = 1;

    posedge_clk(5);

    $finish;
  end

endmodule