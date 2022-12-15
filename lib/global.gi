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
##  This file contains the second stage of the "public" interface to
##  the global variable namespace, allowing globals to be accessed and
##  set by name.
##
##  This is defined in two stages. global.g defines "capitalized" versions
##  of the functions which do not use Info or other niceties and are not
##  set up with InstallGlobalFunction. This can thus be read early, and
##  the functions it defines can be used to define functions used to read
##  more of the library.
##
##  This file and global.gd   install the really "public"
##  functions and can be read later (once Info, DeclareGlobalFunction,
##  etc are there)
##
##  All of these functions give a warning at level 2 if the global
##  variable name contains characters not recognised as part of
##  identifiers by the GAP parser
##
##  Functions that read data give Info messages at level 3 for InfoGlobal
##  Functions that change data give Info messages at level 2 for InfoGlobal
##


#############################################################################
##
#I  InfoGlobal  . . . . . . . . . . . . . . . . . . information message class
##

DeclareInfoClass("InfoGlobal");

#############################################################################
##
#F  IsValidIdentifier( <str> ) . . .  check if a string is a valid identifier
##

InstallGlobalFunction( IsValidIdentifier, function(str)
    return ForAll(str, c -> c in IdentifierLetters) and
           ForAny(str, c -> not (c in "0123456789")) and
           not str in GAPInfo.Keywords;
end);

#############################################################################
##
#F  CheckGlobalName( <name> ) . . . check global variable name -- warn if odd
##
##

CheckGlobalName := function( name )
    if not IsString( name ) then
      Error("CheckGlobalName: the argument must be a string");
    fi;
    if ForAny(name, l -> not l in IdentifierLetters) then
        Info(InfoWarning + InfoGlobal, 2,
             "suspicious global variable name ", name);
    fi;
end;

#############################################################################
##
#M  ValueGlobal ( <name> )  . . . . . . . . . . . access a global by its name
##
##  ValueGlobal ( <name> ) returns the value currently bound to the global
##  variable named by the string <name>. An error is raised if no value
##  is currently bound
##

InstallGlobalFunction( ValueGlobal, VALUE_GLOBAL );


#############################################################################
##
#M  IsBoundGlobal ( <name> )  . . . .  check if a global is bound by its name
##
##  IsBoundGlobal ( <name> ) returns true if a value currently bound
##  to the global variable named by the string <name> and false otherwise
##


InstallGlobalFunction( IsBoundGlobal,
        function (name)
    local isbound;
    CheckGlobalName( name );
    isbound := ISBOUND_GLOBAL(name);
    Info( InfoGlobal, 3,
          "IsBoundGlobal: called for ", name, " returned ", isbound);
    return isbound;
end);


#############################################################################
##
#M  IsAutoGlobal ( <name> )  . . . .  check if a global is automatic
##


InstallGlobalFunction( IsAutoGlobal,
        function (name)
    local isauto;
    CheckGlobalName( name );
    isauto := IS_AUTO_GVAR(name);
    Info( InfoGlobal, 3,
          "IsAutoGlobal: called for ", name, " returned ", isauto);
    return isauto;
end);

#############################################################################
##
#M  UnbindGlobal ( <name> ) . . . . . . . . . .  unbind a global  by its name
##
##  UnbindGlobal ( <name> ) removes any value currently bound
##  to the global variable named by the string <name>. Nothing is returned
##
##  A warning is given isf <name> was not bound
##  The global variable named by <name> must be writable,
##  otherwise an error is raised.
##

InstallGlobalFunction( UnbindGlobal,
        function (name)
    CheckGlobalName( name );
    if not ISBOUND_GLOBAL( name ) then
        Info( InfoWarning + InfoGlobal, 1,
              "UnbindGlobal: ", name, " already unbound");
    fi;
    Info( InfoGlobal, 2, "UnbindGlobal: called for ", name);
    UNBIND_GLOBAL( name );
end);


#############################################################################
##
#F  IsReadOnlyGlobal ( <name> ) . determine if a global variable is read-only
##
##  IsReadOnlyGlobal ( <name> ) returns true if the global variable
##  named by the string <name> is read-only and false otherwise (the default)
##

