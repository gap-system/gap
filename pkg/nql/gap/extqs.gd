############################################################################
##
#W extqs.gd			NQL				René Hartung
##
#H   @(#)$Id: extqs.gd,v 1.3 2009/05/06 12:55:31 gap Exp $
##
Revision.("nql/gap/extqs_gd"):=
  "@(#)$Id: extqs.gd,v 1.3 2009/05/06 12:55:31 gap Exp $";

############################################################################
##
#O  ExtendQuotientSystem ( <quo> )
##
## Extends the quotient system for G/gamma_i(G) to a consistent quotient
## system for G/gamma_{i+1}(G).
##
DeclareOperation( "ExtendQuotientSystem", [ IsObject ] );
