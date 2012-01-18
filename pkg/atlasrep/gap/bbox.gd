#############################################################################
##
#W  bbox.gd              GAP 4 package AtlasRep                 Thomas Breuer
#W                                                            Simon Nickerson
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of the operations
##  for black box programs and straight line decisions.
##
##  1. Functions for black box algorithms
##  2. Functions for straight line decisions
##


#############################################################################
##
##  1. Functions for black box algorithms
##
##  <#GAPDoc Label="BBoxIntro">
##  <E>Black box programs</E> formalize the idea that one takes some group
##  elements, forms arithmetic expressions in terms of them, tests properties
##  of these expressions,
##  executes conditional statements (including jumps inside the program)
##  depending on the results of these tests,
##  and eventually returns some result.
##  <P/>
##  A specification of the language can be found in <Cite Key="Nic06"/>,
##  see also
##  <P/>
##  <URL>http://brauer.maths.qmul.ac.uk/Atlas/info/blackbox.html</URL>.
##  <P/>
##  The <E>inputs</E> of a black box program may be explicit group elements,
##  and the program may also ask for random elements from a given group.
##  The <E>program steps</E> form products, inverses, conjugates,
##  commutators, etc. of known elements,
##  <E>tests</E> concern essentially the orders of elements,
##  and the <E>result</E> is a list of group elements or <K>true</K> or
##  <K>false</K> or <K>fail</K>.
##  <P/>
##  Examples that can be modeled by black box programs are
##  <P/>
##  <List>
##  <Mark><E>straight line programs</E>,</Mark>
##  <Item>
##    which require a fixed number of input elements and form arithmetic
##    expressions of elements but do not use random elements, tests,
##    conditional statements and jumps;
##    the return value is always a list of elements;
##    these programs are described
##    in Section <Ref Sect="Straight Line Programs" BookName="ref"/>.
##  </Item>
##  <Mark><E>straight line decisions</E>,</Mark>
##  <Item>
##    which differ from straight line programs only in the sense that also
##    order tests are admissible,
##    and that the return value is <K>true</K> if all these tests are
##    satisfied, and <K>false</K> as soon as the first such test fails;
##    they are described
##    in Section <Ref Sect="sect:Straight Line Decisions"/>.
##  </Item>
##  <Mark><E>scripts for finding standard generators</E>,</Mark>
##  <Item>
##    which take a group and a function to generate a random element in this
##    group but no explicit input elements,
##    admit all control structures, and return either a list of standard
##    generators or <K>fail</K>;
##    see <Ref Func="ResultOfBBoxProgram"/> for examples.
##  </Item>
##  </List>
##  <P/>
##  In the case of general black box programs, currently &GAP; provides only
##  the possibility to read an existing program via
##  <Ref Func="ScanBBoxProgram"/>,
##  and to run the program using <Ref Func="RunBBoxProgram"/>.
##  It is not our aim to write such programs in &GAP;.
##  <P/>
##  The special case of the <Q>find</Q> scripts mentioned above is also
##  admissible as an argument of <Ref Func="ResultOfBBoxProgram"/>,
##  which returns either the set of generators or <K>fail</K>.
##  <P/>
##  Contrary to the general situation,
##  more support is provided for straight line programs and straight line
##  decisions in &GAP;,
##  see Section <Ref Sect="Straight Line Programs" BookName="ref"/>
##  for functions that manipulate them (compose, restrict etc.).
##  <P/>
##  The functions <Ref Func="AsStraightLineProgram"/> and
##  <Ref Func="AsStraightLineDecision"/> can be used to transform a general
##  black box program object into a straight line program or a straight line
##  decision if this is possible.
##  <P/>
##  Conversely, one can create an equivalent general black box program from
##  a straight line program or from a straight line decision with
##  <Ref Func="AsBBoxProgram"/>.
##  <P/>
##  (Computing a straight line program related to a given straight line
##  decision is supported in the sense of
##  <Ref Func="StraightLineProgramFromStraightLineDecision"/>.)
##  <P/>
##  Note that none of these three kinds of objects is a special case of
##  another:
##  Running a black box program with <Ref Func="RunBBoxProgram"/> yields a
##  record,
##  running a straight line program with
##  <Ref Func="ResultOfStraightLineProgram" BookName="ref"/> yields a list of
##  elements,
##  and running a straight line decision with
##  <Ref Func="ResultOfStraightLineDecision"/> yields <K>true</K> or
##  <K>false</K>.
##  <#/GAPDoc>
##


#############################################################################
##
#V  InfoBBox
##
##  <#GAPDoc Label="InfoBBox">
##  <ManSection>
##  <InfoClass Name="InfoBBox"/>
##
##  <Description>
##  If the info level of <Ref InfoClass="InfoBBox"/> is at least <M>1</M>
##  then information about <K>fail</K> results of functions dealing with
##  black box programs (see Section <Ref Sect="sect:Black Box Programs"/>)
##  is printed.
##  The default level is <M>0</M>, no information is printed on this level.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoBBox" );


