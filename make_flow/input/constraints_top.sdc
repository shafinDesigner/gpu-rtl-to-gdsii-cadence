set_units -time ns

create_clock -name clk -period 2.2 -waveform {0 1.0} [get_ports clk]

set_clock_transition 0.05 [get_clocks clk]

set_clock_uncertainty 0.005 [get_clocks clk]

set_false_path -from [get_ports reset]

set_input_delay -max 0.8 -clock clk [get_ports reset]

set_output_delay -max 0.8 -clock clk [get_ports done]
