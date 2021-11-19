projection
==========

projection is a fortran 90 module that contain subroutines that can convert
between lon,lat and various projections commonly used in numerical weather
prediction forecast/reanalysis products.
These functions were written as a component of the USGS volcanic ash
transport and dispersion model, Ash3d.  However, since they are useful for
other programs outside of Ash3d, they are collected into a stand-along file
that can either be compiled as a library or simply compiled directly with
other source code.

To compile as a library, simple type:

  `make`

To compile the library as well as the auxillary tools, type:

  `make all`

This will additionally build the command-line tools project\_for and project\_inv.

To run test on the library, type:

  `make check`

This will run several forward projections and verify that inverse projections
produce the original input parameters.  Additionaly, the forward projections
will be tested against the proj4 library.

To install the library and module, edit the `INSTALLDIR` variable of the makefile
(the default is `/opt/USGS`) and type:

  `make install`

You will need to have write permission in `${INSTALLDIR}` or install as root.


Usage
-----

The fortran 90 module/library consists of three subroutine:

 `PJ_Set_Proj_Params` : sets projection parameters by parsing an 80-character string  
 `PJ_proj_for`        : calculates x,y coordinates, given lon,lat  
 `PJ_proj_inv`        : calculates lon,lat coordinates, give x,y  

The calling program reads an 80-character string from an input file.  This
string is passed to the projection module as an argument to the subroutine
`PJ_Set_Proj_Params`.  The required format of the string depends on the particular
projection used, but must begin with an integer.

The first number, read as an integer, is copied to the module public variable
`PJ_ilatlonflag` and must be either 0 if the coordinate systemp is projected, or
1 if the coordinates are in latitude and longitude.  If `PJ_ilatlonflag` is 0,
then the second integer is read as `PJ_iprojflag`, indicating the projection type.
Depending on which projection is used, several subsequent floating point numbers
are read from the string.



1. `PJ_iprojflag = 1` (Polar Stereographic)  
For polar stereographic projections, four floating point values are read:  
`PJ_lam0`, `PJ_phi0`, `PJ_k0`, `PJ_radius_earth`  
   Examples:  
    NAM grid 104 (90.75 km over N.Am.) :: 0 1 -105.0 90.0 0.933 6371.229  
    NAM grid 198 ( 5.95 km over AK   ) :: 0 1 -150.0 90.0 0.933 6371.229  
    NAM grid 216 (45.00 km over AK   ) :: 0 1 -135.0 90.0 0.933 6371.229  

2. `PJ_iprojflag = 2` (Albers Equal Area)  
   For Albers equal area projections, four floating point values are read:  
        `PJ_lam0`, 
        `PJ_phi0`, 
        `PJ_phi1`, 
        `PJ_phi2`,  
   This projection is not currently functional

3. `PJ_iprojflag = 3` (UTM)  
   This projection is not currently functional

4. `PJ_iprojflag = 4` (Lambert Conformal Conic)  
   For Lambert conformal conic projections, five floating point values are read:  
        `PJ_lam0`, 
        `PJ_phi0`, 
        `PJ_phi1`,
        `PJ_phi2`, 
        `PJ_radius_earth`  
   Examples:  
    NAM grid 212 (40.64 km over Conus) :: 0 4 265.0 25.0 25.0 25.0 6371.229  
    NAM grid 221 (32.46 km over N.Am.) :: 0 4 -107.0 50.0 50.0 50.0 6371.229  

5. `PJ_iprojflag = 5` (Mercator)  
   For Mercator projections, three floating point values are read:  
        `PJ_lam0`, 
        `PJ_phi0`, 
        `PJ_radius_earth`  
   Examples:  
    NAM grid 196 (2.5 km over HI) :: 0 5 198.475 20.0 6371.229 

The forward and inverse projection tools (`project_for` and `project_inv`) take command-line
arguments as outlined above, except additionally the lon,lat (or x,y) pairs.

For example, for a stereographic projection:  
  `project_for lon_in lat_in 0 1 lon0 lat0 k0 Re`  
  `project_inv   x_in   y_in 0 1 lon0 lat0 k0 Re`  

The forward projection (from lon,lat to x,y) can be calculated by the subroutine  
  `PJ_proj_for(lon_in,lat_in,iprojflag,lon_0,lat_0,lat_1,lat_2,k_0,earth_R, x_out,y_out)`

The inverse projection (from x,y to lon,lat) can be calculated by the subroutine  
  `PJ_proj_inv(x_in,y_in,iprojflag,lon_0,lat_0,lat_1,lat_2,k_0,earth_R,lon_out,lat_out)`

Not all the parameters need to be set for all projections. The Mercator projection,
for example, does not use `lat_1`, `lat_2`, or `k_0`, but the call to the subroutine must
have dummy variable in those positions.  All floating point variables must be of `kind=8`


Authors
-------

Hans F. Schwaiger <hschwaiger@usgs.gov>  
Larry G. Mastin <lgmastin@usgs.gov>  
Roger P. Denlinger <rdenlinger@usgs.gov>  
