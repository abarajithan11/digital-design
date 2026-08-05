module axis_dense_relu #(
  parameter int N_IN         = 2,
  parameter int N_OUT        = 2,
  parameter int W_X          = 4,
  parameter int W_K          = 4,
  parameter int W_B          = 8,
  parameter int W_ACC        = 20,
  parameter int SHIFT        = 4,
  parameter int REG_INTERVAL = 1,
  parameter bit RELU         = 1'b1,
  parameter logic signed [N_OUT*N_IN*W_K-1:0] K = '0,
  parameter logic signed      [N_OUT*W_B-1:0] B = '0,
  localparam int DEPTH   = $clog2(N_IN),
  localparam int LATENCY = (DEPTH + REG_INTERVAL - 1) / REG_INTERVAL
  )(
  input  logic clk, rstn,
  input  logic s_valid,
  output logic s_ready,
  input logic signed [N_IN-1:0][W_X-1:0] s_data,
  output logic m_valid,
  input  logic m_ready,
  output logic signed [N_OUT-1:0][W_X-1:0] m_data
  );

  logic stall, cen;
  logic [LATENCY-1:0] valid_pipe;

  always_comb begin
    m_valid = valid_pipe[LATENCY-1];
    stall   = m_valid && !m_ready;
    cen     = !stall;
    s_ready = cen;
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)     valid_pipe <= '0;
    else if (cen)  valid_pipe <= LATENCY'({valid_pipe, s_valid});
  end

  dense_qrelu #(
    .N_IN         (N_IN),
    .N_OUT        (N_OUT),
    .W_X          (W_X),
    .W_K          (W_K),
    .W_B          (W_B),
    .W_ACC        (W_ACC),
    .REG_INTERVAL (REG_INTERVAL),
    .SHIFT        (SHIFT),
    .RELU         (RELU),
    .K            (K),
    .B            (B)
  ) dense (
    .clk, .rstn, .cen,
    .x (s_data),
    .y (m_data)
  );
endmodule
