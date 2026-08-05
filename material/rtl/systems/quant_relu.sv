module quant_relu #(
  parameter int W_ACC=16, W_Y=8, SHIFT=4,
  parameter bit RELU = 1'b1
) (
  input  logic signed [W_ACC-1:0] acc,
  output logic signed [W_Y-1:0]   y
);
  logic signed [W_ACC-1:0] quotient, 
                      remainder, rounded, clamped;

  localparam logic signed [W_ACC-1:0] 
    MIN  = -(1 <<< (W_Y - 1)),
    MAX  =  (1 <<< (W_Y - 1)) - 1,
    HALF =   1 <<< (SHIFT - 1);

  always_comb begin

    // Round to nearest even
    quotient = acc >>> SHIFT;

    if (SHIFT == 0) begin
      rounded = acc;
    end else begin
      remainder = acc - (quotient <<< SHIFT);

      if (remainder > HALF) 
        rounded = quotient + 1;
      else if (remainder == HALF && quotient[0]) 
        rounded = quotient + 1;
      else
        rounded = quotient;
    end

    // Clamp to MAX and MIN
    if (rounded < MIN) begin
      clamped = MIN;
    end else if (rounded > MAX) begin
      clamped = MAX;
    end else begin
      clamped = rounded;
    end

    // ReLU
    y = W_Y'(clamped);
    if (acc < 0 && RELU) y = '0;
  end

endmodule
