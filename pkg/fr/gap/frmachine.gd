#############################################################################
##
#W frmachine.gd                                             Laurent Bartholdi
##
#H   @(#)$Id: frmachine.gd,v 1.30 2011/03/31 10:21:28 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file declares the category of functionally recursive machines.
##
#############################################################################

#############################################################################
##
#C IsFRObject . . . . .category underlying all functionally recursive objects
#C IsFRMachine . . . . . . . . . . . . . . . .functionally recursive machines
##
## <#GAPDoc Label="IsFRObject">
## <ManSection>
##   <Filt Name="IsFRObject" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is an FR machine or element.</Returns>
##   <Description>
##     This function is the acceptor for the most general FR category
##     (which splits up as <Ref Filt="IsFRMachine"/> and
##     <Ref Filt="IsFRElement"/>).
##
##     <P/> It implies that <A>obj</A> has an attribute
##     <Ref Attr="AlphabetOfFRObject"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Filt Name="IsFRMachine" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is an FR machine.</Returns>
##   <Description>
##     This function is the acceptor for the <E>functionally recursive
##     machine</E> category.
##     It splits up as <Ref Prop="IsGroupFRMachine"/>, <Ref
##     Prop="IsSemigroupFRMachine"/>, <Ref Prop="IsMonoidFRMachine"/> and
##     <Ref Filt="IsMealyMachine"/>).
##
##     <P/> It implies that <A>obj</A> has attributes <Ref
##     Attr="StateSet" Label="FR machine"/>, <Ref Attr="GeneratorsOfFRMachine"/>,
##     and <Ref Attr="WreathRecursion"/>; the
##     last two are usually not used for Mealy machines.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsFRObject", IsRingElementWithInverse);
DeclareCategory("IsFRMachine", IsFRObject and IsAssociativeElement);
BindGlobal("FR_FAMILIES", []); # an associative list [[alphabet, machine family, element family],...]
#############################################################################

#############################################################################
##
#O FRMFamily . . . . . . . .the family of all FR machines on a given alphabet
##
## <#GAPDoc Label="FRMFamily">
## <ManSection>
##   <Oper Name="FRMFamily" Arg="obj"/>
##   <Returns>the family of FR machines on alphabet <A>obj</A>.</Returns>
##   <Description>
##     The family of an FR object is the arity of the tree on which
##     elements cat act; in other words, there is one family for each
##     alphabet.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("FRMFamily", [IsObject]);
#############################################################################

#############################################################################
##
#A AlphabetOfFRObject. . . . . . . . . . .the alphabet on which machines act
##
## <#GAPDoc Label="AlphabetOfFRObject">
## <ManSection>
##   <Oper Name="AlphabetOfFRObject" Arg="obj"/>
##   <Oper Name="AlphabetOfFRAlgebra" Arg="obj"/>
##   <Oper Name="AlphabetOfFRSemigroup" Arg="obj"/>
##   <Oper Name="Alphabet" Arg="obj"/>
##   <Returns>the alphabet associated with <A>obj</A>.</Returns>
##   <Description>
##     This command applies to the family of any FR object, or to the
##     object themselves. Alphabets are returned as lists, and in pratice
##     are generally of the form <C>[1..n]</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("AlphabetOfFRObject", IsFRObject);
#############################################################################

#############################################################################
##
#R IsFRMachineStdRep
##
## <#GAPDoc Label="IsFRMachineStdRep">
## <ManSection>
##   <Filt Name="IsFRMachineStrRep" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a standard (group,monoid,semigroup) FR machine.</Returns>
##   <Description>
##     There is a free object <C>free</C>, of rank <M>N</M>, a list
##     <C>transitions</C> of length <M>N</M>, each entry a list, indexed
##     by the alphabet, of elements of <C>free</C>, and a list
##     <C>output</C> of length <C>N</C> of transformations or permutations
##     of the alphabet.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareRepresentation("IsFRMachineStdRep",
        IsComponentObjectRep and IsAttributeStoringRep,
        ["free","transitions","output"]);
#############################################################################

#############################################################################
##
#P IsGroupFRMachine . . . . . . is this a machine with stateset a free group?
#P IsSemigroupFRMachine . . is this a machine with stateset a free semigroup?
#P IsMonoidFRMachine . . . . . is this a machine with stateset a free monoid?
##
## <#GAPDoc Label="IsGroupFRMachine">
## <ManSection>
##   <Prop Name="IsGroupFRMachine" Arg="obj"/>
##   <Prop Name="IsMonoidFRMachine" Arg="obj"/>
##   <Prop Name="IsSemigroupFRMachine" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is an FR machine whose stateset
##   is a free group/monoid/semigroup.</Returns>
##   <Description>
##     This function is the acceptor for those functionally recursive
##     machines whose stateset (accessible via <Ref Attr="StateSet" Label="FR machine"/>) is
##     a free group, monoid or semigroup. The generating set of its stateset
##     is accessible via <Ref Attr="GeneratorsOfFRMachine"/>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareProperty("IsGroupFRMachine", IsFRMachine);
DeclareProperty("IsSemigroupFRMachine", IsFRMachine);
DeclareProperty("IsMonoidFRMachine", IsFRMachine);
#############################################################################

