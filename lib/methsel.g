#############################################################################
##
#W  methsel.g                   GAP library                      Frank Celler
#W                                                           Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file defines the functions to install and select methods.
##
Revision.methsel_g :=
    "@(#)$Id$";


#############################################################################
##

#F  # # # # # # # # # # # # #  method selection # # # # # # # # # # # # # # #
##


#############################################################################
##

#F  METHOD_0ARGS
##
METHOD_0ARGS := function ( operation )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 0 );
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            return methods[4*(i-1)+2];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
end;


#############################################################################
##
#F  METHOD_1ARGS
##
METHOD_1ARGS := function ( operation, type1 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( type1![1] )
        then
            return methods[5*(i-1)+3];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
end;


#############################################################################
##
#F  METHOD_2ARGS
##
METHOD_2ARGS := function ( operation, type1, type2 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( type1![1], type2![1] )
        then
            return methods[6*(i-1)+4];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
end;


#############################################################################
##
#F  METHOD_3ARGS
##
METHOD_3ARGS := function ( operation, type1, type2, type3 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( type1![1], type2![1], type3![1] )
        then
            return methods[7*(i-1)+5];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
end;


#############################################################################
##
#F  METHOD_4ARGS
##
METHOD_4ARGS := function ( operation, type1, type2, type3,
                                      type4 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 4 );
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1] )
        then
            return methods[8*(i-1)+6];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
end;


#############################################################################
##
#F  METHOD_5ARGS
##
METHOD_5ARGS := function ( operation, type1, type2, type3,
                                      type4, type5 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 5 );
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1], type5![1] )
        then
            return methods[9*(i-1)+7];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
end;


#############################################################################
##
#F  METHOD_6ARGS
##
METHOD_6ARGS := function ( operation, type1, type2, type3,
                                      type4, type5, type6 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 6 );
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
            return methods[10*(i-1)+8];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
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

#F  # # # # # # # # # # #  verbose method selection # # # # # # # # # # # # #
##


#############################################################################
##

#F  VMETHOD_0ARGS
##
VMETHOD_0ARGS := function ( operation )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 0 );
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            Print( "#I  ", methods[4*(i-1)+4], "\n" );
            return methods[4*(i-1)+2];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
end;


