SHELL := /bin/bash


PYTHON_SHORT_VERSION := $(shell echo $(PYTHON_VERSION) | grep -o '[0-9].[0-9]*')

ifeq ($(USE_SYSTEM_PYTHON), true)
	PYTHON_PACKAGE_PATH:=$(shell python -c "import sys; print(sys.path[-1])")
	PYTHON_ENV :=
	PYTHON := python
	PYTHON_VENV :=
else
	PYTHON_PACKAGE_PATH:=.venv/lib/python$(PYTHON_SHORT_VERSION)/site-packages
	PYTHON_ENV :=  . .venv/bin/activate &&
	PYTHON := . .venv/bin/activate && python
	PYTHON_VENV := .venv
endif

# Used to confirm that pip has run at least once
PACKAGE_CHECK:=$(PYTHON_PACKAGE_PATH)/build
PYTHON_DEPS := $(PACKAGE_CHECK)

#
# Make the environement
#

.PHONY: env
env: .venv pip

.venv:
	
	$(PYTHON) -m pip install maturin
	
.PHONY: pip
pip: $(PYTHON_VENV)
	$(PYTHON) -m pip install -e .[dev]

#
# Formatting
#

.PHONY: check
check: ruff_fixes mypy black_fixes dapperdata_fixes tomlsort_fixes

.PHONY: black_fixes
black_fixes:
	$(PYTHON) -m ruff format .

.PHONY: mypy
mypy:
	$(PYTHON) -m mypy python/*

.PHONY: ruff_fixes
ruff_fixes:
	$(PYTHON) -m ruff check . --fix

.PHONY: dapperdata_fixes
dapperdata_fixes:
	$(PYTHON) -m dapperdata.cli pretty . --no-dry-run

.PHONY: tomlsort_fixes
tomlsort_fixes:
	$(PYTHON_ENV) toml-sort $$(find . -not -path "./.venv/*" -name "*.toml") -i


#
# Testing
#


.PHONY: test
test:
	$(PYTHON) -m coverage run --branch --source src -m unittest discover
	@$(PYTHON) -m coverage report -m


#
# Packaging
#

.PHONY: build
build: $(PACKAGE_CHECK)
	$(PYTHON) -m build
