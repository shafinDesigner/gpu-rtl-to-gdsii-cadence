puts "RM-info: Starting time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists soce_setup.tcl] } {
    puts "Encounter setup file soce_setup.tcl not found. Exit ....."
    exit
}
source soce_setup.tcl

set rda_Input(ui_view_definition_file) "input/mmmc.view"
setUIVar rda_Input {ui_settop}          {1}
setUIVar rda_Input {ui_topcell}         $DESIGN_NAME
setUIVar rda_Input {ui_netlist}         $VERILOG_NETLIST_FILE
setUIVar rda_Input {ui_timelib,max}     $TARGET_LIBRARY_FILES
setUIVar rda_Input {ui_timelib,min}     $MIN_LIBRARY_FILES
setUIVar rda_Input {ui_leffile}         $LIBRARY_LEF_FILES
setUIVar rda_Input {ui_timingcon_file}  $FUNC_SDC
setUIVar rda_Input {ui_delay_limit}     {1000}
setUIVar rda_Input {ui_net_delay}       {1000.0ps}
setUIVar rda_Input {ui_net_load}        {0.5pf}
setUIVar rda_Input {ui_in_tran_delay}   {0.1ps}
setUIVar rda_Input {ui_rel_c_thresh}    {0.03}
setUIVar rda_Input {ui_tot_c_thresh}    {5.0}
setUIVar rda_Input {ui_pwrnet}          $POWERNET_NAME
setUIVar rda_Input {ui_gndnet}          $GROUNDNET_NAME
setUIVar rda_Input {flip_first}         "1"

init_design
puts "RM-info: Command init_design completed"

applyGlobalNets

if { [file exists $DEF_FILE] } {
    puts "RM-info: Creating Floorplan from DEF file"
    defIn $DEF_FILE
    checkPinAssignment
} elseif { [file exists $FLOORPLAN_FILE] } {
    loadFPlan $FLOORPLAN_FILE
} elseif { [file exists $TCL_FILE] } {
    source $TCL_FILE
} else {
    if { [file exists $DEF_IO_PIN] && $DEF_IO_PIN != "" } {
        setPtnPinStatus -cell $DESIGN_NAME -pin * -status fixed
    }
}

deselectAll
setPlaceMode -placeIoPins false
setPtnPinStatus -cell $DESIGN_NAME -pin * -status fixed

if { [file exists $SCAN_DEF_FILE] } {
    defIn $SCAN_DEF_FILE
}

redirect ./reports/init_design/report_analysis_views "report_analysis_views"

remove_assigns
remove_assigns -buffering -ignorePortConstraints
update_names -nocase

saveDesign $GPU_DESIGN_LIBRARY/init_design.inn

checkDesign -all -outdir ${REPORTS_DIR}/init_design
setCheckMode -tapeOut true
setCheckMode -all true
summaryReport -outdir ${REPORTS_DIR}/init_design/summaryReport

redirect ./reports/init_design/report_tracks "report_tracks -prefer_only" -tee
verify_drc -limit 1000000 -report ${REPORTS_DIR}/init_design/report_verify_drc

puts "RM-info: Completed time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
