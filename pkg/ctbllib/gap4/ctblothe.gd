#############################################################################
##
#W  ctblothe.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id: ctblothe.gd,v 1.7 2008/11/14 17:21:21 gap Exp $
##
#Y  Copyright 1990-1992,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of functions for interfaces to
##  other data formats of character tables.
##
##  1. Interface to {\sf CAS}
##  2. Interface to {\sf MOC}
##  3. Interface to {\GAP}~3
##  4. Interface to the Cambridge format
##
##  <#GAPDoc Label="interfaces">
##  This chapter describes data formats for character tables that can be read
##  or created by &GAP;.
##  Currently these are the formats used by
##  the &CAS; system (see&nbsp;<Ref Sect="sec:interface-cas"/>),
##  the &MOC; system (see&nbsp;<Ref Sect="sec:interface-moc"/>),
##  and &GAP;&nbsp;3 (see&nbsp;<Ref Sect="sec:interface-gap3"/>).
##  <#/GAPDoc>
##
Revision.ctblothe_gd :=
    "@(#)$Id: ctblothe.gd,v 1.7 2008/11/14 17:21:21 gap Exp $";


#############################################################################
##
#T  TODO:
##
#a  MocData( <chi> )
#a  MocInfo( <tbl> )
#o  VirtualCharacterByMocData( <tbl>, <vector> )
#o  CharacterByMocData( <tbl>, <vector> )
##


#############################################################################
##
##  1. Interface to {\sf CAS}
##
##  <#GAPDoc Label="interface_CAS">
##  The interface to &CAS; is thought just for printing the
##  &CAS; data to a file.
##  The function <Ref Func="CASString"/> is available mainly
##  in order to document the data format.
##  <E>Reading</E> &CAS; tables is not supported;
##  note that the tables contained in the
##  &CAS; Character Table Library have been migrated to
##  &GAP; using a few <C>sed</C> scripts and <C>C</C> programs.
##  <#/GAPDoc>
##


#############################################################################
##
#F  CASString( <tbl> )
##
##  <#GAPDoc Label="CASString">
##  <ManSection>
##  <Func Name="CASString" Arg="tbl"/>
##  
##  <Description>
##  is a string that encodes the &CAS; library format
##  of the character table <A>tbl</A>.
##  This string can be printed to a file which then can be read into the
##  &CAS; system using its <C>get</C> command (see&nbsp;<Cite Key="NPP84"/>).
##  <P/>
##  The used line length is the first entry in the list returned by
##  <Ref Func="SizeScreen" BookName="ref"/>.
##  <P/>
##  Only the known values of the following attributes are used.
##  <Ref Attr="ClassParameters" BookName="ref"/> (for partitions only),
##  <Ref Func="ComputedClassFusions" BookName="ref"/>,
##  <Ref Func="ComputedIndicators" BookName="ref"/>,
##  <Ref Func="ComputedPowerMaps" BookName="ref"/>,
##  <Ref Func="ComputedPrimeBlocks" BookName="ref"/>,
##  <Ref Func="Identifier" Label="for character tables" BookName="ref"/>,
##  <Ref Func="InfoText" BookName="ref"/>,
##  <Ref Func="Irr" BookName="ref"/>,
##  <Ref Func="OrdersClassRepresentatives" BookName="ref"/>,
##  <Ref Func="Size" BookName="ref"/>,
##  <Ref Func="SizesCentralizers" BookName="ref"/>.
##  <Example>
##  gap> Print( CASString( CharacterTable( "Cyclic", 2 ) ), "\n" );
##  'C2'
##  00/00/00. 00.00.00.
##  (2,2,0,2,-1,0)
##  text:
##  (#computed using generic character table for cyclic groups#),
##  order=2,
##  centralizers:(
##  2,2
##  ),
##  reps:(
##  1,2
##  ),
##  powermap:2(
##  1,1
##  ),
##  characters:
##  (1,1
##  ,0:0)
##  (1,-1
##  ,0:0);
##  /// converted from GAP
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CASString" );


