`timescale 1ns / 1ps
`default_nettype none

// up_counter: incr=S1;  count[5:0] -> LEDs, also mirrored to gpio[5:0]
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

  logic [7:0] count;
  logic       btn_prev, incr;

  always_ff @(posedge clk) begin
    if (rst) btn_prev <= 1'b0;
    else     btn_prev <= btn[0];
  end
  always_comb incr = btn[0] && !btn_prev;

  up_counter #(
    .WIDTH(8)
  ) u_dut (
    .clk  (clk),
    .rstn (~rst),
    .incr (incr),
    .count(count)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led     = count[5:0];
    gpio_oe = '1;
    gpio_o  = count[5:0];
  end
endmodule
