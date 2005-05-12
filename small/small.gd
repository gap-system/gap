#############################################################################
##
#W  small.gd                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
Revision.small_gd :=
    "@(#)$Id$";

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
##  returns fail if the library of groups of <order> is not installed. 
##  Otherwise a record with some information about the construction of the 
##  groups of <order> is returned.
DeclareGlobalFunction( "SMALL_AVAILABLE" );

UnbindGlobal( "SmallGroup" );

#############################################################################
##
#F  SmallGroup( <order>, <i> )
#F  SmallGroup( [<order>, <i>] )
##
## returns the <i>-th group of order <order> in the catalogue. If the group
## is solvable, it will be given as a PcGroup; otherwise it will be given as
## a permutation group. If the groups of order <order> are not installed,
## the function reports an error and enters a break loop.

DeclareGlobalFunction( "SmallGroup" );

#############################################################################
##
#F  SelectSmallGroups( <argl>, <all>, <id> )
##
##  universal function for 'AllGroups', 'OneGroup' and 'IdsOfAllGroups'.
##
DeclareGlobalFunction( "SelectSmallGroups" );

UnbindGlobal( "AllGroups" );

#############################################################################
##
#F  AllSmallGroups( <arg> )
##
## returns all groups with certain properties as specified by <arg>.
## If <arg> is a number $n$, then this function returns all groups of order
## $n$. However, the function can also take several arguments which then
## must be organized in pairs `function' and `value'. In this case the first
## function must be `Size' and the first value an order or a range of orders.
## If value is a list then it is considered a list of possible function
## values to include. 
## The function returns those groups of the specified orders having those
## properties specified by the remaining functions and their values.
## 
##  Precomputed information is stored for the properties `IsAbelian', 
##  `IsNilpotentGroup', `IsSupersolvableGroup', `IsSolvableGroup', 
##  `RankPGroup', `PClassPGroup', `LGLength', `FrattinifactorSize' and 
##  `FrattinifactorId' for the groups of order at most $2000$ which have 
##  more than three prime factors, except those of order $512$, $768$, 
##  $1024$, $1152$, $1536$, $1920$ and those of order $p^n \cdot q > 1000$ 
##  with $n > 2$. 
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
## returns one group with certain properties as specified by <arg>.
## The permitted arguments are those supported by `AllSmallGroups'.
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
## similar to `AllSmallGroups' but returns ids instead of groups. This may
## prevent workspace overflows, if a large number of groups are expected in 
## the output.

IdsOfAllGroups := function( arg )
    return SelectSmallGroups( arg, true, true );
end;

DeclareSynonym( "IdsOfAllSmallGroups", IdsOfAllGroups );

UnbindGlobal( "NumberSmallGroups" );

#############################################################################
##
#F  NumberSmallGroups( <order> )
##
##  returns the number of groups of order <order>.
DeclareGlobalFunction( "NumberSmallGroups" );
DeclareSynonym( "NrSmallGroups",NumberSmallGroups );

#############################################################################
##
#F  UnloadSmallGroupsData( )
##
## GAP loads all necessary data from the library automatically, but it does 
## not delete the data from the workspace again. Usually, this will be not 
## necessary, since the data is stored in a compressed format. However, if 
## a large number of groups from the library have been loaded, then the user 
## might wish to remove the data from the workspace and this can be done by 
## the above function call.
DeclareGlobalFunction( "UnloadSmallGroupsData" );

UnbindGlobal( "ID_AVAILABLE" );
#############################################################################
##
#F  ID_AVAILABLE( <order> )
##
##  returns false, if the identification routines for of groups of <order> is
##  not installed. Otherwise a record with some information about the 
##  identification of groups of <order> is returned.
DeclareGlobalFunction( "ID_AVAILABLE" );

UnbindGlobal( "IdGroup" );

#############################################################################
##
#A  IdSmallGroup( <G> )
#A  IdGroup( <G> )
##
## returns the library number of <G>; that is, the function returns a pair
## `[<order>, <i>]' where <G> is isomorphic to `SmallGroup( <order>, <i> )'.

DeclareAttribute( "IdGroup", IsGroup );
DeclareSynonym( "IdSmallGroup",IdGroup );

UnbindGlobal( "IdStandardPresented512Group" );

#############################################################################
##
#F  IdStandardPresented512Group( <G> )
#F  IdStandardPresented512Group( <pcgs> )
##
##  returns the catalogue number of a group <G> of order 512 if `Pcgs(<G>)' 
##  or `pcgs' is a pcgs corresponding to a power-commutator presentation 
##  which forms an ANUPQ-standard presentation of <G>. If the input is not
##  corresponding to a standard presentation, then a warning is printed 
##  and `fail' is returned.
##
DeclareGlobalFunction( "IdStandardPresented512Group" );

#############################################################################
##
#F  SmallGroupsInformation( <order> )
##
##  prints information on the groups of the specified order.
DeclareGlobalFunction( "SmallGroupsInformation" );

UnbindGlobal( "Gap3CatalogueIdGroup" );

#############################################################################
##  
#A  IdGap3SolvableGroup( <G> )
#A  Gap3CatalogueIdGroup( <G> )
##  
##  returns the catalogue number of <G> in the GAP 3 catalogue of solvable
##  groups; that is, the function returns a pair `[<order>, <i>]' meaning that
##  <G> is isomorphic to the group `SolvableGroup( <order>, <i> )' in GAP 3.
DeclareAttribute( "Gap3CatalogueIdGroup", IsGroup );
DeclareSynonym( "IdGap3SolvableGroup", Gap3CatalogueIdGroup );

#############################################################################
##  
#F  Gap3CatalogueGroup( <order>, <i> )
##  
##  returns  the  <i>-th  group  of  order  <order>  in the GAP 3 catalogue of
##  solvable  groups.  This  group  is  isomorphic  to  the group returned by
##  `SolvableGroup( <order>, <i> )' in GAP 3.
DeclareGlobalFunction( "Gap3CatalogueGroup" );

#############################################################################
##  
#A  FrattinifactorSize( <G> )
##  
DeclareAttribute( "FrattinifactorSize", IsGroup );

#############################################################################
##  
#A  FrattinifactorId( <G> )
##  
DeclareAttribute( "FrattinifactorId", IsGroup );
