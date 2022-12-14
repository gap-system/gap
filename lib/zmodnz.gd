#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the design of the rings $Z / n Z$ and their elements.
##
##  The ordering of elements for nonprime $n$ is defined by the ordering of
##  the representatives.
##  For primes smaller than `MAXSIZE_GF_INTERNAL', the ordering of the
##  internal finite field elements must be respected, for larger primes
##  again the ordering of representatives is chosen.
##


#############################################################################
##
#C  IsZmodnZObj( <obj> )
#C  IsZmodnZObjNonprime( <obj> )
#C  IsZmodpZObj( <obj> )
#C  IsZmodpZObjSmall( <obj> )
#C  IsZmodpZObjLarge( <obj> )
##
##  <#GAPDoc Label="IsZmodnZObj">
##  <ManSection>
##  <Filt Name="IsZmodnZObj" Arg='obj' Type='Category'/>
##  <Filt Name="IsZmodnZObjNonprime" Arg='obj' Type='Category'/>
##  <Filt Name="IsZmodpZObj" Arg='obj' Type='Category'/>
##  <Filt Name="IsZmodpZObjSmall" Arg='obj' Type='Category'/>
##  <Filt Name="IsZmodpZObjLarge" Arg='obj' Type='Category'/>
##
##  <Description>
##  The elements in the rings <M>Z / n Z</M> are in the category
##  <Ref Filt="IsZmodnZObj"/>.
##  If <M>n</M> is a prime then the elements are of course also in the
##  category <Ref Filt="IsFFE"/>,
##  otherwise they are in <Ref Filt="IsZmodnZObjNonprime"/>.
##  <Ref Filt="IsZmodpZObj"/> is an abbreviation of
##  <C>IsZmodnZObj and IsFFE</C>.
##  This category is the disjoint union of <Ref Filt="IsZmodpZObjSmall"/> and
##  <Ref Filt="IsZmodpZObjLarge"/>, the former containing all elements with
##  <M>n</M> at most <C>MAXSIZE_GF_INTERNAL</C>.
##  <P/>
##  The reasons to distinguish the prime case from the nonprime case are
##  <List>
##  <Item>
##    that objects in <Ref Filt="IsZmodnZObjNonprime"/> have an external
##    representation (namely the residue in the range
##    <M>[ 0, 1, \ldots, n-1 ]</M>),
##  </Item>
##  <Item>
##    that the comparison of elements can be defined as comparison of the
##    residues, and
##  </Item>
##  <Item>
##    that the elements lie in a family of type
##    <C>IsZmodnZObjNonprimeFamily</C>
##    (note that for prime <M>n</M>, the family must be an
##    <C>IsFFEFamily</C>).
##  </Item>
##  </List>
##  <P/>
##  The reasons to distinguish the small and the large case are
##  that for small <M>n</M> the elements must be compatible with the internal
##  representation of finite field elements, whereas we are free to define
##  comparison as comparison of residues for large <M>n</M>.
##  <P/>
##  Note that we <E>cannot</E> claim that every finite field element of
##  degree 1 is in <Ref Filt="IsZmodnZObj"/>, since finite field elements in
##  internal representation may not know that they lie in the prime field.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsZmodnZObj", IsScalar and IsAssociativeElement
    and IsCommutativeElement and IsAdditivelyCommutativeElement );
DeclareCategory( "IsZmodnZObjNonprime", IsZmodnZObj );
DeclareSynonym( "IsZmodpZObj", IsZmodnZObj and IsFFE );
DeclareSynonym( "IsZmodpZObjSmall", IsZmodpZObj and IsLogOrderedFFE );
DeclareSynonym( "IsZmodpZObjLarge", IsZmodpZObj and IsLexOrderedFFE );


#############################################################################
##
#C  IsZmodnZObjNonprimeFamily( <obj> )
##
##  <ManSection>
##  <Filt Name="IsZmodnZObjNonprimeFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryFamily( "IsZmodnZObjNonprime" );


#############################################################################
##
#C  IsZmodnZObjNonprimeCollection( <obj> )
#C  IsZmodnZObjNonprimeCollColl( <obj> )
#C  IsZmodnZObjNonprimeCollCollColl( <obj> )
##
##  <ManSection>
##  <Filt Name="IsZmodnZObjNonprimeCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsZmodnZObjNonprimeCollColl" Arg='obj' Type='Category'/>
##  <Filt Name="IsZmodnZObjNonprimeCollCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryCollections( "IsZmodnZObjNonprime" );
DeclareCategoryCollections( "IsZmodnZObjNonprimeCollection" );
DeclareCategoryCollections( "IsZmodnZObjNonprimeCollColl" );


#############################################################################
##
#M  IsFinite( <R> ) . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallTrueMethod( IsFinite,
    IsZmodnZObjNonprimeCollection and IsDuplicateFree );


#############################################################################
##
#M  IsEuclideanRing( <R> ) . . . . . . . . . . . .  method for full ring Z/nZ
##
InstallTrueMethod(IsEuclideanRing, IsZmodnZObjNonprimeCollection and
    IsWholeFamily and IsRing);

