#############################################################################
##
#W  liefam.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definition of the family of Lie elements of a
##  family of ring elements.
##
Revision.liefam_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsLieObject( <obj> )
##
IsLieObject := NewCategory( "IsLieObject",
        IsRingElement
    and IsZeroSquaredElement
    and IsJacobianElement );


#############################################################################
##
#A  LieFamily( <Fam> )
##
##  is a family $F$ isomorphic to the family <Fam>, but with the Lie bracket
##  as infix multiplication.
##  That is, for $x$, $y$ in <Fam>, the product of the images in $F$ will be
##  the image of $x \* y - y \* x$.
##
##  The standard kind of objects in a Lie family <F> is '<F>!.packedKind'.
##
##  The isomorphism is given by 'Embedding( <Fam>, $F$ )'.
##
LieFamily := NewAttribute( "LieFamily", IsFamily );
SetLieFamily := Setter( LieFamily );
HasLieFamily := Tester( LieFamily );


#############################################################################
##
#A  LieObject( <obj> )
##
LieObject := NewAttribute( "LieObject", IsRingElement );


#############################################################################
##
#F  IsLieFamFam( <LieFam>, <Fam> )
#F  IsFamLieFam( <Fam>, <LieFam> )
##
IsLieFamFam := function( LieFam, Fam )
    return HasLieFamily( Fam ) and IsIdentical( LieFamily( Fam ), LieFam );
end;

IsFamLieFam := function( Fam, LieFam )
    return HasLieFamily( Fam ) and IsIdentical( LieFamily( Fam ), LieFam );
end;


#############################################################################
##
#E  liefam.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



