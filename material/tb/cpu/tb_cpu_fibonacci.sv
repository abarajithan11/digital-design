`timescale 1ns/1ps

module tb_cpu_fibonacci;
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
    $dumpvars(0, tb_cpu_fibonacci);

    dmem.mem[0] = 16'd0;
    dmem.mem[1] = 16'd1;
    dmem.mem[2] = 16'd10;

    // Initialize consecutive Fibonacci values, counter, and constant one.
    imem.mem[0] = {8'h00,        4'h0, LOAD};  // R0 = *(0);          a       = 0
    imem.mem[1] = {8'h01,        4'h1, LOAD};  // R1 = *(1);          b       = 1
    imem.mem[2] = {8'h02,        4'h3, LOAD};  // R3 = *(2);          counter = 10
    imem.mem[3] = {8'h01,        4'h4, LOAD};  // R4 = *(1);          one     = 1

    // Advance the pair and repeat ten times.
    imem.mem[4] = {4'h1,  4'h0,  4'h2, ADD};   // R2 = R0 + R1;       next = a + b
    imem.mem[5] = {4'h0,  4'h1,  4'h0, MOVE};  // R0 = R1;
    imem.mem[6] = {4'h0,  4'h2,  4'h1, MOVE};  // R1 = R2;
    imem.mem[7] = {4'h4,  4'h3,  4'h3, SUB};   // R3 = R3 - R4;
    imem.mem[8] = {8'h04,        4'h3, JNZ};   // if (R3!=0) goto 4;

    imem.mem[9] = {8'h04,        4'h0, STORE}; // *(4) = R0;          F(10)

    posedge_clk(); reset = 0;
    posedge_clk(56);

    assert (dmem.mem[4] == 55)
      $display("PASS: fibonacci(10)=%0d", dmem.mem[4]);
      else $fatal(1, "Fibonacci failed");
    $finish;
  end

endmodule
