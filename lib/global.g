

#############################################################################
##
#W  global.g                    GAP library                      Steve Linton
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
#V  REREADING                set to true inside a Reread, changes much
##                           behaviour
##

REREADING := false;
MAKE_READ_ONLY_GLOBAL("REREADING");

GLOBAL_REBINDING_LIST := [ ]; 
GLOBAL_REBINDING_COUNT := [ ]; 

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
local   pos; 
    ## special case: rebinding is permitted so increment count for 'name'  
    if ( name in GLOBAL_REBINDING_LIST ) then 
        pos := POS_LIST_DEFAULT( GLOBAL_REBINDING_LIST, name, 0 ); 
        GLOBAL_REBINDING_COUNT[pos] := GLOBAL_REBINDING_COUNT[pos] + 1; 
        ## if already bound then there is nothing to do 
        if ISBOUND_GLOBAL( name ) then 
            return; 
        fi;
    fi; 
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

#############################################################################
##
#F  AllowGlobalRebinding( <list> ) . . function(s) may be BIND_GLOBAL'ed twice
##
BIND_GLOBAL( "AllowGlobalRebinding", function( arg ) 
    local  L, pos, name, val;
    ##  form the arguments into a list of strings L 
    if ( LEN_LIST(arg) = 1 ) then 
        if IS_STRING_REP( arg[1] ) then 
            L := arg; 
        elif IS_LIST( arg[1] ) then 
            L := arg[1]; 
        fi; 
    else 
        L := arg; 
    fi; 
    for name in L do  
        if not IS_STRING_REP( name ) then 
            Error("arg must be a string (function name) or a list of strings");
        fi;
    od;
    for name in L do 
        ##  avoid duplicate entries in GLOBAL_REBINDING_LIST 
        pos := POS_LIST_DEFAULT( GLOBAL_REBINDING_LIST, name, 0 ); 
        if ( pos = fail ) then 
            ADD_LIST( GLOBAL_REBINDING_LIST, name ); 
            ##  has 'name' been declared already? 
            if ISBOUND_GLOBAL( name ) then 
                val := 1; 
            else 
                val := 0;
            fi; 
            ADD_LIST( GLOBAL_REBINDING_COUNT, val ); 
        fi;
    od;
end );

#############################################################################
##
#E  global.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



