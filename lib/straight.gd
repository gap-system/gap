#############################################################################
##
#W  straight.gd              GAP library                        Thomas Breuer
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of the operations
##  for straight line programs.
##
##  1. Functions for straight line programs
##  2. Functions for elements represented by straight line programs
##
Revision.straight_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. Functions for straight line programs
##


#############################################################################
#1
##  *Straight line programs* describe an efficient way for evaluating an
##  abstract word at concrete generators,
##  in a more efficient way than with `MappedWord' (see~"MappedWord").
##  For example, the associative word $ababbab$ of length $7$ can be computed
##  from the generators $a$, $b$ with only four multiplications,
##  by first computing $c = ab$, then $d = cb$, and then $cdc$;
##  Alternatively, one can compute $c = ab$, $e = bc$, and $aee$.
##  In each step of these computations, one forms words in terms of the
##  words computed in the previous steps.
##
##  A straight line program in {\GAP} is represented by an object in the
##  category `IsStraightLineProgram' (see~"IsStraightLineProgram")
##  that stores a list of ``lines''
##  each of which has one of the following three forms.
##  \beginlist%ordered
##  \item{1.}
##      a nonempty dense list $l$ of integers,
##  \item{2.}
##      a pair $[ l, i ]$
##      where $l$ is a list of form 1. and $i$ is a positive integer,
##  \item{3.}
##      a list $[ l_1, l_2, \ldots, l_k ]$
##      where each $l_i$ is a list of form 1.;
##      this may occur only for the last line of the program.
##  \endlist
##
##  The lists of integers that occur are interpreted as external
##  representations of associative words
##  (see~"The External Representation for Associative Words");
##  for example, the list $[ 1, 3, 2, -1 ]$ represents the word
##  $g_1^3 g_2^{-1}$, with $g_1$ and $g_2$ the first and second abstract
##  generator, respectively.
##
##  Straight line programs can be constructed using
##  `StraightLineProgram' (see~"StraightLineProgram").
##
##  Defining attributes for straight line programs are
##  `NrInputsOfStraightLineProgram' (see~"NrInputsOfStraightLineProgram")
##  and `LinesOfStraightLineProgram' (see~"LinesOfStraightLineProgram").
##  Another operation for straight line programs is
##  `ResultOfStraightLineProgram' (see~"ResultOfStraightLineProgram").
##
##  Special methods applicable to straight line programs are installed for
##  the operations `Display', `IsInternallyConsistent', `PrintObj',
##  and `ViewObj'.
##
##  For a straight line program <prog>, the default `Display' method prints
##  the interpretation of <prog> as a sequence of assignments of associative
##  words;
##  a record with components `gensnames' (with value a list of strings)
##  and `listname' (a string) may be entered as second argument of `Display',
##  in this case these names are used, the default for `gensnames' is
##  $[ `g1', `g2', \ldots ]$, the default for `listname' is $r$.
##


#############################################################################
##
#C  IsStraightLineProgram( <obj> )
##
##  Each straight line program in {\GAP} lies in the category
##  `IsStraightLineProgram'.
##
DeclareCategory( "IsStraightLineProgram", IsObject );


#############################################################################
##
#F  StraightLineProgram( <lines>[, <nrgens>] )
#F  StraightLineProgram( <string>, <gens> )
#F  StraightLineProgramNC( <lines>[, <nrgens>] )
#F  StraightLineProgramNC( <string>, <gens> )
##
##  In the first form, <lines> must be a list of lists that defines a unique
##  straight line program (see~"IsStraightLineProgram");
##  in this case `StraightLineProgram' returns this program,
##  otherwise an error is signalled.
##  The optional argument <nrgens> specifies the number of input generators
##  of the program;
##  if a line of form 1. (that is, a list of integers) occurs in <lines>
##  except in the last position, this number is not determined by <lines>
##  and therefore *must* be specified by the argument <nrgens>;
##  if not then `StraightLineProgram' returns `fail'.
##
##  In the second form, <string> must be a string describing an arithmetic
##  expression in terms of the strings in the list <gens>,
##  where multiplication is denoted by concatenation, powering is denoted by
##  `^', and round brackets `(', `)' may be used.
##  Each entry in <gens> must consist only of (uppercase or lowercase)
##  letters (i.e., letters in `IsAlphaChar', see~"IsAlphaChar")
##  such that no entry is an initial part of another one.
##  Called with this input, `StraightLineProgramNC' returns a straight line
##  program that evaluates to the word corresponding to <string> when called
##  with generators corresponding to <gens>.
##
##  `StraightLineProgramNC' does the same as `StraightLineProgram',
##  except that the internal consistency of the program is not checked.
##
DeclareGlobalFunction( "StraightLineProgram" );

