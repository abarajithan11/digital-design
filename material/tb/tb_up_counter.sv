`timescale 1ns/1ps

module tb_up_counter;
  localparam WIDTH = 8;
  logic clk=0, rstn=0, incr;
  logic [WIDTH-1:0] count;

  initial forever #1ns clk = ~clk;
  up_counter #(.WIDTH(WIDTH)) dut (.*);
  

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;
    
    @(posedge clk);
    #1ps rstn  = 1;

    repeat(2) @(posedge clk);
    #1ps incr = 1;

    @(posedge clk);
    #1ps rstn  = 0; incr = 1;

    repeat(4) @(posedge clk);
    #1ps incr = 0;

    repeat(4) @(posedge clk);
    #1ps rstn  = 1;
    
    $finish();
  end
endmodule