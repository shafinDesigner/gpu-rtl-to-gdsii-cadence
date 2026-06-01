puts "RM-info: Starting place_opt [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

source scripts/soce_setup.tcl

restoreDesign GPU_DESIGN_LIBRARY/init_design.inn.dat $DESIGN_NAME

# === Power Connections === #
set delaycal_use_default_delay_limit 1000
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
applyGlobalNets

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

# === Placement === #
setPlaceMode -clkGateAware              true
setPlaceMode -softGuide                 true
setPlaceMode -maxDensity                0.70
setPlaceMode -place_global_cong_effort  high
setPlaceMode -ignoreScan                1

placeDesign -noPrePlaceOpt

# === Pre-CTS Opt === #
setExtractRCMode -engine preRoute
setOptMode -fixCap          true
setOptMode -fixTran         true
setOptMode -fixFanoutLoad   true
setOptMode -simplifyNetlist false

optDesign -preCTS -drv
optDesign -preCTS

# === Timing Report === #
timeDesign -preCTS -numPaths 100 -outDir ./reports/place_opt

# === Save === #
saveDesign GPU_DESIGN_LIBRARY/place_opt.inn

set dbgLefDefOutVersion 5.8
defOut -unit 1000 -floorplan -netlist ./def/placed/${DESIGN_NAME}.def
saveNetlist ./ver/placed/${DESIGN_NAME}.v

reportGateCount    -outfile ./reports/place_opt/gate_count.rpt
report_power               > ./reports/place_opt/power.rpt

puts "RM-info: Completed place_opt [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
