# 2005/11/28 (TB)
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );
gap> Display( t, rec( classes:= [ 4 ] ) );
Sym(4)

     2  .
     3  1

       3a
    2P 3a
    3P 1a

X.1     1
X.2     .
X.3    -1
X.4     .
X.5     1
