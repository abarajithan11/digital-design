module cpu_2_load_data_into_registers (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction,

  output logic [7:0]  addr,      // --- new
  input  logic [15:0] read_data  // --- new
);
  enum logic [3:0] {NOP, LOAD} opcode; // --- new
  logic [ 3:0] i_reg_a;                // --- new
  logic [15:0][15:0] regs;             // --- new
  logic [15:0] alu_out;                // --- new
  logic reg_wen;                       // --- new

  always_comb begin                        // --- new
    {addr, i_reg_a, opcode} = instruction; // --- new

    alu_out = '0;                          // --- new
    reg_wen = 1'b1;                        // --- new
    case (opcode)                          // --- new
      LOAD   : alu_out = read_data;        // --- new
      default: reg_wen = 1'b0;             // --- new
    endcase                                // --- new
  end                                      // --- new

  always_ff @(posedge clk)
    if (reset) {pc, regs} <= '0;             // --- new: regs
    else begin
      pc <= pc + 1;
      if (reg_wen) regs[i_reg_a] <= alu_out; // --- new
    end
endmodule
