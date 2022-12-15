#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Alexander Hulpke, Max Neunhöffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations of the operations
##  for straight line programs.
##
##  1. Functions for straight line programs
##  2. Functions for elements represented by straight line programs
##


#############################################################################
##
##  1. Functions for straight line programs
##


#############################################################################
##
##  <#GAPDoc Label="[1]{straight}">
##  <E>Straight line programs</E> describe an efficient way for evaluating an
##  abstract word at concrete generators,
##  in a more efficient way than with <Ref Oper="MappedWord"/>.
##  For example,
##  the associative word <M>ababbab</M> of length <M>7</M> can be computed
##  from the generators <M>a</M>, <M>b</M> with only four multiplications,
##  by first computing <M>c = ab</M>, then <M>d = cb</M>,
##  and then <M>cdc</M>;
##  Alternatively, one can compute <M>c = ab</M>, <M>e = bc</M>,
##  and <M>aee</M>.
##  In each step of these computations, one forms words in terms of the
##  words computed in the previous steps.
##  <P/>
##  A straight line program in &GAP; is represented by an object in the
##  category <Ref Filt="IsStraightLineProgram"/>)
##  that stores a list of <Q>lines</Q>
##  each of which has one of the following three forms.
##  <Enum>
##  <Item>
##      a nonempty dense list <M>l</M> of integers,
##  </Item>
##  <Item>
##      a pair <M>[ l, i ]</M>
##      where <M>l</M> is a list of form 1.
##      and <M>i</M> is a positive integer,
##  </Item>
##  <Item>
##      a list <M>[ l_1, l_2, \ldots, l_k ]</M>
##      where each <M>l_i</M> is a list of form 1.;
##      this may occur only for the last line of the program.
##  </Item>
##  </Enum>
##  <P/>
##  The lists of integers that occur are interpreted as external
##  representations of associative words (see Section&nbsp;
##  <Ref Sect="The External Representation for Associative Words"/>);
##  for example, the list <M>[ 1, 3, 2, -1 ]</M> represents the word
##  <M>g_1^3 g_2^{{-1}}</M>, with <M>g_1</M> and <M>g_2</M> the first and
##  second abstract generator, respectively.
##  <P/>
##  For the meaning of the list of lines, see
##  <Ref Oper="ResultOfStraightLineProgram"/>.
##  <P/>
##  Straight line programs can be constructed using
##  <Ref Func="StraightLineProgram" Label="for a list of lines (and the number of generators)"/>.
##  <P/>
##  Defining attributes for straight line programs are
##  <Ref Attr="NrInputsOfStraightLineProgram"/>
##  and <Ref Attr="LinesOfStraightLineProgram"/>.
##  Another operation for straight line programs is
##  <Ref Oper="ResultOfStraightLineProgram"/>.
##  <P/>
##  Special methods applicable to straight line programs are installed for
##  the operations <Ref Oper="Display"/>,
##  <Ref Oper="IsInternallyConsistent"/>, <Ref Oper="PrintObj"/>,
##  and <Ref Oper="ViewObj"/>.
##  <P/>
##  For a straight line program <A>prog</A>,
##  the default <Ref Oper="Display"/> method prints the interpretation
##  of <A>prog</A> as a sequence of assignments of associative words;
##  a record with components <C>gensnames</C> (with value a list of strings)
##  and <C>listname</C> (a string) may be entered as second argument of
##  <Ref Oper="Display"/>,
##  in this case these names are used, the default for <C>gensnames</C> is
##  <C>[ g1, g2, </C><M>\ldots</M><C> ]</C>,
##  the default for <C>listname</C> is <M>r</M>.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsStraightLineProgram( <obj> )
##
##  <#GAPDoc Label="IsStraightLineProgram">
##  <ManSection>
##  <Filt Name="IsStraightLineProgram" Arg='obj' Type='Category'/>
##
##  <Description>
##  Each straight line program in &GAP; lies in the category
##  <Ref Filt="IsStraightLineProgram"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsStraightLineProgram", IsObject );


