`timescale 1ns/1ps

module tb_ax_plus_b;
  localparam W = 8;
  localparam WS = 2*W+1;

  logic clk=0, rstn=0;
  logic [W-1:0] a, x, b, y, y_exp;

  initial forever #1 clk = !clk;

  ax_plus_b #(.W(W)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    @(posedge clk) rstn = 1;
    repeat(2) @(posedge clk);

    @(posedge clk) a = 2; b = 3; x = 4;
    @(posedge clk) a = 5; b = 2; x = 3;
    @(posedge clk) a = 5; b = 3; x = 2;

    repeat(10) begin
      a = W'($urandom);
      x = W'($urandom);
      b = W'($urandom);
      y_exp = W'(WS'($signed(a)) * WS'($signed(x)) + WS'($signed(b)));
      repeat(3) @(posedge clk);
      #1ps;
      assert (y == y_exp) $display("OK");
      else $display("Error: y_exp=%d, y=%d", y_exp, y); 
    end

    $finish();
  end
endmodule