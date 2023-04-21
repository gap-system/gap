#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Isabel Araújo.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for semigroups defined by rws.
##

############################################################################
##
#A  ReducedConfluentRewritingSystem( <S>[, <ordering>] )
##
##  <#GAPDoc Label="ReducedConfluentRewritingSystem">
##  <ManSection>
##  <Attr Name="ReducedConfluentRewritingSystem" Arg='S[, ordering]'/>
##
##  <Description>
##  returns a reduced confluent rewriting system of
##  the finitely presented semigroup or monoid <A>S</A> with respect to the
##  reduction ordering <A>ordering</A> (see <Ref Chap="Orderings"/>).
##  <P/>
##  The default for <A>ordering</A> is the length plus lexicographic ordering
##  on words, also called the shortlex ordering; for the definition see for
##  example <Cite Key="Sims94"/>.
##  <P/>
##  Notice that this might not terminate. In particular, if the semigroup or
##  monoid <A>S</A> does not have a solvable word problem then it this will
##  certainly never end.
##  Also, in this case, the object returned is an immutable
##  rewriting system, because once we have a confluent
##  rewriting system for a finitely presented semigroup or monoid we do
##  not want to allow it to change (as it was most probably very time
##  consuming to get it in the first place). Furthermore, this is also
##  an attribute storing object (see <Ref Sect="Representation"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> f := FreeSemigroup( "a", "b" );;
##  gap> a := f.1;;  b := f.2;;
##  gap> s := f / [ [ a*b*a, b ], [ b*a*b, a ] ];;
##  gap> rws := ReducedConfluentRewritingSystem( s );
##  Rewriting System for Semigroup( [ a, b ] ) with rules
##  [ [ a*b*a, b ], [ b*a*b, a ], [ b*a^2, a^2*b ], [ b^2, a^2 ],
##    [ a^5, a ], [ a^3*b, b*a ] ]
##  gap> c := s.1;;  d := s.2;;
##  gap> e := (c*d^2)^3;
##  (a*b^2)^3
##  gap> ## ReducedForm( rws, e );  gives an error!
##  gap> w := UnderlyingElement( e );
##  (a*b^2)^3
##  gap> ReducedForm( rws, w );
##  a
##  ]]></Example>
##  <P/>
##  The creation of a reduced confluent rewriting system for a semigroup
##  or for a monoid, in &GAP;, uses the Knuth-Bendix procedure for strings,
##  which manipulates a rewriting system of the semigroup or monoid and
##  attempts to make it confluent,
##  (see Chapter <Ref Chap="Rewriting Systems"/>
##  and also Sims <Cite Key="Sims94"/>).
##  (Since the word problem for semigroups/monoids is not solvable in general,
##  the Knuth-Bendix procedure cannot always terminate).
##  <P/>
##  In order to apply this procedure we will build a rewriting system
##  for the semigroup or monoid, which we will call a  <E>Knuth-Bendix Rewriting
##  System</E> (we need to define this because we need the rewriting system
##  to store some information needed for the implementation of the
##  Knuth-Bendix procedure).
##  <P/>
##  Actually, Knuth-Bendix Rewriting Systems do not only serve this purpose.
##  Indeed these  are objects which are mutable and which can be manipulated
##  (see <Ref Chap="Rewriting Systems"/>).
##  <P/>
##  Note that the implemented version of the Knuth-Bendix procedure, in &GAP;
##  returns, if it terminates, a confluent rewriting system which is reduced.
##  Also, a reduction ordering has to be specified when building a rewriting
##  system. If none is specified, the shortlex ordering is assumed
##  (note that the procedure may terminate with a certain ordering and
##  not with another one).
##  <P/>
##  On Unix systems it is possible to replace the built-in Knuth-Bendix by
##  other routines, for example the package <Package>kbmag</Package> offers
##  such a possibility.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ReducedConfluentRewritingSystem",IsSemigroup);

#############################################################################
##
#A  FreeSemigroupOfRewritingSystem(<rws>)
#A  FreeMonoidOfRewritingSystem(<rws>)
##
##  <#GAPDoc Label="FreeSemigroupOfRewritingSystem">
##  <ManSection>
##  <Attr Name="FreeSemigroupOfRewritingSystem" Arg='rws'/>
##  <Attr Name="FreeMonoidOfRewritingSystem" Arg='rws'/>
##
##  <Description>
##  returns the free semigroup or monoid over which <A>rws</A> is
##  a rewriting system.
##  <P/>
##  <Example><![CDATA[
##  gap> f1 := FreeSemigroupOfRewritingSystem( rws );
##  <free semigroup on the generators [ a, b ]>
##  gap> f1 = f;
##  true
##  gap> s1 := SemigroupOfRewritingSystem( rws );
##  <fp semigroup on the generators [ a, b ]>
##  gap> s1 = s;
##  true
##  ]]></Example>
##  <P/>
##  As mentioned before, having a confluent rewriting system, one can decide
##  whether two words represent the same element of a finitely
##  presented semigroup (or finitely presented monoid).
##  <P/>
##  <Example><![CDATA[
##  gap> d^6 = c^2;
##  true
##  gap> ReducedForm( rws, UnderlyingElement( d^6 ) );
##  a^2
##  gap> ReducedForm( rws, UnderlyingElement( c^2 ) );
##  a^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("FreeSemigroupOfRewritingSystem", IsRewritingSystem);
DeclareAttribute("FreeMonoidOfRewritingSystem", IsRewritingSystem);

#############################################################################
##
#A  FamilyForRewritingSystem(<rws>)
##
##  <ManSection>
##  <Attr Name="FamilyForRewritingSystem" Arg='rws'/>
##
##  <Description>
##  returns the family of words over which <A>rws</A> is
##  a rewriting system
##  </Description>
##  </ManSection>
##
DeclareAttribute("FamilyForRewritingSystem", IsRewritingSystem);


#############################################################################
##
#F  ReduceLetterRepWordsRewSys(<tzrules>,<w>)
##
##  <ManSection>
##  <Func Name="ReduceLetterRepWordsRewSys" Arg='tzrules,w'/>
##
##  <Description>
##  Here <A>w</A> is a word of a free monoid or a free semigroup in tz
##  representation, and <A>tzrules</A> are rules in tz representation.
##  This function returns the reduced word in tz representation.
##  <P/>
##  All lists in <A>tzrules</A> as well as <A>w</A> must be plain lists,
##  the entries must be small integers.
##  (The behaviour otherwise is unpredictable.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ReduceLetterRepWordsRewSys");