#############################################################################
##
#P IsInvertible . . . . . . . . . . . . . . . . . is this machine invertible?
##
## <#GAPDoc Label="IsInvertible">
## <ManSection>
##   <Prop Name="IsInvertible" Arg="m"/>
##   <Returns><K>true</K> if <A>m</A> is an invertible FR machine.</Returns>
##   <Description>
##     This function accepts invertible FR machines, i.e. machines
##     <A>m</A> such that <M>(m,q)</M> is an invertible
##     transformation of the alphabet for all <M>q</M> in the stateset of
##     <A>m</A>.
## <Example><![CDATA[
## gap> m := FRMachine([[[],[]]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
## gap> IsInvertible(m);
## true
## gap> m := FRMachine([[[],[]]],[[1,1]]);
## <FR machine with alphabet [ 1, 2 ] on Monoid( [ m1 ], ... )>
## gap> IsInvertible(m);
## false
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareProperty("IsInvertible", IsFRMachine);
#############################################################################

#############################################################################
##
#O FRMachine . . . . . . . . .create a FR machine from transitions and output
##
## <#GAPDoc Label="FRMachine">
## <ManSection>
##   <Oper Name="FRMachineNC" Arg="fam,free,transitions,outputs" Label="family,free,listlist,list"/>
##   <Returns>A new FR machine.</Returns>
##   <Description>
##     This function constructs a new FR machine, belonging to family
##     <A>fam</A>. It has stateset the free group/semigroup/monoid
##     <A>free</A>, and transitions described by <A>states</A> and
##     <A>outputs</A>.
##
##     <P/> <A>transitions</A> is a list of lists;
##     <A>transitions</A>[<A>s</A>][<A>x</A>] is a word in <A>free</A>,
##     which is the state reached by the machine when started in state
##     <A>s</A> and fed input <A>x</A>.
##
##     <P/> <A>outputs</A> is also a list of lists;
##     <A>outputs</A>[<A>s</A>][<A>x</A>] is the output produced by the
##     machine is in state <A>s</A> and inputs <A>x</A>.
## <Example><![CDATA[
## gap> f := FreeGroup(2);
## <free group on the generators [ f1, f2 ]>
## gap> m := FRMachineNC(FRMFamily([1,2]),f,[[One(f),f.1],[One(f),f.2^-1]],
##                       [[2,1],[1,2]]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2 ] )>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FRMachine" Arg="[names,]transitions,outputs" Label="[list,]list,list"/>
##   <Oper Name="FRMachine" Arg="free,transitions,outputs" Label="semigroup,list,list"/>
##   <Returns>A new FR machine.</Returns>
##   <Description>
##     This function constructs a new FR machine. It has stateset a free
##     group/semigroup/monoid, and structure described by <A>transitions</A>
##     and <A>outputs</A>.
##
##     <P/> If there is an argument <A>free</A>, it is the free
##     group/monoid/semigroup to be used as stateset. Otherwise, the
##     stateset will be guessed from the <A>transitions</A> and
##     <A>outputs</A>; it will be a free group if all states are
##     invertible, and a monoid otherwise. <A>names</A> is then an
##     optional list, with at position <A>s</A> a string naming
##     generator <A>s</A> of the stateset. If <A>names</A> contains
##     too few entries, they are completed by the names
##     <A>&uscore;&uscore;1,&uscore;&uscore;2,...</A>.
##
##     <P/> <A>transitions</A> is a list of lists;
##     <C>transitions[s][x]</C> is either an associative
##     word, or a list of integers describing the state reached by the
##     machine when started in state <A>s</A> and fed input
##     <A>x</A>. Positive integers indicate a generator index, negative
##     integers its inverse, the empty list in the identity state, and
##     lists of length greater than one indicate a product of states.
##     If an entry is an FR element, then its machine is incorporated into
##     the newly constructed one.
##
##     <P/> <A>outputs</A> is a list; at position <A>s</A> it contains a
##     permutation, a transformation, or a list of integers (the images
##     of a transformation), describing the activity of state <A>s</A>.
##     If all states are invertible, the outputs are all converted
##     to permutations, while if there is a non-invertible state then
##     the outputs are all converted to transformations.
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ tau, mu ] )>
## gap> m=n;
## true
## gap> Display(n);
##      |     1         2
## -----+--------+---------+
##  tau | <id>,2     tau,1
##   mu | <id>,2   mu^-1,1
## -----+--------+---------+
## gap> m := FRMachine([[[],[FRElement(n,1)]]],[()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3 ] )>
## gap> Display(m);
##     |     1         2
## ----+--------+---------+
##  f1 | <id>,1      f2,2
##  f2 | <id>,2      f2,1
##  f3 | <id>,2   f1^-1,1
## ----+--------+---------+
## gap> f := FreeGroup(2);
## <free group on the generators [ f1, f2 ]>
## gap> p := FRMachine(f,[[One(f),f.1],[One(f),f.2^-1],[(1,2),(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2 ] )>
## gap> n=p;
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="UnderlyingFRMachine" Arg="obj"/>
##   <Returns>An FR machine underlying <A>obj</A>.</Returns>
##   <Description>
##     FR elements, FR groups etc. often have an underlying FR machine,
##     which is returned by this command.
##
## <Example><![CDATA[
## gap> m := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b ] )>
## gap> a := FRElement(m,1); b := FRElement(m,2);
## <2|a>
## <2|b>
## gap> UnderlyingFRMachine(a)=m;
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("FRMachine", [IsList, IsList]);
DeclareOperation("FRMachine", [IsList, IsList, IsList]);
DeclareOperation("FRMachineNC", [IsFamily, IsSemigroup, IsList, IsList]);
DeclareOperation("FRMachine", [IsSemigroup, IsList, IsList]);
DeclareAttribute("UnderlyingFRMachine",IsFRObject);
#############################################################################

