`timescale 1ns / 1ps
`default_nettype none

// not_gate: i=S1 -> o=LED0
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
  not_gate u_dut (
    .i(btn[0]),
    .o(o)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led[0] = o;
  end
endmodule
