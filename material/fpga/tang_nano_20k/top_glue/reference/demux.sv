`timescale 1ns / 1ps
`default_nettype none

// demux: routes constant 3'b111 to lane sel={S2,S1};  lanes 0,1 -> LEDs
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

  logic [3:0][2:0] out;
  demux #(
    .W    (3),
    .W_SEL(2)
  ) u_dut (
    .in (3'b111),
    .sel(btn),
    .out(out)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led = out[1:0];
  end
endmodule
