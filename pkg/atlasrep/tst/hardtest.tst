#############################################################################
##
#W  hardtest.tst        GAP 4 package `atlasrep'                Thomas Breuer
##
#H  @(#)$Id: hardtest.tst,v 1.28 2008/06/25 12:48:58 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains, among others, those checks for the AtlasRep package
##  that examine the transfer from a server and the matrices that are
##  contained in the local `atlasgens' directory.
##  NOTE that these tests cannot be performed without server access.
##
##  In order to run the tests, one starts GAP from the `tst' subdirectory
##  of the `pkg/atlasrep' directory, and calls `ReadTest( "hardtest.tst" );'.
##

gap> START_TEST("$Id: hardtest.tst,v 1.28 2008/06/25 12:48:58 gap Exp $");


# Load the package if necessary.
gap> LoadPackage( "atlasrep" );
true

# The character table library is used here.
gap> LoadPackage( "ctbllib" );
true

# Test transferring group generators in MeatAxe format (using `IO').
gap> dir:= DirectoriesPackageLibrary( "atlasrep", "datagens" );;
gap> id:= OneAtlasGeneratingSet( "A5", Characteristic, 2 ).identifier;;
gap> for file in List( id[2], name -> Filename( dir, name ) ) do
>      RemoveFile( file );
> od;
gap> id = AtlasGenerators( id ).identifier;
true

# Test transferring group generators in GAP format (using `wget').
gap> AtlasOfGroupRepresentationsInfo.wget:= true;;
gap> id:= OneAtlasGeneratingSetInfo( "A5", Characteristic, 0 ).identifier;;
gap> RemoveFile( Filename( dir, id[2] ) );;
gap> id = AtlasGenerators( id ).identifier;
true
gap> Unbind( AtlasOfGroupRepresentationsInfo.wget );

# Read all MeatAxe format files in the local installation.
gap> if not AtlasOfGroupRepresentationsTestFiles() then
>      Print( "#I  Error in `AtlasOfGroupRepresentationsTestFiles'\n" );
> fi;

# Test whether the group names are consistent (with verification test).
gap> if not AtlasOfGroupRepresentationsTestGroupOrders( true ) then
>      Print( "#I  Error in `AtlasOfGroupRepresentationsTestGroupOrders'\n" );
> fi;
gap> if not AtlasOfGroupRepresentationsTestSubgroupOrders() then
>      Print( "#I  Error in `AtlasOfGroupRepresentationsTestSubgroupOrders'\n" );
> fi;
gap> if not AtlasOfGroupRepresentationsTestStdCompatibility() then
>      Print( "#I  Error in `AtlasOfGroupRepresentationsTestStdCompatibility'\n" );
> fi;

# Check the conversion between binary and text format.
gap> if not AtlasOfGroupRepresentationsTestBinaryFormat() then
>      Print( "#I  Error in `AtlasOfGroupRepresentationsTestBinaryFormat'\n" );
> fi;

# Check whether changes of server files require cleanup.
gap> if not IsEmpty(
>        AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates() ) then
>      Print( "#I  Cleanup required by ",
>        "`AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates'\n" );
> fi;

# Check the interface functions.
gap> g:= "A5";;
gap> IsRecord( OneAtlasGeneratingSet( g ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsPermGroup ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsPermGroup, true ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsPermGroup, NrMovedPoints, 5 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsPermGroup,true,NrMovedPoints,5 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, IsPermGroup ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, NrMovedPoints, 5 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, NrMovedPoints, 5 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsMatrixGroup ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsMatrixGroup, true ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsMatrixGroup, Dimension, 2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, IsMatrixGroup,true,Dimension,2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, IsMatrixGroup ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, Characteristic, 2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, Characteristic, 2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, Dimension, 2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, Dimension, 2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, Characteristic,2,Dimension,2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1,Characteristic,2,Dimension,2 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, Ring, GF(2) ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, Ring, GF(2) ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, Ring, GF(2), Dimension, 4 ) );
true
gap> IsRecord( OneAtlasGeneratingSet( g, 1, Ring, GF(2), Dimension, 4 ) );
true

