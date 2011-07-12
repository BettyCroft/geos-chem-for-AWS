!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !MODULE: restart_mod
!
! !DESCRIPTION: Module RESTART\_MOD contains variables and routines which 
!  are used to read and write restart files for GEOS-Chem advected tracers
!  in units of [v/v] mixing ratio) and chemical species (in concentration 
!  units of [molec/cm3]).
!\\
!\\
! !INTERFACE:
!
      MODULE RESTART_MOD
!
! !USES:
!
      IMPLICIT NONE
      PRIVATE
!
! !PUBLIC MEMBER FUNCTIONS
!
      PUBLIC  :: MAKE_RESTART_FILE
      PUBLIC  :: READ_RESTART_FILE
      PUBLIC  :: SET_RESTART
      PUBLIC  :: MAKE_CSPEC_FILE
      PUBLIC  :: READ_CSPEC_FILE
!
! !PRIVATE MEMBER FUNCTIONS:
!
      PRIVATE :: CONVERT_TRACER_TO_VV
      PRIVATE :: CHECK_DIMENSIONS
      PRIVATE :: COPY_STT
      PRIVATE :: CHECK_DATA_BLOCKS
!
! !REVISION HISTORY:
!  25 Jun 2002 - R. Yantosca - Initial version
!  (1 ) Moved routines "make_restart_file.f"" and "read_restart_file.f" into
!        this module.  Also now internal routines to "read_restart_file.f"
!        are now a part of this module.  Now reference "file_mod.f" to get
!        file unit numbers and error checking routines. (bmy, 6/25/02)
!  (2 ) Now reference AD from "dao_mod.f".  Now reference "error_mod.f".
!        Also added minor bug fix for ALPHA platform. (bmy, 10/15/02)
!  (3 ) Now references "grid_mod.f" and the new "time_mod.f" (bmy, 2/11/03)
!  (4 ) Added error-check and cosmetic changes (bmy, 4/29/03)
!  (5 ) Removed call to COPY_STT_FOR_OX, it's obsolete (bmy, 8/18/03)
!  (6 ) Add fancy output (bmy, 4/26/04)
!  (7 ) Added routine SET_RESTART.  Now reference "logical_mod.f" and
!        "tracer_mod.f" (bmy, 7/20/04)
!  (8 ) Removed obsolete routines TRUE_TRACER_INDEX and COPY_DATA_FOR_CO_OH
!        (bmy, 6/28/05)
!  (9 ) Now make sure all USE statements are USE, ONLY (bmy, 10/3/05)
!  (10) Now pass TAU via the arg list in MAKE_RESTART_FILE (bmy, 12/15/05)
!  (11) Add MAKE_CSPEC_FILE and READ_CSPEC_FILE routines to save and read
!        CSPEC_FULL restart files (dkh, 02/12/09)
!  11 Jul 2011 - R. Yantosca - Corrected mis-indexing problem w/ the 
!                              CSPEC restart file
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !PRIVATE TYPES:
!
      ! Full path name of the advected tracer restart file (INPUT)
      CHARACTER(LEN=255) :: INPUT_RESTART_FILE  

      ! Full path name of (w/ replaceable tokens) of the 
      ! advected tracer restart file (OUTPUT)
      CHARACTER(LEN=255) :: OUTPUT_RESTART_FILE 

      CONTAINS
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: make_restart_file
!
! !DESCRIPTION: Subroutine MAKE\_RESTART\_FILE creates restart files for 
!  GEOS-Chem advected tracers [units: v/v].  The file format is GEOS-Chem
!  binary punch (bpch) format.
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE MAKE_RESTART_FILE( YYYYMMDD, HHMMSS, TAU )
!
! !USES:
!
      USE BPCH2_MOD,   ONLY : BPCH2,         GET_MODELNAME
      USE BPCH2_MOD,   ONLY : GET_HALFPOLAR, OPEN_BPCH2_FOR_WRITE
      USE DAO_MOD,     ONLY : AD
      USE ERROR_MOD,   ONLY : DEBUG_MSG
      USE FILE_MOD,    ONLY : IU_RST,        IOERROR
      USE GRID_MOD,    ONLY : GET_XOFFSET,   GET_YOFFSET
      USE LOGICAL_MOD, ONLY : LPRT
      USE TIME_MOD,    ONLY : EXPAND_DATE
      USE TRACER_MOD,  ONLY : STT,           N_TRACERS,  TCVV

#     include "CMN_SIZE"    ! Size parameters
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)  :: YYYYMMDD   ! YYYY/MM/DD GMT date
      INTEGER, INTENT(IN)  :: HHMMSS     ! hh:mm:ss GMT time
      REAL*8,  INTENT(IN)  :: TAU        ! TAU value (hrs from 1/1/1985)
