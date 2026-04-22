# Generic course SDC for ASAP7.
#
# ORFS interprets timing values using the platform liberty time units.
# For ASAP7 that means picoseconds, so keep the units explicit in the
# Tcl variable names instead of using bare numeric literals.

set clk_period_ps 10000
set io_delay_ps 0

# Use a real top-level clock when the design has one so STA can report
# reg-to-reg paths. Fall back to a virtual clock for combinational designs.
set clk_ports [get_ports clk]
if {[llength $clk_ports] > 0} {
  set clk_name clk
  create_clock -name $clk_name -period $clk_period_ps $clk_ports
  set non_clock_inputs [remove_from_collection [all_inputs] $clk_ports]
} else {
  set clk_name virtual_clock
  create_clock -name $clk_name -period $clk_period_ps
  set non_clock_inputs [all_inputs]
}

set_input_delay $io_delay_ps -clock $clk_name $non_clock_inputs
set_output_delay $io_delay_ps -clock $clk_name [all_outputs]
