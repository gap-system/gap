#############################################################################
##
#W  addmagma.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for additive magmas,
##  Note that the meaning of generators for the three categories
##  additive magma, additive-magma-with-zero,
##  and additive-magma-with-inverses is different.
##
Revision.addmagma_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsNearAdditiveMagma( <obj> )
##
##  A *near-additive magma* in {\GAP} is a domain $A$ with an associative
##  but not necessarily commutative addition `+'$: A \times A \rightarrow A$.
##
DeclareCategory( "IsNearAdditiveMagma",
    IsDomain and IsNearAdditiveElementCollection );


#############################################################################
##
#C  IsNearAdditiveMagmaWithZero( <obj> )
##
##  A *near-additive magma-with-zero* in {\GAP} is a near-additive magma $A$
##  with an operation `0\*' (or `Zero') that yields the zero of $A$.
##
##  So a near-additive magma-with-zero <A> does always contain a unique
##  additively neutral element $z$, i.e., $z + a = a = a + z$ holds for all
##  $a \in A$ (see~"AdditiveNeutralElement").
##  This element $z$ can be computed with the operation `Zero' (see~"Zero")
##  as `Zero( <A> )', and $z$ is also equal to `Zero( <elm> )' and to
##  `0\*<elm>' for each element <elm> in <A>.
##
##  *Note* that
#T  a near-additive magma may contain an additively neutral element
#T  but *not* a zero (see~"Zero"), and
##  a near-additive magma containing a zero may *not* lie in the category
##  `IsNearAdditiveMagmaWithZero' (see~"Domain Categories").
##
DeclareCategory( "IsNearAdditiveMagmaWithZero",
    IsNearAdditiveMagma and IsNearAdditiveElementWithZeroCollection );


#############################################################################
##
#C  IsNearAdditiveGroup( <obj> )
#C  IsNearAdditiveMagmaWithInverses( <obj> )
##
##  A *near-additive group* in {\GAP} is a near-additive magma-with-zero $A$
##  with an operation `-1\*'$: A \rightarrow A$ that maps each element <a> of
##  $A$ to its additive inverse `-1\*<a>' (or `AdditiveInverse( <a> )',
##  see~"AdditiveInverse").
##
##  The addition `+' of $A$ is assumed to be associative,
##  so a near-additive group is not more than a
##  *near-additive magma-with-inverses*.
##  `IsNearAdditiveMagmaWithInverses' is just a synonym for
##  `IsNearAdditiveGroup',
##  and can be used alternatively in all function names involving
##  `NearAdditiveGroup'.
##
##  Note that not every trivial near-additive magma is a near-additive
##  magma-with-zero,
##  but every trivial near-additive magma-with-zero is a near-additive group.
##
DeclareCategory( "IsNearAdditiveGroup",
        IsNearAdditiveMagmaWithZero
    and IsNearAdditiveElementWithInverseCollection );

DeclareSynonym( "IsNearAdditiveMagmaWithInverses", IsNearAdditiveGroup );


#############################################################################
##
#P  IsAdditivelyCommutative( <A> )
##
##  A near-additive magma <A> in {\GAP} is *additively commutative* if
##  for all elements $a, b \in <A>$ the equality $a + b = b + a$ holds.
##
##  Note that the commutativity of the *multiplication* `\*' in a
##  multiplicative structure can be tested with `IsCommutative',
##  (see~"IsCommutative").
##
DeclareProperty( "IsAdditivelyCommutative", IsNearAdditiveMagma );

InstallTrueMethod( IsAdditivelyCommutative,
    IsAdditivelyCommutativeElementCollection and IsMagma );

InstallSubsetMaintenance( IsAdditivelyCommutative,
    IsNearAdditiveMagma and IsAdditivelyCommutative, IsNearAdditiveMagma );

InstallFactorMaintenance( IsAdditivelyCommutative,
    IsNearAdditiveMagma and IsAdditivelyCommutative,
    IsObject, IsNearAdditiveMagma );

InstallTrueMethod( IsAdditivelyCommutative,
    IsNearAdditiveMagma and IsTrivial );


InstallTrueMethod( IsAdditiveElementCollection,
    IsNearAdditiveElementCollection and IsAdditivelyCommutative );
InstallTrueMethod( IsAdditiveElementWithZeroCollection,
    IsNearAdditiveElementWithZeroCollection and IsAdditivelyCommutative );
InstallTrueMethod( IsAdditiveElementWithInverseCollection,
        IsNearAdditiveElementWithInverseCollection
    and IsAdditivelyCommutative );


