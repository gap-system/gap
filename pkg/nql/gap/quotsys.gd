############################################################################
##
#W quotsys.gd			NQL				René Hartung
##
#H   @(#)$Id: quotsys.gd,v 1.3 2009/05/06 12:56:31 gap Exp $
##
Revision.("nql/gap/quotsys_gd"):=
  "@(#)$Id: quotsys.gd,v 1.3 2009/05/06 12:56:31 gap Exp $";


############################################################################
##
#F  SmallerQuotientSystem ( <Q>, <int> )
## 
## Computes a nilpotent quotient system for G/gamma_i(G) if a nilpotent 
## quotient system for G/gamma_j(G) is known, i<j.
##
DeclareGlobalFunction( "SmallerQuotientSystem" );

############################################################################
##
#F  NQL_SaveQuotientSystem( <Q>, <String> )
##
## stores the quotient system <Q> in the file <String>.
##
DeclareGlobalFunction( "NQL_SaveQuotientSystem" );

############################################################################
##
#F  NQL_SaveQuotientSystemCover( <Q>, <String> )
##
DeclareGlobalFunction( "NQL_SaveQuotientSystemCover" );