! 
! !REVISION HISTORY: 
!  27 May 1999 - R. Yantosca - Initial version
!  (1 ) Now use function NYMD_STRING from "time_mod.f" to generate a
!        Y2K compliant string for all data sets. (bmy, 6/22/00)
!  (2 ) Reference F90 module "bpch2_mod.f" which contains routines BPCH2_HDR, 
!        BPCH2, and GET_MODELNAME for writing data to binary punch files. 
!        (bmy, 6/22/00)
!  (3 ) Now do not write more than NTRACE data blocks to disk.  
!        Also updated comments. (bmy, 7/17/00)
!  (4 ) Now use IOS /= 0 to trap both I/O errors and EOF. (bmy, 9/13/00)
!  (5 ) Added to "restart_mod.f".  Also now save the entire grid to the
!        restart file. (bmy, 6/24/02)
!  (6 ) Bug fix: Remove duplicate definition of MM.  This causes compile-time
!        problems on the ALPHA platform. (gcc, bmy, 11/6/02)
!  (7 ) Now references functions GET_OFFSET, GET_YOFFSET from "grid_mod.f".
!        Now references function GET_TAU from "time_mod.f".  Now added a call 
!        to DEBUG_MSG from "error_mod.f" (bmy, 2/11/03)
!  (8 ) Cosmetic changes (bmy, 4/29/03)
!  (9 ) Now reference STT, N_TRACERS, TCVV from "tracer_mod.f".  Also now
!        remove hardwired output restart filename.   Now references LPRT
!        from "logical_mod.f". (bmy, 7/20/04)
!  (10) Remove references to CMN_DIAG and TRCOFFSET.  Now call GET_HALFPOLAR 
!        from "bpch2_mod.f" to get the HALFPOLAR flag value for GEOS or GCAP 
!        grids. (bmy, 6/28/05)
!  (11) Now make sure all USE statements are USE, ONLY (bmy, 10/3/05)
!  (12) Add TAU to the argument list (bmy, 12/16/05)
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      ! Arguments

      ! Local Variables      
      INTEGER              :: I,    I0, IOS, J,  J0, L, N
      INTEGER              :: YYYY, MM, DD,  HH, SS
      REAL*4               :: TRACER(IIPAR,JJPAR,LLPAR)
      CHARACTER(LEN=255)   :: FILENAME

      ! For binary punch file, version 2.0
      REAL*4               :: LONRES, LATRES
      INTEGER              :: HALFPOLAR
      INTEGER, PARAMETER   :: CENTER180 = 1
      
      CHARACTER(LEN=20)    :: MODELNAME
      CHARACTER(LEN=40)    :: CATEGORY
      CHARACTER(LEN=40)    :: UNIT     
      CHARACTER(LEN=40)    :: RESERVED = ''
      CHARACTER(LEN=80)    :: TITLE 

      !=================================================================
      ! MAKE_RESTART_FILE begins here!
      !=================================================================

      ! Define variables for BINARY PUNCH FILE OUTPUT
      TITLE    = 'GEOS-CHEM Restart File: ' // 
     &           'Instantaneous Tracer Concentrations (v/v)'
      UNIT     = 'v/v'
      CATEGORY = 'IJ-AVG-$'
      LONRES   = DISIZE
      LATRES   = DJSIZE

      ! Call GET_MODELNAME to return the proper model name for
      ! the given met data being used (bmy, 6/22/00)
      MODELNAME = GET_MODELNAME()

      ! Call GET_HALFPOLAR to return the proper value
      ! for either GCAP or GEOS grids (bmy, 6/28/05)
      HALFPOLAR = GET_HALFPOLAR()

      ! Get the nested-grid offsets
      I0 = GET_XOFFSET( GLOBAL=.TRUE. )
      J0 = GET_YOFFSET( GLOBAL=.TRUE. )

      !=================================================================
      ! Open the restart file for output -- binary punch format
      !=================================================================

      ! Copy the output restart file name into a local variable
      FILENAME = TRIM( OUTPUT_RESTART_FILE )

      ! Replace YYYY, MM, DD, HH tokens in FILENAME w/ actual values
      CALL EXPAND_DATE( FILENAME, YYYYMMDD, HHMMSS )

      WRITE( 6, 100 ) TRIM( FILENAME )
 100  FORMAT( '     - MAKE_RESTART_FILE: Writing ', a )

      ! Open restart file for output
      CALL OPEN_BPCH2_FOR_WRITE( IU_RST, FILENAME, TITLE )

      !=================================================================
      ! Write each tracer to the restart file
      !=================================================================
      DO N = 1, N_TRACERS
         
         ! Convert from [kg] to [v/v] and store in the TRACER array
!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L )
         DO L = 1, LLPAR
         DO J = 1, JJPAR
         DO I = 1, IIPAR
            TRACER(I,J,L) = STT(I,J,L,N) * TCVV(N) / AD(I,J,L)
         ENDDO
         ENDDO
         ENDDO
!$OMP END PARALLEL DO

         ! Convert STT from [kg] to [v/v] mixing ratio 
         ! and store in temporary variable TRACER
         CALL BPCH2( IU_RST,    MODELNAME, LONRES,    LATRES,    
     &               HALFPOLAR, CENTER180, CATEGORY,  N,
     &               UNIT,      TAU,       TAU,       RESERVED,   
     &               IIPAR,     JJPAR,     LLPAR,     I0+1,            
     &               J0+1,      1,         TRACER )
      ENDDO  

      ! Close file
      CLOSE( IU_RST )

      !### Debug
      IF ( LPRT ) CALL DEBUG_MSG( '### MAKE_RESTART_FILE: wrote file' )

      END SUBROUTINE MAKE_RESTART_FILE
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: read_restart_file
!
! !DESCRIPTION: Subroutine READ\_RESTART\_FILE initializes GEOS-Chem advected
!  tracer concentrations from a restart file (binary punch file format) 
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE READ_RESTART_FILE( YYYYMMDD, HHMMSS ) 
!
! !USES:
!
      USE BPCH2_MOD,   ONLY : OPEN_BPCH2_FOR_READ
      USE DAO_MOD,     ONLY : AD
      USE ERROR_MOD,   ONLY : DEBUG_MSG
      USE FILE_MOD,    ONLY : IU_RST
      USE FILE_MOD,    ONLY : IOERROR
      USE LOGICAL_MOD, ONLY : LSPLIT
      USE LOGICAL_MOD, ONLY : LPRT
      USE TIME_MOD,    ONLY : EXPAND_DATE
      USE TRACER_MOD,  ONLY : N_TRACERS
      USE TRACER_MOD,  ONLY : STT
      USE TRACER_MOD,  ONLY : TRACER_NAME
      USE TRACER_MOD,  ONLY : TRACER_MW_G

