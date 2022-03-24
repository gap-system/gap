#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

DeclareInfoClass( "InfoClasses" );

#############################################################################
##
#R  IsExternalOrbitByStabilizerRep  . . . . .  external orbit via transversal
##
##  <ManSection>
##  <Filt Name="IsExternalOrbitByStabilizerRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsExternalOrbitByStabilizerRep",
    IsExternalOrbit, [  ] );


#############################################################################
##
#R  IsConjugacyClassGroupRep( <obj> )
#R  IsConjugacyClassPermGroupRep( <obj> )
##
##  <ManSection>
##  <Filt Name="IsConjugacyClassGroupRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsConjugacyClassPermGroupRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  is a representation of conjugacy classes, a subrepresentation for
##  permutation groups is <C>IsConjugacyClassPermGroupRep</C>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsConjugacyClassGroupRep",
    IsExternalOrbit, [  ] );

DeclareRepresentation( "IsConjugacyClassPermGroupRep",
    IsExternalOrbitByStabilizerRep and IsConjugacyClassGroupRep, [  ] );

#############################################################################
##
#O  ConjugacyClass( <G>, <g> )  . . . . . . . . . conjugacy class constructor
##
##  <#GAPDoc Label="ConjugacyClass">
##  <ManSection>
##  <Oper Name="ConjugacyClass" Arg='G, g'/>
##
##  <Description>
##  creates the conjugacy class in <A>G</A> with representative <A>g</A>.
##  This class is an external set, so functions such as
##  <Ref Attr="Representative"/> (which returns <A>g</A>),
##  <Ref Attr="ActingDomain"/> (which returns <A>G</A>),
##  <Ref Attr="StabilizerOfExternalSet"/> (which returns the centralizer of
##  <A>g</A>) and <Ref Attr="AsList"/> work for it.
##  <P/>
##  A conjugacy class is an external orbit (see <Ref Oper="ExternalOrbit"/>)
##  of group elements with the group acting by conjugation on it.
##  Thus element tests or operation representatives can be computed.
##  The attribute
##  <Ref Attr="Centralizer" Label="for a class of objects in a magma"/>
##  gives the centralizer of the representative (which is the same result as
##  <Ref Attr="StabilizerOfExternalSet"/>).
##  (This is a slight abuse of notation: This is <E>not</E> the centralizer
##  of the class as a <E>set</E> which would be the standard behaviour of
##  <Ref Attr="Centralizer" Label="for a class of objects in a magma"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ConjugacyClass", [ IsGroup, IsObject ] );


#############################################################################
##
#R  IsRationalClassGroupRep . . . . . . . . . . . . . rational class in group
#R  IsRationalClassPermGroupRep . . . . . . . . rational class in perm. group
##
##  <ManSection>
##  <Filt Name="IsRationalClassGroupRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsRationalClassPermGroupRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  is a representation of rational classes, a subrepresentation for
##  permutation groups is <C>IsRationalClassPermGroupRep</C>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsRationalClassGroupRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "galoisGroup", "power" ] );

DeclareRepresentation( "IsRationalClassPermGroupRep",
    IsRationalClassGroupRep,
    [ "galoisGroup", "power" ] );


#############################################################################
##
#M  IsFinite( <cl> )  . . . . . . . . . . . . . . . . .  for a rational class
##
InstallTrueMethod( IsFinite, IsRationalClassGroupRep and IsDomain );
#T The `*' in the `Size' method (file `clas.gi') indicates that infinite
#T rational classes are not allowed.


#############################################################################
##
#O  RationalClass( <G>, <g> ) . . . . . . . . . .  rational class constructor
##
##  <#GAPDoc Label="RationalClass">
##  <ManSection>
##  <Oper Name="RationalClass" Arg='G, g'/>
##
##  <Description>
##  creates the rational class in <A>G</A> with representative <A>g</A>.
##  A rational class consists of all elements that are conjugate to
##  <A>g</A> or to an <M>i</M>-th power of <A>g</A> where <M>i</M> is coprime
##  to the order of <M>g</M>.
##  Thus a rational class can be interpreted as a conjugacy class of cyclic
##  subgroups.
##  A rational class is an external set (<Ref Filt="IsExternalSet"/>) of
##  group elements with the group acting by conjugation on it, but not an
##  external orbit.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RationalClass", [ IsGroup, IsObject ] );