############################################################################
##
#A StateSet . . . . . . . . . . . . . . . . . the set of states of a machine
#A GeneratorsOfFRMachine . . .generators for the stateset (if a free object)
##
## <#GAPDoc Label="StateSet">
## <ManSection>
##   <Attr Name="StateSet" Arg="m" Label="FR machine"/>
##   <Returns>The set of states associated with <A>m</A>.</Returns>
##   <Description>
##     This function returns the stateset of <A>m</A>. It can be
##     either a list (if the machine is of Mealy type), or a free
##     group/semigroup/monoid (in all other cases).
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ tau, mu ] )>
## gap> StateSet(n);
## <free group on the generators [ tau, mu ]>
## gap> StateSet(AsMealyMachine(n));
## [ 1 .. 4 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="GeneratorsOfFRMachine" Arg="m"/>
##   <Returns>The generating set of the stateset of <A>m</A>.</Returns>
##   <Description>
##     This function returns the generating set of the stateset of
##     <A>m</A>. If <A>m</A> is a Mealy machine, it returs
##     the stateset.
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ tau, mu ] )>
## gap> GeneratorsOfFRMachine(n);
## [ tau, mu ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("StateSet", IsFRObject);
DeclareAttribute("GeneratorsOfFRMachine", IsFRMachine);
#############################################################################

############################################################################
##
#O Output . . . . . . .the transformation of the alphabet induced by a state
#O Transition . . . . .the state reached from a given state on a given input
#A WreathRecursion . . . . . . . . . .returns a function computing the above
##
## <#GAPDoc Label="Output/machine">
## <ManSection>
##   <Oper Name="Output" Arg="m,s" Label="FR machine,state"/>
##   <Oper Name="Output" Arg="m,s,x" Label="FR machine,state,letter"/>
##   <Returns>A transformation of <A>m</A>'s alphabet.</Returns>
##   <Description>
##     This function returns the transformation of <A>m</A>'s
##     alphabet associated with state <A>s</A>. This transformation is
##     returned as a list of images.
##
##     <P/> <A>s</A> is also allowed to be a list, in which case it is
##     interpreted as the corresponding product of states.
##
##     <P/> In the second form, the result is actually the image of <A>x</A>
##     under <C>Output(m,s)</C>.
## <Example><![CDATA[
## gap> n := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b ] )>
## gap> Output(n,[1,2]);
## [2,1]
## gap> Output(n,Product(GeneratorsOfFRMachine(n)));
## [2,1]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Transition" Arg="m,s,i" Label="FR machine,state,input"/>
##   <Returns>An element of <A>m</A>'s stateset.</Returns>
##   <Description>
##     This function returns the state reached by <A>m</A> when
##     started in state <A>s</A> and fed input <A>i</A>. This
##     input may be an alphabet letter or a sequence of alphabet letters.
## <Example><![CDATA[
## gap> n := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b ] )>
## gap> Transition(n,[2,1],2);
## a*b
## gap> Transition(n,Product(GeneratorsOfFRMachine(n))^2,1);
## a*b
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Transitions" Arg="m,s" Label="FR machine,state"/>
##   <Returns>A list of elements of <A>m</A>'s stateset.</Returns>
##   <Description>
##     This function returns the states reached by <A>m</A> when
##     started in state <A>s</A> and fed inputs from the alphabet.
##     The state may be expressed as a word or as a list of states.
## <Example><![CDATA[
## gap> n := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b ] )>
## gap> Transitions(n,[2,1]);
## [ <identity ...>, a*b ]
## gap> Transitions(n,Product(GeneratorsOfFRMachine(n))^2);
## [ a*b, b*a ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="WreathRecursion" Arg="m"/>
##   <Returns>A function on the stateset of <A>m</A>.</Returns>
##   <Description>
##     This function returns a function on <A>m</A>'s
##     stateset. This function, on receiving state <A>q</A> as input,
##     returns a list. Its first entry is a list indexed by
##     <A>m</A>'s alphabet, with in position <A>x</A> the state
##     <A>m</A> would be in if it received input <A>x</A> when in
##     state <A>q</A>. The second entry is the list of the permutation
##     of <A>m</A>'s alphabet induced by <A>q</A>.
##
##     <P/> <A>WreathRecursion(machine)(q)[1][a]</A> is equal to
##     <A>Transition(machine,q,a)</A> and <A>WreathRecursion(machine)(q)[2]</A>
##     is equal to <A>Output(machine,q)</A>.
## <Example><![CDATA[
## gap> n := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b ] )>
## gap> WreathRecursion(n)(GeneratorsOfFRMachine(n)[1]);
## [ [ <identity ...>, b ], [2,1] ]
## gap> WreathRecursion(n)(GeneratorsOfFRMachine(n)[2]);
## [ [ <identity ...>, a ], [1,2] ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("WreathRecursion", IsFRMachine);
DeclareOperation("VirtualEndomorphism", [IsFRMachine, IsObject]);
DeclareOperation("Output", [IsFRMachine, IsObject]);
DeclareOperation("Output", [IsFRMachine, IsObject, IsObject]);
DeclareOperation("Transition", [IsFRMachine, IsObject, IsObject]);
DeclareOperation("Transitions", [IsFRMachine, IsObject]);
#############################################################################

