`timescale 1ns/1ps

module alu #(
  parameter  WIDTH     = 8,
  localparam W_ALU_SEL = 3
)(
  input  logic [WIDTH-1:0] bus_a,
  input  logic [WIDTH-1:0] bus_b,
  output logic [WIDTH-1:0] alu_out,
  input  logic [W_ALU_SEL   -1:0] alu_sel,
  output logic zero, negative
);

  always_comb begin

    unique case (alu_sel)
      'b001  : alu_out = $signed(bus_a) + $signed(bus_b);
      'b010  : alu_out = $signed(bus_a) - $signed(bus_b);
      'b011  : alu_out = $signed(bus_a) * $signed(bus_b);
      'b100  : alu_out = bus_a/2;
      default: alu_out = bus_a; // pass a if 0
    endcase

    zero      = (alu_out == 0);
    negative  = (alu_out <  0);
  end

endmodule