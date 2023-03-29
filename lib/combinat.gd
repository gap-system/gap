#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declaration for combinatorics functions.
##


#############################################################################
##
#F  Factorial( <n> )  . . . . . . . . . . . . . . . . factorial of an integer
##
##  <#GAPDoc Label="Factorial">
##  <ManSection>
##  <Func Name="Factorial" Arg='n'/>
##
##  <Description>
##  returns the <E>factorial</E> <M>n!</M> of the positive integer <A>n</A>,
##  which is defined as the product <M>1 \cdot 2 \cdot 3 \cdots n</M>.
##  <P/>
##  <M>n!</M> is the number of permutations of a set of <M>n</M> elements.
##  <M>1 / n!</M> is the coefficient of <M>x^n</M> in the formal series
##  <M>\exp(x)</M>,
##  which is the generating function for factorial.
##  <P/>
##  <Example><![CDATA[
##  gap> List( [0..10], Factorial );
##  [ 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800 ]
##  gap> Factorial( 30 );
##  265252859812191058636308480000000
##  ]]></Example>
##  <P/>
##  <Ref Func="PermutationsList"/> computes the set of all permutations
##  of a list.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Factorial");


#############################################################################
##
#F  Binomial( <n>, <k> )  . . . . . . . . .  binomial coefficient of integers
##
##  <#GAPDoc Label="Binomial">
##  <ManSection>
##  <Func Name="Binomial" Arg='n, k'/>
##
##  <Description>
##  returns the <E>binomial coefficient</E>
##  <Index Subkey="binomial">coefficient</Index>
##  <Index Subkey="binomial">number</Index>
##  <M>{{n \choose k}}</M> of integers <A>n</A> and <A>k</A>. This is defined by
##  the conditions <M>{{n \choose k}} = 0</M> for <M>k &lt; 0</M>,
##  <M>{{0 \choose k}} = 0</M> for <M>k \neq 0</M>, <M>{{0 \choose 0}} =
##  1</M> and the relation
##  <M>{{n \choose k}} = {{n-1 \choose k}} + {{n-1 \choose k-1}}</M>
##  for all <M>n</M> and <M>k</M>.
##  <P/>
##  There are many ways of describing this function. For example,
##  if <M>n \geq 0</M> and <M>0 \leq k \leq n</M>, then
##  <M>{{n \choose k}} = n! / (k! (n-k)!)</M> and for <M>n &lt; 0</M> and
##  <M>k \geq 0</M> we have <M>{{n \choose k}} =
##  (-1)^k {{-n+k-1 \choose k}}</M>.
##  <P/>
##  If <M>n \geq 0</M> then <M>{{n \choose k}}</M> is
##  the number of subsets with <M>k</M> elements of a set with <M>n</M>
##  elements.
##  Also, <M>{{n \choose k}}</M> is the coefficient of <M>x^k</M> in the
##  polynomial <M>(x + 1)^n</M>,
##  which is the generating function for <M>{{n \choose .}}</M>,
##  hence the name.
##  <P/>
##  <Example><![CDATA[
##  gap> # Knuth calls this the trademark of Binomial:
##  gap> List( [0..4], k->Binomial( 4, k ) );
##  [ 1, 4, 6, 4, 1 ]
##  gap> List( [0..6], n->List( [0..6], k->Binomial( n, k ) ) );;
##  gap> # the lower triangle is called Pascal's triangle:
##  gap> PrintArray( last );
##  [ [   1,   0,   0,   0,   0,   0,   0 ],
##    [   1,   1,   0,   0,   0,   0,   0 ],
##    [   1,   2,   1,   0,   0,   0,   0 ],
##    [   1,   3,   3,   1,   0,   0,   0 ],
##    [   1,   4,   6,   4,   1,   0,   0 ],
##    [   1,   5,  10,  10,   5,   1,   0 ],
##    [   1,   6,  15,  20,  15,   6,   1 ] ]
##  gap> Binomial( 50, 10 );
##  10272278170
##  ]]></Example>
##  <P/>
##  <Ref Func="NrCombinations"/> is the generalization of
##  <Ref Func="Binomial"/> for multisets.
##  <Ref Func="Combinations"/> computes the set of all combinations of a
##  multiset.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Binomial");

#############################################################################
##
#F  GaussianCoefficient( <n>, <k>, <q> ) . . . . . . . .  number of subspaces
##
##  <#GAPDoc Label="GaussianCoefficient">
##  <ManSection>
##  <Func Name="GaussianCoefficient" Arg='n, k, q'/>
##
##  <Description>
##  returns the <E>Gaussian binomial coefficient</E>
##  <Index Subkey="gaussian">coefficient</Index>
##  <M>{{n \choose k}}_q</M> of integers <A>n</A>, <A>k</A>, and <A>q</A>,
##  which is defined as
##  <M>
##  {n \choose k}_q
##  = \begin{cases}
##  \frac{(1-q^n)(1-q^{n-1})\cdots(1-q^{n-k+1})} {(1-q)(1-q^2)\cdots(1-q^k)} & k
##  \le n \\
##  0 & k>n \end{cases}.
##  </M>
##  It counts the number of <M>k</A>-dimensional subspaces of an
##  <M>n</M>-dimensional vector space over the field with <M>q</M> elements.
##  <P/>
##  <Example><![CDATA[
##  ]]></Example>
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("GaussianCoefficient");


#############################################################################
##
#F  Bell( <n> ) . . . . . . . . . . . . . . . . .  value of the Bell sequence
##
##  <#GAPDoc Label="Bell">
##  <ManSection>
##  <Func Name="Bell" Arg='n'/>
##
##  <Description>
##  returns the <E>Bell number</E>
##  <Index Subkey="Bell">number</Index>
##  <M>B(n)</M>.
##  The Bell numbers are defined by
##  <M>B(0) = 1</M> and the recurrence
##  <M>B(n+1) = \sum_{{k = 0}}^n {{n \choose k}} B(k)</M>.
##  <P/>
##  <M>B(n)</M> is the number of ways to partition a set of <A>n</A> elements
##  into pairwise disjoint nonempty subsets
##  (see <Ref Func="PartitionsSet"/>).
##  This implies of course that <M>B(n) = \sum_{{k = 0}}^n S_2(n,k)</M>
##  (see <Ref Func="Stirling2"/>).
##  <M>B(n)/n!</M> is the coefficient of <M>x^n</M> in the formal series
##  <M>\exp( \exp(x)-1 )</M>, which is the generating function for <M>B(n)</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> List( [0..6], n -> Bell( n ) );
##  [ 1, 1, 2, 5, 15, 52, 203 ]
##  gap> Bell( 14 );
##  190899322
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Bell");