#############################################################################
##
#F  StraightLineProgram( <lines>[, <nrgens>] )
#F  StraightLineProgram( <string>, <gens> )
#F  StraightLineProgramNC( <lines>[, <nrgens>] )
#F  StraightLineProgramNC( <string>, <gens> )
##
##  <#GAPDoc Label="StraightLineProgram">
##  <ManSection>
##  <Func Name="StraightLineProgram" Arg='lines[, nrgens]'
##   Label="for a list of lines (and the number of generators)"/>
##  <Func Name="StraightLineProgram" Arg='string, gens'
##   Label="for a string and a list of generators names"/>
##  <Func Name="StraightLineProgramNC" Arg='lines[, nrgens]'
##   Label="for a list of lines (and the number of generators)"/>
##  <Func Name="StraightLineProgramNC" Arg='string, gens'
##   Label="for a string and a list of generators names"/>
##
##  <Description>
##  In the first form, <A>lines</A> must be a nonempty list of lists
##  that defines a unique straight line program
##  (see&nbsp;<Ref Filt="IsStraightLineProgram"/>); in this case
##  <Ref Func="StraightLineProgram" Label="for a list of lines (and the number of generators)"/>
##  returns this program, otherwise an error is signalled.
##  The optional argument <A>nrgens</A> specifies the number of input
##  generators of the program;
##  if a line of form 1. (that is, a list of integers) occurs in <A>lines</A>
##  except in the last position,
##  this number is not determined by <A>lines</A> and therefore <E>must</E>
##  be specified by the argument <A>nrgens</A>;
##  if not then
##  <Ref Func="StraightLineProgram" Label="for a list of lines (and the number of generators)"/>
##  returns <K>fail</K>.
##  <P/>
##  In the second form, <A>string</A> must be a nonempty string describing an
##  arithmetic expression in terms of the strings in the list <A>gens</A>,
##  where multiplication is denoted by concatenation, powering is denoted by
##  <C>^</C>, and round brackets <C>(</C>, <C>)</C> may be used.
##  Each entry in <A>gens</A> must consist only of uppercase or lowercase
##  letters (i.e., letters in <Ref Func="IsAlphaChar"/>)
##  such that no entry is an initial part of another one.
##  Called with this input,
##  <Ref Func="StraightLineProgram" Label="for a string and a list of generators names"/>
##  returns a straight line program that evaluates to the word corresponding
##  to <A>string</A> when called with generators corresponding to
##  <A>gens</A>.
##  <P/>
##  The <C>NC</C> variant does the same,
##  except that the internal consistency of the program is not checked.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StraightLineProgram" );

DeclareGlobalFunction( "StraightLineProgramNC" );


#############################################################################
##
#F  StringToStraightLineProgram( <string>, <gens>, <script> )
##
##  <ManSection>
##  <Func Name="StringToStraightLineProgram" Arg='string, gens, script'/>
##
##  <Description>
##  For a string <A>string</A>, a list <A>gens</A> of strings such that
##  <A>string</A> describes a word in terms of <A>gens</A>,
##  and a list <A>script</A>, <Ref Func="StringToStraightLineProgram"/>
##  transforms <A>string</A> into the lines of a straight line program,
##  which are collected in <A>script</A>.
##  <P/>
##  The return value is <K>true</K> if <A>string</A> is valid,
##  and <K>false</K> otherwise.
##  <P/>
##  This function is used by
##  <Ref Func="StraightLineProgram" Label="for a string and a list of generators names"/>
##  and <Ref Func="ScriptFromString"/>;
##  it is only of local interest, we declare it here because it is recursive.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "StringToStraightLineProgram" );


#############################################################################
##
#A  LinesOfStraightLineProgram( <prog> )
##
##  <#GAPDoc Label="LinesOfStraightLineProgram">
##  <ManSection>
##  <Attr Name="LinesOfStraightLineProgram" Arg='prog'/>
##
##  <Description>
##  For a straight line program <A>prog</A>,
##  <Ref Attr="LinesOfStraightLineProgram"/> returns
##  the list of program lines.
##  There is no default method to compute these lines if they are not stored.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LinesOfStraightLineProgram", IsStraightLineProgram );


