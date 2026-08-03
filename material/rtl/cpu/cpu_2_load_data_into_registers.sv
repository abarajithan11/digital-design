module cpu_2_load_data_into_registers (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction,

  output logic [7:0]  dmem_addr,  // --- new
  input  logic [15:0] dmem_rdata // --- new
);
  enum logic [3:0] {NOP, LOAD} opcode; // --- new
  logic [ 3:0] i_reg_a; // --- new
  logic [15:0] regs [16]; // --- new

  always_comb begin
    {dmem_addr, i_reg_a, opcode} = instruction; // --- new
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      pc   <= '0;
      for (int i = 0; i < 16; i++) regs[i] <= '0;  // --- new
    end else begin
      pc   <= pc + 1'b1;

      case (opcode) // --- new
        LOAD: regs[i_reg_a] <= dmem_rdata; // --- new
        default: ;
      endcase
    end
  end

endmodule
