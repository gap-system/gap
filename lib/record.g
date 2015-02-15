#############################################################################
##
#W  record.g                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains methods for records.
##  Compared to &GAP; 3, where records were used to represent domains and
##  all kinds of external arithmetic objects, in &GAP; 4 there is no
##  important role for records.
##  So the standard library provides only methods for `PrintObj', `String',
##  `=', and `<', and the latter two are not installed to compare records
##  with objects in other families.
##
##  In order to achieve a special behaviour of records as in &GAP; 3 such
##  that a record can be regarded as equal to objects in other families
##  or such that a record can be compared via `<' with objects in other
##  families, one can load the file `compat3c.g'.
##


#############################################################################
##
#C  IsRecord( <obj> )
#C  IsRecordCollection( <obj> )
#C  IsRecordCollColl( <obj> )
##
##  <#GAPDoc Label="IsRecord">
##  <ManSection>
##  <Filt Name="IsRecord" Arg='obj' Type='Category'/>
##  <Filt Name="IsRecordCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsRecordCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Index Subkey="for records">test</Index>
##  <Example><![CDATA[
##  gap> IsRecord( rec( a := 1, b := 2 ) );
##  true
##  gap> IsRecord( IsRecord );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsRecord", IsObject, IS_REC );
DeclareCategoryCollections( "IsRecord" );
DeclareCategoryCollections( "IsRecordCollection" );


#############################################################################
##
#V  RecordsFamily . . . . . . . . . . . . . . . . . . . . . family of records
##
##  <ManSection>
##  <Var Name="RecordsFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "RecordsFamily", NewFamily( "RecordsFamily", IS_REC ) );


#############################################################################
##
#V  TYPE_PREC_MUTABLE . . . . . . . . . . . type of a mutable internal record
##
##  <ManSection>
##  <Var Name="TYPE_PREC_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_PREC_MUTABLE",
    NewType( RecordsFamily, IS_MUTABLE_OBJ and IS_REC and IsInternalRep ) );


#############################################################################
##
#V  TYPE_PREC_IMMUTABLE . . . . . . . .  type of an immutable internal record
##
##  <ManSection>
##  <Var Name="TYPE_PREC_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
#A  RecNames( <record> )
##
##  <#GAPDoc Label="RecNames">
##  <ManSection>
##  <Attr Name="RecNames" Arg='record'/>
##
##  <Description>
##  returns a list of strings corresponding to the names of the record
##  components of the record <A>record</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> r := rec( a := 1, b := 2 );;
##  gap> Set(RecNames( r )); # 'Set' because ordering depends on GAP session
##  [ "a", "b" ]
##  ]]></Example>
##  <P/>
##  Note that you cannot use the string result in the ordinary way to access
##  or change a record component.
##  You can use the <C><A>record</A>.(<A>name</A>)</C> construct for that,
##  see <Ref Sect="Accessing Record Elements"/> and
##  <Ref Sect="Record Assignment"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RecNames", IsRecord );

DeclareSynonym( "RecFields", RecNames );


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
#F  NamesOfComponents( <comobj> )
##
##  <#GAPDoc Label="NamesOfComponents">
##  <ManSection>
##  <Func Name="NamesOfComponents" Arg='comobj'/>
##
##  <Description>
##  For a component object <A>comobj</A>,
##  <Ref Func="NamesOfComponents"/> returns a list of strings,
##  which are the names of components currently bound in <A>comobj</A>.
##  <P/>
##  For a record <A>comobj</A>,
##  <Ref Func="NamesOfComponents"/> returns the result of
##  <Ref Func="RecNames"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
## Changed to use sorted component names to make printing nicer to read and
## independent of session (i.e., the ordering in which component names were 
## first used). Except for the sorting of components this does the same as 
## the former (now removed) kernel function FuncPRINT_PREC_DEFAULT.
    function( record )
    local okchars, com, i, snam, nam, names, order;
    okchars :=
          "0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
    Print("\>\>rec(\n\>\>");
    com := false;

    names := List(RecNames(record));
    order := [1..Length(names)];
    SortParallel(names, order);

    for i in [1..Length(names)] do
        nam := names[i];
        if com then
            Print("\<\<,\n\>\>");
        else
            com := true;
        fi;
        SET_PRINT_OBJ_INDEX(order[i]);
        # easy if nam is integer or valid identifier:
        if ForAll(nam, x-> x in okchars) and Size(nam) > 0 then
          Print(nam, "\< := \>");
        else 
          # otherwise we use (...) syntax:
          snam := String(nam);
          Print("("); View(snam); Print(")\< := \>");
        fi;
        PrintObj(record.(nam));
    od;
    Print(" \<\<\<\<)");
end);

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
    for nam in Set(RecNames( record )) do
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
    # should not be necessary if all methods for components are alright
    ConvertToStringRep( str );
    return str;
end );


#############################################################################
##
#m  ViewObj( <record> ) . . . . . . . . . . . . . . .  for a record (default)
##
InstallMethod( ViewObj,
    "record",
    [ IsRecord ],
    function( record )
    local nam, com, i, snam, okchars, names, order;
    okchars :=
          "0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
    Print("\>\>rec( \>\>");
    com := false;

    names := List(RecNames(record));
    order := [1..Length(names)];
    SortParallel(names, order);

    for i in [1..Length(names)] do
        nam := names[i];
        if com then
            Print("\<,\< \>\>");
        else
            com := true;
        fi;
        SET_PRINT_OBJ_INDEX(order[i]);
        # easy if nam is integer or valid identifier:
        if ForAll(nam, x-> x in okchars) and Size(nam) > 0 then
          Print(nam, " := ");
        else 
          # otherwise we use (...) syntax:
          snam := String(nam);
          Print("("); View(snam); Print(") := ");
        fi;
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
#F  SetNamesForFunctionsInRecord( <rec-name>[, <record> ][, <field-names>])
##
##  set the names of functions bound to components of a record. 
##
BIND_GLOBAL("SetNamesForFunctionsInRecord", 
            function( arg )
    local   recname,  next,  record,  fields,  field;
    if LENGTH(arg) = 0 or not IS_STRING(arg[1]) then
        Error("SetNamesForFunctionsInRecord: you must give a record name");
    fi;
    recname := arg[1];
    next := 2;
    if LENGTH(arg) >= next and IS_REC(arg[next]) then
        record := arg[2];
        next := 3;
    else 
        record := VALUE_GLOBAL(recname);
    fi;
    if LENGTH(arg) >= next and IS_LIST(arg[next]) then
        fields := arg[next];
    else
        fields := REC_NAMES(record);
    fi;
    for field in fields do
        if IS_STRING(field) then
            if IsFunction(record.(field)) then
                SetNameFunction(record.(field), Concatenation(recname,".",field));
            fi;
        fi;
    od;
end);
    
    

#############################################################################
##
#E

