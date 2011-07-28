#############################################################################
##  
#W Intsect.gd                  FGA package                  Christian Sievers
##
## The declaration file for the computation of intersections of free groups
##
#H @(#)$Id: Intsect.gd,v 1.3 2010/04/13 09:41:43 gap Exp $
##
#Y 2003 - 2009
##
Revision.("fga/lib/Intsect_gd") :=
    "@(#)$Id: Intsect.gd,v 1.3 2010/04/13 09:41:43 gap Exp $";


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
#F  FGA_FindRepInIntersection ( <A1>, <t1>, <A2>, <t2> )
##
DeclareGlobalFunction( "FGA_FindRepInIntersection" );


#############################################################################
##
#E
