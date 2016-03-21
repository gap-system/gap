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
