`timescale 1ns / 1ps
`default_nettype none

// ============================================================================
//  board_glue - the ONE file that changes per design.
//
//  Copy this, rename to <design>.sv, and wire your module to the clean,
//  active-high signals board_top provides:
//     clk         system clock          btn[1:0]  1 = pressed (S1, S2)
//     rst          1 = reset asserted    led[5:0]  drive 1 to light an LED
//     rx / tx      serial
//     gpio_o[i]    value to drive        gpio_oe[i] 1 = drive, 0 = input (high-Z)
//     gpio_i[i]    value read on the pin
//
//  Pattern (keeps a single driver per output, so it stays error-free):
//    1) instantiate your design
//    2) in the always_comb, FIRST zero everything: {led,tx,gpio_o,gpio_oe}='0
//    3) then connect only what you use - last assignment wins.
//  Map an active-low reset with .rstn(~rst).
// ============================================================================
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

  // 1) Instantiate your design:
  // logic result;
  // my_design #(
  //   .W(8)
  // ) u_dut (
  //   .a  (btn[0]),
  //   .out(result)
  // );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;     // all off / high-Z by default
    // 2) Connect what you use:
    // led[0]     = result;
    // gpio_oe[0] = 1'b1;  gpio_o[0] = result;   // drive gpio[0]
  end
endmodule