#     include "CMN_SIZE"                ! Size parameters
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN) :: YYYYMMDD   ! YYYY/MM/DD GMT date
      INTEGER, INTENT(IN) :: HHMMSS     ! hh:mm:ss   GMT time
! 
! !REVISION HISTORY: 
!  27 May 1999 - R. Yantosca - Initial version
!  (1 ) Now check that N = NTRACER - TRCOFFSET is valid.  
!        Also reorganize some print statements  (bmy, 10/25/99)
!  (2 ) Now pass LFORCE, LSPLIT via CMN_SETUP. (bmy, 11/4/99)
!  (3 ) Cosmetic changes, added comments (bmy, 3/17/00)
!  (4 ) Now use function NYMD_STRING from "time_mod.f" to generate a
!        Y2K compliant string for all data sets. (bmy, 6/22/00)
!  (5 ) Broke up sections of code into internal subroutines.  Also updated
!        comments & cleaned up a few things. (bmy, 7/17/00)
!  (6 ) Now use IOS /= 0 to trap both I/O errors and EOF. (bmy, 9/13/00)
!  (7 ) Print max & min of tracer regardless of the units (bmy, 10/5/00)
!  (8 ) Removed obsolete code from 10/00 (bmy, 12/21/00)
!  (9 ) Removed obsolete commented out code (bmy, 4/23/01)
!  (10) Added updates from amf for tagged Ox run.  Also updated comments
!        and made some cosmetic changes (bmy, 7/3/01)
!  (11) Bug fix: if starting from multiox restart file, then NTRACER 
!        will be greater than 40  but less than 60.  Adjust COPY_STT_FOR_OX
!        accordingly. (amf, bmy, 9/6/01)
!  (12) Now reference TRANUC from "charpak_mod.f" (bmy, 11/15/01)
!  (13) Updated comments (bmy, 1/25/02)
!  (14) Now reference AD from "dao_mod.f" (bmy, 9/18/02)
!  (15) Now added a call to DEBUG_MSG from "error_mod.f" (bmy, 2/11/03)
!  (16) Remove call to COPY_STT_FOR_OX, it's obsolete. (bmy, 8/18/03)
!  (17) Add fancy output string (bmy, 4/26/04)
!  (18) No longer use hardwired filename.  Also now reference "logical_mod.f"
!        and "tracer_mod.f" (bmy, 7/20/04)
!  (19) Remove code for obsolete CO-OH simulation.  Also remove references
!        to CMN_DIAG and TRCOFFSET.   Change tracer name format string to A10.
!        (bmy, 6/24/05)
!  (20) Updated comments (bmy, 12/16/05)
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER             :: I, IOS, J, L, N
      INTEGER             :: NCOUNT(NNPAR) 
      REAL*4              :: TRACER(IIPAR,JJPAR,LLPAR)
      REAL*8              :: SUMTC
      CHARACTER(LEN=255)  :: FILENAME

      ! For binary punch file, version 2.0
      INTEGER             :: NI,     NJ,     NL
      INTEGER             :: IFIRST, JFIRST, LFIRST
      INTEGER             :: NTRACER,   NSKIP
      INTEGER             :: HALFPOLAR, CENTER180
      REAL*4              :: LONRES,    LATRES
      REAL*8              :: ZTAU0,     ZTAU1
      CHARACTER(LEN=20)   :: MODELNAME
      CHARACTER(LEN=40)   :: CATEGORY
      CHARACTER(LEN=40)   :: UNIT     
      CHARACTER(LEN=40)   :: RESERVED

      !=================================================================
      ! READ_RESTART_FILE begins here!
      !=================================================================

      ! Initialize some variables
      NCOUNT(:)     = 0
      TRACER(:,:,:) = 0e0

      !=================================================================
      ! Open restart file and read top-of-file header
      !=================================================================
      
      ! Copy input file name to a local variable
      FILENAME = TRIM( INPUT_RESTART_FILE )

      ! Replace YYYY, MM, DD, HH tokens in FILENAME w/ actual values
      CALL EXPAND_DATE( FILENAME, YYYYMMDD, HHMMSS )

      ! Echo some input to the screen
      WRITE( 6, '(a)'   ) REPEAT( '=', 79 )
      WRITE( 6, '(a,/)' ) 'R E S T A R T   F I L E   I N P U T'
      WRITE( 6, 100 ) TRIM( FILENAME )
 100  FORMAT( 'READ_RESTART_FILE: Reading ', a )

      ! Open the binary punch file for input
      CALL OPEN_BPCH2_FOR_READ( IU_RST, FILENAME )
      
      ! Echo more output
      WRITE( 6, 110 )
 110  FORMAT( /, 'Min and Max of each tracer, as read from the file:',
     &        /, '(in volume mixing ratio units: v/v)' )

      !=================================================================
      ! Read concentrations -- store in the TRACER array
      !=================================================================
      DO 
         READ( IU_RST, IOSTAT=IOS ) 
     &     MODELNAME, LONRES, LATRES, HALFPOLAR, CENTER180

         ! IOS < 0 is end-of-file, so exit
         IF ( IOS < 0 ) EXIT

         ! IOS > 0 is a real I/O error -- print error message
         IF ( IOS > 0 ) CALL IOERROR( IOS,IU_RST,'read_restart_file:4' )

         READ( IU_RST, IOSTAT=IOS ) 
     &        CATEGORY, NTRACER,  UNIT, ZTAU0,  ZTAU1,  RESERVED,
     &        NI,       NJ,       NL,   IFIRST, JFIRST, LFIRST,
     &        NSKIP

         IF ( IOS /= 0 ) CALL IOERROR( IOS,IU_RST,'read_restart_file:5')

         READ( IU_RST, IOSTAT=IOS ) 
     &        ( ( ( TRACER(I,J,L), I=1,NI ), J=1,NJ ), L=1,NL )

         IF ( IOS /= 0 ) CALL IOERROR( IOS,IU_RST,'read_restart_file:6')

         !==============================================================
         ! Assign data from the TRACER array to the STT array.
         !==============================================================
  
         ! Only process concentration data (i.e. mixing ratio)
         IF ( CATEGORY(1:8) == 'IJ-AVG-$' ) THEN 

            ! Make sure array dimensions are of global size
            ! (NI=IIPAR; NJ=JJPAR, NL=LLPAR), or stop the run
            CALL CHECK_DIMENSIONS( NI, NJ, NL )

            ! Convert TRACER from its native units to [v/v] mixing ratio
            CALL CONVERT_TRACER_TO_VV( NTRACER, TRACER, UNIT )

            ! Convert TRACER from [v/v] to [kg] and copy into STT array
            CALL COPY_STT( NTRACER, TRACER, NCOUNT )

         ENDIF
      ENDDO

      !=================================================================
      ! Examine data blocks, print totals, and return
      !=================================================================

      ! Check for missing or duplicate data blocks
      CALL CHECK_DATA_BLOCKS( N_TRACERS, NCOUNT )

      ! Close file
      CLOSE( IU_RST )      

      ! Print totals atmospheric mass for each tracer
      WRITE( 6, 120 )
 120  FORMAT( /, 'Total atmospheric masses for each tracer: ' ) 

      DO N = 1, N_TRACERS

         ! For tracers in kg C, be sure to use correct unit string
         IF ( INT( TRACER_MW_G(N) + 0.5 ) == 12 ) THEN
            UNIT = 'kg C'
         ELSE
            UNIT = 'kg  '
         ENDIF

         ! Print totals
         WRITE( 6, 130 ) N,                   TRACER_NAME(N), 
     &                   SUM( STT(:,:,:,N) ), ADJUSTL( UNIT )
 130     FORMAT( 'Tracer ', i3, ' (', a10, ') ', es12.5, 1x, a4)
      ENDDO

      ! Fancy output
      WRITE( 6, '(a)' ) REPEAT( '=', 79 )

      !### Debug
      IF ( LPRT ) CALL DEBUG_MSG( '### READ_RESTART_FILE: read file' )

      END SUBROUTINE READ_RESTART_FILE
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: convert_tracer_to_vv
!
! !DESCRIPTION: Subroutine CONVERT\_TRACER\_TO\_VV converts the TRACER array 
!  from its natural units (e.g. ppbv, ppmv) as read from the restart file to 
!  v/v mixing ratio. 
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE CONVERT_TRACER_TO_VV( NTRACER, TRACER, UNIT )
!
! !USES:
!
      USE CHARPAK_MOD, ONLY : TRANUC
      USE ERROR_MOD,   ONLY : GEOS_CHEM_STOP

