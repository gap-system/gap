#############################################################################
##
#W helpers.gd                                               Laurent Bartholdi
##
#H   @(#)$Id: helpers.gd,v 1.40 2009/09/25 14:59:18 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file contains helper code for functionally recursive groups,
##  in particular related to the geometry of groups.
##
#############################################################################

#############################################################################
##
#F Products
##
## <#GAPDoc Label="TensorSum">
## <ManSection>
##   <Func Name="TensorSum" Arg="objects,..."/>
##   <Description>
##     This function is similar in syntax to <Ref Func="DirectProduct"
##     BookName="ref"/>, and delegates to <C>TensorSumOp</C>; its meaning
##     depends on context, see e.g.
##     <Ref Meth="TensorSumOp" Label="FR Machines"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="TensorProduct" Arg="objects,..."/>
##   <Description>
##     This function is similar in syntax to <Ref Func="DirectProduct"
##     BookName="ref"/>, and delegates to <C>TensorProductOp</C>; its meaning
##     depends on context, see e.g.
##     <Ref Meth="TensorProductOp" Label="FR Machines"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="DirectSum" Arg="objects,..."/>
##   <Description>
##     This function is similar in syntax to <Ref Func="DirectProduct"
##     BookName="ref"/>, and delegates to <C>DirectSumOp</C>; its meaning
##     depends on context, see e.g.
##     <Ref Meth="DirectSumOp" Label="FR Machines"/>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("TensorSum");
#############################################################################