#############################################################################
##
#F  Stirling1( <n>, <k> ) . . . . . . . . . Stirling number of the first kind
##
##  <#GAPDoc Label="Stirling1">
##  <ManSection>
##  <Func Name="Stirling1" Arg='n, k'/>
##
##  <Description>
##  returns the <E>Stirling number of the first kind</E>
##  <Index>Stirling number of the first kind</Index>
##  <Index Subkey="Stirling, of the first kind">number</Index>
##  <M>S_1(n,k)</M> of the integers <A>n</A> and <A>k</A>.
##  Stirling numbers of the first kind are defined by
##  <M>S_1(0,0) = 1</M>, <M>S_1(n,0) = S_1(0,k) = 0</M> if <M>n, k \ne 0</M>
##  and the recurrence <M>S_1(n,k) = (n-1) S_1(n-1,k) + S_1(n-1,k-1)</M>.
##  <P/>
##  <M>S_1(n,k)</M> is the number of permutations of <A>n</A> points with
##  <A>k</A> cycles.
##  Stirling numbers of the first kind appear as coefficients in the series
##  <M>n! {{x \choose n}} = \sum_{{k = 0}}^n S_1(n,k) x^k</M>
##  which is the generating function for Stirling numbers of the first kind.
##  Note the similarity to
##  <M>x^n = \sum_{{k = 0}}^n S_2(n,k) k! {{x \choose k}}</M>
##  (see <Ref Func="Stirling2"/>).
##  Also the definition of <M>S_1</M> implies <M>S_1(n,k) = S_2(-k,-n)</M> if
##  <M>n, k &lt; 0</M>.
##  There are many formulae relating Stirling numbers of the first kind to
##  Stirling numbers of the second kind, Bell numbers,
##  and Binomial coefficients.
##  <P/>
##  <Example><![CDATA[
##  gap> # Knuth calls this the trademark of S_1:
##  gap> List( [0..4], k -> Stirling1( 4, k ) );
##  [ 0, 6, 11, 6, 1 ]
##  gap> List( [0..6], n->List( [0..6], k->Stirling1( n, k ) ) );;
##  gap> # note the similarity with Pascal's triangle for Binomial numbers
##  gap> PrintArray( last );
##  [ [    1,    0,    0,    0,    0,    0,    0 ],
##    [    0,    1,    0,    0,    0,    0,    0 ],
##    [    0,    1,    1,    0,    0,    0,    0 ],
##    [    0,    2,    3,    1,    0,    0,    0 ],
##    [    0,    6,   11,    6,    1,    0,    0 ],
##    [    0,   24,   50,   35,   10,    1,    0 ],
##    [    0,  120,  274,  225,   85,   15,    1 ] ]
##  gap> Stirling1(50,10);
##  101623020926367490059043797119309944043405505380503665627365376
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Stirling1");


#############################################################################
##
#F  Stirling2( <n>, <k> ) . . . . . . . .  Stirling number of the second kind
##
##  <#GAPDoc Label="Stirling2">
##  <ManSection>
##  <Func Name="Stirling2" Arg='n, k'/>
##
##  <Description>
##  returns the <E>Stirling number of the second kind</E>
##  <Index>Stirling number of the second kind</Index>
##  <Index Subkey="Stirling, of the second kind">number</Index>
##  <M>S_2(n,k)</M> of the integers <A>n</A> and <A>k</A>.
##  Stirling numbers of the second kind are defined by
##  <M>S_2(0,0) = 1</M>, <M>S_2(n,0) = S_2(0,k) = 0</M> if <M>n, k \ne 0</M>
##  and the recurrence <M>S_2(n,k) = k S_2(n-1,k) + S_2(n-1,k-1)</M>.
##  <P/>
##  <M>S_2(n,k)</M> is the number of ways to partition a set of <A>n</A>
##  elements into <A>k</A> pairwise disjoint nonempty subsets
##  (see <Ref Func="PartitionsSet"/>).
##  Stirling numbers of the second kind  appear as coefficients in the
##  expansion of <M>x^n = \sum_{{k = 0}}^n S_2(n,k) k! {{x \choose k}}</M>.
##  Note the similarity to
##  <M>n! {{x \choose n}} = \sum_{{k = 0}}^n S_1(n,k) x^k</M>
##  (see <Ref Func="Stirling1"/>).
##  Also the definition of <M>S_2</M> implies <M>S_2(n,k) = S_1(-k,-n)</M> if
##  <M>n, k &lt; 0</M>.
##  There are many formulae relating Stirling numbers of the second kind to
##  Stirling numbers of the first kind, Bell numbers,
##  and Binomial coefficients.
##  <P/>
##  <Example><![CDATA[
##  gap> # Knuth calls this the trademark of S_2:
##  gap> List( [0..4], k->Stirling2( 4, k ) );
##  [ 0, 1, 7, 6, 1 ]
##  gap> List( [0..6], n->List( [0..6], k->Stirling2( n, k ) ) );;
##  gap> # note the similarity with Pascal's triangle for Binomial numbers
##  gap> PrintArray( last );
##  [ [   1,   0,   0,   0,   0,   0,   0 ],
##    [   0,   1,   0,   0,   0,   0,   0 ],
##    [   0,   1,   1,   0,   0,   0,   0 ],
##    [   0,   1,   3,   1,   0,   0,   0 ],
##    [   0,   1,   7,   6,   1,   0,   0 ],
##    [   0,   1,  15,  25,  10,   1,   0 ],
##    [   0,   1,  31,  90,  65,  15,   1 ] ]
##  gap> Stirling2( 50, 10 );
##  26154716515862881292012777396577993781727011
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Stirling2");


#############################################################################
##
#F  Combinations( <mset>[, <k>] )
##
##  <#GAPDoc Label="Combinations">
##  <ManSection>
##  <Func Name="Combinations" Arg='mset[, k]'/>
##
##  <Description>
##  returns the set of all combinations of the multiset <A>mset</A>
##  (a list of objects which may contain the same object several times)
##  with <A>k</A> elements;
##  if <A>k</A> is not given it returns all combinations of <A>mset</A>.
##  <P/>
##  A <E>combination</E> of <A>mset</A> is an unordered selection without
##  repetitions and is represented by a sorted sublist of <A>mset</A>.
##  If <A>mset</A> is a proper set,
##  there are <M>{{|<A>mset</A>| \choose <A>k</A>}}</M>
##  (see <Ref Func="Binomial"/>) combinations with <A>k</A> elements,
##  and the set of all combinations is just the <E>power set</E>
##  <Index>power set</Index>
##  <Index>subsets</Index>
##  of <A>mset</A>, which contains all <E>subsets</E> of <A>mset</A> and has
##  cardinality <M>2^{{|<A>mset</A>|}}</M>.
##  <P/>
##  To loop over combinations of a larger multiset use <Ref
##  Func="IteratorOfCombinations" /> which produces combinations one by one
##  and may save a lot of memory. Another memory efficient representation of
##  the list of all combinations is provided by <Ref
##  Func="EnumeratorOfCombinations" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Combinations");

#############################################################################
##
#F  IteratorOfCombinations( mset[, k ] )
#F  EnumeratorOfCombinations( mset )
##
##  <#GAPDoc Label="IteratorOfCombinations">
##  <ManSection>
##  <Heading>Iterator and enumerator of combinations</Heading>
##  <Func Name="IteratorOfCombinations" Arg='mset[, k]'/>
##  <Func Name="EnumeratorOfCombinations" Arg='mset'/>
##
##  <Description>
##  <Ref Func="IteratorOfCombinations" /> returns an <Ref Oper="Iterator" />
##  for  combinations (see <Ref Func="Combinations"/>) of the given multiset
##  <A>mset</A>. If a non-negative integer <A>k</A> is given as second argument
##  then only the combinations with <A>k</A> entries are produced, otherwise
##  all combinations.
##  <P/>
##  <Ref Func="EnumeratorOfCombinations"/> returns an <Ref Attr="Enumerator" />
##  of the given multiset <A>mset</A>. Currently only a variant without second
##  argument <A>k</A> is implemented.
##  <P/>
##  The ordering of combinations from these functions can be different and also
##  different from the list returned by <Ref Func="Combinations"/>.
##  <P/>
##  <Example>
##  gap> m:=[1..15];; Add(m, 15);
##  gap> NrCombinations(m);
##  49152
##  gap> i := 0;; for c in Combinations(m) do i := i+1; od;
##  gap> i;
##  49152
##  gap> cm := EnumeratorOfCombinations(m);;
##  gap> cm[1000];
##  [ 1, 2, 3, 6, 7, 8, 9, 10 ]
##  gap> Position(cm, [1,13,15,15]);
##  36866
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorOfCombinations" );
DeclareGlobalFunction( "EnumeratorOfCombinations" );


