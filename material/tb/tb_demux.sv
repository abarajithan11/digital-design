`timescale 1ns/1ps

module tb_demux;
  localparam W = 3, W_SEL = 2, N = 2**W_SEL;

  logic [W-1:0]        in;
  logic [W_SEL-1:0]    sel;
  logic [N-1:0][W-1:0] out;

  demux #(.W(W), .W_SEL(W_SEL)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int s = 0; s < N; s++) begin
      #1;
      in = W'($urandom); sel = s[W_SEL-1:0];
      #1ps;
      assert (out[sel] == in)   // unselected lanes are don't-care
        else $error("sel=%0d out=%0d in=%0d", sel, out[sel], in);
    end

    $finish;
  end
endmodule
