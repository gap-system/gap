#############################################################################
##
#W  combinat.gi      GAP library       Martin Schoenert
#W                     Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains declaration for combinatoric functions.
##
Revision.combinat_gd :=
  "@(#)$Id$";


#############################################################################
##
#F  Factorial( <n> )  . . . . . . . . . . . . . . . . factorial of an integer
##
##  returns the *factorial*  $n!$  of the positive  integer <n>, which is
##  defined as the product $1 \* 2 \* 3 \* .. \* n$.
##
##  $n!$ is the  number of permutations of a set of $n$ elements.  $1/n!$
##  is the coefficient  of  $x^n$  in  the  formal series  $e^x$, which  is
##  the generating function for factorial.
DeclareGlobalFunction("Factorial");


#############################################################################
##
#F  Binomial( <n>, <k> )  . . . . . . . . .  binomial coefficient of integers
##
##  returns the *binomial coefficient* ${n \choose k}$ of integers <n> and
##  <k>, which  is defined as $n!  / (k!  (n-k)!)$ (see "Factorial").  We
##  define ${0 \choose 0} = 1$, ${n \choose  k} = 0$  if $k\<0$ or $n\<k$,
##  and ${n \choose k} = (-1)^k {-n+k-1  \choose  k}$ if  $n \<  0$, which
##  is consistent with ${n \choose k} = {n-1 \choose k} + {n-1 \choose
##  k-1}$.
## 
##  ${n \choose k}$ is the number of combinations with  $k$  elements,  i.e.,
##  the number of subsets with $k$ elements, of  a  set  with  $n$  elements.
##  ${n \choose k}$  is the coefficient of the  term $x^k$ of the  polynomial
##  $(x + 1)^n$, which is the generating function for ${n \choose \*}$, hence
##  the name.
DeclareGlobalFunction("Binomial");


#############################################################################
##
#F  Bell( <n> ) . . . . . . . . . . . . . . . . .  value of the Bell sequence
##
##  returns the *Bell number* $B(n)$.  The Bell numbers are defined by
##  $B(0)=1$ and the recurrence $B(n+1) = \sum_{k=0}^{n}{{n \choose
##  k}B(k)}$.
## 
##  $B(n)$ is the  number of ways to  partition a  set of <n> elements
##  into pairwise disjoint  nonempty subsets  (see "PartitionsSet").  This
##  implies of  course that $B(n) =  \sum_{k=0}^{n}{S_2(n,k)}$  (see
##  "Stirling2").  $B(n)/n!$ is the coefficient of  $x^n$ in the formal
##  series  $e^{e^x-1}$, which is the generating function for $B(n)$.
DeclareGlobalFunction("Bell");


#############################################################################
##
#F  Stirling1( <n>, <k> ) . . . . . . . . . Stirling number of the first kind
##
##  returns the *Stirling number of the first kind* $S_1(n,k)$ of the
##  integers <n> and <k>.  Stirling numbers of the first kind are defined by
##  $S_1(0,0)  = 1$, $S_1(n,0) =  S_1(0,k) = 0$  if  $n, k \<> 0$  and the
##  recurrence $S_1(n,k) = (n-1) S_1(n-1,k) + S_1(n-1,k-1)$.
##
##  $S_1(n,k)$ is the number  of permutations of  <n> points with <k>
##  cycles.  Stirling numbers of  the first kind  appear as coefficients in
##  the series $n! {x \choose n} = \sum_{k=0}^{n}{S_1(n,k) x^k}$ which is
##  the generating function for Stirling numbers of the first kind.  Note
##  the similarity to $x^n =  \sum_{k=0}^{n}{S_2(n,k) k!  {x  \choose k}}$
##  (see  "Stirling2").  Also the definition of $S_1$ implies $S_1(n,k) =
##  S_2(-k,-n)$ if $n,k\<0$.  There are  many  formulae relating Stirling
##  numbers of  the first kind to Stirling numbers of the second kind, Bell
##  numbers, and Binomial numbers.
DeclareGlobalFunction("Stirling1");


