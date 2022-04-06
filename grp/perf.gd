#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for the Holt/Plesken library of
##  perfect groups
##


PERFRec := fail; # indicator that perf0.grp is not loaded
if IsHPCGAP then
    BindThreadLocal("PERFGRP", []);
else
    PERFGRP := [];
fi;


#############################################################################
##
#C  IsPerfectLibraryGroup(<G>)  identifier for groups constructed from the
##                              library (used for perm->fp isomorphism)
##
##  <ManSection>
##  <Filt Name="IsPerfectLibraryGroup" Arg='G' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory("IsPerfectLibraryGroup", IsGroup );


#############################################################################
##
#O  PerfGrpConst(<filter>,<descriptor>)
##
##  <ManSection>
##  <Oper Name="PerfGrpConst" Arg='filter,descriptor'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor("PerfGrpConst",[IsGroup,IsList]);


#############################################################################
##
#F  PerfGrpLoad(<size>)  force loading of secondary files, return index
##
##  <ManSection>
##  <Func Name="PerfGrpLoad" Arg='size'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("PerfGrpLoad");


#############################################################################
##
#A  PerfectIdentification(<G>) . . . . . . . . . . . . id. for perfect groups
##
##  <#GAPDoc Label="PerfectIdentification">
##  <ManSection>
##  <Attr Name="PerfectIdentification" Arg='G'/>
##
##  <Description>
##  This attribute is set for all groups obtained from the perfect groups
##  library and has the value <C>[<A>size</A>,<A>nr</A>]</C> if the group is obtained with
##  these parameters from the library.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("PerfectIdentification", IsGroup );


#############################################################################
##
#F  SizesPerfectGroups()
##
##  <#GAPDoc Label="SizesPerfectGroups">
##  <ManSection>
##  <Func Name="SizesPerfectGroups" Arg=''/>
##
##  <Description>
##  This is the ordered list of all numbers up to <M>2\cdot 10^6</M> that occur as
##  sizes of perfect groups.
##  One can iterate over part of the perfect groups library with:
##  <Example><![CDATA[
##  gap> for n in Intersection([100..500],SizesPerfectGroups()) do
##  >      for k in [1..NrPerfectGroups(n)] do
##  >        pg := PerfectGroup(n,k);
##  >      od;
##  >    od;
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SizesPerfectGroups");


#############################################################################
##
#F  NumberPerfectGroups( <size> ) . . . . . . . . . . . . . . . . . . . . . .
##
##  <#GAPDoc Label="NumberPerfectGroups">
##  <ManSection>
##  <Func Name="NumberPerfectGroups" Arg='size'/>
##  <Func Name="NrPerfectGroups" Arg='size'/>
##  <Func Name="NumberPerfectLibraryGroups" Arg='size'/>
##  <Func Name="NrPerfectLibraryGroups" Arg='size'/>
##
##  <Description>
##  returns the number of non-isomorphic perfect groups of size <A>size</A> for
##  each positive integer <A>size</A> up to <M>2\cdot10^6</M>. Additionally, for
##  odd <A>size</A> an answer is returned (odd order groups are solvable).
##  For any other argument out of range it returns <K>fail</K>.
##  <A>NrPerfectGroups</A> is a synonym for <Ref Func="NumberPerfectGroups"/>.
##  Moreover <A>NumberPerfectLibraryGroups</A> (and its synonym <A>NrPerfectLibraryGroups</A>)
##  exist for historical reasons, and return 0 instead of fail for arguments
##  outside the library scope.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NumberPerfectGroups");
DeclareSynonym("NrPerfectGroups",NumberPerfectGroups);
DeclareGlobalFunction("NumberPerfectLibraryGroups");
DeclareSynonym("NrPerfectLibraryGroups",NumberPerfectLibraryGroups);



#############################################################################
##
#F  PerfectGroup( [<filt>, ]<size>[, <n>] )
#F  PerfectGroup( [<filt>, ]<sizenumberpair> )
##
##  <#GAPDoc Label="PerfectGroup">
##  <ManSection>
##  <Heading>PerfectGroup</Heading>
##  <Func Name="PerfectGroup" Arg='[filt, ]size[, n]'
##   Label="for group order (and index)"/>
##  <Func Name="PerfectGroup" Arg='[filt, ]sizenumberpair'
##   Label="for a pair [ order, index ]"/>
##
##  <Description>
##  returns a group which is isomorphic to the library group specified
##  by the size number <C>[ <A>size</A>, <A>n</A> ]</C> or by the two
##  separate arguments <A>size</A> and <A>n</A>, assuming a default value of
##  <M><A>n</A> = 1</M>.
##  The optional argument <A>filt</A> defines the filter in which the group is
##  returned.
##  Possible filters so far are <Ref Filt="IsPermGroup"/> and
##  <Ref Filt="IsSubgroupFpGroup"/>.
##  In the latter case, the  generators and relators used coincide with those
##  given in&nbsp;<Cite Key="HP89"/>.
##  The default filter is <Ref Filt="IsPermGroup"/>.
##  <Example><![CDATA[
##  gap> G := PerfectGroup(IsPermGroup,6048,1);
##  U3(3)
##  gap> G:=PerfectGroup(IsPermGroup,823080,2);
##  A5 2^1 19^2 C 19^1
##  gap> NrMovedPoints(G);
##  6859
##  gap> G:=PerfectGroup(1866240,12);
##  PG1866240.12
##  gap> NrMovedPoints(G);
##  270
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PerfectGroup");


