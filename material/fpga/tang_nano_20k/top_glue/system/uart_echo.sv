`timescale 1ns / 1ps
`default_nettype none

// uart_echo at 2 Mbaud.  board_top supplies 54 MHz, so
// CLKS_PER_BIT = 54e6/2e6 = 27.  The design drives tx; the board's onboard
// bridge runs the UART at 2 Mbaud.  Host: python3 py/uart_echo.py.
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

  uart_echo #(
    .CLKS_PER_BIT  (27),
    .PACKET_SIZE_TX(10),
    .W_OUT         (8)
  ) u_dut (
    .clk (clk),
    .rstn(~rst),
    .rx  (rx),
    .tx  (tx)
  );

  always_comb begin
    {led, gpio_o, gpio_oe} = '0;
  end
endmodule
