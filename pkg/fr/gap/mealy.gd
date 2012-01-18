#############################################################################
##
#W mealy.gd                                                 Laurent Bartholdi
##
#H   @(#)$Id: mealy.gd,v 1.39 2011/08/02 22:36:10 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file declares the category of Mealy machines and elements
##
#############################################################################

#############################################################################
##
#C IsMealyMachine . . . . . . . . . . . . . . . . . . . . . . .Mealy machines
#C IsMealyElement . . . . . . . . . . . . . Mealy machines with initial state
##
## <#GAPDoc Label="IsMealyMachine">
## <ManSection>
##   <Filt Name="IsMealyMachine" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a Mealy machine.</Returns>
##   <Description>
##     This function is the acceptor for the <E>Mealy
##     machine</E> subcategory of <E>FR machine</E>s.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Filt Name="IsMealyElement" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a Mealy element.</Returns>
##   <Description>
##     This function is the acceptor for the <E>Mealy
##     element</E> subcategory of <E>FR element</E>s.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsMealyMachine", IsFRMachine);
DeclareCategory("IsMealyElement", IsFRElement and IsAssociativeElement);
#############################################################################

#############################################################################
##
#R IsMealyMachineIntRep
#R IsMealyMachineDomainRep
##
## <#GAPDoc Label="IsMealyMachineIntRep">
## <ManSection>
##   <Filt Name="IsMealyMachineIntRep" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a Mealy machine in integer representation.</Returns>
##   <Description>
##     A Mealy machine in <E>integer</E> representation has components
##     <C>nrstates</C>, <C>transitions</C>, <C>output</C> and optionally
##     <C>initial</C>.
##
##     <P/> Its stateset is <C>[1..nrstates]</C>, its transitions is a matrix
##     with <C>transitions[s][x]</C> the transition from state <C>s</C> with
##     input <C>x</C>, its output is a list of transformations or permutations,
##     and its initial state is an integer.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Filt Name="IsMealyMachineDomainRep" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a Mealy machine in domain representation.</Returns>
##   <Description>
##     A Mealy machine in <E>domain</E> representation has components
##     <C>states</C>, <C>transitions</C>, <C>output</C> and optionally
##     <C>initial</C>.
##
##     <P/> Its states is a domain, its transitions is a function
##     with <C>transitions(s,x)</C> the transition from state <C>s</C> with
##     input <C>x</C>, its output is a function with <C>output(s,x)</C> the
##     output from input <C>x</C> in state <C>s</C>,
##     and its initial state is an elemnent of <C>states</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareRepresentation("IsMealyMachineIntRep",
        IsComponentObjectRep and IsAttributeStoringRep,
        ["nrstates","transitions","output","initial"]);

DeclareRepresentation("IsMealyMachineDomainRep",
        IsComponentObjectRep and IsAttributeStoringRep,
        ["states","transitions","output","initial"]);
############################################################################

