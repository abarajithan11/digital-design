module uart_rx #(
  parameter CLKS_PER_BIT    = 4,
            BITS_PER_WORD   = 8,
            W_OUT           = 24,
            PACKET_GAP_CLKS = 100
)(
  input  logic clk, rstn, rx,
  output logic m_valid,
  output logic [W_OUT-1:0] m_data
);
  localparam NUM_WORDS = W_OUT / BITS_PER_WORD;
  localparam CW_CLK    = $clog2(CLKS_PER_BIT);
  localparam CW_BIT    = $clog2(BITS_PER_WORD);
  localparam CW_WORD   = $clog2(NUM_WORDS) == 0 ? 1 : $clog2(NUM_WORDS);
  localparam CW_GAP    = $clog2(PACKET_GAP_CLKS+1);

  typedef enum logic [1:0] {IDLE, START, DATA, END} state_t;
  state_t state;

  logic [CW_CLK -1:0] c_clocks;
  logic [CW_BIT -1:0] c_bits;
  logic [CW_WORD-1:0] c_words;
  logic [CW_GAP -1:0] c_gap;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state    <= IDLE;
      {c_clocks, c_bits, c_words, c_gap} <= '0;
      {m_valid, m_data}  <= '0;
    end else begin
      m_valid <= 1'b0;
      case (state)
        IDLE:   begin
                  c_clocks <= '0;
                  c_bits   <= '0;
                  if (!rx) begin
                    state <= START;
                    c_gap <= '0;
                    if (c_gap >= CW_GAP'(PACKET_GAP_CLKS))
                      c_words <= '0;
                  end else if (c_gap < CW_GAP'(PACKET_GAP_CLKS))
                    c_gap <= c_gap + 1'b1;
                end

        START:  begin
                  c_gap <= '0;
                  if (c_clocks == CW_CLK'(CLKS_PER_BIT/2 - 1)) begin
                    state    <= DATA;
                    c_clocks <= '0;
                  end else c_clocks <= c_clocks + 1'b1;
                end

        DATA:   if (c_clocks == CW_CLK'(CLKS_PER_BIT - 1)) begin
                  c_clocks <= '0;
                  m_data   <= {rx, m_data[W_OUT-1:1]};

                  if (c_bits == CW_BIT'(BITS_PER_WORD - 1)) begin
                    state  <= END;
                    c_bits <= '0;

                    if (c_words == CW_WORD'(NUM_WORDS - 1)) begin
                      m_valid <= 1'b1;
                      c_words <= '0;

                    end else c_words <= c_words + 1'b1;
                  end else c_bits <= c_bits + 1'b1;
                end else c_clocks <= c_clocks + 1'b1;

        END:    if (c_clocks == CW_CLK'(CLKS_PER_BIT - 1)) begin
                  state    <= IDLE;
                  c_clocks <= '0;
                end else c_clocks <= c_clocks + 1'b1;

        default: state <= IDLE;
      endcase
    end
  end
endmodule
