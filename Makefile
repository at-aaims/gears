.PHONY: help
ARCH ?= $(shell uname -m)
CWD ?= $(shell pwd)

define SHELL_INC
. ./bin/common.sh
endef

CLUSTER_NAME = $(shell $(SHELL_INC); cluster_name)
CONDA ?= /sw/aaims/miniconda3/python3.8/$(ARCH)
CONDA_ENV ?= $(CWD)/.gears.$(CLUSTER_NAME)
APP_PATH ?= $(CONDA_ENV)
VERSION ?= $(shell cat ./VERSION)
VERSION_POSTFIX ?=
PIP_OPTS ?=

help:
	-@echo ""
	-@echo "[Gears: Jupyter on HPC environment - $(VERSION)]"
	-@echo ""
	-@echo "Conda environment:"
	-@echo "  init|fini: initialize / finalize conda environment"
	-@echo "  env: printout environment to activate the conda virtualenv"
	-@echo "  password: jupyter lab password setup"
	-@echo ""
	-@echo "SSH Tunnel setup (laptop to hub.ccs.ornl.gov)"
	-@echo "  ssh-config: Printout an ssh config entry for external connection"
	-@echo ""
	-@echo "Jupyterlab servers on login nodes and the tunnels from hub.ccs.ornl.gov"
	-@echo "  andes-lab[-shutdown]: Spawn or reestablish backend jupyterlab session on andes"
	-@echo "  summit-lab[-shutdown]: Spawn or reestablish backend jupyterlab session on summit"
	-@echo ""
	-@echo "Environment variables:"
	-@echo "  CLUSTER_NAME=$(CLUSTER_NAME)"
	-@echo "  ARCH=$(ARCH)"
	-@echo "  CONDA_ENV=$(CONDA_ENV)"
	-@echo "  conda activate $(CONDA_ENV) <- activate development environment"
	-@echo ""

.PHONY: .deploy .integrate-test
.deploy:
	@if [ ! -e $(APP_PATH) ]; then \
		conda info; \
		conda env create -p $(APP_PATH) -f ./environment.yml; \
	else \
		conda info; \
		conda env update -p $(APP_PATH) -f ./environment.yml; \
	fi


.PHONY: init fini env
init:
	-@echo "@ initializing conda environment"
	@APP_PATH=$(CONDA_ENV) PIP_OPTS=-e make -C . .deploy
	-@echo "@ conda virtual environment setup finished"
	-@echo ""

fini:
	-@echo "@ Removing conda environment"
	-conda env remove -p $(APP_PATH)
	-rm -rf $(CONDA_ENV)

env:
	@echo "conda activate $(CONDA_ENV)"


.PHONY: ssh-config
ssh-config:
	@echo "Host andes-jupyter"
	@echo "  User $(shell whoami)"
	@echo "  LocalForward 38888 $(shell pwd)/run/$(CLUSTER_NAME)/socket"
	@echo "  CanonicalizeHostname yes"

.PHONY: password
password:
	@echo "@ Setting up jupyter server password"
	conda run -p $(CONDA_ENV) jupyter server password


#
# andes cluster
#

.PHONY: andes-lab andes-lab-shutdown
andes-lab:
	@echo "@ Spawning jupyterlab and tunnels"
	@$(SHELL_INC); ./bin/hub-proxy.sh andes

andes-lab-shutdown:
	@echo "@ Shuttind down jupyterlab and tunnels"
	@$(SHELL_INC); ./bin/hub-proxy-shutdown.sh andes

#
# summit cluster
#

.PHONY: summit-lab summit-lab-shutdown
summit-lab:
	@echo "@ Spawning jupyterlab and tunnels"
	$(SHELL_INC); ./bin/hub-proxy.sh summit

summit-lab-shutdown:
	@echo "@ Shuttind down jupyterlab and tunnels"
	$(SHELL_INC); ./bin/hub-proxy-shutdown.sh summit