#############################################################################
##
#C  IsBBoxProgram( <obj> )
##
##  <#GAPDoc Label="IsBBoxProgram">
##  <ManSection>
##  <Filt Name="IsBBoxProgram" Arg='obj' Type="Category"/>
##
##  <Description>
##  Each black box program in &GAP; lies in the filter
##  <Ref Func="IsBBoxProgram"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsBBoxProgram", IsObject );


#############################################################################
##
#A  LinesOfBBoxProgram( <prog> )
##
##  Since no black box program can be a straight line program,
##  we (ab)use the available attribute.
##
DeclareSynonymAttr( "LinesOfBBoxProgram", LinesOfStraightLineProgram );


#############################################################################
##
#F  ScanBBoxProgram( <string> )
##
##  <#GAPDoc Label="ScanBBoxProgram">
##  <ManSection>
##  <Func Name="ScanBBoxProgram" Arg='string'/>
##
##  <Returns>
##  a record containing the black box program encoded by the input string,
##  or <K>fail</K>.
##  </Returns>
##  <Description>
##  For a string <A>string</A> that describes a black box program, e.g.,
##  the return value of <Ref Func="StringFile" BookName="gapdoc"/>,
##  <Ref Func="ScanBBoxProgram"/> computes this black box program.
##  If this is successful then the return value is a record containing as the
##  value of its component <C>program</C> the corresponding &GAP; object
##  that represents the program,
##  otherwise <K>fail</K> is returned.
##  <P/>
##  As the first example, we construct a black box program that tries to find
##  standard generators for the alternating group <M>A_5</M>;
##  these standard generators are any pair of elements of the orders <M>2</M>
##  and <M>3</M>, respectively, such that their product has order <M>5</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> findstr:= "\
##  >   set V 0\n\
##  > lbl START1\n\
##  >   rand 1\n\
##  >   ord 1 A\n\
##  >   incr V\n\
##  >   if V gt 100 then timeout\n\
##  >   if A notin 1 2 3 5 then fail\n\
##  >   if A noteq 2 then jmp START1\n\
##  > lbl START2\n\
##  >   rand 2\n\
##  >   ord 2 B\n\
##  >   incr V\n\
##  >   if V gt 100 then timeout\n\
##  >   if B notin 1 2 3 5 then fail\n\
##  >   if B noteq 3 then jmp START2\n\
##  >   # The elements 1 and 2 have the orders 2 and 3, respectively.\n\
##  >   set X 0\n\
##  > lbl CONJ\n\
##  >   incr X\n\
##  >   if X gt 100 then timeout\n\
##  >   rand 3\n\
##  >   cjr 2 3\n\
##  >   mu 1 2 4   # ab\n\
##  >   ord 4 C\n\
##  >   if C notin 2 3 5 then fail\n\
##  >   if C noteq 5 then jmp CONJ\n\
##  >   oup 2 1 2";;
##  gap> find:= ScanBBoxProgram( findstr );
##  rec( program := <black box program> )
##  ]]></Example>
##  <P/>
##  The second example is a black box program that checks whether its two
##  inputs are standard generators for <M>A_5</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> checkstr:= "\
##  > chor 1 2\n\
##  > chor 2 3\n\
##  > mu 1 2 3\n\
##  > chor 3 5";;
##  gap> check:= ScanBBoxProgram( checkstr );
##  rec( program := <black box program> )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ScanBBoxProgram" );


#############################################################################
##
#F  BBoxPerformInstruction( fullline, ins, G, ans, gpelts, ctr, options )
##
##  local utility (but recursive, therefore we declare it here)
##
DeclareGlobalFunction( "BBoxPerformInstruction" );


