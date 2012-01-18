#############################################################################
##
#W  atlasrep.tst         GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains among others the function calls needed to perform some
##  of the sanity checks mentioned in the manual section about sanity checks.
##
##  In order to run the tests, one starts GAP from the `tst' subdirectory
##  of the `pkg/atlasrep' directory, and calls `ReadTest( "atlasrep.tst" );'.
##
##  If one of the functions `AGR.Test.Words', `AGR.Test.FileHeaders' reports
##  an error then detailed information can be obtained by increasing the
##  info level of `InfoAtlasRep' to at least 1 and then running the tests
##  again.
##

gap> START_TEST( "Input file: atlasrep.tst" );


# Load the package.
gap> LoadPackage( "atlasrep" );
true
gap> LoadPackage( "ctbllib" );
true
gap> ReadPackage( "atlasrep", "gap/test.g" );
true

# Test whether the locally stored straight line programs
# can be read and processed.
gap> if not AGR.Test.Words() then
>      Print( "#I  Error in `AGR.Test.Words'\n" );
> fi;

# Test whether the locally stored generators are consistent
# with their filenames.
gap> if not AGR.Test.FileHeaders() then
>      Print( "#I  Error in `AGR.Test.FileHeaders'\n" );
> fi;

# Test the standardization of the available generators.
#T missing!

# Test reading and writing straight line programs.
gap> str:= "\
> mu 1 2 3\n\
> mu 3 2 4\n\
> mu 3 4 5\n\
> mu 3 5 6\n\
> mu 6 6 5\n\
> mu 6 5 1\n\
> iv 4 5\n\
> mu 5 2 6\n\
> mu 6 4 2\n\
> iv 3 4\n\
> mu 4 1 5\n\
> mu 5 3 1";;
gap> prog:= ScanStraightLineProgram( str, "string" );
rec( program := <straight line program> )
gap> Print( AtlasStringOfProgram( prog.program ) );
inp 2
mu 1 2 3
mu 3 2 4
mu 3 4 5
mu 3 5 6
mu 6 6 5
mu 6 5 1
iv 4 5
mu 5 2 6
mu 6 4 2
iv 3 4
mu 4 1 5
mu 5 3 1
oup 2
gap> Print( AtlasStringOfProgram( prog.program, "mtx" ) );
# inputs are expected in 1 2
zmu 1 2 3
zmu 3 2 4
zmu 3 4 5
zmu 3 5 6
zmu 6 6 5
zmu 6 5 1
ziv 4 5
zmu 5 2 6
zmu 6 4 2
ziv 3 4
zmu 4 1 5
zmu 5 3 1
echo "outputs are in 1 2"
gap> str:= "\
> mu 1 2 3\n\
> mu 3 2 4\n\
> mu 3 4 5\n\
> mu 5 4 6\n\
> mu 6 2 7\n\
> oup 4 7 4 6 3";;
gap> prog:= ScanStraightLineProgram( str, "string" );
rec( program := <straight line program> )
gap> Print( AtlasStringOfProgram( prog.program,
>     ["5A","6A","8A","11A"] ) );
inp 2
mu 1 2 3
mu 3 2 4
mu 3 4 5
mu 5 4 6
mu 6 2 7
echo "Classes 5A 6A 8A 11A"
oup 4 7 4 6 3
gap> prg:= ScanStraightLineProgram( "inp 4 1 2 3 4\noup 3 1 2 4", "string" );;
gap> Display( prg.program );
# input:
r:= [ g1, g2, g3, g4 ];
# program:
# return values:
[ r[1], r[2], r[4] ]
gap> prg:= ScanStraightLineProgram( "inp 3 1 2 3\noup 3 1 2 3", "string" );;
gap> Display( prg.program );
# input:
r:= [ g1, g2, g3 ];
# program:
# return values:
[ r[1], r[2], r[3] ]
gap> str:= "\
> inp 2\n\
> mu 1 2 3\n\
> mu 1 1 4\n\
> mu 3 3 5\n\
> echo \"Classes 1A 2A 3A 5A 5B\"\n\
> oup 5 4 1 2 3 5";;
gap> prg:= ScanStraightLineProgram( str, "string" );
rec( outputs := [ "1A", "2A", "3A", "5A", "5B" ], 
  program := <straight line program> )