DeclareGlobalFunction( "StraightLineProgramNC" );


#############################################################################
##
#F  StringToStraightLineProgram( <string>, <gens>, <script> )
##
##  For a string <string>, a list <gens> of strings such that <string>
##  describes a word in terms of <gens>, and a list <script>,
##  `StringToStraightLineProgram' transforms <string> into the lines of a
##  straight line program, which are collected in <script>.
##
##  The return value is `true' if <string> is valid, and `false' otherwise.
##
##  This function is used by `StraightLineProgram' and `ScriptFromString';
##  it is only of local interest, we declare it here because it is recursive.
##
DeclareGlobalFunction( "StringToStraightLineProgram" );


#############################################################################
##
#A  LinesOfStraightLineProgram( <prog> )
##
##  For a straight line program <prog>, `LinesOfStraightLineProgram' returns
##  the list of program lines.
##  There is no default method to compute these lines if they are not stored.
##
DeclareAttribute( "LinesOfStraightLineProgram", IsStraightLineProgram );


#############################################################################
##
#A  NrInputsOfStraightLineProgram( <prog> )
##
##  For a straight line program <prog>, `NrInputsOfStraightLineProgram'
##  returns the number of generators that are needed as input.
##
##  If a line of form 1. (that is, a list of integers) occurs in the lines of
##  <prog> except the last line
##  then the number of generators is not determined by the lines,
##  and must be set in the construction of the straight line program
##  (see~"StraightLineProgram").
##  So if <prog> contains a line of form 1. other than the last line
##  and does *not* store the number of generators
##  then `NrInputsOfStraightLineProgram' signals an error.
##
DeclareAttribute( "NrInputsOfStraightLineProgram", IsStraightLineProgram );


