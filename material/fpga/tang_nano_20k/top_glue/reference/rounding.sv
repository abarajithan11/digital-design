`timescale 1ns / 1ps
`default_nettype none

// rounding: value 0x6B, mode={S2,S1};  result[5:0] -> LEDs
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

  logic [7:0] f;
  rounding #(
    .W    (8),
    .SHIFT(2)
  ) u_dut (
    .a   (8'h6B),
    .mode(btn),
    .f   (f)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led = f[5:0];
  end
endmodule