#############################################################################
##
##  2. Interface to {\sf MOC}
##
##  <#GAPDoc Label="interface_MOC">
##  The interface to &MOC; can be used to print &MOC; input.
##  Additionally it provides an alternative representation of (virtual)
##  characters.
##  <P/>
##  The &MOC;&nbsp;3 code of a <M>5</M> digit number
##  in &MOC;&nbsp;2 code is given by the following list.
##  (Note that the code must contain only lower case letters.)
##  <P/>
##  <Verb>
##  ABCD    for  0ABCD
##  a       for  10000
##  b       for  10001          k       for  20001
##  c       for  10002          l       for  20002
##  d       for  10003          m       for  20003
##  e       for  10004          n       for  20004
##  f       for  10005          o       for  20005
##  g       for  10006          p       for  20006
##  h       for  10007          q       for  20007
##  i       for  10008          r       for  20008
##  j       for  10009          s       for  20009
##  tAB     for  100AB
##  uAB     for  200AB
##  vABCD   for  1ABCD
##  wABCD   for  2ABCD
##  yABC    for  30ABC
##  z       for  31000
##  </Verb>
##  <P/>
##  <E>Note</E> that any long number in &MOC;&nbsp;2 format
##  is divided into packages of length <M>4</M>,
##  the first (!) one filled with leading zeros if necessary.
##  Such a number with decimals <M>d_1, d_2, \ldots, d_{{4n+k}}</M>
##  is the sequence
##  <M>0 d_1 d_2 d_3 d_4 \ldots 0 d_{{4n-3}} d_{{4n-2}} d_{{4n-1}} d_{4n}
##  d_{{4n+1}} \ldots d_{{4n+k}}</M>
##  where <M>0 \leq k \leq 3</M>,
##  the first digit of <M>x</M> is <M>1</M> if the number is positive
##  and <M>2</M> if the number is negative,
##  and then follow <M>(4-k)</M> zeros.
##  <P/>
##  Details about the &MOC; system are explained
##  in&nbsp;<Cite Key="HJLP92"/>,
##  a brief description can be found in&nbsp;<Cite Key="LP91"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#F  MAKElb11( <listofns> )
##
##  <#GAPDoc Label="MAKElb11">
##  <ManSection>
##  <Func Name="MAKElb11" Arg="listofns"/>
##  
##  <Description>
##  For a list <A>listofns</A> of positive integers,
##  <Ref Func="MAKElb11"/> prints field information for all number fields
##  with conductor in this list.
##  <P/>
##  The output of <Ref Func="MAKElb11"/> is used by the &MOC; system;
##  Calling <C>MAKElb11( [ 3 .. 189 ] )</C> will print something very similar
##  to Richard Parker's file <F>lb11</F>.
##  <P/>
##  <Example>
##  gap> MAKElb11( [ 3, 4 ] );
##     3   2   0   1   0
##     4   2   0   1   0
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MAKElb11" );