#############################################################################
##
#A  NrInputsOfStraightLineProgram( <prog> )
##
##  <#GAPDoc Label="NrInputsOfStraightLineProgram">
##  <ManSection>
##  <Attr Name="NrInputsOfStraightLineProgram" Arg='prog'/>
##
##  <Description>
##  For a straight line program <A>prog</A>,
##  <Ref Attr="NrInputsOfStraightLineProgram"/>
##  returns the number of generators that are needed as input.
##  <P/>
##  If a line of form 1. (that is, a list of integers) occurs in the lines of
##  <A>prog</A> except the last line
##  then the number of generators is not determined by the lines,
##  and must be set in the construction of the straight line program
##  (see&nbsp;<Ref Func="StraightLineProgram" Label="for a list of lines (and the number of generators)"/>).
##  So if <A>prog</A> contains a line of form 1. other than the last line
##  and does <E>not</E> store the number of generators
##  then <Ref Attr="NrInputsOfStraightLineProgram"/> signals an error.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NrInputsOfStraightLineProgram", IsStraightLineProgram );


#############################################################################
##
#O  ResultOfStraightLineProgram( <prog>, <gens> )
##
##  <#GAPDoc Label="ResultOfStraightLineProgram">
##  <ManSection>
##  <Oper Name="ResultOfStraightLineProgram" Arg='prog, gens'/>
##
##  <Description>
##  <Ref Oper="ResultOfStraightLineProgram"/> evaluates the straight line
##  program (see&nbsp;<Ref Filt="IsStraightLineProgram"/>) <A>prog</A>
##  at the group elements in the list <A>gens</A>.
##  <P/>
##  The <E>result</E> of a straight line program with lines
##  <M>p_1, p_2, \ldots, p_k</M>
##  when applied to <A>gens</A> is defined as follows.
##  <List>
##  <Mark>(a)</Mark>
##  <Item>
##      First a list <M>r</M> of intermediate results is initialized
##      with a shallow copy of <A>gens</A>.
##  </Item>
##  <Mark>(b)</Mark>
##  <Item>
##      For <M>i &lt; k</M>, before the <M>i</M>-th step,
##      let <M>r</M> be of length <M>n</M>.
##      If <M>p_i</M> is the external representation of an associative word
##      in the first <M>n</M> generators then the image of this word under
##      the homomorphism that is given by mapping <M>r</M> to these first
##      <M>n</M> generators is added to <M>r</M>;
##      if <M>p_i</M> is a pair <M>[ l, j ]</M>, for a list <M>l</M>,
##      then the same element is computed, but instead of being added to
##      <M>r</M>, it replaces the <M>j</M>-th entry of <M>r</M>.
##  </Item>
##  <Mark>(c)</Mark>
##  <Item>
##      For <M>i = k</M>, if <M>p_k</M> is the external representation of an
##      associative word then the element described in (b) is the result
##      of the program,
##      if <M>p_k</M> is a pair <M>[ l, j ]</M>, for a list <M>l</M>,
##      then the result is the element described by <M>l</M>,
##      and if <M>p_k</M> is a list <M>[ l_1, l_2, \ldots, l_k ]</M> of lists
##      then the result is a list of group elements, where each <M>l_i</M> is
##      treated as in (b).
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> f:= FreeGroup( "x", "y" );;  gens:= GeneratorsOfGroup( f );;
##  gap> x:= gens[1];;  y:= gens[2];;
##  gap> prg:= StraightLineProgram( [ [] ] );
##  <straight line program>
##  gap> ResultOfStraightLineProgram( prg, [] );
##  [  ]
##  ]]></Example>
##  The above straight line program <C>prg</C> returns
##  &ndash;for <E>any</E> list of input generators&ndash; an empty list.
##  <Example><![CDATA[
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
##  (x*y^2)^3*x
##  gap> res1 = (x*y^2)^3*x;
##  true
##  gap> res2:= ResultOfStraightLineProgram( prg2, gens );
##  (x*y^2)^3*x
##  gap> res2 = (x*y^2)^3*x;
##  true
##  gap> prg:= StraightLineProgram( [ [2,3], [ [3,1,1,4], [1,2,3,1] ] ], 2 );;
##  gap> res:= ResultOfStraightLineProgram( prg, gens );
##  [ y^3*x^4, x^2*y^3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ResultOfStraightLineProgram",
    [ IsStraightLineProgram, IsHomogeneousList ] );


