#############################################################################
##
#W img.gd                                                   Laurent Bartholdi
##
#H   @(#)$Id: img.gd,v 1.27 2009/10/06 17:13:31 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  Iterated monodromy groups
##
#############################################################################

#############################################################################
##
#M IMGMachine
##
## <#GAPDoc Label="IMGMachine">
## <ManSection>
##   <Oper Name="AsIMGMachine" Arg="m[,w]" Label="FR machine"/>
##   <Returns>An IMG FR machine.</Returns>
##   <Description>
##     This function creates a new IMG FR machine, starting from a group
##     FR machine <A>m</A>. If a state <C>w</C> is specified, and that
##     state defines the trivial FR element, then it is used
##     as <Ref Attr="IMGRelator"/>; if the state <C>w</C> is non-trivial, then
##     a new generator <C>f</C> is added to <A>m</A>, equal to the
##     inverse of <C>w</C>; and the IMG relator is chosen to be <C>w*f</C>.
##     Finally, if no relator is specified, and the product (in some ordering)
##     of the generators is trivial, then that product is used as IMG
##     relator. In other cases, the method returns <K>fail</K>.
##
##     <P/> Note that IMG elements and FR elements are compared differently
##     (see the example below); namely, an FR element is trivial precisely
##     when it acts trivially on sequences. An IMG element is trivial
##     precisely when a finite number of applications of free cancellation,
##     the IMG relator, and the decomposition map, result in trivial elements
##     of the underlying free group.
##
##     <P/> A standard FR machine can be recovered from an IMG FR machine
##     by <Ref Oper="AsGroupFRMachine"/>, <Ref Oper="AsMonoidFRMachine"/>,
##     and <Ref Oper="AsSemigroupFRMachine"/>.
## <Example><![CDATA[
## gap> m := UnderlyingFRMachine(BasilicaGroup);
## <Mealy machine on alphabet [ 1 .. 2 ] with 3 states>
## gap> g := AsGroupFRMachine(m);
## <FR machine with alphabet [ 1 .. 2 ] on Group( [ f1, f2 ] )>
## gap> AsIMGMachine(g,Product(GeneratorsOfFRMachine(g)));
## <FR machine with alphabet [ 1 .. 2 ] on Group( [ f1, f2, t ] )/[ f1*f2*t ]>
## gap> Display(last);
##  G  |              1         2
## ----+-----------------+---------+
##  f1 |          <id>,2      f2,1
##  f2 |          <id>,1      f1,2
##   t | f2^-1*f1*f2*t,2   f1^-1,1
## ----+-----------------+---------+
## Relator: f1*f2*t
## gap> g := AsGroupFRMachine(GuptaSidkiMachine);
## <FR machine with alphabet [ 1 .. 3 ] on Group( [ f1, f2 ] )>
## gap> m := AsIMGMachine(g,GeneratorsOfFRMachine(g)[1]);
## <FR machine with alphabet [ 1 .. 3 ] on Group( [ f1, f2, t ] )/[ f1*t ]>
## gap> x := FRElement(g,2)^3; IsOne(x);
## <3|identity ...>
## true
## gap> x := FRElement(m,2)^3; IsOne(x);
## <3#f2^3>
## false
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="IMGRelator" Arg="m"/>
##   <Returns>The relator of the IMG FR machine.</Returns>
##   <Description>
##     This attribute stores the product of generators that is trivial.
##     In essence, it records an ordering of the generators whose
##     product is trivial in the punctured sphere's fundamental group.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("IMGRelator",IsGroupFRMachine);
DeclareSynonym("IsIMGMachine",IsGroupFRMachine and HasIMGRelator);
DeclareAttribute("AsIMGMachine",IsFRMachine);
DeclareOperation("AsIMGMachine",[IsFRMachine,IsWord]);

DeclareCategory("IsIMGElement",IsGroupFRElement);
DeclareCategoryCollections("IsIMGElement");
DeclareAttribute("AsIMGElement",IsGroupFRElement);
#############################################################################

