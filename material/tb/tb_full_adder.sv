`timescale 1ns/1ps

module tb_full_adder;

  logic a=0, ci=0, b, sum, co; // b != 0, intentional

  full_adder dut (.*);

  initial begin // simulation starts
    $dumpfile(`VCD_PATH); $dumpvars;

    #30 a = 0; b = 0; ci = 0;    
    #10 a = 0; b = 0; ci = 1;
    
    #20 a = 1; b = 1; ci = 0;
    #1  assert ({co,sum} == a+b+ci) 
          $display ("OK"); 
          else $error("Not OK");
    
    #10 a = 1; b = 1; ci = 1;
    #1  assert (dut.wire_1 == 0) // 1 (xor) 1 = 0 
          else $error("False. wire_1:%d", dut.wire_1);
    
    $finish(); // simulation ends
  end
endmodule