#############################################################################
##
#O MealyMachine(Transitions, Output)
#O MealyMachine(Alphabet, Transitions, Output)
#O MealyMachine(Stateset, Alphabet, Transitions, Output)
#O MealyMachineNC(MealyFamily, Transitions, Output)
#O MealyElement(Transitions, Output, Init)
#O MealyElement(Alphabet, Transitions, Output, Init)
#O MealyElement(Stateset, Alphabet, Transitions, Output)
#O MealyElementNC(MealyFamily, Transitions, Output, Init)
#O FRElement(MealyMachine, Init)
##
## <#GAPDoc Label="MealyMachine">
## <ManSection>
##   <Oper Name="MealyMachine" Arg="[alphabet,]transitions,output" Label="[list,]listlist,list"/>
##   <Oper Name="MealyElement" Arg="[alphabet,]transitions,output,init" Label="[list,]listlist,list,int"/>
##   <Returns>A new Mealy machine/element.</Returns>
##   <Description>
##     This function constructs a new Mealy machine or element, of integer type.
##
##     <P/> <A>transitions</A> is a list of lists;
##     <C>transitions[s][x]</C> is an integer,
##     which is the state reached by the machine when started in state
##     <A>s</A> and fed input <A>x</A>.
##
##     <P/> <A>output</A> is a list; at position <A>s</A> it contains a
##     permutation, a transformation describing the activity of state
##     <A>s</A>, or a list describing the images of the transformation.
##
##     <P/> <A>alphabet</A> is an optional domain given as first argument;
##     When present, it is assumed to be a finite domain, mapped bijectively
##     to <C>[1..n]</C> by its enumerator. The indices "<C>[s]</C>" above
##     are then understood with respect to this enumeration.
##
##     <P/> <A>init</A> is an integer describing the initial state the
##     newly created Mealy element should be in.
## <Example><![CDATA[
## gap> b := MealyMachine([[3,2],[3,1],[3,3]],[(1,2),(),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> Display(b);
##    |  1     2
## ---+-----+-----+
##  a | c,2   b,1
##  b | c,1   a,2
##  c | c,1   c,2
## ---+-----+-----+
## gap> n := MealyMachine(Domain([11,12]),[[3,2],[3,1],[3,3]],[(1,2),(),()]);
## <Mealy machine on alphabet [ 11, 12 ] with states [ 1 .. 3 ]>
## gap> Display(n);
##    |  11     12
## ---+------+------+
##  a | c,12   b,11
##  b | c,11   a,12
##  c | c,11   c,12
## ---+------+------+
## ]]></Example>
## <Example><![CDATA[
## gap> tau := MealyElement([[2,1],[2,2]],[(1,2),()],1);
## <Mealy machine on alphabet [ 1, 2 ] with 2 states, initial state 1>
## gap> Display(tau);
##    |  1     2
## ---+-----+-----+
##  a | b,2   a,1
##  b | b,1   b,2
## ---+-----+-----+
## Initial state:  a
## gap> [1,1]^tau; [[1]]^tau; [[2]]^tau;
## [ 2, 1 ]
## [ 2, [ 1 ] ]
## [ [ 1 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="MealyMachine" Arg="stateset,alphabet,transitions,output" Label="domain,domain,function,function"/>
##   <Oper Name="MealyElement" Arg="stateset,alphabet,transitions,output,init" Label="domain,domain,function,function,obj"/>
##   <Returns>A new Mealy machine/element.</Returns>
##   <Description>
##     This function constructs a new Mealy machine or element, of domain type.
##
##     <P/> <A>stateset</A> and <A>alphabet</A> are domains; they are not
##     necessarily finite.
##
##     <P/> <A>transitions</A> is a function; it takes as
##     arguments a state and an alphabet letter, and returns a state.
##
##     <P/> <A>output</A> is either a function, accepting as arguments a
##     state and a letter, and returning a letter.
##
##     <P/> <A>init</A> is an element of <A>stateset</A> describing the
##     initial state the newly created Mealy element should be in.
## <Example><![CDATA[
## gap> g := Group((1,2));; n := MealyMachine(g,g,\*,\*);
## <Mealy machine on alphabet [ (), (1,2) ] with states Group( [ (1,2) ] )>
## gap> [(1,2),()]^FRElement(n,());
## [ (1,2), (1,2) ]
## gap> a := MealyElement(g,g,\*,\*,());
## <Mealy machine on alphabet [ (), (1,2) ] with states Group(
## [ (1,2) ] ), initial state ()>
## gap> [(1,2),()]^a;
## [ (1,2), (1,2) ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="MealyMachineNC" Arg="fam,transitions,output" Label="family,listlist,list"/>
##   <Oper Name="MealyElementNC" Arg="fam,transitions,output,init" Label="family,listlist,list,int"/>
##   <Returns>A new Mealy machine/element.</Returns>
##   <Description>
##     This function constructs a new Mealy machine or element, of integer type.
##     No tests are performed to check that the arguments contain values
##     within bounds, or even of the right type (beyond the simple checking
##     performed by &GAP;'s method selection algorithms). In particular,
##     Mealy elements are always assumed to be minimized, but these functions
##     leave this task to the user.
##
##     <P/> <A>fam</A> is the family to which the newly created Mealy
##     machine will belong.
##
##     <P/> <A>transitions</A> is a list of lists;
##     <C>transitions[s][x]</C> is an integer,
##     which is the state reached by the machine when started in state
##     <A>s</A> and fed input <A>x</A>.
##
##     <P/> <A>output</A> is a list; at position <A>s</A> it contains a
##     permutation or a transformation describing the activity of state
##     <A>s</A>.
##
##     <P/> <A>init</A> is an integer describing the initial state the
##     newly created Mealy element should be in.
## <Example><![CDATA[
## gap> taum := MealyMachine([[2,1],[2,2]],[(1,2),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 2 states>
## gap> tauminv := MealyMachineNC(FamilyObj(taum),[[1,2],[2,2]],[(1,2),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 2 states>
## gap> tau := MealyElement([[2,1],[2,2]],[(1,2),()],1);
## <Mealy machine on alphabet [ 1, 2 ] with 2 states, initial state 1>
## gap> tauinv := MealyElementNC(FamilyObj(n),[[1,2],[2,2]],[(1,2),()],1);
## <Mealy machine on alphabet [ 1, 2 ] with 2 states, initial state 1>
## gap> tau=FRElement(taum,1); tauinv=FRElement(tauminv,1);
## true
## true
## gap> IsOne(tau*tauinv);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("MealyMachine", [IsList, IsList]);
DeclareOperation("MealyMachine", [IsDomain, IsList, IsList]);
DeclareOperation("MealyMachine", [IsDomain, IsDomain, IsFunction, IsFunction]);
DeclareOperation("MealyMachineNC", [IsFamily, IsList, IsList]);
##
DeclareOperation("MealyElement", [IsList, IsList, IsInt]);
DeclareOperation("MealyElement", [IsDomain, IsList, IsList, IsInt]);
DeclareOperation("MealyElement", [IsDomain, IsDomain, IsFunction, IsFunction, IsObject]);
DeclareOperation("MealyElementNC", [IsFamily, IsList, IsList, IsInt]);
#############################################################################

#############################################################################
##
#O Draw . . . . . . . . . . . . . . . .displays the Mealy machine graphically
##
## <#GAPDoc Label="Draw">
## <ManSection>
##   <Oper Name="Draw" Arg="m[,filename]"/>
##   <Description>
##     This function creates a graph description of the
##     Mealy machine/element <A>m</A>. If a second argument <A>filename</A>
##     is present, the graph is saved, in <K>dot</K> format, under that
##     filename; otherwise it is converted to Postscript using the program
##     <K>dot</K> from the <Package>graphviz</Package> package, and
##     is displayed in a separate X window using the program
##     <Package>display</Package> or <Package>rsvg-view</Package>.
##     This works on UNIX systems.
##
##     <P/> It is assumed, but not checked, that <Package>graphviz</Package>
##     and <Package>display</Package>/<Package>rsvg-view</Package> are
##     properly installed on the system. The option <K>usesvg</K> requests
##     the use of <Package>rsvg-view</Package>; by default,
##     <Package>display</Package> is used.
##
##     <P/> A circle is displayed for every state of <A>m</A>, and there is
##     an edge for every transition in <A>m</A>. It has label of the form
##     <M>x/y</M>, where <M>x</M> is the input symbol and <M>y</M> is the
##     corresponding output. Edges are coloured according to the input symbol,
##     in the order "red", "blue", "green", "gray", "yellow", "cyan", "orange",
##     "purple". If <A>m</A> has an initial state, it is indicated
##     as a doubly circled state.
##
##     <P/> If <A>m</A> is a FR machine, <C>Draw</C> first attempts to convert
##     it to a Mealy machine (see <Ref Attr="AsMealyMachine" Label="FR machine"/>).
##
##     <P/> The optional value "detach" detaches the drawing subprocess after
##     it is started, in the syntax <C>Draw(M:detach)</C>.
##
##     <P/> It is assumed that <Package>graphviz</Package>
##     and <Package>display</Package>/<Package>rsvg-view</Package> are properly
##     installed on the system. The option <K>usesvg</K> requests the use of
##     <Package>rsvg-view</Package>; by default, <Package>display</Package> is used.
##
##     <P/> For example, the command
##     <C>Draw(NucleusMachine(BasilicaGroup));</C> produces (in a new
##     window) the following picture:
##     <Alt Only="LaTeX"><![CDATA[
##       \includegraphics[height=4cm,keepaspectratio=true]{basilica-nucleus.jpg}
##     ]]></Alt>
##     <Alt Only="HTML"><![CDATA[
##       <img alt="Nucleus" src="basilica-nucleus.jpg">
##     ]]></Alt>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("Draw", [IsMealyMachine]);
DeclareOperation("Draw", [IsMealyMachine, IsString]);
DeclareOperation("Draw", [IsMealyElement]);
DeclareOperation("Draw", [IsMealyElement, IsString]);
#############################################################################

