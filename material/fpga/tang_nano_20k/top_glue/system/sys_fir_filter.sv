`timescale 1ns / 1ps
`default_nettype none

// sys_fir_filter live audio at 2 Mbaud. board_top's 54 MHz -> CLKS_PER_BIT=27.
// Needs data/coef.svh on the include path (material/ is added by fpga.mk).
// Host: python3 py/fir_audio.py.
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

  sys_fir_filter #(
    .CLKS_PER_BIT  (27),
    .PACKET_SIZE_TX(10)
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
