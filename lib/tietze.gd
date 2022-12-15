#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##


#############################################################################
##
##  Some global symbolic constants.
##
TZ_NUMGENS      :=  1;
TZ_NUMRELS      :=  2;
TZ_TOTAL        :=  3;
TZ_GENERATORS   :=  4;
TZ_INVERSES     :=  5;
TZ_RELATORS     :=  6;
TZ_LENGTHS      :=  7;
TZ_FLAGS        :=  8;
TZ_MODIFIED     := 10;
TZ_NUMREDUNDS   := 11;
TZ_STATUS       := 15;
TZ_LENGTHTIETZE := 21;

TZ_FREEGENS     :=  9;
# TZ_ITERATOR     := 12;
TZ_OCCUR        :=21;

TR_TREELENGTH   :=  3;
TR_PRIMARY      :=  4;
TR_TREENUMS     :=  5;
TR_TREEPOINTERS :=  6;
TR_TREELAST     :=  7;


#############################################################################
##
##  List of option names
##
TzOptionNames := MakeImmutable([ "protected", "eliminationsLimit", "expandLimit",
     "generatorsLimit", "lengthLimit", "loopLimit", "printLevel",
     "saveLimit", "searchSimultaneous" ]);


#############################################################################
##
#A  TietzeOrigin( <G> )
##
##  <ManSection>
##  <Attr Name="TietzeOrigin" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "TietzeOrigin", IsSubgroupFpGroup );


#############################################################################
##
#F  AbstractWordTietzeWord( <word>, <fgens> )
##
##  <#GAPDoc Label="AbstractWordTietzeWord">
##  <ManSection>
##  <Func Name="AbstractWordTietzeWord" Arg='word, fgens'/>
##
##  <Description>
##  assumes  <A>fgens</A>  to be  a list  of  free group
##  generators and  <A>word</A> to be a Tietze word in these generators,
##  i. e., a list of positive or negative generator numbers.
##  It converts <A>word</A> to an abstract word.
##  <P/>
##  This function simply calls <Ref Oper="AssocWordByLetterRep"/>.
##  <Example><![CDATA[
##  gap> F := FreeGroup( "a", "b", "c" ,"d");
##  <free group on the generators [ a, b, c, d ]>
##  gap> tzword := TietzeWordAbstractWord(
##  > Comm(F.4,F.2) * (F.3^2 * F.2)^-1, GeneratorsOfGroup( F ){[2,3,4]} );
##  [ -3, -1, 3, -2, -2 ]
##  gap> AbstractWordTietzeWord( tzword, GeneratorsOfGroup( F ){[2,3,4]} );
##  d^-1*b^-1*d*c^-2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AbstractWordTietzeWord");


#############################################################################
##
#F  TietzeWordAbstractWord( <word>, <fgens> )
##
##  <#GAPDoc Label="TietzeWordAbstractWord">
##  <ManSection>
##  <Oper Name="TietzeWordAbstractWord" Arg='word, fgens'/>
##
##  <Description>
##  assumes <A>fgens</A> to be a list of free group generators
##  and <A>word</A> to be an abstract word in these generators.
##  It converts <A>word</A> into a Tietze word,
##  i. e., a list of positive or negative generator numbers.
##  <P/>
##  This function simply calls <Ref Oper="LetterRepAssocWord"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym("TietzeWordAbstractWord",LetterRepAssocWord);

#############################################################################
##
#F  TzWordAbstractWord( <word> )
#F  AbstractWordTzWord(<fam>, <tzword> )
##
##  <ManSection>
##  <Func Name="TzWordAbstractWord" Arg='word'/>
##  <Func Name="AbstractWordTzWord" Arg='fam, tzword'/>
##
##  <Description>
##  only supported for compatibility.
##  </Description>
##  </ManSection>
##
DeclareSynonym("TzWordAbstractWord",LetterRepAssocWord);
DeclareSynonym("AbstractWordTzWord",AssocWordByLetterRep);


#############################################################################
##
#F  AddGenerator( <P> )
##
##  <#GAPDoc Label="AddGenerator">
##  <ManSection>
##  <Func Name="AddGenerator" Arg='P'/>
##
##  <Description>
##  extends the presentation <A>P</A> by a new generator.
##  <P/>
##  Let <M>i</M> be the smallest positive integer which has not yet been used
##  as a generator number in the given presentation.
##  <Ref Func="AddGenerator"/> defines a new abstract generator <M>x_i</M>
##  with the name <C>"_x</C><M>i</M><C>"</C> and adds it to the
##  list of generators of <A>P</A>.
##  <P/>
##  You may access the generator <M>x_i</M> by typing
##  <A>P</A><C>!.</C><M>i</M>. However, this
##  is only practicable if you are running an interactive job because you
##  have to know the value of <M>i</M>. Hence the proper way to access the new
##  generator is to write
##  <C>GeneratorsOfPresentation(P)[Length(GeneratorsOfPresentation(P))]</C>.
##  <Example><![CDATA[
##  gap> G := PerfectGroup(IsFpGroup, 120 );;
##  gap> H := Subgroup( G, [ G.1^G.2, G.3 ] );;
##  gap> P := PresentationSubgroup( G, H );
##  <presentation with 4 gens and 7 rels of total length 21>
##  gap> AddGenerator( P );
##  #I  now the presentation has 5 generators, the new generator is _x7
##  gap> gens := GeneratorsOfPresentation( P );
##  [ _x1, _x2, _x4, _x5, _x7 ]
##  gap> gen := gens[Length( gens )];
##  _x7
##  gap> gen = P!.7;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AddGenerator");


#############################################################################
##
#F  AddRelator( <P>, <word> )
##
##  <#GAPDoc Label="AddRelator">
##  <ManSection>
##  <Func Name="AddRelator" Arg='P, word'/>
##
##  <Description>
##  adds the relator <A>word</A> to the presentation <A>P</A>, probably
##  changing the group defined by <A>P</A>.
##  <A>word</A> must be an abstract word in the generators of <A>P</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AddRelator");


