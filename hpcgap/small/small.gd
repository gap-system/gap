#############################################################################
##
#W  small.gd                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small","2.1");

InfoIdgroup := NewInfoClass( "InfoIdgroup" );

UnbindGlobal( "SMALL_AVAILABLE" );

#############################################################################
##
#F  SMALL_AVAILABLE( <order> )
##
##  <ManSection>
##  <Func Name="SMALL_AVAILABLE" Arg='order'/>
##
##  <Description>
##  returns fail if the library of groups of <A>order</A> is not installed. 
##  Otherwise a record with some information about the construction of the 
##  groups of <A>order</A> is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SMALL_AVAILABLE" );

UnbindGlobal( "SmallGroup" );

#############################################################################
##
#F  SmallGroup( <order>, <i> )
#F  SmallGroup( [<order>, <i>] )
##
##  <#GAPDoc Label="SmallGroup">
##  <ManSection>
##  <Func Name="SmallGroup" Arg='order, i'
##   Label="for group order and index"/>
##  <Func Name="SmallGroup" Arg='pair' Label="for a pair [ order, index ]"/>
##
##  <Description>
##  returns the <A>i</A>-th group of order <A>order</A> in the catalogue.
##  If the group is solvable, it will be given as a PcGroup;
##  otherwise it will be given as a permutation group.
##  If the groups of order <A>order</A> are not installed,
##  the function reports an error and enters a break loop.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SmallGroup" );

#############################################################################
##
#F  SelectSmallGroups( <argl>, <all>, <id> )
##
##  <ManSection>
##  <Func Name="SelectSmallGroups" Arg='argl, all, id'/>
##
##  <Description>
##  universal function for 'AllGroups', 'OneGroup' and 'IdsOfAllGroups'.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SelectSmallGroups" );

UnbindGlobal( "AllGroups" );

#############################################################################
##
#F  AllSmallGroups( <arg> )
##
##  <#GAPDoc Label="AllSmallGroups">
##  <ManSection>
##  <Func Name="AllSmallGroups" Arg='arg'/>
##
##  <Description>
##  returns all groups with certain properties as specified by <A>arg</A>.
##  If <A>arg</A> is a number <M>n</M>, then this function returns all groups
##  of order <M>n</M>.
##  However, the function can also take several arguments which then
##  must be organized in pairs <C>function</C> and <C>value</C>.
##  In this case the first function must be <Ref Func="Size"/>
##  and the first value an order or a range of orders.
##  If value is a list then it is considered a list of possible function
##  values to include. 
##  The function returns those groups of the specified orders having those
##  properties specified by the remaining functions and their values.
##  <P/>
##  Precomputed information is stored for the properties
##  <Ref Func="IsAbelian"/>, <Ref Func="IsNilpotentGroup"/>,
##  <Ref Func="IsSupersolvableGroup"/>, <Ref Func="IsSolvableGroup"/>, 
##  <Ref Func="RankPGroup"/>, <Ref Func="PClassPGroup"/>,
##  <Ref Func="LGLength"/>, <C>FrattinifactorSize</C> and 
##  <C>FrattinifactorId</C> for the groups of order at most
##  <M>2000</M> which have  more than three prime factors,
##  except those of order <M>512</M>, <M>768</M>, 
##  <M>1024</M>, <M>1152</M>, <M>1536</M>, <M>1920</M> and those of order
##  <M>p^n \cdot q > 1000</M> 
##  with <M>n > 2</M>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
AllSmallGroups := function( arg )
    return SelectSmallGroups( arg, true, false );
end;
DeclareSynonym( "AllGroups", AllSmallGroups );

UnbindGlobal( "OneGroup" );

#############################################################################
##
#F  OneSmallGroup( <arg> )
##
##  <#GAPDoc Label="OneSmallGroup">
##  <ManSection>
##  <Func Name="OneSmallGroup" Arg='arg'/>
##
##  <Description>
##  returns one group with certain properties as specified by <A>arg</A>.
##  The permitted arguments are those supported by
##  <Ref Func="AllSmallGroups"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OneSmallGroup := function( arg )
    return SelectSmallGroups( arg, false, false );
end;
DeclareSynonym( "OneGroup", OneSmallGroup );

UnbindGlobal( "IdsOfAllGroups" );

#############################################################################
##
#F  IdsOfAllSmallGroups( <arg> )
##
##  <#GAPDoc Label="IdsOfAllSmallGroups">
##  <ManSection>
##  <Func Name="IdsOfAllSmallGroups" Arg='arg'/>
##
##  <Description>
##  similar to <C>AllSmallGroups</C> but returns ids instead of groups. This may
##  prevent workspace overflows, if a large number of groups are expected in 
##  the output.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
IdsOfAllGroups := function( arg )
    return SelectSmallGroups( arg, true, true );
