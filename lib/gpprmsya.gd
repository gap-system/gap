#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for symmetric and alternating
##  permutation groups
##


#############################################################################
##
#P  IsNaturalSymmetricGroup( <group> )
#P  IsNaturalAlternatingGroup( <group> )
##
##  <#GAPDoc Label="IsNaturalSymmetricGroup">
##  <ManSection>
##  <Prop Name="IsNaturalSymmetricGroup" Arg='group'/>
##  <Prop Name="IsNaturalAlternatingGroup" Arg='group'/>
##
##  <Description>
##  A group is a natural symmetric or alternating group if it is
##  a permutation group acting as symmetric or alternating group,
##  respectively, on its moved points.
##  <P/>
##  For groups that are known to be natural symmetric or natural alternating
##  groups, very efficient methods for computing membership,
##  conjugacy classes, Sylow subgroups etc.&nbsp;are used.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,5,7,8,99),(1,99,13,72));;
##  gap> IsNaturalSymmetricGroup(g);
##  true
##  gap> g;
##  Sym( [ 1, 5, 7, 8, 13, 72, 99 ] )
##  gap> IsNaturalSymmetricGroup( Group( (1,2)(4,5), (1,2,3)(4,5,6) ) );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsNaturalSymmetricGroup", IsPermGroup );
InstallTrueMethod( IsPermGroup, IsNaturalSymmetricGroup );

DeclareProperty( "IsNaturalAlternatingGroup", IsPermGroup );
InstallTrueMethod( IsPermGroup, IsNaturalAlternatingGroup );


#############################################################################
##
#P  IsAlternatingGroup( <group> )
##
##  <#GAPDoc Label="IsAlternatingGroup">
##  <ManSection>
##  <Prop Name="IsAlternatingGroup" Arg='group'/>
##
##  <Description>
##  is <K>true</K> if the group <A>group</A> is isomorphic to an
##  alternating group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsAlternatingGroup", IsGroup );
InstallTrueMethod( IsGroup, IsAlternatingGroup );


#############################################################################
##
#M  IsAlternatingGroup( <nat-alt-grp> )
##
InstallTrueMethod( IsAlternatingGroup, IsNaturalAlternatingGroup );


#############################################################################
##
#P  IsSymmetricGroup( <group> )
##
##  <#GAPDoc Label="IsSymmetricGroup">
##  <ManSection>
##  <Prop Name="IsSymmetricGroup" Arg='group'/>
##
##  <Description>
##  is <K>true</K> if the group <A>group</A> is isomorphic to a
##  symmetric group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSymmetricGroup", IsGroup );
InstallTrueMethod( IsGroup, IsSymmetricGroup );


#############################################################################
##
#M  IsSymmetricGroup( <nat-sym-grp> )
##
InstallTrueMethod( IsSymmetricGroup, IsNaturalSymmetricGroup );


#############################################################################
##
#A  SymmetricParentGroup( <grp> )
##
##  <#GAPDoc Label="SymmetricParentGroup">
##  <ManSection>
##  <Attr Name="SymmetricParentGroup" Arg='grp'/>
##
##  <Description>
##  For a permutation group <A>grp</A> this function returns the symmetric
##  group that moves the same points as <A>grp</A> does.
##  <Example><![CDATA[
##  gap> SymmetricParentGroup( Group( (1,2), (4,5), (7,8,9) ) );
##  Sym( [ 1, 2, 4, 5, 7, 8, 9 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("SymmetricParentGroup",IsPermGroup);

#############################################################################
##
#A  AlternatingSubgroup( <grp> )
##
##  <ManSection>
##  <Attr Name="AlternatingSubgroup" Arg='grp'/>
##
##  <Description>
##  returns the intersection of <A>grp</A> with the alternating group on the
##  points moved by <A>grp</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("AlternatingSubgroup",IsPermGroup);

#############################################################################
##
#A  OrbitStabilizingParentGroup( <grp> )
##
##  <ManSection>
##  <Attr Name="OrbitStabilizingParentGroup" Arg='grp'/>
##
##  <Description>
##  returns the subgroup of <C>SymmetricParentGroup(<A>grp</A>)</C> which stabilizes
##  the orbits of <A>grp</A> setwise. (So it is a direct product of wreath
##  products of symmetric groups.) It is a natural supergroup for the
##  normalizer.
##  </Description>
##  </ManSection>
##
DeclareAttribute("OrbitStabilizingParentGroup",IsPermGroup);

DeclareGlobalFunction("NormalizerParentSA");

#############################################################################
##
#F  MaximalSubgroupsSymmAlt( <grp> [,<onlyprimitive>] )
##
##  <ManSection>
##  <Func Name="MaximalSubgroupsSymmAlt" Arg='grp [,onlyprimitive]'/>
##
##  <Description>
##  For a symmetric or alternating group <A>grp</A>, this function returns
##  representatives of the classes of maximal subgroups.
##  <P/>
##  If the parameter <A>onlyprimitive</A> is given and set to <K>true</K> only the
##  primitive maximal subgroups are computed.
##  <P/>
##  No parameter test is performed. (The function relies on the primitive
##  groups library for its functionality.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MaximalSubgroupsSymmAlt");