#############################################################################
##
#F AllMealyMachines(Alphabet, StateSize [, Filters])
##
## <#GAPDoc Label="AllMealyMachines">
## <ManSection>
##   <Func Name="AllMealyMachines" Arg="m,n[,filters]"/>
##   <Returns>A list of all Mealy machines with specified properties.</Returns>
##   <Description>
##     This function constructs all Mealy machines with alphabet <C>[1..m]</C>,
##     stateset <C>[1..n]</C> and specified properties.
##
##     <P/> These properties are specified as additional arguments. They can
##     include <Ref Prop="IsInvertible"/>, <Ref Prop="IsReversible"/>,
##     <Ref Prop="IsBireversible"/>, and <Ref Prop="IsMinimized"/> to specify
##     that the machines should have that property.
##
##     <P/> A group/monoid/semigroup <C>p</C> may also be passed as argument;
##     this specifies the allowable vertex transformations of the machines.
##     The property <C>IsTransitive</C> requires that the state-closed
##     group/monoid/semigroup of the machine act transitively on its alphabet,
##     and <C>IsSurjective</C> requires that its
##     <Ref Attr="VertexTransformationsFRMachine"/>
##     be precisely equal to <C>p</C>.
##
##     <P/> The argument <C>EquivalenceClasses</C> returns one
##     isomorphism class of Mealy machine, under the permutations
##     of the stateset and alphabet.
##
##     <P/> The argument <C>InverseClasses</C> returns one
##     isomorphism class of Mealy machine under inversion of the stateset.
##
##     <P/> The following example constructs the two Mealy machines
##     <Ref Var="AleshinMachine"/> and <Ref Var="BabyAleshinMachine"/>:
## <Example><![CDATA[
## gap> l := AllMealyMachines(2,3,IsBireversible,IsSurjective,EquivalenceClasses);;
## gap> Length(l);
## 20
## gap> Filtered(l,x->VertexTransformationsFRMachine(DualMachine(x))=SymmetricGroup(3)
## >                     and Size(StateSet(Minimized(x)))=3);
## [ <Mealy machine on alphabet [ 1, 2 ] with 3 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 3 states> ]
##  gap> Display(last[1]);
##    |  1     2
## ---+-----+-----+
##  a | a,1   b,2
##  b | c,2   c,1
##  c | b,1   a,2
## ---+-----+-----+
## gap> Display(last[2]);
##    |  1     2
## ---+-----+-----+
##  a | a,2   b,1
##  b | c,1   c,2
##  c | b,2   a,1
## ---+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("AllMealyMachines");
#############################################################################

#############################################################################
##
#O Minimized. . . . . . . . . . . . . . . . . . . . .minimize a Mealy machine
##
## <#GAPDoc Label="MM-Minimized">
## <ManSection>
##   <Oper Name="Minimized" Arg="m" Label="Mealy machine"/>
##   <Returns>A minimized machine equivalent to <A>m</A>.</Returns>
##   <Description>
##     This function contructs the minimized Mealy machine <C>r</C>
##     corresponding to <A>m</A>, by identifying isomorphic states;
##     and, if <A>m</A> is initial, by removing inaccessible states.
##
##     <P/> If <A>m</A> is initial, the minimized automaton is such that
##     its states are numbered first by distance to the initial state, and
##     then lexicographically by input letter. (in particular, the initial
##     state is 1). This makes comparison of minimized automata efficient.
##
##     <P/> Furthermore, <C>Correspondence(r)</C> is a list describing,
##     for each (accessible) state of <A>m</A>, its corresponding state
##     in <C>r</C>; see <Ref Attr="Correspondence" Label="FR machine"/>.
## <Example><![CDATA[
## gap> GrigorchukMachine := MealyMachine([[2,3],[4,4],[2,5],[4,4],[4,1]],
##                                        [(),(1,2),(),(),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 5 states>
## gap> g2 := GrigorchukMachine^2;
## <Mealy machine on alphabet [ 1, 2 ] with 25 states>
## gap> Minimized(g2);
## <Mealy machine on alphabet [ 1, 2 ] with 11 states, minimized>
## gap> Correspondence(last);
## [ 2, 1, 4, 11, 9, 1, 2, 5, 7, 6, 4, 3, 2, 9, 11, 11, 10, 9, 2, 4, 9, 8, 11, 4, 2 ]
## gap> e := FRElement(g2,11);
## <Mealy element on alphabet [ 1, 2 ] with 25 states, initial state 11>
## gap> Minimized(e);
## <Mealy element on alphabet [ 1, 2 ] with 5 states, initial state 1, minimized>
## gap> Correspondence(last);
## [ 3, 2, 1, 4, 5, 2, 3,,,, 1,, 3, 5, 4, 4,, 5, 3, 1, 5,, 4, 1, 3 ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
#############################################################################

