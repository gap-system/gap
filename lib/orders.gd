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
##  These file contains declarations for orderings.
##


##  <#GAPDoc Label="[1]{orders}">
##  In &GAP; an ordering is a relation defined on a family, which is
##  reflexive, anti-symmetric and transitive.
##  <#/GAPDoc>


#############################################################################
##
#C  IsOrdering( <ord> )
##
##  <#GAPDoc Label="IsOrdering">
##  <ManSection>
##  <Filt Name="IsOrdering" Arg='obj' Type='Category'/>
##
##  <Description>
##  returns <K>true</K> if and only if the object <A>ord</A> is an ordering.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsOrdering" ,IsObject);

#############################################################################
##
#A  OrderingsFamily( <fam> )  . . . . . . . . . . make an orderings  family
##
##  <#GAPDoc Label="OrderingsFamily">
##  <ManSection>
##  <Attr Name="OrderingsFamily" Arg='fam'/>
##
##  <Description>
##  for a family <A>fam</A>, returns the family of all
##  orderings on elements of <A>fam</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "OrderingsFamily", IsFamily );


#############################################################################
##
##  General Properties for orderings
##

#############################################################################
##
#P  IsWellFoundedOrdering( <ord>)
##
##  <#GAPDoc Label="IsWellFoundedOrdering">
##  <ManSection>
##  <Prop Name="IsWellFoundedOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A>,
##  returns <K>true</K> if and only if the ordering is well founded.
##  An ordering <A>ord</A> is well founded if it admits no infinite descending
##  chains.
##  Normally this property is set at the time of creation of the ordering
##  and there is no general method to check whether a certain ordering
##  is well founded.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsWellFoundedOrdering" ,IsOrdering);

#############################################################################
##
#P  IsTotalOrdering( <ord> )
##
##  <#GAPDoc Label="IsTotalOrdering">
##  <ManSection>
##  <Prop Name="IsTotalOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A>,
##  returns true if and only if the ordering is total.
##  An ordering <A>ord</A> is total if any two elements of the family
##  are comparable under <A>ord</A>.
##  Normally this property is set at the time of creation of the ordering
##  and there is no general method to check whether a certain ordering
##  is total.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsTotalOrdering" ,IsOrdering);


#############################################################################
##
##  General attributes and operations
##

#############################################################################
##
#A  FamilyForOrdering( <ord> )
##
##  <#GAPDoc Label="FamilyForOrdering">
##  <ManSection>
##  <Attr Name="FamilyForOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A>,
##  returns the family of elements that the ordering <A>ord</A> compares.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FamilyForOrdering" ,IsOrdering);

#############################################################################
##
#A  LessThanFunction( <ord> )
##
##  <#GAPDoc Label="LessThanFunction">
##  <ManSection>
##  <Attr Name="LessThanFunction" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A>,
##  returns a function <M>f</M> which takes two elements <M>el1</M>,
##  <M>el2</M> in <C>FamilyForOrdering</C>(<A>ord</A>) and returns
##  <K>true</K> if <M>el1</M> is strictly less than <M>el2</M>
##  (with respect to <A>ord</A>), and returns <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LessThanFunction" ,IsOrdering);

#############################################################################
##
#A  LessThanOrEqualFunction( <ord> )
##
##  <#GAPDoc Label="LessThanOrEqualFunction">
##  <ManSection>
##  <Attr Name="LessThanOrEqualFunction" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A>,
##  returns a function that takes two elements <M>el1</M>, <M>el2</M> in
##  <C>FamilyForOrdering</C>(<A>ord</A>) and returns <K>true</K>
##  if <M>el1</M> is less than <E>or equal to</E> <M>el2</M>
##  (with respect to <A>ord</A>), and returns <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LessThanOrEqualFunction" ,IsOrdering);

#############################################################################
##
#O  IsLessThanUnder( <ord>, <el1>, <el2> )
##
##  <#GAPDoc Label="IsLessThanUnder">
##  <ManSection>
##  <Oper Name="IsLessThanUnder" Arg='ord, el1, el2'/>
##
##  <Description>
##  for an ordering <A>ord</A> on the elements of the family of <A>el1</A>
##  and <A>el2</A>, returns <K>true</K> if <A>el1</A> is (strictly) less than
##  <A>el2</A> with respect to <A>ord</A>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsLessThanUnder" ,[IsOrdering,IsObject,IsObject]);