#############################################################################
##
#F  VMETHOD_1ARGS
##
VMETHOD_1ARGS := function ( operation, type1 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( type1![1] )
        then
            Print( "#I  ", methods[5*(i-1)+5], "\n" );
            return methods[5*(i-1)+3];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
end;


#############################################################################
##
#F  VMETHOD_2ARGS
##
VMETHOD_2ARGS := function ( operation, type1, type2 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( type1![1], type2![1] )
        then
            Print( "#I  ", methods[6*(i-1)+6], "\n" );
            return methods[6*(i-1)+4];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
end;


#############################################################################
##
#F  VMETHOD_3ARGS
##
VMETHOD_3ARGS := function ( operation, type1, type2, type3 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( type1![1], type2![1], type3![1] )
        then
            Print( "#I  ", methods[7*(i-1)+7], "\n" );
            return methods[7*(i-1)+5];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
end;


#############################################################################
##
#F  VMETHOD_4ARGS
##
VMETHOD_4ARGS := function ( operation, type1, type2, type3,
                                      type4 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 4 );
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1] )
        then
            Print( "#I  ", methods[8*(i-1)+8], "\n" );
            return methods[8*(i-1)+6];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
end;


#############################################################################
##
#F  VMETHOD_5ARGS
##
VMETHOD_5ARGS := function ( operation, type1, type2, type3,
                                      type4, type5 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 5 );
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( type5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( type1![1], type2![1], type3![1],
                                   type4![1], type5![1] )
        then
            Print( "#I  ", methods[9*(i-1)+9], "\n" );
            return methods[9*(i-1)+7];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
end;


#############################################################################
##
#F  VMETHOD_6ARGS
##
VMETHOD_6ARGS := function ( operation, type1, type2, type3,
                                      type4, type5, type6 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 6 );
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
            Print( "#I  ", methods[10*(i-1)+10], "\n" );
            return methods[10*(i-1)+8];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
end;


#############################################################################
##
#F  VMETHOD_XARGS
##
VMETHOD_XARGS := function(arg)
    Error( "not supported yet" );
end;


#############################################################################
##

#F  # # # # # # # # # # #  verbose try next method  # # # # # # # # # # # # #
##



#############################################################################
##

#F  NEXT_VMETHOD_0ARGS
##
NEXT_VMETHOD_0ARGS := function ( operation, k )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 0 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            if k = j  then
                Print( "#I  trying next: ", methods[4*(i-1)+4], "\n" );
                return methods[4*(i-1)+2];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_1ARGS
##
NEXT_VMETHOD_1ARGS := function ( operation, k, type1 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 1 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( type1![1] )
        then
            if k = j  then
                Print( "#I  trying next: ", methods[5*(i-1)+5], "\n" );
                return methods[5*(i-1)+3];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_2ARGS
##
NEXT_VMETHOD_2ARGS := function ( operation, k, type1, type2 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 2 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( type1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( type1![1], type2![1] )
        then
            if k = j  then
                Print( "#I  trying next: ", methods[6*(i-1)+6], "\n" );
                return methods[6*(i-1)+4];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_3ARGS
##
NEXT_VMETHOD_3ARGS := function ( operation, k, type1, type2, type3 )
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
                Print( "#I  trying next: ", methods[7*(i-1)+7], "\n" );
                return methods[7*(i-1)+5];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_4ARGS
##
NEXT_VMETHOD_4ARGS := function ( operation, k, type1, type2, type3,
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
                Print( "#I  trying next: ", methods[8*(i-1)+8], "\n" );
                return methods[8*(i-1)+6];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_5ARGS
##
NEXT_VMETHOD_5ARGS := function ( operation, k, type1, type2, type3,
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
                Print( "#I  trying next: ", methods[9*(i-1)+9], "\n" );
                return methods[9*(i-1)+7];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_6ARGS
##
NEXT_VMETHOD_6ARGS := function ( operation, k, type1, type2, type3,
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
                Print( "#I  trying next: ", methods[10*(i-1)+10], "\n" );
                return methods[10*(i-1)+8];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
end;


#############################################################################
##
#F  NEXT_VMETHOD_XARGS
##
NEXT_VMETHOD_XARGS := function(arg)
    Error( "not supported yet" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
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
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
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

#F  # # # # # # # # # #  verbose constructor selection  # # # # # # # # # # #
##


#############################################################################
##

#F  VCONSTRUCTOR_0ARGS
##
VCONSTRUCTOR_0ARGS := function ( operation )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 0 );
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            Print( "#I  ", methods[4*(i-1)+4], "\n" );
            return methods[4*(i-1)+2];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_1ARGS
##
VCONSTRUCTOR_1ARGS := function ( operation, flags1 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( methods[5*(i-1)+2], flags1 )
          and methods[5*(i-1)+1]( flags1 )
        then
            Print( "#I  ", methods[5*(i-1)+5], "\n" );
            return methods[5*(i-1)+3];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_2ARGS
##
VCONSTRUCTOR_2ARGS := function ( operation, flags1, type2 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( methods[6*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( flags1, type2![1] )
        then
            Print( "#I  ", methods[6*(i-1)+6], "\n" );
            return methods[6*(i-1)+4];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_3ARGS
##
VCONSTRUCTOR_3ARGS := function ( operation, flags1, type2, type3 )
    local   methods, i;

    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( methods[7*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( flags1, type2![1], type3![1] )
        then
            Print( "#I  ", methods[7*(i-1)+7], "\n" );
            return methods[7*(i-1)+5];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_4ARGS
##
VCONSTRUCTOR_4ARGS := function ( operation, flags1, type2, type3,
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
            Print( "#I  ", methods[8*(i-1)+8], "\n" );
            return methods[8*(i-1)+6];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_5ARGS
##
VCONSTRUCTOR_5ARGS := function ( operation, flags1, type2, type3,
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
            Print( "#I  ", methods[9*(i-1)+9], "\n" );
            return methods[9*(i-1)+7];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_6ARGS
##
VCONSTRUCTOR_6ARGS := function ( operation, flags1, type2, type3,
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
            Print( "#I  ", methods[10*(i-1)+10], "\n" );
            return methods[10*(i-1)+8];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
end;


#############################################################################
##
#F  VCONSTRUCTOR_XARGS
##
VCONSTRUCTOR_XARGS := function(arg)
    Error( "not supported yet" );
end;


#############################################################################
##

#F  # # # # # # # # # #  verbose try next constructor # # # # # # # # # # # #
##



#############################################################################
##

#F  NEXT_VCONSTRUCTOR_0ARGS
##
NEXT_VCONSTRUCTOR_0ARGS := function ( operation, k )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 0 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/4]  do
        if methods[4*(i-1)+1]()
        then
            if k = j  then
                Print( "#I  trying next: ", methods[4*(i-1)+4], "\n" );
                return methods[4*(i-1)+2];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 0 arguments" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_1ARGS
##
NEXT_VCONSTRUCTOR_1ARGS := function ( operation, k, flags1 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 1 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( methods[5*(i-1)+2], flags1 )
          and methods[5*(i-1)+1]( flags1 )
        then
            if k = j  then
                Print( "#I  trying next: ", methods[5*(i-1)+5], "\n" );
                return methods[5*(i-1)+3];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_2ARGS
##
NEXT_VCONSTRUCTOR_2ARGS := function ( operation, k, flags1, type2 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 2 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( methods[6*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( flags1, type2![1] )
        then
            if k = j  then
                Print( "#I  trying next: ", methods[6*(i-1)+6], "\n" );
                return methods[6*(i-1)+4];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_3ARGS
##
NEXT_VCONSTRUCTOR_3ARGS := function ( operation, k, flags1, type2, type3 )
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
                Print( "#I  trying next: ", methods[7*(i-1)+7], "\n" );
                return methods[7*(i-1)+5];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_4ARGS
##
NEXT_VCONSTRUCTOR_4ARGS := function ( operation, k, flags1, type2, type3,
                                              type4 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 4 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( methods[8*(i-1)+2], flags1    )
          and IS_SUBSET_FLAGS( type2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( type3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( type4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( flags1, type2![1], type3![1],
                                   type4![1] )
        then
            if k = j  then
                Print( "#I  trying next: ", methods[8*(i-1)+8], "\n" );
                return methods[8*(i-1)+6];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_5ARGS
##
NEXT_VCONSTRUCTOR_5ARGS := function ( operation, k, flags1, type2, type3,
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
                Print( "#I  trying next: ", methods[9*(i-1)+9], "\n" );
                return methods[9*(i-1)+7];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_6ARGS
##
NEXT_VCONSTRUCTOR_6ARGS := function ( operation, k, flags1, type2, type3,
                                              type4, type5, type6 )
    local   methods, i, j;

    methods := METHODS_OPERATION( operation, 6 );
    j := 0;
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
            if k = j  then
                Print( "#I  trying next: ", methods[10*(i-1)+10], "\n" );
                return methods[10*(i-1)+8];
            else
                j := j + 1;
            fi;
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
end;


#############################################################################
##
#F  NEXT_VCONSTRUCTOR_XARGS
##
NEXT_VCONSTRUCTOR_XARGS := function(arg)
    Error( "not supported yet" );
end;


#############################################################################
##

#E  methsel.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
