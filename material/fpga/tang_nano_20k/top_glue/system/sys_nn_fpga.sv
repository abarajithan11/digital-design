`timescale 1ns / 1ps
`default_nettype none

// sys_nn at 2 Mbaud. board_top supplies a 54 MHz clock, so
// CLKS_PER_BIT = 54e6 / 2e6 = 27.
// Host: python3 material/py/fpga_nn.py or material/py/fpga_nn_camera.py.
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

  sys_nn #(
    .CLKS_PER_BIT(27)
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

`default_nettype wire
