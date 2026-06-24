`timescale 1ns/1ps

module tb_auto_light;

  logic dark_outside = 0, motion_sensed = 0, scheduled_time = 0;
  logic light, light_expected;

  auto_light dut (.*);

  initial begin
    $dumpfile(`FST_PATH); $dumpvars;

    for (int test_vector = 0; test_vector < 8; test_vector++) begin
      
      {dark_outside, motion_sensed, scheduled_time} = 3'(test_vector);
      #1;
      
      light_expected = dark_outside & (motion_sensed | scheduled_time);
      assert (light === light_expected)
        else $error("dark_outside=%0b motion_sensed=%0b scheduled_time=%0b: exp light=%0b, got light=%0b",
                    dark_outside, motion_sensed, scheduled_time, light_expected, light);
    end
    $finish;
  end
endmodule
