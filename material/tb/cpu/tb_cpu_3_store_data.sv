`timescale 1ns/1ps

module tb_cpu_3_store_data;
  typedef enum logic [3:0] {NOP, LOAD, STORE} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] pc, dmem_addr;
  logic [15:0] instruction, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu_3_store_data dut(.*);

  memory imem(clk, pc,                '0,     1'b0, instruction);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #1 clk = ~clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_3_store_data);

    dmem.mem[3] = 16'hBEEF;
    // Load 0xBEEF from address 3 into r2, then store r2 at addresses 2, 1 and 0.
    imem.mem[0] = {8'h03, 4'h2, LOAD};  // R2 = *(3);
    imem.mem[1] = {8'h02, 4'h2, STORE}; // *(2) = R2;
    imem.mem[2] = {8'h01, 4'h2, STORE}; // *(1) = R2;
    imem.mem[3] = {8'h00, 4'h2, STORE}; // *(0) = R2;

    posedge_clk(); reset = 0;
    posedge_clk(10);

    assert (dut.regs[2]  == 16'hBEEF) else $fatal(1, "LOAD failed");
    assert (dmem.mem[2] == 16'hBEEF) else $fatal(1, "STORE to mem[2] failed");
    assert (dmem.mem[1] == 16'hBEEF) else $fatal(1, "STORE to mem[1] failed");
    assert (dmem.mem[0] == 16'hBEEF) else $fatal(1, "STORE to mem[0] failed");
    $display("PASS: r2=%04h mem[2:0]=%04h %04h %04h",
             dut.regs[2], dmem.mem[2], dmem.mem[1], dmem.mem[0]);
    $finish;
  end

endmodule
