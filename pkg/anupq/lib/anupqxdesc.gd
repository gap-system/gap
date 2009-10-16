#############################################################################
####
##
#W  anupqxdesc.gd              ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  Declares functions to do recursive development of a descendants tree.
##  If ANUPQ is loaded from XGAP the development is seen graphically.
##    
#H  @(#)$Id: anupqxdesc.gd,v 1.1 2002/03/25 15:16:25 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqxdesc_gd :=
    "@(#)$Id: anupqxdesc.gd,v 1.1 2002/03/25 15:16:25 gap Exp $";

#############################################################################
##
#O  GraphicSheet() . . . . . . . . . . . . . . . . . . . . .  dummy operation
#O  Disc() . . . . . . . . . . . . . . . . . . . . . . . . .  dummy operation
#O  Line() . . . . . . . . . . . . . . . . . . . . . . . . .  dummy operation
##
##  These dummy operations are declared so that the functions  below  may  be
##  defined    even    for    a    non-{\XGAP}    {\GAP}    session,    where
##  `PqDescendantsTreeCoclassOne' will still work but without displaying  the
##  tree developed graphically.
##
DeclareOperation( "GraphicSheet", [] );
DeclareOperation( "Disc", [] );
DeclareOperation( "Line", [] );

#############################################################################
##
#F  PqDescendantsTreeCoclassOne([<i>]) . . . generate a coclass one des. tree
##
DeclareGlobalFunction( "PqDescendantsTreeCoclassOne" );

#############################################################################
##
#F  PQX_PLACE_NEXT_NODE( <datarec>, <class> ) . place a node on an XGAP sheet
##
DeclareGlobalFunction( "PQX_PLACE_NEXT_NODE" );

#############################################################################
##
#F  PQX_MAKE_CONNECTION( <datarec>, <a>, <b> ) . .  join two XGAP sheet nodes
##
DeclareGlobalFunction( "PQX_MAKE_CONNECTION" );

#############################################################################
##
#F  PQX_RECURSE_DESCENDANTS(<datarec>,<class>,<parent>,<n>)  extend des. tree
##
DeclareGlobalFunction( "PQX_RECURSE_DESCENDANTS" );

#E  anupqxdesc.gd . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
