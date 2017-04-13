#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include <src/compiled.h>

/* global variables used in handlers */
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
static GVar G_IsType;
static Obj  GF_IsType;
static GVar G_IS__REC;
static Obj  GF_IS__REC;
static GVar G_IS__LIST;
static Obj  GF_IS__LIST;
static GVar G_ADD__LIST;
static Obj  GF_ADD__LIST;
static GVar G_IS__PLIST__REP;
static Obj  GF_IS__PLIST__REP;
static GVar G_IS__BLIST;
static Obj  GF_IS__BLIST;
static GVar G_IS__RANGE;
static Obj  GF_IS__RANGE;
static GVar G_IS__STRING__REP;
static Obj  GF_IS__STRING__REP;
static GVar G_Error;
static Obj  GF_Error;
static GVar G_TYPE__OBJ;
static Obj  GC_TYPE__OBJ;
static Obj  GF_TYPE__OBJ;
static GVar G_FAMILY__OBJ;
static Obj  GC_FAMILY__OBJ;
static GVar G_IMMUTABLE__COPY__OBJ;
static Obj  GF_IMMUTABLE__COPY__OBJ;
static GVar G_IS__IDENTICAL__OBJ;
static Obj  GF_IS__IDENTICAL__OBJ;
static GVar G_IS__COMOBJ;
static Obj  GF_IS__COMOBJ;
static GVar G_SET__TYPE__COMOBJ;
static Obj  GF_SET__TYPE__COMOBJ;
static GVar G_IS__POSOBJ;
static Obj  GF_IS__POSOBJ;
static GVar G_SET__TYPE__POSOBJ;
static Obj  GF_SET__TYPE__POSOBJ;
static GVar G_LEN__POSOBJ;
static Obj  GF_LEN__POSOBJ;
static GVar G_IS__DATOBJ;
static Obj  GF_IS__DATOBJ;
static GVar G_SET__TYPE__DATOBJ;
static Obj  GF_SET__TYPE__DATOBJ;
static GVar G_FORCE__SWITCH__OBJ;
static Obj  GF_FORCE__SWITCH__OBJ;
static GVar G_MakeImmutable;
static Obj  GF_MakeImmutable;
static GVar G_IS__OBJECT;
static Obj  GC_IS__OBJECT;
static GVar G_AND__FLAGS;
static Obj  GF_AND__FLAGS;
static GVar G_SUB__FLAGS;
static Obj  GF_SUB__FLAGS;
static GVar G_HASH__FLAGS;
static Obj  GF_HASH__FLAGS;
static GVar G_IS__EQUAL__FLAGS;
static Obj  GF_IS__EQUAL__FLAGS;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_FLAG1__FILTER;
static Obj  GF_FLAG1__FILTER;
static GVar G_FLAGS__FILTER;
static Obj  GF_FLAGS__FILTER;
static GVar G_METHODS__OPERATION;
static Obj  GF_METHODS__OPERATION;
static GVar G_SETTER__FUNCTION;
static Obj  GF_SETTER__FUNCTION;
static GVar G_GETTER__FUNCTION;
static Obj  GF_GETTER__FUNCTION;
static GVar G_IS__AND__FILTER;
static Obj  GF_IS__AND__FILTER;
static GVar G_COMPACT__TYPE__IDS;
static Obj  GF_COMPACT__TYPE__IDS;
static GVar G_fail;
static Obj  GC_fail;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_SET__FILTER__LIST;
static Obj  GF_SET__FILTER__LIST;
static GVar G_RESET__FILTER__LIST;
static Obj  GF_RESET__FILTER__LIST;
static GVar G_GASMAN;
static Obj  GF_GASMAN;
static GVar G_WRITE__LOCK;
static Obj  GF_WRITE__LOCK;
static GVar G_READ__LOCK;
static Obj  GF_READ__LOCK;
static GVar G_UNLOCK;
static Obj  GF_UNLOCK;
static GVar G_MIGRATE__RAW;
static Obj  GF_MIGRATE__RAW;
static GVar G_MakeReadOnly;
static Obj  GF_MakeReadOnly;
static GVar G_MakeReadOnlyObj;
static Obj  GF_MakeReadOnlyObj;
static GVar G_AtomicList;
static Obj  GF_AtomicList;
static GVar G_FixedAtomicList;
static Obj  GF_FixedAtomicList;
static GVar G_AtomicRecord;
static Obj  GF_AtomicRecord;
static GVar G_IS__ATOMIC__RECORD;
static Obj  GF_IS__ATOMIC__RECORD;
static GVar G_FromAtomicRecord;
static Obj  GF_FromAtomicRecord;
static GVar G_MakeWriteOnceAtomic;
static Obj  GF_MakeWriteOnceAtomic;
static GVar G_StrictBindOnce;
static Obj  GF_StrictBindOnce;
static GVar G_InstallAttributeFunction;
static Obj  GF_InstallAttributeFunction;
static GVar G_InstallOtherMethod;
static Obj  GF_InstallOtherMethod;
static GVar G_IsAttributeStoringRep;
static Obj  GC_IsAttributeStoringRep;
static Obj  GF_IsAttributeStoringRep;
static GVar G_GETTER__FLAGS;
static Obj  GC_GETTER__FLAGS;
static GVar G_LENGTH__SETTER__METHODS__2;
static Obj  GC_LENGTH__SETTER__METHODS__2;
static GVar G_SetFilterObj;
static Obj  GC_SetFilterObj;
static Obj  GF_SetFilterObj;
static GVar G_Subtype;
static Obj  GF_Subtype;
static GVar G_DS__TYPE__CACHE;
static Obj  GC_DS__TYPE__CACHE;
static GVar G_ShareSpecialObj;
static Obj  GF_ShareSpecialObj;
static GVar G_BIND__GLOBAL;
static Obj  GF_BIND__GLOBAL;
static GVar G_WITH__IMPS__FLAGS;
static Obj  GF_WITH__IMPS__FLAGS;
static GVar G_CATEGORIES__FAMILY;
static Obj  GC_CATEGORIES__FAMILY;
static GVar G_NEW__FAMILY;
static Obj  GF_NEW__FAMILY;
static GVar G_EMPTY__FLAGS;
static Obj  GC_EMPTY__FLAGS;
static GVar G_NewFamily2;
static Obj  GF_NewFamily2;
static GVar G_TypeOfFamilies;
static Obj  GC_TypeOfFamilies;
static GVar G_NewFamily3;
static Obj  GF_NewFamily3;
static GVar G_NewFamily4;
static Obj  GF_NewFamily4;
static GVar G_NewFamily5;
static Obj  GF_NewFamily5;
static GVar G_NEW__TYPE__CACHE__MISS;
static Obj  GC_NEW__TYPE__CACHE__MISS;
static GVar G_NEW__TYPE__CACHE__HIT;
static Obj  GC_NEW__TYPE__CACHE__HIT;
static GVar G_POS__DATA__TYPE;
static Obj  GC_POS__DATA__TYPE;
static GVar G_POS__FIRST__FREE__TYPE;
static Obj  GC_POS__FIRST__FREE__TYPE;
static GVar G_NEW__TYPE__NEXT__ID;
static Obj  GC_NEW__TYPE__NEXT__ID;
static GVar G_NEW__TYPE__ID__LIMIT;
static Obj  GC_NEW__TYPE__ID__LIMIT;
static GVar G_FLUSH__ALL__METHOD__CACHES;
static Obj  GF_FLUSH__ALL__METHOD__CACHES;
static GVar G_POS__NUMB__TYPE;
static Obj  GC_POS__NUMB__TYPE;
static GVar G_NEW__TYPE;
static Obj  GF_NEW__TYPE;
static GVar G_IsFamily;
static Obj  GF_IsFamily;
static GVar G_NewType3;
static Obj  GF_NewType3;
static GVar G_TypeOfTypes;
static Obj  GC_TypeOfTypes;
static GVar G_NewType4;
static Obj  GF_NewType4;
static GVar G_Subtype2;
static Obj  GF_Subtype2;
static GVar G_Subtype3;
static Obj  GF_Subtype3;
static GVar G_SupType2;
static Obj  GF_SupType2;
static GVar G_SupType3;
static Obj  GF_SupType3;
static GVar G_MakeLiteral;
static Obj  GF_MakeLiteral;
static GVar G_FlagsType;
static Obj  GF_FlagsType;
static GVar G_TypeObj;
static Obj  GF_TypeObj;
static GVar G_DataType;
static Obj  GF_DataType;
static GVar G_IsNoImmediateMethodsObject;
static Obj  GF_IsNoImmediateMethodsObject;
static GVar G_RunImmediateMethods;
static Obj  GF_RunImmediateMethods;
static GVar G_IsNonAtomicComponentObjectRep;
static Obj  GC_IsNonAtomicComponentObjectRep;
static GVar G_IsAtomicPositionalObjectRep;
static Obj  GC_IsAtomicPositionalObjectRep;
static GVar G_IsReadOnlyPositionalObjectRep;
static Obj  GC_IsReadOnlyPositionalObjectRep;
static Obj  GF_IsReadOnlyPositionalObjectRep;
static GVar G_IsAtomicPositionalObjectRepFlags;
static Obj  GC_IsAtomicPositionalObjectRepFlags;
static GVar G_IsNonAtomicComponentObjectRepFlags;
static Obj  GC_IsNonAtomicComponentObjectRepFlags;
static GVar G_ChangeTypeObj;
static Obj  GC_ChangeTypeObj;
static Obj  GF_ChangeTypeObj;
static GVar G_IGNORE__IMMEDIATE__METHODS;
static Obj  GC_IGNORE__IMMEDIATE__METHODS;
static GVar G_ResetFilterObj;
static Obj  GC_ResetFilterObj;
static Obj  GF_ResetFilterObj;
static GVar G_Tester;
static Obj  GF_Tester;
static GVar G_Setter;
static Obj  GF_Setter;
static GVar G_FamilyType;
static Obj  GF_FamilyType;
static GVar G_Ignore;
static Obj  GC_Ignore;
static GVar G_MAKE__READ__WRITE__GLOBAL;
static Obj  GF_MAKE__READ__WRITE__GLOBAL;
static GVar G_IsAttributeStoringRepFlags;
static Obj  GC_IsAttributeStoringRepFlags;
static GVar G_INFO__OWA;
static Obj  GF_INFO__OWA;
static GVar G_Objectify;
static Obj  GF_Objectify;

/* record names used in handlers */
static RNam R_TYPES__LIST__FAM;
static RNam R_NAME;
static RNam R_REQ__FLAGS;
static RNam R_IMP__FLAGS;
static RNam R_TYPES;
static RNam R_nTYPES;
static RNam R_HASH__SIZE;

/* information for the functions */
static Obj  NameFunc[35];
static Obj  NamsFunc[35];
static Int  NargFunc[35];
static Obj  DefaultName;
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_name,
 Obj  a_filter,
 Obj  a_getter,
 Obj  a_setter,
 Obj  a_tester,
 Obj  a_mutflag )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* InstallOtherMethod( getter, "system getter", true, [ IsAttributeStoringRep and tester ], GETTER_FLAGS, GETTER_FUNCTION( name ) ); */
 t_1 = GF_InstallOtherMethod;
 C_NEW_STRING( t_2, 13, "system getter" );
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_6 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_6, "IsAttributeStoringRep" )
 if ( t_6 == False ) {
  t_5 = t_6;
 }
 else if ( t_6 == True ) {
  CHECK_BOOL( a_tester )
  t_5 = a_tester;
 }
 else {
  CHECK_FUNC( t_6 )
  CHECK_FUNC( a_tester )
  t_5 = NewAndFilter( t_6, a_tester );
 }
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_5 = GC_GETTER__FLAGS;
 CHECK_BOUND( t_5, "GETTER_FLAGS" )
 t_7 = GF_GETTER__FUNCTION;
 t_6 = CALL_1ARGS( t_7, a_name );
 CHECK_FUNC_RESULT( t_6 )
 CALL_6ARGS( t_1, a_getter, t_2, t_3, t_4, t_5, t_6 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 4 */
static Obj  HdlrFunc4 (
 Obj  self,
 Obj  a_obj,
 Obj  a_val )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* obj!.(name) := val; */
 t_1 = OBJ_LVAR_1UP( 1 );
 CHECK_BOUND( t_1, "name" )
 if ( TNUM_OBJ(a_obj) == T_COMOBJ ) {
  AssPRec( a_obj, RNamObj(t_1), a_val );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_obj) == T_ACOMOBJ ) {
  AssARecord( a_obj, RNamObj(t_1), a_val );
#endif
 }
 else {
  ASS_REC( a_obj, RNamObj(t_1), a_val );
 }
 
 /* SetFilterObj( obj, tester ); */
 t_1 = GF_SetFilterObj;
 t_2 = OBJ_LVAR_1UP( 2 );
 CHECK_BOUND( t_2, "tester" )
 CALL_2ARGS( t_1, a_obj, t_2 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self,
 Obj  a_name,
 Obj  a_filter,
 Obj  a_getter,
 Obj  a_setter,
 Obj  a_tester,
 Obj  a_mutflag )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,2,0,oldFrame);
 ASS_LVAR( 1, a_name );
 ASS_LVAR( 2, a_tester );
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if mutflag then */
 CHECK_BOOL( a_mutflag )
 t_1 = (Obj)(UInt)(a_mutflag != False);
 if ( t_1 ) {
  
  /* InstallOtherMethod( setter, "system mutable setter", true, [ IsAttributeStoringRep, IS_OBJECT ], 0, function ( obj, val )
      obj!.(name) := val;
      SetFilterObj( obj, tester );
      return;
  end ); */
  t_1 = GF_InstallOtherMethod;
  C_NEW_STRING( t_2, 21, "system mutable setter" );
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_5, "IsAttributeStoringRep" )
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  CHECK_BOUND( t_5, "IS_OBJECT" )
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4 );
  ENVI_FUNC( t_5 ) = STATE(CurrLVars);
  t_6 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
  SET_STARTLINE_BODY(t_6, INTOBJ_INT(39));
  SET_ENDLINE_BODY(t_6, INTOBJ_INT(42));
  SET_FILENAME_BODY(t_6, FileName);
  BODY_FUNC(t_5) = t_6;
  CHANGED_BAG( STATE(CurrLVars) );
  CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
  
 }
 
 /* else */
 else {
  
  /* InstallOtherMethod( setter, "system setter", true, [ IsAttributeStoringRep, IS_OBJECT ], 0, SETTER_FUNCTION( name, tester ) ); */
  t_1 = GF_InstallOtherMethod;
  C_NEW_STRING( t_2, 13, "system setter" );
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_5, "IsAttributeStoringRep" )
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  CHECK_BOUND( t_5, "IS_OBJECT" )
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_6 = GF_SETTER__FUNCTION;
  t_7 = OBJ_LVAR( 1 );
  CHECK_BOUND( t_7, "name" )
  t_8 = OBJ_LVAR( 2 );
  CHECK_BOUND( t_8, "tester" )
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  CHECK_FUNC_RESULT( t_5 )
  CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
  
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 5 */
static Obj  HdlrFunc5 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req__filter,
 Obj  a_imp__filter )
{
 Obj l_lock = 0;
 Obj l_type = 0;
 Obj l_pair = 0;
 Obj l_family = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) ); */
 t_2 = GF_WITH__IMPS__FLAGS;
 t_4 = GF_AND__FLAGS;
 t_3 = CALL_2ARGS( t_4, a_imp__filter, a_req__filter );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 a_imp__filter = t_1;
 
 /* type := Subtype( typeOfFamilies, IsAttributeStoringRep ); */
 t_2 = GF_Subtype;
 t_3 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_3, "IsAttributeStoringRep" )
 t_1 = CALL_2ARGS( t_2, a_typeOfFamilies, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_type = t_1;
 
 /* lock := READ_LOCK( CATEGORIES_FAMILY ); */
 t_2 = GF_READ__LOCK;
 t_3 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_3, "CATEGORIES_FAMILY" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_lock = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_4, "CATEGORIES_FAMILY" )
 if ( IS_SMALL_LIST(t_4) ) {
  t_3 = (Obj)(UInt)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)(UInt)0;
  t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
 }
 while ( 1 ) {
  if ( t_3 ) {
   if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
   t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
   t_1 = (Obj)(((UInt)t_1)+4);
   if ( t_2 == 0 )  continue;
  }
  else {
   if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
   t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
  }
  l_pair = t_2;
  
  /* if IS_SUBSET_FLAGS( imp_filter, pair[1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_LIST_FPL( t_8, l_pair, INTOBJ_INT(1) )
  t_6 = CALL_2ARGS( t_7, a_imp__filter, t_8 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* type := Subtype( type, pair[2] ); */
   t_6 = GF_Subtype;
   C_ELM_LIST_FPL( t_7, l_pair, INTOBJ_INT(2) )
   t_5 = CALL_2ARGS( t_6, l_type, t_7 );
   CHECK_FUNC_RESULT( t_5 )
   l_type = t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* UNLOCK( lock ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_lock );
 
 /* family := AtomicRecord(  ); */
 t_2 = GF_AtomicRecord;
 t_1 = CALL_0ARGS( t_2 );
 CHECK_FUNC_RESULT( t_1 )
 l_family = t_1;
 
 /* SET_TYPE_COMOBJ( family, type ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 CALL_2ARGS( t_1, l_family, l_type );
 
 /* family!.NAME := MakeImmutable( name ); */
 t_2 = GF_MakeImmutable;
 t_1 = CALL_1ARGS( t_2, a_name );
 CHECK_FUNC_RESULT( t_1 )
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_NAME, t_1 );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_NAME, t_1 );
#endif
 }
 else {
  ASS_REC( l_family, R_NAME, t_1 );
 }
 
 /* family!.REQ_FLAGS := req_filter; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_REQ__FLAGS, a_req__filter );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_REQ__FLAGS, a_req__filter );
#endif
 }
 else {
  ASS_REC( l_family, R_REQ__FLAGS, a_req__filter );
 }
 
 /* family!.IMP_FLAGS := imp_filter; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_IMP__FLAGS, a_imp__filter );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_IMP__FLAGS, a_imp__filter );
#endif
 }
 else {
  ASS_REC( l_family, R_IMP__FLAGS, a_imp__filter );
 }
 
 /* lock := WRITE_LOCK( DS_TYPE_CACHE ); */
 t_2 = GF_WRITE__LOCK;
 t_3 = GC_DS__TYPE__CACHE;
 CHECK_BOUND( t_3, "DS_TYPE_CACHE" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_lock = t_1;
 
 /* family!.TYPES := MIGRATE_RAW( [  ], DS_TYPE_CACHE ); */
 t_2 = GF_MIGRATE__RAW;
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 t_4 = GC_DS__TYPE__CACHE;
 CHECK_BOUND( t_4, "DS_TYPE_CACHE" )
 t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_TYPES, t_1 );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_TYPES, t_1 );
