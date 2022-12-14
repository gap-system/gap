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
##
##  This file contains the first stage of the "public" interface to
##  the global variable namespace, allowing globals to be accessed and
##  set by name.
##
##  This is defined in two stages. This file defines "capitalized" versions
##  of the functions which do not use Info or other niceties and are not
##  set up with InstallGlobalFunction. This can thus be read early, and
##  the functions it defines can be used to define functions used to read
##  more of the library.
##
##  The global.gd and global.gi stages will install the really "public"
##  functions and can be read later (once Info, DeclareGlobalFunction,
##  etc are there)
##


#############################################################################
##
#F  VALUE_GLOBAL ( <name> ) .  . . . . . . . . . .access a global by its name
##
##  VALUE_GLOBAL ( <name> ) returns the value currently bound to the global
##  variable named by the string <name>. An error is raised if no value
##  is currently bound
##

VALUE_GLOBAL := VAL_GVAR;


#############################################################################
##
#F  ISBOUND_GLOBAL ( <name> ) .  . . . check if a global is bound by its name
##
##  ISBOUND_GLOBAL ( <name> ) returns true if a value currently bound
##  to the global variable named by the string <name> and false otherwise
##

ISBOUND_GLOBAL := ISB_GVAR;


#############################################################################
##
#F  UNBIND_GLOBAL ( <name> ) .  . . . . . . . . .unbind a global  by its name
##
##  UNBIND_GLOBAL ( <name> ) removes any value currently bound
##  to the global variable named by the string <name>. Nothing is returned.
##
##  The global variable named by <name> must be writable,
##  otherwise an error is raised.
##

UNBIND_GLOBAL := UNB_GVAR;

#############################################################################
##
#F  IS_READ_ONLY_GLOBAL ( <name> ) determine if a global variable is read-only
##
##  IS_READ_ONLY_GLOBAL ( <name> ) returns true if the global variable
##  named by the string <name> is read-only and false otherwise (the default)
##

IS_READ_ONLY_GLOBAL := IsReadOnlyGVar;

#############################################################################
##
#F  IS_CONSTANT_GLOBAL ( <name> ) determine if a global variable is constant
##
##  IS_CONSTANT_GLOBAL ( <name> ) returns true if the global variable
##  named by the string <name> is constant and false otherwise (the default)
##

IS_CONSTANT_GLOBAL := IsConstantGVar;

#############################################################################
##
#F  MAKE_READ_ONLY_GLOBAL ( <name> ) . . . . make a global variable read-only
##
##  MAKE_READ_ONLY_GLOBAL ( <name> ) marks the global variable named
##  by the string <name> as read-only.
##

MAKE_READ_ONLY_GLOBAL := MakeReadOnlyGVar;

#############################################################################
##
#F  MAKE_READ_WRITE_GLOBAL ( <name> ) . . .make a global variable read-write
##
##  MAKE_READ_WRITE_GLOBAL ( <name> ) marks the global variable named
##  by the string <name> as read-write
##

MAKE_READ_WRITE_GLOBAL := MakeReadWriteGVar;

#############################################################################
##
#F  MAKE_CONSTANT_GLOBAL ( <name> )
##
##  MAKE_CONSTANT_GLOBAL ( <name> ) marks the global variable named
##  by the string <name> as constant
##

MAKE_CONSTANT_GLOBAL := MakeConstantGVar;

#############################################################################
##
#V  REREADING                set to true inside a Reread, changes much
##                           behaviour
##

REREADING := false;
MAKE_READ_ONLY_GLOBAL("REREADING");


#############################################################################
##
#F  BIND_GLOBAL ( <name>, <val> ) . . . . . .sets a global variable 'safely'
##
##  BIND_GLOBAL ( <name>, <val> ) sets the global variable named by
##  the string <name> to the value <val>, provided it was previously
##  unbound, and makes it read-only. This is intended to be the normal
##  way to create and set "official" global variable (such as
##  Operations and Categories)
##

BIND_GLOBAL := function( name, val)
    if not REREADING and ISBOUND_GLOBAL( name ) then
        if (IS_READ_ONLY_GLOBAL(name)) then
            Error("BIND_GLOBAL: variable `", name, "' must be unbound");
        else
            Print("#W BIND_GLOBAL: variable `", name,"' already has a value\n");
        fi;
    fi;
    ASS_GVAR(name, val);
    MAKE_READ_ONLY_GLOBAL(name);
    return val;
end;
MAKE_READ_ONLY_GLOBAL("BIND_GLOBAL");

BIND_CONSTANT := function( name, val)
    # Ignore attempts to reassign an identical value, to simplify
    # rereading files
    if ISBOUND_GLOBAL( name ) and
       IS_IDENTICAL_OBJ( val, VAL_GVAR( name ) ) then
       return;
    fi;

    # Even when REREADING we do not allow constants to be changed, as
    # they are substituted in at parsing time
    ASS_GVAR(name, val);
    MAKE_CONSTANT_GLOBAL(name);
    return val;
end;
MAKE_READ_ONLY_GLOBAL("BIND_CONSTANT");
