#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  DirectProduct( <G>{, <H>} )
#O  DirectProductOp( <list>, <expl> )
##
##  <#GAPDoc Label="DirectProduct">
##  <ManSection>
##  <Func Name="DirectProduct" Arg='G[, H, ...]'/>
##  <Oper Name="DirectProductOp" Arg='list, expl'/>
##
##  <Description>
##  These functions construct the direct product of the groups given as
##  arguments.
##  <Ref Func="DirectProduct"/> takes an arbitrary positive number of
##  arguments and calls the operation <Ref Oper="DirectProductOp"/>,
##  which takes exactly two arguments,
##  namely a nonempty list <A>list</A> of groups and one of these groups,
##  <A>expl</A>.
##  (This somewhat strange syntax allows the method selection to choose
##  a reasonable method for special cases, e.g., if all groups are
##  permutation groups or pc groups.)
##  <P/>
##  &GAP; will try to choose an efficient representation for the direct
##  product. For example the direct product of permutation groups will be a
##  permutation group again and the direct product of pc groups will be a pc
##  group.
##  <P/>
##  If the groups are in different representations a generic direct product
##  will be formed which may not be particularly efficient for many
##  calculations.
##  Instead it may be worth to convert all factors to a common representation
##  first, before forming the product.
##  <P/>
##  <Index Key="Embedding" Subkey="example for direct products">
##  <C>Embedding</C></Index>
##  <Index Key="Projection" Subkey="example for direct products">
##  <C>Projection</C></Index>
##  For a direct product <M>P</M>, calling
##  <Ref Oper="Embedding" Label="for a domain and a positive integer"/> with
##  <M>P</M> and <M>n</M> yields the homomorphism embedding the <M>n</M>-th
##  factor into <M>P</M>; calling
##  <Ref Oper="Projection" Label="for a domain and a positive integer"/> with
##  <A>P</A> and <A>n</A> yields the projection of <M>P</M> onto the
##  <M>n</M>-th factor,
##  see&nbsp;<Ref Sect="Embeddings and Projections for Group Products"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(1,2));;
##  gap> d:=DirectProduct(g,g,g);
##  Group([ (1,2,3), (1,2), (4,5,6), (4,5), (7,8,9), (7,8) ])
##  gap> Size(d);
##  216
##  gap> e:=Embedding(d,2);
##  2nd embedding into Group([ (1,2,3), (1,2), (4,5,6), (4,5), (7,8,9),
##    (7,8) ])
##  gap> Image(e,(1,2));
##  (4,5)
##  gap> Image(Projection(d,2),(1,2,3)(4,5)(8,9));
##  (1,2)
##  gap> f:=FreeGroup("a","b");;
##  gap> g:=f/ParseRelators(f,"a2,b3,(ab)5");
##  <fp group on the generators [ a, b ]>
##  gap> f2:=FreeGroup("x","y");;
##  gap> h:=f2/ParseRelators(f2,"x2,y4,xy=Yx");
##  <fp group on the generators [ x, y ]>
##  gap> d:=DirectProduct(g,h);
##  <fp group on the generators [ a, b, x, y ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectProduct" );
DeclareOperation( "DirectProductOp", [ IsList, IsSemigroup ] );

#############################################################################
##
#F  PcgsDirectProduct( <D>, <pcgsop>, <indsop>, <filter> )
##
##  <ManSection>
##  <Func Name="PcgsDirectProduct" Arg='D, pcgsop, indsop, filter'/>
##
##  <Description>
##  constructs a new pcgs from pcgses of the components of D, setting
##  the necessary indices for the new pcgs and sets the property
##  specified by filter.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PcgsDirectProduct" );

