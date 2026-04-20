`timescale 1ns/1ps

module tb_uart_echo;

  timeunit 1ns/1ps;
  localparam CLKS_PER_BIT     = 4,
             BITS_PER_WORD    = 8,
             W_OUT            = 24,
             N_WORDS          = W_OUT/BITS_PER_WORD,
             PACKET_SIZE_TX   = BITS_PER_WORD+5,
             NUM_EXP          = 10;

  logic clk=0, rstn=0, rx=1, tx;
  initial forever #1 clk = !clk;

  uart_echo #(
    .CLKS_PER_BIT    (CLKS_PER_BIT),
    .BITS_PER_WORD   (BITS_PER_WORD),
    .PACKET_SIZE_TX  (PACKET_SIZE_TX),
    .W_OUT           (W_OUT)
  ) dut (.*);

  typedef logic [N_WORDS-1:0][BITS_PER_WORD-1:0] data_t;

  data_t s_data, m_data;
  logic [BITS_PER_WORD+2-1:0] s_packet;
  logic [BITS_PER_WORD-1:0]   m_packet;

  task automatic send_packet(input data_t data);
    for (int iw=0; iw<N_WORDS; iw++) begin
      s_packet = {1'b1, data[iw], 1'b0};
      repeat ($urandom_range(1,20)) @(posedge clk);
      for (int ib=0; ib<BITS_PER_WORD+2; ib++)
        repeat (CLKS_PER_BIT) begin
          #1ps rx = s_packet[ib];
          @(posedge clk);
        end
    end
    #1ps rx = 1;
  endtask

  task automatic recv_packet(output data_t data);
    data = 'x;
    for (int iw=0; iw<N_WORDS; iw++) begin
      wait(!tx);
      repeat (CLKS_PER_BIT/2) @(posedge clk);

      for (int ib=0; ib<BITS_PER_WORD; ib++) begin
        repeat (CLKS_PER_BIT) @(posedge clk);
        m_packet[ib] = tx;
      end
      data[iw] = m_packet;

      for (int ib=0; ib<PACKET_SIZE_TX-BITS_PER_WORD-1; ib++) begin
        repeat (CLKS_PER_BIT) @(posedge clk);
        if (tx != 1) $error("Incorrect end bits/padding");
      end
    end
  endtask

  initial begin
    assert (W_OUT % BITS_PER_WORD == 0);
    $dumpfile("dump.vcd"); $dumpvars;

    repeat(2) @(posedge clk) #1ps;
    rstn = 1;

    repeat (NUM_EXP) begin
      for (int iw=0; iw<N_WORDS; iw++)
        s_data[iw] = BITS_PER_WORD'($urandom_range(2**BITS_PER_WORD-1));

      fork
        send_packet(s_data);
        recv_packet(m_data);
      join

      assert (s_data == m_data) $display("Outputs match: %p", m_data);
      else $error("Expected: %p != Output: %p", s_data, m_data);

      repeat ($urandom_range(1,20)) @(posedge clk);
    end
    $finish();
  end

  // Counters to help with waveform readability

  int tx_bits, rx_bits;
  initial forever begin
    tx_bits = 0;
    wait(rstn);
    wait(!tx);
    for (int n=0; n<PACKET_SIZE_TX*N_WORDS; n++) begin
      tx_bits += 1;
      repeat (CLKS_PER_BIT) @(posedge clk);
    end
  end

  initial forever begin
    rx_bits = 0;
    wait(!rx);
    for (int n=0; n<(BITS_PER_WORD+2)*N_WORDS; n++) begin
      rx_bits += 1;
      repeat (CLKS_PER_BIT) @(posedge clk);
    end
  end
endmodule