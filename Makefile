COV_REP := $(shell find run_dir -name 'coverage.dat')
SPEC_TEST ?= -k test_ravenoc_basic['vanilla']

# Docker image used for test and build (tox+verilator and openlane pre-installed)
DOCKER_IMAGE := aignacio/ravenoc

# Mount current dir into Docker
RUN_CMD := docker run --rm --name ravenoc \
	-v $(abspath .):/ravenoc -w /ravenoc $(DOCKER_IMAGE)

# OpenLane GDS flow
GDS_FLOW_DIR := openlane
DESIGN_NAME := ravenoc
OPENLANE_RUN := $(GDS_FLOW_DIR)/runs/$(DESIGN_NAME)

.PHONY: run cov clean all gds push-gds

all: run
	@echo "> Test run finished, please check the terminal"

run:
	$(RUN_CMD) tox -- $(SPEC_TEST)

coverage.info:
	verilator_coverage $(COV_REP) --write-info coverage.info

cov: coverage.info
	genhtml $< -o output_lcov

clean:
	$(RUN_CMD) rm -rf run_dir $(OPENLANE_RUN)

# 🔽 Run the RTL-to-GDS flow via OpenLane

gds:
	$(RUN_CMD) bash -c "apt-get update && apt-get install -y tcllib && cd openlane && ./flow.tcl -design ravenoc"

# 🔼 Push the GDS to a GitHub artifacts folder or gh-pages (stub — replace with actual logic)
push-gds:
	git add $(OPENLANE_RUN)/results
	git commit -m 'Add latest GDS'
	git push origin main  # or gh-pages or artifacts branch

