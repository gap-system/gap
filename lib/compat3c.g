#############################################################################
##
#W  compat3c.g                  GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file provides methods to make records behave as records with
##  `operations' component in {\GAP} 3.
##
Revision.compat3c_g :=
    "@(#)$Id$";


#############################################################################
##
#M  PrintObj( <record> )
##
##  The record <record> is printed either by printing all its components or,
##  if the component `operations' of <record> is bound and is a record with
##  component `Print', this function is called with argument <record>.
##
InstallMethod( PrintObj,
    "record",
    true,
    [ IsRecord ], 1,  # override the method that ignores `operations'
    PRINT_PREC );


#############################################################################
##
#M  <record> + <object>
##
InstallOtherMethod( \+,
    "record + object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    SUM_PREC );


#############################################################################
##
#M  <object> + <record>
##
InstallOtherMethod( \+,
    "object + record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    SUM_PREC );


#############################################################################
##
#M  Zero( <record> )
##
InstallOtherMethod( Zero,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ], 0,
    function( record )
    if     IsBound( record.operations )
       and IsBound( record.operations.\* ) then
      return record.operations.\*( 0, record );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  AdditiveInverse( <record> )
##
InstallOtherMethod( AdditiveInverse,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ], 0,
    function( record )
    if     IsBound( record.operations )
       and IsBound( record.operations.\* ) then
      return record.operations.\*( -1, record );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  <record> - <object>
##
InstallOtherMethod( \-,
    "record - object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    DIFF_PREC );


#############################################################################
##
#M  <object> - <record>
##
InstallOtherMethod( \-,
    "object - record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    DIFF_PREC );


#############################################################################
##
#M  <record> * <object>
##
InstallOtherMethod( \*,
    "record * object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    PROD_PREC );


#############################################################################
##
#M  <object> * <record>
##
InstallOtherMethod( \*,
    "object * record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    PROD_PREC );


#############################################################################
##
#M  One( <record> )
##
InstallOtherMethod( One,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ], 0,
    function( record )
    if     IsBound( record.operations )
       and IsBound( record.operations.\^ ) then
      return record.operations.\^( record, 0 );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Inverse( <record> )
##
InstallOtherMethod( Inverse,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ], 0,
    function( record )
    if     IsBound( record.operations )
       and IsBound( record.operations.\^ ) then
      return record.operations.\^( record, -1 );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  <record> / <object>
##
InstallOtherMethod( \/,
    "record / object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    QUO_PREC );


#############################################################################
##
#M  <object> / <record>
##
InstallOtherMethod( \/,
    "object / record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    QUO_PREC );


#############################################################################
##
#M  <record> ^ <object>
##
InstallOtherMethod( \^,
    "record ^ object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    POW_PREC );


#############################################################################
##
#M  <object> ^ <record>
##
InstallOtherMethod( \^,
    "object ^ record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    POW_PREC );


#############################################################################
##
#M  <record> mod <object>
##
InstallOtherMethod( \mod,
    "record mod object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    MOD_PREC );


#############################################################################
##
#M  <object> mod <record>
##
InstallOtherMethod( \mod,
    "object mod record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    MOD_PREC );


#############################################################################
##
#M  LeftQuotient( <record>, <object> )
##
InstallOtherMethod( LeftQuotient,
    "record, object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    LQUO_PREC );


#############################################################################
##
#M  LeftQuotient( <object>, <record> )
##
InstallOtherMethod( LeftQuotient,
    "object, record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    LQUO_PREC );


#############################################################################
##
#M  Comm( <record>, <object> )
##
InstallOtherMethod( Comm,
    "record, object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    COMM_PREC );


#############################################################################
##
#M  Comm( <object>, <record> )
##
InstallOtherMethod( Comm,
    "object, record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    COMM_PREC );


#############################################################################
##
#M  <object> in <record>
##
InstallOtherMethod( \in,
    "object in record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    IN_PREC );


#############################################################################
##
#M  <record> = <object>
##
InstallOtherMethod( \=,
    "record = object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    EQ_PREC );


#############################################################################
##
#M  <object> = <record>
##
InstallOtherMethod( \=,
    "object = record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    EQ_PREC );


#############################################################################
##
#M  <record> < <object>
##
InstallOtherMethod( \<,
    "record < object",
    true,
    [ IsRecord,
      IsObject ],
    0,
    LT_PREC );


#############################################################################
##
#M  <object> < <record>
##
InstallOtherMethod( \<,
    "object < record",
    true,
    [ IsObject,
      IsRecord ],
    0,
    LT_PREC );


#############################################################################
##
#F  InstallRecordMethod1Args( <opr>, <compname> )
##
##  provides the installation of a method for the unary operation <opr> that
##  is associated to the component <compname> of a record.
##
InstallRecordMethod1Args := function( opr, compname )
    InstallOtherMethod( opr,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ], 1,  # override method that ignores `operations'
    function( record )
    if     IsBound( record.operations )
       and IsBound( record.operations.( compname ) ) then
      return record.operations.( compname )( record );
    else
      TryNextMethod();
    fi;
    end );
end;


#############################################################################
##
#M  Int( <record> ) . . . . . . . . . . . . .  for a record with `operations'
##
InstallRecordMethod1Args( Int, "Int" );


#############################################################################
##
#M  String( <record> )  . . . . . . . . . . .  for a record with `operations'
##
InstallRecordMethod1Args( String, "String" );


#############################################################################
##
#F  IsOperationsRecord( <obj> ) . . . . . . . . .  ``category'' test function
##
IsOperationsRecord := function( obj )
    return     IsRecord( obj )
           and IsBound( obj.name )
           and IsBound( obj.operations )
           and IsRecord( obj.operations )
           and IsBound( obj.operations.name )
           and obj.operations.name = "OpsOps";
end;


##############################################################################
##
#V  OpsOps
##
OpsOps := rec(
    name  := "OpsOps",
    Print := function( obj ) Print( obj.name ); end,
    \=    := function( oprec1, oprec2 )
               if IsOperationsRecord( oprec1 )  then
                 if IsOperationsRecord( oprec2 )  then
                   return oprec1.name = oprec2.name;
                 else
                   return false;
                 fi;
               elif not IsOperationsRecord( oprec2 )  then
                 Error( "panic, neither argument is an operations record" );
               fi;
             end );

OpsOps.operations := OpsOps;


##############################################################################
##
#F  OperationsRecord( <name> )
#F  OperationsRecord( <name>, <parent>... )
##
OperationsRecord := function ( arg )
    local   sub, sup;

    # make the new operations record
    sub := rec();
    sub.name       := arg[1];
    sub.operations := OpsOps;

    # remember super operations records
    sub.SUPS := arg{[2..Length(arg)]};
    sub.SUPC := 0;

    # this operations record is not finished yet
    sub.DONE := false;

    # register yourself to the super operations records
    for sup  in sub.SUPS  do
        if not IsBound( sup.SUBS )  then
            sup.SUBS := [ sub ];
        else
            Add( sup.SUBS, sub );
        fi;
    od;

    # inherit as much as can be determined now
    FinishSubOperationsRecord( sub );

    # return the new operations record
    return sub;
end;

FinishOperationsRecord := function ( sup )
    local   sub;

    # this operations record is finished now
    sup.DONE := true;

    # for all sub operations records inherit as much as can be determined now
    if IsBound( sup.SUBS )  then
        for sub  in sup.SUBS  do
            FinishSubOperationsRecord( sub );
        od;
    fi;

end;

FinishSubOperationsRecord := function ( sub )
    local   sup, name;

    # inherit everything from all finished super operations records
    while sub.SUPC < Length(sub.SUPS)
      and IsBound( sub.SUPS[sub.SUPC+1].DONE )
      and sub.SUPS[sub.SUPC+1].DONE
    do
        sup := sub.SUPS[sub.SUPC+1];
        for  name  in RecNames(sup)  do
            if not IsBound( sub.(name) )  then
                sub.(name) := sup.(name);
            fi;
        od;
	sub.SUPC := sub.SUPC + 1;
    od;

    # inherit everything from the first unfinished super operations record
    if sub.SUPC < Length(sub.SUPS)  then
        sup := sub.SUPS[sub.SUPC+1];
        for  name  in RecNames(sup)  do
            if not IsBound( sub.(name) )  then
                sub.(name) := sup.(name);
            fi;
        od;
    fi;

end;


#T #############################################################################
#T ##
#T #F  PrintRec(<record>)  . . . . . . . . . . . . . . . . . . .  print a record
#T ##
#T ##  'PrintRec' must  call 'Print'  so that 'Print'   assigns  the record   to
#T ##  '~' and  prints for  example 'rec( a := ~  )'  in this  form and does not
#T ##  go into an  infinite loop 'rec( a  := rec(  a := ...'.   To make  'Print'
#T ##  do the right   thing, we  assign to '<record>.operation'  the  operations
#T ##  record 'RecordOps', which contains the appropriate 'Print' function.
#T ##
#T PrintRecIgnore := [ "operations", "parent" ];
#T 
#T PrintRecIndent := "  ";
#T 
#T RecordOps := OperationsRecord( "RecordOps" );
#T 
#T RecordOps.Print := function ( record )
#T     local  len, i, nam, lst, printRecIndent;
#T     len  := 0;
#T     for nam in RecNames( record )  do
#T         if len < Length( nam )  then
#T             len := Length( nam );
#T         fi;
#T         lst := nam;
#T     od;
#T     Print( "rec(\n" );
#T     for nam  in RecNames( record )  do
#T         if not nam in PrintRecIgnore then
#T             if not IsRecord( record.(nam) )  then
#T                 Print( PrintRecIndent, nam );
#T                 for i  in [Length(nam)..len]  do
#T                     Print( " " );
#T                 od;
#T                 Print( ":= ", record.(nam) );
#T                 if nam <> lst  then  Print( ",\n" );  fi;
#T             else
#T                 Print( PrintRecIndent, nam );
#T                 for i  in [Length(nam)..len]  do
#T                     Print( " " );
#T                 od;
#T                 Print( ":= " );
#T                 printRecIndent := PrintRecIndent;
#T                 PrintRecIndent := Concatenation(PrintRecIndent,"  ");
#T                 PrintRec( record.(nam) );
#T                 if nam <> lst  then Print( ",\n" );  fi;
#T                 PrintRecIndent := printRecIndent;
#T             fi;
#T         else
#T             Print( PrintRecIndent, nam );
#T             for i  in [Length(nam)..len]  do
#T                 Print( " " );
#T             od;
#T             Print( ":= ..." );
#T             if nam <> lst  then Print( ",\n" );  fi;
#T         fi;
#T     od;
#T     Print( " )" );
#T end;
#T 
#T PrintRec := function ( record )
#T     local   operations;
#T     if IsBound( record.operations )  then
#T         operations := record.operations;
#T     fi;
#T     record.operations := RecordOps;
#T     Print( record );
#T     if IsBound( operations )  then
#T         record.operations := operations;
#T     else
#T         Unbind( record.operations );
#T     fi;
#T end;


#############################################################################
##
#E  compat3c.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



