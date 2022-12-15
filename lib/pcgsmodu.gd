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
##  This file contains the operations for polycyclic generating systems modulo
##  another such system.
##

#############################################################################
##
#O  ModuloPcgsByPcSequenceNC( <home>, <pcs>, <modulo> )
##
##  <ManSection>
##  <Oper Name="ModuloPcgsByPcSequenceNC" Arg='home, pcs, modulo'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ModuloPcgsByPcSequenceNC",
    [ IsPcgs, IsList, IsPcgs ] );


#############################################################################
##
#O  ModuloPcgsByPcSequence( <home>, <pcs>, <modulo> )
##
##  <ManSection>
##  <Oper Name="ModuloPcgsByPcSequence" Arg='home, pcs, modulo'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ModuloPcgsByPcSequence",
    [ IsPcgs, IsList, IsPcgs ] );

#############################################################################
##
#O  ModuloTailPcgsByList( <home>, <list>, <taildepths> )
##
##  <ManSection>
##  <Oper Name="ModuloTailPcgsByList" Arg='home, list, taildepths'/>
##
##  <Description>
##  constructs a modulo pcgs whose elements are <A>list</A> and whose denominator
##  is the subset of <A>home</A> given by the indices in <A>taildepths</A>.  <A>list</A>
##  must be a list of elements of different depths so that the exponents for
##  this modulo pcgs are just the exponents in home at the indices given by
##  the entries in <A>list</A>. (So in particular, <A>list</A> must be a subset of
##  <A>home</A> modulo the tail.) No check is performed whether the input is
##  valid.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ModuloTailPcgsByList" );

#############################################################################
##
#O  ModuloPcgs( <G>, <N> )
##
##  <#GAPDoc Label="ModuloPcgs">
##  <ManSection>
##  <Oper Name="ModuloPcgs" Arg='G, N'/>
##
##  <Description>
##  returns a modulo pcgs for the factor <M><A>G</A>/<A>N</A></M> which must
##  be solvable, while <A>N</A> may be non-solvable.
##  <Ref Oper="ModuloPcgs"/> will return <E>a</E> pcgs for the factor,
##  there is no guarantee that it will be <Q>compatible</Q> with any other
##  pcgs.
##  If this is required, the <K>mod</K> operator must be used on
##  induced pcgs, see <Ref Meth="\mod" Label="for two pcgs"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ModuloPcgs", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  DenominatorOfModuloPcgs( <pcgs> )
##
##  <#GAPDoc Label="DenominatorOfModuloPcgs">
##  <ManSection>
##  <Attr Name="DenominatorOfModuloPcgs" Arg='pcgs'/>
##
##  <Description>
##  returns a generating set for the denominator of the modulo pcgs
##  <A>pcgs</A>.
##
##  <Example><![CDATA[
##  gap> G := Group( (1,2,3,4,5),(1,2) );
##  Group([ (1,2,3,4,5), (1,2) ])
##  gap> P := ModuloPcgs(G, DerivedSubgroup(G) );
##  Pcgs([ (4,5) ])
##  gap> NumeratorOfModuloPcgs(P);
##  [ (1,2,3,4,5), (1,2) ]
##  gap> DenominatorOfModuloPcgs(P);
##  [ (1,3,2), (1,4,3), (2,5,4) ]
##  gap> RelativeOrders(P);
##  [ 2 ]
##  gap> ExponentsOfPcElement( P, (1,2,3,4,5) );
##  [ 0 ]
##  gap> ExponentsOfPcElement( P, (4,5) );
##  [ 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DenominatorOfModuloPcgs", IsModuloPcgs );


#############################################################################
##
#A  NumeratorOfModuloPcgs( <pcgs> )
##
##  <#GAPDoc Label="NumeratorOfModuloPcgs">
##  <ManSection>
##  <Attr Name="NumeratorOfModuloPcgs" Arg='pcgs'/>
##
##  <Description>
##  returns a generating set for the numerator of the modulo pcgs
##  <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NumeratorOfModuloPcgs", IsModuloPcgs );

#############################################################################
##
#P  IsNumeratorParentPcgsFamilyPcgs( <mpcgs> )
##
##  <ManSection>
##  <Prop Name="IsNumeratorParentPcgsFamilyPcgs" Arg='mpcgs'/>
##
##  <Description>
##  This property indicates that the numerator of the modulo pcgs
##  <A>mpcgs</A> is induced with respect to a family pcgs.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsNumeratorParentPcgsFamilyPcgs", IsModuloPcgs );


#############################################################################
##
#O  ExponentsConjugateLayer( <mpcgs>, <elm>, <e> )
##
##  <#GAPDoc Label="ExponentsConjugateLayer">
##  <ManSection>
##  <Oper Name="ExponentsConjugateLayer" Arg='mpcgs, elm, e'/>
##
##  <Description>
##  Computes the exponents of <A>elm</A><C>^</C><A>e</A> with respect to
##  <A>mpcgs</A>; <A>elm</A> must be in the span of <A>mpcgs</A>,
##  <A>e</A> a pc element in the span of the
##  parent pcgs of <A>mpcgs</A> and <A>mpcgs</A> must be the modulo pcgs for
##  an abelian layer. (This is the usual case when acting on a chief
##  factor). In this case if <A>mpcgs</A> is induced by the family pcgs (see
##  section <Ref Sect="Subgroups of Polycyclic Groups - Induced Pcgs"/>),
##  the exponents can be computed directly by looking up exponents without
##  having to compute in the group and having to collect a potential tail.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentsConjugateLayer",
  [IsModuloPcgs,IsMultiplicativeElementWithInverse,
                IsMultiplicativeElementWithInverse] );