#############################################################################
##
#F  StringOfResultOfStraightLineProgram( <prog>, <gensnames>[, "LaTeX"] )
##
##  <#GAPDoc Label="StringOfResultOfStraightLineProgram">
##  <Index Subkey="for the result of a straight line program">LaTeX</Index>
##  <ManSection>
##  <Func Name="StringOfResultOfStraightLineProgram"
##  Arg='prog, gensnames[, "LaTeX"]'/>
##
##  <Description>
##  <Ref Func="StringOfResultOfStraightLineProgram"/> returns a string
##  that describes the result of the straight line program
##  (see&nbsp;<Ref Filt="IsStraightLineProgram"/>) <A>prog</A>
##  as word(s) in terms of the strings in the list <A>gensnames</A>.
##  If the result of <A>prog</A> is a single element then the return value of
##  <Ref Func="StringOfResultOfStraightLineProgram"/> is a string consisting
##  of the entries of <A>gensnames</A>, opening and closing brackets <C>(</C>
##  and <C>)</C>, and powering by integers via <C>^</C>.
##  If the result of <A>prog</A> is a list of elements then the return value
##  of <Ref Func="StringOfResultOfStraightLineProgram"/> is a comma separated
##  concatenation of the strings of the single elements,
##  enclosed in square brackets <C>[</C>, <C>]</C>.
##  <Example><![CDATA[
##  gap> prg:= StraightLineProgram( [ [ 1, 2, 2, 3 ], [ 3, -1 ] ], 2 );;
##  gap> StringOfResultOfStraightLineProgram( prg, [ "a", "b" ] );
##  "(a^2b^3)^-1"
##  gap> StringOfResultOfStraightLineProgram( prg, [ "a", "b" ], "LaTeX" );
##  "(a^{2}b^{3})^{-1}"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StringOfResultOfStraightLineProgram" );


#############################################################################
##
#F  CompositionOfStraightLinePrograms( <prog2>, <prog1> )
##
##  <#GAPDoc Label="CompositionOfStraightLinePrograms">
##  <ManSection>
##  <Func Name="CompositionOfStraightLinePrograms" Arg='prog2, prog1'/>
##
##  <Description>
##  For two straight line programs <A>prog1</A> and <A>prog2</A>,
##  <Ref Func="CompositionOfStraightLinePrograms"/> returns a straight line
##  program <A>prog</A> with the properties that <A>prog1</A> and <A>prog</A>
##  have the same number of inputs, and the result of <A>prog</A>
##  when applied to given generators <A>gens</A> equals the result of
##  <A>prog2</A> when this is applied to the output of
##  <A>prog1</A> applied to <A>gens</A>.
##  <P/>
##  (Of course the number of outputs of <A>prog1</A> must be the same as the
##  number of inputs of <A>prog2</A>.)
##  <Example><![CDATA[
##  gap> prg1:= StraightLineProgram( "a^2b", [ "a","b" ] );;
##  gap> prg2:= StraightLineProgram( "c^5", [ "c" ] );;
##  gap> comp:= CompositionOfStraightLinePrograms( prg2, prg1 );
##  <straight line program>
##  gap> StringOfResultOfStraightLineProgram( comp, [ "a", "b" ] );
##  "(a^2b)^5"
##  gap> prg:= StraightLineProgram( [ [2,3], [ [3,1,1,4], [1,2,3,1] ] ], 2 );;
##  gap> StringOfResultOfStraightLineProgram( prg, [ "a", "b" ] );
##  "[ b^3a^4, a^2b^3 ]"
##  gap> comp:= CompositionOfStraightLinePrograms( prg, prg );
##  <straight line program>
##  gap> StringOfResultOfStraightLineProgram( comp, [ "a", "b" ] );
##  "[ (a^2b^3)^3(b^3a^4)^4, (b^3a^4)^2(a^2b^3)^3 ]"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CompositionOfStraightLinePrograms" );


