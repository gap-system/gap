#############################################################################
##
#W  methsel1.g                   GAP library                  Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines the more frequently used functions to 
##  select methods. Less frequently used functions are in methsel1.g, which
##  is not compiled in the default setup. See also methsel2.g
##

#############################################################################
##
#F  METHOD_0ARGS
##
METHOD_0ARGS := function ( operation )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 0 );
    for i  in [1,5..LEN_LIST(methods)-3]  do
        if methods[i]()
        then
            return methods[i+1];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_1ARGS
##
METHOD_1ARGS := function ( operation, type1 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1,6..LEN_LIST(methods)-4]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[i+1] )
          and methods[i]( type1![1] )
        then
            return methods[i+2];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_2ARGS
##
METHOD_2ARGS := function ( operation, type1, type2 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1,7..LEN_LIST(methods)-5]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[i+1] )
          and IS_SUBSET_FLAGS( type2![2], methods[i+2] )
          and methods[i]( type1![1], type2![1] )
        then
            return methods[i+3];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_3ARGS
##
METHOD_3ARGS := function ( operation, type1, type2, type3 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1,8..LEN_LIST(methods)-6]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[i+1] )
          and IS_SUBSET_FLAGS( type2![2], methods[i+2] )
          and IS_SUBSET_FLAGS( type3![2], methods[i+3] )
          and methods[i]( type1![1], type2![1], type3![1] )
        then
            return methods[i+4];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_4ARGS
##
METHOD_4ARGS := function ( operation, type1, type2, type3,
                                      type4 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 4 );
    for i  in [1,9..LEN_LIST(methods)-7]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[i+1] )
          and IS_SUBSET_FLAGS( type2![2], methods[i+2] )
          and IS_SUBSET_FLAGS( type3![2], methods[i+3] )
          and IS_SUBSET_FLAGS( type4![2], methods[i+4] )
          and  methods[i]( type1![1], type2![1], type3![1],
                                   type4![1] )
        then
            return methods[i+5];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_5ARGS
##
METHOD_5ARGS := function ( operation, type1, type2, type3,
                                      type4, type5 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 5 );
    for i  in [1,10..LEN_LIST(methods)-8]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[i+1] )
          and IS_SUBSET_FLAGS( type2![2], methods[i+2] )
          and IS_SUBSET_FLAGS( type3![2], methods[i+3] )
          and IS_SUBSET_FLAGS( type4![2], methods[i+4] )
          and IS_SUBSET_FLAGS( type5![2], methods[i+5] )
          and  methods[i]( type1![1], type2![1], type3![1],
                                   type4![1], type5![1] )
        then
            return methods[i+6];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_6ARGS
##
METHOD_6ARGS := function ( operation, type1, type2, type3,
                                      type4, type5, type6 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 6 );
    for i  in [1,11..LEN_LIST(methods)-9]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[i+1] )
          and IS_SUBSET_FLAGS( type2![2], methods[i+2] )
          and IS_SUBSET_FLAGS( type3![2], methods[i+3] )
          and IS_SUBSET_FLAGS( type4![2], methods[i+4] )
          and IS_SUBSET_FLAGS( type5![2], methods[i+5] )
          and IS_SUBSET_FLAGS( type6![2], methods[i+6] )
          and  methods[i]( type1![1], type2![1], type3![1],
                      type4![1], type5![1], type6![1] )
        then
            return methods[i+7];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  METHOD_XARGS
##
METHOD_XARGS := function(arg)
    Error( "not supported yet" );
end;


#############################################################################
##

#F  # # # # # # # # # # # # #  try next method  # # # # # # # # # # # # # # #
##


#############################################################################
##

#F  NEXT_METHOD_0ARGS
##
NEXT_METHOD_0ARGS := function ( operation, k )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 0 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            if k = j  then
                return methods[4*(i-1)+2];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_1ARGS
