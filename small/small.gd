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
DeclareComponent("small","2.0");

InfoIdgroup := NewInfoClass( "InfoIdgroup" );

UnbindGlobal( "SMALL_AVAILABLE" );

#############################################################################
##
#F  SMALL_AVAILABLE( size )
##
##  returns fail if the library of groups of <size> is not installed. 
##  Otherwise a record with some information about the construction of the 
##  groups of <size> is returned.
DeclareGlobalFunction( "SMALL_AVAILABLE" );

UnbindGlobal( "SmallGroup" );

#############################################################################
##
#F  SmallGroup(<size>,<i>)
#F  SmallGroup([<size>,<i>])
##
##  returns the <i>-th group of order <size> in the catalogue. The group will
##  be given as PcGroup, if it is solvable and as permutation group otherwise.
##  If the groups of order <size> are not installed, the function returns an
##  error.  
DeclareGlobalFunction( "SmallGroup" );

#############################################################################
##
#F  SelectSmallGroups( argl, all, id )
##
##  universal function for 'AllGroups', 'OneGroup' and 
##  'IdsOfAllGroups'.
DeclareGlobalFunction( "SelectSmallGroups" );

UnbindGlobal( "AllGroups" );

#############################################################################
##
#F  AllSmallGroups( arg )
#F  AllGroups( arg )
##
##  returns all small groups with certain properties. The first selection
##  function has to be `Size'. There are precomputed listings for the 
##  properties `IsAbelian', `IsNilpotentGroup', `IsSupersolvableGroup', 
##  `IsSolvableGroup', `RankPGroup', `PClassPGroup', `LGLength', 
##  `FrattinifactorSize' and `FrattinifactorId' for the groups of order
##   at most $1000$ except $512$  and $768$ whose order have more than 
##  three prime factors. 
AllSmallGroups := function( arg )
    return SelectSmallGroups( arg, true, false );
end;
DeclareSynonym( "AllGroups", AllSmallGroups );

UnbindGlobal( "OneGroup" );

#############################################################################
##
#F  OneSmallGroup( arg )
#F  OneGroup( arg )
##
##  see `AllSmallGroups'.
OneSmallGroup := function( arg )
    return SelectSmallGroups( arg, false, false );
end;

DeclareSynonym( "OneGroup", OneSmallGroup );

UnbindGlobal( "IdsOfAllGroups" );

#############################################################################
##
#F  IdsOfAllSmallGroups( arg )
#F  IdsOfAllGroups( arg )
##
##  similar to `AllGroups' but returns id's instead of groups. This may
##  be useful to avoid workspace overflows, if a large number of groups are 
##  expected in the output.
IdsOfAllGroups := function( arg )
    return SelectSmallGroups( arg, true, true );
end;

DeclareSynonym( "IdsOfAllSmallGroups", IdsOfAllGroups );

UnbindGlobal( "NumberSmallGroups" );

#############################################################################
##
#F  NumberSmallGroups(<size>)
#F  NrSmallGroups(<size>)
##
##  returns the number of groups of order <size>.
DeclareGlobalFunction( "NumberSmallGroups" );
DeclareSynonym( "NrSmallGroups",NumberSmallGroups );

#############################################################################
##
#F  UnloadSmallGroupsData( )
##
##  while GAP  loads all necessary data from the small groups library
##  automatically, it does not remove the data from the workspace again.
##  Usually, this will be not necessary, since the data is stored in
##  a compressed format. However, if a large number of small groups have
##  been loaded by a user, then the user might wish to remove the
##  data from the workspace and this can be done by the above function
##  call. Note that this is not dangerous in any case, since the data
##  will be reloaded automatically, if necessary.
DeclareGlobalFunction( "UnloadSmallGroupsData" );

UnbindGlobal( "ID_AVAILABLE" );
#############################################################################
##
#F  ID_AVAILABLE( size )
##
##  returns false, if the identification routines for of groups of <size> is
##  not installed. Otherwise a record with some information about the 
##  identification of groups of <size> is returned.
DeclareGlobalFunction( "ID_AVAILABLE" );

UnbindGlobal( "IdGroup" );

#############################################################################
##
#A  IdGroup(<G>)
##
##  returns the catalogue number of <G>; that is, the function returns
##  a pair `[<size>, <i>]' meaning that <G> is isomorphic to 
##  `SmallGroup( <size>, <i> )'.
DeclareAttribute( "IdGroup", IsGroup );

UnbindGlobal( "Gap3CatalogueIdGroup" );

#############################################################################
##
#F  SmallGroupsInformation( size )
##
##  prints information on the groups of the specified size.
DeclareGlobalFunction( "SmallGroupsInformation" );

#############################################################################
##  
#A  Gap3CatalogueIdGroup(<G>)
##  
##  returns the catalogue number of <G> in the GAP 3 catalogue of solvable
##  groups; that is, the function returns a pair `[<size>, <i>]' meaning that
##  <G> is isomorphic to the group `SolvableGroup( <size>, <i> )' in GAP 3.
DeclareAttribute( "Gap3CatalogueIdGroup", IsGroup );

#############################################################################
##  
#F  Gap3CatalogueGroup(<size>,<i>)
##  
##  returns  the  <i>-th  group  of  order  <size>  in the GAP 3 catalogue of
##  solvable  groups.  This  group  is  isomorphic  to  the group returned by
##  `SolvableGroup( <size>, <i> )' in GAP 3.
DeclareGlobalFunction( "Gap3CatalogueGroup" );

#############################################################################
##  
#A  FrattinifactorSize(<G>)
##  
DeclareAttribute( "FrattinifactorSize", IsGroup );

#############################################################################
##  
#A  FrattinifactorId( <G> )
##  
DeclareAttribute( "FrattinifactorId", IsGroup );
