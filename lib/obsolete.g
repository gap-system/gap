#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains a helpers for declaring synonyms for functions which
##  are now deprecated.
##

BIND_GLOBAL( "DeclareObsoleteSynonym", function( name_obsolete, name_current, level_arg... )
    local value, orig_value, printed_warning, level;
    if not ForAll( [ name_obsolete, name_current ], IsString ) then
        Error("Each argument of DeclareObsoleteSynonym must be a string\n");
    fi;
    if Length(level_arg) = 0 then
        level := 2;
    else
        level := level_arg[1];
    fi;

    value := ValueGlobal( name_current );
    if IsFunction( value ) then
        orig_value := value;
        printed_warning := false;
        value := function (arg)
            local res;
            if not printed_warning and InfoLevel(InfoObsolete) >= level then
                Info( InfoObsolete, level, "'", name_obsolete, "' is obsolete.",
                    "\n#I  It may be removed in a future release of GAP.",
                    "\n#I  Use ", name_current, " instead.");
                printed_warning := true;
            fi;
            # TODO: This will error out if orig_value is a function which returns nothing.
            #return CallFuncList(orig_value, arg);
            res := CallFuncListWrap(orig_value, arg);
            if Length(res) = 1 then
                return res[1];
            fi;
        end;
    fi;
    BIND_GLOBAL( name_obsolete, value );
end );

BIND_GLOBAL( "DeclareObsoleteSynonymAttr", function( name_obsolete, name_current, level_arg... )
    local level;
    Assert(0, IsFunction( ValueGlobal( name_current ) ) );
    level := 1;
    if Length(level_arg) > 0 then
        level := level_arg[1];
    fi;
    DeclareObsoleteSynonym( name_obsolete, name_current, level );
    DeclareObsoleteSynonym( Concatenation("Set", name_obsolete), Concatenation("Set", name_current), level );
    DeclareObsoleteSynonym( Concatenation("Has", name_obsolete), Concatenation("Has", name_current), level );
end );
