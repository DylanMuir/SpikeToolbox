# Makefile - Makefile for pciaer_stim_mon
# $Id: Makefile 8309 2008-01-30 14:46:03Z dylan $

# Author: Dylan Muir <dylan@ini.phys.ethz.ch>
# Created: 24th February, 2005 (from alavlsi/SW/c/poisson/Makefile)

# -------------------------------------------------------
# Usage: make <all / c / mex / clean>
#
# The commands "make c" and "make mex" will make only the C or MEX versions
# of pciaer_stim_mon respectively.  "make all" will make both, and "make clean"
# will delete any old output binaries.
#
# This makefile requires 'PCIAER_DIR' to be defined in the environment.  This
# variable should contain the path to the PCI-AER system base directory, e.g.
# ~/projects/pciaer.
#
# The makefile variable 'PROGRESS' will turn on progress display within the
# compiled function if set to "-DPROGRESS".
#
# Uncomment to turn ON progress display
PROGRESS = -DPROGRESS

# -------------------------------------------------------


# Default rule
.PHONY = clean all

# Define make process output binaries
EXECUTABLES = pciaer_stim_mon pciaer_stim_mon.mex* pciaer_stim_mon.dll

# Define PCI-AER system directories
LIB_DIR = $(PCIAER_DIR)/lib
DRIVER_DIR = $(PCIAER_DIR)/driver

# Define compiler and linker flags for GCC and MEX
LDFLAGS = -L$(LIB_DIR)
LOADLIBES = -lpciaer -lm
COMFLAGS = -g -I$(DRIVER_DIR) -I$(LIB_DIR) $(PROGRESS)
CFLAGS = -Wall $(COMFLAGS) -DPLATFORM="\"`uname -psr`\""
MEXFLAGS = -argcheck $(COMFLAGS) $(LDFLAGS) $(LOADLIBES) -DPLATFORM="\"\\\"`uname -psr`\\\"\""

# Rule to make all executables for this platform
all: pciaer_stim_mon mex

c: pciaer_stim_mon

pciaer_stim_mon: pciaer_stim_mon.o

mex: pciaer_stim_mon.c
	mex $(MEXFLAGS) pciaer_stim_mon.c

clean:
	rm -f $(EXECUTABLES) core* *.o matlab_crash_dump*

# --- END of Makefile ---
