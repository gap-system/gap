#############################################################################
##
#W examples.gd                                              Laurent Bartholdi
##
#H   @(#)$Id: examples.gd,v 1.35 2011/06/13 22:54:33 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  All interesting examples of Mealy machines and groups I came through
##
#############################################################################

#############################################################################
##
#E AddingMachine(n)
#E AddingGroup(n)
##
## <#GAPDoc Label="AddingMachine">
## <ManSection>
##   <Func Name="AddingGroup" Arg="n"/>
##   <Func Name="AddingMachine" Arg="n"/>
##   <Func Name="AddingElement" Arg="n"/>
##   <Description>
##     The second function constructs the adding machine on the alphabet
##     <C>[1..n]</C>. This machine has a trivial state 1, and a non-trivial
##     state 2. It implements the operation "add 1 with carry" on sequences.
##
##     <P/> The third function constructs the Mealy element on the adding
##     machine, with initial state 2.
##
##     <P/> The first function constructs the state-closed group generated
##     by the adding machine on <C>[1..n]</C>. This group is
##     isomorphic to the <C>Integers</C>.
## <Example><![CDATA[
## gap> Display(AddingElement(3));
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   b,1
## ---+-----+-----+-----+
## Initial state: b
## gap> ActivityPerm(FRElement(AddingMachine(3),2),2);
## (1,4,7,2,5,8,3,6,9)
## gap> G := AddingGroup(3);
## <self-similar group over [ 1 .. 3 ] with 1 generator>
## gap> Size(G);
## infinity
## gap> IsRecurrentFRSemigroup(G);
## true
## gap> IsLevelTransitive(G);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="BinaryAddingGroup"/>
##   <Var Name="BinaryAddingMachine"/>
##   <Var Name="BinaryAddingElement"/>
##   <Description>
##     These are respectively the same as <C>AddingGroup(2)</C>,
##    <C>AddingMachine(2)</C> and <C>AddingElement(2)</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("AddingMachine",IsPosInt);
DeclareAttribute("AddingElement",IsPosInt);
DeclareGlobalFunction("AddingGroup");
DeclareGlobalVariable("BinaryAddingMachine");
DeclareGlobalVariable("BinaryAddingElement");
DeclareGlobalVariable("BinaryAddingGroup");
#############################################################################

#############################################################################
##
#E FiniteDepthBinaryGroup(l)
#E FinitaryBinaryGroup
#E BoundedBinaryGroup
#E PolynomialStateGrowthBinaryGroup
#E FiniteStateBinaryGroup
#E FullBinaryGroup
##
## <#GAPDoc Label="FiniteDepthBinaryGroup">
## <ManSection>
##   <Var Name="FullBinaryGroup"/>
##   <Func Name="FiniteDepthBinaryGroup" Arg="l"/>
##   <Var Name="FinitaryBinaryGroup"/>
##   <Var Name="BoundedBinaryGroup"/>
##   <Var Name="PolynomialGrowthBinaryGroup"/>
##   <Var Name="FiniteStateBinaryGroup"/>
##   <Description>
##     These are the finitary, bounded, polynomial-growth, finite-state,
##     or unrestricted groups acting on the binary tree. They are
##     respectively shortcuts for
##     <C>FullSCGroup([1..2])</C>,
##     <C>FullSCGroup([1..2],l)</C>,
##     <C>FullSCGroup([1..2],IsFinitaryFRSemigroup)</C>,
##     <C>FullSCGroup([1..2],IsBoundedFRSemigroup)</C>,
##     <C>FullSCGroup([1..2],IsPolynomialGrowthFRSemigroup)</C>,
##     and <C>FullSCGroup([1..2],IsFiniteStateFRSemigroup)</C>.
##
##     <P/> They may be used to draw random elements, or to test membership.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("FiniteDepthBinaryGroup");
DeclareGlobalVariable("FinitaryBinaryGroup");
DeclareGlobalVariable("BoundedBinaryGroup");
DeclareGlobalVariable("PolynomialGrowthBinaryGroup");
DeclareGlobalVariable("FiniteStateBinaryGroup");
DeclareGlobalVariable("FullBinaryGroup");
#############################################################################

#############################################################################
##
#E MixerMachine
#E MixerGroup
##
## <#GAPDoc Label="MixerMachine">
## <ManSection>
##   <Func Name="MixerGroup" Arg="A, B, f [g]"/>
##   <Func Name="MixerMachine" Arg="A, B, f [g]"/>
##   <Returns>A Mealy "mixer" machine/group.</Returns>
##   <Description>
##     The second function constructs a Mealy "mixer" machine <C>m</C>. This is a
##     machine determined by a permutation group <A>A</A>,
##     a finitely generated group <A>B</A>, and a matrix of homomorphisms
##     from <A>B</A> to <A>A</A>. If <A>A</A> acts on <C>[1..d]</C>, then
##     each row of <A>f</A> contains at most <M>d-1</M> homomorphisms. The optional
##     last argument is an endomorphism of <A>B</A>. If absent, it is treated
##     as the identity map on <A>B</A>.
##
##     <P/> The states of the machine are 1, followed by some elements
##     <C>a</C> of <A>A</A>, followed by as many copies of some elements
##     <C>b</C> of <A>B</A> as there are rows in <A>f</A>. The elements in <A>B</A>
##     that are taken is the smallest sublist of <A>B</A> containing its generators
##     and closed under <A>g</A>. The elements in <A>A</A> that are taken are the
##     generators of <A>A</A> and all images of all taken elements of <A>B</A> under
##     maps in <A>f</A>.
##
##     <P/> The transitions from <C>a</C> are towards 1 and the outputs are the
##     permutations in <A>A</A>. The transitions from <C>b</C> are periodically
##     given by <A>f</A>, completed by trivial elements, and finally by <M>b^g</M>;
##     the output of <C>b</C> is trivial.
##
##     <P/> This construction is described in more detail in
##     <Cite Key="MR1856923"/> and <Cite Key="MR2035113"/>.
##
##     <P/> <C>Correspondence(m)</C> is a list, with in first position the
##     subset of the states that correspond to <A>A</A>, in second position
##     the states that correspond to the first copy of <A>B</A>, etc.
##
##     <P/> The first function constructs the group generated by the
##     mixer machine. For examples
##     see <Ref Func="GrigorchukGroups"/>, <Ref Func="NeumannGroup"/>,
##     <Ref Func="GuptaSidkiGroups"/>, and <Ref Var="ZugadiSpinalGroup"/>.
## <Example><![CDATA[
## gap> grigorchukgroup := MixerGroup(Group((1,2)),Group((1,2)),
##      [[IdentityMapping(Group((1,2)))],[IdentityMapping(Group((1,2)))],[]]));
## <self-similar group over [ 1 .. 2 ] with 4 generators>
## gap> IdGroup(Group(grigorchukgroup.1,grigorchukgroup.2));
## [ 32, 18 ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("MixerMachine");
DeclareGlobalFunction("MixerGroup");
#############################################################################