#############################################################################
##
#M PolynomialMachine
##
## <#GAPDoc Label="PolynomialFRMachine">
## <ManSection>
##   <Prop Name="IsKneadingMachine" Arg="m"/>
##   <Prop Name="IsPlanarKneadingMachine" Arg="m"/>
##   <Returns>Whether <A>m</A> is a (planar) kneading machine.</Returns>
##   <Description>
##     A <E>kneading machine</E> is a special kind of Mealy machine, used
##     to describe postcritically finite complex polynomials. It is a
##     machine such that its set of permutations is "treelike" (see
##     <Cite Key="MR2162164" Where="§6.7"/>) and such that each non-trivial
##     state occurs exactly once among the outputs.
##
##     <P/> Furthermore, this set of permutations is <E>treelike</E> if
##     there exists an ordering of the states that their product in that
##     order <M>t</M> is an adding machine; i.e. such that <M>t</M>'s
##     activity is a full cycle, and the product of its states along that
##     cycle is conjugate to <M>t</M>. This element <M>t</M> represents the
##     Carathéodory loop around infinity.
## <Example><![CDATA[
## gap> M := BinaryKneadingMachine("0");
## BinaryKneadingMachine("0*")
## gap> Display(M);
##    |  1     2
## ---+-----+-----+
##  a | c,2   b,1
##  b | a,1   c,2
##  c | c,1   c,2
## ---+-----+-----+
## gap> IsPlanarKneadingMachine(M);
## true
## gap> IsPlanarKneadingMachine(GrigorchukMachine);
## false
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AsPolynomialFRMachine" Arg="m [,adder]"/>
##   <Oper Name="AsPolynomialIMGMachine" Arg="m [,adder [,relator]]"/>
##   <Returns>A polynomial FR machine.</Returns>
##   <Description>
##     The first function creates a new polynomial FR machine, starting from
##     a group or Mealy machine. A <E>polynomial</E> machine is one that
##     has a distinguished adding element, <Ref Attr="AddingElement"/>.
##
##     <P/> If the argument is a Mealy machine, it must be planar (see
##     <Ref Prop="IsPlanarKneadingMachine"/>). If the argument is a group
##     machine, its permutations must be treelike, and its outputs must be
##     such that, up to conjugation, each non-trivial state appears
##     exactly once as the product along all cycles of all states.
##
##     <P/> If a second argument <A>adder</A> is supplied, it is checked to
##     represent an adding element, and is used as such.
##
##     <P/> The second function creates a new polynomial IMG machine, i.e.
##     a polynomial FR machine with an extra relation among the generators.
##     the optional second argument may be an adder (if <A>m</A> is an IMG
##     machine) or a relator (if <A>m</A> is a polynomial FR machine). Finally,
##     if <A>m</A> is a group FR machine, two arguments, an adder and a relator,
##     may be specified.
##
##     <P/> A machine without the extra polynomial / IMG information may be
##     recovered using <Ref Oper="AsGroupFRMachine"/>.
## <Example><![CDATA[
## gap> M := PolynomialIMGMachine(2,[1/7],[]);; SetName(StateSet(M),"F"); M;
## <FR machine with alphabet [ 1, 2 ] and adder f4 on F/[ f4*f3*f2*f1 ]>
## gap> Mi := AsIMGMachine(M);
## <FR machine with alphabet [ 1, 2 ] on F/[ f4*f3*f2*f1 ]>
## gap> Mp := AsPolynomialFRMachine(M);
## <FR machine with alphabet [ 1, 2 ] and adder f4 on F>
## gap> Mg := AsGroupFRMachine(M);
## <FR machine with alphabet [ 1, 2 ] on F>
## gap>
## gap> AsPolynomialIMGMachine(Mg);
## <FR machine with alphabet [ 1, 2 ] and adder f4 on F/[ f4*f3*f2*f1 ]>
## gap> AsPolynomialIMGMachine(Mi);
## <FR machine with alphabet [ 1, 2 ] and adder f4 on F/[ f4*f3*f2*f1 ]>
## gap> AsPolynomialIMGMachine(Mp);
## <FR machine with alphabet [ 1, 2 ] and adder f4 on F/[ f4*f3*f2*f1 ]>
## gap> AsIMGMachine(Mg);
## <FR machine with alphabet [ 1, 2 ] on F4/[ f1*f4*f3*f2 ]>
## gap> AsPolynomialFRMachine(Mg);
##<FR machine with alphabet [ 1, 2 ] and adder f4 on F4>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="AddingElement" Arg="m" Label="FR machine"/>
##   <Returns>The relator of the IMG FR machine.</Returns>
##   <Description>
##     This attribute stores the product of generators that is an
##     adding machine.
##     In essence, it records an ordering of the generators whose
##     product corresponds to the Carathéodory loop around infinity.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareProperty("IsKneadingMachine",IsFRMachine);
DeclareProperty("IsPlanarKneadingMachine",IsFRMachine);
InstallTrueMethod(IsBoundedFRMachine,IsKneadingMachine);
InstallTrueMethod(IsLevelTransitive,IsKneadingMachine);

DeclareAttribute("AddingElement",IsGroupFRMachine);
DeclareSynonym("IsPolynomialFRMachine",IsGroupFRMachine and HasAddingElement);
DeclareAttribute("AsPolynomialFRMachine",IsFRMachine);
DeclareOperation("AsPolynomialFRMachine",[IsFRMachine,IsWord]);

DeclareAttribute("AsPolynomialIMGMachine",IsFRMachine);
DeclareOperation("AsPolynomialIMGMachine",[IsFRMachine,IsWord]);
DeclareOperation("AsPolynomialIMGMachine",[IsFRMachine,IsWord,IsWord]);
DeclareSynonym("IsPolynomialIMGMachine",IsIMGMachine and IsPolynomialFRMachine);
#############################################################################