#############################################################################
##
#F  NrCombinations( <mset>[, <k>] )
##
##  <#GAPDoc Label="NrCombinations">
##  <ManSection>
##  <Func Name="NrCombinations" Arg='mset[, k]'/>
##
##  <Description>
##  returns the number of <C>Combinations(<A>mset</A>,<A>k</A>)</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> Combinations( [1,2,2,3] );
##  [ [  ], [ 1 ], [ 1, 2 ], [ 1, 2, 2 ], [ 1, 2, 2, 3 ], [ 1, 2, 3 ],
##    [ 1, 3 ], [ 2 ], [ 2, 2 ], [ 2, 2, 3 ], [ 2, 3 ], [ 3 ] ]
##  gap> # number of different hands in a game of poker:
##  gap> NrCombinations( [1..52], 5 );
##  2598960
##  ]]></Example>
##  <P/>
##  The function <Ref Func="Arrangements"/> computes ordered selections
##  without repetitions,
##  <Ref Func="UnorderedTuples"/> computes unordered selections with
##  repetitions, and
##  <Ref Func="Tuples"/> computes ordered selections with repetitions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrCombinations");


#############################################################################
##
#F  Arrangements( <mset> [,<k>] )
##
##  <#GAPDoc Label="Arrangements">
##  <ManSection>
##  <Func Name="Arrangements" Arg='mset [,k]'/>
##
##  <Description>
##  returns the  set of arrangements of the multiset <A>mset</A> that contain <A>k</A>
##  elements. If <A>k</A> is not given it returns all arrangements of <A>mset</A>.
##  <P/>
##  An  <E>arrangement</E> of <A>mset</A>  is an ordered selection  without
##  repetitions and is represented by a list that contains only elements
##  from <A>mset</A>, but maybe  in a different  order. If <A>mset</A>  is  a proper
##  set there  are <M>|mset|!  /  (|mset|-k)!</M> (see  <Ref Func="Factorial"/>)
##  arrangements  with  <A>k</A> elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Arrangements");


#############################################################################
##
#F  NrArrangements( <mset> [,<k>] )
##
##  <#GAPDoc Label="NrArrangements">
##  <ManSection>
##  <Func Name="NrArrangements" Arg='mset [,k]'/>
##
##  <Description>
##  returns the number of <C>Arrangements(<A>mset</A>,<A>k</A>)</C>.
##  <P/>
##  As an example of arrangements of a multiset, think of the game Scrabble.
##  Suppose you have the six characters of the word <C>"settle"</C>
##  and you have to make a four letter word.
##  Then the possibilities are given by
##  <P/>
##  <Log><![CDATA[
##  gap> Arrangements( ["s","e","t","t","l","e"], 4 );
##  [ [ "e", "e", "l", "s" ], [ "e", "e", "l", "t" ], [ "e", "e", "s", "l" ],
##    [ "e", "e", "s", "t" ], [ "e", "e", "t", "l" ], [ "e", "e", "t", "s" ],
##    ... 93 more possibilities ...
##    [ "t", "t", "l", "s" ], [ "t", "t", "s", "e" ], [ "t", "t", "s", "l" ] ]
##  ]]></Log>
##  <P/>
##  Can you find the five proper English words,
##  where <C>"lets"</C> does not count?
##  Note that the fact that the  list  returned by <Ref Func="Arrangements"/>
##  is a proper set means in this example that the possibilities are listed
##  in  the same order as they appear in the dictionary.
##  <P/>
##  <Example><![CDATA[
##  gap> NrArrangements( ["s","e","t","t","l","e"] );
##  523
##  ]]></Example>
##  <P/>
##  The function <Ref Func="Combinations"/> computes unordered selections
##  without repetitions,
##  <Ref Func="UnorderedTuples"/> computes unordered selections with
##  repetitions, and
##  <Ref Func="Tuples"/> computes ordered selections with repetitions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrArrangements");


#############################################################################
##
#F  UnorderedTuples( <set>, <k> ) . . . .  set of unordered tuples from a set
##
##  <#GAPDoc Label="UnorderedTuples">
##  <ManSection>
##  <Func Name="UnorderedTuples" Arg='set, k'/>
##
##  <Description>
##  returns the set of all unordered tuples of length <A>k</A> of the set
##  <A>set</A>.
##  <P/>
##  An <E>unordered tuple</E> of length <A>k</A> of <A>set</A> is an
##  unordered selection with repetitions of <A>set</A> and is represented by
##  a sorted list of length <A>k</A> containing elements from <A>set</A>.
##  There  are <M>{{|set| + k - 1 \choose k}}</M> (see <Ref Func="Binomial"/>)
##  such unordered tuples.
##  <P/>
##  Note that the fact that <Ref Func="UnorderedTuples"/> returns a set
##  implies that the last index runs fastest.
##  That means the first tuple contains the smallest element from <A>set</A>
##  <A>k</A> times, the second tuple contains the smallest element of
##  <A>set</A> at all positions except at the last positions,
##  where it contains the second smallest element from <A>set</A> and so on.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("UnorderedTuples");


#############################################################################
##
#F  NrUnorderedTuples( <set>, <k> ) . . number unordered of tuples from a set
##
##  <#GAPDoc Label="NrUnorderedTuples">
##  <ManSection>
##  <Func Name="NrUnorderedTuples" Arg='set, k'/>
##
##  <Description>
##  returns the number of <C>UnorderedTuples(<A>set</A>,<A>k</A>)</C>.
##  <P/>
##  As an example for unordered tuples think of a poker-like game played with
##  5  dice.
##  Then each possible hand corresponds to an unordered five-tuple
##  from the set <M>\{ 1, 2, \ldots, 6 \}</M>.
##  <P/>
##  <Log><![CDATA[
##  gap> NrUnorderedTuples( [1..6], 5 );
##  252
##  gap> UnorderedTuples( [1..6], 5 );
##  [ [ 1, 1, 1, 1, 1 ], [ 1, 1, 1, 1, 2 ], [ 1, 1, 1, 1, 3 ], [ 1, 1, 1, 1, 4 ],
##    [ 1, 1, 1, 1, 5 ], [ 1, 1, 1, 1, 6 ], [ 1, 1, 1, 2, 2 ], [ 1, 1, 1, 2, 3 ],
##    ... 100 more tuples ...
##    [ 1, 3, 5, 5, 6 ], [ 1, 3, 5, 6, 6 ], [ 1, 3, 6, 6, 6 ], [ 1, 4, 4, 4, 4 ],
##    ... 100 more tuples ...
##    [ 3, 3, 5, 5, 5 ], [ 3, 3, 5, 5, 6 ], [ 3, 3, 5, 6, 6 ], [ 3, 3, 6, 6, 6 ],
##    ... 32 more tuples ...
##    [ 5, 5, 5, 6, 6 ], [ 5, 5, 6, 6, 6 ], [ 5, 6, 6, 6, 6 ], [ 6, 6, 6, 6, 6 ] ]
##  ]]></Log>
##  <P/>
##  The function <Ref Func="Combinations"/> computes unordered selections
##  without repetitions,
##  <Ref Func="Arrangements"/> computes ordered selections without
##  repetitions, and
##  <Ref Func="Tuples"/> computes ordered selections with repetitions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrUnorderedTuples");


#############################################################################
##
#F  IteratorOfCartesianProduct( list1, list2, ... )
#F  IteratorOfCartesianProduct( list )
##
##  <#GAPDoc Label="IteratorOfCartesianProduct">
##  <ManSection>
##  <Heading>IteratorOfCartesianProduct</Heading>
##  <Func Name="IteratorOfCartesianProduct" Arg='list1, list2, ...'
##   Label="for several lists"/>
##  <Func Name="IteratorOfCartesianProduct" Arg='list'
##   Label="for a list of lists"/>
##
##  <Description>
##  In the first form
##  <Ref Func="IteratorOfCartesianProduct" Label="for several lists"/>
##  returns  an iterator (see&nbsp;<Ref Sect="Iterators"/>) of all elements
##  of the cartesian product
##  (see&nbsp;<Ref Func="Cartesian" Label="for a list"/>)
##  of the lists <A>list1</A>, <A>list2</A>, etc.
##  <P/>
##  In the second form <A>list</A> must be a list of lists
##  <A>list1</A>, <A>list2</A>, etc.,
##  and <Ref Func="IteratorOfCartesianProduct" Label="for a list of lists"/>
##  returns an iterator of the cartesian product of those lists.
##  <P/>
##  Resulting tuples will be returned in the lexicographic order.
##  Usage of iterators of cartesian products is recommended in the
##  case when the resulting cartesian product is big enough, so its
##  generating and storage will require essential amount of runtime
##  and memory. For smaller cartesian products it is faster to generate the
##  full set of tuples using <Ref Func="Cartesian" Label="for a list"/>
##  and then loop over its elements (with some minor overhead of needing
##  more memory).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorOfCartesianProduct" );
DeclareGlobalFunction("EnumeratorOfCartesianProduct");

