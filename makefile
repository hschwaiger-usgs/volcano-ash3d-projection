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

#      Sequence of commands:
#      "make"  compiles the libprojection.a library
#      "make all" builds the library, and the tools executables
#      "make check" runs test cases and compares with proj4
#      "make install" copies the library to the install location
#                        e.g. /opt/USGS
#
#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran , ifort , aocc , nvhpc
#    This variable cannot be left blank
#
SYSTEM = gfortran
SYSINC = make_$(SYSTEM).inc
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#      OPT   : includes optimizations flags for fastest runtime
#    This variable cannot be left blank

#RUN = DEBUG
#RUN = PROF
RUN = OPT

INSTALLDIR=/opt/USGS

###############################################################################
#####  END OF USER SPECIFIED FLAGS  ###########################################
###############################################################################

###############################################################################
# Import the compiler-specific include file.  Currently one of:
#  GNU Fortran Compiler
#  Intel Fortran Compiler
#  AMD Optimizing C/C++/Fortran Compiler (aocc)
#  Nvidia HPC Fortran Compiler (ncfortran)
include $(SYSINC)
###############################################################################

LIB = libprojection.a

EXEC = \
 project_for \
 project_inv

###############################################################################
# TARGETS
###############################################################################
lib: $(LIB)

libprojection.a: projection.F90 projection.o makefile $(SYSINC)
	ar rcs libprojection.a projection.o
projection.o: projection.F90 makefile $(SYSINC)
	bash get_version.sh
	$(FC) $(FPPFLAGS) $(FFLAGS) $(EXFLAGS) $(LIBS) -c projection.F90
project_for: project.F90 libprojection.a  makefile $(SYSINC)
	$(FC) $(FPPFLAGS) -DFORWARD $(FFLAGS) $(EXFLAGS) -o project_for project.F90 $(LIBS) -lprojection
project_inv: project.F90 libprojection.a makefile $(SYSINC)
	$(FC) $(FPPFLAGS) -DINVERSE $(FFLAGS) $(EXFLAGS) -o project_inv project.F90 $(LIBS) -lprojection

all: lib tools

lib: libprojection.a

tools: project_inv project_for makefile $(SYSINC)
	
check: libprojection.a project_inv project_for makefile $(SYSINC)
	bash check.sh
clean:
	rm -f projection.o
	rm -f *.mod
	rm -f lib*.a
	rm -f project_for
	rm -f project_inv

install:
	install -d $(INSTALLDIR)/lib/
	install -d $(INSTALLDIR)/include/
	install -d $(INSTALLDIR)/bin/
	install -m 644 $(LIB) $(INSTALLDIR)/lib/
	install -m 644 projection.mod $(INSTALLDIR)/include/
	install -m 755 $(EXEC) $(INSTALLDIR)/bin/

uninstall:
	rm -f $(INSTALLDIR)/lib/$(LIB)
	rm -f $(INSTALLDIR)/include/projection.mod
	rm -f $(INSTALLDIR)/bin/project_for
	rm -f $(INSTALLDIR)/bin/project_inv