#############################################################################
##
#O  DecomposedRationalClass( <c> )
##
##  <ManSection>
##  <Oper Name="DecomposedRationalClass" Arg='c'/>
##
##  <Description>
##  For a rational class <A>c</A> this attribute contains a list of the ordinary
##  classes contained therein.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "DecomposedRationalClass",IsRationalClassGroupRep );

#############################################################################
##
#A  GaloisGroup( <ratcl> )
##
##  <#GAPDoc Label="GaloisGroup:clas">
##  <ManSection>
##  <Attr Name="GaloisGroup" Arg='ratcl'
##   Label="of rational class of a group"/>
##
##  <Description>
##  Suppose that <A>ratcl</A> is a rational class of a group <M>G</M> with
##  representative <M>g</M>.
##  The exponents <M>i</M> for which <M>g^i</M> lies already in the ordinary
##  conjugacy class of <M>g</M>, form a subgroup of the
##  <E>prime residue class group</E> <M>P_n</M>
##  (see <Ref Func="PrimitiveRootMod"/>),
##  the so-called <E>Galois group</E>  of the rational class.
##  The prime residue class group <M>P_n</M> is obtained in
##  &GAP; as <C>Units( Integers mod <A>n</A> )</C>,
##  the unit group of a residue class ring.
##  The Galois group of a rational class <A>ratcl</A> is stored in the
##  attribute <Ref Attr="GaloisGroup" Label="of rational class of a group"/>
##  as a subgroup of this group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GaloisGroup", IsRationalClassGroupRep );


#############################################################################
##
#F  ConjugacyClassesByRandomSearch( <G> )
##
##  <#GAPDoc Label="ConjugacyClassesByRandomSearch">
##  <ManSection>
##  <Func Name="ConjugacyClassesByRandomSearch" Arg='G'/>
##
##  <Description>
##  computes the classes of the group <A>G</A> by random search.
##  This works very efficiently for almost simple groups.
##  <P/>
##  This function is also accessible via the option <C>random</C> to
##  the function <Ref Oper="ConjugacyClass"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConjugacyClassesByRandomSearch" );

#############################################################################
##
#F  ConjugacyClassesByOrbits( <G> )
##
##  <#GAPDoc Label="ConjugacyClassesByOrbits">
##  <ManSection>
##  <Func Name="ConjugacyClassesByOrbits" Arg='G'/>
##
##  <Description>
##  computes the classes of the group <A>G</A> as orbits of <A>G</A> on its
##  elements.
##  This can be quick but unsurprisingly may also take a lot of memory if
##  <A>G</A> becomes larger.
##  All the classes will store their element list and
##  thus a membership test will be quick as well.
##  <P/>
##  This function is also accessible via the option <C>action</C> to
##  the function <Ref Oper="ConjugacyClass"/>.
##  <P/>
##  Typically, for small groups (roughly of order up to <M>10^3</M>)
##  the computation of classes as orbits under the action is fastest;
##  memory restrictions (and the increasing cost of eliminating duplicates)
##  make this less efficient for larger groups.
##  <P/>
##  Calculation by random search has the smallest memory requirement, but in
##  generally performs worse, the more classes are there.
##  <P/>
##  The following example shows the effect of this for a small group
##  with many classes:
##  <P/>
##  <!-- this example is time and load-status dependent. No point in testing -->
##  <Log><![CDATA[
##  gap> h:=Group((4,5)(6,7,8),(1,2,3)(5,6,9));;ConjugacyClasses(h:noaction);;time;
##  110
##  gap> h:=Group((4,5)(6,7,8),(1,2,3)(5,6,9));;ConjugacyClasses(h:random);;time;
##  300
##  gap> h:=Group((4,5)(6,7,8),(1,2,3)(5,6,9));;ConjugacyClasses(h:action);;time;
##  30
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConjugacyClassesByOrbits" );

