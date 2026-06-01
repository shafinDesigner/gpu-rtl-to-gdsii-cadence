.PHONY: synth init_design impl clean all

BLOCK = gpu

FE_EXEC = innovus

WOPTIONS = -overwrite -64

REPORT_DIR = reports

LOG = log

default:
	@echo "make synth"
	@echo "make init_design"
	@echo "make impl"
	@echo "make all"

all: impl

synth:
	cd .. && genus -files scripts/genus.tcl

init_design: synth
	mkdir -p $(REPORT_DIR) $(LOG) DESIGN
	$(FE_EXEC) $(WOPTIONS) -win \
	-init scripts/init_design.tcl \
	-log $(LOG)/init_design.log

impl: init_design
	mkdir -p $(REPORT_DIR) $(LOG) DESIGN
	$(FE_EXEC) $(WOPTIONS) -win \
	-init scripts/impl.tcl \
	-log $(LOG)/impl.log

clean:
	rm -rf log/*
	rm -rf reports/*
	rm -rf DESIGN/*
