#############################################################################
##
#W ispolyz.gi              POLENTA package                     Bjoern Assmann
##
##
#H  @(#)$Id:
##
#Y 2006
##

#############################################################################
##
#F POL_ComputePolyZSeries( G )
##
## IN: G ............ polycyclic group given by a pcp
##
## OUT: If G is polyZ, then this function returns a series of characteristic
##      subgroups, such that the factors are free-abelian.
##      If G is not polyZ, then this function returns fail.
##
POL_ComputePolyZSeries := function( G )
    local H,sers,der,nat,im,T;

    # setup
    H := G;
    sers := [G];

    # compute poly Z series
    repeat
        der := DerivedSubgroup( H );
        nat := NaturalHomomorphism( H, der );
        im := Image( nat );
        if IsFinite( im ) then
           return fail;
        else
           T := TorsionSubgroup( im );
           H := PreImage( nat, T );
           Add( sers, H );
        fi;
    until IsTrivial( H );

    SetEfaSeries( G, sers );
    return sers;
end;

#############################################################################
##
#F POL_IsPolyZGroup( G )
##
## IN: G ............. polycyclic group given by a pcp
##
## OUT: true if G is polyZ, false otherwise.
##
POL_IsPolyZGroup := function( G )
    local sers;

    sers := POL_ComputePolyZSeries( G );
    if sers = fail then
        return false;
    else
        return true;
    fi;

end;


#############################################################################
##
#M IsPolyInfiniteCyclicGroup( G )
##
## IN: G ............. polycyclic group given by a pcp
##
## OUT: true if G is polyZ, false otherwise.
##
InstallMethod( IsPolyInfiniteCyclicGroup, "for pcp groups", true,
               [ IsPcpGroup ], 0,
function( G )
    return POL_IsPolyZGroup( G );
end );

#############################################################################
##
#E
