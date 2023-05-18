#!/bin/bash

# This bash script is run for the target 'make check'
# The script iterates through several projections used by forecast products and
# tests the accuracy of routines via the script check_proj4.sh
# The program 'bc' is required for testing so a hard stop is placed at the
# beginning of this script if this program is not installed.

rc=0
echo "Looking for bc"
which bc > /dev/null
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
  echo "Error: Could not find bc in your path"
  echo "       bc is needed to verify accuracy of routines."
  exit 1
fi

which proj > /dev/null
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
  echo "Warning: proj4 not found."
  echo "Testing will only verify that _for and _inv are inverses"
  echo "If you install proj4, testing will also verify results against proj4."
fi


###############################################################################
#        ! Polar stereographic
echo "-----------------------------------------------------------"
echo "  Testing Polar stereographic projections"
echo "    NAM 3-km (grids 91 and 198)"
./check_proj4.sh 181.42899 40.5301 0 1 210.0 90.0 0.933 6371.229
./check_proj4.sh 266.30820 63.9757 0 1 210.0 90.0 0.933 6371.229
echo "    NAM 90-km (grids 104)"
./check_proj4.sh 220.524994 -0.268780380 0 1 -105.0 90.0 0.933 6371.229
./check_proj4.sh 345.401520 32.7462044 0 1 -105.0 90.0 0.933 6371.229
echo "    NAM 45-km (grids 216)"
./check_proj4.sh 187.0 30.0 0 1 -135.0 90.0 0.933 6371.229
./check_proj4.sh 297.15 70.111 0 1 -135.0 90.0 0.933 6371.229
echo "    WRF Antarctic grid"
./check_proj4.sh 167.1523 -77.5293 0 1 180.0 -90.0 0.972759 6370.0
echo "-----------------------------------------------------------"
###############################################################################


###############################################################################
#        ! Lambert conformal conic (NARR, NAM218, NAM221)
echo "-----------------------------------------------------------"
echo "  Testing Lambert conformal conic projections"
echo "    NAM CONUS (grids 218, 221)"
./check_proj4.sh 226.541 12.190 0 4 262.5 38.5 38.5 38.5 6371.229
./check_proj4.sh 226.541 12.190 0 4 262.5 38.5 38.5 38.5 6371.229

#  NAM 32-km Lambert Conformal used by NARR (used Met_Re=6367.470, not 6371.229)
echo "    NARR "
./check_proj4.sh 214.50  1.0 0 4 -107.0 50.0 50.0 50.0 6367.47
./check_proj4.sh 357.43 46.352 0 4 -107.0 50.0 50.0 50.0 6367.47
#        ! CONUS 40-km Lambert Conformal
echo "    NAM CONUS (grids 212)"
./check_proj4.sh 226.541 12.190 0 4 265.0 25.0 25.0 25.0 6371.229
./check_proj4.sh 310.615 57.290 0 4 265.0 25.0 25.0 25.0 6371.229
#        ! NAM 32-km Lambert Conformal
echo "    NAM  (grids 221)"
./check_proj4.sh 214.50  1.0 0 4 -107.0 50.0 50.0 50.0 6371.229 
./check_proj4.sh 357.43 46.352 0 4 -107.0 50.0 50.0 50.0 6371.229
echo "-----------------------------------------------------------"

###############################################################################
#        ! Mercator
echo "-----------------------------------------------------------"
echo "  Testing Mercator projections"
#  HI 2.5-km Mercator
echo "    NAM (grids 196)"
./check_proj4.sh 198.475 18.073 0 5 198.475 20.0 6371.229
./check_proj4.sh 206.131 23.088 0 5 198.475 20.0 6371.229
echo "-----------------------------------------------------------"
##############################################################################
