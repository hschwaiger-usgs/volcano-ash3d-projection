##############################################################################
#  Makefile for libprojection.a
#
#    User-specified flags are in this top block
#
###############################################################################

#      This file is a component of the volcanic ash transport and dispersion model Ash3d,
#      written at the U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov),
#      Larry G. Mastin (lgmastin@usgs.gov), and Roger P. Denlinger (roger@usgs.gov).

#      The model and its source code are products of the U.S. Federal Government and therefore
#      bear no copyright.  They may be copied, redistributed and freely incorporated 
#      into derivative products.  However as a matter of scientific courtesy we ask that
#      you credit the authors and cite published documentation of this model (below) when
#      publishing or distributing derivative products.

#      Schwaiger, H.F., Denlinger, R.P., and Mastin, L.G., 2012, Ash3d, a finite-
#         volume, conservative numerical model for ash transport and tephra deposition,
#         Journal of Geophysical Research, 117, B04204, doi:10.1029/2011JB008968. 

#      We make no guarantees, expressed or implied, as to the usefulness of the software
#      and its documentation for any purpose.  We assume no responsibility to provide
#      technical support to users of this software.

#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran , ifort
#    This variable cannot be left blank
#      
SYSTEM = gfortran
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#    This variable cannot be left blank

#RUN = DEBUG
#RUN = PROF
RUN = OPT
#
INSTALLDIR=/opt/USGS

###############################################################################
#####  END OF USER SPECIFIED FLAGS  ###########################################
###############################################################################



###############################################################################
###############################################################################

###############################################################################
##########  GNU Fortran Compiler  #############################################
ifeq ($(SYSTEM), gfortran)
    FCHOME=/usr
    FC = /usr/bin/gfortran
    COMPINC = -I./ -I$(FCHOME)/include -I$(FCHOME)/lib64/gfortran/modules
    COMPLIBS = -L./ -L$(FCHOME)/lib64

    LIBS = $(COMPLIBS) $(COMPINC)

# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS = -O0 -g3 -Wall -Wextra -fimplicit-none  -Wall  -Wline-truncation  -Wcharacter-truncation  -Wsurprising  -Waliasing  -Wimplicit-interface  -Wunused-parameter  -fwhole-file  -fcheck=all  -std=f2008  -pedantic  -fbacktrace -Wunderflow -ffpe-trap=invalid,zero,overflow -fdefault-real-8
endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g -pg -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
endif
      # Preprocessing flags
    FPPFLAGS = -x f95-cpp-input
    EXFLAGS =
endif
###############################################################################

LIB = libprojection.a


###############################################################################
# TARGETS
###############################################################################
lib: $(LIB)

libprojection.a: projection.f90 projection.o makefile
	ar rcs libprojection.a projection.o
projection.o: projection.f90 makefile
	./get_version.sh
	$(FC) $(FFLAGS) $(EXFLAGS) $(LIBS) -c projection.f90
project_for: project.F90 libprojection.a  makefile
	$(FC) $(FPPFLAGS) -DFORWARD $(FFLAGS) $(EXFLAGS) -o project_for project.F90 $(LIBS) -lprojection
project_inv: project.F90 libprojection.a makefile
	$(FC) $(FPPFLAGS) -DINVERSE $(FFLAGS) $(EXFLAGS) -o project_inv project.F90 $(LIBS) -lprojection

all: lib tools

lib: libprojection.a

tools: project_inv project_for makefile
	
check: libprojection.a project_inv project_for makefile
	./check.sh
clean:
	rm -f projection.o
	rm -f *.mod
	rm -f lib*.a
	rm -f project_for
	rm -f project_inv

install:
	install -d $(INSTALLDIR)/lib/
	install -d $(INSTALLDIR)/include/
	install -d $(INSTALLDIR)/bin
	install -m 644 libprojection.a $(INSTALLDIR)/lib/
	install -m 644 projection.mod $(INSTALLDIR)/include/
	install -m 775 project_for $(INSTALLDIR)/bin
	install -m 775 project_inv $(INSTALLDIR)/bin

uninstall:
	rm -f $(INSTALLDIR)/lib/$(LIB)
	rm -f $(INSTALLDIR)/include/projection.mod
	rm -f $(INSTALLDIR)/bin/project_for
	rm -f $(INSTALLDIR)/bin/project_inv

