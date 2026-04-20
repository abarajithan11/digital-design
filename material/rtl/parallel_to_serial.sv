`timescale 1ns/1ps

module parallel_to_serial #(WIDTH = 8)
(
  input  logic clk, rstn, 
  input  logic ser_ready, par_valid, 
  input  logic [WIDTH-1:0] par_data,
  output logic par_ready, ser_data, ser_valid
);
  localparam N_BITS = $clog2(WIDTH);
  enum logic {RX=0, TX=1} next_state, state;
  logic [N_BITS-1:0] count;
  logic [WIDTH-1:0] shift_reg;

  always_comb begin
    next_state = state;
    unique case (state)
      RX: next_state = par_valid ? TX : RX;
      TX: next_state = ser_ready && count==N_BITS'(WIDTH-1) ? RX : TX;
    endcase
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) state <= RX;
    else       state <= TX;
  end

  always_comb begin
    ser_data  = shift_reg[0];
    par_ready = (state == RX);
    ser_valid = (state == TX);
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      count     <= '0;
      shift_reg <= '0;
    end else if (state == RX) begin  
      shift_reg <= par_data;
      count     <= '0;
    end else if (state == TX && ser_ready) begin
      shift_reg <= shift_reg >> 1;
      count     <= count + 1'd1;
    end
  end
endmodule