#############################################################################
##
#F  Tuples( <set>, <k> )  . . . . . . . . .  set of ordered tuples from a set
##
##  <#GAPDoc Label="Tuples">
##  <ManSection>
##  <Func Name="Tuples" Arg='set, k'/>
##
##  <Description>
##  returns the set of all ordered tuples of length <A>k</A> of the set
##  <A>set</A>.
##  <P/>
##  An <E>ordered tuple</E> of length <A>k</A> of <A>set</A> is an ordered
##  selection with repetition and is represented by a list of length <A>k</A>
##  containing elements of <A>set</A>.
##  There are <M>|<A>set</A>|^{<A>k</A>}</M> such ordered tuples.
##  <P/>
##  Note that the fact that <Ref Func="Tuples"/> returns a set implies that
##  the last index runs fastest.
##  That means the first tuple contains the smallest element from <A>set</A>
##  <A>k</A> times, the second tuple contains the smallest element of
##  <A>set</A> at all positions except at the last positions,
##  where it contains the second smallest element from <A>set</A> and so on.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Tuples");


#############################################################################
##
#F  EnumeratorOfTuples( <set>, <k> )
##
##  <#GAPDoc Label="EnumeratorOfTuples">
##  <ManSection>
##  <Func Name="EnumeratorOfTuples" Arg='set, k'/>
##
##  <Description>
##  This function is referred to as an example of enumerators that are
##  defined by functions but are not constructed from a domain.
##  The result is equal to that of <C>Tuples( <A>set</A>, <A>k</A> )</C>.
##  However, the entries are not stored physically in the list but are
##  created/identified on demand.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  It might be interesting to add analogous enumerator constructors
##  also for other functions that are declared in <F>lib/combinat.gd</F>.
##
DeclareGlobalFunction( "EnumeratorOfTuples" );


#############################################################################
##
#F  IteratorOfTuples( <set>, <k> )
##
##  <#GAPDoc Label="IteratorOfTuples">
##  <ManSection>
##  <Func Name="IteratorOfTuples" Arg='set, k'/>
##
##  <Description>
##  For a set <A>set</A> and a positive integer <A>k</A>,
##  <Ref Func="IteratorOfTuples"/>
##  returns an iterator (see&nbsp;<Ref Sect="Iterators"/>) of the set of
##  all ordered tuples (see&nbsp;<Ref Func="Tuples"/>) of length <A>k</A>
##  of the set <A>set</A>. The tuples are returned in lexicographic order.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorOfTuples" );


#############################################################################
##
#F  NrTuples( <set>, <k> )  . . . . . . . number of ordered tuples from a set
##
##  <#GAPDoc Label="NrTuples">
##  <ManSection>
##  <Func Name="NrTuples" Arg='set, k'/>
##
##  <Description>
##  returns the number of <C>Tuples(<A>set</A>,<A>k</A>)</C>.
##  <Example><![CDATA[
##  gap> Tuples( [1,2,3], 2 );
##  [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 3 ],
##    [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]
##  gap> NrTuples( [1..10], 5 );
##  100000
##  ]]></Example>
##  <P/>
##  <C>Tuples(<A>set</A>,<A>k</A>)</C> can also be viewed as the
##  <A>k</A>-fold cartesian product of <A>set</A>
##  (see <Ref Func="Cartesian" Label="for a list"/>).
##  <P/>
##  The function <Ref Func="Combinations"/> computes unordered selections
##  without repetitions,
##  <Ref Func="Arrangements"/> computes ordered selections without
##  repetitions, and finally the function
##  <Ref Func="UnorderedTuples"/> computes unordered selections
##  with repetitions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrTuples");


#############################################################################
##
#F  PermutationsList( <mset> )  . . . . . . set of permutations of a multiset
##
##  <#GAPDoc Label="PermutationsList">
##  <ManSection>
##  <Func Name="PermutationsList" Arg='mset'/>
##
##  <Description>
##  <Ref Func="PermutationsList"/> returns the set of permutations of the
##  multiset <A>mset</A>.
##  <P/>
##  A <E>permutation</E> is represented by a list that contains exactly the
##  same elements as <A>mset</A>, but possibly in different order.
##  If <A>mset</A> is a proper set there are <M>|<A>mset</A>| !</M>
##  (see <Ref Func="Factorial"/>) such permutations.
##  Otherwise if the first elements appears <M>k_1</M> times,
##  the second element appears <M>k_2</M> times and so on,
##  the number of permutations is
##  <M>|<A>mset</A>| ! / (k_1! k_2! \ldots)</M>,
##  which is sometimes called multinomial coefficient.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PermutationsList");


#############################################################################
##
#F  NrPermutationsList( <mset> )  . . .  number of permutations of a multiset
##
##  <#GAPDoc Label="NrPermutationsList">
##  <ManSection>
##  <Func Name="NrPermutationsList" Arg='mset'/>
##
##  <Description>
##  returns the number of <C>PermutationsList(<A>mset</A>)</C>.
##  <Example><![CDATA[
##  gap> PermutationsList( [1,2,3] );
##  [ [ 1, 2, 3 ], [ 1, 3, 2 ], [ 2, 1, 3 ], [ 2, 3, 1 ], [ 3, 1, 2 ],
##    [ 3, 2, 1 ] ]
##  gap> PermutationsList( [1,1,2,2] );
##  [ [ 1, 1, 2, 2 ], [ 1, 2, 1, 2 ], [ 1, 2, 2, 1 ], [ 2, 1, 1, 2 ],
##    [ 2, 1, 2, 1 ], [ 2, 2, 1, 1 ] ]
##  gap> NrPermutationsList( [1,2,2,3,3,3,4,4,4,4] );
##  12600
##  ]]></Example>
##  <P/>
##  The function <Ref Func="Arrangements"/> is the generalization of
##  <Ref Func="PermutationsList"/> that allows you to specify the size of the
##  permutations.
##  <Ref Func="Derangements"/> computes permutations that have no fixed
##  points.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrPermutationsList");


#############################################################################
##
#F  Derangements( <list> ) . . . . set of fixpointfree permutations of a list
##
##  <#GAPDoc Label="Derangements">
##  <ManSection>
##  <Func Name="Derangements" Arg='list'/>
##
##  <Description>
##  returns the set of all derangements of the list <A>list</A>.
##  <P/>
##  A <E>derangement</E> is a fixpointfree permutation of <A>list</A> and
##  is represented by a list that contains exactly the same elements as
##  <A>list</A>, but in such an order that the derangement has at no position
##  the same element as <A>list</A>.
##  If the list <A>list</A> contains no element twice there are exactly
##  <M>|<A>list</A>|! (1/2! - 1/3! + 1/4! - \cdots + (-1)^n / n!)</M>
##  derangements.
##  <P/>
##  Note that the ratio
##  <C>NrPermutationsList( [ 1 .. n ] ) / NrDerangements( [ 1 .. n ] )</C>,
##  which is <M>n! / (n! (1/2! - 1/3! + 1/4! - \cdots + (-1)^n / n!))</M>
##  is an approximation for the base of the natural logarithm
##  <M>e = 2.7182818285\ldots</M>, which is correct to about <M>n</M> digits.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Derangements");


