
      program project

      use projection,      only : &
         PJ_ilatlonflag,PJ_iprojflag,PJ_k0,PJ_lam0,PJ_lam1,PJ_lam2,PJ_phi0,PJ_phi1,PJ_phi2,PJ_Re,&
           PJ_Set_Proj_Params, &
           PJ_proj_for, &
           PJ_proj_inv

      implicit none

      integer             :: nargs
      integer             :: status
      character (len=100) :: arg

      real(kind=8)  :: inx    ! input lon or x to convert
      real(kind=8)  :: iny    ! input lat or y to convert
      real(kind=8)  :: outx   ! output lon or x returned
      real(kind=8)  :: outy   ! output lat or y returned

      integer :: ProjDir

        ! CONUS 3.0-km Lambert Conformal
        ! 0 4 262.5 38.5 38.5 38.5 6371.229    #Proj flags and params  
        ! proj +proj=lcc +lon_0=262.5 +lat_0=38.5 +lat_1=38.5 +lat_2=38.5 +R=6371.229

        ! CONUS 40-km Lambert Conformal and
        ! CONUS 12-km Lambert Conformal and
        ! CONUS 5.079-km Lambert Conformal
        ! 0 4 265.0 25.0 25.0 25.0 6371.229    #Proj flags and params                  
        ! proj +proj=lcc +lon_0=265.0 +lat_0=25.0 +lat_1=25.0 +lat_2=25.0 +R=6371.229

        ! NAM 32-km Lambert Conformal used by NARR (used PJ_Re=6367.470, not 6371.229)
        ! 0 4 -107.0 50.0 50.0 50.0 6367.47    #Proj flags and params  
        ! proj +proj=lcc +lon_0=-107.0 +lat_0=50.0 +lat_1=50.0 +lat_2=50.0 +R=6367.47

        ! NAM 32-km Lambert Conformal


        ! HI 2.5-km Mercator
        ! 0 5 198.475 20.0 0.933 6371.229    #Proj flags and params
        ! proj +proj=merc  +lat_ts=20.0 +lon_0=198.475 +R=6371.229

        ! NAM 6-km Polar Sterographic
        ! 0 1 -150.0 90.0 0.933 6371.229    #Proj flags and params
        ! proj +proj=stere  +lon_0=210  +lat_0=90 +k_0=0.933 +R=6371.229

        ! NAM 3-km Polar Sterographic and
        ! NAM 90-km Polar Sterographic
        ! 0 1 -150.0 90.0 0.933 6371.229    #Proj flags and params
        ! proj +proj=stere  +lon_0=210  +lat_0=90 +k_0=0.933 +R=6371.229

        ! NAM 45-km Polar Sterographic and
        ! NAM 11.25-km Polar Sterographic
        ! 0 1 -135.0 90.0 0.933 6371.229    #Proj flags and params
        ! proj +proj=stere  +lon_0=225  +lat_0=90 +k_0=0.933 +R=6371.229

      ProjDir = 0
#ifdef FORWARD
      ProjDir = 1
#endif
#ifdef INVERSE
      ProjDir = -1
#endif

      if (ProjDir.eq.0) then
        write(6,*)"project.F90 must be compiled with either -DFORWARD or -DINVERSE"
        write(6,*)"Forward or inverse not set"
        stop 1
      endif

