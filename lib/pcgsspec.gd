#############################################################################
##
#W  pcgsspec.gd                 GAP library                      Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.pcgsspec_gd :=
    "@(#)$Id$";


#############################################################################
##

#V  InfoSpecPcgs
##
InfoSpecPcgs := NewInfoClass( "InfoSpecPcgs" );


#############################################################################
##

#P  IsSpecialPcgs
##
IsSpecialPcgs := NewProperty( "IsSpecialPcgs", IsPcgs );

SetIsSpecialPcgs := Setter(IsSpecialPcgs);
HasIsSpecialPcgs := Tester(IsSpecialPcgs);


#############################################################################
##

#A  SpecialPcgs( <pcgs> )
##
SpecialPcgs := NewAttribute( "SpecialPcgs",
    IsPcgs );

SetSpecialPcgs := Setter(SpecialPcgs);
HasSpecialPcgs := Tester(SpecialPcgs);


#############################################################################
##
#A  LGWeights( <pcgs> )
##
LGWeights := NewAttribute( "LGWeights", 
    IsPcgs and IsSpecialPcgs );

SetLGWeights := Setter(LGWeights);
HasLGWeights := Tester(LGWeights);


#############################################################################
##
#A  LGLayers( <pcgs> )
##
LGLayers := NewAttribute( "LGLayers", 
    IsPcgs and IsSpecialPcgs );

SetLGLayers := Setter(LGLayers);
HasLGLayers := Tester(LGLayers);


#############################################################################
##
#A  LGFirst( <pcgs> )
##
LGFirst := NewAttribute( "LGFirst", 
    IsPcgs and IsSpecialPcgs );

SetLGFirst := Setter(LGFirst);
HasLGFirst := Tester(LGFirst);

#############################################################################
##
#A  InducedPcgsWrtSpecialPcgs( <G> )
##
InducedPcgsWrtSpecialPcgs := NewAttribute( "InducedPcgsWrtSpecialPcgs",
                                            IsGroup );

SetInducedPcgsWrtSpecialPcgs := Setter( InducedPcgsWrtSpecialPcgs );
HasInducedPcgsWrtSpecialPcgs := Tester( InducedPcgsWrtSpecialPcgs );

#############################################################################
##
#A  CanonicalPcgsWrtSpecialPcgs( <G> )
##
CanonicalPcgsWrtSpecialPcgs := NewAttribute( "CanonicalPcgsWrtSpecialPcgs",
                                              IsGroup );

SetCanonicalPcgsWrtSpecialPcgs := Setter( CanonicalPcgsWrtSpecialPcgs );
HasCanonicalPcgsWrtSpecialPcgs := Tester( CanonicalPcgsWrtSpecialPcgs );

#############################################################################
##
#P  IsInducedPcgsWrtSpecialPcgs( <pcgs> )
##
IsInducedPcgsWrtSpecialPcgs := NewProperty( "IsInducedPcgsWrtSpecialPcgs",
                                             IsPcgs );

SetIsInducedPcgsWrtSpecialPcgs := Setter( IsInducedPcgsWrtSpecialPcgs );
HasIsInducedPcgsWrtSpecialPcgs := Tester( IsInducedPcgsWrtSpecialPcgs );

#############################################################################
##
#P  IsCanonicalPcgsWrtSpecialPcgs( <pcgs> )
##
IsCanonicalPcgsWrtSpecialPcgs := NewProperty( "IsCanonicalPcgsWrtSpecialPcgs",
                                               IsPcgs );

SetIsCanonicalPcgsWrtSpecialPcgs := Setter( IsCanonicalPcgsWrtSpecialPcgs );
HasIsCanonicalPcgsWrtSpecialPcgs := Tester( IsCanonicalPcgsWrtSpecialPcgs );

#############################################################################
##

#E  pcgsspec.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
