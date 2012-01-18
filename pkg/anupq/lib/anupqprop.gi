#############################################################################
####
##
#W  anupqprop.gi               ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  Installs methods for properties and attributes needed for ANUPQ.
##    
#H  @(#)$Id: anupqprop.gi,v 1.3 2011/11/29 20:00:13 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

#############################################################################
##
#F  SET_PQ_PROPS_AND_ATTRS( <G>, <func> )
##
InstallGlobalFunction( SET_PQ_PROPS_AND_ATTRS, function( G, func )
local S;
  if not( HasIsPGroup(G) and IsPGroup(G) ) then
    Error( "supplied group is not known to be a p-group\n" );
  fi;
  S := PqStandardPresentation(G : Prime := PrimePGroup(G));
  SetIsCapable( G, IsCapable(S) );
  SetNuclearRank( G, NuclearRank(S) );
  SetMultiplicatorRank( G, MultiplicatorRank(S) );
  return func(G);
end );

#############################################################################
##
#M  IsCapable( <G> )
##    
InstallMethod( IsCapable, "fp p-groups", true, [ IsFpGroup ], 0,
  G -> SET_PQ_PROPS_AND_ATTRS(G, IsCapable)
);

InstallMethod( IsCapable, "pc p-groups", true, [ IsPcGroup ], 0,
  G -> SET_PQ_PROPS_AND_ATTRS(G, IsCapable)
);

#############################################################################
##
#M  NuclearRank( <G> )
##    
InstallMethod( NuclearRank, "fp p-groups", [ IsFpGroup ], 0,
  G -> SET_PQ_PROPS_AND_ATTRS(G, NuclearRank)
);

InstallMethod( NuclearRank, "pc p-groups", [ IsPcGroup ], 0,
  G -> SET_PQ_PROPS_AND_ATTRS(G, NuclearRank)
);

#############################################################################
##
#M  MultiplicatorRank( <G> )
##    
InstallMethod( MultiplicatorRank, "fp p-groups", [ IsFpGroup ], 0,
  G -> SET_PQ_PROPS_AND_ATTRS(G, MultiplicatorRank)
);

InstallMethod( MultiplicatorRank, "pc p-groups", [ IsPcGroup ], 0,
  G -> SET_PQ_PROPS_AND_ATTRS(G, MultiplicatorRank)
);

#E  anupqprop.gi  . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