##
NEXT_METHOD_1ARGS := function ( operation, k, type1 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 1 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( type1![1] )
        then
            if k = j  then
                return methods[5*(i-1)+3];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_2ARGS
##
NEXT_METHOD_2ARGS := function ( operation, k, type1, type2 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 2 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( type1![1], type2![1] )
        then
            if k = j  then
                return methods[6*(i-1)+4];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_3ARGS
##
NEXT_METHOD_3ARGS := function ( operation, k, type1, type2, type3 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 3 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( type1![1], type2![1], type3![1] )
        then
            if k = j  then
                return methods[7*(i-1)+5];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_4ARGS
##
NEXT_METHOD_4ARGS := function ( operation, k, type1, type2, type3,
                                              type4 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 4 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1] )
        then
            if k = j  then
                return methods[8*(i-1)+6];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_5ARGS
##
NEXT_METHOD_5ARGS := function ( operation, k, type1, type2, type3,
                                              type4, type5 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 5 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1], type5![1] )
        then
            if k = j  then
                return methods[9*(i-1)+7];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_6ARGS
##
NEXT_METHOD_6ARGS := function ( operation, k, type1, type2, type3,
                                              type4, type5, type6 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 6 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[10*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( type6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1], type5![1], type6![1] )
        then
            if k = j  then
                return methods[10*(i-1)+8];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_METHOD_XARGS
##
NEXT_METHOD_XARGS := function(arg)
    Error( "not supported yet" );
end;

#############################################################################
##
#F  AttributeValueNotSet( <attr>, <obj> )
##
AttributeValueNotSet := function(attr,obj)
local type,fam,methods,i,flag,erg;
  type:=TypeObj(obj);
  fam:=FamilyObj(obj);
  methods:=METHODS_OPERATION(attr,1);
  for i in [1..LEN_LIST(methods)/5] do
#    nam:=methods[5*(i-1)+5]; # name
    flag:=true;
    flag:=flag and IS_SUBSET_FLAGS(type![2],methods[5*(i-1)+2]);
    if flag then
      flag:=flag and methods[5*(i-1)+1](fam);
    fi;
    if flag then
      attr:=methods[5*(i-1)+3];
      erg:=attr(obj);
      if not IS_IDENTICAL_OBJ(erg,TRY_NEXT_METHOD) then
	return erg;
      fi;
    fi;
  od;
  Error("No applicable method found for attribute");
end;

#############################################################################
##
#F  # # # # # # # # # # # #  constructor selection  # # # # # # # # # # # # #
##


#############################################################################
##

#F  CONSTRUCTOR_0ARGS
##
CONSTRUCTOR_0ARGS := function ( operation )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 0 );
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            return methods[4*(i-1)+2];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_1ARGS
##
CONSTRUCTOR_1ARGS := function ( operation, flags1 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( methods[5*(i-1)+2], flags1 )
          and methods[5*(i-1)+1]( flags1 )
        then
            return methods[5*(i-1)+3];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_2ARGS
##
CONSTRUCTOR_2ARGS := function ( operation, flags1, type2 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( methods[6*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( flags1, type2![1] )
        then
            return methods[6*(i-1)+4];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_3ARGS
##
CONSTRUCTOR_3ARGS := function ( operation, flags1, type2, type3 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( methods[7*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( flags1, type2![1], type3![1] )
        then
            return methods[7*(i-1)+5];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_4ARGS
##
CONSTRUCTOR_4ARGS := function ( operation, flags1, type2, type3,
                                      type4 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 4 );
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( methods[8*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1] )
        then
            return methods[8*(i-1)+6];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_5ARGS
##
CONSTRUCTOR_5ARGS := function ( operation, flags1, type2, type3,
                                      type4, type5 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 5 );
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( methods[9*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1], type5![1] )
        then
            return methods[9*(i-1)+7];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_6ARGS
##
CONSTRUCTOR_6ARGS := function ( operation, flags1, type2, type3,
                                      type4, type5, type6 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 6 );
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS( methods[10*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( type6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1], type5![1], type6![1] )
        then
            return methods[10*(i-1)+8];
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  CONSTRUCTOR_XARGS
##
CONSTRUCTOR_XARGS := function(arg)
    Error( "not supported yet" );
end;


#############################################################################
##

#F  # # # # # # # # # # # #  try next constructor # # # # # # # # # # # # # #
##


#############################################################################
##

#F  NEXT_CONSTRUCTOR_0ARGS
##
NEXT_CONSTRUCTOR_0ARGS := function ( operation, k )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 0 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            if k = j  then
                return methods[4*(i-1)+2];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_1ARGS
##
NEXT_CONSTRUCTOR_1ARGS := function ( operation, k, flags1 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 1 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( methods[5*(i-1)+2], flags1 )
          and methods[5*(i-1)+1]( flags1 )
        then
            if k = j  then
                return methods[5*(i-1)+3];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_2ARGS
##
NEXT_CONSTRUCTOR_2ARGS := function ( operation, k, flags1, type2 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 2 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( methods[6*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( flags1, type2![1] )
        then
            if k = j  then
                return methods[6*(i-1)+4];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_3ARGS
##
NEXT_CONSTRUCTOR_3ARGS := function ( operation, k, flags1, type2, type3 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 3 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( methods[7*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( flags1, type2![1], type3![1] )
        then
            if k = j  then
                return methods[7*(i-1)+5];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_4ARGS
##
NEXT_CONSTRUCTOR_4ARGS := function ( operation, k, flags1, type2, type3,
                                              type4 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 4 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( methods[8*(i-1)+2], flags1 )
          and IS_SUBSET_FLAGS( type2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1] )
        then
            if k = j  then
                return methods[8*(i-1)+6];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_5ARGS
##
NEXT_CONSTRUCTOR_5ARGS := function ( operation, k, flags1, type2, type3,
                                              type4, type5 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 5 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( methods[9*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1], type5![1] )
        then
            if k = j  then
                return methods[9*(i-1)+7];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_6ARGS
##
NEXT_CONSTRUCTOR_6ARGS := function ( operation, k, flags1, type2, type3,
                                              type4, type5, type6 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 6 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS(  methods[10*(i-1)+2], flags1   )
          and IS_SUBSET_FLAGS( type2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( type6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1], type5![1], type6![1] )
        then
            if k = j  then
                return methods[10*(i-1)+8];
            else
                j := j + 1;
            fi;
        fi;
    od;
    return fail;
end;


#############################################################################
##
#F  NEXT_CONSTRUCTOR_XARGS
##
NEXT_CONSTRUCTOR_XARGS := function(arg)
    Error( "not supported yet" );
end;

#############################################################################
##
#E  methsel1.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
