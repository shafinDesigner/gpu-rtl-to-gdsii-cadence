puts "RM-info: Starting script.. [info script]"

set PROJECT_BASE "/home/user_77/backup_extract/my_project/project"

set DESIGN_NAME                 "gpu"
set LIB_USED                    "9trk"
set DESIGN_FLOW                 "asic"
set PROCESS_NODE                "45"
set CTS_ENGINE                  "CCOPT"

########################################################################################
# Design Input
########################################################################################
set INIT_DESIGN_INPUT           "verilog"
set VERILOG_NETLIST_FILE        "./SYN/outputs/gpu_netlist.v"
set SDC_FILE                    "./SYN/outputs/gpu_sdc.sdc"
set FUNC_SDC                    "./SYN/outputs/gpu_sdc.sdc"
set INIT_MMMC_FILE              "./input/mmmc.view"
set DEF_FILE                    "$PROJECT_BASE/make_flow/def/gpu_floorplan.def"
set DEF_IO_PIN                  ""
set SCAN_DEF_FILE               ""
set FLOORPLAN_FILE              ""
set TCL_FILE                    ""
set IO_FILE                     ""
set CREATE_PWRGRID              0
set LOAD_INITIAL_ID_TCL_FILE    0
set LOAD_FINAL_ID_TCL_FILE      0
set ADD_TAPCELL                 0
set TAP_DISTANGE                60
set ADD_SPARE                   0
set ADD_BOUNDARY_CELL           0
set POWERNET_NAME               VDD
set GROUNDNET_NAME              VSS

# Output paths
set RC_CORN                     "(rcworst)"
set RC_CORN_STA                 "(rcbest rcworst)"
set REPORTS_DIR                 "reports"
set LOG_DIR                     "log"

########################################################################################
# Library Files
########################################################################################
set TARGET_LIBRARY_FILES        "$PROJECT_BASE/LIB/slow_vdd1v0_basiccells.lib"
set MIN_LIBRARY_FILES           "$PROJECT_BASE/LIB/fast_vdd1v0_basicCells.lib"
set LIBRARY_LEF_FILES           "$PROJECT_BASE/LEF/gsclib045_tech.lef $PROJECT_BASE/LEF/gsclib045_macro.lef"

set CAP_TABLE_MAX_FILE          ""
set CAP_TABLE_MIN_FILE          ""
set CAP_TABLE_TYP_FILE          "$PROJECT_BASE/Captable/cln28hpl_1p10m+alrdl_5x2yu2yz_typical.capTbl"

set QRC_TECH_FILE_MAX           ""
set QRC_TECH_FILE_MIN           ""
set QRC_TECH_FILE_TYPICAL       "$PROJECT_BASE/QRC_tech/gpdk045.tch"

########################################################################################
# Floorplan
########################################################################################
set ASPECT_RATIO                1
set CORE_UTILIZATION            0.7
set MIN_ROUTING_LAYER           "1"
set MAX_ROUTING_LAYER           "11"
set GDS2MAP                     ""
set GDS_FILES                   ""

#setDesignMode -process $PROCESS_NODE

set FILLER_CELLS {}

########################################################################################
# Timing Parameters
########################################################################################
set MAX_TRANSITION_DATA         1.5
set MAX_TRANSITION_CLOCK        0.75
set MAX_FANOUT                  20
set MAX_CAP                     0.1
set SOURCE_MAXCAP               2.00
set TARGET_SKEW                 0.250
set MAX_WIRELENGTH              500
set SETUP_CLOCK_UNCERTAINTY     0.5
set HOLD_CLOCK_UNCERTAINTY      0.07
set CTS_TOP_ROUTING_LAYER       11
set CTS_BOTTOM_ROUTING_LAYER    1

set IS_SCAN_AVAILABLE           0
set IS_NETLIST_ECO              "0"
set ECO_DESIGN_DIR              ""
set ECO_NETLIST                 ""
set FE_DESIGN_LIBRARY           "DESIGN"

puts "RM-info: Completed script.. [info script]"
