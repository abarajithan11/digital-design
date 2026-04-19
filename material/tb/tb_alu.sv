`timescale 1ns/1ps

module tb_alu;
  localparam WIDTH = 8;

  logic        [2:0]       alu_sel;
  logic signed [WIDTH-1:0] bus_a, bus_b, alu_out;
  logic                    zero, negative;

  alu #(.WIDTH(WIDTH)) dut (.*);

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, alu_tb);

    repeat (5) begin
      #10;
      bus_a   = $urandom[WIDTH-1:0];
      bus_b   = $urandom[WIDTH-1:0];
      alu_sel = $urandom_range(4, 0);
    end

    #30 bus_a =  8'sd5;   bus_b =  8'sd10;  alu_sel = 3'b000;
    #10 bus_a =  8'sd30;  bus_b = -8'sd10;  alu_sel = 3'b001;
    #10 bus_a =  8'sd5;   bus_b =  8'sd10;  alu_sel = 3'b010;
    #10 bus_a =  8'sd51;  bus_b =  8'sd17;  alu_sel = 3'b011;
  end
endmodule