#############################################################################
##
#O FRMachineRWS . . . . . . . . . . . . . . . . . . . . . . .rewriting system
##
## <#GAPDoc Label="FRMachineRWS">
## <ManSection>
##   <Attr Name="FRMachineRWS" Arg="m"/>
##   <Returns>A record containing a rewriting system for <A>m</A>.</Returns>
##   <Description>
##     Elements of an FR machine are compared using a rewriting system, which
##     records all known relations among states of the machine.
##
##     <P/> One may specify via an optional argument <C>:fr_maxlen:=n</C>,
##     the maximal length of rules to be added. By default, this maximum
##     length is 5.
##
## <Example><![CDATA[
## gap> n := FRMachine(["a","b"],[[[],[2]],[[],[1]]],[(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b ] )>
## gap> FRMachineRWS(n);
## rec( rws := Knuth Bendix Rewriting System for Monoid( [ a^-1, a, b^-1, b
##      ], ... ) with rules
##     [ [ a^-1*a, <identity ...> ], [ a*a^-1, <identity ...> ],
##       [ b^-1*b, <identity ...> ], [ b*b^-1, <identity ...> ] ],
##   tzrules := [ [ [ 1, 2 ], [  ] ], [ [ 2, 1 ], [  ] ], [ [ 3, 4 ], [  ] ],
##       [ [ 4, 3 ], [  ] ] ], letterrep := function( w ) ... end,
##   pi := function( w ) ... end, reduce := function( w ) ... end,
##   addgprule := function( w ) ... end, commit := function(  ) ... end,
##   restart := function(  ) ... end )
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("FRMachineRWS",IsFRMachine,"mutable");
DeclareGlobalFunction("NewFRMachineRWS");
#############################################################################

#############################################################################
##
#M StructuralGroup
#M StructuralMonoid
#M StructuralSemigroup
##
## <#GAPDoc Label="StructuralGroup">
## <ManSection>
##   <Oper Name="StructuralGroup" Arg="m"/>
##   <Oper Name="StructuralMonoid" Arg="m"/>
##   <Oper Name="StructuralSemigroup" Arg="m"/>
##   <Returns>A finitely presented group/monoid/semigroup capturing the structure of <A>m</A>.</Returns>
##   <Description>
##     This function returns a finitely presented group/monoid/semigroup,
##     with generators the union of the <Ref Attr="AlphabetOfFRObject"/> and
##     <Ref Attr="GeneratorsOfFRMachine"/> of <A>m</A>, and relations
##     all <M>qa'=aq'</M> whenever <M>\phi(q,a)=(a',q')</M>.
## <Example><![CDATA[
## gap> n := FRMachine(["a","b","c"],[[[2],[3]],[[3],[2]],[[1],[1]]],[(1,2),(1,2),()]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ a, b, c ] )>
## gap> StructuralGroup(n);
## <fp group on the generators [ a, b, c, 1, 2 ]>
## gap> RelatorsOfFpGroup(last);
## [ a*2*b^-1*1^-1, a*1*c^-1*2^-1, b*2*c^-1*1^-1,
##   b*1*b^-1*2^-1, c*1*a^-1*1^-1, c*2*a^-1*2^-1 ]
## gap> SimplifiedFpGroup(last2);
## <fp group on the generators [ a, 1 ]>
## gap> RelatorsOfFpGroup(last);
## [ 1^-1*a^2*1^4*a^-2*1^-1*a*1^-2*a^-1, 1*a*1^-1*a*1^2*a^-1*1*a^-2*1^-3*a,
##   1^-1*a^2*1^2*a^-1*1^-1*a*1^2*a^-2*1^-2 ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("StructuralGroup", [IsFRMachine]);
DeclareOperation("StructuralSemigroup", [IsFRMachine]);
DeclareOperation("StructuralMonoid", [IsFRMachine]);
#############################################################################

