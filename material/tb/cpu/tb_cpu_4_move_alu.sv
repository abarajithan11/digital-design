`timescale 1ns/1ps

module tb_cpu_4_move_alu;
  typedef enum logic [3:0] {NOP, LOAD, STORE, MOVE, ADD, SUB, MUL} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] pc, addr;
  logic [15:0] instruction, read_data, write_data;
  logic dmem_wen;

  cpu_4_move_alu dut(.*);

  memory imem(clk, pc,           '0,     1'b0, instruction);
  memory dmem(clk, addr, write_data, dmem_wen, read_data);

  initial forever #1 clk = ~clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_4_move_alu);

    dmem.mem[0] = 16'd7;
    dmem.mem[1] = 16'd3;

    // Load 7 and 3, copy r1, then calculate sum, difference, and product.
    imem.mem[0] = {8'h00,        4'h1, LOAD}; // R1 = *(0);      (7)
    imem.mem[1] = {8'h01,        4'h2, LOAD}; // R2 = *(1);      (3)
    imem.mem[2] = {4'h0,  4'h1,  4'h6, MOVE}; // R6 = R1;
    imem.mem[3] = {4'h2,  4'h1,  4'h3, ADD};  // R3 = R1 + R2;
    imem.mem[4] = {4'h2,  4'h1,  4'h4, SUB};  // R4 = R1 - R2;
    imem.mem[5] = {4'h2,  4'h1,  4'h5, MUL};  // R5 = R1 * R2;

    posedge_clk(); reset = 0;
    posedge_clk(10);

    assert (dut.regs[6] == 7)  else $fatal(1, "MOVE failed");
    assert (dut.regs[3] == 10) else $fatal(1, "ADD failed");
    assert (dut.regs[4] == 4)  else $fatal(1, "SUB failed");
    assert (dut.regs[5] == 21) else $fatal(1, "MUL failed");
    $display("PASS: add=%0d sub=%0d mul=%0d", dut.regs[3], dut.regs[4], dut.regs[5]);
    $finish;
  end

endmodule
