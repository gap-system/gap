#############################################################################
##
#W  small.gd                 GAP group library             Hans Ulrich Besche
#W                                                             & Bettina Eick
##
Revision.small_gd :=
    "@(#)$Id: ";

InfoIdGroup := NewInfoClass( "InfoIdGroup" );

CoefficientsMultiadic := NewOperationArgs( "CoefficientsMultiadic" );
PermGroupCode := NewOperationArgs( "PermGroupCode" );
GroupCode := NewOperationArgs( "GroupCode" );
LoadSmallGroups := NewOperationArgs( "LoadSmallGroups" );
UnloadSmallGroups := NewOperationArgs( "UnloadSmallGroups" );
SmallGroup := NewOperationArgs( "SmallGroup" );
AllSmallGroups := NewOperationArgs( "AllSmallGroups" );
NumberSmallGroups := NewOperationArgs( "NumberSmallGroups" );

IdGroupRandomTest := NewOperationArgs( "IdGroupRandomTest" );
IdGroupSpecialFp := NewOperationArgs( "IdGroupSpecialFp" );
EvalFpCoc := NewOperationArgs( "EvalFpCoc" );
IdSmallGroup := NewOperationArgs( "IdSmallGroup" );
IdP1Q1R1Group := NewOperationArgs( "IdP1Q1R1Group" );
IdP2Q1Group := NewOperationArgs( "IdP2Q1Group" );
IdP1Q2Group := NewOperationArgs( "IdP1Q2Group" );
IdP1Group := NewOperationArgs( "IdP1Group" );
IdP2Group := NewOperationArgs( "IdP2Group" );
IdP3Group := NewOperationArgs( "IdP3Group" );
IdP1Q1Group := NewOperationArgs( "IdP1Q1Group" );

IdGroup := NewAttribute( "IdGroup", IsGroup );
