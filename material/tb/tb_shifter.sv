`timescale 1ns/1ps

module tb_shifter;
  localparam W = 8, C = 2;

  logic [W-1:0]         a, f, exp;
  logic [2:0]           sel;
  logic [$clog2(W)-1:0] shift_var;

  shifter #(.W(W), .SHIFT_CONST(C)) dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int s = 0; s < 7; s++) begin
      repeat (5) begin
        #1;
        a = W'($urandom); sel = s[2:0]; shift_var = ($clog2(W))'($urandom);
        case (sel)
          3'd0: exp = a << C;                        // arithmetic left  == logical left
          3'd1: exp = $signed(a) >>> C;              // arithmetic right
          3'd2: exp = a << C;                        // logical left
          3'd3: exp = a >> C;                        // logical right
          3'd4: exp = {a[W-1-C:0], a[W-1:W-C]};      // rotate left
          3'd5: exp = {a[C-1:0], a[W-1:C]};          // rotate right
          3'd6: exp = a << shift_var;                // arithmetic left by variable
          default: exp = a;
        endcase
        #1ps;
        assert (f == exp)
          else $error("sel=%0d a=%b sv=%0d f=%b exp=%b", sel, a, shift_var, f, exp);
      end
    end

    $finish;
  end
endmodule
