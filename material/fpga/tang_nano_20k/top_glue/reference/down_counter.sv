`timescale 1ns / 1ps
`default_nettype none

// down_counter: en=S1, counts down from 63;  count[5:0] -> LEDs, last -> gpio[0]
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
  logic       last, last_clk, btn_prev, en;

  always_ff @(posedge clk) begin
    if (rst) btn_prev <= 1'b0;
    else     btn_prev <= btn[0];
  end
  always_comb en = btn[0] && !btn_prev;

  down_counter #(
    .WIDTH(8)
  ) u_dut (
    .clk     (clk),
    .rstn    (~rst),
    .en      (en),
    .clear   (1'b0),
    .max_in  (8'd63),
    .count   (count),
    .last    (last),
    .last_clk(last_clk)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led        = count[5:0];
    gpio_oe[0] = 1'b1;
    gpio_o[0]  = last;
  end
endmodule
