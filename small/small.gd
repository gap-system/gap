#############################################################################
##
#W  small.gd                 GAP group library             Hans Ulrich Besche
#W                                                             & Bettina Eick
##
Revision.small_gd :=
    "@(#)$Id$";

InfoIdGroup := NewInfoClass( "InfoIdGroup" );

UnbindGlobal( "SmallGroup" );

#############################################################################
##
#O  SmallGroup(<size>,<i>)
##
##  returns the <i>th  group of  order <size> in the catalogue. It will return
##  an PcGroup, if the group is soluble and a permutation group otherwise.
DeclareGlobalFunction( "SmallGroup" );

UnbindGlobal( "AllSmallGroups" );
DeclareGlobalFunction( "AllSmallGroups" );

#############################################################################
##
#O  NumberSmallGroups(<size>)
##
##  returns the  number of groups of the order <size>.
DeclareGlobalFunction( "NumberSmallGroups" );

#############################################################################
##
#O  UnloadSmallGroups(<sizes>)
##
##  will remove the small groups of the sizes given in <sizes> from memory. The
##  groups will be loaded again automatically if necessary.
DeclareGlobalFunction( "UnloadSmallGroups" );

UnbindGlobal( "IdGroup" );

#############################################################################
##
#A  IdGroup(<G>)
##
##  Let <G> be a group of size at most 1000, but not  of size 256, 512 or 768.
##  Then `IdGroup( <G> )'  returns a pair `[<size>, <i>]'  meaning  that  <G>
##  is isomorphic  to the <i>-th group in the catalogue of small groups of
##  order <size>.
DeclareAttribute( "IdGroup", IsGroup );

DeclareGlobalFunction( "PermGroupCode" );
DeclareGlobalFunction( "GroupCode" );
DeclareGlobalFunction( "LoadSmallGroups" );

DeclareGlobalFunction( "IdGroupRandomTest" );
DeclareGlobalFunction( "IdGroupSpecialFp" );
DeclareGlobalFunction( "IdSmallGroup" );
DeclareGlobalFunction( "IdP1Q1R1Group" );
DeclareGlobalFunction( "IdP2Q1Group" );
DeclareGlobalFunction( "IdP1Q2Group" );
DeclareGlobalFunction( "IdP1Group" );
DeclareGlobalFunction( "IdP2Group" );
DeclareGlobalFunction( "IdP3Group" );
DeclareGlobalFunction( "IdP1Q1Group" );