#     include "CMN_SIZE"    ! Size parameters

!
! !INPUT PARAMETERS: 
!
      ! Tracer number and units 
      INTEGER,          INTENT(IN) :: NTRACER  
      CHARACTER(LEN=*), INTENT(IN) :: UNIT
!
! !INPUT/OUTPUT PARAMETERS: 
!
      ! Array containing tracer concentrations
      REAL*4,        INTENT(INOUT) :: TRACER(IIPAR,JJPAR,LLPAR)  
! 
! !REVISION HISTORY: 
!  (1 ) Added to "restart_mod.f".  Can now also convert from ppm or ppmv
!        to v/v mixing ratio. (bmy, 6/25/02)
!  (2 ) Now reference GEOS_CHEM_STOP from "error_mod.f", which frees all
!        allocated memory before stopping the run. (bmy, 10/15/02)
!  (3 ) Remove obsolete reference to CMN (bmy, 6/24/05)
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
      !=================================================================
      ! CONVERT_TRACER_TO_VV begins here!
      !=================================================================

      ! Convert UNIT to uppercase
      CALL TRANUC( UNIT )
      
      ! Convert from the current unit to v/v
      SELECT CASE ( TRIM( UNIT ) )

         CASE ( '', 'V/V' )
            ! Do nothing, TRACER is already in v/v
            
         CASE ( 'PPM', 'PPMV', 'PPMC' ) 
            TRACER = TRACER * 1d-6

         CASE ( 'PPB', 'PPBV', 'PPBC' ) 
            TRACER = TRACER * 1d-9

         CASE ( 'PPT', 'PPTV', 'PPTC' )
            TRACER = TRACER * 1d-12

         CASE DEFAULT
            WRITE( 6, '(a)' ) 'Incompatible units in punch file!'
            WRITE( 6, '(a)' ) 'STOP in CONVERT_TRACER_TO_VV'
            WRITE( 6, '(a)' ) REPEAT( '=', 79 )
            CALL GEOS_CHEM_STOP

      END SELECT

      ! Print the min & max of each tracer as it is read from the file
      WRITE( 6, 110 ) NTRACER,  MINVAL( TRACER ), MAXVAL( TRACER )
 110  FORMAT( 'Tracer ', i3, ': Min = ', es12.5, '  Max = ',  es12.5 )

      END SUBROUTINE CONVERT_TRACER_TO_VV
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: check_dimensions
!
! !DESCRIPTION: Subroutine CHECK\_DIMENSIONS makes sure that the dimensions 
!  of the restart file extend to cover the entire grid. 
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE CHECK_DIMENSIONS( NI, NJ, NL ) 
!
! !USES:
!
      USE ERROR_MOD, ONLY : GEOS_CHEM_STOP