#############################################################################
##
#E GrigorchukGroup
#E GrigorchukGroups
##
## <#GAPDoc Label="GrigorchukGroup">
## <ManSection>
##   <Func Name="GrigorchukMachines" Arg="omega"/>
##   <Func Name="GrigorchukGroups" Arg="omega"/>
##   <Returns>One of the Grigorchuk groups.</Returns>
##   <Description>
##     This function constructs the Grigorchuk machine or group associated
##     with the infinite sequence <A>omega</A>, which is assumed (pre)periodic;
##     <A>omega</A> is either a periodic list (see <Ref Oper="PeriodicList"/>)
##     or a plain list describing the period. Entries in the list are
##     integers in <C>[1..3]</C>.
##
##     <P/> These groups are <Ref Func="MixerGroup"/>s. The most famous
##     example is <C>GrigorchukGroups([1,2,3])</C>, which is also called
##     <Ref Var="GrigorchukGroup"/>.
##
##     <P/> These groups are all 4-generated and infinite.
##     They are described in <Cite Key="MR764305"/>.
##     <C>GrigorchukGroups([1])</C> is infinite dihedral. If <A>omega</A>
##     contains at least 2 different digits, <C>GrigorchukGroups([1])</C> has
##     intermediate word growth. If <A>omega</A>
##     contains all 3 digits, <C>GrigorchukGroups([1])</C> is torsion.
##
##     <P/> The growth of <C>GrigorchukGroups([1,2])</C> has been studied in
##     <Cite Key="MR2144977"/>.
## <Example><![CDATA[
## gap> G := GrigorchukGroups([1]);
## GrigorchukGroups([ 1 ])
## gap> Index(G,DerivedSubgroup(G)); IsAbelian(DerivedSubgroup(G));
## 4
## true
## gap> H := GrigorchukGroups([1,2]);
## GrigorchukGroups([ 1, 2 ])
## gap> Order(H.1*H.2);
## 8
## gap> Order(H.1*H.4);
## infinity
## gap> IsSubgroup(H,G);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="GrigorchukMachine"/>
##   <Var Name="GrigorchukGroup"/>
##   <Description>
##     This is Grigorchuk's first group, introduced in <Cite Key="MR565099"/>.
##     It is a 4-generated infinite torsion group, and has intermediate
##     word growth. It could have been defined as
##     <C><![CDATA[FRGroup("a=(1,2)","b=<a,c>","c=<a,d>","d=<,b>")]]></C>,
##     but is rather defined using Mealy elements.
##
##     <P/> The command <C>EpimorphismFromFpGroup(GrigorchukGroup,n)</C>
##     constructs an approximating presentation for the
##     Grigorchuk group, as proven in <Cite Key="MR819415"/>. Adding the
##     relations <C>Image(sigma&circum;(n-2),(a*d)&circum;2)</C>,
##     <C>Image(sigma&circum;(n-1),(a*b)&circum;2)</C> and
##     <C>Image(sigma&circum;(n-2),(a*c)&circum;4)</C> yields the quotient
##     acting on <M>2^n</M> points, as a finitely presented group.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="GrigorchukOverGroup"/>
##   <Description>
##     This is a group strictly containing the Grigorchuk group (see
##     <Ref Var="GrigorchukGroup"/>).
##     It also has
##     intermediate growth (see <Cite Key="MR1899368"/>, but it contains
##     elements of infinite order. It could have been defined as
##     <C><![CDATA[FRGroup("a=(1,2)","b=<a,c>","c=<,d>","d=<,b>")]]></C>,
##     but is rather defined using Mealy elements.
##
## <Example><![CDATA[
## gap> IsSubgroup(GrigorchukOverGroup,GrigorchukGroup);
## true
## gap> Order(Product(GeneratorsOfGroup(GrigorchukOverGroup)));
## infinity
## gap> GrigorchukGroup.2=GrigorchukSuperGroup.2*GrigorchukSuperGroup.3;
## true
## ]]></Example>
##
##     <P/> The command <C>EpimorphismFromFpGroup(GrigorchukOverGroup,n)</C> will
##     will construct an approximating presentation for the
##     Grigorchuk overgroup, as proven in <Cite Key="MR2009317"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="GrigorchukTwistedTwin"/>
##   <Description>
##     This is a group with same closure as the Grigorchuk group (see
##     <Ref Var="GrigorchukGroup"/>), but not isomorphic to it.
##     It could have been defined as
##     <C><![CDATA[FRGroup("a=(1,2)","x=<y,a>","y=<a,z>","z=<,x>")]]></C>,
##     but is rather defined using Mealy elements.
##
## <Example><![CDATA[
## gap> AbelianInvariants(GrigorchukTwistedTwin);
## [ 2, 2, 2, 2 ]
## gap> AbelianInvariants(GrigorchukGroup);
## [ 2, 2, 2 ]
## gap> PermGroup(GrigorchukGroup,8)=PermGroup(GrigorchukTwistedTwin,8);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("GrigorchukMachines");
DeclareGlobalFunction("GrigorchukGroups");
DeclareGlobalVariable("GrigorchukMachine");
DeclareGlobalVariable("GrigorchukGroup");
DeclareGlobalVariable("GrigorchukOverGroup");
DeclareGlobalVariable("GrigorchukTwistedTwin");
#############################################################################

