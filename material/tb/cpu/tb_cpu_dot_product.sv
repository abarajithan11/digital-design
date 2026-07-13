`timescale 1ns/1ps

module tb_cpu_dot_product;
  typedef enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu dut(.*);

  memory imem(clk, imem_addr,         '0,     1'b0, imem_rdata);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #1 clk = ~clk;

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
    imem.mem[0]  = {8'h00,        4'h0, LOAD};  // r0 (sum) = mem[0] = 0

    // Accumulate 1 * 4.
    imem.mem[1]  = {8'h01,        4'h1, LOAD};  // r1 (x) = 1
    imem.mem[2]  = {8'h04,        4'h2, LOAD};  // r2 (y) = 4
    imem.mem[3]  = {4'h2,  4'h1,  4'h3, MUL};   // r3 (product) = r1 (x) * r2 (y)
    imem.mem[4]  = {4'h3,  4'h0,  4'h0, ADD};   // r0 (sum) += r3 (product)

    // Accumulate 2 * 5.
    imem.mem[5]  = {8'h02,        4'h1, LOAD};  // r1 (x) = 2
    imem.mem[6]  = {8'h05,        4'h2, LOAD};  // r2 (y) = 5
    imem.mem[7]  = {4'h2,  4'h1,  4'h3, MUL};   // r3 (product) = r1 (x) * r2 (y)
    imem.mem[8]  = {4'h3,  4'h0,  4'h0, ADD};   // r0 (sum) += r3 (product)

    // Accumulate 3 * 6.
    imem.mem[9]  = {8'h03,        4'h1, LOAD};  // r1 (x) = 3
    imem.mem[10] = {8'h06,        4'h2, LOAD};  // r2 (y) = 6
    imem.mem[11] = {4'h2,  4'h1,  4'h3, MUL};   // r3 (product) = r1 (x) * r2 (y)
    imem.mem[12] = {4'h3,  4'h0,  4'h0, ADD};   // r0 (sum) += r3 (product)

    imem.mem[13] = {8'h04,        4'h0, STORE}; // mem[4] = r0 (sum)

    @(posedge clk); #1ps reset = 0;
    repeat (15) @(posedge clk);
    #1ps;

    assert (dmem.mem[4] == 32)
      $display("PASS: dot_product=%0d", dmem.mem[4]);
      else $fatal(1, "Dot product failed");
    $finish;
  end

endmodule