#############################################################################
##
#F  DecodeTree(<P>)
##
##  <#GAPDoc Label="DecodeTree">
##  <ManSection>
##  <Func Name="DecodeTree" Arg='P'/>
##
##  <Description>
##  assumes that <A>P</A> is a subgroup presentation provided by the Reduced
##  Reidemeister-Schreier or by the Modified Todd-Coxeter method (see
##  <Ref Func="PresentationSubgroupRrs"
##  Label="for two groups (and a string)"/>,
##  <Ref Func="PresentationNormalClosureRrs"/>,
##  <Ref Func="PresentationSubgroupMtc"/>).
##  It eliminates the secondary generators of <A>P</A>
##  (see Section <Ref Sect="Subgroup Presentations"/>) by applying the
##  so called <Q>decoding tree</Q> procedure.
##  <P/>
##  <Ref Func="DecodeTree"/> is called automatically by the command
##  <Ref Func="PresentationSubgroupMtc"/> where it
##  reduces <A>P</A> to a presentation on the given (primary) subgroup
##  generators.
##  <Index>secondary subgroup generators</Index>
##  <P/>
##  In order to explain the effect of this command we need to insert a few
##  remarks on the subgroup presentation commands described in section
##  <Ref Sect="Subgroup Presentations"/>.
##  All these commands have the common property that in the process of
##  constructing a presentation for a given subgroup <A>H</A> of a finitely
##  presented group <A>G</A> they first build up a highly
##  redundant list of generators of <A>H</A> which consists of an (in general
##  small) list of <Q>primary</Q> generators, followed by an (in general
##  large) list of <Q>secondary</Q> generators, and then construct a
##  presentation <M>P_0</M>
##  <E>on a sublist of these generators</E> by rewriting
##  the defining relators of <A>G</A>.
##  This sublist contains all primary, but, at least in general,
##  by far not all secondary generators.
##  <Index>primary subgroup generators</Index>
##  <P/>
##  The role of the primary generators depends on the concrete choice of the
##  subgroup presentation command. If the Modified Todd-Coxeter method is
##  used, they are just the given generators of <A>H</A>,
##  whereas in the case of the Reduced Reidemeister-Schreier algorithm they
##  are constructed by the program.
##  <P/>
##  Each of the secondary generators is defined by a word of length two in
##  the preceding generators and their inverses. By historical reasons, the
##  list of these definitions is called the <E>subgroup generators tree</E>
##  though in fact it is not a tree but rather a kind of bush.
##  <Index>subgroup generators tree</Index>
##  <P/>
##  Now we have to distinguish two cases. If <M>P_0</M> has been constructed
##  by the Reduced Reidemeister-Schreier routines, it is a presentation of
##  <A>H</A>. However, if the Modified Todd-Coxeter routines have been used
##  instead, then the relators in <M>P_0</M> are valid relators of <A>H</A>,
##  but they do not necessarily define <A>H</A>.
##  We handle these cases in turn, starting with the latter one.
##  <P/>
##  In fact, we could easily receive a presentation of <A>H</A> also in this
##  case if we extended <M>P_0</M> by adding to it all the
##  secondary generators which are not yet contained in it and all the
##  definitions from the generators tree as additional generators and
##  relators.
##  Then we could recursively eliminate all secondary generators by Tietze
##  transformations using the new relators.
##  However, this procedure turns out to be too inefficient to
##  be of interest.
##  <P/>
##  Instead, we use the so called <E>decoding tree</E> procedure
##  (see <Cite Key="AMW82"/>, <Cite Key="AR84"/>). It proceeds as follows.
##  <P/>
##  Starting from <M>P = P_0</M>, it runs through a number of steps in each
##  of which it eliminates the current <Q>last</Q> generator (with respect to
##  the list of all primary and secondary generators). If the last generator
##  <A>g</A> is a primary generator, then the procedure terminates.
##  Otherwise it checks whether there is a relator in the current
##  presentation which can be used to substitute <A>g</A> by a Tietze
##  transformation. If so, this is done.
##  Otherwise, and only then, the tree definition of <A>g</A> is added to
##  <A>P</A> as a new relator, and the generators involved are added as new
##  generators if they have not yet been contained in <A>P</A>.
##  Subsequently, <A>g</A> is eliminated.
##  <P/>
##  Note that the extension of <A>P</A> by one or two new generators is
##  <E>not</E> a Tietze transformation.
##  In general, it will change the isomorphism type
##  of the group defined by <A>P</A>.
##  However, it is a remarkable property of this procedure, that at the end,
##  i.e., as soon as all secondary generators have been eliminated,
##  it provides a presentation <M>P = P_1</M>,
##  say, which defines a group isomorphic to <A>H</A>. In fact, it is this
##  presentation which is returned by the command <Ref Func="DecodeTree"/>
##  and hence by the command <Ref Func="PresentationSubgroupMtc"/>.
##  <P/>
##  If, in the other case, the presentation <M>P_0</M> has been constructed
##  by the Reduced Reidemeister-Schreier algorithm,
##  then <M>P_0</M> itself is a presentation of <A>H</A>,
##  and the corresponding subgroup presentation command
##  (<Ref Func="PresentationSubgroupRrs"
##  Label="for two groups (and a string)"/> or
##  <Ref Func="PresentationNormalClosureRrs"/>) just returns <M>P_0</M>.
##  <P/>
##  As mentioned in section <Ref Sect="Subgroup Presentations"/>,
##  we recommend to further simplify this presentation before you use it.
##  The standard way to do this is to start from <M>P_0</M> and to apply
##  suitable Tietze transformations,
##  e. g., by calling the commands <Ref Func="TzGo"/> or
##  <Ref Func="TzGoGo"/>.
##  This is probably the most efficient approach, but you will end up with a
##  presentation on some unpredictable set of generators.
##  As an alternative, &GAP; offers you the <Ref Func="DecodeTree"/> command
##  which you can use to eliminate all secondary
##  generators (provided that there are no space or time problems). For this
##  purpose, the subgroup presentation commands do not only return the
##  resulting presentation, but also the tree (together with some associated
##  lists) as a kind of side result in a component <A>P</A><C>!.tree</C> of
##  the resulting presentation <A>P</A>.
##  <P/>
##  Note, however, that the decoding tree routines will not work correctly
##  any more on a presentation from which generators have already been
##  eliminated by Tietze transformations.
##  Therefore, to prevent you from getting wrong results by calling
##  <Ref Func="DecodeTree"/> in such a situation,
##  &GAP; will automatically remove the subgroup generators tree
##  from a presentation as soon as one of the generators is substituted by a
##  Tietze transformation.
##  <P/>
##  Nevertheless, a certain misuse of the command is still possible, and we
##  want to explicitly warn you from this.
##  The reason is that the Tietze option parameters described in
##  Section <Ref Sect="Tietze Options"/> apply to
##  <Ref Func="DecodeTree"/> as well.
##  Hence, in case of inadequate values of these parameters, it may happen that
##  <Ref Func="DecodeTree"/> stops before all the secondary generators have
##  vanished. In this case &GAP;
##  will display an appropriate warning. Then you should change the
##  respective parameters and continue the process by calling
##  <Ref Func="DecodeTree"/> again. Otherwise, if you would apply Tietze
##  transformations, it might happen because of the convention described
##  above that the tree is removed and that you end up with a wrong
##  presentation.
##  <P/>
##  After a successful run of <Ref Func="DecodeTree"/> it is convenient to
##  further simplify the resulting presentation by suitable Tietze
##  transformations.
##  <P/>
##  As an example of an explicit call of <Ref Func="DecodeTree"/> we compute
##  two presentations of a subgroup of order <M>384</M> in a group of order
##  <M>6912</M>. In both cases we use the Reduced Reidemeister-Schreier
##  algorithm, but in the first run we just apply the Tietze transformations
##  offered by the <Ref Func="TzGoGo"/> command with its default parameters,
##  whereas in the second run we call the <Ref Func="DecodeTree"/> command
##  before.
##  <P/>
##  <Example><![CDATA[
##  gap> F2 := FreeGroup( "a", "b" );;
##  gap> G := F2 / [ F2.1*F2.2^2*F2.1^-1*F2.2^-1*F2.1^3*F2.2^-1,
##  >                F2.2*F2.1^2*F2.2^-1*F2.1^-1*F2.2^3*F2.1^-1 ];;
##  gap> a := G.1;;  b := G.2;;
##  gap> H := Subgroup( G, [ Comm(a^-1,b^-1), Comm(a^-1,b), Comm(a,b) ] );;
##  ]]></Example>
##  <P/>
##  We use the Reduced Reidemeister Schreier method and default Tietze
##  transformations to get a presentation for <A>H</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> P := PresentationSubgroupRrs( G, H );
##  <presentation with 18 gens and 35 rels of total length 169>
##  gap> TzGoGo( P );
##  #I  there are 3 generators and 20 relators of total length 488
##  #I  there are 3 generators and 20 relators of total length 466
##  ]]></Example>
##  <P/>
##  We end up with 20 relators of total length 466. Now we repeat the
##  procedure, but we call the decoding tree algorithm before doing the Tietze
##  transformations.
##  <P/>
##  <Example><![CDATA[
##  gap> P := PresentationSubgroupRrs( G, H );
##  <presentation with 18 gens and 35 rels of total length 169>
##  gap> DecodeTree( P );
##  #I  there are 9 generators and 26 relators of total length 185
##  #I  there are 6 generators and 23 relators of total length 213
##  #I  there are 3 generators and 20 relators of total length 252
##  #I  there are 3 generators and 20 relators of total length 244
##  gap> TzGoGo( P );
##  #I  there are 3 generators and 19 relators of total length 168
##  #I  there are 3 generators and 17 relators of total length 138
##  #I  there are 3 generators and 15 relators of total length 114
##  #I  there are 3 generators and 13 relators of total length 96
##  #I  there are 3 generators and 12 relators of total length 84
##  ]]></Example>
##  <P/>
##  This time we end up with a shorter presentation.
##  <P/>
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DecodeTree");


#############################################################################
##
#F  FpGroupPresentation( <P> [,<nam>] )
##
##  <#GAPDoc Label="FpGroupPresentation">
##  <ManSection>
##  <Func Name="FpGroupPresentation" Arg='P [,nam]'/>
##
##  <Description>
##  constructs an f. p. group as defined by the given Tietze
##  presentation <A>P</A>.
##  <Example><![CDATA[
##  gap> h := FpGroupPresentation( p );
##  <fp group on the generators [ a, b ]>
##  gap> h = g;
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("FpGroupPresentation");


#############################################################################
##
#F  PresentationFpGroup( <G> [,<printlevel>] ) . . .  create a presentation
##
##  <#GAPDoc Label="PresentationFpGroup">
##  <ManSection>
##  <Func Name="PresentationFpGroup" Arg='G [,printlevel]'/>
##
##  <Description>
##  creates a presentation, i. e., a Tietze object, for the given finitely
##  presented group <A>G</A>. This presentation will be exactly as the
##  presentation of <A>G</A> and <E>no</E> initial Tietze transformations
##  are applied to it.
##  <P/>
##  The  optional <A>printlevel</A> parameter can be used to restrict or to
##  extend the amount of output provided by Tietze transformation
##  commands when being applied to the created presentation.  The
##  default value 1 is designed  for  interactive  use  and  implies
##  explicit  messages  to  be displayed  by most of  these  commands. A
##  <A>printlevel</A> value of  0 will suppress these messages, whereas a
##  <A>printlevel</A>  value of 2  will enforce some additional output.
##  <Example><![CDATA[
##  gap> f := FreeGroup( "a", "b" );
##  <free group on the generators [ a, b ]>
##  gap> g := f / [ f.1^3, f.2^2, (f.1*f.2)^3 ];
##  <fp group on the generators [ a, b ]>
##  gap> p := PresentationFpGroup( g );
##  <presentation with 2 gens and 3 rels of total length 11>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PresentationFpGroup");


#############################################################################
##
#F  PresentationRegularPermutationGroup(<G>)
#F  PresentationRegularPermutationGroupNC(<G>)
##
##  <ManSection>
##  <Func Name="PresentationRegularPermutationGroup" Arg='G'/>
##  <Func Name="PresentationRegularPermutationGroupNC" Arg='G'/>
##
##  <Description>
##  constructs a presentation from the given regular permutation group using
##  the algorithm which has been described in <Cite Key="Can73"/> and <Cite Key="Neu82"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("PresentationRegularPermutationGroup");
DeclareGlobalFunction("PresentationRegularPermutationGroupNC");


#############################################################################
##
#F  PresentationViaCosetTable( <G>[, <F>, <words>] )
##
##  <#GAPDoc Label="PresentationViaCosetTable">
##  <ManSection>
##  <Func Name="PresentationViaCosetTable" Arg='G[, F, words]'/>
##
##  <Description>
##  constructs a presentation for a given concrete finite group.
##  It applies the relations finding algorithm which has been described in
##  <Cite Key="Can73"/> and <Cite Key="Neu82"/>.
##  It automatically applies Tietze transformations to the presentation
##  found.
##  <P/>
##  If only a group <A>G</A> has been specified, the single stage algorithm
##  is applied.
##  <P/>
##  The operation <Ref Attr="IsomorphismFpGroup"/> in contrast uses a
##  multiple-stage algorithm using a chief series and stabilizer chains.
##  It usually should be used rather than
##  <Ref Func="PresentationViaCosetTable"/>.
##  (It does not apply Tietze transformations automatically.)
##  <P/>
##  If the two stage algorithm is to be used,
##  <Ref Func="PresentationViaCosetTable"/> expects a subgroup <A>H</A> of
##  <A>G</A> to be provided in form of two additional arguments <A>F</A> and
##  <A>words</A>, where <A>F</A> is a free group with the same number
##  of generators as <A>G</A>, and <A>words</A> is a list of words in the
##  generators of <A>F</A> which supply a list of generators of <A>H</A> if
##  they are evaluated as words in the corresponding generators of <A>G</A>.
##  <Example><![CDATA[
##  gap> G := GeneralLinearGroup( 2, 7 );
##  GL(2,7)
##  gap> GeneratorsOfGroup( G );
##  [ [ [ Z(7), 0*Z(7) ], [ 0*Z(7), Z(7)^0 ] ],
##    [ [ Z(7)^3, Z(7)^0 ], [ Z(7)^3, 0*Z(7) ] ] ]
##  gap> Size( G );
##  2016
##  gap> P := PresentationViaCosetTable( G );
##  <presentation with 2 gens and 5 rels of total length 46>
##  gap> TzPrintRelators( P );
##  #I  1. f2^3
##  #I  2. f1^6
##  #I  3. (f1*f2)^6
##  #I  4. f1*f2*f1^-1*f2*f1*f2^-1*f1^-1*f2*f1*f2*f1^-1*f2^-1
##  #I  5. f1^-3*f2*f1*f2*(f1^-1*f2^-1)^2*f1^-2*f2
##  ]]></Example>
##  <P/>
##  The two stage algorithm saves an essential amount of space by
##  constructing two coset tables of lengths <M>|H|</M> and <M>|G|/|H|</M>
##  instead of just one coset table of length <M>|G|</M>.
##  The next example shows an application
##  of this option in the case of a subgroup of size 7920 and index 12 in a
##  permutation group of size 95040.
##  <P/>
##  <Example><![CDATA[
##  gap> M12 := Group( [ (1,2,3,4,5,6,7,8,9,10,11), (3,7,11,8)(4,10,5,6),
##  > (1,12)(2,11)(3,6)(4,8)(5,9)(7,10) ], () );;
##  gap> F := FreeGroup( "a", "b", "c" );
##  <free group on the generators [ a, b, c ]>
##  gap> words := [ F.1, F.2 ];
##  [ a, b ]
##  gap> P := PresentationViaCosetTable( M12, F, words );
##  <presentation with 3 gens and 10 rels of total length 97>
##  gap> G := FpGroupPresentation( P );
##  <fp group on the generators [ a, b, c ]>
##  gap> RelatorsOfFpGroup( G );
##  [ c^2, b^4, (a*c)^3, (a*b^-2)^3, a^11,
##    a^2*b*a^-2*b^-1*(b^-1*a)^2*a*b^-1, (a*(b*a^-1)^2*b^-1)^2,
##    a^2*b*a^2*b^-2*a^-1*b*(a^-1*b^-1)^2,
##    a^2*b^-1*a^-1*b^-1*a*c*b*c*(a*b)^2, a^2*(a^2*b)^2*a^-2*c*a*b*a^-1*c
##   ]
##  ]]></Example>
##  <P/>
##  Before it is returned, the resulting presentation is being simplified by
##  appropriate calls of the function <Ref Func="SimplifyPresentation"/>
##  (see <Ref Sect="Tietze Transformations"/>),
##  but without allowing any eliminations of generators.
##  This restriction guarantees that we get a bijection between the list of
##  generators of <A>G</A> and the list of generators in the presentation.
##  Hence, if the generators of <A>G</A> are redundant and if you don't care
##  for the bijection, you may get a shorter presentation by calling the
##  function <Ref Func="SimplifyPresentation"/>,
##  now without this restriction, once more yourself.
##  <P/>
##  <Example><![CDATA[
##  gap> H := Group(
##  > [ (2,5,3), (2,7,5), (1,8,4), (1,8,6), (4,8,6), (3,5,7) ], () );;
##  gap> P := PresentationViaCosetTable( H );
##  <presentation with 6 gens and 12 rels of total length 42>
##  gap> SimplifyPresentation( P );
##  #I  there are 4 generators and 10 relators of total length 36
##  ]]></Example>
##  <P/>
##  If you apply the function <Ref Func="FpGroupPresentation"/> to the
##  resulting presentation you will get a finitely presented group isomorphic
##  to <A>G</A>.
##  Note, however, that the function <Ref Attr="IsomorphismFpGroup"/>
##  is recommended for this purpose.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PresentationViaCosetTable");


