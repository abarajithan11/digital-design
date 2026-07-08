`timescale 1ns/1ps

module tb_cpu_5_jump;
  typedef enum logic [3:0] {LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu_5_jump dut(.*);

  memory imem(clk, imem_addr,         '0,     1'b0, imem_rdata);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #5 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_5_jump);

    dmem.mem[0] = 16'd1;
    dmem.mem[1] = 16'hDEAD;
    dmem.mem[2] = 16'hBEEF;

    // Put 1 in r1, then jump from PC 1 to immediate address 4.
    imem.mem[0] = {8'h00, 4'h1, LOAD}; // r1 = mem[0] = 1
    imem.mem[1] = {8'h04, 4'h1, JNZ};  // if (r1 != 0) jump to PC 4
    imem.mem[2] = {8'h01, 4'h3, LOAD}; // r3 = mem[1] (skipped)
    imem.mem[4] = {8'h02, 4'h3, LOAD}; // r3 = mem[2]

    @(posedge clk); #1ps reset = 0;
    repeat (3) @(posedge clk);
    #1ps;

    assert (dut.regs[3] == 16'hBEEF)
      $display("PASS: r3=%04h", dut.regs[3]);
      else $fatal(1, "JNZ failed");
    $finish;
  end

endmodule
