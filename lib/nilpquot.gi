#############################################################################
##  
#W  nilpquot.gi                 GAP Library                     Werner Nickel
##
##

# TODO: document this function? it is used in various packages by now
BindGlobal( "LeftNormedComm", function( list )
    local c, i;

    if not IsList(list) or Length(list) = 0 then
        Error("<list> must be a non-empty list");
    fi;
    c := list[1];
    for i in [2..Length(list)] do
        c := Comm(c, list[i]);
    od;
    return c;
end );