#############################################################################
##
#F  MOCTable( <gaptbl> )
#F  MOCTable( <gaptbl>, <basicset> )
##
##  <#GAPDoc Label="MOCTable">
##  <ManSection>
##  <Func Name="MOCTable" Arg="gaptbl[, basicset]"/>
##  
##  <Description>
##  <Ref Func="MOCTable"/> returns the &MOC; table record of the
##  &GAP; character table <A>gaptbl</A>.
##  <P/>
##  The one argument version can be used only if <A>gaptbl</A> is an
##  ordinary (<M>G.0</M>) table.
##  For Brauer (<M>G.p</M>) tables, one has to specify a basic set
##  <A>basicset</A> of ordinary irreducibles.
##  <A>basicset</A> must then be a list of positions of the basic set
##  characters in the <Ref Attr="Irr" BookName="ref"/> list
##  of the ordinary table of <A>gaptbl</A>.
##  <P/>
##  The result is a record that contains the information of <A>gaptbl</A>
##  in a format similar to the &MOC;&nbsp;3 format.
##  This record can, e.&nbsp;g., easily be printed out or be used to print
##  out characters using <Ref Func="MOCString"/>.
##  <P/>
##  The components of the result are
##  <List>
##  <Mark><C>identifier</C></Mark>
##  <Item>
##    the string <C>MOCTable( <A>name</A> )</C> where <A>name</A> is the
##    <Ref Func="Identifier" Label="for character tables" BookName="ref"/>
##    value of <A>gaptbl</A>,
##  </Item>
##  <Mark><C>GAPtbl</C></Mark>
##  <Item>
##    <A>gaptbl</A>,
##  </Item>
##  <Mark><C>prime</C></Mark>
##  <Item>
##    the characteristic of the field (label <C>30105</C> in &MOC;),
##  </Item>
##  <Mark><C>centralizers</C></Mark>
##  <Item>
##    centralizer orders for cyclic subgroups (label <C>30130</C>)
##  </Item>
##  <Mark><C>orders</C></Mark>
##  <Item>
##    element orders for cyclic subgroups (label <C>30140</C>)
##  </Item>
##  <Mark><C>fieldbases</C></Mark>
##  <Item>
##    at position <M>i</M> the Parker basis of the number field generated
##    by the character values of the <M>i</M>-th cyclic subgroup.
##    The length of <C>fieldbases</C> is equal to the value of label
##    <C>30110</C> in &MOC;.
##  </Item>
##  <Mark><C>cycsubgps</C></Mark>
##  <Item>
##    <C>cycsubgps[i] = j</C> means that class <C>i</C> of the &GAP; table
##    belongs to the <C>j</C>-th cyclic subgroup of the &GAP; table,
##  </Item>
##  <Mark><C>repcycsub</C></Mark>
##  <Item>
##    <C>repcycsub[j] = i</C> means that class <C>i</C> of the &GAP; table
##    is the representative of the <C>j</C>-th cyclic subgroup of the
##    &GAP; table.
##    <E>Note</E> that the representatives of &GAP; table and
##    &MOC; table need not agree!
##  </Item>
##  <Mark><C>galconjinfo</C></Mark>
##  <Item>
##    a list <M>[ r_1, c_1, r_2, c_2, \ldots, r_n, c_n ]</M>
##    which means that the <M>i</M>-th class of the &GAP; table is
##    the <M>c_i</M>-th conjugate of the representative of
##    the <M>r_i</M>-th cyclic subgroup on the &MOC; table.
##    (This is used to translate back to &GAP; format,
##    stored under label <C>30160</C>)
##  </Item>
##  <Mark><C>30170</C></Mark>
##  <Item>
##    (power maps) for each cyclic subgroup (except the trivial one)
##    and each prime divisor of the representative order store four values,
##    namely the number of the subgroup, the power,
##    the number of the cyclic subgroup containing the image,
##    and the power to which the representative must be raised to yield
##    the image class.
##    (This is used only to construct the <C>30230</C> power map/embedding
##    information.)
##    In <C>30170</C> only a list of lists (one for each cyclic subgroup)
##    of all these values is stored, it will not be used by &GAP;.
##  </Item>
##  <Mark><C>tensinfo</C></Mark>
##  <Item>
##    tensor product information, used to compute the coefficients
##    of the Parker base for tensor products of characters
##    (label <C>30210</C> in &MOC;).
##    For a field with vector space basis <M>(v_1, v_2, \ldots, v_n)</M>,
##    the tensor product information of a cyclic subgroup in
##    &MOC; (as computed by <C>fct</C>) is either <M>1</M>
##    (for rational classes)
##    or a sequence
##    <Display>
##    n x_{1,1} y_{1,1} z_{1,1} x_{1,2} y_{1,2} z_{1,2}
##    \ldots x_{1,m_1} y_{1,m_1} z_{1,m_1} 0 x_{2,1} y_{2,1}
##    z_{2,1} x_{2,2} y_{2,2} z_{2,2} \ldots x_{2,m_2}
##    y_{2,m_2} z_{2,m_2} 0 \ldots z_{n,m_n} 0
##    </Display>
##    which means that the coefficient of <M>v_k</M> in the product
##    <Display>
##    \left( \sum_{i=1}^{n} a_i v_i \right)
##    \left( \sum_{j=1}^{n} b_j v_j \right)
##    </Display>
##    is equal to
##    <Display>
##    \sum_{i=1}^{m_k} x_{k,i} a_{y_{k,i}} b_{z_{k,i}} .
##    </Display>
##    On a &MOC; table in &GAP;,
##    the <C>tensinfo</C> component is a list of lists,
##    each containing exactly the sequence mentioned above.
##  </Item>
##  <Mark><C>invmap</C></Mark>
##  <Item>
##    inverse map to compute complex conjugate characters,
##    label <C>30220</C> in &MOC;.
##  </Item>
##  <Mark><C>powerinfo</C></Mark>
##  <Item>
##    field embeddings for <M>p</M>-th symmetrizations,
##    <M>p</M> a prime integer not larger than the largest element order,
##    label <C>30230</C> in &MOC;.
##  </Item>
##  <Mark><C>30900</C></Mark>
##  <Item>
##    basic set of restricted ordinary irreducibles in the
##    case of nonzero characteristic,
##    all ordinary irreducibles otherwise.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MOCTable" );


