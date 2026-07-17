`timescale 1ns/1ps

module tb_ax_plus_b;
  localparam W = 8;
  localparam WS = 2*W+1;
  localparam logic [W-1:0] MIN = 1 << (W-1),
                           MAX = MIN - 1'b1;

  logic clk=0, rstn=0;
  logic [W-1:0] a, x, b, y, y_exp;
  logic signed [WS-1:0] sum_exp;

  initial forever #1 clk = !clk;
  task automatic posedge_clk(int n = 1);
    repeat (n) @(posedge clk); #1ps;
  endtask

  ax_plus_b #(.W(W)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    posedge_clk; rstn = 1;
    posedge_clk(2);

    posedge_clk; a = 2; b = 3; x = 4;
    posedge_clk; a = 5; b = 2; x = 3;
    posedge_clk; a = 5; b = 3; x = 2;

    repeat(10) begin
      a = W'($urandom);
      x = W'($urandom);
      b = W'($urandom);
      sum_exp = WS'($signed(a)) * WS'($signed(x)) + WS'($signed(b));
      y_exp = sum_exp < WS'($signed(MIN)) ? MIN :
              sum_exp > WS'($signed(MAX)) ? MAX :
              W'(sum_exp);
      posedge_clk(3);
      assert (y == y_exp) $display("OK");
      else $display("Error: y_exp=%d, y=%d", y_exp, y);
    end

    $finish();
  end
endmodule