#############################################################################
##
#C  IsAdditiveMagma( <obj> )
##
##  An *additive magma* in {\GAP} is a domain $A$ with an associative and
##  commutative addition `+'$: A \times A \rightarrow A$,
##  see~"IsNearAdditiveMagma" and "IsAdditivelyCommutative".
##
DeclareSynonym( "IsAdditiveMagma",
    IsNearAdditiveMagma and IsAdditivelyCommutative );


#############################################################################
##
#C  IsAdditiveMagmaWithZero( <obj> )
##
##  An *additive magma-with-zero* in {\GAP} is an additive magma $A$ with
##  an operation `0\*' (or `Zero') that yields the zero of $A$.
##
##  So an additive magma-with-zero <A> does always contain a unique
##  additively neutral element $z$, i.e., $z + a = a = a + z$ holds for all
##  $a \in A$ (see~"AdditiveNeutralElement").
##  This element $z$ can be computed with the operation `Zero' (see~"Zero")
##  as `Zero( <A> )', and $z$ is also equal to `Zero( <elm> )' and to
##  `0\*<elm>' for each element <elm> in <A>.
##
##  *Note* that
#T  an additive magma may contain an additively neutral element
#T  but *not* a zero (see~"Zero"), and
##  an additive magma containing a zero may *not* lie in the category
##  `IsAdditiveMagmaWithZero' (see~"Domain Categories").
##
DeclareSynonym( "IsAdditiveMagmaWithZero",
    IsNearAdditiveMagmaWithZero and IsAdditiveMagma );


#############################################################################
##
#C  IsAdditiveGroup( <obj> )
#C  IsAdditiveMagmaWithInverses( <obj> )
##
##  An *additive group* in {\GAP} is an additive magma-with-zero $A$ with an
##  operation `-1\*'$: A \rightarrow A$ that maps each element <a> of $A$ to
##  its additive inverse `-1\*<a>' (or `AdditiveInverse( <a> )',
##  see~"AdditiveInverse").
##
##  The addition `+' of $A$ is assumed to be commutative and associative,
##  so an additive group is not more than an *additive magma-with-inverses*.
##  `IsAdditiveMagmaWithInverses' is just a synonym for `IsAdditiveGroup',
##  and can be used alternatively in all function names involving
##  `AdditiveGroup'.
##
##  Note that not every trivial additive magma is an additive
##  magma-with-zero,
##  but every trivial additive magma-with-zero is an additive group.
##
DeclareSynonym( "IsAdditiveGroup",
    IsNearAdditiveGroup and IsAdditiveMagma );

DeclareSynonym( "IsAdditiveMagmaWithInverses", IsAdditiveGroup );


#############################################################################
##
#a  Zero( <D> )
##
##  (see the description in `arith.gd')
##
DeclareAttribute( "Zero", IsDomain and IsAdditiveElementWithZeroCollection );


#############################################################################
##
#F  NearAdditiveMagma( <gens> )
#F  NearAdditiveMagma( <Fam>, <gens> )
##
##  returns the (near-)additive magma $A$ that is generated by the elements
##  in the list <gens>, that is,
##  the closure of <gens> under addition `+'.
##  The family <Fam> of $A$ can be entered as first argument;
##  this is obligatory if <gens> is empty (and hence also $A$ is empty).
##
DeclareGlobalFunction( "NearAdditiveMagma" );

DeclareSynonym( "AdditiveMagma", NearAdditiveMagma );


#############################################################################
##
#F  NearAdditiveMagmaWithZero( <gens> )
#F  NearAdditiveMagmaWithZero( <Fam>, <gens> )
##
##  returns the (near-)additive magma-with-zero $A$ that is generated by
##  the elements in the list <gens>, that is,
##  the closure of <gens> under addition `+' and `Zero'.
##  The family <Fam> of $A$ can be entered as first argument;
##  this is obligatory if <gens> is empty (and hence $A$ is trivial).
##
DeclareGlobalFunction( "NearAdditiveMagmaWithZero" );

DeclareSynonym( "AdditiveMagmaWithZero", NearAdditiveMagmaWithZero );


#############################################################################
##
#F  NearAdditiveGroup( <gens> )
#F  NearAdditiveGroup( <Fam>, <gens> )
##
##  returns the (near-)additive group $A$ that is generated by the elements
##  in the list <gens>, that is,
##  the closure of <gens> under addition `+', `Zero', and `AdditiveInverse'.
##  The family <Fam> of $A$ can be entered as first argument;
##  this is obligatory if <gens> is empty (and hence $A$ is trivial).
##
DeclareGlobalFunction( "NearAdditiveGroup" );