#endif
 }
 else {
  ASS_REC( l_family, R_TYPES, t_1 );
 }
 
 /* UNLOCK( lock ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_lock );
 
 /* family!.nTYPES := 0; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_nTYPES, INTOBJ_INT(0) );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_nTYPES, INTOBJ_INT(0) );
#endif
 }
 else {
  ASS_REC( l_family, R_nTYPES, INTOBJ_INT(0) );
 }
 
 /* family!.HASH_SIZE := 32; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_HASH__SIZE, INTOBJ_INT(32) );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_HASH__SIZE, INTOBJ_INT(32) );
#endif
 }
 else {
  ASS_REC( l_family, R_HASH__SIZE, INTOBJ_INT(32) );
 }
 
 /* family!.TYPES_LIST_FAM := MakeWriteOnceAtomic( AtomicList( 27 ) ); */
 t_2 = GF_MakeWriteOnceAtomic;
 t_4 = GF_AtomicList;
 t_3 = CALL_1ARGS( t_4, INTOBJ_INT(27) );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_TYPES__LIST__FAM, t_1 );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(l_family) == T_ACOMOBJ ) {
  AssARecord( l_family, R_TYPES__LIST__FAM, t_1 );
#endif
 }
 else {
  ASS_REC( l_family, R_TYPES__LIST__FAM, t_1 );
 }
 
 /* return family; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_family;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_FAMILY( typeOfFamilies, name, EMPTY_FLAGS, EMPTY_FLAGS ); */
 t_2 = GF_NEW__FAMILY;
 t_3 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_3, "EMPTY_FLAGS" )
 t_4 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_4, "EMPTY_FLAGS" )
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 7 */
static Obj  HdlrFunc7 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_FAMILY( typeOfFamilies, name, FLAGS_FILTER( req ), EMPTY_FLAGS ); */
 t_2 = GF_NEW__FAMILY;
 t_4 = GF_FLAGS__FILTER;
 t_3 = CALL_1ARGS( t_4, a_req );
 CHECK_FUNC_RESULT( t_3 )
 t_4 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_4, "EMPTY_FLAGS" )
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req,
 Obj  a_imp )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_FAMILY( typeOfFamilies, name, FLAGS_FILTER( req ), FLAGS_FILTER( imp ) ); */
 t_2 = GF_NEW__FAMILY;
 t_4 = GF_FLAGS__FILTER;
 t_3 = CALL_1ARGS( t_4, a_req );
 CHECK_FUNC_RESULT( t_3 )
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_imp );
 CHECK_FUNC_RESULT( t_4 )
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 9 */
static Obj  HdlrFunc9 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req,
 Obj  a_imp,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_FAMILY( Subtype( typeOfFamilies, filter ), name, FLAGS_FILTER( req ), FLAGS_FILTER( imp ) ); */
 t_2 = GF_NEW__FAMILY;
 t_4 = GF_Subtype;
 t_3 = CALL_2ARGS( t_4, a_typeOfFamilies, a_filter );
 CHECK_FUNC_RESULT( t_3 )
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_req );
 CHECK_FUNC_RESULT( t_4 )
 t_6 = GF_FLAGS__FILTER;
 t_5 = CALL_1ARGS( t_6, a_imp );
 CHECK_FUNC_RESULT( t_5 )
 t_1 = CALL_4ARGS( t_2, t_3, a_name, t_4, t_5 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 10 */
static Obj  HdlrFunc10 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if LEN_LIST( arg ) = 1 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(1) ));
 if ( t_1 ) {
  
  /* return NewFamily2( TypeOfFamilies, arg[1] ); */
  t_2 = GF_NewFamily2;
  t_3 = GC_TypeOfFamilies;
  CHECK_BOUND( t_3, "TypeOfFamilies" )
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(1) )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 2 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
  if ( t_1 ) {
   
   /* return NewFamily3( TypeOfFamilies, arg[1], arg[2] ); */
   t_2 = GF_NewFamily3;
   t_3 = GC_TypeOfFamilies;
   CHECK_BOUND( t_3, "TypeOfFamilies" )
   C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(1) )
   C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(2) )
   t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
   CHECK_FUNC_RESULT( t_1 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_1;
   
  }
  
  /* elif LEN_LIST( arg ) = 3 then */
  else {
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, a_arg );
   CHECK_FUNC_RESULT( t_2 )
   t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(3) ));
   if ( t_1 ) {
    
    /* return NewFamily4( TypeOfFamilies, arg[1], arg[2], arg[3] ); */
    t_2 = GF_NewFamily4;
    t_3 = GC_TypeOfFamilies;
    CHECK_BOUND( t_3, "TypeOfFamilies" )
    C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(1) )
    C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(2) )
    C_ELM_LIST_FPL( t_6, a_arg, INTOBJ_INT(3) )
    t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
    CHECK_FUNC_RESULT( t_1 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_1;
    
   }
   
   /* elif LEN_LIST( arg ) = 4 then */
   else {
    t_3 = GF_LEN__LIST;
    t_2 = CALL_1ARGS( t_3, a_arg );
    CHECK_FUNC_RESULT( t_2 )
    t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(4) ));
    if ( t_1 ) {
     
     /* return NewFamily5( TypeOfFamilies, arg[1], arg[2], arg[3], arg[4] ); */
     t_2 = GF_NewFamily5;
     t_3 = GC_TypeOfFamilies;
     CHECK_BOUND( t_3, "TypeOfFamilies" )
     C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(1) )
     C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(2) )
     C_ELM_LIST_FPL( t_6, a_arg, INTOBJ_INT(3) )
     C_ELM_LIST_FPL( t_7, a_arg, INTOBJ_INT(4) )
     t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, t_7 );
     CHECK_FUNC_RESULT( t_1 )
     RES_BRK_CURR_STAT();
     SWITCH_TO_OLD_FRAME(oldFrame);
     return t_1;
     
    }
    
    /* else */
    else {
     
     /* Error( "usage: NewFamily( <name>, [ <req> [, <imp> ]] )" ); */
     t_1 = GF_Error;
     C_NEW_STRING( t_2, 47, "usage: NewFamily( <name>, [ <req> [, <imp> ]] )" );
     CALL_1ARGS( t_1, t_2 );
     
    }
   }
  }
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 11 */
static Obj  HdlrFunc11 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_flags,
 Obj  a_data,
 Obj  a_parent )
{
 Obj l_lock = 0;
 Obj l_hash = 0;
 Obj l_cache = 0;
 Obj l_cached = 0;
 Obj l_type = 0;
 Obj l_ncache = 0;
 Obj l_ncl = 0;
 Obj l_t = 0;
 Obj l_i = 0;
 Obj l_match = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Obj t_10 = 0;
 Obj t_11 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* lock := WRITE_LOCK( DS_TYPE_CACHE ); */
 t_2 = GF_WRITE__LOCK;
 t_3 = GC_DS__TYPE__CACHE;
 CHECK_BOUND( t_3, "DS_TYPE_CACHE" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_lock = t_1;
 
 /* cache := family!.TYPES; */
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_1 = ElmPRec( a_family, R_TYPES );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_1 = ElmARecord( a_family, R_TYPES );
#endif
 }
 else {
  t_1 = ELM_REC( a_family, R_TYPES );
 }
 l_cache = t_1;
 
 /* hash := HASH_FLAGS( flags ) mod family!.HASH_SIZE + 1; */
 t_4 = GF_HASH__FLAGS;
 t_3 = CALL_1ARGS( t_4, a_flags );
 CHECK_FUNC_RESULT( t_3 )
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_4 = ElmPRec( a_family, R_HASH__SIZE );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_4 = ElmARecord( a_family, R_HASH__SIZE );
#endif
 }
 else {
  t_4 = ELM_REC( a_family, R_HASH__SIZE );
 }
 t_2 = MOD( t_3, t_4 );
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 l_hash = t_1;
 
 /* if IsBound( cache[hash] ) then */
 CHECK_INT_POS( l_hash )
 t_2 = C_ISB_LIST( l_cache, l_hash );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* cached := cache[hash]; */
  C_ELM_LIST_FPL( t_1, l_cache, l_hash )
  l_cached = t_1;
  
  /* if IS_EQUAL_FLAGS( flags, cached![2] ) then */
  t_3 = GF_IS__EQUAL__FLAGS;
  C_ELM_POSOBJ_NLE( t_4, l_cached, 2 );
  t_2 = CALL_2ARGS( t_3, a_flags, t_4 );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* flags := cached![2]; */
   C_ELM_POSOBJ_NLE( t_1, l_cached, 2 );
   a_flags = t_1;
   
   /* if IS_IDENTICAL_OBJ( data, cached![POS_DATA_TYPE] ) and IS_IDENTICAL_OBJ( typeOfTypes, TYPE_OBJ( cached ) ) then */
   t_4 = GF_IS__IDENTICAL__OBJ;
   t_6 = GC_POS__DATA__TYPE;
   CHECK_BOUND( t_6, "POS_DATA_TYPE" )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_POSOBJ_NLE( t_5, l_cached, INT_INTOBJ(t_6) );
   t_3 = CALL_2ARGS( t_4, a_data, t_5 );
   CHECK_FUNC_RESULT( t_3 )
   CHECK_BOOL( t_3 )
   t_2 = (Obj)(UInt)(t_3 != False);
   t_1 = t_2;
   if ( t_1 ) {
    t_5 = GF_IS__IDENTICAL__OBJ;
    t_7 = GF_TYPE__OBJ;
    t_6 = CALL_1ARGS( t_7, l_cached );
    CHECK_FUNC_RESULT( t_6 )
    t_4 = CALL_2ARGS( t_5, a_typeOfTypes, t_6 );
    CHECK_FUNC_RESULT( t_4 )
    CHECK_BOOL( t_4 )
    t_3 = (Obj)(UInt)(t_4 != False);
    t_1 = t_3;
   }
   if ( t_1 ) {
    
    /* if IS_IDENTICAL_OBJ( parent, fail ) and LEN_POSOBJ( cached ) = POS_FIRST_FREE_TYPE - 1 then */
    t_4 = GF_IS__IDENTICAL__OBJ;
    t_5 = GC_fail;
    CHECK_BOUND( t_5, "fail" )
    t_3 = CALL_2ARGS( t_4, a_parent, t_5 );
    CHECK_FUNC_RESULT( t_3 )
    CHECK_BOOL( t_3 )
    t_2 = (Obj)(UInt)(t_3 != False);
    t_1 = t_2;
    if ( t_1 ) {
     t_5 = GF_LEN__POSOBJ;
     t_4 = CALL_1ARGS( t_5, l_cached );
     CHECK_FUNC_RESULT( t_4 )
     t_6 = GC_POS__FIRST__FREE__TYPE;
     CHECK_BOUND( t_6, "POS_FIRST_FREE_TYPE" )
     C_DIFF_FIA( t_5, t_6, INTOBJ_INT(1) )
     t_3 = (Obj)(UInt)(EQ( t_4, t_5 ));
     t_1 = t_3;
    }
    if ( t_1 ) {
     
     /* NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1; */
     t_2 = GC_NEW__TYPE__CACHE__HIT;
     CHECK_BOUND( t_2, "NEW_TYPE_CACHE_HIT" )
     C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
     AssGVar( G_NEW__TYPE__CACHE__HIT, t_1 );
     
     /* UNLOCK( lock ); */
     t_1 = GF_UNLOCK;
     CALL_1ARGS( t_1, l_lock );
     
     /* return cached; */
     RES_BRK_CURR_STAT();
     SWITCH_TO_OLD_FRAME(oldFrame);
     return l_cached;
     
    }
    /* fi */
    
    /* if LEN_POSOBJ( parent ) = LEN_POSOBJ( cached ) then */
    t_3 = GF_LEN__POSOBJ;
    t_2 = CALL_1ARGS( t_3, a_parent );
    CHECK_FUNC_RESULT( t_2 )
    t_4 = GF_LEN__POSOBJ;
    t_3 = CALL_1ARGS( t_4, l_cached );
    CHECK_FUNC_RESULT( t_3 )
    t_1 = (Obj)(UInt)(EQ( t_2, t_3 ));
    if ( t_1 ) {
     
     /* match := true; */
     t_1 = True;
     l_match = t_1;
     
     /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( parent ) ] do */
     t_2 = GC_POS__FIRST__FREE__TYPE;
     CHECK_BOUND( t_2, "POS_FIRST_FREE_TYPE" )
     CHECK_INT_SMALL( t_2 )
     t_4 = GF_LEN__POSOBJ;
     t_3 = CALL_1ARGS( t_4, a_parent );
     CHECK_FUNC_RESULT( t_3 )
     CHECK_INT_SMALL( t_3 )
     for ( t_1 = t_2;
           ((Int)t_1) <= ((Int)t_3);
           t_1 = (Obj)(((UInt)t_1)+4) ) {
      l_i = t_1;
      
      /* if IsBound( parent![i]) <> IsBound( cached![i]) then */
      CHECK_INT_SMALL_POS( l_i )
      if ( TNUM_OBJ(a_parent) == T_POSOBJ ) {
       t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_parent)/sizeof(Obj)-1
          && ELM_PLIST(a_parent,INT_INTOBJ(l_i)) != 0 ? True : False);
#ifdef HPCGAP
      } else if ( TNUM_OBJ(a_parent) == T_APOSOBJ ) {
       t_5 = Elm0AList(a_parent,INT_INTOBJ(l_i)) != 0 ? True : False;
#endif
      }
      else {
       t_5 = (ISB_LIST( a_parent, INT_INTOBJ(l_i) ) ? True : False);
      }
      if ( TNUM_OBJ(l_cached) == T_POSOBJ ) {
       t_6 = (INT_INTOBJ(l_i) <= SIZE_OBJ(l_cached)/sizeof(Obj)-1
          && ELM_PLIST(l_cached,INT_INTOBJ(l_i)) != 0 ? True : False);
#ifdef HPCGAP
      } else if ( TNUM_OBJ(l_cached) == T_APOSOBJ ) {
       t_6 = Elm0AList(l_cached,INT_INTOBJ(l_i)) != 0 ? True : False;
#endif
      }
      else {
       t_6 = (ISB_LIST( l_cached, INT_INTOBJ(l_i) ) ? True : False);
      }
      t_4 = (Obj)(UInt)( ! EQ( t_5, t_6 ));
      if ( t_4 ) {
       
       /* match := false; */
       t_4 = False;
       l_match = t_4;
       
       /* break; */
       break;
       
      }
      /* fi */
      
      /* if IsBound( parent![i]) and IsBound( cached![i]) and not IS_IDENTICAL_OBJ( parent![i], cached![i] ) then */
      if ( TNUM_OBJ(a_parent) == T_POSOBJ ) {
       t_7 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_parent)/sizeof(Obj)-1
          && ELM_PLIST(a_parent,INT_INTOBJ(l_i)) != 0 ? True : False);
#ifdef HPCGAP
      } else if ( TNUM_OBJ(a_parent) == T_APOSOBJ ) {
       t_7 = Elm0AList(a_parent,INT_INTOBJ(l_i)) != 0 ? True : False;
#endif
      }
      else {
       t_7 = (ISB_LIST( a_parent, INT_INTOBJ(l_i) ) ? True : False);
      }
      t_6 = (Obj)(UInt)(t_7 != False);
      t_5 = t_6;
      if ( t_5 ) {
       if ( TNUM_OBJ(l_cached) == T_POSOBJ ) {
        t_8 = (INT_INTOBJ(l_i) <= SIZE_OBJ(l_cached)/sizeof(Obj)-1
           && ELM_PLIST(l_cached,INT_INTOBJ(l_i)) != 0 ? True : False);
#ifdef HPCGAP
       } else if ( TNUM_OBJ(l_cached) == T_APOSOBJ ) {
        t_8 = Elm0AList(l_cached,INT_INTOBJ(l_i)) != 0 ? True : False;
#endif
       }
       else {
        t_8 = (ISB_LIST( l_cached, INT_INTOBJ(l_i) ) ? True : False);
       }
       t_7 = (Obj)(UInt)(t_8 != False);
       t_5 = t_7;
      }
      t_4 = t_5;
      if ( t_4 ) {
       t_9 = GF_IS__IDENTICAL__OBJ;
       C_ELM_POSOBJ_NLE( t_10, a_parent, INT_INTOBJ(l_i) );
       C_ELM_POSOBJ_NLE( t_11, l_cached, INT_INTOBJ(l_i) );
       t_8 = CALL_2ARGS( t_9, t_10, t_11 );
       CHECK_FUNC_RESULT( t_8 )
       CHECK_BOOL( t_8 )
       t_7 = (Obj)(UInt)(t_8 != False);
       t_6 = (Obj)(UInt)( ! ((Int)t_7) );
       t_4 = t_6;
      }
      if ( t_4 ) {
       
       /* match := false; */
       t_4 = False;
       l_match = t_4;
       
       /* break; */
       break;
       
      }
      /* fi */
      
     }
     /* od */
     
     /* if match then */
     t_1 = (Obj)(UInt)(l_match != False);
     if ( t_1 ) {
      
      /* NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1; */
      t_2 = GC_NEW__TYPE__CACHE__HIT;
      CHECK_BOUND( t_2, "NEW_TYPE_CACHE_HIT" )
      C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
      AssGVar( G_NEW__TYPE__CACHE__HIT, t_1 );
      
      /* UNLOCK( lock ); */
      t_1 = GF_UNLOCK;
      CALL_1ARGS( t_1, l_lock );
      
      /* return cached; */
      RES_BRK_CURR_STAT();
      SWITCH_TO_OLD_FRAME(oldFrame);
      return l_cached;
      
     }
     /* fi */
     
    }
    /* fi */
    
   }
   /* fi */
   
  }
  /* fi */
  
  /* NEW_TYPE_CACHE_MISS := NEW_TYPE_CACHE_MISS + 1; */
  t_2 = GC_NEW__TYPE__CACHE__MISS;
  CHECK_BOUND( t_2, "NEW_TYPE_CACHE_MISS" )
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  AssGVar( G_NEW__TYPE__CACHE__MISS, t_1 );
  
 }
 /* fi */
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* if NEW_TYPE_NEXT_ID >= NEW_TYPE_ID_LIMIT then */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 t_3 = GC_NEW__TYPE__ID__LIMIT;
 CHECK_BOUND( t_3, "NEW_TYPE_ID_LIMIT" )
 t_1 = (Obj)(UInt)(! LT( t_2, t_3 ));
 if ( t_1 ) {
  
  /* GASMAN( "collect" ); */
  t_1 = GF_GASMAN;
  C_NEW_STRING( t_2, 7, "collect" );
  CALL_1ARGS( t_1, t_2 );
  
  /* FLUSH_ALL_METHOD_CACHES(  ); */
  t_1 = GF_FLUSH__ALL__METHOD__CACHES;
  CALL_0ARGS( t_1 );
  
  /* NEW_TYPE_NEXT_ID := COMPACT_TYPE_IDS(  ); */
  t_2 = GF_COMPACT__TYPE__IDS;
  t_1 = CALL_0ARGS( t_2 );
  CHECK_FUNC_RESULT( t_1 )
  AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
  
 }
 /* fi */
 
 /* type := [ family, flags ]; */
 t_1 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_1, 2 );
 SET_ELM_PLIST( t_1, 1, a_family );
 CHANGED_BAG( t_1 );
 SET_ELM_PLIST( t_1, 2, a_flags );
 CHANGED_BAG( t_1 );
 l_type = t_1;
 
 /* type[POS_DATA_TYPE] := MakeReadOnly( data ); */
 t_1 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_1, "POS_DATA_TYPE" )
 CHECK_INT_POS( t_1 )
 t_3 = GF_MakeReadOnly;
 t_2 = CALL_1ARGS( t_3, a_data );
 CHECK_FUNC_RESULT( t_2 )
 C_ASS_LIST_FPL( l_type, t_1, t_2 )
 
 /* type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID; */
 t_1 = GC_POS__NUMB__TYPE;
 CHECK_BOUND( t_1, "POS_NUMB_TYPE" )
 CHECK_INT_POS( t_1 )
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_ASS_LIST_FPL( l_type, t_1, t_2 )
 
 /* if not IS_IDENTICAL_OBJ( parent, fail ) then */
 t_4 = GF_IS__IDENTICAL__OBJ;
 t_5 = GC_fail;
 CHECK_BOUND( t_5, "fail" )
 t_3 = CALL_2ARGS( t_4, a_parent, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( parent ) ] do */
  t_2 = GC_POS__FIRST__FREE__TYPE;
  CHECK_BOUND( t_2, "POS_FIRST_FREE_TYPE" )
  CHECK_INT_SMALL( t_2 )
  t_4 = GF_LEN__POSOBJ;
  t_3 = CALL_1ARGS( t_4, a_parent );
  CHECK_FUNC_RESULT( t_3 )
  CHECK_INT_SMALL( t_3 )
  for ( t_1 = t_2;
        ((Int)t_1) <= ((Int)t_3);
        t_1 = (Obj)(((UInt)t_1)+4) ) {
   l_i = t_1;
   
   /* if IsBound( parent![i]) and not IsBound( type[i] ) then */
   CHECK_INT_SMALL_POS( l_i )
   if ( TNUM_OBJ(a_parent) == T_POSOBJ ) {
    t_6 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_parent)/sizeof(Obj)-1
       && ELM_PLIST(a_parent,INT_INTOBJ(l_i)) != 0 ? True : False);