#############################################################################
##
#O  IsLessThanOrEqualUnder( <ord>, <el1>, <el2> )
##
##  <#GAPDoc Label="IsLessThanOrEqualUnder">
##  <ManSection>
##  <Oper Name="IsLessThanOrEqualUnder" Arg='ord, el1, el2'/>
##
##  <Description>
##  for an ordering <A>ord</A> on the elements of the family of <A>el1</A>
##  and <A>el2</A>, returns <K>true</K> if <A>el1</A> is less than or equal
##  to <A>el2</A> with respect to <A>ord</A>, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> IsLessThanUnder(ord,a,a*b);
##  true
##  gap> IsLessThanOrEqualUnder(ord,a*b,a*b);
##  true
##  gap> IsIncomparableUnder(ord,a,b);
##  true
##  gap> FamilyForOrdering(ord) = FamilyObj(a);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsLessThanOrEqualUnder" ,[IsOrdering,IsObject,IsObject]);

#############################################################################
##
#O  IsIncomparableUnder( <ord>, <el1>, <el2> )
##
##  <#GAPDoc Label="IsIncomparableUnder">
##  <ManSection>
##  <Oper Name="IsIncomparableUnder" Arg='ord, el1, el2'/>
##
##  <Description>
##  for an ordering <A>ord</A> on the elements of the family of <A>el1</A>
##  and <A>el2</A>, returns <K>true</K> if <A>el1</A> <M>\neq</M> <A>el2</A>
##  and <C>IsLessThanUnder</C>(<A>ord</A>,<A>el1</A>,<A>el2</A>),
##  <C>IsLessThanUnder</C>(<A>ord</A>,<A>el2</A>,<A>el1</A>) are both
##  <K>false</K>; and returns <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsIncomparableUnder" ,[IsOrdering,IsObject,IsObject]);

#############################################################################
##
##  Building new orderings
##

#############################################################################
##
#O  OrderingByLessThanFunctionNC( <fam>, <lt>[, <l>] )
##
##  <#GAPDoc Label="OrderingByLessThanFunctionNC">
##  <ManSection>
##  <Oper Name="OrderingByLessThanFunctionNC" Arg='fam, lt[, l]'/>
##
##  <Description>
##  Called with two arguments, <Ref Oper="OrderingByLessThanFunctionNC"/>
##  returns the ordering on the elements of the elements of the family
##  <A>fam</A>, according to the <Ref Attr="LessThanFunction"/> value given
##  by <A>lt</A>,
##  where <A>lt</A> is a function that takes two
##  arguments in <A>fam</A> and returns <K>true</K> or <K>false</K>.
##  <P/>
##  Called with three arguments, for a family <A>fam</A>,
##  a function <A>lt</A> that takes two arguments in <A>fam</A> and returns
##  <K>true</K> or <K>false</K>, and a list <A>l</A>
##  of properties of orderings, <Ref Oper="OrderingByLessThanFunctionNC"/>
##  returns the ordering on the elements of <A>fam</A> with
##  <Ref Attr="LessThanFunction"/> value given by <A>lt</A>
##  and with the properties from <A>l</A> set to <K>true</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OrderingByLessThanFunctionNC" ,[IsFamily,IsFunction]);