#############################################################################
##
#F  NrDerangements( <list> ) .  number of fixpointfree permutations of a list
##
##  <#GAPDoc Label="NrDerangements">
##  <ManSection>
##  <Func Name="NrDerangements" Arg='list'/>
##
##  <Description>
##  returns the number of <C>Derangements(<A>list</A>)</C>.
##  <P/>
##  As an  example of  derangements suppose    that  you have  to  send  four
##  different letters  to   four  different  people.    Then  a   derangement
##  corresponds  to a way  to send those letters such  that no letter reaches
##  the intended person.
##  <P/>
##  <Example><![CDATA[
##  gap> Derangements( [1,2,3,4] );
##  [ [ 2, 1, 4, 3 ], [ 2, 3, 4, 1 ], [ 2, 4, 1, 3 ], [ 3, 1, 4, 2 ],
##    [ 3, 4, 1, 2 ], [ 3, 4, 2, 1 ], [ 4, 1, 2, 3 ], [ 4, 3, 1, 2 ],
##    [ 4, 3, 2, 1 ] ]
##  gap> NrDerangements( [1..10] );
##  1334961
##  gap> Int( 10^7*NrPermutationsList([1..10])/last );
##  27182816
##  gap> Derangements( [1,1,2,2,3,3] );
##  [ [ 2, 2, 3, 3, 1, 1 ], [ 2, 3, 1, 3, 1, 2 ], [ 2, 3, 1, 3, 2, 1 ],
##    [ 2, 3, 3, 1, 1, 2 ], [ 2, 3, 3, 1, 2, 1 ], [ 3, 2, 1, 3, 1, 2 ],
##    [ 3, 2, 1, 3, 2, 1 ], [ 3, 2, 3, 1, 1, 2 ], [ 3, 2, 3, 1, 2, 1 ],
##    [ 3, 3, 1, 1, 2, 2 ] ]
##  gap> NrDerangements( [1,2,2,3,3,3,4,4,4,4] );
##  338
##  ]]></Example>
##  <P/>
##  The function  <Ref Func="PermutationsList"/>  computes all
##  permutations of a list.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrDerangements");


#############################################################################
##
#F  PartitionsSet( <set> [,<k>] )
##
##  <#GAPDoc Label="PartitionsSet">
##  <ManSection>
##  <Func Name="PartitionsSet" Arg='set [,k]'/>
##
##  <Description>
##  returns the  set  of  all unordered
##  partitions of the set <A>set</A> into  <A>k</A> pairwise disjoint nonempty sets.
##  If <A>k</A> is not given it returns all unordered partitions of <A>set</A> for all
##  <A>k</A>.
##  <P/>
##  An <E>unordered partition</E> of <A>set</A> is  a set of pairwise disjoint
##  nonempty sets with union <A>set</A>  and is represented by  a sorted list of
##  such sets.  There are <M>B( |set| )</M> (see <Ref Func="Bell"/>) partitions of  the
##  set  <A>set</A>  and <M>S_2( |set|, k )</M> (see <Ref Func="Stirling2"/>) partitions with
##  <A>k</A> elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PartitionsSet");


#############################################################################
##
#F  NrPartitionsSet( <set>[, <k>] )
##
##  <#GAPDoc Label="NrPartitionsSet">
##  <ManSection>
##  <Func Name="NrPartitionsSet" Arg='set[, k]'/>
##
##  <Description>
##  returns the number of <C>PartitionsSet(<A>set</A>,<A>k</A>)</C>.
##  <Example><![CDATA[
##  gap> PartitionsSet( [1,2,3] );
##  [ [ [ 1 ], [ 2 ], [ 3 ] ], [ [ 1 ], [ 2, 3 ] ], [ [ 1, 2 ], [ 3 ] ],
##    [ [ 1, 2, 3 ] ], [ [ 1, 3 ], [ 2 ] ] ]
##  gap> PartitionsSet( [1,2,3,4], 2 );
##  [ [ [ 1 ], [ 2, 3, 4 ] ], [ [ 1, 2 ], [ 3, 4 ] ],
##    [ [ 1, 2, 3 ], [ 4 ] ], [ [ 1, 2, 4 ], [ 3 ] ],
##    [ [ 1, 3 ], [ 2, 4 ] ], [ [ 1, 3, 4 ], [ 2 ] ],
##    [ [ 1, 4 ], [ 2, 3 ] ] ]
##  gap> NrPartitionsSet( [1..6] );
##  203
##  gap> NrPartitionsSet( [1..10], 3 );
##  9330
##  ]]></Example>
##  <P/>
##  Note that <Ref Func="PartitionsSet"/> does currently not support
##  multisets and that there is currently no ordered counterpart.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrPartitionsSet");


#############################################################################
##
#F  Partitions( <n>[, <k>])
##
##  <#GAPDoc Label="Partitions">
##  <ManSection>
##  <Func Name="Partitions" Arg='n[, k]'/>
##
##  <Description>
##  returns the set of all (unordered) partitions of the positive integer
##  <A>n</A> into sums with <A>k</A> summands.
##  If <A>k</A> is not given it returns all unordered partitions of
##  <A>n</A> for all <A>k</A>.
##  <P/>
##  An <E>unordered partition</E> is an unordered sum
##  <M>n = p_1 + p_2 + \cdots + p_k</M>
##  of positive integers and is represented by the list
##  <M>p = [ p_1, p_2, \ldots, p_k ]</M>, in nonincreasing order, i.e.,
##  <M>p_1 \geq p_2 \geq \ldots \geq p_k</M>.
##  We write <M>p \vdash n</M>.
##  There are approximately
##  <M>\exp(\pi \sqrt{{2/3 n}}) / (4 \sqrt{{3}} n)</M> such partitions,
##  use <Ref Func="NrPartitions"/> to compute the precise number.
##  <P/>
##  If you want to loop over all partitions of some larger <A>n</A> use
##  the more memory efficient <Ref Func="IteratorOfPartitions"/>.
##  <P/>
##  It is possible to associate with every partition of the integer <A>n</A>
##  a conjugacy class of permutations in the symmetric group on <A>n</A>
##  points and vice versa.
##  Therefore <M>p(n) := </M><C>NrPartitions</C><M>(n)</M> is the
##  number of conjugacy classes of the symmetric group on <A>n</A> points.
##  <P/>
##  Ramanujan found the identities <M>p(5i+4) = 0</M> mod 5,
##  <M>p(7i+5) = 0</M>  mod 7 and <M>p(11i+6) = 0</M> mod 11
##  and many other fascinating things about the number of partitions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PartitionsRecursively");
DeclareGlobalFunction("Partitions");


#############################################################################
##
#F  NrPartitions( <n> [,<k>])
##
##  <#GAPDoc Label="NrPartitions">
##  <ManSection>
##  <Func Name="NrPartitions" Arg='n [,k]'/>
##
##  <Description>
##  returns the number of <C>Partitions(<A>set</A>,<A>k</A>)</C>.
##  <Example><![CDATA[
##  gap> Partitions( 7 );
##  [ [ 1, 1, 1, 1, 1, 1, 1 ], [ 2, 1, 1, 1, 1, 1 ], [ 2, 2, 1, 1, 1 ],
##    [ 2, 2, 2, 1 ], [ 3, 1, 1, 1, 1 ], [ 3, 2, 1, 1 ], [ 3, 2, 2 ],
##    [ 3, 3, 1 ], [ 4, 1, 1, 1 ], [ 4, 2, 1 ], [ 4, 3 ], [ 5, 1, 1 ],
##    [ 5, 2 ], [ 6, 1 ], [ 7 ] ]
##  gap> Partitions( 8, 3 );
##  [ [ 3, 3, 2 ], [ 4, 2, 2 ], [ 4, 3, 1 ], [ 5, 2, 1 ], [ 6, 1, 1 ] ]
##  gap> NrPartitions( 7 );
##  15
##  gap> NrPartitions( 100 );
##  190569292
##  ]]></Example>
##  <P/>
##  The function <Ref Func="OrderedPartitions"/> is the ordered
##  counterpart of <Ref Func="Partitions"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrPartitions");


