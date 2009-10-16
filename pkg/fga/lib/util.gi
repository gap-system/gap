#############################################################################
##
#W  util.gi               FGA package                    Christian Sievers
##
##  Utility functions
##
#H  @(#)$Id: util.gi,v 1.1 2003/03/21 14:38:01 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/util_gi") :=
    "@(#)$Id: util.gi,v 1.1 2003/03/21 14:38:01 gap Exp $";


InstallGlobalFunction( BoundPositions,
    l -> Filtered([1..Length(l)], i -> IsBound(l[i])) );

InstallGlobalFunction( ATf,
    function(l, p)
    if IsBound(l[p]) then
        return l[p];
    else
        return fail;
    fi;
    end );


#############################################################################
##
#E