#############################################################################
##
#V  Z_MOD_NZ
##
##  <ManSection>
##  <Var Name="Z_MOD_NZ"/>
##
##  <Description>
##  is a list of length 2, the first containing at position <A>i</A> the
##  <A>i</A>-th value <A>n</A> for that <C>ZmodnZ( <A>n</A> )</C> is stored,
##  and the second containing this ring at position <A>i</A>.
##  </Description>
##  </ManSection>
##
BindGlobal( "Z_MOD_NZ", NEW_SORTED_CACHE(true) );


#############################################################################
##
#F  ZmodnZ( <n> )
#F  ZmodpZ( <p> )
#F  ZmodpZNC( <p> )
##
##  <#GAPDoc Label="ZmodnZ">
##  <ManSection>
##  <Func Name="ZmodnZ" Arg='n'/>
##  <Func Name="ZmodpZ" Arg='p'/>
##  <Func Name="ZmodpZNC" Arg='p'/>
##
##  <Description>
##  <Ref Func="ZmodnZ"/> returns a ring <M>R</M> isomorphic to the residue
##  class ring of the integers modulo the ideal generated by <A>n</A>.
##  The element corresponding to the residue class of the integer <M>i</M>
##  in this ring can be obtained by <C>i * One( R )</C>,
##  and a representative of the residue class corresponding to the element
##  <M>x \in R</M> can be computed by <C>Int</C><M>( x )</M>.
##  <P/>
##  <Index Subkey="Integers">mod</Index>
##  <C>ZmodnZ( <A>n</A> )</C> is equal to <C>Integers mod <A>n</A></C>.
##  <P/>
##  <Ref Func="ZmodpZ"/> does the same if the argument <A>p</A> is a prime
##  integer, additionally the result is a field.
##  <Ref Func="ZmodpZNC"/> omits the check whether <A>p</A> is a prime.
##  <P/>
##  Each ring returned by these functions contains the whole family of its
##  elements
##  if <A>n</A> is not a prime, and is embedded into the family of finite
##  field elements of characteristic <A>n</A> if <A>n</A> is a prime.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ZmodnZ" );
DeclareGlobalFunction( "ZmodpZ" );
DeclareGlobalFunction( "ZmodpZNC" );


#############################################################################
##
#O  ZmodnZObj( <Fam>, <r> )
#O  ZmodnZObj( <r>, <n> )
##
##  <#GAPDoc Label="ZmodnZObj">
##  <ManSection>
##  <Oper Name="ZmodnZObj"
##   Arg='Fam, r' Label="for a residue class family and integer"/>
##  <Oper Name="ZmodnZObj" Arg='r, n' Label="for two integers"/>
##
##  <Description>
##  If the first argument is a residue class family <A>Fam</A> then
##  <Ref Oper="ZmodnZObj" Label="for a residue class family and integer"/>
##  returns the element in <A>Fam</A> whose coset is represented by the
##  integer <A>r</A>.
##  <P/>
##  If the two arguments are an integer <A>r</A> and a positive integer
##  <A>n</A> then <Ref Oper="ZmodnZObj" Label="for two integers"/>
##  returns the element in <C>ZmodnZ( <A>n</A> )</C>
##  (see&nbsp;<Ref Func="ZmodnZ"/>) whose coset is represented by the integer
##  <A>r</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> r:= ZmodnZ(15);
##  (Integers mod 15)
##  gap> fam:=ElementsFamily(FamilyObj(r));;
##  gap> a:= ZmodnZObj(fam,9);
##  ZmodnZObj( 9, 15 )
##  gap> a+a;
##  ZmodnZObj( 3, 15 )
##  gap> Int(a+a);
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZmodnZObj", [ IsZmodnZObjNonprimeFamily, IsInt ] );
DeclareOperation( "ZmodnZObj", [ IsInt, IsPosInt ] );
DeclareSynonym( "ZmodpZObj", ZmodnZObj );


#############################################################################
##
#A  ModulusOfZmodnZObj( <obj> )
##
##  <ManSection>
##  <Attr Name="ModulusOfZmodnZObj" Arg='obj'/>
##
##  <Description>
##  For an element <A>obj</A> in a residue class ring of integers modulo
##  <M>n</M> (see&nbsp;<Ref Filt="IsZmodnZObj"/>),
##  <Ref Attr="ModulusOfZmodnZObj"/> returns the positive integer <M>n</M>.
##
##  Deprecated, use <Ref Attr="Characteristic"/> instead.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ModulusOfZmodnZObj", IsZmodnZObj );


#############################################################################
##
#F  EnumeratorOfZmodnZ( <R> ). . . . . . . . . . . . . enumerator for Z / n Z
##
##  <ManSection>
##  <Func Name="EnumeratorOfZmodnZ" Arg='R'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "EnumeratorOfZmodnZ" );


#############################################################################
##
#M  IsFinite( <zmodnz-mat-grp> )
##
##  *NOTE*:  The following implication only  holds if there are no infinite
##  dimensional matrices.
##
InstallTrueMethod( IsFinite,
    IsZmodnZObjNonprimeCollCollColl and IsRingElementCollCollColl
                                    and IsGroup
                                    and IsFinitelyGeneratedGroup );
