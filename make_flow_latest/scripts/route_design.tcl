puts "RM-info: Starting time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists scripts/soce_setup.tcl] } {
    puts "Encounter setup file scripts/soce_setup.tcl not found. Exit ....."
    exit
}
source scripts/soce_setup.tcl

restoreDesign $FE_DESIGN_LIBRARY/clock_opt.inn.dat $DESIGN_NAME

# === Constraints === #
set_interactive_constraint_modes [all_constraint_modes -active]
set_max_capacitance $MAX_CAP [current_design]
set_propagated_clock [all_clocks]
reset_clock_uncertainty -from [all_clocks] -to [all_clocks]
set_clock_uncertainty -setup $SETUP_CLOCK_UNCERTAINTY [all_clocks]
set_clock_uncertainty -hold  $HOLD_CLOCK_UNCERTAINTY  [all_clocks]
update_constraint_mode -name func_mode -sdc_files $FUNC_SDC
setMaxRouteLayer $MAX_ROUTING_LAYER
set_max_fanout 30 [current_design]
set_max_transition $MAX_TRANSITION_DATA  -data_path  [all_clocks]
set_max_transition $MAX_TRANSITION_CLOCK -clock_path [all_clocks]
setMultiCpuUsage -localCpu 1

set save_design_name    "$FE_DESIGN_LIBRARY/route_design.inn"
set route_design_def    "./def/route_design/${DESIGN_NAME}.def"
set route_design_ver    "./ver/route_design/${DESIGN_NAME}.v"
set route_reports_dir   "./${REPORTS_DIR}/route_design"
set rpt_sum             "$route_reports_dir/${DESIGN_NAME}.sum"
set num_tim_path        100

setAnalysisMode -analysisType   onChipVariation
setAnalysisMode -cppr           both

# === Routing === #
setNanoRouteMode -routeWithTimingDriven     true
setNanoRouteMode -quiet -routeInsertAntennaDiode true
setNanoRouteMode -routeTopRoutingLayer      $MAX_ROUTING_LAYER
setNanoRouteMode -routeBottomRoutingLayer   $MIN_ROUTING_LAYER

set_propagated_clock [all_clocks]

# Combined route + optimization (route_opt_design)
routeDesign

report_clocks
update_names -nocase
puts "RM-info: Saving Route Design Database"
saveDesign $save_design_name

report_power

mkdir -p ./reports/route_design/checkDesign
checkDesign -all -outdir ./reports/route_design/checkDesign
checkDesign -all

# === Post-Route Optimization === #
catch {optDesign -postRoute -drv  -outDir $route_reports_dir/opt_drv}

setOptMode -addInstancePrefix route_setup
catch {optDesign -postRoute -incr -outDir $route_reports_dir/opt_setup}

setOptMode -addInstancePrefix route_hold
setOptMode -holdFixingEffort  high
setOptMode -setupTargetSlack  0.3
catch {optDesign -postRoute -hold -outDir $route_reports_dir/opt_hold}
# === Export Final Outputs === #
set dbgLefDefOutVersion 5.8
set dbgDefOutLefVias    1
defOut    -unit 1000 -floorplan -netlist $route_design_def
saveNetlist $route_design_ver

saveDesign $save_design_name

# === Final Reports === #
reportGateCount -outfile $rpt_sum
reportGateCount -outfile $route_reports_dir/reportGateCount.rpt

set_propagated_clock [all_clocks]

timeDesign -postRoute -hold  -numPaths $num_tim_path -outDir $route_reports_dir/hold
timeDesign -postRoute -prefix setup -numPaths $num_tim_path -outDir $route_reports_dir/setup
timeDesign -reportOnly                          -numPaths $num_tim_path -outDir $route_reports_dir/setup

summaryReport -outdir ${route_reports_dir}/summaryReport

report_ccopt_clock_trees -file ${route_reports_dir}/ccopt_clock_trees.rpt
report_ccopt_skew_groups -file ${route_reports_dir}/ccopt_skew_groups.rpt

reportCongestion -overflow

puts "RM-info: Completed time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
