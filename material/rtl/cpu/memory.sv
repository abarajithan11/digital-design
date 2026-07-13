module memory #(
  parameter int ADDR_W = 8   // depth = 2**ADDR_W rows (default 256, the CPU's full 8-bit space)
)(
  input  logic        clk,
  input  logic [7:0]  addr,
  input  logic [15:0] wdata,
  input  logic        wen,
  output logic [15:0] rdata
);
  logic [15:0] mem [2**ADDR_W];

  // Only the low ADDR_W address bits select a row; a smaller memory (e.g. on
  // FPGA, to save area) simply ignores the upper bits.
  wire [ADDR_W-1:0] a = addr[ADDR_W-1:0];

  always_ff @(posedge clk)
    if (wen) mem[a] <= wdata;

  always_comb rdata = mem[a];

endmodule
