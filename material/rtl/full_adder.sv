`timescale 1ns/1ps

module full_adder (
  input  logic a, b, ci,
  output logic sum, co
);
  logic wire_1, wire_2, wire_3;

  always_comb begin
    wire_1 = a ^ b;            // bitwise XOR
    wire_2 = wire_1 & ci;      // bitwise AND
    wire_3 = a & b;            // bitwise AND

    co     = wire_2 | wire_3;  // bitwise OR
    sum    = wire_1 ^ ci  ;    // bitwise XOR
  end

endmodule