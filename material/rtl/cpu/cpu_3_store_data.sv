`timescale 1ns/1ps

module cpu_3_store_data (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  imem_addr,
  input  logic [15:0] imem_rdata,

  output logic [7:0]  dmem_addr,
  input  logic [15:0] dmem_rdata,
  output logic [15:0] dmem_wdata, // --- new
  output logic        dmem_wen    // --- new
);
  logic [7:0] pc, addr;
  enum logic [3:0] {LOAD, STORE} opcode;
  logic  [3:0] i_reg;
  logic [15:0] regs [16];

  always_comb begin
    imem_addr                 = pc;
    {addr        , i_reg, opcode} = imem_rdata;

    dmem_addr  = addr;
    dmem_wdata = regs[i_reg]; // --- new
    dmem_wen   = opcode == STORE; // --- new
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
      for (int i = 0; i < 16; i++) regs[i] <= '0;
    end else begin
      pc   <= pc + 1'b1;

      case (opcode)
        LOAD: regs[i_reg] <= dmem_rdata;
        default: ;
      endcase
    end
  end

endmodule
