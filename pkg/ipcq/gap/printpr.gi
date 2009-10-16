#############################################################################
##
#W  printpr.gi                 ipcq package                      Bettina Eick
##
##  Printing a module presentation in useful format
##

#############################################################################
##
#F PrintWord( w )
##
PrintWord := function( w )
    local i;
    Sort( w, function( a, b )
             return Exponents(a[2])^2 < Exponents(b[2])^2; end );

    # the trivial case
    if Length( w ) = 0 then Print(" ( ",0, " )  "); return; fi;

    # the first coefficient
    if w[1][1] = w[1][1] ^ 0 and w[1][2] = w[1][2] ^ 0 then
        Print(" ( id");
    elif w[1][1] = w[1][1] ^ 0 then
        Print(" ( ", w[1][2]);
    elif w[1][1] = - w[1][1] ^ 0 and w[1][2] = w[1][2] ^ 0 then
        Print(" ( - id");
    elif w[1][1] = - w[1][1] ^ 0 then
        Print(" ( - ", w[1][2]);
    elif w[1][2] = w[1][2] ^ 0 then
        Print(" ( ",w[1][1],"*id");
    else
        Print(" ( ",w[1][1],"*", w[1][2]);
    fi;

    # the remaining coefficients
    for i in [2..Length(w)] do
        if w[i][1] = w[i][1] ^ 0 then
            Print( " + ", w[i][2] );
        elif w[i][1] = - w[i][1] ^ 0 then
            Print( " - ", w[i][2] );
        elif w[i][1] < 0 then
            Print( " - ",-w[i][1], "*", w[i][2] );
        elif w[i][1] > 0 then
            Print( " + ",w[i][1], "*", w[i][2] );
        fi;
    od;
    Print(" )  ");
end;

#############################################################################
##
#F PrettyPrintMPres( M )
##
PrettyPrintMPres := function( M )
    local i, j;
    Print("all pc tails: ",[1..M.nrpct],"\n");
    Print("all fp tails: ",[M.nrpct + 1..M.nrtails],"\n");
    Print("used tails: ",M.used,"\n");
    for i in [1..M.cols] do
        for j in [1..M.rows] do
            if IsBound( M.tails[j] ) then
               if M.word then
                   PrintWord( ShallowCopy(M.tails[j][i]) );
               else
                   Print( " ",M.tails[j][i]," " );
               fi;
            fi;
        od;
        Print("\n");
    od;
end;
