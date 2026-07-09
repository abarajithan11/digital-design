module auto_light (
  input  logic dark_outside, motion_sensed, scheduled_time,
  output logic light
);
  always_comb light = dark_outside && (motion_sensed || scheduled_time);
endmodule