#############################################################################
##
#O  ResultOfStraightLineProgram( <prog>, <gens> )
##
##  `ResultOfStraightLineProgram' evaluates the straight line program
##  (see~"IsStraightLineProgram") <prog> at the group elements in the list
##  <gens>.
##
##  The *result* of a straight line program with lines
##  $p_1, p_2, \ldots, p_k$
##  when applied to <gens> is defined as follows.
##  \beginlist%ordered{a}
##  \item{(a)}
##      First a list $r$ of intermediate results is initialized
##      with a shallow copy of $<gens>$.
##  \item{(b)}
##      For $i \< k$, before the $i$-th step, let $r$ be of length $n$.
##      If $p_i$ is the external representation of an associative word
##      in the first $n$ generators then the image of this word under the
##      homomorphism that is given by mapping $r$ to these first $n$
##      generators is added to $r$;
##      if $p_i$ is a pair $[ l, j ]$, for a list $l$, then the same element
##      is computed, but instead of being added to $r$,
##      it replaces the $j$-th entry of $r$.
##  \item{(c)}
##      For $i = k$, if $p_k$ is the external representation of an
##      associative word then the element described in (b) is the result
##      of the program,
##      if $p_k$ is a pair $[ l, j ]$, for a list $l$, then the result is
##      the element described by $l$,
##      and if $p_k$ is a list $[ l_1, l_2, \ldots, l_k ]$ of lists
##      then the result is a list of group elements, where each $l_i$ is
##      treated as in (b).
##  \endlist
##
##  Here are some examples.
##  \beginexample
##  gap> f:= FreeGroup( "x", "y" );;  gens:= GeneratorsOfGroup( f );;
##  gap> x:= gens[1];;  y:= gens[2];;
##  gap> prg:= StraightLineProgram( [ [] ] );
##  <straight line program>
##  gap> ResultOfStraightLineProgram( prg, [] );
##  [  ]
##  \endexample
##  The above straight line program `prg' returns
##  --for *any* list of input generators-- an empty list.
##  \beginexample
##  gap> StraightLineProgram( [ [1,2,2,3], [3,-1] ] );
##  fail
##  gap> prg:= StraightLineProgram( [ [1,2,2,3], [3,-1] ], 2 );
##  <straight line program>
##  gap> LinesOfStraightLineProgram( prg );
##  [ [ 1, 2, 2, 3 ], [ 3, -1 ] ]
##  gap> prg:= StraightLineProgram( "(a^2b^3)^-1", [ "a", "b" ] );
##  <straight line program>
##  gap> LinesOfStraightLineProgram( prg );
##  [ [ [ 1, 2, 2, 3 ], 3 ], [ [ 3, -1 ], 4 ] ]
##  gap> res:= ResultOfStraightLineProgram( prg, gens );
##  y^-3*x^-2
##  gap> res = (x^2 * y^3)^-1;
##  true
##  gap> NrInputsOfStraightLineProgram( prg );
##  2
##  gap> Print( prg, "\n" );
##  StraightLineProgram( [ [ [ 1, 2, 2, 3 ], 3 ], [ [ 3, -1 ], 4 ] ], 2 )
##  gap> Display( prg );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  r[3]:= r[1]^2*r[2]^3;
##  r[4]:= r[3]^-1;
##  # return value:
##  r[4]
##  gap> IsInternallyConsistent( StraightLineProgramNC( [ [1,2] ] ) );
##  true
##  gap> IsInternallyConsistent( StraightLineProgramNC( [ [1,2,3] ] ) );
##  false
##  gap> prg1:= StraightLineProgram( [ [1,1,2,2], [3,3,1,1] ], 2 );;
##  gap> prg2:= StraightLineProgram( [ [ [1,1,2,2], 2 ], [2,3,1,1] ] );;
##  gap> res1:= ResultOfStraightLineProgram( prg1, gens );
##  x*y^2*x*y^2*x*y^2*x
##  gap> res1 = (x*y^2)^3*x;
##  true
##  gap> res2:= ResultOfStraightLineProgram( prg2, gens );
##  x*y^2*x*y^2*x*y^2*x
##  gap> res2 = (x*y^2)^3*x;
##  true
##  gap> prg:= StraightLineProgram( [ [2,3], [ [3,1,1,4], [1,2,3,1] ] ], 2 );;
##  gap> res:= ResultOfStraightLineProgram( prg, gens );
##  [ y^3*x^4, x^2*y^3 ]
##  \endexample
##
DeclareOperation( "ResultOfStraightLineProgram",
    [ IsStraightLineProgram, IsHomogeneousList ] );


#############################################################################
##
#F  StringOfResultOfStraightLineProgram( <prog>, <gensnames>[, \"LaTeX\"] )
##
##  `StringOfResultOfStraightLineProgram' returns a string that describes the
##  result of the straight line program (see~"IsStraightLineProgram") <prog>
##  as word(s) in terms of the strings in the list <gensnames>.
##  If the result of <prog> is a single element then the return value of
##  `StringOfResultOfStraightLineProgram' is a string consisting of the
##  entries of <gensnames>, opening and closing brackets `(' and `)',
##  and powering by integers via `^'.
##  If the result of <prog> is a list of elements then the return value of
##  `StringOfResultOfStraightLineProgram' is a comma separated concatenation
##  of the strings of the single elements,
##  enclosed in square brackets `[', `]'.
##
DeclareGlobalFunction( "StringOfResultOfStraightLineProgram" );


#############################################################################
##
#F  CompositionOfStraightLinePrograms( <prog2>, <prog1> )
##
##  For two straight line programs <prog1> and <prog2>,
##  `CompositionOfStraightLinePrograms' returns a straight line program
##  <prog> with the properties that <prog1> and <prog> have the same number
##  of inputs, and the result of <prog> when applied to given generators
##  <gens> equals the result of <prog2> when this is applied to the output of
##  <prog1> applied to <gens>.
##
##  (Of course the number of outputs of <prog1> must be the same as the
##  number of inputs of <prog2>.)
##
DeclareGlobalFunction( "CompositionOfStraightLinePrograms" );


