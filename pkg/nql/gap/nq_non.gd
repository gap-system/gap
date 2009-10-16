############################################################################
##
#W nq_non.gd			NQL				René Hartung
##
#H   @(#)$Id: nq_non.gd,v 1.2 2008/08/28 08:59:06 gap Exp $
##
Revision.("nql/gap/nq_non_gd"):=
  "@(#)$Id: nq_non.gd,v 1.2 2008/08/28 08:59:06 gap Exp $";


############################################################################
##
#F  NQL_TerminatedNonInvariantNQ( <LpGroup>, <QS> )
##
DeclareGlobalFunction("NQL_TerminatedNonInvariantNQ");

BindGlobal( "InfoNQL_MAX_GENS", 10);
