#############################################################################
##
#W  vspchom.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.vspchom_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  LeftModuleGeneralMappingByImages( <S>, <R>, <gens>, <imgs> )
##
LeftModuleGeneralMappingByImages := NewOperation(
    "LeftModuleGeneralMappingByImages",
    [ IsLeftModule, IsLeftModule, IsList, IsList ] );


#############################################################################
##
#O  LeftModuleHomomorphismByImages( <S>, <R>, <gens>, <imgs> )
##
LeftModuleHomomorphismByImages := NewOperation(
    "LeftModuleHomomorphismByImages",
    [ IsLeftModule, IsLeftModule, IsList, IsList ] );


#############################################################################
##
#O  LeftModuleHomomorphismByMatrix( <BS>, <matrix>, <BR> )
##
##  is the total and single-valued linear general mapping with <BS> a basis
##  of the source and <BR> a basis of the range, and the rows of the matrix
##  <matrix> being the coefficients vectors of the images of <BS> w.r.t.
##  <BR>.
##
LeftModuleHomomorphismByMatrix := NewOperation(
    "LeftModuleHomomorphismByMatrix",
    [ IsBasis, IsMatrix, IsBasis ] );


#############################################################################
##
#O  NaturalHomomorphismBySubspace( <V>, <W> ) . . . . . map onto factor space
##
NaturalHomomorphismBySubspace := NewOperation(
    "NaturalHomomorphismBySubspace",
    [ IsLeftModule, IsLeftModule ] );


#############################################################################
##
#P  IsFullHomModule( <M> )
##
##  A *full hom module* is a module $Hom_R(V,W)$, for a ring $R$ and two
##  left modules $V$, $W$.
##
IsFullHomModule := NewProperty( "IsFullHomModule", IsFreeLeftModule );
SetIsFullHomModule := Setter( IsFullHomModule );
HasIsFullHomModule := Tester( IsFullHomModule );


#############################################################################
##
#P  IsPseudoCanonicalBasisFullHomModule( <B> )
##
##  A basis of a full hom module is called pseudo canonical basis
##  if the matrices of its basis vectors w.r.t. the stored bases of source
##  and range contain exactly one identity entry and otherwise zeros.
##
##  Note that this is not canonical because it depends on the stored
##  bases of source and range.
##
IsPseudoCanonicalBasisFullHomModule := NewProperty(
    "IsPseudoCanonicalBasisFullHomModule", IsBasis );


#############################################################################
##
#O  Hom( <F>, <V>, <W> )  . . .  space of <F>-linear mappings from <V> to <W>
##
##  is the left module $Hom_F(V,W)$.
##
Hom := NewOperation( "Hom", [ IsRing, IsLeftModule, IsLeftModule ] );


#############################################################################
##
#O  End( <F>, <V> ) . . . . . .  space of <F>-linear mappings from <V> to <V>
##
##  is the left module $End_F(V)$.
##
End := NewOperation( "End", [ IsRing, IsLeftModule ] );


#############################################################################
##
#E  vspchom.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



