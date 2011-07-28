############################################################################
##
##  access.gd                     IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: obsolete.gi,v 1.2 2011/04/07 07:58:09 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  IndicesAbsolutelyIrreducibleSolvableMatrixGroups(<n>, <q>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IndicesAbsolutelyIrreducibleSolvableMatrixGroups,
    function (n, q)
        Info (InfoWarning, 1, "Obsolete function. See ?IndicesAbsolutelyIrreducibleSolvableMatrixGroups.");
        return IndicesIrreducibleSolvableMatrixGroups(n, q, 1);
    end);


############################################################################
##
#F  AbsolutelyIrreducibleSolvableMatrixGroup(<n>, <q>, <k>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (AbsolutelyIrreducibleSolvableMatrixGroup,
    function (n, q, k)
        Info (InfoWarning, 1, "Obsolete function. See ? AbsolutelyIrreducibleSolvableMatrixGroup.");
        return IrreducibleSolvableMatrixGroup(n, q, 1, k);
    end);


############################################################################
##
#F  RecognitionAbsolutelyIrreducibleSolvableMatrixGroup(G, wantmat, wantgroup)
##
##  see the IRREDSOL manual
##
InstallGlobalFunction (RecognitionAbsolutelyIrreducibleSolvableMatrixGroup,
    function (G, wantmat, wantgroup)
        local r;
        Info (InfoWarning, 1, "Obsolete function. See ? RecognitionAbsolutelyIrreducibleSolvableMatrixGroup.");
        r := RecognitionIrreducibleSolvableMatrixGroup (G, wantmat, wantgroup);
        if r.id[3] <> 1 then
            Error ("G is not absolutely irreducible");
        fi;
        r.id := r.id{[1,2,4]};
        return r;
    end);


############################################################################
##
#F  RecognitionAbsolutelyIrreducibleSolvableMatrixGroupNC(G, wantmat, wantgroup)
##
##  see the IRREDSOL manual
##
InstallGlobalFunction (RecognitionAbsolutelyIrreducibleSolvableMatrixGroupNC,
    function (G, wantmat, wantgroup)
        local r;
        Info (InfoWarning, 1, "Obsolete function. See ? RecognitionAbsolutelyIrreducibleSolvableMatrixGroupNC.");
        r := RecognitionIrreducibleSolvableMatrixGroupNC (G, wantmat, wantgroup);
        if r <> fail then
            if r.id[3] <> 1 then
                Error ("G is not absolutely irreducible");
            fi;
            r.id := r.id{[1,2,4]};
        fi;
        return r;
    end);


############################################################################
##
#A  IdAbsolutelyIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction ("IdAbsolutelyIrreducibleSolvableMatrixGroup",
    function (G)
        local r;
        Info (InfoWarning, 1, "Obsolete function. See ? IdAbsolutelyIrreducibleSolvableMatrixGroup.");
        r := IdIrreducibleSolvableMatrixGroup (G, false, false);
        if r[3] <> 1 then
            Error ("G is not absolutely irreducible");
        fi;
        return r{[1,2,4]};
    end);
    

############################################################################
##
#E
##