#############################################################################
##
#F  RelsViaCosetTable(<G>,<cosets>,<F>)
#F  RelsViaCosetTable(<G>,<cosets>,<F>,<ggens>)
#F  RelsViaCosetTable(<G>,<cosets>,<F>,<words>,<H>,<R1>)
##
##  <ManSection>
##  <Func Name="RelsViaCosetTable" Arg='G,cosets,F'/>
##  <Func Name="RelsViaCosetTable" Arg='G,cosets,F,ggens'/>
##  <Func Name="RelsViaCosetTable" Arg='G,cosets,F,words,H,R1'/>
##
##  <Description>
##  constructs a defining set of relators  for the given
##  concrete group using the algorithm
##  which has been described in <Cite Key="Can73"/> and <Cite Key="Neu82"/>.
##  <P/>
##  It is a  subroutine  of function  <C>PresentationViaCosetTable</C>.  Hence its
##  input and output are specifically designed only for this purpose,  and it
##  does not check the arguments.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelsViaCosetTable");


#############################################################################
##
#F  RemoveRelator( <P>, <n> )
##
##  <#GAPDoc Label="RemoveRelator">
##  <ManSection>
##  <Func Name="RemoveRelator" Arg='P, n'/>
##
##  <Description>
##  removes the <A>n</A>-th relator from the presentation <A>P</A>,
##  probably changing the group defined by <A>P</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RemoveRelator");


#############################################################################
##
#F  SimplifiedFpGroup( <G> )
##
##  <#GAPDoc Label="SimplifiedFpGroup">
##  <ManSection>
##  <Func Name="SimplifiedFpGroup" Arg='G'/>
##
##  <Description>
##  applies Tietze transformations to a copy of the presentation of the
##  given finitely presented group <A>G</A> in order to reduce it
##  with respect to the number of generators, the number of relators,
##  and the relator lengths.
##  <P/>
##  <Ref Func="SimplifiedFpGroup"/> returns a group isomorphic to
##  the given one  with a presentation which has been tried to simplify
##  via Tietze transformations.
##  <P/>
##  If the connection to the original group is important, then the operation
##  <Ref Attr="IsomorphismSimplifiedFpGroup"/> should be used instead.
##  <P/>
##  <Example><![CDATA[
##  gap> F6 := FreeGroup( 6, "G" );;
##  gap> G := F6 / [ F6.1^2, F6.2^2, F6.4*F6.6^-1, F6.5^2, F6.6^2,
##  > F6.1*F6.2^-1*F6.3, F6.1*F6.5*F6.3^-1, F6.2*F6.4^-1*F6.3,
##  > F6.3*F6.4*F6.5^-1, F6.1*F6.6*F6.3^-2, F6.3^4 ];;
##  gap> H := SimplifiedFpGroup( G );
##  <fp group on the generators [ G1, G3 ]>
##  gap> RelatorsOfFpGroup( H );
##  [ G1^2, (G1*G3^-1)^2, G3^4 ]
##  ]]></Example>
##  <P/>
##  In fact, the command
##  <P/>
##  <Log><![CDATA[
##  H := SimplifiedFpGroup( G );
##  ]]></Log>
##  <P/>
##  is an abbreviation of the command sequence
##  <P/>
##  <Log><![CDATA[
##  P := PresentationFpGroup( G, 0 );;
##  SimplifyPresentation( P );
##  H := FpGroupPresentation( P );
##  ]]></Log>
##  <P/>
##  which applies a rather simple-minded strategy of Tietze transformations
##  to the intermediate presentation <A>P</A>.
##  If, for some concrete group, the resulting presentation is unsatisfying,
##  then you should try a more sophisticated, interactive use of the
##  available Tietze transformation commands
##  (see <Ref Sect="Tietze Transformations"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SimplifiedFpGroup");


############################################################################
##
#F  TzCheckRecord
##
##  <ManSection>
##  <Func Name="TzCheckRecord" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzCheckRecord");


#############################################################################
##
#F  TzEliminate( <P>[, <gen>] )
#F  TzEliminate( <P>[, <n>] )
##
##  <#GAPDoc Label="TzEliminate">
##  <ManSection>
##  <Heading>TzEliminate</Heading>
##  <Func Name="TzEliminate" Arg='P[, gen]'
##   Label="for a presentation (and a generator)"/>
##  <Func Name="TzEliminate" Arg='P[, n]'
##   Label="for a presentation (and an integer)"/>
##
##  <Description>
##  tries to eliminate a generator from a presentation <A>P</A> via
##  Tietze transformations.
##  <P/>
##  Any relator which contains some generator just once can be used to
##  substitute that generator by a word in the remaining generators.
##  If such generators and relators exist, then
##  <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##  chooses a generator for which the product of its number of occurrences
##  and the length of the substituting word is minimal,
##  and then it eliminates this generator from the presentation,
##  provided that the resulting total length of the relators does not exceed
##  the associated Tietze option parameter <C>spaceLimit</C>
##  (see <Ref Sect="Tietze Options"/>). The default value of that parameter
##  is <Ref Var="infinity"/>, but you may alter it appropriately.
##  <P/>
##  If a generator <A>gen</A> has been specified,
##  <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##  eliminates it if possible, i. e. if there is a relator in which
##  <A>gen</A> occurs just once.
##  If no second argument has been specified,
##  <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##  eliminates some appropriate generator if possible and if the resulting
##  total length of the relators will not exceed the Tietze options parameter
##  <C>lengthLimit</C>.
##  <P/>
##  If an integer <A>n</A> has been specified,
##  <Ref Func="TzEliminate" Label="for a presentation (and an integer)"/>
##  tries to eliminate up to <A>n</A> generators.
##  Note that the calls <C>TzEliminate(<A>P</A>)</C> and
##  <C>TzEliminate(<A>P</A>,1)</C> are equivalent.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzEliminate");


#############################################################################
##
#F  TzEliminateFromTree( <P> )
##
##  <ManSection>
##  <Func Name="TzEliminateFromTree" Arg='P'/>
##
##  <Description>
##  <Ref Func="TzEliminateFromTree"/> eliminates the last Tietze generator.
##  If that generator cannot be isolated in any Tietze relator,
##  then its definition is taken from the tree and added as an additional
##  Tietze relator, extending the set of Tietze generators appropriately,
##  if necessary.
##  However, the elimination will not be performed if the resulting total
##  length of the relators cannot be guaranteed to not exceed the parameter
##  <C>lengthLimit</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzEliminateFromTree");


#############################################################################
##
#F  TzEliminateGen( <P>, <n> )
##
##  <ManSection>
##  <Func Name="TzEliminateGen" Arg='P, n'/>
##
##  <Description>
##  eliminates the Tietze generator <C>GeneratorsOfPresentation(P)[n]</C>
##  if possible, i. e. if that generator can be isolated  in some appropriate
##  Tietze relator.  However,  the elimination  will not be  performed if the
##  resulting total length of the relators cannot be guaranteed to not exceed
##  the parameter <C>lengthLimit</C>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzEliminateGen");


#############################################################################
##
#F  TzEliminateGen1( <P> )
##
##  <ManSection>
##  <Func Name="TzEliminateGen1" Arg='P'/>
##
##  <Description>
##  tries to  eliminate a  Tietze generator:  If there are
##  Tietze generators which occur just once in certain Tietze relators,  then
##  one of them is chosen  for which the product of the length of its minimal
##  defining word  and the  number of its  occurrences  is minimal.  However,
##  the elimination  will not be performed  if the resulting  total length of
##  the  relators   cannot  be  guaranteed   to  not  exceed   the  parameter
##  <C>lengthLimit</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzEliminateGen1");


#############################################################################
##
#F  TzEliminateGens( <P> [, <decode>] )
##
##  <ManSection>
##  <Func Name="TzEliminateGens" Arg='P [, decode]'/>
##
##  <Description>
##  <Ref Func="TzEliminateGens"/> repeatedly eliminates generators from the
##  presentation of the given group until at least one of the following
##  conditions is violated:
##  <P/>
##  <Enum>
##  <Item>
##     The current number of generators is not greater than the
##     parameter <C>generatorsLimit</C>.
##  </Item>
##  <Item>
##     The number of generators eliminated so far is less than
##      the parameter <C>eliminationsLimit</C>.
##  </Item>
##  <Item>
##     The total length of the relators has not yet grown to a percentage
##     greater than the parameter <C>expandLimit</C>.
##  </Item>
##  <Item>
##     The next elimination will not extend the total length to a value
##     greater than the parameter <C>lengthLimit</C>.
##  </Item>
##  </Enum>
##  <P/>
##  If a second argument has been specified, then it is assumed that we
##  are in the process of decoding a tree.
##  <P/>
##  If not, then the function will not eliminate any protected generators.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzEliminateGens");