#############################################################################
##
#F  Stirling2( <n>, <k> ) . . . . . . . .  Stirling number of the second kind
##
##  returns the *Stirling number of  the  second kind* $S_2(n,k)$ of the
##  integers <n>  and <k>.  Stirling  numbers  of the second  kind are
##  defined by $S_2(0,0) = 1$, $S_2(n,0) = S_2(0,k) = 0$ if $n,  k \<> 0$
##  and the recurrence $S_2(n,k) = k S_2(n-1,k) + S_2(n-1,k-1)$.
##
##  $S_2(n,k)$ is the number of ways to partition a set of <n>  elements
##  into <k> pairwise disjoint nonempty  subsets  (see "PartitionsSet").
##  Stirling numbers of the second kind  appear as  coefficients  in the
##  expansion of $x^n = \sum_{k=0}^{n}{S_2(n,k) k!  {x  \choose k}}$.  Note
##  the similarity to $n! {x \choose  n} = \sum_{k=0}^{n}{S_1(n,k) x^k}$
##  (see  "Stirling1").  Also the definition of $S_2$ implies $S_2(n,k) =
##  S_1(-k,-n)$ if $n,k\<0$.  There are many formulae relating  Stirling
##  numbers of  the second kind to Stirling numbers of the first kind, Bell
##  numbers, and Binomial numbers.
DeclareGlobalFunction("Stirling2");


#############################################################################
##
#F  Combinations( <mset> [,<k>] )
##
##  returns the  set of all combinations of the multiset  <mset> with <k>
##  elements if <k> is not given it returns all multisets.
##
##  A *combination* of  <mset> is an  unordered selection without
##  repetitions and is represented by a sorted sublist of <mset>. If
##  <mset> is a proper set, there  are  ${|mset| \choose  k}$  (see
##  "Binomial")  combinations with <k> elements, and the set of all
##  combinations is just the *powerset* of <mset>, which contains all
##  *subsets* of <mset>  and has  cardinality $2^{|mset|}$.
##
DeclareGlobalFunction("Combinations");


#############################################################################
##
#F  NrCombinations( <mset> [,<k>] )
##
##  returns the number of `Combinations(<mset>,<k>)'.
##
DeclareGlobalFunction("NrCombinations");


#############################################################################
##
#F  Arrangements( <mset> [,<k>] )
##
##  returns the  set of arrangements of the multiset <mset> that contain <k>
##  elements. If <k> is not given it returns all arrangements.
##
##  An  *arrangement* of <mset>  is an ordered selection  without
##  repetitions and is represented by a list that contains only elements
##  from <mset>, but maybe  in a different  order. If <mset>  is  a proper
##  set there  are $|mset|!  /  (|mset|-k)!$ (see  "Factorial")
##  arrangements  with  <k> elements.
##
DeclareGlobalFunction("Arrangements");

#############################################################################
##
#F  NrArrangements( <mset> [,<k>] )
##
##  returns the number of `Arrangements(<mset>,<k>)'.
DeclareGlobalFunction("NrArrangements");

#############################################################################
##
#F  UnorderedTuples( <set>, <k> ) . . . .  set of unordered tuples from a set
##
##  returns the  set of all  unordered tuples of length <k> of the set <set>.
##
##  An *unordered tuple* of length <k> of <set> is a unordered selection
##  with repetitions  of <set> and  is represented by a sorted  list of
##  length <k> containing  elements  from  <set>. There  are ${|set|+k-1
##  \choose k}$ (see "Binomial") such unordered tuples.
##
##  Note that the fact that `UnOrderedTuples' returns a set  implies that
##  the last  index runs fastest. That means the first  tuple
##  contains the smallest element from <set> <k> times,  the  second tuple
##  contains the smallest element of <set> at all  positions except at the
##  last positions, where it contains the second smallest element from <set>
##  and so on.
DeclareGlobalFunction("UnorderedTuples");


#############################################################################
##
#F  NrUnorderedTuples( <set>, <k> ) . . number unordered of tuples from a set
##
##  returns the number of `UnorderedTuples(<set>,<k>)'.
DeclareGlobalFunction("NrUnorderedTuples");


#############################################################################
##
#F  Tuples( <set>, <k> )  . . . . . . . . .  set of ordered tuples from a set
##
##  returns the set of all ordered tuples  of length <k> of  the set <set>.
##
##  An *ordered tuple* of  length <k> of <set> is  an ordered selection
##  with repetition and is represented by a list of length <k> containing
##  elements of <set>.  There are $|set|^k$ such ordered tuples.
##
##  Note that the fact  that `Tuples' returns  a  set implies that the
##  last index runs  fastest.  That means  the first tuple contains the
##  smallest element from <set> <k>  times,  the  second tuple  contains the
##  smallest element of <set> at all positions except at the  last
##  positions, where it contains the second smallest element from <set> and
##  so on.
DeclareGlobalFunction("Tuples");