#############################################################################
##
#M Operations
##
## <#GAPDoc Label="IMGOperations">
## <ManSection>
##   <Oper Name="PolynomialFRMachine" Arg="d,per,pre"/>
##   <Oper Name="PolynomialIMGMachine" Arg="d,per,pre[,formal]"/>
##   <Oper Name="PolynomialMealyMachine" Arg="d,per,pre"/>
##   <Returns>An IMG FR machine.</Returns>
##   <Description>
##     This function creates a group, IMG or Mealy machine that describes
##     a topological polynomial. The polynomial is described symbolically
##     in the language of <E>external angles</E>. For more details, see
##     <Cite Key="MR762431"/> and <Cite Key="MR812271"/> (in the quadratic
##      case), <Cite Key="MR1149891"/> (in the preperiodic case), and
##     <Cite Key="math.DS/9305207"/> (in the general case).
##
##     <P/> <A>d</A> is the degree of the polynomial. <A>per</A> and
##     <A>pre</A> are lists of angles or preangles. In what follows,
##     angles are rational numbers, considered modulo 1.  Each entry in
##     <A>per</A> or <A>pre</A> is either a rational (interpreted as an
##     angle), or a list of angles <M>[a_1,\ldots,a_i]</M> such that
##     <M>da_1=\ldots=da_i</M>. The angles in <A>per</A> are angles landing
##     at the root of a Fatou component, and the angles in <A>pre</A> land
##     on the Julia set.
##
##     <P/> Note that, for IMG machines, the last generator of the machine
##     produced is an adding machine, representing a loop going
##     counterclockwise around infinity (in the compactification of
##     <M>\mathbb C</M> by a disk, this loop goes <E>clockwise</E> around
##     that disk).
##
##     <P/> In constructing a polynomial IMG machine, one may specify a
##     boolean flag <A>formal</A>, which defaults to <K>true</K>. In
##     a <E>formal</E> recursion, distinct angles give distinct generators;
##     while in a non-formal recursion, distinct angles, which land at the
##     same point in the Julia set, give a single generator. The simplest
##     example where this occurs is angle <M>5/12</M> in the quadratic
##     family, in which angles <M>1/3</M> and <M>2/3</M> land at the same
##     point -- see the example below.
##
##     <P/> The attribute <C>Correspondence(m)</C> records the angles
##     landing on the generators: <C>Correspondence(m)[i]</C> is a list
##     <C>[a,s]</C> where <M>a</M> is an angle landing on generator <C>i</C>
##     and <M>s</M> is <K>"Julia"</K> or <K>"Fatou"</K>.
##
##     <P/> The inverse operation, reconstructing the angles from the IMG
##     machine, is <Ref Oper="ExternalAngles"/>.
## <Example><![CDATA[
## gap> PolynomialIMGMachine(2,[0],[]); # the adding machine
## <FR machine with alphabet [ 1 .. 2 ] on Group( [ f1, f2 ] )/[ f2*f1 ]>
## gap> Display(last);
##  G  |     1        2
## ----+--------+--------+
##  f1 | <id>,2     f1,1
##  f2 |   f2,2   <id>,1
## ----+--------+--------+
## Relator: f2*f1
## gap> Display(PolynomialIMGMachine(2,[1/3],[])); # the Basilica
##  G  |      1         2
## ----+---------+---------+
##  f1 | f1^-1,2   f2*f1,1
##  f2 |    f1,1    <id>,2
##  f3 |    f3,2    <id>,1
## ----+---------+---------+
## Relator: f3*f2*f1
## gap> Display(PolynomialIMGMachine(2,[],[1/6])); # z^2+I
##  G  |            1         2
## ----+---------------+---------+
##  f1 | f1^-1*f2^-1,2   f2*f1,1
##  f2 |          f1,1      f3,2
##  f3 |          f2,1    <id>,2
##  f4 |          f4,2    <id>,1
## ----+---------------+---------+
## Relator: f4*f3*f2*f1
## gap> PolynomialIMGMachine(2,[],[5/12]);
## gap> PolynomialIMGMachine(2,[],[5/12]);
## <FR machine with alphabet [ 1, 2 ] and adder f5 on Group( [ f1, f2, f3, f4, f5 ] )/[ f5*f4*f3*f2*f1 ]>
## gap> Correspondence(last);
## [ [ 1/3, "Julia" ], [ 5/12, "Julia" ], [ 2/3, "Julia" ], [ 5/6, "Julia" ] ]
## gap> PolynomialIMGMachine(2,[],[5/12],false);
## <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>
## gap> Correspondence(last);
## [ [ [ 1/3, 2/3 ], "Julia" ], [ [ 5/12 ], "Julia" ], [ [ 5/6 ], "Julia" ] ]
## ]]></Example>
##     The following construct the examples in Poirier's paper:
## <Listing><![CDATA[
## PoirierExamples := function(arg)
##     if arg=[1] then
##         return PolynomialIMGMachine(2,[1/7],[]);
##     elif arg=[2] then
##         return PolynomialIMGMachine(2,[],[1/2]);
##     elif arg=[3,1] then
##         return PolynomialIMGMachine(2,[],[5/12]);
##     elif arg=[3,2] then
##         return PolynomialIMGMachine(2,[],[7/12]);
##     elif arg=[4,1] then
##         return PolynomialIMGMachine(3,[[3/4,1/12],[1/4,7/12]],[]);
##     elif arg=[4,2] then
##         return PolynomialIMGMachine(3,[[7/8,5/24],[5/8,7/24]],[]);
##     elif arg=[4,3] then
##         return PolynomialIMGMachine(3,[[1/8,19/24],[3/8,17/24]],[]);
##     elif arg=[5] then
##         return PolynomialIMGMachine(3,[[3/4,1/12],[3/8,17/24]],[]);
##     elif arg=[6,1] then
##         return PolynomialIMGMachine(4,[],[[1/4,3/4],[1/16,13/16],[5/16,9/16]]);
##     elif arg=[6,2] then
##         return PolynomialIMGMachine(4,[],[[1/4,3/4],[3/16,15/16],[7/16,11/16]]);
##     elif arg=[7] then
##         return PolynomialIMGMachine(5,[[0,4/5],[1/5,2/5,3/5]],[[1/5,4/5]]);
##     elif arg=[9,1] then
##         return PolynomialIMGMachine(3,[[0,1/3],[5/9,8/9]],[]);
##     elif arg=[9,2] then
##         return PolynomialIMGMachine(3,[[0,1/3]],[[5/9,8/9]]);
##     else
##         Error("Unknown Poirier example ",arg);
##     fi;
## end;
## ]]></Listing>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="ExternalAngles" Arg="m [,full]"/>
##   <Returns>A <C>[degree,fatou,julia]</C> description of <A>m</A>.</Returns>
##   <Description>
##     This operation is the inverse of <Ref Oper="PolynomialIMGMachine"/>:
##     it computes a choice of angles, describing landing rays on Fatou/Julia
##     critical points.
##
##     <P/> If the second argument <A>full</A> is present and equals
##     <K>true</K>, the function returns a record with fields
##     <C>degree,fatou,julia,angle,twist</C>. The last two are: for each
##     generator of <A>m</A> the angle of a ray landing on it; and an
##     automorphism of <A>m</A>'s stateset that puts the machine into a
##     reasonably simple form.
##
##     <P/> If there does not exist a complex realization, namely if the
##     machine is obstructed, then this command returns an obstruction, as
##     a record. The field <C>obstruction</C> is a string, describing the
##     obstruction: either "Dehn twist", with fields <C>twist</C> a
##     free group automorphism turning about the twist and <C>machine</C> a
##     simplified machine on which this twist acts; or "Topological" if
##     there does not even exist a topological polynomial satisfying the
##     given recursion; or "Collisions", with a field <C>pairs</C> indicating
##     which pairs of generators land at the same external ray.
## <Example><![CDATA[
## gap> r := PolynomialIMGMachine(2,[1/7],[]);
## <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>
## gap> F := StateSet(r);; SetName(F,"F");
## gap> ExternalAngles(r);
## [ 2, [ [ 1/7, 9/14 ] ], [  ] ] # actually returns the angle 2/7
## gap> ExternalAngles(r,true);
## rec( degree := 2, twist := IdentityMapping( F ), fatou := [ [ 1/7, 9/14 ] ],
##      julia := [  ], angle := [ 4/7, 1/7, 2/7, 0 ] )
## gap> twist := GroupHomomorphismByImages(F,F,GeneratorsOfGroup(F),[F.1^(F.2*F.1),F.2^F.1,F.3,F.4]);
## [ f1, f2, f3, f4 ] -> [ f1^-1*f2^-1*f1*f2*f1, f1^-1*f2*f1, f3, f4 ]
## gap> List([-10..10],i->2*ExternalAngles(r*twist^i)[2][1][1]);
## [ 4/7, 4/7, 4/7, 4/7, 4/7, 4/7, 4/7, 2/7, 4/7, 4/7,
##   2/7, 5/7, 4/7, 4/7, 5/7, 4/7, 4/7, 4/7, 4/7, 4/7, 4/7 ]
## gap> r := PolynomialIMGMachine(2,[],[1/6]);;
## gap> F := StateSet(r);;
## gap> twist := GroupHomomorphismByImages(F,F,GeneratorsOfGroup(F),[F.1,F.2^(F.3*F.2),F.3^F.2,F.4]);;
## gap> ExternalAngles(r);
## [ 2, [  ], [ [ 1/12, 7/12 ] ] ]
## gap> ExternalAngles(r*twist);
## [ 2, [  ], [ [ 5/12, 11/12 ] ] ]
## gap> ExternalAngles(r*twist^2);
## rec( machine := <FR machine with alphabet [ 1, 2 ] on F/[ f4*f1*f2*f3 ]>,
##      twist := [ f1, f2, f3, f4 ] -> [ f1, f3*f2*f3^-1, f3*f2*f3*f2^-1*f3^-1, f4 ],
##      obstruction := "Dehn twist" )
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="Lift" Arg="m [,shift]"/>
##   <Returns>The lift of a polynomial FR machine.</Returns>
##   <Description>
##     This operation constructs, for a polynomial FR machine representing
##     a point in Teichmüller space, the image of this point under Thurston's
##     <M>\sigma</M> map.
##
##     <P/> Iteration of this method is at the basis of <Ref
##     Oper="ExternalAngles"/>. It is currently only implemented for
##     polynomial maps.
## <Example><![CDATA[
## gap> r := PolynomialIMGMachine(2,[],[1/6]);;
## gap> F := StateSet(r);;
## gap> twist := GroupHomomorphismByImages(F,F,GeneratorsOfGroup(F),[F.1,F.2^(F.3*F.2),F.3^F.2,F.4]);
## [ f1, f2, f3, f4 ] -> [ f1, f2^-1*f3^-1*f2*f3*f2, f2^-1*f3*f2, f4 ]
## gap> r=Lift(r);
## true
## gap> r2 := [r*twist^2];; # an obstructed map
## gap> for i in [1..5] do Add(r2,Lift(r2[i])); od;
## gap> r2[4]=r2[6];
## true
## gap> Display(r2[4]);
##  G  |      1               2
## ----+---------+---------------+
##  f1 | f1^-1,2            f1,1
##  f2 |    f1,1            f3,2
##  f3 |  <id>,1   f3*f2*f3^-1,2
##  f4 |    f4,2          <id>,1
## ----+---------+---------------+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="AsGroupFRMachine" Arg="f" Label="endomorphism"/>
##   <Attr Name="AsMonoidFRMachine" Arg="f" Label="endomorphism"/>
##   <Attr Name="AsSemigroupFRMachine" Arg="f" Label="endomorphism"/>
##   <Returns>An FR machine.</Returns>
##   <Description>
##     This function creates an FR machine on a 1-letter alphabet,
##     that represents the endomorphism <A>f</A>. It is specially useful
##     when combined with products of machines; indeed the usual product
##     of machines corresponds to composition of endomorphisms.
## <Example><![CDATA[
## gap> f := FreeGroup(2);;
## gap> h := GroupHomomorphismByImages(f,f,[f.1,f.2],[f.2,f.1*f.2]);
## [ f1, f2 ] -> [ f2, f1*f2 ]
## gap> m := AsGroupFRMachine(h);
## <FR machine with alphabet [ 1 ] on Group( [ f1, f2 ] )>
## gap> mm := TensorProduct(m,m);
## <FR machine with alphabet [ 1 ] on Group( [ f1, f2 ] )>
## gap> Display(mm);
##  G  |         1
## ----+------------+
##  f1 |    f1*f2,1
##  f2 | f2*f1*f2,1
## ----+------------+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="NormalizedPolynomialFRMachine" Arg="m"/>
##   <Attr Name="NormalizedPolynomialIMGMachine" Arg="m"/>
##   <Returns>A polynomial FR machine.</Returns>
##   <Description>
##     This function returns a new FR machine, in which the adding element
##     has been put into a standard form <M>t=[t,1,\dots,1]s</M>, where
##     <M>s</M> is the long cycle <M>i\mapsto i-1</M>.
##
##     <P/> For the first command, the machine returned is an FR machine;
##     for the second, it is an IMG machine.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Mating" Arg="m1,m2 [,formal]"/>
##   <Returns>An IMG FR machine.</Returns>
##   <Description>
##     This function "mates" two polynomial IMG machines.
##
##     <P/> The mating is defined as follows: one removes a disc around
##     the adding machine in <A>m1</A> and <A>m2</A>; one applies complex
##     conjugation to <A>m2</A>; and one glues the hollowed spheres along
##     their boundary circle.
##
##     <P/> The optional argument <A>formal</A>, which defaults to
##     <K>true</K>, specifies whether a <E>formal</E> mating should be done;
##     in a non-formal mating, generators of <A>m1</A> and <A>m2</A> which
##     have identical angle should be treated as a single generator. A
##     non-formal mating is of course possible only if the machines are
##     realizable -- see <Ref Oper="ExternalAngles"/>.
##
##     <P/> The attribute <C>Correspondence</C> is a pair of homomorphisms,
##     from the statesets of <A>m1,m2</A> respectively to the stateset of the
##     mating.
## <Example><![CDATA[
## gap> # the Tan-Shishikura examples
## gap> z := Indeterminate(COMPLEX_FIELD);;
## gap> a := ComplexRootsOfUnivariatePolynomial((z-1)*(3*z^2-2*z^3)+1);;
## gap> c := ComplexRootsOfUnivariatePolynomial((z^3+z)^3+z);;
## gap> am := List(a,a->IMGMachine((a-1)*(3*z^2-2*z^3)+1));;
## gap> cm := List(c,c->IMGMachine(z^3+c));;
## gap> m := ListX(am,cm,Mating);;
## gap> # m[2] is realizable
## gap> RationalFunction(m[2]);
## ((1.66408+I*0.668485)*z^3+(-2.59772+I*0.627498)*z^2+(-1.80694-I*0.833718)*z
##   +(1.14397-I*1.38991))/((-1.52357-I*1.27895)*z^3+(2.95502+I*0.234926)*z^2
##   +(1.61715+I*1.50244)*z+1)
## gap> # m[6] is obstructed
## gap> RationalFunction(m[6]);
## rec( matrix := [ [ 1/2, 1 ], [ 1/2, 0 ] ], machine := <FR machine with alphabet
##     [ 1, 2, 3 ] on Group( [ f1, f2, f3, g1, g2, g3 ] )/[ f2*f3*f1*g1*g3*g2 ]>,
##   obstruction := [ f1^-1*f3^-1*f2^-1*f1*f2*f3*f1*g2^-1*g3^-1*f1^-1*f3^-1*f2^-1,
##       f2*f3*f1*f2*f3*f1*g2*f1^-1*f3^-1*f2^-1*f1^-1*f3^-1 ],
##   spider := <spider on <triangulation with 8 vertices, 36 edges and
##     12 faces> marked by GroupHomomorphismByImages( Group( [ f1, f2, f3, g1, g2, g3
##      ] ), Group( [ f1, f2, f3, f4, f5 ] ), [ f1, f2, f3, g1, g2, g3 ],
##     [ f1*f4*f2^-1*f1*f4^-1*f1^-1, f1*f4*f2^-1*f1*f4*f5^-1*f1^-1*f2*f4^-1*f1^-1,
##       f1*f4*f2^-1*f1*f5*f1^-1*f2*f4^-1*f1^-1, f2*f4^-1*f1^-1*f2*f1*f4*f2^-1,
##       f2*f4^-1*f3*f2^-1, f2*f4^-1*f1^-1*f3^-1*f4*f2^-1 ] )> )
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("AsGroupFRMachine",IsGroupHomomorphism);
DeclareAttribute("AsMonoidFRMachine",IsMagmaHomomorphism);
DeclareAttribute("AsSemigroupFRMachine",IsMagmaHomomorphism);