DeclareSynonym( "AdditiveGroup", NearAdditiveGroup );
DeclareSynonym( "NearAdditiveMagmaWithInverses", NearAdditiveGroup );
DeclareSynonym( "AdditiveMagmaWithInverses", NearAdditiveGroup );


#############################################################################
##
#O  NearAdditiveMagmaByGenerators( <gens> )
#O  NearAdditiveMagmaByGenerators( <Fam>, <gens> )
##
DeclareOperation( "NearAdditiveMagmaByGenerators", [ IsCollection ] );

DeclareSynonym( "AdditiveMagmaByGenerators", NearAdditiveMagmaByGenerators );


#############################################################################
##
#O  NearAdditiveMagmaWithZeroByGenerators( <gens> )
#O  NearAdditiveMagmaWithZeroByGenerators( <Fam>, <gens> )
##
DeclareOperation( "NearAdditiveMagmaWithZeroByGenerators",
    [ IsCollection ] );

DeclareSynonym( "AdditiveMagmaWithZeroByGenerators",
    NearAdditiveMagmaWithZeroByGenerators );


#############################################################################
##
#O  NearAdditiveGroupByGenerators( <gens> )
#O  NearAdditiveGroupByGenerators( <Fam>, <gens> )
##
DeclareOperation( "NearAdditiveGroupByGenerators", [ IsCollection ] );

DeclareSynonym( "AdditiveGroupByGenerators",
    NearAdditiveGroupByGenerators );
DeclareSynonym( "NearAdditiveMagmaWithInversesByGenerators",
    NearAdditiveGroupByGenerators );
DeclareSynonym( "AdditiveMagmaWithInversesByGenerators",
    NearAdditiveGroupByGenerators );


#############################################################################
##
#F  SubnearAdditiveMagma( <D>, <gens> )
#F  SubnearAdditiveMagmaNC( <D>, <gens> )
##
##  `SubadditiveMagma' returns the near-additive magma generated by
##  the elements in the list <gens>, with parent the domain <D>.
##  `SubadditiveMagmaNC' does the same, except that it is not checked
##  whether the elements of <gens> lie in <D>.
##
DeclareGlobalFunction( "SubnearAdditiveMagma" );

DeclareGlobalFunction( "SubnearAdditiveMagmaNC" );

DeclareSynonym( "SubadditiveMagma", SubnearAdditiveMagma );
DeclareSynonym( "SubadditiveMagmaNC", SubnearAdditiveMagmaNC );


#############################################################################
##
#F  SubnearAdditiveMagmaWithZero( <D>, <gens> )
#F  SubnearAdditiveMagmaWithZeroNC( <D>, <gens> )
##
##  `SubadditiveMagmaWithZero' returns the near-additive magma-with-zero
##  generated by the elements in the list <gens>, with parent the domain <D>.
##  `SubadditiveMagmaWithZeroNC' does the same, except that it is not checked
##  whether the elements of <gens> lie in <D>.
##
DeclareGlobalFunction( "SubnearAdditiveMagmaWithZero" );

DeclareGlobalFunction( "SubnearAdditiveMagmaWithZeroNC" );

DeclareSynonym( "SubadditiveMagmaWithZero", SubnearAdditiveMagmaWithZero );
DeclareSynonym( "SubadditiveMagmaWithZeroNC",
    SubnearAdditiveMagmaWithZeroNC );


#############################################################################
##
#F  SubnearAdditiveGroup( <D>, <gens> )
#F  SubnearAdditiveGroupNC( <D>, <gens> )
##
##  `SubadditiveGroup' returns the near-additive group generated by
##  the elements in the list <gens>, with parent the domain <D>.
##  `SubadditiveGroupNC' does the same, except that it is not checked
##  whether the elements of <gens> lie in <D>.
##
DeclareGlobalFunction( "SubnearAdditiveGroup" );

DeclareGlobalFunction( "SubnearAdditiveGroupNC" );

DeclareSynonym( "SubadditiveGroup", SubnearAdditiveGroup );
DeclareSynonym( "SubnearAdditiveMagmaWithInverses", SubnearAdditiveGroup );
DeclareSynonym( "SubadditiveMagmaWithInverses", SubnearAdditiveGroup );

