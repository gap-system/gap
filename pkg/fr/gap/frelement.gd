#############################################################################
##
#W frelement.gd                                             Laurent Bartholdi
##
#H   @(#)$Id: frelement.gd,v 1.34 2011/06/29 13:38:34 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file declares the category of elements of functionally recursive
##  elements, i.e. machines with a distinguished state.
##
#############################################################################

#############################################################################
##
#C IsFRElement . . . . . . . . . . . . FR machines, plus a word in the states
##
## <#GAPDoc Label="IsFRElement">
## <ManSection>
##   <Filt Name="IsFRElement" Arg="obj"/>
##   <Filt Name="IsSemigroupFRElement" Arg="obj"/>
##   <Filt Name="IsMonoidFRElement" Arg="obj"/>
##   <Filt Name="IsGroupFRElement" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is an FR element.</Returns>
##   <Description>
##     This filter is the acceptor for the <E>functionally recursive
##     element</E> category.
##
##     <P/> It implies that <A>obj</A> has an underlying FR machine,
##     may act on sequences, and has a recursive <Ref Attr="DecompositionOfFRElement"/>.
##
##     <P/> The next filters specify the type of free object the stateset of
##     <A>obj</A> is modelled on.
##   </Description>
## </ManSection>
## <ManSection>
##   <Filt Name="IsFRMealyElement" Arg="obj"/>
##   <Filt Name="IsSemigroupFRMealyElement" Arg="obj"/>
##   <Filt Name="IsMonoidFRMealyElement" Arg="obj"/>
##   <Filt Name="IsGroupFRMealyElement" Arg="obj"/>
##   <Attr Name="UnderlyingMealyElement" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is an FR element.</Returns>
##   <Description>
##     This filter is the acceptor for the <E>functionally recursive
##     element</E> category, with an additional Mealy element stored as
##     attribute for faster calculations. It defines a subcategory of
##     <Ref Filt="IsFRElement"/>. This additional Mealy element may be
##     obtained as <C>UnderlyingMealyElement(obj)</C>.
##
##     <P/> The next filters specify the type of free object the stateset of
##     <A>obj</A> is modelled on.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
## <#GAPDoc Label="FREFamily">
## <ManSection>
##   <Oper Name="FREFamily" Arg="obj"/>
##   <Returns>the family of FR elements on alphabet <A>obj</A>.</Returns>
##   <Description>
##     The family of an FR object is the arity of the tree on which
##     elements cat act; in other words, there is one family for each
##     alphabet.
##
##     <P/> The argument may be an FR machine, an alphabet, or a family
##     of FR machines.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsFRElement", IsFRObject);
DeclareCategoryCollections("IsFRElement");
DeclareCategory("IsGroupFRElement", IsFRElement and IsAssociativeElement and IsInvertible);
DeclareCategory("IsMonoidFRElement", IsFRElement and IsAssociativeElement);
DeclareCategory("IsSemigroupFRElement", IsFRElement and IsAssociativeElement);
DeclareAttribute("UnderlyingMealyElement", IsFRElement);
DeclareSynonym("IsFRMealyElement", IsFRElement and HasUnderlyingMealyElement);
DeclareSynonym("IsGroupFRMealyElement", IsGroupFRElement and HasUnderlyingMealyElement);
DeclareSynonym("IsMonoidFRMealyElement", IsMonoidFRElement and HasUnderlyingMealyElement);
DeclareSynonym("IsSemigroupFRMealyElement", IsSemigroupFRElement and HasUnderlyingMealyElement);
DeclareOperation("FREFamily", [IsObject]);
DeclareOperation("Minimized", [IsFRElement]);
#############################################################################

#############################################################################
##
#R IsFRElementRep . . . . . . . . . . . . . . . representation of FR elements
##
##  An FR element is an FR machine and a word in its generators.
##
DeclareSynonym("IsFRElementStdRep", IsPackedElementDefaultRep);
#############################################################################

#############################################################################
##
#P IsInvertible . . . . . . . . . . . . . . .does FR element have an inverse?
##
DeclareProperty("IsInvertible", IsFRElement);
#############################################################################

