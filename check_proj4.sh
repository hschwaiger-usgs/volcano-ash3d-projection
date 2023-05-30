#!/bin/bash

# This script takes as command-line arguments, a lon/lat coordinate followed by the projection
# line.  Then the forward projection is calculated followed by the inverse projection using the
# projected values.  If the forward->inverse do not return the initial values, the test fails.
# Additionally, the forward case is tested against proj4 if that is installed on the system.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

rc=0
which proj > /dev/null
rc=$((rc + $?))
if [[ "$rc" -gt 0 ]] ; then
  HaveProj="T"
else
  HaveProj="F"
fi

rm -f tst1.dat tst2.dat tst3.dat
errthrsh=-3  # 0 -> 1 km; -3 -> 1 m

pt1lon=$1
pt1lat=$2
iLL=$3
ipj=$4
# do error-check on these values

if [[ "$ipj" -eq 1 ]] ; then
 # Polar stereographic
 # PJ_ilatlonflag,PJ_iprojflag,PJ_lam0,PJ_phi0,PJ_k0,PJ_radius_earth
 lon0=$5
 lat0=$6
 k0=$7
 Re=$8
 ./project_for ${pt1lon} ${pt1lat} ${iLL} ${ipj} ${lon0} ${lat0} ${k0} ${Re} > tst1.dat
 pt1x=`cat tst1.dat  | tr -s ' ' | cut -f 2 -d ' '`
 pt1y=`cat tst1.dat  | tr -s ' ' | cut -f 3 -d ' '`
 ./project_inv ${pt1x} ${pt1y} ${iLL} ${ipj} ${lon0} ${lat0} ${k0} ${Re} > tst2.dat
 if [[ "$HaveProj" -eq "T" ]] ; then
   proj +proj=stere +lon_0=${lon0} +lat_0=${lat0} +k_0=${k0} +R=${Re} -f "%.5f" > tst3.dat <<EOF
   ${pt1lon} ${pt1lat}
EOF
 fi
elif [[ "$ipj" -eq 2 ]] ; then
 # Albers Equal Area
 exit
elif [[ "$ipj" -eq 3 ]] ; then
 # UTM
 exit
elif [[ "$ipj" -eq 4 ]] ; then
 # Lambert conformal conic (NARR, NAM218, NAM221)
 # PJ_ilatlonflag,PJ_iprojflag,PJ_lam0, PJ_phi0,PJ_phi1,PJ_phi2,PJ_radius_earth
 lon0=$5
 lat0=$6
 lat1=$7
 lat2=$8
 Re=$9
 ./project_for ${pt1lon} ${pt1lat} ${iLL} ${ipj} ${lon0} ${lat0} ${lat1} ${lat2} ${Re} > tst1.dat
 pt1x=`cat tst1.dat  | tr -s ' ' | cut -f 2 -d ' '`
 pt1y=`cat tst1.dat  | tr -s ' ' | cut -f 3 -d ' '`
 ./project_inv ${pt1x} ${pt1y} ${iLL} ${ipj} ${lon0} ${lat0} ${lat1} ${lat2} ${Re} > tst2.dat
 if [[ "$HaveProj" -eq "T" ]] ; then
   proj +proj=lcc +lon_0=${lon0} +lat_0=${lat0} +lat_1=${lat1} +lat_2=${lat2} +R=${Re} -f "%.5f" > tst3.dat <<EOF
   ${pt1lon} ${pt1lat}
EOF
 fi
elif [[ "$ipj" -eq 5 ]] ; then
 # Mercator (NAM196)
 # PJ_ilatlonflag,PJ_iprojflag,PJ_lam0,PJ_phi0,PJ_radius_earth
 lon0=$5
 lat0=$6
 Re=$7
 ./project_for ${pt1lon} ${pt1lat} ${iLL} ${ipj} ${lon0} ${lat0} ${Re} > tst1.dat
 pt1x=`cat tst1.dat  | tr -s ' ' | cut -f 2 -d ' '`
 pt1y=`cat tst1.dat  | tr -s ' ' | cut -f 3 -d ' '`
 ./project_inv ${pt1x} ${pt1y} ${iLL} ${ipj} ${lon0} ${lat0} ${Re} > tst2.dat
 if [[ "$HaveProj" -eq "T" ]] ; then
   proj +proj=merc +lon_0=${lon0} +lat_ts=${lat0} +R=${Re} -f "%.5f" > tst3.dat <<EOF
   ${pt1lon} ${pt1lat}
EOF
 fi
else
 echo "exiting"
 exit
fi
# Finished all the projections and inverse projections.

# Now process the values and check for errors.
# First the forward and inverse check
pt2lon=`cat tst2.dat  | tr -s ' ' | cut -f 2 -d ' '`
pt2lat=`cat tst2.dat  | tr -s ' ' | cut -f 3 -d ' '`
# This bc function takes the absolute value of the absolute error and returns the log_10
#   We don't want relative error because some returned values will be close to 0 and
#   absolute error will report km of error.  A threshhold of -3 means errors should not
#   exceed 1 m.  Hopefully they are less than that.
errlon=`echo "var=($pt1lon - $pt2lon);var2=sqrt(var*var);l(var2)/l(10)" | bc -l`
errlat=`echo "var=($pt1lat - $pt2lat);var2=sqrt(var*var);l(var2)/l(10)" | bc -l`
l1=$( printf "%.0f" $errlon )
l2=$( printf "%.0f" $errlat )
# Check to make sure project_for and project_inv are actual inverses
if [[ "$l1" -gt $errthrsh || "$l2" -gt $errthrsh ]] ; then
    stat="FAIL"
    printf " ---> ${RED}${stat}${NC}\n"
    echo "ERROR: projection->inverse does not match within error tolerance"
    echo "original point    : $pt1lon $pt1lat"
    echo "inverse projection: $pt2lon $pt2lat"
    exit 1
fi

if [[ "$HaveProj" -eq "T" ]] ; then
# Now the proj check
  pt2x=`cat tst3.dat  | cut -f 1 `
  pt2y=`cat tst3.dat  | cut -f 2 `
  errx=`echo "var=($pt1x - $pt2x);var2=sqrt(var*var);l(var2)/l(10)" | bc -l`
  erry=`echo "var=($pt1y - $pt2y);var2=sqrt(var*var);l(var2)/l(10)" | bc -l`
  l3=$( printf "%.0f" $errx )
  l4=$( printf "%.0f" $erry )

  # Check to make sure project_for produces the same result as proj4
  if [[ "$l3" -gt $errthrsh || "$l4" -gt $errthrsh ]] ; then
      stat="FAIL"
      printf " ---> ${RED}${stat}${NC}\n"
      echo "Error: projection does not match proj4 within error tolerance"
      echo "project_for: $pt1lon $pt1lat"
      echo "proj4:       $pt2lon $pt2lat"
      exit 1
  fi
fi

# If the results clear both of the above tests, then echo PASS
stat="PASS"
printf " ---> ${GREEN}${stat}${NC}\n"

rm -f tst1.dat tst2.dat tst3.dat
exit 0