#     include "CMN_SIZE"
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN) :: NI   ! # of longitudes read from restart file
      INTEGER, INTENT(IN) :: NJ   ! # of latitudes  read from restart file
      INTEGER, INTENT(IN) :: NL   ! # of levels     read from restart file
! 
! !REVISION HISTORY: 
!  (1 ) Added to "restart_mod.f".  Now no longer allow initialization with 
!        less than a globally-sized data block. (bmy, 6/25/02)
!  (2 ) Now reference GEOS_CHEM_STOP from "error_mod.f", which frees all
!        allocated memory before stopping the run. (bmy, 10/15/02)
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
      !=================================================================
      ! CHECK_DIMENSIONS begins here!
      !=================================================================

      ! Error check longitude dimension: NI must equal IIPAR
      IF ( NI /= IIPAR ) THEN
         WRITE( 6, '(a)' ) 'ERROR reading in restart file!'
         WRITE( 6, '(a)' ) 'Wrong number of longitudes encountered!'
         WRITE( 6, '(a)' ) 'STOP in CHECK_DIMENSIONS (restart_mod.f)'
         WRITE( 6, '(a)' ) REPEAT( '=', 79 )
         CALL GEOS_CHEM_STOP
      ENDIF

      ! Error check latitude dimension: NJ must equal JJPAR
      IF ( NJ /= JJPAR ) THEN
         WRITE( 6, '(a)' ) 'ERROR reading in restart file!'
         WRITE( 6, '(a)' ) 'Wrong number of latitudes encountered!'
         WRITE( 6, '(a)' ) 'STOP in CHECK_DIMENSIONS (restart_mod.f)'
         WRITE( 6, '(a)' ) REPEAT( '=', 79 )
         CALL GEOS_CHEM_STOP
      ENDIF
      
      ! Error check vertical dimension: NL must equal LLPAR
      IF ( NL /= LLPAR ) THEN
         WRITE( 6, '(a)' ) 'ERROR reading in restart file!'
         WRITE( 6, '(a)' ) 'Wrong number of levels encountered!'
         WRITE( 6, '(a)' ) 'STOP in CHECK_DIMENSIONS (restart_mod.f)'
         WRITE( 6, '(a)' ) REPEAT( '=', 79 )
         CALL GEOS_CHEM_STOP
      ENDIF

      END SUBROUTINE CHECK_DIMENSIONS
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: copy_stt
!
! !DESCRIPTION: Subroutine COPY\_STT converts tracer concetrations from [v/v] 
!  to [kg] and then copies the results into the STT tracer array. 
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE COPY_STT( NTRACER, TRACER, NCOUNT )
!
! !USES:
!
      USE DAO_MOD,    ONLY : AD
      USE TRACER_MOD, ONLY : N_TRACERS, STT, TCVV
      
#     include "CMN_SIZE"   ! Size parameters
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)    :: NTRACER                    ! Tracer #
      REAL*4,  INTENT(IN)    :: TRACER(IIPAR,JJPAR,LLPAR)  ! Tracers from 
                                                           !  rst file [v/v]
!
! !INPUT/OUTPUT PARAMETERS: 
!
      INTEGER, INTENT(INOUT) :: NCOUNT(NNPAR)              ! # of data blocks
!                                                          !  for each tracer
! 
! !REVISION HISTORY: 
!  (1 ) Added to "restart_mod.f".  Also added parallel loops. (bmy, 6/25/02)
!  (2 ) Now reference AD from "dao_mod.f" (bmy, 9/18/02)
!  (3 ) Now exit if N is out of range (bmy, 4/29/03)
!  (4 ) Now references N_TRACERS, STT & TCVV from "tracer_mod.f" (bmy, 7/20/04)
!  (5 ) Remove call to TRUE_TRACER_INDEX (bmy, 6/24/05)
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: I, J, L, N
      
      !=================================================================
      ! COPY_STT begins here!
      !=================================================================

      ! Tracer number
      N = NTRACER

      ! Exit if N is out of range
      IF ( N < 1 .or. N > N_TRACERS ) RETURN

      ! Convert from [v/v] to [kg] and store in STT
!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L )
      DO L = 1, LLPAR
      DO J = 1, JJPAR
      DO I = 1, IIPAR
         STT(I,J,L,N) = TRACER(I,J,L) * AD(I,J,L) / TCVV(N) 
      ENDDO
      ENDDO
      ENDDO
!$OMP END PARALLEL DO

      ! Increment the # of records found for tracer N
      NCOUNT(N) = NCOUNT(N) + 1

      END SUBROUTINE COPY_STT
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: check_data_blocks
!
! !DESCRIPTION: Subroutine CHECK\_DATA\_BLOCKS checks to see if we have 
!  multiple or missing data blocks for a given tracer. 
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE CHECK_DATA_BLOCKS( NTRACE, NCOUNT )
!
! !USES:
!
      USE ERROR_MOD, ONLY : GEOS_CHEM_STOP

#     include "CMN_SIZE"  ! Size parameters

!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN) :: NTRACE          ! # of advected tracers 
      INTEGER, INTENT(IN) :: NCOUNT(NNPAR)   ! Data blocks found per tracer