#############################################################################
##
#O  SubdirectProduct(<G>, <H>, <Ghom>, <Hhom> )
##
##  <#GAPDoc Label="SubdirectProduct">
##  <ManSection>
##  <Func Name="SubdirectProduct" Arg='G, H, Ghom, Hhom'/>
##
##  <Description>
##  constructs the subdirect product of <A>G</A> and <A>H</A> with respect to
##  the epimorphisms <A>Ghom</A> from <A>G</A> onto a group <M>A</M> and
##  <A>Hhom</A> from <A>H</A> onto the same group <M>A</M>.
##  <P/>
##  <Index Key="Projection" Subkey="example for subdirect products">
##  <C>Projection</C></Index>
##  For a subdirect product <M>P</M>, calling
##  <Ref Oper="Projection" Label="for a domain and a positive integer"/> with
##  <M>P</M> and <M>n</M> yields the projection on the <M>n</M>-th factor.
##  (In general the factors do not embed into a subdirect product.)
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(1,2));
##  Group([ (1,2,3), (1,2) ])
##  gap> hom:=GroupHomomorphismByImagesNC(g,g,[(1,2,3),(1,2)],[(),(1,2)]);
##  [ (1,2,3), (1,2) ] -> [ (), (1,2) ]
##  gap> s:=SubdirectProduct(g,g,hom,hom);
##  Group([ (1,2,3), (1,2)(4,5), (4,5,6) ])
##  gap> Size(s);
##  18
##  gap> p:=Projection(s,2);
##  2nd projection of Group([ (1,2,3), (1,2)(4,5), (4,5,6) ])
##  gap> Image(p,(1,3,2)(4,5,6));
##  (1,2,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SubdirectProduct");
DeclareOperation( "SubdirectProductOp",
    [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ] );

#############################################################################
##
#F  SubdirectDiagonalPerms(<l>,<m>)
##
##  <ManSection>
##  <Func Name="SubdirectDiagonalPerms" Arg='l,m'/>
##
##  <Description>
##  Let <A>l</A> and <A>m</A> be lists of permutations that are the images of
##  the same generating set <A>gens</A>.
##  This function returns permutations for the images
##  of <A>gens</A> under the subdirect product of the homomorphisms.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SubdirectDiagonalPerms");

