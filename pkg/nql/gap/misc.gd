############################################################################
##
#W misc.gd			NQL				René Hartung
##
#H   @(#)$Id: misc.gd,v 1.1 2008/08/28 08:12:26 gap Exp $
##
Revision.("nql/gap/misc_gi"):=
  "@(#)$Id: misc.gd,v 1.1 2008/08/28 08:12:26 gap Exp $";


############################################################################
##
#F  NQL_WordsOfLengthAtMostN( <list>, <n> )
##   
## returns a list of all words of <list> of length at most <n>
##
DeclareGlobalFunction( "NQL_WordsOfLengthAtMostN" );

############################################################################
##
#F  NQL_LowerCentralSeriesSections( <PcpGroup> )
##   
## returns either the p-ranks of the lower central series sections of
## <PcpGroup> or its abelian invariants.
##
DeclareGlobalFunction( "NQL_LowerCentralSeriesSections" );

############################################################################
##
#F  NQL_LCSofGuptaSidki( <PcpGroup>, <prime> )
##
## computes the lower central series sections of the Gupta-Sidki group
## from an index-3 subgroup which is invariantly L-presented.
##
DeclareGlobalFunction( "NQL_LCSofGuptaSidki" );