#############################################################################
##
#F  TzFindCyclicJoins( <P> )
##
##  <#GAPDoc Label="TzFindCyclicJoins">
##  <ManSection>
##  <Func Name="TzFindCyclicJoins" Arg='P'/>
##
##  <Description>
##  searches for  power and commutator relators in order
##  to find  pairs of generators  which  generate a  common  cyclic subgroup.
##  It uses these pairs to introduce new relators,  but it does not introduce
##  any new generators as is done by <Ref Func="TzSubstituteCyclicJoins"/>.
##  <P/>
##  More precisely:
##  <Ref Func="TzFindCyclicJoins"/> searches for pairs of generators <M>a</M>
##  and <M>b</M> such that (possibly after inverting or conjugating some
##  relators) the set of relators contains the commutator <M>[a,b]</M>,
##  a power <M>a^n</M>, and a product of the form <M>a^s b^t</M>
##  with <M>s</M> prime to <M>n</M>.
##  For each such pair, <Ref Func="TzFindCyclicJoins"/> uses the
##  Euclidean algorithm to express <M>a</M> as a power of <M>b</M>,
##  and then it eliminates <M>a</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzFindCyclicJoins");


############################################################################
##
#F  TzGeneratorExponents(<P>)
##
##  <ManSection>
##  <Func Name="TzGeneratorExponents" Arg='P'/>
##
##  <Description>
##  <Ref Func="TzGeneratorExponents"/> tries to find exponents for the
##  Tietze generators and returns them in a list parallel to the list of the
##  generators.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzGeneratorExponents");


#############################################################################
##
#F  TzGo( <P>[, <silent>] )
##
##  <#GAPDoc Label="TzGo">
##  <ManSection>
##  <Func Name="TzGo" Arg='P[, silent]'/>
##
##  <Description>
##  automatically performs suitable Tietze transformations of the given
##  presentation <A>P</A>. It is perhaps the most convenient one among the
##  interactive Tietze transformation commands. It offers a kind of default
##  strategy which, in general, saves you from explicitly calling the
##  lower-level commands it involves.
##  <P/>
##  If <A>silent</A> is specified as <K>true</K>,
##  the printing of the status line by <Ref Func="TzGo"/> is suppressed
##  if the Tietze option <C>printLevel</C>
##  (see <Ref Sect="Tietze Options"/>) has a value less than <M>2</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzGo");

############################################################################
##
#F  SimplifyPresentation(<P>)
##
##  <#GAPDoc Label="SimplifyPresentation">
##  <ManSection>
##  <Func Name="SimplifyPresentation" Arg='P'/>
##
##  <Description>
##  <Ref Func="SimplifyPresentation"/> is a synonym for <Ref Func="TzGo"/>.
##  <Example><![CDATA[
##  gap> F2 := FreeGroup( "a", "b" );;
##  gap> G := F2 / [ F2.1^9, F2.2^2, (F2.1*F2.2)^4, (F2.1^2*F2.2)^3 ];;
##  gap> a := G.1;; b := G.2;;
##  gap> H := Subgroup( G, [ (a*b)^2, (a^-1*b)^2 ] );;
##  gap> Index( G, H );
##  408
##  gap> P := PresentationSubgroup( G, H );
##  <presentation with 8 gens and 36 rels of total length 111>
##  gap> PrimaryGeneratorWords( P );
##  [ b, a*b*a ]
##  gap> TzOptions( P ).protected := 2;
##  2
##  gap> TzOptions( P ).printLevel := 2;
##  2
##  gap> SimplifyPresentation( P );
##  #I  eliminating _x7 = _x5^-1
##  #I  eliminating _x5 = _x4
##  #I  eliminating _x18 = _x3
##  #I  eliminating _x8 = _x3
##  #I  there are 4 generators and 8 relators of total length 21
##  #I  there are 4 generators and 7 relators of total length 18
##  #I  eliminating _x4 = _x3^-1*_x2^-1
##  #I  eliminating _x3 = _x2*_x1^-1
##  #I  there are 2 generators and 4 relators of total length 14
##  #I  there are 2 generators and 4 relators of total length 13
##  #I  there are 2 generators and 3 relators of total length 9
##  gap> TzPrintRelators( P );
##  #I  1. _x1^2
##  #I  2. _x2^3
##  #I  3. (_x2*_x1)^2
##  ]]></Example>
##  <P/>
##  Roughly speaking, <Ref Func="TzGo"/> consists of a loop over a
##  procedure which involves two phases: In the <E>search phase</E> it calls
##  <Ref Func="TzSearch"/> and <Ref Func="TzSearchEqual"/> described below
##  which try to reduce the relator lengths by substituting common subwords
##  of relators, in the <E>elimination phase</E> it calls the command
##  <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##  described below (or, more precisely, a subroutine of
##  <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##  in order to save some administrative overhead) which tries to eliminate
##  generators that can be expressed as words in the remaining generators.
##  <P/>
##  If <Ref Func="TzGo"/> succeeds in reducing the number of generators,
##  the number of relators, or the total length of all relators, it
##  displays the new status before returning (provided that you did not set
##  the print level to zero). However, it does not provide any output if all
##  these three values have remained unchanged, even if the command
##  <Ref Func="TzSearchEqual"/> involved has changed the presentation
##  such that another call of <Ref Func="TzGo"/> might provide further
##  progress.
##  Hence, in such a case it makes sense to repeat the call of the command
##  for several times (or to call the command <Ref Func="TzGoGo"/> instead).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
SimplifyPresentation := TzGo;


############################################################################
##
#F  TzGoGo(<P>)
##
##  <#GAPDoc Label="TzGoGo">
##  <ManSection>
##  <Func Name="TzGoGo" Arg='P'/>
##
##  <Description>
##  calls the command <Ref Func="TzGo"/> again and again until it does not
##  reduce the presentation any more.
##  <P/>
##  The result of the Tietze transformations can be affected substantially by
##  the options parameters (see <Ref Sect="Tietze Options"/>).
##  To demonstrate the effect of the <C>eliminationsLimit</C> parameter,
##  we will give an example in which we handle a subgroup of index 240 in a
##  group of order 40320 given by a presentation due to B.&nbsp;H. Neumann.
##  First we construct a presentation of the subgroup, and then we apply to
##  it the command <Ref Func="TzGoGo"/> for different
##  values of the parameter <C>eliminationsLimit</C>
##  (including the default value 100). In fact, we also alter the
##  <C>printLevel</C> parameter, but this is only done in order to suppress
##  most of the output.  In all cases the resulting presentations cannot be
##  improved any more by applying the command <Ref Func="TzGoGo"/> again,
##  i.e., they are the best results which we can get without substituting new
##  generators.
##  <P/>
##  <Example><![CDATA[
##  gap> F3 := FreeGroup( "a", "b", "c" );;
##  gap> G := F3 / [ F3.1^3, F3.2^3, F3.3^3, (F3.1*F3.2)^5,
##  > (F3.1^-1*F3.2)^5, (F3.1*F3.3)^4, (F3.1*F3.3^-1)^4,
##  > F3.1*F3.2^-1*F3.1*F3.2*F3.3^-1*F3.1*F3.3*F3.1*F3.3^-1,
##  > (F3.2*F3.3)^3, (F3.2^-1*F3.3)^4 ];;
##  gap> a := G.1;; b := G.2;; c := G.3;;
##  gap> H := Subgroup( G, [ a, c ] );;
##  gap> for i in [ 61, 62, 63, 90, 97 ] do
##  > Pi := PresentationSubgroup( G, H );
##  > TzOptions( Pi ).eliminationsLimit := i;
##  > Print("#I eliminationsLimit set to ",i,"\n");
##  > TzOptions( Pi ).printLevel := 0;
##  > TzGoGo( Pi );
##  > TzPrintStatus( Pi );
##  > od;
##  #I eliminationsLimit set to 61
##  #I  there are 2 generators and 104 relators of total length 7012
##  #I eliminationsLimit set to 62
##  #I  there are 2 generators and 7 relators of total length 56
##  #I eliminationsLimit set to 63
##  #I  there are 3 generators and 97 relators of total length 5998
##  #I eliminationsLimit set to 90
##  #I  there are 3 generators and 11 relators of total length 68
##  #I eliminationsLimit set to 97
##  #I  there are 4 generators and 109 relators of total length 3813
##  ]]></Example>
##  <P/>
##  Similarly, we demonstrate the influence of the <C>saveLimit</C> parameter
##  by just continuing the preceding example for some different values of the
##  <C>saveLimit</C> parameter (including its default value 10), but without
##  changing the <C>eliminationsLimit</C> parameter which keeps its default
##  value 100.
##  <P/>
##  <Example><![CDATA[
##  gap> for i in [ 7 .. 11 ] do
##  > Pi := PresentationSubgroup( G, H );
##  > TzOptions( Pi ).saveLimit := i;
##  > Print( "#I saveLimit set to ", i, "\n" );
##  > TzOptions( Pi ).printLevel := 0;
##  > TzGoGo( Pi );
##  > TzPrintStatus( Pi );
##  > od;
##  #I saveLimit set to 7
##  #I  there are 3 generators and 99 relators of total length 2713
##  #I saveLimit set to 8
##  #I  there are 2 generators and 103 relators of total length 11982
##  #I saveLimit set to 9
##  #I  there are 2 generators and 6 relators of total length 41
##  #I saveLimit set to 10
##  #I  there are 3 generators and 118 relators of total length 13713
##  #I saveLimit set to 11
##  #I  there are 3 generators and 11 relators of total length 58
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzGoGo");

############################################################################
##
#F  TzGoElim(<P>,<len>)
##
##  <#GAPDoc Label="TzGoElim">
##  <ManSection>
##  <Func Name="TzGoElim" Arg='P,len'/>
##
##  <Description>
##  A variant for the TzGoXXX functions for the MTC. Tries to reduce down to
##  <C>len</C> generators and does not try so hard to reduce.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzGoElim");


#############################################################################
##
#F  TzHandleLength1Or2Relators( <P> )
##
##  <ManSection>
##  <Func Name="TzHandleLength1Or2Relators" Arg='P'/>
##
##  <Description>
##  <Ref Func="TzHandleLength1Or2Relators"/>  searches for  relators of length 1 or 2 and
##  performs suitable Tietze transformations for each of them:
##  <P/>
##  Generators occurring in relators of length 1 are eliminated.
##  <P/>
##  Generators  occurring  in square relators  of length 2  are marked  to be
##  involutions.
##  <P/>
##  If a relator  of length 2  involves two  different  generators,  then the
##  generator with the  larger number is substituted  by the other one in all
##  relators and finally eliminated from the set of generators.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzHandleLength1Or2Relators");