#############################################################################
##
#F  PartitionsGreatestLE( <n>, <m> ) . . .  set of partitions of n parts <= n
##
##  <#GAPDoc Label="PartitionsGreatestLE">
##  <ManSection>
##  <Func Name="PartitionsGreatestLE" Arg='n, m'/>
##
##  <Description>
##  returns the set of all (unordered) partitions of the integer <A>n</A>
##  having parts less or equal to the integer <A>m</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PartitionsGreatestLE");


#############################################################################
##
#F  PartitionsGreatestEQ( <n>, <m> ) . . . . set of partitions of n parts = n
##
##  <#GAPDoc Label="PartitionsGreatestEQ">
##  <ManSection>
##  <Func Name="PartitionsGreatestEQ" Arg='n, m'/>
##
##  <Description>
##  returns the set of all (unordered) partitions of the integer <A>n</A>
##  having greatest part equal to the integer <A>m</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PartitionsGreatestEQ");


#############################################################################
##
#F  OrderedPartitions( <n> [,<k>] )
##
##  <#GAPDoc Label="OrderedPartitions">
##  <ManSection>
##  <Func Name="OrderedPartitions" Arg='n [,k]'/>
##
##  <Description>
##  returns the set of all ordered partitions
##  <Index Subkey="ordered, of an integer">partitions</Index>
##  <Index Subkey="improper, of an integer">partitions</Index>
##  of the positive integer <A>n</A> into sums with <A>k</A> summands.
##  If <A>k</A> is not given it returns all ordered partitions of <A>set</A>
##  for all <A>k</A>.
##  <P/>
##  An <E>ordered partition</E> is an ordered sum
##  <M>n = p_1 + p_2 + \ldots + p_k</M> of positive integers and is
##  represented by the list <M>[ p_1, p_2, \ldots, p_k ]</M>.
##  There are totally <M>2^{{n-1}}</M> ordered partitions and
##  <M>{{n-1 \choose k-1}}</M> (see <Ref Func="Binomial"/>)
##  ordered partitions with <A>k</A> summands.
##  <P/>
##  Do not call <Ref Func="OrderedPartitions"/> with an <A>n</A> much larger
##  than <M>15</M>, the list will simply become too large.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OrderedPartitions");


#############################################################################
##
#F  NrOrderedPartitions( <n> [,<k>] )
##
##  <#GAPDoc Label="NrOrderedPartitions">
##  <ManSection>
##  <Func Name="NrOrderedPartitions" Arg='n [,k]'/>
##
##  <Description>
##  returns the number of <C>OrderedPartitions(<A>set</A>,<A>k</A>)</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> OrderedPartitions( 5 );
##  [ [ 1, 1, 1, 1, 1 ], [ 1, 1, 1, 2 ], [ 1, 1, 2, 1 ], [ 1, 1, 3 ],
##    [ 1, 2, 1, 1 ], [ 1, 2, 2 ], [ 1, 3, 1 ], [ 1, 4 ], [ 2, 1, 1, 1 ],
##    [ 2, 1, 2 ], [ 2, 2, 1 ], [ 2, 3 ], [ 3, 1, 1 ], [ 3, 2 ],
##    [ 4, 1 ], [ 5 ] ]
##  gap> OrderedPartitions( 6, 3 );
##  [ [ 1, 1, 4 ], [ 1, 2, 3 ], [ 1, 3, 2 ], [ 1, 4, 1 ], [ 2, 1, 3 ],
##    [ 2, 2, 2 ], [ 2, 3, 1 ], [ 3, 1, 2 ], [ 3, 2, 1 ], [ 4, 1, 1 ] ]
##  gap> NrOrderedPartitions(20);
##  524288
##  ]]></Example>
##  <P/>
##  The function <Ref Func="Partitions"/> is the unordered counterpart
##  of <Ref Func="OrderedPartitions"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrOrderedPartitions");


#############################################################################
##
#F  RestrictedPartitions( <n>, <set> [,<k>] )
##
##  <#GAPDoc Label="RestrictedPartitions">
##  <ManSection>
##  <Func Name="RestrictedPartitions" Arg='n, set [,k]'/>
##
##  <Description>
##  In the first form <Ref Func="RestrictedPartitions"/> returns the set of
##  all restricted partitions
##  <Index Subkey="restricted, of an integer">partitions</Index>
##  of the positive integer <A>n</A> into sums with <A>k</A> summands
##  with the summands of the partition coming from the set <A>set</A>.
##  If <A>k</A> is not given all restricted partitions for all <A>k</A> are
##  returned.
##  <P/>
##  A <E>restricted partition</E> is like an ordinary partition
##  (see <Ref Func="Partitions"/>) an unordered sum
##  <M>n = p_1 + p_2 + \ldots + p_k</M> of positive integers
##  and is represented by the list <M>p = [ p_1, p_2, \ldots, p_k ]</M>,
##  in nonincreasing order.
##  The difference is that here the <M>p_i</M> must be elements from the set
##  <A>set</A>,
##  while for ordinary partitions they may be elements from
##  <C>[ 1 .. n ]</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RestrictedPartitions");


#############################################################################
##
#F  NrRestrictedPartitions( <n>, <set>[, <k>] )
##
##  <#GAPDoc Label="NrRestrictedPartitions">
##  <ManSection>
##  <Func Name="NrRestrictedPartitions" Arg='n, set[, k]'/>
##
##  <Description>
##  returns the number of
##  <C>RestrictedPartitions(<A>n</A>,<A>set</A>,<A>k</A>)</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> RestrictedPartitions( 8, [1,3,5,7] );
##  [ [ 1, 1, 1, 1, 1, 1, 1, 1 ], [ 3, 1, 1, 1, 1, 1 ], [ 3, 3, 1, 1 ],
##    [ 5, 1, 1, 1 ], [ 5, 3 ], [ 7, 1 ] ]
##  gap> NrRestrictedPartitions(50,[1,2,5,10,20,50]);
##  451
##  ]]></Example>
##  <P/>
##  The last example tells us that there are 451 ways to return 50 pence
##  change using 1, 2, 5, 10, 20 and 50 pence coins.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrRestrictedPartitions");


#############################################################################
##
#F  IteratorOfPartitions( <n> )
##
##  <#GAPDoc Label="IteratorOfPartitions">
##  <ManSection>
##  <Func Name="IteratorOfPartitions" Arg='n'/>
##
##  <Description>
##  For a positive integer <A>n</A>, <Ref Func="IteratorOfPartitions" />
##  returns an iterator
##  (see&nbsp;<Ref Sect="Iterators"/>) of the set of partitions
##  of <A>n</A> (see&nbsp;<Ref Func="Partitions"/>).
##  The partitions of <A>n</A> are returned in lexicographic order.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorOfPartitions" );


#############################################################################
##
#F  IteratorOfPartitionsSet( <set> [, <k> [ <flag> ] ] )
##
##  <#GAPDoc Label="IteratorOfPartitionsSet">
##  <ManSection>
##  <Func Name="IteratorOfPartitionsSet" Arg='set [, k [ flag ] ]'/>
##
##  <Description>
##  <Ref Func="IteratorOfPartitionsSet" /> returns an iterator
##  (see&nbsp;<Ref Sect="Iterators"/>) for all unordered partitions of the
##  set <A>set</A> into pairwise disjoint nonempty sets
##  (see <Ref Func="PartitionsSet"/>).
##  If <A>k</A> given and <A>flag</A> is omitted or equal to <K>false</K>,
##  then only partitions of size <A>k</A> are computed.
##  If <A>k</A> is given and <A>flag</A> is equal to <K>true</K>,
##  then only partitions of size at most <A>k</A> are computed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorOfPartitionsSet" );


