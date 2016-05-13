#############################################################################
##
#W  irredsol.gd                 GAP group library                  Mark Short
#W                                                           Burkhard Höfling
##
##
#Y  Copyright (C) 1993, Murdoch University, Perth, Australia
##
##  This file contains the  functions and  data for the  irreducible solvable
##  matrix group library.  It  contains  exactly one member  for each of  the
##  372  conjugacy  classes of  irreducible  solvable subgroups of  $GL(n,p)$
##  where $1 < n$, $p$ is a prime, and $p^n < 256$.  
##
##  By well-known  theory, this data also  doubles as a  library of primitive
##  solvable permutation groups of non-prime degree $<256$. 
##
##  This file contains the data  from Mark Short's thesis,  plus  two  groups 
##  missing from that list, subsequently discovered by Alexander Hulpke.
##

#############################################################################
##
#V  IrredSolJSGens[]  . . . . . . . . . . . . . . . generators for the groups
##
##  <ManSection>
##  <Var Name="IrredSolJSGens"/>
##
##  <Description>
##  <C>IrredSolJSGens[<A>n</A>][<A>p</A>][<A>k</A>]</C> is a generating set
##  for the <A>k</A>-th JS-maximal of GL(<A>n</A>,<A>p</A>).
##  This generating set is polycyclic, i.e. forms an AG-system for the group.
##  A JS-maximal is a maximal irreducible solvable subgroup of
##  GL(<A>n</A>,<A>p</A>)
##  (for a few exceptional small values of n and p this group isn't maximal).
##  Every group in the library is generated with reference to the generating
##  set of one of these JS-maximals, called its guardian (a group may be a
##  subgroup of several JS-maximals but it only has one guardian).
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable("IrredSolJSGens");

#############################################################################
##
#V  IrredSolGroupList[] . . . . . . . . . . . . . . description of the groups
##
##  <ManSection>
##  <Var Name="IrredSolGroupList"/>
##
##  <Description>
##  <C>IrredSolGroupList[<A>n</A>][<A>p</A>][<A>i</A>]</C> is a list containing the information
##  about the <A>i</A>-th group from GL(<A>n</A>,<A>p</A>).
##  The groups are ordered with respect to the following criteria:
##      1. Increasing size
##      2. Increasing guardian number
##  If two groups have the same size and guardian, they are in no particular
##  order.
##  <P/>
##  The list <C>IrredSolGroupList[<A>n</A>][<A>p</A>][<A>i</A>]</C> contains the following info:
##  Position: [1]:   the size of the group
##            [2]:   0 if group is linearly primitive,
##                   otherwise its minimal block size
##            [3]:   the absolute value is the number of the group's guardian,
##                   i.e. its position in 'IrredSolJSGens[<A>n</A>][<A>p</A>]',
##                   it's negative iff it equals its guardian
##            [4..]: the group's generators in normal form
##                   (with respect to its guardian's AG-system)
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable ("IrredSolGroupList");


#############################################################################
##
#F  IrreducibleSolvableGroup( <n>, <p>, <i> )
##
##  <#GAPDoc Label="IrreducibleSolvableGroup">
##  <ManSection>
##  <Func Name="IrreducibleSolvableGroup" Arg='n, p, i'/>
##
##  <Description>
##  This function is obsolete, because for <A>n</A> <M>= 2</M>,
##  <A>p</A> <M>= 13</M>,  two groups were missing from the
##  underlying database. It has been replaced by the function
##  <Ref Func="IrreducibleSolvableGroupMS"/>. Please note that the latter
##  function does not guarantee any ordering of the groups in the database.
##  However, for values of <A>n</A>, <A>p</A>, and <A>i</A> admissible to
##  <Ref Func="IrreducibleSolvableGroup"/>,
##  <Ref Func="IrreducibleSolvableGroupMS"/> returns a representative of the
##  same conjugacy class of subgroups of GL(<A>n</A>, <A>p</A>) as
##  <Ref Func="IrreducibleSolvableGroup"/> did before. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IrreducibleSolvableGroup");

#############################################################################
##
#F  IrreducibleSolvableGroupMS( <n>, <p>, <i> )
##
##  <#GAPDoc Label="IrreducibleSolvableGroupMS">
##  <ManSection>
##  <Func Name="IrreducibleSolvableGroupMS" Arg='n, p, i'/>
##
##  <Description>
##  This function returns a representative of the <A>i</A>-th conjugacy class
##  of irreducible solvable subgroup of GL(<A>n</A>, <A>p</A>),
##  where <A>n</A> is an integer <M>&gt; 1</M>, <A>p</A> is a prime,
##  and <M><A>p</A>^{<A>n</A>} &lt; 256</M>.
##  <P/>
##  The numbering of the representatives should be 
##  considered arbitrary. However, it is guaranteed that the <A>i</A>-th 
##  group on this list will lie in the same conjugacy class in all future
##  versions of &GAP;, unless two (or more) groups on the list are discovered
##  to be duplicates,
##  in which case <Ref Func="IrreducibleSolvableGroupMS"/> will return
##  <K>fail</K> for all but one of the duplicates. 
##  <P/>
##  For values of <A>n</A>, <A>p</A>, and <A>i</A> admissible to
##  <Ref Func="IrreducibleSolvableGroup"/>,
##  <Ref Func="IrreducibleSolvableGroupMS"/> returns a representative of
##  the same conjugacy class of subgroups of GL(<A>n</A>, <A>p</A>) as
##  <Ref Func="IrreducibleSolvableGroup"/>.
##  Note that it currently adds two more groups (missing from the
##  original list by Mark Short) for <A>n</A> <M>= 2</M>,
##  <A>p</A> <M>= 13</M>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IrreducibleSolvableGroupMS");

