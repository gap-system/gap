# 2005/12/08 (TB)
gap> LoadPackage("ctbllib", false);;
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );  Display( t,
>     rec( powermap:= "ATLAS", centralizers:= "ATLAS", chars:= false ) );
Sym(4)

    24  4  8  3  4

 p      A  A  A  B
 p'     A  A  A  A
    1A 2A 2B 3A 4A


#############################################################################
#
# Tests requiring Crisp 
