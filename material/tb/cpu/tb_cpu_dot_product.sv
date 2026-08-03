`timescale 1ns/1ps

module tb_cpu_dot_product;
  typedef enum logic [3:0] {NOP, LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] pc, dmem_addr;
  logic [15:0] instruction, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu dut(.*);

  memory imem(clk, pc,                '0,     1'b0, instruction);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #1 clk = ~clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_dot_product);

    dmem.mem[0] = 16'd0;
    dmem.mem[1] = 16'd1;
    dmem.mem[2] = 16'd2;
    dmem.mem[3] = 16'd3;
    dmem.mem[4] = 16'd4;
    dmem.mem[5] = 16'd5;
    dmem.mem[6] = 16'd6;

    // Initialize the accumulator.
    imem.mem[0]  = {8'h00,        4'h0, LOAD};  // R0 = *(0);        sum = 0

    // Accumulate 1 * 4.
    imem.mem[1]  = {8'h01,        4'h1, LOAD};  // R1 = *(1);        x
    imem.mem[2]  = {8'h04,        4'h2, LOAD};  // R2 = *(4);        y
    imem.mem[3]  = {4'h2,  4'h1,  4'h3, MUL};   // R3 = R1 * R2;
    imem.mem[4]  = {4'h3,  4'h0,  4'h0, ADD};   // R0 = R0 + R3;

    // Accumulate 2 * 5.
    imem.mem[5]  = {8'h02,        4'h1, LOAD};  // R1 = *(2);        x
    imem.mem[6]  = {8'h05,        4'h2, LOAD};  // R2 = *(5);        y
    imem.mem[7]  = {4'h2,  4'h1,  4'h3, MUL};   // R3 = R1 * R2;
    imem.mem[8]  = {4'h3,  4'h0,  4'h0, ADD};   // R0 = R0 + R3;

    // Accumulate 3 * 6.
    imem.mem[9]  = {8'h03,        4'h1, LOAD};  // R1 = *(3);        x
    imem.mem[10] = {8'h06,        4'h2, LOAD};  // R2 = *(6);        y
    imem.mem[11] = {4'h2,  4'h1,  4'h3, MUL};   // R3 = R1 * R2;
    imem.mem[12] = {4'h3,  4'h0,  4'h0, ADD};   // R0 = R0 + R3;

    imem.mem[13] = {8'h04,        4'h0, STORE}; // *(4) = R0;

    posedge_clk(); reset = 0;
    posedge_clk(15);

    assert (dmem.mem[4] == 32)
      $display("PASS: dot_product=%0d", dmem.mem[4]);
      else $fatal(1, "Dot product failed");
    $finish;
  end

endmodule