#############################################################################
##
#M AsXXXFRElement
##
## <#GAPDoc Label="AsGroupFRElement">
## <ManSection>
##   <Oper Name="AsGroupFRElement" Arg="e"/>
##   <Oper Name="AsMonoidFRElement" Arg="e"/>
##   <Oper Name="AsSemigroupFRElement" Arg="e"/>
##   <Returns>An FR element isomorphic to <A>m</A>, with a free group/monoid/semigroup as stateset.</Returns>
##   <Description>
##     This function constructs, from the FR element <A>e</A>, an isomorphic
##     FR element <C>f</C> with a free group/monoid/semigroup as stateset.
##     <A>e</A> may be a Mealy, group, monoid or semigroup FR element.
## <Example><![CDATA[
## gap> e := AsGroupFRElement(FRElement(GuptaSidkiMachines(3),4));
## <3|f1>
## gap> Display(e);
##  G  |     1         2        3
## ----+--------+---------+--------+
##  f1 |   f2,1   f2^-1,2     f1,3
##  f2 | <id>,2    <id>,3   <id>,1
## ----+--------+---------+--------+
## Initial state: f1
## gap> e=FRElement(GuptaSidkiMachines(3),4);
## #I  \=: converting second argument to FR element
## true
## ]]></Example>
## <Example><![CDATA[
## gap> e := AsMonoidFRElement(FRElement(GuptaSidkiMachines(3),4));
## <3|m1>
## gap> Display(e);
##  M  |     1        2        3
## ----+--------+--------+--------+
##  m1 |   m2,1     m3,2     m1,3
##  m2 | <id>,2   <id>,3   <id>,1
##  m3 | <id>,3   <id>,1   <id>,2
## ----+--------+--------+--------+
## Initial state: m1
## gap> e=FRElement(GuptaSidkiMachines(3),4);
## #I  \=: converting second argument to FR element
## true
## ]]></Example>
## <Example><![CDATA[
## gap> e := AsSemigroupFRElement(FRElement(GuptaSidkiMachines(3),4));
## <3|s1>
## gap> Display(e);
##  S  |   1      2      3
## ----+------+------+------+
##  s1 | s2,1   s3,2   s1,3
##  s2 | s4,2   s4,3   s4,1
##  s3 | s4,3   s4,1   s4,2
##  s4 | s4,1   s4,2   s4,3
## ----+------+------+------+
## Initial state: s1
## gap> e=FRElement(GuptaSidkiMachines(3),4);
## #I  \=: converting second argument to FR element
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
DeclareOperation("AsGroupFRElement", [IsFRElement]);
DeclareOperation("AsMonoidFRElement", [IsFRElement]);
DeclareOperation("AsSemigroupFRElement", [IsFRElement]);
#############################################################################

#############################################################################
##
#A InitialState . . . . . . . . . . . . . . . . . initial state of FR element
##
## <#GAPDoc Label="InitialState">
## <ManSection>
##   <Oper Name="InitialState" Arg="e"/>
##   <Returns>The initial state of an FR element.</Returns>
##   <Description>
##     This function returns the initial state of an FR element.
##     It is an element of the stateset of the underlying FR machine of
##     <A>e</A>.
## <Example><![CDATA[
## gap> n := FRElement(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)],[1,2]);
## <2|tau*mu>
## gap> InitialState(n);
## tau*mu
## gap> last in StateSet(n);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("InitialState", [IsFRElement]);
#############################################################################

