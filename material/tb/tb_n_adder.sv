`timescale 1ns/1ps

module tb_n_adder;  
  localparam N = 8;

  logic signed [N-1:0] A, B, S;
  logic ci, co;
  
  bit [N-1:0] m;
  int status;

  n_adder #(.N(N)) dut (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars(0, dut);
    
    A = 8'd5; B = 8'd10; ci = 0;
    #1 assert (S == 8'd15) else $error("Fail");

    #1 A = 8'd30;  B = -8'd10; ci = 0;
    #1 A = 8'd5;   B = 8'd10;  ci = 1;
    #1 A = 8'd127; B = 8'd1;   ci = 0;

    repeat(10) begin
      #1
      status = std::randomize(ci);
      status = std::randomize(A) with { A inside {[-128:127]}; };
      status = std::randomize(B) with { B inside {[-128:127]}; };
      #1ps
      assert ({co,S} == A+B+ci)
        else $error("%d+%d+%d != {%d,%d}", A,B,ci,co,S);
    end

    $finish;
  end
endmodule