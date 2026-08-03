`timescale 1ns/1ps

module tb_cpu_sum_to_n;
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
    $dumpvars(0, tb_cpu_sum_to_n);

    dmem.mem[0] = 16'd0;
    dmem.mem[1] = 16'd1;
    dmem.mem[2] = 16'd10;

    // Initialize N, constant one, and the sum.
    imem.mem[0] = {8'h00,        4'h0, LOAD};  // R0 = *(0);          sum     = 0
    imem.mem[1] = {8'h01,        4'h1, LOAD};  // R1 = *(1);          one     = 1
    imem.mem[2] = {8'h02,        4'h2, LOAD};  // R2 = *(2);          counter = N = 10

    // Add each counter value and count down to zero.
    imem.mem[3] = {4'h2,  4'h0,  4'h0, ADD};   // R0 = R0 + R2;
    imem.mem[4] = {4'h1,  4'h2,  4'h2, SUB};   // R2 = R2 - R1;
    imem.mem[5] = {8'h03,        4'h2, JNZ};   // if (R2!=0) goto 3;

    imem.mem[6] = {8'h04,        4'h0, STORE}; // *(4) = R0;          sum

    posedge_clk(); reset = 0;
    posedge_clk(35);

    assert (dmem.mem[4] == 55)
      $display("PASS: sum(1..10)=%0d", dmem.mem[4]);
      else $fatal(1, "Sum to N failed");
    $finish;
  end

endmodule