#############################################################################
##
#O  OrderingByLessThanOrEqualFunctionNC( <fam>, <lteq>[, <l>] )
##
##  <#GAPDoc Label="OrderingByLessThanOrEqualFunctionNC">
##  <ManSection>
##  <Oper Name="OrderingByLessThanOrEqualFunctionNC" Arg='fam, lteq[, l]'/>
##
##  <Description>
##  Called with two arguments,
##  <Ref Oper="OrderingByLessThanOrEqualFunctionNC"/> returns the ordering on
##  the elements of the elements of the family <A>fam</A> according to
##  the <Ref Attr="LessThanOrEqualFunction"/> value given by <A>lteq</A>,
##  where <A>lteq</A> is a function that takes two arguments in <A>fam</A>
##  and returns <K>true</K> or <K>false</K>.
##  <P/>
##  Called with three arguments, for a family <A>fam</A>,
##  a function <A>lteq</A> that takes two arguments in <A>fam</A> and returns
##  <K>true</K> or <K>false</K>, and a list <A>l</A>
##  of properties of orderings,
##  <Ref Oper="OrderingByLessThanOrEqualFunctionNC"/>
##  returns the ordering on the elements of <A>fam</A> with
##  <Ref Attr="LessThanOrEqualFunction"/> value given by <A>lteq</A>
##  and with the properties from <A>l</A> set to <K>true</K>.
##  <P/>
##  Notice that these functions do not check whether <A>fam</A> and <A>lt</A>
##  or <A>lteq</A> are compatible,
##  and whether the properties listed in <A>l</A> are indeed satisfied.
##  <Example><![CDATA[
##  gap> f := FreeSemigroup("a","b");;
##  gap> a := GeneratorsOfSemigroup(f)[1];;
##  gap> b := GeneratorsOfSemigroup(f)[2];;
##  gap> lt := function(x,y) return Length(x)<Length(y); end;
##  function( x, y ) ... end
##  gap> fam := FamilyObj(a);;
##  gap> ord := OrderingByLessThanFunctionNC(fam,lt);
##  Ordering
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OrderingByLessThanOrEqualFunctionNC" ,
    [IsFamily,IsFunction]);


############################################################################
##
##  Orderings on families of associative words
##
##  <#GAPDoc Label="[2]{orders}">
##  We now consider orderings on families of associative words.
##  <P/>
##  Examples of families of associative words are the families of elements
##  of a free semigroup or a free monoid;
##  these are the two cases that we consider mostly.
##  Associated with those families is
##  an alphabet, which is the semigroup (resp. monoid) generating set
##  of the correspondent free semigroup (resp. free monoid).
##  For definitions of the orderings considered,
##  see Sims <Cite Key="Sims94"/>.
##  <#/GAPDoc>
##
##  The ordering on the letters of the alphabet is important when
##  defining an order in such a family.
##  An alphabet has a default ordering: the generators of a free semigroup
##  or free monoid are indexed on <M>[ 1, 2, \ldots, n ]</M>,
##  where <M>n</M> is the size of the alphabet.
##  Another ordering on the alphabet will always be given in terms
##  of this one, either in terms of a list of length <M>n</M>, where position
##  <M>i</M> (<M>1 \leq i \leq n</M>) indicates what is the <M>i</M>-th
##  generator in the ordering, or else as a list of the generators,
##  starting from the smallest one.
##

#############################################################################
##
#P  IsOrderingOnFamilyOfAssocWords( <ord>)
##
##  <#GAPDoc Label="IsOrderingOnFamilyOfAssocWords">
##  <ManSection>
##  <Prop Name="IsOrderingOnFamilyOfAssocWords" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A>,
##  returns true if <A>ord</A> is an ordering over a family of associative
##  words.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsOrderingOnFamilyOfAssocWords",IsOrdering);

#############################################################################
##
#A  LetterRepWordsLessFunc( <ord> )
##
##  <ManSection>
##  <Attr Name="LetterRepWordsLessFunc" Arg='ord'/>
##
##  <Description>
##  If <A>ord</A> is an ordering for associative words,
##  this attribute (if known) will hold a function which implements a
##  <Q>less than</Q> function for words given by a list of letters
##  (see&nbsp;<Ref Func="LetterRepAssocWord"/>).
##  </Description>
##  </ManSection>
##
DeclareAttribute( "LetterRepWordsLessFunc" ,IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#P  IsTranslationInvariantOrdering( <ord> )
##
##  <#GAPDoc Label="IsTranslationInvariantOrdering">
##  <ManSection>
##  <Prop Name="IsTranslationInvariantOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A> on a family of associative words,
##  returns <K>true</K> if and only if the ordering is translation invariant.
##  <P/>
##  This is a property of orderings on families of associative words.
##  An ordering <A>ord</A> over a family <M>F</M>, with alphabet <M>X</M>
##  is translation invariant if
##  <C>IsLessThanUnder(</C> <A>ord</A>, <M>u</M>, <M>v</M> <C>)</C> implies
##  that for any <M>a, b \in X^*</M>,
##  <C>IsLessThanUnder(</C> <A>ord</A>, <M>a*u*b</M>, <M>a*v*b</M> <C>)</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsTranslationInvariantOrdering" ,IsOrdering and
                                    IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#P  IsReductionOrdering( <ord> )
##
##  <#GAPDoc Label="IsReductionOrdering">
##  <ManSection>
##  <Prop Name="IsReductionOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A> on a family of associative words,
##  returns <K>true</K> if and only if the ordering is a reduction ordering.
##  An ordering <A>ord</A> is a reduction ordering
##  if it is well founded and translation invariant.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsReductionOrdering",
    IsTranslationInvariantOrdering and IsWellFoundedOrdering );