#############################################################################
##
#F  MOCString( <moctbl> )
#F  MOCString( <moctbl>, <chars> )
##
##  <#GAPDoc Label="MOCString">
##  <ManSection>
##  <Func Name="MOCString" Arg="moctbl[, chars]"/>
##
##  <Description>
##  Let <A>moctbl</A> be a &MOC; table record,
##  as returned by <Ref Func="MOCTable"/>.
##  <Ref Func="MOCString"/> returns a string describing the
##  &MOC;&nbsp;3 format of <A>moctbl</A>.
##  <P/>
##  If a second argument <A>chars</A> is specified,
##  it must be a list of &MOC;
##  format characters as returned by <Ref Func="MOCChars"/>.
##  In this case, these characters are stored under label <C>30900</C>.
##  If the second argument is missing then the basic set of ordinary
##  irreducibles is stored under this label.
##  <Example>
##  gap> moca5:= MOCTable( CharacterTable( "A5" ) );
##  rec( identifier := "MOCTable(A5)", prime := 0, fields := [  ], 
##    GAPtbl := CharacterTable( "A5" ), cycsubgps := [ 1, 2, 3, 4, 4 ], 
##    repcycsub := [ 1, 2, 3, 4 ], galconjinfo := [ 1, 1, 2, 1, 3, 1, 4, 1, 4, 2 ]
##      , centralizers := [ 60, 4, 3, 5 ], orders := [ 1, 2, 3, 5 ], 
##    fieldbases := [ CanonicalBasis( Rationals ), CanonicalBasis( Rationals ), 
##        CanonicalBasis( Rationals ), 
##        Basis( NF(5,[ 1, 4 ]), [ 1, E(5)+E(5)^4 ] ) ], 
##    30170 := [ [  ], [ 2, 2, 1, 1 ], [ 3, 3, 1, 1 ], [ 4, 5, 1, 1 ] ], 
##    tensinfo := 
##      [ [ 1 ], [ 1 ], [ 1 ], [ 2, 1, 1, 1, 1, 2, 2, 0, 1, 1, 2, 1, 2, 1, -1, 2, 
##            2, 0 ] ], 
##    invmap := [ [ 1, 1, 0 ], [ 1, 2, 0 ], [ 1, 3, 0 ], [ 1, 4, 0, 1, 5, 0 ] ], 
##    powerinfo := 
##      [ , [ [ 1, 1, 0 ], [ 1, 1, 0 ], [ 1, 3, 0 ], [ 1, 4, -1, 5, 0, -1, 5, 0 ] 
##           ], 
##        [ [ 1, 1, 0 ], [ 1, 2, 0 ], [ 1, 1, 0 ], [ 1, 4, -1, 5, 0, -1, 5, 0 ] ],
##        , [ [ 1, 1, 0 ], [ 1, 2, 0 ], [ 1, 3, 0 ], [ 1, 1, 0, 0 ] ] ], 
##    30900 := [ [ 1, 1, 1, 1, 0 ], [ 3, -1, 0, 0, -1 ], [ 3, -1, 0, 1, 1 ], 
##        [ 4, 0, 1, -1, 0 ], [ 5, 1, -1, 0, 0 ] ] )
##  gap> str:= MOCString( moca5 );;
##  gap> str{[1..70]};
##  "y100y105ay110fey130t60edfy140bcdfy150bbbfcabbey160bbcbdbebecy170ccbbdd"
##  gap> moca5mod3:= MOCTable( CharacterTable( "A5" ) mod 3, [ 1 .. 4 ] );;
##  gap> MOCString( moca5mod3 ){ [ 1 .. 70 ] };
##  "y100y105dy110edy130t60efy140bcfy150bbfcabbey160bbcbdbdcy170ccbbdfbby21"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MOCString" );