! 
! !REVISION HISTORY: 
!  25 Jun 2002 - R. Yantosca - Initial version
!  (1 ) Added to "restart_mod.f".  Also now use F90 intrinsic REPEAT to
!        write a long line of "="'s to the screen. (bmy, 6/25/02)
!  (2 ) Now reference GEOS_CHEM_STOP from "error_mod.f", which frees all
!        allocated memory before stopping the run. (bmy, 10/15/02)
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: N

      !=================================================================
      ! CHECK_DATA_BLOCKS begins here! 
      !=================================================================

      ! Loop over all tracers
      DO N = 1, NTRACE

         ! Stop if a tracer has more than one data block 
         IF ( NCOUNT(N) > 1 ) THEN 
            WRITE( 6, 100 ) N
            WRITE( 6, 120 ) 
            WRITE( 6, '(a)' ) REPEAT( '=', 79 )
            CALL GEOS_CHEM_STOP
         ENDIF
         
         ! Stop if a tracer has no data blocks 
         IF ( NCOUNT(N) == 0 ) THEN
            WRITE( 6, 110 ) N
            WRITE( 6, 120 ) 
            WRITE( 6, '(a)' ) REPEAT( '=', 79 )
            CALL GEOS_CHEM_STOP
         ENDIF
      ENDDO

      ! FORMAT statements
 100  FORMAT( 'More than one record found for tracer : ', i4 )
 110  FORMAT( 'No records found for tracer : ',           i4 ) 
 120  FORMAT( 'STOP in CHECK_DATA_BLOCKS (restart_mod.f)'    )

      END SUBROUTINE CHECK_DATA_BLOCKS
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: set_restart
!
! !DESCRIPTION: Subroutine SET\_RESTART initializes the variables 
!  INPUT\_RESTART\_FILE and OUTPUT\_RESTART\_FILE with the values read from 
!  the \texttt{input.geos} file.  These specify the names of the input and
!  output restart files for GEOS-Chem advected tracers.
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE SET_RESTART( INFILE, OUTFILE )
!
! !INPUT PARAMETERS: 
!
      CHARACTER(LEN=255) :: INFILE    ! Advected tracer input  restart file
      CHARACTER(LEN=255) :: OUTFILE   ! Advected tracer output restart file 
! 
! !REVISION HISTORY: 
!  09 Jul 2004 - R. Yantosca - Initial version
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
      !=================================================================
      ! SET_RESTART begins here
      !=================================================================
      INPUT_RESTART_FILE  = INFILE
      OUTPUT_RESTART_FILE = OUTFILE
     
      END SUBROUTINE SET_RESTART
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: make_cspec_file
!
! !DESCRIPTION: Subroutine MAKE\_CSPEC\_FILE writes GEOS-Chem chemical
!  species concentrations into a checkpoint file (binary punch file format).
!  The chemical species are saved into the CSPEC array, which is used by
!  the SMVGEAR and KPP solvers.
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE MAKE_CSPEC_FILE( YYYYMMDD, HHMMSS )
!
! !USES:
!
      USE BPCH2_MOD
      USE COMODE_MOD,  ONLY : CSPEC
      USE COMODE_MOD,  ONLY : CSPEC_FULL
      USE COMODE_MOD,  ONLY : JLOP
      USE ERROR_MOD,   ONLY : DEBUG_MSG
      USE ERROR_MOD,   ONLY : ERROR_STOP
      USE FILE_MOD,    ONLY : IU_RST
      USE FILE_MOD,    ONLY : IOERROR
      USE GRID_MOD,    ONLY : GET_XOFFSET
      USE GRID_MOD,    ONLY : GET_YOFFSET
      USE LOGICAL_MOD, ONLY : LPRT
      USE TIME_MOD,    ONLY : EXPAND_DATE
      USE TIME_MOD,    ONLY : GET_TAU

#     include "CMN_SIZE"                 ! Size parameters
#     include "CMN"                      ! TAU , NSRCX, LSOILNOX
#     include "comode.h"                 ! IGAS
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)  :: YYYYMMDD   ! YYYY/MM/DD GMT date
      INTEGER, INTENT(IN)  :: HHMMSS     ! hh:mm:ss   GMT time