##  The ordering on the letters of the alphabet is important when
##  defining an order in a family of associative words.
##  An alphabet has a default ordering: the generators of a free semigroup
##  or free monoid are indexed on <M>[1,2,\ldots,n]</M>, where <M>n</M> is the size of
##  the alphabet. Another ordering on the alphabet will always be given in terms
##  of this one, either in terms of a list <A>gensord</A> of length <M>n</M>,
##  where position <M>i</M> (<M>1 \leq i \leq n</M>) indicates what is the <M>i</M>-th
##  generator in the ordering, or else as a list <A>alphabet</A> of the generators,
##  starting from the smallest one.


#############################################################################
##
#A  OrderingOnGenerators( <ord>)
##
##  <#GAPDoc Label="OrderingOnGenerators">
##  <ManSection>
##  <Attr Name="OrderingOnGenerators" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A> on a family of associative words,
##  returns a list in which the generators are considered.
##  This could be indeed the ordering of the generators in the ordering,
##  but, for example, if a weight is associated to each generator
##  then this is not true anymore.
##  See the example for <Ref Oper="WeightLexOrdering"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("OrderingOnGenerators",IsOrdering and
                    IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#O  LexicographicOrdering( <D>[, <gens>] )
##
##  <#GAPDoc Label="LexicographicOrdering">
##  <ManSection>
##  <Oper Name="LexicographicOrdering" Arg='D[, gens]'/>
##
##  <Description>
##  Let <A>D</A> be a free semigroup, a free monoid, or the elements
##  family of such a domain.
##  Called with only argument <A>D</A>,
##  <Ref Oper="LexicographicOrdering"/> returns the lexicographic
##  ordering on the elements of <A>D</A>.
##  <P/>
##  The optional argument <A>gens</A> can be either the list of free
##  generators of <A>D</A>, in the desired order,
##  or a list of the positions of these generators,
##  in the desired order,
##  and <Ref Oper="LexicographicOrdering"/> returns the lexicographic
##  ordering on the elements of <A>D</A> with the ordering on the
##  generators as given.
##  <Example><![CDATA[
##  gap> f := FreeSemigroup(3);
##  <free semigroup on the generators [ s1, s2, s3 ]>
##  gap> lex := LexicographicOrdering(f,[2,3,1]);
##  Ordering
##  gap> IsLessThanUnder(lex,f.2*f.3,f.3);
##  true
##  gap> IsLessThanUnder(lex,f.3,f.2);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("LexicographicOrdering",
    [IsFamily and IsAssocWordFamily, IsList and IsAssocWordCollection]);


#############################################################################
##
#O  ShortLexOrdering( <D>[, <gens>] )
##
##  <#GAPDoc Label="ShortLexOrdering">
##  <ManSection>
##  <Oper Name="ShortLexOrdering" Arg='D[, gens]'/>
##
##  <Description>
##  Let <A>D</A> be a free semigroup, a free monoid, or the elements
##  family of such a domain.
##  Called with only argument <A>D</A>,
##  <Ref Oper="ShortLexOrdering"/> returns the shortlex
##  ordering on the elements of <A>D</A>.
##  <P/>
##  The optional argument <A>gens</A> can be either the list of free
##  generators of <A>D</A>, in the desired order,
##  or a list of the positions of these generators,
##  in the desired order,
##  and <Ref Oper="ShortLexOrdering"/> returns the shortlex
##  ordering on the elements of <A>D</A> with the ordering on the
##  generators as given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ShortLexOrdering",[IsFamily and IsAssocWordFamily,
                                     IsList and IsAssocWordCollection]);

