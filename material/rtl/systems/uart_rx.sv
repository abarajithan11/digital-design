`timescale 1ns / 1ps

module uart_rx #(
  parameter CLKS_PER_BIT  = 4,
            BITS_PER_WORD = 8,
            W_OUT         = 24
)(
  input  logic clk, rstn, rx,
  output logic m_valid,
  output logic [W_OUT-1:0] m_data
);
  localparam NUM_WORDS = W_OUT/BITS_PER_WORD;
  localparam BITS_WORDS = $clog2(NUM_WORDS) == 0 ? 1 : $clog2(NUM_WORDS);

  logic bw_clr;
  logic [$clog2(CLKS_PER_BIT) -1:0] c, c_max;
  logic [$clog2(BITS_PER_WORD)-1:0] b, b_max;
  logic [BITS_WORDS-1:0]            w, w_max;
  logic c_en, c_clr, c_last, c_last_clk;
  logic b_en, b_clr, b_last, b_last_clk;
  logic w_en, w_clr, w_last, w_last_clk;

  enum {IDLE, START, DATA, END} state;

  down_counter #(.WIDTH($bits(c))) c_ctr
    (.clk(clk), .rstn(rstn), .en(c_en), .clear(c_clr), .max_in(c_max), .count(c), .last(c_last), .last_clk(c_last_clk));
  down_counter #(.WIDTH($bits(b))) b_ctr
    (.clk(clk), .rstn(rstn), .en(b_en), .clear(b_clr), .max_in(b_max), .count(b), .last(b_last), .last_clk(b_last_clk));
  down_counter #(.WIDTH($bits(w))) w_ctr
    (.clk(clk), .rstn(rstn), .en(w_en), .clear(w_clr), .max_in(w_max), .count(w), .last(w_last), .last_clk(w_last_clk));

  always_comb begin
    c_clr = 0; 
    b_clr = bw_clr; 
    w_clr = bw_clr;
    c_en = state != IDLE;
    b_en = c_last_clk;
    w_en = b_last_clk;
    c_max = $bits(c)'(CLKS_PER_BIT-1);
    b_max = $bits(b)'(BITS_PER_WORD-1);
    w_max = $bits(w)'(NUM_WORDS-1);

    if (state == IDLE && !rx) begin
      c_clr = 1;
      c_max = $bits(c)'(CLKS_PER_BIT/2-1);
    end else if (state == START && c_last) begin
      c_clr = 1;
      b_clr = 1;
      c_max = $bits(c)'(CLKS_PER_BIT-1);
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      m_valid <= 0;
      m_data  <= '0;
      bw_clr  <= 1;
      state   <= IDLE;
    end else begin
      m_valid <= 0;
      if (bw_clr) bw_clr <= 0;
      case (state)
        IDLE :  if (!rx)    state <= START;
        START:  if (c_last) state <= DATA;
        DATA :  if (c_last_clk) begin
                  m_data <= {rx, m_data[W_OUT-1:1]};
                  if (b_last_clk) begin
                    state <= END;
                    m_valid <= w_last_clk;
                  end
                end
        END  :  if (c_last_clk) state <= IDLE;
      endcase
    end
  end
endmodule