
import nn_weights_pkg::*;

module nn (
  input  logic clk, rstn,
  input  logic s_valid,
  output logic s_ready,
  input  logic signed [N_IN-1:0][W_X-1:0] s_data,
  output logic m_valid,
  input  logic m_ready,
  output logic signed [N_OUT-1:0][W_X-1:0] m_data
  );

  logic hidden_valid, hidden_ready;
  logic signed [N_HIDDEN-1:0][W_X-1:0] hidden_data;

  axis_dense_relu #(
    .N_IN         (N_IN),
    .N_OUT        (N_HIDDEN),
    .W_X          (W_X),
    .W_K          (W_K),
    .W_B          (W_B),
    .W_ACC        (W_ACC),
    .REG_INTERVAL (2),
    .SHIFT        (SHIFT_0),
    .RELU         (1),
    .K            (weights_0),
    .B            (bias_0)
  ) layer0 (
    .clk, .rstn,
    .s_valid,
    .s_ready,
    .s_data,
    .m_valid (hidden_valid),
    .m_ready (hidden_ready),
    .m_data  (hidden_data)
  );

  axis_dense_relu #(
    .N_IN         (N_HIDDEN),
    .N_OUT        (N_OUT),
    .W_X          (W_X),
    .W_K          (W_K),
    .W_B          (W_B),
    .W_ACC        (W_ACC),
    .REG_INTERVAL (2),
    .SHIFT        (SHIFT_1),
    .RELU         (0),
    .K            (weights_1),
    .B            (bias_1)
  ) layer1 (
    .clk, .rstn,
    .s_valid (hidden_valid),
    .s_ready (hidden_ready),
    .s_data  (hidden_data),
    .m_valid,
    .m_ready,
    .m_data
  );
endmodule