#ifdef HPCGAP
   } else if ( TNUM_OBJ(a_parent) == T_APOSOBJ ) {
    t_6 = Elm0AList(a_parent,INT_INTOBJ(l_i)) != 0 ? True : False;
#endif
   }
   else {
    t_6 = (ISB_LIST( a_parent, INT_INTOBJ(l_i) ) ? True : False);
   }
   t_5 = (Obj)(UInt)(t_6 != False);
   t_4 = t_5;
   if ( t_4 ) {
    t_8 = C_ISB_LIST( l_type, l_i );
    t_7 = (Obj)(UInt)(t_8 != False);
    t_6 = (Obj)(UInt)( ! ((Int)t_7) );
    t_4 = t_6;
   }
   if ( t_4 ) {
    
    /* type[i] := parent![i]; */
    C_ELM_POSOBJ_NLE( t_4, a_parent, INT_INTOBJ(l_i) );
    C_ASS_LIST_FPL( l_type, l_i, t_4 )
    
   }
   /* fi */
   
  }
  /* od */
  
 }
 /* fi */
 
 /* SET_TYPE_POSOBJ( type, typeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 CALL_2ARGS( t_1, l_type, a_typeOfTypes );
 
 /* if 3 * family!.nTYPES > family!.HASH_SIZE then */
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_3 = ElmPRec( a_family, R_nTYPES );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_3 = ElmARecord( a_family, R_nTYPES );
#endif
 }
 else {
  t_3 = ELM_REC( a_family, R_nTYPES );
 }
 C_PROD_FIA( t_2, INTOBJ_INT(3), t_3 )
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_3 = ElmPRec( a_family, R_HASH__SIZE );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_3 = ElmARecord( a_family, R_HASH__SIZE );
#endif
 }
 else {
  t_3 = ELM_REC( a_family, R_HASH__SIZE );
 }
 t_1 = (Obj)(UInt)(LT( t_3, t_2 ));
 if ( t_1 ) {
  
  /* ncache := MIGRATE_RAW( [  ], DS_TYPE_CACHE ); */
  t_2 = GF_MIGRATE__RAW;
  t_3 = NEW_PLIST( T_PLIST, 0 );
  SET_LEN_PLIST( t_3, 0 );
  t_4 = GC_DS__TYPE__CACHE;
  CHECK_BOUND( t_4, "DS_TYPE_CACHE" )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  l_ncache = t_1;
  
  /* ncl := 3 * family!.HASH_SIZE + 1; */
  if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
   t_3 = ElmPRec( a_family, R_HASH__SIZE );
#ifdef HPCGAP
  } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
   t_3 = ElmARecord( a_family, R_HASH__SIZE );
#endif
  }
  else {
   t_3 = ELM_REC( a_family, R_HASH__SIZE );
  }
  C_PROD_FIA( t_2, INTOBJ_INT(3), t_3 )
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  l_ncl = t_1;
  
  /* for t in cache do */
  t_4 = l_cache;
  if ( IS_SMALL_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_t = t_2;
   
   /* ncache[HASH_FLAGS( t![2] ) mod ncl + 1] := t; */
   t_8 = GF_HASH__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, l_t, 2 );
   t_7 = CALL_1ARGS( t_8, t_9 );
   CHECK_FUNC_RESULT( t_7 )
   t_6 = MOD( t_7, l_ncl );
   C_SUM_FIA( t_5, t_6, INTOBJ_INT(1) )
   CHECK_INT_POS( t_5 )
   C_ASS_LIST_FPL( l_ncache, t_5, l_t )
   
  }
  /* od */
  
  /* family!.HASH_SIZE := ncl; */
  if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
   AssPRec( a_family, R_HASH__SIZE, l_ncl );
#ifdef HPCGAP
  } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ ) {
   AssARecord( a_family, R_HASH__SIZE, l_ncl );
#endif
  }
  else {
   ASS_REC( a_family, R_HASH__SIZE, l_ncl );
  }
  
  /* family!.TYPES := ncache; */
  if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
   AssPRec( a_family, R_TYPES, l_ncache );
#ifdef HPCGAP
  } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ ) {
   AssARecord( a_family, R_TYPES, l_ncache );
#endif
  }
  else {
   ASS_REC( a_family, R_TYPES, l_ncache );
  }
  
  /* ncache[HASH_FLAGS( flags ) mod ncl + 1] := type; */
  t_4 = GF_HASH__FLAGS;
  t_3 = CALL_1ARGS( t_4, a_flags );
  CHECK_FUNC_RESULT( t_3 )
  t_2 = MOD( t_3, l_ncl );
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  CHECK_INT_POS( t_1 )
  C_ASS_LIST_FPL( l_ncache, t_1, l_type )
  
 }
 
 /* else */
 else {
  
  /* cache[hash] := type; */
  C_ASS_LIST_FPL( l_cache, l_hash, l_type )
  
 }
 /* fi */
 
 /* family!.nTYPES := family!.nTYPES + 1; */
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_2 = ElmPRec( a_family, R_nTYPES );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_2 = ElmARecord( a_family, R_nTYPES );
#endif
 }
 else {
  t_2 = ELM_REC( a_family, R_nTYPES );
 }
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  AssPRec( a_family, R_nTYPES, t_1 );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ ) {
  AssARecord( a_family, R_nTYPES, t_1 );
#endif
 }
 else {
  ASS_REC( a_family, R_nTYPES, t_1 );
 }
 
 /* MakeReadOnlyObj( type ); */
 t_1 = GF_MakeReadOnlyObj;
 CALL_1ARGS( t_1, l_type );
 
 /* UNLOCK( lock ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_lock );
 
 /* return type; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), fail, fail ); */
 t_2 = GF_NEW__TYPE;
 t_4 = GF_WITH__IMPS__FLAGS;
 t_6 = GF_AND__FLAGS;
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_7 = ElmPRec( a_family, R_IMP__FLAGS );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_7 = ElmARecord( a_family, R_IMP__FLAGS );
#endif
 }
 else {
  t_7 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 t_4 = GC_fail;
 CHECK_BOUND( t_4, "fail" )
 t_5 = GC_fail;
 CHECK_BOUND( t_5, "fail" )
 t_1 = CALL_5ARGS( t_2, a_typeOfTypes, a_family, t_3, t_4, t_5 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 13 */
static Obj  HdlrFunc13 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_filter,
 Obj  a_data )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), data, fail ); */
 t_2 = GF_NEW__TYPE;
 t_4 = GF_WITH__IMPS__FLAGS;
 t_6 = GF_AND__FLAGS;
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_7 = ElmPRec( a_family, R_IMP__FLAGS );
#ifdef HPCGAP
 } else if ( TNUM_OBJ(a_family) == T_ACOMOBJ) {
  t_7 = ElmARecord( a_family, R_IMP__FLAGS );
#endif
 }
 else {
  t_7 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 t_4 = GC_fail;
 CHECK_BOUND( t_4, "fail" )
 t_1 = CALL_5ARGS( t_2, a_typeOfTypes, a_family, t_3, a_data, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 14 */
static Obj  HdlrFunc14 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_type = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if not IsFamily( arg[1] ) then */
 t_4 = GF_IsFamily;
 C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(1) )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<family> must be a family" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 25, "<family> must be a family" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 2 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* type := NewType3( TypeOfTypes, arg[1], arg[2] ); */
  t_2 = GF_NewType3;
  t_3 = GC_TypeOfTypes;
  CHECK_BOUND( t_3, "TypeOfTypes" )
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(1) )
  C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(2) )
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
  CHECK_FUNC_RESULT( t_1 )
  l_type = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 3 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(3) ));
  if ( t_1 ) {
   
   /* type := NewType4( TypeOfTypes, arg[1], arg[2], arg[3] ); */
   t_2 = GF_NewType4;
   t_3 = GC_TypeOfTypes;
   CHECK_BOUND( t_3, "TypeOfTypes" )
   C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(1) )
   C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(2) )
   C_ELM_LIST_FPL( t_6, a_arg, INTOBJ_INT(3) )
   t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
   CHECK_FUNC_RESULT( t_1 )
   l_type = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "usage: NewType( <family>, <filter> [, <data> ] )" ); */
   t_1 = GF_Error;
   C_NEW_STRING( t_2, 48, "usage: NewType( <family>, <filter> [, <data> ] )" );
   CALL_1ARGS( t_1, t_2 );
   
  }
 }
 /* fi */
 
 /* return type; */
 CHECK_BOUND( l_type, "type" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 15 */
static Obj  HdlrFunc15 (
 Obj  self,
 Obj  a_type,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Obj t_10 = 0;
 Obj t_11 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_TYPE( TypeOfTypes, type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), type![POS_DATA_TYPE], type ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_WITH__IMPS__FLAGS;
 t_8 = GF_AND__FLAGS;
 C_ELM_POSOBJ_NLE( t_9, a_type, 2 );
 t_11 = GF_FLAGS__FILTER;
 t_10 = CALL_1ARGS( t_11, a_filter );
 CHECK_FUNC_RESULT( t_10 )
 t_7 = CALL_2ARGS( t_8, t_9, t_10 );
 CHECK_FUNC_RESULT( t_7 )
 t_5 = CALL_1ARGS( t_6, t_7 );
 CHECK_FUNC_RESULT( t_5 )
 t_7 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_7, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_7 )
 C_ELM_POSOBJ_NLE( t_6, a_type, INT_INTOBJ(t_7) );
 t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, a_type );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 16 */
static Obj  HdlrFunc16 (
 Obj  self,
 Obj  a_type,
 Obj  a_filter,
 Obj  a_data )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Obj t_10 = 0;
 Obj t_11 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_TYPE( TypeOfTypes, type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), data, type ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_WITH__IMPS__FLAGS;
 t_8 = GF_AND__FLAGS;
 C_ELM_POSOBJ_NLE( t_9, a_type, 2 );
 t_11 = GF_FLAGS__FILTER;
 t_10 = CALL_1ARGS( t_11, a_filter );
 CHECK_FUNC_RESULT( t_10 )
 t_7 = CALL_2ARGS( t_8, t_9, t_10 );
 CHECK_FUNC_RESULT( t_7 )
 t_5 = CALL_1ARGS( t_6, t_7 );
 CHECK_FUNC_RESULT( t_5 )
 t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, a_data, a_type );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 17 */
static Obj  HdlrFunc17 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_p = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* p := READ_LOCK( arg ); */
 t_2 = GF_READ__LOCK;
 t_1 = CALL_1ARGS( t_2, a_arg );
 CHECK_FUNC_RESULT( t_1 )
 l_p = t_1;
 
 /* if not IsType( arg[1] ) then */
 t_4 = GF_IsType;
 C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(1) )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 2 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* return Subtype2( arg[1], arg[2] ); */
  t_2 = GF_Subtype2;
  C_ELM_LIST_FPL( t_3, a_arg, INTOBJ_INT(1) )
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(2) )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* return Subtype3( arg[1], arg[2], arg[3] ); */
  t_2 = GF_Subtype3;
  C_ELM_LIST_FPL( t_3, a_arg, INTOBJ_INT(1) )
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(2) )
  C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(3) )
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 /* fi */
 
 /* UNLOCK( p ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_p );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 18 */
static Obj  HdlrFunc18 (
 Obj  self,
 Obj  a_type,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), type![POS_DATA_TYPE], type ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_SUB__FLAGS;
 C_ELM_POSOBJ_NLE( t_7, a_type, 2 );
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_7 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_7, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_7 )
 C_ELM_POSOBJ_NLE( t_6, a_type, INT_INTOBJ(t_7) );
 t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, a_type );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 19 */
static Obj  HdlrFunc19 (
 Obj  self,
 Obj  a_type,
 Obj  a_filter,
 Obj  a_data )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), data, type ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_SUB__FLAGS;
 C_ELM_POSOBJ_NLE( t_7, a_type, 2 );
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, a_data, a_type );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 20 */
static Obj  HdlrFunc20 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if not IsType( arg[1] ) then */
 t_4 = GF_IsType;
 C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(1) )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 2 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* return SupType2( arg[1], arg[2] ); */
  t_2 = GF_SupType2;
  C_ELM_LIST_FPL( t_3, a_arg, INTOBJ_INT(1) )
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(2) )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* return SupType3( arg[1], arg[2], arg[3] ); */
  t_2 = GF_SupType3;
  C_ELM_LIST_FPL( t_3, a_arg, INTOBJ_INT(1) )
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(2) )
  C_ELM_LIST_FPL( t_5, a_arg, INTOBJ_INT(3) )
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 21 */
static Obj  HdlrFunc21 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return K![1]; */
 C_ELM_POSOBJ_NLE( t_1, a_K, 1 );
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 22 */
static Obj  HdlrFunc22 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return K![2]; */
 C_ELM_POSOBJ_NLE( t_1, a_K, 2 );
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 23 */
static Obj  HdlrFunc23 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return K![POS_DATA_TYPE]; */
 t_2 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_2, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_2 )
 C_ELM_POSOBJ_NLE( t_1, a_K, INT_INTOBJ(t_2) );
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 24 */
static Obj  HdlrFunc24 (
 Obj  self,
 Obj  a_K,
 Obj  a_data )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* StrictBindOnce( K, POS_DATA_TYPE, MakeLiteral( data ) ); */
 t_1 = GF_StrictBindOnce;
 t_2 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_2, "POS_DATA_TYPE" )
 t_4 = GF_MakeLiteral;
 t_3 = CALL_1ARGS( t_4, a_data );
 CHECK_FUNC_RESULT( t_3 )
 CALL_3ARGS( t_1, a_K, t_2, t_3 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 25 */
static Obj  HdlrFunc25 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return FlagsType( TypeObj( obj ) ); */
 t_2 = GF_FlagsType;
 t_4 = GF_TypeObj;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 26 */
static Obj  HdlrFunc26 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return DataType( TypeObj( obj ) ); */
 t_2 = GF_DataType;
 t_4 = GF_TypeObj;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 27 */
static Obj  HdlrFunc27 (
 Obj  self,
 Obj  a_type,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if IS_LIST( obj ) then */
 t_3 = GF_IS__LIST;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_REC( obj ) then */
 else {
  t_3 = GF_IS__REC;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, a_type );
   
  }
 }
 /* fi */
 
 /* if not IsNoImmediateMethodsObject( obj ) then */
 t_4 = GF_IsNoImmediateMethodsObject;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* RunImmediateMethods( obj, type![2] ); */
  t_1 = GF_RunImmediateMethods;
  C_ELM_POSOBJ_NLE( t_2, a_type, 2 );
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 /* fi */
 
 /* return obj; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_obj;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 28 */
static Obj  HdlrFunc28 (
 Obj  self,
 Obj  a_type,
 Obj  a_obj )
{
 Obj l_flags = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* flags := FlagsType( type ); */
 t_2 = GF_FlagsType;
 t_1 = CALL_1ARGS( t_2, a_type );
 CHECK_FUNC_RESULT( t_1 )
 l_flags = t_1;
 
 /* if IS_LIST( obj ) then */
 t_3 = GF_IS__LIST;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* if IS_SUBSET_FLAGS( flags, IsAtomicPositionalObjectRepFlags ) then */
  t_3 = GF_IS__SUBSET__FLAGS;
  t_4 = GC_IsAtomicPositionalObjectRepFlags;
  CHECK_BOUND( t_4, "IsAtomicPositionalObjectRepFlags" )
  t_2 = CALL_2ARGS( t_3, l_flags, t_4 );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* FORCE_SWITCH_OBJ( obj, FixedAtomicList( obj ) ); */
   t_1 = GF_FORCE__SWITCH__OBJ;
   t_3 = GF_FixedAtomicList;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  /* fi */
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_REC( obj ) then */
 else {
  t_3 = GF_IS__REC;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* if IS_ATOMIC_RECORD( obj ) then */
   t_3 = GF_IS__ATOMIC__RECORD;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* if IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags ) then */
    t_3 = GF_IS__SUBSET__FLAGS;
    t_4 = GC_IsNonAtomicComponentObjectRepFlags;
    CHECK_BOUND( t_4, "IsNonAtomicComponentObjectRepFlags" )
    t_2 = CALL_2ARGS( t_3, l_flags, t_4 );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* FORCE_SWITCH_OBJ( obj, FromAtomicRecord( obj ) ); */
     t_1 = GF_FORCE__SWITCH__OBJ;
     t_3 = GF_FromAtomicRecord;
     t_2 = CALL_1ARGS( t_3, a_obj );
     CHECK_FUNC_RESULT( t_2 )
     CALL_2ARGS( t_1, a_obj, t_2 );
     
    }
    /* fi */
    
   }
   
   /* elif not IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags ) then */
   else {
    t_4 = GF_IS__SUBSET__FLAGS;
    t_5 = GC_IsNonAtomicComponentObjectRepFlags;
    CHECK_BOUND( t_5, "IsNonAtomicComponentObjectRepFlags" )
    t_3 = CALL_2ARGS( t_4, l_flags, t_5 );
    CHECK_FUNC_RESULT( t_3 )
    CHECK_BOOL( t_3 )
    t_2 = (Obj)(UInt)(t_3 != False);
    t_1 = (Obj)(UInt)( ! ((Int)t_2) );
    if ( t_1 ) {
     
     /* FORCE_SWITCH_OBJ( obj, AtomicRecord( obj ) ); */
     t_1 = GF_FORCE__SWITCH__OBJ;
     t_3 = GF_AtomicRecord;
     t_2 = CALL_1ARGS( t_3, a_obj );
     CHECK_FUNC_RESULT( t_2 )
     CALL_2ARGS( t_1, a_obj, t_2 );
     
    }
   }
   /* fi */
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, a_type );
   
  }
 }
 /* fi */
 
 /* if not IsNoImmediateMethodsObject( obj ) then */
 t_4 = GF_IsNoImmediateMethodsObject;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* RunImmediateMethods( obj, type![2] ); */
  t_1 = GF_RunImmediateMethods;
  C_ELM_POSOBJ_NLE( t_2, a_type, 2 );
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 /* fi */
 
 /* if IsReadOnlyPositionalObjectRep( obj ) then */
 t_3 = GF_IsReadOnlyPositionalObjectRep;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* MakeReadOnlyObj( obj ); */
  t_1 = GF_MakeReadOnlyObj;
  CALL_1ARGS( t_1, a_obj );
  
 }
 /* fi */
 
 /* return obj; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_obj;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 29 */
static Obj  HdlrFunc29 (
 Obj  self,
 Obj  a_type,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, a_type );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, type ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    CALL_2ARGS( t_1, a_obj, a_type );
    
   }
  }
 }
 /* fi */
 
 /* if not IsNoImmediateMethodsObject( obj ) then */
 t_4 = GF_IsNoImmediateMethodsObject;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* RunImmediateMethods( obj, type![2] ); */
  t_1 = GF_RunImmediateMethods;
  C_ELM_POSOBJ_NLE( t_2, a_type, 2 );
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 /* fi */
 
 /* return obj; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_obj;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 30 */
