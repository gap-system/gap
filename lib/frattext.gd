#############################################################################
##
#W  frattext.gd                 GAP library                      Bettina Eick
##
Revision.frattext_gd :=
    "@(#)$Id$";

#############################################################################
##
#I Infos
##
InfoFrattExt := NewInfoClass( "InfoFrattExt" );
InfoFEMeth := NewInfoClass( "InfoFEMeth" );

#############################################################################
##
#A FrattiniFactor 
##
FrattiniFactor := NewAttribute( "FrattiniFactor", IsGroup );
SetFrattiniFactor := Setter( FrattiniFactor );
HasFrattiniFactor := Tester( FrattiniFactor );

#############################################################################
##
#A FrattiniExtensionInfo 
##
FrattiniExtensionInfo := NewAttribute( "FrattiniExtensionInfo", IsGroup,
                                       "mutable" );
SetFrattiniExtensionInfo := Setter( FrattiniExtensionInfo );
HasFrattiniExtensionInfo := Tester( FrattiniExtensionInfo );