#############################################################################
##
#F  RunBBoxProgram( <prog>, <G>, <input>, <options> )
##
##  <#GAPDoc Label="RunBBoxProgram">
##  <ManSection>
##  <Func Name="RunBBoxProgram" Arg='prog, G, input, options'/>
##
##  <Returns>
##  a record describing the result and the statistics of running the
##  black box program <A>prog</A>, or <K>fail</K>,
##  or the string <C>"timeout"</C>.
##  </Returns>
##  <Description>
##  For a black box program <A>prog</A>, a group <A>G</A>,
##  a list <A>input</A> of group elements,
##  and a record <A>options</A>,
##  <Ref Func="RunBBoxProgram"/> applies <A>prog</A> to <A>input</A>,
##  where <A>G</A> is used only to compute random elements.
##  <P/>
##  The return value is <K>fail</K> if a syntax error or
##  an explicit <C>fail</C> statement is reached at runtime,
##  and the string <C>"timeout"</C> if a <C>timeout</C> statement is reached.
##  (The latter might mean that the random choices were unlucky.)
##  Otherwise a record with the following components is returned.
##  <P/>
##  <List>
##  <Mark><C>gens</C></Mark>
##  <Item>
##    a list of group elements, bound if an <C>oup</C> statement was reached,
##  </Item>
##  <Mark><C>result</C></Mark>
##  <Item>
##    <K>true</K> if a <C>true</C> statement was reached,
##    <K>false</K> if either a <C>false</C> statement or a failed order check
##    was reached,
##  </Item>
##  </List>
##  <P/>
##  The other components serve as statistical information about the numbers
##  of the various operations (<C>multiply</C>, <C>invert</C>, <C>power</C>,
##  <C>order</C>, <C>random</C>, <C>conjugate</C>, <C>conjugateinplace</C>,
##  <C>commutator</C>), and the runtime in milliseconds (<C>timetaken</C>).
##  <P/>
##  The following components of <A>options</A> are supported.
##  <P/>
##  <List>
##  <Mark><C>randomfunction</C></Mark>
##  <Item>
##    the function called with argument <A>G</A> in order to compute a
##    random element of <A>G</A>
##    (default <Ref Oper="PseudoRandom" BookName="ref"/>)
##  </Item>
##  <Mark><C>orderfunction</C></Mark>
##  <Item>
##    the function for computing element orders
##    (the default is <Ref Oper="Order" BookName="ref"/>),
##  </Item>
##  <Mark><C>quiet</C></Mark>
##  <Item>
##    if <K>true</K> then ignore <C>echo</C> statements
##    (default <K>false</K>),
##  </Item>
##  <Mark><C>verbose</C></Mark>
##  <Item>
##    if <K>true</K> then print information about the line that is currently
##    processed, and about order checks (default <K>false</K>),
##  </Item>
##  <Mark><C>allowbreaks</C></Mark>
##  <Item>
##    if <K>true</K> then call <Ref Func="Error" BookName="ref"/> when a
##    <C>break</C> statement is reached, otherwise ignore <C>break</C>
##    statements (default <K>true</K>).
##  </Item>
##  </List>
##  <P/>
##  As an example, we run the black box programs constructed in the example
##  for <Ref Func="ScanBBoxProgram"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= AlternatingGroup( 5 );;
##  gap> res:= RunBBoxProgram( find.program, g, [], rec() );;
##  gap> IsBound( res.gens );  IsBound( res.result );
##  true
##  false
##  gap> List( res.gens, Order );
##  [ 2, 3 ]
##  gap> Order( Product( res.gens ) );
##  5
##  gap> res:= RunBBoxProgram( check.program, "dummy", res.gens, rec() );;
##  gap> IsBound( res.gens );  IsBound( res.result );
##  false
##  true
##  gap> res.result;
##  true
##  gap> othergens:= GeneratorsOfGroup( g );;
##  gap> res:= RunBBoxProgram( check.program, "dummy", othergens, rec() );;
##  gap> res.result;
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RunBBoxProgram" );


#############################################################################
##
#F  ResultOfBBoxProgram( <prog>, <G> )
#F  ResultOfBBoxProgram( <prog>, <gens> )
##
##  <#GAPDoc Label="ResultOfBBoxProgram">
##  <ManSection>
##  <Func Name="ResultOfBBoxProgram" Arg='prog, G'/>
##
##  <Returns>
##  a list of group elements or <K>true</K>, <K>false</K>, <K>fail</K>,
##  or the string <C>"timeout"</C>.
##  </Returns>
##  <Description>
##  This function calls <Ref Func="RunBBoxProgram"/>
##  with the black box program <A>prog</A> and second argument either a group
##  or a list of group elements; the default options are assumed.
##  The return value is <K>fail</K> if this call yields <K>fail</K>,
##  otherwise the <C>gens</C> component of the result, if bound,
##  or the <C>result</C> component if not.
##  <P/>
##  As an example, we run the black box programs constructed in the example
##  for <Ref Func="ScanBBoxProgram"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= AlternatingGroup( 5 );;
##  gap> res:= ResultOfBBoxProgram( find.program, g );;
##  gap> List( res, Order );
##  [ 2, 3 ]
##  gap> Order( Product( res ) );
##  5
##  gap> res:= ResultOfBBoxProgram( check.program, res );
##  true
##  gap> othergens:= GeneratorsOfGroup( g );;
##  gap> res:= ResultOfBBoxProgram( check.program, othergens );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ResultOfBBoxProgram" );


#############################################################################
##
##  2. Functions for straight line decisions
##


