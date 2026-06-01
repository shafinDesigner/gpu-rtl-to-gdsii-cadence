# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.18-s082_1 on Thu May 21 02:40:02 +06 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design gpu

create_clock -name "clk" -period 2.2 -waveform {0.0 1.0} [get_ports clk]
set_clock_transition 0.05 [get_clocks clk]
set_false_path -from [get_ports reset]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 0.8 [get_ports reset]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.8 [get_ports done]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.005 [get_clocks clk]
set_clock_uncertainty -hold 0.005 [get_clocks clk]