DeclareOperation("PolynomialMealyMachine",[IsPosInt,IsList,IsList]);
DeclareOperation("PolynomialFRMachine",[IsPosInt,IsList,IsList]);
DeclareOperation("PolynomialIMGMachine",[IsPosInt,IsList,IsList]);
DeclareOperation("PolynomialIMGMachine",[IsPosInt,IsList,IsList,IsBool]);

DeclareAttribute("NormalizedPolynomialFRMachine",IsPolynomialFRMachine);
DeclareAttribute("NormalizedPolynomialIMGMachine",IsPolynomialFRMachine);
DeclareAttribute("Lift",IsPolynomialFRMachine);
DeclareOperation("Lift",[IsPolynomialFRMachine,IsObject]);
DeclareAttribute("ExternalAngles",IsPolynomialFRMachine);
DeclareOperation("ExternalAngles",[IsPolynomialFRMachine,IsBool]);
DeclareOperation("Mating",[IsPolynomialFRMachine,IsPolynomialFRMachine]);
DeclareOperation("Mating",[IsPolynomialFRMachine,IsPolynomialFRMachine,IsBool]);
#############################################################################

#############################################################################
##
#M ChangeFRMachineBasis
##
## <#GAPDoc Label="ChangeFRMachineBasis">
## <ManSection>
##   <Attr Name="ChangeFRMachineBasis" Arg="m[,l]"/>
##   <Returns>An equivalent FR machine, in a new basis.</Returns>
##   <Description>
##     This function constructs a new group FR machine, given a group
##     FR machine <A>m</A> and a list of states <A>l</A> (as elements of
##     the free object <C>StateSet(m)</C>).
##
##     <P/> The new machine
##     has the following transitions: if alphabet letter <C>a</C> is mapped
##     to <C>b</C> by state <C>s</C> in <A>m</A>, leading to state <C>t</C>,
##     then in the new machine the new state is <C>l[a]&circum;-1*t*l[b]</C>.
##
##     <P/> The group generated by the new machine is isomorphic to the
##     group generated by <A>m</A>. This command amounts to a change of
##     basis of the associated bimodule (see <Cite Key="MR2162164"
##     Where="Section 2.2"/>). It amounts to conjugation by the automorphism
##     <C>c=FRElement("c",[l[1]*c,...,l[n]*c],[()],1)</C>.
##
##     <P/> If the second argument is absent, this command attempts to
##     choose one that makes many entries of the recursion trivial.
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);;
## gap> Display(n);
##  G   |     1         2
## -----+--------+---------+
##  tau | <id>,2     tau,1
##   mu | <id>,2   mu^-1,1
## -----+--------+---------+
## gap> nt := ChangeFRMachineBasis(n,GeneratorsOfFRMachine(n){[1,1]});;
## gap> Display(nt);
##  G   |     1                    2
## -----+--------+--------------------+
##  tau | <id>,2                tau,1
##   mu | <id>,2   tau^-1*mu^-1*tau,1
## -----+--------+--------------------+
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("ChangeFRMachineBasis", [IsFRMachine, IsCollection]);
DeclareOperation("ChangeFRMachineBasis", [IsFRMachine]);
#############################################################################

