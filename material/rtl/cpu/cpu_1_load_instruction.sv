`timescale 1ns/1ps

module cpu_1_load_instruction (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  imem_addr, // program counter
  input  logic [15:0] imem_rdata // this is our instruction!
);
  logic [7:0] pc;

  always_comb begin
    imem_addr = pc;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
    end else begin
      pc   <= pc + 1'b1;
    end
  end

endmodule