end;

DeclareSynonym( "IdsOfAllSmallGroups", IdsOfAllGroups );

UnbindGlobal( "NumberSmallGroups" );

#############################################################################
##
#F  NumberSmallGroups( <order> )
##
##  <#GAPDoc Label="NumberSmallGroups">
##  <ManSection>
##  <Func Name="NumberSmallGroups" Arg='order'/>
##
##  <Description>
##  returns the number of groups of order <A>order</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NumberSmallGroups" );
DeclareSynonym( "NrSmallGroups",NumberSmallGroups );

#############################################################################
##
#F  UnloadSmallGroupsData( )
##
##  <#GAPDoc Label="UnloadSmallGroupsData">
##  <ManSection>
##  <Func Name="UnloadSmallGroupsData" Arg=''/>
##
##  <Description>
##  &GAP; loads all necessary data from the library automatically,
##  but it does not delete the data from the workspace again.
##  Usually, this will be not necessary, since the data is stored in a
##  compressed format. However, if 
##  a large number of groups from the library have been loaded, then the user 
##  might wish to remove the data from the workspace and this can be done by 
##  the above function call.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 768, 1000000 );
##  <pc group of size 768 with 9 generators>
##  gap> G := SmallGroup( [768, 1000000] );
##  <pc group of size 768 with 9 generators>
##  gap> AllSmallGroups( 6 );
##  [ <pc group of size 6 with 2 generators>, 
##    <pc group of size 6 with 2 generators> ]
##  gap> AllSmallGroups( Size, 120, IsSolvableGroup, false );
##  [ Group(
##      [ (1,2,4,8)(3,6,9,5)(7,12,13,17)(10,14,11,15)(16,20,21,24)(18,22,
##          19,23), (1,3,7)(2,5,10)(4,9,13)(6,11,8)(12,16,20)(14,18,
##          22)(15,19,23)(17,21,24) ]), Group([ (1,2,3,4,5), (1,2) ]), 
##    Group([ (1,2,3,5,4), (1,3)(2,4)(6,7) ]) ]
##  gap> G := OneSmallGroup( 120, IsNilpotentGroup, false );
##  <pc group of size 120 with 5 generators>
##  gap> IdSmallGroup(G);
##  [ 120, 1 ]
##  gap> G := OneSmallGroup( Size, [1..1000], IsSolvableGroup, false );
##  Group([ (1,2,3,4,5), (1,2,3) ])
##  gap> IdSmallGroup(G);
##  [ 60, 5 ]
##  gap> UnloadSmallGroupsData();
##  gap> IdSmallGroup( GL( 2,3 ) );
##  [ 48, 29 ]
##  gap> IdSmallGroup( Group( (1,2,3,4),(4,5) ) );
##  [ 120, 34 ]
##  gap> IdsOfAllSmallGroups( Size, 60, IsSupersolvableGroup, true );
##  [ [ 60, 1 ], [ 60, 2 ], [ 60, 3 ], [ 60, 4 ], [ 60, 6 ], [ 60, 7 ], 
##    [ 60, 8 ], [ 60, 10 ], [ 60, 11 ], [ 60, 12 ], [ 60, 13 ] ]
##  gap> NumberSmallGroups( 512 );
##  10494213
##  gap> NumberSmallGroups( 2^8 * 23 );
##  1083472
##  ]]></Example>
##  <P/>
##  <Log><![CDATA[
##  gap> NumberSmallGroups( 2^9 * 23 );
##  Error, the library of groups of size 11776 is not available called from
##  <function>( <arguments> ) called from read-eval-loop
##  Entering break read-eval-print loop ...
##  you can 'quit;' to quit to outer loop, or
##  you can 'return;' to continue
##  brk> quit;
##  gap>
##  ]]></Log>
##  <P/>
##  <Example><![CDATA[
##  gap> SmallGroupsInformation( 32 );
##  
##    There are 51 groups of order 32.
##    They are sorted by their ranks. 
##       1 is cyclic. 
##       2 - 20 have rank 2.
##       21 - 44 have rank 3.
##       45 - 50 have rank 4.
##       51 is elementary abelian. 
##  
##    For the selection functions the values of the following attributes 
##    are precomputed and stored:
##       IsAbelian, PClassPGroup, RankPGroup, FrattinifactorSize and 
##       FrattinifactorId. 
##  
##    This size belongs to layer 2 of the SmallGroups library. 
##    IdSmallGroup is available for this size. 
##   
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "UnloadSmallGroupsData" );