#############################################################################
##
#F  IntegratedStraightLineProgram( <listofprogs> )
##
##  <#GAPDoc Label="IntegratedStraightLineProgram">
##  <ManSection>
##  <Func Name="IntegratedStraightLineProgram" Arg='listofprogs'/>
##
##  <Description>
##  For a nonempty dense list <A>listofprogs</A> of straight line programs
##  <M>p_1, p_2, \ldots, p_m</M>
##  that have the same number <M>n</M> of inputs
##  (see&nbsp;<Ref Attr="NrInputsOfStraightLineProgram"/>),
##  <Ref Func="IntegratedStraightLineProgram"/> returns a straight line
##  program <M>prog</M> with <M>n</M> inputs such that for each
##  <M>n</M>-tuple <M>gens</M> of generators,
##  <C>ResultOfStraightLineProgram( </C><M>prog, gens</M><C> )</C>
##  is the concatenation of the lists <M>r_1, r_2, \ldots, r_m</M>,
##  where <M>r_i</M> is equal to
##  <C>ResultOfStraightLineProgram( </C><M>p_i, gens</M><C> )</C>
##  if this result is a list of elements,
##  and otherwise <M>r_i</M> is equal to the list of length one
##  that contains this result.
##
##  <Example><![CDATA[
##  gap> f:= FreeGroup( "x", "y" );;  gens:= GeneratorsOfGroup( f );;
##  gap> prg1:= StraightLineProgram([ [ [ 1, 2 ], 1 ], [ 1, 2, 2, -1 ] ], 2);;
##  gap> prg2:= StraightLineProgram([ [ [ 2, 2 ], 3 ], [ 1, 3, 3, 2 ] ], 2);;
##  gap> prg3:= StraightLineProgram([ [ 2, 2 ], [ 1, 3, 3, 2 ] ], 2);;
##  gap> prg:= IntegratedStraightLineProgram( [ prg1, prg2, prg3 ] );;
##  gap> ResultOfStraightLineProgram( prg, gens );
##  [ x^4*y^-1, x^3*y^4, x^3*y^4 ]
##  gap> prg:= IntegratedStraightLineProgram( [ prg2, prg3, prg1 ] );;
##  gap> ResultOfStraightLineProgram( prg, gens );
##  [ x^3*y^4, x^3*y^4, x^4*y^-1 ]
##  gap> prg:= IntegratedStraightLineProgram( [ prg3, prg1, prg2 ] );;
##  gap> ResultOfStraightLineProgram( prg, gens );
##  [ x^3*y^4, x^4*y^-1, x^3*y^4 ]
##  gap> prg:= IntegratedStraightLineProgram( [ prg, prg ] );;
##  gap> ResultOfStraightLineProgram( prg, gens );
##  [ x^3*y^4, x^4*y^-1, x^3*y^4, x^3*y^4, x^4*y^-1, x^3*y^4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntegratedStraightLineProgram" );


#############################################################################
##
##  2. Functions for elements represented by straight line programs
##
##  <#GAPDoc Label="[2]{straight}">
##  When computing with very large (in terms of memory) elements, for
##  example permutations of degree a few hundred thousands, it can be
##  helpful (in terms of memory usage) to represent them via straight line
##  programs in terms of an original generator set. (So every element takes
##  only small extra storage for the straight line program.)
##  <P/>
##  A straight line program element has a <E>seed</E>
##  (a list of group elements) and a straight line program
##  on the same number of generators as the length of this seed,
##  its value is the value of the evaluated straight line program.
##  <P/>
##  At the moment, the entries of the straight line program have to be
##  simple lists (i.e. of the first form).
##  <P/>
##  Straight line program elements are in the same categories
##  and families as the elements of the seed, so they should work together
##  with existing algorithms.
##  <P/>
##  Note however, that due to the different way of storage some normally
##  very cheap operations (such as testing for element equality) can become
##  more expensive when dealing with straight line program elements. This is
##  essentially the tradeoff for using less memory.
##  <P/>
##  See also
##  Section&nbsp;<Ref Sect="Working with large degree permutation groups"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#R  IsStraightLineProgElm(<obj>)
##
##  <#GAPDoc Label="IsStraightLineProgElm">
##  <ManSection>
##  <Filt Name="IsStraightLineProgElm" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A straight line program element is a group element given (for memory
##  reasons) as a straight line program. Straight line program elements are
##  positional objects, the first component is a record with a component
##  <C>seeds</C>, the second component the straight line program.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  we need to rank higher than default methods
DeclareFilter("StraightLineProgramElmRankFilter",100);

DeclareRepresentation("IsStraightLineProgElm",
  IsMultiplicativeElementWithInverse and IsPositionalObjectRep
  and StraightLineProgramElmRankFilter,[]);


#############################################################################
##
#A  StraightLineProgElmType(<fam>)
##
##  <ManSection>
##  <Attr Name="StraightLineProgElmType" Arg='fam'/>
##
##  <Description>
##  returns a type for straight line program elements over the family
##  <A>fam</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("StraightLineProgElmType",IsFamily);


