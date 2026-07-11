`timescale 1ns/1ps

module tb_cpu_fibonacci;
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
    $dumpvars(0, tb_cpu_fibonacci);

    dmem.mem[0] = 16'd0;
    dmem.mem[1] = 16'd1;
    dmem.mem[2] = 16'd10;

    // Initialize consecutive Fibonacci values, counter, and constant one.
    imem.mem[0] = {8'h00,        4'h0, LOAD};  // r0 (a)       = mem[0] = 0
    imem.mem[1] = {8'h01,        4'h1, LOAD};  // r1 (b)       = mem[1] = 1
    imem.mem[2] = {8'h02,        4'h3, LOAD};  // r3 (counter) = 10
    imem.mem[3] = {8'h01,        4'h4, LOAD};  // r4 (one)     = 1

    // Advance the pair and repeat ten times.
    imem.mem[4] = {4'h1,  4'h0,  4'h2, ADD};   // r2 (next) = r0 (a) + r1 (b)
    imem.mem[5] = {4'h0,  4'h1,  4'h0, MOVE};  // r0 (a) = r1 (b)
    imem.mem[6] = {4'h0,  4'h2,  4'h1, MOVE};  // r1 (b) = r2 (next)
    imem.mem[7] = {4'h4,  4'h3,  4'h3, SUB};   // r3 (counter) -= r4 (one)
    imem.mem[8] = {8'h04,        4'h3, JNZ};   // repeat while r3 (counter) != 0

    imem.mem[9] = {8'h03,        4'h0, STORE}; // mem[3] = r0 = F(10)

    @(posedge clk); #1ps reset = 0;
    repeat (56) @(posedge clk);
    #1ps;

    assert (dmem.mem[3] == 55)
      $display("PASS: fibonacci(10)=%0d", dmem.mem[3]);
      else $fatal(1, "Fibonacci failed");
    $finish;
  end

endmodule