UnbindGlobal( "ID_AVAILABLE" );
#############################################################################
##
#F  ID_AVAILABLE( <order> )
##
##  <ManSection>
##  <Func Name="ID_AVAILABLE" Arg='order'/>
##
##  <Description>
##  returns false, if the identification routines for of groups of <A>order</A> is
##  not installed. Otherwise a record with some information about the 
##  identification of groups of <A>order</A> is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ID_AVAILABLE" );

UnbindGlobal( "IdGroup" );

#############################################################################
##
#A  IdSmallGroup( <G> )
#A  IdGroup( <G> )
##
##  <#GAPDoc Label="IdSmallGroup">
##  <ManSection>
##  <Attr Name="IdSmallGroup" Arg='G'/>
##  <Attr Name="IdGroup" Arg='G'/>
##
##  <Description>
##  returns the library number of <A>G</A>; that is, the function returns a pair
##  <C>[<A>order</A>, <A>i</A>]</C> where <A>G</A> is isomorphic to <C>SmallGroup( <A>order</A>, <A>i</A> )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IdGroup", IsGroup );
DeclareSynonym( "IdSmallGroup",IdGroup );

UnbindGlobal( "IdStandardPresented512Group" );

#############################################################################
##
#F  IdStandardPresented512Group( <G> )
#F  IdStandardPresented512Group( <pcgs> )
##
##  <ManSection>
##  <Func Name="IdStandardPresented512Group" Arg='G'/>
##  <Func Name="IdStandardPresented512Group" Arg='pcgs'/>
##
##  <Description>
##  returns the catalogue number of a group <A>G</A> of order 512 if <C>Pcgs(<A>G</A>)</C> 
##  or <C>pcgs</C> is a pcgs corresponding to a power-commutator presentation 
##  which forms an ANUPQ-standard presentation of <A>G</A>. If the input is not
##  corresponding to a standard presentation, then a warning is printed 
##  and <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "IdStandardPresented512Group" );

#############################################################################
##
#F  SmallGroupsInformation( <order> )
##
##  <#GAPDoc Label="SmallGroupsInformation">
##  <ManSection>
##  <Func Name="SmallGroupsInformation" Arg='order'/>
##
##  <Description>
##  prints information on the groups of the specified order.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SmallGroupsInformation" );

UnbindGlobal( "Gap3CatalogueIdGroup" );

#############################################################################
##  
#A  IdGap3SolvableGroup( <G> )
#A  Gap3CatalogueIdGroup( <G> )
##
##  <#GAPDoc Label="IdGap3SolvableGroup">
##  <ManSection>
##  <Attr Name="IdGap3SolvableGroup" Arg='G'/>
##  <Attr Name="Gap3CatalogueIdGroup" Arg='G'/>
##
##  <Description>
##  returns the catalogue number of <A>G</A> in the &GAP;&nbsp;3 catalogue
##  of solvable groups;
##  that is, the function returns a pair <C>[<A>order</A>, <A>i</A>]</C> meaning that
##  <A>G</A> is isomorphic to the group
##  <C>SolvableGroup( <A>order</A>, <A>i</A> )</C> in &GAP;&nbsp;3.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Gap3CatalogueIdGroup", IsGroup );
DeclareSynonym( "IdGap3SolvableGroup", Gap3CatalogueIdGroup );

#############################################################################
##  
#F  Gap3CatalogueGroup( <order>, <i> )
##
##  <ManSection>
##  <Func Name="Gap3CatalogueGroup" Arg='order, i'/>
##
##  <Description>
##  returns the <A>i</A>-th group of order <A>order</A> in the &GAP;&nbsp;3
##  catalogue of solvable groups.
##  This group is isomorphic to the group returned by
##  <C>SolvableGroup( <A>order</A>, <A>i</A> )</C> in &GAP;&nbsp;3.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "Gap3CatalogueGroup" );

#############################################################################
##  
#A  FrattinifactorSize( <G> )
##
##  <ManSection>
##  <Attr Name="FrattinifactorSize" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "FrattinifactorSize", IsGroup );

#############################################################################
##  
#A  FrattinifactorId( <G> )
##
##  <ManSection>
##  <Attr Name="FrattinifactorId" Arg='G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "FrattinifactorId", IsGroup );

#############################################################################
##  
#F  FinalizeSmallGroupData()
##
##  This function should be called when all levels of the small group library 
##  have been loaded. It makes various records immutable for thread-safety.
##
DeclareGlobalFunction( "FinalizeSmallGroupData");

#############################################################################
##
#E