gap> # missing: \= method for SLPs!
gap> checkprg:= function( id )
> return IsRecord( id ) and LinesOfStraightLineProgram( id.program ) =
>  LinesOfStraightLineProgram(
>      AtlasProgram( id.identifier ).program );
> end;;
gap> checkprg( AtlasProgram( "M11", 2 ) );
true
gap> checkprg( AtlasProgram( "M11", 1, 2 ) );
true
gap> checkprg( AtlasProgram( "M11", "maxes", 2 ) );
true
gap> checkprg( AtlasProgram( "M11", 1, "maxes", 2 ) );
true
gap> checkprg( AtlasProgram( "M11", "classes" ) );
true
gap> checkprg( AtlasProgram( "M11", 1, "classes" ) );
true
gap> checkprg( AtlasProgram( "M11", "cyclic" ) );
true
gap> checkprg( AtlasProgram( "M11", 1, "cyclic" ) );
true
gap> checkprg( AtlasProgram( "L2(13)", "automorphism", "2" ) );
true
gap> checkprg( AtlasProgram( "L2(13)", 1, "automorphism", "2" ) );
true
gap> checkprg( AtlasProgram( "J4", 1, "restandardize", 2 ) );
true

# Test the ``minimal degrees feature''.
gap> info:= ComputedMinimalRepresentationInfo();;
gap> infostr:= StringOfMinimalRepresentationInfoData( info );;
# eventually, compare old and new version!
gap> AGR_TestMinimalDegrees();
true

# Call `AtlasClassNames' for all tables of nonsimple and almost simple
# groups.
# (Note that we have no easy access to the list of almost simple groups,
# here we use a heuristic argument based on the structure of names.)
# We check whether the function runs without error messages,
# and that the class names returned are different and are compatible with
# the element orders.
gap> digitprefix:= function( str )
>        local bad;
>        bad:= First( str, x -> not IsDigitChar( x ) );
>        if bad = fail then
>          return str;
>        else
>          return str{ [ 1 .. Position( str, bad ) - 1 ] };
>        fi;
> end;;
gap> simpl:= AllCharacterTableNames( IsSimple, true );;
gap> bad:= [ "A6.D8" ];;
gap> name:= "dummy";;
gap> for name in AllCharacterTableNames() do
>      pos:= Position( name, '.' );
>      if pos <> fail then
>        for simp in simpl do
>          if     Length( simp ) = pos-1
>             and name{ [ 1 .. pos-1 ] } = simp
>             and ForAll( "xMN", x -> Position( name, x, pos ) = fail )
>             and not name in bad then
>            # upward extension of a simple group
>            tbl:= CharacterTable( name );
>            classnames:= AtlasClassNames( tbl );
>            if    classnames = fail
>               or Length( classnames ) <> Length( Set( classnames ) )
>               or List( classnames, digitprefix )
>                   <> List( OrdersClassRepresentatives( tbl ), String ) then
>              Print( "#I  AtlasClassNames: problem for `", name, "'\n" );
>            fi;
>          elif   Length( simp ) = Length( name ) - pos
>             and name{ [ pos+1 .. Length( name ) ] } = simp
>             and ForAll( name{ [ 1 .. pos-1 ] },
>                         c -> IsDigitChar( c ) or c = '_' )
>             and not name in bad then
>            tbl:= CharacterTable( name );
>            classnames:= AtlasClassNames( tbl );
>            if    classnames = fail
>               or Length( classnames ) <> Length( Set( classnames ) ) then
>              Print( "#I  AtlasClassNames: problem for `", name, "'\n" );
>            fi;
>          fi;
>        od;
>      fi;
>    od;

# Test whether there are new `cyc' scripts for which the `cyc2ccls' script
# can be computed by GAP.
gap> if not AtlasOfGroupRepresentationsTestCycToCcls() then
>      Print( "#I  Error in ",
>             "`AtlasOfGroupRepresentationsTestCycToCcls'\n" );
> fi;

# Test whether the scripts that return class representatives
# are sufficiently consistent.
# (This test should be the last one,
# because newly added scripts may be too hard for it.)
gap> if not AtlasOfGroupRepresentationsTestClassScripts() then
>      Print( "#I  Error in ",
>             "`AtlasOfGroupRepresentationsTestClassScripts'\n" );
> fi;


gap> STOP_TEST( "hardtest.tst", 10000000 );


#############################################################################
##
#E

