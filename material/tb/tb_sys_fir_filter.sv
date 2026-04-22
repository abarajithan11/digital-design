`timescale 1ns/1ps

module tb_sys_fir_filter;

  timeunit 1ns/1ps;
  localparam  CLKS_PER_BIT     = 4,
              WIDTH            = 8,
              FRAC             = 7,
              W_K              = 4,
              N                = 100,
              W_Y              = WIDTH + W_K + $clog2(N+1),
              PACKET_SIZE_TX   = WIDTH+5,
              N_WORDS          = 1;

  typedef logic [N_WORDS-1:0][WIDTH-1:0] data_t;

  int status, file, x_val, y_val;
  logic clk = 0, rstn = 0, rx, tx;
  data_t s_data, m_data;
  logic [WIDTH-1:0] y_exp;
  logic [WIDTH-1:0] x_queue [$];
  logic [WIDTH-1:0] y_queue [$];

  initial forever #1 clk = !clk;

  sys_fir_filter #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (WIDTH),
    .PACKET_SIZE_TX (PACKET_SIZE_TX),
    .WIDTH          (WIDTH),
    .FRAC           (FRAC),
    .N              (N),
    .W_K            (W_K)
  ) dut (.*);

  vip_uart_rx #(
    .CLKS_PER_BIT  (CLKS_PER_BIT),
    .BITS_PER_WORD (WIDTH),
    .W_OUT         (WIDTH)
  ) vip_rx (.*);

  vip_uart_tx #(
    .CLKS_PER_BIT   (CLKS_PER_BIT),
    .BITS_PER_WORD  (WIDTH),
    .W_OUT          (WIDTH),
    .PACKET_SIZE_TX (PACKET_SIZE_TX)
  ) vip_tx (.*);

  initial begin
    #(`SIM_MAX_TIME);
    $display("\n\nTimeout at time: %0t\n\n", $time);
    $finish();
  end

  initial begin
    $dumpfile(`VCD_PATH); $dumpvars;

    // Read files
    file = $fopen("data/x_music.txt", "r");
    if (file==0) $fatal(1, "failed to open data/x_music.txt");
    while (!$feof(file)) begin
      status = $fscanf(file, "%d,", x_val);
      x_queue.push_back(WIDTH'(x_val));
    end
    $fclose(file);

    file = $fopen("data/y_exp.txt", "r");
    if (file==0) $fatal(1, "failed to open data/y_exp.txt");
    while (!$feof(file)) begin
      status = $fscanf(file, "%d,", y_val);
      y_queue.push_back(WIDTH'(y_val));
    end
    $fclose(file);

    // Start the test

    repeat (2) @(posedge clk) #1ps;
    rstn = 1;

    for (int i = 0; i < x_queue.size(); i++) begin
      s_data[0] = x_queue[i];
      y_exp   = y_queue[i];

      fork
        vip_rx.send_packet(s_data);
        vip_tx.recv_packet(m_data);
      join

      assert ($signed(m_data[0]) == $signed(y_exp))
      else $error("Mismatch [%0d]: expected %0d, got %0d",
                  i, $signed(y_exp), $signed(m_data[0]));

      repeat ($urandom_range(1,20)) @(posedge clk);
    end
    $display("All outputs match!");
    $finish();
  end

endmodule
