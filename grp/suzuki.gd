#############################################################################
##
#W  suzuki.gd                   GAP library                       Stefan Kohl
##
#H  @(#)$Id$
##
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.suzuki_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  SuzukiGroupCons( <filter>, <q> )
##
DeclareConstructor( "SuzukiGroupCons", [ IsGroup, IsInt ] );

#############################################################################
##
#F  SuzukiGroup( [<filt>, ] <q> )  . . . . . . . . . . . . . . . Suzuki group
#F  Sz( [<filt>, ] <q> )
##
##  Constructs a group isomorphic to the Suzuki group Sz( <q> )
##  over the field with <q> elements, where $q \ge 8$ is a non - square
##  power of 2.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the Suzuki group itself.
##
BindGlobal( "SuzukiGroup", function ( arg )

  if Length(arg) = 1 then
    return SuzukiGroupCons( IsMatrixGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2 then
      return SuzukiGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: SuzukiGroup( [<filter>, ] <q> )" );

end );

DeclareSynonym( "Sz", SuzukiGroup );