#############################################################################
##
#H WordGrowth(g)
##
## <#GAPDoc Label="WordGrowth">
## <ManSection>
##   <Func Name="WordGrowth" Arg="g,rec(options...)"/>
##   <Func Name="WordGrowth" Arg="g:options..." Label="1arg"/>
##   <Func Name="OrbitGrowth" Arg="g,point[,limit]"/>
##   <Func Name="Ball" Arg="g,radius"/>
##   <Func Name="Sphere" Arg="g,radius"/>
##   <Returns>The word growth of the semigroup <A>g</A>.</Returns>
##   <Description>
##     This function computes the first terms of growth series associated
##     with the semigroup <A>g</A>. The argument <A>g</A> can actually be
##     a group/monoid/semigroup, or a list representing that semigroup's
##     generating set.
##
##     <P/> The behaviour of <C>WordGrowth</C> is controlled via options
##     passed in the second argument, which is a record. They can be combined
##     when reasonable, and are: <List>
##     <Mark><C>limit:=n</C></Mark> <Item> to specify a limit
##       radius;</Item>
##     <Mark><C>sphere:=radius</C></Mark> <Item> to return the sphere
##       of the specified radius, unless a radius was specified in
##       <C>limit</C>, in which case the value is ignored;</Item>
##     <Mark><C>spheres:=maxradius</C></Mark> <Item> to return the list
##       of spheres of radius between 0 and the specified limit;</Item>
##     <Mark><C>spheresizes:=maxradius</C></Mark> <Item> to return the list
##       sizes of spheres of radius between 0 and the specified limit;</Item>
##     <Mark><C>ball:=radius</C></Mark> <Item> to return the ball
##       of the specified radius;</Item>
##     <Mark><C>balls:=maxradius</C></Mark> <Item> to return the list
##       of balls of radius between 0 and the specified limit;</Item>
##     <Mark><C>ballsizes:=maxradius</C></Mark> <Item> to return the list
##       sizes of balls of radius between 0 and the specified limit;</Item>
##     <Mark><C>indet:=z</C></Mark> <Item> to return the
##       <C>spheresizes</C>, as a polynomial in <C>z</C> (or the first
##       indeterminate if <C>z</C> is not a polynomial;</Item>
##     <Mark><C>draw:=filename</C></Mark> <Item> to create a
##       rendering of the Cayley graph of <A>g</A>. Edges are
##       given colours according to the cyclic ordering "red", "blue",
##       "green", "gray", "yellow", "cyan", "orange", "purple".
##       If <C>filename</C> is a string, the graph is appended,
##       in <K>dot</K> format, to that file. Otherwise, the output is converted
##       to Postscript using the program <K>neato</K> from the
##       <Package>graphviz</Package> package, and displayed in a separate
##       X window using the program <Package>display</Package>.
##       This works on UNIX systems.
##       <P/> It is assumed, but not checked, that <Package>graphviz</Package>
##       and <Package>display</Package> are properly installed on the system.
##       </Item>
##     <Mark><C>point:=p</C></Mark> <Item> to compute the
##       growth of the orbit of <C>p</C> under <A>g</A>, rather than the growth
##       of <A>g</A>.</Item>
##     <Mark><C>track:=true</C></Mark> <Item> to keep track of a word in the
##       generators that gives the element. This affects the "ball", "balls",
##       "sphere" and "spheres" commands, where the result returned is a
##       3-element list: the first entry is the original results; the
##       second entry is a homomorphism from a free group/monoid/semigroup;
##       and the third entry contains the words corresponding to the first
##       entry via the homomorphism.</Item>
##     </List>
##
##     If the first argument is an integer <C>n</C> and not a record,
##     the command is interpreted as
##     <C>WordGrowth(...,rec(spheresizes:=n))</C>.
##
##     <P/> <C>WordGrowth(...,rec(draw:=true))</C> may be abbreviated as
##     <C>Draw(...)</C>; <C>WordGrowth(...,rec(ball:=n))</C> may be
##     abbreviated as <C>Ball(...,n)</C>; <C>WordGrowth(...,rec(sphere:=n))</C>
##     may be abbreviated as <C>Sphere(...,n)</C>;
## <Example><![CDATA[
## gap> WordGrowth(GrigorchukGroup,4);
## [ 1, 4, 6, 12, 17 ]
## gap> WordGrowth(GrigorchukGroup,rec(limit:=4,indet:=true));
## 17*x_1^4+12*x_1^3+6*x_1^2+4*x_1+1
## gap> WordGrowth(GrigorchukGroup,rec(limit:=1,spheres:=true));
## [ [ <Mealy element on alphabet [ 1, 2 ] with 1 state, initial state 1> ],
##   [ d, b, c, a ] ]
## gap> WordGrowth(GrigorchukGroup,rec(point:=[2,2,2]));
## [ 1, 1, 1, 1, 1, 1, 1, 1 ]
## gap> OrbitGrowth(GrigorchukGroup,[1,1,1]);
## [ 1, 2, 2, 1, 1, 1 ]
## gap> WordGrowth(GrigorchukGroup,rec(spheres:=4,point:=PeriodicList([],[2])));
## [ [ [/ 2 ] ], [ [ 1, / 2 ] ], [ [ 1, 1, / 2 ] ], [ [ 2, 1, / 2 ] ],
##   [ [ 2, 1, 1, / 2 ] ] ]
## gap> WordGrowth([(1,2),(2,3)],rec(spheres:=infinity,track:=true));
## [ [ [  ], [ (2,3), (1,2) ], [ (), (1,2,3), (1,3,2) ], [ (1,3) ] ],
##   MappingByFunction( <free semigroup on the generators [ s1, s2 ]>, <group>, function( w ) ... end ),
##   [ [  ], [ s2, s1 ], [ s2^2, s2*s1, s1*s2 ], [ s2*s1*s2 ] ] ]
## ]]></Example>
##     Note that the orbit growth of <C>[/2]</C> is constant 1, while
##     that of <C>[/1]</C> is constant 2.
##     The following code would find the point with maximal orbit growth
##     of a semigroup acting on the integers (for example, constructed with
##     <Ref Meth="PermGroup"/>):
## <Listing>
## MaximalOrbitGrowth := function(g)
##     local maxpt, growth, max;
##     maxpt := LargestMovedPoint(g);
##     growth := List([1..maxpt],n->WordGrowth(g:point:=n));
##     max := Maximum(growth);
##     return [max,Filtered([1..maxpt],n->growth[n]=max)];
## end;
## </Listing>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("WordGrowth");
DeclareGlobalFunction("OrbitGrowth");
DeclareOperation("Ball",[IsObject,IsInt]);
DeclareOperation("Sphere",[IsObject,IsInt]);
#############################################################################

