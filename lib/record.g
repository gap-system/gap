#############################################################################
##
#W  record.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#C  IsRecordCollection
#C  IsRecordCollColl
##
DeclareCategoryKernel( "IsRecord", IsObject, IS_REC );
DeclareCategoryCollections( "IsRecord" );
DeclareCategoryCollections( "IsRecordCollection" );


#############################################################################
##
#V  RecordsFamily . . . . . . . . . . . . . . . . . . . . . family of records
##
BIND_GLOBAL( "RecordsFamily", NewFamily(  "RecordsFamily", IS_REC ) );


#############################################################################
##
#V  TYPE_PREC_MUTABLE . . . . . . . . . . . type of a mutable internal record
##
BIND_GLOBAL( "TYPE_PREC_MUTABLE",
    NewType( RecordsFamily, IS_MUTABLE_OBJ and IS_REC and IsInternalRep ) );


#############################################################################
##
#V  TYPE_PREC_IMMUTABLE . . . . . . . .  type of an immutable internal record
##
BIND_GLOBAL( "TYPE_PREC_IMMUTABLE",
    NewType( RecordsFamily, IS_REC and IsInternalRep ) );


#############################################################################
##
#o  \.( <rec>, <name> )	. . . . . . . . . . . . . . . . get a component value
##
DeclareOperationKernel( ".", [ IsObject, IsObject ], ELM_REC );


#############################################################################
##
#o  IsBound\.( <rec>, <name> )  . . . . . . . . . . . . . .  test a component
##
DeclareOperationKernel( "IsBound.", [ IsObject, IsObject ], ISB_REC );


#############################################################################
##
#o  \.\:\=( <rec>, <name>, <val> )  . . . . . . . . . . . . .  assign a value
##
DeclareOperationKernel( ".:=", [ IsObject, IsObject, IsObject ], ASS_REC );


#############################################################################
##
#o  Unbind\.( <rec>, <name> ) . . . . . . . . . . . . . . .  unbind component
##
DeclareOperationKernel( "Unbind.", [ IsObject, IsObject ], UNB_REC );


#############################################################################
##
#F  RecNames(<obj>)
##
##  returns a list of strings corresponding to the names of the record
##  components of the record <rec>.
DeclareSynonym( "RecNames", REC_NAMES );


#############################################################################
##
#m  PrintObj( <record> )
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
#m  String( <record> )  . . . . . . . . . . . . . . . . . . . .  for a record
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
#m  <record> = <record>
##
InstallMethod( \=,
    "record = record",
    IsIdenticalObj,
    [ IsRecord, IsRecord ],
    0,
    EQ_PREC );


#############################################################################
##
#m  <record> < <record>
##
InstallMethod( \<,
    "record < record",
    IsIdenticalObj,
    [ IsRecord, IsRecord ],
    0,
    LT_PREC );


#############################################################################
##
#E  record.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



