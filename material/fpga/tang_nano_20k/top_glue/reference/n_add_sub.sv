`timescale 1ns / 1ps
`default_nettype none

// n_add_sub: sub=S1 toggles 50-/+20;  result[5:0] -> LEDs
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

  logic [7:0] S;
  logic       co;
  n_add_sub #(
    .N(8)
  ) u_dut (
    .A  (8'd50),
    .B  (8'd20),
    .sub(btn[0]),
    .S  (S),
    .co (co)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led = S[5:0];
  end
endmodule