#############################################################################
##
#O DualMachine . . . . . . . . . . . . .construct the dual of a Mealy machine
##
## <#GAPDoc Label="DualMachine">
## <ManSection>
##   <Oper Name="DualMachine" Arg="m"/>
##   <Returns>The dual Mealy machine of <A>m</A>.</Returns>
##   <Description>
##     This function constructs the <E>dual</E> machine of <A>m</A>, i.e.
##     the machine with stateset the alphabet of <A>m</A>, with alphabet the
##     stateset of <A>m</A>, and similarly with transitions and output
##     switched.
## <Example><![CDATA[
## gap> b := MealyMachine([[3,2],[3,1],[3,3]],[(1,2),(),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> d := DualMachine(b)^4);
## <Mealy machine on alphabet [ 1, 2, 3 ] with 16 states>
## gap> Draw(d); # action on 2^4 points
## gap> DualMachine(d);
## <Mealy machine on alphabet [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
##  ] with 3 states>
## gap> Output(last,1)=Activity(FRElement(b,1),4);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsReversible" Arg="m"/>
##   <Returns><K>true</K> if <A>m</A> is a reversible Mealy machine.</Returns>
##   <Description>
##     This function tests whether <A>m</A> is <E>reversible</E>, i.e.
##     whether the <Ref Oper="DualMachine"/> of <A>m</A> is invertible.
##     See <Cite Key="MR1841119"/> for more details.
## <Example><![CDATA[
## gap> IsReversible(MealyMachine([[1,2],[2,2]],[(1,2),()]));
## false
## gap> IsReversible(MealyMachine([[1,2],[2,1]],[(),(1,2)]));
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsMinimized" Arg="m"/>
##   <Returns><K>true</K> if <A>m</A> is a minimized Mealy machine.</Returns>
##   <Description>
##     This function tests whether <A>m</A> is <E>minimized</E>, i.e.
##     whether nono of its states can be removed or coalesced. All Mealy
##     elements are automatically minimized.
## <Example><![CDATA[
## gap> AllMealyMachines(2, 2, IsBireversible,EquivalenceClasses);
## [ <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states>,
##   <Mealy machine on alphabet [ 1, 2 ] with 2 states> ]
## gap> List(last,IsMinimized);
## [ false, true, false, false, false, false, true, false ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="AlphabetInvolution" Arg="m"/>
##   <Returns>A list giving, for each alphabet letter, its inverse.</Returns>
##   <Description>
##     If <A>m</A> is a bireversible machine, it may happen that the
##     stateset of the dual of <A>m</A> (see <Ref Oper="DualMachine"/>)
##     is closed under taking inverses. If this happens, then this list
##     records the mapping from an alphabet letter of <A>m</A> to its
##     inverse.
## <Example><![CDATA[
## gap> m := GammaPQMachine(3,5);; AlphabetOfFRObject(m);
## [ 1 .. 6 ]
## gap> IsBireversible(m); AlphabetInvolution(GammaPQMachine(3,5));
## true
## [ 6, 5, 4, 3, 2, 1 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsBireversible" Arg="m"/>
##   <Returns><K>true</K> if <A>m</A> is a bireversible Mealy machine.</Returns>
##   <Description>
##     This function tests whether <A>m</A> is <E>bireversible</E>, i.e.
##     whether all eight machines obtained from <A>m</A> using
##     <Ref Oper="DualMachine"/> and <C>Inverse</C> are well-defined.
##     See <Cite Key="MR1841119"/> for more details.
## <Example><![CDATA[
## gap> IsBireversible(MealyMachine([[1,2],[2,1]],[(),(1,2)]));
## false
## gap> IsBireversible(MealyMachine([[1,1],[2,2]],[(),(1,2)]));
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("DualMachine", [IsMealyMachine]);
DeclareProperty("IsReversible", IsFRMachine);
DeclareProperty("IsBireversible", IsFRMachine);
DeclareAttribute("AlphabetInvolution", IsMealyMachine);
DeclareProperty("IsMinimized", IsFRMachine);
DeclareProperty("IsMinimized", IsFRElement);
#############################################################################

