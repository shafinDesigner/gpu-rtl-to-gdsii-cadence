puts "RM-info: Starting time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists soce_setup.tcl] } {
    puts "Encounter setup file soce_setup.tcl not found. Exit ....."
    exit
}
source soce_setup.tcl

restoreDesign $GPU_DESIGN_LIBRARY/place_opt.inn.dat $DESIGN_NAME

set_interactive_constraint_modes [all_constraint_modes -active]
set_max_capacitance $MAX_CAP [current_design]
set_propagated_clock [all_clocks]
reset_clock_uncertainty -from [all_clocks] -to [all_clocks]
set_clock_uncertainty -setup $SETUP_CLOCK_UNCERTAINTY [all_clocks]
set_clock_uncertainty -hold  $HOLD_CLOCK_UNCERTAINTY  [all_clocks]
update_constraint_mode -name func_mode -sdc_files $FUNC_SDC
source ./input/mmmc.view

set_max_transition $MAX_TRANSITION_DATA  -data_path  [all_clocks]
set_max_transition $MAX_TRANSITION_CLOCK -clock_path [all_clocks]
set_max_delay 14 -from [all_registers -clock_pins] -to [all_outputs]

setMaxRouteLayer $MAX_ROUTING_LAYER
set_max_fanout $MAX_FANOUT [current_design]
setMultiCpuUsage -localCpu 4

set save_design_name    "$GPU_DESIGN_LIBRARY/clock_opt.inn"
set clk_reports_dir     "./${REPORTS_DIR}/clock_opt"
set sum_rpt             "$clk_reports_dir/${DESIGN_NAME}.sum"
set postCTS_def         "./def/postCTS/${DESIGN_NAME}.def"
set postCTS_ver         "./ver/postCTS/${DESIGN_NAME}.v"
set num_tim_path        100

catch {exec mkdir reports/clock_opt}
setvar soceSupportRiseFallPinCap 1
setRCAccuracyMode all:on
setAnalysisMode -timeBorrowing  false
setAnalysisMode -analysisType   onChipVariation
setAnalysisMode -cppr           both

set_ccopt_mode  -reset
setCTSMode      -reset
delete_ccopt_clock_tree_spec
source data/ccopt.ctstch

puts "RM-info: Setting CCOPT attributes Start"
set_ccopt_mode -integration native
set_ccopt_property buffer_cells   {}
set_ccopt_property inverter_cells {}
set_ccopt_property force_nanoroute_single_threaded          false
set_ccopt_property target_max_trans                         0.6  -net_type leaf
set_ccopt_property target_max_trans                         0.6  -net_type trunk
set_ccopt_property target_max_trans                         0.6  -net_type top
set_ccopt_property target_skew                              $TARGET_SKEW
set_ccopt_property -use_inverters                           false
set_ccopt_property target_insertion_delay                   2
set_ccopt_property source_max_capacitance                   $SOURCE_MAXCAP

setOptMode -simplifyNetlist false
set_ccopt_property -delay_corner * target_skew -late  0.500
set_ccopt_property -delay_corner * target_skew -early 0.500
set_ccopt_property cts_target_skew                          $TARGET_SKEW
set_ccopt_property advanced_insertion_delay_optimization    true
set_ccopt_property expand_multi_child_regions               true
set_ccopt_property low_power_clustering                     false
set_ccopt_property recluster_to_reduce_power                true
set_ccopt_property max_fanout                               $MAX_FANOUT

setOptMode -maxLength           $MAX_WIRELENGTH
setOptMode -addInstancePrefix   cts
setOptMode -usefulSkew          false
set_ccopt_property call_cong_repair_during_final_implementation true
set_ccopt_property add_wire_delay_in_detailed_balancer          true
set_ccopt_property fraction_max_wire_to_add                     0.5

puts "RM-info: Set CCOPT property completes"
redirect $clk_reports_dir/report_analysis_views.rpt "report_analysis_views"
puts "RM-info: Starting CCOPT design"
ccopt_design

report_ccopt_skew_groups -summary -file $clk_reports_dir/skew.rep
report_ccopt_clock_trees -summary -file $clk_reports_dir/tree.rep
report_ccopt_clock_trees          -file $clk_reports_dir/ccopt_clock_trees.rpt
report_ccopt_skew_groups          -file $clk_reports_dir/ccopt_skew_groups.rpt
report_clocks

update_names -nocase
puts "RM-info: Saving Design"
saveDesign $save_design_name

set dltSdc [glob -nocomplain currentSDC*]
foreach iFile $dltSdc { file delete -force $iFile }

reportGateCount -outfile $sum_rpt

puts "RM-info: Checking Timing Info"
set_propagated_clock [all_clocks]

catch {timeDesign -postCTS -hold -numPaths $num_tim_path -outDir $clk_reports_dir}
catch {timeDesign -reportOnly  -numPaths $num_tim_path -outDir $clk_reports_dir}
catch {timeDesign -reportOnly -timingDebugReport -prefix setup -numPaths $num_tim_path -outDir $clk_reports_dir}

report_power
report_tracks -prefer_only
checkDesign -all
summaryReport -outdir ${clk_reports_dir}/summaryReport

puts "RM-info: Completed time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
puts "RM-info: Completed script.. [info script]"
exit