#############################################################################
##
#M \+
##
## <#GAPDoc Label="+">
## <ManSection>
##   <Meth Name="\+" Arg="m1,m2"/>
##   <Returns>A new FR machine, in the same family as its arguments.</Returns>
##   <Description>
##     This function returns a new FR machine <C>r</C>, with stateset generated by
##     the union of the statesets of its arguments.
##     The arguments <A>m1</A> and <A>m2</A> must operate on the
##     same alphabet. If the stateset of
##     <A>m1</A> is free on <M>n_1</M> letters and the stateset of
##     <A>m2</A> is free on <M>n_2</M> letters, then the stateset
##     of their sum is free on <M>n_1+n_2</M> letters, with the first
##     <M>n_1</M> identified with <A>m1</A>'s states and the next
##     <M>n_2</M> with <A>m2</A>'s.
##
##     <P/> The transition and output functions are naturally extended to
##     the sum.
##
##     <P/> The arguments may be free group, semigroup or monoid
##     machines. The sum is in the weakest containing category: it is
##     a group machine if both arguments are group machines; a monoid
##     if both are either group of monoid machines; and a semigroup
##     machine otherwise.
##
##     <P/> The maps from the stateset of <A>m1</A> and <A>m2</A>
##     to the stateset of <C>r</C> can be recovered as
##     <C>Correspondence(r)[1]</C> and <C>Correspondence(r)[2]</C>; see
##     <Ref Attr="Correspondence" Label="FR machine"/>.
## <Example><![CDATA[
## gap> tau := FRMachine([[[],[1]]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
## gap> mu := FRMachine([[[],[-1]]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
## gap> sum := tau+mu;; Display(sum);
##      |     1          2
## -----+--------+----------+
##  f11 | <id>,2      f11,1
##  f12 | <id>,2   f12^-1,1
## -----+--------+----------+
## gap> Correspondence(sum)[1];
## [ f1 ] -> [ f11 ]
## gap> GeneratorsOfFRMachine(tau)[1]^last;
## f11
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="\*" Arg="machine1,machine2"/>
##   <Returns>A new FR machine, in the same family as its arguments.</Returns>
##   <Description>
##     The product of two FR machines coincides with their sum, since the
##     natural free object mapping to the product of the statesets is
##     generated by the union of the statesets. See therefore
##     <Ref Meth="\+"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="TensorSumOp" Arg="FR_machines, machine" Label="FR Machines"/>
##   <Returns>A new FR machine on the disjoint union of the arguments' alphabets.</Returns>
##   <Description>
##     The tensor sum of FR machines with
##     same stateset is defined as the FR machine acting on the disjoint
##     union of the alphabets; if these alphabets are <C>[1..n1]</C> up to
##     <C>[1..nk]</C>, then the alphabet of their sum is
##     <C>[1..n1+...+nk]</C> and the transition functions are similarly
##     concatenated.
##     <P/>
##     The first argument is a list; the second argument is any element of
##     that list, and is used only to improve the method selection algorithm.
## <Example><![CDATA[
## gap> m := TensorSum(AddingMachine(2),AddingMachine(3),AddingMachine(4));
## AddingMachine(2)(+)AddingMachine(3)(+)AddingMachine(4)
## gap> Display(m);
##    |  1     2     3     4     5     6     7     8     9
## ---+-----+-----+-----+-----+-----+-----+-----+-----+-----+
##  a | a,1   a,2   a,3   a,4   a,5   a,6   a,7   a,8   a,9
##  b | a,2   b,1   a,4   a,5   b,3   a,7   a,8   a,9   b,6
## ---+-----+-----+-----+-----+-----+-----+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="TensorProductOp" Arg="FR machines,machine" Label="FR Machines"/>
##   <Returns>A new FR machine on the cartesian product of the arguments' alphabets.</Returns>
##   <Description>
##     The tensor product of FR machines with
##     same stateset is defined as the FR machine acting on the cartesian
##     product of the alphabets. The transition function and output function
##     behave as if a single letter, in the tensor product's alphabet, were
##     a word (read from left to right) in the machines' alphabets.
##     <P/>
##     The first argument is a list; the second argument is any element of
##     that list, and is used only to improve the method selection algorithm.
## <Example><![CDATA[
## gap> m := TensorProduct(AddingMachine(2),AddingMachine(3));
## AddingMachine(2)(*)AddingMachine(3)
## gap> Display(last);
##    |  1     2     3     4     5     6
## ---+-----+-----+-----+-----+-----+-----+
##  a | a,1   a,2   a,3   a,4   a,5   a,6
##  b | a,4   a,5   a,6   a,2   a,3   b,1
## ---+-----+-----+-----+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="DirectSumOp" Arg="FR machines,machine" Label="FR Machines"/>
##   <Returns>A new FR machine on the disjoint union of the arguments' alphabets.</Returns>
##   <Description>
##     The direct sum of FR machines is defined as the FR machine with stateset
##     generated by the disjoint union of the statesets, acting on the disjoint
##     union of the alphabets; if these alphabets are <C>[1..n1]</C> up to
##     <C>[1..nk]</C>, then the alphabet of their sum is
##     <C>[1..n1+...+nk]</C> and the output and transition functions are
##     similarly concatenated.
##     <P/>
##     The first argument is a list; the second argument is any element of
##     that list, and is used only to improve the method selection algorithm.
## <Example><![CDATA[
## gap> m := DirectSum(AddingMachine(2),AddingMachine(3),AddingMachine(4));
## AddingMachine(2)#AddingMachine(3)#AddingMachine(4)
## gap> Display(m);
##    |  1     2     3     4     5     6     7     8     9
## ---+-----+-----+-----+-----+-----+-----+-----+-----+-----+
##  a | a,1   a,2   a,3   a,4   a,5   a,6   a,7   a,8   a,9
##  b | a,2   b,1   b,3   b,4   b,5   b,6   b,7   b,8   b,9
##  c | c,1   c,2   a,3   a,4   a,5   c,6   c,7   c,8   c,9
##  d | d,1   d,2   a,4   a,5   b,3   d,6   d,7   d,8   d,9
##  e | e,1   e,2   e,3   e,4   e,5   a,6   a,7   a,8   a,9
##  f | f,1   f,2   f,3   f,4   f,5   a,7   a,8   a,9   b,6
## ---+-----+-----+-----+-----+-----+-----+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="DirectProductOp" Arg="FR machines,machine" Label="FR Machines"/>
##   <Returns>A new FR machine on the cartesian product of the arguments' alphabets.</Returns>
##   <Description>
##     The direct product of FR machines is defined as the FR machine with stateset
##     generated by the product of the statesets, acting on the product
##     of the alphabets; if these alphabets are <C>[1..n1]</C> up to
##     <C>[1..nk]</C>, then the alphabet of their product is
##     <C>[1..n1*...*nk]</C> and the output and transition functions act
##     component-wise.
##     <P/>
##     The first argument is a list; the second argument is any element of
##     that list, and is used only to improve the method selection algorithm.
## <Example><![CDATA[
## gap> m := DirectProduct(AddingMachine(2),AddingMachine(3));
## AddingMachine(2)xAddingMachine(3)
## gap> Display(last);
##    |  1     2     3     4     5     6
## ---+-----+-----+-----+-----+-----+-----+
##  a | a,1   a,2   a,3   a,4   a,5   a,6
##  b | a,2   a,3   b,1   a,5   a,6   b,4
##  c | a,4   a,5   a,6   c,1   c,2   c,3
##  d | a,5   a,6   b,4   c,2   c,3   d,1
## ---+-----+-----+-----+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Meth Name="TreeWreathProduct" Arg="m,n,x0,y0" Label="FR machine"/>
##   <Returns>A new FR machine on the cartesian product of the arguments' alphabets.</Returns>
##   <Description>
##     The <E>tree-wreath product</E> of two FR machines is a machine acting
##     on the product of its arguments' alphabets <M>X,Y</M>, in such a way
##     that many images of the first machine's states under
##     conjugation by the second commute.
##
##     <P/> It is introduced (in lesser generality, and with small variations)
##     in <Cite Key="MR2197828"/>, and may be described as follows:
##     one takes two copies of the stateset of <A>m</A>,
##     one copy of the stateset of <A>n</A>, and, if necessary,
##     an extra identity state.
##
##     <P/> The first copy of <A>m</A> fixes the alphabet <M>X\times Y</M>;
##     its state <M>\tilde s</M> has transitions to the identity except
##     <M>\tilde s</M> at <M>(x0,y0)</M> and <M>s</M> at <M>(*,y0)</M> for any
##     other <M>*</M>. The second copy of <A>m</A> is also trivial except
##     that, on input <M>(x,y0)</M>, its state <M>s</M> goes to state <M>s'</M>
##     with output <M>(x',y0)</M> whenever <M>s</M> originally went, on
##     input <M>x</M>, to state <M>s'</M> with output <M>x'</M>. This copy of
##     <A>m</A> therefore acts only in the <M>X</M> direction, on the subtree
##     <M>(X\times\{y0\})^\infty</M>, on subtrees below vertices of the form
##     <M>(x0,y0)^t(x,y0)</M>.
##
##     <P/> A state <M>t</M> in the copy of <A>n</A> maps the input
##     <M>(x,y)</M> to <M>(x,y')</M> and proceeds to state <M>t'</M> if
##     <M>y=y0</M>, and to the identity state otherwise, when on input
##     <M>y</M> the original machine mapped state <M>t</M> to output <M>t'</M>
##     and output <M>y'</M>.
## <Example><![CDATA[
## gap> m := TreeWreathProduct(AddingMachine(2),AddingMachine(3),1,1);
## AddingMachine(2)~AddingMachine(3)
## gap> Display(last);
##    |  1     2     3     4     5     6
## ---+-----+-----+-----+-----+-----+-----+
##  a | c,2   c,3   a,1   c,5   c,6   c,4
##  b | c,4   c,2   c,3   b,1   c,5   c,6
##  c | c,1   c,2   c,3   c,4   c,5   c,6
##  d | d,1   c,2   c,3   b,4   c,5   c,6
## ---+-----+-----+-----+-----+-----+-----+
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("TensorSumOp", [IsList,IsFRMachine]);
DeclareOperation("TensorProductOp", [IsList,IsFRMachine]);
DeclareOperation("DirectSumOp", [IsList,IsFRMachine]);
DeclareOperation("DirectProductOp", [IsList,IsFRMachine]);
DeclareOperation("TreeWreathProduct", [IsFRMachine,IsFRMachine,IsObject,IsObject]);
#############################################################################