#############################################################################
##
#F  SignPartition( <pi> ) . . . . . . . . . . . . .  sign of partition <pi>
##
##  <#GAPDoc Label="SignPartition">
##  <ManSection>
##  <Func Name="SignPartition" Arg='pi'/>
##
##  <Description>
##  returns the sign of a permutation with cycle structure <A>pi</A>.
##  <P/>
##  This function actually describes  a homomorphism from  the  symmetric
##  group <M>S_n</M> into  the  cyclic group of order  2,  whose  kernel  is
##  exactly the alternating  group <M>A_n</M>  (see <Ref Attr="SignPerm"/>).  Partitions  of
##  sign  1  are called <E>even</E> partitions while partitions of sign <M>-1</M> are
##  called <E>odd</E>.
##  <Example><![CDATA[
##  gap> SignPartition([6,5,4,3,2,1]);
##  -1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SignPartition");


#############################################################################
##
#F  AssociatedPartition( <pi> )
##
##  <#GAPDoc Label="AssociatedPartition">
##  <ManSection>
##  <Func Name="AssociatedPartition" Arg='pi'/>
##
##  <Description>
##  <Ref Func="AssociatedPartition"/> returns the associated partition of the
##  partition <A>pi</A> which is obtained by transposing the corresponding
##  Young diagram.
##  <P/>
##  <Example><![CDATA[
##  gap> AssociatedPartition([4,2,1]);
##  [ 3, 2, 1, 1 ]
##  gap> AssociatedPartition([6]);
##  [ 1, 1, 1, 1, 1, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AssociatedPartition");


#############################################################################
##
#F  PowerPartition( <pi>, <k> ) . . . . . . . . . . . .  power of a partition
##
##  <#GAPDoc Label="PowerPartition">
##  <ManSection>
##  <Func Name="PowerPartition" Arg='pi, k'/>
##
##  <Description>
##  <Ref Func="PowerPartition"/> returns the partition corresponding to the
##  <A>k</A>-th power of a permutation with cycle structure <A>pi</A>.
##  <P/>
##  Each part <M>l</M> of <A>pi</A> is replaced by <M>d = \gcd(l, k)</M>
##  parts <M>l/d</M>.
##  So if <A>pi</A> is a partition of <M>n</M> then
##  <M><A>pi</A>^{<A>k</A>}</M> also is a partition of <M>n</M>.
##  <Ref Func="PowerPartition"/> describes the power map
##  <Index Subkey="power map">symmetric group</Index>
##  of symmetric groups.
##  <P/>
##  <Example><![CDATA[
##  gap> PowerPartition([6,5,4,3,2,1], 3);
##  [ 5, 4, 2, 2, 2, 2, 1, 1, 1, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PowerPartition");


#############################################################################
##
#F  PartitionTuples( <n>, <r> ) . . . . . . . . . <r> partitions with sum <n>
##
##  <#GAPDoc Label="PartitionTuples">
##  <ManSection>
##  <Func Name="PartitionTuples" Arg='n, r'/>
##
##  <Description>
##  <Ref Func="PartitionTuples"/> returns the list of all <A>r</A>-tuples of
##  partitions which together form a partition of <A>n</A>.
##  <P/>
##  <A>r</A>-tuples of partitions describe the classes and the characters
##  of wreath products of groups with <A>r</A> conjugacy classes with the
##  symmetric group on <A>n</A> points,
##  see <Ref Func="CharacterTableWreathSymmetric"/>
##  and <Ref Func="CharacterValueWreathSymmetric"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PartitionTuples");


#############################################################################
##
#F  NrPartitionTuples( <n>, <r> )
##
##  <#GAPDoc Label="NrPartitionTuples">
##  <ManSection>
##  <Func Name="NrPartitionTuples" Arg='n, r'/>
##
##  <Description>
##  returns the number of <C>PartitionTuples( <A>n</A>, <A>r</A> )</C>.
##  <Example><![CDATA[
##  gap> PartitionTuples(3, 2);
##  [ [ [ 1, 1, 1 ], [  ] ], [ [ 1, 1 ], [ 1 ] ], [ [ 1 ], [ 1, 1 ] ],
##    [ [  ], [ 1, 1, 1 ] ], [ [ 2, 1 ], [  ] ], [ [ 1 ], [ 2 ] ],
##    [ [ 2 ], [ 1 ] ], [ [  ], [ 2, 1 ] ], [ [ 3 ], [  ] ],
##    [ [  ], [ 3 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrPartitionTuples");


#############################################################################
##
#F  Lucas( <P>, <Q>, <k> )  . . . . . . . . . . . . value of a Lucas sequence
##
##  <#GAPDoc Label="Lucas">
##  <ManSection>
##  <Func Name="Lucas" Arg='P, Q, k'/>
##
##  <Description>
##  returns the <A>k</A>-th values of the <E>Lucas sequence</E>
##  <Index Subkey="Lucas">sequence</Index>
##  with parameters <A>P</A>
##  and <A>Q</A>, which must be integers, as a list of three integers.
##  If <A>k</A> is a negative integer, then the values of the Lucas sequence
##  may be nonintegral rational numbers,
##  with denominator roughly <A>Q</A>^<A>k</A>.
##  <P/>
##  Let <M>\alpha, \beta</M> be the two roots of  <M>x^2 - P x + Q</M>
##  then we define
##  <C>Lucas( <A>P</A>, <A>Q</A>, <A>k</A> )[1]</C> <M>= U_k =
##  (\alpha^k - \beta^k) / (\alpha - \beta)</M>
##  and <C>Lucas( <A>P</A>, <A>Q</A>, <A>k</A> )[2]</C>
##  <M>= V_k = (\alpha^k + \beta^k)</M> and as a convenience
##  <C>Lucas( <A>P</A>, <A>Q</A>, <A>k</A> )[3]</C> <M>= Q^k</M>.
##  <P/>
##  The following recurrence relations are easily derived from the definition
##  <M>U_0 = 0, U_1 = 1, U_k = P U_{{k-1}} - Q U_{{k-2}}</M> and
##  <M>V_0 = 2, V_1 = P, V_k = P V_{{k-1}} - Q V_{{k-2}}</M>.
##  Those relations are actually used to define <Ref Func="Lucas"/> if
##  <M>\alpha = \beta</M>.
##  <P/>
##  Also the more complex relations used in <Ref Func="Lucas"/> can be easily
##  derived
##  <M>U_{2k} = U_k V_k</M>, <M>U_{{2k+1}} = (P U_{2k} + V_{2k}) / 2</M> and
##  <M>V_{2k} = V_k^2 - 2 Q^k</M>,
##  <M>V_{{2k+1}} = ((P^2-4Q) U_{2k} + P V_{2k}) / 2</M>.
##  <P/>
##  <C>Fibonacci(<A>k</A>)</C> (see <Ref Func="Fibonacci"/>) is simply
##  <C>Lucas(1,-1,<A>k</A>)[1]</C>.
##  In an abuse of notation, the sequence <C>Lucas(1,-1,<A>k</A>)[2]</C>
##  is sometimes called the Lucas sequence.
##  <P/>
##  <Example><![CDATA[
##  gap> List( [0..10], i -> Lucas(1,-2,i)[1] );     # 2^k - (-1)^k)/3
##  [ 0, 1, 1, 3, 5, 11, 21, 43, 85, 171, 341 ]
##  gap> List( [0..10], i -> Lucas(1,-2,i)[2] );     # 2^k + (-1)^k
##  [ 2, 1, 5, 7, 17, 31, 65, 127, 257, 511, 1025 ]
##  gap> List( [0..10], i -> Lucas(1,-1,i)[1] );     # Fibonacci sequence
##  [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ]
##  gap> List( [0..10], i -> Lucas(2,1,i)[1] );      # the roots are equal
##  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Lucas");


