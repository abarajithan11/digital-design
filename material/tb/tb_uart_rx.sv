`timescale 1ns/1ps

module tb_uart_rx;

  localparam  CLKS_PER_BIT     = 4, //200_000_000/9600
              W_OUT            = 16,
              BITS_PER_WORD    = 8,
              NUM_WORDS        = W_OUT/BITS_PER_WORD,
              DATA_WIDTH       = NUM_WORDS*BITS_PER_WORD;

  logic clk=0, rstn=0, rx=1, m_valid;
  logic [NUM_WORDS-1:0][BITS_PER_WORD-1:0] m_data, data;
  logic [BITS_PER_WORD+2-1:0] packet;

  initial forever #1 clk = !clk;

  uart_rx #(
    .CLKS_PER_BIT(CLKS_PER_BIT), 
    .W_OUT(W_OUT),
    .BITS_PER_WORD(BITS_PER_WORD)) dut (.*);

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    repeat(2)  @(posedge clk) #1ps; 
    rstn = 1;
    repeat(5)  @(posedge clk) #1ps;

    repeat (10) begin
      data = DATA_WIDTH'($urandom());

      for (int iw=0; iw<NUM_WORDS; iw=iw+1) begin
        packet = {1'b1, data[iw], 1'b0};

        repeat ($urandom_range(1,20)) @(posedge clk);

        for (int ib=0; ib<BITS_PER_WORD+2; ib=ib+1)
          repeat(CLKS_PER_BIT) begin 
            #1ps rx = packet[ib];
            @(posedge clk);
          end
      end
      repeat ($urandom_range(1,100)) @(posedge clk);
    end
    $finish();
  end

  initial forever
    @(posedge clk)
    if(m_valid)
      assert (m_data == data) $display("OK, %b", m_data);
      else $error("Sent %b, got %b", data, m_data);

  // Count UART bits on waveform
  int bits;
  initial forever begin
    bits = 0;
    wait(!rx);
    for (int n=0; n<BITS_PER_WORD+2; n++) begin
      bits += 1;
      repeat (CLKS_PER_BIT) @(posedge clk);
    end
  end

endmodule