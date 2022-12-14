#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  1. Single Linear Mappings
##  2. Vector Spaces of Linear Mappings
##


#############################################################################
##
##  <#GAPDoc Label="[1]{vspchom}">
##  <E>Vector space homomorphisms</E> (or <E>linear mappings</E>) are defined
##  in Section&nbsp;<Ref Sect="Linear Mappings"/>.
##  &GAP; provides special functions to construct a particular linear
##  mapping from images of given elements in the source,
##  from a matrix of coefficients, or as a natural epimorphism.
##  <P/>
##  <M>F</M>-linear mappings with same source and same range can be added,
##  so one can form vector spaces of linear mappings.
##  <#/GAPDoc>
##


#############################################################################
##
##  1. Single Linear Mappings
##


#############################################################################
##
#O  LeftModuleGeneralMappingByImages( <V>, <W>, <gens>, <imgs> )
##
##  <#GAPDoc Label="LeftModuleGeneralMappingByImages">
##  <ManSection>
##  <Oper Name="LeftModuleGeneralMappingByImages" Arg='V, W, gens, imgs'/>
##
##  <Description>
##  Let <A>V</A> and <A>W</A> be two left modules over the same left acting
##  domain <M>R</M> and <A>gens</A> and <A>imgs</A> lists
##  (of the same length) of elements in <A>V</A> and <A>W</A>, respectively.
##  <Ref Oper="LeftModuleGeneralMappingByImages"/> returns
##  the general mapping with source <A>V</A> and range <A>W</A>
##  that is defined by mapping the elements in <A>gens</A> to the
##  corresponding elements in <A>imgs</A>,
##  and taking the <M>R</M>-linear closure.
##  <P/>
##  <A>gens</A> need not generate <A>V</A> as a left <M>R</M>-module,
##  and if the specification does not define a linear mapping then the result
##  will be multi-valued; hence in general it is not a mapping
##  (see&nbsp;<Ref Filt="IsMapping"/>).
##  <Example><![CDATA[
##  gap> V:= Rationals^2;;
##  gap> W:= VectorSpace( Rationals, [ [1,2,3], [1,0,1] ] );;
##  gap> f:= LeftModuleGeneralMappingByImages( V, W,
##  >                                [[1,0],[2,0]], [[1,0,1],[1,0,1] ] );
##  [ [ 1, 0 ], [ 2, 0 ] ] -> [ [ 1, 0, 1 ], [ 1, 0, 1 ] ]
##  gap> IsMapping( f );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeftModuleGeneralMappingByImages",
    [ IsLeftModule, IsLeftModule, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  LeftModuleHomomorphismByImages( <V>, <W>, <gens>, <imgs> )
#O  LeftModuleHomomorphismByImagesNC( <V>, <W>, <gens>, <imgs> )
##
##  <#GAPDoc Label="LeftModuleHomomorphismByImages">
##  <ManSection>
##  <Func Name="LeftModuleHomomorphismByImages" Arg='V, W, gens, imgs'/>
##  <Oper Name="LeftModuleHomomorphismByImagesNC" Arg='V, W, gens, imgs'/>
##
##  <Description>
##  Let <A>V</A> and <A>W</A> be two left modules over the same left acting
##  domain <M>R</M> and <A>gens</A> and <A>imgs</A> lists (of the same
##  length) of elements in <A>V</A> and <A>W</A>, respectively.
##  <Ref Func="LeftModuleHomomorphismByImages"/> returns
##  the left <M>R</M>-module homomorphism with source <A>V</A> and range
##  <A>W</A> that is defined by mapping the elements in <A>gens</A> to the
##  corresponding elements in <A>imgs</A>.
##  <P/>
##  If <A>gens</A> does not generate <A>V</A> or if the homomorphism does not
##  exist (i.e., if mapping the generators describes only a multi-valued
##  mapping) then <K>fail</K> is returned.
##  For creating a possibly multi-valued mapping from <A>V</A> to <A>W</A>
##  that respects addition, multiplication, and scalar multiplication,
##  <Ref Oper="LeftModuleGeneralMappingByImages"/> can be used.
##  <P/>
##  <Ref Oper="LeftModuleHomomorphismByImagesNC"/> does the same as
##  <Ref Func="LeftModuleHomomorphismByImages"/>,
##  except that it omits all checks.
##  <Example><![CDATA[
##  gap> V:=Rationals^2;;
##  gap> W:=VectorSpace( Rationals, [ [ 1, 0, 1 ], [ 1, 2, 3 ] ] );;
##  gap> f:=LeftModuleHomomorphismByImages( V, W,
##  > [ [ 1, 0 ], [ 0, 1 ] ], [ [ 1, 0, 1 ], [ 1, 2, 3 ] ] );
##  [ [ 1, 0 ], [ 0, 1 ] ] -> [ [ 1, 0, 1 ], [ 1, 2, 3 ] ]
##  gap> Image( f, [1,1] );
##  [ 2, 2, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LeftModuleHomomorphismByImages" );

DeclareOperation( "LeftModuleHomomorphismByImagesNC",
    [ IsLeftModule, IsLeftModule, IsList, IsList ] );


#############################################################################
##
#A  AsLeftModuleGeneralMappingByImages( <map> )
##
##  <ManSection>
##  <Attr Name="AsLeftModuleGeneralMappingByImages" Arg='map'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AsLeftModuleGeneralMappingByImages", IsGeneralMapping );


#############################################################################
##
#O  LeftModuleHomomorphismByMatrix( <BS>, <matrix>, <BR> )
##
##  <#GAPDoc Label="LeftModuleHomomorphismByMatrix">
##  <ManSection>
##  <Oper Name="LeftModuleHomomorphismByMatrix" Arg='BS, matrix, BR'/>
##
##  <Description>
##  Let <A>BS</A> and <A>BR</A> be bases of the left <M>R</M>-modules
##  <M>V</M> and <M>W</M>, respectively.
##  <Ref Oper="LeftModuleHomomorphismByMatrix"/> returns the <M>R</M>-linear
##  mapping from <M>V</M> to <M>W</M> that is defined by the matrix
##  <A>matrix</A>, as follows.
##  The image of the <M>i</M>-th basis vector of <A>BS</A> is the linear
##  combination of the basis vectors of <A>BR</A> with coefficients the
##  <M>i</M>-th row of <A>matrix</A>.
##  <Example><![CDATA[
##  gap> V:= Rationals^2;;
##  gap> W:= VectorSpace( Rationals, [ [ 1, 0, 1 ], [ 1, 2, 3 ] ] );;
##  gap> f:= LeftModuleHomomorphismByMatrix( Basis( V ),
##  > [ [ 1, 2 ], [ 3, 1 ] ], Basis( W ) );
##  <linear mapping by matrix, ( Rationals^
##  2 ) -> <vector space over Rationals, with 2 generators>>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeftModuleHomomorphismByMatrix",
    [ IsBasis, IsMatrix, IsBasis ] );


