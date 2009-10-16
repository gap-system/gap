#############################################################################
##
#A  tblgener.gd             GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
##
##  Table generation
##
#H  @(#)$Id: tblgener.gd,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/tblgener_gd") :=
    "@(#)$Id: tblgener.gd,v 1.4 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  CreateBoundsTable( <Sz>, <q> [, <info> ] ) . . constructs table of bounds
##
DeclareOperation("CreateBoundsTable", [IsInt, IsInt, IsBool]); 