#############################################################################
##
#F  GeneratorsOfPresentation(<P>)
##
##  <#GAPDoc Label="GeneratorsOfPresentation">
##  <ManSection>
##  <Func Name="GeneratorsOfPresentation" Arg='P'/>
##
##  <Description>
##  returns a list of free generators that is a shallow copy
##  (see <Ref Oper="ShallowCopy"/>) of the current
##  generators of the presentation <A>P</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("GeneratorsOfPresentation");

#############################################################################
##
#F  TzInitGeneratorImages( <P> )
##
##  <#GAPDoc Label="TzInitGeneratorImages">
##  <ManSection>
##  <Func Name="TzInitGeneratorImages" Arg='P'/>
##
##  <Description>
##  expects <A>P</A> to be a presentation. It defines the current generators
##  to be the <Q>old generators</Q> of <A>P</A> and initializes the
##  (pre)image tracing.
##  See <Ref Func="TzImagesOldGens"/> and <Ref Func="TzPreImagesNewGens"/>
##  for details.
##  <P/>
##  You can reinitialize the tracing of the generator images at any later
##  state by just calling the function <Ref Func="TzInitGeneratorImages"/>
##  again.
##  <P/>
##  Note:
##  A subsequent call of the function <Ref Func="DecodeTree"/> will imply
##  that the images and preimages are deleted and reinitialized
##  after decoding the tree.
##  <P/>
##  Moreover, if you introduce a new generator by calling the function
##  <Ref Func="AddGenerator"/> described
##  in Section <Ref Sect="Changing Presentations"/>, this
##  new generator cannot be traced in the old generators.
##  Therefore <Ref Func="AddGenerator"/> will terminate the tracing of the
##  generator images and preimages and delete the respective lists
##  whenever it is called.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzInitGeneratorImages");

#############################################################################
##
#F  OldGeneratorsOfPresentation(<P>)
##
##  <#GAPDoc Label="OldGeneratorsOfPresentation">
##  <ManSection>
##  <Func Name="OldGeneratorsOfPresentation" Arg='P'/>
##
##  <Description>
##  assumes that <A>P</A> is a presentation for which the generator images
##  and preimages are being traced under Tietze transformations. It
##  returns the list of old generators of <A>P</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OldGeneratorsOfPresentation");

#############################################################################
##
#F  TzImagesOldGens(<P>)
##
##  <#GAPDoc Label="TzImagesOldGens">
##  <ManSection>
##  <Func Name="TzImagesOldGens" Arg='P'/>
##
##  <Description>
##  assumes that <A>P</A> is a presentation for which the generator images
##  and preimages are being traced under Tietze transformations. It
##  returns a list <M>l</M> of words in the (current)
##  <Ref Func="GeneratorsOfPresentation"/> value of <A>P</A>
##  such that the <M>i</M>-th word
##  <M>l[i]</M> represents the <M>i</M>-th old generator of <A>P</A>, i. e.,
##  the <M>i</M>-th entry of the <Ref Func="OldGeneratorsOfPresentation"/>
##  value of <A>P</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzImagesOldGens");

#############################################################################
##
#F  TzPreImagesNewGens(<P>)
##
##  <#GAPDoc Label="TzPreImagesNewGens">
##  <ManSection>
##  <Func Name="TzPreImagesNewGens" Arg='P'/>
##
##  <Description>
##  assumes that <A>P</A> is a presentation for which the generator images
##  and preimages are being traced under Tietze transformations.
##  It returns a list <M>l</M> of words in the old generators of <A>P</A>
##  (the <Ref Func="OldGeneratorsOfPresentation"/> value of <A>P</A>)
##  such that the <M>i</M>-th entry of <M>l</M>
##  represents the <M>i</M>-th (current) generator of <A>P</A>
##  (the <Ref Func="GeneratorsOfPresentation"/> value of <A>P</A>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPreImagesNewGens");


#############################################################################
##
#F  TzMostFrequentPairs( <P>, <n> )
##
##  <ManSection>
##  <Func Name="TzMostFrequentPairs" Arg='P, n'/>
##
##  <Description>
##  <Ref Func="TzMostFrequentPairs"/> returns a list describing the <A>n</A>
##  most frequently occurring relator subwords of the form <M>g_1 g_2</M>,
##  where <M>g_1</M> and <M>g_2</M> are different generators or their
##  inverses.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzMostFrequentPairs");


############################################################################
##
#F  TzNewGenerator(<P>)
##
##  <#GAPDoc Label="TzNewGenerator">
##  <ManSection>
##  <Func Name="TzNewGenerator" Arg='P'/>
##
##  <Description>
##  is an internal function which defines a new abstract generator and
##  adds it to the presentation <A>P</A>.
##  It is called by <Ref Func="AddGenerator"/> and
##  by several Tietze transformation commands. As it does not know which
##  global lists have to be kept consistent, you should not call it.
##  Instead, you should call the function <Ref Func="AddGenerator"/>,
##  if needed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzNewGenerator");


#############################################################################
##
#F  TzPrint( <P>[, <list>] )
##
##  <#GAPDoc Label="TzPrint">
##  <ManSection>
##  <Func Name="TzPrint" Arg='P[, list]'/>
##
##  <Description>
##  prints the current generators of the given presentation <A>P</A>,
##  and prints the relators of <A>P</A> as Tietze words (without converting
##  them back to abstract words as the functions
##  <Ref Func="TzPrintRelators"/> and <Ref Func="TzPrintPresentation"/> do).
##  The optional second argument can be used to specify the numbers of the
##  relators to be printed.
##  Default: all relators are printed.
##  <Example><![CDATA[
##  gap> TzPrint( P );
##  #I  generators: [ f1, f2, f3 ]
##  #I  relators:
##  #I  1.  2  [ 3, 3 ]
##  #I  2.  4  [ 2, 2, 2, 2 ]
##  #I  3.  4  [ 2, 3, 2, 3 ]
##  #I  4.  5  [ 1, 1, 1, 1, 1 ]
##  #I  5.  5  [ 1, 1, 2, 1, -2 ]
##  #I  6.  8  [ 1, -2, -2, 3, 1, 3, -1, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrint");


#############################################################################
##
#F  TzPrintGeneratorImages(<P>)
##
##  <#GAPDoc Label="TzPrintGeneratorImages">
##  <ManSection>
##  <Func Name="TzPrintGeneratorImages" Arg='P'/>
##
##  <Description>
##  assumes that <A>P</A> is a presentation for which the generator images
##  and preimages are being traced under Tietze transformations. It
##  displays the preimages of the current generators as Tietze words in
##  the old generators, and the images of the old generators as Tietze
##  words in the current generators.
##  <Example><![CDATA[
##  gap> G := PerfectGroup( IsSubgroupFpGroup, 960, 1 );
##  A5 2^4
##  gap> P := PresentationFpGroup( G );
##  <presentation with 6 gens and 21 rels of total length 84>
##  gap> TzInitGeneratorImages( P );
##  gap> TzGo( P );
##  #I  there are 3 generators and 11 relators of total length 96
##  #I  there are 3 generators and 10 relators of total length 81
##  gap> TzPrintGeneratorImages( P );
##  #I  preimages of current generators as Tietze words in the old ones:
##  #I  1. [ 1 ]
##  #I  2. [ 2 ]
##  #I  3. [ 4 ]
##  #I  images of old generators as Tietze words in the current ones:
##  #I  1. [ 1 ]
##  #I  2. [ 2 ]
##  #I  3. [ 1, -2, 1, 3, 1, 2, 1 ]
##  #I  4. [ 3 ]
##  #I  5. [ -2, 1, 3, 1, 2 ]
##  #I  6. [ 1, 3, 1 ]
##  gap> gens := GeneratorsOfPresentation( P );
##  [ a, b, t ]
##  gap> oldgens := OldGeneratorsOfPresentation( P );
##  [ a, b, s, t, u, v ]
##  gap> TzImagesOldGens( P );
##  [ a, b, a*b^-1*a*t*a*b*a, t, b^-1*a*t*a*b, a*t*a ]
##  gap> for i in [ 1 .. Length( oldgens ) ] do
##  > Print( oldgens[i], " = ", TzImagesOldGens( P )[i], "\n" );
##  > od;
##  a = a
##  b = b
##  s = a*b^-1*a*t*a*b*a
##  t = t
##  u = b^-1*a*t*a*b
##  v = a*t*a
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintGeneratorImages");


#############################################################################
##
#F  TzPrintGenerators( <P>[, <list>] )
##
##  <#GAPDoc Label="TzPrintGenerators">
##  <ManSection>
##  <Func Name="TzPrintGenerators" Arg='P[, list]'/>
##
##  <Description>
##  prints the generators of the given Tietze presentation <A>P</A> together
##  with the number of their occurrences in the relators. The optional second
##  argument can be used to specify the numbers of the generators to be
##  printed. Default: all generators are printed.
##  <Example><![CDATA[
##  gap> G := Group( [ (1,2,3,4,5), (2,3,5,4), (1,6)(3,4) ], () );
##  Group([ (1,2,3,4,5), (2,3,5,4), (1,6)(3,4) ])
##  gap> P := PresentationViaCosetTable( G );
##  <presentation with 3 gens and 6 rels of total length 28>
##  gap> TzPrintGenerators( P );
##  #I  1.  f1   11 occurrences
##  #I  2.  f2   10 occurrences
##  #I  3.  f3   7 occurrences   involution
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintGenerators");


#############################################################################
##
#F  TzPrintLengths( <P> )
##
##  <#GAPDoc Label="TzPrintLengths">
##  <ManSection>
##  <Func Name="TzPrintLengths" Arg='P'/>
##
##  <Description>
##  prints just a list of all relator lengths of the given presentation
##  <A>P</A>.
##  <Example><![CDATA[
##  gap> TzPrintLengths( P );
##  [ 2, 4, 4, 5, 5, 8 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintLengths");