#############################################################################
##
#E Triangulations
##
## <#GAPDoc Label="Triangulations">
## <ManSection>
##   <Oper Name="DelaunayTriangulation" Arg="points"/>
##   <Returns>A Delaunay triangulation of the sphere.</Returns>
##   <Description>
##     If <A>points</A> is a list of points on the unit sphere, represented
##     by their 3D coordinates, this function creates a triangulation of
##     the sphere with these points as vertices. This triangulation is
##     such that the angles are as equilateral as possible.
##
##     <P/> This triangulation is a recursive collection of records, one
##     for each vertex, oriented edge or face. Each such object has a
##     <C>pos</C> component giving its coordinates; and an <C>index</C>
##     component identifying it uniquely. Additionally, vertices and
##     faces have a <C>n</C> component which lists their neighbours in CCW
##     order, and edges have <C>from,to,left,right,reverse</C> components.
##
##     <P/> If all points are aligned on a great circle, or if all points
##     are in a hemisphere, some points are added so as to make the
##     triangulation simplicial with all edges of length <M>&lt;\pi</M>.
##     These vertices additionally have a <C>fake</C> component set to
##     <K>true</K>.
##
##     <P/> A triangulation may be plotted with <C>Draw</C>; this requires
##     <Package>appletviewer</Package> to be installed. The command
##     <C>Draw(t:detach)</C> detaches the subprocess after it is started.
##
##     <P/> This command makes essential use of Renka's package
##     "Algorithm 772" (<Cite Key="MR1672176"/>), which must have been compiled
##     before &GAP; was run.
##
## <Example><![CDATA[
## gap> octagon := Concatenation(IdentityMat(3),-IdentityMat(3))*MACFLOAT_1;
## gap> dt := DelaunayTriangulation(octagon);
## <triangulation with 6 vertices, 24 edges and 8 faces>
## gap> dt!.v;
## [ <vertex 1>, <vertex 2>, <vertex 3>, <vertex 4>, <vertex 5>, <vertex 6> ]
## gap> last[1].n;
## [ <edge 17>, <edge 1>, <edge 2>, <edge 11> ]
## gap> last[1].from;
## <vertex 1>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="LocateInTriangulation" Arg="t,[seed,]point"/>
##   <Returns>The face in <A>t</A> containing <A>point</A>.</Returns>
##   <Description>
##     This command locates the face in <A>t</A> that contains <A>point</A>;
##     or, if <A>point</A> lies on an edge or a vertex, it returns that
##     edge or vertex.
##
##     <P/> The optional second argument specifies a starting vertex,
##     edge, face, or vertex index from which to start the search. Its only
##     effect is to speed up the algorithm.
## <Example><![CDATA[
## gap> cube := Tuples([-1,1],3)/Sqrt(Float(3));;
## gap> dt := DelaunayTriangulation(cube);
## <triangulation with 8 vertices, 36 edges and 12 faces>
## gap> LocateInTriangulation(dt,dt!.v[1].pos);
## <vertex 1>
## gap> LocateInTriangulation(dt,[3/5,0,4/5]*MACFLOAT_1);
## <face 9>
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsSphereTriangulation", IsObject);
TYPE_TRIANGULATION := NewType(FamilyObj(rec()), IsSphereTriangulation);

