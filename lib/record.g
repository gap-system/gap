#############################################################################
##
#W  record.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for records.
##  Compared to {\GAP} 3, where records were used to represent domains and
##  all kinds of external arithmetic objects, in {\GAP} 4 there is no
##  important role for records.
##  So the standard library provided only methods for `PrintObj', `String',
##  `\=', and `\<', and the latter two are not installed to compare records
##  with objects in other families.
##
##  In order to achieve a special behaviour of records as in {\GAP} 3 such
##  that a record can be regarded as equal to objects in other families
##  or such that a record can be compared via `\<' with objects in other
##  families, one can load the file `compat3c.g'.
##  
Revision.record_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsRecord  . . . . . . . . . . . . . . . . . . . . . . category of records
##
IsRecord := NewCategoryKernel(
    "IsRecord",
    IsObject,
    IS_REC );


#############################################################################
##

#V  RecordsFamily . . . . . . . . . . . . . . . . . . . . . family of records
##
RecordsFamily := NewFamily(  "RecordsFamily", IS_REC );


#############################################################################
##
#V  TYPE_PREC_MUTABLE . . . . . . . . . . . type of a mutable internal record
##
TYPE_PREC_MUTABLE := NewType( RecordsFamily,
    IS_MUTABLE_OBJ and IS_REC and IsInternalRep );


#############################################################################
##
#V  TYPE_PREC_IMMUTABLE . . . . . . . .  type of an immutable internal record
##
TYPE_PREC_IMMUTABLE := NewType( RecordsFamily,
    IS_REC and IsInternalRep );


#############################################################################
##

#O  \.( <rec>, <name> )	. . . . . . . . . . . . . . . . get a component value
##
\. := NewOperationKernel( "ELM_REC", [ IsObject, IsObject ], ELM_REC );


#############################################################################
##
#O  IsBound\.( <rec>, <name> )  . . . . . . . . . . . . . .  test a component
##
IsBound\. := NewOperationKernel( "ISB_REC", 
    [ IsObject, IsObject ], ISB_REC );


#############################################################################
##
#O  \.\:\=( <rec>, <name>, <val> )  . . . . . . . . . . . . .  assign a value
##
\.\:\= := NewOperationKernel( "ASS_REC", 
    [ IsObject, IsObject, IsObject ], ASS_REC );


#############################################################################
##
#O  Unbind\.( <rec>, <name> ) . . . . . . . . . . . . . . .  unbind component
##
Unbind\. := NewOperationKernel( "UNB_REC", [ IsObject, IsObject ], UNB_REC );


#############################################################################
##

#F  RecNames  . . . . . . . . . . . . . . . . . . . . . . names of components
##
RecNames := REC_NAMES;


#############################################################################
##

#M  PrintObj( <record> )
##
##  The record <record> is printed by printing all its components.
##
InstallMethod( PrintObj,
    "record",
    true,
    [ IsRecord ],
    0,
    function( record ) PRINT_PREC_DEFAULT( record ); end );


#############################################################################
##
#M  String( <record> )  . . . . . . . . . . . . . . . . . . . .  for a record
##
InstallMethod( String,
    "record",
    true,
    [ IsRecord ],
    0,
    function( record )
    local   str,  nam,  com;

    str := "rec( ";
    com := false;
    for nam in RecNames( record ) do
      if com then
        Append( str, ", " );
      else
        com := true;
      fi;
      Append( str, nam );
      Append( str, " := " );
      Append( str, String( record.(nam) ) );
    od;
    Append( str, " )" );
    ConvertToStringRep( str );
    return str;
    end );


#############################################################################
##
#M  <record> = <record>
##
InstallMethod( \=,
    "record = record",
    IsIdentical,
    [ IsRecord, IsRecord ],
    0,
    EQ_PREC );


#############################################################################
##
#M  <record> < <record>
##
InstallMethod( \<,
    "record < record",
    IsIdentical,
    [ IsRecord, IsRecord ],
    0,
    LT_PREC );


#############################################################################
##

#E  record.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