#############################################################################
##
#A  TzOptions(<P>)
##
##  <#GAPDoc Label="TzOptions">
##  <ManSection>
##  <Attr Name="TzOptions" Arg='P'/>
##
##  <Description>
##  is a record whose components direct the heuristics applied by the Tietze
##  transformation functions.
##  <P/>
##  You may alter the value of any of these Tietze options by just assigning
##  a new value to the respective record component.
##  <P/>
##  The following Tietze options are recognized by &GAP;:
##  <P/>
##  <List>
##  <Mark><C>protected</C>:</Mark>
##  <Item>
##    The first <C>protected</C> generators in a presentation <A>P</A> are
##    protected from being eliminated by the Tietze transformations
##    functions.  There are only  two exceptions:  The option
##    <C>protected</C>   is   ignored   by   the   functions
##    <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##    and <Ref Func="TzSubstitute" Label="for a presentation and a word"/>
##    because they explicitly specify the generator to be eliminated.
##    The default value of <C>protected</C> is 0.
##  </Item>
##  <Mark><C>eliminationsLimit</C>:</Mark>
##  <Item>
##    Whenever the elimination phase of the <Ref Func="TzGo"/> command is
##    entered for a presentation <A>P</A>,  then it  will eliminate at most
##    <C>eliminationsLimit</C> generators (except for further ones which
##    have turned out to  be trivial). Hence you may use  the
##    <C>eliminationsLimit</C> parameter as a break criterion for the
##    <Ref Func="TzGo"/> command. Note, however, that it is ignored by the
##    <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##    command. The default value of <C>eliminationsLimit</C> is 100.
##  </Item>
##  <Mark><C>expandLimit</C>:</Mark>
##  <Item>
##    Whenever the routine for eliminating more than 1 generator is
##    called for a presentation <A>P</A> by the
##    <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>
##    command or the elimination phase of the <Ref Func="TzGo"/> command,
##    then it saves the given total length of the relators,
##    and subsequently it checks the current total length against its value
##    before each elimination.
##    If the total length has increased to more than <C>expandLimit</C>
##    per cent of its original value, then the routine returns instead
##    of  eliminating another generator.
##    Hence you may use the <C>expandLimit</C> parameter as a break criterion
##    for the <Ref Func="TzGo"/> command.
##    The default value of <C>expandLimit</C> is 150.
##  </Item>
##  <Mark><C>generatorsLimit</C>:</Mark>
##  <Item>
##    Whenever the elimination phase of the <Ref Func="TzGo"/> command is
##    entered for a presentation <A>P</A> with <M>n</M> generators,
##    then it will eliminate at most <M>n - </M><C>generatorsLimit</C>
##    generators (except for generators which turn out to be trivial).
##    Hence you may use the <C>generatorsLimit</C> parameter as a break
##    criterion for the <Ref Func="TzGo"/> command.
##    The default value of <C>generatorsLimit</C> is 0.
##  </Item>
##  <Mark><C>lengthLimit</C>:</Mark>
##  <Item>
##    The Tietze transformation commands will never eliminate  a
##    generator of a presentation <A>P</A>, if they cannot exclude the
##    possibility that the resulting total length of the relators
##    exceeds the maximal &GAP; list length of <M>2^{31}-1</M> or the value
##    of the option <C>lengthLimit</C>.
##    The default value of <C>lengthLimit</C> is <M>2^{31}-1</M>.
##  </Item>
##  <Mark><C>loopLimit</C>:</Mark>
##  <Item>
##    Whenever the <Ref Func="TzGo"/> command is called for a presentation
##    <A>P</A>, then it will loop over at most <C>loopLimit</C> of its basic
##    steps. Hence you may use the <C>loopLimit</C> parameter as a break
##    criterion for  the <Ref Func="TzGo"/>  command. The  default value of
##    <C>loopLimit</C> is <Ref Var="infinity"/>.
##  </Item>
##  <Mark><C>printLevel</C>:</Mark>
##  <Item>
##    Whenever  Tietze transformation commands are called for  a
##    presentation <A>P</A> with <C>printLevel</C> <M>= 0</M>, they will not
##    provide any output except for error messages. If <C>printLevel</C>
##    <M>= 1</M>, they will display some reasonable amount of output which
##    allows you to watch the progress of the computation and to decide
##    about your next commands. In the case <C>printLevel</C> <M>= 2</M>, you
##    will get a much more generous amount of output. Finally, if
##    <C>printLevel</C> <M>= 3</M>, various messages on internal details will
##    be added. The default value of <C>printLevel</C> is 1.
##  </Item>
##  <Mark><C>saveLimit</C>:</Mark>
##  <Item>
##    Whenever the <Ref Func="TzSearch"/> command has finished its main loop
##    over all relators of a presentation <A>P</A>, then it checks whether
##    during this loop the total length of the relators has been reduced by
##    at least <C>saveLimit</C> per cent. If this is the case, then
##    <Ref Func="TzSearch"/> repeats its procedure instead of returning.
##    Hence you may use the <C>saveLimit</C> parameter as a break criterion
##    for the <Ref Func="TzSearch"/> command and, in particular,
##    for the search phase of the <Ref Func="TzGo"/> command.
##    The default value of <C>saveLimit</C> is 10.
##  </Item>
##  <Mark><C>searchSimultaneous</C>:</Mark>
##  <Item>
##    Whenever the <Ref Func="TzSearch"/> or the <Ref Func="TzSearchEqual"/>
##    command is called for a presentation <A>P</A>, then it is allowed to
##    handle up to <C>searchSimultaneous</C> short relators simultaneously
##    (see the description of the <Ref Func="TzSearch"/> command for more
##    details).
##    The choice of this parameter may heavily influence the performance as
##    well as the result of the <Ref Func="TzSearch"/> and the
##    <Ref Func="TzSearchEqual"/> commands and hence also of the search phase
##    of the <Ref Func="TzGo"/> command.
##    The default value of <C>searchSimultaneous</C> is 20.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("TzOptions",IsPresentation,"mutable");


#############################################################################
##
#F  TzPrintOptions( <P> )
##
##  <#GAPDoc Label="TzPrintOptions">
##  <ManSection>
##  <Func Name="TzPrintOptions" Arg='P'/>
##
##  <Description>
##  prints the current values of the Tietze options of the presentation
##  <A>P</A>.
##  <Example><![CDATA[
##  gap> TzPrintOptions( P );
##  #I  protected          = 0
##  #I  eliminationsLimit  = 100
##  #I  expandLimit        = 150
##  #I  generatorsLimit    = 0
##  #I  lengthLimit        = 2147483647
##  #I  loopLimit          = infinity
##  #I  printLevel         = 1
##  #I  saveLimit          = 10
##  #I  searchSimultaneous = 20
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintOptions");


#############################################################################
##
#F  TzPrintPairs( <P> [,<n>] )
##
##  <#GAPDoc Label="TzPrintPairs">
##  <ManSection>
##  <Func Name="TzPrintPairs" Arg='P [,n]'/>
##
##  <Description>
##  prints the <A>n</A> most often occurring relator subwords of the form
##  <M>a b</M>,
##  where <M>a</M> and <M>b</M> are different generators or inverses of
##  generators, together with the number of their occurrences. The default
##  value of <A>n</A> is 10.
##  A value <A>n</A> = 0 is interpreted as <Ref Var="infinity"/>.
##  <P/>
##  The function <Ref Func="TzPrintPairs"/> is useful in the context of
##  Tietze transformations which introduce new generators by substituting
##  words in the current generators
##  (see <Ref Sect="Tietze Transformations that introduce new Generators"/>).
##  It gives some evidence for an appropriate choice of
##  a word of length 2 to be substituted.
##  <Example><![CDATA[
##  gap> TzPrintPairs( P, 3 );
##  #I  1.  3  occurrences of  f2^-1 * f3
##  #I  2.  2  occurrences of  f2 * f3
##  #I  3.  2  occurrences of  f1^-1 * f3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintPairs");


############################################################################
##
#F  TzPrintPresentation(<P>)
##
##  <#GAPDoc Label="TzPrintPresentation">
##  <ManSection>
##  <Func Name="TzPrintPresentation" Arg='P'/>
##
##  <Description>
##  prints the generators and the relators of a Tietze presentation.
##  In fact, it is an abbreviation for the successive call of the three
##  commands <Ref Func="TzPrintGenerators"/>,
##  <Ref Func="TzPrintRelators"/>, and <Ref Func="TzPrintStatus"/>,
##  each with the presentation <A>P</A> as only argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintPresentation");


############################################################################
##
#F  TzPrintRelators(<P>[, <list>])
##
##  <#GAPDoc Label="TzPrintRelators">
##  <ManSection>
##  <Func Name="TzPrintRelators" Arg='P[, list]'/>
##
##  <Description>
##  prints the relators of the given  Tietze presentation <A>P</A>.
##  The optional second argument <A>list</A> can be used to specify the
##  numbers of the relators to be printed.
##  Default: all relators are printed.
##  <Example><![CDATA[
##  gap> TzPrintRelators( P );
##  #I  1. f3^2
##  #I  2. f2^4
##  #I  3. (f2*f3)^2
##  #I  4. f1^5
##  #I  5. f1^2*f2*f1*f2^-1
##  #I  6. f1*f2^-2*f3*f1*f3*f1^-1*f3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintRelators");


#############################################################################
##
#F  TzPrintStatus( <P>[, <norepeat>] )
##
##  <#GAPDoc Label="TzPrintStatus">
##  <ManSection>
##  <Func Name="TzPrintStatus" Arg='P[, norepeat]'/>
##
##  <Description>
##  is an internal function which is used by the Tietze transformation
##  routines to print the number of generators, the number of relators,
##  and the total length of all relators in the given Tietze presentation
##  <A>P</A>.
##  If <A>norepeat</A> is specified as <K>true</K>, the printing is
##  suppressed if none of the three values has changed since the last call.
##  <Example><![CDATA[
##  gap> TzPrintStatus( P );
##  #I  there are 3 generators and 6 relators of total length 28
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzPrintStatus");


############################################################################
##
#f  TzRecoverFromFile
##
#T DeclareGlobalFunction("TzRecoverFromFile");
#T up to now no function is installed


############################################################################
##
#F  TzRelator( <P>, <word> )
##
##  <ManSection>
##  <Func Name="TzRelator" Arg='P, word'/>
##
##  <Description>
##  <Ref Func="TzRelator"/> assumes <A>word</A> to be an abstract word in the
##  group generators associated to the given presentation, and converts it to
##  a Tietze relator, i.e. a free and cyclically reduced Tietze word.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzRelator");


############################################################################
##
#F  TzRemoveGenerators(<P>)
##
##  <ManSection>
##  <Func Name="TzRemoveGenerators" Arg='P'/>
##
##  <Description>
##  <C>TzRemoveGenerators</C> deletes the redundant Tietze generators and
##  renumbers the non-redundant ones accordingly. The redundant generators
##  are assumed to be marked in the inverses list by an entry
##  <C>invs[numgens+1-i] &lt;> i</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzRemoveGenerators");