static Obj  HdlrFunc30 (
 Obj  self,
 Obj  a_obj,
 Obj  a_filter )
{
 Obj l_type = 0;
 Obj l_newtype = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* type := TYPE_OBJ( obj ); */
  t_2 = GF_TYPE__OBJ;
  t_1 = CALL_1ARGS( t_2, a_obj );
  CHECK_FUNC_RESULT( t_1 )
  l_type = t_1;
  
  /* newtype := Subtype2( type, filter ); */
  t_2 = GF_Subtype2;
  t_1 = CALL_2ARGS( t_2, l_type, a_filter );
  CHECK_FUNC_RESULT( t_1 )
  l_newtype = t_1;
  
  /* SET_TYPE_POSOBJ( obj, newtype ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, l_newtype );
  
  /* if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj )) then */
  t_4 = GC_IGNORE__IMMEDIATE__METHODS;
  CHECK_BOUND( t_4, "IGNORE_IMMEDIATE_METHODS" )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  t_2 = t_3;
  if ( ! t_2 ) {
   t_6 = GF_IsNoImmediateMethodsObject;
   t_5 = CALL_1ARGS( t_6, a_obj );
   CHECK_FUNC_RESULT( t_5 )
   CHECK_BOOL( t_5 )
   t_4 = (Obj)(UInt)(t_5 != False);
   t_2 = t_4;
  }
  t_1 = (Obj)(UInt)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) ); */
   t_1 = GF_RunImmediateMethods;
   t_3 = GF_SUB__FLAGS;
   C_ELM_POSOBJ_NLE( t_4, l_newtype, 2 );
   C_ELM_POSOBJ_NLE( t_5, l_type, 2 );
   t_2 = CALL_2ARGS( t_3, t_4, t_5 );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  /* fi */
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* type := TYPE_OBJ( obj ); */
   t_2 = GF_TYPE__OBJ;
   t_1 = CALL_1ARGS( t_2, a_obj );
   CHECK_FUNC_RESULT( t_1 )
   l_type = t_1;
   
   /* newtype := Subtype2( type, filter ); */
   t_2 = GF_Subtype2;
   t_1 = CALL_2ARGS( t_2, l_type, a_filter );
   CHECK_FUNC_RESULT( t_1 )
   l_newtype = t_1;
   
   /* SET_TYPE_COMOBJ( obj, newtype ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, l_newtype );
   
   /* if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj )) then */
   t_4 = GC_IGNORE__IMMEDIATE__METHODS;
   CHECK_BOUND( t_4, "IGNORE_IMMEDIATE_METHODS" )
   CHECK_BOOL( t_4 )
   t_3 = (Obj)(UInt)(t_4 != False);
   t_2 = t_3;
   if ( ! t_2 ) {
    t_6 = GF_IsNoImmediateMethodsObject;
    t_5 = CALL_1ARGS( t_6, a_obj );
    CHECK_FUNC_RESULT( t_5 )
    CHECK_BOOL( t_5 )
    t_4 = (Obj)(UInt)(t_5 != False);
    t_2 = t_4;
   }
   t_1 = (Obj)(UInt)( ! ((Int)t_2) );
   if ( t_1 ) {
    
    /* RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) ); */
    t_1 = GF_RunImmediateMethods;
    t_3 = GF_SUB__FLAGS;
    C_ELM_POSOBJ_NLE( t_4, l_newtype, 2 );
    C_ELM_POSOBJ_NLE( t_5, l_type, 2 );
    t_2 = CALL_2ARGS( t_3, t_4, t_5 );
    CHECK_FUNC_RESULT( t_2 )
    CALL_2ARGS( t_1, a_obj, t_2 );
    
   }
   /* fi */
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* type := TYPE_OBJ( obj ); */
    t_2 = GF_TYPE__OBJ;
    t_1 = CALL_1ARGS( t_2, a_obj );
    CHECK_FUNC_RESULT( t_1 )
    l_type = t_1;
    
    /* newtype := Subtype2( type, filter ); */
    t_2 = GF_Subtype2;
    t_1 = CALL_2ARGS( t_2, l_type, a_filter );
    CHECK_FUNC_RESULT( t_1 )
    l_newtype = t_1;
    
    /* SET_TYPE_DATOBJ( obj, newtype ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    CALL_2ARGS( t_1, a_obj, l_newtype );
    
    /* if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj )) then */
    t_4 = GC_IGNORE__IMMEDIATE__METHODS;
    CHECK_BOUND( t_4, "IGNORE_IMMEDIATE_METHODS" )
    CHECK_BOOL( t_4 )
    t_3 = (Obj)(UInt)(t_4 != False);
    t_2 = t_3;
    if ( ! t_2 ) {
     t_6 = GF_IsNoImmediateMethodsObject;
     t_5 = CALL_1ARGS( t_6, a_obj );
     CHECK_FUNC_RESULT( t_5 )
     CHECK_BOOL( t_5 )
     t_4 = (Obj)(UInt)(t_5 != False);
     t_2 = t_4;
    }
    t_1 = (Obj)(UInt)( ! ((Int)t_2) );
    if ( t_1 ) {
     
     /* RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) ); */
     t_1 = GF_RunImmediateMethods;
     t_3 = GF_SUB__FLAGS;
     C_ELM_POSOBJ_NLE( t_4, l_newtype, 2 );
     C_ELM_POSOBJ_NLE( t_5, l_type, 2 );
     t_2 = CALL_2ARGS( t_3, t_4, t_5 );
     CHECK_FUNC_RESULT( t_2 )
     CALL_2ARGS( t_1, a_obj, t_2 );
     
    }
    /* fi */
    
   }
   
   /* elif IS_PLIST_REP( obj ) then */
   else {
    t_3 = GF_IS__PLIST__REP;
    t_2 = CALL_1ARGS( t_3, a_obj );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* SET_FILTER_LIST( obj, filter ); */
     t_1 = GF_SET__FILTER__LIST;
     CALL_2ARGS( t_1, a_obj, a_filter );
     
    }
    
    /* elif IS_STRING_REP( obj ) then */
    else {
     t_3 = GF_IS__STRING__REP;
     t_2 = CALL_1ARGS( t_3, a_obj );
     CHECK_FUNC_RESULT( t_2 )
     CHECK_BOOL( t_2 )
     t_1 = (Obj)(UInt)(t_2 != False);
     if ( t_1 ) {
      
      /* SET_FILTER_LIST( obj, filter ); */
      t_1 = GF_SET__FILTER__LIST;
      CALL_2ARGS( t_1, a_obj, a_filter );
      
     }
     
     /* elif IS_BLIST( obj ) then */
     else {
      t_3 = GF_IS__BLIST;
      t_2 = CALL_1ARGS( t_3, a_obj );
      CHECK_FUNC_RESULT( t_2 )
      CHECK_BOOL( t_2 )
      t_1 = (Obj)(UInt)(t_2 != False);
      if ( t_1 ) {
       
       /* SET_FILTER_LIST( obj, filter ); */
       t_1 = GF_SET__FILTER__LIST;
       CALL_2ARGS( t_1, a_obj, a_filter );
       
      }
      
      /* elif IS_RANGE( obj ) then */
      else {
       t_3 = GF_IS__RANGE;
       t_2 = CALL_1ARGS( t_3, a_obj );
       CHECK_FUNC_RESULT( t_2 )
       CHECK_BOOL( t_2 )
       t_1 = (Obj)(UInt)(t_2 != False);
       if ( t_1 ) {
        
        /* SET_FILTER_LIST( obj, filter ); */
        t_1 = GF_SET__FILTER__LIST;
        CALL_2ARGS( t_1, a_obj, a_filter );
        
       }
       
       /* else */
       else {
        
        /* Error( "cannot set filter for internal object" ); */
        t_1 = GF_Error;
        C_NEW_STRING( t_2, 37, "cannot set filter for internal object" );
        CALL_1ARGS( t_1, t_2 );
        
       }
      }
     }
    }
   }
  }
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 31 */
static Obj  HdlrFunc31 (
 Obj  self,
 Obj  a_obj,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if IS_AND_FILTER( filter ) then */
 t_3 = GF_IS__AND__FILTER;
 t_2 = CALL_1ARGS( t_3, a_filter );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* Error( "You can't reset an \"and-filter\". Reset components individually." ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 63, "You can't reset an \"and-filter\". Reset components individually." );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  t_3 = GF_SupType2;
  t_5 = GF_TYPE__OBJ;
  t_4 = CALL_1ARGS( t_5, a_obj );
  CHECK_FUNC_RESULT( t_4 )
  t_2 = CALL_2ARGS( t_3, t_4, a_filter );
  CHECK_FUNC_RESULT( t_2 )
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   t_3 = GF_SupType2;
   t_5 = GF_TYPE__OBJ;
   t_4 = CALL_1ARGS( t_5, a_obj );
   CHECK_FUNC_RESULT( t_4 )
   t_2 = CALL_2ARGS( t_3, t_4, a_filter );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    t_3 = GF_SupType2;
    t_5 = GF_TYPE__OBJ;
    t_4 = CALL_1ARGS( t_5, a_obj );
    CHECK_FUNC_RESULT( t_4 )
    t_2 = CALL_2ARGS( t_3, t_4, a_filter );
    CHECK_FUNC_RESULT( t_2 )
    CALL_2ARGS( t_1, a_obj, t_2 );
    
   }
   
   /* elif IS_PLIST_REP( obj ) then */
   else {
    t_3 = GF_IS__PLIST__REP;
    t_2 = CALL_1ARGS( t_3, a_obj );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* RESET_FILTER_LIST( obj, filter ); */
     t_1 = GF_RESET__FILTER__LIST;
     CALL_2ARGS( t_1, a_obj, a_filter );
     
    }
    
    /* elif IS_STRING_REP( obj ) then */
    else {
     t_3 = GF_IS__STRING__REP;
     t_2 = CALL_1ARGS( t_3, a_obj );
     CHECK_FUNC_RESULT( t_2 )
     CHECK_BOOL( t_2 )
     t_1 = (Obj)(UInt)(t_2 != False);
     if ( t_1 ) {
      
      /* RESET_FILTER_LIST( obj, filter ); */
      t_1 = GF_RESET__FILTER__LIST;
      CALL_2ARGS( t_1, a_obj, a_filter );
      
     }
     
     /* elif IS_BLIST( obj ) then */
     else {
      t_3 = GF_IS__BLIST;
      t_2 = CALL_1ARGS( t_3, a_obj );
      CHECK_FUNC_RESULT( t_2 )
      CHECK_BOOL( t_2 )
      t_1 = (Obj)(UInt)(t_2 != False);
      if ( t_1 ) {
       
       /* RESET_FILTER_LIST( obj, filter ); */
       t_1 = GF_RESET__FILTER__LIST;
       CALL_2ARGS( t_1, a_obj, a_filter );
       
      }
      
      /* elif IS_RANGE( obj ) then */
      else {
       t_3 = GF_IS__RANGE;
       t_2 = CALL_1ARGS( t_3, a_obj );
       CHECK_FUNC_RESULT( t_2 )
       CHECK_BOOL( t_2 )
       t_1 = (Obj)(UInt)(t_2 != False);
       if ( t_1 ) {
        
        /* RESET_FILTER_LIST( obj, filter ); */
        t_1 = GF_RESET__FILTER__LIST;
        CALL_2ARGS( t_1, a_obj, a_filter );
        
       }
       
       /* else */
       else {
        
        /* Error( "cannot reset filter for internal object" ); */
        t_1 = GF_Error;
        C_NEW_STRING( t_2, 39, "cannot reset filter for internal object" );
        CALL_1ARGS( t_1, t_2 );
        
       }
      }
     }
    }
   }
  }
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 32 */
static Obj  HdlrFunc32 (
 Obj  self,
 Obj  a_obj,
 Obj  a_filter,
 Obj  a_val )
{
 Obj t_1 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if val then */
 CHECK_BOOL( a_val )
 t_1 = (Obj)(UInt)(a_val != False);
 if ( t_1 ) {
  
  /* SetFilterObj( obj, filter ); */
  t_1 = GF_SetFilterObj;
  CALL_2ARGS( t_1, a_obj, a_filter );
  
 }
 
 /* else */
 else {
  
  /* ResetFilterObj( obj, filter ); */
  t_1 = GF_ResetFilterObj;
  CALL_2ARGS( t_1, a_obj, a_filter );
  
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 33 */
static Obj  HdlrFunc33 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_obj = 0;
 Obj l_type = 0;
 Obj l_flags = 0;
 Obj l_attr = 0;
 Obj l_val = 0;
 Obj l_i = 0;
 Obj l_extra = 0;
 Obj l_nfilt = 0;
 Obj l_nflags = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Obj t_10 = 0;
 Obj t_11 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* obj := arg[1]; */
 C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(1) )
 l_obj = t_1;
 
 /* if IsAttributeStoringRep( obj ) then */
 t_3 = GF_IsAttributeStoringRep;
 t_2 = CALL_1ARGS( t_3, l_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* extra := [  ]; */
  t_1 = NEW_PLIST( T_PLIST, 0 );
  SET_LEN_PLIST( t_1, 0 );
  l_extra = t_1;
  
  /* type := TypeObj( obj ); */
  t_2 = GF_TypeObj;
  t_1 = CALL_1ARGS( t_2, l_obj );
  CHECK_FUNC_RESULT( t_1 )
  l_type = t_1;
  
  /* flags := FlagsType( type ); */
  t_2 = GF_FlagsType;
  t_1 = CALL_1ARGS( t_2, l_type );
  CHECK_FUNC_RESULT( t_1 )
  l_flags = t_1;
  
  /* nfilt := IS_OBJECT; */
  t_1 = GC_IS__OBJECT;
  CHECK_BOUND( t_1, "IS_OBJECT" )
  l_nfilt = t_1;
  
  /* for i in [ 2, 4 .. LEN_LIST( arg ) - 1 ] do */
  t_7 = GF_LEN__LIST;
  t_6 = CALL_1ARGS( t_7, a_arg );
  CHECK_FUNC_RESULT( t_6 )
  C_DIFF_FIA( t_5, t_6, INTOBJ_INT(1) )
  t_4 = Range3Check( INTOBJ_INT(2), INTOBJ_INT(4), t_5 );
  if ( IS_SMALL_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_i = t_2;
   
   /* attr := arg[i]; */
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_5, a_arg, l_i )
   l_attr = t_5;
   
   /* val := arg[i + 1]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, a_arg, t_6 )
   l_val = t_5;
   
   /* if 0 <> FLAG1_FILTER( attr ) then */
   t_7 = GF_FLAG1__FILTER;
   t_6 = CALL_1ARGS( t_7, l_attr );
   CHECK_FUNC_RESULT( t_6 )
   t_5 = (Obj)(UInt)( ! EQ( INTOBJ_INT(0), t_6 ));
   if ( t_5 ) {
    
    /* if val then */
    CHECK_BOOL( l_val )
    t_5 = (Obj)(UInt)(l_val != False);
    if ( t_5 ) {
     
     /* nfilt := nfilt and attr; */
     if ( l_nfilt == False ) {
      t_5 = l_nfilt;
     }
     else if ( l_nfilt == True ) {
      CHECK_BOOL( l_attr )
      t_5 = l_attr;
     }
     else {
      CHECK_FUNC( l_nfilt )
      CHECK_FUNC( l_attr )
      t_5 = NewAndFilter( l_nfilt, l_attr );
     }
     l_nfilt = t_5;
     
    }
    
    /* else */
    else {
     
     /* nfilt := nfilt and Tester( attr ); */
     if ( l_nfilt == False ) {
      t_5 = l_nfilt;
     }
     else if ( l_nfilt == True ) {
      t_7 = GF_Tester;
      t_6 = CALL_1ARGS( t_7, l_attr );
      CHECK_FUNC_RESULT( t_6 )
      CHECK_BOOL( t_6 )
      t_5 = t_6;
     }
     else {
      CHECK_FUNC( l_nfilt )
      t_8 = GF_Tester;
      t_7 = CALL_1ARGS( t_8, l_attr );
      CHECK_FUNC_RESULT( t_7 )
      CHECK_FUNC( t_7 )
      t_5 = NewAndFilter( l_nfilt, t_7 );
     }
     l_nfilt = t_5;
     
    }
    /* fi */
    
   }
   
   /* elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2 ) ) <> 12 then */
   else {
    t_7 = GF_LEN__LIST;
    t_9 = GF_METHODS__OPERATION;
    t_11 = GF_Setter;
    t_10 = CALL_1ARGS( t_11, l_attr );
    CHECK_FUNC_RESULT( t_10 )
    t_8 = CALL_2ARGS( t_9, t_10, INTOBJ_INT(2) );
    CHECK_FUNC_RESULT( t_8 )
    t_6 = CALL_1ARGS( t_7, t_8 );
    CHECK_FUNC_RESULT( t_6 )
    t_5 = (Obj)(UInt)( ! EQ( t_6, INTOBJ_INT(12) ));
    if ( t_5 ) {
     
     /* ADD_LIST( extra, attr ); */
     t_5 = GF_ADD__LIST;
     CALL_2ARGS( t_5, l_extra, l_attr );
     
     /* ADD_LIST( extra, val ); */
     t_5 = GF_ADD__LIST;
     CALL_2ARGS( t_5, l_extra, l_val );
     
    }
    
    /* else */
    else {
     
     /* obj!.(NAME_FUNC( attr )) := IMMUTABLE_COPY_OBJ( val ); */
     t_6 = GF_NAME__FUNC;
     t_5 = CALL_1ARGS( t_6, l_attr );
     CHECK_FUNC_RESULT( t_5 )
     t_7 = GF_IMMUTABLE__COPY__OBJ;
     t_6 = CALL_1ARGS( t_7, l_val );
     CHECK_FUNC_RESULT( t_6 )
     if ( TNUM_OBJ(l_obj) == T_COMOBJ ) {
      AssPRec( l_obj, RNamObj(t_5), t_6 );
#ifdef HPCGAP
     } else if ( TNUM_OBJ(l_obj) == T_ACOMOBJ ) {
      AssARecord( l_obj, RNamObj(t_5), t_6 );
#endif
     }
     else {
      ASS_REC( l_obj, RNamObj(t_5), t_6 );
     }
     
     /* nfilt := nfilt and Tester( attr ); */
     if ( l_nfilt == False ) {
      t_5 = l_nfilt;
     }
     else if ( l_nfilt == True ) {
      t_7 = GF_Tester;
      t_6 = CALL_1ARGS( t_7, l_attr );
      CHECK_FUNC_RESULT( t_6 )
      CHECK_BOOL( t_6 )
      t_5 = t_6;
     }
     else {
      CHECK_FUNC( l_nfilt )
      t_8 = GF_Tester;
      t_7 = CALL_1ARGS( t_8, l_attr );
      CHECK_FUNC_RESULT( t_7 )
      CHECK_FUNC( t_7 )
      t_5 = NewAndFilter( l_nfilt, t_7 );
     }
     l_nfilt = t_5;
     
    }
   }
   /* fi */
   
  }
  /* od */
  
  /* nflags := FLAGS_FILTER( nfilt ); */
  t_2 = GF_FLAGS__FILTER;
  t_1 = CALL_1ARGS( t_2, l_nfilt );
  CHECK_FUNC_RESULT( t_1 )
  l_nflags = t_1;
  
  /* if not IS_SUBSET_FLAGS( flags, nflags ) then */
  t_4 = GF_IS__SUBSET__FLAGS;
  t_3 = CALL_2ARGS( t_4, l_flags, l_nflags );
  CHECK_FUNC_RESULT( t_3 )
  CHECK_BOOL( t_3 )
  t_2 = (Obj)(UInt)(t_3 != False);
  t_1 = (Obj)(UInt)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* flags := WITH_IMPS_FLAGS( AND_FLAGS( flags, nflags ) ); */
   t_2 = GF_WITH__IMPS__FLAGS;
   t_4 = GF_AND__FLAGS;
   t_3 = CALL_2ARGS( t_4, l_flags, l_nflags );
   CHECK_FUNC_RESULT( t_3 )
   t_1 = CALL_1ARGS( t_2, t_3 );
   CHECK_FUNC_RESULT( t_1 )
   l_flags = t_1;
   
   /* ChangeTypeObj( NEW_TYPE( TypeOfTypes, FamilyType( type ), flags, DataType( type ) ), obj ); */
   t_1 = GF_ChangeTypeObj;
   t_3 = GF_NEW__TYPE;
   t_4 = GC_TypeOfTypes;
   CHECK_BOUND( t_4, "TypeOfTypes" )
   t_6 = GF_FamilyType;
   t_5 = CALL_1ARGS( t_6, l_type );
   CHECK_FUNC_RESULT( t_5 )
   t_7 = GF_DataType;
   t_6 = CALL_1ARGS( t_7, l_type );
   CHECK_FUNC_RESULT( t_6 )
   t_2 = CALL_4ARGS( t_3, t_4, t_5, l_flags, t_6 );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, t_2, l_obj );
   
  }
  /* fi */
  
  /* for i in [ 2, 4 .. LEN_LIST( extra ) ] do */
  t_6 = GF_LEN__LIST;
  t_5 = CALL_1ARGS( t_6, l_extra );
  CHECK_FUNC_RESULT( t_5 )
  t_4 = Range3Check( INTOBJ_INT(2), INTOBJ_INT(4), t_5 );
  if ( IS_SMALL_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_i = t_2;
   
   /* Setter( extra[i - 1] )( obj, extra[i] ); */
   t_6 = GF_Setter;
   C_DIFF_FIA( t_8, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_extra, t_8 )
   t_5 = CALL_1ARGS( t_6, t_7 );
   CHECK_FUNC_RESULT( t_5 )
   CHECK_FUNC( t_5 )
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_6, l_extra, l_i )
   CALL_2ARGS( t_5, l_obj, t_6 );
   
  }
  /* od */
  
 }
 
 /* else */
 else {
  
  /* extra := arg; */
  l_extra = a_arg;
  
  /* for i in [ 2, 4 .. LEN_LIST( extra ) ] do */
  t_6 = GF_LEN__LIST;
  t_5 = CALL_1ARGS( t_6, l_extra );
  CHECK_FUNC_RESULT( t_5 )
  t_4 = Range3Check( INTOBJ_INT(2), INTOBJ_INT(4), t_5 );
  if ( IS_SMALL_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_i = t_2;
   
   /* Setter( extra[i] )( obj, extra[i + 1] ); */
   t_6 = GF_Setter;
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_7, l_extra, l_i )
   t_5 = CALL_1ARGS( t_6, t_7 );
   CHECK_FUNC_RESULT( t_5 )
   CHECK_FUNC( t_5 )
   C_SUM_FIA( t_7, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_7 )
   C_ELM_LIST_FPL( t_6, l_extra, t_7 )
   CALL_2ARGS( t_5, l_obj, t_6 );
   
  }
  /* od */
  
 }
 /* fi */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 34 */
