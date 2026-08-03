module cpu (
  input  logic        clk, reset,
  output logic [7 :0] pc,          dmem_addr,
  input  logic [15:0] instruction, dmem_rdata,
  output logic [15:0] dmem_wdata,
  output logic        dmem_wen
);
  enum logic [3:0] {NOP, LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} opcode;
  logic [ 3:0] i_reg_a, i_reg_b, i_reg_c;
  logic [15:0][15:0] regs;
  logic [15:0] reg_b, reg_c;

  always_comb begin
    {dmem_addr,        i_reg_a, opcode} = instruction;
    {i_reg_c, i_reg_b, i_reg_a, opcode} = instruction;

    dmem_wdata = regs[i_reg_a];
    dmem_wen   = opcode == STORE;

    reg_b      = regs[i_reg_b];
    reg_c      = regs[i_reg_c];
  end

  always_ff @(posedge clk)
    if (reset) {pc, regs} <= '0;
    else begin
      pc   <= pc + 1'b1;

      case (opcode)
        LOAD: regs[i_reg_a] <= dmem_rdata;
        MOVE: regs[i_reg_a] <= reg_b;
        ADD : regs[i_reg_a] <= reg_b + reg_c;
        SUB : regs[i_reg_a] <= reg_b - reg_c;
        MUL : regs[i_reg_a] <= reg_b * reg_c;
        JNZ : if (regs[i_reg_a] != '0) pc <= dmem_addr;
        default: ;
      endcase
    end
endmodule
