// 2:1 mux, one behaviour, five ways to describe it (out = sel ? b : a).
// TYPE picks which style is elaborated:
//   0: if-else   1: ternary   2: priority case   3: unique case   4: array index
module mux #(
  parameter TYPE = 0,
  parameter W    = 8
)(
  input  logic [W-1:0] a, b,
  input  logic         sel,
  output logic [W-1:0] out
);
  if (TYPE == 0) begin : if_else

    always_comb if (sel) out = b; else out = a;

  end else if (TYPE == 1) begin : ternary

    always_comb out = sel ? b : a;

  end else if (TYPE == 2) begin : priority_case

    always_comb priority case (sel)
      1'b0: out = a;
      1'b1: out = b;
    endcase

  end else if (TYPE == 3) begin : unique_case

    always_comb unique case (sel)
      1'b0: out = a;
      1'b1: out = b;
    endcase

  end else begin : array_index

    logic [1:0][W-1:0] arr;
    always_comb begin
      arr = {b, a};      // arr[0]=a, arr[1]=b
      out = arr[sel];
    end

  end
endmodule
