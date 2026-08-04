`timescale 1ns/1ps
module tb_cpu_1_load_instruction;
   logic clk = 0, reset = 1;
   logic [7:0] pc, addr;
   logic [15:0] instruction, read_data, write_data;
   logic dmem_wen;
   memory imem(clk, pc,                    '0,       1'b0, instruction);
   memory dmem(clk, addr, write_data, dmem_wen, read_data);
   cpu_1_load_instruction dut(.*);

  typedef enum logic[3:0]{NOP,LOAD,STORE,MOVE,ADD,SUB,MUL,JNZ} op_t;

   initial forever #1 clk = ~clk;
   task automatic posedge_clk(int n = 1);
      repeat (n) @(posedge clk); #1ps;
   endtask

   initial begin
      $dumpfile(`FST_PATH); $dumpvars;
      // Read three example instructions.
      imem.mem[0] = 16'h1234; // ins0
      imem.mem[1] = 16'hABCD; // ins1
      imem.mem[2] = 16'hBEEF; // ins2
      posedge_clk(); reset = 0;
      posedge_clk(20);
      $finish;
   end
endmodule
