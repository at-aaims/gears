.PHONY: help

ARCH ?= $(shell uname -m)
CONDA_ENV ?= ~/.gears.$(ARCH)
INSTALL_PATH ?= ~/.gears.$(ARCH)
APP_PATH ?= $(INSTALL_PATH)
VERSION ?= $(shell cat ./VERSION)
VERSION_POSTFIX ?=
PIP_OPTS ?=

help:
	-@echo ""
	-@echo "[Jupyter on HPC environment - $(VERSION)]"
	-@echo ""
	-@echo "development:"
	-@echo "  init|fini: initialize / finalize development environment"
	-@echo "  env: printout environment to activate the conda virtualenv"
	-@echo ""
	-@echo "environment:"
	-@echo "  ARCH=$(ARCH)"
	-@echo "  APP_PATH=$(APP_PATH)"
	-@echo "  CONDA_ENV=$(CONDA_ENV)"
	-@echo "  conda activate $(CONDA_ENV) <- activate development environment"
	-@echo ""

.PHONY: .deploy .integrate-test
.deploy:
	@if [ ! -e $(APP_PATH) ]; then \
		conda env create -p $(APP_PATH) -f ./environment.yml; \
	else \
		conda env update -p $(APP_PATH) -f ./environment.yml; \
	fi


.PHONY: init fini
init:
	-@echo "@ initializing development environment"
	@APP_PATH=$(CONDA_ENV) PIP_OPTS=-e make -C . .deploy
	-@echo "@ conda virtual environment setup finished"
	-@echo ""

fini:
	-rm -rf $(CONDA_ENV)

.PHONY: test test-verbose
test:
	conda run -p $(CONDA_ENV) pytest -m 'not integrate'

test-verbose:
	conda run -p $(CONDA_ENV) pytest -m 'not integrate' -sv

#
# Andes cluster
#

.PHONY: andes-lab
andes-lab:
	@echo "@ Spawning jupyterlab"
	./bin/jupyter.sh andes

