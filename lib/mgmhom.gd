#############################################################################
##
#W  mgmhom.gd                    GAP library                  Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations for magma homomorphisms.
##

#############################################################################
##
#P  IsMagmaHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsMagmaHomomorphism">
##  <ManSection>
##  <Filt Name="IsMagmaHomomorphism" Arg='mapp'/>
##
##  <Description>
##  A <E>magma homomorphism</E> is a total single valued mapping
##  which respects  multiplication.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsMagmaHomomorphism",
	IsMapping and RespectsMultiplication );


#############################################################################
##
#F  MagmaHomomorphismByFunctionNC( <G>, <H>, <fn> ) 
##
##  <#GAPDoc Label="MagmaHomomorphismByFunctionNC">
##  <ManSection>
##  <Func Name="MagmaHomomorphismByFunctionNC" Arg='G, H, fn'/>
##
##  <Description>
##  Creates the homomorphism from <A>G</A> to <A>H</A> without checking
##  that <A>fn</A> is a homomorphism.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaHomomorphismByFunctionNC");

#############################################################################
##
#F  MagmaIsomorphismByFunctionsNC( <G>, <H>, <fn>, <inv> ) 
##
##  <ManSection>
##  <Func Name="MagmaIsomorphismByFunctionsNC" Arg='G, H, fn, inv'/>
##
##  <Description>
##  Creates the isomorphism from <A>G</A> to <A>H</A> without checking
##  that <A>fn</A> or <A>inv</A> are homomorphisms or bijective or inverse.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "MagmaIsomorphismByFunctionsNC");


############################################################################
##
#O  NaturalHomomorphismByGenerators( <f>, <s> )
##
##  <#GAPDoc Label="NaturalHomomorphismByGenerators">
##  <ManSection>
##  <Oper Name="NaturalHomomorphismByGenerators" Arg='f, s'/>
##
##  <Description>
##  returns a mapping from the magma <A>f</A> with <M>n</M> generators to the
##  magma <A>s</A> with <M>n</M> generators,
##  which maps the <M>i</M>-th generator of <A>f</A> to the 
##  <M>i</M>-th generator of <A>s</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("NaturalHomomorphismByGenerators",[IsMagma, IsMagma]);