#############################################################################
##
#F  StraightLineProgElm(<seed>,<prog>)
##
##  <#GAPDoc Label="StraightLineProgElm">
##  <ManSection>
##  <Func Name="StraightLineProgElm" Arg='seed,prog'/>
##
##  <Description>
##  Creates a straight line program element for seed <A>seed</A> and program
##  <A>prog</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("StraightLineProgElm");


#############################################################################
##
#F  EvalStraightLineProgElm(<slpel>)
##
##  <#GAPDoc Label="EvalStraightLineProgElm">
##  <ManSection>
##  <Func Name="EvalStraightLineProgElm" Arg='slpel'/>
##
##  <Description>
##  evaluates a straight line program element <A>slpel</A> from its seeds.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EvalStraightLineProgElm");


#############################################################################
##
#F  StraightLineProgGens(<gens>[,<base>])
##
##  <#GAPDoc Label="StraightLineProgGens">
##  <ManSection>
##  <Func Name="StraightLineProgGens" Arg='gens[,base]'/>
##
##  <Description>
##  returns a set of straight line program elements corresponding to the
##  generators in <A>gens</A>.
##  If <A>gens</A> is a set of permutations then <A>base</A> can be given
##  which must be a base for the group generated by <A>gens</A>.
##  (Such a base will be used to speed up equality tests.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("StraightLineProgGens");


#############################################################################
##
#O  StretchImportantSLPElement(<elm>)
##
##  <#GAPDoc Label="StretchImportantSLPElement">
##  <ManSection>
##  <Oper Name="StretchImportantSLPElement" Arg='elm'/>
##
##  <Description>
##  If <A>elm</A> is a straight line program element whose straight line
##  representation is very long, this operation changes the
##  representation of <A>elm</A> to a straight line program element, equal to
##  <A>elm</A>, whose seed contains the evaluation of <A>elm</A> and whose
##  straight line program has length 1.
##  <P/>
##  For other objects nothing happens.
##  <P/>
##  This operation permits to designate <Q>important</Q> elements within an
##  algorithm (elements that will be referred to often), which will be
##  represented by guaranteed short straight line program elements.
##  <Example><![CDATA[
##  gap> gens:=StraightLineProgGens([(1,2,3,4),(1,2)]);
##  [ <[ [ 2, 1 ] ]|(1,2,3,4)>, <[ [ 1, 1 ] ]|(1,2)> ]
##  gap> g:=Group(gens);;
##  gap> (gens[1]^3)^gens[2];
##  <[ [ 1, -1, 2, 3, 1, 1 ] ]|(1,2,4,3)>
##  gap> Size(g);
##  24
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("StretchImportantSLPElement",
  [IsMultiplicativeElementWithInverse]);

#############################################################################
##
#F  TreeRepresentedWord( <roots>,<tree>,<nr> )
##
##  <ManSection>
##  <Func Name="TreeRepresentedWord" Arg='roots,tree,nr'/>
##
##  <Description>
##  returns a straight line element by decoding element <A>nr</A>
##  of <A>tree</A> with respect to <A>roots</A>.
##  <A>tree</A> is a tree as given by the augmented coset table routines.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TreeRepresentedWord");


#############################################################################
##
##  3. Functions for straight line programs, mostly needed for memory objects:
##


#############################################################################
##
#F  SLPChangesSlots( <l>, <nrinputs> )
##
##  <ManSection>
##  <Func Name="SLPChangesSlots" Arg='l, nrinputs'/>
##
##  <Description>
##  l must be the lines of an slp, nrinps the number of inputs.
##  This function returns a list with the same length than l, containing
##  at each position the number of the slot that is changed in the
##  corresponding line of the slp. In addition one more number is
##  appended to the list, namely the number of the biggest slot used.
##  For the moment, this function is intentionally left undocumented.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SLPChangesSlots" );