!     TEST READ COMMAND LINE ARGUMENTS
      nargs = command_argument_count()
      if (nargs.lt.4) then
        write(6,*)"Enter lon lat IsLatLon ProjFlag ..."
        stop 1
      endif

      call get_command_argument(1, arg, status)
      read(arg,*)inx
      call get_command_argument(2, arg, status)
      read(arg,*)iny
      call get_command_argument(3, arg, status)
      read(arg,*)PJ_ilatlonflag
      
      if(PJ_ilatlonflag.eq.1)then
        ! coordinates are in lon/lat
        stop 0
      elseif(PJ_ilatlonflag.eq.0)then
        ! coordinates are projected, read the projection flag
        call get_command_argument(4, arg, status)
        read(arg,*)PJ_iprojflag
        if(PJ_iprojflag.ne.0.and.PJ_iprojflag.ne.1.and. &
           PJ_iprojflag.ne.2.and.PJ_iprojflag.ne.3.and. &
           PJ_iprojflag.ne.4.and.PJ_iprojflag.ne.5) then
          write(0,*)"Unrecognized projection flag"
          stop 1
        endif
      else
        ! PJ_ilatlonflag is not 0 or 1, stopping program
        write(0,*)"Unrecognized latlonflag"
        stop 1
      endif

      select case (PJ_iprojflag)

      case(0)
        ! Non-geographic projection, (x,y) only
      PJ_k0    = 0.0_8
      PJ_Re    = 6371.229_8
      PJ_lam0  = 0.0_8
      PJ_lam1  = 0.0_8
      PJ_lam2  = 0.0_8
      PJ_phi0  = 0.0_8
      PJ_phi1  = 0.0_8
      PJ_phi2  = 0.0_8

      write(*,*)"Both PJ_ilatlonflag and PJ_iprojflag are 0"
      write(*,*)"No geographic projection used"

      case(1)
        ! Polar stereographic
        !read(linebuffer,*)PJ_ilatlonflag,PJ_iprojflag,PJ_lam0,PJ_phi0,PJ_k0,PJ_Re
        if (nargs.lt.8) then
          write(6,*)"Enter lon lat IsLatLon ProjFlag lam0 phi0 k0 radius"
          stop 1
        endif
        call get_command_argument(5, arg, status)
        read(arg,*)PJ_lam0
        call get_command_argument(6, arg, status)
        read(arg,*)PJ_phi0
        PJ_phi1 = PJ_phi0  ! Set the truescale lat to be phi0 with scale
                           ! determined by k0
        call get_command_argument(7, arg, status)
        read(arg,*)PJ_k0
        call get_command_argument(8, arg, status)
        read(arg,*)PJ_Re

      case(2)
        ! Albers Equal Area
        write(0,*)"WARNING: Albers not yet verified"
        !read(linebuffer,*)PJ_ilatlonflag,PJ_iprojflag,PJ_lam0,PJ_phi0,PJ_phi1,PJ_phi2
        if (nargs.lt.8) then
          write(6,*)"Enter lon lat IsLatLon ProjFlag lam0 phi0 phi1 phi2"
          stop 1
        endif

      case(3)
        ! UTM
        write(0,*)"WARNING: UTM not yet verified"
        !read(linebuffer,*)PJ_ilatlonflag,PJ_iprojflag,izone,inorth
        if (nargs.lt.6) then
          write(6,*)"Enter lon lat IsLatLon ProjFlag izonne inorth"
          stop 1
        endif

      case(4)
        ! Lambert conformal conic (NARR, NAM218, NAM221)
        !read(linebuffer,*)PJ_ilatlonflag,PJ_iprojflag,PJ_lam0, &
        !                  PJ_phi0,PJ_phi1,PJ_phi2,PJ_Re
        if (nargs.lt.9) then
          write(6,*)"Enter lon lat IsLatLon ProjFlag lam0 phi0 phi1 phi2 radius"
          stop 1
        endif
        call get_command_argument(5, arg, status)
        read(arg,*)PJ_lam0
        call get_command_argument(6, arg, status)
        read(arg,*)PJ_phi0
        call get_command_argument(7, arg, status)
        read(arg,*)PJ_phi1
        call get_command_argument(8, arg, status)
        read(arg,*)PJ_phi2
        call get_command_argument(9, arg, status)
        read(arg,*)PJ_Re

      case(5)
        ! Mercator (NAM196)
        !read(linebuffer,*)PJ_ilatlonflag,PJ_iprojflag,PJ_lam0,PJ_phi0,PJ_Rd
        if (nargs.lt.7) then
          write(6,*)"Enter lon lat IsLatLon ProjFlag lam0 phi0 radius"
          stop 1
        endif
        call get_command_argument(5, arg, status)
        read(arg,*)PJ_lam0
        call get_command_argument(6, arg, status)
        read(arg,*)PJ_phi0
        call get_command_argument(7, arg, status)
        read(arg,*)PJ_Re

      end select

      if (ProjDir.eq.1) then
        ! Forward Projection: assumming inx,iny are lon,lat
        call PJ_proj_for(inx,iny, &
                       PJ_iprojflag,&
                       PJ_lam0,PJ_phi0,PJ_phi1,PJ_phi2,PJ_k0,PJ_Re,&
                       outx,outy)
      else
        ! Inverse Projection: assumming inx,iny are x,y
        call PJ_proj_inv(inx,iny, &
                       PJ_iprojflag,&
                       PJ_lam0,PJ_phi0,PJ_phi1,PJ_phi2,PJ_k0,PJ_Re,&
                       outx,outy)
      endif

      !write(*,*)inx,iny
      !write(*,*)PJ_iprojflag,PJ_lam0,PJ_phi0,PJ_phi1,PJ_phi2,PJ_k0,PJ_Re
!      write(*,2)outx,outy
! 2    format(/2f15.5/)

      write(*,*)real(outx,kind=4),real(outy,kind=4)

      end program project
