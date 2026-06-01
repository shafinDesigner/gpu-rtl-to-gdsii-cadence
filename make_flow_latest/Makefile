BLOCK = gpu

DATE = $(shell date +"%Y%m%d%H%M")

## Work directories (all relative to make_flow_latest/)
REPORT_DIR	= reports
LOG		= log
LSF		= 
SYN_EXEC	= genus
LEC_EXEC	= lec -lpgxl
FE_EXEC		= innovus
OPTIONS		= -overwrite -64
WOPTIONS	= -overwrite -64

#########################################################################################
# Targets — 'make all' runs full flow: syn → init → place → cts → route
#########################################################################################

all: route_design
	@echo "#### Full flow complete at `date '+%D %T'` ####"

syn_design:
	@echo ""
	@echo "#### Start syn_design at `date '+%D %T'` ####"
	@mkdir -p $(REPORT_DIR) $(LOG) SYN/outputs SYN/reports SYN/logs_genus
	$(LSF) $(SYN_EXEC) $(WOPTIONS) -files scripts/syn_design.tcl -log $(LOG)/syn_design.log | tee $(LOG)/syn_design.log_$(DATE)
	@touch syn_design
	@echo "#### End syn_design at `date '+%D %T'` ####"

lec_design: syn_design
	@echo ""
	@echo "#### Start lec_design at `date '+%D %T'` ####"
	@mkdir -p $(REPORT_DIR) $(LOG) LEC/reports
	$(LSF) $(LEC_EXEC) -dofile scripts/lec_design.do -log $(LOG)/lec_design.log | tee $(LOG)/lec_design.log_$(DATE)
	@touch lec_design
	@echo "#### End lec_design at `date '+%D %T'` ####"

init_design: syn_design
	@echo ""
	@echo "#### Start init_design at `date '+%D %T'` ####"
	@mkdir -p $(REPORT_DIR) $(LOG) DESIGN reports/init_design
	$(LSF) $(FE_EXEC) $(WOPTIONS) -init scripts/init_design.tcl -log $(LOG)/init_design.log | tee $(LOG)/init_design.log_$(DATE)
	@./scripts/gen_runTime.csh init_design
	@touch init_design
	@echo "#### End init_design at `date '+%D %T'` ####"

place_opt: init_design
	@ls init_design
	@rm -rf ver/placed def/placed
	@echo ""
	@echo "#### Start place_opt at `date '+%D %T'` ####"
	@mkdir -p $(REPORT_DIR) $(LOG) ver/placed def/placed reports/place_opt data
	$(LSF) $(FE_EXEC) $(WOPTIONS) -init scripts/place_opt.tcl -log $(LOG)/place_opt.log | tee $(LOG)/place_opt.log_$(DATE)
	@./scripts/gen_runTime.csh place_opt
	@touch place_opt
	@echo "#### End place_opt at `date '+%D %T'` ####"

clock_opt: place_opt
	@ls place_opt
	@rm -rf ver/postCTS def/postCTS
	@echo ""
	@echo "#### Start clock_opt at `date '+%D %T'` ####"
	@mkdir -p $(REPORT_DIR) $(LOG) ver/postCTS def/postCTS reports/clock_opt data
	$(LSF) $(FE_EXEC) $(WOPTIONS) -init scripts/clock_opt.tcl -log $(LOG)/clock_opt.log | tee $(LOG)/clock_opt.log_$(DATE)
	@./scripts/gen_runTime.csh clock_opt
	@touch clock_opt
	@echo "#### End clock_opt at `date '+%D %T'` ####"

route_design: clock_opt
	@ls clock_opt
	@rm -rf ver/route_design def/route_design
	@echo ""
	@echo "#### Start route_design at `date '+%D %T'` ####"
	@mkdir -p $(REPORT_DIR) $(LOG) ver/route_design def/route_design reports/route_design
	$(LSF) $(FE_EXEC) $(OPTIONS) -init scripts/route_design.tcl -log $(LOG)/route_design.log | tee $(LOG)/route_design.log_$(DATE)
	@./scripts/gen_runTime.csh route_design
	@touch route_design
	@echo "#### End route_design at `date '+%D %T'` ####"

clean:
	@rm -f syn_design lec_design init_design place_opt clock_opt route_design
	@echo "Ready for fresh run"
