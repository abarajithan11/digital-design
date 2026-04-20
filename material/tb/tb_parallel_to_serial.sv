`timescale 1ns/1ps

module tb_parallel_to_serial;
  logic clk = 0, rstn = 0;
  initial forever #1ns clk = ~clk;

  parameter WIDTH = 8;
  logic [WIDTH-1:0] par_data;
  logic par_valid=0, par_ready, ser_data, ser_valid, ser_ready;

  parallel_to_serial #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;
    
    @(posedge clk)  #1ps  rstn = 1;
    @(posedge clk)  #1ps  par_data  = 8'd7 ; par_valid = 0; ser_ready = 1;
    repeat(3) @(posedge clk)
    
    @(posedge clk)  #1ps  par_data  = 8'd62; par_valid = 1;
    @(posedge clk)  #1ps  par_valid = 0;
    repeat(10) @(posedge clk)
    
    @(posedge clk)  #1ps  par_data  = 8'd52; par_valid = 1;
    @(posedge clk)  #1ps  par_valid = 0; 
    @(posedge clk)  #1ps  ser_ready = 0;
    repeat(3) @(posedge clk)
    
    @(posedge clk)  #1ps  ser_ready = 1;
    repeat(10) @(posedge clk)
    
    @(posedge clk)  #1ps  ser_ready = 0;
    
    $finish();
  end
endmodule