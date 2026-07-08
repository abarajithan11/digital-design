`timescale 1ns/1ps

module demux #(
  parameter W     = 3,
  parameter W_SEL = 2
)(
  input  logic [W-1:0]               in,
  input  logic [W_SEL-1:0]           sel,
  output logic [2**W_SEL-1:0][W-1:0] out
);
  always_comb begin
    out      = '0;
    out[sel] = in;
  end
endmodule