#############################################################################
##
#O FRElement . . . . . . . . . . . . . . . . . . . . . . create an FR element
##
## <#GAPDoc Label="FRElement">
## <ManSection>
##   <Oper Name="FRElementNC" Arg="fam,free,transitions,outputs,init" Label="family,free,listlist,list,assocword"/>
##   <Returns>A new FR element.</Returns>
##   <Description>
##     This function constructs a new FR element, belonging to family
##     <A>fam</A>. It has stateset the free group/semigroup/monoid
##     <A>free</A>, and transitions described by <A>states</A> and
##     <A>outputs</A>, and initial states <A>init</A>.
##
##     <P/> <A>transitions</A> is a list of lists;
##     <A>transitions</A>[<A>s</A>][<A>x</A>] is a word in <A>free</A>,
##     which is the state reached by the machine when started in state
##     <A>s</A> and fed input <A>x</A>.
##
##     <P/> <A>outputs</A> is a list of lists;
##     <A>outputs</A>[<A>s</A>][<A>x</A>] is a output letter of the machine
##     when it receives input <A>x</A> in state <A>s</A>.
##
##     <P/> <A>init</A> is a word in <A>free</A>.
## <Example><![CDATA[
## gap> f := FreeGroup(2);
## <free group on the generators [ f1, f2 ]>
## gap> e := FRElementNC(FREFamily([1,2]),f,[[One(f),f.1],[One(f),f.2^-1]],
##                       [[2,1],[2,1]],f.1);
## <2|f1>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FRElement" Arg="[names,]transitions,outputs,init" Label="[list,]list,list,list"/>
##   <Oper Name="FRElement" Arg="free,transitions,outputs,init" Label="semigroup,list,list,list"/>
##   <Returns>A new FR element.</Returns>
##   <Description>
##     This function constructs a new FR element. It has stateset a free
##     group/semigroup/monoid, structure described by
##     <A>transitions</A> and <A>outputs</A>, and initial state <A>init</A>.
##     If the stateset is not passed as argument <A>free</A>, then it is
##     determined by <A>transitions</A> and <A>outputs</A>; it is a free group
##     if all states are invertible, and a free monoid otherwise.
##     In that case, <A>names</A> is an optional list; at position <A>s</A> it
##     contains a string describing generator <A>s</A>.
##
##     <P/> <A>transitions</A> is a list of lists;
##     <C>transitions[s][x]</C> is either an associative
##     word, or a list of integers or FR elements describing the state
##     reached by the machine when started in state <A>s</A> and fed input
##     <A>x</A>. Positive integers indicate a generator, negative
##     integers its inverse, the empty list in the identity state, and
##     lists of length greater than one indicate a product of states.
##     If an entry is an FR element, then its machine is incorporated into
##     the newly constructed element.
##
##     <P/> <A>outputs</A> is a list; at position <A>s</A> it contains a
##     permutation, a transformation, or a list of images, describing the
##     activity of state <A>s</A>.
##
##     <P/> <A>init</A> is either an associative word, an integer, or a list
##     of integers describing the inital state of the machine.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);
## <2|tau>
## gap> tau1 := FRElement(["tau1","tau"],[[[],[2]],[[],[2]]],[(),(1,2)],1);
## <2|tau1>
## gap> (tau/tau1)^2;
## <2|tau1*tau2^-1*tau1*tau2^-1>
## gap> IsOne(last);
## true
## ]]></Example>
## <Example><![CDATA[
## gap> f := FreeGroup("tau","tau1");
## <free group on the generators [ tau, tau1 ]>
## gap> tau := FRElement(f,[[One(f),f.1],[One(f),f.1]],[(1,2),()],f.1);
## <2|tau>
## gap> tau1 := FRElement(f,[[One(f),f.1],[One(f),f.1]],[(1,2),()],f.2);
## <2|tau1>
## gap> (tau/tau1)^2;
## <2|tau1*tau2^-1*tau1*tau2^-1>
## gap> IsOne(last);
## true
## gap> tauX := FRElement(f,[[One(f),f.1],[One(f),f.1]],[(1,2),()],1);;
## gap> tauY := FRElement(f,[[One(f),f.1],[One(f),f.1]],[(1,2),()],f.1);;
## gap> Size(Set([tau,tauX,tauY]));
## 1
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FRElement" Arg="m,q" Label="machine/element,list"/>
##   <Returns>A new FR element.</Returns>
##   <Description>
##     This function constructs a new FR element. If <A>m</A> is an FR machine,
##     it creates the element <M>(m,q)</M> whose <C>FRMachine</C> is <A>m</A>
##     and whose initial state is <A>q</A>.
##
##     <P/>If <A>m</A> is an FR element, this command creates an FR element
##     with the same FR machine as <A>m</A>, and with initial state <A>q</A>.
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1 .. 2 ] on Group( [ a, b ] )>
## gap> a := FRElement(m,1); b := FRElement(m,2);
## <2|a>
## <2|b>
## gap> Comm(b,b^a);
## <2|b^-1*a^-1*b^-1*a*b*a^-1*b*a>
## gap> IsOne(last);
## true
## gap> last2=FRElement(m,[-2,-1,-2,1,2,-1,2,1]);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ComposeElement" Arg="l,p" Label="elementcoll,perm"/>
##   <Returns>A new FR element.</Returns>
##   <Description>
##     This function constructs a new FR element. <A>l</A> is a list of FR
##     elements, and <A>p</A> is a permutation, transformation or list.
##     In that last case, the resulting element <C>g</C>
##     satisfies <C>DecompositionOfFRElement(g)=[l,p]</C>.
##
##     <P/> If all arguments are Mealy elements, the result is a Mealy element.
##     Otherwise, it is a MonoidFRElement.
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);;
## gap> a := FRElement(m,1); b := FRElement(m,2);
## <2|a>
## <2|b>
## gap> ComposeElement([b^0,b],(1,2));
## <2|f1>
## gap> last=a;
## true
## gap> DecompositionOfFRElement(last2);
## [ [ <2|identity ...>, <2|f5> ], [ 2, 1 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="VertexElement" Arg="v,e"/>
##   <Returns>A new FR element.</Returns>
##   <Description>
##     This function constructs a new FR element. <A>v</A> is either an integer
##     or a list of integers, and represents a vertex. <A>e</A> is an FR
##     element. The resulting element acts on the subtree below vertex <A>v</A>
##     as <A>e</A> acts on the whole tree, and fixes all other subtrees.
## <Example><![CDATA[
## gap> e := FRElement([[[],[]]],[(1,2)],[1]);
## <2|f1>
## gap> f := VertexElement(1,e);;
## gap> g := VertexElement(2,f);;
## gap> g = VertexElement([2,1],e);
## true
## gap> 1^e;
## 2
## gap> [1,1]^f;
## [ 1, 2 ]
## gap> [2,1,1]^g;
## [ 2, 1, 2 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="DiagonalElement" Arg="n,e"/>
##   <Returns>A new FR element.</Returns>
##   <Description>
##     This function constructs a new FR element. <A>n</A> is either an integer
##     or a list of integers, representing a sequence of operations
##     to be performed on <A>e</A> starting from the last.
##
##     <P/> <C>DiagonalElement(n,e)</C> is an element with trivial output,
##     and with <M>e^{(-1)^i \mathop{binomial}(n,i)}</M> in coordinate <M>i+1</M> of
##     the alphabet, assumed to be of the form <C>[1..d]</C>.
##
##     <P/> In particular, <C>DiagonalElement(0,e)</C> is the same as
##     <C>VertexElement(1,e)</C>; <C>DiagonalElement(1,e)</C> is the commutator
##     of <C>VertexElement(1,e)</C> with any cycle mapping 1 to 2; and
##     <C>DiagonalElement(-1,e)</C> has a transition to <A>e</A> at all
##     inputs.
## <Example><![CDATA[
## gap> e := FRElement([[[],[],[1]]],[(1,2,3)],[1]);
## <3|f1>
## gap> Display(e);
##     |     1        2      3
## ----+--------+--------+------+
##  f1 | <id>,2   <id>,3   f1,1
## ----+--------+--------+------+
## Initial state: f1
## gap> Display(DiagonalElement(0,e));
##     |     1        2        3
## ----+--------+--------+--------+
##  f1 |   f2,1   <id>,2   <id>,3
##  f2 | <id>,2   <id>,3     f2,1
## ----+--------+--------+--------+
## Initial state: f1
## gap> Display(DiagonalElement(1,e));
##     |     1         2        3
## ----+--------+---------+--------+
##  f1 |   f2,1   f2^-1,2   <id>,3
##  f2 | <id>,2    <id>,3     f2,1
## ----+--------+---------+--------+
## Initial state: f1
## gap> Display(DiagonalElement(2,e));
##     |     1         2      3
## ----+--------+---------+------+
##  f1 |   f2,1   f2^-2,2   f2,3
##  f2 | <id>,2    <id>,3   f2,1
## ----+--------+---------+------+
## Initial state: f1
## gap> Display(DiagonalElement(-1,e));
##     |     1        2      3
## ----+--------+--------+------+
##  f1 |   f2,1     f2,2   f2,3
##  f2 | <id>,2   <id>,3   f2,1
## ----+--------+--------+------+
## Initial state: f1
## gap> DiagonalElement(-1,e)=DiagonalElement(2,e);
## true
## gap> Display(DiagonalElement([0,-1],e));
##  G  |     1        2        3
## ----+--------+--------+--------+
##  f1 |   f2,1   <id>,2   <id>,3
##  f2 |   f3,1     f3,2     f3,3
##  f3 | <id>,2   <id>,3     f3,1
## ----+--------+--------+--------+
## Initial state: f1
## gap> Display(DiagonalElement([-1,0],e));
##  G  |     1        2        3
## ----+--------+--------+--------+
##  f1 |   f2,1     f2,2     f2,3
##  f2 |   f3,1   <id>,2   <id>,3
##  f3 | <id>,2   <id>,3     f3,1
## ----+--------+--------+--------+
## Initial state: f1
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("FRElementNC", [IsFamily, IsSemigroup, IsList, IsList, IsAssocWord]);
DeclareOperation("FRElementNC", [IsFamily, IsFRMachine, IsAssocWord]);
DeclareOperation("FRElement", [IsList, IsList, IsList]);
DeclareOperation("FRElement", [IsList, IsList, IsInt]);
DeclareOperation("FRElement", [IsList, IsList, IsList, IsList]);
DeclareOperation("FRElement", [IsList, IsList, IsList, IsInt]);
DeclareOperation("FRElement", [IsSemigroup, IsList, IsList, IsAssocWord]);
DeclareOperation("FRElement", [IsSemigroup, IsList, IsList, IsList]);
DeclareOperation("FRElement", [IsSemigroup, IsList, IsList, IsInt]);
DeclareOperation("FRElement", [IsFRMachine, IsObject]);
DeclareOperation("FRElement", [IsFRElement, IsObject]);
DeclareOperation("VertexElement", [IsPosInt, IsFRElement]);
DeclareOperation("VertexElement", [IsList, IsFRElement]);
DeclareOperation("DiagonalElement", [IsInt, IsFRElement]);
DeclareOperation("DiagonalElement", [IsList, IsFRElement]);
DeclareOperation("ComposeElement", [IsFRElementCollection, IsObject]);
#############################################################################