#############################################################################
##
#H StringByInt
##
## <#GAPDoc Label="Helpers">
## <ManSection>
##   <Func Name="StringByInt" Arg="n[,b]"/>
##   <Returns>A string representing <A>n</A> in base <A>b</A>.</Returns>
##   <Description>
##     This function converts a positive integer to string. It accepts
##     an optional second argument, which is a base in which to
##     print <A>n</A>. By default, <A>b</A> is 2.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="PositionInTower" Arg="t,x"/>
##   <Returns>The largest index such that <C>t[i]</C> contains <A>x</A>.</Returns>
##   <Description>
##     This function assumes <A>t</A> is a descending tower of domains, such
##     as that constructed by <C>LowerCentralSeries</C>. It returns the largest
##     integer <C>i</C> such that <C>t[i]</C> contains <A>x</A>; in case the
##     tower ends precisely with <A>x</A>, the value <K>infinity</K> is
##     returned.
##
##     <P/> <A>x</A> can be an element or a subdomain of <C>t[1]</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="CoefficientsInAbelianExtension" Arg="x,b,G"/>
##   <Returns>The coefficients in <A>b</A> of the element <A>x</A>, modulo <A>G</A>.</Returns>
##   <Description>
##     If <A>b</A> is a list of group elements <M>b_1,\ldots,b_k</M>, and
##     <M>H=\langle G,b_1,\ldots,b_k\rangle</M> contains <A>G</A> as a
##     normal subgroup, and <M>H/G</M> is abelian and <M>x\in H</M>,
##     then this function computes exponents <M>e_1,\ldots,e_k</M> such that
##     <M>\prod b_i^{e_i}G=xG</M>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="MagmaEndomorphismByImagesNC" Arg="f,im"/>
##   <Returns>An endomorphism of <A>f</A>.</Returns>
##   <Description>
##     This function constructs an endomorphism of the group,monoid or
##     semigroup <A>f</A> specified by sending generator number <M>i</M>
##     to the <M>i</M>th entry in <A>im</A>. It is a shortcut for a call
##     to <C>GroupHomomorphismByImagesNC</C> or
##     <C>MagmaHomomorphismByFunctionNC(...,MappedWord(...))</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="MagmaHomomorphismByImagesNC" Arg="f,g,im"/>
##   <Returns>An homomorphism from <A>f</A> to <A>g</A>.</Returns>
##   <Description>
##     This function constructs a homomorphism of the group,monoid or
##     semigroup <A>f</A> specified by sending generator number <M>i</M>
##     to the <M>i</M>th entry in <A>im</A>. It is a shortcut for a call
##     to <C>GroupHomomorphismByImagesNC</C> or
##     <C>MagmaHomomorphismByFunctionNC(...,MappedWord(...))</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("StringByInt");
DeclareGlobalFunction("HallBasis");
DeclareGlobalFunction("PositionInTower");
DeclareGlobalFunction("CoefficientsInAbelianExtension");
DeclareGlobalFunction("MagmaEndomorphismByImagesNC");
DeclareGlobalFunction("MagmaHomomorphismByImagesNC");
#############################################################################