# This function computes the classes by orbits if the group is small and the
# `noaction' option is not set, otherwise it returns `fail'.
DeclareGlobalFunction( "ConjugacyClassesForSmallGroup" );

DeclareGlobalFunction( "ConjugacyClassesForSolvableGroup" );


#############################################################################
##
#F  ConjugacyClassesByHomomorphicImage( <G>, <hom> )
##
##  <#GAPDoc Label="ConjugacyClassesByHomomorphicImage">
##  <ManSection>
##  <Func Name="ConjugacyClassesByHomomorphicImage" Arg='G,hom'/>
##
##  <Description>
##  computes the classes of the group <A>G</A> through the image of <A>G</A>
##  under the homomorphism <A>hom</A>.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConjugacyClassesByHomomorphicImage" );

DeclareGlobalFunction( "GroupByPrimeResidues" );

DeclareGlobalFunction( "ConjugacyClassesTry" );
DeclareGlobalFunction( "RationalClassesTry" );
DeclareGlobalFunction( "RationalClassesInEANS" );

DeclareGlobalFunction( "SubspaceVectorSpaceGroup" );
DeclareGlobalFunction( "CentralStepConjugatingElement" );
DeclareGlobalFunction( "KernelHcommaC" );
DeclareGlobalFunction( "OrderModK" );
DeclareGlobalFunction( "CentralStepRatClPGroup" );
DeclareGlobalFunction( "CentralStepClEANS" );
DeclareGlobalFunction( "CorrectConjugacyClass" );
DeclareGlobalFunction( "GeneralStepClEANS" );
DeclareGlobalFunction("PcClassFactorCentralityTest");

#############################################################################
##
#F  ClassesSolvableGroup(<G>, <mode>[, <opt>])  . . . . .
##
##  <#GAPDoc Label="ClassesSolvableGroup">
##  <ManSection>
##  <Func Name="ClassesSolvableGroup" Arg='G, mode[, opt]'/>
##
##  <Description>
##  computes conjugacy classes and centralizers in solvable groups. <A>G</A> is
##  the acting group. <A>mode</A> indicates the type of the calculation:
##  <P/>
##  0 Conjugacy classes
##  <P/>
##  4 Conjugacy test for the two elements in <A>opt</A><C>.candidates</C>
##  <P/>
##  In mode 0 the function returns a list of records containing components
##  <A>representative</A> and <A>centralizer</A>.
##  In mode 4 it returns a conjugating element.
##  <P/>
##  The optional record <A>opt</A> may contain the following components
##  that will affect the algorithm's behaviour:
##  <P/>
##  <List>
##  <Mark><C>pcgs</C></Mark>
##  <Item>
##  is a pcgs that will be used for the calculation.
##  The attribute <Ref Attr="EANormalSeriesByPcgs"/> must return an
##  appropriate series of normal subgroups with elementary abelian factors
##  among them. The algorithm will step down this series.
##  In the case of
##  the calculation of rational classes, it must be a pcgs refining a
##  central series.
##  </Item>
##  <Mark><C>candidates</C></Mark>
##  <Item>
##  is a list of elements for which canonical representatives
##  are to be computed or for which a conjugacy test is performed. Both
##  elements must lie in <A>G</A>, but this is not tested. In mode 4 these
##  elements must be given.
##  In mode 0 a list of classes corresponding to
##  <C>candidates</C> is returned (which may contain duplicates). The
##  <C>representative</C>s chosen are canonical with respect to <C>pcgs</C>.
##  The records returned also contain components <C>operator</C>
##  such that
##  <C>candidate ^ operator = representative</C>.
##  </Item>
##  <Mark><C>consider</C></Mark>
##  <Item>
##  is a function <C>consider( fhome, rep, cenp, K, L )</C>. Here
##  <C>fhome</C> is a home pcgs for the factor group <M>F</M> in which the
##  calculation currently takes place,
##  <C>rep</C> is an element of the factor and <C>cenp</C> is a
##  pcgs for the centralizer of <C>rep</C> modulo <C>K</C>.
##  In mode 0, when lifting from <M>F</M>/<C>K</C> to <M>F</M>/<C>L</C>
##  (note: for efficiency reasons, <M>F</M> can be different from <A>G</A> or
##  <C>L</C> might be not trivial) this function is called
##  before performing the actual lifting and only those representatives for
##  which it returns <K>true</K> are passed to the next level.
##  This permits for example the calculation of only those classes
##  with small centralizers or classes of restricted orders.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ClassesSolvableGroup" );