#############################################################################
##
#O Output . . . . . . . . . . . . . . . . permutation of the alphabet induced
#O Activity . . . . . . . . . . . . .induced permutation on power of alphabet
#O Portrait . . . . . . . . . . . . . . nested list of activities on subtrees
#A DecompositionOfFRElement . . . . .actions on subtrees and permutation of the alphabet
##
## <#GAPDoc Label="Output/element">
## <ManSection>
##   <Oper Name="Output" Arg="e" Label="FR element"/>
##   <Returns>A transformation of <A>e</A>'s alphabet.</Returns>
##   <Description>
##     This function returns the transformation of <A>e</A>'s
##     alphabet, i.e. the action on strings of length 1 over the alphabet.
##     This transformation is a permutation if <A>machine</A> is a group
##     machine, and a transformation otherwise.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> Output(tau);
## (1,2)
## zap := FRElement(["zap"],[[[],[1]]],[[1,1]],[1]);;
## gap> Output(zap);
## <1,1>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Activity" Arg="e[,l]"/>
##   <Oper Name="ActivityInt" Arg="e[,l]"/>
##   <Oper Name="ActivityTransformation" Arg="e[,l]"/>
##   <Oper Name="ActivityPerm" Arg="e[,l]"/>
##   <Returns>The transformation induced by <A>e</A> on the <A>l</A>th level of the tree.</Returns>
##   <Description>
##     This function returns the transformation induced by <A>e</A>
##     on the <A>l</A>th level of the tree, i.e. on the strings of length
##     <A>l</A> over <A>e</A>'s alphabet.
##
##     <P/> This set of strings is identified with the set
##     <M>L=\{1,\ldots,d^l\}</M> of integers, where the alphabet of <A>e</A> has
##     <M>d</M> letters. Changes of the first letter of a string induce
##     changes of a multiple of <M>d^{l-1}</M> on the position in <M>L</M>,
##     while changes of the last letter of a string induce changes of
##     <M>1</M> on the position in <M>L</M>.
##
##     <P/> In its first form, this command returns a permutation (for
##     group elements) or a <Ref Func="Trans"/> (for other elements).
##     In the second form, it returns the
##     unique integer <C>i</C> such that the transformation <A>e</A> acts
##     on <C>[1..Length(AlphabetOfFRObject(e))&circum;n]</C> as adding
##     <C>i</C> in base <C>Length(alphabet(e))</C>, or
##     <K>fail</K> if no such <C>i</C> exists. In the third form, it returns
##     a &GAP; transformation. In the fourth form, it returns a permutation,
##     or <K>fail</K> if <A>e</A> is not invertible.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> Output(tau); PermList(last)=Activity(tau);
## [ 2, 1 ]
## true
## gap> Activity(tau,2); ActivityInt(tau,2);
## (1,3,2,4)
## 1
## gap> Activity(tau,3); ActivityInt(tau,3);
## (1,5,3,7,2,6,4,8)
## 1
## gap> zap := FRElement(["zap"],[[[1],[]]],[[1,1]],[1]);
## <2|zap>
## gap> Output(zap);
## [ 1, 1 ]
## gap> Activity(zap,3);
## <1,1,1,2,1,2,3,4>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Transition" Arg="e,i" Label="FR element,input"/>
##   <Returns>An element of <A>machine</A>'s stateset.</Returns>
##   <Description>
##     This function returns the state reached by <A>e</A> when
##     fed input <A>i</A>. This
##     input may be an alphabet letter or a sequence of alphabet letters.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> Transition(tau,2);
## tau
## gap> Transition(tau,[2,2]);
## tau
## gap> Transition(tau^2,[2,2]);
## tau
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Transitions" Arg="e" Label="FR element"/>
##   <Returns>A list of elements of <A>machine</A>'s stateset.</Returns>
##   <Description>
##     This function returns the states reached by <A>e</A> when
##     fed the alphabet as input.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> Transitions(tau);
## [ <identity ...>, tau ]
## gap> Transition(tau^2);
## [ tau, tau ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Portrait" Arg="e,l"/>
##   <Oper Name="PortraitPerm" Arg="e,l"/>
##   <Oper Name="PortraitInt" Arg="e,l"/>
##   <Returns>A nested list describing the action of <A>e</A>.</Returns>
##   <Description>
##     This function returns a sequence of <M>l+1</M> lists; the <M>i</M>th
##     list in the sequence is an <A>i-1</A>-fold nested list. The entry at
##     position <M>(x_1,\ldots,x_i)</M> is the transformation of the alphabet
##     induced by <A>e</A> under vertex <M>x_1\ldots x_i</M>.
##
##     <P/> The difference between the commands is the following:
##     <C>Portrait</C> returns transformations, <C>PortraitPerm</C> returns
##     permutations, and and <C>PortraitInt</C> returns integers,
##     the power of the cycle <M>x\mapsto x+1</M> that represents the transformation,
##     as for the function <Ref Oper="ActivityInt"/>.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> Portrait(tau,0);
## [ <2,1> ]
## gap> Portrait(tau,3);
## [ <2,1>, [ <>, <2,1> ], [ [ <>, <> ], [ <>, <2,1> ] ],
##   [ [ [ <>, <> ], [ <>, <> ] ], [ [ <>, <> ], [ <>, <2,1> ] ] ] ]
## gap> PortraitPerm(tau,0);
## [ (1,2) ]
## gap> PortraitInt(tau,0);
## [ 1 ]
## gap> PortraitInt(tau,3);
## [ 1 , [ 0 , 1 ],
##   [ [ 0 , 0 ], [ 0 , 1 ] ],
##   [ [ [ 0 , 0 ], [ 0 , 0 ] ], [ [ 0 , 0 ], [ 0 , 1 ] ] ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="DecompositionOfFRElement" Arg="e [,n]"/>
##   <Returns>A list describing the action and transitions of <A>e</A>.</Returns>
##   <Description>
##     This function returns a list. The second coordinate is the action of
##     <A>e</A> on its alphabet, see <Ref Oper="Output" Label="FR element"/>. The first
##     coordinate is a list, containing in position <M>i</M> the FR
##     element inducing the action of <A>e</A> on strings starting with
##     <M>i</M>.
##
##     <P/> If a second argument <A>n</A> is supplied, the decomposition is
##     iterated <A>n</A> times.
##
##     <P/> This FR element has same underlying machine as <A>e</A>,
##     and initial state given by <Ref Oper="Transition" Label="FR element,input"/>.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> DecompositionOfFRElement(tau);
## [ [ <2|identity ...>, <2|tau> ], [ 2, 1 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("Output", [IsFRElement]);
DeclareOperation("Output", [IsFRElement, IsObject, IsObject]);
DeclareOperation("Transition", [IsFRElement, IsObject]);
DeclareOperation("Transition", [IsFRElement, IsObject, IsObject]);
DeclareOperation("Transitions", [IsFRElement]);
DeclareOperation("Transitions", [IsFRElement, IsObject]);
DeclareOperation("Portrait", [IsFRElement, IsInt]);
DeclareOperation("PortraitInt", [IsFRElement, IsInt]);
DeclareOperation("PortraitPerm", [IsFRElement, IsInt]);
DeclareOperation("Activity", [IsFRElement]);
DeclareOperation("Activity", [IsFRElement, IsInt]);
DeclareOperation("ActivityInt", [IsFRElement]);
DeclareOperation("ActivityInt", [IsFRElement, IsInt]);
DeclareOperation("ActivityTransformation", [IsFRElement]);
DeclareOperation("ActivityTransformation", [IsFRElement, IsInt]);
DeclareOperation("ActivityPerm", [IsFRElement]);
DeclareOperation("ActivityPerm", [IsFRElement, IsInt]);
DeclareOperation("DecompositionOfFRElement", [IsFRElement]);
DeclareOperation("DecompositionOfFRElement", [IsFRElement, IsInt]);
##############################################################################