DeclareOperation("DelaunayTriangulation", [IsList]);
DeclareOperation("LocateInTriangulation", [IsSphereTriangulation,IsList]);
DeclareOperation("LocateInTriangulation", [IsSphereTriangulation,IsObject,IsList]);
DeclareOperation("Draw", [IsSphereTriangulation]);
#############################################################################

#############################################################################
##
#E Spiders
##
## <#GAPDoc Label="Spiders">
## <ManSection>
##   <Oper Name="RationalFunction" Arg="[z,] m"/>
##   <Returns>A rational function.</Returns>
##   <Description>
##   This command runs a modification of Hubbard and Schleicher's
##   "spider algorithm" <Cite Key="MR1315537"/> on the IMG FR machine <A>m</A>.
##   It either returns a rational function <C>f</C> whose associated machine
##   is <A>m</A>; or a record describing the Thurston obstruction to
##   realizability of <C>f</C>.
##
##   <P/> This obstruction record <C>r</C> contains a list <C>r.multicurve</C>
##   of conjugacy classes in <C>StateSet(m)</C>, which represent
##   short multicurves; a matrix <C>r.mat</C>, and a spider <C>r.spider</C>
##   on which the obstruction was discovered.
##
##   <P/> If a rational function is returned, it has preset attributes
##   <C>Spider(f)</C> and <C>IMGMachine(f)</C> which is a simplified
##   version of <A>m</A>. This rational function is also normalized so that
##   its post-critical points have barycenter=0 and has two post-critical
##   points at infinity and on the positive real axis.
##   Furthermore, if <A>m</A> is polynomial-like, then the returned map is
##   a polynomial.
## <Example><![CDATA[
## gap> m := PolynomialIMGMachine(2,[1/3],[]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3 ] )/[ f3*f2*f1 ]>
## gap> RationalFunction(m);
## 0.866025*z^2+(-1)*z+(-0.288675)
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FRMachine" Arg="f" Label="rational function"/>
##   <Oper Name="IMGMachine" Arg="f" Label="rational function"/>
##   <Returns>An IMG FR machine.</Returns>
##   <Description>
##   This function computes a triangulation of the sphere, on the
##   post-critical set of <A>f</A>, and lifts it through the map <A>f</A>.
##   the action of the fundamental group of the punctured sphere is
##   then read into an IMG fr machine <C>m</C>, which is returned.
##
##   <P/> This machine has a preset attribute <C>Spider(m)</C>.
##
##   <P/> An approximation of the Julia set of <A>f</A> can be computed,
##   and plotted on the spider, with the form <C>IMGMachine(f:julia)</C>
##   or <C>IMGMachine(f:julia:=gridsize)</C>.
## <Example><![CDATA[
## gap> z := Indeterminate(COMPLEX_FIELD);;
## gap> IMGMachine(z^2-1);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3 ] )/[ f2*f1*f3 ]>
## gap> Display(last);
##  G  |            1        2
## ----+---------------+--------+
##  f1 |          f2,2   <id>,1
##  f2 | f3^-1*f1*f3,1   <id>,2
##  f3 |        <id>,2     f3,1
## ----+---------------+--------+
## Relator: f2*f1*f3
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FindThurstonObstruction" Arg="list"/>
##   <Returns>A description of the obstruction corresponding to <A>list</A>, or <K>fail</K>.</Returns>
##   <Description>
##     This method accepts a list of IMG elements on the same underlying
##     machine, and treats these as representatives of conjugacy classes
##     defining (part of) a multicurve. It computes whether these
##     curves, when supplemented with their lifts under the recursion,
##     constitute a Thurston obstruction, by computing its transition matrix.
##
##     <P/> The method either returns <K>fail</K>, if there is no obstruction,
##     or a record with as fields <C>matrix,machine,obstruction</C> giving
##     respectively the transition matrix, a simplified machine, and the
##     curves that constitute a minimal obstruction.
## <Example><![CDATA[
## gap> r := PolynomialIMGMachine(2,[],[1/6]);;
## gap> F := StateSet(r);;
## gap> twist := GroupHomomorphismByImages(F,F,GeneratorsOfGroup(F),[F.1,F.2^(F.3*F.2),F.3^F.2,F.4]);;
## gap> ExternalAngles(r*twist^-1);
## rec( machine := <FR machine with alphabet [ 1, 2 ] on F/[ f4*f1*f2*f3 ]>,
##      twist := [ f1, f2, f3, f4 ] -> [ f1, f3^-1*f2*f3, f3^-1*f2^-1*f3*f2*f3, f4 ],
##      obstruction := "Dehn twist" )
## gap> FindThurstonObstruction([FRElement(last.machine,[2,3])]);
## rec( matrix := [ [ 1 ] ], machine := <FR machine with alphabet [ 1, 2 ] on F/[ f4*f1*f2*f3 ]>, obstruction := [ f1^-1*f4^-1 ] )
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsSpider", IsObject);
TYPE_SPIDER := NewType(FamilyObj(rec()), IsSpider);
DeclareOperation("Draw", [IsSpider]);
DeclareAttribute("VERTICES@", IsSpider);
DeclareAttribute("SPIDERRELATORS@", IsSpider);
DeclareAttribute("TREEBOUNDARY@", IsSpider);
DeclareAttribute("NFFUNCTION@", IsSpider);

