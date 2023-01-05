echo -n "      character(len=40),parameter,public :: PJ_GitComID ='" > PJ_version.h
git log -n 1 | grep commit | cut -f 2 -d' ' | tr -d $'\n' >> PJ_version.h
echo -n "'" >> PJ_version.h
