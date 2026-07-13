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

  logic y;
  xor_gate u_dut (
    .a(btn[0]),
    .b(btn[1]),
    .y(y)
  );

  always_comb begin
    {led, tx, gpio_o, gpio_oe} = '0;
    led[0] = y;
  end
endmodule