#############################################################################
##
#F  ScanMOC( <list> )
##
##  <#GAPDoc Label="ScanMOC">
##  <ManSection>
##  <Func Name="ScanMOC" Arg="list"/>
##
##  <Description>
##  returns a record containing the information encoded in the list
##  <A>list</A>.
##  The components of the result are the labels that occur in <A>list</A>.
##  If <A>list</A> is in &MOC;&nbsp;2 format (10000-format),
##  the names of components are 30000-numbers;
##  if it is in &MOC;&nbsp;3 format the names of components
##  have <C>yABC</C>-format.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ScanMOC" );


#############################################################################
##
#F  GAPChars( <tbl>, <mocchars> )
##
##  <#GAPDoc Label="GAPChars">
##  <ManSection>
##  <Func Name="GAPChars" Arg="tbl, mocchars"/>
##
##  <Description>
##  Let <A>tbl</A> be a character table or a &MOC;
##  table record,
##  and <A>mocchars</A> be either a list of &MOC; format
##  characters
##  (as returned by <Ref Func="MOCChars"/>)
##  or a list of positive integers such as a record component encoding
##  characters, in a record produced by <Ref Func="ScanMOC"/>.
##  <P/>
##  <Ref Func="GAPChars"/> returns translations of <A>mocchars</A> to &GAP;
##  character values lists.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GAPChars" );


#############################################################################
##
#F  MOCChars( <tbl>, <gapchars> )
##
##  <#GAPDoc Label="MOCChars">
##  <ManSection>
##  <Func Name="MOCChars" Arg="tbl, gapchars"/>
##
##  <Description>
##  Let <A>tbl</A> be a character table or a &MOC;
##  table record,
##  and <A>gapchars</A> be a list of (&GAP; format) characters.
##  <Ref Func="MOCChars"/> returns translations of <A>gapchars</A>
##  to &MOC; format.
##  <Example>
##  gap> scan:= ScanMOC( str );
##  rec( y105 := [ 0 ], y110 := [ 5, 4 ], y130 := [ 60, 4, 3, 5 ], 
##    y140 := [ 1, 2, 3, 5 ], y150 := [ 1, 1, 1, 5, 2, 0, 1, 1, 4 ], 
##    y160 := [ 1, 1, 2, 1, 3, 1, 4, 1, 4, 2 ], 
##    y170 := [ 2, 2, 1, 1, 3, 3, 1, 1, 4, 5, 1, 1 ], 
##    y210 := [ 1, 1, 1, 2, 1, 1, 1, 1, 2, 2, 0, 1, 1, 2, 1, 2, 1, -1, 2, 2, 0 ], 
##    y220 := [ 1, 1, 0, 1, 2, 0, 1, 3, 0, 1, 4, 0, 1, 5, 0 ], 
##    y230 := [ 2, 1, 1, 0, 1, 1, 0, 1, 3, 0, 1, 4, -1, 5, 0, -1, 5, 0 ], 
##    y050 := [ 5, 1, 1, 0, 1, 2, 0, 1, 3, 0, 1, 1, 0, 0 ], 
##    y900 := [ 1, 1, 1, 1, 0, 3, -1, 0, 0, -1, 3, -1, 0, 1, 1, 4, 0, 1, -1, 0, 
##        5, 1, -1, 0, 0 ] )
##  gap> gapchars:= GAPChars( moca5, scan.y900 );
##  [ [ 1, 1, 1, 1, 1 ], [ 3, -1, 0, -E(5)-E(5)^4, -E(5)^2-E(5)^3 ], 
##    [ 3, -1, 0, -E(5)^2-E(5)^3, -E(5)-E(5)^4 ], [ 4, 0, 1, -1, -1 ], 
##    [ 5, 1, -1, 0, 0 ] ]
##  gap> mocchars:= MOCChars( moca5, gapchars );
##  [ [ 1, 1, 1, 1, 0 ], [ 3, -1, 0, 0, -1 ], [ 3, -1, 0, 1, 1 ], 
##    [ 4, 0, 1, -1, 0 ], [ 5, 1, -1, 0, 0 ] ]
##  gap> Concatenation( mocchars ) = scan.y900;
##  true
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MOCChars" );