#############################################################################
##
#O  NaturalHomomorphismBySubspace( <V>, <W> ) . . . . . map onto factor space
##
##  <#GAPDoc Label="NaturalHomomorphismBySubspace">
##  <ManSection>
##  <Oper Name="NaturalHomomorphismBySubspace" Arg='V, W'/>
##
##  <Description>
##  For an <M>R</M>-vector space <A>V</A> and a subspace <A>W</A> of
##  <A>V</A>,
##  <Ref Oper="NaturalHomomorphismBySubspace"/> returns the <M>R</M>-linear
##  mapping that is the natural projection of <A>V</A> onto the factor space
##  <C><A>V</A> / <A>W</A></C>.
##  <Example><![CDATA[
##  gap> V:= Rationals^3;;
##  gap> W:= VectorSpace( Rationals, [ [ 1, 1, 1 ] ] );;
##  gap> f:= NaturalHomomorphismBySubspace( V, W );
##  <linear mapping by matrix, ( Rationals^3 ) -> ( Rationals^2 )>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NaturalHomomorphismBySubspace",
    [ IsLeftModule, IsLeftModule ] );


#############################################################################
##
#F  NaturalHomomorphismBySubspaceOntoFullRowSpace( <V>, <W> )
##
##  <ManSection>
##  <Func Name="NaturalHomomorphismBySubspaceOntoFullRowSpace" Arg='V, W'/>
##
##  <Description>
##  returns a vector space homomorphism from the vector space <A>V</A> onto a
##  full row space, with kernel exactly the vector space <A>W</A>,
##  which must be contained in <A>V</A>.
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="IsFullHomModule">
##  <ManSection>
##  <Prop Name="IsFullHomModule" Arg='M'/>
##
##  <Description>
##  A <E>full hom module</E> is a module of all <M>R</M>-linear mappings
##  between two left <M>R</M>-modules.
##  The function <Ref Oper="Hom"/> can be used to construct a full hom
##  module.
##  <Example><![CDATA[
##  gap> V:= Rationals^2;;
##  gap> W:= VectorSpace( Rationals, [ [ 1, 0, 1 ], [ 1, 2, 3 ] ] );;
##  gap> H:= Hom( Rationals, V, W );;
##  gap> IsFullHomModule( H );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullHomModule", IsFreeLeftModule );


