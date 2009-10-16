#############################################################################
##
#W  compat3c.g                  GAP library                      Frank Celler
##
#H  @(#)$Id: compat3c.g,v 4.13 2002/04/15 10:04:30 sal Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file provides methods to make records behave as records with
##  `operations' component in {\GAP} 3.
##
Revision.compat3c_g :=
    "@(#)$Id: compat3c.g,v 4.13 2002/04/15 10:04:30 sal Exp $";


#############################################################################
##
##  The files `compat3a.g' and `compat3b.g' must have been read before this
##  file can be read.
##
if not IsBound( Revision.compat3b_g ) then
  ReadLib( "compat3b.g" );
fi;


#############################################################################
##
#M  PrintObj( <record> )
#M  ViewObj( <record> )
##
##  The record <record> is printed either by printing all its components or,
##  if the component `operations' of <record> is bound and has a component
##  `Print', this function is called with argument <record>.
##
InstallMethod( PrintObj,
    "for a record, look for entry in `operations'",
    true,
    [ IsRecord ], SUM_FLAGS,
    PRINT_PREC );

InstallMethod( ViewObj,
    "for a record, look for entry in `operations'",
    true,
    [ IsRecord ], SUM_FLAGS,
    PRINT_PREC );


#############################################################################
##
#M  <record> + <object>
#M  <object> + <record>
##
##  Note that `SUM_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \+,
    "record + object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    SUM_PREC );