##
#F  SLPOnlyNeededLinesBackward( <l>,<i>,<nrinps>,<changes>,<needed>,
##                              <slotsused>,<ll> )
##
##  <ManSection>
##  <Func Name="SLPOnlyNeededLinesBackward"
##  Arg='l,i,nrinps,changes,needed, slotsused,ll'/>
##
##  <Description>
##  l is a list of lines of an slp, nrinps the number of inputs.
##  i is the number of the last line, that is not a line of type 3 (results).
##  changes is the result of SLPChangesSlots for that slp.
##  needed is a list, where those entries are bound to true that are
##  needed in the end of the slp. slotsused is a list that should be
##  initialized with [1..nrinps] and which contains in the end the set
##  of slots used.
##  ll is any list.
##  This functions goes backwards through the slp and adds exactly those
##  lines of the slp to ll that have to be executed to produce the
##  result (in backward order). All lines are transformed into type 2
##  lines ([assocword,slot]). Note that needed is changed underways.
##  For the moment, this function is intentionally left undocumented.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SLPOnlyNeededLinesBackward" );

##
#F  SLPReversedRenumbered( <ll>,<slotsused>,<nrinps>,<invtab> )
##
##  <ManSection>
##  <Func Name="SLPReversedRenumbered" Arg='ll,slotsused,nrinps,invtab'/>
##
##  <Description>
##  Internally used function.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SLPReversedRenumbered" );

##
#F  RestrictOutputsOfSLP( <slp>, <k> )
##
##  <#GAPDoc Label="RestrictOutputsOfSLP">
##  <ManSection>
##  <Func Name="RestrictOutputsOfSLP" Arg='slp, k'/>
##
##  <Description>
##  <A>slp</A> must be a straight line program returning a tuple
##  of values. This function
##  returns a new slp that calculates only those outputs specified by
##  <A>k</A>. The argument
##  <A>k</A> may be an integer or a list of integers. If <A>k</A> is an integer,
##  the resulting slp calculates only the result with that number
##  in the original output tuple.
##  If <A>k</A> is a list of integers, the resulting slp calculates those
##  results with indices <A>k</A> in the original output tuple.
##  In both cases the resulting slp
##  does only what is necessary. Obviously, the slp must have a line with
##  enough expressions (lists) for the supplied <A>k</A> as its last line.
##  <A>slp</A> is either an slp or a pair where the first entry are the lines
##  of the slp and the second is the number of inputs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RestrictOutputsOfSLP" );

##
#F  IntermediateResultOfSLP( <slp>, <k> )
##
##  <#GAPDoc Label="IntermediateResultOfSLP">
##  <ManSection>
##  <Func Name="IntermediateResultOfSLP" Arg='slp, k'/>
##
##  <Description>
##  Returns a new slp that calculates only the value of slot <A>k</A>
##  at the end of <A>slp</A> doing only what is necessary.
##  slp is either an slp or a pair where the first entry are the lines
##  of the slp and the second is the number of inputs.
##  Note that this assumes a general SLP with possible overwriting.
##  If you know that your SLP does not overwrite slots, please use
##  <Ref Func="IntermediateResultOfSLPWithoutOverwrite"/>,
##  which is much faster in this case.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntermediateResultOfSLP" );

##
#F  IntermediateResultsOfSLPWithoutOverwriteInner( ... )
##
##  <ManSection>
##  <Func Name="IntermediateResultsOfSLPWithoutOverwriteInner" Arg='...'/>
##
##  <Description>
##  Internal function.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "IntermediateResultsOfSLPWithoutOverwriteInner" );

##
#F  IntermediateResultsOfSLPWithoutOverwrite( <slp>, <k> )
##
##  <#GAPDoc Label="IntermediateResultsOfSLPWithoutOverwrite">
##  <ManSection>
##  <Func Name="IntermediateResultsOfSLPWithoutOverwrite" Arg='slp, k'/>
##
##  <Description>
##  Returns a new slp that calculates only the values of slots contained
##  in the list <A>k</A>.
##  Note that <A>slp</A> must not overwrite slots but only append!!!
##  Use <Ref Func="IntermediateResultOfSLP"/> in the other case!
##  <A>slp</A> is either a slp or a pair where the first entry is the
##  list of lines of the slp and the second is the number of its inputs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntermediateResultsOfSLPWithoutOverwrite" );

##
#F  IntermediateResultOfSLPWithoutOverwrite( <slp>, <k> )
##
##  <#GAPDoc Label="IntermediateResultOfSLPWithoutOverwrite">
##  <ManSection>
##  <Func Name="IntermediateResultOfSLPWithoutOverwrite" Arg='slp, k'/>
##
##  <Description>
##  Returns a new slp that calculates only the value of slot <A>k</A>, which
##  must be an integer.
##  Note that <A>slp</A> must not overwrite slots but only append!!!
##  Use <Ref Func="IntermediateResultOfSLP"/> in the other case!
##  <A>slp</A> is either an slp or a pair where the first entry is the
##  list of lines of the slp and the second is the number of its inputs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntermediateResultOfSLPWithoutOverwrite" );