#############################################################################
##
##  <#GAPDoc Label="StraightLineDecisionIntro">
##  <E>Straight line decisions</E> are similar to straight line programs
##  (see Section&nbsp;<Ref Sect="Straight Line Programs" BookName="ref"/>)
##  but return <K>true</K> or <K>false</K>.
##  A straight line decisions checks a property for its inputs.
##  An important example is to check whether a given list of group generators
##  is in fact a list of standard generators
##  (cf.&nbsp;Section<Ref Sect="sect:Standard Generators Used in AtlasRep"/>)
##  for this group.
##  <P/>
##  A straight line decision in &GAP; is represented by an object in the
##  filter <Ref Filt="IsStraightLineDecision"/>
##  that stores a list of <Q>lines</Q>
##  each of which has one of the following three forms.
##  <P/>
##  <Enum>
##  <Item>
##      a nonempty dense list <M>l</M> of integers,
##  </Item>
##  <Item>
##      a pair <M>[ l, i ]</M> where
##      <M>l</M> is a list of form 1. and <M>i</M> is a positive integer,
##  </Item>
##  <Item>
##      a list <M>[ </M><C>"Order"</C><M>, i, n ]</M>
##      where <M>i</M> and <M>n</M> are positive integers.
##  </Item>
##  </Enum>
##  <P/>
##  The first two forms have the same meaning as for straight line programs
##  (see Section&nbsp;<Ref Sect="Straight Line Programs" BookName="ref"/>),
##  the last form means a check whether the element stored at the label
##  <M>i</M>-th has the order <M>n</M>.
##  <P/>
##  For the meaning of the list of lines, see
##  <Ref Oper="ResultOfStraightLineDecision"/>.
##  <P/>
##  Straight line decisions can be constructed using
##  <Ref Func="StraightLineDecision"/>,
##  defining attributes for straight line decisions are
##  <Ref Func="NrInputsOfStraightLineDecision"/> and
##  <Ref Func="LinesOfStraightLineDecision"/>,
##  an operation for straight line decisions is
##  <Ref Func="ResultOfStraightLineDecision"/>.
##  <P/>
##  Special methods applicable to straight line decisions are installed for
##  the operations <Ref Func="Display" BookName="ref"/>,
##  <Ref Func="IsInternallyConsistent" BookName="ref"/>,
##  <Ref Func="PrintObj" BookName="ref"/>,
##  and <Ref Func="ViewObj" BookName="ref"/>.
##  <P/>
##  For a straight line decision <A>prog</A>,
##  the default <Ref Func="Display" BookName="ref"/> method prints
##  the interpretation of <A>prog</A> as a sequence of assignments
##  of associative words and of order checks;
##  a record with components <C>gensnames</C> (with value a list of strings)
##  and <C>listname</C> (a string) may be entered as second argument of
##  <Ref Func="Display" BookName="ref"/>,
##  in this case these names are used, the default for <C>gensnames</C> is
##  <C>[ g1, g2, </C><M>\ldots</M><C> ]</C>,
##  the default for <A>listname</A> is <M>r</M>.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsStraightLineDecision( <obj> )
##
##  <#GAPDoc Label="IsStraightLineDecision">
##  <ManSection>
##  <Filt Name="IsStraightLineDecision" Arg='obj' Type="Category"/>
##
##  <Description>
##  Each straight line decision in &GAP; lies in the filter
##  <Ref Func="IsStraightLineDecision"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsStraightLineDecision", IsObject );


#############################################################################
##
#F  StraightLineDecision( <lines>[, <nrgens>] )
#F  StraightLineDecisionNC( <lines>[, <nrgens>] )
##
##  <#GAPDoc Label="StraightLineDecision">
##  <ManSection>
##  <Func Name="StraightLineDecision" Arg='lines[, nrgens]'/>
##  <Func Name="StraightLineDecisionNC" Arg='lines[, nrgens]'/>
##
##  <Returns>
##  the straight line decision given by the list of lines.
##  </Returns>
##  <Description>
##  Let <A>lines</A> be a list of lists that defines a unique
##  straight line decision (see&nbsp;<Ref Func="IsStraightLineDecision"/>);
##  in this case <Ref Func="StraightLineDecision"/> returns this program,
##  otherwise an error is signalled.
##  The optional argument <A>nrgens</A> specifies the number of
##  input generators of the program;
##  if a list of integers (a line of form 1. in the definition above) occurs
##  in <A>lines</A> then this number is not determined by <A>lines</A>
##  and therefore <E>must</E> be specified by the argument <A>nrgens</A>;
##  if not then <Ref Func="StraightLineDecision"/> returns <K>fail</K>.
##  <P/>
##  <Ref Func="StraightLineDecisionNC"/> does the same as
##  <Ref Func="StraightLineDecision"/>,
##  except that the internal consistency of the program is not checked.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StraightLineDecision" );

DeclareGlobalFunction( "StraightLineDecisionNC" );


