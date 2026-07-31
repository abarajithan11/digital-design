`timescale 1ns/1ps

module tb_cpu_factorial;
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
    $dumpvars(0, tb_cpu_factorial);

    dmem.mem[0] = 16'd5;
    dmem.mem[1] = 16'd1;

    // Load 5 and constant 1, then initialize the factorial accumulator.
    imem.mem[0] = {8'h00,        4'h2, LOAD}; // R2 = *(0);          counter = 5
    imem.mem[1] = {8'h01,        4'h1, LOAD}; // R1 = *(1);          one     = 1
    imem.mem[2] = {4'h0,  4'h1,  4'h0, MOVE}; // R0 = R1;            factorial

    // Multiply by the counter, decrement it, and repeat until zero.
    imem.mem[3] = {4'h2,  4'h0,  4'h0, MUL}; // R0 = R0 * R2;
    imem.mem[4] = {4'h1,  4'h2,  4'h2, SUB}; // R2 = R2 - R1;
    imem.mem[5] = {8'h03,        4'h2, JNZ}; // if (R2!=0) goto 3;

    // Store 5! at memory address 4.
    imem.mem[6] = {8'h04,        4'h0, STORE}; // *(4) = R0;

    @(posedge clk); #1ps reset = 0;
    repeat (20) @(posedge clk);
    #1ps;

    assert (dmem.mem[4] == 120)
      $display("PASS: factorial=%0d", dmem.mem[4]);
      else $fatal(1, "Factorial failed");
    $finish;
  end

endmodule