#############################################################################
##
#E SunicMachine
#E SunicGroup
##
## <#GAPDoc Label="SunicMachine">
## <ManSection>
##   <Func Name="SunicGroup" Arg="phi"/>
##   <Func Name="SunicMachine" Arg="phi"/>
##   <Returns>The Sunic machine associated with the polynomial <A>phi</A>.</Returns>
##   <Description>
##     A "Sunic machine" is a special kind of <Ref Func="MixerMachine"/>, in which
##     the group <M>A</M> is a finite field <M>GF(q)</M>, the group <M>B</M> is an
##     extension <M>A[x]/(\phi)</M>, where <M>\phi</M> is a monic polynomial; there
##     is a map <M>f:B\to A</M>, given say by evaluation; and there is an endomorphism
##     of <M>g:B\to B</M> given by multiplication by <M>\phi</M>.
##
##     <P/> These groups were described in <Cite Key="MR2318546"/>. In particular,
##     the case <M>q=2</M> and <M>\phi=x^2+x+1</M> gives the original
##     <Ref Var="GrigorchukGroup"/>.
## <Example><![CDATA[
## gap> x := Indeterminate(GF(2));;
## gap> g := SunicGroup(x^2+x+1);
## SunicGroup(x^2+x+Z(2)^0)
## gap> g = GrigorchukGroup;
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("SunicMachine");
DeclareGlobalFunction("SunicGroup");
#############################################################################

#############################################################################
##
#E AleshinMachine
#E AleshinGroup
#E BabyAleshinMachine
#E BabyAleshinGroup
##
## <#GAPDoc Label="AleshinMachine">
## <ManSection>
##   <Func Name="AleshinGroups" Arg="l"/>
##   <Func Name="AleshinMachines" Arg="l"/>
##   <Returns>The Aleshin machine with <C>Length(l)</C> states.</Returns>
##   <Description>
##     This function constructs the bireversible machines introduced by
##     Aleshin in <Cite Key="MR713968"/>. The argument <A>l</A> is a
##     list of permutations, either <C>()</C> or <C>(1,2)</C>.
##     The groups that they generate are contructed as
##     <Ref Func="AleshinGroups"/>.
##
##     <P/> If <C>l=[(1,2),(1,2),()]</C>, this is <Ref Var="AleshinGroup"/>.
##     More generally, if <C>l=[(1,2,(1,2),(),...,()]</C> has odd length,
##     this is a free group of rank <C>Length(l)</C>,
##     see <Cite Key="MR2318547"/> and <Cite Key="0604328"/>.
##
##     <P/> If <C>l=[(1,2),(1,2),...]</C> has even length and contains an
##     even number of <C>()</C>'s, then this is also a free group of
##     rank <C>Length(l)</C>, see <Cite Key="0610033"/>.
##
##     <P/> If <C>l=[(),(),(1,2)]</C>, this is <Ref Var="BabyAleshinGroup"/>.
##     more generally, if <C>l=[(),(),...]</C> has even length and contains
##     an even number of <C>(1,2)</C>'s, then this is the free product of
##     <C>Length(l)</C> copies of the order-2 group.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="AleshinGroup"/>
##   <Var Name="AleshinMachine"/>
##   <Description>
##     This is the first example of non-abelian free group. It is the group
##     generated by <C>AleshinMachine([(1,2),(1,2),()])</C>.
##     It could have been defined as
##     <C><![CDATA[FRGroup("a=<b,c>(1,2)","b=<c,b>(1,2)","c=<a,a>")]]></C>,
##     but is rather defined using Mealy elements.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="BabyAleshinGroup"/>
##   <Var Name="BabyAleshinMachine"/>
##   <Description>
##     There are only two connected, transitive bireversible machines
##     on a 2-letter alphabet, with 3 generators: <C>AleshinMachine(3)</C>
##     and the baby Aleshin machine.
##
##     <P/> The group generated by this machine
##     is abstractly the free product of three <M>C_2</M>'s, see
##     <Cite Key="MR2162164" Where="1.10.3"/>. It could have been defined as
##     <C><![CDATA[FRGroup("a=<b,c>","b=<c,b>","c=<a,a>(1,2)")]]></C>,
##     but is rather defined here using Mealy elements.
## <Example><![CDATA[
## gap> K := Kernel(GroupHomomorphismByImagesNC(BabyAleshinGroup,Group((1,2)),
##                  GeneratorsOfGroup(BabyAleshinGroup),[(1,2),(1,2),(1,2)]));
## <self-similar group over [ 1 .. 2 ] with 4 generators>
## gap> Index(BabyAleshinGroup,K);
## 2
## gap> IsSubgroup(AleshinGroup,K);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="SidkiFreeGroup"/>
##   <Description>
##     This is a group suggested by Sidki as an example of a non-abelian
##     state-closed free group. Nothing is known about that group: whether
##     it is free as conjectured; whether generator <A>a</A> is state-closed,
##     etc. It is defined as
##     <C>FRGroup("a=&lt;a&circum;2,a&circum;t&gt;","t=&lt;,t&gt;(1,2)")]]></C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("AleshinMachines");
DeclareGlobalFunction("AleshinGroups");
DeclareGlobalVariable("AleshinMachine");
DeclareGlobalVariable("AleshinGroup");
DeclareGlobalVariable("BabyAleshinMachine");
DeclareGlobalVariable("BabyAleshinGroup");
DeclareGlobalVariable("SidkiFreeGroup");
#############################################################################

#############################################################################
##
#E BrunnerSidkiVieiraMachine
#E BrunnerSidkiVieiraGroup
##
## <#GAPDoc Label="BrunnerSidkiVieiraMachine">
## <ManSection>
##   <Var Name="BrunnerSidkiVieiraGroup"/>
##   <Var Name="BrunnerSidkiVieiraMachine"/>
##   <Description>
##     This machine is the sum of two adding machines, one in standard
##     form and one conjugated by the element <C>d</C> described below.
##
##     The group that it generates is described in <Cite Key="MR1656573"/>.
##     It could have been defined as
##     <C>FRGroup("tau=&lt;,tau&gt;(1,2)","mu=&lt;,mu&circum;-1&gt;(1,2)")</C>,
##     but is rather defined using Mealy elements.
## <Example><![CDATA[
## gap> V := FRGroup("d=<e,e>(1,2)","e=<d,d>");
## <self-similar group over [ 1 .. 2 ] with 2 generators>
## gap> Elements(V);
## [ <2|identity ...>, <2|e>, <2|d>, <2|e*d> ]
## gap> AssignGeneratorVariables(BrunnerSidkiVieiraGroup);
## #I  Assigned the global variables [ "tau", "mu", "" ]
## gap> List(V,x->tau^x)=[tau,mu,mu^-1,tau^-1];
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalVariable("BrunnerSidkiVieiraMachine");
DeclareGlobalVariable("BrunnerSidkiVieiraGroup");
#############################################################################

