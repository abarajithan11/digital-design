`timescale 1ns/1ps

module tb_fir_filter;
  localparam W_X = 8, W_K = 4, N = 3,
             W_Y = W_X + W_K + $clog2(N),
             RETIMED = 1;

  localparam logic [N:0][W_K-1:0] K = {4'd1, 4'd2, 4'd3, 4'd4};

  logic clk=0, rstn=0, en=1;
  localparam CLK_PERIOD = 10;
  initial forever #(CLK_PERIOD/2) clk = ~clk;

  logic [W_X-1:0] x=0;
  logic [W_Y-1:0] y, y_exp=0;
  fir_filter #(.RETIMED(RETIMED), .N(N), .W_X(W_X), .W_K (W_K), .K(K)) dut (.*);

  logic [W_X-1:0] zi [N+1] = '{default:0};
  logic [W_X-1:0] zq [$];
  initial repeat(N+1) zq.push_back('0);

  int status;
  int file_x  = $fopen("data/x.txt", "r");
  int file_y  = $fopen("data/y.txt", "w");

  // Drive signals
  initial begin
    $dumpfile(`VCD_PATH); $dumpvars(0, dut);

    #10 rstn = 1;
    
    while (!$feof(file_x))
      @(posedge clk) #1ps status = $fscanf(file_x,"%d\r", x);
    $fclose(file_x);
    $fclose(file_y);
    $finish();
  end

  // Monitor signals
  initial forever begin
    @(posedge clk) #2
    zq.push_front(x);
    zq.pop_back();
    
    y_exp = 0;
    for (int i = 0; i < N+1; i += 1)
      y_exp = $signed(y_exp) + $signed(zq[i]) * $signed(K[i]);
    
    assert (y==y_exp) begin 
      $display("OK: y:%d", y);
      $fdisplay(file_y, "%d", y);
    end else $error("y:%d != y_exp:%d", y, y_exp);
  end
endmodule