############################################################################
##
#F  TzSearch(<P>)
##
##  <#GAPDoc Label="TzSearch">
##  <ManSection>
##  <Func Name="TzSearch" Arg='P'/>
##
##  <Description>
##  searches for relator subwords which, in some relator, have a complement
##  of shorter length and which occur in other relators, too, and uses them
##  to reduce these other relators.
##  <P/>
##  The idea is to find pairs of relators <M>r_1</M> and <M>r_2</M> of length
##  <M>l_1</M> and <M>l_2</M>, respectively,
##  such that <M>l_1 \leq l_2</M> and <M>r_1</M> and <M>r_2</M>
##  coincide (possibly after inverting or conjugating one of them) in some
##  maximal subword <M>w</M> of length greater than <M>l_1/2</M>,
##  and then to substitute each copy of <M>w</M> in <M>r_2</M> by the inverse
##  complement of <M>w</M> in <M>r_1</M>.
##  <P/>
##  Two of the Tietze option parameters which are listed in section
##  <Ref Sect="Tietze Options"/> may strongly influence the performance and
##  the results of the command <Ref Func="TzSearch"/>.
##  These are the parameters <C>saveLimit</C> and <C>searchSimultaneous</C>.
##  The first of them has the following effect:
##  <P/>
##  When <Ref Func="TzSearch"/> has finished its main loop over all relators,
##  then, in general, there are relators which have changed and hence should
##  be handled again in another run through the whole procedure. However,
##  experience shows that it really does not pay to continue this way until
##  no more relators change.
##  Therefore, <Ref Func="TzSearch"/> starts a new loop only if
##  the loop just finished has reduced the total length of the relators by at
##  least <C>saveLimit</C> per cent.
##  <P/>
##  The default value of <C>saveLimit</C> is 10 per cent.
##  <P/>
##  To understand the effect of the option <C>searchSimultaneous</C>, we
##  have to look in more detail at how <Ref Func="TzSearch"/> proceeds:
##  <P/>
##  First, it sorts the list of relators by increasing lengths. Then it
##  performs a loop over this list. In each step of this loop, the current
##  relator is treated as <E>short relator</E> <M>r_1</M>, and a subroutine
##  is called which loops over the succeeding relators,
##  treating them as <E>long relators</E> <M>r_2</M> and performing the
##  respective comparisons and substitutions.
##  <P/>
##  As this subroutine performs a very expensive process, it has been
##  implemented as a C routine in the &GAP; kernel. For the given relator
##  <M>r_1</M> of length <M>l_1</M> it first determines the
##  <E>minimal match length</E> <M>l</M> which is <M>l_1/2+1</M>,
##  if <M>l_1</M> is even, or <M>(l_1+1)/2</M>, otherwise.
##  Then it builds up a hash list for all subwords of length <M>l</M>
##  occurring in the conjugates of <M>r_1</M> or <M>r_1^{{-1}}</M>,
##  and finally it loops
##  over all long relators <M>r_2</M> and compares the hash values of their
##  subwords of length <M>l</M> against this list.
##  A comparison of subwords which is much more expensive is only done if a
##  hash match has been found.
##  <P/>
##  To improve the efficiency of this process we allow the subroutine to
##  handle several short relators simultaneously provided that they have the
##  same minimal match length.  If, for example, it handles <M>n</M> short
##  relators simultaneously, then you save <M>n - 1</M> loops over the long
##  relators <M>r_2</M>, but you pay for it by additional fruitless subword
##  comparisons. In general, you will not get the best performance by always
##  choosing the maximal possible number of short relators to be handled
##  simultaneously. In fact, the optimal choice of the number will depend on
##  the concrete presentation under investigation. You can use the parameter
##  <C>searchSimultaneous</C> to prescribe an upper bound for the number of
##  short relators to be handled simultaneously.
##  <P/>
##  The default value of <C>searchSimultaneous</C> is 20.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzSearch");


############################################################################
##
#F  TzSearchEqual(<P>)
##
##  <#GAPDoc Label="TzSearchEqual">
##  <ManSection>
##  <Func Name="TzSearchEqual" Arg='P'/>
##
##  <Description>
##  searches for Tietze relator subwords which, in some relator, have a
##  complement of equal length and which occur in other relators, too, and
##  uses them to modify these other relators.
##  <P/>
##  The idea is to find pairs of relators <M>r_1</M> and <M>r_2</M> of length
##  <M>l_1</M> and <M>l_2</M>, respectively, such that <M>l_1</M> is even,
##  <M>l_1 \leq l_2</M>, and <M>r_1</M> and <M>r_2</M> coincide (possibly
##  after inverting or conjugating one of them) in some maximal subword
##  <M>w</M> of length at least <M>l_1/2</M>.
##  Let <M>l</M> be the length of <M>w</M>. Then, if <M>l > l_1/2</M>,
##  the pair is handled as in <Ref Func="TzSearch"/>.
##  Otherwise, if <M>l = l_1/2</M>, then <Ref Func="TzSearchEqual"/>
##  substitutes each copy of <M>w</M> in <M>r_2</M> by the inverse complement
##  of <M>w</M> in <M>r_1</M>.
##  <P/>
##  The Tietze option parameter <C>searchSimultaneous</C> is used by
##  <Ref Func="TzSearchEqual"/> in the same way as described for
##  <Ref Func="TzSearch"/>. However, <Ref Func="TzSearchEqual"/> does
##  not use the parameter <C>saveLimit</C>:
##  The loop over the relators is executed exactly once.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzSearchEqual");


############################################################################
##
#F  TzSort(<P>)
##
##  <#GAPDoc Label="TzSort">
##  <ManSection>
##  <Func Name="TzSort" Arg='P'/>
##
##  <Description>
##  sorts the relators of the given presentation <A>P</A> by increasing
##  lengths.
##  There is no particular ordering defined for the relators of equal length.
##  Note that <Ref Func="TzSort"/> does not return a new object.
##  It changes the given presentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzSort");


