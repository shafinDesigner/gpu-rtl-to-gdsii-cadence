puts "RM-info: Starting Init Design [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists setup.tcl] } {
puts "setup file setup.tcl not found. Exit ....."
exit
}

source setup.tcl

set init_lib_search_path ../LIB

set init_hdl_search_path ../src

set init_verilog $VERILOG_NETLIST_FILE

set init_top_cell $DESIGN_NAME

set init_lef_file $LIBRARY_LEF_FILES

set init_mmmc_file $INIT_MMMC_FILE

init_design

if {[file exists $DEF_FILE] } {


puts "RM-info: Reading DEF file"

defIn $DEF_FILE


}

globalNetConnect VDD -type pgpin -pin VDD -inst *

globalNetConnect VSS -type pgpin -pin VSS -inst *

applyGlobalNets

checkDesign -physicalLibrary

saveDesign ${DESIGN_LIBRARY}/init_design

summaryReport -outdir ${REPORTS_DIR}/init_design

verify_drc -limit 1000000 -report ${REPORTS_DIR}/init_design/report_verify_drc

puts "RM-info: Completed Init Design [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

