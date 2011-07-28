#############################################################################
##
#W helpers.gd                                               Laurent Bartholdi
##
#H   @(#)$Id: helpers.gd,v 1.53 2011/06/20 14:23:51 gap Exp $
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
##
##     <P/> For example, the command
##     <C>Draw(BasilicaGroup,rec(point:=PeriodicList([],[2,1]),limit:=3));</C>
##     produces (in a new window) the following picture:
##     <Alt Only="LaTeX"><![CDATA[
##       \includegraphics[height=5cm,keepaspectratio=true]{basilica-ball.jpg}
##     ]]></Alt>
##     <Alt Only="HTML"><![CDATA[
##       <img alt="Nucleus" src="basilica-ball.jpg">
##     ]]></Alt>
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
##   <Func Name="RenameSubobjects" Arg="obj,refobj"/>
##   <Description>
##     This function traverses <A>obj</A> if it is a list or a record, and,
##     when it finds an element which has no name, but is equal (in the sense
##     of <C>=</C>) to an element of <A>refobj</A>, assigns it the name of
##     that element.
## <Example><![CDATA[
## gap> trivial := Group(());; SetName(trivial,"trivial");
## gap> a := List([1..10],i->Group(Random(SymmetricGroup(3))));
## [ Group([ (2,3) ]), Group([ (2,3) ]), Group([ (1,3) ]), Group([ (1,3) ]),
##   Group([ (1,3,2) ]), Group([ (1,3,2) ]), Group([ (1,2) ]), Group(()),
##   Group([ (2,3) ]), Group([ (1,3,2) ]) ]
## gap> RenameSubobjects(a,[trivial]); a;
## [ Group([ (2,3) ]), Group([ (2,3) ]), Group([ (1,3) ]), Group([ (1,3) ]),
##   Group([ (1,3,2) ]), Group([ (1,3,2) ]), Group([ (1,2) ]), trivial,
##   Group([ (2,3) ]), Group([ (1,3,2) ]) ]
## ]]></Example>
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
DeclareGlobalFunction("PositionInTower");
DeclareOperation("RenameSubobjects",[IsObject,IsList]);
DeclareOperation("Draw",[IsBinaryRelation]);
DeclareOperation("Draw",[IsBinaryRelation,IsString]);
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
#H Posets
##
## <#GAPDoc Label="Posets">
## <ManSection>
##   <Func Name="Draw" Arg="p" Label="poset"/>
##   <Func Name="HeightOfPoset" Arg="p"/>
##   <Returns>The length of a maximal chain in the poset.</Returns>
##   <Description>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("HeightOfPoset", IsBinaryRelation);
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
## <#GAPDoc Label="complexnumbers">
## <ManSection>
##   <Filt Name="IS_COMPLEX"/>
##   <Fam Name="COMPLEX_FAMILY"/>
##   <Func Name="Complex" Arg="..."/>
##   <Var Name="COMPLEX_FIELD"/>
##   <Var Name="COMPLEX_0"/>
##   <Var Name="COMPLEX_1"/>
##   <Var Name="COMPLEX_I"/>
##   <Var Name="COMPLEX_2IPI"/>
##   <Var Name="COMPLEX_INF"/>
##   <Var Name="COMPLEX_NAN"/>
##   <Func Name="EXP_COMPLEX" Arg="z"/>
##   <Oper Name="Argument" Arg="z"/>
##   <Oper Name="AbsoluteValue" Arg="z"/>
##   <Oper Name="Norm" Arg="z"/>
##   <Oper Name="RealPart" Arg="z"/>
##   <Oper Name="ImaginaryPart" Arg="z"/>
##   <Description>
##     A rough implementation of complex numbers, based on the underlying
##     floating-point numbers in &GAP;.
##     <P/>
##     Strictly speaking, complex numbers do not form a field in &GAP;,
##     because associativity etc. do not hold. Still, a field is defined,
##     <C>COMPLEX_FIELD</C>, making it possible to construct an indeterminate
##     and rational functions, to be passed to <Package>FR</Package>'s
##     routines.
## <Example><![CDATA[
## gap> z := Indeterminate(COMPLEX_FIELD);
## gap> z := Indeterminate(COMPLEX_FIELD);
## z
## gap> (z+1/2)^5/(z-1/2);
## (z^5+2.5*z^4+2.5*z^3+1.25*z^2+0.3125*z+0.03125)/(z+(-0.5))
## gap> Complex(1,2);
## 1+I*2
## gap> last^2;
## -3+I*4
## gap> RealPart(last);
## -3
## gap> Norm(last2);
## 25
## gap> Complex("1+2*I");
## 1+I*2
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ComplexRootsOfUnivariatePolynomial" Arg="poly"/>
##   <Oper Name="ComplexRootsOfUnivariatePolynomial" Arg="list" Label="l"/>
##   <Returns>The complex roots of <A>poly</A>.</Returns>
##   <Description>
##     These methods compute the complex roots of a univariate
##     complex polynomial, using the Jenkins-Traub algorithm (TOMS 493).
##     <P/>
##     Note that this is a globally-convergent, very fast algorithm, but
##     that it suffers from loss of precision due to deflation, in
##     case many roots have the same norm.
## <Example><![CDATA[
## gap> ComplexRootsOfUnivariatePolynomial(z^2-5);
## [ -2.23607, 2.23607 ]
## gap> ComplexRootsOfUnivariatePolynomial([COMPLEX_1,COMPLEX_2]);
## Error, Variable: 'COMPLEX_2' must have a value
## not in any function
## gap> ComplexRootsOfUnivariatePolynomial([COMPLEX_1,2*COMPLEX_1]);
## [ -0.5 ]
## gap> ComplexRootsOfUnivariatePolynomial(ListWithIdenticalEntries(70,COMPLEX_1));
## [ 0.995974-I*0.0896393, 0.995974+I*0.0896393, 0.963963+I*0.266037, 0.98393-I*0.178557,
##   ...
##   -0.550314+I*0.826223 ]
## gap> List(last,AbsoluteValue);
## [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.989218, 0.977391, 0.9982, 1,
##   1.01007, 1, 1.0075, 1.00466, 1.00055, 1.00228, 0.999955, 1.00023, 0.999212, 0.999573, 1,
##   0.999914, 1, 1, 1.00104, 1, 0.999998, 1.00224, 1, 1.01073, 1, 1, 1.00003, 1, 0.990849, 1,
##   0.999983, 0.999955, 0.999985, 0.999749, 0.999999, 1.00043, 1.00002, 1, 0.999926, 1.00004,
##   1.00001, 0.99722, 1.00597, 0.999355, 1, 0.997287, 1.00555, 1.00117, 1.00759, 0.992719 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="MACFLOAT_PI"/>
##   <Var Name="MACFLOAT_EPS"/>
##   <Var Name="MACFLOAT_INF"/>
##   <Var Name="MACFLOAT_NAN"/>
##   <Description>
##     Floating-point constants.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="DegreeOfRationalFunction" Arg="rat"/>
##   <Returns>The degree of the univariate rational function <A>rat</A>.</Returns>
## </ManSection>
## <#/GAPDoc>
##
## <#GAPDoc Label="P1Points">
## <ManSection>
##   <Filt Name="IsP1Point"/>
##   <Fam Name="P1PointsFamily"/>
##   <Func Name="P1Point" Arg="complex"/>
##   <Func Name="P1Point" Arg="real, imag" Label="ri"/>
##   <Func Name="P1Point" Arg="string" Label="s"/>
##   <Description>
##     P1 points are complex numbers or infinity;
##     fast methods are implemented to compute with them, and to apply
##     rational maps to them.
##     <P/>
##     The first filter recognizes these objects. Next, the family they
##     belong to. The next methods create a new P1 point.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="CleanedP1Point" Arg="p, prec"/>
##   <Returns><A>p</A>, rounded towards 0/1/infinity/reals at precision <A>prec</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Var Name="P1infinity"/>
##   <Description>The north pole of the Riemann sphere.</Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1Antipode" Arg="p"/>
##   <Returns>The antipode of <A>p</A> on the Riemann sphere.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1Barycentre" Arg="points ..."/>
##   <Returns>The barycentre of its arguments (which can also be a list of P1 points).</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1Circumcentre" Arg="p, q, r"/>
##   <Returns>The centre of the smallest disk containing <A>p,q,r</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1Distance" Arg="p, q"/>
##   <Returns>The spherical distance from <A>p</A> to <A>q</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1Midpoint" Arg="p, q"/>
##   <Returns>The point between <A>p</A> to <A>q</A> (undefined if they are antipodes of each other).</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1Sphere" Arg="v"/>
##   <Returns>The P1 point corresponding to <A>v</A> in <M>\mathbb R^3</M>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="SphereP1" Arg="p"/>
##   <Returns>The coordinates in <M>\mathbb R^3</M> of <A>p</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="SphereP1Y" Arg="p"/>
##   <Returns>The Y coordinate in <M>\mathbb R^3</M> of <A>p</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="P1XRatio" Arg="p q r s"/>
##   <Returns>The cross ratio of <A>p, q, r, s</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Filt Name="IsP1Map"/>
##   <Fam Name="P1MapsFamily"/>
##   <Func Name="P1Map" Arg="p, q, r, P, Q, R"/>
##   <Func Name="P1Map" Arg="p, q, r" Label="3"/>
##   <Func Name="P1Map" Arg="p, q" Label="2"/>
##   <Description>
##     P1 maps are efficiently-coded rational maps with complex coefficients.
##     <P/>
##     The first filter recognizes these objects. Next, the family they
##     belong to. The next methods create a new P1 map. In the first case,
##     this is the Möbius transformation sending <A>p,q,r</A> to <A>P,Q,R</A>
##     respectively; in the second case, the map sending <A>p,q,r</A> to
##     <C>0,1,P1infinity</C> respectively; in the third case, the map sending
##     <A>p,q</A> to <C>0,P1infinity</C> respectively, of the form <M>(z-p)/(z-q)</M>.
##     <P/>
##     P1 maps may not be added. They can be multiplied, and this operation
##     corresponds to composition, in the topological order (<C>a*b</C> is
##     first <C>b</C>, then <C>a</C>).
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="P1Identity"/>
##   <Description>The identity Möbius transformation.</Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="CleanedP1Map" Arg="map, prec"/>
##   <Returns><A>map</A>, with coefficients rounded using <A>prec</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="CoefficientsOfP1Map" Arg="map"/>
##   <Returns>Coefficients of numerator and denominator of <A>map</A>, lowest degree first.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1MapByCoefficients" Arg="numer, denom"/>
##   <Returns>The P1 map with numerator coefficients <A>numer</A> and denominator <A>denom</A>, lowest degree first.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1Path" Arg="p q"/>
##   <Returns>The P1 map sending <C>0</C> to <A>p</A> and <C>1</C> to <A>q</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="DegreeOfP1Map" Arg="map"/>
##   <Returns>The degree of <A>map</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1Image" Arg="map, p1point"/>
##   <Returns>The image of <A>p1point</A> under <A>map</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1PreImages" Arg="map, p1point"/>
##   <Returns>The preimages of <A>p1point</A> under <A>map</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1MapCriticalPoints" Arg="map"/>
##   <Returns>The critical points of <A>map</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1MapRational" Arg="rat"/>
##   <Returns>The P1 map given by the rational function <A>rat</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="RationalP1Map" Arg="map"/>
##   <Oper Name="RationalP1Map" Arg="indeterminate, map" Label="im"/>
##   <Returns>The rational function given by P1 map <A>map</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="P1MapSL2" Arg="mat"/>
##   <Returns>The Möbius P1 map given by the 2x2 matrix <A>mat</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="SL2P1Map" Arg="map"/>
##   <Returns>The matrix of the Möbius P1 map <A>map</A>.</Returns>
## </ManSection>
## <#/GAPDoc>
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
DeclareAttribute("Argument", IS_COMPLEX);
DeclareGlobalVariable("COMPLEX_0");
DeclareGlobalVariable("COMPLEX_1");
DeclareGlobalVariable("COMPLEX_I");
DeclareGlobalVariable("COMPLEX_2IPI");
DeclareGlobalFunction("EXP_COMPLEX");
DeclareGlobalVariable("MACFLOAT_INF");
DeclareGlobalVariable("MACFLOAT_NAN");
DeclareGlobalVariable("MACFLOAT_PI");
DeclareAttribute("RealPart", IS_COMPLEX);
DeclareAttribute("ImaginaryPart", IS_COMPLEX);

