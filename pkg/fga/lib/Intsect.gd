#############################################################################
##  
#W Intsect.gd                  FGA package                  Christian Sievers
##
## The declaration file for the computation of intersections of free groups
##
#H @(#)$Id: Intsect.gd,v 1.2 2003/09/05 13:58:57 gap Exp $
##
#Y 2003
##
Revision.("fga/lib/Intsect_gd") :=
    "@(#)$Id: Intsect.gd,v 1.2 2003/09/05 13:58:57 gap Exp $";


## These are all helper functions:

#############################################################################
##
#F  FGA_StateTable( <table>, <i>, <j> )
##
DeclareGlobalFunction( "FGA_StateTable" );

#############################################################################
##
#F  FGA_TrySetRepTable( <t>, <i>, <j>, <r>, <g> )
##
DeclareGlobalFunction( "FGA_TrySetRepTable" );

#############################################################################
##
#F  FGA_GetNr ( <state>, <statelist> )
##
DeclareGlobalFunction( "FGA_GetNr" );

#############################################################################
##
#F  FGA_FindRepInIntersection ( <A1>, <A2> )
##
DeclareGlobalFunction( "FGA_FindRepInIntersection" );


#############################################################################
##
#E
