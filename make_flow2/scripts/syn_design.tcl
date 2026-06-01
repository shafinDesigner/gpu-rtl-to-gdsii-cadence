set DESIGN gpu

set_db init_lib_search_path ../LIB/
set_db init_hdl_search_path ../src/

read_libs ../LIB/slow_vdd1v0_basiccells.lib

read_hdl -v [glob ../src/*.v]

elaborate $DESIGN

read_sdc ../Constraints/constraints_top.sdc

set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

syn_generic
syn_map
syn_opt

report_timing > ./SYN/reports/timing.rpt
report_power  > ./SYN/reports/power.rpt
report_area   > ./SYN/reports/area.rpt
report_qor    > ./SYN/reports/qor.rpt

write_hdl    > ./SYN/outputs/gpu_netlist.v
write_sdc    > ./SYN/outputs/gpu_sdc.sdc
write_script > ./SYN/outputs/gpu_constraints.g

write_db -common ./SYN/outputs/gpu_design.db

exit
