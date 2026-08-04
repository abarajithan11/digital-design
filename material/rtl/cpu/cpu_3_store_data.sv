module cpu_3_store_data (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction,

  output logic [7:0]  addr,
  input  logic [15:0] read_data,
  output logic [15:0] write_data, // --- new
  output logic        dmem_wen    // --- new
);
  enum logic [3:0] {NOP, LOAD, STORE} opcode; // --- new
  logic [ 3:0] i_reg_a;
  logic [15:0][15:0] regs;
  logic [15:0] alu_out;
  logic reg_wen;

  always_comb begin
    {addr, i_reg_a, opcode} = instruction;

    write_data = regs[i_reg_a];   // --- new
    dmem_wen   = opcode == STORE; // --- new

    alu_out = '0;
    reg_wen = 1'b1;
    case (opcode)
      LOAD   : alu_out = read_data;
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
