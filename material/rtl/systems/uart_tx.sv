module uart_tx #(
  parameter CLKS_PER_BIT  = 4,
            BITS_PER_WORD = 8,
            PACKET_SIZE   = BITS_PER_WORD+5,
            W_OUT         = 24
  )(
    input  logic clk, rstn, s_valid,
    input  logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] s_data,
    output logic tx, s_ready
  );
  localparam NUM_WORDS = W_OUT / BITS_PER_WORD;
  localparam END_BITS  = PACKET_SIZE - BITS_PER_WORD - 1;
  localparam NUM_BITS  = NUM_WORDS * PACKET_SIZE;
  localparam CW_CLK    = $clog2(CLKS_PER_BIT);
  localparam CW_BIT    = $clog2(NUM_BITS);

  typedef enum logic {IDLE, SEND} state_t;
  state_t state;

  logic [NUM_BITS-1:0] m_packets;
  logic [CW_CLK-1:0]   c_clocks;
  logic [CW_BIT-1:0]   c_bits;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state     <= IDLE;
      c_clocks  <= '0;
      c_bits    <= '0;
      m_packets <= '1;
      tx        <= 1'b1;
      s_ready   <= 1'b1;
    end else begin
      s_ready <= 1'b0;

      case (state)
        IDLE: begin
          c_clocks <= '0;
          c_bits   <= '0;
          tx       <= 1'b1;
          s_ready  <= 1'b1;

          if (s_valid) begin
            state   <= SEND;
            tx      <= 1'b0;
            s_ready <= 1'b0;
            for (int n = 0; n < NUM_WORDS; n++)
              m_packets[n*PACKET_SIZE +: PACKET_SIZE] <=
                {{END_BITS{1'b1}}, s_data[n], 1'b0};
          end
        end

        SEND: if (c_clocks == CW_CLK'(CLKS_PER_BIT - 1)) begin
                c_clocks <= '0;

                if (c_bits == CW_BIT'(NUM_BITS - 1)) begin
                  state     <= IDLE;
                  c_bits    <= '0;
                  m_packets <= '1;
                  tx        <= 1'b1;
                  s_ready   <= 1'b1;
                end else begin
                  c_bits    <= c_bits + 1'b1;
                  m_packets <= m_packets >> 1;
                  tx        <= m_packets[1];
                end
              end else c_clocks <= c_clocks + 1'b1;

        default: state <= IDLE;
      endcase
    end
  end
endmodule
