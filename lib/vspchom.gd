#############################################################################
##
#W  vspchom.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.vspchom_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  LeftModuleGeneralMappingByImages( <V>, <W>, <gens>, <imgs> )
##
##  is a general mapping from the left $R$-module <V> to the left $R$-module
##  <W>.
##  This general mapping is defined by mapping the entries in the list <gens>
##  (elements of <V>) to the entries in the list <imgs> (elements of <W>),
##  and taking the $R$-linear closure.
##
##  <gens> need not generate <V> as a left $R$-module, and if the
##  specification does not define a linear mapping then the result will be 
##  multivalued.
##  Hence, in general it is not a mapping.
##
DeclareOperation( "LeftModuleGeneralMappingByImages",
    [ IsLeftModule, IsLeftModule, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  LeftModuleHomomorphismByImages( <S>, <R>, <gens>, <imgs> )
##
##  `LeftModuleHomomorphismByImages' returns the left module homomorphism
##  with source <S> and range <R> that is defined by mapping the list <gens>
##  of generators of <S> to the list <imgs> of images in <R>.
##
##  If <gens> does not generate <S> or if the homomorphism does not exist
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then `fail' is returned.
##
##  One can avoid the checks by calling `LeftModuleHomomorphismByImagesNC',
##  and one can construct multi-valued mappings with
##  `LeftModuleGeneralMappingByImages'.
##
DeclareGlobalFunction( "LeftModuleHomomorphismByImages" );


#############################################################################
##
#O  LeftModuleHomomorphismByImagesNC( <S>, <R>, <gens>, <imgs> )
##
##  `LeftModuleHomomorphismByImagesNC' is the operation that is called by the
##  function `LeftModuleHomomorphismByImages'.
##  Its methods may assume that <gens> generates <S> and that the mapping of
##  <gens> to <imgs> defines a left module homomorphism.
##  Results are unpredictable if these conditions do not hold.
##
##  For creating a possibly multi-valued mapping from <A> to <B> that
##  respects addition, multiplication, and scalar multiplication,
##  `LeftModuleGeneralMappingByImages' can be used.
##
#T see the comment in the declaration of `GroupHomomorphismByImagesNC'!
##
DeclareOperation( "LeftModuleHomomorphismByImagesNC",
    [ IsLeftModule, IsLeftModule, IsList, IsList ] );


#############################################################################
##
#A  AsLeftModuleGeneralMappingByImages( <map> )
##
DeclareAttribute( "AsLeftModuleGeneralMappingByImages", IsGeneralMapping );


#############################################################################
##
#O  LeftModuleHomomorphismByMatrix( <BS>, <matrix>, <BR> )
##
##  is the total and single-valued linear general mapping with <BS> a basis
##  of the source and <BR> a basis of the range, and the rows of the matrix
##  <matrix> being the coefficients vectors of the images of <BS> w.r.t.
##  <BR>.
##
DeclareOperation( "LeftModuleHomomorphismByMatrix",
    [ IsBasis, IsMatrix, IsBasis ] );


#############################################################################
##
#O  NaturalHomomorphismBySubspace( <V>, <W> ) . . . . . map onto factor space
##
##  For a vector space <V> and a subspace <W> of <V>, this function 
##  returns the natural projection of <V> onto <V>/<W>.
##
DeclareOperation( "NaturalHomomorphismBySubspace",
    [ IsLeftModule, IsLeftModule ] );


#############################################################################
##
#P  IsFullHomModule( <M> )
##
##  A *full hom module* is a module $Hom_R(V,W)$, for a ring $R$ and two
##  left modules $V$, $W$.
##
DeclareProperty( "IsFullHomModule", IsFreeLeftModule );


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
DeclareProperty( "IsPseudoCanonicalBasisFullHomModule", IsBasis );


#############################################################################
##
#O  Hom( <F>, <V>, <W> )  . . .  space of <F>-linear mappings from <V> to <W>
##
##  is the left module $Hom_F(V,W)$.
##
DeclareOperation( "Hom", [ IsRing, IsLeftModule, IsLeftModule ] );


#############################################################################
##
#O  End( <F>, <V> ) . . . . . .  space of <F>-linear mappings from <V> to <V>
##
##  is the left module $End_F(V)$.
##
DeclareOperation( "End", [ IsRing, IsLeftModule ] );


#############################################################################
##
#E  vspchom.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

