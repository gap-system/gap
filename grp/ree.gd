#############################################################################
#
#W  ree.gd                        GAP library                Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  (C) 2001 School Math. Sci., University of St.  Andrews, Scotland
##
Revision.ree_gd :=
    "@(#)$Id$";

#############################################################################
##
#O  ReeGroupCons( <filter>, <q> )
##
DeclareConstructor( "ReeGroupCons", [ IsGroup, IsInt ] );

#############################################################################
##
#F  ReeGroup( [<filt>, ] <q> )  . . . . . . . . . . . . . . . Ree group
#F  Ree( [<filt>, ] <q> )
##
##  Constructs a group isomorphic to the Ree group $2G2(q)$ where
##  $q=3^{1+2m}$ for $m>0$.
##
##  If <filt> is not given it defaults to `IsMatrixGroup' and
##  the generating matrices are based on~\cite{KLM01}.
##  (No particular choice of a generating set is guaranteed.)
#
BindGlobal( "ReeGroup", function ( arg )

  if Length(arg) = 1 then
    return ReeGroupCons( IsMatrixGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2 then
      return ReeGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: ReeGroup( [<filter>, ] <m> )" );

end );

DeclareSynonym( "Ree", ReeGroup );

#############################################################################
##
#E  ree.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

