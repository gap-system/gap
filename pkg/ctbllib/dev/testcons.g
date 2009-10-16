#############################################################################
##
#W  testcons.g           GAP 4 package `ctbllib'                Thomas Breuer
##
##  This file is used as input for the `testcons' target in `Makefile'.
##  The purpose of the contents is to test the consistency of the character
##  table library.
#T eventually the consistency with other data libraries must be tested, too!
##
##  A logfile is saved in the `log' directory, and is mailed to me.
##

thispkg:= "ctbllib";;

# Create the name for the logfile.
LoadPackage( "atlasrep" );  # currently needed for `CurrentDateTimeString'
dirname:= DirectoriesPackageLibrary( thispkg, "dev/log" );
datestring:= CurrentDateTimeString( [ "-u", "+%Y-%m-%d-%H-%M" ] );
logfile:= Filename( dirname[1], Concatenation( "testcons_", datestring ) );
statfile:= Filename( dirname[1], Concatenation( "fusions_", datestring ) );
SizeScreen( [ 256 ] );;

# Start logging.
LogTo( logfile );

# Save the time when the process started.
CurrentDateTimeString();

# Load the package.
thispkg;
LoadPackage( thispkg );
ReadPackage( thispkg, "dev/maintain.g" );

# Run the standard tests.
ReadTest( Filename( DirectoriesPackageLibrary( thispkg, "tst" ),
                    Concatenation( thispkg, ".tst" ) ) );

# Check that exactly all simple tables have this information stored.
issimple:= function( tbl )
  local simplestored;

  simplestored:= HasIsSimpleCharacterTable( tbl ) and
                 IsSimpleCharacterTable( tbl );
  if IsSimpleCharacterTable( tbl ) then
    if not simplestored then
      Print( "#E  ", tbl, " is simple but does not store it\n" );
    fi;
  elif simplestored then
    Print( "#E  ", tbl, " is not simple but stores it\n" );
  fi;
  return false;
end;;
AllCharacterTableNames( issimple, true );;

# Check that tables of direct products are stored as such.
isdirectproduct:= function( tbl )
  if not IsEmpty( ClassPositionsOfDirectProductDecompositions( tbl ) ) and
     not HasConstructionInfoCharacterTable( tbl ) then
    Print( "#E  ", tbl, " is a direct product but not stored as such\n" );
  fi;
  return false;
end;;
AllCharacterTableNames( isdirectproduct, true );;

# List those tables for which the construction is still a function.
fun:= function( tbl )
  if     HasConstructionInfoCharacterTable( tbl )
     and IsFunction( ConstructionInfoCharacterTable( tbl ) ) then
    Print( "#I  construction is a function for ", tbl, "\n" );
  fi;
  return true;
end;;
AllCharacterTableNames( fun, false );;

# Check that for tables with relative names of the form `<grp>M<n>' or
# `<grp>N<n>', a fusion to <grp> is stored.
res:= CTblLibTestMax();;
if res = false then
  Print( "#I  problems in `CTblLibTestMax'\n" );
fi;

# Check that for tables with names of the form `<grp>N<p>',
# the Sylow <p> subgroup is really a normal subgroup and has the right order.
res:= CTblLibTestSylowNormalizers();;
if res = false then
  Print( "#I  problems in `CTblLibTestSylowNormalizers'\n" );
fi;

# Check that for tables with names of the form `<grp>C<nam>',
# the table can be the centralizer of the class <nam> in <grp>,
# in particular that a reasonable fusion into <grp> is stored.
res:= CTblLibTestElementCentralizers();;
if res = false then
  Print( "#I  problems in `CTblLibTestElementCentralizers'\n" );
fi;

# Check that for tables with names of the form `<grp>N<nam>',
# the table can be the normalizer of the class <nam> in <grp>,
# in particular that a reasonable fusion into <grp> is stored.
res:= CTblLibTestElementNormalizers();;
if res = false then
  Print( "#I  problems in `CTblLibTestElementNormalizers'\n" );
fi;

# List the open problems/new ideas marked with `#T' in the files.
#T !!

# Check that the names of ordinary tables do not involve the substring `mod'.
for name in LIBLIST.allnames do
  if PositionSublist( name, "mod" ) <> fail then
    Print( "#E  name `", name, "' contains substring `mod'\n" );
  fi;
od;

# Check that for each table of marks in the library of tables of marks,
# there is an ordinary character table.
#T !!

# Recompute all table automorphisms of ordinary and Brauer tables.
CTblLibTestTableAutomorphisms();;

# Check the `InfoText' values of ordinary tables.
res:= CTblLibTestInfoText();;
if res = false then
  Print( "#I  problems in `CTblLibTestInfoText'\n" );
fi;

# Check the constructions.
res:= CTblLibTestConstructions();;
if res = false then
  Print( "#I  problems in `CTblLibTestConstructions'\n" );
fi;

# Check that those factor fusions are stored on the ordinary tables
# that are needed to create Brauer tables.
res:= CTblLibTestFactorsModOP();;
if res = false then
  Print( "#I  problems in `CTblLibTestFactorsModOP'\n" );
fi;

# Recompute all fusions (and create statistics information).
SizeScreen();
statinfo:= InitFusionsStatistics( statfile );;
res:= CTblLibTestFusions( statinfo );;
if res = false then
  Print( "#I  problems in `CTblLibTestFusions'\n" );
fi;
FinalizeFusionsStatistics( statinfo );

# Recompute all power maps.
res:= CTblLibTestPowerMaps();;
if res = false then
  Print( "#I  problems in `CTblLibTestPowerMaps'\n" );
fi;

# Check the Brauer tables:
# The decomposition matrices and inverses must consist of integers,
# tensor products of Brauer characters must decompose into Brauer characters,
# and the 2nd indicators are tested.
brauernames:= function( ordtbl )
  local primes;
  primes:= Set( Factors( Size( ordtbl ) ) );
  return List( primes, p -> Concatenation( Identifier( ordtbl ),
                                           "mod", String( p ) ) );
end;;
testBrauerTables:= function( modtbl )
  local result;
  result:= CTblLibTestBlocksInfo( modtbl );
  result:= CTblLibTestTensorDecomposition( modtbl ) and result;
  result:= CTblLibTestIndicators( modtbl ) and result;
  return result;
end;;
if not IsEmpty( AllCharacterTableNames( OfThose, brauernames,
                                        IsCharacterTable, true,
                                        testBrauerTables, false ) ) then
  Print( "#E  problems in Brauer tables\n" );
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