# faster version for character table code
DeclareGlobalFunction("MultiClassIdsPc");

#############################################################################
##
#F  RationalClassesSolvableGroup(<G>, <mode> [,<opt>])  . . . . .
##
##  <ManSection>
##  <Func Name="RationalClassesSolvableGroup" Arg='G, mode [,opt]'/>
##
##  <Description>
##  computes rational classes and centralizers in solvable groups. <A>G</A> is
##  the acting group. <A>mode</A> indicates the type of the calculation:
##  <P/>
##  1 Rational classes of a <M>p</M>-group (mode 3 is used internally as well)
##  <P/>
##  In mode 0 the function returns a list of records containing components
##  <A>representative</A> and <A>centralizer</A>. In mode 1 the records in addition
##  contain the component <A>galoisGroup</A>.
##  <P/>
##  The optional record <A>opt</A> may contain the following components that will
##  affect the algorithms behaviour:
##  <P/>
##  <List>
##  <Mark><C>pcgs</C></Mark>
##  <Item>
##  s a pcgs that will be used for the calculation. In the case of
##  the calculation of rational classes, it must be a pcgs refining a
##  central series. The attribute <C>CentralNormalSeriesByPcgs</C> must return an
##  appropriate series of normal subgroups with elementary abelian factors
##  among them. The algorithm will step down this series.
##  </Item>
##  <Mark><C>candidates</C></Mark>
##  <Item>
##  s a list of elements for which canonical representatives
##  are to be computed or for which a conjugacy test is performed. They must
##  be given in mode 4. In modes 0 and 1 a list of classes corresponding to
##  <A>candidates</A> is returned (which may contain duplicates). The
##  <A>representative</A>s chosen are canonical with respect to <A>pcgs</A>. The
##  records returned also contain components <A>operator</A> and (in mode 1)
##  <A>exponent</A> such that
##  (<A>candidate</A> <C>^</C> <A>operator</A>) <C>^</C> <A>exponent</A>=<A>representative</A>.
##  </Item>
##  <Mark>%<C>consider</C></Mark>
##  <Item>
##  s a function <A>consider</A>(<A>rep</A>,<A>cen</A>,<A>K</A>,<A>L</A>). Here <A>rep</A> is
##  <!-- %an element of <A>G</A> and <A>cen</A>/<A>K</A> is the centralizer of <A>rep</A><A>K</A> modulo -->
##  <!-- %<A>K</A>. In mode 0 when lifting from <A>G</A>/<A>K</A> to <A>G</A>/<A>L</A> this function is -->
##  <!-- %called before performing the actual lifting and only those -->
##  <!-- %representatives for which it returns <K>true</K> are passed to the next -->
##  <!-- %level. This permits the calculation of only those classes with say small -->
##  %centralizers or classes of restricted orders.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "RationalClassesSolvableGroup" );


#############################################################################
##
#F  CentralizerSizeLimitConsiderFunction(<sz>)
##
##  <#GAPDoc Label="CentralizerSizeLimitConsiderFunction">
##  <ManSection>
##  <Func Name="CentralizerSizeLimitConsiderFunction" Arg='sz'/>
##
##  <Description>
##  returns a function (with arguments <C>fhome</C>, <C>rep</C>, <C>cen</C>,
##  <C>K</C>, <C>L</C>)
##  that can be used in <Ref Func="ClassesSolvableGroup"/> as the
##  <C>consider</C> component of the options record.
##  It will restrict the lifting to those classes,
##  for which the size of the centralizer (in the factor) is at most
##  <A>sz</A>.
##  <P/>
##  See also <Ref Func="SubgroupsSolvableGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareGlobalFunction( "CentralizerSizeLimitConsiderFunction" );