#############################################################################
##
#H ShortMonoidRelations
##
## <#GAPDoc Label="ShortMonoidRelations">
## <ManSection>
##   <Oper Name="ShortGroupRelations" Arg="g,n"/>
##   <Oper Name="ShortMonoidRelations" Arg="g,n"/>
##   <Returns>A list of relations between words over <A>g</A>, of length at most <A>n</A>.</Returns>
##   <Description>
##     This function assumes that <A>g</A> is a list of monoid elements.
##     it searches for products of at most <A>n</A> elements over <A>g</A>
##     that are equal.
##
##     <P/> In its first form, it returns a list of words in a free group
##     <C>f</C> of rank the length of <A>g</A>, that are trivial in <A>g</A>.
##     The first argument may be a group, in which case its symmetric
##     generating set is considered.
##
##     <P/> In its second form, it returns a list of pairs
##     <C>[l,r]</C>, where <C>l</C> and <C>r</C> are words in a free
##     monoid <C>f</C> of rank the length of <A>g</A>, that are equal in
##     <A>g</A>. The first argument may be a monoid, in which case its monoid
##     generating set is considered.
##
##     <P/> This command does not construct all such pairs; rather, it returns
##     a small set, in the hope that it may serve as a presentation for
##     the monoid generated by <A>g</A>.
##
##     <P/> The first element of the list returned is actually not a relation:
##     it is a homomorphism from <C>f</C> to [the group/monoid
##     generated by] <A>g</A>.
## <Example><![CDATA[
## gap> ShortGroupRelations(GrigorchukGroup,10);
## [ [ x1, x2, x3, x4 ] -> [ a, b, c, d ],
##   x1^2, x2^2, x3^2, x4^2, x2*x3*x4, x4*x1*x4*x1*x4*x1*x4*x1,
##   x3*x1*x3*x1*x3*x1*x3*x1*x3*x1*x3*x1*x3*x1*x3*x1 ]
## gap> ShortGroupRelations(GuptaSidkiGroup,9);
## [ [ x1, x2 ] -> [ x, gamma ],
##   x1^3, x2^3, x2*x1^-1*x2*x1^-1*x2*x1^-1*x2*x1^-1*x2*x1^-1*x2*x1^-1*
##      x2*x1^-1*x2*x1^-1*x2*x1^-1,    x1^-1*x2^-1*x1^-1*x2^-1*x1^-1*x2^-1*
## x1^-1*x2^-1*x1^-1*x2^-1*x1^-1*x2^-1*x1^-1*x2^-1*x1^-1*x2^-1*x1^-1*x2^-1 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ShortGroupWordInSet" Arg="g,s,n"/>
##   <Oper Name="ShortMonoidWordInSet" Arg="g,s,n"/>
##   <Oper Name="ShortSemigroupWordInSet" Arg="g,s,n"/>
##   <Returns>Words over <A>g</A> that express elements of <A>s</A>.</Returns>
##   <Description>
##     This command produces words in the free group/monoid/semigroup
##     generated by <A>g</A>'s generators that express elements of the set
##     <A>s</A>. Elements of length at most <A>AbsoluteValue(n)</A> are
##     searched; if <A>n</A> is non-negative then at most one element is
##     returned. The value <C><A>n</A>=infinity</C> is allowed.
##
##     <P/> The second argument may be either a list, a predicate
##     (i.e. a function returning <K>true</K> or <K>false</K>) or an element.
##
##     <P/> The function returns a list of words in the free
##     group/monoid/semigroup; the first entry of the list is a
##     homomorphism from the free group/monoid/semigroup to <A>g</A>.
## <Example><![CDATA[
## gap> l := ShortMonoidWordInSet(Group((1,2),(2,3),(3,4)),
##             [(1,2,3,4),(4,3,2,1)],-3);
## [ MappingByFunction( <free monoid on the generators [ m1, m2, m3 ]>, Group(
##     [ (1,2), (2,3), (3,4) ]), function( w ) ... end ), m3*m2*m1, m1*m2*m3 ]
## gap> f := Remove(l,1);;
## gap> List(l,x->x^f);
## [ (1,2,3,4), (1,4,3,2) ]
## gap> ShortMonoidWordInSet(GrigorchukGroup,
##        [Comm(GrigorchukGroup.1,GrigorchukGroup.2)],4);
## [ MappingByFunction( <free monoid on the generators [ m1, m2, m3, m4
##      ]>, <self-similar monoid over [ 1 .. 2 ] with
##     4 generators>, function( w ) ... end ), m1*m2*m1*m2 ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("ShortMonoidRelations",[IsObject,IsInt]);
DeclareOperation("ShortGroupRelations",[IsObject,IsInt]);
DeclareOperation("ShortGroupWordInSet",[IsGroup,IsObject,IsObject]);
DeclareOperation("ShortMonoidWordInSet",[IsMonoid,IsObject,IsObject]);
DeclareOperation("ShortSemigroupWordInSet",[IsSemigroup,IsObject,IsObject]);
#############################################################################

