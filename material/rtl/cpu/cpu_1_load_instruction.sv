module cpu_1_load_instruction (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction
);
  always_ff @(posedge clk)
    if (reset) pc <= '0;
    else       pc <= pc + 1;
endmodule