#############################################################################
##
#P  IsShortLexOrdering( <ord>)
##
##  <#GAPDoc Label="IsShortLexOrdering">
##  <ManSection>
##  <Prop Name="IsShortLexOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A> of a family of associative words,
##  returns <K>true</K> if and only if <A>ord</A> is a shortlex ordering.
##  <Example><![CDATA[
##  gap> f := FreeSemigroup(3);
##  <free semigroup on the generators [ s1, s2, s3 ]>
##  gap> sl := ShortLexOrdering(f,[2,3,1]);
##  Ordering
##  gap> IsLessThanUnder(sl,f.1,f.2);
##  false
##  gap> IsLessThanUnder(sl,f.3,f.2);
##  false
##  gap> IsLessThanUnder(sl,f.3,f.1);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsShortLexOrdering",IsOrdering and
                          IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#F  IsShortLexLessThanOrEqual( <u>, <v> )
##
##  <#GAPDoc Label="IsShortLexLessThanOrEqual">
##  <ManSection>
##  <Func Name="IsShortLexLessThanOrEqual" Arg='u, v'/>
##
##  <Description>
##  returns <C>IsLessThanOrEqualUnder(<A>ord</A>, <A>u</A>, <A>v</A>)</C>
##  where <A>ord</A> is the short less ordering for the family of <A>u</A>
##  and <A>v</A>.
##  (This is here for compatibility with &GAP;&nbsp;4.2.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsShortLexLessThanOrEqual" );

#############################################################################
##
#O  WeightLexOrdering( <D>, <gens>, <wt> )
##
##  <#GAPDoc Label="WeightLexOrdering">
##  <ManSection>
##  <Oper Name="WeightLexOrdering" Arg='D, gens, wt'/>
##
##  <Description>
##  Let <A>D</A> be a free semigroup, a free monoid, or the elements
##  family of such a domain. <A>gens</A> can be either the list of free
##  generators of <A>D</A>, in the desired order,
##  or a list of the positions of these generators, in the desired order.
##  Let <A>wt</A> be a list of weights.
##  <Ref Oper="WeightLexOrdering"/> returns the weightlex
##  ordering on the elements of <A>D</A> with the ordering on the
##  generators and weights of the generators as given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("WeightLexOrdering",
  [IsFamily and IsAssocWordFamily,IsList and IsAssocWordCollection,IsList]);

#############################################################################
##
#A  WeightOfGenerators( <ord>)
##
##  <#GAPDoc Label="WeightOfGenerators">
##  <ManSection>
##  <Attr Name="WeightOfGenerators" Arg='ord'/>
##
##  <Description>
##  for a weightlex ordering <A>ord</A>,
##  returns a list with length the size of the alphabet of the family.
##  This list gives the weight of each of the letters of the alphabet
##  which are used for weightlex orderings with respect to the
##  ordering given by <Ref Attr="OrderingOnGenerators"/>.
##  <Example><![CDATA[
##  gap> f := FreeSemigroup(3);
##  <free semigroup on the generators [ s1, s2, s3 ]>
##  gap> wtlex := WeightLexOrdering(f,[f.2,f.3,f.1],[3,2,1]);
##  Ordering
##  gap> IsLessThanUnder(wtlex,f.1,f.2);
##  true
##  gap> IsLessThanUnder(wtlex,f.3,f.2);
##  true
##  gap> IsLessThanUnder(wtlex,f.3,f.1);
##  false
##  gap> OrderingOnGenerators(wtlex);
##  [ s2, s3, s1 ]
##  gap> WeightOfGenerators(wtlex);
##  [ 3, 2, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("WeightOfGenerators",IsOrdering and
                    IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#P  IsWeightLexOrdering( <ord>)
##
##  <#GAPDoc Label="IsWeightLexOrdering">
##  <ManSection>
##  <Prop Name="IsWeightLexOrdering" Arg='ord'/>
##
##  <Description>
##  for an ordering <A>ord</A> on a family of associative words,
##  returns <K>true</K> if and only if <A>ord</A> is a weightlex ordering.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsWeightLexOrdering",IsOrdering and
                      IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#O  BasicWreathProductOrdering( <D>[, <gens>] )
##
##  <#GAPDoc Label="BasicWreathProductOrdering">
##  <ManSection>
##  <Oper Name="BasicWreathProductOrdering" Arg='D[, gens]'/>
##
##  <Description>
##  Let <A>D</A> be a free semigroup, a free monoid, or the elements
##  family of such a domain.
##  Called with only argument <A>D</A>,
##  <Ref Oper="BasicWreathProductOrdering"/> returns the basic wreath product
##  ordering on the elements of <A>D</A>.
##  <P/>
##  The optional argument <A>gens</A> can be either the list of free
##  generators of <A>D</A>, in the desired order,
##  or a list of the positions of these generators,
##  in the desired order,
##  and <Ref Oper="BasicWreathProductOrdering"/> returns the lexicographic
##  ordering on the elements of <A>D</A> with the ordering on the
##  generators as given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("BasicWreathProductOrdering",[IsAssocWordFamily,IsList]);