DeclareAttribute("Spider", IsFRMachine);
DeclareAttribute("Spider", IsRationalFunction);
DeclareAttribute("IMGORDERING@", IsIMGMachine);

DeclareAttribute("RationalFunction", IsFRMachine);
DeclareOperation("RationalFunction", [IsRingElement, IsFRMachine]);
DeclareOperation("FRMachine", [IsRationalFunction]);
DeclareAttribute("IMGMachine", IsRationalFunction);

DeclareOperation("FindThurstonObstruction", [IsIMGElementCollection]);
#############################################################################

#############################################################################
##
#E DBRationalIMGGroup
##
## <#GAPDoc Label="DBRationalIMGGroup">
## <ManSection>
##   <Func Name="DBRationalIMGGroup" Arg="sequence/map"/>
##   <Returns>An IMG group from Dau's database.</Returns>
##   <Description>
##     This function returns the iterated monodromy group from a database
##     of groups associated to quadratic rational maps. This database has
##     been compiled by Dau Truong Tan <Cite Key="tan:database"/>.
##
##     <P/> When called with no arguments, this command returns the database
##     contents in raw form.
##
##     <P/> The argments can be a sequence; the first integer is the size
##     of the postcritical set, the second argument is an index for the
##     postcritical graph, and sometimes a third argument distinguishes
##     between maps with same post-critical graph.
##
##     <P/> If the argument is a rational map, the command returns the
##     IMG group of that map, assuming its canonical quadratic rational form
##     form exists in the database.
## <Example><![CDATA[
## gap> DBRationalIMGGroup(z^2-1);
## IMG((z-1)^2)
## gap> DBRationalIMGGroup(z^2+1); # not post-critically finite
## fail
## gap> DBRationalIMGGroup(4,1,1);
## IMG((z/h+1)^2|2h^3+2h^2+2h+1=0,h~-0.64)
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="PostCriticalMachine" Arg="f"/>
##   <Returns>The Mealy machine of <A>f</A>'s post-critical orbit.</Returns>
##   <Description>
##     This function constructs a Mealy machine <C>P</C> on the alphabet
##     <C>[1]</C>, which describes the post-critical set of <A>f</A>.
##     It is in fact an oriented graph with constant out-degree 1. It is
##     most conveniently passed to <Ref Oper="Draw"/>.
##
##     <P/> The attribute <C>Correspondence(P)</C> is the list of values
##     associated with the stateset of <C>P</C>.
## <Example><![CDATA[
## gap> z := Indeterminate(Rationals,"z");;
## gap> m := PostCriticalMachine(z^2);
## <Mealy machine on alphabet [ 1 ] with 2 states>
## gap> Display(m);
##    |  1
## ---+-----+
##  a | a,1
##  b | b,1
## ---+-----+
## gap> Correspondence(m);
## [ 0, infinity ]
## gap> m := PostCriticalMachine(z^2-1);; Display(m); Correspondence(m);
##    |  1
## ---+-----+
##  a | c,1
##  b | b,1
##  c | a,1
## ---+-----+
## [ -1, infinity, 0 ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("PostCriticalMachine");
DeclareGlobalFunction("DBRationalIMGGroup");
#############################################################################

#E img.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