#############################################################################
##
#F  TzSubstitute( <P>, <word> )
#F  TzSubstitute( <P>[, <n>[, <eliminate>]] )
##
##  <#GAPDoc Label="TzSubstitute">
##  <ManSection>
##  <Heading>TzSubstitute</Heading>
##  <Func Name="TzSubstitute" Arg='P, word'
##   Label="for a presentation and a word"/>
##  <Func Name="TzSubstitute" Arg='P[, n[, eliminate]]'
##   Label="for a presentation (and an integer and 0/1/2)"/>
##
##  <Description>
##  In the first form
##  <Ref Func="TzSubstitute" Label="for a presentation and a word"/> expects
##  <A>P</A> to be a presentation and <A>word</A> to be either an abstract
##  word or a Tietze word in the generators of <A>P</A>.
##  It substitutes the given word as a new generator of <A>P</A>.
##  This is done as follows:
##  First, <Ref Func="TzSubstitute" Label="for a presentation and a word"/>
##  creates a new abstract generator, <M>g</M> say, and adds it to the
##  presentation, then it adds a new relator
##  <M>g^{{-1}} \cdot <A>word</A></M>.
##  <P/>
##  In its second form,
##  <Ref Func="TzSubstitute" Label="for a presentation (and an integer and 0/1/2)"/>
##  substitutes a squarefree word of length 2 as a new generator and then
##  eliminates a generator from the extended generator list.
##  We will describe this process in more detail below.
##  <P/>
##  The parameters <A>n</A> and <A>eliminate</A> are optional.
##  If you specify arguments for them, then <A>n</A> is expected to be a
##  positive integer, and <A>eliminate</A> is expected to be 0, 1, or 2.
##  The default values are <A>n</A> <M>= 1</M> and
##  <A>eliminate</A> <M>= 0</M>.
##  <P/>
##  <Ref Func="TzSubstitute" Label="for a presentation (and an integer and 0/1/2)"/>
##  first determines the <A>n</A> most frequently occurring
##  relator subwords of the form <M>g_1 g_2</M>,
##  where <M>g_1</M> and <M>g_2</M> are different generators or their
##  inverses, and sorts them by decreasing numbers of occurrences.
##  <P/>
##  Let <M>a b</M> be the last word in that list, and let <M>i</M> be the
##  smallest positive integer which has not yet been used as a generator
##  number in the presentation <A>P</A> so far.
##  <Ref Func="TzSubstitute" Label="for a presentation (and an integer and 0/1/2)"/>
##  defines a new abstract generator <M>x_i</M> named <C>"_x<A>i</A>"</C> and
##  adds it to <A>P</A> (see <Ref Func="AddGenerator"/>).
##  Then it adds the word <M>x_i^{{-1}} a b</M> as a new relator to <A>P</A>
##  and replaces all occurrences of <M>a b</M> in the relators by <M>x_i</M>.
##  Finally, it eliminates some suitable generator from <A>P</A>.
##  <P/>
##  The choice of the generator to be eliminated depends on the actual
##  value of the parameter <A>eliminate</A>:
##  <P/>
##  If <A>eliminate</A> is zero,
##  <Ref Func="TzSubstitute" Label="for a presentation (and an integer and 0/1/2)"/>
##  just calls the function
##  <Ref Func="TzEliminate" Label="for a presentation (and a generator)"/>.
##  So it may happen that it is the just introduced generator <M>x_i</M>
##  which now is deleted again so that you don't get any
##  remarkable progress in simplifying your presentation.
##  On the first glance this does not look reasonable,
##  but it is a consequence of the request that a call of
##  <Ref Func="TzSubstitute" Label="for a presentation (and an integer and 0/1/2)"/>
##  with <A>eliminate</A> = 0 must not increase the total length of the
##  relators.
##  <P/>
##  Otherwise, if <A>eliminate</A> is 1 or 2,
##  <Ref Func="TzSubstitute" Label="for a presentation (and an integer and 0/1/2)"/>
##  eliminates the respective factor of the substituted word <M>a b</M>,
##  i. e., it eliminates <M>a</M> if <A>eliminate</A> = 1 or <M>b</M> if
##  <A>eliminate</A> = 2.
##  In this case, it may happen that the total length of the relators
##  increases, but sometimes such an intermediate extension is the only way
##  to finally reduce a given presentation.
##  <P/>
##  There is still another property of the command
##  <Ref Func="TzSubstitute" Label="for a presentation and a word"/> which
##  should be mentioned.
##  If, for instance, <C>word</C> is an abstract word, a call
##  <P/>
##  <Log><![CDATA[
##  TzSubstitute( P, word );
##  ]]></Log>
##  <P/>
##  is more or less equivalent to
##  <P/>
##  <Log><![CDATA[
##  AddGenerator( P );
##  g := GeneratorsOfPresentation(P)[Length(GeneratorsOfPresentation(P))];
##  AddRelator( P, g^-1 * word );
##  ]]></Log>
##  <P/>
##  However, there is a difference: If you are tracing generator images and
##  preimages of <A>P</A> through the Tietze transformations applied to
##  <A>P</A> (see
##  <Ref Sect="Tracing generator images through Tietze transformations"/>),
##  then <Ref Func="TzSubstitute" Label="for a presentation and a word"/>,
##  as a Tietze transformation of <A>P</A>, will update and save the
##  respective lists, whereas a call of the function
##  <Ref Func="AddGenerator"/>
##  (which does not perform a Tietze transformation) will delete these lists
##  and hence terminate the tracing.
##  <P/>
##  <Example><![CDATA[
##  gap> G := PerfectGroup( IsSubgroupFpGroup, 960, 1 );
##  A5 2^4
##  gap> P := PresentationFpGroup( G );
##  <presentation with 6 gens and 21 rels of total length 84>
##  gap> GeneratorsOfPresentation( P );
##  [ a, b, s, t, u, v ]
##  gap> TzGoGo( P );
##  #I  there are 3 generators and 10 relators of total length 81
##  #I  there are 3 generators and 10 relators of total length 80
##  gap> TzPrintGenerators( P );
##  #I  1.  a   31 occurrences   involution
##  #I  2.  b   26 occurrences
##  #I  3.  t   23 occurrences   involution
##  gap> a := GeneratorsOfPresentation( P )[1];;
##  gap> b := GeneratorsOfPresentation( P )[2];;
##  gap> TzSubstitute( P, a*b );
##  #I  now the presentation has 4 generators, the new generator is _x7
##  #I  substituting new generator _x7 defined by a*b
##  #I  there are 4 generators and 11 relators of total length 83
##  gap> TzGo( P );
##  #I  there are 3 generators and 10 relators of total length 74
##  gap> TzPrintGenerators( P );
##  #I  1.  a   23 occurrences   involution
##  #I  2.  t   23 occurrences   involution
##  #I  3.  _x7   28 occurrences
##  ]]></Example>
##  <P/>
##  As an example of an application of the command
##  <Ref Func="TzSubstitute" Label="for a presentation and a word"/>
##  in its second
##  form we handle a subgroup of index 266 in the Janko group <M>J_1</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> F2 := FreeGroup( "a", "b" );;
##  gap> J1 := F2 / [ F2.1^2, F2.2^3, (F2.1*F2.2)^7,
##  > Comm(F2.1,F2.2)^10, Comm(F2.1,F2.2^-1*(F2.1*F2.2)^2)^6 ];;
##  gap> a := J1.1;; b := J1.2;;
##  gap> H := Subgroup ( J1, [ a, b^(a*b*(a*b^-1)^2) ] );;
##  gap> P := PresentationSubgroup( J1, H );
##  <presentation with 23 gens and 82 rels of total length 530>
##  gap> TzGoGo( P );
##  #I  there are 3 generators and 47 relators of total length 1368
##  #I  there are 2 generators and 46 relators of total length 3773
##  #I  there are 2 generators and 46 relators of total length 2570
##  gap> TzGoGo( P );
##  #I  there are 2 generators and 46 relators of total length 2568
##  gap> TzGoGo( P );
##  ]]></Example>
##  <P/>
##  Here we do not get any more progress without substituting a new
##  generator.
##  <P/>
##  <Example><![CDATA[
##  gap> TzSubstitute( P );
##  #I  substituting new generator _x28 defined by _x6*_x23^-1
##  #I  eliminating _x28 = _x6*_x23^-1
##  ]]></Example>
##  <P/>
##  &GAP; cannot substitute a new generator without extending the total
##  length,
##  so we have to explicitly ask for it by using the second form of the
##  command <Ref Func="TzSubstitute" Label="for a presentation and a word"/>.
##  Our problem is to choose appropriate values for the arguments
##  <A>n</A> and <A>eliminate</A>.
##  For this purpose it may be helpful to print out a list of the most
##  frequently occurring squarefree relator subwords of length 2.
##  <P/>
##  <Example><![CDATA[
##  gap> TzPrintPairs( P );
##  #I  1.  504  occurrences of  _x6 * _x23^-1
##  #I  2.  504  occurrences of  _x6^-1 * _x23
##  #I  3.  448  occurrences of  _x6 * _x23
##  #I  4.  448  occurrences of  _x6^-1 * _x23^-1
##  gap> TzSubstitute( P, 2, 1 );
##  #I  substituting new generator _x29 defined by _x6^-1*_x23
##  #I  eliminating _x6 = _x23*_x29^-1
##  #I  there are 2 generators and 46 relators of total length 2867
##  gap> TzGoGo( P );
##  #I  there are 2 generators and 45 relators of total length 2417
##  #I  there are 2 generators and 45 relators of total length 2122
##  gap> TzSubstitute( P, 1, 2 );
##  #I  substituting new generator _x30 defined by _x23*_x29^-1
##  #I  eliminating _x29 = _x30^-1*_x23
##  #I  there are 2 generators and 45 relators of total length 2192
##  gap> TzGoGo( P );
##  #I  there are 2 generators and 42 relators of total length 1637
##  #I  there are 2 generators and 40 relators of total length 1286
##  #I  there are 2 generators and 36 relators of total length 807
##  #I  there are 2 generators and 32 relators of total length 625
##  #I  there are 2 generators and 22 relators of total length 369
##  #I  there are 2 generators and 18 relators of total length 213
##  #I  there are 2 generators and 13 relators of total length 141
##  #I  there are 2 generators and 12 relators of total length 121
##  #I  there are 2 generators and 10 relators of total length 101
##  gap> TzPrintPairs( P );
##  #I  1.  19  occurrences of  _x23 * _x30^-1
##  #I  2.  19  occurrences of  _x23^-1 * _x30
##  #I  3.  14  occurrences of  _x23 * _x30
##  #I  4.  14  occurrences of  _x23^-1 * _x30^-1
##  ]]></Example>
##  <P/>
##  If we save a copy of the current presentation, then later we will be able to
##  restart the computation from the current state.
##  <P/>
##  <Example><![CDATA[
##  gap> P1 := ShallowCopy( P );
##  <presentation with 2 gens and 10 rels of total length 101>
##  ]]></Example>
##  <P/>
##  Just for demonstration we make an inconvenient choice:
##  <P/>
##  <Example><![CDATA[
##  gap> TzSubstitute( P, 3, 1 );
##  #I  substituting new generator _x31 defined by _x23*_x30
##  #I  eliminating _x23 = _x31*_x30^-1
##  #I  there are 2 generators and 10 relators of total length 122
##  gap> TzGoGo( P );
##  #I  there are 2 generators and 9 relators of total length 105
##  ]]></Example>
##  <P/>
##  This presentation is worse than the one we have saved, so we restart from
##  that presentation again.
##  <P/>
##  <Example><![CDATA[
##  gap> P := ShallowCopy( P1 );
##  <presentation with 2 gens and 10 rels of total length 101>
##  gap> TzSubstitute( P, 2, 1);
##  #I  substituting new generator _x31 defined by _x23^-1*_x30
##  #I  eliminating _x23 = _x30*_x31^-1
##  #I  there are 2 generators and 10 relators of total length 107
##  gap> TzGoGo( P );
##  #I  there are 2 generators and 9 relators of total length 84
##  #I  there are 2 generators and 8 relators of total length 75
##  gap> TzSubstitute( P, 2, 1);
##  #I  substituting new generator _x32 defined by _x30^-1*_x31
##  #I  eliminating _x30 = _x31*_x32^-1
##  #I  there are 2 generators and 8 relators of total length 71
##  gap> TzGoGo( P );
##  #I  there are 2 generators and 7 relators of total length 56
##  #I  there are 2 generators and 5 relators of total length 36
##  gap> TzPrintRelators( P );
##  #I  1. _x32^5
##  #I  2. _x31^5
##  #I  3. (_x31^-1*_x32^-1)^3
##  #I  4. _x31*(_x32*_x31^-1)^2*_x32*_x31*_x32^-2
##  #I  5. _x31^-1*_x32^2*(_x31*_x32^-1*_x31)^2*_x32^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzSubstitute");


############################################################################
##
#F  TzSubstituteCyclicJoins(<P>)
##
##  <#GAPDoc Label="TzSubstituteCyclicJoins">
##  <ManSection>
##  <Func Name="TzSubstituteCyclicJoins" Arg='P'/>
##
##  <Description>
##  tries to find pairs of commuting generators <M>a</M> and <M>b</M>
##  such that the exponent of <M>a</M> (i. e. the least currently known
##  positive integer <M>n</M> such that <M>a^n</M> is a relator in <A>P</A>)
##  is prime to the exponent of <M>b</M>.
##  For each such pair, their product <M>a b</M> is substituted as a new
##  generator, and <M>a</M> and <M>b</M> are eliminated.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TzSubstituteCyclicJoins");


#############################################################################
##
#F  TzSubstituteWord( <P>, <word> )
##
##  <ManSection>
##  <Func Name="TzSubstituteWord" Arg='P, word'/>
##
##  <Description>
##  <C>TzSubstituteWord</C>  expects <A>P</A> to be a presentation  and <A>word</A> to be a
##  word in the generators of <A>P</A>.  It adds a new generator <A>gen</A> and a
##  new relator of the form  <C><A>gen</A>^-1 * <A>word</A></C> to <A>P</A>.
##  <P/>
##  The second argument <A>word</A> may be  either an abstract word  or a Tietze
##  word, i. e., a list of positive or negative generator numbers.
##  <P/>
##  More precisely: The effect of a call
##  <P/>
##  <Log><![CDATA[
##     TzSubstituteWord( T, word );
##  ]]></Log>
##  <P/>
##  is more or less equivalent to that of
##  <P/>
##  <Log><![CDATA[
##     AddGenerator( T );
##     gen := T.generators[Length( T.generators )];
##     AddRelator( T, gen^-1 * word );
##  ]]></Log>
##  <P/>
##  The  essential  difference  is,  that  <C>TzSubstituteWord</C>,  as  a  Tietze
##  transformation of <A>P</A>,  saves and updates the lists of generator images and
##  preimages, in case they are being traced under the Tietze transformations
##  applied to <A>P</A>,  whereas a call of the function <C>AddGenerator</C> (which  does
##  not perform a Tietze transformation)  will delete  these lists  and hence
##  terminate the tracing.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzSubstituteWord");


#############################################################################
##
#F  TzUpdateGeneratorImage( <P>, <n>, <word> )
##
##  <ManSection>
##  <Func Name="TzUpdateGeneratorImage" Arg='P, n, word'/>
##
##  <Description>
##  <C>TzUpdateGeneratorImages</C>  assumes  that it is called  by a function that
##  performs  Tietze transformations  to a presentation <A>P</A>  in which
##  images of the old generators  are being traced as Tietze words in the new
##  generators  as well as preimages of the new generators as Tietze words in
##  the old generators.
##  <P/>
##  If  <A>n</A>  is zero,  it assumes that  a new generator defined by the Tietze
##  word <A>word</A> has just been added to the presentation.  It converts  <A>word</A>
##  from a  Tietze word  in the new generators  to a  Tietze word  in the old
##  generators and adds that word to the list of preimages.
##  <P/>
##  If  <A>n</A>  is greater than zero,  it assumes that the  <A>n</A>-th generator has
##  just been eliminated from the presentation.  It updates the images of the
##  old generators  by replacing each occurrence of the  <A>n</A>-th  generator by
##  the given Tietze word <A>word</A>.
##  <P/>
##  If <A>n</A> is less than zero,  it terminates the tracing of generator images,
##  i. e., it deletes the corresponding components of <A>P</A>.
##  <P/>
##  Note: <C>TzUpdateGeneratorImages</C> is considered to be an internal function.
##  Hence it does not check the arguments.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TzUpdateGeneratorImages");

DeclareGlobalFunction("TzRelatorOldImages");