#############################################################################
##
#P  IsBasicWreathProductOrdering( <ord>)
##
##  <#GAPDoc Label="IsBasicWreathProductOrdering">
##  <ManSection>
##  <Prop Name="IsBasicWreathProductOrdering" Arg='ord'/>
##
##  <Description>
##  <Example><![CDATA[
##  gap> f := FreeSemigroup(3);
##  <free semigroup on the generators [ s1, s2, s3 ]>
##  gap> basic := BasicWreathProductOrdering(f,[2,3,1]);
##  Ordering
##  gap> IsLessThanUnder(basic,f.3,f.1);
##  true
##  gap> IsLessThanUnder(basic,f.3*f.2,f.1);
##  true
##  gap> IsLessThanUnder(basic,f.3*f.2*f.1,f.1*f.3);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsBasicWreathProductOrdering",IsOrdering);

#############################################################################
##
#F  IsBasicWreathLessThanOrEqual( <u>, <v> )
##
##  <#GAPDoc Label="IsBasicWreathLessThanOrEqual">
##  <ManSection>
##  <Func Name="IsBasicWreathLessThanOrEqual" Arg='u, v'/>
##
##  <Description>
##  returns <C>IsLessThanOrEqualUnder(<A>ord</A>, <A>u</A>, <A>v</A>)</C>
##  where <A>ord</A> is the basic wreath product ordering for the family of
##  <A>u</A> and <A>v</A>.
##  (This is here for compatibility with &GAP;&nbsp;4.2.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsBasicWreathLessThanOrEqual" );

#############################################################################
##
#O  WreathProductOrdering( <D>[, <gens>], <levels>)
##
##  <#GAPDoc Label="WreathProductOrdering">
##  <ManSection>
##  <Oper Name="WreathProductOrdering" Arg='D[, gens], levels'/>
##
##  <Description>
##  Let <A>D</A> be a free semigroup, a free monoid, or the elements
##  family of such a domain,
##  let <A>gens</A> be either the list of free generators of <A>D</A>,
##  in the desired order,
##  or a list of the positions of these generators, in the desired order,
##  and let <A>levels</A> be a list of levels for the generators.
##  If <A>gens</A> is omitted then the default ordering is taken.
##  <Ref Oper="WreathProductOrdering"/> returns the wreath product
##  ordering on the elements of <A>D</A> with the ordering on the
##  generators as given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("WreathProductOrdering",[IsFamily,IsList,IsList]);

#############################################################################
##
#P  IsWreathProductOrdering( <ord>)
##
##  <#GAPDoc Label="IsWreathProductOrdering">
##  <ManSection>
##  <Prop Name="IsWreathProductOrdering" Arg='ord'/>
##
##  <Description>
##  specifies whether an ordering is a wreath product ordering
##  (see <Ref Oper="WreathProductOrdering"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsWreathProductOrdering",IsOrdering);

#############################################################################
##
#A  LevelsOfGenerators( <ord>)
##
##  <#GAPDoc Label="LevelsOfGenerators">
##  <ManSection>
##  <Attr Name="LevelsOfGenerators" Arg='ord'/>
##
##  <Description>
##  for a wreath product ordering <A>ord</A>, returns the levels
##  of the generators as given at creation
##  (with respect to <Ref Attr="OrderingOnGenerators"/>).
##  <Example><![CDATA[
##  gap> f := FreeSemigroup(3);
##  <free semigroup on the generators [ s1, s2, s3 ]>
##  gap> wrp := WreathProductOrdering(f,[1,2,3],[1,1,2,]);
##  Ordering
##  gap> IsLessThanUnder(wrp,f.3,f.1);
##  false
##  gap> IsLessThanUnder(wrp,f.3,f.2);
##  false
##  gap> IsLessThanUnder(wrp,f.1,f.2);
##  true
##  gap> LevelsOfGenerators(wrp);
##  [ 1, 1, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("LevelsOfGenerators",IsOrdering and IsWreathProductOrdering);
