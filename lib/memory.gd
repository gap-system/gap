#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Max Neunhöffer, Ákos Seress.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Group objects remembering how they were created from the generators.
##
#############################################################################


#############################################################################
##
##  <#GAPDoc Label="objwithmemory">
##  The idea behind objects with memory is as follows.
##  One starts with a list of seed objects
##  and creates corresponding new objects for them that store how they arise
##  from the seed objects (see <Ref Func="GeneratorsWithMemory"/>).
##  Each product, inverse, commutator etc. of the new objects then also
##  stores how it was obtained from the seed objects.
##  One can use <Ref Func="SLPOfElm"/> to create a straight line program
##  for a given element <M>x</M> such that evaluating this program in the
##  seed objects yields <M>x</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds:= [ (1,2,3), (1,2) ];;
##  gap> elms:= GeneratorsWithMemory( seeds );
##  [ <(1,2,3) with mem>, <(1,2) with mem> ]
##  gap> x:= (elms[1] * elms[2])^-1;
##  <(2,3) with mem>
##  gap> xslp:= SLPOfElm( x );
##  <straight line program>
##  gap> Display( xslp );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  r[3]:= r[1]*r[2];
##  r[4]:= r[3]^-1;
##  # return value:
##  r[4]
##  gap> ResultOfStraightLineProgram( xslp, seeds );
##  (2,3)
##  ]]></Example>
##  <P/>
##  The objects with memory are intended to behave equally to the underlying
##  objects without memory, apart from the behaviour concerning the memory
##  information.
##  In particular, the tests for equality and ordering are delegated to the
##  underlying objects.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds = elms;
##  true
##  gap> ( seeds[1] < seeds[2] ) = ( elms[1] < elms[2] );
##  true
##  ]]></Example>
##  <P/>
##  It may, however, happen that some &GAP; function runs into an error
##  when it is called with elements with memory.
##  In such cases, probably a method for elements with memory is missing,
##  and perhaps some existing methods are installed with too weak
##  requirements.
##  As a solution, one can then add the missing method,
##  or ask &GAP; support for help.
##  <P/>
##  An overview of the currently supported functionality for objects with
##  memory can be computed with <Ref Func="MethodsForObjWithMemory"/>,
##  this may be helpful for finding code that can be adapted.
##  <#/GAPDoc>


# This filter is intended to increase the rank of `IsObjWithMemory`.
DeclareFilter("IsObjWithMemoryRankFilter",100);


#############################################################################
##
#F  IsObjWithMemory( <obj> )
##
##  <#GAPDoc Label="IsObjWithMemory">
##  <ManSection>
##  <Filt Name="IsObjWithMemory" Arg='obj' Type='Representation'/>
##
##  <Description>
##  The filter <Ref Filt="IsObjWithMemory"/> describes objects that can be
##  multiplied and store information how they arise from seed objects
##  via arithmetic operations.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds:= [ (1,2,3), (1,2) ];;
##  gap> elms:= GeneratorsWithMemory( seeds );;
##  gap> IsObjWithMemory( elms[1] );
##  true
##  gap> IsObjWithMemory( seeds[1] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation("IsObjWithMemory",
    IsComponentObjectRep and IsObjWithMemoryRankFilter and
    IsMultiplicativeElementWithInverse);


#############################################################################
##
#F  GeneratorsWithMemory( <list> )
##
##  <#GAPDoc Label="GeneratorsWithMemory">
##  <ManSection>
##  <Func Name="GeneratorsWithMemory" Arg='list'/>
##
##  <Returns>a list of objects with memory</Returns>
##  <Description>
##  For a list <A>list</A> of multiplicative elements,
##  <Ref Func="GeneratorsWithMemory"/> returns a list of corresponding
##  objects with memory.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds:= [ (1,2,3), (1,2) ];;
##  gap> elms:= GeneratorsWithMemory( seeds );
##  [ <(1,2,3) with mem>, <(1,2) with mem> ]
##  gap> seeds = elms;
##  true
##  gap> ForAll( elms, IsObjWithMemory );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GeneratorsWithMemory" );


#############################################################################
##
#F  GroupWithMemory( <G> )
#F  GroupWithMemory( <gens> )
##
##  <#GAPDoc Label="GroupWithMemory">
##  <ManSection>
##  <Heading>GroupWithMemory</Heading>
##  <Func Name="GroupWithMemory" Arg='G' Label="for a group"/>
##  <Func Name="GroupWithMemory" Arg='gens' Label="for a list of generators"/>
##
##  <Description>
##  Return a group whose <Ref Attr="GeneratorsOfGroup"/> value is the
##  <Ref Func="GeneratorsWithMemory"/> value of
##  <C>GeneratorsOfGroup( </C><A>G</A><C> )</C> or of <A>gens</A>,
##  respectively.
##  <P/>
##  <Example><![CDATA[
##  gap> G:= GroupWithMemory( SymmetricGroup( 3 ) );
##  Group([ (1,2,3), (1,2) ])
##  gap> IsObjWithMemory( One( G ) );
##  true
##  gap> G:= GroupWithMemory( [ (1,2,3) ] );
##  Group([ (1,2,3) ])
##  gap> IsObjWithMemory( One( G ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GroupWithMemory" );


