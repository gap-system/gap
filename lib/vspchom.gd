#############################################################################
##
#W  vspchom.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  1. Single Linear Mappings
##  2. Vector Spaces of Linear Mappings
##
Revision.vspchom_gd :=
    "@(#)$Id$";


#############################################################################
#1
##  *Vector space homomorphisms* (or *linear mappings*) are defined in
##  Section~"Linear Mappings".
##  {\GAP} provides special functions to construct a particular linear
##  mapping from images of given elements in the source, from a matrix of
##  coefficients, or as a natural epimorphism.
##
##  $F$-linear mappings with same source and same range can be added,
##  so one can form vector spaces of linear mappings.
##


#############################################################################
##
##  1. Single Linear Mappings
##


#############################################################################
##
#O  LeftModuleGeneralMappingByImages( <V>, <W>, <gens>, <imgs> )
##
##  Let <V> and <W> be two left modules over the same left acting domain
##  $R$, say, and <gens> and <imgs> lists of elements in <V> and <W>,
##  respectively.
##  `LeftModuleGeneralMappingByImages' returns the general mapping
##  with source <V> and range <W> that is defined by mapping the elements in
##  <gens> to the corresponding elements in <imgs>,
##  and taking the $R$-linear closure.
##
##  <gens> need not generate <V> as a left $R$-module, and if the
##  specification does not define a linear mapping then the result will be
##  multi-valued; hence in general it is not a mapping (see~"IsMapping").
##
DeclareOperation( "LeftModuleGeneralMappingByImages",
    [ IsLeftModule, IsLeftModule, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  LeftModuleHomomorphismByImages( <V>, <W>, <gens>, <imgs> )
#O  LeftModuleHomomorphismByImagesNC( <V>, <W>, <gens>, <imgs> )
##
##  Let <V> and <W> be two left modules over the same left acting domain
##  $R$, say, and <gens> and <imgs> lists of elements in <V> and <W>,
##  respectively.
##  `LeftModuleHomomorphismByImages' returns the left $R$-module homomorphism
##  with source <V> and range <W> that is defined by mapping the elements in
##  <gens> to the corresponding elements in <imgs>.
##
##  If <gens> does not generate <V> or if the homomorphism does not exist
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then `fail' is returned.
##  `LeftModuleHomomorphismByImagesNC' does the same, except that these
##  checks are omitted.
##
##  For creating a possibly multi-valued mapping from <V> to <W> that
##  respects addition, multiplication, and scalar multiplication,
##  `LeftModuleGeneralMappingByImages' can be used.
##
DeclareGlobalFunction( "LeftModuleHomomorphismByImages" );

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
##  Let <BS> and <BR> be bases of the left $R$-modules $V$ and $W$,
##  respectively.
##  `LeftModuleHomomorphismByMatrix' returns the $R$-linear mapping from $V$
##  to $W$ that is defined by the matrix <matrix> as follows.
##  The image of the $i$-th basis vector of <BS> is the linear combination of
##  the basis vectors of <BR> with coefficients the $i$-th row of <matrix>.
##
DeclareOperation( "LeftModuleHomomorphismByMatrix",
    [ IsBasis, IsMatrix, IsBasis ] );


#############################################################################
##
#O  NaturalHomomorphismBySubspace( <V>, <W> ) . . . . . map onto factor space
##
##  For an $R$-vector space <V> and a subspace <W> of <V>,
##  `NaturalHomomorphismBySubspace' returns the $R$-linear mapping that is
##  the natural projection of <V> onto the factor space `<V> / <W>'.
##
DeclareOperation( "NaturalHomomorphismBySubspace",
    [ IsLeftModule, IsLeftModule ] );


#############################################################################
##
#F  NaturalHomomorphismBySubspaceOntoFullRowSpace( <V>, <W> )
##
##  returns a vector space homomorphism from the vector space <V> onto a full
##  row space, with kernel exactly the vector space <W>,
##  which must be contained in <V>.
##
DeclareGlobalFunction( "NaturalHomomorphismBySubspaceOntoFullRowSpace" );


#############################################################################
##
##  2. Vector Spaces of Linear Mappings
##


#############################################################################
##
#P  IsFullHomModule( <M> )
##
##  A *full hom module* is a module of all $R$-linear mappings between two
##  left $R$-modules.  The function `Hom' (see~"Hom") can be used to
##  construct a full hom module.
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
##  Note that this is not a canonical basis (see~"CanonicalBasis")
##  because it depends on the stored bases of source and range.
##
DeclareProperty( "IsPseudoCanonicalBasisFullHomModule", IsBasis );


#############################################################################
##
#O  Hom( <F>, <V>, <W> )  . . .  space of <F>-linear mappings from <V> to <W>
##
##  For a field <F> and two vector spaces <V> and <W> that can be regarded as
##  <F>-modules (see~"AsLeftModule"), `Hom' returns the <F>-vector space of
##  all <F>-linear mappings from <V> to <W>.
##
DeclareOperation( "Hom", [ IsRing, IsLeftModule, IsLeftModule ] );


#############################################################################
##
#O  End( <F>, <V> ) . . . . . .  space of <F>-linear mappings from <V> to <V>
##
##  For a field <F> and a vector space <V> that can be regarded as an
##  <F>-module (see~"AsLeftModule"), `End' returns the <F>-algebra of
##  all <F>-linear mappings from <V> to <V>.
##
DeclareOperation( "End", [ IsRing, IsLeftModule ] );


#############################################################################
##
#F  IsLinearMappingsModule( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsLinearMappingsModule' then
##  this expresses that <V> consists of linear mappings, and that <V> is
##  handled via the mechanism of nice bases
##  (see~"Vector Spaces Handled By Nice Bases") in the following way.
##  Let $S$ and $R$ be the source and the range, respectively, of each
##  mapping in $V$.
##  Then the `NiceFreeLeftModuleInfo' value of <V> is a record with the
##  components `basissource' (a basis $B_S$ of $S$)
##  and `basisrange' (a basis $B_R$ of $R$),
##  and the `NiceVector' value of $v \in <V>$ is defined as the
##  matrix of the $F$-linear mapping $v$ w.r.t.~the bases $B_S$ and $B_R$.
##
DeclareHandlingByNiceBasis( "IsLinearMappingsModule",
    "for free left modules of linear mappings" );


#############################################################################
##
#M  IsFiniteDimensional( <A> )  . . . . .  hom FLMLORs are finite dimensional
##
InstallTrueMethod( IsFiniteDimensional, IsLinearMappingsModule );


#############################################################################
##
#E

