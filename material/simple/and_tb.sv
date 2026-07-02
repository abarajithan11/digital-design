// and_tb.sv
`timescale 1ns/1ps

module and_tb;
  bit A, B, C;
  always_comb C = A && B;

  initial begin
    $dumpfile("waveform.vcd"); $dumpvars(0, and_tb);

         A = 0; B = 0; #1; $display("A=%b B=%b C=%b", A, B, C);
    #9   A = 0; B = 1; #1; $display("A=%b B=%b C=%b", A, B, C);
    #9   A = 1; B = 0; #1; $display("A=%b B=%b C=%b", A, B, C);
    #9   A = 1; B = 1; #1; $display("A=%b B=%b C=%b", A, B, C);

    #9 $finish;
  end
endmodule