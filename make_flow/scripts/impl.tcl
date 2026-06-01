puts "RM-info: Starting Impl [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

if { ! [file exists setup.tcl] } {
puts "setup file setup.tcl not found. Exit ....."
exit
}

source setup.tcl

restoreDesign ${DESIGN_LIBRARY}/init_design.dat $DESIGN_NAME

set delaycal_use_default_delay_limit 1000

globalNetConnect VDD -type pgpin -pin VDD -inst *

globalNetConnect VSS -type pgpin -pin VSS -inst *

applyGlobalNets

setPlaceMode -clkGateAware true

setPlaceMode -softGuide true

setPlaceMode -maxDensity 0.70

setPlaceMode -place_global_cong_effort high

placeDesign -noPrePlaceOpt

setOptMode -fixCap true

setOptMode -fixTran true

setOptMode -fixFanoutLoad true

optDesign -preCTS

saveDesign ${DESIGN_LIBRARY}/preCTS

set_ccopt_property target_max_trans 0.2

set_ccopt_property inverter_cells {
CLKINVX1 CLKINVX2 CLKINVX3
CLKINVX4 CLKINVX6 CLKINVX8
}

set_ccopt_property buffer_cells {
CLKBUFX2 CLKBUFX3 CLKBUFX4
CLKBUFX6 CLKBUFX8
}

create_ccopt_clock_tree_spec -file ccopt.spec

ccopt_design

setAnalysisMode -analysisType onChipVariation

saveDesign ${DESIGN_LIBRARY}/postCTS

routeDesign

saveDesign ${DESIGN_LIBRARY}/postRoute

optDesign -postRoute

optDesign -postRoute -hold

timeDesign -postRoute

summaryReport -outdir ${REPORTS_DIR}/impl_summary

defOut def/gpu_postroute.def

saveNetlist ver/gpu_postroute.v

puts "RM-info: Completed Impl [clock format [clock seconds] -format %H:%M:%S_%d/%m/%y]"