DeclareCategory("IsP1Point",IsObject);
BindGlobal("P1PointsFamily", NewFamily("P1PointsFamily",IsP1Point));
BindGlobal("TYPE_P1POINT", NewType(P1PointsFamily,IsP1Point and IsDataObjectRep));
DeclareCategory("IsP1Map", IsMapping);
BindGlobal("P1MapsFamily", NewFamily("P1MapsFamily", IsP1Map));
SetFamilySource(P1MapsFamily,COMPLEX_FIELD);
SetFamilyRange(P1MapsFamily,COMPLEX_FIELD);
BindGlobal("TYPE_P1MAP", NewType(P1MapsFamily, IsP1Map and IsDataObjectRep));

DeclareGlobalFunction("P1Point");
DeclareGlobalVariable("P1infinity");
DeclareOperation("P1Map",[IsP1Point,IsP1Point]);
DeclareOperation("P1Map",[IsP1Point,IsP1Point,IsP1Point]);
DeclareOperation("P1Map",[IsP1Point,IsP1Point,IsP1Point,IsP1Point,IsP1Point,IsP1Point]);
DeclareOperation("P1Barycentre",[IsList]);
DeclareOperation("P1Barycentre",[IsP1Point]);
DeclareOperation("P1Barycentre",[IsP1Point,IsP1Point]);
DeclareOperation("P1Barycentre",[IsP1Point,IsP1Point,IsP1Point]);
DeclareAttribute("DegreeOfRationalFunction",IsRationalFunction);
DeclareAttribute("Primitive",IsRationalFunction);
DeclareGlobalFunction("P1MapRational");
DeclareGlobalFunction("RationalP1Map");
DeclareGlobalFunction("P1MapSL2");
DeclareGlobalFunction("SL2P1Map");
DeclareGlobalFunction("P1MapByCoefficients");
DeclareGlobalFunction("CoefficientsOfP1Map");
#############################################################################