##############################################################################
##
#A StateSet . . . . . . . . . . . . . . underlying set of states of an element
#O State . . . . . . . . . . . . . . . . . . . . . element acting on a subtree
#O States . . . . . . . . . . . . . . . . .all the elements acting on subtrees
#O LimitStates . .those elements that appear infinitely many times in subtrees
#O LimitFRMachine . . . . . . . . . . .the Mealy machine on those limit states
##
## <#GAPDoc Label="States">
## <ManSection>
##   <Oper Name="StateSet" Arg="e" Label="FR element"/>
##   <Returns>The set of states associated with <A>e</A>.</Returns>
##   <Description>
##     This function returns the stateset of <A>e</A>. If <A>e</A> is of
##     Mealy type, this is the list of all states reached by <A>e</A>.
##
##     <P/> If <A>e</A> is of group/semigroup/monoid type, then this is the
##     stateset of the underlying FR machine, and not the minimal set of
##     states of <A>e</A>, which is computed with <Ref Oper="States"/>.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> StateSet(tau);
## <free group on the generators [ tau ]>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="State" Arg="e,v"/>
##   <Returns>An FR element describing the action of <A>e</A> at vertex <A>v</A>.</Returns>
##   <Description>
##     This function returns the FR element with same underlying machine as
##     <A>e</A>, acting on the binary tree as <A>e</A> acts on the subtree
##     below <A>v</A>.
##
##     <P/> <A>v</A> is either an integer or a list. This function returns
##     an FR element, but otherwise is essentially a call to
##     <Ref Oper="Transition" Label="FR element,input"/>.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> State(tau,2);
## <2|tau>
## gap> State(tau,[2,2]);
## <2|tau>
## gap> State(tau^2,[2,2]);
## <2|tau>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="States" Arg="e"/>
##   <Returns>A list of FR elements describing the action of <A>e</A> on all subtrees.</Returns>
##   <Description>
##     This function calls repeatedly <Ref Oper="State"/> to compute all the
##     states of <A>e</A>; it returns the smallest list of <C>FRElement</C>s
##     that is closed under the function <Ref Oper="State"/>.
##
##     <P/> <A>e</A> may be either an FR element, or a list of FR elements.
##     In the latter case, it amounts to computing the list of all states
##     of all elements of the list <A>e</A>.
##
##     <P/> The ordering of the list is as follows. First come <A>e</A>, or
##     all elements of <A>e</A>. Then come the states reached by <A>e</A> in
##     one transition, ordered by the alphabet letter leading to them; then
##     come those reached in two transitions, ordered lexicographically by
##     the transition; etc.
##
##     <P/> Note that this function is not guaranteed to terminate. There is
##     currently no mechanism that detects whether an FR element is finite
##     state, so in fact this function terminates if and only if <A>e</A> is
##     finite-state.
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);;
## gap> a := FRElement(m,1);; b := FRElement(m,2);;
## gap> States(a);
## [ <2|a>, <2|identity ...>, <2|b> ]
## gap> States(b);
## [ <2|b>, <2|identity ...>, <2|a> ]
## gap> States(a^2);
## [ <2|a^2>, <2|b>, <2|identity ...>, <2|a> ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FixedStates" Arg="e"/>
##   <Returns>A list of FR elements describing the action of <A>e</A> at fixed vertices.</Returns>
##   <Description>
##     This function calls repeatedly <Ref Oper="State"/> to compute all the
##     states of <A>e</A> at non-trivial fixed vertices.
##
##     <P/> <A>e</A> may be either an FR element, or a list of FR elements.
##     In the latter case, it amounts to computing the list of all states
##     of all elements of the list <A>e</A>.
##
##     <P/> The ordering of the list is as follows. First come <A>e</A>, or
##     all elements of <A>e</A>. Then come the states reached by <A>e</A> in
##     one transition, ordered by the alphabet letter leading to them; then
##     come those reached in two transitions, ordered lexicographically by
##     the transition; etc.
##
##     <P/> Note that this function is not guaranteed to terminate, if <A>e</A>
##     is not finite-state.
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);;
## gap> a := FRElement(m,1);; b := FRElement(m,2);;
## gap> FixedStates(a);
## [ ]
## gap> FixedStates(b);
## [ <2|identity ...>, <2|a> ]
## gap> FixedStates(a^2);
## [ <2|b>, <2|identity ...>, <2|a> ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="LimitStates" Arg="e"/>
##   <Returns>A set of FR element describing the recurring actions of <A>e</A> on all subtrees.</Returns>
##   <Description>
##     This function computes the <Ref Oper="States"/> <M>S</M> of <A>e</A>,
##     and then repeatedly removes elements that are not
##     <E>recurrent</E>, i.e. that do not appear as states of elements
##     of <M>S</M> on subtrees distinct from the entire tree; and then
##     converts the result to a set.
##
##     <P/> As for <Ref Oper="States"/>, <A>e</A> may be either an FR element,
##     or a list of FR elements.
##
##     <P/> Note that this function is not guaranteed to terminate. It
##     currently terminates if and only if <Ref Oper="States"/> terminates.
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);;
## gap> a := FRElement(m,1);; b := FRElement(m,2);;
## gap> LimitStates(a);
## [ <2|identity ...>, <2|b>, <2|a> ]
## gap> LimitStates(a^2);
## [ <2|identity ...>, <2|b>, <2|a> ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsFiniteStateFRElement" Arg="e"/>
##   <Prop Name="IsFiniteStateFRMachine" Arg="e"/>
##   <Returns><K>true</K> if <A>e</A> is a finite-state element.</Returns>
##   <Description>
##     This function tests whether <A>e</A> is a finite-state element.
##
##     <P/> When applied to a Mealy element, it returns <K>true</K>.
## <Example><![CDATA[
## gap> m := GuptaSidkiMachines(3);; Display(m);
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   a,1
##  c | a,3   a,1   a,2
##  d | b,1   c,2   d,3
## ---+-----+-----+-----+
## gap> Filtered(StateSet(m),i->IsFiniteStateFRElement(FRElement(m,i)));
## [ 1, 2, 3, 4 ]
## gap> IsFiniteStateFRMachine(m);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="NucleusOfFRMachine" Arg="m"/>
##   <Oper Name="Nucleus" Arg="m" Label="FR machine"/>
##   <Returns>The nucleus of the machine <A>m</A>.</Returns>
##   <Description>
##     This function computes the <E>nucleus</E> of the machine <A>m</A>.
##     It is the minimal set <C>N</C> of states such that, for every word
##     <A>s</A> in the states of <A>m</A>, all states of <A>s</A> of
##     at large enough depth belong to <C></C>.
##
##     <P/> It may also be characterized as the minimal set <C>N</C>
##     of states that contains the limit states of <A>m</A> and is such that
##     the limit states of <C>N*m</C> belong to <C>N</C>.
##
##     <P/> The elements of the nucleus form the stateset of a Mealy machine;
##     this machine is created by <Ref Oper="NucleusMachine" Label="FR machine"/>.
##
##     <P/> This command is not guaranteed to terminate; though it will,
##     if the semigroup generated by <A>m</A> is contracting. If the minimal
##     such <C>N</C> is infinite, this command either returns <A>K</A>
##     or runs forever.
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);;
## gap> NucleusOfFRMachine(m);
## [ <2|identity ...>, <2|b>, <2|a> ]
## gap> m := FRMachine(["a","b"],[[[],[1]],[[1],[2]]],[(1,2),()]);;
## gap> NucleusOfFRMachine(m);
## fail
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("State", [IsFRElement, IsInt]);
DeclareOperation("State", [IsFRElement, IsList]);
DeclareOperation("States", [IsFRElement]);
DeclareOperation("States", [IsFRElementCollection]);
DeclareAttribute("FixedStates", IsFRElement);
DeclareAttribute("FixedStates", IsFRElementCollection);
DeclareAttribute("LimitStates", IsFRElement);
DeclareAttribute("LimitStates", IsFRElementCollection);
DeclareAttribute("LimitFRMachine", IsFRObject);
DeclareAttribute("LimitFRMachine", IsFRElementCollection);
DeclareProperty("IsFiniteStateFRElement", IsFRElement);
DeclareProperty("IsFiniteStateFRMachine", IsFRMachine);
DeclareAttribute("NucleusOfFRMachine", IsFRMachine);
##############################################################################

