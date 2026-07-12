`timescale 1ns / 1ps
`default_nettype none

// decoder: code = {0,S2,S1};  one-hot -> LEDs
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

  logic [7:0] onehot;
  decoder #(
    .N(3)
  ) u_dut (
    .code  ({1'b0, btn}),
    .onehot(onehot)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led = onehot[5:0];
  end
endmodule