#############################################################################
##
#O StateGrowth . . . . . . . . . . . . . . count number of non-trivial states
##
## <#GAPDoc Label="StateGrowth">
## <ManSection>
##   <Oper Name="StateGrowth" Arg="m[,x]"/>
##   <Returns>The state growth of the Mealy machine or element <A>m</A>.</Returns>
##   <Description>
##     This function computes, as a rational function, the power series in
##     <A>x</A> whose coefficient of degree <M>n</M> is the number of
##     non-trivial states at level <M>n</M> of the tree.
##
##     <P/> If <A>x</A> is absent, it is assumed to be
##     <C>Indeterminate(Rationals)</C>.
##
##     <P/> If <A>m</A> is a Mealy machine, this function is computed with
##     respect to all possible starting states. If <A>m</A> is a Mealy
##     element, this
##     function is computed with respect to the initial state of <A>m</A>.
## <Example><![CDATA[
## gap> b := MealyMachine([[3,2],[3,1],[3,3]],[(1,2),(),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> StateGrowth(b,Indeterminate(Rationals));
## (2)/(-x_1+1)
## gap> StateGrowth(FRElement(b,1),Indeterminate(Rationals));
## (1)/(-x_1+1)
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Degree" Arg="m" Label="FR element"/>
##   <Oper Name="DegreeOfFRMachine" Arg="m"/>
##   <Oper Name="DegreeOfFRElement" Arg="m"/>
##   <Returns>The growth degree of the Mealy machine or element <A>m</A>.</Returns>
##   <Description>
##     This function computes the order of the pole at <M>x=1</M> of
##     <C>StateGrowth(m,x)</C>, in case its denominator is a product
##     of cyclotomics; and returns <K>infinity</K> otherwise.
##
##     <P/> This attribute of Mealy machines was studied inter alia in
##     <Cite Key="MR1774362"/>.
## <Example><![CDATA[
## gap> m := MealyMachine([[2,1],[3,2],[3,3]],[(),(1,2),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> StateGrowth(m,Indeterminate(Rationals));
## (-x_1+2)/(x_1^2-2*x_1+1)
## gap> List(StateSet(m),i->Degree(FRElement(m,i)));
## [ 2, 1, -1 ]
## gap> a := MealyMachine(Group((1,2)),Group((1,2)),\*,\*);
## <Mealy machine on alphabet [ (), (1,2) ] with states Group( [ (1,2) ] )>
## gap> Degree(a);
## infinity
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsFinitaryFRElement" Arg="e"/>
##   <Prop Name="IsFinitaryFRMachine" Arg="e"/>
##   <Returns><K>true</K> if <A>e</A> is a finitary element.</Returns>
##   <Description>
##     This function tests whether <A>e</A> is a finitary element.
##     These are by definition the elements of growth degree at most <M>0</M>.
##
##     <P/> When applied to a Mealy machine, it returns <K>true</K> if all
##     states of <A>e</A> are finitary.
## <Example><![CDATA[
## gap> m := GuptaSidkiMachines(3);; Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   a,1
##  c | a,3   a,1   a,2
##  d | b,1   c,2   d,3
## ---+-----+-----+-----+
## gap> Filtered(StateSet(m),i->IsFinitaryFRElement(FRElement(m,i)));
## [ 1, 2, 3 ]
## gap> IsFinitaryFRElement(m);
## false
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="Depth" Arg="m" Label="FR element"/>
##   <Attr Name="DepthOfFRMachine" Arg="m"/>
##   <Attr Name="DepthOfFRElement" Arg="m"/>
##   <Returns>The depth of the finitary Mealy machine or element <A>m</A>.</Returns>
##   <Description>
##     This function computes the maximal level at which the <A>m</A> has an
##     non-trivial state. In particular the identity has depth 0, and
##     FR elements acting only at the root vertex have depth 1.
##     The value <K>infinity</K> is returned if <A>m</A>
##     is not finitary (see <Ref Prop="IsFinitaryFRElement"/>).
## <Example><![CDATA[
## gap> m := MealyMachine([[2,1],[3,3],[4,4],[4,4]],[(),(),(1,2),()]);
## <Mealy machine on alphabet [ 1, 2 ] with 4 states>
## gap> DepthOfFRMachine(m);
## infinity
## gap> List(StateSet(m),i->DepthOfFRElement(FRElement(m,i)));
## [ infinity, 2, 1, 0 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsBoundedFRElement" Arg="e"/>
##   <Prop Name="IsBoundedFRMachine" Arg="e"/>
##   <Returns><K>true</K> if <A>e</A> is a finitary element.</Returns>
##   <Description>
##     This function tests whether <A>e</A> is a bounded element.
##     These are by definition the elements of growth degree at most <M>1</M>.
##
##     <P/> When applied to a Mealy machine, it returns <K>true</K> if all
##     states of <A>e</A> are bounded.
## <Example><![CDATA[
## gap> m := GuptaSidkiMachines(3);; Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   a,1
##  c | a,3   a,1   a,2
##  d | b,1   c,2   d,3
## ---+-----+-----+-----+
## gap> Filtered(StateSet(m),i->IsBoundedFRElement(FRElement(m,i)));
## [ 1, 2, 3, 4 ]
## gap> IsBoundedFRMachine(m);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsPolynomialGrowthFRElement" Arg="e"/>
##   <Prop Name="IsPolynomialGrowthFRMachine" Arg="e"/>
##   <Returns><K>true</K> if <A>e</A> is an element of polynomial growth.</Returns>
##   <Description>
##     This function tests whether <A>e</A> is a polynomial element.
##     These are by definition the elements of polynomial growth degree.
##
##     <P/> When applied to a Mealy machine, it returns <K>true</K> if all
##     states of <A>e</A> are of polynomial growth.
## <Example><![CDATA[
## gap> m := GuptaSidkiMachines(3);; Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   a,1
##  c | a,3   a,1   a,2
##  d | b,1   c,2   d,3
## ---+-----+-----+-----+
## gap> Filtered(StateSet(m),i->IsPolynomialGrowthFRElement(FRElement(m,i)));
## [ 1, 2, 3, 4 ]
## gap> IsPolynomialGrowthFRMachine(m);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("StateGrowth", [IsFRObject, IsRingElement]);
DeclareOperation("StateGrowth", [IsFRObject]);
DeclareProperty("IsFinitaryFRMachine", IsFRMachine);
DeclareProperty("IsFinitaryFRElement", IsFRElement);
DeclareAttribute("DepthOfFRMachine", IsFRMachine);
DeclareAttribute("DepthOfFRElement", IsFRElement);
DeclareAttribute("DegreeOfFRMachine", IsFRMachine);
DeclareAttribute("DegreeOfFRElement", IsFRElement);
DeclareProperty("IsBoundedFRElement", IsFRElement);
DeclareProperty("IsBoundedFRMachine", IsFRMachine);
DeclareProperty("IsPolynomialGrowthFRElement", IsFRElement);
DeclareProperty("IsPolynomialGrowthFRMachine", IsFRMachine);
DeclareOperation("Depth", [IsFRObject]);
#############################################################################

#############################################################################
##
#O GuessMealyElement
##
## <#GAPDoc Label="GuessMealyElement">
## <ManSection>
##   <Oper Name="GuessMealyElement" Arg="p,d,n"/>
##   <Returns>A Mealy element that probably has the same activity as <A>p</A>.</Returns>
##   <Description>
##     This function receives a permutation or transformation <A>p</A>,
##     a degree <A>d</A> and a level <A>n</A>, and attempts to find a
##     Mealy element on the alphabet <C>[1..d]</C> whose activity on level
##     <A>n</A> is <A>p</A>.
##
##     <P/> This function returns <C>fail</C> if it thinks that the given
##     level is not large enough to make a reasonable guess. In all cases,
##     the function is not guaranteed to return the correct Mealy machine.
## <Example><![CDATA[
## gap> GuessMealyElement(Activity(GrigorchukGroup.2,6),2,6);
## <Mealy element on alphabet [ 1, 2 ] with 5 states>
## gap> last=GrigorchukGroup.2;
## true
## gap> GuessMealyElement(Activity(GrigorchukGroup.2,5),2,5);
## fail
## gap> ComposeElement([GrigorchukGroup.2,One(GrigorchukGroup)],());
## <Mealy element on alphabet [ 1, 2 ] with 6 states>
## gap> last=GuessMealyElement(Activity(GrigorchukGroup.2,6),2,7);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("GuessMealyElement", [IsPerm, IsPosInt, IsInt]);
DeclareOperation("GuessMealyElement", [IsTrans, IsPosInt, IsInt]);
DeclareOperation("GuessMealyElement", [IsTransformation, IsPosInt, IsInt]);
#############################################################################

