`timescale 1ns / 1ps
`default_nettype none

// full_adder: a=S1, b=S2, ci=0;  sum->LED0, carry->LED1
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

  logic sum, co;
  full_adder u_dut (
    .a  (btn[0]),
    .b  (btn[1]),
    .ci (1'b0),
    .sum(sum),
    .co (co)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led[0] = sum;
    led[1] = co;
  end
endmodule
