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

  initial forever #1 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_5_jump);

    dmem.mem[0] = 16'd1;
    dmem.mem[1] = 16'hDEAD;
    dmem.mem[2] = 16'hBEEF;

    // Load 1 into r1, then jump over the LOAD at PC 2 and store r1 at address 2.
    imem.mem[0] = {8'h00, 4'h1, LOAD};  // R1 = *(0);
    imem.mem[1] = {8'h03, 4'h1, JNZ};   // if (R1!=0) goto 3;
    imem.mem[2] = {8'h01, 4'h1, LOAD};  // R1 = *(1);            (skipped)
    imem.mem[3] = {8'h02, 4'h1, STORE}; // *(2) = R1;

    @(posedge clk); #1ps reset = 0;
    repeat (10) @(posedge clk);
    #1ps;

    assert (dmem.mem[2] == 16'd1)
      $display("PASS: mem[2]=%04h", dmem.mem[2]);
      else $fatal(1, "JNZ failed");
    $finish;
  end

endmodule