#############################################################################
##
#M AsXXXFRMachine
##
## <#GAPDoc Label="AsGroupFRMachine">
## <ManSection>
##   <Attr Name="AsGroupFRMachine" Arg="m"/>
##   <Attr Name="AsMonoidFRMachine" Arg="m"/>
##   <Attr Name="AsSemigroupFRMachine" Arg="m"/>
##   <Returns>An FR machine isomorphic to <A>m</A>, on a free group/monoid/semigroup.</Returns>
##   <Description>
##     This function constructs, from the FR machine <A>m</A>, an isomorphic
##     FR machine <C>n</C> with a free group/monoid/semigroup as stateset.
##     The attribute
##     <C>Correspondence(n)</C> is a mapping (homomorphism or list) from
##     the stateset of <A>m</A> to the stateset of <C>n</C>.
##
##     <P/><A>m</A> can be an arbitrary FR machine, or can be an free
##     group/monoid/semigroup endomorphism. It is then converted to an
##     FR machine on a 1-letter alphabet.
## <Example><![CDATA[
## gap> s := FreeSemigroup(1);;
## gap> sm := FRMachine(s,[[GeneratorsOfSemigroup(s)[1],
##                          GeneratorsOfSemigroup(s)[1]^2]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Semigroup( [ s1 ] )>
## gap> m := FreeMonoid(1);;
## gap> mm := FRMachine(m,[[One(m),GeneratorsOfMonoid(m)[1]^2]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Monoid( [ m1 ], ... )>
## gap> g := FreeGroup(1);;
## gap> gm := FRMachine(g,[[One(g),GeneratorsOfGroup(g)[1]^-2]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
## gap> AsGroupFRMachine(sm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
##     |   1        2
## ----+------+--------+
##  f1 | f1,2   f1^2,1
## ----+------+--------+
## gap> Correspondence(last);
## MappingByFunction( <free semigroup on the generators
## [ s1 ]>, <free group on the generators [ f1 ]>, function( w ) ... end )
## gap> AsGroupFRMachine(mm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
##     |     1        2
## ----+--------+--------+
##  f1 | <id>,2   f1^2,1
## ----+--------+--------+
## gap> AsGroupFRMachine(gm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
##     |     1         2
## ----+--------+---------+
##  f1 | <id>,2   f1^-2,1
## ----+--------+---------+
## gap> AsMonoidFRMachine(sm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Monoid( [ m1 ], ... )>
##     |   1        2
## ----+------+--------+
##  m1 | m1,2   m1^2,1
##   ----+------+--------+
## gap> AsMonoidFRMachine(mm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Monoid( [ m1 ], ... )>
##     |     1        2
## ----+--------+--------+
##  m1 | <id>,2   m1^2,1
## ----+--------+--------+
## gap> AsMonoidFRMachine(gm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Monoid( [ m1, m2 ], ... )>
##     |     1        2
## ----+--------+--------+
##  m1 | <id>,2   m2^2,1
##  m2 | m1^2,2   <id>,1
## ----+--------+--------+
## gap> AsSemigroupFRMachine(sm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Semigroup( [ s1 ] )>
##     |   1        2
## ----+------+--------+
##  s1 | s1,2   s1^2,1
## ----+------+--------+
## gap> AsSemigroupFRMachine(mm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Semigroup( [ s1, s2 ] )>
##     |   1        2
## ----+------+--------+
##  s1 | s2,2   s1^2,1
##  s2 | s2,1     s2,2
## ----+------+--------+
## gap> AsSemigroupFRMachine(gm); Display(last);
## <FR machine with alphabet [ 1, 2 ] on Semigroup( [ s1, s2, s3 ] )>
##     |     1        2
## ----+--------+--------+
##  s1 |   s3,2   s2^2,1
##  s2 | s1^2,2     s3,1
##  s3 |   s3,1     s3,2
## ----+--------+--------+
## gap>
## gap> Display(GuptaSidkiMachines(3));
##    |  1     2     3
## ---+-----+-----+-----+
##  a | a,1   a,2   a,3
##  b | a,2   a,3   a,1
##  c | a,3   a,1   a,2
##  d | b,1   c,2   d,3
## ---+-----+-----+-----+
## gap> AsGroupFRMachine(GuptaSidkiMachines(3));
## <FR machine with alphabet [ 1 .. 3 ] on Group( [ f1, f2 ] )>
## gap> Display(last);
##     |     1         2        3
## ----+--------+---------+--------+
##  f1 | <id>,2    <id>,3   <id>,1
##  f2 |   f1,1   f1^-1,2     f2,3
## ----+--------+---------+--------+
## gap> Correspondence(last);
## [ <identity ...>, f1, f1^-1, f2 ]
## gap> AsGroupFRMachine(GroupHomomorphism(g,g,[g.1],[g.1^3]));
## <FR machine with alphabet [ 1 ] on Group( [ f1 ] )>
## gap> Display(last);
##  G  |     1
## ----+--------+
##  f1 | f1^3,1
## ----+--------+
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("AsGroupFRMachine", IsFRMachine);
DeclareAttribute("AsMonoidFRMachine", IsFRMachine);
DeclareAttribute("AsSemigroupFRMachine", IsFRMachine);
#############################################################################