#############################################################################
##
#A  LinesOfStraightLineDecision( <prog> )
##
##  <#GAPDoc Label="LinesOfStraightLineDecision">
##  <ManSection>
##  <Oper Name="LinesOfStraightLineDecision" Arg='prog'/>
##
##  <Returns>
##  the list of lines that define the straight line decision.
##  </Returns>
##  <Description>
##  This defining attribute for the straight line decision <A>prog</A>
##  (see <Ref Func="IsStraightLineDecision"/>) corresponds to
##  <Ref Attr="LinesOfStraightLineProgram" BookName="ref"/>
##  for straight line programs.
##  <P/>
##  <Example><![CDATA[
##  gap> dec:= StraightLineDecision( [ [ [ 1, 1, 2, 1 ], 3 ],
##  > [ "Order", 1, 2 ], [ "Order", 2, 3 ], [ "Order", 3, 5 ] ] );
##  <straight line decision>
##  gap> LinesOfStraightLineDecision( dec );
##  [ [ [ 1, 1, 2, 1 ], 3 ], [ "Order", 1, 2 ], [ "Order", 2, 3 ], 
##    [ "Order", 3, 5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LinesOfStraightLineDecision", IsStraightLineDecision );


#############################################################################
##
#A  NrInputsOfStraightLineDecision( <prog> )
##
##  <#GAPDoc Label="NrInputsOfStraightLineDecision">
##  <ManSection>
##  <Oper Name="NrInputsOfStraightLineDecision" Arg='prog'/>
##
##  <Returns>
##  the number of inputs required for the straight line decision.
##  </Returns>
##  <Description>
##  This defining attribute corresponds to
##  <Ref Attr="NrInputsOfStraightLineProgram" BookName="ref"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> NrInputsOfStraightLineDecision( dec );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NrInputsOfStraightLineDecision", IsStraightLineDecision );


#############################################################################
##
#O  ResultOfStraightLineDecision( <prog>, <gens>[, <orderfunc>] )
##
##  <#GAPDoc Label="ResultOfStraightLineDecision">
##  <ManSection>
##  <Oper Name="ResultOfStraightLineDecision" Arg='prog, gens[, orderfunc]'/>
##
##  <Returns>
##  <K>true</K> if all checks succeed, otherwise <K>false</K>.
##  </Returns>
##  <Description>
##  <Ref Oper="ResultOfStraightLineDecision"/> evaluates the straight line
##  decision (see&nbsp;<Ref Func="IsStraightLineDecision"/>) <A>prog</A>
##  at the group elements in the list <A>gens</A>.
##  <P/>
##  The function for computing the order of a group element can be given as
##  the optional argument <A>orderfunc</A>.
##  For example, this may be a function that gives up at a certain limit
##  if one has to be aware of extremely huge orders in failure cases.
##  <P/>
##  The <E>result</E> of a straight line decision with lines
##  <M>p_1, p_2, \ldots, p_k</M>
##  when applied to <A>gens</A> is defined as follows.
##  <P/>
##  <List>
##  <Mark>(a)</Mark>
##  <Item>
##      First a list <M>r</M> of intermediate values is initialized
##      with a shallow copy of <A>gens</A>.
##  </Item>
##  <Mark>(b)</Mark>
##  <Item>
##      For <M>i \leq k</M>, before the <M>i</M>-th step,
##      let <M>r</M> be of length <M>n</M>.
##      If <M>p_i</M> is the external representation of an associative word
##      in the first <M>n</M> generators then the image of this word
##      under the homomorphism that is given by mapping <M>r</M>
##      to these first <M>n</M> generators is added to <M>r</M>.
##      If <M>p_i</M> is a pair <M>[ l, j ]</M>, for a list <M>l</M>,
##      then the same element is computed,
##      but instead of being added to <M>r</M>,
##      it replaces the <M>j</M>-th entry of <M>r</M>.
##      If <M>p_i</M> is a triple <M>[ </M><C>"Order"</C><M>, i, n ]</M>
##      then it is checked whether the order of <M>r[i]</M> is <M>n</M>;
##      if not then <K>false</K> is returned immediately.
##  </Item>
##  <Mark>(c)</Mark>
##  <Item>
##      If all <M>k</M> lines have been processed and no order check
##      has failed then <K>true</K> is returned.
##  </Item>
##  </List>
##  <P/>
##  Here are some examples.
##  <P/>
##  <Example><![CDATA[
##  gap> dec:= StraightLineDecision( [ ], 1 );
##  <straight line decision>
##  gap> ResultOfStraightLineDecision( dec, [ () ] );
##  true
##  ]]></Example>
##  <P/>
##  The above straight line decision <C>dec</C> returns <K>true</K>
##  &ndash;for <E>any</E> input of the right length.
##  <P/>
##  <Example><![CDATA[
##  gap> dec:= StraightLineDecision( [ [ [ 1, 1, 2, 1 ], 3 ],
##  >       [ "Order", 1, 2 ], [ "Order", 2, 3 ], [ "Order", 3, 5 ] ] );
##  <straight line decision>
##  gap> LinesOfStraightLineDecision( dec );
##  [ [ [ 1, 1, 2, 1 ], 3 ], [ "Order", 1, 2 ], [ "Order", 2, 3 ], 
##    [ "Order", 3, 5 ] ]
##  gap> ResultOfStraightLineDecision( dec, [ (), () ] );
##  false
##  gap> ResultOfStraightLineDecision( dec, [ (1,2)(3,4), (1,4,5) ] );
##  true
##  ]]></Example>
##  <P/>
##  The above straight line decision admits two inputs;
##  it tests whether the orders of the inputs are <M>2</M> and <M>3</M>,
##  and the order of their product is <M>5</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ResultOfStraightLineDecision",
    [ IsStraightLineDecision, IsHomogeneousList ] );