static Obj  HdlrFunc34 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_obj = 0;
 Obj l_type = 0;
 Obj l_flags = 0;
 Obj l_attr = 0;
 Obj l_val = 0;
 Obj l_i = 0;
 Obj l_extra = 0;
 Obj l_nflags = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Obj t_10 = 0;
 Obj t_11 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* obj := arg[1]; */
 C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(1) )
 l_obj = t_1;
 
 /* type := arg[2]; */
 C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(2) )
 l_type = t_1;
 
 /* flags := FlagsType( type ); */
 t_2 = GF_FlagsType;
 t_1 = CALL_1ARGS( t_2, l_type );
 CHECK_FUNC_RESULT( t_1 )
 l_flags = t_1;
 
 /* extra := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 l_extra = t_1;
 
 /* if not IS_SUBSET_FLAGS( flags, IsAttributeStoringRepFlags ) then */
 t_4 = GF_IS__SUBSET__FLAGS;
 t_5 = GC_IsAttributeStoringRepFlags;
 CHECK_BOUND( t_5, "IsAttributeStoringRepFlags" )
 t_3 = CALL_2ARGS( t_4, l_flags, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* extra := arg{[ 3 .. LEN_LIST( arg ) ]}; */
  t_4 = GF_LEN__LIST;
  t_3 = CALL_1ARGS( t_4, a_arg );
  CHECK_FUNC_RESULT( t_3 )
  t_2 = Range2Check( INTOBJ_INT(3), t_3 );
  t_1 = ElmsListCheck( a_arg, t_2 );
  l_extra = t_1;
  
  /* INFO_OWA( "#W ObjectifyWithAttributes called ", "for non-attribute storing rep\n" ); */
  t_1 = GF_INFO__OWA;
  C_NEW_STRING( t_2, 34, "#W ObjectifyWithAttributes called " );
  C_NEW_STRING( t_3, 30, "for non-attribute storing rep\n" );
  CALL_2ARGS( t_1, t_2, t_3 );
  
  /* Objectify( type, obj ); */
  t_1 = GF_Objectify;
  CALL_2ARGS( t_1, l_type, l_obj );
  
 }
 
 /* else */
 else {
  
  /* nflags := EMPTY_FLAGS; */
  t_1 = GC_EMPTY__FLAGS;
  CHECK_BOUND( t_1, "EMPTY_FLAGS" )
  l_nflags = t_1;
  
  /* for i in [ 3, 5 .. LEN_LIST( arg ) - 1 ] do */
  t_7 = GF_LEN__LIST;
  t_6 = CALL_1ARGS( t_7, a_arg );
  CHECK_FUNC_RESULT( t_6 )
  C_DIFF_FIA( t_5, t_6, INTOBJ_INT(1) )
  t_4 = Range3Check( INTOBJ_INT(3), INTOBJ_INT(5), t_5 );
  if ( IS_SMALL_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_i = t_2;
   
   /* attr := arg[i]; */
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_5, a_arg, l_i )
   l_attr = t_5;
   
   /* val := arg[i + 1]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, a_arg, t_6 )
   l_val = t_5;
   
   /* if 0 <> FLAG1_FILTER( attr ) then */
   t_7 = GF_FLAG1__FILTER;
   t_6 = CALL_1ARGS( t_7, l_attr );
   CHECK_FUNC_RESULT( t_6 )
   t_5 = (Obj)(UInt)( ! EQ( INTOBJ_INT(0), t_6 ));
   if ( t_5 ) {
    
    /* if val then */
    CHECK_BOOL( l_val )
    t_5 = (Obj)(UInt)(l_val != False);
    if ( t_5 ) {
     
     /* nflags := AND_FLAGS( nflags, FLAGS_FILTER( attr ) ); */
     t_6 = GF_AND__FLAGS;
     t_8 = GF_FLAGS__FILTER;
     t_7 = CALL_1ARGS( t_8, l_attr );
     CHECK_FUNC_RESULT( t_7 )
     t_5 = CALL_2ARGS( t_6, l_nflags, t_7 );
     CHECK_FUNC_RESULT( t_5 )
     l_nflags = t_5;
     
    }
    
    /* else */
    else {
     
     /* nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) ); */
     t_6 = GF_AND__FLAGS;
     t_8 = GF_FLAGS__FILTER;
     t_10 = GF_Tester;
     t_9 = CALL_1ARGS( t_10, l_attr );
     CHECK_FUNC_RESULT( t_9 )
     t_7 = CALL_1ARGS( t_8, t_9 );
     CHECK_FUNC_RESULT( t_7 )
     t_5 = CALL_2ARGS( t_6, l_nflags, t_7 );
     CHECK_FUNC_RESULT( t_5 )
     l_nflags = t_5;
     
    }
    /* fi */
    
   }
   
   /* elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2 ) ) <> LENGTH_SETTER_METHODS_2 then */
   else {
    t_7 = GF_LEN__LIST;
    t_9 = GF_METHODS__OPERATION;
    t_11 = GF_Setter;
    t_10 = CALL_1ARGS( t_11, l_attr );
    CHECK_FUNC_RESULT( t_10 )
    t_8 = CALL_2ARGS( t_9, t_10, INTOBJ_INT(2) );
    CHECK_FUNC_RESULT( t_8 )
    t_6 = CALL_1ARGS( t_7, t_8 );
    CHECK_FUNC_RESULT( t_6 )
    t_7 = GC_LENGTH__SETTER__METHODS__2;
    CHECK_BOUND( t_7, "LENGTH_SETTER_METHODS_2" )
    t_5 = (Obj)(UInt)( ! EQ( t_6, t_7 ));
    if ( t_5 ) {
     
     /* ADD_LIST( extra, attr ); */
     t_5 = GF_ADD__LIST;
     CALL_2ARGS( t_5, l_extra, l_attr );
     
     /* ADD_LIST( extra, val ); */
     t_5 = GF_ADD__LIST;
     CALL_2ARGS( t_5, l_extra, l_val );
     
    }
    
    /* else */
    else {
     
     /* obj.(NAME_FUNC( attr )) := IMMUTABLE_COPY_OBJ( val ); */
     t_6 = GF_NAME__FUNC;
     t_5 = CALL_1ARGS( t_6, l_attr );
     CHECK_FUNC_RESULT( t_5 )
     t_7 = GF_IMMUTABLE__COPY__OBJ;
     t_6 = CALL_1ARGS( t_7, l_val );
     CHECK_FUNC_RESULT( t_6 )
     ASS_REC( l_obj, RNamObj(t_5), t_6 );
     
     /* nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) ); */
     t_6 = GF_AND__FLAGS;
     t_8 = GF_FLAGS__FILTER;
     t_10 = GF_Tester;
     t_9 = CALL_1ARGS( t_10, l_attr );
     CHECK_FUNC_RESULT( t_9 )
     t_7 = CALL_1ARGS( t_8, t_9 );
     CHECK_FUNC_RESULT( t_7 )
     t_5 = CALL_2ARGS( t_6, l_nflags, t_7 );
     CHECK_FUNC_RESULT( t_5 )
     l_nflags = t_5;
     
    }
   }
   /* fi */
   
  }
  /* od */
  
  /* if not IS_SUBSET_FLAGS( flags, nflags ) then */
  t_4 = GF_IS__SUBSET__FLAGS;
  t_3 = CALL_2ARGS( t_4, l_flags, l_nflags );
  CHECK_FUNC_RESULT( t_3 )
  CHECK_BOOL( t_3 )
  t_2 = (Obj)(UInt)(t_3 != False);
  t_1 = (Obj)(UInt)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* flags := WITH_IMPS_FLAGS( AND_FLAGS( flags, nflags ) ); */
   t_2 = GF_WITH__IMPS__FLAGS;
   t_4 = GF_AND__FLAGS;
   t_3 = CALL_2ARGS( t_4, l_flags, l_nflags );
   CHECK_FUNC_RESULT( t_3 )
   t_1 = CALL_1ARGS( t_2, t_3 );
   CHECK_FUNC_RESULT( t_1 )
   l_flags = t_1;
   
   /* Objectify( NEW_TYPE( TypeOfTypes, FamilyType( type ), flags, DataType( type ), fail ), obj ); */
   t_1 = GF_Objectify;
   t_3 = GF_NEW__TYPE;
   t_4 = GC_TypeOfTypes;
   CHECK_BOUND( t_4, "TypeOfTypes" )
   t_6 = GF_FamilyType;
   t_5 = CALL_1ARGS( t_6, l_type );
   CHECK_FUNC_RESULT( t_5 )
   t_7 = GF_DataType;
   t_6 = CALL_1ARGS( t_7, l_type );
   CHECK_FUNC_RESULT( t_6 )
   t_7 = GC_fail;
   CHECK_BOUND( t_7, "fail" )
   t_2 = CALL_5ARGS( t_3, t_4, t_5, l_flags, t_6, t_7 );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, t_2, l_obj );
   
  }
  
  /* else */
  else {
   
   /* Objectify( type, obj ); */
   t_1 = GF_Objectify;
   CALL_2ARGS( t_1, l_type, l_obj );
   
  }
  /* fi */
  
 }
 /* fi */
 
 /* for i in [ 1, 3 .. LEN_LIST( extra ) - 1 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_extra );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(1) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(3), t_5 );
 if ( IS_SMALL_LIST(t_4) ) {
  t_3 = (Obj)(UInt)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)(UInt)0;
  t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
 }
 while ( 1 ) {
  if ( t_3 ) {
   if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
   t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
   t_1 = (Obj)(((UInt)t_1)+4);
   if ( t_2 == 0 )  continue;
  }
  else {
   if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
   t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
  }
  l_i = t_2;
  
  /* if Tester( extra[i] )( obj ) then */
  t_8 = GF_Tester;
  CHECK_INT_POS( l_i )
  C_ELM_LIST_FPL( t_9, l_extra, l_i )
  t_7 = CALL_1ARGS( t_8, t_9 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_FUNC( t_7 )
  t_6 = CALL_1ARGS( t_7, l_obj );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* INFO_OWA( "#W  Supplied type has tester of ", NAME_FUNC( extra[i] ), "with non-standard setter\n" ); */
   t_5 = GF_INFO__OWA;
   C_NEW_STRING( t_6, 32, "#W  Supplied type has tester of " );
   t_8 = GF_NAME__FUNC;
   C_ELM_LIST_FPL( t_9, l_extra, l_i )
   t_7 = CALL_1ARGS( t_8, t_9 );
   CHECK_FUNC_RESULT( t_7 )
   C_NEW_STRING( t_8, 25, "with non-standard setter\n" );
   CALL_3ARGS( t_5, t_6, t_7, t_8 );
   
   /* ResetFilterObj( obj, Tester( extra[i] ) ); */
   t_5 = GF_ResetFilterObj;
   t_7 = GF_Tester;
   C_ELM_LIST_FPL( t_8, l_extra, l_i )
   t_6 = CALL_1ARGS( t_7, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CALL_2ARGS( t_5, l_obj, t_6 );
   
  }
  /* fi */
  
  /* Setter( extra[i] )( obj, extra[i + 1] ); */
  t_6 = GF_Setter;
  C_ELM_LIST_FPL( t_7, l_extra, l_i )
  t_5 = CALL_1ARGS( t_6, t_7 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_FUNC( t_5 )
  C_SUM_FIA( t_7, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_7 )
  C_ELM_LIST_FPL( t_6, l_extra, t_7 )
  CALL_2ARGS( t_5, l_obj, t_6 );
  
 }
 /* od */
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 1 */
static Obj  HdlrFunc1 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* InstallAttributeFunction( function ( name, filter, getter, setter, tester, mutflag )
      InstallOtherMethod( getter, "system getter", true, [ IsAttributeStoringRep and tester ], GETTER_FLAGS, GETTER_FUNCTION( name ) );
      return;
  end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2 );
 ENVI_FUNC( t_2 ) = STATE(CurrLVars);
 t_3 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_3, INTOBJ_INT(19));
 SET_ENDLINE_BODY(t_3, INTOBJ_INT(26));
 SET_FILENAME_BODY(t_3, FileName);
 BODY_FUNC(t_2) = t_3;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_1ARGS( t_1, t_2 );
 
 /* LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + 6; */
 t_2 = GC_LENGTH__SETTER__METHODS__2;
 CHECK_BOUND( t_2, "LENGTH_SETTER_METHODS_2" )
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(6) )
 AssGVar( G_LENGTH__SETTER__METHODS__2, t_1 );
 
 /* InstallAttributeFunction( function ( name, filter, getter, setter, tester, mutflag )
      if mutflag  then
          InstallOtherMethod( setter, "system mutable setter", true, [ IsAttributeStoringRep, IS_OBJECT ], 0, function ( obj, val )
                obj!.(name) := val;
                SetFilterObj( obj, tester );
                return;
            end );
      else
          InstallOtherMethod( setter, "system setter", true, [ IsAttributeStoringRep, IS_OBJECT ], 0, SETTER_FUNCTION( name, tester ) );
      fi;
      return;
  end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3 );
 ENVI_FUNC( t_2 ) = STATE(CurrLVars);
 t_3 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_3, INTOBJ_INT(31));
 SET_ENDLINE_BODY(t_3, INTOBJ_INT(52));
 SET_FILENAME_BODY(t_3, FileName);
 BODY_FUNC(t_2) = t_3;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_1ARGS( t_1, t_2 );
 
 /* Subtype := "defined below"; */
 C_NEW_STRING( t_1, 13, "defined below" );
 AssGVar( G_Subtype, t_1 );
 
 /* DS_TYPE_CACHE := ShareSpecialObj( [  ] ); */
 t_2 = GF_ShareSpecialObj;
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 AssGVar( G_DS__TYPE__CACHE, t_1 );
 
 /* BIND_GLOBAL( "NEW_FAMILY", function ( typeOfFamilies, name, req_filter, imp_filter )
      local  lock, type, pair, family;
      imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) );
      type := Subtype( typeOfFamilies, IsAttributeStoringRep );
      lock := READ_LOCK( CATEGORIES_FAMILY );
      for pair  in CATEGORIES_FAMILY  do
          if IS_SUBSET_FLAGS( imp_filter, pair[1] )  then
              type := Subtype( type, pair[2] );
          fi;
      od;
      UNLOCK( lock );
      family := AtomicRecord(  );
      SET_TYPE_COMOBJ( family, type );
      family!.NAME := MakeImmutable( name );
      family!.REQ_FLAGS := req_filter;
      family!.IMP_FLAGS := imp_filter;
      lock := WRITE_LOCK( DS_TYPE_CACHE );
      family!.TYPES := MIGRATE_RAW( [  ], DS_TYPE_CACHE );
      UNLOCK( lock );
      family!.nTYPES := 0;
      family!.HASH_SIZE := 32;
      family!.TYPES_LIST_FAM := MakeWriteOnceAtomic( AtomicList( 27 ) );
      return family;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NEW_FAMILY" );
 t_3 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(90));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(120));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily2", function ( typeOfFamilies, name )
      return NEW_FAMILY( typeOfFamilies, name, EMPTY_FLAGS, EMPTY_FLAGS );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily2" );
 t_3 = NewFunction( NameFunc[6], NargFunc[6], NamsFunc[6], HdlrFunc6 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(123));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(128));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily3", function ( typeOfFamilies, name, req )
      return NEW_FAMILY( typeOfFamilies, name, FLAGS_FILTER( req ), EMPTY_FLAGS );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily3" );
 t_3 = NewFunction( NameFunc[7], NargFunc[7], NamsFunc[7], HdlrFunc7 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(131));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(136));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily4", function ( typeOfFamilies, name, req, imp )
      return NEW_FAMILY( typeOfFamilies, name, FLAGS_FILTER( req ), FLAGS_FILTER( imp ) );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily4" );
 t_3 = NewFunction( NameFunc[8], NargFunc[8], NamsFunc[8], HdlrFunc8 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(139));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(144));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily5", function ( typeOfFamilies, name, req, imp, filter )
      return NEW_FAMILY( Subtype( typeOfFamilies, filter ), name, FLAGS_FILTER( req ), FLAGS_FILTER( imp ) );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily5" );
 t_3 = NewFunction( NameFunc[9], NargFunc[9], NamsFunc[9], HdlrFunc9 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(148));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(153));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily", function ( arg... )
      if LEN_LIST( arg ) = 1  then
          return NewFamily2( TypeOfFamilies, arg[1] );
      elif LEN_LIST( arg ) = 2  then
          return NewFamily3( TypeOfFamilies, arg[1], arg[2] );
      elif LEN_LIST( arg ) = 3  then
          return NewFamily4( TypeOfFamilies, arg[1], arg[2], arg[3] );
      elif LEN_LIST( arg ) = 4  then
          return NewFamily5( TypeOfFamilies, arg[1], arg[2], arg[3], arg[4] );
      else
          Error( "usage: NewFamily( <name>, [ <req> [, <imp> ]] )" );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "NewFamily" );
 t_3 = NewFunction( NameFunc[10], NargFunc[10], NamsFunc[10], HdlrFunc10 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(156));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(179));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* NEW_TYPE_CACHE_MISS := 0; */
 AssGVar( G_NEW__TYPE__CACHE__MISS, INTOBJ_INT(0) );
 
 /* NEW_TYPE_CACHE_HIT := 0; */
 AssGVar( G_NEW__TYPE__CACHE__HIT, INTOBJ_INT(0) );
 
 /* BIND_GLOBAL( "NEW_TYPE", function ( typeOfTypes, family, flags, data, parent )
      local  lock, hash, cache, cached, type, ncache, ncl, t, i, match;
      lock := WRITE_LOCK( DS_TYPE_CACHE );
      cache := family!.TYPES;
      hash := HASH_FLAGS( flags ) mod family!.HASH_SIZE + 1;
      if IsBound( cache[hash] )  then
          cached := cache[hash];
          if IS_EQUAL_FLAGS( flags, cached![2] )  then
              flags := cached![2];
              if IS_IDENTICAL_OBJ( data, cached![POS_DATA_TYPE] ) and IS_IDENTICAL_OBJ( typeOfTypes, TYPE_OBJ( cached ) )  then
                  if IS_IDENTICAL_OBJ( parent, fail ) and LEN_POSOBJ( cached ) = POS_FIRST_FREE_TYPE - 1  then
                      NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1;
                      UNLOCK( lock );
                      return cached;
                  fi;
                  if LEN_POSOBJ( parent ) = LEN_POSOBJ( cached )  then
                      match := true;
                      for i  in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( parent ) ]  do
                          if IsBound( parent![i]) <> IsBound( cached![i])  then
                              match := false;
                              break;
                          fi;
                          if IsBound( parent![i]) and IsBound( cached![i]) and not IS_IDENTICAL_OBJ( parent![i], cached![i] )  then
                              match := false;
                              break;
                          fi;
                      od;
                      if match  then
                          NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1;
                          UNLOCK( lock );
                          return cached;
                      fi;
                  fi;
              fi;
          fi;
          NEW_TYPE_CACHE_MISS := NEW_TYPE_CACHE_MISS + 1;
      fi;
      NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1;
      if NEW_TYPE_NEXT_ID >= NEW_TYPE_ID_LIMIT  then
          GASMAN( "collect" );
          FLUSH_ALL_METHOD_CACHES(  );
          NEW_TYPE_NEXT_ID := COMPACT_TYPE_IDS(  );
      fi;
      type := [ family, flags ];
      type[POS_DATA_TYPE] := MakeReadOnly( data );
      type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID;
      if not IS_IDENTICAL_OBJ( parent, fail )  then
          for i  in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( parent ) ]  do
              if IsBound( parent![i]) and not IsBound( type[i] )  then
                  type[i] := parent![i];
              fi;
          od;
      fi;
      SET_TYPE_POSOBJ( type, typeOfTypes );
      if 3 * family!.nTYPES > family!.HASH_SIZE  then
          ncache := MIGRATE_RAW( [  ], DS_TYPE_CACHE );
          ncl := 3 * family!.HASH_SIZE + 1;
          for t  in cache  do
              ncache[HASH_FLAGS( t![2] ) mod ncl + 1] := t;
          od;
          family!.HASH_SIZE := ncl;
          family!.TYPES := ncache;
          ncache[HASH_FLAGS( flags ) mod ncl + 1] := type;
      else
          cache[hash] := type;
      fi;
      family!.nTYPES := family!.nTYPES + 1;
      MakeReadOnlyObj( type );
      UNLOCK( lock );
      return type;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NEW_TYPE" );
 t_3 = NewFunction( NameFunc[11], NargFunc[11], NamsFunc[11], HdlrFunc11 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(207));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(296));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType3", function ( typeOfTypes, family, filter )
      return NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), fail, fail );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NewType3" );
 t_3 = NewFunction( NameFunc[12], NargFunc[12], NamsFunc[12], HdlrFunc12 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(300));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(307));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType4", function ( typeOfTypes, family, filter, data )
      return NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), data, fail );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NewType4" );
 t_3 = NewFunction( NameFunc[13], NargFunc[13], NamsFunc[13], HdlrFunc13 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(310));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(317));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType", function ( arg... )
      local  type;
      if not IsFamily( arg[1] )  then
          Error( "<family> must be a family" );
      fi;
      if LEN_LIST( arg ) = 2  then
          type := NewType3( TypeOfTypes, arg[1], arg[2] );
      elif LEN_LIST( arg ) = 3  then
          type := NewType4( TypeOfTypes, arg[1], arg[2], arg[3] );
      else
          Error( "usage: NewType( <family>, <filter> [, <data> ] )" );
      fi;
      return type;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "NewType" );
 t_3 = NewFunction( NameFunc[14], NargFunc[14], NamsFunc[14], HdlrFunc14 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(320));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(344));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "Subtype2", function ( type, filter )
      return NEW_TYPE( TypeOfTypes, type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), type![POS_DATA_TYPE], type );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "Subtype2" );
 t_3 = NewFunction( NameFunc[15], NargFunc[15], NamsFunc[15], HdlrFunc15 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(357));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(364));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "Subtype3", function ( type, filter, data )
      return NEW_TYPE( TypeOfTypes, type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), data, type );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "Subtype3" );
 t_3 = NewFunction( NameFunc[16], NargFunc[16], NamsFunc[16], HdlrFunc16 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(367));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(374));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Unbind( Subtype ); */
 AssGVar( G_Subtype, 0 );
 
 /* BIND_GLOBAL( "Subtype", function ( arg... )
      local  p;
      p := READ_LOCK( arg );
      if not IsType( arg[1] )  then
          Error( "<type> must be a type" );
      fi;
      if LEN_LIST( arg ) = 2  then
          return Subtype2( arg[1], arg[2] );
      else
          return Subtype3( arg[1], arg[2], arg[3] );
      fi;
      UNLOCK( p );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "Subtype" );
 t_3 = NewFunction( NameFunc[17], NargFunc[17], NamsFunc[17], HdlrFunc17 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(378));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(393));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SupType2", function ( type, filter )
      return NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), type![POS_DATA_TYPE], type );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "SupType2" );
 t_3 = NewFunction( NameFunc[18], NargFunc[18], NamsFunc[18], HdlrFunc18 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(407));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(414));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SupType3", function ( type, filter, data )
      return NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), data, type );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "SupType3" );
 t_3 = NewFunction( NameFunc[19], NargFunc[19], NamsFunc[19], HdlrFunc19 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(417));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(424));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SupType", function ( arg... )
      if not IsType( arg[1] )  then
          Error( "<type> must be a type" );
      fi;
      if LEN_LIST( arg ) = 2  then
          return SupType2( arg[1], arg[2] );
      else
          return SupType3( arg[1], arg[2], arg[3] );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "SupType" );
 t_3 = NewFunction( NameFunc[20], NargFunc[20], NamsFunc[20], HdlrFunc20 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(427));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(441));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FamilyType", function ( K )
      return K![1];
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "FamilyType" );
 t_3 = NewFunction( NameFunc[21], NargFunc[21], NamsFunc[21], HdlrFunc21 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(455));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(455));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FlagsType", function ( K )
      return K![2];
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "FlagsType" );
 t_3 = NewFunction( NameFunc[22], NargFunc[22], NamsFunc[22], HdlrFunc22 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(469));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(469));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DataType", function ( K )
      return K![POS_DATA_TYPE];
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "DataType" );
 t_3 = NewFunction( NameFunc[23], NargFunc[23], NamsFunc[23], HdlrFunc23 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(485));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(485));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetDataType", function ( K, data )
      StrictBindOnce( K, POS_DATA_TYPE, MakeLiteral( data ) );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "SetDataType" );
 t_3 = NewFunction( NameFunc[24], NargFunc[24], NamsFunc[24], HdlrFunc24 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(487));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(489));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "TypeObj", TYPE_OBJ ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "TypeObj" );
 t_3 = GC_TYPE__OBJ;
 CHECK_BOUND( t_3, "TYPE_OBJ" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FamilyObj", FAMILY_OBJ ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "FamilyObj" );
 t_3 = GC_FAMILY__OBJ;
 CHECK_BOUND( t_3, "FAMILY_OBJ" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FlagsObj", function ( obj )
      return FlagsType( TypeObj( obj ) );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "FlagsObj" );
 t_3 = NewFunction( NameFunc[25], NargFunc[25], NamsFunc[25], HdlrFunc25 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(588));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(588));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DataObj", function ( obj )
      return DataType( TypeObj( obj ) );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "DataObj" );
 t_3 = NewFunction( NameFunc[26], NargFunc[26], NamsFunc[26], HdlrFunc26 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(602));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(602));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetTypeObj", function ( type, obj )
      if not IsType( type )  then
          Error( "<type> must be a type" );
      fi;
      if IS_LIST( obj )  then
          SET_TYPE_POSOBJ( obj, type );
      elif IS_REC( obj )  then
          SET_TYPE_COMOBJ( obj, type );
      fi;
      if not IsNoImmediateMethodsObject( obj )  then
          RunImmediateMethods( obj, type![2] );
      fi;
      return obj;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "SetTypeObj" );
 t_3 = NewFunction( NameFunc[27], NargFunc[27], NamsFunc[27], HdlrFunc27 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(616));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(629));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "IsNonAtomicComponentObjectRepFlags", FLAGS_FILTER( IsNonAtomicComponentObjectRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 34, "IsNonAtomicComponentObjectRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsNonAtomicComponentObjectRep;
 CHECK_BOUND( t_5, "IsNonAtomicComponentObjectRep" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "IsAtomicPositionalObjectRepFlags", FLAGS_FILTER( IsAtomicPositionalObjectRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 32, "IsAtomicPositionalObjectRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsAtomicPositionalObjectRep;
 CHECK_BOUND( t_5, "IsAtomicPositionalObjectRep" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "IsReadOnlyPositionalObjectRepFlags", FLAGS_FILTER( IsReadOnlyPositionalObjectRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 34, "IsReadOnlyPositionalObjectRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsReadOnlyPositionalObjectRep;
 CHECK_BOUND( t_5, "IsReadOnlyPositionalObjectRep" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "Objectify", function ( type, obj )
      local  flags;
      if not IsType( type )  then
          Error( "<type> must be a type" );
      fi;
      flags := FlagsType( type );
      if IS_LIST( obj )  then
          if IS_SUBSET_FLAGS( flags, IsAtomicPositionalObjectRepFlags )  then
              FORCE_SWITCH_OBJ( obj, FixedAtomicList( obj ) );
          fi;
          SET_TYPE_POSOBJ( obj, type );
      elif IS_REC( obj )  then
          if IS_ATOMIC_RECORD( obj )  then
              if IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags )  then
                  FORCE_SWITCH_OBJ( obj, FromAtomicRecord( obj ) );
              fi;
          elif not IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags )  then
              FORCE_SWITCH_OBJ( obj, AtomicRecord( obj ) );
          fi;
          SET_TYPE_COMOBJ( obj, type );
      fi;
      if not IsNoImmediateMethodsObject( obj )  then
          RunImmediateMethods( obj, type![2] );
      fi;
      if IsReadOnlyPositionalObjectRep( obj )  then
          MakeReadOnlyObj( obj );
      fi;
      return obj;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "Objectify" );
 t_3 = NewFunction( NameFunc[28], NargFunc[28], NamsFunc[28], HdlrFunc28 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(639));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(668));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "ChangeTypeObj", function ( type, obj )
      if not IsType( type )  then
          Error( "<type> must be a type" );
      fi;
      if IS_POSOBJ( obj )  then
          SET_TYPE_POSOBJ( obj, type );
      elif IS_COMOBJ( obj )  then
          SET_TYPE_COMOBJ( obj, type );
      elif IS_DATOBJ( obj )  then
          SET_TYPE_DATOBJ( obj, type );
      fi;
      if not IsNoImmediateMethodsObject( obj )  then
          RunImmediateMethods( obj, type![2] );
      fi;
      return obj;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "ChangeTypeObj" );
 t_3 = NewFunction( NameFunc[29], NargFunc[29], NamsFunc[29], HdlrFunc29 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(682));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(697));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "ReObjectify", ChangeTypeObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "ReObjectify" );
 t_3 = GC_ChangeTypeObj;
 CHECK_BOUND( t_3, "ChangeTypeObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Unbind( SetFilterObj ); */
 AssGVar( G_SetFilterObj, 0 );
 
 /* BIND_GLOBAL( "SetFilterObj", function ( obj, filter )
      local  type, newtype;
      if IS_POSOBJ( obj )  then
          type := TYPE_OBJ( obj );
          newtype := Subtype2( type, filter );
          SET_TYPE_POSOBJ( obj, newtype );
          if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj ))  then
              RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) );
          fi;
      elif IS_COMOBJ( obj )  then
          type := TYPE_OBJ( obj );
          newtype := Subtype2( type, filter );
          SET_TYPE_COMOBJ( obj, newtype );
          if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj ))  then
              RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) );
          fi;
      elif IS_DATOBJ( obj )  then
          type := TYPE_OBJ( obj );
          newtype := Subtype2( type, filter );
          SET_TYPE_DATOBJ( obj, newtype );
          if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj ))  then
              RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) );
          fi;
      elif IS_PLIST_REP( obj )  then
          SET_FILTER_LIST( obj, filter );
      elif IS_STRING_REP( obj )  then
          SET_FILTER_LIST( obj, filter );
      elif IS_BLIST( obj )  then
          SET_FILTER_LIST( obj, filter );
      elif IS_RANGE( obj )  then
          SET_FILTER_LIST( obj, filter );
      else
          Error( "cannot set filter for internal object" );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 12, "SetFilterObj" );
 t_3 = NewFunction( NameFunc[30], NargFunc[30], NamsFunc[30], HdlrFunc30 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(721));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(759));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SET_FILTER_OBJ", SetFilterObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 14, "SET_FILTER_OBJ" );
 t_3 = GC_SetFilterObj;
 CHECK_BOUND( t_3, "SetFilterObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "ResetFilterObj", function ( obj, filter )
      if IS_AND_FILTER( filter )  then
          Error( "You can't reset an \"and-filter\". Reset components individually." );
      fi;
      if IS_POSOBJ( obj )  then
          SET_TYPE_POSOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) );
      elif IS_COMOBJ( obj )  then
          SET_TYPE_COMOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) );
      elif IS_DATOBJ( obj )  then
          SET_TYPE_DATOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) );
      elif IS_PLIST_REP( obj )  then
          RESET_FILTER_LIST( obj, filter );
      elif IS_STRING_REP( obj )  then
          RESET_FILTER_LIST( obj, filter );
      elif IS_BLIST( obj )  then
          RESET_FILTER_LIST( obj, filter );
      elif IS_RANGE( obj )  then
          RESET_FILTER_LIST( obj, filter );
      else
          Error( "cannot reset filter for internal object" );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 14, "ResetFilterObj" );
 t_3 = NewFunction( NameFunc[31], NargFunc[31], NamsFunc[31], HdlrFunc31 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(781));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(803));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "RESET_FILTER_OBJ", ResetFilterObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 16, "RESET_FILTER_OBJ" );
 t_3 = GC_ResetFilterObj;
 CHECK_BOUND( t_3, "ResetFilterObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetFeatureObj", function ( obj, filter, val )
      if val  then
          SetFilterObj( obj, filter );
      else
          ResetFilterObj( obj, filter );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "SetFeatureObj" );
 t_3 = NewFunction( NameFunc[32], NargFunc[32], NamsFunc[32], HdlrFunc32 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(819));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(825));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetMultipleAttributes", function ( arg... )
      local  obj, type, flags, attr, val, i, extra, nfilt, nflags;
      obj := arg[1];
      if IsAttributeStoringRep( obj )  then
          extra := [  ];
          type := TypeObj( obj );
          flags := FlagsType( type );
          nfilt := IS_OBJECT;
          for i  in [ 2, 4 .. LEN_LIST( arg ) - 1 ]  do
              attr := arg[i];
              val := arg[i + 1];
              if 0 <> FLAG1_FILTER( attr )  then
                  if val  then
                      nfilt := nfilt and attr;
                  else
                      nfilt := nfilt and Tester( attr );
                  fi;
              elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2 ) ) <> 12  then
                  ADD_LIST( extra, attr );
                  ADD_LIST( extra, val );
              else
                  obj!.(NAME_FUNC( attr )) := IMMUTABLE_COPY_OBJ( val );
                  nfilt := nfilt and Tester( attr );
              fi;
          od;
          nflags := FLAGS_FILTER( nfilt );
          if not IS_SUBSET_FLAGS( flags, nflags )  then
              flags := WITH_IMPS_FLAGS( AND_FLAGS( flags, nflags ) );
              ChangeTypeObj( NEW_TYPE( TypeOfTypes, FamilyType( type ), flags, DataType( type ) ), obj );
          fi;
          for i  in [ 2, 4 .. LEN_LIST( extra ) ]  do
              Setter( extra[i - 1] )( obj, extra[i] );
          od;
      else
          extra := arg;
          for i  in [ 2, 4 .. LEN_LIST( extra ) ]  do
              Setter( extra[i] )( obj, extra[i + 1] );
          od;
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 21, "SetMultipleAttributes" );
 t_3 = NewFunction( NameFunc[33], NargFunc[33], NamsFunc[33], HdlrFunc33 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(846));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(898));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "IsAttributeStoringRepFlags", FLAGS_FILTER( IsAttributeStoringRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 26, "IsAttributeStoringRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_5, "IsAttributeStoringRep" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "INFO_OWA", Ignore ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "INFO_OWA" );
 t_3 = GC_Ignore;
 CHECK_BOUND( t_3, "Ignore" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* MAKE_READ_WRITE_GLOBAL( "INFO_OWA" ); */
 t_1 = GF_MAKE__READ__WRITE__GLOBAL;
 C_NEW_STRING( t_2, 8, "INFO_OWA" );
 CALL_1ARGS( t_1, t_2 );
 
 /* BIND_GLOBAL( "ObjectifyWithAttributes", function ( arg... )
      local  obj, type, flags, attr, val, i, extra, nflags;
      obj := arg[1];
      type := arg[2];
      flags := FlagsType( type );
      extra := [  ];
      if not IS_SUBSET_FLAGS( flags, IsAttributeStoringRepFlags )  then
          extra := arg{[ 3 .. LEN_LIST( arg ) ]};
          INFO_OWA( "#W ObjectifyWithAttributes called ", "for non-attribute storing rep\n" );
          Objectify( type, obj );
      else
          nflags := EMPTY_FLAGS;
          for i  in [ 3, 5 .. LEN_LIST( arg ) - 1 ]  do
              attr := arg[i];
              val := arg[i + 1];
              if 0 <> FLAG1_FILTER( attr )  then
                  if val  then
                      nflags := AND_FLAGS( nflags, FLAGS_FILTER( attr ) );
                  else
                      nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) );
                  fi;
              elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2 ) ) <> LENGTH_SETTER_METHODS_2  then
                  ADD_LIST( extra, attr );
                  ADD_LIST( extra, val );
              else
                  obj.(NAME_FUNC( attr )) := IMMUTABLE_COPY_OBJ( val );
                  nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) );
              fi;
          od;
          if not IS_SUBSET_FLAGS( flags, nflags )  then
              flags := WITH_IMPS_FLAGS( AND_FLAGS( flags, nflags ) );
              Objectify( NEW_TYPE( TypeOfTypes, FamilyType( type ), flags, DataType( type ), fail ), obj );
          else
              Objectify( type, obj );
          fi;
      fi;
      for i  in [ 1, 3 .. LEN_LIST( extra ) - 1 ]  do
          if Tester( extra[i] )( obj )  then
              INFO_OWA( "#W  Supplied type has tester of ", NAME_FUNC( extra[i] ), "with non-standard setter\n" );
              ResetFilterObj( obj, Tester( extra[i] ) );
          fi;
          Setter( extra[i] )( obj, extra[i + 1] );
      od;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 23, "ObjectifyWithAttributes" );
 t_3 = NewFunction( NameFunc[34], NargFunc[34], NamsFunc[34], HdlrFunc34 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(945));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(1010));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "NAME_FUNC", &GF_NAME__FUNC );
 InitFopyGVar( "IsType", &GF_IsType );
 InitFopyGVar( "IS_REC", &GF_IS__REC );
 InitFopyGVar( "IS_LIST", &GF_IS__LIST );
 InitFopyGVar( "ADD_LIST", &GF_ADD__LIST );
 InitFopyGVar( "IS_PLIST_REP", &GF_IS__PLIST__REP );
 InitFopyGVar( "IS_BLIST", &GF_IS__BLIST );
 InitFopyGVar( "IS_RANGE", &GF_IS__RANGE );
 InitFopyGVar( "IS_STRING_REP", &GF_IS__STRING__REP );
 InitFopyGVar( "Error", &GF_Error );
 InitCopyGVar( "TYPE_OBJ", &GC_TYPE__OBJ );
 InitFopyGVar( "TYPE_OBJ", &GF_TYPE__OBJ );
 InitCopyGVar( "FAMILY_OBJ", &GC_FAMILY__OBJ );
 InitFopyGVar( "IMMUTABLE_COPY_OBJ", &GF_IMMUTABLE__COPY__OBJ );
 InitFopyGVar( "IS_IDENTICAL_OBJ", &GF_IS__IDENTICAL__OBJ );
 InitFopyGVar( "IS_COMOBJ", &GF_IS__COMOBJ );
 InitFopyGVar( "SET_TYPE_COMOBJ", &GF_SET__TYPE__COMOBJ );
 InitFopyGVar( "IS_POSOBJ", &GF_IS__POSOBJ );
 InitFopyGVar( "SET_TYPE_POSOBJ", &GF_SET__TYPE__POSOBJ );
 InitFopyGVar( "LEN_POSOBJ", &GF_LEN__POSOBJ );
 InitFopyGVar( "IS_DATOBJ", &GF_IS__DATOBJ );
 InitFopyGVar( "SET_TYPE_DATOBJ", &GF_SET__TYPE__DATOBJ );
 InitFopyGVar( "FORCE_SWITCH_OBJ", &GF_FORCE__SWITCH__OBJ );
 InitFopyGVar( "MakeImmutable", &GF_MakeImmutable );
 InitCopyGVar( "IS_OBJECT", &GC_IS__OBJECT );
 InitFopyGVar( "AND_FLAGS", &GF_AND__FLAGS );
 InitFopyGVar( "SUB_FLAGS", &GF_SUB__FLAGS );
 InitFopyGVar( "HASH_FLAGS", &GF_HASH__FLAGS );
 InitFopyGVar( "IS_EQUAL_FLAGS", &GF_IS__EQUAL__FLAGS );
 InitFopyGVar( "IS_SUBSET_FLAGS", &GF_IS__SUBSET__FLAGS );
 InitFopyGVar( "FLAG1_FILTER", &GF_FLAG1__FILTER );
 InitFopyGVar( "FLAGS_FILTER", &GF_FLAGS__FILTER );
 InitFopyGVar( "METHODS_OPERATION", &GF_METHODS__OPERATION );
 InitFopyGVar( "SETTER_FUNCTION", &GF_SETTER__FUNCTION );
 InitFopyGVar( "GETTER_FUNCTION", &GF_GETTER__FUNCTION );
 InitFopyGVar( "IS_AND_FILTER", &GF_IS__AND__FILTER );
 InitFopyGVar( "COMPACT_TYPE_IDS", &GF_COMPACT__TYPE__IDS );
 InitCopyGVar( "fail", &GC_fail );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitFopyGVar( "SET_FILTER_LIST", &GF_SET__FILTER__LIST );
 InitFopyGVar( "RESET_FILTER_LIST", &GF_RESET__FILTER__LIST );
 InitFopyGVar( "GASMAN", &GF_GASMAN );
 InitFopyGVar( "WRITE_LOCK", &GF_WRITE__LOCK );
 InitFopyGVar( "READ_LOCK", &GF_READ__LOCK );
 InitFopyGVar( "UNLOCK", &GF_UNLOCK );
 InitFopyGVar( "MIGRATE_RAW", &GF_MIGRATE__RAW );
 InitFopyGVar( "MakeReadOnly", &GF_MakeReadOnly );
 InitFopyGVar( "MakeReadOnlyObj", &GF_MakeReadOnlyObj );
 InitFopyGVar( "AtomicList", &GF_AtomicList );
 InitFopyGVar( "FixedAtomicList", &GF_FixedAtomicList );
 InitFopyGVar( "AtomicRecord", &GF_AtomicRecord );
 InitFopyGVar( "IS_ATOMIC_RECORD", &GF_IS__ATOMIC__RECORD );
 InitFopyGVar( "FromAtomicRecord", &GF_FromAtomicRecord );
 InitFopyGVar( "MakeWriteOnceAtomic", &GF_MakeWriteOnceAtomic );
 InitFopyGVar( "StrictBindOnce", &GF_StrictBindOnce );
 InitFopyGVar( "InstallAttributeFunction", &GF_InstallAttributeFunction );
 InitFopyGVar( "InstallOtherMethod", &GF_InstallOtherMethod );
 InitCopyGVar( "IsAttributeStoringRep", &GC_IsAttributeStoringRep );
 InitFopyGVar( "IsAttributeStoringRep", &GF_IsAttributeStoringRep );
 InitCopyGVar( "GETTER_FLAGS", &GC_GETTER__FLAGS );
 InitCopyGVar( "LENGTH_SETTER_METHODS_2", &GC_LENGTH__SETTER__METHODS__2 );
 InitCopyGVar( "SetFilterObj", &GC_SetFilterObj );
 InitFopyGVar( "SetFilterObj", &GF_SetFilterObj );
 InitFopyGVar( "Subtype", &GF_Subtype );
 InitCopyGVar( "DS_TYPE_CACHE", &GC_DS__TYPE__CACHE );
 InitFopyGVar( "ShareSpecialObj", &GF_ShareSpecialObj );
 InitFopyGVar( "BIND_GLOBAL", &GF_BIND__GLOBAL );
 InitFopyGVar( "WITH_IMPS_FLAGS", &GF_WITH__IMPS__FLAGS );
 InitCopyGVar( "CATEGORIES_FAMILY", &GC_CATEGORIES__FAMILY );
 InitFopyGVar( "NEW_FAMILY", &GF_NEW__FAMILY );
 InitCopyGVar( "EMPTY_FLAGS", &GC_EMPTY__FLAGS );
 InitFopyGVar( "NewFamily2", &GF_NewFamily2 );
 InitCopyGVar( "TypeOfFamilies", &GC_TypeOfFamilies );
 InitFopyGVar( "NewFamily3", &GF_NewFamily3 );
 InitFopyGVar( "NewFamily4", &GF_NewFamily4 );
 InitFopyGVar( "NewFamily5", &GF_NewFamily5 );
 InitCopyGVar( "NEW_TYPE_CACHE_MISS", &GC_NEW__TYPE__CACHE__MISS );
 InitCopyGVar( "NEW_TYPE_CACHE_HIT", &GC_NEW__TYPE__CACHE__HIT );
 InitCopyGVar( "POS_DATA_TYPE", &GC_POS__DATA__TYPE );
 InitCopyGVar( "POS_FIRST_FREE_TYPE", &GC_POS__FIRST__FREE__TYPE );
 InitCopyGVar( "NEW_TYPE_NEXT_ID", &GC_NEW__TYPE__NEXT__ID );
 InitCopyGVar( "NEW_TYPE_ID_LIMIT", &GC_NEW__TYPE__ID__LIMIT );
 InitFopyGVar( "FLUSH_ALL_METHOD_CACHES", &GF_FLUSH__ALL__METHOD__CACHES );
 InitCopyGVar( "POS_NUMB_TYPE", &GC_POS__NUMB__TYPE );
 InitFopyGVar( "NEW_TYPE", &GF_NEW__TYPE );
 InitFopyGVar( "IsFamily", &GF_IsFamily );
 InitFopyGVar( "NewType3", &GF_NewType3 );
 InitCopyGVar( "TypeOfTypes", &GC_TypeOfTypes );
 InitFopyGVar( "NewType4", &GF_NewType4 );
 InitFopyGVar( "Subtype2", &GF_Subtype2 );
 InitFopyGVar( "Subtype3", &GF_Subtype3 );
 InitFopyGVar( "SupType2", &GF_SupType2 );
 InitFopyGVar( "SupType3", &GF_SupType3 );
 InitFopyGVar( "MakeLiteral", &GF_MakeLiteral );
 InitFopyGVar( "FlagsType", &GF_FlagsType );
 InitFopyGVar( "TypeObj", &GF_TypeObj );
 InitFopyGVar( "DataType", &GF_DataType );
 InitFopyGVar( "IsNoImmediateMethodsObject", &GF_IsNoImmediateMethodsObject );
 InitFopyGVar( "RunImmediateMethods", &GF_RunImmediateMethods );
 InitCopyGVar( "IsNonAtomicComponentObjectRep", &GC_IsNonAtomicComponentObjectRep );
 InitCopyGVar( "IsAtomicPositionalObjectRep", &GC_IsAtomicPositionalObjectRep );
 InitCopyGVar( "IsReadOnlyPositionalObjectRep", &GC_IsReadOnlyPositionalObjectRep );
 InitFopyGVar( "IsReadOnlyPositionalObjectRep", &GF_IsReadOnlyPositionalObjectRep );
 InitCopyGVar( "IsAtomicPositionalObjectRepFlags", &GC_IsAtomicPositionalObjectRepFlags );
 InitCopyGVar( "IsNonAtomicComponentObjectRepFlags", &GC_IsNonAtomicComponentObjectRepFlags );
 InitCopyGVar( "ChangeTypeObj", &GC_ChangeTypeObj );
 InitFopyGVar( "ChangeTypeObj", &GF_ChangeTypeObj );
 InitCopyGVar( "IGNORE_IMMEDIATE_METHODS", &GC_IGNORE__IMMEDIATE__METHODS );
 InitCopyGVar( "ResetFilterObj", &GC_ResetFilterObj );
 InitFopyGVar( "ResetFilterObj", &GF_ResetFilterObj );
 InitFopyGVar( "Tester", &GF_Tester );
 InitFopyGVar( "Setter", &GF_Setter );
 InitFopyGVar( "FamilyType", &GF_FamilyType );
 InitCopyGVar( "Ignore", &GC_Ignore );
 InitFopyGVar( "MAKE_READ_WRITE_GLOBAL", &GF_MAKE__READ__WRITE__GLOBAL );
 InitCopyGVar( "IsAttributeStoringRepFlags", &GC_IsAttributeStoringRepFlags );
 InitFopyGVar( "INFO_OWA", &GF_INFO__OWA );
 InitFopyGVar( "Objectify", &GF_Objectify );
 
 /* information for the functions */
 InitGlobalBag( &DefaultName, "GAPROOT/lib/type1.g:DefaultName(-93412607)" );
 InitGlobalBag( &FileName, "GAPROOT/lib/type1.g:FileName(-93412607)" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/type1.g:HdlrFunc1(-93412607)" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/type1.g:NameFunc[1](-93412607)" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/type1.g:HdlrFunc2(-93412607)" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/type1.g:NameFunc[2](-93412607)" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/type1.g:HdlrFunc3(-93412607)" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/type1.g:NameFunc[3](-93412607)" );
 InitHandlerFunc( HdlrFunc4, "GAPROOT/lib/type1.g:HdlrFunc4(-93412607)" );
 InitGlobalBag( &(NameFunc[4]), "GAPROOT/lib/type1.g:NameFunc[4](-93412607)" );
 InitHandlerFunc( HdlrFunc5, "GAPROOT/lib/type1.g:HdlrFunc5(-93412607)" );
 InitGlobalBag( &(NameFunc[5]), "GAPROOT/lib/type1.g:NameFunc[5](-93412607)" );
 InitHandlerFunc( HdlrFunc6, "GAPROOT/lib/type1.g:HdlrFunc6(-93412607)" );
 InitGlobalBag( &(NameFunc[6]), "GAPROOT/lib/type1.g:NameFunc[6](-93412607)" );
 InitHandlerFunc( HdlrFunc7, "GAPROOT/lib/type1.g:HdlrFunc7(-93412607)" );
 InitGlobalBag( &(NameFunc[7]), "GAPROOT/lib/type1.g:NameFunc[7](-93412607)" );
 InitHandlerFunc( HdlrFunc8, "GAPROOT/lib/type1.g:HdlrFunc8(-93412607)" );
 InitGlobalBag( &(NameFunc[8]), "GAPROOT/lib/type1.g:NameFunc[8](-93412607)" );
 InitHandlerFunc( HdlrFunc9, "GAPROOT/lib/type1.g:HdlrFunc9(-93412607)" );
 InitGlobalBag( &(NameFunc[9]), "GAPROOT/lib/type1.g:NameFunc[9](-93412607)" );
 InitHandlerFunc( HdlrFunc10, "GAPROOT/lib/type1.g:HdlrFunc10(-93412607)" );
 InitGlobalBag( &(NameFunc[10]), "GAPROOT/lib/type1.g:NameFunc[10](-93412607)" );
 InitHandlerFunc( HdlrFunc11, "GAPROOT/lib/type1.g:HdlrFunc11(-93412607)" );
 InitGlobalBag( &(NameFunc[11]), "GAPROOT/lib/type1.g:NameFunc[11](-93412607)" );
 InitHandlerFunc( HdlrFunc12, "GAPROOT/lib/type1.g:HdlrFunc12(-93412607)" );
 InitGlobalBag( &(NameFunc[12]), "GAPROOT/lib/type1.g:NameFunc[12](-93412607)" );
 InitHandlerFunc( HdlrFunc13, "GAPROOT/lib/type1.g:HdlrFunc13(-93412607)" );
 InitGlobalBag( &(NameFunc[13]), "GAPROOT/lib/type1.g:NameFunc[13](-93412607)" );
 InitHandlerFunc( HdlrFunc14, "GAPROOT/lib/type1.g:HdlrFunc14(-93412607)" );
 InitGlobalBag( &(NameFunc[14]), "GAPROOT/lib/type1.g:NameFunc[14](-93412607)" );
 InitHandlerFunc( HdlrFunc15, "GAPROOT/lib/type1.g:HdlrFunc15(-93412607)" );
 InitGlobalBag( &(NameFunc[15]), "GAPROOT/lib/type1.g:NameFunc[15](-93412607)" );
 InitHandlerFunc( HdlrFunc16, "GAPROOT/lib/type1.g:HdlrFunc16(-93412607)" );
 InitGlobalBag( &(NameFunc[16]), "GAPROOT/lib/type1.g:NameFunc[16](-93412607)" );
 InitHandlerFunc( HdlrFunc17, "GAPROOT/lib/type1.g:HdlrFunc17(-93412607)" );
 InitGlobalBag( &(NameFunc[17]), "GAPROOT/lib/type1.g:NameFunc[17](-93412607)" );
 InitHandlerFunc( HdlrFunc18, "GAPROOT/lib/type1.g:HdlrFunc18(-93412607)" );
 InitGlobalBag( &(NameFunc[18]), "GAPROOT/lib/type1.g:NameFunc[18](-93412607)" );
 InitHandlerFunc( HdlrFunc19, "GAPROOT/lib/type1.g:HdlrFunc19(-93412607)" );
 InitGlobalBag( &(NameFunc[19]), "GAPROOT/lib/type1.g:NameFunc[19](-93412607)" );
 InitHandlerFunc( HdlrFunc20, "GAPROOT/lib/type1.g:HdlrFunc20(-93412607)" );
 InitGlobalBag( &(NameFunc[20]), "GAPROOT/lib/type1.g:NameFunc[20](-93412607)" );
 InitHandlerFunc( HdlrFunc21, "GAPROOT/lib/type1.g:HdlrFunc21(-93412607)" );
 InitGlobalBag( &(NameFunc[21]), "GAPROOT/lib/type1.g:NameFunc[21](-93412607)" );
 InitHandlerFunc( HdlrFunc22, "GAPROOT/lib/type1.g:HdlrFunc22(-93412607)" );
 InitGlobalBag( &(NameFunc[22]), "GAPROOT/lib/type1.g:NameFunc[22](-93412607)" );
 InitHandlerFunc( HdlrFunc23, "GAPROOT/lib/type1.g:HdlrFunc23(-93412607)" );
 InitGlobalBag( &(NameFunc[23]), "GAPROOT/lib/type1.g:NameFunc[23](-93412607)" );
 InitHandlerFunc( HdlrFunc24, "GAPROOT/lib/type1.g:HdlrFunc24(-93412607)" );
 InitGlobalBag( &(NameFunc[24]), "GAPROOT/lib/type1.g:NameFunc[24](-93412607)" );
 InitHandlerFunc( HdlrFunc25, "GAPROOT/lib/type1.g:HdlrFunc25(-93412607)" );
 InitGlobalBag( &(NameFunc[25]), "GAPROOT/lib/type1.g:NameFunc[25](-93412607)" );
 InitHandlerFunc( HdlrFunc26, "GAPROOT/lib/type1.g:HdlrFunc26(-93412607)" );
 InitGlobalBag( &(NameFunc[26]), "GAPROOT/lib/type1.g:NameFunc[26](-93412607)" );
 InitHandlerFunc( HdlrFunc27, "GAPROOT/lib/type1.g:HdlrFunc27(-93412607)" );
 InitGlobalBag( &(NameFunc[27]), "GAPROOT/lib/type1.g:NameFunc[27](-93412607)" );
 InitHandlerFunc( HdlrFunc28, "GAPROOT/lib/type1.g:HdlrFunc28(-93412607)" );
 InitGlobalBag( &(NameFunc[28]), "GAPROOT/lib/type1.g:NameFunc[28](-93412607)" );
 InitHandlerFunc( HdlrFunc29, "GAPROOT/lib/type1.g:HdlrFunc29(-93412607)" );
 InitGlobalBag( &(NameFunc[29]), "GAPROOT/lib/type1.g:NameFunc[29](-93412607)" );
 InitHandlerFunc( HdlrFunc30, "GAPROOT/lib/type1.g:HdlrFunc30(-93412607)" );
 InitGlobalBag( &(NameFunc[30]), "GAPROOT/lib/type1.g:NameFunc[30](-93412607)" );
 InitHandlerFunc( HdlrFunc31, "GAPROOT/lib/type1.g:HdlrFunc31(-93412607)" );
 InitGlobalBag( &(NameFunc[31]), "GAPROOT/lib/type1.g:NameFunc[31](-93412607)" );
 InitHandlerFunc( HdlrFunc32, "GAPROOT/lib/type1.g:HdlrFunc32(-93412607)" );
 InitGlobalBag( &(NameFunc[32]), "GAPROOT/lib/type1.g:NameFunc[32](-93412607)" );
 InitHandlerFunc( HdlrFunc33, "GAPROOT/lib/type1.g:HdlrFunc33(-93412607)" );
 InitGlobalBag( &(NameFunc[33]), "GAPROOT/lib/type1.g:NameFunc[33](-93412607)" );
 InitHandlerFunc( HdlrFunc34, "GAPROOT/lib/type1.g:HdlrFunc34(-93412607)" );
 InitGlobalBag( &(NameFunc[34]), "GAPROOT/lib/type1.g:NameFunc[34](-93412607)" );
 
 /* return success */
 return 0;
 
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
 Obj func1;
 Obj body1;
 
 /* Complete Copy/Fopy registration */
 UpdateCopyFopyInfo();
 
 /* global variables used in handlers */
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 G_IsType = GVarName( "IsType" );
 G_IS__REC = GVarName( "IS_REC" );
 G_IS__LIST = GVarName( "IS_LIST" );
 G_ADD__LIST = GVarName( "ADD_LIST" );
 G_IS__PLIST__REP = GVarName( "IS_PLIST_REP" );
 G_IS__BLIST = GVarName( "IS_BLIST" );
 G_IS__RANGE = GVarName( "IS_RANGE" );
 G_IS__STRING__REP = GVarName( "IS_STRING_REP" );
 G_Error = GVarName( "Error" );
 G_TYPE__OBJ = GVarName( "TYPE_OBJ" );
 G_FAMILY__OBJ = GVarName( "FAMILY_OBJ" );
 G_IMMUTABLE__COPY__OBJ = GVarName( "IMMUTABLE_COPY_OBJ" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_IS__COMOBJ = GVarName( "IS_COMOBJ" );
 G_SET__TYPE__COMOBJ = GVarName( "SET_TYPE_COMOBJ" );
 G_IS__POSOBJ = GVarName( "IS_POSOBJ" );
 G_SET__TYPE__POSOBJ = GVarName( "SET_TYPE_POSOBJ" );
 G_LEN__POSOBJ = GVarName( "LEN_POSOBJ" );
 G_IS__DATOBJ = GVarName( "IS_DATOBJ" );
 G_SET__TYPE__DATOBJ = GVarName( "SET_TYPE_DATOBJ" );
 G_FORCE__SWITCH__OBJ = GVarName( "FORCE_SWITCH_OBJ" );
 G_MakeImmutable = GVarName( "MakeImmutable" );
 G_IS__OBJECT = GVarName( "IS_OBJECT" );
 G_AND__FLAGS = GVarName( "AND_FLAGS" );
 G_SUB__FLAGS = GVarName( "SUB_FLAGS" );
 G_HASH__FLAGS = GVarName( "HASH_FLAGS" );
 G_IS__EQUAL__FLAGS = GVarName( "IS_EQUAL_FLAGS" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_FLAG1__FILTER = GVarName( "FLAG1_FILTER" );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_SETTER__FUNCTION = GVarName( "SETTER_FUNCTION" );
 G_GETTER__FUNCTION = GVarName( "GETTER_FUNCTION" );
 G_IS__AND__FILTER = GVarName( "IS_AND_FILTER" );
 G_COMPACT__TYPE__IDS = GVarName( "COMPACT_TYPE_IDS" );
 G_fail = GVarName( "fail" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_SET__FILTER__LIST = GVarName( "SET_FILTER_LIST" );
 G_RESET__FILTER__LIST = GVarName( "RESET_FILTER_LIST" );
 G_GASMAN = GVarName( "GASMAN" );
 G_WRITE__LOCK = GVarName( "WRITE_LOCK" );
 G_READ__LOCK = GVarName( "READ_LOCK" );
 G_UNLOCK = GVarName( "UNLOCK" );
 G_MIGRATE__RAW = GVarName( "MIGRATE_RAW" );
 G_MakeReadOnly = GVarName( "MakeReadOnly" );
 G_MakeReadOnlyObj = GVarName( "MakeReadOnlyObj" );
 G_AtomicList = GVarName( "AtomicList" );
 G_FixedAtomicList = GVarName( "FixedAtomicList" );
 G_AtomicRecord = GVarName( "AtomicRecord" );
 G_IS__ATOMIC__RECORD = GVarName( "IS_ATOMIC_RECORD" );
 G_FromAtomicRecord = GVarName( "FromAtomicRecord" );
 G_MakeWriteOnceAtomic = GVarName( "MakeWriteOnceAtomic" );
 G_StrictBindOnce = GVarName( "StrictBindOnce" );
 G_InstallAttributeFunction = GVarName( "InstallAttributeFunction" );
 G_InstallOtherMethod = GVarName( "InstallOtherMethod" );
 G_IsAttributeStoringRep = GVarName( "IsAttributeStoringRep" );
 G_GETTER__FLAGS = GVarName( "GETTER_FLAGS" );
 G_LENGTH__SETTER__METHODS__2 = GVarName( "LENGTH_SETTER_METHODS_2" );
 G_SetFilterObj = GVarName( "SetFilterObj" );
 G_Subtype = GVarName( "Subtype" );
 G_DS__TYPE__CACHE = GVarName( "DS_TYPE_CACHE" );
 G_ShareSpecialObj = GVarName( "ShareSpecialObj" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_WITH__IMPS__FLAGS = GVarName( "WITH_IMPS_FLAGS" );
 G_CATEGORIES__FAMILY = GVarName( "CATEGORIES_FAMILY" );
 G_NEW__FAMILY = GVarName( "NEW_FAMILY" );
 G_EMPTY__FLAGS = GVarName( "EMPTY_FLAGS" );
 G_NewFamily2 = GVarName( "NewFamily2" );
 G_TypeOfFamilies = GVarName( "TypeOfFamilies" );
 G_NewFamily3 = GVarName( "NewFamily3" );
 G_NewFamily4 = GVarName( "NewFamily4" );
 G_NewFamily5 = GVarName( "NewFamily5" );
 G_NEW__TYPE__CACHE__MISS = GVarName( "NEW_TYPE_CACHE_MISS" );
 G_NEW__TYPE__CACHE__HIT = GVarName( "NEW_TYPE_CACHE_HIT" );
 G_POS__DATA__TYPE = GVarName( "POS_DATA_TYPE" );
 G_POS__FIRST__FREE__TYPE = GVarName( "POS_FIRST_FREE_TYPE" );
 G_NEW__TYPE__NEXT__ID = GVarName( "NEW_TYPE_NEXT_ID" );
 G_NEW__TYPE__ID__LIMIT = GVarName( "NEW_TYPE_ID_LIMIT" );
 G_FLUSH__ALL__METHOD__CACHES = GVarName( "FLUSH_ALL_METHOD_CACHES" );
 G_POS__NUMB__TYPE = GVarName( "POS_NUMB_TYPE" );
 G_NEW__TYPE = GVarName( "NEW_TYPE" );
 G_IsFamily = GVarName( "IsFamily" );
 G_NewType3 = GVarName( "NewType3" );
 G_TypeOfTypes = GVarName( "TypeOfTypes" );
 G_NewType4 = GVarName( "NewType4" );
 G_Subtype2 = GVarName( "Subtype2" );
 G_Subtype3 = GVarName( "Subtype3" );
 G_SupType2 = GVarName( "SupType2" );
 G_SupType3 = GVarName( "SupType3" );
 G_MakeLiteral = GVarName( "MakeLiteral" );
 G_FlagsType = GVarName( "FlagsType" );
 G_TypeObj = GVarName( "TypeObj" );
 G_DataType = GVarName( "DataType" );
 G_IsNoImmediateMethodsObject = GVarName( "IsNoImmediateMethodsObject" );
 G_RunImmediateMethods = GVarName( "RunImmediateMethods" );
 G_IsNonAtomicComponentObjectRep = GVarName( "IsNonAtomicComponentObjectRep" );
 G_IsAtomicPositionalObjectRep = GVarName( "IsAtomicPositionalObjectRep" );
 G_IsReadOnlyPositionalObjectRep = GVarName( "IsReadOnlyPositionalObjectRep" );
 G_IsAtomicPositionalObjectRepFlags = GVarName( "IsAtomicPositionalObjectRepFlags" );
 G_IsNonAtomicComponentObjectRepFlags = GVarName( "IsNonAtomicComponentObjectRepFlags" );
 G_ChangeTypeObj = GVarName( "ChangeTypeObj" );
 G_IGNORE__IMMEDIATE__METHODS = GVarName( "IGNORE_IMMEDIATE_METHODS" );
 G_ResetFilterObj = GVarName( "ResetFilterObj" );
 G_Tester = GVarName( "Tester" );
 G_Setter = GVarName( "Setter" );
 G_FamilyType = GVarName( "FamilyType" );
 G_Ignore = GVarName( "Ignore" );
 G_MAKE__READ__WRITE__GLOBAL = GVarName( "MAKE_READ_WRITE_GLOBAL" );
 G_IsAttributeStoringRepFlags = GVarName( "IsAttributeStoringRepFlags" );
 G_INFO__OWA = GVarName( "INFO_OWA" );
 G_Objectify = GVarName( "Objectify" );
 
 /* record names used in handlers */
 R_TYPES__LIST__FAM = RNamName( "TYPES_LIST_FAM" );
 R_NAME = RNamName( "NAME" );
 R_REQ__FLAGS = RNamName( "REQ_FLAGS" );
 R_IMP__FLAGS = RNamName( "IMP_FLAGS" );
 R_TYPES = RNamName( "TYPES" );
 R_nTYPES = RNamName( "nTYPES" );
 R_HASH__SIZE = RNamName( "HASH_SIZE" );
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" );
 C_NEW_STRING( FileName, 19, "GAPROOT/lib/type1.g" );
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 6;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 6;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 2;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 4;
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = 2;
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = 3;
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 4;
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = 5;
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = -1;
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 5;
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 3;
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 4;
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = -1;
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 2;
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 3;
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = -1;
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = 2;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 3;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = -1;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 1;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 1;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 1;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 2;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = 1;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 1;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 2;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 2;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 2;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 2;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 3;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = -1;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = -1;
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);
 ENVI_FUNC( func1 ) = STATE(CurrLVars);
 CHANGED_BAG( STATE(CurrLVars) );
 body1 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj));
 BODY_FUNC( func1 ) = body1;
 CHANGED_BAG( func1 );
 CALL_0ARGS( func1 );
 
 /* return success */
 return 0;
 
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 G_IsType = GVarName( "IsType" );
 G_IS__REC = GVarName( "IS_REC" );
 G_IS__LIST = GVarName( "IS_LIST" );
 G_ADD__LIST = GVarName( "ADD_LIST" );
 G_IS__PLIST__REP = GVarName( "IS_PLIST_REP" );
 G_IS__BLIST = GVarName( "IS_BLIST" );
 G_IS__RANGE = GVarName( "IS_RANGE" );
 G_IS__STRING__REP = GVarName( "IS_STRING_REP" );
 G_Error = GVarName( "Error" );
 G_TYPE__OBJ = GVarName( "TYPE_OBJ" );
 G_FAMILY__OBJ = GVarName( "FAMILY_OBJ" );
 G_IMMUTABLE__COPY__OBJ = GVarName( "IMMUTABLE_COPY_OBJ" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_IS__COMOBJ = GVarName( "IS_COMOBJ" );
 G_SET__TYPE__COMOBJ = GVarName( "SET_TYPE_COMOBJ" );
 G_IS__POSOBJ = GVarName( "IS_POSOBJ" );
 G_SET__TYPE__POSOBJ = GVarName( "SET_TYPE_POSOBJ" );
 G_LEN__POSOBJ = GVarName( "LEN_POSOBJ" );
 G_IS__DATOBJ = GVarName( "IS_DATOBJ" );
 G_SET__TYPE__DATOBJ = GVarName( "SET_TYPE_DATOBJ" );
 G_FORCE__SWITCH__OBJ = GVarName( "FORCE_SWITCH_OBJ" );
 G_MakeImmutable = GVarName( "MakeImmutable" );
 G_IS__OBJECT = GVarName( "IS_OBJECT" );
 G_AND__FLAGS = GVarName( "AND_FLAGS" );
 G_SUB__FLAGS = GVarName( "SUB_FLAGS" );
 G_HASH__FLAGS = GVarName( "HASH_FLAGS" );
 G_IS__EQUAL__FLAGS = GVarName( "IS_EQUAL_FLAGS" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_FLAG1__FILTER = GVarName( "FLAG1_FILTER" );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_SETTER__FUNCTION = GVarName( "SETTER_FUNCTION" );
 G_GETTER__FUNCTION = GVarName( "GETTER_FUNCTION" );
 G_IS__AND__FILTER = GVarName( "IS_AND_FILTER" );
 G_COMPACT__TYPE__IDS = GVarName( "COMPACT_TYPE_IDS" );
 G_fail = GVarName( "fail" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_SET__FILTER__LIST = GVarName( "SET_FILTER_LIST" );
 G_RESET__FILTER__LIST = GVarName( "RESET_FILTER_LIST" );
 G_GASMAN = GVarName( "GASMAN" );
 G_WRITE__LOCK = GVarName( "WRITE_LOCK" );
 G_READ__LOCK = GVarName( "READ_LOCK" );
 G_UNLOCK = GVarName( "UNLOCK" );
 G_MIGRATE__RAW = GVarName( "MIGRATE_RAW" );
 G_MakeReadOnly = GVarName( "MakeReadOnly" );
 G_MakeReadOnlyObj = GVarName( "MakeReadOnlyObj" );
 G_AtomicList = GVarName( "AtomicList" );
 G_FixedAtomicList = GVarName( "FixedAtomicList" );
 G_AtomicRecord = GVarName( "AtomicRecord" );
 G_IS__ATOMIC__RECORD = GVarName( "IS_ATOMIC_RECORD" );
 G_FromAtomicRecord = GVarName( "FromAtomicRecord" );
 G_MakeWriteOnceAtomic = GVarName( "MakeWriteOnceAtomic" );
 G_StrictBindOnce = GVarName( "StrictBindOnce" );
 G_InstallAttributeFunction = GVarName( "InstallAttributeFunction" );
 G_InstallOtherMethod = GVarName( "InstallOtherMethod" );
 G_IsAttributeStoringRep = GVarName( "IsAttributeStoringRep" );
 G_GETTER__FLAGS = GVarName( "GETTER_FLAGS" );
 G_LENGTH__SETTER__METHODS__2 = GVarName( "LENGTH_SETTER_METHODS_2" );
 G_SetFilterObj = GVarName( "SetFilterObj" );
 G_Subtype = GVarName( "Subtype" );
 G_DS__TYPE__CACHE = GVarName( "DS_TYPE_CACHE" );
 G_ShareSpecialObj = GVarName( "ShareSpecialObj" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_WITH__IMPS__FLAGS = GVarName( "WITH_IMPS_FLAGS" );
 G_CATEGORIES__FAMILY = GVarName( "CATEGORIES_FAMILY" );
 G_NEW__FAMILY = GVarName( "NEW_FAMILY" );
 G_EMPTY__FLAGS = GVarName( "EMPTY_FLAGS" );
 G_NewFamily2 = GVarName( "NewFamily2" );
 G_TypeOfFamilies = GVarName( "TypeOfFamilies" );
 G_NewFamily3 = GVarName( "NewFamily3" );
 G_NewFamily4 = GVarName( "NewFamily4" );
 G_NewFamily5 = GVarName( "NewFamily5" );
 G_NEW__TYPE__CACHE__MISS = GVarName( "NEW_TYPE_CACHE_MISS" );
 G_NEW__TYPE__CACHE__HIT = GVarName( "NEW_TYPE_CACHE_HIT" );
 G_POS__DATA__TYPE = GVarName( "POS_DATA_TYPE" );
 G_POS__FIRST__FREE__TYPE = GVarName( "POS_FIRST_FREE_TYPE" );
 G_NEW__TYPE__NEXT__ID = GVarName( "NEW_TYPE_NEXT_ID" );
 G_NEW__TYPE__ID__LIMIT = GVarName( "NEW_TYPE_ID_LIMIT" );
 G_FLUSH__ALL__METHOD__CACHES = GVarName( "FLUSH_ALL_METHOD_CACHES" );
 G_POS__NUMB__TYPE = GVarName( "POS_NUMB_TYPE" );
 G_NEW__TYPE = GVarName( "NEW_TYPE" );
 G_IsFamily = GVarName( "IsFamily" );
 G_NewType3 = GVarName( "NewType3" );
 G_TypeOfTypes = GVarName( "TypeOfTypes" );
 G_NewType4 = GVarName( "NewType4" );
 G_Subtype2 = GVarName( "Subtype2" );
 G_Subtype3 = GVarName( "Subtype3" );
 G_SupType2 = GVarName( "SupType2" );
 G_SupType3 = GVarName( "SupType3" );
 G_MakeLiteral = GVarName( "MakeLiteral" );
 G_FlagsType = GVarName( "FlagsType" );
 G_TypeObj = GVarName( "TypeObj" );
 G_DataType = GVarName( "DataType" );
 G_IsNoImmediateMethodsObject = GVarName( "IsNoImmediateMethodsObject" );
 G_RunImmediateMethods = GVarName( "RunImmediateMethods" );
 G_IsNonAtomicComponentObjectRep = GVarName( "IsNonAtomicComponentObjectRep" );
 G_IsAtomicPositionalObjectRep = GVarName( "IsAtomicPositionalObjectRep" );
 G_IsReadOnlyPositionalObjectRep = GVarName( "IsReadOnlyPositionalObjectRep" );
 G_IsAtomicPositionalObjectRepFlags = GVarName( "IsAtomicPositionalObjectRepFlags" );
 G_IsNonAtomicComponentObjectRepFlags = GVarName( "IsNonAtomicComponentObjectRepFlags" );
 G_ChangeTypeObj = GVarName( "ChangeTypeObj" );
 G_IGNORE__IMMEDIATE__METHODS = GVarName( "IGNORE_IMMEDIATE_METHODS" );
 G_ResetFilterObj = GVarName( "ResetFilterObj" );
 G_Tester = GVarName( "Tester" );
 G_Setter = GVarName( "Setter" );
 G_FamilyType = GVarName( "FamilyType" );
 G_Ignore = GVarName( "Ignore" );
 G_MAKE__READ__WRITE__GLOBAL = GVarName( "MAKE_READ_WRITE_GLOBAL" );
 G_IsAttributeStoringRepFlags = GVarName( "IsAttributeStoringRepFlags" );
 G_INFO__OWA = GVarName( "INFO_OWA" );
 G_Objectify = GVarName( "Objectify" );
 
 /* record names used in handlers */
 R_TYPES__LIST__FAM = RNamName( "TYPES_LIST_FAM" );
 R_NAME = RNamName( "NAME" );
 R_REQ__FLAGS = RNamName( "REQ_FLAGS" );
 R_IMP__FLAGS = RNamName( "IMP_FLAGS" );
 R_TYPES = RNamName( "TYPES" );
 R_nTYPES = RNamName( "nTYPES" );
 R_HASH__SIZE = RNamName( "HASH_SIZE" );
 
 /* information for the functions */
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 6;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 6;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 2;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 4;
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = 2;
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = 3;
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 4;
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = 5;
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = -1;
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 5;
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 3;
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 4;
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = -1;
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 2;
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 3;
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = -1;
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = 2;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 3;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = -1;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 1;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 1;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 1;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 2;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = 1;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 1;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 2;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 2;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 2;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 2;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 3;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = -1;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = -1;
 
 /* return success */
 return 0;
 
}


/* <name> returns the description of this module */
static StructInitInfo module = {
 /* type        = */ 2,
 /* name        = */ "GAPROOT/lib/type1.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ -93412607,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__type1 ( void )
{
 return &module;
}

/* compiled code ends here */
#endif
