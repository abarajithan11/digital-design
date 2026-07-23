module uart_tx #(
  parameter CLKS_PER_BIT  = 4,
            N_WORDS       = 2,
            BITS_PER_WORD = 8,
            W_PACKET      = BITS_PER_WORD+5
  )(
    input  logic clk, rstn, s_valid,
    input  logic [N_WORDS-1:0][BITS_PER_WORD-1:0] s_data,
    output logic tx, s_ready
  );
  localparam END_BITS = W_PACKET-BITS_PER_WORD-1;
  localparam CW_BITS = $clog2(N_WORDS*W_PACKET);
  localparam CW_CLKS = $clog2(CLKS_PER_BIT);

  logic [N_WORDS-1:0][W_PACKET-1:0] s_packets;
  logic [N_WORDS*W_PACKET-1:0]      m_packets;

  always_comb begin
    tx      = m_packets[0];
    s_ready = (state == IDLE);
    for (int n=0; n<N_WORDS; n=n+1)
      s_packets[n] = {{END_BITS{1'b1}}, s_data[n], 1'b0};
  end

  logic [CW_BITS-1:0] c_bits;
  logic [CW_CLKS-1:0] c_clocks;

  enum {IDLE, SEND} state;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state     <= IDLE;
      m_packets <= '1;
      {c_bits, c_clocks} <= '0;
    end else
      case (state)
        IDLE: if (s_valid) begin
                state     <= SEND;
                m_packets <= s_packets;
              end

        SEND: if (c_clocks == CW_CLKS'(CLKS_PER_BIT-1)) begin
                c_clocks <= '0;

                if (c_bits == CW_BITS'(N_WORDS*W_PACKET-1)) begin
                  c_bits    <= '0;
                  m_packets <= '1;
                  state     <= IDLE;
                end else begin
                  c_bits     <= c_bits + 1'b1;
                  m_packets <= m_packets >> 1;
                end
              end else c_clocks <= c_clocks + 1'b1;
      endcase
  end

endmodule