#############################################################################
##
#F  NrTuples( <set>, <k> )  . . . . . . . number of ordered tuples from a set
##
##  returns the number of `Tuples(<set>,<k>)'.
DeclareGlobalFunction("NrTuples");


#############################################################################
##
#F  PermutationsList( <mset> )  . . . . . . set of permutations of a multiset
##
##  `PermutationsList' returns the set of permutations of  the
##  multiset <mset>.
##
##  A *permutation* is represented by a  list  that contains exactly the
##  same elements as  <mset>,  but possibly in different order.  If <mset>
##  is a proper  set there are $|mset| !$ (see "Factorial")  such
##  permutations.  Otherwise if the  first elements appears $k_1$  times,
##  the second element appears  $k_2$  times and so  on,  the  number
##  of permutations is $|mset|! /  (k_1! k_2! ..)$,  which  is
##  sometimes  called  multinomial coefficient.
##
DeclareGlobalFunction("PermutationsList");

#############################################################################
##
#F  NrPermutationsList( <mset> )  . . .  number of permutations of a multiset
##
##  returns the number of `PermutationsList(<mset>)'.
##
DeclareGlobalFunction("NrPermutationsList");

#############################################################################
##
#F  Derangements( <list> ) . . . . set of fixpointfree permutations of a list
##
##  returns the set of all derangements of the list <list>.
##
##  A *derangement* is  a fixpointfree  permutation  of <list> and
##  is represented by a list that contains exactly the  same elements as
##  <list>, but in such  an order  that the  derangement has at  no position
##  the same element as  <list>.  If the  list  <list> contains no element
##  twice there are  exactly  $|list|!  (1/2! -  1/3!  +  1/4!  -  ..
##  (-1)^n/n!)$ derangements.
##
##  Note that the  ratio
##  `NrPermutationsList([1..n])/NrDerangements([1..n])', which  is  $n!  /
##  (n! (1/2!  -  1/3!  + 1/4!  - .. (-1)^n/n!))$  is an approximation for
##  the base of the natural logarithm  $e =  2.7182818285$, which is correct
##  to about $n$ digits.
##
DeclareGlobalFunction("Derangements");

#############################################################################
##
#F  NrDerangements( <list> ) .  number of fixpointfree permutations of a list
##
##  returns the number of `Derangements(<list>)'.
DeclareGlobalFunction("NrDerangements");

#############################################################################
##
#F  PartitionsSet( <set> [,<k>] )
##
##  returns the  set  of  all unordered
##  partitions of the set <set> into  <k> pairwise disjoint nonempty sets.
##  If <k> is not given it returns all unordered partitions of <set> for all
##  <k>.
##
##  An *unordered partition* of <set> is  a set of pairwise disjoint
##  nonempty sets with union <set>  and is represented by  a sorted list of
##  such sets.  There are $B( |set| )$ (see "Bell") partitions of  the
##  set  <set>  and $S_2( |set|, k )$ (see "Stirling2") partitions with
##  <k> elements.
DeclareGlobalFunction("PartitionsSet");


#############################################################################
##
#F  NrPartitionsSet( <set> [,<k>] )
##
##  returns the number of `PartitionsSet(<set>,<k>)'.
DeclareGlobalFunction("NrPartitionsSet");


#############################################################################
##
#F  Partitions( <n> [,<k>])
##
##  returns the  set  of  all (unordered) partitions of the positive integer
##  <n> into  <k> sums with <k> summands.  If <k> is not given it returns
##  all unordered partitions of <set> for all <k>.
##
##  An *unordered partition* is an  unordered sum $n =  p_1+p_2 +..+ p_k$
##  of positive integers and is represented by the list  $p =
##  [p_1,p_2,..,p_k]$, in nonincreasing order, i.e., $p_1>=p_2>=..>=p_k$.
##  We write $p\vdash n$.  There are approximately $E^{\pi \sqrt{2/3 n}}
##  / {4 \sqrt{3} n}$ such partitions.
##
##  It  is possible to  associate with every partition  of the integer  <n>
##  a conjugacy class of permutations in the symmetric group on <n>  points
##  and vice  versa. Therefore $p(n) := NrPartitions(n)$  is  the
##  number of conjugacy classes of the symmetric group on <n> points.
##
##  Ramanujan found the identities $p(5i+4) = 0$ mod 5, $p(7i+5) = 0$  mod
##  7 and  $p(11i+6) = 0$ mod 11 and many  other  fascinating  things about
##  the number of partitions.
##
##  Do not call `Partitions' with an <n> much larger than 40, in  which
##  case there are 37338 partitions, since the list will simply become too
##  large.
DeclareGlobalFunction("Partitions");