#############################################################################
##
#O  SemidirectProduct(<G>, <alpha>, <N> )
#O  SemidirectProduct(<autgp>, <N> )
##
##  <#GAPDoc Label="SemidirectProduct">
##  <ManSection>
##  <Heading>SemidirectProduct</Heading>
##  <Oper Name="SemidirectProduct" Arg='G, alpha, N'
##   Label="for acting group, action, and a group"/>
##  <Oper Name="SemidirectProduct" Arg='autgp, N'
##   Label="for a group of automorphisms and a group"/>
##
##  <Description>
##  constructs the semidirect product of <A>N</A> with <A>G</A> acting via
##  <A>alpha</A>, which must be a homomorphism from <A>G</A> into a group of
##  automorphisms of <A>N</A>.
##  <P/>
##  If <A>N</A> is a group, <A>alpha</A> must be a homomorphism from <A>G</A>
##  into a group of automorphisms of <A>N</A>.
##  <P/>
##  If <A>N</A> is a full row space over a field <A>F</A>, <A>alpha</A> must
##  be a homomorphism from <A>G</A> into a matrix group of the right
##  dimension over a subfield of <A>F</A>, or into a permutation group
##  (in this case permutation matrices are taken).
##  <P/>
##  In the second variant, <A>autgp</A> must be a group of automorphism of
##  <A>N</A>, it is a shorthand for
##  <C>SemidirectProduct(<A>autgp</A>,IdentityMapping(<A>autgp</A>),<A>N</A>)</C>.
##  Note that (unless <A>autgrp</A> has been obtained by the operation
##  <Ref Attr="AutomorphismGroup"/>)
##  you have to test <Ref Prop="IsGroupOfAutomorphisms"/> for <A>autgrp</A>
##  to ensure that &GAP; knows that <A>autgrp</A> consists of
##  group automorphisms.
##  <Example><![CDATA[
##  gap> n:=AbelianGroup(IsPcGroup,[5,5]);
##  <pc group of size 25 with 2 generators>
##  gap> au:=DerivedSubgroup(AutomorphismGroup(n));;
##  gap> Size(au);
##  120
##  gap> p:=SemidirectProduct(au,n);;
##  gap> Size(p);
##  3000
##  gap> n:=Group((1,2),(3,4));;
##  gap> au:=AutomorphismGroup(n);;
##  gap> au:=First(AsSet(au),i->Order(i)=3);;
##  gap> au:=Group(au);
##  <group with 1 generator>
##  gap> IsGroupOfAutomorphisms(au);
##  true
##  gap> SemidirectProduct(au,n);
##  <pc group with 3 generators>
##  gap> n:=AbelianGroup(IsPcGroup,[2,2]);
##  <pc group of size 4 with 2 generators>
##  gap> au:=AutomorphismGroup(n);;
##  gap> apc:=IsomorphismPcGroup(au);;
##  gap> g:=Image(apc);
##  Group([ f1, f2 ])
##  gap> apci:=InverseGeneralMapping(apc);;
##  gap> IsGroupHomomorphism(apci);
##  true
##  gap> p:=SemidirectProduct(g,apci,n);
##  <pc group of size 24 with 4 generators>
##  gap> IsomorphismGroups(p,Group((1,2,3,4),(1,2))) <> fail;
##  true
##  gap> SemidirectProduct(SU(3,3),GF(9)^3);
##  <matrix group of size 4408992 with 3 generators>
##  gap> SemidirectProduct(Group((1,2,3),(2,3,4)),GF(5)^4);
##  <matrix group of size 7500 with 3 generators>
##  gap> g:=Group((3,4,5),(1,2,3));;
##  gap> mats:=[[[Z(2^2),0*Z(2)],[0*Z(2),Z(2^2)^2]],
##  >          [[Z(2)^0,Z(2)^0], [Z(2)^0,0*Z(2)]]];;
##  gap> hom:=GroupHomomorphismByImages(g,Group(mats),[g.1,g.2],mats);;
##  gap> SemidirectProduct(g,hom,GF(4)^2);
##  <matrix group of size 960 with 3 generators>
##  gap> SemidirectProduct(g,hom,GF(16)^2);
##  <matrix group of size 15360 with 4 generators>
##  ]]></Example>
##  <P/>
##  <Index Key="Embedding" Subkey="example for semidirect products">
##  <C>Embedding</C></Index>
##  <Index Key="Projection" Subkey="example for semidirect products">
##  <C>Projection</C></Index>
##  For a semidirect product <M>P</M> of <A>G</A> with <A>N</A>, calling
##  <Ref Oper="Embedding" Label="for a domain and a positive integer"/> with
##  <M>P</M> and <C>1</C> yields the embedding of <A>G</A>, calling
##  <Ref Oper="Embedding" Label="for a domain and a positive integer"/> with
##  <M>P</M> and <C>2</C> yields the embedding of <A>N</A>; calling
##  <Ref Oper="Projection" Label="for a domain and a positive integer"/> with
##  <A>P</A> yields the projection of <M>P</M> onto <A>G</A>,
##  see&nbsp;<Ref Sect="Embeddings and Projections for Group Products"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> Size(Image(Embedding(p,1)));
##  6
##  gap> Embedding(p,2);
##  [ f1, f2 ] -> [ f3, f4 ]
##  gap> Projection(p);
##  [ f1, f2, f3, f4 ] -> [ f1, f2, <identity> of ..., <identity> of ... ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SemidirectProduct",
    [ IsGroup, IsGroupHomomorphism, IsObject ] );


