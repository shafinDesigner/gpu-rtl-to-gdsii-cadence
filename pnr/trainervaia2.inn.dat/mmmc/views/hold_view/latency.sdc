set_clock_latency -source -early -max -rise  -0.356156 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -max -fall  -0.382835 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -rise  -0.356156 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -fall  -0.382835 [get_ports {clk}] -clock clk 
