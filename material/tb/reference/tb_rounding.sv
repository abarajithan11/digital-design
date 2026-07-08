`timescale 1ns/1ps

module tb_rounding;
  localparam W = 8, SHIFT = 2;

  logic [W-1:0] a, f;
  logic [1:0]   mode;
  int           t;
  real          q;

  rounding #(.W(W), .SHIFT(SHIFT)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int m = 0; m < 3; m++) begin
      repeat (20) begin
        #1;
        a = W'($urandom); mode = m[1:0];
        q = real'($signed(a)) / (2.0 ** SHIFT);   // exact: divisor is a power of 2
        case (mode)
          2'd0: t = int'($floor(q));              // truncate (toward -inf)
          2'd1: t = int'($floor(q + 0.5));        // nearest (half up)
          2'd2: begin                             // nearest even
            t = int'($floor(q));
            if ((q - t) > 0.5 || ((q - t) == 0.5 && (t % 2 != 0))) t = t + 1;
          end
          default: t = 0;
        endcase
        #1ps;
        assert (int'($signed(f)) == t)
          else $error("mode=%0d a=%0d f=%0d exp=%0d q=%f", mode, $signed(a), $signed(f), t, q);
      end
    end

    $finish;
  end
endmodule
