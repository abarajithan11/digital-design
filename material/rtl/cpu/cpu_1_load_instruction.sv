module cpu_1_load_instruction (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction
);
  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
    end else begin
      pc   <= pc + 1'b1;
    end
  end

endmodule
