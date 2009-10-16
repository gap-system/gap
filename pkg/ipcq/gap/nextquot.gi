#############################################################################
##
#W  nextquot.gi                   ipcq package                   Bettina Eick
##

#############################################################################
##
#F Avoided( Q, flags ) . . . . . . . . . . . check which tails can be avoided
##
##  flags.ignore  (bool) -- ignore definitions
##  flags.pcavoid (bool/list) -- avoid all/listed pc relators
##  flags.fpavoid (bool/list) -- avoid all/listed fp images
##
Avoided := function( Q, flags )
    local f;

    # shall we ignore definitions?
    if not IsBound( flags.ignore ) then 
        f := rec( pcrels := Q.pcdefs, fprels := Q.fpdefs );
    else
        f := rec( pcrels := [], fprels := [] );
    fi;

    # add avoided pc tails
    if IsBound(flags.pcavoid) and IsBool(flags.pcavoid) then
        f.pcrels := true;
    elif IsBound( flags.pcavoid ) then
        f.pcrels := Union( f.pcrels, flags.pcrels );
    fi;

    # add avoided fp tails
    if IsBound(flags.fpavoid) and IsBool(flags.fpavoid) then
        f.fprels := true;
    elif IsBound( flags.fpavoid ) then
        f.pcrels := Union( f.fprels, flags.fprels );
    fi;
    return f;
end;

AvoidPcTails := function( Q );
    return Avoided( Q, rec( pcavoid := true ) );
end;

AvoidPowers := function( Q )
    local f;
    f := Filtered( Q.pcenum, x -> x[1] = x[2] );
    f := List( f, x -> Position( Q.pcenum, x ) );
    f := rec( pcrels := f );
    return Avoided( Q, f );
end;

AvoidCommutators := function( Q )
    local f;
    f := Filtered( Q.pcenum, x -> x[1] <> x[2] );
    f := List( f, x -> Position( Q.pcenum, x ) );
    f := rec( pcrels := f );
    return Avoided( Q, f );
end;

#############################################################################
##
#F ModulePresInt( Q, flags )
##
ModulePresInt := function( Q, flags ) 
    local M;
    M := MSystemByWords( Q, Avoided( Q, flags ), Integers );
    AddModulePresentation( Q, M );
    return M;
end;

#############################################################################
##
#F ModulePresQSystem( Q )
##
ModulePresQSystem := function( Q )
    return ModulePresInt( Q, rec() );
end;

#############################################################################
##
#F NextStepInt( Q, flags )
##
NextStepInt := function( Q, flags )
    local M, N;
    Info( InfoIPCQ, 2, "  compute module presentation ");
    M := ModulePresInt( Q, flags );
    if M.rows = 0 then Add( Q.steps, [] ); return; fi;
    Info( InfoIPCQ, 2, "  call zme, ",M.rows, " tails, ",M.cols," rels");
    N := RunZme( Q, M );
    ExtendQSystem( Q, M, N );
end;

#############################################################################
##
#F NextStepSplit( Q )
##
NextStepSplit := function( Q )
    NextStepInt( Q, rec( ignore := true, pcavoid := true ) );
end;

#############################################################################
##
#F NextStepQSystem( Q )
##
InstallGlobalFunction( NextStepQSystem, function( Q )
    NextStepInt( Q, rec() );
    Info( InfoIPCQ, 1, "next step yields orders : ", Q.steps[Length(Q.steps)] );
    if CHECKIPCQ and not CheckQSystem(Q) then Error("wrong next step"); fi;
end );

