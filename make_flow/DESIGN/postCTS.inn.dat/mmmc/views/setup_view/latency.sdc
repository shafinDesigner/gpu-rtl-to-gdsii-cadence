set_clock_latency -source -early -min -rise  -1.15502 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -min -fall  -1.13233 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -max -rise  -1.15502 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -max -fall  -1.13233 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -min -rise  -1.15502 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -min -fall  -1.13233 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -rise  -1.15502 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -fall  -1.13233 [get_ports {clk}] -clock clk 
