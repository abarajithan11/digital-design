`timescale 1ns/1ps

module uart_tx #(
  parameter CLOCKS_PER_PULSE = 4,
            BITS_PER_WORD    = 8,
            PACKET_SIZE      = BITS_PER_WORD+5,
            W_OUT            = 24
  )(
    input  logic clk, rstn, s_valid,
    input  logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] s_data,
    output logic tx, s_ready
  );
  localparam NUM_WORDS = W_OUT/BITS_PER_WORD;
  localparam END_BITS  = PACKET_SIZE-BITS_PER_WORD-1;
  localparam NUM_BITS  = NUM_WORDS*PACKET_SIZE;

  logic [NUM_BITS-1:0] m_packets;
  logic [NUM_WORDS-1:0][PACKET_SIZE-1:0] s_packets;
  logic [$clog2(CLOCKS_PER_PULSE)-1:0] c, c_max;
  logic [$clog2(NUM_BITS)-1:0]         p, p_max;
  logic c_en, c_clr, c_last, c_last_clk;
  logic p_en, p_clr, p_last, p_last_clk;

  enum {IDLE, SEND} state;

  down_counter #(.WIDTH($bits(c))) c_ctr
    (.clk(clk), .rstn(rstn), .en(c_en), .clear(c_clr), .max_in(c_max), .count(c), .last(c_last), .last_clk(c_last_clk));
  down_counter #(.WIDTH($bits(p))) p_ctr
    (.clk(clk), .rstn(rstn), .en(p_en), .clear(p_clr), .max_in(p_max), .count(p), .last(p_last), .last_clk(p_last_clk));

  genvar n;
  for (n=0; n<NUM_WORDS; n=n+1)
    always_comb s_packets[n] = {{END_BITS{1'b1}}, s_data[n], 1'b0};

  always_comb begin
    tx      = m_packets[0];
    s_ready = state == IDLE;

    c_clr = state == IDLE && s_valid; 
    p_clr = state == IDLE && s_valid;
    c_en  = state == SEND;
    p_en  = c_last_clk;
    c_max = $bits(c)'(CLOCKS_PER_PULSE-1);
    p_max = $bits(p)'(NUM_BITS-1);
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state     <= IDLE;
      m_packets <= '1;
    end else if (state == IDLE && s_valid) begin
      state     <= SEND;
      m_packets <= s_packets;
    end else if (state == SEND && c_last_clk) begin
      if (p_last_clk) begin
        state     <= IDLE;
        m_packets <= '1;
      end else begin
        m_packets <= m_packets >> 1;
      end
    end
  end
endmodule