#############################################################################
##
#F  NumberIrreducibleSolvableGroups( <n>, <p> )
##
##  <#GAPDoc Label="NumberIrreducibleSolvableGroups">
##  <ManSection>
##  <Func Name="NumberIrreducibleSolvableGroups" Arg='n, p'/>
##
##  <Description>
##  This function returns the number of conjugacy classes of 
##  irreducible solvable subgroup of 
##  GL(<A>n</A>, <A>p</A>). 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NumberIrreducibleSolvableGroups");
DeclareSynonym("NrIrreducibleSolvableGroups",NumberIrreducibleSolvableGroups);

#############################################################################
##
#F  AllIrreducibleSolvableGroups( <func1>, <val1>, <func2>, <val2>, ... )
##
##  <#GAPDoc Label="AllIrreducibleSolvableGroups">
##  <ManSection>
##  <Func Name="AllIrreducibleSolvableGroups"
##   Arg='func1, val1, func2, val2, ...'/>
##
##  <Description>
##  This function returns a list  of conjugacy class representatives <M>G</M>
##  of matrix groups over a prime field such that
##  <M>f(G) = v</M> or <M>f(G) \in v</M>, for all pairs <M>(f,v)</M> in
##  (<A>func1</A>, <A>val1</A>), (<A>func2</A>, <A>val2</A>), <M>\ldots</M>.
##  The following possibilities for the functions <M>f</M> 
##  are particularly efficient, because the values can be read off the
##  information in the data base:
##  <C>DegreeOfMatrixGroup</C> (or
##  <Ref Func="Dimension"/> or <Ref Func="DimensionOfMatrixGroup"/>) for the
##  linear degree,
##  <Ref Func="Characteristic"/> for the field characteristic,
##  <Ref Func="Size"/>, <C>IsPrimitiveMatrixGroup</C>
##  (or <C>IsLinearlyPrimitive</C>), and
##  <C>MinimalBlockDimension</C>>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AllIrreducibleSolvableGroups");

#############################################################################
##
#F  OneIrreducibleSolvableGroup( <func1>, <val1>, <func2>, <val2>, ...)
##
##  <#GAPDoc Label="OneIrreducibleSolvableGroup">
##  <ManSection>
##  <Func Name="OneIrreducibleSolvableGroup"
##   Arg='func1, val1, func2, val2, ...'/>
##
##  <Description>
##  This function returns one solvable subgroup <M>G</M> of a
##  matrix group over a prime field such that
##  <M>f(G) = v</M> or <M>f(G) \in v</M>, for all pairs <M>(f,v)</M> in
##  (<A>func1</A>, <A>val1</A>), (<A>func2</A>, <A>val2</A>), <M>\ldots</M>.
##  The following possibilities for the functions <M>f</M>
##  are particularly efficient, because the values can be read off the
##  information in the data base:
##  <C>DegreeOfMatrixGroup</C> (or
##  <Ref Func="Dimension"/> or <Ref Func="DimensionOfMatrixGroup"/>) for the
##  linear degree,
##  <Ref Func="Characteristic"/> for the field characteristic,
##  <Ref Func="Size"/>, <C>IsPrimitiveMatrixGroup</C>
##  (or <C>IsLinearlyPrimitive</C>), and
##  <C>MinimalBlockDimension</C>>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OneIrreducibleSolvableGroup");

#############################################################################
##
#A  DegreeOfMatrixGroup(<G>)
##
##  <ManSection>
##  <Attr Name="DegreeOfMatrixGroup" Arg='G'/>
##
##  <Description>
##  This function returns the dimension of the underlying vector space,
##  same as <C>DimensionOfMatrixGroup</C>
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr ("DegreeOfMatrixGroup", DimensionOfMatrixGroup);

#############################################################################
##
#A  MinimalBlockDimension(<G>)
##
##  <ManSection>
##  <Attr Name="MinimalBlockDimension" Arg='G'/>
##
##  <Description>
##  The minimum integer <A>n</A> such that the matrix group has an imprimitivity
##  system consisting of <A>n</A>-dimensional subspaces of the underlying vector
##  space over <C>FieldOfMatrixGroup(G)</C>
##  </Description>
##  </ManSection>
##
DeclareAttribute("MinimalBlockDimension", IsMatrixGroup);

#############################################################################
##
#P  IsPrimitiveMatrixGroup(<G>)
##
##  <ManSection>
##  <Prop Name="IsPrimitiveMatrixGroup" Arg='G'/>
##
##  <Description>
##  <K>true</K> if <A>G</A> is primitive over <C>FieldOfMatrixGroup(G)</C> 
##  </Description>
##  </ManSection>
##
DeclareProperty("IsPrimitiveMatrixGroup", IsMatrixGroup);
DeclareSynonymAttr ("IsLinearlyPrimitive", IsPrimitiveMatrixGroup);


#############################################################################
##
#E

