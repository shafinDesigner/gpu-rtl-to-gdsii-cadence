puts "RM-info: Starting time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists scripts/soce_setup.tcl] } {
    puts "Encounter setup file scripts/soce_setup.tcl not found. Exit ....."
    exit
}
source scripts/soce_setup.tcl

restoreDesign $FE_DESIGN_LIBRARY/init_design.inn.dat $DESIGN_NAME

# === Constraints === #
set_interactive_constraint_modes [all_constraint_modes -active]
set_max_capacitance $MAX_CAP [current_design]
set_propagated_clock [all_clocks]
set_max_transition $MAX_TRANSITION_DATA  -data_path  [all_clocks]
set_max_transition $MAX_TRANSITION_CLOCK -clock_path [all_clocks]
reset_clock_uncertainty -from [all_clocks] -to [all_clocks]
set_clock_uncertainty -setup $SETUP_CLOCK_UNCERTAINTY [all_clocks]
set_clock_uncertainty -hold  $HOLD_CLOCK_UNCERTAINTY  [all_clocks]
update_constraint_mode -name func_mode -sdc_files $FUNC_SDC

setDesignMode -topRoutingLayer $MAX_ROUTING_LAYER
set_max_fanout $MAX_FANOUT [current_design]
setDesignMode -process $PROCESS_NODE

set save_design_name    "$FE_DESIGN_LIBRARY/place_opt.inn"
set placed_def          "./def/placed/${DESIGN_NAME}.def"
set placed_ver          "./ver/placed/${DESIGN_NAME}.v"
set place_reports_dir   "./${REPORTS_DIR}/place_opt"
set sum_rpt             "$place_reports_dir/${DESIGN_NAME}.sum"
set num_tim_path        10000

setMultiCpuUsage -keepLicense true
setMultiCpuUsage -localCpu 8
setMaxRouteLayer $MAX_ROUTING_LAYER
setRCAccuracyMode all:on

# === CTS Spec === #
delete_ccopt_clock_tree_spec
create_ccopt_clock_tree_spec -file data/ccopt.ctstch
source data/ccopt.ctstch

set_global report_timing_format {hpin net arc cell fanout load slew delay arrival}
setAnalysisMode -timeBorrowing  false
setAnalysisMode -analysisType   onChipVariation
setAnalysisMode -cppr           both

# === Placement Mode === #
if { [file exists $DEF_FILE] } {
    setPlaceMode -placeIoPins false
} else {
    setPlaceMode -placeIoPins true
}

setPlaceMode -clkGateAware                  true
setPlaceMode -softGuide                     true
setPlaceMode -maxDensity                    0.70
setPlaceMode -ignoreScan                    1
setPlaceMode -moduleAwareSpare              false
setPlaceMode -ignoreSpare                   true
setPlaceMode -place_global_ignore_scan      true
setPlaceMode -place_global_reorder_scan     true
setPlaceMode -place_global_clock_gate_aware true
setPlaceMode -place_global_uniform_density  true
setPlaceMode -place_global_cong_effort      high
setPlaceMode -place_opt_run_global_place    full

setLimitedAccessFeature legacy_fects_final_release 1

setOptMode -maxLength        400
setOptMode -simplifyNetlist  false
setOptMode -fixFanoutLoad    true
setOptMode -fixGlitch        true
setOptMode -usefulSkew       false

# === Path Groups === #
group_path -name "reg2reg" -from [all_registers] \
    -to [filter_collection [all_registers] "is_integrated_clock_gating_cell != true"]
group_path -name "clkgate" -from [all_registers] \
    -to [filter_collection [all_registers] "is_integrated_clock_gating_cell == true"]
group_path -name in2reg  -from [all_inputs -no_clocks] -to [all_registers]
group_path -name reg2out -from [all_registers]         -to [all_outputs]
group_path -name in2out  -from [all_inputs -no_clocks] -to [all_outputs]

setPathGroupOptions reg2reg -effortLevel high
setPathGroupOptions in2reg  -effortLevel high
setPathGroupOptions reg2out -effortLevel high
setPathGroupOptions in2out  -effortLevel high
setPathGroupOptions clkgate  -slackAdjustment 0
setPathGroupOptions in2reg   -slackAdjustment 0
setPathGroupOptions reg2out  -slackAdjustment 0

redirect $place_reports_dir/report_analysis_views.rpt "report_analysis_views"
report_tracks -prefer_only
setOptMode -usefulSkewPreCTS false

# === Combined Place + Opt === #
place_opt_design

update_names -nocase
saveDesign $FE_DESIGN_LIBRARY/placeinit.inn
saveDesign $save_design_name

puts "RM-info: Timing Report after place_opt_design"
timeDesign -reportOnly -numPaths $num_tim_path       -outDir $place_reports_dir/setup
timeDesign -reportOnly -numPaths $num_tim_path -hold  -outDir $place_reports_dir/hold

reportGateCount -outfile $place_reports_dir/report_gate_count.sum

report_clocks

# === Re-apply path groups === #
group_path -name "reg2reg" -from [all_registers] \
    -to [filter_collection [all_registers] "is_integrated_clock_gating_cell != true"]
group_path -name "clkgate" -from [all_registers] \
    -to [filter_collection [all_registers] "is_integrated_clock_gating_cell == true"]
group_path -name in2reg  -from [all_inputs -no_clocks] -to [all_registers]
group_path -name reg2out -from [all_registers]         -to [all_outputs]
group_path -name in2out  -from [all_inputs -no_clocks] -to [all_outputs]

setPathGroupOptions reg2reg -effortLevel high
setPathGroupOptions clkgate  -slackAdjustment 0
setPathGroupOptions in2reg   -slackAdjustment 0
setPathGroupOptions reg2out  -slackAdjustment 0

reportPathGroupOptions

# === Pre-CTS DRV Fix === #
setOptMode -addInstancePrefix pre_cts
setOptMode -fixFanoutLoad true
optDesign -preCTS -drv -outDir $place_reports_dir/drv

# === Export === #
set dbgLefDefOutVersion 5.8
set dbgDefOutLefVias    1
defOut    -unit 1000 -floorplan -netlist $placed_def
saveNetlist $placed_ver

reportGateCount   -outfile $sum_rpt
reportCongestion  -overflow -hotSpot -3d -num_hotspot 20
checkPlace        $place_reports_dir/report_checkPlace
report_power
checkDesign       -all

redirect {puts "corner_coordinates\n[dbGet top.fPlan.boxes]"}    > reports/fPlan.rpt
redirect {puts "no_of_rows= [dbGet top.fPlan.numRows]"}         >> reports/fPlan.rpt
redirect {puts "row_height= [dbGet top.fPlan.coreSite.size_y]"} >> reports/fPlan.rpt
redirect {puts "design_height= [dbGet top.fPlan.box_sizey]"}    >> reports/fPlan.rpt

summaryReport -outdir ${place_reports_dir}/summaryReport

report_constraint -drv_violation_type max_capacitance > $place_reports_dir/${DESIGN_NAME}_max_cap.rpt
report_constraint -drv_violation_type max_transition  > $place_reports_dir/${DESIGN_NAME}_max_tran.rpt
report_constraint -drv_violation_type max_fanout      > $place_reports_dir/${DESIGN_NAME}_max_fanout.rpt

puts "RM-info: Completed time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
