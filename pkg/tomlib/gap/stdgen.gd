#############################################################################
##
#W  stdgen.gd                GAP library                        Thomas Breuer
##
#H  @(#)$Id: stdgen.gd,v 1.4 2008/08/18 16:11:40 gap Exp $
##
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations needed for dealing with standard
##  generators of finite groups.
##
Revision.stdgen_gd :=
    "@(#)$Id: stdgen.gd,v 1.4 2008/08/18 16:11:40 gap Exp $";


#T TO DO:
#T - a function that can be used to *define* standard generators,
#T   using the character table with underlying group (perhaps also the
#T   table of marks or an explicit description of all maximal subgroups)


#############################################################################
##
##  Standard Generators of Groups
##  <#GAPDoc Label="[1]{stdgen}">
##  An <M>s</M>-tuple of <E>standard generators</E> of a given group <M>G</M>
##  is a vector <M>(g_1, g_2, \ldots, g_s)</M> of elements <M>g_i \in G</M>
##  satisfying certain conditions (depending on the isomorphism type of
##  <M>G</M>) such that
##  <Enum>
##  <Item>
##      <M>\langle g_1, g_2, \ldots, g_s \rangle = G</M> and
##  </Item>
##  <Item>
##      the vector is unique up to automorphisms of <M>G</M>,
##      i.e., for two vectors <M>(g_1, g_2, \ldots, g_s)</M> and
##      <M>(h_1, h_2, \ldots, h_s)</M> of standard generators,
##      the map <M>g_i \mapsto h_i</M> extends to an automorphism of <M>G</M>.
##  </Item>
##  </Enum>
##  For details about standard generators, see&nbsp;<Cite Key="Wil96"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#A  StandardGeneratorsInfo( <G> )
##
##  <#GAPDoc Label="StandardGeneratorsInfo:stdgen">
##  <ManSection>
##  <Attr Name="StandardGeneratorsInfo" Arg='G' Label="for groups"/>
##
##  <Description>
##  When called with the group <A>G</A>,
##  <Ref Func="StandardGeneratorsInfo" Label="for groups"/> returns a list of
##  records with at least one of the components <C>script</C> and
##  <C>description</C>.
##  Each such record defines <E>standard generators</E> of groups isomorphic
##  to <A>G</A>, the <M>i</M>-th record is referred to as the <M>i</M>-th set
##  of standard generators for such groups.
##  The value of <C>script</C> is a dense list of lists, each encoding a
##  command that has one of the following forms.
##  <List>
##  <Mark>A <E>definition</E> <M>[ i, n, k ]</M> or <M>[ i, n ]</M></Mark>
##  <Item>
##      means to search for an element of order <M>n</M>,
##      and to take its <M>k</M>-th power as candidate for the <M>i</M>-th
##      standard generator (the default for <M>k</M> is <M>1</M>),
##  </Item>
##  <Mark>a <E>relation</E> <M>[ i_1, k_1, i_2, k_2, \ldots, i_m, k_m, n ]</M> with <M>m > 1</M></Mark>
##  <Item>
##      means a check whether the element
##      <M>g_{{i_1}}^{{k_1}} g_{{i_2}}^{{k_2}} \cdots g_{{i_m}}^{{k_m}}</M>
##      has order <M>n</M>; if <M>g_j</M> occurs then of course the
##      <M>j</M>-th generator must have been defined before,
##  </Item>
##  <Mark>a <E>relation</E> <M>[ [ i_1, i_2, \ldots, i_m ], <A>slp</A>, n ]</M></Mark>
##  <Item>
##      means a check whether the result of the straight line program
##      <A>slp</A> (see&nbsp;<Ref Sect="Straight Line Programs"/>) applied to
##      the candidates <M>g_{{i_1}}, g_{{i_2}}, \ldots, g_{{i_m}}</M> has
##      order <M>n</M>, where the candidates <M>g_j</M> for the <M>j</M>-th
##      standard generators must have been defined before,
##  </Item>
##  <Mark>a <E>condition</E> <M>[ [ i_1, k_1, i_2, k_2, \ldots, i_m, k_m ], f, v ]</M></Mark>
##  <Item>
##      means a check whether the &GAP; function in the global list
##      <Ref Var="StandardGeneratorsFunctions"/>
##      that is followed by the list <M>f</M> of strings returns the value
##      <M>v</M> when it is called with <M>G</M> and
##      <M>g_{{i_1}}^{{k_1}} g_{{i_2}}^{{k_2}} \cdots g_{{i_m}}^{{k_m}}</M>.
##  </Item>
##  </List>
##  Optional components of the returned records are
##  <List>
##  <Mark><C>generators</C></Mark>
##  <Item>
##      a string of names of the standard generators,
##  </Item>
##  <Mark><C>description</C></Mark>
##  <Item>
##      a string describing the <C>script</C> information in human readable
##      form, in terms of the <C>generators</C> value,
##  </Item>
##  <Mark><C>classnames</C></Mark>
##  <Item>
##      a list of strings, the <M>i</M>-th entry being the name of the
##      conjugacy class containing the <M>i</M>-th standard generator,
##      according to the &ATLAS; character table of the group
##      (see&nbsp;<Ref Func="ClassNames"/>), and
##  <!-- function that tries to compute the classes from the <C>description</C> value-->
##  <!-- and the character table? -->
##  </Item>
##  <Mark><C>ATLAS</C></Mark>
##  <Item>
##      a boolean; <K>true</K> means that the standard generators coincide
##      with those defined in Rob Wilson's &ATLAS; of Group Representations
##      (see&nbsp;<Cite Key="AGR"/>), and <K>false</K> means that this
##      property is not guaranteed.
##  </Item>
##  </List>
##  <P/>
##  There is no default method for an arbitrary isomorphism type,
##  since in general the definition of standard generators is not obvious.
##  <P/>
##  The function <Ref Func="StandardGeneratorsOfGroup"/>
##  can be used to find standard generators of a given group isomorphic
##  to <A>G</A>.
##  <P/>
##  The <C>generators</C> and <C>description</C> values, if not known,
##  can be computed by <Ref Func="HumanReadableDefinition"/>.
##  <Example><![CDATA[
##  gap> StandardGeneratorsInfo( TableOfMarks( "L3(3)" ) );
##  [ rec( generators := "a, b", 
##        description := "|a|=2, |b|=3, |C(b)|=9, |ab|=13, |ababb|=4", 
##        script := [ [ 1, 2 ], [ 2, 3 ], [ [ 2, 1 ], [ "|C(",, ")|" ], 9 ], 
##            [ 1, 1, 2, 1, 13 ], [ 1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 4 ] ], 
##        ATLAS := true ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "StandardGeneratorsInfo", IsGroup );
#T make this an operation also for strings?


