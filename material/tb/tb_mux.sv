`timescale 1ns/1ps

module tb_mux;
  localparam W = 8;

  logic [W-1:0] a, b;
  logic         sel;
  logic [W-1:0] out [5];

  mux #(.TYPE(0), .W(W)) d0 (.a, .b, .sel, .out(out[0]));   // if-else
  mux #(.TYPE(1), .W(W)) d1 (.a, .b, .sel, .out(out[1]));   // ternary
  mux #(.TYPE(2), .W(W)) d2 (.a, .b, .sel, .out(out[2]));   // priority case
  mux #(.TYPE(3), .W(W)) d3 (.a, .b, .sel, .out(out[3]));   // unique case
  mux #(.TYPE(4), .W(W)) d4 (.a, .b, .sel, .out(out[4]));   // array index

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    repeat (20) begin
      #1;
      a = W'($urandom); b = W'($urandom); sel = 1'($urandom);
      #1ps;
      for (int k = 0; k < 5; k++)
        assert (out[k] == (sel ? b : a))
          else $error("type %0d: sel=%0b a=%0d b=%0d out=%0d", k, sel, a, b, out[k]);
    end

    $finish;
  end
endmodule