#############################################################################
##
#E GuptaSidkiMachines
#E GuptaSidkiGroups
#E GuptaSidkiGroup
#E FabrykowskiGuptaGroup
#E ZugadiSpinalGroup
##
## <#GAPDoc Label="GuptaSidkiMachines">
## <ManSection>
##   <Func Name="GuptaSidkiGroups" Arg="n"/>
##   <Func Name="GeneralizedGuptaSidkiGroups" Arg="n"/>
##   <Func Name="GuptaSidkiMachines" Arg="n"/>
##   <Returns>The Gupta-Sidki group/machine on an <A>n</A>-letter alphabet.</Returns>
##   <Description>
##     This function constructs the machines introduced by Gupta
##     and Sidki in <Cite Key="MR696534"/>. They generate finitely generated
##     infinite torsion groups: the exponent of every element divides some
##     power of <A>n</A>. The
##     special case <M>n=3</M> is defined as <Ref Var="GuptaSidkiGroup"/>
##     and <Ref Var="GuptaSidkiMachine"/>.
##
##     <P/> For <M>n&gt;3</M>, there are (at least) two natural ways to
##     generalize the Gupta-Sidki construction: the original one involves
##     the recursion <C>"t=&lt;a,a&circum;-1,1,...,1,t&gt;"</C>,
##     while the second (called here `generalized') involves the
##     recursion <C>"t=&lt;a,a&circum;2,...,a&circum;-1,t&gt;"</C>.
##     A finite L-presentation for the latter is implemented. It is not
##     as computationally efficient as the L-presentation of the normal
##     closure of <C>t</C> (a subgroup of index <M>p</M>), which is an
##     ascending L-presented group. The inclusion of that subgroup may be
##     recoverd via <C>EmbeddingOfAscendingSubgroup(GuptaSidkiGroup)</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="GuptaSidkiGroup"/>
##   <Var Name="GuptaSidkiMachine"/>
##   <Description>
##     This is an infinite, 2-generated, torsion 3-group. It could have
##     been defined as <C>FRGroup("a=(1,2,3)","t=&lt;a,a&circum;-1,t&gt;")</C>,
##     but is rather defined using Mealy elements.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="NeumannGroup" Arg="P"/>
##   <Func Name="NeumannMachine" Arg="P"/>
##   <Returns>The Neumann group/machine on the permutation group <A>P</A>.</Returns>
##   <Description>
##     The first function constructs the Neumann group associated
##     with the permutation group <A>P</A>.
##     These groups were first considered in
##     <Cite Key="MR840129"/>. In particular, <C>NeumannGroup(PSL(3,2))</C>
##     is a group of non-uniform exponential growth
##     (see <Cite Key="MR1981466"/>), and <C>NeumannGroup(Group((1,2,3)))</C>
##     is <Ref Var="FabrykowskiGuptaGroup"/>.
##
##     <P/> The second function constructs the Neumann machine associated to the
##     permutation group <A>P</A>. It is a shortcut for
##     <C>MixerMachine(P,P,[[IdentityMapping(P)]])</C>.
##
##     <P/> The attribute <C>Correspondence(G)</C> is set to a list of
##     homomorphisms from <A>P</A> to the <C>A</C> and <C>B</C> copies of
##     <C>P</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="FabrykowskiGuptaGroup"/>
##   <Func Name="FabrykowskiGuptaGroups" Arg="p"/>
##   <Description>
##     This is an infinite, 2-generated group of intermediate word growth.
##     It was studied in <Cite Key="MR942349"/> and <Cite Key="MR1153150"/>.
##     It could have been defined as <C><![CDATA[FRGroup("a=(1,2,3)","t=<a,,t>")]]></C>,
##     but is rather defined using Mealy elements. It has a torsion-free
##     subgroup of index 3 and is branched.
##
##     <P/> The natural generalization, replacing 3 by <M>p</M>, is
##     constructed by the second form. It is a specific case of
##     Neumann group (see <Ref Func="NeumannGroup"/>), for which an
##     ascending L-presentation is known.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="ZugadiSpinalGroup"/>
##   <Description>
##     This is an infinite, 2-generated group, which
##     was studied in <Cite Key="MR1899368"/>. It has a torsion-free subgroup
##     of index 3, and is virtually branched but not branched.
##     It could have been defined as <C><![CDATA[FRGroup("a=(1,2,3)","t=<a,a,t>")]]></C>,
##     but is rather defined using Mealy elements.
##
##     <P/> Amaia Zugadi computed its Hausdorff dimension to be <M>1/2</M>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("GuptaSidkiMachines");
DeclareGlobalFunction("GuptaSidkiGroups");
DeclareGlobalFunction("GeneralizedGuptaSidkiGroups");
DeclareGlobalVariable("GuptaSidkiMachine");
DeclareGlobalVariable("GuptaSidkiGroup");
DeclareGlobalFunction("NeumannMachine");
DeclareGlobalFunction("NeumannGroup");
DeclareGlobalVariable("FabrykowskiGuptaGroup");
DeclareGlobalFunction("FabrykowskiGuptaGroups");
DeclareGlobalVariable("ZugadiSpinalGroup");
#############################################################################