#############################################################################
## <#GAPDoc Label="fpliealgebra">
## <ManSection>
##   <Filt Name="IsFpLieAlgebra"/>
##   <Description>
##     The category of Lie algebras coming from a finitely presented group.
##     They appear as the <Ref Oper="JenningsLieAlgebra" BookName="ref"/>
##     of a finitely presented group.
##
##     <P/> If <C>G</C> is an infinite, finitely presented group, then
##     the original implementation of <Ref Oper="JenningsLieAlgebra"
##     BookName="ref"/> does not return. On the other hand, the implementation
##     in <Package>FR</Package> constructs a graded object, for which
##     the graded components are computed on-demand; see
##     <Ref Oper="JenningsLieAlgebra"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="JenningsLieAlgebra" Arg="ring, fpgroup"/>
##   <Returns>The Jennings Lie algebra of <A>fpgroup</A>.</Returns>
##   <Description>
##     This method does not compute the Jennings Lie algebra <E>per se</E>;
##     it merely constructs a placeholder to contain the result.
## <Example><![CDATA[
## gap> f := FreeGroup(4);
## <free group on the generators [ f1, f2, f3, f4 ]>
## gap> surfacegp := f/[Comm(f.1,f.2)*Comm(f.3,f.4)];
## <fp group of size infinity on the generators [ f1, f2, f3, f4 ]>
## gap> j := JenningsLieAlgebra(Rationals,surfgp);
## <FP Lie algebra over Rationals>
## gap> List([1..4],Grading(j).hom_components);
## [ <vector space over Rationals, with 4 generators>,
##   <vector space over Rationals, with 5 generators>,
##   <vector space over Rationals, with 16 generators>,
##   <vector space over Rationals, with 45 generators> ]
## gap> B := Basis(Grading(j).hom_components(1));
## gap> B[1]*B[2]+B[3]*B[4];
## <zero Lie element>
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
DeclareRepresentation("IsLieFpElementRep",
        IsPositionalObjectRep and IsAttributeStoringRep,[]);
DeclareCategory("IsFpLieAlgebra",IsLieAlgebra);

DeclareHandlingByNiceBasis("IsLieFpElementSpace",
        "FR: for FP Lie algebras");
#############################################################################

#E helpers.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