#############################################################################
##
#F  DisplayInformationPerfectGroups( <size>[, <n>] )  . . . . . . . . . . . .
#F  DisplayInformationPerfectGroups( <sizenumberpair>] )  . . . . . . . . . .
##
##  <#GAPDoc Label="DisplayInformationPerfectGroups">
##  <ManSection>
##  <Heading>DisplayInformationPerfectGroups</Heading>
##  <Func Name="DisplayInformationPerfectGroups" Arg='size[, n]'
##   Label="for group order (and index)"/>
##  <Func Name="DisplayInformationPerfectGroups" Arg='sizenumberpair'
##   Label="for a pair [ order, index ]"/>
##
##  <Description>
##  <Ref Func="DisplayInformationPerfectGroups" Label="for group order (and index)"/>
##  displays some invariants of the <A>n</A>-th group of order <A>size</A>
##  from the perfect groups library.
##  <P/>
##  If no value of <A>n</A> has been specified, the invariants will be
##  displayed for all groups of size <A>size</A> available in the library.
##  <P/>
##  Alternatively, also a list of length two may be entered as the only
##  argument, with entries <A>size</A> and <A>n</A>.
##  <P/>
##  The information provided for <M>G</M> includes the following items:
##  <List>
##  <Item>
##        a headline containing the size number <C>[ <A>size</A>, <A>n</A> ]</C> of <M>G</M>
##        in the form <C><A>size</A>.<A>n</A></C> (the suffix <C>.<A>n</A></C> will be suppressed
##        if, up to isomorphism, <M>G</M> is the only perfect group of order
##        <A>size</A>),
##  </Item>
##  <Item>
##   a message if <M>G</M> is simple  or quasisimple, i.e.,
##        if the factor group of <M>G</M> by its centre is simple,
##  </Item>
##  <Item>
##   the <Q>description</Q> of  the structure of  <M>G</M> as it is
##      given by Holt and Plesken in&nbsp;<Cite Key="HP89"/> (see below),
##  </Item>
##  <Item>
##   the size of  the centre of <M>G</M>  (suppressed, if <M>G</M> is
##      simple),
##  </Item>
##  <Item>
##   the prime decomposition of the size of <M>G</M>,
##  </Item>
##  <Item>
##   orbit sizes for  a faithful permutation representation
##      of <M>G</M> which is provided by the library (see below),
##  </Item>
##  <Item>
##   a reference to each occurrence of <M>G</M> in the tables of
##      section 5.3    of  <Cite Key="HP89"/>. Each  of   these  references
##      consists of a class number and an internal number <M>(i,j)</M> under which
##      <M>G</M> is listed in that class. For some groups, there  is more than one
##      reference because these groups belong to more than one of the classes
##      in the book.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> DisplayInformationPerfectGroups( 30720, 3 );
##  #I Perfect group 30720:  A5 ( 2^4 E N 2^1 E 2^4 ) A
##  #I   size = 2^11*3*5  orbit size = 240
##  #I   Holt-Plesken class 1 (9,3)
##  gap> DisplayInformationPerfectGroups( 30720, 6 );
##  #I Perfect group 30720:  A5 ( 2^4 x 2^4 ) C N 2^1
##  #I   centre = 2  size = 2^11*3*5  orbit size = 384
##  #I   Holt-Plesken class 1 (9,6)
##  gap> DisplayInformationPerfectGroups( Factorial( 8 ) / 2 );
##  #I Perfect group 20160.1:  A5 x L3(2) 2^1
##  #I   centre = 2  size = 2^6*3^2*5*7  orbit sizes = 5 + 16
##  #I   Holt-Plesken class 31 (1,1) (occurs also in class 32)
##  #I Perfect group 20160.2:  A5 2^1 x L3(2)
##  #I   centre = 2  size = 2^6*3^2*5*7  orbit sizes = 7 + 24
##  #I   Holt-Plesken class 31 (1,2) (occurs also in class 32)
##  #I Perfect group 20160.3:  ( A5 x L3(2) ) 2^1
##  #I   centre = 2  size = 2^6*3^2*5*7  orbit size = 192
##  #I   Holt-Plesken class 31 (1,3)
##  #I Perfect group 20160.4:  simple group  A8
##  #I   size = 2^6*3^2*5*7  orbit size = 8
##  #I   Holt-Plesken class 26 (0,1)
##  #I Perfect group 20160.5:  simple group  L3(4)
##  #I   size = 2^6*3^2*5*7  orbit size = 21
##  #I   Holt-Plesken class 27 (0,1)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DisplayInformationPerfectGroups");


