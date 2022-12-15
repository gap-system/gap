#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for matrix groups over finite fields.
##


#############################################################################
##
#C  IsFFEMatrixGroup( <G> )
##
##  <#GAPDoc Label="IsFFEMatrixGroup">
##  <ManSection>
##  <Filt Name="IsFFEMatrixGroup" Arg='G' Type='Category'/>
##
##  <Description>
##  tests whether all matrices in <A>G</A> have finite field element entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsFFEMatrixGroup", IsFFECollCollColl and IsMatrixGroup );


#############################################################################
##
#M  IsSubsetLocallyFiniteGroup( <ffe-mat-grp> )
##
##  As a consequence, any IsFFEMatrixGroup in IsFinitelyGeneratedGroup
##  automatically is also in IsFinite.
##
##  *Note:*  The following implication only holds  if  there are no  infinite
##  dimensional matrices.
##
InstallTrueMethod( IsSubsetLocallyFiniteGroup, IsFFEMatrixGroup );


#############################################################################
##
#F  NicomorphismFFMatGroupOnFullSpace
##
##  <ManSection>
##  <Func Name="NicomorphismFFMatGroupOnFullSpace" Arg='obj'/>
##
##  <Description>
##  Compute the permutation action on the full vector space
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "NicomorphismFFMatGroupOnFullSpace" );


#############################################################################
##
#F  ProjectiveActionOnFullSpace( <G>, <F>, <n> )
##
##  <#GAPDoc Label="ProjectiveActionOnFullSpace">
##  <ManSection>
##  <Func Name="ProjectiveActionOnFullSpace" Arg='G, F, n'/>
##
##  <Description>
##  Let <A>G</A> be a group of <A>n</A> by <A>n</A> matrices over a field
##  contained in the finite field <A>F</A>.
##  <!-- why is <A>n</A> an argument?-->
##  <!-- (it should be read off from the group!)-->
##  <Ref Func="ProjectiveActionOnFullSpace"/> returns the image of the
##  projective action of <A>G</A> on the full row space
##  <M><A>F</A>^{<A>n</A>}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ProjectiveActionOnFullSpace" );


#############################################################################
##
#F  ConjugacyClassesOfNaturalGroup
##
##  <ManSection>
##  <Func Name="ConjugacyClassesOfNaturalGroup" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ConjugacyClassesOfNaturalGroup" );


#############################################################################
##
#F  Phi2( <n> ) . . . . . . . . . . . .  Modification of Euler's Phi function
##
##  <ManSection>
##  <Func Name="Phi2_Md" Arg='n'/>
##
##  <Description>
##  This is a utility function for the computation of the class numbers of
##  SL(n,q), PSL(n,q), SU(n,q) and PSU(n,q). It is a variant of the Euler
##  Phi function defined by Macdonald in <Cite Key="Mac81"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("Phi2_Md");

#############################################################################
##
#F  NrConjugacyClassesGL( <n>, <q> ) . . . . . . . . Class number for GL(n,q)
#F  NrConjugacyClassesGU( <n>, <q> ) . . . . . . . . Class number for GU(n,q)
#F  NrConjugacyClassesSL( <n>, <q> ) . . . . . . . . Class number for SL(n,q)
#F  NrConjugacyClassesSU( <n>, <q> ) . . . . . . . . Class number for SU(n,q)
#F  NrConjugacyClassesPGL( <n>, <q> ) . . . . . . .  Class number for PGL(n,q)
#F  NrConjugacyClassesPGU( <n>, <q> ) . . . . . . .  Class number for PGU(n,q)
#F  NrConjugacyClassesPSL( <n>, <q> ) . . . . . . .  Class number for PSL(n,q)
#F  NrConjugacyClassesPSU( <n>, <q> ) . . . . . . .  Class number for PSU(n,q)
#F  NrConjugacyClassesSLIsogeneous( <n>, <q>, <f> ) . . for SL(n,q) isogeneous
#F  NrConjugacyClassesSUIsogeneous( <n>, <q>, <f> ) . . for SU(n,q) isogeneous
##
##  <#GAPDoc Label="NrConjugacyClassesGL">
##  <ManSection>
##  <Func Name="NrConjugacyClassesGL" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesGU" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesSL" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesSU" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesPGL" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesPGU" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesPSL" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesPSU" Arg='n, q'/>
##  <Func Name="NrConjugacyClassesSLIsogeneous" Arg='n, q, f'/>
##  <Func Name="NrConjugacyClassesSUIsogeneous" Arg='n, q, f'/>
##
##  <Description>
##  The first of these functions compute for given positive integer <A>n</A>
##  and prime power <A>q</A> the number of conjugacy classes in the classical
##  groups GL( <A>n</A>, <A>q</A> ), GU( <A>n</A>, <A>q</A> ),
##  SL( <A>n</A>, <A>q</A> ), SU( <A>n</A>, <A>q</A> ),
##  PGL( <A>n</A>, <A>q</A> ), PGU( <A>n</A>, <A>q</A> ),
##  PSL( <A>n</A>, <A>q</A> ), PSL( <A>n</A>, <A>q</A> ), respectively.
##  (See also <Ref Attr="ConjugacyClasses" Label="attribute"/>  and
##  Section&nbsp;<Ref Sect="Classical Groups"/>.)
##  <P/>
##  For each divisor <A>f</A> of <A>n</A> there is a group of Lie type
##  with the same order as SL( <A>n</A>, <A>q</A> ), such that its derived
##  subgroup modulo its center is isomorphic to PSL( <A>n</A>, <A>q</A> ).
##  The various such groups with fixed <A>n</A> and <A>q</A> are called
##  <E>isogeneous</E>.
##  (Depending on congruence conditions on <A>q</A> and <A>n</A> several of
##  these groups may actually be isomorphic.)
##  The function <Ref Func="NrConjugacyClassesSLIsogeneous"/> computes the
##  number of conjugacy classes in this group.
##  The extreme cases <A>f</A> <M>= 1</M> and <A>f</A> <M>= n</M> lead
##  to the groups SL( <A>n</A>, <A>q</A> ) and PGL( <A>n</A>, <A>q</A> ),
##  respectively.
##  <P/>
##  The function <Ref Func="NrConjugacyClassesSUIsogeneous"/> is the
##  analogous one for the corresponding unitary groups.
##  <P/>
##  The formulae for the number of conjugacy classes are taken
##  from&nbsp;<Cite Key="Mac81"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> NrConjugacyClassesGL(24,27);
##  22528399544939174406067288580609952
##  gap> NrConjugacyClassesPSU(19,17);
##  15052300411163848367708
##  gap> NrConjugacyClasses(SL(16,16));
##  1229782938228219920
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrConjugacyClassesGL");
DeclareGlobalFunction("NrConjugacyClassesGU");
DeclareGlobalFunction("NrConjugacyClassesSL");
DeclareGlobalFunction("NrConjugacyClassesSU");
DeclareGlobalFunction("NrConjugacyClassesPGL");
DeclareGlobalFunction("NrConjugacyClassesPGU");
DeclareGlobalFunction("NrConjugacyClassesPSL");
DeclareGlobalFunction("NrConjugacyClassesPSU");
DeclareGlobalFunction("NrConjugacyClassesSLIsogeneous");
DeclareGlobalFunction("NrConjugacyClassesSUIsogeneous");

DeclareGlobalFunction("ClassesProjectiveImage");
