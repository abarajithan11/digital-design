`timescale 1ns/1ps

module vip_uart_tx #(
  parameter CLKS_PER_BIT   = 4,
            BITS_PER_WORD  = 8,
            W_OUT          = 24,
            N_WORDS        = W_OUT / BITS_PER_WORD,
            PACKET_SIZE_TX = BITS_PER_WORD + 5
  )(
    input logic clk, rstn, tx
  );

  typedef logic [N_WORDS-1:0][BITS_PER_WORD-1:0] data_t;

  logic [BITS_PER_WORD-1:0] m_packet;
  int tx_bits;

  task automatic recv_packet(output data_t data);
    data = 'x;

    for (int iw = 0; iw < N_WORDS; iw++) begin
      wait (!tx);
      repeat (CLKS_PER_BIT/2) @(posedge clk);

      for (int ib = 0; ib < BITS_PER_WORD; ib++) begin
        repeat (CLKS_PER_BIT) @(posedge clk);
        m_packet[ib] = tx;
      end
      data[iw] = m_packet;

      for (int ib = 0; ib < PACKET_SIZE_TX-BITS_PER_WORD-1; ib++) begin
        repeat (CLKS_PER_BIT) @(posedge clk);
        if (tx != 1'b1) $error("Incorrect end bits/padding");
      end
    end
  endtask

  // Counter to help with waveform readability
  initial forever begin
    tx_bits = 0;
    wait (rstn);
    wait (!tx);
    for (int n = 0; n < PACKET_SIZE_TX*N_WORDS; n++) begin
      tx_bits += 1;
      repeat (CLKS_PER_BIT) @(posedge clk);
    end
  end
endmodule