#############################################################################
##
##  3. Interface to {\GAP}~3
##
##  <#GAPDoc Label="interface_GAP3">
##  The following functions are used to read and write character tables in
##  &GAP;&nbsp;3 format.
##  <#/GAPDoc>
##


#############################################################################
##
#V  GAP3CharacterTableData
##
##  <#GAPDoc Label="GAP3CharacterTableData">
##  <ManSection>
##  <Var Name="GAP3CharacterTableData"/>
##  
##  <Description>
##  This is a list of pairs,
##  the first entry being the name of a component in a &GAP;&nbsp;3
##  character table and the second entry being the corresponding
##  attribute name in &GAP;&nbsp;4.
##  The variable is used by <Ref Func="GAP3CharacterTableScan"/>
##  and <Ref Func="GAP3CharacterTableString"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalVariable( "GAP3CharacterTableData",
    "list of pairs [ <GAP 3 component>, <GAP 4 attribute> ]" );


#############################################################################
##
#F  GAP3CharacterTableScan( <string> )
##
##  <#GAPDoc Label="GAP3CharacterTableScan">
##  <ManSection>
##  <Func Name="GAP3CharacterTableScan" Arg="string"/>
##  
##  <Description>
##  Let <A>string</A> be a string that contains the output of the
##  &GAP;&nbsp;3 function <C>PrintCharTable</C>.
##  In other words, <A>string</A> describes a &GAP; record whose components
##  define an ordinary character table object in &GAP;&nbsp;3.
##  <Ref Func="GAP3CharacterTableScan"/> returns the corresponding
##  &GAP;&nbsp;4 character table object.
##  <P/>
##  The supported record components are given by the list
##  <Ref Var="GAP3CharacterTableData"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GAP3CharacterTableScan" );


#############################################################################
##
#F  GAP3CharacterTableString( <tbl> )
##
##  <#GAPDoc Label="GAP3CharacterTableString">
##  <ManSection>
##  <Func Name="GAP3CharacterTableString" Arg="tbl"/>
##  
##  <Description>
##  For an ordinary character table <A>tbl</A>,
##  <Ref Func="GAP3CharacterTableString"/> returns
##  a string that when read into &GAP;&nbsp;3 evaluates to a character table
##  corresponding to <A>tbl</A>.
##  A similar format is printed by the &GAP;&nbsp;3 function
##  <C>PrintCharTable</C>.
##  <P/>
##  The supported record components are given by the list
##  <Ref Var="GAP3CharacterTableData"/>.
##  <Example>
##  gap> tbl:= CharacterTable( "Alternating", 5 );;
##  gap> str:= GAP3CharacterTableString( tbl );;
##  gap> Print( str );
##  rec(
##  centralizers := [ 60, 4, 3, 5, 5 ],
##  fusions := [ rec( name := "Sym(5)", map := [ 1, 3, 4, 7, 7 ] ) ],
##  identifier := "Alt(5)",
##  irreducibles := [
##  [ 1, 1, 1, 1, 1 ],
##  [ 4, 0, 1, -1, -1 ],
##  [ 5, 1, -1, 0, 0 ],
##  [ 3, -1, 0, -E(5)-E(5)^4, -E(5)^2-E(5)^3 ],
##  [ 3, -1, 0, -E(5)^2-E(5)^3, -E(5)-E(5)^4 ]
##  ],
##  orders := [ 1, 2, 3, 5, 5 ],
##  powermap := [ , [ 1, 1, 3, 5, 4 ], [ 1, 2, 1, 5, 4 ], , [ 1, 2, 3, 1, 1 ] ],
##  size := 60,
##  text := "computed using generic character table for alternating groups",
##  operations := CharTableOps )
##  gap> scan:= GAP3CharacterTableScan( str );
##  CharacterTable( "Alt(5)" )
##  gap> TransformingPermutationsCharacterTables( tbl, scan );
##  rec( columns := (), rows := (), group := Group([ (4,5) ]) )
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GAP3CharacterTableString" );


#############################################################################
##
##  4. Interface to the Cambridge format
##


#############################################################################
##
#F  CambridgeMaps( <tbl> )
##
##  For a character table <tbl>, `CambridgeMaps' returns a record with the
##  following components.
##
##  ...
##
DeclareGlobalFunction( "CambridgeMaps" );


#############################################################################
##
#E

