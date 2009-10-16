#############################################################################
##
#W  testcons.g           GAP 4 package `tomlib'                 Thomas Breuer
##
##  This file is used as input for the `testcons' target in `Makefile'.
##  The purpose of the contents is to test the consistency of the library of
##  tables of marks.
##
##  A logfile is saved in the `log' directory, and is mailed to me.
##

thispkg:= "tomlib";;

# Create the name for the logfile.
LoadPackage( "atlasrep" );  # currently needed for `CurrentDateTimeString'
dirname:= DirectoriesPackageLibrary( thispkg, "dev/log" );
datestring:= CurrentDateTimeString( [ "-u", "+%Y-%m-%d-%H-%M" ] );
logfile:= Filename( dirname[1], Concatenation( "testcons_", datestring ) );
statfile:= Filename( dirname[1], Concatenation( "fusions_", datestring ) );

# Start logging.
LogTo( logfile );

# Save the time when the process started.
CurrentDateTimeString();

# Load the package.
thispkg;
LoadPackage( thispkg );
# ReadPackage( thispkg, "dev/maintain.g" );
SizeScreen( [ 256 ] );;
#T perhaps set the linelength *before* starting the logging?
RereadPackage( "tomlib", "gap/test.gd" );
RereadPackage( "tomlib", "gap/test.gi" );

# Run the standard tests.
ReadTest( Filename( DirectoriesPackageLibrary( thispkg, "tst" ),
                    Concatenation( thispkg, ".tst" ) ) );

# Check `TOM_TBL_INFO'.
if    Length( TOM_TBL_INFO[1] ) <> Length( Set( TOM_TBL_INFO[1] ) )
   or Length( TOM_TBL_INFO[2] ) <> Length( Set( TOM_TBL_INFO[2] ) ) then
  Print( "#I  problem in `TOM_TBL_INFO'\n" );
fi;

# Check that each table of marks has valid straight line programs,
# and if yes, that the derived subgroups stored in the table are correct.
res:= TomLibTestStraightLineProgramsAndDerivedSubgroups();
if res = false then
  Print( "#I  problems in ",
         "`TomLibTestStraightLineProgramsAndDerivedSubgroups'\n" );
fi;

# Check that for each table of marks, a character table is available.
LoadPackage( "ctbllib" );
LIBTABLE.unload:= false;;
res:= TomLibTestCharacterTable();
if res = false then
  Print( "#I  problems in `TomLibTestCharacterTable'\n" );
fi;

# Check the consistency of fusions between tables of marks
# with the corresponding fusions between character tables.
res:= TomLibTestFusions();
if res = false then
  Print( "#I  problems in `TomLibTestFusions'\n" );
fi;

# Save the time when this process finished.
CurrentDateTimeString();

LogTo();

# Send me a message.
SendMail( [ "sam@math.rwth-aachen.de" ], [],
          Concatenation( thispkg, " testcons" ),
          StringFile( logfile ) );


#############################################################################
##
#E