DeclareOperation( "ResultOfStraightLineDecision",
    [ IsStraightLineDecision, IsHomogeneousList, IsFunction ] );


#############################################################################
##
##  <#GAPDoc Label="Semi-Presentations">
##  <Subsection Label="Semi-Presentations and Presentations">
##  <Heading>Semi-Presentations and Presentations</Heading>
##
##  <Index>semi-presentation</Index>
##  We can associate a <E>finitely presented group</E> <M>F / R</M>
##  to each straight line decision <A>dec</A>, say, as follows.
##  The free generators of the free group <M>F</M> are in bijection
##  with the inputs, and the defining relators generating <M>R</M> as a
##  normal subgroup of <M>F</M> are given by those words <M>w^k</M>
##  for which <A>dec</A> contains a check whether the order of <M>w</M>
##  equals <M>k</M>.
##  <P/>
##  So if <A>dec</A> returns <K>true</K> for the input list
##  <M>[ g_1, g_2, \ldots, g_n ]</M> then mapping the free generators of
##  <M>F</M> to the inputs defines an epimorphism <M>\Phi</M> from <M>F</M>
##  to the group <M>G</M>, say, that is generated by these inputs,
##  such that <M>R</M> is contained in the kernel of <M>\Phi</M>.
##  <P/>
##  (Note that <Q>satisfying <A>dec</A></Q> is a stronger property than
##  <Q>satisfying a presentation</Q>.<Index>presentation</Index>
##  For example, <M>\langle x \mid x^2 = x^3 = 1 \rangle</M>
##  is a presentation for the trivial group, but the straight line decision
##  that checks whether the order of <M>x</M> is both <M>2</M> and <M>3</M>
##  clearly always returns <K>false</K>.)
##  <P/>
##  The &ATLAS; of Group Representations contains the following two kinds of
##  straight line decisions.
##  <P/>
##  <List>
##  <Item>
##    A <E>presentation</E> is a straight line decision <A>dec</A>
##    that is defined for a set of standard generators of a group <M>G</M>
##    and that returns <K>true</K> if and only if the list of inputs is
##    in fact a sequence of such standard generators for <M>G</M>.
##    In other words, the relators derived from the order checks in the way
##    described above are defining relators for <M>G</M>,
##    and moreover these relators are words in terms of standard generators.
##    (In particular the kernel of the map <M>\Phi</M> equals <M>R</M>
##    whenever <A>dec</A> returns <K>true</K>.)
##  </Item>
##  <Item>
##    A <E>semi-presentation</E> is a straight line decision <A>dec</A>
##    that is defined for a set of standard generators of a group <M>G</M>
##    and that returns <K>true</K> for a list of inputs <E>that is known to
##    generate a group isomorphic with <M>G</M></E> if and only if
##    these inputs form in fact a sequence of standard generators for
##    <M>G</M>.
##    In other words, the relators derived from the order checks in the way
##    described above are <E>not necessarily defining relators</E>
##    for <M>G</M>, but if we assume that the <M>g_i</M> generate <M>G</M>
##    then they are standard generators.
##    (In particular, <M>F / R</M> may be a larger group than <M>G</M>
##    but in this case <M>\Phi</M> maps the free generators of <M>F</M>
##    to standard generators of <M>G</M>.)
##    <P/>
##    More about semi-presentations can be found in <Cite Key="NW05"/>.
##  </Item>
##  </List>
##  <P/>
##  Available presentations and semi-presentations are listed by
##  <Ref Func="DisplayAtlasInfo"/>,
##  they can be accessed via <Ref Func="AtlasProgram"/>.
##  (Clearly each presentation is also a semi-presentation.
##  So a semi-presentation for some standard generators of a group is
##  regarded as available whenever a presentation for these standard
##  generators and this group is available.)
##  <P/>
##  Note that different groups can have the same semi-presentation.
##  We illustrate this with an example that is mentioned in
##  <Cite Key="NW05"/>.
##  The groups <M>L_2(7) \cong L_3(2)</M> and <M>L_2(8)</M> are generated by
##  elements of the orders <M>2</M> and <M>3</M> such that their product has
##  order <M>7</M>, and no further conditions are necessary to define
##  standard generators.
##  <P/>
##  <Example><![CDATA[
##  gap> check:= AtlasProgram( "L2(8)", "check" );
##  rec( groupname := "L2(8)", identifier := [ "L2(8)", "L28G1-check1", 1, 1 ], 
##    program := <straight line decision>, standardization := 1 )
##  gap> gens:= AtlasGenerators( "L2(8)", 1 );
##  rec( charactername := "1a+8a", 
##    generators := [ (1,2)(3,4)(6,7)(8,9), (1,3,2)(4,5,6)(7,8,9) ], 
##    groupname := "L2(8)", id := "", 
##    identifier := [ "L2(8)", [ "L28G1-p9B0.m1", "L28G1-p9B0.m2" ], 1, 9 ], 
##    isPrimitive := true, maxnr := 1, p := 9, rankAction := 2, 
##    repname := "L28G1-p9B0", repnr := 1, size := 504, stabilizer := "2^3:7", 
##    standardization := 1, transitivity := 3, type := "perm" )
##  gap> ResultOfStraightLineDecision( check.program, gens.generators );
##  true
##  gap> gens:= AtlasGenerators( "L3(2)", 1 );
##  rec( generators := [ (2,4)(3,5), (1,2,3)(5,6,7) ], groupname := "L3(2)", 
##    id := "a", identifier := [ "L3(2)", [ "L27G1-p7aB0.m1", "L27G1-p7aB0.m2" ], 
##        1, 7 ], isPrimitive := true, maxnr := 1, p := 7, rankAction := 2, 
##    repname := "L27G1-p7aB0", repnr := 1, size := 168, stabilizer := "S4", 
##    standardization := 1, transitivity := 2, type := "perm" )
##  gap> ResultOfStraightLineDecision( check.program, gens.generators );
##  true
##  ]]></Example>
##  </Subsection>
##  <#/GAPDoc>
##


