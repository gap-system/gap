#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Lukas Maas, Jack Schmidt.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
##  <#GAPDoc Label="{SchurCoversOfSymmetricGroup}">
##
##  <Subsection><Heading>Covering groups of symmetric groups</Heading>
##
##  The covering groups of symmetric groups were classified in <Cite
##  Key="Schur1911"/>; an inductive procedure to construct faithful,
##  irreducible representations of minimal degree over all fields was presented
##  in <Cite Key="Maas2010"/>. Methods for <Ref Attr="EpimorphismSchurCover"/> are
##  provided for natural symmetric groups which use these representations. For
##  alternating groups, the restriction of these representations are provided,
##  but they may not be irreducible.  In the case of degree <M>6</M> and
##  <M>7</M>, they are not the full covering groups and so matrix
##  representations are just stored explicitly for the six-fold covers.
##
##  <Example><![CDATA[
##  gap> EpimorphismSchurCover(SymmetricGroup(15));
##  [ < immutable compressed matrix 64x64 over GF(9) >,
##    < immutable compressed matrix 64x64 over GF(9) > ] ->
##  [ (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15), (1,2) ]
##  gap> EpimorphismSchurCover(AlternatingGroup(15));
##  [ < immutable compressed matrix 64x64 over GF(9) >,
##    < immutable compressed matrix 64x64 over GF(9) > ] ->
##  [ (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15), (13,14,15) ]
##  gap> SchurCoverOfSymmetricGroup(12);
##  <matrix group of size 958003200 with 2 generators>
##  gap> DoubleCoverOfAlternatingGroup(12);
##  <matrix group of size 479001600 with 2 generators>
##  gap> BasicSpinRepresentationOfSymmetricGroup( 10, 3, -1 );
##  [ < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) >,
##    < immutable compressed matrix 16x16 over GF(9) > ]
##  ]]></Example>
##
##  </Subsection>
##
##  <#Include Label="BasicSpinRepresentationOfSymmetricGroup">
##
##  <#Include Label="SchurCoverOfSymmetricGroup">
##
##  <#Include Label="DoubleCoverOfAlternatingGroup">
##
##  <#/GAPDoc>

#############################################################################
##
#F  BasicSpinRepresentationOfSymmetricGroup
##
##  <#GAPDoc Label="BasicSpinRepresentationOfSymmetricGroup">
##
##  <ManSection>
##
##  <Func Name="BasicSpinRepresentationOfSymmetricGroup" Arg="n, p, sign"/>
##
##  <Description> Constructs the image of the Coxeter generators in the basic
##  spin (projective) representation of the symmetric group of degree <A>n</A>
##  over a field of characteristic <M><A>p</A> \geq 0</M>. There are two such
##  representations and <A>sign</A> controls which is returned: +1 gives a
##  group where the preimage of an adjacent transposition <M>(i,i+1)</M> has
##  order 4, -1 gives a group where the preimage of an adjacent transposition
##  <M>(i,i+1)</M> has order 2.  If no <A>sign</A> is specified, +1 is used by
##  default.  If no <A>p</A> is specified, 3 is used by default.
##  (Note that the convention of which cover is labelled as +1 is
##  inconsistent in the literature.)</Description>
##
##  </ManSection>
##
##  <#/GAPDoc>

DeclareGlobalFunction( "BasicSpinRepresentationOfSymmetricGroup" );

#############################################################################
##
#O  SchurCoverOfSymmetricGroup( <n>, <p>, <sign> )
##
##  <#GAPDoc Label="SchurCoverOfSymmetricGroup">
##
##  <ManSection> <Oper Name="SchurCoverOfSymmetricGroup" Arg='n, p, sign'/>
##
##  <Description> Constructs a Schur cover of <C>SymmetricGroup(<A>n</A>)</C>
##  as a faithful, irreducible matrix group in characteristic <A>p</A>
##  (<M><A>p</A> \neq 2</M>).  For <M><A>n</A> \geq 4</M>, there are two such
##  covers, and <A>sign</A> determines which is returned: +1 gives a group
##  where the preimage of an adjacent transposition <M>(i,i+1)</M> has order 4,
##  -1 gives a group where the preimage of an adjacent transposition
##  <M>(i,i+1)</M> has order 2.  If no <A>sign</A> is specified, +1 is used by
##  default.  If no <A>p</A> is specified, 3 is used by default.
##  (Note that the convention of which cover is labelled as +1 is
##  inconsistent in the literature.)
##
##  For <M><A>n</A> \leq 3</M>, the symmetric group is its own Schur cover and
##  <A>sign</A> is ignored. For <M><A>p</A> = 2</M>, there is no faithful,
##  irreducible representation of the Schur cover unless <M><A>n</A> = 1</M> or
##  <M><A>n</A> = 3</M>, so <K>fail</K> is returned if <M><A>p</A> = 2</M>. For
##  <M><A>p</A> = 3</M>, <M><A>n</A> = 3</M>, the representation is
##  indecomposable, but reducible.
##
##  The field of the matrix group is generally <C>GF(<A>p</A>^2)</C> if
##  <M><A>p</A> &gt; 0</M>, and an abelian number field if <M><A>p</A> = 0</M>.
##
##  </Description> </ManSection>
##
##  <#/GAPDoc>
##
DeclareOperation("SchurCoverOfSymmetricGroup",[IsPosInt,IsInt,IsInt]);

#############################################################################
##
#O  DoubleCoverOfAlternatingGroup( <n>, <p> )
##
##  <#GAPDoc Label="DoubleCoverOfAlternatingGroup">
##
##  <ManSection> <Oper Name="DoubleCoverOfAlternatingGroup" Arg='n, p'/>
##
##  <Description>
##
##  Constructs a double cover of <C>AlternatingGroup(<A>n</A>)</C> as a
##  faithful, completely reducible matrix group in characteristic <A>p</A>
##  (<M>p \neq 2</M>) for <M>n \geq 4</M>.
##
##  For <M>n \leq 3</M>, the alternating group is its own Schur cover, and
##  <K>fail</K> is returned. For <M>p = 2</M>, there is no faithful, completely
##  reducible representation of the double cover, so <K>fail</K> is returned.
##
##  The field of the matrix group is generally <C>GF(p^2)</C> if <M>p>0</M>,
##  and an abelian number field if <M>p=0</M>.  If <A>p</A> is omitted, the
##  default is 3.
##
##  </Description> </ManSection>
##
##  <#/GAPDoc>
##
DeclareOperation("DoubleCoverOfAlternatingGroup",[IsPosInt,IsInt]);
