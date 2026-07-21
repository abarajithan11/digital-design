`timescale 1ns/1ps

module tb_parallel_to_serial;
  logic clk = 0, rstn = 0;
  initial forever #1ns clk = ~clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  parameter WIDTH = 8;
  logic [WIDTH-1:0] par_data;
  logic par_valid=0, par_ready, ser_data, ser_valid, ser_ready;

  parallel_to_serial #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk;     rstn = 1;
    posedge_clk;     par_data  = 8'd7 ; par_valid = 0; ser_ready = 1;
    posedge_clk(3);

    posedge_clk;     par_data  = 8'd62; par_valid = 1;
    posedge_clk;     par_valid = 0;
    posedge_clk(10);

    posedge_clk;     par_data  = 8'd52; par_valid = 1;
    posedge_clk;     par_valid = 0;
    posedge_clk;     ser_ready = 0;
    posedge_clk(3);

    posedge_clk;     ser_ready = 1;
    posedge_clk(10);

    posedge_clk;     ser_ready = 0;

    $finish();
  end
endmodule