#############################################################################
##
#O Signatures . . . . . . . . . . . . compute product of activities on levels
##
## <#GAPDoc Label="Signatures">
## <ManSection>
##   <Oper Name="Signatures" Arg="e"/>
##   <Returns>A list describing the product of the activities on each level.</Returns>
##   <Description>
##     This function computes the product of the activities of <A>e</A> on
##     each level, and returns a periodic list describing it (see
##     <Ref Oper="PeriodicList"/>).
##
##     <P/> The entries <C>pi</C> are permutations, and their values are
##     meaningful only when projected in the abelianization of
##     <C>VertexTransformationsFRElement(e)</C>.
## <Example><![CDATA[
## gap> Signatures(GrigorchukGroup.1);
## [ (1,2), / () ]
## gap> Signatures(GrigorchukGroup.2);
## [/ (), (1,2), (1,2) ]
## gap> last[50];
## (1,2)
## gap> Signatures(AddingMachine(3)[2]);
## [/ (1,2,3) ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="VertexTransformationsFRMachine" Arg="m"/>
##   <Oper Name="VertexTransformationsFRElement" Arg="e"/>
##   <Returns>The group/monoid generated by all vertex transformations of states of <A>m</A>.</Returns>
##   <Description>
##     The first function computes the finite permutation group /
##     transformation monoid generated by all outputs of states of <A>m</A>.
##
##     <P/> The second command is a short-hand for
##     <C>VertexTransformationsFRMachine(UnderlyingFRMachine(e))</C>.
## <Example><![CDATA[
## gap> m := MealyMachine([[1,3,2],[3,2,1],[2,1,3]],[(2,3),(1,3),(1,2)]);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> VertexTransformationsFRMachine(m);
## Group([ (2,3), (1,3), (1,2) ])
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FixedRay" Arg="e" Label="FR element"/>
##   <Returns>The lexicographically first ray fixed by <A>e</A>.</Returns>
##   <Description>
##     This function computes the lexicographically first infinite
##     sequence that is fixed by the FR element <A>e</A>, and returns it as a
##     periodic list (see <Ref Oper="PeriodicList"/>). It returns <K>fail</K> if no
##     such ray exists.
## <Example><![CDATA[
## gap> m := MealyMachine([[1,3,2],[3,2,1],[2,1,3]],[(2,3),(1,3),(1,2)]);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> FixedRay(FRElement(m,1));
## [/ 1 ]
## gap> last^FRElement(m,1);
## [/ 1 ]
## gap> FixedRay(FRElement(m,[1,2]));
## fail
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsLevelTransitive" Arg="e" Label="FR element"/>
##   <Returns><K>true</K> if <A>e</A> acts transitively on each level of the tree.</Returns>
##   <Description>
##     This function tests whether <A>e</A> acts transitively on each level
##     of the tree. It is implemented only if
##     <C>VertexTransformationsFRElement(e)</C> is abelian.
##
##     <P/> This function is used as a simple test to detect whether an
##     element has infinite order: if <A>e</A> has a fixed vertex <M>v</M>
##     such that the <C>State(e,v)</C> is level-transitive, then <A>e</A>
##     has infinite order.
## <Example><![CDATA[
## gap> m := AddingMachine(3);; Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   b,1
## ---+-----+-----+-----+
## Initial state:  b
## gap> IsLevelTransitive(m);
## true
## gap> IsLevelTransitive(Product(UnderlyingFRMachine(GrigorchukOverGroup){[2..5]}));
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("Signatures", [IsFRElement]);
DeclareAttribute("VertexTransformationsFRMachine", IsFRMachine);
DeclareAttribute("VertexTransformationsFRElement", IsFRElement);
DeclareProperty("IsLevelTransitive", IsFRElement);
DeclareOperation("FixedRay",[IsFRElement]);
#############################################################################

