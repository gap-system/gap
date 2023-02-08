#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for the Dixon-Schneider algorithm
##


#############################################################################
##
##  <#GAPDoc Label="[1]{ctblgrp}">
##  <Index>Dixon-Schneider algorithm</Index>
##  The &GAP; library implementation of the Dixon-Schneider algorithm
##  first computes the linear characters, using the commutator factor group.
##  If irreducible characters are missing afterwards,
##  they are computed using the techniques described in <Cite Key="Dix67"/>,
##  <Cite Key="Sch90"/> and <Cite Key="Hulpke93"/>.
##  <P/>
##  Called with a group <M>G</M>, the function
##  <Ref Oper="CharacterTable" Label="for a group"/> returns a character
##  table object that stores already information such as class lengths,
##  but not the irreducible characters.
##  The routines that compute the irreducibles may use the information that
##  is already contained in this table object.
##  In particular the ordering of classes in the computed characters
##  coincides with the ordering of classes in the character table of <A>G</A>
##  (see&nbsp;<Ref Sect="The Interface between Character Tables and Groups"/>).
##  Thus it is possible to combine computations using the group
##  with character theoretic computations
##  (see&nbsp;<Ref Sect="Advanced Methods for Dixon-Schneider Calculations"/>
##  for details),
##  for example one can enter known characters.
##  Note that the user is responsible for the correctness of the characters.
##  (There is little use in providing the trivial character to the routine.)
##  <P/>
##  The computation of irreducible characters from the group needs to
##  identify the classes of group elements very often,
##  so it can be helpful to store a class list of all group elements.
##  Since this is obviously limited by the group order,
##  it is controlled by the global function <Ref Func="IsDxLargeGroup"/>.
##  <P/>
##  The routines compute in a prime field of size <M>p</M>,
##  such that the exponent of the group divides <M>(p-1)</M> and such that
##  <M>2 \sqrt{{|G|}} &lt; p</M>.
##  Currently prime fields of size smaller than <M>65\,536</M> are handled more
##  efficiently than larger prime fields,
##  so the runtime of the character calculation depends on how large the
##  chosen prime is.
##  <P/>
##  The routine stores a Dixon record (see&nbsp;<Ref Attr="DixonRecord"/>)
##  in the group that helps routines that identify classes,
##  for example <Ref Oper="FusionConjugacyClasses" Label="for two groups"/>,
##  to work much faster.
##  Note that interrupting Dixon-Schneider calculations will prevent &GAP;
##  from cleaning up the Dixon record;
##  when the computation by <Ref Attr="IrrDixonSchneider"/> is complete,
##  the possibly large record is shrunk to an acceptable size.
##  <#/GAPDoc>
##


#############################################################################
##
#F  IsDxLargeGroup( <G> )
##
##  <#GAPDoc Label="IsDxLargeGroup">
##  <ManSection>
##  <Func Name="IsDxLargeGroup" Arg='G'/>
##
##  <Description>
##  returns <K>true</K> if the order of the group <A>G</A> is smaller than
##  the current value of the global variable <C>DXLARGEGROUPORDER</C>,
##  and <K>false</K> otherwise.
##  In Dixon-Schneider calculations, for small groups in the above sense a
##  class map is stored, whereas for large groups,
##  each occurring element is identified individually.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsDxLargeGroup" );


#############################################################################
##
#F  DxModularValuePol
#F  DxDegreeCandidates
##
##  <ManSection>
##  <Func Name="DxModularValuePol" Arg='...'/>
##  <Func Name="DxDegreeCandidates" Arg='...'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("DxModularValuePol");
DeclareGlobalFunction("DxDegreeCandidates");

DeclareGlobalFunction("DxGaloisOrbits");
DeclareGlobalFunction("DoubleCentralizerOrbit");

#############################################################################
##
#A  DixonRecord( <G> )
##
##  <#GAPDoc Label="DixonRecord">
##  <ManSection>
##  <Attr Name="DixonRecord" Arg='G'/>
##
##  <Description>
##  The <Ref Attr="DixonRecord"/> of a group contains information used by the
##  routines to compute the irreducible characters and related information
##  via the Dixon-Schneider algorithm such as class arrangement and character
##  spaces split obtained so far.
##  Usually this record is passed as argument to all subfunctions to avoid a
##  long argument list.
##  It has a component <C>conjugacyClasses</C> which contains the classes of
##  <A>G</A> <E>ordered as the algorithm needs them</E>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("DixonRecord",IsGroup,"mutable");


#############################################################################
##
#O  DxPreparation(<G>,<D>)
##
##  <ManSection>
##  <Oper Name="DxPreparation" Arg='G,D'/>
##
##  <Description>
##  Creates entries in the dixon record <A>D</A> of the group <A>G</A>
##  which are representation dependent,
##  like functions to identify the class of elements.
##  </Description>
##  </ManSection>
##
DeclareOperation("DxPreparation",[IsGroup,IsRecord]);


