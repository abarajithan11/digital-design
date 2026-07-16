`timescale 1ns / 1ps
`default_nettype none

// ============================================================================
//  board_glue for the CPU (CSE140).
//
//  Puts the whole toy computer on the Tang Nano 20K: instruction RAM, data RAM,
//  the CPU, and a UART loader/dumper.  Flow (a tiny state machine):
//
//    LOAD  the host streams the program image in over UART (see
//          py/program_cpu.py): all MEM_ROWS instruction words, then all
//          MEM_ROWS data words.  The UART is 16 bits wide, so uart_rx/uart_tx
//          pack and unpack the two bytes of each word for us (low byte first) -
//          the loader just writes one whole word per received beat.
//    WAIT  hold the CPU in reset until S1 (btn[0]) is pressed.
//    RUN   release reset and clock the CPU at ~1 Hz (a divided clock).  The LEDs
//          show, live:  S2 (btn[1]) up  -> low 6 bits of dmem[WATCH_ADDR];
//                       S2 down         -> the 4-bit opcode, with the top LED
//                                          lit so you can see it stepping.
//          After RUN_CYCLES CPU steps we stop.
//    DUMP  send the whole data RAM back out over UART, one word per row.
//
//  The two RAMs run on the fast 54 MHz clock; only the CPU runs on the slow
//  1 Hz clock.  Because the RAMs read combinationally and the CPU's outputs are
//  stable for a whole slow period, the fast-clock writes are simply repeated
//  (idempotent) - no clock-domain-crossing logic is needed for the memories.
//
//  All counting reuses the course up_counter / down_counter (same building
//  blocks as uart_rx / uart_tx).
// ============================================================================
module board_glue #(
    parameter int ADDR_W       = 6,           // RAM depth = 2**ADDR_W rows (area knob)
    parameter int CLKS_PER_BIT = 27,          // 54 MHz / 2 Mbaud
    parameter int PACKET_SIZE  = 10,          // start + 8 data + stop (+ padding)
    parameter int CPU_HALF     = 27_000_000,  // fast clks per half of the CPU clock
                                              // (-> 1 Hz from board_top's 54 MHz)
    parameter int WATCH_ADDR   = 4,           // dmem row shown on the LEDs
    parameter int RUN_CYCLES   = (1 << ADDR_W)// CPU steps to run before dumping
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] btn,
    output logic[5:0] led,
    input  wire       rx,
    output logic      tx,
    output logic[5:0] gpio_o,
    output logic[5:0] gpio_oe,
    input  wire [5:0] gpio_i
);
  localparam int MEM_ROWS   = 1 << ADDR_W;
  localparam int LOAD_WORDS = 2 * MEM_ROWS;    // all imem words, then all dmem words

  // Sized, unsigned terminal counts so comparisons/ports stay warning-clean.
  localparam logic [ADDR_W:0]                 LOAD_LAST = (ADDR_W+1)'(LOAD_WORDS-1);
  localparam logic [$clog2(CPU_HALF)-1:0]     DIV_MAX   = ($clog2(CPU_HALF))'(CPU_HALF-1);
  localparam logic [$clog2(RUN_CYCLES+1)-1:0] RUN_MAX   = ($clog2(RUN_CYCLES+1))'(RUN_CYCLES);
  localparam logic [ADDR_W-1:0]               DUMP_LAST = (ADDR_W)'(MEM_ROWS-1);
  localparam logic [ADDR_W-1:0]               WATCH_ROW = (ADDR_W)'(WATCH_ADDR);

  wire rstn = ~rst;

  typedef enum logic [2:0] {S_LOAD, S_WAIT, S_RUN, S_DUMP, S_DONE} state_t;
  state_t state;

  // ==========================================================================
  //  UART: 16-bit words (uart_rx/uart_tx handle the low/high byte packing)
  // ==========================================================================
  wire         rx_valid;
  wire  [15:0] rx_word;
  wire         tx_ready;
  logic        tx_valid;
  logic [15:0] tx_word;

  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT), .BITS_PER_WORD(8), .W_OUT(16)) u_rx (
    .clk(clk), .rstn(rstn), .rx(rx), .m_valid(rx_valid), .m_data(rx_word)
  );

  uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT), .BITS_PER_WORD(8),
            .PACKET_SIZE(PACKET_SIZE), .W_OUT(16)) u_tx (
    .clk(clk), .rstn(rstn), .s_valid(tx_valid), .s_data(tx_word),
    .tx(tx), .s_ready(tx_ready)
  );

  // ==========================================================================
  //  Loader: first MEM_ROWS words fill imem, the next MEM_ROWS fill dmem
  // ==========================================================================
  wire ld_beat = rx_valid && state == S_LOAD;
  logic [ADDR_W:0] ld_idx;                     // 0 .. 2*MEM_ROWS-1
  up_counter #(.WIDTH(ADDR_W+1)) u_ld_ctr (
    .clk(clk), .rstn(rstn), .incr(ld_beat), .count(ld_idx)
  );
  wire              ld_is_dmem = ld_idx[ADDR_W];        // second half -> dmem
  wire [ADDR_W-1:0] ld_row     = ld_idx[ADDR_W-1:0];
  wire              ld_imem_we = ld_beat && !ld_is_dmem;
  wire              ld_dmem_we = ld_beat &&  ld_is_dmem;
  wire              ld_done    = ld_beat && ld_idx == LOAD_LAST;

  // ==========================================================================
  //  The CPU and its ~1 Hz clock (a down_counter divides the 54 MHz clock)
  // ==========================================================================
  wire [7:0]  imem_addr, dmem_addr;
  wire [15:0] imem_rdata, dmem_rdata, dmem_wdata;
  wire        dmem_wen;

  wire  div_wrap;                              // pulses every CPU_HALF fast clks (while RUN)
  logic cpu_clk;
  down_counter #(.WIDTH($clog2(CPU_HALF))) u_div (
    .clk(clk), .rstn(rstn),
    .en(state == S_RUN), .clear(state != S_RUN),
    .max_in(DIV_MAX),
    .count(), .last(), .last_clk(div_wrap)
  );
  always_ff @(posedge clk)
    if (rst)            cpu_clk <= 1'b0;
    else if (div_wrap)  cpu_clk <= ~cpu_clk;

  wire cpu_reset = state != S_RUN;             // held in reset except while running
  wire cpu_step  = div_wrap & ~cpu_clk;        // one fast pulse per rising CPU edge

  logic [$clog2(RUN_CYCLES+1)-1:0] run_cnt;
  up_counter #(.WIDTH($clog2(RUN_CYCLES+1))) u_run_ctr (
    .clk(clk), .rstn(rstn), .incr(cpu_step), .count(run_cnt)
  );

  cpu u_cpu (
    .clk(cpu_clk), .reset(cpu_reset),
    .imem_addr(imem_addr), .dmem_addr(dmem_addr),
    .imem_rdata(imem_rdata), .dmem_rdata(dmem_rdata),
    .dmem_wdata(dmem_wdata), .dmem_wen(dmem_wen)
  );

  // ==========================================================================
  //  Dump reader: one dmem word per row, straight out the UART
  // ==========================================================================
  wire dump_beat = state == S_DUMP && tx_valid && tx_ready;   // a word was accepted
  logic [ADDR_W-1:0] dump_row;
  up_counter #(.WIDTH(ADDR_W)) u_dump_ctr (
    .clk(clk), .rstn(rstn), .incr(dump_beat), .count(dump_row)
  );
  wire dump_done = dump_beat && dump_row == DUMP_LAST;

  // ==========================================================================
  //  Memory address / write muxing (one shared port each)
  // ==========================================================================
  wire [7:0] imem_paddr = (state == S_LOAD) ? {{(8-ADDR_W){1'b0}}, ld_row} : imem_addr;

  memory #(.ADDR_W(ADDR_W)) u_imem (
    .clk(clk), .addr(imem_paddr), .wdata(rx_word), .wen(ld_imem_we), .rdata(imem_rdata)
  );

  logic [7:0]  dmem_paddr;
  logic [15:0] dmem_pwdata;
  logic        dmem_pwen;
  always_comb begin
    case (state)
      S_LOAD:  begin dmem_paddr = {{(8-ADDR_W){1'b0}}, ld_row};   dmem_pwdata = rx_word;    dmem_pwen = ld_dmem_we; end
      S_RUN:   begin dmem_paddr = dmem_addr;                      dmem_pwdata = dmem_wdata; dmem_pwen = dmem_wen;   end
      S_DUMP:  begin dmem_paddr = {{(8-ADDR_W){1'b0}}, dump_row}; dmem_pwdata = '0;         dmem_pwen = 1'b0;       end
      default: begin dmem_paddr = '0;                             dmem_pwdata = '0;         dmem_pwen = 1'b0;       end
    endcase
  end

  memory #(.ADDR_W(ADDR_W)) u_dmem (
    .clk(clk), .addr(dmem_paddr), .wdata(dmem_pwdata), .wen(dmem_pwen), .rdata(dmem_rdata)
  );

  // Snoop writes to WATCH_ADDR so the LEDs can show it without stealing the
  // dmem read port (which the CPU/dumper are using).
  logic [15:0] watch_val;
  always_ff @(posedge clk)
    if (rst)                                                               watch_val <= '0;
    else if (dmem_pwen && dmem_paddr[ADDR_W-1:0] == WATCH_ROW) watch_val <= dmem_pwdata;

  // Dump drives the UART; otherwise it's idle.
  always_comb begin
    tx_valid = state == S_DUMP;
    tx_word  = dmem_rdata;
  end

  // ==========================================================================
  //  State transitions
  // ==========================================================================
  always_ff @(posedge clk)
    if (rst) state <= S_LOAD;
    else case (state)
      S_LOAD:  if (ld_done)  state <= S_WAIT;
      S_WAIT:  if (btn[0])   state <= S_RUN;
      S_RUN:   if (run_cnt == RUN_MAX) state <= S_DUMP;
      S_DUMP:  if (dump_done) state <= S_DONE;
      S_DONE:  ;
      default: state <= S_LOAD;
    endcase

  // ==========================================================================
  //  LEDs
  // ==========================================================================
  wire [3:0] opcode = imem_rdata[3:0];         // the instruction currently fetched
  always_comb begin
    {led, gpio_o, gpio_oe} = '0;
    if (btn[1]) led = watch_val[5:0];          // S2 held: low 6 bits of dmem[WATCH_ADDR]
    else        led = {1'b1, 1'b0, opcode};    // else: opcode, top LED lit = CPU stepping
  end
endmodule
`default_nettype wire
