#############################################################################
##
#W  introspection.gi            GAP library
##
##  This file contains functions that help introspection of the GAP language
##  and types.
##

InstallMethod(ViewString,
              "for a family",
              true,
              [ IsFamily],
              0,
function(fam)
    local res, req_flags, imp_flags;
    req_flags := NamesFilter( TRUES_FLAGS( fam!.REQ_FLAGS ) );
    imp_flags := NamesFilter( TRUES_FLAGS( fam!.IMP_FLAGS ) );

    return STRINGIFY("family ",
                     fam!.NAME, "\n",
                     " required: \n        ",
                     JoinStringsWithSeparator(req_flags, ",\n        "), "\n",
                     " implied : \n        ",
                     JoinStringsWithSeparator(imp_flags, ",\n        ") );
end);

InstallMethod(ViewString,
              "for a type",
              true,
              [ IsType ],
function(type)
    local res, family, flags, data;

    family := type![1];
    flags := NamesFilter( TRUES_FLAGS( type![2] ) );
    data := type![ POS_DATA_TYPE ];

    return STRINGIFY("type\n",
                     " family: \n        ",
                     ViewString(family), "\n",
                     " filters : \n        ",
                     JoinStringsWithSeparator(flags, ",\n        ") );
end);

InstallGlobalFunction( IsCategory,
function(x)
    local fid;
    for fid in [1..Length(FILTERS)] do
        if (FILTERS[fid] = x)
           and (INFO_FILTERS[fid] in FNUM_CATS) then
            return true;
        fi;
    od;
    return false;
end);

InstallGlobalFunction( FilterByName,
function(name)
    local fid;
    for fid in FILTERS do
        if NAME_FUNC(FILTERS[fid]) = name then
            return FILTERS[fid];
        fi;
    od;
    return fail;
end);

InstallGlobalFunction( CategoryByName,
function(name)
    local fid;
    for fid in CATS_AND_REPS do
        if (INFO_FILTERS[fid] in FNUM_CATS) and
           (NAME_FUNC(FILTERS[fid]) = name) then
            return FILTERS[fid];
        fi;
    od;
    return fail;
end);

InstallGlobalFunction( DeclareObject,
function(name, super, repfilter, attributes, properties)
    local cat
        , familyname, fam
        , repname, rep
        , typename, type
        , att, prop;

    #X Check whether name exists,
    #X check whether name is empty
    cat := NewCategory(name, super);
    BindGlobal(name, cat);

    familyname := Concatenation(name, "Family");
    fam := NewFamily(familyname);
    BindGlobal(familyname, fam);

    repname := Concatenation(name, "Rep");
    rep := NewRepresentation(repname, cat and repfilter, []);
    BindGlobal(repname, rep);

    for att in attributes do
        DeclareAttribute(att, cat);
    od;

    for prop in properties do
        DeclareProperty(prop, cat);
    od;

    typename := Concatenation(name, "Type");
    type := NewType(fam, rep);
    BindGlobal(typename, type);
end);