#############################################################################
##
#F  ClassComparison(<c>,<d>)  . . . . . . . . . . . . compare classes c and d
##
##  <ManSection>
##  <Func Name="ClassComparison" Arg='c,d'/>
##
##  <Description>
##  Comparison function for conjugacy classes,
##  used by <Ref Func="Sort"/>.
##  Comparison is based first on the size of the class and then on the
##  order of the representatives.
##  Thus the class containing the identity element is in the first position,
##  as required. Since sorting is primary by the class sizes,smaller
##  classes are in earlier positions, making the active columns those to
##  smaller classes, thus reducing the work for calculating class matrices.
##  Additionally, galois conjugated classes are kept together, thus increasing
##  the chance,that with one columns of them active to be several active,
##  again reducing computation time.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ClassComparison");


#############################################################################
##
#F  DxIncludeIrreducibles( <D>, <new>[, <newmod>] )
##
##  <#GAPDoc Label="DxIncludeIrreducibles">
##  <ManSection>
##  <Func Name="DxIncludeIrreducibles" Arg='D, new[, newmod]'/>
##
##  <Description>
##  This function takes a list of irreducible characters <A>new</A>,
##  each given as a list of values (corresponding to the class arrangement in
##  <A>D</A>), and adds these to a partial computed list of irreducibles as
##  maintained by the Dixon record <A>D</A>.
##  This permits one to add characters in interactive use obtained from other
##  sources and to continue the Dixon-Schneider calculation afterwards.
##  If the optional argument <A>newmod</A> is given, it must be a
##  list of reduced characters, corresponding to <A>new</A>.
##  (Otherwise the function has to reduce the characters itself.)
##  <P/>
##  The function closes the new characters under the action of Galois
##  automorphisms and tensor products with linear characters.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DxIncludeIrreducibles" );


#############################################################################
##
#F  SplitCharacters( <D>, <list> )   split characters according to the spaces
##
##  <#GAPDoc Label="SplitCharacters">
##  <ManSection>
##  <Func Name="SplitCharacters" Arg='D, list'/>
##
##  <Description>
##  This routine decomposes the characters given in <A>list</A> according to
##  the character spaces found up to this point. By applying this routine to
##  tensor products etc., it may result in characters with smaller norm,
##  even irreducible ones. Since the recalculation of characters is only
##  possible if the degree is small enough, the splitting process is
##  applied only to characters of sufficiently small degree.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SplitCharacters" );


#############################################################################
##
#F  OrbitSplit(<D>) . . . . . . . . . . . . . . try to split two-orbit-spaces
##
##  <ManSection>
##  <Func Name="OrbitSplit" Arg='D'/>
##
##  <Description>
##  Tries to split two-orbit character spaces.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OrbitSplit");


#############################################################################
##
#F  DxSplitDegree(<D>,<space>,<r>)                                    local
##
##  <ManSection>
##  <Func Name="DxSplitDegree" Arg='D,space,r'/>
##
##  <Description>
##  estimates the number of parts obtained when splitting the character space
##  <A>space</A> with matrix number <A>r</A>.
##  This estimate is obtained using character morphisms.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("DxSplitDegree");

DeclareGlobalFunction("DxOnedimCleanout");


#############################################################################
##
#F  BestSplittingMatrix(<D>)
##
##  <#GAPDoc Label="BestSplittingMatrix">
##  <ManSection>
##  <Func Name="BestSplittingMatrix" Arg='D'/>
##
##  <Description>
##  returns the number of the class sum matrix that is assumed to yield the
##  best (cost/earning ration) split. This matrix then will be the next one
##  computed and used.
##  <P/>
##  The global option <C>maxclasslen</C>
##  (defaulting to <Ref Var="infinity"/>) is recognized
##  by <Ref Func="BestSplittingMatrix"/>:
##  Only classes whose length is limited by the value of this option will be
##  considered for splitting. If no usable class remains,
##  <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("BestSplittingMatrix");


#############################################################################
##
#F  DixonInit( <G> ) . . . . . . . . . . initialize Dixon-Schneider algorithm
##
##  <#GAPDoc Label="DixonInit">
##  <ManSection>
##  <Func Name="DixonInit" Arg='G'/>
##
##  <Description>
##  This function does all the initializations for the Dixon-Schneider
##  algorithm. This includes calculation of conjugacy classes, power maps,
##  linear characters and character morphisms.
##  It returns a record (see&nbsp;<Ref Attr="DixonRecord"/> and
##  Section <Ref Sect="Components of a Dixon Record"/>)
##  that can be used when calculating the irreducible characters of <A>G</A>
##  interactively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DixonInit" );


#############################################################################
##
#F  DixonSplit( <D> ) .  calculate matrix, split spaces and obtain characters
##
##  <#GAPDoc Label="DixonSplit">
##  <ManSection>
##  <Func Name="DixonSplit" Arg='D'/>
##
##  <Description>
##  This function performs one splitting step in the Dixon-Schneider
##  algorithm. It selects a class, computes the (partial) class sum matrix,
##  uses it to split character spaces and stores all the irreducible
##  characters obtained that way.
##  <P/>
##  The class to use for splitting is chosen via
##  <Ref Func="BestSplittingMatrix"/> and the options described for this
##  function apply here.
##  <P/>
##  <Ref Func="DixonSplit"/> returns the number of the class that was
##  used for splitting if a split was performed, and <K>fail</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DixonSplit" );
DeclareGlobalFunction( "SplitStep" );


