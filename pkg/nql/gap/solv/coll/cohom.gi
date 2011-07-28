############################################################################
##
#W cohom.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: cohom.gi,v 1.1 2010/07/26 05:18:46 gap Exp $
##
Revision.("isopcp/gap/coll/coll_gi"):=
  "@(#)$Id: cohom.gi,v 1.1 2010/07/26 05:18:46 gap Exp $";

############################################################################
##
#F  TwoCohomology( Q, N, Coupling )
##
TwoCohomology := function( Q, N, Coupling )
  local CRRec, Tails;

  if not IsAbelian( N ) then
    Error("<N> must be an abelian group");
  fi;

  CRRec := CRRecord( Q, N, Coupling );
  Tails := ConsistencyChecks( CRRec );


  return( Tails );
end;