##############################################################################
##
#O \^
#O \*
#O \[]
#O \{}
##
## <#GAPDoc Label="^">
## <ManSection>
##   <Meth Name="\^" Arg="e,v" Label="POW"/>
##   <Returns>The image of a vertex <A>v</A> under <A>e</A>.</Returns>
##   <Description>
##     This function accepts an FR element and a vertex <A>v</A>, which is
##     either an integer or a list. It returns the image of <A>v</A> under
##     the transformation <A>e</A>, in the same format (integer/list) as
##     <A>v</A>.
##
##     <P/> The list <A>v</A> can be a periodic list (see
##     <Ref Oper="PeriodicList"/>). In that case, the result is again a
##     periodic list. The computation will succeed only if the states
##     along the period are again periodic.
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> 1^tau;
## 2
## gap> [1,1]^tau;
## [ 2, 1 ]
## gap> [2,2,2]^tau;
## [ 1, 1, 1 ]
## gap List([0..5],i->PeriodicList([],[2])^(tau^i));
## [ [/ 2 ], [/ 1 ], [ 2, / 1 ], [ 1, 2, / 1 ], [ 2, 2, / 1 ],
##   [ 1, 1, 2, / 1 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="\*" Arg="m,n" Label="PROD"/>
##   <Returns>The product of the two FR elements <A>m</A> and <A>n</A>.</Returns>
##   <Description>
##     This function returns a new FR element, which is the product of the
##     FR elements <A>m</A> and <A>n</A>.
##
##     <P/> In case <A>m</A> and <A>n</A> have the same underlying machine,
##     this is the machine of the result. In case the machine of <A>n</A>
##     embeds in the machine of <A>m</A> (see <Ref Oper="SubFRMachine"/>),
##     the machine of the product is the machine of <A>m</A>.
##     In case the machine of <A>m</A>
##     embeds in the machine of <A>n</A>, the machine of the product is the
##     machine of <A>n</A>. Otherwise the machine of the product is the product
##     of the machines of <A>m</A> and <A>n</A> (See <Ref Meth="\*"/>).
## <Example><![CDATA[
## gap> tau := FRElement(["tau"],[[[],[1]]],[(1,2)],[1]);;
## gap> tau*tau; tau^2;
## <2|tau^2>
## <2|tau^2>
## gap> [2,2,2]^(tau^2);
## [ 2, 1, 1 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="\[\]" Arg="m,i" Label="ELMLIST"/>
##   <Meth Name="\{\}" Arg="m,l" Label="ELMSLIST"/>
##   <Returns>A [list of] FR element[s] with initial state <A>i</A>.</Returns>
##   <Description>
##     These are respectively synonyms for <C>FRElement(m,i)</C> and
##     <C>List(l,s->FRElement(m,s))</C>. The argument <A>m</A> must be an
##     FR machine, <A>i</A> must be a positive integer, and <A>l</A> must
##     be a list.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##############################################################################

#E frelement.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
