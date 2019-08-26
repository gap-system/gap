#@local g,t
gap> START_TEST("ctbl.tst");

# `ClassPositionsOf...' for the trivial group (which usually causes trouble)
gap> g:= TrivialGroup( IsPermGroup );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfAgemo( t, 2 );
[ 1 ]
gap> ClassPositionsOfCentre( t );
[ 1 ]
gap> ClassPositionsOfDerivedSubgroup( t );
[ 1 ]
gap> ClassPositionsOfDirectProductDecompositions( t );
[  ]
gap> ClassPositionsOfElementaryAbelianSeries( t );
[ [ 1 ] ]
gap> ClassPositionsOfFittingSubgroup( t );
[ 1 ]
gap> ClassPositionsOfLowerCentralSeries( t );
[ [ 1 ] ]
gap> ClassPositionsOfMaximalNormalSubgroups( t );
[  ]
gap> ClassPositionsOfNormalClosure( t, [ 1 ] );
[ 1 ]
gap> ClassPositionsOfNormalSubgroups( t );
[ [ 1 ] ]
gap> ClassPositionsOfUpperCentralSeries( t );
[ [ 1 ] ]
gap> ClassPositionsOfSolvableResiduum( t );
[ 1 ]
gap> ClassPositionsOfSupersolvableResiduum( t );
[ 1 ]
gap> ClassPositionsOfCentre( TrivialCharacter( t ) );
[ 1 ]
gap> ClassPositionsOfKernel( TrivialCharacter( t ) );
[ 1 ]

# Display for the table of the trivial group
gap> Display( CharacterTable( CyclicGroup( 1 ) ) );
CT1


       1a

X.1     1

# Display with unusual parameters
gap> t:= CharacterTable( SymmetricGroup( 3 ) );;  Irr( t );;
gap> Display( t, rec( centralizers:= false ) );
CT2

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

X.1     1 -1  1
X.2     2  . -1
X.3     1  1  1
gap> Display( t, rec( centralizers:= "ATLAS" ) );
CT2

        6  2  3

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

