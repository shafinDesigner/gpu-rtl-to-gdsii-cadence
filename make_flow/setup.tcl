puts "RM-info: Starting script.. [info script]"

set DESIGN_NAME                 "gpu"

set LIB_USED                    ""

set DESIGN_FLOW                 "asic"

set INIT_DESIGN_INPUT           "verilog"

set VERILOG_NETLIST_FILE        "input/gpu_netlist.v"

set SDC_FILE                    "../Constraints/constraints_top.sdc"

set FUNC_SDC                    "../Constraints/constraints_top.sdc"

set INIT_MMMC_FILE              "input/mmmc.view"

set DEF_FILE                    "def/gpu_floorplan.def"

set SCAN_DEF_FILE               ""

set ADD_TAPCELL                0

set TAP_DISTANCE               50

set REPORTS_DIR                 "reports"

set LOG_DIR                     "log"

set DESIGN_LIBRARY              "DESIGN"

set TARGET_LIBRARY_FILES        "../LIB/slow_vdd1v0_basiccells.lib"

set MIN_LIBRARY_FILES           "../LIB/fast_vdd1v0_basicCells.lib"

set LIBRARY_LEF_FILES           "../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef"

set CAP_TABLE_MAX_FILE          ""

set CAP_TABLE_MIN_FILE          ""

set CAP_TABLE_TYP_FILE          "../Captable/cln28hpl_1p10m+alrdl_5x2yu2yz_typical.capTbl"

set QRC_TECH_FILE_MAX           ""

set QRC_TECH_FILE_MIN           ""

set QRC_TECH_FILE_TYPICAL       "../QRC_tech/gpdk045.tch"

set ASPECT_RATIO                1

set CORE_UTILIZATION            0.5

set IO_FILE                     ""

set MIN_ROUTING_LAYER           "1"

set MAX_ROUTING_LAYER           "10"

set GDS2MAP                     ""

set GDS_FILES                   ""

set FILLER_CELLS               {}

set MAX_TRANSITION_DATA         0.2

set MAX_TRANSITION_CLOCK        0.05

set MAX_FANOUT                  20

set MAX_CAP                     0.1

set SOURCE_MAXCAP               2.00

set TARGET_SKEW                 0.05

set MAX_WIRELENGTH              500

set SETUP_CLOCK_UNCERTAINTY     0.05

set HOLD_CLOCK_UNCERTAINTY      0.02

set CTS_TOP_ROUTING_LAYER       10

set CTS_BOTTOM_ROUTING_LAYER    1

set IS_SCAN_AVAILABLE           0

set IS_NETLIST_ECO              "0"

set ECO_DESIGN_DIR              ""

set ECO_NETLIST                 ""

puts "RM-info: Completed script..[info script]"

