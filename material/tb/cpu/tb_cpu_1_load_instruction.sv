`timescale 1ns/1ps

module tb_cpu_1_load_instruction;

  logic clk = 0, reset = 1;
  logic [7:0] imem_addr;
  logic [15:0] imem_rdata;

  cpu_1_load_instruction dut(.*);

  memory imem(clk, imem_addr, '0, 1'b0, imem_rdata);

  initial forever #5 clk = ~clk;

  initial begin
    $dumpfile(`FST_PATH);
    $dumpvars(0, tb_cpu_1_load_instruction);

    // Read and display three example instructions.
    imem.mem[0] = 16'h1234; // example instruction
    imem.mem[1] = 16'hABCD; // example instruction
    imem.mem[2] = 16'hBEEF; // example instruction

    @(posedge clk); #1ps reset = 0;
    repeat (3) @(posedge clk);
    #1ps;

    assert (imem_addr == 8'd3)
      $display("PASS: fetched three instructions");
      else $fatal(1, "Instruction fetch failed");
    $finish;
  end

endmodule
