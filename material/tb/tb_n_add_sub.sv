`timescale 1ns/1ps

module tb_n_add_sub;
  localparam N = 8;

  logic [N-1:0] A, B, S, exp;
  logic         sub, co;

  n_add_sub #(.N(N)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int s = 0; s < 2; s++) begin
      repeat (20) begin
        #1;
        A = N'($urandom); B = N'($urandom); sub = s[0];
        exp = sub ? (A - B) : (A + B);
        #1ps;
        assert (S == exp)
          else $error("sub=%0b A=%0d B=%0d S=%0d exp=%0d", sub, A, B, S, exp);
      end
    end

    $finish;
  end
endmodule