gap> Display( prg.program );
# input:
r:= [ g1, g2 ];
# program:
r[3]:= r[1]*r[2];
r[4]:= r[1]*r[1];
r[5]:= r[3]*r[3];
# return values:
[ r[4], r[1], r[2], r[3], r[5] ]
gap> str:= "cj 1 2 3\noup 1 3";;
gap> prg:= ScanStraightLineProgram( str, "string" );;
gap> AtlasStringOfProgram( prg.program );
"inp 2\ncj 1 2 3\noup 1 3\n"

# Test reading group generators in {\MeatAxe} format.
gap> dir:= DirectoriesPackageLibrary( "atlasrep", "tst" );;

# mode 12
gap> str:= "\
> 12     1    9     1\n\
>      1\n\
>      4\n\
>      5\n\
>      2\n\
>      3\n\
>      8\n\
>      6\n\
>      9\n\
>      7";;
gap> perms:= ScanMeatAxeFile( str, "string" );
[ (2,4)(3,5)(6,8,9,7) ]
gap> str:= "\
> permutation degree=9\n\
> 1 4 5 2 3 8 6 9 7";;
gap> perms = ScanMeatAxeFile( str, "string" );
true
gap> ScanMeatAxeFile( Filename( dir, "perm7.tst" ) );
[ (1,2,3)(4,6) ]

# mode 1
gap> str:= "\
>  1     9     3     3\n\
> 200\n\
> 020\n\
> 331";
" 1     9     3     3\n200\n020\n331"
gap> scan:= ScanMeatAxeFile( str, "string" );
[ [ Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3), 0*Z(3) ], 
  [ Z(3^2), Z(3^2), Z(3)^0 ] ]
gap> str:= "\
> matrix field=9 rows=3 cols=3\n\
> 200\n\
> 020\n\
> 331";;
gap> scan = ScanMeatAxeFile( str, "string" );
true
gap> scan = ScanMeatAxeFile( Filename( dir, "matf9r3.tst" ) );
true
gap> scan = ScanMeatAxeFile( Filename( dir, "matf81r3.tst" ) );
true

# mode 3
gap> str:= "\
>  3    11    10    10\n\
>   0  1  0  0  0  0  0  0  0  0\n\
>   1  0  0  0  0  0  0  0  0  0\n\
>   0  0  0  1  0  0  0  0  0  0\n\
>   0  0  1  0  0  0  0  0  0  0\n\
>   0  0  0  0  0  0  1  0  0  0\n\
>   0  0  0  0  0  0  0  1  0  0\n\
>   0  0  0  0  1  0  0  0  0  0\n\
>   0  0  0  0  0  1  0  0  0  0\n\
>   6  6 10 10  9 10  9 10 10  0\n\
>  10 10  9  9  1  6  1  6  0 10";;
gap> scan:= ScanMeatAxeFile( str, "string" );;
gap> Print( scan, "\n" );
[ [ 0*Z(11), Z(11)^0, 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ Z(11)^0, 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ 0*Z(11), 0*Z(11), 0*Z(11), Z(11)^0, 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ 0*Z(11), 0*Z(11), Z(11)^0, 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), Z(11)^0, 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), Z(11)^0,
       0*Z(11), 0*Z(11) ],
  [ 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), Z(11)^0, 0*Z(11), 0*Z(11), 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), 0*Z(11), Z(11)^0, 0*Z(11), 0*Z(11),
       0*Z(11), 0*Z(11) ],
  [ Z(11)^9, Z(11)^9, Z(11)^5, Z(11)^5, Z(11)^6, Z(11)^5, Z(11)^6, Z(11)^5,
       Z(11)^5, 0*Z(11) ],
  [ Z(11)^5, Z(11)^5, Z(11)^6, Z(11)^6, Z(11)^0, Z(11)^9, Z(11)^0, Z(11)^9,
       0*Z(11), Z(11)^5 ] ]
gap> str:= "\
> matrix field=11 rows=10 cols=10\n\
>   0  1  0  0  0  0  0  0  0  0\n\
>   1  0  0  0  0  0  0  0  0  0\n\
>   0  0  0  1  0  0  0  0  0  0\n\
>   0  0  1  0  0  0  0  0  0  0\n\
>   0  0  0  0  0  0  1  0  0  0\n\
>   0  0  0  0  0  0  0  1  0  0\n\
>   0  0  0  0  1  0  0  0  0  0\n\
>   0  0  0  0  0  1  0  0  0  0\n\
>   6  6 10 10  9 10  9 10 10  0\n\
>  10 10  9  9  1  6  1  6  0 10";;
gap> scan = ScanMeatAxeFile( str, "string" );
true
gap> scan = ScanMeatAxeFile( Filename( dir, "matf11r10.tst" ) );
true