! 
! !REVISION HISTORY: 
!  27 Aug 2004 - D. Henze    - Initial version, based on MAKE_RESTART
!  11 Jul 2011 - R. Yantosca - Now skip over ND65 families when writing
!                              species to the restart.cspec.YYYYMMDDhh file!
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!  12 Jul 2011 - R. Yantosca - Save species name to restart file using the
!                              RESERVED field of the bpch file
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER              :: I,    I0, IOS, J,  J0, L, N, JLOOP
      INTEGER              :: YYYY, MM, DD,  HH, SS, ZIP_HH
      CHARACTER(LEN=255)   :: FILENAME
      CHARACTER(LEN=255)   :: OUTPUT_CHECKPT_FILE


      ! Temporary storage arrays for checkpointed variables
      REAL*4               :: TMP(ILONG, ILAT, IPVERT)

      ! For binary punch file, version 2.0
      REAL*4               :: LONRES, LATRES
      ! make HALFPOLAR variable (hotp 2/25/09)
      !INTEGER, PARAMETER   :: HALFPOLAR = 1
      INTEGER              :: HALFPOLAR
      INTEGER, PARAMETER   :: CENTER180 = 1

      INTEGER 		   :: MAX_nitr_max
      INTEGER 		   :: NSOFAR
      
      CHARACTER(LEN=20)    :: MODELNAME
      CHARACTER(LEN=40)    :: CATEGORY
      CHARACTER(LEN=40)    :: UNIT     
      CHARACTER(LEN=40)    :: RESERVED = ''
      CHARACTER(LEN=80)    :: TITLE 


      !=================================================================
      ! MAKE_CSPEC_FILE begins here!
      !=================================================================

      ! Hardwire output file for now
      OUTPUT_CHECKPT_FILE = 'restart.cspec.YYYYMMDDhh'

      ! Clear some arrays 
      ! use minimum value instead of zero hotp 2/25/09
      !TMP(:,:,:)   = 0e0
      TMP(:,:,:)   = 1e-30


      ! Define variables for BINARY PUNCH FILE OUTPUT
      TITLE    = 'GEOS-CHEM Checkpoint File: ' // 
     &           'Instantaneous Species Concentrations (#/cm3)'
      CATEGORY = 'IJ-CHK-$'
      LONRES   = DISIZE
      LATRES   = DJSIZE
      ! get value of HALFPOLAR hotp 2/25/09
      HALFPOLAR = GET_HALFPOLAR()

      ! Call GET_MODELNAME to return the proper model name for
      ! the given met data being used (bmy, 6/22/00)
      MODELNAME = GET_MODELNAME()

      ! Get the nested-grid offsets
      I0 = GET_XOFFSET( GLOBAL=.TRUE. )
      J0 = GET_YOFFSET( GLOBAL=.TRUE. )

      !=================================================================
      ! Open the checkpoint file for output -- binary punch format
      !=================================================================

      ! Copy the output checkpoint file name into a local variable
      FILENAME = TRIM( OUTPUT_CHECKPT_FILE )

      ! Replace YYYY, MM, DD, HH tokens in FILENAME w/ actual values
      CALL EXPAND_DATE( FILENAME, YYYYMMDD, HHMMSS )

      ! Add ADJ_DIR prefix to filename
      !FILENAME = TRIM( ADJ_DIR ) // TRIM( FILENAME )

      WRITE( 6, 100 ) TRIM( FILENAME )
 100  FORMAT( '     - MAKE_CSPEC_FILE: Writing ', a )

      ! Open checkpoint file for output
      CALL OPEN_BPCH2_FOR_WRITE( IU_RST, FILENAME, TITLE )

      !=================================================================
      ! Write each checkpointed quantity to the checkpoint file
      !=================================================================

      ! Checkpt additional values for full chem simulation
  
      ! Write the final species concetrations after full chemistry
      UNIT = 'molec/cm3/box'
          
      ! Loop over the total # of species.  This also includes the "fake"
      ! prod/loss family species for the ND65 diagnostic (bmy, 7/11/11)
      DO N = 1 , NTSPEC(1)
         
         ! The IFAM array denotes the index # of species in the CSPEC
         ! array that are "fake" ND65 prod/loss families.  If we 
         ! encounter one of these, then we can skip it (bmy, 7/11/11)
         IF ( ANY( IFAM == N ) ) THEN
            CYCLE
         ENDIF

!$OMP PARALLEL DO
!$OMP+DEFAULT( SHARED )
!$OMP+PRIVATE( I, J, L )
         DO L = 1, IPVERT
         DO J = 1, ILAT
         DO I = 1, ILONG
        
            ! fix recommended by pls, save CSPEC_FULL (hotp 2/18/09)
            ! now set conc no smalle than 1d-30
            IF ( CSPEC_FULL(I,J,L,N) .LE. 1d-30 ) THEN
                 TMP(I,J,L) = 1e-30
            ELSE
                 TMP(I,J,L) = CSPEC_FULL(I,J,L,N)
            ENDIF

         ENDDO
         ENDDO
         ENDDO
!$OMP END PARALLEL DO
 
         ! Save the species name to the RESERVED slot of the bpch file
         RESERVED = TRIM( NAMEGAS(N) )

         ! Write the data block to the CSPEC checkpoint file
         CALL BPCH2( IU_RST,    MODELNAME, LONRES,    LATRES,
     &               HALFPOLAR, CENTER180, CATEGORY,  N,
     &               UNIT,      GET_TAU(), GET_TAU(), RESERVED,
     &               ILONG,     ILAT,      IPVERT,    I0+1,
     &               J0+1,      1,         TMP(:,:,:) )
 
      ENDDO

      ! Close file
      CLOSE( IU_RST )

      !### Debug
      IF ( LPRT ) CALL DEBUG_MSG( '### MAKE_CSPEC_FILE: wrote file' )

      END SUBROUTINE MAKE_CSPEC_FILE
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: read_cspec_file
!
! !DESCRIPTION: Subroutine READ\_CSPEC\_FILE initializes GEOS-Chem chemical
!  species concentrations from a checkpoint file (binary punch file format).
!  The chemical species are saved into the CSPEC array, which is used by
!  the SMVGEAR and KPP solvers.
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE READ_CSPEC_FILE( YYYYMMDD, HHMMSS, IT_EXISTS ) 
!
! !USES:
!
      USE BPCH2_MOD,   ONLY : OPEN_BPCH2_FOR_READ
      USE COMODE_MOD,  ONLY : CSPEC_FULL
      USE COMODE_MOD,  ONLY : JLOP
      USE ERROR_MOD,   ONLY : DEBUG_MSG
      USE ERROR_MOD,   ONLY : ERROR_STOP
      USE FILE_MOD,    ONLY : IU_RST
      USE FILE_MOD,    ONLY : IOERROR
      USE FILE_MOD,    ONLY : FILE_EXISTS
      USE LOGICAL_MOD, ONLY : LPRT
      USE TIME_MOD,    ONLY : EXPAND_DATE

#     include "CMN_SIZE"                ! Size parameters
#     include "CMN"	                ! LPRT, NSRCX, LSOILNOX
#     include "comode.h"                ! ITLOOP, IGAS
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN) :: YYYYMMDD   ! YYYY/MM/DD GMT date
      INTEGER, INTENT(IN) :: HHMMSS     ! hh:mm:ss   GMT time
