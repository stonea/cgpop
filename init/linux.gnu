#
# File:  linux.gnu
#
# The commenting in this file is intended for occasional maintainers who 
# have better uses for their time than learning "make", "awk", etc.  There 
# will someday be a file which is a cookbook in Q&A style: "How do I do X?" 
# is followed by something like "Go to file Y and add Z to line NNN."
#
FC = gfortran 
LD = gfortran 
CC = gcc
Cp = /bin/cp
Cpp = /usr/bin/cpp -P -traditional-cpp
AWK = /usr/bin/gawk
ABI = 
COMMDIR = serial
 
#  Enable MPI library for parallel code, yes/no.

MPI = no

# Adjust these to point to where netcdf is installed

NETCDFINC = -I$(NETCDF_DIR)/include
NETCDFLIB = -L$(NETCDF_DIR)/lib 

PIO = ../pio
#PIOINCS = -I../$(PIO)/pio
#PIOLIBS = -L$(PIO)/pio -l pio
PIOINCS =
PIOLIBS =

#  Enable trapping and traceback of floating point exceptions, yes/no.
#  Note - Requires 'setenv TRAP_FPE "ALL=ABORT,TRACE"' for traceback.

TRAP_FPE = no

#------------------------------------------------------------------
#  precompiler options
#------------------------------------------------------------------

Cpp_opts = $(DCOUPL)


Cpp_opts := $(Cpp_opts) -DPOSIX
 
#----------------------------------------------------------------------------
#
#                           C Flags
#
#----------------------------------------------------------------------------
 
CFLAGS = 


ifeq ($(OPTIMIZE),yes)
  CFLAGS := $(CFLAGS) 
else
  CFLAGS := $(CFLAGS) 
endif
 
#----------------------------------------------------------------------------
#
#                           FORTRAN Flags
#
#----------------------------------------------------------------------------
 
FBASE = $(ABI) $(PIOINCS) $(NETCDFINC) -I$(ObjDepDir) 

ifeq ($(TRAP_FPE),yes)
  FBASE := $(FBASE) 
endif

ifeq ($(OPTIMIZE),yes)
  FFLAGS = $(FBASE) -w
else
  FFLAGS = $(FBASE) -w -O0
endif
 
#----------------------------------------------------------------------------
#
#                           Loader Flags and Libraries
#
#----------------------------------------------------------------------------
 
LDFLAGS = $(ABI) -O3
 
LIBS = $(PIOLIBS) $(NETCDFLIB)
 
ifeq ($(MPI),yes)
  LIBS := $(LIBS) 
endif

ifeq ($(TRAP_FPE),yes)
  LIBS := $(LIBS) 
endif
 
#LDLIBS = $(TARGETLIB) $(LIBRARIES) $(LIBS)
LDLIBS =  $(LIBS) -lnetcdff -lnetcdf
 
#----------------------------------------------------------------------------
#
#                           Explicit Rules for Compilation Problems
#
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#
#                           Implicit Rules for Compilation
#
#----------------------------------------------------------------------------
 
# Cancel the implicit gmake rules for compiling
%.o : %.f
%.o : %.f90
%.o : %.c

%.o: %.f
	@echo LINUX Compiling with implicit rule $<
	@$(FC) $(FFLAGS) -c $<
	@if test -f *.mod; then mv -f *.mod $(ObjDepDir); fi
 
%.o: %.f90
	@echo LINUX Compiling with implicit rule $<
	@$(FC) $(FFLAGS) -c $<
	@if test -f *.mod; then mv -f *.mod $(ObjDepDir); fi
 
%.o: %.c
	@echo LINUX Compiling with implicit rule $<
	@$(CC) $(Cpp_opts) $(CFLAGS) -c $<

#----------------------------------------------------------------------------
#
#                           Implicit Rules for Dependencies
#
#----------------------------------------------------------------------------
 
ifeq ($(OPTIMIZE),yes)
  DEPSUF = .do
else
  DEPSUF = .d
endif

# Cancel the implicit gmake rules for preprocessing

%.c : %.C
%.o : %.C

%.f90 : %.F90
%.o : %.F90

%.f : %.F
%.o : %.F

%.h : %.H
%.o : %.H

# Preprocessing  dependencies are generated for Fortran (.F, F90) and C files
$(SrcDepDir)/%$(DEPSUF): %.F
	@echo 'LINUX Making depends for preprocessing' $<
	echo $(Cpp) $(Cpp_opts) $< $(TOP)/compile/$*.f
	$(Cpp) $(Cpp_opts) $< >$(TOP)/compile/$*.f
	@echo '$(*).f: $(basename $<)$(suffix $<)' > $(SrcDepDir)/$(@F)

$(SrcDepDir)/%$(DEPSUF): %.F90
	@echo 'LINUX Making depends for preprocessing' $<
	@$(Cpp) $(Cpp_opts) $< >$(TOP)/compile/$*.f90
	@echo '$(*).f90: $(basename $<)$(suffix $<)' > $(SrcDepDir)/$(@F)

$(SrcDepDir)/%$(DEPSUF): %.C
	@echo 'LINUX Making depends for preprocessing' $<
#  For some reason, our current Cpp options are incorrect for C files.
#  Therefore, let the C compiler take care of #ifdef's, etc.  Just copy.
#	@$(Cpp) $(Cpp_opts) $< >$(TOP)/compile/$*.c
	@$(Cp) $< $(TOP)/compile/$*.c
	@echo '$(*).c: $(basename $<)$(suffix $<)' > $(SrcDepDir)/$(@F)

# Compiling dependencies are generated for all normal .f files
$(ObjDepDir)/%$(DEPSUF): %.f
	@if test -f $(TOP)/compile/$*.f;  \
       then : ; \
       else $(Cp) $< $(TOP)/compile/$*.f; fi
	@echo 'LINUX Making depends for compiling' $<
	@$(AWK) -f $(TOP)/fdepends.awk -v NAME=$(basename $<) -v ObjDepDir=$(ObjDepDir) -v SUF=$(suffix $<) -v DEPSUF=$(DEPSUF) $< > $(ObjDepDir)/$(@F)

# Compiling dependencies are generated for all normal .f90 files
$(ObjDepDir)/%$(DEPSUF): %.f90
	@if test -f $(TOP)/compile/$*.f90;  \
       then : ; \
       else $(Cp) $< $(TOP)/compile/$*.f90; fi
	@echo 'LINUX Making depends for compiling' $<
	@$(AWK) -f $(TOP)/fdepends.awk -v NAME=$(basename $<) -v ObjDepDir=$(ObjDepDir) -v SUF=$(suffix $<) -v DEPSUF=$(DEPSUF) $< > $(ObjDepDir)/$(@F)

# Compiling dependencies are also generated for all .c files, but 
# locally included .h files are not treated.  None exist at this 
# time.  The two .c files include only system .h files with names 
# delimited by angle brackets, "<...>"; these are not, and should 
# not, be analyzed.  If the c programming associated with this code 
# gets complicated enough to warrant it, the file "cdepends.awk" 
# will need to test for includes delimited by quotes.
$(ObjDepDir)/%$(DEPSUF): %.c
	@if test -f $(TOP)/compile/$*.c;  \
       then : ; \
       else $(Cp) $< $(TOP)/compile/$*.c; fi
	@echo 'LINUX Making depends for compiling' $<
	@echo '$(*).o $(ObjDepDir)/$(*)$(DEPSUF): $(basename $<)$(suffix $<)' > $(ObjDepDir)/$(@F)