# mode 4

# mode 5
gap> file:= Filename( dir, "matf7r3.tst" );;
gap> scan:= ScanMeatAxeFile( file );
[ [ Z(7)^5, 0*Z(7), Z(7)^0 ], [ 0*Z(7), Z(7), 0*Z(7) ], 
  [ Z(7)^2, Z(7)^2, Z(7) ] ]
gap> str:= StringFile( file );;
gap> scan = ScanMeatAxeFile( str, "string" );
true

# mode 6

# mode 2
gap> str:= "\
> 2 5 3 6\n\
> 4\n\
> 6\n\
> 1";;
gap> scan:= ScanMeatAxeFile( str, "string" );
[ [ 0*Z(5), 0*Z(5), 0*Z(5), Z(5)^0, 0*Z(5), 0*Z(5) ], 
  [ 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), Z(5)^0 ], 
  [ Z(5)^0, 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5), 0*Z(5) ] ]
gap> str:= "\
> matrix field=5 rows=3 cols=6\n\
> 000100\n\
> 000001\n\
> 100000";;
gap> scan = ScanMeatAxeFile( str, "string" );
true
gap> scan:= ScanMeatAxeFile( Filename( dir, "permmat7.tst" ) );;
gap> scan = PermutationMat( (1,2,3)(4,6), 7, GF(3) );
true

# Test writing group generators in {\MeatAxe} format.
# (Cover the cases of matrices over small fields, over large prime fields,
# and over large nonprime fields.)
gap> mat:= [ [ 1, 0 ], [ 0, 0 ] ] * Z(3)^0;; # (not a permutation matrix)
gap> MeatAxeString( mat, 3 );
"1 3 2 2\n10\n00\n"
gap> mat:= [ [ 1, 0 ], [ 1, 0 ] ] * Z(3)^0;  # (not a permutation matrix)
[ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, 0*Z(3) ] ]
gap> MeatAxeString( mat, 3 );
"1 3 2 2\n10\n10\n"
gap> q:= 101;;
gap> mat:= RandomMat( 20, 20, GF(q) );;
gap> str:= MeatAxeString( mat, q );;
gap> ScanMeatAxeFile( str, "string" ) = mat;
true
gap> q:= 3^7;;
gap> mat:= RandomMat( 20, 20, GF(q) );;
gap> str:= MeatAxeString( mat, q );;
gap> ScanMeatAxeFile( str, "string" ) = mat;
true

# Check access to representations with unusual parameters.
gap> OneAtlasGeneratingSetInfo( IsPermGroup, true );;
gap> OneAtlasGeneratingSetInfo( [ "A5", "A6" ], IsPermGroup, true );;
gap> AllAtlasGeneratingSetInfos( IsPermGroup, true );;
gap> AllAtlasGeneratingSetInfos( [ "A5", "A6" ], IsPermGroup, true );;
gap> OneAtlasGeneratingSetInfo( Identifier, "a" );;
gap> OneAtlasGeneratingSetInfo( Position, 1 );;
gap> OneAtlasGeneratingSetInfo( Position, 10^6 );
fail
gap> chi:= PermChars( CharacterTable( "M11" ), [ 11 ] )[1];;
gap> OneAtlasGeneratingSetInfo( Character, chi );;
gap> OneAtlasGeneratingSetInfo( "M11", Character, chi );;

# Check that the function `StringOfAtlasTableOfContents' works.
gap> StringOfAtlasTableOfContents( "remote" );;

# Check whether reading the file `atlasprm.g' reports inconsistencies,
# and whether store/replace of a table of contents works.
gap> level:= InfoLevel( InfoAtlasRep );;
gap> SetInfoLevel( InfoAtlasRep, 3 );
gap> tmpname:= Filename( DirectoryTemporary(), "atlastoc.tmp" );;
gap> StoreAtlasTableOfContents( tmpname );
gap> oldval:= AtlasOfGroupRepresentationsInfo.TableOfContents.( "remote" );;
gap> ReplaceAtlasTableOfContents( tmpname );
gap> newval:= AtlasOfGroupRepresentationsInfo.TableOfContents.( "remote" );;
gap> newval = oldval;
true
gap> SetInfoLevel( InfoAtlasRep, level );

gap> STOP_TEST( "atlasrep.tst", 10000000 );


#############################################################################
##
#E

