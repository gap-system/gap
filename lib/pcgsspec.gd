#############################################################################
##
#W  pcgsspec.gd                 GAP library                      Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.pcgsspec_gd :=
    "@(#)$Id$";


#############################################################################
##

#V  InfoSpecPcgs
##
DeclareInfoClass( "InfoSpecPcgs" );


#############################################################################
##

#P  IsSpecialPcgs
##
DeclareProperty( "IsSpecialPcgs", IsPcgs );



#############################################################################
##
#A  SpecialPcgs( <pcgs> )
##
DeclareAttribute( "SpecialPcgs",
    IsPcgs );



#############################################################################
##
#A  LGWeights( <pcgs> )
##
DeclareAttribute( "LGWeights", IsPcgs );


#############################################################################
##
#A  LGLayers( <pcgs> )
##
DeclareAttribute( "LGLayers", IsPcgs );


#############################################################################
##
#A  LGFirst( <pcgs> )
##
DeclareAttribute( "LGFirst", IsPcgs );

#############################################################################
##
#A  InducedPcgsWrtSpecialPcgs( <G> )
##
DeclareAttribute( "InducedPcgsWrtSpecialPcgs",
                                            IsGroup );


#############################################################################
##
#A  CanonicalPcgsWrtSpecialPcgs( <G> )
##
DeclareAttribute( "CanonicalPcgsWrtSpecialPcgs",
                                              IsGroup );


#############################################################################
##
#P  IsInducedPcgsWrtSpecialPcgs( <pcgs> )
##
DeclareProperty( "IsInducedPcgsWrtSpecialPcgs",
                                             IsPcgs );


#############################################################################
##
#P  IsCanonicalPcgsWrtSpecialPcgs( <pcgs> )
##
DeclareProperty( "IsCanonicalPcgsWrtSpecialPcgs",
                                               IsPcgs );


#############################################################################
##
#E  pcgsspec.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