#############################################################################
##
#E HanoiMachine
#E HanoiGroup
#E GuptaSidkiGroup
#E FabrykowskiGuptaGroup
##
## <#GAPDoc Label="OtherGroups">
## <ManSection>
##   <Func Name="HanoiGroup" Arg="n"/>
##   <Returns>The Hanoi group on an <A>n</A> pegs.</Returns>
##   <Description>
##     This function constructs the Hanoi group on <A>n</A> pegs.
##     Generators of the group correspond to moving a peg, and tree
##     vertices correspond to peg configurations. This group is studied
##     in <Cite Key="MR2217913"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="DahmaniGroup"/>
##   <Description>
##     This is an example of a non-contracting weakly branched group. It was
##     first studied in <Cite Key="MR2140091"/>. It could have been defined as
##     <C><![CDATA[FRGroup("a=<c,a>(1,2)","b=<b,a>(1,2)","c=<b,c>")]]></C>,
##     but is rather defined using Mealy elements.
##
##     <P/> It has relators <M>abc</M>, <M>[a^2c,[a,c]]</M>,
##     <M>[cab,a^{-1}c^{-1}ab]</M> and <M>[ac^2,c^{-1}b^{-1}c^2]</M>
##     among others.
##
##     <P/> It admits an endomorphism on its derived subgroup. Indeed
##     <C>FRElement(1,Comm(a,b))=Comm(c&circum;-1,b/a)</C>,
##     <C>FRElement(1,Comm(a,c))=Comm(a/b,c)</C>,
##     <C>FRElement(1,Comm(b,c))=Comm(c,(a/b)&circum;c)</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="MamaghaniGroup"/>
##   <Description>
##      This group was studied in <Cite Key="MR2139928"/>. It is fractal,
##      but not contracting. It could have been defined as
##      <C>FRGroup("a=&lt;,b&gt;(1,2)","b=&lt;a,c&gt;","c=&lt;a,a&circum;-1&gt;(1,2)")]]></C>,
##      but is rather defined using Mealy elements.
##
##      It partially admits branching on its subgroup
##      <C>Subgroup(G,[a&circum;2,(a&circum;2)&circum;b,(a&circum;2)&circum;c])</C>,
##      and, setting <C>x=Comm(a&circum;2,b)</C>, on
##      <C>Subgroup(G,[x,x&circum;a,x&circum;b,x&circum;(b*a),x&circum;(b/a)])</C>.
##      One has <C>FRElement(1,x)=(x&circum;-1)&circum;b/x</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="WeierstrassGroup"/>
##   <Description>
##     This is the iterated monodromy group associated with the
##     Weierstrass <M>\wp</M>-function.
##
##     <P/> Some relators in the group: <M>(atbt)^4</M>,
##     <M>((atbt)(bt)^4n)^4</M>, <M>((atbt)^2(bt)^4n)^2</M>.
##
##     <P/> Set <M>x=[a,t]</M>, <M>y=[b,t]</M>, <M>z=[c,t]</M>, and
##     <M>w=[x,y]</M>. Then <M>G'=\langle x,y,z\rangle</M> of index 8, and
##     <M>\gamma_3=\langle[\{x,y,z\},\{a,b,c\}]\rangle</M> of index 32, and
##     <M>\gamma_4=G''=\langle w\rangle^G</M>, of index 256, and
##     <M>G''&gt;(G'')^4</M> since <M>[[t^a,t],[t^b,t]]=(w,1,1,1)</M>.
##
##     <P/> The Schreier graph is obtained in the complex plane as the image
##     of a <M>2^n\times 2^n</M> lattice in the torus, via Weierstrass's
##     <M>\wp</M>-function.
##
##     <P/> The element <M>at</M> has infinite order.
##
##     <P/> <M>[c,t,b][b,t,c][a,t,c][c,t,a]</M> has order 2, and belongs
##     to <M>G''</M>; so there exist elements of arbitrary large finite order
##     in the group.
##
##     <!--<P/> Its Lie algebra has polynomial growth.-->
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("HanoiGroup");
DeclareGlobalVariable("DahmaniGroup");
DeclareGlobalVariable("MamaghaniGroup");
DeclareGlobalVariable("WeierstrassGroup");
#############################################################################

