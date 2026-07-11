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

    dmem.mem[0] = 16'hBEEF;

    // Load memory location 0 into register 3.
    imem.mem[0] = {8'h00, 4'h3, LOAD}; // r3 = mem[0]

    @(posedge clk); #1ps reset = 0;
    @(posedge clk); #1ps;

    assert (dut.regs[3] == 16'hBEEF)
      $display("PASS: r3=%04h", dut.regs[3]);
      else $fatal(1, "LOAD failed");
    $finish;
  end

endmodule
