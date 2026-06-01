if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name fast_lib\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib]
create_library_set -name slow_lib\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow_vdd1v0_basiccells.lib]
create_op_cond -name slow_op -library_file ${::IMEX::libVar}/mmmc/slow_vdd1v0_basiccells.lib -P 1 -V 1 -T 125
create_op_cond -name fast_op -library_file ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib -P 1 -V 1 -T -40
create_rc_corner -name typical_rc\
   -cap_table ${::IMEX::libVar}/mmmc/cln28hpl_1p10m+alrdl_5x2yu2yz_typical.capTbl\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -T 25\
   -qx_tech_file ${::IMEX::libVar}/mmmc/typical_rc/gpdk045.tch
create_delay_corner -name slow_delay\
   -rc_corner typical_rc\
   -early_library_set fast_lib\
   -late_library_set slow_lib
create_delay_corner -name fast_delay\
   -rc_corner typical_rc\
   -early_library_set slow_lib\
   -late_library_set fast_lib
create_constraint_mode -name func_mode\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/func_mode/func_mode.sdc]
create_analysis_view -name setup_view -constraint_mode func_mode -delay_corner slow_delay -latency_file ${::IMEX::dataVar}/mmmc/views/setup_view/latency.sdc
create_analysis_view -name hold_view -constraint_mode func_mode -delay_corner fast_delay -latency_file ${::IMEX::dataVar}/mmmc/views/hold_view/latency.sdc
set_analysis_view -setup [list setup_view] -hold [list hold_view]