#############################################################################
##
#E FRAffineGroup
#E CayleyMachine
#E CayleyGroup
##
## <#GAPDoc Label="FRAffineGroup">
## <ManSection>
##   <Oper Name="FRAffineGroup" Arg="d, R, u [transversal]"/>
##   <Returns>The <A>d</A>-dimensional affine group over <A>R</A>.</Returns>
##   <Description>
##     This function constructs a new FR group <C>G</C>, which is finite-index
##     subgroup of the <A>d</A>-dimensional affine group over
##     <M>R_u</M>, the local ring over <A>R</A> in which all
##     non-multiples of <A>u</A> are invertible.
##
##     Since no generators of <C>G</C> are known, <C>G</C> is in fact returned
##     as a full SC group; only its attribute <C>Correspondence(G)</C>,
##     which is a homomorphism from <M>GL_{d+1}(R_u)</M> to <C>G</C>,
##     is relevant.
##
##     <P/> The affine group can also be described as a subgroup of
##     <M>GL_{d+1}(R_u)</M>, consisting of those matrices <M>M</M> with
##     <M>M_{i,d+1}=0</M> and <M>M_{d+1,d+1}=1</M>. The finite-index
##     subgroup is defined by the conditions <M>u|M_{i,j}</M> for all
##     <M>j&lt;i</M>.
##
##     <P/> The only valid arguments are <C>R=Integers</C> and
##     <C>R=PolynomialRing(S)</C> for a finite ring <C>S</C>.
##     The alphabet of the affine group is <M>R/RuR</M>; an explicit
##     transversal of <M>RuR</M> be specified as last argument.
##
##     <P/> The following examples construct the "Baumslag-Solitar group"
##     <M>\mathbb Z[\frac12]\rtimes_2\mathbb Z</M> first introduced in
##     <Cite Key="MR0142635"/>, the "lamplighter group"
##     <M>(\mathbb Z/2)\wr\mathbb Z</M>, and a 2-dimensional affine group.
##     Note that the lamplighter group may also be defined via
##     <Ref Func="CayleyGroup"/>.
## <Example><![CDATA[
## gap> A := FRAffineGroup(1,Integers,3);
## <self-similar group over [ 1 .. 3 ]>
## gap> f := Correspondence(A);
## MappingByFunction( ( Integers^
## [ 2, 2 ] ), <self-similar group over [ 1 .. 3 ]>, function( mat ) ... end )
## gap> BaumslagSolitar := Group([[2,0],[0,1]]^f,[[1,0],[1,1]]^f);
## <self-similar group over [ 1 .. 3 ] with 2 generators>
## gap> BaumslagSolitar.2^BaumslagSolitar.1=BaumslagSolitar.2^2;
## true
## gap> R := PolynomialRing(GF(2));;
## gap> A := FRAffineGroup(1,R,R.1);;
## gap> f := Correspondence(A);;
## gap> Lamplighter := Group(([[1+R.1,0],[0,1]]*One(R))^f,([[1,0],[1,1]]*One(R))^f);
## <self-similar group over [ 1 .. 2 ] with 2 generators>
## gap> Lamplighter = CayleyGroup(Group((1,2)));
## true
## gap> StructureDescription(Group(Lamplighter.2,Lamplighter.2^Lamplighter.1));
## "C2 x C2"
## gap> ForAll([1..10],i->IsOne(Comm(Lamplighter.2,Lamplighter.2^(Lamplighter.1^i))));
## true
## gap> A := FRAffineGroup(2,Integers,2);;
## gap> f := Correspondence(A);;
## gap> a := [[1,4,0],[2,3,0],[1,0,1]];
## [ [ 1, 4, 0 ], [ 2, 3, 0 ], [ 1, 0, 1 ] ]
## gap> b := [[1,2,0],[4,3,0],[0,1,1]];
## [ [ 1, 2, 0 ], [ 4, 3, 0 ], [ 0, 1, 1 ] ]
## gap> Display(b^f);
##     |   1      2
## ----+------+------+
##   a |  b,1    c,2
##   b |  d,2    e,1
##   c |  a,2    f,1
## ...
##  bh | cb,1   be,2
##  ca | bd,1   bf,2
##  cb | ae,2   bh,1
## ----+------+------+
## Initial state:  a
## gap> a^f*b^f=(a*b)^f;
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="CayleyGroup" Arg="G"/>
##   <Func Name="CayleyMachine" Arg="G"/>
##   <Meth Name="LamplighterGroup" Arg="IsFRGroup, G"/>
##   <Returns>The Cayley machine/group of the group <A>G</A>.</Returns>
##   <Description>
##     The <E>Cayley machine</E> of a group <A>G</A> is a machine with
##     alphabet and stateset equal to <A>G</A>, and with output and
##     transition functions given by multiplication in the group, in the
##     order <C>state*letter</C>.
##
##     <P/> The second function constructs a new FR group <C>CG</C>, which acts on
##     <C>[1..Size(G)]</C>. Its generators are in
##     bijection with the elements of <A>G</A>, and have as output the
##     corresponding permutation of <A>G</A> induced by right multiplication,
##     and as transitions all elements of <A>G</A>; see
##     <Ref Func="CayleyMachine"/>.
##     This construction was introduced in <Cite Key="MR2197829"/>.
##
##     <P/> If <A>G</A> is an abelian group, then <C>CG</C> is
##     the wreath product <M>G\wr\mathbb Z</M>; it is created by the
##     constructor <C>LamplighterGroup(IsFRGroup,G)</C>.
##
##     <P/> The attribute <C>Correspondence(CG)</C> is a list. Its
##     first entry is a homomorphism from <A>G</A> into <C>CG</C>. Its
##     second entry is the generator of <C>CG</C> that has trivial output.
##     <C>CG</C> is generated <C>Correspondence(CG)[2]</C> and the image
##     of <C>Correspondence(CG)[1]</C>.
##
##     <P/> In the example below, recall the definition of <C>Lamplighter</C>
##     in the example of <Ref Oper="FRAffineGroup"/>.
## <Example><![CDATA[
## gap> L := CayleyGroup(Group((1,2)));
## CayleyGroup(Group( [ (1,2) ] ))
## gap> L=LamplighterGroup(IsFRGroup,CyclicGroup(2));
## true
## gap> (1,2)^Correspondence(L)[1];
## <Mealy element on alphabet [ 1, 2 ] with 2 states, initial state 1>
## gap> IsFinitaryFRElement(last); Display(last2);
## true
##    |  1     2
## ---+-----+-----+
##  a | b,2   b,1
##  b | b,1   b,2
## ---+-----+-----+
## Initial state: a
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("FRAffineGroup",[IsPosInt,IsRing,IsRingElement]);
DeclareOperation("FRAffineGroup",[IsPosInt,IsRing,IsRingElement,IsCollection]);
DeclareGlobalFunction("CayleyMachine");
DeclareGlobalFunction("CayleyGroup");
DeclareConstructor("LamplighterGroup",[IsFRGroup,IsGroup]);
#############################################################################

