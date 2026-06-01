# === Set the design name === #
set DESIGN gpu

# === Set the search paths === #
set_db init_lib_search_path ../LIB/
set_db init_hdl_search_path ../src/

# === Read the liberty library (full path) === #
read_libs ../LIB/slow_vdd1v0_basiccells.lib

# === Read all RTL source files === #
read_hdl -v [glob ../src/*.v]

# === Elaborate the design === #
elaborate $DESIGN

# === Apply timing constraints === #
read_sdc ../Constraints/constraints_top.sdc

# === Lint report === #
report_timing -lint > ./SYN/reports/lint.rpt

# === Set Synthesis Effort === #
set_db syn_generic_effort high
set_db syn_map_effort     high
set_db syn_opt_effort     high

# === Run Synthesis Steps === #
syn_generic
syn_map
syn_opt

# === Reports === #
report_timing > ./SYN/reports/timing.rpt
report_power  > ./SYN/reports/power.rpt
report_area   > ./SYN/reports/area.rpt
report_qor    > ./SYN/reports/qor.rpt

# === Export Design === #
write_hdl    > ./SYN/outputs/gpu_netlist.v
write_sdc    > ./SYN/outputs/gpu_sdc.sdc
write_script > ./SYN/outputs/gpu_constraints.g

exit
