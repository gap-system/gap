#############################################################################
##
#W  gprd.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.gprd_gd :=
    "@(#)$Id$";

DirectProduct := NewOperationArgs( "DirectProduct" );
DirectProductOfPermGroups := NewOperationArgs( "DirectProductOfPermGroups" );
DirectProductOfPcGroups := NewOperationArgs( "DirectProductOfPcGroups" );
DirectProductOfGroups := NewOperationArgs( "DirectProductOfGroups" );
SubdirectProduct := NewOperation( "SubdirectProduct",
    [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ] );
SemidirectProduct := NewOperation( "SemidirectProduct",
    [ IsGroup, IsGroupHomomorphism, IsGroup ] );
WreathProduct := NewOperation( "WreathProduct", [ IsObject, IsObject ] );
WreathProductProductAction := NewOperationArgs( "WreathProductProductAction" );
InnerSubdirectProducts := NewOperationArgs( "InnerSubdirectProducts" );
InnerSubdirectProducts2 := NewOperationArgs( "InnerSubdirectProducts2" );
SubdirectProducts := NewOperationArgs( "SubdirectProducts" );

#############################################################################
##
#A  DirectProductInfo( <G> )
##
DirectProductInfo := NewAttribute( "DirectProductInfo", IsGroup, "mutable" );
SetDirectProductInfo := Setter(DirectProductInfo);
HasDirectProductInfo := Tester(DirectProductInfo);

#############################################################################
##
#A  SubdirectProductInfo( <G> )
##
SubdirectProductInfo := NewAttribute( "SubdirectProductInfo", IsGroup, 
                                      "mutable" );
SetSubdirectProductInfo := Setter(SubdirectProductInfo);
HasSubdirectProductInfo := Tester(SubdirectProductInfo);

#############################################################################
##
#A  SemidirectProductInfo( <G> )
##
SemidirectProductInfo := NewAttribute( "SemidirectProductInfo", IsGroup, 
                                       "mutable" );
SetSemidirectProductInfo := Setter(SemidirectProductInfo);
HasSemidirectProductInfo := Tester(SemidirectProductInfo);

#############################################################################
##
#A  WreathProductInfo( <G> )
##
WreathProductInfo := NewAttribute( "WreathProductInfo", IsGroup, "mutable" );
SetWreathProductInfo := Setter(WreathProductInfo);
HasWreathProductInfo := Tester(WreathProductInfo);

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