#############################################################################
##
#F  HumanReadableDefinition( <info> )
#F  ScriptFromString( <string> )
##
##  <#GAPDoc Label="HumanReadableDefinition">
##  <ManSection>
##  <Func Name="HumanReadableDefinition" Arg='info'/>
##  <Func Name="ScriptFromString" Arg='string'/>
##
##  <Description>
##  Let <A>info</A> be a record that is valid as value of
##  <Ref Func="StandardGeneratorsInfo" Label="for groups"/>.
##  <Ref Func="HumanReadableDefinition"/> returns a string that describes the
##  definition of standard generators given by the <C>script</C> component of
##  <A>info</A> in human readable form.
##  The names of the generators are taken from the <C>generators</C>
##  component (default names <C>"a"</C>, <C>"b"</C> etc.&nbsp;are computed
##  if necessary),
##  and the result is stored in the <C>description</C> component.
##  <P/>
##  <Ref Func="ScriptFromString"/> does the converse of
##  <Ref Func="HumanReadableDefinition"/>, i.e.,
##  it takes a string <A>string</A> as returned by
##  <Ref Func="HumanReadableDefinition"/>, and returns a corresponding
##  <C>script</C> list.
##  <P/>
##  If <Q>condition</Q> lines occur in the script
##  (see&nbsp;<Ref Func="StandardGeneratorsInfo" Label="for groups"/>)
##  then the functions that occur must be contained in
##  <Ref Var="StandardGeneratorsFunctions"/>.
##  <Example><![CDATA[
##  gap> scr:= ScriptFromString( "|a|=2, |b|=3, |C(b)|=9, |ab|=13, |ababb|=4" );
##  [ [ 1, 2 ], [ 2, 3 ], [ [ 2, 1 ], [ "|C(",, ")|" ], 9 ], [ 1, 1, 2, 1, 13 ], 
##    [ 1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 4 ] ]
##  gap> info:= rec( script:= scr );
##  rec( script := [ [ 1, 2 ], [ 2, 3 ], [ [ 2, 1 ], [ "|C(",, ")|" ], 9 ], 
##        [ 1, 1, 2, 1, 13 ], [ 1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 4 ] ] )
##  gap> HumanReadableDefinition( info );
##  "|a|=2, |b|=3, |C(b)|=9, |ab|=13, |ababb|=4"
##  gap> info;
##  rec( script := [ [ 1, 2 ], [ 2, 3 ], [ [ 2, 1 ], [ "|C(",, ")|" ], 9 ], 
##        [ 1, 1, 2, 1, 13 ], [ 1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 4 ] ], 
##    generators := "a, b", 
##    description := "|a|=2, |b|=3, |C(b)|=9, |ab|=13, |ababb|=4" )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "HumanReadableDefinition" );

DeclareGlobalFunction( "ScriptFromString" );