#############################################################################
##
#O  WreathProduct(<G>, <H>[, <hom>] )
##
##  <#GAPDoc Label="WreathProduct">
##  <ManSection>
##  <Oper Name="WreathProduct" Arg='G, H[, hom]'/>
##  <Oper Name="StandardWreathProduct" Arg='G, H'/>
##
##  <Description>
##  <C>WreathProduct</C>
##  constructs the wreath product of the group <A>G</A> with the group
##  <A>H</A>, acting as a permutation group.
##  <P/>
##  If a third argument <A>hom</A> is given, it must be
##  a homomorphism from <A>H</A> into a permutation group,
##  and the action of this group on its moved points is considered.
##  <P/>
##  If only two arguments are given, <A>H</A> must be a permutation group.
##  <P/>
##  <C>StandardWreathProduct</C> returns the wreath product for the (right
##  regular) permutation action of <A>H</A> on its elements.
##  <P/>
##  <Index Key="Embedding" Subkey="example for wreath products">
##  <C>Embedding</C></Index>
##  <Index Key="Projection" Subkey="example for wreath products">
##  <C>Projection</C></Index>
##  For a wreath product <M>W</M> of <A>G</A> with a permutation group
##  <M>P</M> of degree <M>n</M> and <M>1 \leq i \leq n</M> calling
##  <Ref Oper="Embedding" Label="for a domain and a positive integer"/> with
##  <M>W</M> and <M>i</M> yields the embedding of <A>G</A> in the <M>i</M>-th
##  component of the direct product of the base group <M><A>G</A>^n</M> of
##  <M>W</M>.
##  For <M>i = n+1</M>,
##  <Ref Oper="Embedding" Label="for a domain and a positive integer"/>
##  yields the embedding of <M>P</M> into <M>W</M>.  Calling
##  <Ref Oper="Projection" Label="for a domain and a positive integer"/> with
##  <M>W</M> yields the projection onto the acting group <M>P</M>,
##  see&nbsp;<Ref Sect="Embeddings and Projections for Group Products"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(1,2));
##  Group([ (1,2,3), (1,2) ])
##  gap> p:=Group((1,2,3));
##  Group([ (1,2,3) ])
##  gap> w:=WreathProduct(g,p);
##  Group([ (1,2,3), (1,2), (4,5,6), (4,5), (7,8,9), (7,8),
##    (1,4,7)(2,5,8)(3,6,9) ])
##  gap> Size(w);
##  648
##  gap> Embedding(w,1);
##  1st embedding into Group( [ (1,2,3), (1,2), (4,5,6), (4,5), (7,8,9),
##    (7,8), (1,4,7)(2,5,8)(3,6,9) ] )
##  gap> Image(Embedding(w,3));
##  Group([ (7,8,9), (7,8) ])
##  gap> Image(Embedding(w,4));
##  Group([ (1,4,7)(2,5,8)(3,6,9) ])
##  gap> Image(Projection(w),(1,4,8,2,6,7,3,5,9));
##  (1,2,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "WreathProduct", [ IsGroup, IsGroup ] );
DeclareOperation( "StandardWreathProduct", [ IsGroup, IsGroup ] );


#############################################################################
##
#F  WreathProductImprimitiveAction(<G>, <H> )
##
##  <#GAPDoc Label="WreathProductImprimitiveAction">
##  <ManSection>
##  <Func Name="WreathProductImprimitiveAction" Arg='G, H'/>
##
##  <Description>
##  For two permutation groups <A>G</A> and <A>H</A>,
##  this function constructs the wreath product of <A>G</A> and <A>H</A>
##  in the imprimitive action.
##  If <A>G</A> acts on <M>l</M> points and <A>H</A> on <M>m</M> points
##  this action will be on <M>l \cdot m</M> points,
##  it will be imprimitive with <M>m</M> blocks of size <M>l</M> each.
##  <P/>
##  The operations <Ref Oper="Embedding" Label="for two domains"/>
##  and <Ref Oper="Projection" Label="for two domains"/>
##  operate on this product as described for general wreath products.
##  <P/>
##  <Example><![CDATA[
##  gap> w:=WreathProductImprimitiveAction(g,p);;
##  gap> LargestMovedPoint(w);
##  9
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "WreathProductImprimitiveAction" );


