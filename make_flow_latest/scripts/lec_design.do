// === Set the log file name === //
set log file ./LEC/gpu_lec.log -replace

// === Set the library === //
set PROJECT_BASE "/home/user_77/backup_extract/my_project/project"
read library -liberty -both $PROJECT_BASE/LIB/slow_vdd1v0_basiccells.lib

// === Read the golden RTL design === //
read design -verilog -golden \
    $PROJECT_BASE/src/alu.v \
    $PROJECT_BASE/src/controller.v \
    $PROJECT_BASE/src/core.v \
    $PROJECT_BASE/src/dcr.v \
    $PROJECT_BASE/src/decoder.v \
    $PROJECT_BASE/src/dispatch.v \
    $PROJECT_BASE/src/fetcher.v \
    $PROJECT_BASE/src/gpu.v \
    $PROJECT_BASE/src/lsu.v \
    $PROJECT_BASE/src/pc.v \
    $PROJECT_BASE/src/registers.v \
    $PROJECT_BASE/src/scheduler.v

// === Read the revised gate-level netlist === //
read design -verilog -revised ./SYN/outputs/gpu_netlist.v

// === Set Top Module === //
set root module gpu -both

// === Set constraints === //
add pin constraints 0 SE  -both
add ignored inputs scan_in -both
add ignored outputs scan_out -both
set undriven signal 0 -both
set compare option -seq_constant
set flatten model -all

// === Run LEC === //
set system mode lec
set compare effort high
set mapping method -name first

map key points
compare

// === Reports === //
report compare data        > ./LEC/reports/compare.rpt
report compare data -noneq > ./LEC/reports/nonequ.rpt
report unmapped points     > ./LEC/reports/unmapped.rpt
