#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

# returns names of components
InstallMethod( RecNames,
               "for a record in internal representation",
               [ IsRecord and IsInternalRep ],
               REC_NAMES );


InstallGlobalFunction( "NamesOfComponents",
function( obj )
    if IsComponentObjectRep( obj ) then
        return REC_NAMES_COMOBJ( obj );
    elif IsRecord( obj ) then
        return RecNames( obj );
    else
        Error( "<obj> must be a component object or a record" );
    fi;
end );

#############################################################################
##
#m  PrintObj( <record> )
##
##  The record <record> is printed by printing all its components.
##
InstallMethod( PrintObj,
    "record",
    [ IsRecord ],
## Changed to use sorted component names to make printing nicer to read and
## independent of session (i.e., the ordering in which component names were
## first used). Except for the sorting of components this does the same as
## the former (now removed) kernel function FuncPRINT_PREC_DEFAULT.
    function( record )
    local com, i, snam, nam, names, order;
    Print("\>\>rec(\n\>\>");
    com := false;

    names := List(RecNames(record));
    order := [1..Length(names)];
    SortParallel(names, order);

    for i in [1..Length(names)] do
        nam := names[i];
        if com then
            Print("\<\<,\n\>\>");
        else
            com := true;
        fi;
        SET_PRINT_OBJ_INDEX(order[i]);
        # easy if nam is integer or valid identifier:
        if ForAll(nam, x-> x in IdentifierLetters) and Size(nam) > 0 then
          Print(nam, "\< := \>");
        else
          # otherwise we use (...) syntax:
          snam := String(nam);
          Print("("); View(snam); Print(")\< := \>");
        fi;
        PrintObj(record.(nam));
    od;
    Print(" \<\<\<\<)");
end);

#############################################################################
##
#m  String( <record> )  . . . . . . . . . . . . . . . . . . . .  for a record
##
InstallMethod( String,
    "record",
    [ IsRecord ],
    function( record )
    local   str,  nam,  com;

    str := "rec( ";
    com := false;
    for nam in Set(RecNames( record )) do
      if com then
        Append( str, ", " );
      else
        com := true;
      fi;
      Append( str, nam );
      Append( str, " := " );
      if IsStringRep( record.( nam ) )
         or ( IsString( record.( nam ) )
              and not IsEmpty( record.( nam ) ) ) then
        Append( str, "\"" );
        Append( str, String( record.(nam) ) );
        Append( str, "\"" );
      else
        Append( str, String( record.(nam) ) );
      fi;
    od;
    Append( str, " )" );
    # should not be necessary if all methods for components are alright
    ConvertToStringRep( str );
    return str;
end );


#############################################################################
##
#m  ViewObj( <record> ) . . . . . . . . . . . . . . .  for a record (default)
##
InstallMethod( ViewObj,
    "record",
    [ IsRecord ],
    function( record )
    local nam, com, i, snam, names, order;
    Print("\>\>rec( \>\>");
    com := false;

    names := List(RecNames(record));
    order := [1..Length(names)];
    SortParallel(names, order);

    for i in [1..Length(names)] do
        nam := names[i];
        if com then
            Print("\<,\< \>\>");
        else
            com := true;
        fi;
        SET_PRINT_OBJ_INDEX(order[i]);
        # easy if nam is integer or valid identifier:
        if ForAll(nam, x-> x in IdentifierLetters) and Size(nam) > 0 then
          Print(nam, " := ");
        else
          # otherwise we use (...) syntax:
          snam := String(nam);
          Print("("); View(snam); Print(") := ");
        fi;
        ViewObj(record.(nam));
    od;
    Print(" \<\<\<\<)");
end);


# methods to catch error cases

InstallMethod( \.,
               "catch error",
               true,
               [IsObject,IsObject],
               0,
function(obj,nr)
    local msg;
    msg:=Concatenation("illegal access to record component `obj.",
                        NameRNam(nr),"'\n",
                        "of the object <obj>. (Objects by default do not have record components.\n",
                        "The error might be a relic from translated GAP3 code.)");
    Error(msg);
end);

InstallMethod( IsBound\.,
               "catch error",true,[IsObject,IsObject],0,
function(obj,nr)
    local msg;
    msg:=Concatenation("illegal access to record component `IsBound(obj.",
                        NameRNam(nr),")'\n",
                        "of the object <obj>. (Objects by default do not have record components.\n",
                        "The error might be a relic from translated GAP3 code.)");
    Error(msg);
end);

InstallMethod( Unbind\.,
               "catch error",
               true,
               [IsObject,IsObject],
               0,
function(obj,nr)
    local msg;
    msg:=Concatenation("illegal access to record component `Unbind(obj.",
                       NameRNam(nr),")'\n",
                       "of the object <obj>. (Objects by default do not have record components.\n",
                       "The error might be a relic from translated GAP3 code.)");
    Error(msg);
end);

InstallMethod( \.\:\=,
               "catch error",
               true,
               [IsObject,IsObject,IsObject],
               0,
function(obj,nr,elm)
local msg;
    msg:=Concatenation("illegal assignment to record component `obj.",
                       NameRNam(nr),"'\n",
                       "of the object <obj>. (Objects by default cannot have record components.\n",
                       "The error might be a relic from translated GAP3 code.)");
    Error(msg);
end);

#############################################################################
##
#F  SetNamesForFunctionsInRecord( <rec-name>[, <record> ][, <field-names>])
##
##  set the names of functions bound to components of a record.
##
InstallGlobalFunction(SetNamesForFunctionsInRecord,
function(arg)
    local recname, next, record, fields, field;
    if LENGTH(arg) = 0 or not IS_STRING(arg[1]) then
        Error("SetNamesForFunctionsInRecord: you must give a record name");
    fi;
    recname := arg[1];
    next := 2;
    if LENGTH(arg) >= next and IS_REC(arg[next]) then
        record := arg[2];
        next := 3;
    else
        record := VALUE_GLOBAL(recname);
    fi;
    if LENGTH(arg) >= next and IS_LIST(arg[next]) then
        fields := arg[next];
    else
        fields := REC_NAMES(record);
    fi;
    for field in fields do
        if IS_STRING(field) then
            if IsFunction(record.(field)) then
                SetNameFunction(record.(field), Concatenation(recname,".",field));
            fi;
        fi;
    od;
end);