#############################################################################
##
#O AsMealyMachine
#O AsFRMachine
#O AsMealyElement
#O AsFRElement
##
## <#GAPDoc Label="AsMealyMachine">
## <ManSection>
##   <Attr Name="AsMealyMachine" Arg="m" Label="FR machine"/>
##   <Returns>A Mealy machine isomorphic to <A>m</A>.</Returns>
##   <Description>
##     This function constructs a Mealy machine <C>r</C>, which is as
##     close as possible to the FR machine <A>m</A>. Furthermore,
##     <C>Correspondence(r)</C> is a list identifying, for every generator
##     of the stateset of <A>m</A>, a corresponding state in the
##     new Mealy machine; see <Ref Attr="Correspondence" Label="FR machine"/>.
##
##     <P/> <A>m</A> may be a group/monoid/semigroup FR machine, or a Mealy
##     machine; in which case the result is returned unchanged.
##
##     <P/> In particular, <C>FRElement(m,s)</C> and
##     <C>FRElement(AsMealyMachine(m),s)</C> return the same tree
##     automorphism, for any FR machine <C>m</C> and any state <C>s</C>.
##
##     <P/> This function is not guaranteed to return; if <A>m</A> does not
##     have finite states, then it will loop forever.
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);
## <FR machine with alphabet [ 1 .. 2 ] on Group( [ tau, mu ] )>
## gap> Display(n);
##      |     1         2
## -----+--------+---------+
##  tau | <id>,2     tau,1
##   mu | <id>,2   mu^-1,1
## -----+--------+---------+
## gap> AsMealyMachine(n);
## <Mealy machine on alphabet [ 1, 2 ] with 4 states>
## gap> Display(last);
##    |  1     2
## ---+-----+-----+
##  a | c,2   a,1
##  b | c,2   d,1
##  c | c,1   c,2
##  d | b,2   c,1
## ---+-----+-----+
## gap> Correspondence(last);
## [ 1, 2 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="AsMealyMachine" Arg="l" Label="List"/>
##   <Returns>A Mealy machine constructed out of the FR elements in <A>l</A>.</Returns>
##   <Description>
##     This function constructs a Mealy machine <C>r</C>, with states
##     <A>l</A> (which must be a state-closed set). Its outputs are
##     the outputs of its elements, and its transitions are the
##     transitions of its elements; in particular, <C>FRElement(r,i)</C>
##     is equal to <C>l[i]</C> as an FR element.
##
##     <P/> <C>Correspondence(r)</C> records the argument <A>l</A>.
##
##     <P/> This function returns <K>fail</K> if <A>l</A> is not state-closed.
## <Example><![CDATA[
## gap>  mu := FRElement([[[],[-1]]],[(1,2)],[1]);
## <2|f1>
## gap>
## gap> States(mu);
## [ <2|f1>, <2|identity ...>, <2|f1^-1> ]
## gap> AsMealyMachine(last);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states>
## gap> Display(last);
##    |  1     2
## ---+-----+-----+
##  a | b,2   c,1
##  b | b,1   b,2
##  c | a,2   b,1
## ---+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="AsMealyElement" Arg="m"/>
##   <Returns>A Mealy element isomorphic to <A>m</A>.</Returns>
##   <Description>
##     This function constructs a Mealy element, which induces the same tree
##     automorphism as the FR element <A>m</A>.
##
##     <P/> <A>m</A> may be a group/monoid/semigroup FR element, or a Mealy
##     element; in which case the result is returned unchanged.
##
##     <P/> This function is not guaranteed to return; if <A>m</A> does not
##     have finite states, then it will loop forever.
## <Example><![CDATA[
## gap> mu := FRElement([[[],[-1]]],[(1,2)],[1]);
## <2|f1>
## gap> AsMealyElement(mu);
## <Mealy machine on alphabet [ 1, 2 ] with 3 states, initial state 1>
## gap> [[2,1]]^last;
## [ [ 1, 2 ] ]
## gap> [2,1,2,1]^mu;
## [ 1, 2, 1, 2 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="AsIntMealyMachine" Arg="m"/>
##   <Attr Name="AsIntMealyElement" Arg="m"/>
##   <Returns>A Mealy machine in integer format, isomorphic to <A>m</A>.</Returns>
##   <Description>
##     This function constructs a Mealy machine <C>r</C>, which has
##     similar behaviour as <A>m</A> while having stateset <C>[1..n]</C>
##     for some natural <C>n</C>. Most <Package>FR</Package> commands
##     operate efficiently only on Mealy machines of this type.
##
##     <P/> This function is not guaranteed to return; if <A>m</A> does not
##     have finite states, then it will loop forever.
## <Example><![CDATA[
## gap> g := Group((1,2));; n := MealyMachine(g,g,\*,\*);
## <Mealy machine on alphabet [ (), (1,2) ] with states Group( [ (1,2) ] )>
## gap> Display(n);
##        |      ()            (1,2)
## -------+-------------+-------------+
##     () |    (),()      (1,2),(1,2)
##  (1,2) | (1,2),(1,2)      (),()
## -------+-------------+-------------+
## gap> AsIntMealyMachine(n);
## <Mealy machine on alphabet [ 1, 2 ] with 2 states>
## gap> Display(last);
##    |  1     2
## ---+-----+-----+
##  a | a,1   b,2
##  b | b,2   a,1
## ---+-----+-----+
## gap> Correspondence(last);
## [ 1, 2 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="TopElement" Arg="p[,n]"/>
##   <Returns>A Mealy machine in integer format, acting on the first symbol of sequences.</Returns>
##   <Description>
##     This function constructs a Mealy machine <C>r</C>, which acts as
##     <A>p</A> on the first letter of sequences and fixes the other letters.
##     The argument <A>n</A> is the size of the alphabet of <C>r</C>; if it
##     is ommitted, then it is assumed to be the degree of the transformation
##     <A>p</A>, or the largest moved point of the permutation or trans
##     <A>p</A>.
## <Example><![CDATA[
## gap> a := TopElement((1,2));
## <Mealy element on alphabet [ 1, 2 ] with 2 states>
## gap> last=GrigorchukGroup.1;
## true
## gap> a := TopElement((1,2),3);
## <Mealy element on alphabet [ 1, 2, 3 ] with 2 states>
## gap> last in GuptaSidkiGroup;
## false
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("AsMealyMachine", IsFRElementCollection);
DeclareAttribute("AsMealyMachine", IsFRMachine);
DeclareAttribute("AsMealyElement", IsFRElement);
DeclareOperation("AsIntMealyMachine", [IsFRMachine]);
DeclareOperation("AsIntMealyElement", [IsFRElement]);
DeclareOperation("TopElement", [IsPerm]);
DeclareOperation("TopElement", [IsPerm,IsInt]);
DeclareOperation("TopElement", [IsTransformation]);
DeclareOperation("TopElement", [IsTransformation,IsInt]);
DeclareOperation("TopElement", [IsTrans]);
DeclareOperation("TopElement", [IsTrans,IsInt]);
#############################################################################