#############################################################################
##
#F  IntegratedStraightLineProgram( <listofprogs> )
##
##  For a nonempty dense list <listofprogs> of straight line programs
##  that have the same number $n$, say, of inputs
##  (see~"NrInputsOfStraightLineProgram")
##  and for which the results (see~"ResultOfStraightLineProgram") are single
##  elements (i.e., *not* lists of elements),
##  `IntegratedStraightLineProgram' returns a straight line program <prog>
##  with $n$ inputs such that for each $n$-tuple <gens> of generators,
##  `ResultOfStraightLineProgram( <prog>, <gens> )' is equal to the list
##  `List( <listofprogs>, <p> -> ResultOfStraightLineProgram( <p>, <gens> )'.
##
DeclareGlobalFunction( "IntegratedStraightLineProgram" );


#############################################################################
##
##  2. Functions for elements represented by straight line programs
##

#2
##  When computing with very large (in terms of memory) elements, for
##  example permutations of degree a few hundred thousands, it can be
##  helpful (in terms of memory usage) to represent them via straight line
##  programs in terms of an original generator set. (So every element takes
##  only small extra storage for the straight line program.)
##
##  A straight line program element has a *seed* (a list of group elements)
##  and a straight line program on the same number of generators as the
##  length of this seed, its value is the value of the evaluated straight
##  line program. 
##
##  At the moment, the entries of the straight line program have to be
##  simple lists (i.e. of the first form).
##
##  Straight line program elements are in the same categories
##  and families as the elements of the seed, so they should work together
##  with existing algorithms.
##
##  Note however, that due to the different way of storage some normally
##  very cheap operations (such as testing for element equality) can become
##  more expensive when dealing with straight line program elements. This is
##  essentially the tradeoff for using less memory.


#############################################################################
##
#R  IsStraightLineProgElm(<obj>)
##
##  A straight line program element is a group element given (for memory
##  reasons) as a straight line program. Straight line program elements are
##  positional objects, the first component is a record with a component
##  `seeds', the second component the straight line program.
# we need to rank higher than default methods
DeclareFilter("StraightLineProgramElmRankFilter",100);

DeclareRepresentation("IsStraightLineProgElm",
  IsMultiplicativeElementWithInverse and IsPositionalObjectRep 
  and StraightLineProgramElmRankFilter,[]);

#############################################################################
##
#A  StraightLineProgElmType(<fam>)
##
##  returns a type for straigth line program elements over the family <fam>
DeclareAttribute("StraightLineProgElmType",IsFamily);

#############################################################################
##
#F  StraightLineProgElm(<seed>,<prog>)
##
##  Creates a straight line program element for seed <seed> and program
##  <prog>.
DeclareGlobalFunction("StraightLineProgElm");

#############################################################################
##
#F  EvalStraightLineProgElm(<slpel>)
##
##  evaluates a straight line program element <slpel> from its seeds.
DeclareGlobalFunction("EvalStraightLineProgElm");

#############################################################################
##
#F  StraightLineProgGens(<gens>[,<base>])
##
##  returns a set of straight line program elements corresponding to the
##  generators in <gens>.
##  If <gens> is a set of permutations then <base> can be given which must
##  be a base for the group generated by <gens>. (Such a base will be used to
##  speed up equality tests.)
DeclareGlobalFunction("StraightLineProgGens");

#############################################################################
##
#O  StretchImportantSLPElement(<elm>)
##
##  If <elm> is a straight line program element whose straight line
##  representation is very long, this operation changes the
##  representation of <elm> to a straight line program element, equal to
##  <elm>, whose seed contains the evaluation of <elm> and whose straight
##  line program has length 1.
##  
##  For other objects nothing happens.
##
##  This operation permits to designate ``important'' elements within an
##  algorithm (elements that wil be referred to often), which will be
##  represented by guaranteed short straight line program elements.
DeclareOperation("StretchImportantSLPElement",
  [IsMultiplicativeElementWithInverse]);

#############################################################################
##
#F  TreeRepresentedWord( <roots>,<tree>,<nr> )
##
##  returns a straight line element by decoding element <nr> of <tree> with
##  respect to <roots>. <tree> is a tree as given by the augmented coset
##  table routines.
DeclareGlobalFunction("TreeRepresentedWord");

#############################################################################
##
#E

