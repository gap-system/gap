#############################################################################
##
#W  straight.gd              GAP library                        Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of the operations
##  for straight line programs.
##
Revision.straight_gd :=
    "@(#)$Id$";


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
##  \beginlist
##  \item{1.}
##      a nonempty list $l$ of integers,
##  \item{2.}
##      a pair $[ l, i ]$
##      where $l$ is a list of form 1. and $i$ is a positive integer,
##  \item{3.}
##      a list $[ l_1, l_2, \ldots, l_k ]$
##      where each $l_i$ is a list of form 1.;
##      this may occur only as last line of the program.
##  \endlist
##
##  The lists of integers that occur are interpreted as external
##  representations of associative words
##  (see~"External Representation for Associative Words");
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
##  \beginlist
##  \item{(a)}
##      First a list $r$ of intermediate results is initialized
##      with a shallow copy of $<gens>$.
##  \item{(b)}
##      For $i \< k$, before the $i$-th step, let $r$ be of length $n$.
##      If $p_i$ is the external representation of an associative word
##      in the first $n$ generators then the image of this word under the
##      homomorphism that is given by mapping $r$ to these first $n$
##      generators is added to $r$;
##      if $p_i$ is a pair $[ l, j ]$ then the same element is computed,
##      but instead of being added to $r$, it replaces the $j$-th entry
##      of $r$.
##  \item{(c)}
##      For $i = k$, if $p_k$ is the external representation of an
##      associative word then the element described in (b) is the result
##      of the program,
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
#E

