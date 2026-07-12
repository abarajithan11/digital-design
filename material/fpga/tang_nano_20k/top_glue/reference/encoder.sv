`timescale 1ns / 1ps
`default_nettype none

// encoder: one-hot = 1<<{S2,S1};  encoded index -> LED[2:0]
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

  logic [2:0] code;
  encoder #(
    .N(3)
  ) u_dut (
    .onehot(8'b1 << {1'b0, btn}),
    .code  (code)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led[2:0] = code;
  end
endmodule
