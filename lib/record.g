#############################################################################
##
#W  record.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains methods for records.
##  Compared to {\GAP}~3, where records were used to represent domains and
##  all kinds of external arithmetic objects, in {\GAP}~4 there is no
##  important role for records.
##  So the standard library provides only methods for `PrintObj', `String',
##  `\=', and `\<', and the latter two are not installed to compare records
##  with objects in other families.
##
##  In order to achieve a special behaviour of records as in {\GAP}~3 such
##  that a record can be regarded as equal to objects in other families
##  or such that a record can be compared via `\<' with objects in other
##  families, one can load the file `compat3c.g'.
##
Revision.record_g :=
    "@(#)$Id$";


#############################################################################
##
#C  IsRecord( <obj> )
#C  IsRecordCollection( <obj> )
#C  IsRecordCollColl( <obj> )
##
DeclareCategoryKernel( "IsRecord", IsObject, IS_REC );
DeclareCategoryCollections( "IsRecord" );
DeclareCategoryCollections( "IsRecordCollection" );


#############################################################################
##
#V  RecordsFamily . . . . . . . . . . . . . . . . . . . . . family of records
##
BIND_GLOBAL( "RecordsFamily", NewFamily( "RecordsFamily", IS_REC ) );


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
#A  RecNames( <rec> )
##
##  returns a list of strings corresponding to the names of the record
##  components of the record <rec>.
##
DeclareAttribute( "RecNames", IsRecord );


#############################################################################
##
#F  RecFields( <record> )
##
BIND_GLOBAL( "RecFields", RecNames );


#############################################################################
##
#M  RecNames( <record> )  . . . . . . . . . . . . . . . . names of components
##
InstallMethod( RecNames,
    "for a record in internal representation",
    [ IsRecord and IsInternalRep ],
    REC_NAMES );


#############################################################################
##
#F  NamesOfComponents( <obj> )
##
##  For a component object <obj>, `NamesOfComponents' returns a list of
##  strings, which are the names of components currently bound in <comobj>.
##
##  For a record <obj>, `NamesOfComponents' returns the result of `RecNames'.
##
BIND_GLOBAL( "NamesOfComponents", function( obj )
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
    function( record ) PRINT_PREC_DEFAULT( record ); end );


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
    for nam in RecNames( record ) do
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
    ConvertToStringRep( str );
    return str;
end );


#############################################################################
##
#m  ViewObj( <record> ) . . . . . . . . . . . . . . .  for a record (default)
##
##
InstallMethod( ViewObj,
    "record",
    [ IsRecord ],
    function( record )
    local nam, com, i;
    Print("\>\>rec( \>\>");
    com := false;
    i := 1;
    for nam in RecNames( record ) do
        if com then
            Print("\<,\< \>\>");
        else
            com := true;
        fi;
        SET_PRINT_OBJ_INDEX(i);
        i := i+1;
        Print(nam, " := ");
        ViewObj(record.(nam));
    od;
    Print(" \<\<\<\<)");
end);


#############################################################################
##
#m  <record> = <record>
##
InstallMethod( \=,
    "record = record",
    IsIdenticalObj,
    [ IsRecord, IsRecord ],
    EQ_PREC );


#############################################################################
##
#m  <record> < <record>
##
InstallMethod( \<,
    "record < record",
    IsIdenticalObj,
    [ IsRecord, IsRecord ],
    LT_PREC );


# methods to catch error cases

#############################################################################
##
#m  \.
##
InstallMethod(\.,"catch error",true,[IsObject,IsObject],0,
function(obj,nr)
local msg;
  msg:=Concatenation("illegal access to record component `obj.",
        NameRNam(nr),"'\n",
  "of the object <obj>. (Objects by default do not have record components.\n",
  "The error might be a relic from translated GAP3 code.)      ");
  Error(msg);
end);

#############################################################################
##
#m  IsBound\.
##
InstallMethod(IsBound\.,"catch error",true,[IsObject,IsObject],0,
function(obj,nr)
local msg;
  msg:=Concatenation("illegal access to record component `IsBound(obj.",
        NameRNam(nr),")'\n",
  "of the object <obj>. (Objects by default do not have record components.\n",
  "The error might be a relic from translated GAP3 code.)      ");
  Error(msg);
end);

#############################################################################
##
#m  Unbind\.
##
InstallMethod(Unbind\.,"catch error",true,[IsObject,IsObject],0,
function(obj,nr)
local msg;
  msg:=Concatenation("illegal access to record component `Unbind(obj.",
        NameRNam(nr),")'\n",
  "of the object <obj>. (Objects by default do not have record components.\n",
  "The error might be a relic from translated GAP3 code.)      ");
  Error(msg);
end);

#############################################################################
##
#m  \.\:\=
##
InstallMethod(\.\:\=,"catch error",true,[IsObject,IsObject,IsObject],0,
function(obj,nr,elm)
local msg;
  msg:=Concatenation("illegal assignement to record component `obj.",
        NameRNam(nr),"'\n",
  "of the object <obj>. (Objects by default cannot have record components.\n",
  "The error might be a relic from translated GAP3 code.)      ");
  Error(msg);
end);

#############################################################################
##
#E

