#############################################################################
##
#W  methsel.g                   GAP library                      Frank Celler
#W                                                           Martin Schönert
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines the less frequently used functions to select
##  methods. More frequently used functions used to be in methsel1.g,
##  which was compiled in the default setup; this code has now been
##  replaced by hand written C code in the kernel.
##


#############################################################################
##
#F  # # # # # # # # # # # # #  method selection # # # # # # # # # # # # # # #
##


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
#F  # # # # # # # # # # #  verbose method selection # # # # # # # # # # # # #
##
VMETHOD_PRINT_INFO := function ( methods, i, arity)
    local offset;
    offset := (arity+4)*(i-1)+arity;
    Print("#I  ", methods[offset+4]);
    if FILENAME_FUNC(methods[offset+2]) <> fail then
        Print(" at ",
              FILENAME_FUNC(methods[offset+2]), ":",
              STARTLINE_FUNC(methods[offset+2]));
    fi;
    Print("\n");
end;

#############################################################################
##
#F  # # # # # # # # # # #  verbose try next method  # # # # # # # # # # # # #
##
NEXT_VMETHOD_PRINT_INFO := function ( methods, i, arity)
    local offset;
    offset := (arity+4)*(i-1)+arity;
    Print("#I Trying next: ", methods[offset+4]);
    if FILENAME_FUNC(methods[offset+2]) <> fail then
        Print(" at ",
              FILENAME_FUNC(methods[offset+2]), ":",
              STARTLINE_FUNC(methods[offset+2]));
    fi;
    Print("\n");
end;


#############################################################################
##
#E  methsel.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
