module register_file #(
  parameter int  W_DATA = 8,
  parameter int  N_REGS = 6,
  localparam int W_ADDR = $clog2(N_REGS)
)(
  input  logic clk, rstn,
  input  logic [W_ADDR-1:0] raddr,
  input  logic [W_ADDR-1:0] waddr,
  input  logic              wen,
  input  logic [W_DATA-1:0] wdata,
  output logic [W_DATA-1:0] rdata
);
  logic [W_DATA-1:0] mem [N_REGS];

  always_ff @(posedge clk)
    if (!rstn)
      for (int i=0; i<N_REGS; i++) mem[i] <= '0;
    else if (wen)
      mem[waddr] <= wdata;

  always_comb rdata = mem[raddr];
endmodule
