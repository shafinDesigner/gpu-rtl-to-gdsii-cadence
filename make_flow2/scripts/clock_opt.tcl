puts "RM-info: Starting clock_opt [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

source scripts/soce_setup.tcl

restoreDesign GPU_DESIGN_LIBRARY/place_opt.inn.dat $DESIGN_NAME

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

# === CCOPT Clock Tree === #
set_ccopt_property target_max_trans     0.2
set_ccopt_property target_skew          $TARGET_SKEW
set_ccopt_property source_max_capacitance $SOURCE_MAXCAP
set_ccopt_property max_fanout           $MAX_FANOUT

set_ccopt_property inverter_cells {
    CLKINVX1 CLKINVX2 CLKINVX3
    CLKINVX4 CLKINVX6 CLKINVX8
}
set_ccopt_property buffer_cells {
    CLKBUFX2 CLKBUFX3 CLKBUFX4
    CLKBUFX6 CLKBUFX8
}

create_ccopt_clock_tree_spec -file ./data/ccopt.spec
ccopt_design

# === Post-CTS Analysis === #
setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both

# === Post-CTS Timing Reports === #
timeDesign -postCTS      -numPaths 100 -outDir ./reports/clock_opt
timeDesign -postCTS -hold -numPaths 100 -outDir ./reports/clock_opt

report_ccopt_clock_trees  -file ./reports/clock_opt/ccopt_clock_trees.rpt
report_ccopt_skew_groups  -file ./reports/clock_opt/ccopt_skew_groups.rpt

# === Save === #
saveDesign GPU_DESIGN_LIBRARY/clock_opt.inn

puts "RM-info: Completed clock_opt [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