#############################################################################
##
#O  StraightLineProgramFromStraightLineDecision( <dec> )
##
##  <#GAPDoc Label="StraightLineProgramFromStraightLineDecision">
##  <ManSection>
##  <Oper Name="StraightLineProgramFromStraightLineDecision" Arg='dec'/>
##
##  <Returns>
##  the straight line program associated to the given straight line decision.
##  </Returns>
##  <Description>
##  For a straight line decision <A>dec</A>
##  (see <Ref Func="IsStraightLineDecision"/>,
##  <Ref Oper="StraightLineProgramFromStraightLineDecision"/> returns the
##  straight line program
##  (see <Ref Func="IsStraightLineProgram" BookName="ref"/> obtained by
##  replacing each line of type 3. (i.e, each order check) by an
##  assignment of the power in question to a new slot,
##  and by declaring the list of these elements as the return value.
##  <P/>
##  This means that the return value describes exactly the defining relators
##  of the presentation that is associated to the straight line decision,
##  see <Ref Subsect="Semi-Presentations and Presentations"/>.
##  <P/>
##  For example, one can use the return value for printing the relators with
##  <Ref Func="StringOfResultOfStraightLineProgram" BookName="ref"/>,
##  or for explicitly constructing the relators as words in terms of free
##  generators,
##  by applying <Ref Func="ResultOfStraightLineProgram" BookName="ref"/>
##  to the program and to these generators.
##  <P/>
##  <Example><![CDATA[
##  gap> dec:= StraightLineDecision( [ [ [ 1, 1, 2, 1 ], 3 ],
##  > [ "Order", 1, 2 ], [ "Order", 2, 3 ], [ "Order", 3, 5 ] ] );
##  <straight line decision>
##  gap> prog:= StraightLineProgramFromStraightLineDecision( dec );
##  <straight line program>
##  gap> Display( prog );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  r[3]:= r[1]*r[2];
##  r[4]:= r[1]^2;
##  r[5]:= r[2]^3;
##  r[6]:= r[3]^5;
##  # return values:
##  [ r[4], r[5], r[6] ]
##  gap> StringOfResultOfStraightLineProgram( prog, [ "a", "b" ] );
##  "[ a^2, b^3, (ab)^5 ]"
##  gap> gens:= GeneratorsOfGroup( FreeGroup( "a", "b" ) );
##  [ a, b ]
##  gap> ResultOfStraightLineProgram( prog, gens );
##  [ a^2, b^3, a*b*a*b*a*b*a*b*a*b ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "StraightLineProgramFromStraightLineDecision",
    [ IsStraightLineDecision ] );