#############################################################################
##
#M ConfinalityClasses
#M Germs
#M HasOpenSetCondition
##
## <#GAPDoc Label="ConfinalityClasses">
## <ManSection>
##   <Attr Name="ConfinalityClasses" Arg="e"/>
##   <Attr Name="IsWeaklyFinitaryFRElement" Arg="e"/>
##   <Returns>A list describing the non-trivial confinality classes of <A>e</A>.</Returns>
##   <Description>
##     If <A>e</A> is a bounded element (see <Ref Prop="IsBoundedFRElement"/>),
##     there are finitely many infinite sequences that have confinality
##     class larger that one; i.e. ultimately periodic sequences that
##     are mapped by <A>e</A> to a sequence with different period. This
##     function returns a list of equivalence classes of periodic lists, see
##     <Ref Oper="PeriodicList"/>, which are
##     related under <A>e</A>.
##
##     <P/> By definition, an element is <E>weakly finitary</E> if it has no
##     non-singleton confinality classes.
## <Example><![CDATA[
## gap> g := FRGroup("t=<,,t>(2,3)","u=<u,,>(1,2)","v=<u,t,>");;
## gap> ConfinalityClasses(g.1);
## [ {PeriodicList([  ],[ 2 ])} ]
## gap> List(GeneratorsOfGroup(g),x->Elements(ConfinalityClasses(x)[1]));
## [ [ [/ 2 ], [/ 3 ] ],
##   [ [/ 1 ], [/ 2 ] ],
##   [ [/ 1 ], [/ 2 ], [/ 3 ] ] ]
## gap> IsWeaklyFinitaryFRElement(BinaryAddingElement);
## false
## gap> IsWeaklyFinitaryFRElement(GuptaSidkiGroup.2);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="Germs" Arg="e"/>
##   <Attr Name="NormOfBoundedFRElement" Arg="e"/>
##   <Returns>The germs of the bounded element <A>e</A>.</Returns>
##   <Description>
##     The <E>germs</E> of a bounded element are the finitely many
##     ultimately periodic sequences on which the state of <A>e</A> does
##     not vanish. This function returns the germs of <A>e</A>, as
##     a list of pairs; the first entry is a ray described as a
##     periodic sequence of integers (see <Ref Oper="PeriodicList"/>),
##     and the second entry is the periodic sequence of states that
##     appear along that ray.
##
##     <P/> The <E>norm</E> of a bounded element is the length of its
##     list of germs.
## <Example><![CDATA[
## gap> Germs(BinaryAddingElement);
## [ [ [/ 2 ], [/ 1 ] ] ]
## gap> Germs(GrigorchukGroup.1);
## [  ]
## gap> Germs(GrigorchukGroup.2);
## [ [ [/ 2 ], [/ 1, 3, 5 ] ] ]
## gap> Display(GrigorchukGroup.2);
##    |  1     2
## ---+-----+-----+
##  a | b,1   c,2
##  b | d,2   d,1
##  c | b,1   e,2
##  d | d,1   d,2
##  e | d,1   a,2
## ---+-----+-----+
## Initial state: a
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="HasOpenSetConditionFRElement" Arg="e"/>
##   <Returns><K>true</K> if <A>e</A> has the open set condition.</Returns>
##   <Description>
##     An FR element <A>e</A> has the <E>open set condition</E> if for
##     every infinite ray in the tree which is fixed by <A>e</A>, there is
##     an open set around that ray which is also fixed by <A>e</A>.
##     This function tests for <A>e</A> to have the open set condition.
##     It currently is implemented only for bounded elements.
## <Example><![CDATA[
## gap> HasOpenSetConditionFRElement(GrigorchukGroup.1);
## true
## gap> HasOpenSetConditionFRElement(GrigorchukGroup.2);
## false
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("ConfinalityClasses", IsFRElement);
DeclareAttribute("Germs", IsFRElement);
DeclareAttribute("NormOfBoundedFRElement", IsFRElement);
DeclareProperty("HasOpenSetConditionFRElement", IsFRElement);
DeclareProperty("IsWeaklyFinitaryFRElement", IsFRElement);
#############################################################################

#############################################################################
##
#M LimitFRMachine
#M NucleusMachine
##
## <#GAPDoc Label="LimitMachine">
## <ManSection>
##   <Attr Name="LimitFRMachine" Arg="m"/>
##   <Returns>The submachine of <A>m</A> on all recurrent states.</Returns>
##   <Description>
##     This command creates a new Mealy machine, with stateset the limit
##     states of <A>m</A>.
## <Example><![CDATA[
## gap> m := MealyMachine([[2,2,3],[2,3,3],[3,3,3]],[(),(),(1,2,3)]);
## <Mealy machine on alphabet [ 1 .. 3 ] with 3 states>
## gap> Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | b,1   b,2   c,3
##  b | b,1   c,2   c,3
##  c | c,2   c,3   c,1
## ---+-----+-----+-----+
## gap> LimitStates(m);
## [ <Mealy element on alphabet [ 1 .. 3 ] with 2 states>,
##   <Mealy element on alphabet [ 1 .. 3 ] with 1 state> ]
## gap> LimitFRMachine(m);
## <Mealy machine on alphabet [ 1 .. 3 ] with 2 states>
## gap> Display(last);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   b,2   b,3
##  b | b,2   b,3   b,1
## ---+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="NucleusMachine" Arg="m" Label="FR machine"/>
##   <Returns>The nucleus of <A>m</A>.</Returns>
##   <Description>
##     This command creates a new Mealy machine <C>n</C>, with stateset the
##     nucleus (see <Ref Oper="NucleusOfFRMachine"/>) of <A>m</A>.
##
##     <P/> This nucleus machine is characterized as the smallest machine
##     <C>n</C> such that <C>Minimized(LimitFRMachine(m*n))</C>
##     is isomorphic to <C>n</C>. It is also isomorphic to the
##     <Ref Attr="NucleusMachine" Label="FR semigroup"/> of the state
##     closure of the <Ref Oper="SCSemigroup"/> of <A>m</A>.
##
##     <P/> Note that the ordering of
##     the states in the resulting machine is not necessarily the same as in
##     <A>m</A>; however, if <A>m</A> and <C>n</C> are isomorphic, then this
##     command returns <A>m</A>.
## <Example><![CDATA[
## gap> m := MealyMachine([[2,1,1],[2,2,2]],[(1,2,3),()]);
## <Mealy machine on alphabet [ 1, 2, 3 ] with 2 states>
## gap> Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | b,2   a,3   a,1
##  b | b,1   b,2   b,3
## ---+-----+-----+-----+
## gap> NucleusMachine(m);
## <Mealy machine on alphabet [ 1, 2, 3 ] with 3 states>
## gap> Display(last);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | c,3   b,1   c,2
##  c | a,2   c,3   c,1
## ---+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("LimitStates", IsFRMachine);
DeclareAttribute("NucleusMachine", IsFRMachine);
#############################################################################

#E mealy.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