#############################################################################
##
#P  IsPseudoCanonicalBasisFullHomModule( <B> )
##
##  <#GAPDoc Label="IsPseudoCanonicalBasisFullHomModule">
##  <ManSection>
##  <Prop Name="IsPseudoCanonicalBasisFullHomModule" Arg='B'/>
##
##  <Description>
##  A basis of a full hom module is called pseudo canonical basis
##  if the matrices of its basis vectors w.r.t. the stored bases of source
##  and range contain exactly one identity entry and otherwise zeros.
##  <P/>
##  Note that this is not a canonical basis
##  (see&nbsp;<Ref Attr="CanonicalBasis"/>)
##  because it depends on the stored bases of source and range.
##  <Example><![CDATA[
##  gap> IsPseudoCanonicalBasisFullHomModule( Basis( H ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPseudoCanonicalBasisFullHomModule", IsBasis );


#############################################################################
##
#O  Hom( <F>, <V>, <W> )  . . .  space of <F>-linear mappings from <V> to <W>
##
##  <#GAPDoc Label="Hom">
##  <ManSection>
##  <Oper Name="Hom" Arg='F, V, W'/>
##
##  <Description>
##  For a field <A>F</A> and two vector spaces <A>V</A> and <A>W</A>
##  that can be regarded as <A>F</A>-modules
##  (see&nbsp;<Ref Oper="AsLeftModule"/>),
##  <Ref Oper="Hom"/> returns the <A>F</A>-vector space of
##  all <A>F</A>-linear mappings from <A>V</A> to <A>W</A>.
##  <Example><![CDATA[
##  gap> V:= Rationals^2;;
##  gap> W:= VectorSpace( Rationals, [ [ 1, 0, 1 ], [ 1, 2, 3 ] ] );;
##  gap> H:= Hom( Rationals, V, W );
##  Hom( Rationals, ( Rationals^2 ), <vector space over Rationals, with
##  2 generators> )
##  gap> Dimension( H );
##  4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Hom", [ IsRing, IsLeftModule, IsLeftModule ] );


#############################################################################
##
#O  End( <F>, <V> ) . . . . . .  space of <F>-linear mappings from <V> to <V>
##
##  <#GAPDoc Label="End">
##  <ManSection>
##  <Oper Name="End" Arg='F, V'/>
##
##  <Description>
##  For a field <A>F</A> and a vector space <A>V</A> that can be regarded as
##  an <A>F</A>-module (see&nbsp;<Ref Oper="AsLeftModule"/>),
##  <Ref Oper="End"/> returns the <A>F</A>-algebra of all <A>F</A>-linear
##  mappings from <A>V</A> to <A>V</A>.
##  <Example><![CDATA[
##  gap> A:= End( Rationals, Rationals^2 );
##  End( Rationals, ( Rationals^2 ) )
##  gap> Dimension( A );
##  4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "End", [ IsRing, IsLeftModule ] );


#############################################################################
##
#F  IsLinearMappingsModule( <V> )
##
##  <#GAPDoc Label="IsLinearMappingsModule">
##  <ManSection>
##  <Filt Name="IsLinearMappingsModule" Arg='V'/>
##
##  <Description>
##  If an <M>F</M>-vector space <A>V</A> is in the filter
##  <Ref Filt="IsLinearMappingsModule"/> then
##  this expresses that <A>V</A> consists of linear mappings,
##  and that <A>V</A> is handled via the mechanism of nice bases
##  (see&nbsp;<Ref Sect="Vector Spaces Handled By Nice Bases"/>),
##  in the following way.
##  Let <M>S</M> and <M>R</M> be the source and the range, respectively,
##  of each mapping in <M>V</M>.
##  Then the <Ref Attr="NiceFreeLeftModuleInfo"/> value of <A>V</A> is
##  a record with the components <C>basissource</C> (a basis <M>B_S</M> of
##  <M>S</M>) and <C>basisrange</C> (a basis <M>B_R</M> of <M>R</M>),
##  and the <Ref Oper="NiceVector"/> value of <M>v \in <A>V</A></M>
##  is defined as the matrix of the <M>F</M>-linear mapping <M>v</M>
##  w.r.t.&nbsp;the bases <M>B_S</M> and <M>B_R</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareHandlingByNiceBasis( "IsLinearMappingsModule",
    "for free left modules of linear mappings" );


#############################################################################
##
#M  IsFiniteDimensional( <A> )  . . . . .  hom FLMLORs are finite dimensional
##
InstallTrueMethod( IsFiniteDimensional, IsLinearMappingsModule );