#############################################################################
##
#A  AsBBoxProgram( <slp> )
#A  AsBBoxProgram( <dec> )
##
##  <#GAPDoc Label="AsBBoxProgram">
##  <ManSection>
##  <Attr Name="AsBBoxProgram" Arg='slp'/>
##
##  <Returns>
##  an equivalent black box program for the given straight line program
##  or straight line decision.
##  </Returns>
##  <Description>
##  Let <A>slp</A> be a straight line program
##  (see <Ref Func="IsStraightLineProgram" BookName="ref"/>)
##  or a straight line decision (see <Ref Func="IsStraightLineDecision"/>).
##  Then <Ref Attr="AsBBoxProgram"/> returns a black box program <A>bbox</A>
##  (see <Ref Func="IsBBoxProgram"/>) with the <Q>same</Q> output as
##  <A>slp</A>,
##  in the sense that <Ref Func="ResultOfBBoxProgram"/> yields the same
##  result for <A>bbox</A>
##  as <Ref Func="ResultOfStraightLineProgram" BookName="ref"/> or
##  <Ref Func="ResultOfStraightLineDecision"/>, respectively, for <A>slp</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> f:= FreeGroup( "x", "y" );;  gens:= GeneratorsOfGroup( f );;
##  gap> slp:= StraightLineProgram( [ [1,2,2,3], [3,-1] ], 2 );
##  <straight line program>
##  gap> ResultOfStraightLineProgram( slp, gens );
##  y^-3*x^-2
##  gap> bboxslp:= AsBBoxProgram( slp );
##  <black box program>
##  gap> ResultOfBBoxProgram( bboxslp, gens );
##  [ y^-3*x^-2 ]
##  gap> lines:= [ [ "Order", 1, 2 ], [ "Order", 2, 3 ],
##  >              [ [ 1, 1, 2, 1 ], 3 ], [ "Order", 3, 5 ] ];;
##  gap> dec:= StraightLineDecision( lines, 2 );
##  <straight line decision>
##  gap> ResultOfStraightLineDecision( dec, [ (1,2)(3,4), (1,3,5) ] );
##  true
##  gap> ResultOfStraightLineDecision( dec, [ (1,2)(3,4), (1,3,4) ] );
##  false
##  gap> bboxdec:= AsBBoxProgram( dec );
##  <black box program>
##  gap> ResultOfBBoxProgram( bboxdec, [ (1,2)(3,4), (1,3,5) ] );
##  true
##  gap> ResultOfBBoxProgram( bboxdec, [ (1,2)(3,4), (1,3,4) ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsBBoxProgram", IsStraightLineProgram );

DeclareAttribute( "AsBBoxProgram", IsStraightLineDecision );


#############################################################################
##
#A  AsStraightLineProgram( <bbox> )
##
##  <#GAPDoc Label="AsStraightLineProgram">
##  <ManSection>
##  <Attr Name="AsStraightLineProgram" Arg='bbox'/>
##
##  <Returns>
##  an equivalent straight line program for the given black box program,
##  or <K>fail</K>.
##  </Returns>
##  <Description>
##  For a black box program (see <Ref Attr="AsBBoxProgram"/>) <A>bbox</A>,
##  <Ref Func="AsStraightLineProgram"/> returns a straight line program
##  (see <Ref Func="IsStraightLineProgram" BookName="ref"/>) with the same
##  output as <A>bbox</A> if such a straight line program exists,
##  and <K>fail</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> Display( AsStraightLineProgram( bboxslp ) );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  r[3]:= r[1]^2;
##  r[4]:= r[2]^3;
##  r[5]:= r[3]*r[4];
##  r[3]:= r[5]^-1;
##  # return values:
##  [ r[3] ]
##  gap> AsStraightLineProgram( bboxdec );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsStraightLineProgram", IsBBoxProgram );


#############################################################################
##
#A  AsStraightLineDecision( <bbox> )
##
##  <#GAPDoc Label="AsStraightLineDecision">
##  <ManSection>
##  <Attr Name="AsStraightLineDecision" Arg='bbox'/>
##
##  <Returns>
##  an equivalent straight line decision for the given black box program,
##  or <K>fail</K>.
##  </Returns>
##  <Description>
##  For a black box program (see <Ref Func="IsBBoxProgram"/>) <A>bbox</A>,
##  <Ref Func="AsStraightLineDecision"/> returns a straight line decision
##  (see <Ref Func="IsStraightLineDecision"/>) with the same
##  output as <A>bbox</A>, in the sense of <Ref Attr="AsBBoxProgram"/>,
##  if such a straight line decision exists,
##  and <K>fail</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> lines:= [ [ "Order", 1, 2 ], [ "Order", 2, 3 ],
##  >              [ [ 1, 1, 2, 1 ], 3 ], [ "Order", 3, 5 ] ];;
##  gap> dec:= StraightLineDecision( lines, 2 );
##  <straight line decision>
##  gap> bboxdec:= AsBBoxProgram( dec );
##  <black box program>
##  gap> asdec:= AsStraightLineDecision( bboxdec );
##  <straight line decision>
##  gap> LinesOfStraightLineDecision( asdec );
##  [ [ "Order", 1, 2 ], [ "Order", 2, 3 ], [ [ 1, 1, 2, 1 ], 3 ], 
##    [ "Order", 3, 5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsStraightLineDecision", IsBBoxProgram );


#############################################################################
##
#E

