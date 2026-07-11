`timescale 1ns/1ps

module tb_cpu_3_store_data;
  typedef enum logic [3:0] {LOAD, STORE} op_t;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr, dmem_addr;
  logic [15:0] imem_rdata, dmem_rdata, dmem_wdata;
  logic dmem_wen;

  cpu_3_store_data dut(.*);

  memory imem(clk, imem_addr,         '0,     1'b0, imem_rdata);
  memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);

  initial forever #1 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_3_store_data);

    dmem.mem[0] = 16'hBEEF;

    // Load 0xBEEF into r3, then store r3 at address 1.
    imem.mem[0] = {8'h00, 4'h3, LOAD};  // r3 = mem[0]
    imem.mem[1] = {8'h01, 4'h3, STORE}; // mem[1] = r3

    @(posedge clk); #1ps reset = 0;
    repeat (2) @(posedge clk);
    #1ps;

    assert (dmem.mem[1] == 16'hBEEF)
      $display("PASS: mem[1]=%04h", dmem.mem[1]);
      else $fatal(1, "STORE failed");
    $finish;
  end

endmodule
