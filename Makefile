# Top level make file for building PandABox Slow FPFA image

TOP := $(CURDIR)

# Need bash for the source command in Xilinx settings64.sh
SHELL = /bin/bash

# The following symbols MUST be defined in the CONFIG file before being used.
PANDA_ROOTFS = $(error Define PANDA_ROOTFS in CONFIG file)
ISE = $(error Define ISE in CONFIG file)

# Build defaults that can be overwritten by the CONFIG file if required
PYTHON = python
SPHINX_BUILD = sphinx-build
MAKE_ZPKG = $(PANDA_ROOTFS)/make-zpkg
MAKE_GITHUB_RELEASE = $(PANDA_ROOTFS)/make-github-release.py

BUILD_DIR = $(TOP)/build
DEFAULT_TARGETS = zpkg

# The CONFIG file is required.  If not present, create by copying CONFIG.example
# and editing as appropriate.
include CONFIG

SLOW_BIN = $(BUILD_DIR)/slow_top.bin

BITS_PREREQ += slow_fpga

# Store the git hash in top-level build directory 
VER = $(BUILD_DIR)/VERSION

#default: $(DEFAULT_TARGETS)
#.PHONY: default

# Build SlowFPGA Firmware target

$(SLOW_BIN): $(TOP)/SlowFPGA.make $(VER) | $(BUILD_DIR) update_VER
	echo building SlowFPGA
	source $(ISE)  &&  \
	  $(MAKE) -C $(BUILD_DIR) -f $< \
	  TOP=$(TOP) SHA=$(SHA) bin

slow_fpga : $(SLOW_BIN)
.PHONY: slow_fpga

$(BUILD_DIR): 
	mkdir -p $(BUILD_DIR)

# ------------------------------------------------------------------------------
# Version symbols for FPGA bitstream generation etc

# Something like 0.1-1-g5539563-dirty
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)
# 8 if dirty, 0 if clean
DIRTY_PRE = $(shell \
    python -c "print(8 if '$(GIT_VERSION)'.endswith('dirty') else 0)")
# Something like 85539563
SHA := $(DIRTY_PRE)$(shell git rev-parse --short=7 HEAD)

# Trigger rebuild of FPGA targets based on change in the git hash wrt hash stored in build dir
# If the stored hash value does not exist, or disagrees with the present
# value, or contains the 'dirty' string then the FPGA build will be considered
# out-of-date.

.PHONY: update_VER
update_VER :
ifeq ($(wildcard $(VER)), ) 
	echo $(SHA) > $(VER)    
else
	if [[ $(SHA) != `cat $(VER)` ]] || [[ $(SHA) == 8* ]]; \
	then echo $(SHA) > $(VER); \
	fi
endif
