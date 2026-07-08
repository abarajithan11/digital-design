`timescale 1ns/1ps

module tb_cpu_4_move_alu;
  typedef enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu_4_move_alu dut(.*);

  memory imem(clk, imem_addr,         '0,     1'b0, imem_rdata);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #5 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_4_move_alu);

    dmem.mem[0] = 16'd7;
    dmem.mem[1] = 16'd3;

    // Load 7 and 3, copy r1, then calculate sum, difference, and product.
    imem.mem[0] = {8'h00,        4'h1, LOAD}; // r1 = mem[0] = 7
    imem.mem[1] = {8'h01,        4'h2, LOAD}; // r2 = mem[1] = 3
    imem.mem[2] = {4'h0,  4'h1,  4'h6, MOVE}; // r6 = r1
    imem.mem[3] = {4'h2,  4'h1,  4'h3, ADD};  // r3 = r1 + r2
    imem.mem[4] = {4'h2,  4'h1,  4'h4, SUB};  // r4 = r1 - r2
    imem.mem[5] = {4'h2,  4'h1,  4'h5, MUL};  // r5 = r1 * r2

    @(posedge clk); #1ps reset = 0;
    repeat (6) @(posedge clk);
    #1ps;

    assert (dut.regs[6] == 7)  else $fatal(1, "MOVE failed");
    assert (dut.regs[3] == 10) else $fatal(1, "ADD failed");
    assert (dut.regs[4] == 4)  else $fatal(1, "SUB failed");
    assert (dut.regs[5] == 21) else $fatal(1, "MUL failed");
    $display("PASS: add=%0d sub=%0d mul=%0d", dut.regs[3], dut.regs[4], dut.regs[5]);
    $finish;
  end

endmodule
