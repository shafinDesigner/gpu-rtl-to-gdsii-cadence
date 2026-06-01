puts "RM-info: Starting time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists scripts/soce_setup.tcl] } {
    puts "Encounter setup file scripts/soce_setup.tcl not found. Exit ....."
    exit
}
source scripts/soce_setup.tcl

set rda_Input(ui_view_definition_file) "input/mmmc.view"
setUIVar rda_Input {ui_settop}      {1}
setUIVar rda_Input {ui_topcell}     $DESIGN_NAME
setUIVar rda_Input {ui_netlist}     $VERILOG_NETLIST_FILE
setUIVar rda_Input {ui_timelib,max} $TARGET_LIBRARY_FILES
setUIVar rda_Input {ui_timelib,min} $MIN_LIBRARY_FILES
setUIVar rda_Input {ui_leffile}     $LIBRARY_LEF_FILES
setUIVar rda_Input {ui_timingcon_file} $FUNC_SDC
setUIVar rda_Input {ui_pwrnet}      $POWERNET_NAME
setUIVar rda_Input {ui_gndnet}      $GROUNDNET_NAME

init_design

puts "RM-info: Command init_design completed"

if { [file exists $DEF_FILE] } {
    puts "RM-info: Creating Floorplan from DEF file"
    defIn $DEF_FILE
    checkPinAssignment
}

remove_assigns
update_names -nocase

saveDesign $GPU_DESIGN_LIBRARY/init_design.inn

checkDesign -all -outdir ${REPORTS_DIR}/init_design
summaryReport  -outdir ${REPORTS_DIR}/init_design/summaryReport
verify_drc -limit 1000000 -report ${REPORTS_DIR}/init_design/report_verify_drc

puts "RM-info: Completed time [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"
exit
