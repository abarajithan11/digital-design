`timescale 1ns/1ps

module flip_flop (
  input  logic clk,
  input  logic rstn,
  input  logic i,
  output logic o
);
  always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) o <= 0;
    else      o <= i;
  end
endmodule