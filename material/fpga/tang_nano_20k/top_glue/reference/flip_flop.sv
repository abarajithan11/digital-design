`timescale 1ns / 1ps
`default_nettype none

// flip_flop: d=S1 -> q=LED0, sampled on clk
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

  logic o;
  flip_flop u_dut (
    .clk (clk),
    .rstn(~rst),
    .i   (btn[0]),
    .o   (o)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led[0] = o;
  end
endmodule
