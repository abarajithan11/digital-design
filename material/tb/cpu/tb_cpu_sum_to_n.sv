`timescale 1ns/1ps

module tb_cpu_sum_to_n;
  typedef enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu dut(.*);

  memory imem(clk, imem_addr,         '0,     1'b0, imem_rdata);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #5 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_sum_to_n);

    dmem.mem[0] = 16'd10;
    dmem.mem[1] = 16'd1;
    dmem.mem[2] = 16'd0;

    // Initialize N, constant one, and the sum.
    imem.mem[0] = {8'h00,        4'h1, LOAD};  // r1 (counter) = N = 10
    imem.mem[1] = {8'h01,        4'h2, LOAD};  // r2 (one) = 1
    imem.mem[2] = {8'h02,        4'h3, LOAD};  // r3 (sum) = 0

    // Add each counter value and count down to zero.
    imem.mem[3] = {4'h1,  4'h3,  4'h3, ADD};   // r3 (sum) += r1 (counter)
    imem.mem[4] = {4'h2,  4'h1,  4'h1, SUB};   // r1 (counter) -= r2 (one)
    imem.mem[5] = {8'h03,        4'h1, JNZ};   // repeat while r1 (counter) != 0

    imem.mem[6] = {8'h03,        4'h3, STORE}; // mem[3] = r3 (sum)

    @(posedge clk); #1ps reset = 0;
    repeat (35) @(posedge clk);
    #1ps;

    assert (dmem.mem[3] == 55)
      $display("PASS: sum(1..10)=%0d", dmem.mem[3]);
      else $fatal(1, "Sum to N failed");
    $finish;
  end

endmodule
