############################################################################
##
#W hnf.gd			NQL				René Hartung
##
#H   @(#)$Id: hnf.gd,v 1.2 2008/08/28 08:04:20 gap Exp $
##
Revision.("nql/gap/hnf_gd"):=
  "@(#)$Id: hnf.gd,v 1.2 2008/08/28 08:04:20 gap Exp $";


############################################################################
##
#F  NQL_PowerRelationsOfHNF ( <rec> )
##
DeclareGlobalFunction( "NQL_PowerRelationsOfHNF" );

############################################################################
##
#F  NQL_ReduceHNF ( <mat> , <int> )
##
DeclareGlobalFunction( "NQL_ReduceHNF" );

############################################################################
##
#F  NQL_AddRow ( <mat> , <evec> )
##
DeclareGlobalFunction( "NQL_AddRow" );

############################################################################
##
#F  NQL_RowReduce( <ev>, <HNF> )
##
DeclareGlobalFunction( "NQL_RowReduce" );