DeclareSynonym( "SubadditiveGroupNC", SubnearAdditiveGroupNC );
DeclareSynonym( "SubnearAdditiveMagmaWithInversesNC",
    SubnearAdditiveGroupNC );
DeclareSynonym( "SubadditiveMagmaWithInversesNC", SubnearAdditiveGroupNC );


#############################################################################
##
#A  GeneratorsOfNearAdditiveMagma( <A> )
#A  GeneratorsOfAdditiveMagma( <A> )
##
##  is a list <gens> of elements of the near-additive magma <A>
##  that generates <A> as a near-additive magma,
##  that is, the closure of <gens> under addition is <A>.
##
DeclareAttribute( "GeneratorsOfNearAdditiveMagma", IsNearAdditiveMagma );

DeclareSynonymAttr( "GeneratorsOfAdditiveMagma",
    GeneratorsOfNearAdditiveMagma );


#############################################################################
##
#A  GeneratorsOfNearAdditiveMagmaWithZero( <A> )
#A  GeneratorsOfAdditiveMagmaWithZero( <A> )
##
##  is a list <gens> of elements of the near-additive magma-with-zero <A>
##  that generates <A> as a near-additive magma-with-zero,
##  that is,
##  the closure of <gens> under addition and `Zero' (see~"Zero") is <A>.
##
DeclareAttribute( "GeneratorsOfNearAdditiveMagmaWithZero",
    IsNearAdditiveMagmaWithZero );

DeclareSynonymAttr( "GeneratorsOfAdditiveMagmaWithZero",
    GeneratorsOfNearAdditiveMagmaWithZero );


#############################################################################
##
#A  GeneratorsOfNearAdditiveGroup( <A> )
#A  GeneratorsOfAdditiveGroup( <A> )
##
##  is a list <gens> of elements of the near-additive group <A>
##  that generates <A> as a near-additive group,
##  that is, the closure of <gens> under addition, taking the zero element,
##  and taking additive inverses (see~"AdditiveInverse") is <A>.
##
DeclareAttribute( "GeneratorsOfNearAdditiveGroup", IsNearAdditiveGroup );

DeclareSynonymAttr( "GeneratorsOfAdditiveMagmaWithInverses",
    GeneratorsOfNearAdditiveGroup );
DeclareSynonymAttr( "GeneratorsOfNearAdditiveMagmaWithInverses",
    GeneratorsOfNearAdditiveGroup );
DeclareSynonymAttr( "GeneratorsOfAdditiveGroup",
    GeneratorsOfNearAdditiveGroup );


#############################################################################
##
#A  TrivialSubnearAdditiveMagmaWithZero( <A> )
##
##  is the additive magma-with-zero that has the zero of
##  the near-additive magma-with-zero <A> as only element.
##
DeclareAttribute( "TrivialSubnearAdditiveMagmaWithZero",
    IsNearAdditiveMagmaWithZero );

DeclareSynonymAttr( "TrivialSubadditiveMagmaWithZero",
    TrivialSubnearAdditiveMagmaWithZero );


#############################################################################
##
#A  AdditiveNeutralElement( <A> )
##
##  returns the element $z$ in the near-additive magma <A> with the property
##  that $z + a = a = a + z$ holds for all $a \in <A>$,
##  if such an element exists.
##  Otherwise `fail' is returned.
##
##  A near-additive magma that is not a near-additive magma-with-zero
##  can have an additive neutral element $z$;
##  in this case, $z$ *cannot* be obtained as `Zero( <A> )' or as `0\*<elm>'
##  for an element <elm> in <A>, see~"Zero".
##
DeclareAttribute( "AdditiveNeutralElement", IsNearAdditiveMagma );


#############################################################################
##
#O  ClosureNearAdditiveGroup( <A>, <a> )  . . for near-add. group and element
#O  ClosureNearAdditiveGroup( <A>, <B> )  . . . . .  for two near-add. groups
##
##  returns the closure of the near-additive magma <A> with the element <a>
##  or the near-additive magma <B>, w.r.t.~addition, taking the zero element,
##  and taking additive inverses.
##
DeclareOperation( "ClosureNearAdditiveGroup",
    [ IsNearAdditiveGroup, IsNearAdditiveElement ] );

DeclareSynonym( "ClosureNearAdditiveMagmaWithInverses",
    ClosureNearAdditiveGroup );
DeclareSynonym( "ClosureAdditiveGroup",
    ClosureNearAdditiveGroup );
DeclareSynonym( "ClosureAdditiveMagmaWithInverses",
    ClosureNearAdditiveGroup );


#############################################################################
##
#E