##############################################################################
##
#F  LucasMod( <P>, <Q>, <N>, <k> )
##
##  <ManSection>
##  <Func Name="LucasMod" Arg='P, Q, N, k'/>
##
##  <Description>
##  This function returns the reduction modulo N of the <A>k</A>-th terms of
##  the Lucas sequences U, V associated to <M>x^2 + Px + Q</M>.
##  <P/>
##  The Lucas sequences are calculated recursively, and this routine ensures
##  intermediate results are reduced mod <A>N</A> as well.
##  Thus <C>LucasMod( <A>P</A>, <A>Q</A>, <A>N</A>, <A>k</A> )</C>
##  is much faster than (but equivalent to)
##  <C>Lucas( <A>P</A>, <A>Q</A>, <A>k</A> ) mod <A>N</A></C>.
##  <P/>
##  If <A>k</A> is negative, then this function may return <K>fail</K> if the
##  reduction mod <A>N</A> does not exist (because U, V are rational numbers
##  with denominators sharing a prime factor with <A>N</A>).
##  </Description>
##  </ManSection>
##
DeclareOperation("LucasMod",[IsInt,IsInt,IsInt,IsInt]);


#############################################################################
##
#F  Fibonacci( <n> )  . . . . . . . . . . . . value of the Fibonacci sequence
##
##  <#GAPDoc Label="Fibonacci">
##  <ManSection>
##  <Func Name="Fibonacci" Arg='n'/>
##
##  <Description>
##  returns the <A>n</A>th number of the <E>Fibonacci sequence</E>.
##  The Fibonacci sequence <M>F_n</M>
##  <Index Subkey="Fibonacci">sequence</Index>
##  is defined by the initial conditions <M>F_1 = F_2 = 1</M> and  the
##  recurrence relation <M>F_{{n+2}} = F_{{n+1}} + F_n</M>.
##  For negative <M>n</M> we define <M>F_n = (-1)^{{n+1}} F_{{-n}}</M>,
##  which is consistent with the recurrence relation.
##  <P/>
##  Using generating functions one can prove that
##  <M>F_n = \phi^n - 1/\phi^n</M>,
##  where <M>\phi</M> is <M>(\sqrt{{5}} + 1)/2</M>,
##  i.e., one root of <M>x^2 - x - 1 = 0</M>.
##  Fibonacci numbers have the property
##  <M>\gcd( F_m, F_n ) = F_{{\gcd(m,n)}}</M>.
##  But a pair of Fibonacci numbers requires more division
##  steps in Euclid's algorithm
##  (see&nbsp;<Ref Func="Gcd" Label="for (a ring and) several elements"/>)
##  than any other pair of integers of the same size.
##  <C>Fibonacci(<A>k</A>)</C> is the special case
##  <C>Lucas(1,-1,<A>k</A>)[1]</C> (see <Ref Func="Lucas"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> Fibonacci( 10 );
##  55
##  gap> Fibonacci( 35 );
##  9227465
##  gap> Fibonacci( -10 );
##  -55
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Fibonacci");


#############################################################################
##
#F  Bernoulli( <n> )  . . . . . . . . . . . . value of the Bernoulli sequence
##
##  <#GAPDoc Label="Bernoulli">
##  <ManSection>
##  <Func Name="Bernoulli" Arg='n'/>
##
##  <Description>
##  returns the <A>n</A>-th <E>Bernoulli number</E>
##  <Index Subkey="Bernoulli">sequence</Index>
##  <M>B_n</M>, which is defined by
##  <M>B_0 = 1</M> and
##  <M>B_n = -\sum_{{k = 0}}^{{n-1}} {{n+1 \choose k}} B_k/(n+1)</M>.
##  <P/>
##  <M>B_n / n!</M> is the coefficient of <M>x^n</M> in the power series of
##  <M>x / (\exp(x)-1)</M>.
##  Except for <M>B_1 = -1/2</M>
##  the Bernoulli numbers for odd indices are zero.
##  <P/>
##  <Example><![CDATA[
##  gap> Bernoulli( 4 );
##  -1/30
##  gap> Bernoulli( 10 );
##  5/66
##  gap> Bernoulli( 12 );  # there is no simple pattern in Bernoulli numbers
##  -691/2730
##  gap> Bernoulli( 50 );  # and they grow fairly fast
##  495057205241079648212477525/66
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Bernoulli");


#############################################################################
##
#F  Permanent( <mat> )  . . . . . . . . . . . . . . . . permanent of a matrix
##
##  <#GAPDoc Label="Permanent">
##  <ManSection>
##  <Attr Name="Permanent" Arg='mat'/>
##
##  <Description>
##  returns the <E>permanent</E> of the matrix <A>mat</A>.
##  The permanent is defined by
##  <M>\sum_{{p \in Sym(n)}} \prod_{{i = 1}}^n mat[i][i^p]</M>.
##  <P/>
##  Note the similarity of the definition of the permanent to the
##  definition of the determinant (see&nbsp;<Ref Attr="DeterminantMat"/>).
##  In fact the only difference is the missing sign of the permutation.
##  However the permanent is quite unlike the determinant,
##  for example it is not multilinear or alternating.
##  It has however important combinatorial properties.
##  <P/>
##  <Example><![CDATA[
##  gap> Permanent( [[0,1,1,1],
##  >      [1,0,1,1],
##  >      [1,1,0,1],
##  >      [1,1,1,0]] );  # inefficient way to compute NrDerangements([1..4])
##  9
##  gap> # 24 permutations fit the projective plane of order 2:
##  gap> Permanent( [[1,1,0,1,0,0,0],
##  >      [0,1,1,0,1,0,0],
##  >      [0,0,1,1,0,1,0],
##  >      [0,0,0,1,1,0,1],
##  >      [1,0,0,0,1,1,0],
##  >      [0,1,0,0,0,1,1],
##  >      [1,0,1,0,0,0,1]] );
##  24
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Permanent", IsMatrix);


#############################################################################
##
#F  AllLinearDiophantineSolutions(<n>,<max>,<sum>)
##
##  <#GAPDoc Label="AllLinearDiophantineSolutions">
##  <ManSection>
##  <Func Name="AllLinearDiophantineSolutions" Arg='n,maxx,sum'/>
##
##  <Description>
##  For a list <A>n</A> of positive integers, an integer <A>sum</A>, and a list
##  of nonnegative integers <A>max</A>, this function returns a list of all
##  nonnegative coefficient vectors <A>v</A>, such that <M>n\cdot v=sum</M>, and
##  <M>v\le max</M> in each entry.
##  <P/>
##  <Example><![CDATA[
##  gap> AllLinearDiophantineSolutions([6,10,15],[10,10,10],57);
##  [ [ 7, 0, 1 ], [ 2, 3, 1 ], [ 2, 0, 3 ] ]
##  gap> AllLinearDiophantineSolutions([6,10,15],[6,4,4],57);
##  [ [ 2, 3, 1 ], [ 2, 0, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AllLinearDiophantineSolutions");

#############################################################################
##
#F  AllSubsetSummations( <to>,<from> [,<limit>] )
##
##  <#GAPDoc Label="AllSubsetSummations">
##  <ManSection>
##  <Func Name="AllSubsetSummations" Arg='to,from [,limit]'/>
##
##  <Description>
##  returns a list of all partitions of the entries in <A>from</A> such that the
##  entries in each cell sum up to the corresponding entry in <A>to</A>. If a bound
##  <A>limit</A> is given, the function stops (and returns <A>fail</A>) if the length
##  of the list created would exceed <A>limit</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> AllSubsetSummations([63,672],[21,42,42,42,42,42,168,168,168 ]);
##  [ [ [ 1, 2 ], [ 3 .. 9 ] ], [ [ 1, 3 ], [ 2, 4, 5, 6, 7, 8, 9 ] ],
##    [ [ 1, 4 ], [ 2, 3, 5, 6, 7, 8, 9 ] ], [ [ 1, 5 ], [ 2, 3, 4, 6, 7, 8, 9 ] ],
##    [ [ 1, 6 ], [ 2, 3, 4, 5, 7, 8, 9 ] ] ]
##  gap> l:=[21,42,42,42,42,42,168,168,168];;
##  gap> Length(AllSubsetSummations([105,210,210,210],l));
##  360
##  gap> AllSubsetSummations([105,210,210,210],l,300);
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AllSubsetSummations");
