`timescale 1ns/1ps
module tb_cpu_1_load_instruction;
   logic clk = 0, reset = 0;
   logic [7:0] imem_addr, dmem_addr;
   logic [15:0] imem_rdata, dmem_rdata, dmem_wdata;
   logic dmem_wen;
   memory imem(clk, imem_addr,             '0,       1'b0, imem_rdata);
   memory dmem(clk, dmem_addr, dmem_wdata, dmem_wen, dmem_rdata);
   cpu_1_load_instruction dut(.*);

  typedef enum logic[3:0]{LOAD,STORE,MOVE,ADD,SUB,MUL,JNZ} op_t;

   initial forever #1 clk = ~clk;
   initial begin
      $dumpfile(`FST_PATH); $dumpvars;
      // Read three example instructions.
      imem.mem[0] = 16'h1234; // ins0
      imem.mem[1] = 16'hABCD; // ins1
      imem.mem[2] = 16'hBEEF; // ins2
      repeat (20) @(posedge clk);
      $finish;
   end
endmodule