#############################################################################
##
#M SubFRMachine
##
## <#GAPDoc Label="SubFRMachine">
## <ManSection>
##   <Oper Name="SubFRMachine" Arg="machine1,machine2"/>
##   <Oper Name="SubFRMachine" Arg="machine1,f" Label="machine,map"/>
##   <Returns>Either <K>fail</K> or an embedding of the states of <A>machine2</A> in the states of <A>machine1</A>.</Returns>
##   <Description>
##     In its first form, this function attempts to locate a copy of
##     <A>machine2</A> in <A>machine1</A>. If is succeeds, it returns
##     a homomorphism from the stateset of <A>machine2</A> into the
##     stateset of <A>machine1</A>; otherwise it returns <K>fail</K>.
##     <P/>
##     In its second form, this function attempts to construct a machine
##     with stateset the source of <A>f</A>, that could be identified as
##     a submachine of <A>machine1</A> via <A>f</A>.
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ tau, mu ] )>
## gap> tauinv := FRMachine([[[1],[]]],[(1,2)]);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
## gap> SubFRMachine(n,tauinv);
## [ f1 ] -> [ tau^-1 ]
## gap> SubFRMachine(n,last);
## <FR machine with alphabet [ 1, 2 ] on Group( [ f1 ] )>
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("SubFRMachine", [IsFRMachine,IsFRMachine]);
DeclareOperation("SubFRMachine", [IsFRMachine,IsMapping]);
#############################################################################

