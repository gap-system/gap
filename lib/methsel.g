#############################################################################
##
#W  methsel.g                   GAP library                  Martin Schoenert
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

#F  METHOD_1ARGS
##
METHOD_1ARGS := function ( operation, kind1 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( kind1![1] )
        then
            return methods[5*(i-1)+3];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 1 argument" );
end;


#############################################################################
##
#F  VMETHOD_1ARGS
##
VMETHOD_1ARGS := function ( operation, kind1 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 1 );
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( kind1![1] )
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
#F  NEXT_METHOD_1ARGS
##
NEXT_METHOD_1ARGS := function ( operation, k, kind1 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 1 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( kind1![1] )
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
#F  NEXT_VMETHOD_1ARGS
##
NEXT_VMETHOD_1ARGS := function ( operation, k, kind1 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 1 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/5]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[5*(i-1)+2] )
          and methods[5*(i-1)+1]( kind1![1] )
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

#F  METHOD_2ARGS
##
METHOD_2ARGS := function ( operation, kind1, kind2 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( kind1![1], kind2![1] )
        then
            return methods[6*(i-1)+4];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 2 arguments" );
end;


#############################################################################
##
#F  VMETHOD_2ARGS
##
VMETHOD_2ARGS := function ( operation, kind1, kind2 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 2 );
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( kind1![1], kind2![1] )
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
#F  NEXT_METHOD_2ARGS
##
NEXT_METHOD_2ARGS := function ( operation, k, kind1, kind2 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 2 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( kind1![1], kind2![1] )
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
#F  NEXT_VMETHOD_2ARGS
##
NEXT_VMETHOD_2ARGS := function ( operation, k, kind1, kind2 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 2 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/6]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[6*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[6*(i-1)+3] )
          and methods[6*(i-1)+1]( kind1![1], kind2![1] )
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

#F  METHOD_3ARGS
##
METHOD_3ARGS := function ( operation, kind1, kind2, kind3 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( kind1![1], kind2![1], kind3![1] )
        then
            return methods[7*(i-1)+5];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 3 arguments" );
end;


#############################################################################
##
#F  VMETHOD_3ARGS
##
VMETHOD_3ARGS := function ( operation, kind1, kind2, kind3 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 3 );
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( kind1![1], kind2![1], kind3![1] )
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
#F  NEXT_METHOD_3ARGS
##
NEXT_METHOD_3ARGS := function ( operation, k, kind1, kind2, kind3 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 3 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( kind1![1], kind2![1], kind3![1] )
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
#F  NEXT_VMETHOD_3ARGS
##
NEXT_VMETHOD_3ARGS := function ( operation, k, kind1, kind2, kind3 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 3 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/7]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[7*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[7*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[7*(i-1)+4] )
          and methods[7*(i-1)+1]( kind1![1], kind2![1], kind3![1] )
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

#F  METHOD_4ARGS
##
METHOD_4ARGS := function ( operation, kind1, kind2, kind3,
                                      kind4 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 4 );
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1] )
        then
            return methods[8*(i-1)+6];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 4 arguments" );
end;


#############################################################################
##
#F  VMETHOD_4ARGS
##
VMETHOD_4ARGS := function ( operation, kind1, kind2, kind3,
                                      kind4 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 4 );
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1] )
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
#F  NEXT_METHOD_4ARGS
##
NEXT_METHOD_4ARGS := function ( operation, k, kind1, kind2, kind3,
                                              kind4 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 4 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1] )
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
#F  NEXT_VMETHOD_4ARGS
##
NEXT_VMETHOD_4ARGS := function ( operation, k, kind1, kind2, kind3,
                                              kind4 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 4 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/8]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[8*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[8*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[8*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[8*(i-1)+5] )
          and  methods[8*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1] )
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

#F  METHOD_5ARGS
##
METHOD_5ARGS := function ( operation, kind1, kind2, kind3,
                                      kind4, kind5 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 5 );
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1] )
        then
            return methods[9*(i-1)+7];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 5 arguments" );
end;


#############################################################################
##
#F  VMETHOD_5ARGS
##
VMETHOD_5ARGS := function ( operation, kind1, kind2, kind3,
                                      kind4, kind5 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 5 );
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1] )
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
#F  NEXT_METHOD_5ARGS
##
NEXT_METHOD_5ARGS := function ( operation, k, kind1, kind2, kind3,
                                              kind4, kind5 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 5 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1] )
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
#F  NEXT_VMETHOD_5ARGS
##
NEXT_VMETHOD_5ARGS := function ( operation, k, kind1, kind2, kind3,
                                              kind4, kind5 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 5 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/9]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[9*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[9*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[9*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[9*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[9*(i-1)+6] )
          and  methods[9*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1] )
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

#F  METHOD_6ARGS
##
METHOD_6ARGS := function ( operation, kind1, kind2, kind3,
                                      kind4, kind5, kind6 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 6 );
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[10*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( kind6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1], kind6![1] )
        then
            return methods[10*(i-1)+8];
        fi;
    od;
    Error( "no method found for operation ", NAME_FUNCTION(operation),
           " with 6 arguments" );
end;


#############################################################################
##
#F  VMETHOD_6ARGS
##
VMETHOD_6ARGS := function ( operation, kind1, kind2, kind3,
                                      kind4, kind5, kind6 )
    local   methods, i;
    methods := METHODS_OPERATION( operation, 6 );
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[10*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( kind6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1], kind6![1] )
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
#F  NEXT_METHOD_6ARGS
##
NEXT_METHOD_6ARGS := function ( operation, k, kind1, kind2, kind3,
                                              kind4, kind5, kind6 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 6 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[10*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( kind6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1], kind6![1] )
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
#F  NEXT_VMETHOD_6ARGS
##
NEXT_VMETHOD_6ARGS := function ( operation, k, kind1, kind2, kind3,
                                              kind4, kind5, kind6 )
    local   methods, i, j;
    methods := METHODS_OPERATION( operation, 6 );
    j := 0;
    for i  in [1..LEN_LIST(methods)/10]  do
        if    IS_SUBSET_FLAGS( kind1![2], methods[10*(i-1)+2] )
          and IS_SUBSET_FLAGS( kind2![2], methods[10*(i-1)+3] )
          and IS_SUBSET_FLAGS( kind3![2], methods[10*(i-1)+4] )
          and IS_SUBSET_FLAGS( kind4![2], methods[10*(i-1)+5] )
          and IS_SUBSET_FLAGS( kind5![2], methods[10*(i-1)+6] )
          and IS_SUBSET_FLAGS( kind6![2], methods[10*(i-1)+7] )
          and  methods[10*(i-1)+1]( kind1![1], kind2![1], kind3![1],
                                   kind4![1], kind5![1], kind6![1] )
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

#E  methsel.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