InstallGlobalFunction( IsReadOnlyGlobal,
        function (name)
    local isro;
    CheckGlobalName( name );
    isro := IS_READ_ONLY_GLOBAL(name);
    Info( InfoGlobal, 3,
          "IsReadOnlyGlobal: called for ", name, " returned ", isro);
    return isro;
end);

#############################################################################
##
#F  IsConstantGlobal ( <name> ) . determine if a global variable is constant
##
##  IsConstantGlobal ( <name> ) returns true if the global variable
##  named by the string <name> is constant and false otherwise (the default)
##

InstallGlobalFunction( IsConstantGlobal,
        function (name)
    local isro;
    CheckGlobalName( name );
    isro := IS_CONSTANT_GLOBAL(name);
    Info( InfoGlobal, 3,
          "IsConstantGlobal: called for ", name, " returned ", isro);
    return isro;
end);


#############################################################################
##
#F  MakeReadOnlyGlobal ( <name> ) . . . . .  make a global variable read-only
##
##  MakeReadOnlyGlobal ( <name> ) marks the global variable named by the
##  string <name> as read-only.
##
##  A warning is given if <name> has no value bound to it or if it is
##  already read-only
##

InstallGlobalFunction( MakeReadOnlyGlobal,
        function (name)
    CheckGlobalName( name );
    if name in ["time", "last", "last2", "last3", "~"] then
        Error("Making ",name," read-only is not a good idea!");
    fi;
    if not ISBOUND_GLOBAL( name ) then
        Info( InfoWarning + InfoGlobal, 1,
              "MakeReadOnlyGlobal: ", name, " no value bound");
    fi;
    if IS_READ_ONLY_GLOBAL( name ) then
        Info( InfoWarning + InfoGlobal, 1,
              "MakeReadOnlyGlobal: ", name, " already read-only");
    fi;
    Info( InfoGlobal, 2, "MakeReadOnlyGlobal: called for ", name);
    MAKE_READ_ONLY_GLOBAL( name );
end);


#############################################################################
##
#F  MakeReadWriteGlobal ( <name> )  . . . . make a global variable read-write
##
##  MakeReadWriteGlobal ( <name> ) marks the global variable named by the
##  string <name> as read-write
##
##  A warning is given if <name> is already read-write
##

InstallGlobalFunction( MakeReadWriteGlobal,
        function (name)
    CheckGlobalName( name );
    if not IS_READ_ONLY_GLOBAL( name ) then
        Info( InfoWarning + InfoGlobal, 1,
              "MakeReadWriteGlobal: ", name, " already read-write");
    fi;
    Info( InfoGlobal, 2, "MakeReadWriteGlobal: called for ", name);
    MAKE_READ_WRITE_GLOBAL( name );
end);

#############################################################################
##
#F  MakeConstantGlobal ( <name> )  . . . . .  make a global variable constant
##
##  MakeConstantGlobal ( <name> ) marks the global variable named by the
##  string <name> as constant
##
##  A warning is given if <name> is already constant
##

InstallGlobalFunction( MakeConstantGlobal,
        function (name)
    CheckGlobalName( name );
    if IS_CONSTANT_GLOBAL( name ) then
        Info( InfoWarning + InfoGlobal, 1,
              "MakeConstantGlobal: ", name, " already constant");
    fi;
    Info( InfoGlobal, 2, "MakeConstantGlobal: called for ", name);
    MAKE_CONSTANT_GLOBAL( name );
end);


#############################################################################
##
#F  BindGlobal ( <name>, <val> )  . . . . . . sets a global variable 'safely'
##
##  BindGlobal ( <name>, <val> ) sets the global variable named by
##  the string <name> to the value <val>, provided it was previously
##  unbound, and makes it read-only. This is intended to be the normal
##  way to create and set "official" global variable (such as
##  Operations and Categories)
##
##  An error is given if <name> already had a value bound.
##

InstallGlobalFunction( BindGlobal,
        function (name, value)
    CheckGlobalName( name );
    Info( InfoGlobal, 2, "BindGlobal: called to set ", name, " to ", value);
    BIND_GLOBAL( name, value );
end);


InstallGlobalFunction( BindConstant,
        function (name, value)
    CheckGlobalName( name );
    Info( InfoGlobal, 2, "BindConstant: called to set ", name, " to ", value);
    BIND_CONSTANT( name, value );
end);
