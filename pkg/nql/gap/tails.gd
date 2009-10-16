############################################################################
##
#W tails.gd			NQL				René Hartung
##
#H   @(#)$Id: tails.gd,v 1.2 2008/08/28 08:04:20 gap Exp $
##
Revision.("nql/gap/tails_gd"):=
  "@(#)$Id: tails.gd,v 1.2 2008/08/28 08:04:20 gap Exp $";


############################################################################
## 
#F  NQL_Tails_lji ( <coll> , <Def of k> , <l> , <k>)  
##
## computes t_{kl}^{++}
##
DeclareGlobalFunction( "NQL_Tails_lji" );

############################################################################
## 
#F  NQL_Tails_lkk ( <coll> , <l> , <k>) 
##
## computes t_{kl}^{-+}
##
DeclareGlobalFunction( "NQL_Tails_lkk" );

############################################################################
##  
#F  NQL_Tails_llk ( <coll> , <l> , <k>) 
##
## computes t_{kl}^{+-} AND t_{kl}^{--}
##
DeclareGlobalFunction( "NQL_Tails_llk" );

############################################################################
##
#M  UpdateNilpotentCollector ( <coll>, <weights>, <defs> )
##
DeclareOperation( "UpdateNilpotentCollector",
  	[ IsFromTheLeftCollectorRep, IsList, IsList]);