#############################################################################
##
#F  SizeNumbersPerfectGroups( <factor1>, <factor2>, ... )
##
##  <#GAPDoc Label="SizeNumbersPerfectGroups">
##  <ManSection>
##  <Func Name="SizeNumbersPerfectGroups" Arg='factor1, factor2, ...'/>
##
##  <Description>
##  <Ref Func="SizeNumbersPerfectGroups"/> returns a list of pairs,
##  each entry consisting of a group order and the number of those groups in
##  the library of perfect groups that contain the specified factors
##  <A>factor1</A>, <A>factor2</A>, ...
##  among their composition factors.
##  <P/>
##  Each argument must either be the name of a nonabelian simple group or an integer
##  which stands for the product of the sizes of one or more cyclic factors.
##  (In fact, the function replaces all integers among the arguments
##  by their product.)
##  <P/>
##  The following text strings are accepted as simple group names.
##  <List>
##  <Item>
##     <C>A<A>n</A></C> or <C>A(<A>n</A>)</C> for the alternating groups
##     <M>A_{<A>n</A>}</M>,
##     <M>5 \leq n \leq 9</M>, for example <C>A5</C> or <C>A(6)</C>.
##  </Item>
##  <Item>
##     <C>L<A>n</A>(<A>q</A>)</C> or <C>L(<A>n</A>,<A>q</A>)</C> for
##     PSL<M>(n,q)</M>, where
##     <M>n \in \{ 2, 3 \}</M> and <M>q</M> a prime power, ranging
##     <List>
##     <Item>
##        for <M>n = 2</M> from 4 to 125
##     </Item>
##     <Item>
##        for <M>n = 3</M> from 2 to 5
##     </Item>
##     </List>
##  </Item>
##  <Item>
##     <C>U<A>n</A>(<A>q</A>)</C> or <C>U(<A>n</A>,<A>q</A>)</C> for
##     PSU<M>(n,q)</M>, where
##     <M>n \in \{ 3, 4 \}</M> and <M>q</M> a prime power, ranging
##     <List>
##     <Item>
##        for <M>n = 3</M> from 3 to 5
##     </Item>
##     <Item>
##        for <M>n = 4</M> from 2 to 2
##     </Item>
##     </List>
##  </Item>
##  <Item>
##     <C>Sp4(4)</C> or <C>S(4,4)</C> for the symplectic group Sp<M>(4,4)</M>,
##  </Item>
##  <Item>
##     <C>Sz(8)</C> for the Suzuki group Sz<M>(8)</M>,
##  </Item>
##  <Item>
##     <C>M<A>n</A></C> or <C>M(<A>n</A>)</C> for the Mathieu groups
##     <M>M_{11}</M>, <M>M_{12}</M>, and <M>M_{22}</M>, and
##  </Item>
##  <Item>
##     <C>J<A>n</A></C> or <C>J(<A>n</A>)</C> for the Janko groups
##     <M>J_1</M> and <M>J_2</M>.
##  </Item>
##  </List>
##  <P/>
##  Note  that, for  most  of the  groups,   the  preceding list  offers  two
##  different  names in order  to  be consistent  with the  notation used  in
##  <Cite Key="HP89"/> as well as with the notation used in the
##  <Ref Func="DisplayCompositionSeries"/> command of &GAP;.
##  However, as the names are
##  compared  as text strings, you are  restricted to  the above choice. Even
##  expressions like <C>L2(2^5)</C> are not accepted.
##  <P/>
##  As the use of the term PSU<M>(n,q)</M> is not unique in the literature,
##  we mention that in this library it denotes the factor group of
##  SU<M>(n,q)</M> by its centre, where SU<M>(n,q)</M> is the group of all
##  <M>n \times n</M> unitary matrices with entries in <M>GF(q^2)</M>
##  and determinant 1.
##  <P/>
##  The purpose  of the function is  to provide a  simple way to  formulate a
##  loop over all library groups which contain certain composition factors.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SizeNumbersPerfectGroups");