#############################################################################
##
#F  DixontinI( <D> )  . . . . . . . . . . . . . . . .  reverse initialisation
##
##  <#GAPDoc Label="DixontinI">
##  <ManSection>
##  <Func Name="DixontinI" Arg='D'/>
##
##  <Description>
##  This function ends a Dixon-Schneider calculation.
##  It sorts the characters according to the degree and
##  unbinds components in the Dixon record that are not of use any longer.
##  It returns a list of irreducible characters.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DixontinI" );


#############################################################################
##
#A  IrrDixonSchneider( <G> ) . . . . irreducible characters of finite group G
##
##  <#GAPDoc Label="IrrDixonSchneider">
##  <ManSection>
##  <Attr Name="IrrDixonSchneider" Arg='G'/>
##
##  <Description>
##  computes the irreducible characters of the finite group <A>G</A>,
##  using the Dixon-Schneider method
##  (see&nbsp;<Ref Sect="The Dixon-Schneider Algorithm"/>).
##  It calls <Ref Func="DixonInit"/> and <Ref Func="DixonSplit"/>,
##  <!--  and <C>OrbitSplit</C>, % is not documented! -->
##  and finally returns the list returned by <Ref Func="DixontinI"/>.
##  See also the sections
##  <Ref Sect="Components of a Dixon Record"/> and
##  <Ref Sect="An Example of Advanced Dixon-Schneider Calculations"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IrrDixonSchneider", IsGroup );
DeclareOperation( "IrrDixonSchneider", [ IsGroup, IsRecord ] );

#############################################################################
##
#F  IrreducibleRepresentationsDixon( <G>[,<chi>] )
##
##  <#GAPDoc Label="IrreducibleRepresentationsDixon">
##  <ManSection>
##  <Func Name="IrreducibleRepresentationsDixon" Arg='G[, chi]'/>
##
##  <Description>
##  Called with one argument, a group <A>G</A>,
##  <Ref Func="IrreducibleRepresentationsDixon"/>
##  computes (representatives of) all irreducible complex representations for
##  the finite group <A>G</A>, using the method of&nbsp;<Cite Key="Dix93"/>,
##  which computes the character table and computes the representation
##  as constituent of an induced monomial representation of a subgroup.
##  <P/>
##  This method can be quite expensive for larger groups, for example it
##  might involve calculation of the subgroup lattice of <A>G</A>.
##  <P/>
##  A character <A>chi</A> of <A>G</A> can be given as the second argument,
##  in this case only a representation affording <A>chi</A> is returned.
##  <P/>
##  The second argument can also be a list of characters of <A>G</A>,
##  in this case only representations for characters in this list are
##  computed.
##  <P/>
##  Note that this method might fail if for an irreducible representation
##  there is no subgroup in which its reduction has a linear constituent
##  with multiplicity one.
##  <P/>
##  If the option <A>unitary</A> is given, &GAP; tries, at extra cost, to find a
##  unitary representation (and will issue an error if it cannot do so).
##  <Example><![CDATA[
##  gap> a5:= AlternatingGroup( 5 );
##  Alt( [ 1 .. 5 ] )
##  gap> char:= First( Irr( a5 ), x -> x[1] = 4 );
##  Character( CharacterTable( Alt( [ 1 .. 5 ] ) ), [ 4, 0, 1, -1, -1 ] )
##  gap> hom:=IrreducibleRepresentationsDixon( a5, char: unitary );;
##  gap> Order( a5.1*a5.2 ) = Order( Image( hom, a5.1 )*Image( hom, a5.2 ) );
##  true
##  gap> reps:= List( ConjugacyClasses( a5 ), Representative );;
##  gap> List( reps, g -> TraceMat( Image( hom, g ) ) );
##  [ 4, 0, 1, -1, -1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IrreducibleRepresentationsDixon");

#############################################################################
##
#F  RepresentationsPermutationIrreducibleCharacters(<G>,<chars>,<reps>)
##
##  <ManSection>
##  <Func Name="RepresentationsPermutationIrreducibleCharacters"
##   Arg='G,chars,reps'/>
##
##  <Description>
##  Given a group <A>G</A> and a list of characters and representations of
##  <A>G</A>, this function returns a permutation of the representations
##  (via <Ref Func="Permuted"/>),
##  that will ensure characters and representations are ordered compatibly.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RepresentationsPermutationIrreducibleCharacters");


# the following function is in this file only for dependency reasons.
#############################################################################
##
#F  NthRootsInGroup( <G>, <e>, <n> )
##
##  <#GAPDoc Label="NthRootsInGroup">
##  <ManSection>
##  <Func Name="NthRootsInGroup" Arg='G, e, n'/>
##
##  <Description>
##  Let <A>e</A> be an element in the group <A>G</A>.
##  This function returns a list of all those elements in <A>G</A>
##  whose <A>n</A>-th power is <A>e</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> NthRootsInGroup(g,(1,2)(3,4),2);
##  [ (1,3,2,4), (1,4,2,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NthRootsInGroup");