#############################################################################
##
#H Braid groups
##
## <#GAPDoc Label="Braids">
## <ManSection>
##   <Func Name="SurfaceBraidFpGroup" Arg="n,g,p"/>
##   <Func Name="PureSurfaceBraidFpGroup" Arg="n,g,p"/>
##   <Returns>The [pure] surface braid group on <A>n</A> strands.</Returns>
##   <Description>
##     This function creates a finitely presented group, isomorphic to the
##     [pure] braid group on <A>n</A> strands of the surface of genus <A>g</A>,
##     with <A>p</A> punctures. In particular,
##     <C>SurfaceBraidFpGroup(n,0,1)</C> is the usual braid group
##     (on the disc).
##
##     <P/> The presentation comes from <Cite Key="MR2043362"/>. The first
##     <M>2g</M> generators are the standard <M>a_i,b_i</M> surface
##     generators; the next <M>n-1</M> are the standard <M>s_i</M> braid
##     generators; and the last are the extra <M>z</M> generators.
##
##     <P/> The pure surface braid group is the kernel of the natural map
##     from the surface braid group to the symmetric group on <A>n</A>
##     points, defined by sending <M>a_i,b_i,z</M> to the identity and
##     <M>s_i</M> to the transposition <C>(i,i+1)</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="CharneyBraidFpGroup" Arg="n"/>
##   <Returns>The braid group on <A>n</A> strands.</Returns>
##   <Description>
##     This function creates a finitely presented group, isomorphic to the
##     braid group on <A>n</A> strands (on the disc). It is isomorphic to
##     <C>SurfaceBraidFpGroup(n,0,1)</C>, but has a different presentation,
##     due to Charney (<Cite Key="MR1314589"/>), with one generator per
##     non-trivial permutation of <A>n</A> points.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="ArtinRepresentation" Arg="n"/>
##   <Returns>The braid group's representation on <C>FreeGroup(n)</C>.</Returns>
##   <Description>
##     This function creates a Artin's representatin, a homomorphism from the
##     braid group on <A>n</A> strands (on the disc) into the automorphism
##     group of a free group of rank <A>n</A>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("SurfaceBraidFpGroup");
DeclareGlobalFunction("PureSurfaceBraidFpGroup");
DeclareGlobalFunction("CharneyBraidFpGroup");
DeclareGlobalFunction("ArtinRepresentation");
#############################################################################

#############################################################################
##
#H Find incompressible elements
##
## <#GAPDoc Label="">
## <ManSection>
##   <Func Name="" Arg=""/>
##   <Returns>.</Returns>
##   <Description>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if false then
G := BinaryKneadingGroup(1/6);
S := [G.1,G.2,G.3];
pi := DecompositionOfFRElement(G);

EasyReduce := function(x)
  local e, i, verygeod, geod;
  e := ShallowCopy(ExtRepOfObj(x));
  verygeod := true;
  geod := true;
  for i in [2,4..Length(e)] do
    if e[i]=-1 then e[i] := 1; fi;
    if e[i] >= 2 or e[i] <= -2 then
      e[i] := RemInt(RemInt(e[i],2)+2,2);
      verygeod := false;
      if e[i-1] >= 2 then geod := false; fi;
    fi;
  od;
  return [ObjByExtRep(FamilyObj(x),e),geod,verygeod];
end;

MakeIncompressible := function(n)
  local inc, ginc, i;

  inc := [[One(G)],[G.1,G.2,G.3],Difference(Ball(G,2),Ball(G,1))];
  ginc := Ball(G,2);

  for i in [3..n] do
    inc[i+1] := Filtered(List(Cartesian(inc[i],[G.1,G.2,G.3]),p->p[1]*p[2]),function(g)
      local x;
      x := pi(g);
      return EasyReduce(g)[3] and x[1][1] in ginc and x[1][2] in ginc and EasyReduce(x[1][1])[2] and EasyReduce(x[1][2])[2];
    end);
    Append(ginc,inc[i+1]);
  od;
  return ginc;
end;
fi;
#############################################################################

#############################################################################
##
#M LowerCentralSeries etc. for algebras
##
## <#GAPDoc Label="LowerCentralSeries">
## <ManSection>
##   <Func Name="ProductIdeal" Arg="a,b"/>
##   <Func Name="ProductBOIIdeal" Arg="a,b"/>
##   <Returns>the product of the ideals <A>a</A> and <A>b</A>.</Returns>
##   <Description>
##     The first command computes the product of the left ideal <A>a</A> and
##     the right ideal <A>b</A>. If they are not appropriately-sided ideals,
##     the command first attempts to convert them.
##
##     <P/> The second command assumes that the ring of these ideals has a
##     basis made of invertible elements. It is then much easier to compute
##     the product.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="DimensionSeries" Arg="a[,n]"/>
##   <Returns>A nested list of ideals in the algebra-with-one <A>a</A>.</Returns>
##   <Description>
##     This command computes the powers of the augmentation ideal of <A>a</A>,
##     and returns their list. The list stops when the list becomes
##     stationary.
##
##     <P/> The optional second argument gives a limit to the number of
##     terms to put in the series.
## <Example><![CDATA[
## gap> a := ThinnedAlgebraWithOne(GF(2),GrigorchukGroup);
## <self-similar algebra-with-one on alphabet GF(2)^2 with 4 generators>
## gap> q := MatrixQuotient(a,3);
## <algebra-with-one of dimension 22 over GF(2)>
## gap> l := DimensionSeries(q);
## [ <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (5 generators)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 21)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 18)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 14)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 10)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 6)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 3)>,
##   <two-sided ideal in <algebra-with-one of dimension 22 over GF(2)>, (dimension 1)>,
##   <algebra of dimension 0 over GF(2)> ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("ProductIdeal",[IsAlgebra,IsAlgebra]);
DeclareOperation("ProductBOIIdeal",[IsAlgebra,IsAlgebra]);
DeclareOperation("DimensionSeries",[IsAlgebra]);
DeclareOperation("DimensionSeries",[IsAlgebra,IsInt]);
#############################################################################

