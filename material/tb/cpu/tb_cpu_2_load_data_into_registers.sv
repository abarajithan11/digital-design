`timescale 1ns/1ps

module tb_cpu_2_load_data_into_registers;
  typedef enum logic [3:0] {LOAD} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata;

  cpu_2_load_data_into_registers dut(.*);

  memory imem(clk, imem_addr, '0, 1'b0, imem_rdata);
  memory dmem(clk, dmem_addr, '0, 1'b0, dmem_rdata);

  initial forever #1 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_2_load_data_into_registers);

    dmem.mem[2] = 16'hBEEF;
    dmem.mem[3] = 16'hABCD;

    // Load memory locations 2 and 3 into registers 1 and 2.
    imem.mem[0] = {8'h02, 4'h1, LOAD}; // R1 = *(2);
    imem.mem[1] = {8'h03, 4'h2, LOAD}; // R2 = *(3);

    @(posedge clk); #1ps reset = 0;
    repeat (2) @(posedge clk);
    #1ps;

    assert (dut.regs[1] == 16'hBEEF)
      $display("PASS: r1=%04h", dut.regs[1]);
      else $fatal(1, "LOAD failed");
    assert (dut.regs[2] == 16'hABCD)
      $display("PASS: r2=%04h", dut.regs[2]);
      else $fatal(1, "LOAD failed");
    repeat(5) @(posedge clk);
    $finish;
  end

endmodule
