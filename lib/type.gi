#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file implements some additional functions relating to types and
##  families.
##

#############################################################################
##
#M  FiltersType( <type> )
##
##  Return list of filters set in the given type.
##
InstallMethod(FiltersType, "for a type", [ IsType ],
    type -> FILTERS{ TRUES_FLAGS(type![POS_FLAGS_TYPE]) });

#############################################################################
##
#M  FiltersObj( <object> )
##
##  Return list of filters set in the type of <object>.
##
InstallMethod(FiltersObj, "for an object", [ IsObject ],
    obj -> FiltersType(TypeObj(obj)));

#############################################################################
##
#M  NamesFilterShort( flags, max )
##
##  Make a shortened list of filter names for display purposes
##
BindGlobal("NamesFilterShort",
function(flags, max)
    local names;

    names := NamesFilter(flags);
    if Length(names) > max then
        names := names{[1..max]};
        Add(names, "...");
    fi;
    names := JoinStringsWithSeparator(names, ", ");

    return Concatenation("[ ", names, " ]");
end);

#############################################################################
##
#M  ViewString( <fam> )
##
InstallMethod( ViewString,
    "for a family",
    true,
    [ IsFamily ],
    0,
function(family)
    return STRINGIFY("<Family: \"", family!.NAME, "\">");
end);

#############################################################################
##
#M  DisplayString( <fam> )
##
InstallMethod( DisplayString,
    "for a family",
    true,
    [ IsFamily ],
    0,
function(family)
    local  res, req_flags, imp_flags, fnams;

    res := "";
    Append(res, STRINGIFY("name:\n    ", family!.NAME));
    req_flags := TRUES_FLAGS(family!.REQ_FLAGS);
    fnams := NamesFilter(req_flags);
    fnams := JoinStringsWithSeparator(fnams, "\n    ");
    Append(res, STRINGIFY("\nrequired filters:\n    ", fnams));
    imp_flags := family!.IMP_FLAGS;
    if imp_flags <> [  ]  then
        fnams := NamesFilter(TRUES_FLAGS(imp_flags));
        fnams := JoinStringsWithSeparator(fnams, "\n    ");
        Append(res, STRINGIFY( "\nimplied filters:\n    ", fnams));
    fi;
    return res;
end);

#############################################################################
##
#M  ViewString( <type> )
##
InstallOtherMethod( ViewString,
    "for a type",
    true,
    [ IsType ],
    0,
function ( type )
    local  res, family, flags, data;

    res := "<Type: (";
    family := type![POS_FAMILY_TYPE];
    Append(res, family!.NAME);
    Append(res, ", ");

    flags := type![POS_FLAGS_TYPE];
    Append(res, NamesFilterShort(flags, 3) );
    Append(res, ")");

    data := type![POS_DATA_TYPE];
    if data <> false  then
        Append(res, STRINGIFY(", data: ", data ) );
    fi;
    Append(res, ">");
    return res;
end);

#############################################################################
##
#M  DisplayString( <type> )
##
InstallOtherMethod( DisplayString,
    "for a type",
    true,
    [ IsType ],
    0,
function ( type )
    local  res, family, flags, data, fnams;

    res := "";
    family := type![POS_FAMILY_TYPE];
    flags := type![POS_FLAGS_TYPE];
    data := type![POS_DATA_TYPE];

    Append(res, STRINGIFY("family:\n    ", family!.NAME));
    if flags <> [  ] or data <> false  then
        fnams := NamesFilter(TRUES_FLAGS(flags));
        fnams := JoinStringsWithSeparator(fnams, "\n    ");
        Append(res, STRINGIFY("\nfilters:\n    ", fnams));
        if data <> false  then
            Append(res, STRINGIFY("\ndata:\n", data ) );
        fi;
    fi;
    return res;
end);

InstallGlobalFunction( TypeOfOperation,
function(oper)
    local type, flags, types, catok, repok, propok, seenprop, t;
    if not IsOperation(oper) then
        ErrorNoReturn("<oper> must be an operation");
    fi;

    type := "Operation";
    if IS_IDENTICAL_OBJ(oper, IS_OBJECT) then
        type := "Filter";
    elif IS_CONSTRUCTOR(oper) then
        type := "Constructor";
    elif IsFilter(oper) then
        type := "Filter";
        flags := FLAGS_FILTER(oper);
        if flags <> false then
            flags := TRUES_FLAGS(flags);
            types := [];
            atomic readonly FILTER_REGION do
                for t in flags do
                    AddSet(types, INFO_FILTERS[t]);
                od;
            od;
            catok := true;
            repok := true;
            propok := true;
            seenprop := false;
            for t in types do
                if not t in FNUM_REPS then
                    repok := false;
                fi;
                if not t in FNUM_CATS then
                    catok := false;
                fi;
                if not t in FNUM_PROS and not t in FNUM_TPRS then
                    propok := false;
                fi;
                if t in FNUM_PROS then
                    seenprop := true;
                fi;
            od;
            if seenprop and propok then
                type := "Property";
            elif catok then
                type := "Category";
            elif repok then
                type := "Representation";
            fi;
        fi;
    elif IsOperation(FLAG1_FILTER(oper)) and IsOperation(FLAG1_FILTER(oper)) then
        # this is a setter for an and-filter
        type := "Setter";
    elif FLAG1_FILTER(oper) > 0 then
        # this is a setter for an elementary filter
        type := "Setter";
    elif Tester(oper) <> false  then
        # oper is an attribute
        type := "Attribute";
    fi;
    return type;
end);

InstallGlobalFunction( IsCategory,
function(object)
    return IsOperation(object) and TypeOfOperation(object) = "Category";
end);

InstallGlobalFunction( IsRepresentation,
function(object)
    return IsOperation(object) and TypeOfOperation(object) = "Representation";
end);

InstallGlobalFunction( IsAttribute,
function(object)
    return IsOperation(object) and TypeOfOperation(object) = "Attribute";
end);

InstallGlobalFunction( IsProperty,
function(object)
    return IsOperation(object) and TypeOfOperation(object) = "Property";
end);

InstallGlobalFunction( CategoryByName,
function(name)
    local fid;

    atomic readonly CATS_AND_REPS, FILTER_REGION do
    for fid in CATS_AND_REPS do
        if (INFO_FILTERS[fid] in FNUM_CATS) and
           (NAME_FUNC(FILTERS[fid]) = name) then
            return FILTERS[fid];
        fi;
    od;
    od;
    return fail;
end);
