#############################################################################
##
#W  ReprActT.gi              FGA package                    Christian Sievers
##
##  Trivial cases for RepresentativeAction
##
##  This is generally applicable and not needed for the FGA package,
##  so maybe it should move to the GAP library.
##
#H  @(#)$Id: ReprActT.gi,v 1.1 2003/03/21 14:38:01 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/ReprActT_gi") :=
    "@(#)$Id: ReprActT.gi,v 1.1 2003/03/21 14:38:01 gap Exp $";


InstallOtherMethod( RepresentativeActionOp,
    "trivial general cases",
    IsCollsElmsElmsX,
    [ IsGroup, IsObject, IsObject, IsFunction ],
    function( G, d, e, act)
        local result;
        if act=OnRight then
            result := LeftQuotient( d, e );
        elif act=OnLeftInverse then
            result := d / e;
        else
            TryNextMethod();
        fi;
        if result in G then
            return result;
        else
            return fail;
        fi;
    end );


#############################################################################
##
#E
