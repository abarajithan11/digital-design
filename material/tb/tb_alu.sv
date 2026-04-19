`timescale 1ns/1ps

module tb_alu;
  localparam WIDTH = 8;

  logic [WIDTH-1:0] bus_a, bus_b, alu_out;
  logic [2:0] alu_sel;
  logic zero, negative;

  alu #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile(`VCD_PATH);
    $dumpvars(0, tb_alu);

    repeat (5) begin
      #1;
      bus_a   = WIDTH'($urandom);
      bus_b   = WIDTH'($urandom);
      alu_sel = 3'($urandom_range(4, 0));
    end

    #3 bus_a =  8'sd5;   bus_b =  8'sd10;  alu_sel = 3'b000;
    #1 bus_a =  8'sd30;  bus_b = -8'sd10;  alu_sel = 3'b001;
    #1 bus_a =  8'sd5;   bus_b =  8'sd10;  alu_sel = 3'b010;
    #1 bus_a =  8'sd51;  bus_b =  8'sd17;  alu_sel = 3'b011;
    #1 $finish;
  end
endmodule