#############################################################################
##
#F  WreathProductProductAction(<G>, <H> )
##
##  <#GAPDoc Label="WreathProductProductAction">
##  <ManSection>
##  <Func Name="WreathProductProductAction" Arg='G, H'/>
##
##  <Description>
##  For two permutation groups <A>G</A> and <A>H</A>,
##  this function constructs the wreath product in product action.
##  If <A>G</A> acts on <M>l</M> points and <A>H</A> on
##  <M>m</M> points this action will be on <M>l^m</M> points.
##  <P/>
##  The operations <Ref Oper="Embedding" Label="for two domains"/>
##  and <Ref Oper="Projection" Label="for two domains"/>
##  operate on this product as described for general wreath products.
##  <Example><![CDATA[
##  gap> w:=WreathProductProductAction(g,p);
##  <permutation group of size 648 with 7 generators>
##  gap> LargestMovedPoint(w);
##  27
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "WreathProductProductAction" );


#############################################################################
##
#F  SubdirectProducts( <G>, <H> )
##
##  <#GAPDoc Label="SubdirectProducts">
##  <ManSection>
##  <Func Name="SubdirectProducts" Arg='G, H'/>
##
##  <Description>
##  this function computes all subdirect products of <A>G</A> and <A>H</A> up
##  to conjugacy in the direct product of Parent(<A>G</A>) and
##  Parent(<A>H</A>).
##  The subdirect products are returned as subgroups of this direct product.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InnerSubdirectProducts" );
DeclareGlobalFunction( "InnerSubdirectProducts2" );
DeclareGlobalFunction( "SubdirectProducts" );


#############################################################################
##
#F  FreeProduct( <G>{, <H>} )
#F  FreeProduct( list )
##
##  <#GAPDoc Label="FreeProduct">
##  <ManSection>
##  <Heading>FreeProduct</Heading>
##  <Func Name="FreeProduct" Arg='G[, H, ...]' Label="for several groups"/>
##  <Func Name="FreeProduct" Arg='list' Label="for a list"/>
##
##  <Description>
##  constructs a finitely presented group which is the free product of
##  the groups given as arguments.
##  If the group arguments are not finitely presented groups,
##  then <Ref Attr="IsomorphismFpGroup"/> must be defined for them.
##  <P/>
##  The operation <Ref Oper="Embedding" Label="for two domains"/>
##  operates on this product.
##  <Example><![CDATA[
##  gap> g := DihedralGroup(8);;
##  gap> h := CyclicGroup(5);;
##  gap> fp := FreeProduct(g,h,h);
##  <fp group on the generators [ f1, f2, f3, f4, f5 ]>
##  gap> fp := FreeProduct([g,h,h]);
##  <fp group on the generators [ f1, f2, f3, f4, f5 ]>
##  gap> Embedding(fp,2);
##  [ f1 ] -> [ f4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("FreeProduct");
DeclareOperation( "FreeProductOp", [ IsList, IsGroup ] );


#############################################################################
##
#A  DirectProductInfo( <G> )
##
##  <ManSection>
##  <Attr Name="DirectProductInfo" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "DirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  SubdirectProductInfo( <G> )
##
##  <ManSection>
##  <Attr Name="SubdirectProductInfo" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "SubdirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  SemidirectProductInfo( <G> )
##
##  <ManSection>
##  <Attr Name="SemidirectProductInfo" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "SemidirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  WreathProductInfo( <G> )
##
##  <ManSection>
##  <Attr Name="WreathProductInfo" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "WreathProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  FreeProductInfo( <G> )
##
##  <ManSection>
##  <Attr Name="FreeProductInfo" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "FreeProductInfo", IsGroup, "mutable" );

#############################################################################
##
#F  SubdirProdPcGroups( <G>,<gi>,<H>,<hi> )
##
##  <ManSection>
##  <Func Name="SubdirProdPcGroups" Arg='G,gi,H,hi'/>
##
##  <Description>
##  Let <A>G</A> and <A>H</A> be two pc groups which are both projections of a
##  subdirect product with generator images <A>gi</A> and <A>hi</A>. the function
##  returns a list <A>l</A> with <A>l</A>[1] a new pc group and <A>l</A>[2] a corresponding
##  generator images list.
##  <P/>
##  No parameter checking is done.
##  (This function is used in a variant of the SQ.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SubdirProdPcGroups" );

