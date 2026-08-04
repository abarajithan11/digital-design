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
  logic [ 3:0] i_reg_a, i_bus_b, i_bus_c;    // --- new
  logic [15:0][15:0] regs;
  logic [15:0] bus_a, bus_b, bus_c, alu_out; // --- new: bus_b, bus_c
  logic reg_wen;

  always_comb begin
    {addr,             i_reg_a, opcode} = instruction;
    {i_bus_c, i_bus_b, i_reg_a, opcode} = instruction; // --- new

    bus_a      = regs[i_reg_a];
    bus_b      = regs[i_bus_b];       // --- new
    bus_c      = regs[i_bus_c];       // --- new

    write_data = bus_a;
    dmem_wen   = opcode == STORE;

    alu_out = '0;
    reg_wen = 1'b1;
    case (opcode)
      LOAD   : alu_out = read_data;
      MOVE   : alu_out = bus_b;         // --- new
      ADD    : alu_out = bus_b + bus_c; // --- new
      SUB    : alu_out = bus_b - bus_c; // --- new
      MUL    : alu_out = bus_b * bus_c; // --- new
      default: reg_wen = 1'b0;
    endcase
  end

  always_ff @(posedge clk)
    if (reset) begin
      pc   <= '0;
      regs <= '0;
    end else begin
      pc <= pc + 1;
      if (reg_wen) regs[i_reg_a] <= alu_out;
    end
endmodule