#############################################################################
##
#F  NrPartitions( <n> [,<k>])
##
##  returns the number of `Partitions(<set>,<k>)'.
DeclareGlobalFunction("NrPartitions");

#############################################################################
##
#F  OrderedPartitions( <n> [,<k>] )
##
##  returns the  set  of  all ordered partitions of the positive integer <n>
##  into  <k> sums with <k> summands.  If <k> is not given it returns all
##  unordered partitions of <set> for all <k>.
##
## An *ordered partition* is an ordered sum $n = p_1 + p_2 + .. +  p_k$ of
## positive integers and is represented by the list $[ p_1, p_2, .., p_k ]$.
## There are  totally $2^{n-1}$ ordered  partitions  and ${n-1 \choose k-1}$
## (see "Binomial") partitions with <k> summands.
##
##  Do not call `OrderedPartitions' with an <n> much larger  than  15,  the
##  list will simply become too large.
DeclareGlobalFunction("OrderedPartitions");

#############################################################################
##
#F  NrOrderedPartitions( <n> [,<k>] )
##
##  returns the number of `OrderedPartitions(<set>,<k>)'.
DeclareGlobalFunction("NrOrderedPartitions");

#############################################################################
##
#F  RestrictedPartitions( <n>, <set> [,<k>] )
##
##  In the first  form  `RestrictedPartitions' returns the set of all
##  restricted  partitions of the positive integer  <n>  into sums  with <k>
##  summands with the summands of the partition  coming  from the  set
##  <set>. If <k> is not given all restricted partitions for all <k> are
##  returned.
##
##  A *restricted partition* is like an ordinary partition (see
##  "Partitions") an  unordered  sum $n =  p_1+p_2 +..+  p_k$ of  positive
##  integers and is represented by the list  $p =  [p_1,p_2,..,p_k]$, in
##  nonincreasing order.  The difference is that  here  the $p_i$ must be
##  elements from the set <set>, while for ordinary partitions they may be
##  elements from `[1..n]'.
DeclareGlobalFunction("RestrictedPartitions");


#############################################################################
##
#F  NrRestrictedPartitions(<n>,<set> [,<k>] )
##
##  returns the number of `RestrictedPartitions(<n>,<set>,<k>)'.
DeclareGlobalFunction("NrRestrictedPartitions");


#############################################################################
##
#F  SignPartition( <pi> ) . . . . . . . . . . . . .  signum of partition <pi>
##
##  returns the signum of a permutation with cycle structure <pi>.
##
##  This function actually describes  a homomorphism of  the  symmetric
##  group $S_n$ into  the  cyclic group of order  2,  whose  kernel  is
##  exactly the alternating  group $A_n$  (see "SignPerm").  Partitions  of
##  sign  1  are called *even* partitions while partitions of sign $-1$ are
##  called *odd*.
DeclareGlobalFunction("SignPartition");


#############################################################################
##
#F  AssociatedPartition( <pi> )
##
##  'AssociatedPartition'  returns the associated partition  of the partition
##  <pi> which is obtained by transposing the corresponding Young diagram.
##
DeclareGlobalFunction("AssociatedPartition");


#############################################################################
##
#F  PowerPartition(" <pi>, <k> ) . . . . . . . . . . . .  power of a partition
##
##  'PowerPartition'  returns the partition corresponding to the <k>-th power
##  of a permutation with cycle structure <pi>.
##
##  Each part $l$ of <pi> is replaced by $d = \gcd(l, k)$ parts $l/d$.  So
##  if <pi> is a partition of $n$ then $<pi>^{<k>}$ also is a partition of
##  $n$.  `PowerPartition'  describes  the  powermap  of  symmetric groups.
##
DeclareGlobalFunction("PowerPartition");


#############################################################################
##
#F  PartitionTuples( <n>, <r> ) . . . . . . . . . <r> partitions with sum <n>
##
##  'PartitionTuples'  returns the list of all <r>-tuples of partitions which
##  together form a partition of <n>.
##
##  <r>--tuples  of partitions describe the  classes  and  the  characters
##  of wreath products of groups with  <r> conjugacy classes with the
##  symmetric group $S_n$.
DeclareGlobalFunction("PartitionTuples");


