`timescale 1ns / 1ps
`default_nettype none

// mux: sel=S1 picks 0x0F or 0xF0;  out[5:0] -> LEDs
module board_glue (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] btn,
    output logic[5:0] led,
    input  wire       rx,
    output logic      tx,
    output logic[5:0] gpio_o,
    output logic[5:0] gpio_oe,
    input  wire [5:0] gpio_i
);

  logic [7:0] out;
  mux #(
    .W(8)
  ) u_dut (
    .a  (8'h0F),
    .b  (8'hF0),
    .sel(btn[0]),
    .out(out)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led = out[5:0];
  end
endmodule
