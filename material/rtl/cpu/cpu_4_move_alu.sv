module cpu_4_move_alu (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction,

  output logic [7:0]  addr,
  input  logic [15:0] read_data,
  output logic [15:0] write_data,
  output logic        dmem_wen
);
  enum logic [3:0] {NOP, LOAD, STORE, MOVE, ADD, SUB, MUL} opcode; // --- new
  logic [ 3:0] i_reg_a, i_reg_b, i_reg_c; // --- new
  logic [15:0][15:0] regs;
  logic [15:0] reg_b, reg_c, alu_out;     // --- new
  logic reg_wen;

  always_comb begin
    {addr,             i_reg_a, opcode} = instruction;
    {i_reg_c, i_reg_b, i_reg_a, opcode} = instruction; // --- new

    write_data = regs[i_reg_a];
    dmem_wen   = opcode == STORE;
    reg_b      = regs[i_reg_b];         // --- new
    reg_c      = regs[i_reg_c];         // --- new

    alu_out = '0;
    reg_wen = 1'b1;
    case (opcode)
      LOAD   : alu_out = read_data;
      MOVE   : alu_out = reg_b;         // --- new
      ADD    : alu_out = reg_b + reg_c; // --- new
      SUB    : alu_out = reg_b - reg_c; // --- new
      MUL    : alu_out = reg_b * reg_c; // --- new
      default: reg_wen = 1'b0;
    endcase
  end

  always_ff @(posedge clk)
    if (reset) {pc, regs} <= '0;
    else begin
      pc <= pc + 1;
      if (reg_wen) regs[i_reg_a] <= alu_out;
    end
endmodule