X.1     1 -1  1
X.2     2  . -1
X.3     1  1  1
gap> Display( t, rec( chars:= 1 ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

X.1     1 -1  1
gap> Display( t, rec( chars:= [ 2, 3 ] ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

X.2     2  . -1
X.3     1  1  1
gap> Display( t, rec( chars:= PermChars( t ) ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

Y.1     1  1  1
Y.2     2  .  2
Y.3     3  1  .
Y.4     6  .  .
gap> Display( t, rec( chars:= PermChars( t ), letter:= "P" ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

P.1     1  1  1
P.2     2  .  2
P.3     3  1  .
P.4     6  .  .
gap> Display( t, rec( classes:= 1 ) );
CT2

     2  1
     3  1

       1a
    2P 1a
    3P 1a

X.1     1
X.2     2
X.3     1
gap> Display( t, rec( classes:= [ 2, 3 ] ) );
CT2

     2  1  .
     3  .  1

       2a 3a
    2P 1a 3a
    3P 2a 1a

X.1    -1  1
X.2     . -1
X.3     1  1
gap> Display( t, rec( indicator:= true ) );
CT2

        2  1  1  .
        3  1  .  1

          1a 2a 3a
       2P 1a 1a 3a
       3P 1a 2a 1a
       2
X.1    +   1 -1  1
X.2    +   2  . -1
X.3    +   1  1  1
gap> Display( t, rec( indicator:= [ 2, 3 ] ) );
CT2

          2  1  1  .
          3  1  .  1

            1a 2a 3a
         2P 1a 1a 3a
         3P 1a 2a 1a
       2 3
X.1    + 0   1 -1  1
X.2    + 1   2  . -1
X.3    + 1   1  1  1
gap> Display( t, rec( powermap:= false ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a

X.1     1 -1  1
X.2     2  . -1
X.3     1  1  1
gap> Display( t, rec( powermap:= 2 ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a
    2P 1a 1a 3a

X.1     1 -1  1
X.2     2  . -1
X.3     1  1  1
gap> Display( t, rec( powermap:= [ 2, 3 ] ) );
CT2

     2  1  1  .
     3  1  .  1

       1a 2a 3a
    2P 1a 1a 3a
    3P 1a 2a 1a

X.1     1 -1  1
X.2     2  . -1
X.3     1  1  1
gap> # Note that the 'ATLAS' option for power maps has the desired effect
gap> # only if the function 'CambridgeMaps' is bound during the tests,
gap> # which depends on the loaded packages; we omit this test.
gap> # Display( t, rec( powermap:= "ATLAS" ) );
gap> Display( t,
>        rec( charnames:= List( CharacterParameters( t ), String ) ) );
CT2

                    2  1  1  .
                    3  1  .  1

                      1a 2a 3a
                   2P 1a 1a 3a
                   3P 1a 2a 1a

[ 1, [ 1, 1, 1 ] ]     1 -1  1
[ 1, [ 2, 1 ] ]        2  . -1
[ 1, [ 3 ] ]           1  1  1
gap> Display( t,
>        rec( classnames:= List( ClassParameters( t ), String ) ) );
CT2

     2                  1                  1                  .
     3                  1                  .                  1

       [ 1, [ 1, 1, 1 ] ]    [ 1, [ 2, 1 ] ]       [ 1, [ 3 ] ]
    2P [ 1, [ 1, 1, 1 ] ] [ 1, [ 1, 1, 1 ] ]       [ 1, [ 3 ] ]
    3P [ 1, [ 1, 1, 1 ] ]    [ 1, [ 2, 1 ] ] [ 1, [ 1, 1, 1 ] ]

X.1                     1                 -1                  1
X.2                     2                  .                 -1
X.3                     1                  1                  1

# viewing and printing of character tables with stored groups
gap> t:= CharacterTable( DihedralGroup( 8 ) );;
gap> View( t ); Print( "\n" );
CharacterTable( <pc group of size 8 with 3 generators> )
gap> Print( t, "\n" );
CharacterTable( Group( [ f1, f2, f3 ] ) )
gap> ViewString( t );
"CharacterTable( <group of size 8 with 3 generators> )"
gap> PrintString( t );
"CharacterTable( \"Group( \>[ f1, f2, f3 ]\<\> )\< )"
gap> t:= CharacterTable( SymmetricGroup( 5 ) );;
gap> View( t ); Print( "\n" );
CharacterTable( Sym( [ 1 .. 5 ] ) )
gap> Print( t, "\n" );
CharacterTable( SymmetricGroup( [ 1 .. 5 ] ) )
gap> ViewString( t );
"CharacterTable( Sym( [ 1 .. 5 ] ) )"
gap> PrintString( t );
"CharacterTable( \"Group( \>[ (1,2,3,4,5), (1,2) ]\<\> )\< )"

# entries of mutable attributes are immutable
gap> t:= CharacterTable( SymmetricGroup( 5 ) );
CharacterTable( Sym( [ 1 .. 5 ] ) )
gap> PowerMap( t, 2 );;  PowerMap( t, 3 );;
gap> Length( ComputedPowerMaps( t ) );
3
gap> IsMutable( ComputedPowerMaps( t ) );
true
gap> ForAny( ComputedPowerMaps( t ), IsMutable );
false
gap> Indicator( t, 2 );;
gap> Length( ComputedIndicators( t ) );
2
gap> IsMutable( ComputedIndicators( t ) );
true
gap> ForAny( ComputedIndicators( t ), IsMutable );
false
gap> PrimeBlocks( t, 2 );;
gap> Length( ComputedPrimeBlockss( t ) );
2
gap> IsMutable( ComputedPrimeBlockss( t ) );
true
gap> ForAny( ComputedPrimeBlockss( t ), IsMutable );
false

# create certain Brauer tables ...
# ... of p-solvable groups
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> IsCharacterTable( t mod 2 );
true
gap> IsCharacterTable( t mod 3 );
true

# ... where all Brauer characters lift to characteristic zero
gap> g:= PSL(2,5);;
gap> t:= CharacterTable( g );;
gap> IsCharacterTable( t mod 3 );
true
gap> IsCharacterTable( t mod 5 );
true

# ... where the Brauer tables of the factors of a product can be computed
gap> g:= AlternatingGroup( 5 );;
gap> t:= CharacterTable( g );;
gap> t:= CharacterTableDirectProduct( t, t );;
gap> IsCharacterTable( t mod 5 );
true

# test a bugfix
gap> g:= SmallGroup( 96, 3 );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfLowerCentralSeries( t );
[ [ 1 .. 12 ], [ 1, 3, 4, 5, 6, 9, 10, 11 ] ]
gap> g:= SmallGroup( 3^5, 22 );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfLowerCentralSeries( t );
[ [ 1 .. 35 ], [ 1, 4, 6, 12, 15 ], [ 1, 6, 15 ], [ 1 ] ]
gap> g:= SmallGroup( 96, 66 );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfSupersolvableResiduum( t );
[ 1, 5, 6 ]

##
gap> STOP_TEST( "ctbl.tst" );