#############################################################################
##
#M Minimized
##
## <#GAPDoc Label="FR-Minimized">
## <ManSection>
##   <Oper Name="Minimized" Arg="m" Label="FR machine"/>
##   <Returns>A minimized machine equivalent to <A>m</A>.</Returns>
##   <Description>
##     This function attempts to construct a machine equivalent to <A>m</A>,
##     but with a stateset of smaller rank. Identical generators are collapsed
##     to a single generator of the stateset; if <A>m</A> is a group or monoid
##     machine then trivial generators are removed; if <A>m</A> is a group
##     machine then mutually inverse generators are grouped.
##
##     This function sets as <C>Correspondence(result)</C> a mapping between
##     the stateset of <A>m</A> and the stateset of the result; see
##     <Ref Attr="Correspondence" Label="FR machine"/>.
## <Example><![CDATA[
## gap> n := FRMachine(["tau","mu"],[[[],[1]],[[],[-2]]],[(1,2),(1,2)]);;
## gap> m := FRMachine(["tauinv"],[[[1],[]]],[(1,2)]);;
## gap> sum := n+m+n;
## <FR machine with alphabet [ 1, 2 ] on Group( [ tau1, mu1, tauinv1, tau2, mu2 ] )>
## gap> min := Minimized(sum);
## <FR machine with alphabet [ 1, 2 ] on Group( [ tau1, mu1 ] )>
## gap> Correspondence(min);
## [ tau1, mu1, tauinv1, tau2, mu2 ] -> [ tau1, mu1, tau1^-1, tau1, mu1 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="Correspondence" Arg="m" Label="FR machine"/>
##   <Returns>A mapping between statesets of FR machines.</Returns>
##   <Description>
##     If a machine <A>m</A> was created as a minimized
##     group/monoid/semigroup machine, then <C>Correspondence(m)</C>
##     is a mapping between the stateset of the original machine and the
##     stateset of <A>m</A>. See
##     <Ref Attr="Minimized" Label="FR machine"/> for an example.
##
##     <P/> If <A>m</A> was created as a minimized
##     Mealy machine, then <C>Correspondence(m)</C>
##     is a list identifying, for each state of the original machine, a state
##     of the new machine. If the original state is inaccessible, the
##     corresponding list entry is unbound. See
##     <Ref Attr="Minimized" Label="Mealy machine"/> for an example.
##
##     <P/> If <A>m</A> was created using
##     <Ref Attr="AsGroupFRMachine"/>,
##     <Ref Attr="AsMonoidFRMachine"/>,
##     <Ref Attr="AsSemigroupFRMachine"/>,
##     or <Ref Attr="AsMealyMachine" Label="FR machine"/>, then <C>Correspondence(m)</C>
##     is a list or a homomorphism identifying for each generator of the
##     original machine a generator, or word in the generators, of the
##     new machine. It is a list if either the original or the final
##     machine is a Mealy machine, and a homomorphism in other cases.
##
##     <P/> If <A>m</A> was created as a sum of two machines, then
##     <A>m</A> has a mapping <C>Correspondence(m)[i]</C> between the
##     stateset of machine <C>i=1,2</C> and its own stateset. See
##     <Ref Meth="\+"/> for an example.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("Minimized", [IsFRMachine]);
DeclareAttribute("Correspondence", IsFRMachine);
#############################################################################

#E frmachine.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