! 
! !REVISION HISTORY: 
!  30 Aug 2004 - D. Henze    - Initial version, based on READ_RESTART  
!  11 Jul 2011 - R. Yantosca - Now skip over ND65 families when reading 
!                              species from the restart.cspec.YYYYMMDDhh file
!  11 Jul 2011 - R. Yantosca - Added ProTeX headers
!  12 Jul 2011 - R. Yantosca - Now read species name from RESERVED slot
!                              of bpch file as an extra error check
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER             :: I, IOS, J, L, N, JLOOP, NN, NTL
      INTEGER             :: NCOUNT(NNPAR) 
      REAL*4		  :: TMP(ILONG,ILAT,IPVERT)
      LOGICAL             :: IT_EXISTS 

      REAL*8              :: SUMTC
      CHARACTER(LEN=255)  :: FILENAME
      CHARACTER(LEN=255)  :: INPUT_CHECKPT_FILE
      CHARACTER(LEN=255)  :: MSG
     

      ! For binary punch file, version 2.0
      INTEGER             :: NI,     NJ,     NL
      INTEGER             :: IFIRST, JFIRST, LFIRST
      INTEGER             :: NTRACER,   NSKIP
      INTEGER             :: HALFPOLAR, CENTER180
      REAL*4              :: LONRES,    LATRES
      REAL*8              :: ZTAU0,     ZTAU1
      CHARACTER(LEN=20)   :: MODELNAME
      CHARACTER(LEN=40)   :: CATEGORY
      CHARACTER(LEN=40)   :: UNIT     
      CHARACTER(LEN=40)   :: RESERVED

      !=================================================================
      ! READ_CSPEC_FILE begins here!
      !=================================================================

      ! Hardwire output file for now
      INPUT_CHECKPT_FILE = 'restart.cspec.YYYYMMDDhh'

      ! Initialize some variables
      !TMP(:,:,:) = 0e0
      ! use 1e-30 as min (hotp 2/25/09)
      TMP(:,:,:) = 1e-30

      !=================================================================
      ! Open checkpoint file and read top-of-file header
      !=================================================================
      
      ! Copy input file name to a local variable
      FILENAME = TRIM( INPUT_CHECKPT_FILE )

      ! Replace YYYY, MM, DD, HH tokens in FILENAME w/ actual values
      CALL EXPAND_DATE( FILENAME, YYYYMMDD, HHMMSS )

      ! Add ADJ_DIR prefix to name
      !FILENAME = TRIM( ADJ_DIR ) // TRIM( FILENAME )

      WRITE( 6, 100 ) TRIM( FILENAME )
 100  FORMAT( '     - READ_CSPEC_FILE: Reading ', a )
 
      ! Check to see if cspec restart file exists
      IT_EXISTS = FILE_EXISTS( FILENAME )
      IF ( .not. IT_EXISTS ) THEN 
         RETURN
      ENDIF 

      ! Open the binary punch file for input
      CALL OPEN_BPCH2_FOR_READ( IU_RST, FILENAME )

      ! Loop over all species in the chemical mechanism
      DO N = 1, NTSPEC(1)

         ! The IFAM array denotes the index # of species in the CSPEC
         ! array that are "fake" ND65 prod/loss families.  If we 
         ! encounter one of these, then we can skip it.
         IF ( ANY( IFAM == N ) ) THEN
            CYCLE
         ENDIF

         ! Read the values of CSPEC
         READ( IU_RST, IOSTAT=IOS )
     &       MODELNAME, LONRES, LATRES, HALFPOLAR, CENTER180

         ! IOS < 0 is end-of-file, so exit
         IF ( IOS < 0 ) GOTO 555

         ! IOS > 0 is a real I/O error -- print error message
         IF ( IOS > 0 ) 
     &      CALL IOERROR( IOS,IU_RST,'read_cspec_file:13' )

         ! Read data block header
         READ( IU_RST, IOSTAT=IOS )
     &         CATEGORY, NTRACER,  UNIT, ZTAU0,  ZTAU1,  RESERVED,
     &         NTL,      NN,       NL,   IFIRST, JFIRST, LFIRST,
     &         NSKIP

         ! Error check
         IF ( IOS /= 0 ) 
     &      CALL IOERROR(IOS,IU_RST,'read_cspec_file:14' )

         ! Read data block
         READ( IU_RST, IOSTAT=IOS )
     &       ( ( ( TMP(I,J,L), I= 1, NTL), J=1,NN ), L = 1, NL)

         ! Error check
         IF ( IOS /= 0 ) 
     &      CALL IOERROR( IOS,IU_RST,'read_cspec_file:16' )

         !==============================================================
         ! Assign data from the TMP array to CSPEC
         !==============================================================

         ! Only process checkpoint data 
         IF ( CATEGORY(1:8) == 'IJ-CHK-$' .and.
     &        NTL           == ILONG      .and. 
     &        NN            == ILAT       .and. 
     &        NL            == IPVERT            ) THEN

            ! Also make sure we have the proper species
            IF ( TRIM( NAMEGAS(N) ) /= TRIM( RESERVED ) ) THEN
               WRITE( 6, 200 ) TRIM( NAMEGAS(N) )
 200           FORMAT( 'Species mismatch for ', a )
               CALL ERROR_STOP( 'Species mismatch!', 
     &                          'READ_CSPEC_FILE (restart_mod.f)' )
            ENDIF

            ! Read data from temporary array into CSPEC_FULL
            ! NOTE: Using N instead of NTRACER will skip over
            ! the "fake" ND65 prod/loss families (bmy, 7/12/11)
            CSPEC_FULL(:,:,:,N) = TMP(:,:,:)

         ELSE
            CALL ERROR_STOP(' Restart data is not correct ', 
     &                   ' reading CSPEC, restart_mod')

         ENDIF
 
      ENDDO ! N 

 555  CONTINUE

      ! Close file
      CLOSE( IU_RST )      

      !### Debug
      IF ( LPRT ) CALL DEBUG_MSG( '### READ_CSPEC_FILE: read file' )

      END SUBROUTINE READ_CSPEC_FILE
!EOC
      END MODULE RESTART_MOD