#############################################################################
##
#F  Lucas(<P>,<Q>,<k>)  . . . . . . . . . . . . . . value of a lucas sequence
##
##  returns the <k>-th values of the *Lucas sequence* with parameters <P>
##  and <Q>, which must be integers, as a list of three integers.
##
##  Let $\alpha, \beta$ be the two roots of  $x^2 - P x + Q$  then we
##  define $Lucas( P, Q, k )[1] = U_k = (\alpha^k - \beta^k) / (\alpha -
##  \beta)$ and $Lucas( P, Q, k )[2] = V_k = (\alpha^k + \beta^k)$  and as
##  a convenience $Lucas( P, Q, k )[3] = Q^k$.
##
##  The following recurrence relations are easily derived from the
##  definition $U_0 = 0, U_1 = 1, U_k = P U_{k-1} - Q U_{k-2}$ and $V_0 = 2,
##  V_1 = P, V_k = P V_{k-1} - Q V_{k-2}$. Those relations are actually used
##  to define `Lucas' if $\alpha = \beta$.
##
##  Also the more complex relations used in `Lucas' can be easily derived
##  $U_{2k} = U_k V_k,  U_{2k+1} = (P U_{2k} + V_{2k}) / 2$ and $V_{2k} =
##  V_k^2 - 2 Q^k,  V_{2k+1} = ((P^2-4Q) U_{2k} + P V_{2k}) / 2$.
##
##  `Fibonnaci(<k>)' (see "Fibonacci") is simply `Lucas(1,-1,<k>)[1]'.  In
##  an abuse of notation, the sequence  `Lucas(1,-1,<k>)[2]' is sometimes
##  called the Lucas sequence.
DeclareGlobalFunction("Lucas");

#############################################################################
##
#F  Fibonacci( <n> )  . . . . . . . . . . . . value of the Fibonacci sequence
##
##  returns  the <n>th number  of the *Fibonacci sequence*.  The Fibonacci
##  sequence $F_n$ is defined by the initial conditions $F_1=F_2=1$ and  the
##  recurrence relation  $F_{n+2} = F_{n+1}  + F_{n}$.  For negative $n$  we
##  define $F_n = (-1)^{n+1}  F_{-n}$, which  is consistent with the
##  recurrence relation.
##  
##  Using generating functions one can prove that $F_n = \phi^n  -
##  1/\phi^n$, where  $\phi$ is $(\sqrt{5} + 1)/2$, i.e., one root of $x^2 -
##  x - 1 = 0$.  Fibonacci  numbers have  the  property $Gcd( F_m,  F_n ) =
##  F_{Gcd(m,n)}$.  But a pair of Fibonacci numbers requires more division
##  steps in Euclid\'s algorithm (see "Gcd") than any  other  pair of
##  integers of the same size.  `Fibonnaci(<k>)' is the special case
##  `Lucas(1,-1,<k>)[1]' (see "Lucas").
DeclareGlobalFunction("Fibonacci");


#############################################################################
##
#F  Bernoulli( <n> )  . . . . . . . . . . . . value of the Bernoulli sequence
##
##  returns the <n>-th *Bernoulli number* $B_n$, which is defined by $B_0 =
##  1$ and $B_n = -\sum_{k=0}^{n-1}{{n+1 \choose k} B_k}/(n+1)$.
##  
##  $B_n/n!$ is the coefficient of $x^n$  in the power series of
##  $x/{e^x-1}$.  Except for $B_1=-1/2$ the Bernoulli numbers for odd
##  indices $m$ are zero.
DeclareGlobalFunction("Bernoulli");

#############################################################################
##
#F  Permanent( <mat> )  . . . . . . . . . . . . . . . . permanent of a matrix
##
##  returns the *permanent* of the matrix  <mat>.  The  permanent is defined
##  by $\sum_{p \in Symm(n)}{\prod_{i=1}^{n}{mat[i][i^p]}}$.
##  
##  Note the similarity of the definition of  the permanent to the
##  definition of the determinant.  In  fact the only  difference is the
##  missing sign of the permutation.  However the  permanent is quite unlike
##  the determinant, for example it is  not  multilinear or  alternating.
##  It has  however important combinatorical properties.
DeclareGlobalFunction("Permanent");

#############################################################################
##
#E  combinat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