#############################################################################
##
#C  IsWreathProductElement
#C  IsWreathProductElementCollection
##
##  <ManSection>
##  <Filt Name="IsWreathProductElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsWreathProductElementCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  categories for elements of generic wreath products: elements are stored
##  as list of base components and permutation.
##  </Description>
##  </ManSection>
##
DeclareCategory("IsWreathProductElement",
  IsMultiplicativeElementWithInverse and IsAssociativeElement);
DeclareCategoryCollections("IsWreathProductElement");

InstallTrueMethod(IsGeneratorsOfMagmaWithInverses,
  IsWreathProductElementCollection);

DeclareRepresentation("IsWreathProductElementDefaultRep",
  IsWreathProductElement and IsPositionalObjectRep,[]);

#############################################################################
##
#F  ListWreathProductElement
#O  ListWreathProductElementNC
##
##  <#GAPDoc Label="ListWreathProductElement">
##  <ManSection>
##  <Func Name="ListWreathProductElement" Arg='G, x[, testDecomposition]'/>
##  <Oper Name="ListWreathProductElementNC" Arg='G, x, testDecomposition'/>
##
##  <Description>
##  Let <A>x</A> be an element of a wreath product <A>G</A>
##  where <M>G = K \wr H</M> and <M>H</M> acts
##  as a finite permutation group of degree <M>m</M>.
##  We can identify the element <A>x</A> with a tuple <M>(f_1, \ldots, f_m; h)</M>,
##  where <M>f_i \in K</M> is the <M>i</M>-th base component of <A>x</A>
##  and <M>h \in H</M> is the top component of <A>x</A>.
##  <P/>
##  <Ref Func="ListWreathProductElement"/> returns a list <M>[f_1, \ldots, f_m, h]</M>
##  containing the components of <A>x</A> or <K>fail</K> if <A>x</A> cannot be decomposed in the wreath product.
##  <P/>
##  If omitted, the argument <A>testDecomposition</A> defaults to true.
##  If <A>testDecomposition</A> is true, <Ref Func="ListWreathProductElement"/> makes additional tests to ensure
##  that the computed decomposition of <A>x</A> is correct,
##  i.e. it checks that <A>x</A> is an element of the parent wreath product of <A>G</A>:
##  <P/>
##  If <M>K \leq \mathop{Sym}(l)</M>, this ensures that <M>x \in \mathop{Sym}(l) \wr \mathop{Sym}(m)</M>
##  where the parent wreath product is considered in the same action as <A>G</A>,
##  i.e. either in imprimitive action or product action.
##  <P/>
##  If <M>K \leq \mathop{GL}(n,q)</M>, this ensures that <M>x \in \mathop{GL}(n,q) \wr \mathop{Sym}(m)</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ListWreathProductElement" );
DeclareOperation( "ListWreathProductElementNC", [HasWreathProductInfo, IsObject, IsBool] );

#############################################################################
##
#F  WreathProductElementList
#O  WreathProductElementListNC
##
##  <#GAPDoc Label="WreathProductElementList">
##  <ManSection>
##  <Func Name="WreathProductElementList" Arg='G, list'/>
##  <Oper Name="WreathProductElementListNC" Arg='G, list'/>
##
##  <Description>
##  Let <A>list</A> be equal to <M>[f_1, \ldots, f_m, h]</M> and <A>G</A> be a wreath product
##  where <M>G = K \wr H</M>, <M>H</M> acts
##  as a finite permutation group of degree <M>m</M>,
##  <M>f_i \in K</M> and <M>h \in H</M>.
##  <P/>
##  <Ref Func="WreathProductElementList"/> returns the element <M>x \in G</M>
##  identified by the tuple <M>(f_1, \ldots, f_m; h)</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "WreathProductElementList" );
DeclareOperation( "WreathProductElementListNC", [HasWreathProductInfo, IsList] );
