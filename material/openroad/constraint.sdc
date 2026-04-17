# Generic course SDC for ASAP7.
#
# ORFS interprets timing values using the platform liberty time units.
# For ASAP7 that means picoseconds, so keep the units explicit in the
# Tcl variable names instead of using bare numeric literals.

set clk_name virtual_clock
set clk_period_ps 10000
set io_delay_ps 0

create_clock -name $clk_name -period $clk_period_ps

set_input_delay $io_delay_ps -clock $clk_name [all_inputs]
set_output_delay $io_delay_ps -clock $clk_name [all_outputs]