#############################################################################
##
#V  StandardGeneratorsFunctions
##
##  <#GAPDoc Label="StandardGeneratorsFunctions">
##  <ManSection>
##  <Var Name="StandardGeneratorsFunctions"/>
##
##  <Description>
##  <Ref Func="StandardGeneratorsFunctions"/> is a list of even length.
##  At position <M>2i-1</M>, a function of two arguments is stored,
##  which are expected to be a group and a group element.
##  At position <M>2i</M> a list of strings is stored such that first
##  inserting a generator name in all holes and then forming the
##  concatenation yields a string that describes the function at the previous
##  position;
##  this string must contain the generator enclosed in round brackets
##  <C>(</C> and <C>)</C>.
##  <P/>
##  This list is used by the functions
##  <Ref Func="StandardGeneratorsInfo" Label="for groups"/>),
##  <Ref Func="HumanReadableDefinition"/>, and
##  <Ref Func="ScriptFromString"/>.
##  Note that the lists at even positions must be pairwise different.
##  <Example><![CDATA[
##  gap> StandardGeneratorsFunctions{ [ 1, 2 ] };
##  [ function( G, g ) ... end, [ "|C(",, ")|" ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalVariable( "StandardGeneratorsFunctions",
    "list of functions used in scripts, and their translations to strings" );


#############################################################################
##
#F  IsStandardGeneratorsOfGroup( <info>, <G>, <gens> )
##
##  <#GAPDoc Label="IsStandardGeneratorsOfGroup">
##  <ManSection>
##  <Func Name="IsStandardGeneratorsOfGroup" Arg='info, G, gens'/>
##
##  <Description>
##  Let <A>info</A> be a record that is valid as value of
##  <Ref Func="StandardGeneratorsInfo" Label="for groups"/>,
##  <A>G</A> a group, and <A>gens</A> a list of generators for <A>G</A>.
##  In this case, <Ref Func="IsStandardGeneratorsOfGroup"/> returns
##  <K>true</K> if <A>gens</A> satisfies the conditions of the <C>script</C>
##  component of <A>info</A>, and <K>false</K> otherwise.
##  <P/>
##  Note that the result <K>true</K> means that <A>gens</A> is a list of
##  standard generators for <A>G</A> only if <A>G</A> has the isomorphism
##  type for which <A>info</A> describes standard generators.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsStandardGeneratorsOfGroup" );


#############################################################################
##
#F  StandardGeneratorsOfGroup( <info>, <G>[, <randfunc>] )
##
##  <#GAPDoc Label="StandardGeneratorsOfGroup">
##  <ManSection>
##  <Func Name="StandardGeneratorsOfGroup" Arg='info, G[, randfunc]'/>
##
##  <Description>
##  Let <A>info</A> be a record that is valid as value of
##  <Ref Func="StandardGeneratorsInfo" Label="for groups"/>,
##  and <A>G</A> a group of the isomorphism type for which <A>info</A>
##  describes standard generators.
##  In this case, <Ref Func="StandardGeneratorsOfGroup"/> returns a list of
##  standard generators of <A>G</A>,
##  see&nbsp;Section&nbsp;<Ref Sect="Standard Generators of Groups"/>.
##  <P/>
##  The optional argument <A>randfunc</A> must be a function that returns an
##  element of <A>G</A> when called with <A>G</A>; the default is
##  <Ref Func="PseudoRandom"/>.
##  <P/>
##  In each call to <Ref Func="StandardGeneratorsOfGroup"/>,
##  the <C>script</C> component of <A>info</A> is scanned line by line.
##  <A>randfunc</A> is used to find an element of the prescribed order
##  whenever a definition line is met,
##  and for the relation and condition lines in the <C>script</C> list,
##  the current generator candidates are checked;
##  if a condition is not fulfilled, all candidates are thrown away,
##  and the procedure starts again with the first line.
##  When the conditions are fulfilled after processing the last line
##  of the <C>script</C> list, the standard generators are returned.
##  <P/>
##  <!-- Admit the possibility to specify the desired classes?-->
##  <!-- For example, if there is only one class of a given order of a standard-->
##  <!-- generator then this element may be taken first and kept also after-->
##  <!-- failure for a partial vector of candidates.-->
##  <!--  (then the first element of right order may be kept, for example)-->
##  Note that if <A>G</A> has the wrong isomorphism type then
##  <Ref Func="StandardGeneratorsOfGroup"/> returns a list of elements in
##  <A>G</A> that satisfy the conditions of the <C>script</C> component of
##  <A>info</A> if such elements exist, and does not terminate otherwise.
##  In the former case, obviously the returned elements need not be standard
##  generators of <A>G</A>.
##  <Example><![CDATA[
##  gap> a5:= AlternatingGroup( 5 );
##  Alt( [ 1 .. 5 ] )
##  gap> info:= StandardGeneratorsInfo( TableOfMarks( "A5" ) )[1];
##  rec( generators := "a, b", description := "|a|=2, |b|=3, |ab|=5", 
##    script := [ [ 1, 2 ], [ 2, 3 ], [ 1, 1, 2, 1, 5 ] ], ATLAS := true )
##  gap> IsStandardGeneratorsOfGroup( info, a5, [ (1,3)(2,4), (3,4,5) ] );
##  true
##  gap> IsStandardGeneratorsOfGroup( info, a5, [ (1,3)(2,4), (1,2,3) ] );
##  false
##  gap> s5:= SymmetricGroup( 5 );;
##  gap> RepresentativeAction( s5, [ (1,3)(2,4), (3,4,5) ], 
##  >        StandardGeneratorsOfGroup( info, a5 ), OnPairs ) <> fail;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StandardGeneratorsOfGroup" );


#############################################################################
##
#E

