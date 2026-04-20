`timescale 1ns/1ps

module vip_uart_rx #(
  parameter CLKS_PER_BIT   = 4,
            BITS_PER_WORD  = 8,
            W_OUT          = 24,
            N_WORDS        = W_OUT / BITS_PER_WORD
  )(
    input  logic clk,
    output logic rx
  );
  typedef logic [N_WORDS-1:0][BITS_PER_WORD-1:0] data_t;
  logic [BITS_PER_WORD+2-1:0] s_packet;
  int rx_bits;

  initial rx = 1'b1;

  task automatic send_packet(input data_t data);
    for (int iw = 0; iw < N_WORDS; iw++) begin
      s_packet = {1'b1, data[iw], 1'b0};

      repeat ($urandom_range(1,20)) @(posedge clk);

      for (int ib = 0; ib < BITS_PER_WORD+2; ib++) begin
        repeat (CLKS_PER_BIT) begin
          #1ps rx = s_packet[ib];
          @(posedge clk);
        end
      end
    end

    #1ps rx = 1'b1;
  endtask

  // Counter to help with waveform readability
  initial forever begin
    rx_bits = 0;
    wait (!rx);
    for (int n = 0; n < (BITS_PER_WORD+2)*N_WORDS; n++) begin
      rx_bits += 1;
      repeat (CLKS_PER_BIT) @(posedge clk);
    end
  end

endmodule