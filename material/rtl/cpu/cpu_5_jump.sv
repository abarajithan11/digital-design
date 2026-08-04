module cpu_5_jump (
  input  logic        clk,
  input  logic        reset,

  output logic [7:0]  pc,
  input  logic [15:0] instruction,

  output logic [7:0]  addr,
  input  logic [15:0] read_data,
  output logic [15:0] write_data,
  output logic        dmem_wen
);
  enum logic [3:0] {NOP, LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ} opcode; // --- new
  logic [ 3:0] i_reg_a, i_bus_b, i_bus_c;
  logic [15:0][15:0] regs;
  logic [15:0] bus_a, bus_b, bus_c, alu_out;
  logic reg_wen, jump; // --- new

  always_comb begin
    {addr,             i_reg_a, opcode} = instruction;
    {i_bus_c, i_bus_b, i_reg_a, opcode} = instruction;

    bus_a      = regs[i_reg_a];
    bus_b      = regs[i_bus_b];
    bus_c      = regs[i_bus_c];

    write_data = bus_a;
    dmem_wen   = opcode == STORE;
    jump       = (opcode == JNZ) && (bus_a != '0); // --- new

    alu_out = '0;
    reg_wen = 1'b1;
    case (opcode)
      LOAD   : alu_out = read_data;
      MOVE   : alu_out = bus_b;
      ADD    : alu_out = bus_b + bus_c;
      SUB    : alu_out = bus_b - bus_c;
      MUL    : alu_out = bus_b * bus_c;
      default: reg_wen = 1'b0;
    endcase
  end

  always_ff @(posedge clk)
    if (reset) begin
      pc   <= '0;
      regs <= '0;
    end else begin
      pc <= jump ? addr : pc + 1; // --- new
      if (reg_wen) regs[i_reg_a] <= alu_out;
    end
endmodule