##
#F  ProductOfStraightLinePrograms( <s1>, <s2> )
##
##  <#GAPDoc Label="ProductOfStraightLinePrograms">
##  <ManSection>
##  <Func Name="ProductOfStraightLinePrograms" Arg='s1, s2'/>
##
##  <Description>
##  <A>s1</A> and <A>s2</A> must be two slps that return a single element with the same
##  number of inputs. This function constructs an slp that returns the product
##  of the two results the slps <A>s1</A> and <A>s2</A> would produce with the same
##  input.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ProductOfStraightLinePrograms" );

##
#F  RewriteStraightLineProgram(<s>,<l>,<lsu>,<inputs>,<tabuslots>)
##
##  <ManSection>
##  <Func Name="RewriteStraightLineProgram" Arg='s,l,lsu,inputs,tabuslots'/>
##
##  <Description>
##  The purpose of this function is the following: Append the slp <A>s</A> to
##  the one currently built in <A>l</A>.
##  The prospective inputs are already standing somewhere and some
##  slots may not be used by the new copy of <A>s</A> within <A>l</A>.
##  <P/>
##  <A>s</A> must be a GAP straight line program.
##  <A>l</A> must be a mutable list making the beginning of a straight line program
##  without result line so far. <A>lsu</A> must be the largest used slot of the
##  slp in <A>l</A> so far. <A>inputs</A> is a list of slot numbers, in which the
##  inputs are, that the copy of <A>s</A> in <A>l</A> should work on, that is, its length
##  must be equal to the number of inputs <A>s</A> takes. <A>tabuslots</A> is a list of
##  slot numbers which will not be overwritten by the new copy of <A>s</A> in <A>l</A>.
##  This function changes <A>l</A> and returns a record with components
##  <C>l</C> being <A>l</A>, <C>results</C> being
##  a list of slot numbers, in which the results of <A>s</A> are stored in the end
##  and <C>lsu</C> being the number of the largest slot used by <A>l</A> up to now.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "RewriteStraightLineProgram" );

##
#F  NewCompositionOfStraightLinePrograms( <s2>, <s1> )
##
##  <ManSection>
##  <Func Name="NewCompositionOfStraightLinePrograms" Arg='s2, s1'/>
##
##  <Description>
##  A new implementation of <Ref Func="CompositionOfStraightLinePrograms"/> using
##  <Ref Func="RewriteStraightLineProgram"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "NewCompositionOfStraightLinePrograms" );

##
#F  NewProductOfStraightLinePrograms( <s2>, <s1> )
##
##  <ManSection>
##  <Func Name="NewProductOfStraightLinePrograms" Arg='s2, s1'/>
##
##  <Description>
##  A new implementation of <Ref Func="ProductOfStraightLinePrograms"/> using
##  <Ref Func="RewriteStraightLineProgram"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "NewProductOfStraightLinePrograms" );

##
#A  SlotUsagePattern( <s> )
##
##  <#GAPDoc Label="SlotUsagePattern">
##  <ManSection>
##  <Attr Name="SlotUsagePattern" Arg="s"/>
##
##  <Description>
##  Analyses the straight line program <A>s</A> for more efficient
##  evaluation. This means in particular two things, when this attribute
##  is known: First of all,
##  intermediate results which are not actually needed later on are
##  not computed at all, and once an intermediate result is used for
##  the last time in this SLP, it is discarded. The latter leads to
##  the fact that the evaluation of the SLP needs less memory.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SlotUsagePattern", IsStraightLineProgram );

##
#A  LargestNrSlots( <s> )
##
##  <ManSection>
##  <Attr Name="LargestNrSlots" Arg="s"/>
##
##  <Description>
##  Returns the maximal number of slots used during the evaluation of
##  the SLP <A>s</A>.
##  </Description>
##  </ManSection>
DeclareAttribute( "LargestNrSlots", IsStraightLineProgram );

##
#I  InfoSLP
##
DeclareInfoClass( "InfoSLP" );
SetInfoLevel(InfoSLP,1);
