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
#P  IsSpecialPcgs( <obj> )
##
##  tests whether <obj> is a special pcgs.
DeclareProperty( "IsSpecialPcgs", IsPcgs );

#InstallTrueMethod(IsPcgsCentralSeries,IsSpecialPcgs);
InstallTrueMethod(IsPcgsElementaryAbelianSeries,IsSpecialPcgs);

#############################################################################
##
#A  SpecialPcgs( <pcgs> )
#A  SpecialPcgs( <G> )
##
##  computes a special pcgs for the group defined by <pcgs> or for <G>.

##  A method for `SpecialPcgs(<G>)' must call `SpecialPcgs(Pcgs(<G>))' (this
##  is to avoid accidentally forgetting information.)
DeclareAttribute( "SpecialPcgs", IsPcgs );

#############################################################################
##
#A  LGHeads( <pcgs> )
##
##  returns the LGHeads of the special pcgs <pcgs>.
DeclareAttribute( "LGHeads", IsPcgs );

#############################################################################
##
#A  LGTails( <pcgs> )
##
##  returns the LGTails of the special pcgs <pcgs>.
DeclareAttribute( "LGTails", IsPcgs );

#############################################################################
##
#A  LGWeights( <pcgs> )
##
##  returns the LGWeights of the special pcgs <pcgs>.
DeclareAttribute( "LGWeights", IsPcgs );


#############################################################################
##
#A  LGLayers( <pcgs> )
##
##  returns the layers of the special pcgs <pcgs>.
DeclareAttribute( "LGLayers", IsPcgs );


#############################################################################
##
#A  LGFirst( <pcgs> )
##
##  returns the first indices for each layer of the special pcgs <pcgs>.
DeclareAttribute( "LGFirst", IsPcgs );

#############################################################################
##
#A  LGLength( <G> )
##
##  returns the Length of the LG-series of the group <G>, if <G> is  solvable
##  and <fail> otherwise.
DeclareAttribute( "LGLength", IsGroup );

#############################################################################
##
#A  InducedPcgsWrtSpecialPcgs( <G> )
##
##  computes an induced pcgs with respect to the special pcgs of the
##  parent of <G>.
DeclareAttribute( "InducedPcgsWrtSpecialPcgs", IsGroup );


#############################################################################
##
#A  CanonicalPcgsWrtSpecialPcgs( <G> )
##
DeclareAttribute( "CanonicalPcgsWrtSpecialPcgs", IsGroup );


#############################################################################
##
#P  IsInducedPcgsWrtSpecialPcgs( <pcgs> )
##
##  tests whether <pcgs> is induced with respect to a special pcgs.
DeclareProperty( "IsInducedPcgsWrtSpecialPcgs", IsPcgs );


#############################################################################
##
#P  IsCanonicalPcgsWrtSpecialPcgs( <pcgs> )
##
DeclareProperty( "IsCanonicalPcgsWrtSpecialPcgs", IsPcgs );


#############################################################################
##
#E  pcgsspec.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