#############################################################################
##
#M Complex numbers, and points on the Riemann sphere
##
DeclareCategoryCollections("IsMacFloat");
DeclareCategoryCollections("IsMacFloatCollection");
DeclareCategory("IS_COMPLEX", IsScalar and IsCommutativeElement);
DeclareCategoryCollections("IS_COMPLEX");
DeclareCategoryCollections("IS_COMPLEXCollection");
BindGlobal("COMPLEX_FAMILY", NewFamily("COMPLEX_FAMILY", IS_COMPLEX));
BindGlobal("TYPE_COMPLEX", NewType(COMPLEX_FAMILY, IS_COMPLEX));
BindGlobal("COMPLEX_FIELD",
        Objectify(NewType(CollectionsFamily(COMPLEX_FAMILY),
                IsField and IsAttributeStoringRep),rec()));
DeclareGlobalFunction("Complex");
DeclareOperation("ComplexRootsOfUnivariatePolynomial",[IsList]);
DeclareOperation("ComplexRootsOfUnivariatePolynomial",[IsPolynomial]);
DeclareAttribute("Argument", IsScalar);
DeclareGlobalVariable("COMPLEX_0");
DeclareGlobalVariable("COMPLEX_1");
DeclareGlobalVariable("COMPLEX_I");
DeclareGlobalVariable("COMPLEX_2IPI");
DeclareGlobalFunction("EXP_COMPLEX");
DeclareGlobalVariable("MACFLOAT_0");
DeclareGlobalVariable("MACFLOAT_1");
DeclareGlobalVariable("MACFLOAT_INF");
DeclareGlobalVariable("MACFLOAT_MINF");
DeclareGlobalVariable("MACFLOAT_NAN");
DeclareGlobalVariable("MACFLOAT_PI");
DeclareGlobalVariable("MACFLOAT_2PI");
DeclareAttribute("RealPart", IS_COMPLEX);
DeclareAttribute("ImaginaryPart", IS_COMPLEX);

DeclareCategory("IsP1Point",IsObject);
BindGlobal("P1Family", NewFamily("P1Family",IsP1Point));
BindGlobal("TYPE_P1POINT", NewType(P1Family,IsP1Point));
DeclareGlobalFunction("P1Point");
DeclareGlobalVariable("P1infinity");
DeclareOperation("Value",[IsRationalFunction,IsP1Point]);
DeclareOperation("P1Map",[IsP1Point,IsP1Point]);
DeclareOperation("P1Map",[IsP1Point,IsP1Point,IsP1Point]);
DeclareOperation("P1Map",[IsP1Point,IsP1Point,IsP1Point,IsP1Point,IsP1Point,IsP1Point]);
DeclareOperation("SphereP1",[IsP1Point]);
DeclareOperation("P1Sphere",[IsList]);
DeclareOperation("P1Distance",[IsP1Point,IsP1Point]);
DeclareOperation("P1PreImages",[IsRationalFunction,IsP1Point]);
DeclareOperation("SphereXProduct",[IsList,IsList]);
DeclareOperation("XProduct",[IsList,IsList]);
DeclareOperation("TripleProduct",[IsList,IsList,IsList]);
DeclareOperation("SphereProject",[IsList]);
DeclareAttribute("DegreeOfRationalFunction",IsRationalFunction);
DeclareAttribute("Primitive",IsRationalFunction);
#############################################################################

#############################################################################
DeclareRepresentation("IsLieFpElementRep",
        IsPositionalObjectRep and IsAttributeStoringRep,[]);
DeclareCategory("IsFpLieAlgebra",IsLieAlgebra);

DeclareHandlingByNiceBasis("IsLieFpElementSpace",
        "FR: for FP Lie algebras");
#############################################################################

#E helpers.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
