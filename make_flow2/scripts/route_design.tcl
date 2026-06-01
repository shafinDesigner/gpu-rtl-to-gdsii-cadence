puts "RM-info: Starting route_design [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

source scripts/soce_setup.tcl

restoreDesign GPU_DESIGN_LIBRARY/clock_opt.inn.dat $DESIGN_NAME

# === Constraints === #
set_interactive_constraint_modes [all_constraint_modes -active]
set_max_capacitance $MAX_CAP [current_design]
set_propagated_clock [all_clocks]
reset_clock_uncertainty -from [all_clocks] -to [all_clocks]
set_clock_uncertainty -setup $SETUP_CLOCK_UNCERTAINTY [all_clocks]
set_clock_uncertainty -hold  $HOLD_CLOCK_UNCERTAINTY  [all_clocks]
set_max_transition $MAX_TRANSITION_DATA  -data_path  [all_clocks]
set_max_transition $MAX_TRANSITION_CLOCK -clock_path [all_clocks]
set_max_fanout $MAX_FANOUT [current_design]

setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both

# === Routing === #
setNanoRouteMode -routeWithTimingDriven  true
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeTopRoutingLayer   $MAX_ROUTING_LAYER
setNanoRouteMode -routeBottomRoutingLayer $MIN_ROUTING_LAYER

routeDesign

saveDesign GPU_DESIGN_LIBRARY/postRoute.inn

# === Post-Route Extraction === #
setExtractRCMode -engine postRoute
setDelayCalMode  -engine AAE -signOff true

# === Post-Route Optimization === #
setOptMode -fixCap        true
setOptMode -fixTran       true
setOptMode -fixFanoutLoad true
setOptMode -holdFixingEffort high
setOptMode -setupTargetSlack 0.0
setOptMode -holdTargetSlack  0.0

optDesign -postRoute -drv
optDesign -postRoute
optDesign -postRoute -hold

# === Final Timing Reports === #
timeDesign -postRoute       -numPaths 100 -outDir ./reports/route_design
timeDesign -postRoute -hold -numPaths 100 -outDir ./reports/route_design

# === Final Reports === #
report_power              > ./reports/route_design/power.rpt
reportGateCount -outfile    ./reports/route_design/gate_count.rpt
report_ccopt_clock_trees  -file ./reports/route_design/clock_trees.rpt
reportCongestion -overflow  > ./reports/route_design/congestion.rpt

# === Export Final Outputs === #
set dbgLefDefOutVersion 5.8
defOut -unit 1000 -floorplan -netlist ./def/route_design/${DESIGN_NAME}.def
saveNetlist ./ver/route_design/${DESIGN_NAME}.v

saveDesign GPU_DESIGN_LIBRARY/route_design.inn

puts "RM-info: Completed route_design [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
