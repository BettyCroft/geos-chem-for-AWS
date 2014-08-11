#!/usr/bin/perl -w
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: lightdist.pl
#
# !DESCRIPTION: Reads the light_dist.ott2010.dat file and converts 
#  the data in the file to hardwired F90 commands for inlining into
#  an include file.  This facilitates I/O in the ESMF environment.
#\\
#\\
# !INTERFACE:
#
# !USES:
#
require 5.003;      # need this version of Perl or newer
use English;        # Use English language
use Carp;           # Strict error checking
use strict;         # Force explicit variable declarations (like IMPLICIT NONE)
#
# !PUBLIC MEMBER FUNCTIONS:
#  &getProTexHeader : Returns
#  &main            : Driver program
#
# !REMARKS:
#  You need to specify the root emissions data directory by setting
#  the $HEMCO_DATA_ROOT environment variable accordingly.
#  
# !CALLING SEQUENCE:
#  gfed3.pl
#
# !REVISION HISTORY:
#  11 Aug 2014 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: getProTeXHeader
#
# !DESCRIPTION: Returns a subroutine header for the include file.
#\\
#\\
# !INTERFACE:
#
sub getProTeXHeader() {
#
# !REVISION HISTORY: 
#  11 Aug 2014 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
  # HERE Docs
  my @header  = <<EOF;
!EOC
!------------------------------------------------------------------------------
!                  GEOS-Chem Global Chemical Transport Model                  !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: lightning_cdf_include.H
!
! !DESCRIPTION: Include file with the cumulative probability distribution
!  functions used to partition column lightning NO in the vertical.
!\\
!\\
! !REMARKS:
!  This file was created by HEMCO/Extensions/Preprocess/lightdist.pl.
!
!  DATA:
!  -----
!  Cumulative emissions of NOx from lightning.  At the top of the cloud 
!  (16km) 100% of NOx has been emitted into the column.  At surface (0km) 
!  0% of NOx  has been emitted into the column. Taken from Table 2, 
!  Ott et al., JGR, 2010.
!
!  There are 4 CDFs for 4 different types of lightning:
!
!  PROFILE(L,1) = Lightning in tropical    marine      regions
!  PROFILE(L,2) = Lightning in tropical    continental regions
!  PROFILE(L,3) = Lightning in midlatitude continental regions
!  PROFILE(L,4) = Lightning in subtropical continental regions
!
!  where L is the level index.  L=0 is the top of the atmosphere (16km) and
!  L=3200 is the surface.  The data points are in 0.005 km increments.
!
! !REVISION HISTORY: 
!  08 Aug 2014 - R. Yantosca - Initial version
!EOP
!------------------------------------------------------------------------------
!BOC
EOF

  # Return to calling program
  return( @header );
}			    
#EOP
#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: main
#
# !DESCRIPTION: Reads the lightdist.ott2010.dat file and writes out
#  equivalent F90 assignment statements commands.
#\\
#\\
# !REMARKS:
#  The format of the input file is:
#  Emission factors in kg/kgDM or kgC/kgDM
#  Column 1 = Species Number
#  Column 2 = Species Name
#  Column 3 = Ag Waste Emission Factor
#  Column 4 = Deforestation Emission Factor
#  Column 5 = Extratrop Forest Emission Factor
#  Column 6 = Peat Emission Factor
#  Column 7 = Savanna Emission Factor
#  Column 8 = Woodland Emission Factor
# 
# !REVISION HISTORY: 
#  11 Aug 2014 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC
#
# !LOCAL VARIABLES:
#
sub main() {

  # Strings
  my $rootDir = "$ENV{'HEMCO_DATA_ROOT'}";
  my $inFile  = "$rootDir/LIGHTNOX/v2014-07/light_dist.ott2010.dat";
  my $outFile = "lightning_cdf_include.H";
  my $line    = "";
  my $nStr    = "";

  # Numbers
  my $n       = 0;

  # Arrays
  my @lines   = ();
  my @result  = ();

  # Get subroutine header
  my @header  = &getProTeXHeader();

  #========================================================================
  # Open files and write the subroutine header to the output file
  #========================================================================

  # Open input and output files
  open( I, "$inFile"   ) or croak( "Cannot open $inFile!\n" );
  open( O, ">$outFile" ) or croak( "Cannot open $outFile\n" );

  # Write subroutine header to output file
  foreach $line ( @header ) { print O "$line"; }

  #=========================================================================
  # Read data from the lightning CDF file
  #=========================================================================

  # Parse input file and write F90 commands to output file
  foreach $line ( <I> ) {

    # Remove newlines
    chomp( $line );
    $line =~ s/\r//g;

    # Parse the line
    if    ( $line =~ m/\#/ ) { ; } # Skip header lines
    else                     {

      #=====================================================================
      # This line has the lightning CDF information
      #=====================================================================

      # Split the line
      @result = split( ' ', $line );

      # Increment
      $n++;

      # Pad spaces (cheap algorithm)
      if    ( $n < 10   ) { $nStr = "   $n"; }
      elsif ( $n < 100  ) { $nStr = "  $n";  }
      elsif ( $n < 1000 ) { $nStr = " $n";   }
      else                { $nStr = "$n";    }

      # Write out the F90 commands to initialize the arrays
      print O "   PROFILE($nStr,1 ) = $result[0]d0\n";
      print O "   PROFILE($nStr,2 ) = $result[1]d0\n";
      print O "   PROFILE($nStr,3 ) = $result[2]d0\n";
      print O "   PROFILE($nStr,4 ) = $result[3]d0\n\n";

    }
  }

  #=========================================================================
  # Cleanup and quit 
  #=========================================================================

  # Print ProTeX "end of code" tag
  print O "!EOC\n";

  # Close files
  close( I );
  close( O );

  # Return status
  return( $? );
}

#------------------------------------------------------------------------------

# Call main program
main();

# Return status
exit( $? );
#EOC