#############################################################################
##
#E BinaryKneadingGroup
#E BasilicaGroup
##
## <#GAPDoc Label="BinaryKneadingGroup">
## <ManSection>
##   <Func Name="BinaryKneadingGroup" Arg="angle/ks"/>
##   <Func Name="BinaryKneadingMachine" Arg="angle/ks"/>
##   <Returns>The [machine generating the] iterated monodromy group of a quadratic polynomial.</Returns>
##   <Description>
##     The first function constructs a Mealy machine whose state closure is
##     the binary kneading group.
##
##     <P/> The second function constructs a new FR group <C>G</C>,
##     which is the iterated monodromy group of a quadratic polynomial,
##     either specified by its angle or by its kneading sequence(s).
##
##     <P/> If the argument is a (rational) angle, the attribute
##     <C>Correspondence(G)</C> is a function returning, for any rational,
##     the corresponding generator of <C>G</C>.
##
##     <P/> If there is one argument, which is a list or a string, it is
##     treated as the kneading sequence of a periodic (superattracting)
##     polynomial. The sequence is implicity assumed to end by '*'.
##     The attribute <C>Correspondence(G)</C> is a list of the generators of
##     <C>G</C>.
##
##     <P/> If there are two arguments, which are lists or strings, they are
##     treated as the preperiod and period of the kneading sequence of a
##     preperiodic polynomial. The last symbol of the arguments must differ.
##     The attribute <C>Correspondence(G)</C> is a pair of lists of
##     generators; <C>Correspondence(G)[1]</C> is the preperiod, and
##     <C>Correspondence(G)[2]</C> is the period. The attribute
##     <C>KneadingSequence(G)</C> returns the kneading sequence, as a pair
##     of strings representing preperiod and period respectively.
##
##     <P/> As particular examples, <C>BinaryKneadingMachine()</C> is the
##     adding machine; <C>BinaryKneadingGroup()</C> is the
##     adding machine; and <C>BinaryKneadingGroup("1")</C> is
##     <Ref Var="BasilicaGroup"/>.
## <Example><![CDATA[
## gap> BinaryKneadingGroup()=AddingGroup(2);
## true
## gap> BinaryKneadingGroup(1/3)=BasilicaGroup;
## true
## gap> g := BinaryKneadingGroup([0,1],[0]);
## BinaryKneadingGroup("01","0")
## gap> ForAll(Correspondence(g)[1],IsFinitaryFRElement);
## true
## gap> ForAll(Correspondence(g)[2],IsFinitaryFRElement);
## false
## gap> ForAll(Correspondence(g)[2],IsBoundedFRElement);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="BasilicaGroup"/>
##   <Description>
##     The <E>Basilica group</E>. This is a shortcut for
##     <C>BinaryKneadingGroup("1")</C>. It is the first-discovered amenable
##     group that is not subexponentially amenable,
##     see <Cite Key="MR2176547"/> and <Cite Key="MR1902367"/>.
## <Example><![CDATA[
## gap> IsBoundedFRSemigroup(BasilicaGroup);
## true
## gap> pi := EpimorphismFromFreeGroup(BasilicaGroup); F := Source(pi);;
## [ x1, x2 ] -> [ a, b ]
## gap> sigma := GroupHomomorphismByImages(F,F,[F.1,F.2],[F.2,F.1^2]);
## [ x1, x2 ] -> [ x2, x1^2 ]
## gap> ForAll([0..10],i->IsOne(Comm(F.2,F.2^F.1)^(sigma^i*pi)));
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="FornaessSibonyGroup"/>
##   <Description>
##     The <E>Fornaess-Sibony group</E>. This group was studied by
##     Nekrashevych in <Cite Key="0811.2777"/>. It is the iterated
##     monodromy group of the endomorphism of <M>\mathbb CP^2</M>
##     defined by <M>(z,p)\mapsto((1-2z/p)^2,(1-2/p)^2)</M>.
## <Example><![CDATA[
## gap> Size(NucleusOfFRSemigroup(FornaessSibonyGroup));
## 288
## gap> List(AdjacencyBasesWithOne(FornaessSibonyGroup),Length);
## [ 128, 128, 36, 36, 16, 16, 8 ]
## gap> p := AdjacencyPoset(FornaessSibonyGroup);
## <general mapping: <object> -> <object> >
## gap> Draw(HasseDiagramBinaryRelation(p));
## ]]></Example>
##     This produces (in a new window) the following picture:
##     <Alt Only="LaTeX"><![CDATA[
##       \includegraphics[height=3cm,keepaspectratio=true]{fornaess-sibony.jpg}
##     ]]></Alt>
##     <Alt Only="HTML"><![CDATA[
##       <img alt="Hasse Diagram" src="fornaess-sibony.jpg">
##     ]]></Alt>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="PoirierExamples" Arg="..."/>
##   <Description>
##     The examples from Poirier's paper <Cite Key="math.DS/9305207"/>.
##     See details under <Ref Oper="PolynomialIMGMachine"/>; in particular,
##     <C>PoirierExamples(1)</C> is the Douady rabbit map.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("KneadingSequence",IsFRGroup);
DeclareGlobalFunction("BinaryKneadingMachine");
DeclareGlobalFunction("BinaryKneadingGroup");
DeclareGlobalVariable("BasilicaGroup");
DeclareGlobalVariable("FornaessSibonyGroup");
DeclareGlobalFunction("PoirierExamples");
#############################################################################

#############################################################################
##
#E I2Machine
#E I2Monoid
#E I4Machine
#E I4Monoid
##
## <#GAPDoc Label="I2Machine">
## <ManSection>
##   <Var Name="I2Machine"/>
##   <Var Name="I2Monoid"/>
##   <Description>
##     The Mealy machine <M>I_2</M>, and the monoid that it generates.
##     This is the smallest
##     Mealy machine generating a monoid of intermediate word growth; see
##     <Cite Key="MR2194959"/>.
##
##     <P/> For sample calculations in this monoid see
##     <Ref Func="SCSemigroup"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="I4Machine"/>
##   <Var Name="I4Monoid"/>
##   <Description>
##     The Mealy machine generating <M>I_4</M>, and the monoid
##     that it generates. This is a very small
##     Mealy machine generating a monoid of intermediate word growth; see
##     <Cite Key="MR2394721"/>.
##
##     <P/> For sample calculations in this monoid see
##     <Ref Func="SCMonoid"/>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalVariable("I2Machine");
DeclareGlobalVariable("I2Monoid");
DeclareGlobalVariable("I4Machine");
DeclareGlobalVariable("I4Monoid");
#############################################################################

