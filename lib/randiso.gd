#############################################################################
##
#W  randiso.gd                GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.randiso_gd :=
    "@(#)$Id: randiso.gd,v 1.15 2009/06/15 15:20:22 gap Exp $";

DeclareInfoClass( "InfoRandIso" );
DeclareAttribute( "OmegaAndLowerPCentralSeries", IsGroup );

#############################################################################
##
#F  CodePcgs( <pcgs> )
##
##  <#GAPDoc Label="CodePcgs">
##  <ManSection>
##  <Func Name="CodePcgs" Arg='pcgs'/>
##
##  <Description>
##  returns the code corresponding to <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CodePcgs" );

#############################################################################
##
#F  CodePcGroup( <G> )
##
##  <#GAPDoc Label="CodePcGroup">
##  <ManSection>
##  <Func Name="CodePcGroup" Arg='G'/>
##
##  <Description>
##  returns the code for a pcgs of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CodePcGroup" );

#############################################################################
##
#F  PcGroupCode( <code>, <size> )
##
##  <#GAPDoc Label="PcGroupCode">
##  <ManSection>
##  <Func Name="PcGroupCode" Arg='code, size'/>
##
##  <Description>
##  returns a pc group of size <A>size</A> corresponding to <A>code</A>.
##  The argument <A>code</A> must be a valid code for a pcgs,
##  otherwise anything may happen.
##  Valid codes are usually obtained by one of the functions
##  <Ref Func="CodePcgs"/> or <Ref Func="CodePcGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PcGroupCode" );

#############################################################################
##
#F  PcGroupCodeRec( <rec> )
##
##  <#GAPDoc Label="PcGroupCodeRec">
##  <ManSection>
##  <Func Name="PcGroupCodeRec" Arg='rec'/>
##
##  <Description>
##  Here <A>rec</A> needs to have entries .code and .order.
##  Then <Ref Func="PcGroupCode"/> returns a pc group of size .order
##  corresponding to .code.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 24, 12 );;
##  gap> p := Pcgs( G );;
##  gap> code := CodePcgs( p );
##  5790338948
##  gap> H := PcGroupCode( code, 24 );
##  <pc group of size 24 with 4 generators>
##  gap> map := GroupHomomorphismByImages( G, H, p, FamilyPcgs(H) );
##  Pcgs([ f1, f2, f3, f4 ]) -> Pcgs([ f1, f2, f3, f4 ])
##  gap> IsBijective(map);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PcGroupCodeRec" );


#############################################################################
##
#F  RandomSpecialPcgsCoded( <G> )
##
##  <ManSection>
##  <Func Name="RandomSpecialPcgsCoded" Arg='G'/>
##
##  <Description>
##  returns a code for a random special pcgs of <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "RandomSpecialPcgsCoded" );

#############################################################################
##
#F  RandomIsomorphismTest( <list>, <n> )
##
##  <#GAPDoc Label="RandomIsomorphismTest">
##  <ManSection>
##  <Func Name="RandomIsomorphismTest" Arg='list, n'/>
##
##  <Description>
##  <A>list</A> must be a list of code records of pc groups
##  and <A>n</A> a non-negative integer.
##  Returns a sublist of <A>list</A> where isomorphic copies detected by 
##  the probabilistic test have been removed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomIsomorphismTest" );

#############################################################################
##
#F  ReducedByIsomorphism( <list>, <n> )
##
##  <ManSection>
##  <Func Name="ReducedByIsomorphism" Arg='list, n'/>
##
##  <Description>
##  returns a list of disjoint sublist of <A>list</A> such that no two isomorphic
##  groups can be in the same sublist.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ReducedByIsomorphisms" );


#############################################################################
##
#E