InstallOtherMethod( \+,
    "object + record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    SUM_PREC );


#############################################################################
##
#M  ZeroOp( <record> )
##
InstallOtherMethod( ZeroOp,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ],
    SUM_FLAGS,
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
#M  AdditiveInverseOp( <record> )
##
##  Note that we cannot simply delegate to multiplication by `-1' since it
##  may happen that no individual multiplication was installed, and the
##  generic multiplication would delegate back to `AdditiveInverseOp'.
##
InstallOtherMethod( AdditiveInverseOp,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ],
    SUM_FLAGS,
    function( record )
    if IsBound( record.operations ) then
      if     IsOperationsRecord( record.operations )
         and IsBound( record.operations!.COMPONENTS.\* ) then
        return record.operations.\*( -1, record );
      elif   IsRecord( record.operations )
         and IsBound( record.operations.\* ) then
        return record.operations.\*( -1, record );
      fi;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  <record> - <object>
#M  <object> - <record>
##
##  Note that `DIFF_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \-,
    "record - object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    DIFF_PREC );

InstallOtherMethod( \-,
    "object - record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    DIFF_PREC );


#############################################################################
##
#M  <record> * <object>
#M  <object> * <record>
##
##  Note that `PROD_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \*,
    "record * object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    PROD_PREC );

InstallOtherMethod( \*,
    "object * record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    PROD_PREC );


#############################################################################
##
#M  OneOp( <record> )
##
##  Note that we cannot simply delegate to powering by `0' since it
##  may happen that no individual powering was installed, and the
##  generic powering would delegate back to `One'.
##
InstallOtherMethod( OneOp,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ],
    SUM_FLAGS,
    function( record )
    if IsBound( record.operations ) then
      if     IsOperationsRecord( record.operations )
         and IsBound( record.operations!.COMPONENTS.\^ ) then
        return record.operations.\^( record, 0 );
      elif   IsRecord( record.operations )
         and IsBound( record.operations.\^ ) then
        return record.operations.\^( record, 0 );
      fi;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  InverseOp( <record> )
##
##  Note that we cannot simply delegate to powering by `-1' since it
##  may happen that no individual powering was installed, and the
##  generic powering would delegate back to `Inverse'.
##
InstallOtherMethod( InverseOp,
    "method for a record (expect `operations' component)",
    true,
    [ IsRecord ],
    SUM_FLAGS,
    function( record )
    if IsBound( record.operations ) then
      if     IsOperationsRecord( record.operations )
         and IsBound( record.operations!.COMPONENTS.\^ ) then
        return record.operations.\^( record, -1 );
      elif   IsRecord( record.operations )
         and IsBound( record.operations.\^ ) then
        return record.operations.\^( record, -1 );
      fi;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  <record> / <object>
#M  <object> / <record>
##
##  Note that `QUO_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \/,
    "record / object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    QUO_PREC );

InstallOtherMethod( \/,
    "object / record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    QUO_PREC );


#############################################################################
##
#M  <record> ^ <object>
#M  <object> ^ <record>
##
##  Note that `POW_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \^,
    "record ^ object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    POW_PREC );

InstallOtherMethod( \^,
    "object ^ record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    POW_PREC );


#############################################################################
##
#M  <record> mod <object>
#M  <object> mod <record>
##
##  Note that `MOD_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \mod,
    "record mod object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    MOD_PREC );

InstallOtherMethod( \mod,
    "object mod record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    MOD_PREC );


#############################################################################
##
#M  LeftQuotient( <record>, <object> )
#M  LeftQuotient( <object>, <record> )
##
##  Note that `LQUO_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( LeftQuotient,
    "record, object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    LQUO_PREC );

InstallOtherMethod( LeftQuotient,
    "object, record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    LQUO_PREC );


#############################################################################
##
#M  Comm( <record>, <object> )
#M  Comm( <object>, <record> )
##
##  Note that `COMM_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( Comm,
    "record, object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    COMM_PREC );

InstallOtherMethod( Comm,
    "object, record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
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
    SUM_FLAGS,
    IN_PREC );


#############################################################################
##
#M  <record> = <object>
#M  <object> = <record>
##
##  Note that `EQ_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \=,
    "record = object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    EQ_PREC );

InstallOtherMethod( \=,
    "object = record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
    EQ_PREC );


#############################################################################
##
#M  <record> < <object>
#M  <object> < <record>
##
##  Note that `LT_PREC' checks first the right operand for being a record
##  with `operations' component, and then the left operand.
##
InstallOtherMethod( \<,
    "record < object",
    true,
    [ IsRecord,
      IsObject ],
    SUM_FLAGS,
    LT_PREC );

InstallOtherMethod( \<,
    "object < record",
    true,
    [ IsObject,
      IsRecord ],
    SUM_FLAGS,
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
    if IsBound( record.operations ) then
      if     IsOperationsRecord( record.operations )
         and IsBound( record.operations!.COMPONENTS.( compname ) ) then
        return record.operations!.COMPONENTS.( compname )( record );
      elif   IsRecord( record.operations )
         and IsBound( record.operations.( compname ) ) then
        return record.operations.( compname )( record );
      fi;
    fi;
    TryNextMethod();
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
##  In order to allow matrices, groups etc.~of records,
##  we install the implication that records are scalars.
##
##  For convincing the kernel, we need some very ugly hacks.
##
InstallTrueMethod( IsScalar, IsRecord );
InstallTrueMethod( IsScalarCollection, IsRecordCollection );
InstallTrueMethod( IsScalarCollColl, IsRecordCollColl );

# for chaching types of homogeneous lists, assigned in kernel when needed 
RecordsFamily!.TYPES_LIST_FAM  := [];
# for efficiency
RecordsFamily!.TYPES_LIST_FAM[27] := 0;

Fam:= CollectionsFamily( RecordsFamily );
Fam!.IMP_FLAGS := AND_FLAGS( Fam!.IMP_FLAGS,
                             FLAGS_FILTER( IsScalarCollection ) );
Fam!.TYPES_LIST_FAM  := [,,,,,,,,,,,,,,,,,,,,,,,,,,false]; # list with 12 holes

Fam:= CollectionsFamily( Fam );
Fam!.IMP_FLAGS := AND_FLAGS( Fam!.IMP_FLAGS,
                             FLAGS_FILTER( IsScalarCollColl ) );

MakeReadWriteGVar( "TYPE_PREC_MUTABLE" );
TYPE_PREC_MUTABLE := NewType( RecordsFamily,
    IS_MUTABLE_OBJ and IsRecord and IsInternalRep );
MakeReadOnlyGVar( "TYPE_PREC_MUTABLE" );

MakeReadWriteGVar( "TYPE_PREC_IMMUTABLE" );
TYPE_PREC_IMMUTABLE := NewType( RecordsFamily,
    IsRecord and IsInternalRep );
MakeReadOnlyGVar( "TYPE_PREC_IMMUTABLE" );


#############################################################################
##
#E  compat3c.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