#############################################################################
##
#E PSZAlgebra
##
## <#GAPDoc Label="PSZAlgebra">
## <ManSection>
##   <Func Name="PSZAlgebra" Arg="k [,m]"/>
##   <Description>
##     This function creates an associative algebra <C>A</C>, over
##     the field <A>k</A> of positive characteristic, generated by
##     <A>m</A> derivations <C>d0,...,d(m-1),v</C>. If the argument <A>m</A>
##     is absent, it is taken to be <C>2</C>.
##
##     <P/> This algebra has polynomial growth, and is not nilpotent.
##     Petrogradsky showed in <Cite Key="MR2293788"/> that
##     the Lie subalgebra of <C>PSZAlgebra(GF(2))</C> generated by
##     <M>v,[u,v]</M> is nil; this result was generalized by
##     Shestakov and Zelmanov in <Cite Key="MR2390328"/> to arbitrary <A>k</A>
##     and <M>m=2</M>.
##
##     <P/> This ring is <M>\mathbb Z^m</M>-graded;
##     the attribute <C>Grading</C> is set. It is graded nil <Cite Key="PSZ"/>.
## <Example><![CDATA[
## gap> a := PSZAlgebra(2);
## PSZAlgebra(GF(2))
## gap> Nillity(a.1); Nillity(a.2);
## 2
## 4
## gap> IsNilElement(LieBracket(a.1,a.2));
## true
## gap> DecompositionOfFRElement(LieBracket(a.1,a.2))=DiagonalMat([a.2,a.2]);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="GrigorchukThinnedAlgebra" Arg="k"/>
##   <Description>
##     This function creates the associative envelope <C>A</C>, over
##     the field <A>k</A>, of Grigorchuk's group <Ref Var="GrigorchukGroup"/>.
##
##     <P/> <A>k</A> may be a field or an prime representing the prime
##     field <C>GF(k)</C>. In characteristic 2, this ring is graded, and
##     the attribute <C>Grading</C> is set.
##
##     <P/> For more information on the structure of this thinned algebra,
##     see <Cite Key="MR2254535"/>.
## <Example><![CDATA[
## gap> R := GrigorchukThinnedAlgebra(2);
## <self-similar algebra-with-one on alphabet GF(2)^2 with 4 generators, of dimension infinity>
## gap> GrigorchukGroup.1^Embedding(GrigorchukGroup,R)=R.1;
## true
## gap> Nillity(R.2+R.1);
## 16
## gap> x := 1+R.1+R.2+(R.1-1)*(R.4-1); # x has infinite order
## <Linear element on alphabet GF(2)^2 with 5-dimensional stateset>
## gap> Inverse(x);
## <Linear element on alphabet GF(2)^2 with 9-dimensional stateset>
## gap> Grading(R).hom_components(4);
## <vector space of dimension 6 over GF(2)>
## gap> Random(last);
## <Linear element on alphabet GF(2)^2 with 6-dimensional stateset>
## gap> Nillity(last);
## 4
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="GuptaSidkiThinnedAlgebra" Arg="k"/>
##   <Description>
##     This function creates the associative envelope <C>A</C>, over
##     the field <A>k</A>, of Gupta-Sidki's group <Ref Var="GuptaSidkiGroup"/>.
##
##     <P/> <A>k</A> may be a field or an prime representing the prime
##     field <C>GF(k)</C>.
##
##     <P/> For more information on the structure of this thinned algebra,
##     see <Cite Key="MR1423285"/>.
## <Example><![CDATA[
## gap> R := GuptaSidkiThinnedAlgebra(3);
## <self-similar algebra-with-one on alphabet GF(3)^3 with 4 generators>
## gap> Order(R.1);
## 3
## gap> R.1*R.3;
## <Identity linear element on alphabet GF(3)^3>
## gap> IsOne(R.2*R.4);
## true
## gap> x := 1+R.2*(1+R.1+R.3); # a non-invertible element
## <Linear element on alphabet GF(3)^3 with 5-dimensional stateset>
## gap> Inverse(x);
## #I  InverseOp: extending to depth 3
## #I  InverseOp: extending to depth 4
## #I  InverseOp: extending to depth 5
## #I  InverseOp: extending to depth 6
## Error, user interrupt in
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="GrigorchukLieAlgebra" Arg="k"/>
##   <Func Name="GuptaSidkiLieAlgebra" Arg="k"/>
##   <Description>
##     Two more examples of self-similar Lie algebras; see
##     <Cite Key="1003.1125"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="SidkiFreeAlgebra" Arg="k"/>
##   <Description>
##     This is an example of a free 2-generated associative ring over
##     the <M>\mathbb Z</M>, defined by self-similar matrices. It is due
##     to S. Sidki. The argument is a field on which to construct the algebra.
##     The recursion is <C>s=[[1,0],[0,2*s]]</C> and
##     <C>t=[[0,2*s],[0,2*t]]</C>.
## <Example><![CDATA[
## gap> R := SidkiFreeAlgebra(Rationals);
## <self-similar algebra-with-one on alphabet Rationals^2 with 2 generators>
## gap> V := VectorSpace(Rationals,[R.1,R.2]);
## <vector space over Rationals, with 2 generators>
## gap> P := [V];; for i in [1..3] do Add(P,ProductSpace(P[i],V)); od;
## gap> List(P,Dimension);
## [ 2, 4, 8, 16 ]
## gap> R := SidkiFreeAlgebra(GF(3));
## <self-similar algebra-with-one on alphabet GF(3)^2 with 2 generators>
## gap> V := VectorSpace(GF(3),[R.1,R.2]);;
## gap> P := [V];; for i in [1..3] do Add(P,ProductSpace(P[i],V)); od;
## gap> List(P,Dimension);
## [ 2, 4, 7, 12 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="SidkiMonomialAlgebra" Arg="k"/>
##   <Description>
##     This is an example of a self-similar algebra that does not come from
##     a semigroup; it is due to S. Sidki.
##     The argument is a field on which to construct the algebra.
##     The recursion is <C>s=[[0,0],[1,0]]</C> and
##     <C>t=[[0,t],[0,s]]</C>. Sidki shows that this algebra, like the
##     Grigorchuk thinned algebra in characteristic 2 (see <Ref
##     Func="GrigorchukThinnedAlgebra"/>), admits a monomial presentation,
##     and in particular is a graded ring.
## <Example><![CDATA[
## gap> R := SidkiMonomialAlgebra(Rationals);
## <self-similar algebra-with-one on alphabet Rationals^2 with 2 generators>
## gap> m := FreeSemigroup("s","t");;
## gap> lambda := MagmaEndomorphismByImagesNC(m,[m.2,m.1*m.2]);;
## gap> u := [m.1^2];; for i in [1..3] do u[2*i] := m.2*u[2*i-1]^lambda; u[2*i+1] := u[2*i]^lambda; od;
## gap> u; # first relations
## [ s^2, t^3, s*t*s*t*s*t, t^2*s*t^2*s*t^2*s*t,
##   s*t*s*t^2*s*t*s*t^2*s*t*s*t^2*s*t,
##   t^2*s*t^2*s*t*s*t^2*s*t^2*s*t*s*t^2*s*t^2*s*t*s*t^2*s*t,
##   s*t*s*t^2*s*t*s*t^2*s*t^2*s*t*s*t^2*s*t*s*t^2*s*t^2*s*t*s*t^2*s*t*s*t^2*s*t^2*s*t*s*t^2*s*t ]
## gap> pi := MagmaHomomorphismByImagesNC(m,R,[R.1,R.2]);;
## gap> Image(pi,u);
## [ <Zero linear element on alphabet Rationals^2> ]
## gap> # growth given by fibonacci numbers
## gap> List([0..6],Grading(R).hom_components);
## [ <vector space over Rationals, with 1 generators>, <vector space over Rationals, with 2 generators>,
##   <vector space of dimension 3 over Rationals>, <vector space of dimension 4 over Rationals>,
##   <vector space of dimension 5 over Rationals>, <vector space of dimension 7 over Rationals>,
##   <vector space of dimension 8 over Rationals> ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("PSZAlgebra");
DeclareGlobalFunction("GrigorchukThinnedAlgebra");
DeclareGlobalFunction("GuptaSidkiThinnedAlgebra");
DeclareGlobalFunction("GrigorchukLieAlgebra");
DeclareGlobalFunction("GuptaSidkiLieAlgebra");
DeclareGlobalFunction("SidkiFreeAlgebra");
DeclareGlobalFunction("SidkiMonomialAlgebra");
#############################################################################

#E examples.gd. . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
