`timescale 1ns/1ps

module tb_register_file;
  localparam int W_DATA = 8;
  localparam int N_REGS = 6;
  localparam int W_ADDR = $clog2(N_REGS);

  logic clk=0, rstn=0;
  logic [W_ADDR-1:0] raddr=0, waddr=0;
  logic wen=0;
  logic [W_DATA-1:0] wdata=0, rdata;

  initial forever #1 clk = !clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  register_file #(.W_DATA(W_DATA), .N_REGS(N_REGS)) dut (.*);

  task automatic write(input logic [W_ADDR-1:0] addr, input logic [W_DATA-1:0] data);
    posedge_clk; wen = 1; waddr = addr; wdata = data;
    posedge_clk; wen = 0;
  endtask

  task automatic check(input logic [W_ADDR-1:0] addr, input logic [W_DATA-1:0] exp);
    raddr = addr; #1ps;
    assert (rdata == exp) $display("OK: mem[%0d]=%h", addr, rdata);
    else $display("Error: mem[%0d]=%h, exp=%h", addr, rdata, exp);
  endtask

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk; rstn = 1;

    check(0, 8'h00);

    write(0, 8'hA5);
    write(3, 8'h3C);
    write(5, 8'h7F);

    check(0, 8'hA5);
    check(3, 8'h3C);
    check(5, 8'h7F);
    check(1, 8'h00);

    $finish();
  end
endmodule