#############################################################################
##
#F  SLPOfElm( <g> )
##
##  <#GAPDoc Label="SLPOfElm">
##  <ManSection>
##  <Func Name="SLPOfElm" Arg='g'/>
##
##  <Description>
##  For <A>g</A> in the filter <Ref Filt="IsObjWithMemory"/>,
##  return a straight line program that describes <A>g</A> in terms of the
##  generators that were used to initialize the memory.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds:= [ (1,2,3), (1,2) ];;
##  gap> elms:= GeneratorsWithMemory( seeds );
##  [ <(1,2,3) with mem>, <(1,2) with mem> ]
##  gap> g:= (elms[2] * elms[1] * elms[2])^-1;
##  <(1,2,3) with mem>
##  gap> slp:= SLPOfElm( g );
##  <straight line program>
##  gap> g = ResultOfStraightLineProgram( slp, seeds );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SLPOfElm" );


#############################################################################
##
#F  SLPOfElms( <list> )
##
##  <#GAPDoc Label="SLPOfElms">
##  <ManSection>
##  <Func Name="SLPOfElms" Arg='list'/>
##
##  <Description>
##  For a list <A>list</A> of elements in the filter
##  <Ref Filt="IsObjWithMemory"/>,
##  return a straight line program that describes <A>list</A> in terms of the
##  generators that were used to initialize the memory.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds:= [ (1,2,3), (1,2) ];;
##  gap> elms:= GeneratorsWithMemory( seeds );
##  [ <(1,2,3) with mem>, <(1,2) with mem> ]
##  gap> list:= [ elms[2] * elms[1], elms[1] * elms[2] ];
##  [ <(1,3) with mem>, <(2,3) with mem> ]
##  gap> slp:= SLPOfElms( list );
##  <straight line program>
##  gap> list = ResultOfStraightLineProgram( slp, seeds );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SLPOfElms" );


#############################################################################
##
#F  MethodsForObjWithMemory()
##
##  <#GAPDoc Label="MethodsForObjWithMemory">
##  <ManSection>
##  <Func Name="MethodsForObjWithMemory" Arg=''/>
##
##  <Description>
##  This function is intended to give an overview of those methods in the
##  current &GAP; session for which at least one argument is required to be
##  in the filter <Ref Filt="IsObjWithMemory"/>.
##  <P/>
##  The return value is a list of records, with the same components as the
##  ones returned by <Ref Func="MethodsOperation"/>.
##  In particular, the <C>func</C> component of each record is the method
##  itself, and the <C>info</C> component is a string that describes its
##  requirements.
##  <P/>
##  <Example><![CDATA[
##  gap> res:= MethodsForObjWithMemory();;
##  gap> for r in res{ [ 1 .. 10 ] } do
##  >      Print( r.info, "\n" );
##  >    od;
##  ViewObj: [ IsObjWithMemory ]
##  =: [ IsObjWithMemory, IsObjWithMemory ]
##  =: [ IsMultiplicativeElement, IsObjWithMemory ]
##  =: [ IsObjWithMemory, IsMultiplicativeElement ]
##  <: [ IsObjWithMemory, IsObjWithMemory ]
##  <: [ IsMultiplicativeElement, IsObjWithMemory ]
##  <: [ IsObjWithMemory, IsMultiplicativeElement ]
##  PrintObj: [ IsObjWithMemory ]
##  Length: [ IsMatrix and IsObjWithMemory ]
##  Length: [ IsObjWithMemory and IsWord ]
##  ]]></Example>
##  <P/>
##  Note that some functions may provide a special treatment for objects in
##  <Ref Filt="IsObjWithMemory"/> but no arguments of the function are
##  objects with memory.
##  For example, there is a <Ref Attr="One"/> method for a group
##  that checks whether the generators are objects with memory,
##  and if yes returns an identity element with memory.
##  Such functions do not occur in the output of
##  <Ref Func="MethodsForObjWithMemory"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MethodsForObjWithMemory" );


#############################################################################
##
#O  StripMemory( <obj> )
##
##  <#GAPDoc Label="StripMemory">
##  <ManSection>
##  <Oper Name="StripMemory" Arg='obj'/>
##
##  <Description>
##  For a list <A>obj</A>, <Ref Oper="StripMemory"/> returns a new list
##  of the <Ref Oper="StripMemory"/> results for the entries of <A>obj</A>.
##  <P/>
##  If <A>obj</A> is not a list and in the filter
##  <Ref Filt="IsObjWithMemory"/>, <Ref Oper="StripMemory"/> returns the
##  underlying object without memory.
##  <P/>
##  Otherwise <A>obj</A> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> seeds:= [ (1,2,3), (1,2) ];;
##  gap> elms:= GeneratorsWithMemory( seeds );
##  [ <(1,2,3) with mem>, <(1,2) with mem> ]
##  gap> StripMemory( elms );
##  [ (1,2,3), (1,2) ]
##  gap> StripMemory( elms[1] );
##  (1,2,3)
##  gap> IsIdenticalObj( seeds[1], StripMemory( seeds[1] ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "StripMemory", [ IsObject ] );

DeclareOperation( "ForgetMemory", [ IsObject ] );

DeclareGlobalFunction( "StripStabChain" );

DeclareGlobalFunction( "CopyMemory" );

DeclareGlobalFunction( "SortFunctionWithMemory" );

