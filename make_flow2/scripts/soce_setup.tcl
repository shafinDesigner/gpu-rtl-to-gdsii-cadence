puts "RM-info: Starting script.. [info script]"

set PROJECT_BASE "/home/user_77/backup_extract/my_project/project"

set DESIGN_NAME                 "gpu"
set PROCESS_NODE                "45"
set CTS_ENGINE                  "CCOPT"

# Input files (absolute paths from project root)
set VERILOG_NETLIST_FILE        "./SYN/outputs/gpu_netlist.v"
set FUNC_SDC                    "./SYN/outputs/gpu_sdc.sdc"
set INIT_MMMC_FILE              "./input/mmmc.view"
set DEF_FILE                    "$PROJECT_BASE/make_flow/def/gpu_floorplan.def"
set TARGET_LIBRARY_FILES        "$PROJECT_BASE/LIB/slow_vdd1v0_basiccells.lib"
set MIN_LIBRARY_FILES           "$PROJECT_BASE/LIB/fast_vdd1v0_basicCells.lib"
set LIBRARY_LEF_FILES           "$PROJECT_BASE/LEF/gsclib045_tech.lef $PROJECT_BASE/LEF/gsclib045_macro.lef"
set CAP_TABLE_TYP_FILE          "$PROJECT_BASE/Captable/cln28hpl_1p10m+alrdl_5x2yu2yz_typical.capTbl"
set QRC_TECH_FILE_TYPICAL       "$PROJECT_BASE/QRC_tech/gpdk045.tch"

# Output directories (relative to make_flow2/)
set REPORTS_DIR                 "reports"
set LOG_DIR                     "log"
set GPU_DESIGN_LIBRARY          "GPU_DESIGN_LIBRARY"

# Floorplan
set ASPECT_RATIO                1
set CORE_UTILIZATION            0.7
set MIN_ROUTING_LAYER           "1"
set MAX_ROUTING_LAYER           "5"

# Timing parameters
set MAX_TRANSITION_DATA         1.5
set MAX_TRANSITION_CLOCK        0.75
set MAX_FANOUT                  20
set MAX_CAP                     0.1
set SOURCE_MAXCAP               2.00
set TARGET_SKEW                 0.250
set MAX_WIRELENGTH              500
set SETUP_CLOCK_UNCERTAINTY     0.5
set HOLD_CLOCK_UNCERTAINTY      0.07
set CTS_TOP_ROUTING_LAYER       5
set CTS_BOTTOM_ROUTING_LAYER    1

set POWERNET_NAME               VDD
set GROUNDNET_NAME              VSS

#setDesignMode -process $PROCESS_NODE

puts "RM-info: Completed script.. [info script]"
