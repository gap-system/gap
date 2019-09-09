#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include "compiled.h"
#define FILE_CRC  "-88497608"

/* global variables used in handlers */
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
static GVar G_SetFilterObj;
static Obj  GF_SetFilterObj;
static GVar G_ResetFilterObj;
static Obj  GF_ResetFilterObj;
static GVar G_IS__REC;
static Obj  GF_IS__REC;
static GVar G_IS__LIST;
static Obj  GF_IS__LIST;
static GVar G_ADD__LIST;
static Obj  GF_ADD__LIST;
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
static GVar G_WITH__IMPS__FLAGS;
static Obj  GF_WITH__IMPS__FLAGS;
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
static GVar G_MakeReadOnlyObj;
static Obj  GF_MakeReadOnlyObj;
static GVar G_MakeReadOnlySingleObj;
static Obj  GF_MakeReadOnlySingleObj;
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
static GVar G_GETTER__FLAGS;
static Obj  GC_GETTER__FLAGS;
static GVar G_LENGTH__SETTER__METHODS__2;
static Obj  GC_LENGTH__SETTER__METHODS__2;
static GVar G_Subtype;
static Obj  GF_Subtype;
static GVar G_DS__TYPE__CACHE;
static Obj  GC_DS__TYPE__CACHE;
static GVar G_ShareSpecialObj;
static Obj  GF_ShareSpecialObj;
static GVar G_BIND__GLOBAL;
static Obj  GF_BIND__GLOBAL;
static GVar G_CATEGORIES__FAMILY;
static Obj  GC_CATEGORIES__FAMILY;
static GVar G_EMPTY__FLAGS;
static Obj  GC_EMPTY__FLAGS;
static GVar G_TypeOfFamilies;
static Obj  GC_TypeOfFamilies;
static GVar G_NEW__FAMILY;
static Obj  GF_NEW__FAMILY;
static GVar G_NEW__TYPE__CACHE__MISS;
static Obj  GC_NEW__TYPE__CACHE__MISS;
static GVar G_NEW__TYPE__CACHE__HIT;
static Obj  GC_NEW__TYPE__CACHE__HIT;
static GVar G_TypeOfTypes;
static Obj  GC_TypeOfTypes;
static GVar G_NEW__TYPE__NEXT__ID;
static Obj  GC_NEW__TYPE__NEXT__ID;
static GVar G_NEW__TYPE__ID__LIMIT;
static Obj  GC_NEW__TYPE__ID__LIMIT;
static GVar G_FLUSH__ALL__METHOD__CACHES;
static Obj  GF_FLUSH__ALL__METHOD__CACHES;
static GVar G_IsFamily;
static Obj  GF_IsFamily;
static GVar G_NEW__TYPE;
static Obj  GF_NEW__TYPE;
static GVar G_IsType;
static Obj  GF_IsType;
static GVar G_FlagsType;
static Obj  GF_FlagsType;
static GVar G_TypeObj;
static Obj  GF_TypeObj;
static GVar G_DataType;
static Obj  GF_DataType;
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
static GVar G_IsNoImmediateMethodsObject;
static Obj  GF_IsNoImmediateMethodsObject;
static GVar G_RunImmediateMethods;
static Obj  GF_RunImmediateMethods;
static GVar G_ErrorNoReturn;
static Obj  GF_ErrorNoReturn;
static GVar G_IGNORE__IMMEDIATE__METHODS;
static Obj  GC_IGNORE__IMMEDIATE__METHODS;
static GVar G_SupType;
static Obj  GF_SupType;
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
static GVar G_Tester;
static Obj  GF_Tester;
static GVar G_Setter;
static Obj  GF_Setter;
static GVar G_FamilyType;
static Obj  GF_FamilyType;

/* record names used in handlers */
static RNam R_TYPES__LIST__FAM;
static RNam R_NAME;
static RNam R_REQ__FLAGS;
static RNam R_IMP__FLAGS;
static RNam R_nTYPES;
static RNam R_HASH__SIZE;
static RNam R_TYPES;

/* information for the functions */
static Obj  NameFunc[21];
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
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* InstallOtherMethod( getter, "system getter", true, [ IsAttributeStoringRep and tester ], GETTER_FLAGS, GETTER_FUNCTION( name ) ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = MakeString( "system getter" );
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_6 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_6, "IsAttributeStoringRep" );
 if ( t_6 == False ) {
  t_5 = t_6;
 }
 else if ( t_6 == True ) {
  CHECK_BOOL( a_tester );
  t_5 = a_tester;
 }
 else if (IS_FILTER( t_6 ) ) {
  t_5 = NewAndFilter( t_6, a_tester );
 }
 else {
  RequireArgumentEx(0, t_6, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_5 = GC_GETTER__FLAGS;
 CHECK_BOUND( t_5, "GETTER_FLAGS" );
 t_7 = GF_GETTER__FUNCTION;
 if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
  t_6 = CALL_1ARGS( t_7, a_name );
 }
 else {
  t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( a_name ) );
 }
 CHECK_FUNC_RESULT( t_6 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_6ARGS( t_1, a_getter, t_2, t_3, t_4, t_5, t_6 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_getter, t_2, t_3, t_4, t_5, t_6 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* obj!.(name) := val; */
 t_1 = OBJ_HVAR( (1 << 16) | 1 );
 CHECK_BOUND( t_1, "name" );
 AssComObj( a_obj, RNamObj(t_1), a_val );
 
 /* SetFilterObj( obj, tester ); */
 t_1 = GF_SetFilterObj;
 t_2 = OBJ_HVAR( (1 << 16) | 2 );
 CHECK_BOUND( t_2, "tester" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, a_obj, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,2,0,oldFrame);
 MakeHighVars(STATE(CurrLVars));
 ASS_LVAR( 1, a_name );
 ASS_LVAR( 2, a_tester );
 
 /* if mutflag then */
 CHECK_BOOL( a_mutflag );
 t_1 = (Obj)(UInt)(a_mutflag != False);
 if ( t_1 ) {
  
  /* InstallOtherMethod( setter, "system mutable setter", true, [ IsAttributeStoringRep, IS_OBJECT ], 0, function ( obj, val )
      obj!.(name) := val;
      SetFilterObj( obj, tester );
      return;
  end ); */
  t_1 = GF_InstallOtherMethod;
  t_2 = MakeString( "system mutable setter" );
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_5, "IsAttributeStoringRep" );
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  CHECK_BOUND( t_5, "IS_OBJECT" );
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = NewFunction( NameFunc[4], 2, ArgStringToList("obj,val"), HdlrFunc4 );
  SET_ENVI_FUNC( t_5, STATE(CurrLVars) );
  t_6 = NewFunctionBody();
  SET_STARTLINE_BODY(t_6, 40);
  SET_ENDLINE_BODY(t_6, 43);
  SET_FILENAME_BODY(t_6, FileName);
  SET_BODY_FUNC(t_5, t_6);
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* InstallOtherMethod( setter, "system setter", true, [ IsAttributeStoringRep, IS_OBJECT ], 0, SETTER_FUNCTION( name, tester ) ); */
  t_1 = GF_InstallOtherMethod;
  t_2 = MakeString( "system setter" );
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_5, "IsAttributeStoringRep" );
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  CHECK_BOUND( t_5, "IS_OBJECT" );
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_6 = GF_SETTER__FUNCTION;
  t_7 = OBJ_LVAR( 1 );
  CHECK_BOUND( t_7, "name" );
  t_8 = OBJ_LVAR( 2 );
  CHECK_BOUND( t_8, "tester" );
  if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
   t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  }
  else {
   t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( t_7, t_8 ) );
  }
  CHECK_FUNC_RESULT( t_5 );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 ) );
  }
  
 }
 /* fi */
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 (void)l_lock;
 (void)l_type;
 (void)l_pair;
 (void)l_family;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) ); */
 t_2 = GF_WITH__IMPS__FLAGS;
 t_4 = GF_AND__FLAGS;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_2ARGS( t_4, a_imp__filter, a_req__filter );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_imp__filter, a_req__filter ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 a_imp__filter = t_1;
 
 /* type := Subtype( typeOfFamilies, IsAttributeStoringRep ); */
 t_2 = GF_Subtype;
 t_3 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_3, "IsAttributeStoringRep" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_2ARGS( t_2, a_typeOfFamilies, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_typeOfFamilies, t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_type = t_1;
 
 /* lock := READ_LOCK( CATEGORIES_FAMILY ); */
 t_2 = GF_READ__LOCK;
 t_3 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_3, "CATEGORIES_FAMILY" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_lock = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_4, "CATEGORIES_FAMILY" );
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
  if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
   t_6 = CALL_2ARGS( t_7, a_imp__filter, t_8 );
  }
  else {
   t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( a_imp__filter, t_8 ) );
  }
  CHECK_FUNC_RESULT( t_6 );
  CHECK_BOOL( t_6 );
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* type := Subtype( type, pair[2] ); */
   t_6 = GF_Subtype;
   C_ELM_LIST_FPL( t_7, l_pair, INTOBJ_INT(2) )
   if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
    t_5 = CALL_2ARGS( t_6, l_type, t_7 );
   }
   else {
    t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( l_type, t_7 ) );
   }
   CHECK_FUNC_RESULT( t_5 );
   l_type = t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* UNLOCK( lock ); */
 t_1 = GF_UNLOCK;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_lock );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_lock ) );
 }
 
 /* family := AtomicRecord(  ); */
 t_2 = GF_AtomicRecord;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_0ARGS( t_2 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_family = t_1;
 
 /* SET_TYPE_COMOBJ( family, type ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_family, l_type );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_family, l_type ) );
 }
 
 /* family!.NAME := IMMUTABLE_COPY_OBJ( name ); */
 t_2 = GF_IMMUTABLE__COPY__OBJ;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, a_name );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_name ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 AssComObj( l_family, R_NAME, t_1 );
 
 /* family!.REQ_FLAGS := req_filter; */
 AssComObj( l_family, R_REQ__FLAGS, a_req__filter );
 
 /* family!.IMP_FLAGS := imp_filter; */
 AssComObj( l_family, R_IMP__FLAGS, a_imp__filter );
 
 /* family!.nTYPES := 0; */
 AssComObj( l_family, R_nTYPES, INTOBJ_INT(0) );
 
 /* family!.HASH_SIZE := 32; */
 AssComObj( l_family, R_HASH__SIZE, INTOBJ_INT(32) );
 
 /* lock := WRITE_LOCK( DS_TYPE_CACHE ); */
 t_2 = GF_WRITE__LOCK;
 t_3 = GC_DS__TYPE__CACHE;
 CHECK_BOUND( t_3, "DS_TYPE_CACHE" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_lock = t_1;
 
 /* family!.TYPES := MIGRATE_RAW( [  ], DS_TYPE_CACHE ); */
 t_2 = GF_MIGRATE__RAW;
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 t_4 = GC_DS__TYPE__CACHE;
 CHECK_BOUND( t_4, "DS_TYPE_CACHE" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, t_4 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 AssComObj( l_family, R_TYPES, t_1 );
 
 /* UNLOCK( lock ); */
 t_1 = GF_UNLOCK;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_lock );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_lock ) );
 }
 
 /* family!.TYPES_LIST_FAM := MakeWriteOnceAtomic( AtomicList( 27 ) ); */
 t_2 = GF_MakeWriteOnceAtomic;
 t_4 = GF_AtomicList;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, INTOBJ_INT(27) );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( INTOBJ_INT(27) ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 AssComObj( l_family, R_TYPES__LIST__FAM, t_1 );
 
 /* return family; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_family;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_typeOfFamilies = 0;
 Obj l_name = 0;
 Obj l_req = 0;
 Obj l_imp = 0;
 Obj l_filter = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 (void)l_typeOfFamilies;
 (void)l_name;
 (void)l_req;
 (void)l_imp;
 (void)l_filter;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* if not LEN_LIST( arg ) in [ 1 .. 4 ] then */
 t_4 = GF_LEN__LIST;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_arg );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_arg ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 t_4 = Range2Check( INTOBJ_INT(1), INTOBJ_INT(4) );
 t_2 = (Obj)(UInt)(IN( t_3, t_4 ));
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "usage: NewFamily( <name> [, <req> [, <imp> [, <famfilter> ] ] ] )" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "usage: NewFamily( <name> [, <req> [, <imp> [, <famfilter> ] ] ] )" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* name := arg[1]; */
 C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(1) )
 l_name = t_1;
 
 /* if LEN_LIST( arg ) >= 2 then */
 t_3 = GF_LEN__LIST;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_arg );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_arg ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_1 = (Obj)(UInt)(! LT( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* req := FLAGS_FILTER( arg[2] ); */
  t_2 = GF_FLAGS__FILTER;
  C_ELM_LIST_FPL( t_3, a_arg, INTOBJ_INT(2) )
  if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
   t_1 = CALL_1ARGS( t_2, t_3 );
  }
  else {
   t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
  }
  CHECK_FUNC_RESULT( t_1 );
  l_req = t_1;
  
 }
 
 /* else */
 else {
  
  /* req := EMPTY_FLAGS; */
  t_1 = GC_EMPTY__FLAGS;
  CHECK_BOUND( t_1, "EMPTY_FLAGS" );
  l_req = t_1;
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) >= 3 then */
 t_3 = GF_LEN__LIST;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_arg );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_arg ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_1 = (Obj)(UInt)(! LT( t_2, INTOBJ_INT(3) ));
 if ( t_1 ) {
  
  /* imp := FLAGS_FILTER( arg[3] ); */
  t_2 = GF_FLAGS__FILTER;
  C_ELM_LIST_FPL( t_3, a_arg, INTOBJ_INT(3) )
  if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
   t_1 = CALL_1ARGS( t_2, t_3 );
  }
  else {
   t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
  }
  CHECK_FUNC_RESULT( t_1 );
  l_imp = t_1;
  
 }
 
 /* else */
 else {
  
  /* imp := EMPTY_FLAGS; */
  t_1 = GC_EMPTY__FLAGS;
  CHECK_BOUND( t_1, "EMPTY_FLAGS" );
  l_imp = t_1;
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 4 then */
 t_3 = GF_LEN__LIST;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_arg );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_arg ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(4) ));
 if ( t_1 ) {
  
  /* typeOfFamilies := Subtype( TypeOfFamilies, arg[4] ); */
  t_2 = GF_Subtype;
  t_3 = GC_TypeOfFamilies;
  CHECK_BOUND( t_3, "TypeOfFamilies" );
  C_ELM_LIST_FPL( t_4, a_arg, INTOBJ_INT(4) )
  if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
   t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  }
  else {
   t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, t_4 ) );
  }
  CHECK_FUNC_RESULT( t_1 );
  l_typeOfFamilies = t_1;
  
 }
 
 /* else */
 else {
  
  /* typeOfFamilies := TypeOfFamilies; */
  t_1 = GC_TypeOfFamilies;
  CHECK_BOUND( t_1, "TypeOfFamilies" );
  l_typeOfFamilies = t_1;
  
 }
 /* fi */
 
 /* return NEW_FAMILY( typeOfFamilies, name, req, imp ); */
 t_2 = GF_NEW__FAMILY;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_4ARGS( t_2, l_typeOfFamilies, l_name, l_req, l_imp );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( l_typeOfFamilies, l_name, l_req, l_imp ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 7 */
static Obj  HdlrFunc7 (
 Obj  self,
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
 (void)l_lock;
 (void)l_hash;
 (void)l_cache;
 (void)l_cached;
 (void)l_type;
 (void)l_ncache;
 (void)l_ncl;
 (void)l_t;
 (void)l_i;
 (void)l_match;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* lock := WRITE_LOCK( DS_TYPE_CACHE ); */
 t_2 = GF_WRITE__LOCK;
 t_3 = GC_DS__TYPE__CACHE;
 CHECK_BOUND( t_3, "DS_TYPE_CACHE" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_lock = t_1;
 
 /* cache := family!.TYPES; */
 t_1 = ElmComObj( a_family, R_TYPES );
 l_cache = t_1;
 
 /* hash := HASH_FLAGS( flags ) mod family!.HASH_SIZE + 1; */
 t_4 = GF_HASH__FLAGS;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_flags );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_flags ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 t_4 = ElmComObj( a_family, R_HASH__SIZE );
 t_2 = MOD( t_3, t_4 );
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 l_hash = t_1;
 
 /* if IsBound( cache[hash] ) then */
 CHECK_INT_POS( l_hash );
 t_2 = C_ISB_LIST( l_cache, l_hash );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* cached := cache[hash]; */
  C_ELM_LIST_FPL( t_1, l_cache, l_hash )
  l_cached = t_1;
  
  /* if IS_EQUAL_FLAGS( flags, cached![2] ) then */
  t_3 = GF_IS__EQUAL__FLAGS;
  t_4 = ElmPosObj( l_cached, 2 );
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_2ARGS( t_3, a_flags, t_4 );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_flags, t_4 ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_BOOL( t_2 );
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* flags := cached![2]; */
   t_1 = ElmPosObj( l_cached, 2 );
   a_flags = t_1;
   
   /* if IS_IDENTICAL_OBJ( data, cached![3] ) and IS_IDENTICAL_OBJ( TypeOfTypes, TYPE_OBJ( cached ) ) then */
   t_4 = GF_IS__IDENTICAL__OBJ;
   t_5 = ElmPosObj( l_cached, 3 );
   if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
    t_3 = CALL_2ARGS( t_4, a_data, t_5 );
   }
   else {
    t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_data, t_5 ) );
   }
   CHECK_FUNC_RESULT( t_3 );
   CHECK_BOOL( t_3 );
   t_2 = (Obj)(UInt)(t_3 != False);
   t_1 = t_2;
   if ( t_1 ) {
    t_5 = GF_IS__IDENTICAL__OBJ;
    t_6 = GC_TypeOfTypes;
    CHECK_BOUND( t_6, "TypeOfTypes" );
    t_8 = GF_TYPE__OBJ;
    if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
     t_7 = CALL_1ARGS( t_8, l_cached );
    }
    else {
     t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( l_cached ) );
    }
    CHECK_FUNC_RESULT( t_7 );
    if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
     t_4 = CALL_2ARGS( t_5, t_6, t_7 );
    }
    else {
     t_4 = DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( t_6, t_7 ) );
    }
    CHECK_FUNC_RESULT( t_4 );
    CHECK_BOOL( t_4 );
    t_3 = (Obj)(UInt)(t_4 != False);
    t_1 = t_3;
   }
   if ( t_1 ) {
    
    /* if IS_IDENTICAL_OBJ( parent, fail ) then */
    t_3 = GF_IS__IDENTICAL__OBJ;
    t_4 = GC_fail;
    CHECK_BOUND( t_4, "fail" );
    if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
     t_2 = CALL_2ARGS( t_3, a_parent, t_4 );
    }
    else {
     t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_parent, t_4 ) );
    }
    CHECK_FUNC_RESULT( t_2 );
    CHECK_BOOL( t_2 );
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* match := true; */
     t_1 = True;
     l_match = t_1;
     
     /* for i in [ 5 .. LEN_POSOBJ( cached ) ] do */
     t_3 = GF_LEN__POSOBJ;
     if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
      t_2 = CALL_1ARGS( t_3, l_cached );
     }
     else {
      t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( l_cached ) );
     }
     CHECK_FUNC_RESULT( t_2 );
     CHECK_INT_SMALL( t_2 );
     for ( t_1 = INTOBJ_INT(5);
           ((Int)t_1) <= ((Int)t_2);
           t_1 = (Obj)(((UInt)t_1)+4) ) {
      l_i = t_1;
      
      /* if IsBound( cached![i] ) then */
      t_4 = IsbPosObj( l_cached, INT_INTOBJ(l_i) ) ? True : False;
      t_3 = (Obj)(UInt)(t_4 != False);
      if ( t_3 ) {
       
       /* match := false; */
       t_3 = False;
       l_match = t_3;
       
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
      CHECK_BOUND( t_2, "NEW_TYPE_CACHE_HIT" );
      C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
      AssGVar( G_NEW__TYPE__CACHE__HIT, t_1 );
      
      /* UNLOCK( lock ); */
      t_1 = GF_UNLOCK;
      if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
       CALL_1ARGS( t_1, l_lock );
      }
      else {
       DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_lock ) );
      }
      
      /* return cached; */
      SWITCH_TO_OLD_FRAME(oldFrame);
      return l_cached;
      
     }
     /* fi */
     
    }
    /* fi */
    
    /* if LEN_POSOBJ( parent ) = LEN_POSOBJ( cached ) then */
    t_3 = GF_LEN__POSOBJ;
    if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
     t_2 = CALL_1ARGS( t_3, a_parent );
    }
    else {
     t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_parent ) );
    }
    CHECK_FUNC_RESULT( t_2 );
    t_4 = GF_LEN__POSOBJ;
    if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
     t_3 = CALL_1ARGS( t_4, l_cached );
    }
    else {
     t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( l_cached ) );
    }
    CHECK_FUNC_RESULT( t_3 );
    t_1 = (Obj)(UInt)(EQ( t_2, t_3 ));
    if ( t_1 ) {
     
     /* match := true; */
     t_1 = True;
     l_match = t_1;
     
     /* for i in [ 5 .. LEN_POSOBJ( parent ) ] do */
     t_3 = GF_LEN__POSOBJ;
     if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
      t_2 = CALL_1ARGS( t_3, a_parent );
     }
     else {
      t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_parent ) );
     }
     CHECK_FUNC_RESULT( t_2 );
     CHECK_INT_SMALL( t_2 );
     for ( t_1 = INTOBJ_INT(5);
           ((Int)t_1) <= ((Int)t_2);
           t_1 = (Obj)(((UInt)t_1)+4) ) {
      l_i = t_1;
      
      /* if IsBound( parent![i] ) <> IsBound( cached![i] ) then */
      t_4 = IsbPosObj( a_parent, INT_INTOBJ(l_i) ) ? True : False;
      t_5 = IsbPosObj( l_cached, INT_INTOBJ(l_i) ) ? True : False;
      t_3 = (Obj)(UInt)( ! EQ( t_4, t_5 ));
      if ( t_3 ) {
       
       /* match := false; */
       t_3 = False;
       l_match = t_3;
       
       /* break; */
       break;
       
      }
      /* fi */
      
      /* if IsBound( parent![i] ) and IsBound( cached![i] ) and not IS_IDENTICAL_OBJ( parent![i], cached![i] ) then */
      t_6 = IsbPosObj( a_parent, INT_INTOBJ(l_i) ) ? True : False;
      t_5 = (Obj)(UInt)(t_6 != False);
      t_4 = t_5;
      if ( t_4 ) {
       t_7 = IsbPosObj( l_cached, INT_INTOBJ(l_i) ) ? True : False;
       t_6 = (Obj)(UInt)(t_7 != False);
       t_4 = t_6;
      }
      t_3 = t_4;
      if ( t_3 ) {
       t_8 = GF_IS__IDENTICAL__OBJ;
       t_9 = ElmPosObj( a_parent, INT_INTOBJ(l_i) );
       t_10 = ElmPosObj( l_cached, INT_INTOBJ(l_i) );
       if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
        t_7 = CALL_2ARGS( t_8, t_9, t_10 );
       }
       else {
        t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( t_9, t_10 ) );
       }
       CHECK_FUNC_RESULT( t_7 );
       CHECK_BOOL( t_7 );
       t_6 = (Obj)(UInt)(t_7 != False);
       t_5 = (Obj)(UInt)( ! ((Int)t_6) );
       t_3 = t_5;
      }
      if ( t_3 ) {
       
       /* match := false; */
       t_3 = False;
       l_match = t_3;
       
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
      CHECK_BOUND( t_2, "NEW_TYPE_CACHE_HIT" );
      C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
      AssGVar( G_NEW__TYPE__CACHE__HIT, t_1 );
      
      /* UNLOCK( lock ); */
      t_1 = GF_UNLOCK;
      if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
       CALL_1ARGS( t_1, l_lock );
      }
      else {
       DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_lock ) );
      }
      
      /* return cached; */
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
  CHECK_BOUND( t_2, "NEW_TYPE_CACHE_MISS" );
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  AssGVar( G_NEW__TYPE__CACHE__MISS, t_1 );
  
 }
 /* fi */
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" );
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* if NEW_TYPE_NEXT_ID >= NEW_TYPE_ID_LIMIT then */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" );
 t_3 = GC_NEW__TYPE__ID__LIMIT;
 CHECK_BOUND( t_3, "NEW_TYPE_ID_LIMIT" );
 t_1 = (Obj)(UInt)(! LT( t_2, t_3 ));
 if ( t_1 ) {
  
  /* GASMAN( "collect" ); */
  t_1 = GF_GASMAN;
  t_2 = MakeString( "collect" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
  /* FLUSH_ALL_METHOD_CACHES(  ); */
  t_1 = GF_FLUSH__ALL__METHOD__CACHES;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_0ARGS( t_1 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
  }
  
  /* NEW_TYPE_NEXT_ID := COMPACT_TYPE_IDS(  ); */
  t_2 = GF_COMPACT__TYPE__IDS;
  if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
   t_1 = CALL_0ARGS( t_2 );
  }
  else {
   t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( ) );
  }
  CHECK_FUNC_RESULT( t_1 );
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
 
 /* data := MakeReadOnlyObj( data ); */
 t_2 = GF_MakeReadOnlyObj;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, a_data );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_data ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 a_data = t_1;
 
 /* type[3] := data; */
 C_ASS_LIST_FPL( l_type, INTOBJ_INT(3), a_data )
 
 /* type[4] := NEW_TYPE_NEXT_ID; */
 t_1 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_1, "NEW_TYPE_NEXT_ID" );
 C_ASS_LIST_FPL( l_type, INTOBJ_INT(4), t_1 )
 
 /* if not IS_IDENTICAL_OBJ( parent, fail ) then */
 t_4 = GF_IS__IDENTICAL__OBJ;
 t_5 = GC_fail;
 CHECK_BOUND( t_5, "fail" );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_2ARGS( t_4, a_parent, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_parent, t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* for i in [ 5 .. LEN_POSOBJ( parent ) ] do */
  t_3 = GF_LEN__POSOBJ;
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_1ARGS( t_3, a_parent );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_parent ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_INT_SMALL( t_2 );
  for ( t_1 = INTOBJ_INT(5);
        ((Int)t_1) <= ((Int)t_2);
        t_1 = (Obj)(((UInt)t_1)+4) ) {
   l_i = t_1;
   
   /* if IsBound( parent![i] ) and not IsBound( type[i] ) then */
   t_5 = IsbPosObj( a_parent, INT_INTOBJ(l_i) ) ? True : False;
   t_4 = (Obj)(UInt)(t_5 != False);
   t_3 = t_4;
   if ( t_3 ) {
    t_7 = C_ISB_LIST( l_type, l_i );
    t_6 = (Obj)(UInt)(t_7 != False);
    t_5 = (Obj)(UInt)( ! ((Int)t_6) );
    t_3 = t_5;
   }
   if ( t_3 ) {
    
    /* type[i] := parent![i]; */
    t_3 = ElmPosObj( a_parent, INT_INTOBJ(l_i) );
    C_ASS_LIST_FPL( l_type, l_i, t_3 )
    
   }
   /* fi */
   
  }
  /* od */
  
 }
 /* fi */
 
 /* SET_TYPE_POSOBJ( type, TypeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 t_2 = GC_TypeOfTypes;
 CHECK_BOUND( t_2, "TypeOfTypes" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_type, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_type, t_2 ) );
 }
 
 /* if 3 * family!.nTYPES > family!.HASH_SIZE then */
 t_3 = ElmComObj( a_family, R_nTYPES );
 C_PROD_FIA( t_2, INTOBJ_INT(3), t_3 )
 t_3 = ElmComObj( a_family, R_HASH__SIZE );
 t_1 = (Obj)(UInt)(LT( t_3, t_2 ));
 if ( t_1 ) {
  
  /* ncache := [  ]; */
  t_1 = NEW_PLIST( T_PLIST, 0 );
  SET_LEN_PLIST( t_1, 0 );
  l_ncache = t_1;
  
  /* MIGRATE_RAW( ncache, DS_TYPE_CACHE ); */
  t_1 = GF_MIGRATE__RAW;
  t_2 = GC_DS__TYPE__CACHE;
  CHECK_BOUND( t_2, "DS_TYPE_CACHE" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, l_ncache, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_ncache, t_2 ) );
  }
  
  /* ncl := 3 * family!.HASH_SIZE + 1; */
  t_3 = ElmComObj( a_family, R_HASH__SIZE );
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
   t_9 = ElmPosObj( l_t, 2 );
   if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
    t_7 = CALL_1ARGS( t_8, t_9 );
   }
   else {
    t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( t_9 ) );
   }
   CHECK_FUNC_RESULT( t_7 );
   t_6 = MOD( t_7, l_ncl );
   C_SUM_FIA( t_5, t_6, INTOBJ_INT(1) )
   CHECK_INT_POS( t_5 );
   C_ASS_LIST_FPL( l_ncache, t_5, l_t )
   
  }
  /* od */
  
  /* family!.HASH_SIZE := ncl; */
  AssComObj( a_family, R_HASH__SIZE, l_ncl );
  
  /* family!.TYPES := ncache; */
  AssComObj( a_family, R_TYPES, l_ncache );
  
  /* ncache[HASH_FLAGS( flags ) mod ncl + 1] := type; */
  t_4 = GF_HASH__FLAGS;
  if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
   t_3 = CALL_1ARGS( t_4, a_flags );
  }
  else {
   t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_flags ) );
  }
  CHECK_FUNC_RESULT( t_3 );
  t_2 = MOD( t_3, l_ncl );
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  CHECK_INT_POS( t_1 );
  C_ASS_LIST_FPL( l_ncache, t_1, l_type )
  
 }
 
 /* else */
 else {
  
  /* cache[hash] := type; */
  C_ASS_LIST_FPL( l_cache, l_hash, l_type )
  
 }
 /* fi */
 
 /* family!.nTYPES := family!.nTYPES + 1; */
 t_2 = ElmComObj( a_family, R_nTYPES );
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssComObj( a_family, R_nTYPES, t_1 );
 
 /* MakeReadOnlySingleObj( type ); */
 t_1 = GF_MakeReadOnlySingleObj;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_type );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_type ) );
 }
 
 /* UNLOCK( lock ); */
 t_1 = GF_UNLOCK;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_lock );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_lock ) );
 }
 
 /* return type; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self,
 Obj  args )
{
 Obj  a_family;
 Obj  a_filter;
 Obj  a_data;
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
 CHECK_NR_AT_LEAST_ARGS( 3, args )
 a_family = ELM_PLIST( args, 1 );
 a_filter = ELM_PLIST( args, 2 );
 Obj x_temp_range = Range2Check(INTOBJ_INT(3), INTOBJ_INT(LEN_PLIST(args)));
 a_data = ELMS_LIST(args , x_temp_range);
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* if not IsFamily( family ) then */
 t_4 = GF_IsFamily;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_family );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_family ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<family> must be a family" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "<family> must be a family" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* if LEN_LIST( data ) = 0 then */
 t_3 = GF_LEN__LIST;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_data );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_data ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(0) ));
 if ( t_1 ) {
  
  /* data := fail; */
  t_1 = GC_fail;
  CHECK_BOUND( t_1, "fail" );
  a_data = t_1;
  
 }
 
 /* elif LEN_LIST( data ) = 1 then */
 else {
  t_3 = GF_LEN__LIST;
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_1ARGS( t_3, a_data );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_data ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(1) ));
  if ( t_1 ) {
   
   /* data := data[1]; */
   C_ELM_LIST_FPL( t_1, a_data, INTOBJ_INT(1) )
   a_data = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "usage: NewType( <family>, <filter> [, <data> ] )" ); */
   t_1 = GF_Error;
   t_2 = MakeString( "usage: NewType( <family>, <filter> [, <data> ] )" );
   if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
    CALL_1ARGS( t_1, t_2 );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
   }
   
  }
 }
 /* fi */
 
 /* return NEW_TYPE( family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), data, fail ); */
 t_2 = GF_NEW__TYPE;
 t_4 = GF_WITH__IMPS__FLAGS;
 t_6 = GF_AND__FLAGS;
 t_7 = ElmComObj( a_family, R_IMP__FLAGS );
 t_9 = GF_FLAGS__FILTER;
 if ( TNUM_OBJ( t_9 ) == T_FUNCTION ) {
  t_8 = CALL_1ARGS( t_9, a_filter );
 }
 else {
  t_8 = DoOperation2Args( CallFuncListOper, t_9, NewPlistFromArgs( a_filter ) );
 }
 CHECK_FUNC_RESULT( t_8 );
 if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 }
 else {
  t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( t_7, t_8 ) );
 }
 CHECK_FUNC_RESULT( t_5 );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 t_4 = GC_fail;
 CHECK_BOUND( t_4, "fail" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_4ARGS( t_2, a_family, t_3, a_data, t_4 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_family, t_3, a_data, t_4 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 9 */
static Obj  HdlrFunc9 (
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
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_type );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_type ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "<type> must be a type" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* return NEW_TYPE( type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), type![3], type ); */
 t_2 = GF_NEW__TYPE;
 t_3 = ElmPosObj( a_type, 1 );
 t_5 = GF_WITH__IMPS__FLAGS;
 t_7 = GF_AND__FLAGS;
 t_8 = ElmPosObj( a_type, 2 );
 t_10 = GF_FLAGS__FILTER;
 if ( TNUM_OBJ( t_10 ) == T_FUNCTION ) {
  t_9 = CALL_1ARGS( t_10, a_filter );
 }
 else {
  t_9 = DoOperation2Args( CallFuncListOper, t_10, NewPlistFromArgs( a_filter ) );
 }
 CHECK_FUNC_RESULT( t_9 );
 if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
 }
 else {
  t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( t_8, t_9 ) );
 }
 CHECK_FUNC_RESULT( t_6 );
 if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
  t_4 = CALL_1ARGS( t_5, t_6 );
 }
 else {
  t_4 = DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( t_6 ) );
 }
 CHECK_FUNC_RESULT( t_4 );
 t_5 = ElmPosObj( a_type, 3 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, a_type );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, t_4, t_5, a_type ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 10 */
static Obj  HdlrFunc10 (
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
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_type );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_type ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "<type> must be a type" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* return NEW_TYPE( type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), type![3], type ); */
 t_2 = GF_NEW__TYPE;
 t_3 = ElmPosObj( a_type, 1 );
 t_5 = GF_SUB__FLAGS;
 t_6 = ElmPosObj( a_type, 2 );
 t_8 = GF_FLAGS__FILTER;
 if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
  t_7 = CALL_1ARGS( t_8, a_filter );
 }
 else {
  t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( a_filter ) );
 }
 CHECK_FUNC_RESULT( t_7 );
 if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
  t_4 = CALL_2ARGS( t_5, t_6, t_7 );
 }
 else {
  t_4 = DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( t_6, t_7 ) );
 }
 CHECK_FUNC_RESULT( t_4 );
 t_5 = ElmPosObj( a_type, 3 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, a_type );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, t_4, t_5, a_type ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 11 */
static Obj  HdlrFunc11 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return K![1]; */
 t_1 = ElmPosObj( a_K, 1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return K![2]; */
 t_1 = ElmPosObj( a_K, 2 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 13 */
static Obj  HdlrFunc13 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return K![3]; */
 t_1 = ElmPosObj( a_K, 3 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 14 */
static Obj  HdlrFunc14 (
 Obj  self,
 Obj  a_K,
 Obj  a_data )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* StrictBindOnce( K, 3, MakeImmutable( data ) ); */
 t_1 = GF_StrictBindOnce;
 t_3 = GF_MakeImmutable;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_data );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_data ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, a_K, INTOBJ_INT(3), t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_K, INTOBJ_INT(3), t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 15 */
static Obj  HdlrFunc15 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return FlagsType( TypeObj( obj ) ); */
 t_2 = GF_FlagsType;
 t_4 = GF_TypeObj;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_obj );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 16 */
static Obj  HdlrFunc16 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return DataType( TypeObj( obj ) ); */
 t_2 = GF_DataType;
 t_4 = GF_TypeObj;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_obj );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 17 */
static Obj  HdlrFunc17 (
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
 (void)l_flags;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_type );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_type ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "<type> must be a type" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* flags := FlagsType( type ); */
 t_2 = GF_FlagsType;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, a_type );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_type ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_flags = t_1;
 
 /* if IS_LIST( obj ) then */
 t_3 = GF_IS__LIST;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_obj );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CHECK_BOOL( t_2 );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* if IS_SUBSET_FLAGS( flags, IsAtomicPositionalObjectRepFlags ) then */
  t_3 = GF_IS__SUBSET__FLAGS;
  t_4 = GC_IsAtomicPositionalObjectRepFlags;
  CHECK_BOUND( t_4, "IsAtomicPositionalObjectRepFlags" );
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_2ARGS( t_3, l_flags, t_4 );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( l_flags, t_4 ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_BOOL( t_2 );
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* FORCE_SWITCH_OBJ( obj, FixedAtomicList( obj ) ); */
   t_1 = GF_FORCE__SWITCH__OBJ;
   t_3 = GF_FixedAtomicList;
   if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
    t_2 = CALL_1ARGS( t_3, a_obj );
   }
   else {
    t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
   }
   CHECK_FUNC_RESULT( t_2 );
   if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
    CALL_2ARGS( t_1, a_obj, t_2 );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, t_2 ) );
   }
   
  }
  /* fi */
  
 }
 
 /* elif IS_REC( obj ) then */
 else {
  t_3 = GF_IS__REC;
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_1ARGS( t_3, a_obj );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_BOOL( t_2 );
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* if IS_ATOMIC_RECORD( obj ) then */
   t_3 = GF_IS__ATOMIC__RECORD;
   if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
    t_2 = CALL_1ARGS( t_3, a_obj );
   }
   else {
    t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
   }
   CHECK_FUNC_RESULT( t_2 );
   CHECK_BOOL( t_2 );
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* if IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags ) then */
    t_3 = GF_IS__SUBSET__FLAGS;
    t_4 = GC_IsNonAtomicComponentObjectRepFlags;
    CHECK_BOUND( t_4, "IsNonAtomicComponentObjectRepFlags" );
    if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
     t_2 = CALL_2ARGS( t_3, l_flags, t_4 );
    }
    else {
     t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( l_flags, t_4 ) );
    }
    CHECK_FUNC_RESULT( t_2 );
    CHECK_BOOL( t_2 );
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* FORCE_SWITCH_OBJ( obj, FromAtomicRecord( obj ) ); */
     t_1 = GF_FORCE__SWITCH__OBJ;
     t_3 = GF_FromAtomicRecord;
     if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
      t_2 = CALL_1ARGS( t_3, a_obj );
     }
     else {
      t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
     }
     CHECK_FUNC_RESULT( t_2 );
     if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
      CALL_2ARGS( t_1, a_obj, t_2 );
     }
     else {
      DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, t_2 ) );
     }
     
    }
    /* fi */
    
   }
   
   /* elif not IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags ) then */
   else {
    t_4 = GF_IS__SUBSET__FLAGS;
    t_5 = GC_IsNonAtomicComponentObjectRepFlags;
    CHECK_BOUND( t_5, "IsNonAtomicComponentObjectRepFlags" );
    if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
     t_3 = CALL_2ARGS( t_4, l_flags, t_5 );
    }
    else {
     t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( l_flags, t_5 ) );
    }
    CHECK_FUNC_RESULT( t_3 );
    CHECK_BOOL( t_3 );
    t_2 = (Obj)(UInt)(t_3 != False);
    t_1 = (Obj)(UInt)( ! ((Int)t_2) );
    if ( t_1 ) {
     
     /* FORCE_SWITCH_OBJ( obj, AtomicRecord( obj ) ); */
     t_1 = GF_FORCE__SWITCH__OBJ;
     t_3 = GF_AtomicRecord;
     if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
      t_2 = CALL_1ARGS( t_3, a_obj );
     }
     else {
      t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
     }
     CHECK_FUNC_RESULT( t_2 );
     if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
      CALL_2ARGS( t_1, a_obj, t_2 );
     }
     else {
      DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, t_2 ) );
     }
     
    }
   }
   /* fi */
   
  }
 }
 /* fi */
 
 /* if IS_LIST( obj ) then */
 t_3 = GF_IS__LIST;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_obj );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CHECK_BOOL( t_2 );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, a_obj, a_type );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, a_type ) );
  }
  
 }
 
 /* elif IS_REC( obj ) then */
 else {
  t_3 = GF_IS__REC;
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_1ARGS( t_3, a_obj );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_BOOL( t_2 );
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
    CALL_2ARGS( t_1, a_obj, a_type );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, a_type ) );
   }
   
  }
 }
 /* fi */
 
 /* if not IsNoImmediateMethodsObject( obj ) then */
 t_4 = GF_IsNoImmediateMethodsObject;
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, a_obj );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* RunImmediateMethods( obj, type![2] ); */
  t_1 = GF_RunImmediateMethods;
  t_2 = ElmPosObj( a_type, 2 );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, a_obj, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, t_2 ) );
  }
  
 }
 /* fi */
 
 /* if IsReadOnlyPositionalObjectRep( obj ) then */
 t_3 = GF_IsReadOnlyPositionalObjectRep;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_obj );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CHECK_BOOL( t_2 );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* MakeReadOnlySingleObj( obj ); */
  t_1 = GF_MakeReadOnlySingleObj;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, a_obj );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj ) );
  }
  
 }
 /* fi */
 
 /* return obj; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_obj;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 18 */
static Obj  HdlrFunc18 (
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
 (void)l_type;
 (void)l_newtype;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* type := TYPE_OBJ( obj ); */
 t_2 = GF_TYPE__OBJ;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, a_obj );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_type = t_1;
 
 /* newtype := Subtype( type, filter ); */
 t_2 = GF_Subtype;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_2ARGS( t_2, l_type, a_filter );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( l_type, a_filter ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_newtype = t_1;
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_obj );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CHECK_BOOL( t_2 );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, newtype ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, a_obj, l_newtype );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, l_newtype ) );
  }
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_1ARGS( t_3, a_obj );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_BOOL( t_2 );
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, newtype ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
    CALL_2ARGS( t_1, a_obj, l_newtype );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, l_newtype ) );
   }
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
    t_2 = CALL_1ARGS( t_3, a_obj );
   }
   else {
    t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
   }
   CHECK_FUNC_RESULT( t_2 );
   CHECK_BOOL( t_2 );
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, newtype ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
     CALL_2ARGS( t_1, a_obj, l_newtype );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, l_newtype ) );
    }
    
   }
   
   /* else */
   else {
    
    /* ErrorNoReturn( "cannot set filter for internal object" ); */
    t_1 = GF_ErrorNoReturn;
    t_2 = MakeString( "cannot set filter for internal object" );
    if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
     CALL_1ARGS( t_1, t_2 );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
    }
    
   }
  }
 }
 /* fi */
 
 /* if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj )) then */
 t_4 = GC_IGNORE__IMMEDIATE__METHODS;
 CHECK_BOUND( t_4, "IGNORE_IMMEDIATE_METHODS" );
 CHECK_BOOL( t_4 );
 t_3 = (Obj)(UInt)(t_4 != False);
 t_2 = t_3;
 if ( ! t_2 ) {
  t_6 = GF_IsNoImmediateMethodsObject;
  if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
   t_5 = CALL_1ARGS( t_6, a_obj );
  }
  else {
   t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( a_obj ) );
  }
  CHECK_FUNC_RESULT( t_5 );
  CHECK_BOOL( t_5 );
  t_4 = (Obj)(UInt)(t_5 != False);
  t_2 = t_4;
 }
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) ); */
  t_1 = GF_RunImmediateMethods;
  t_3 = GF_SUB__FLAGS;
  t_4 = ElmPosObj( l_newtype, 2 );
  t_5 = ElmPosObj( l_type, 2 );
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_2ARGS( t_3, t_4, t_5 );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( t_4, t_5 ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, a_obj, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, t_2 ) );
  }
  
 }
 /* fi */
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 19 */
static Obj  HdlrFunc19 (
 Obj  self,
 Obj  a_obj,
 Obj  a_filter )
{
 Obj l_type = 0;
 Obj l_newtype = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 (void)l_type;
 (void)l_newtype;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* if IS_AND_FILTER( filter ) then */
 t_3 = GF_IS__AND__FILTER;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_filter );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_filter ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CHECK_BOOL( t_2 );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* Error( "You can't reset an \"and-filter\". Reset components individually." ); */
  t_1 = GF_Error;
  t_2 = MakeString( "You can't reset an \"and-filter\". Reset components individually." );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* type := TYPE_OBJ( obj ); */
 t_2 = GF_TYPE__OBJ;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, a_obj );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_type = t_1;
 
 /* newtype := SupType( type, filter ); */
 t_2 = GF_SupType;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_2ARGS( t_2, l_type, a_filter );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( l_type, a_filter ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_newtype = t_1;
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( t_3, a_obj );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CHECK_BOOL( t_2 );
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, newtype ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, a_obj, l_newtype );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, l_newtype ) );
  }
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
   t_2 = CALL_1ARGS( t_3, a_obj );
  }
  else {
   t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
  }
  CHECK_FUNC_RESULT( t_2 );
  CHECK_BOOL( t_2 );
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, newtype ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
    CALL_2ARGS( t_1, a_obj, l_newtype );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, l_newtype ) );
   }
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
    t_2 = CALL_1ARGS( t_3, a_obj );
   }
   else {
    t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( a_obj ) );
   }
   CHECK_FUNC_RESULT( t_2 );
   CHECK_BOOL( t_2 );
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, newtype ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
     CALL_2ARGS( t_1, a_obj, l_newtype );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( a_obj, l_newtype ) );
    }
    
   }
   
   /* else */
   else {
    
    /* Error( "cannot reset filter for internal object" ); */
    t_1 = GF_Error;
    t_2 = MakeString( "cannot reset filter for internal object" );
    if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
     CALL_1ARGS( t_1, t_2 );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
    }
    
   }
  }
 }
 /* fi */
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 20 */
static Obj  HdlrFunc20 (
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
 (void)l_obj;
 (void)l_type;
 (void)l_flags;
 (void)l_attr;
 (void)l_val;
 (void)l_i;
 (void)l_extra;
 (void)l_nflags;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* obj := arg[1]; */
 C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(1) )
 l_obj = t_1;
 
 /* type := arg[2]; */
 C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(2) )
 l_type = t_1;
 
 /* flags := FlagsType( type ); */
 t_2 = GF_FlagsType;
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, l_type );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( l_type ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_flags = t_1;
 
 /* extra := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 l_extra = t_1;
 
 /* if not IS_SUBSET_FLAGS( flags, IsAttributeStoringRepFlags ) then */
 t_4 = GF_IS__SUBSET__FLAGS;
 t_5 = GC_IsAttributeStoringRepFlags;
 CHECK_BOUND( t_5, "IsAttributeStoringRepFlags" );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_2ARGS( t_4, l_flags, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( l_flags, t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 CHECK_BOOL( t_3 );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* extra := arg{[ 3 .. LEN_LIST( arg ) ]}; */
  t_4 = GF_LEN__LIST;
  if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
   t_3 = CALL_1ARGS( t_4, a_arg );
  }
  else {
   t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( a_arg ) );
  }
  CHECK_FUNC_RESULT( t_3 );
  t_2 = Range2Check( INTOBJ_INT(3), t_3 );
  t_1 = ElmsListCheck( a_arg, t_2 );
  l_extra = t_1;
  
  /* INFO_OWA( "#W ObjectifyWithAttributes called ", "for non-attribute storing rep\n" ); */
  t_1 = GF_INFO__OWA;
  t_2 = MakeString( "#W ObjectifyWithAttributes called " );
  t_3 = MakeString( "for non-attribute storing rep\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, t_2, t_3 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
  }
  
  /* Objectify( type, obj ); */
  t_1 = GF_Objectify;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, l_type, l_obj );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_type, l_obj ) );
  }
  
 }
 
 /* else */
 else {
  
  /* nflags := EMPTY_FLAGS; */
  t_1 = GC_EMPTY__FLAGS;
  CHECK_BOUND( t_1, "EMPTY_FLAGS" );
  l_nflags = t_1;
  
  /* for i in [ 3, 5 .. LEN_LIST( arg ) - 1 ] do */
  t_7 = GF_LEN__LIST;
  if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
   t_6 = CALL_1ARGS( t_7, a_arg );
  }
  else {
   t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( a_arg ) );
  }
  CHECK_FUNC_RESULT( t_6 );
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
   CHECK_INT_POS( l_i );
   C_ELM_LIST_FPL( t_5, a_arg, l_i )
   l_attr = t_5;
   
   /* val := arg[i + 1]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_6 );
   C_ELM_LIST_FPL( t_5, a_arg, t_6 )
   l_val = t_5;
   
   /* if 0 <> FLAG1_FILTER( attr ) then */
   t_7 = GF_FLAG1__FILTER;
   if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
    t_6 = CALL_1ARGS( t_7, l_attr );
   }
   else {
    t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( l_attr ) );
   }
   CHECK_FUNC_RESULT( t_6 );
   t_5 = (Obj)(UInt)( ! EQ( INTOBJ_INT(0), t_6 ));
   if ( t_5 ) {
    
    /* if val then */
    CHECK_BOOL( l_val );
    t_5 = (Obj)(UInt)(l_val != False);
    if ( t_5 ) {
     
     /* nflags := AND_FLAGS( nflags, FLAGS_FILTER( attr ) ); */
     t_6 = GF_AND__FLAGS;
     t_8 = GF_FLAGS__FILTER;
     if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
      t_7 = CALL_1ARGS( t_8, l_attr );
     }
     else {
      t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( l_attr ) );
     }
     CHECK_FUNC_RESULT( t_7 );
     if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
      t_5 = CALL_2ARGS( t_6, l_nflags, t_7 );
     }
     else {
      t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( l_nflags, t_7 ) );
     }
     CHECK_FUNC_RESULT( t_5 );
     l_nflags = t_5;
     
    }
    
    /* else */
    else {
     
     /* nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) ); */
     t_6 = GF_AND__FLAGS;
     t_8 = GF_FLAGS__FILTER;
     t_10 = GF_Tester;
     if ( TNUM_OBJ( t_10 ) == T_FUNCTION ) {
      t_9 = CALL_1ARGS( t_10, l_attr );
     }
     else {
      t_9 = DoOperation2Args( CallFuncListOper, t_10, NewPlistFromArgs( l_attr ) );
     }
     CHECK_FUNC_RESULT( t_9 );
     if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
      t_7 = CALL_1ARGS( t_8, t_9 );
     }
     else {
      t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( t_9 ) );
     }
     CHECK_FUNC_RESULT( t_7 );
     if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
      t_5 = CALL_2ARGS( t_6, l_nflags, t_7 );
     }
     else {
      t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( l_nflags, t_7 ) );
     }
     CHECK_FUNC_RESULT( t_5 );
     l_nflags = t_5;
     
    }
    /* fi */
    
   }
   
   /* elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2 ) ) <> LENGTH_SETTER_METHODS_2 then */
   else {
    t_7 = GF_LEN__LIST;
    t_9 = GF_METHODS__OPERATION;
    t_11 = GF_Setter;
    if ( TNUM_OBJ( t_11 ) == T_FUNCTION ) {
     t_10 = CALL_1ARGS( t_11, l_attr );
    }
    else {
     t_10 = DoOperation2Args( CallFuncListOper, t_11, NewPlistFromArgs( l_attr ) );
    }
    CHECK_FUNC_RESULT( t_10 );
    if ( TNUM_OBJ( t_9 ) == T_FUNCTION ) {
     t_8 = CALL_2ARGS( t_9, t_10, INTOBJ_INT(2) );
    }
    else {
     t_8 = DoOperation2Args( CallFuncListOper, t_9, NewPlistFromArgs( t_10, INTOBJ_INT(2) ) );
    }
    CHECK_FUNC_RESULT( t_8 );
    if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
     t_6 = CALL_1ARGS( t_7, t_8 );
    }
    else {
     t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( t_8 ) );
    }
    CHECK_FUNC_RESULT( t_6 );
    t_7 = GC_LENGTH__SETTER__METHODS__2;
    CHECK_BOUND( t_7, "LENGTH_SETTER_METHODS_2" );
    t_5 = (Obj)(UInt)( ! EQ( t_6, t_7 ));
    if ( t_5 ) {
     
     /* ADD_LIST( extra, attr ); */
     t_5 = GF_ADD__LIST;
     if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
      CALL_2ARGS( t_5, l_extra, l_attr );
     }
     else {
      DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( l_extra, l_attr ) );
     }
     
     /* ADD_LIST( extra, val ); */
     t_5 = GF_ADD__LIST;
     if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
      CALL_2ARGS( t_5, l_extra, l_val );
     }
     else {
      DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( l_extra, l_val ) );
     }
     
    }
    
    /* else */
    else {
     
     /* obj.(NAME_FUNC( attr )) := IMMUTABLE_COPY_OBJ( val ); */
     t_6 = GF_NAME__FUNC;
     if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
      t_5 = CALL_1ARGS( t_6, l_attr );
     }
     else {
      t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( l_attr ) );
     }
     CHECK_FUNC_RESULT( t_5 );
     t_7 = GF_IMMUTABLE__COPY__OBJ;
     if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
      t_6 = CALL_1ARGS( t_7, l_val );
     }
     else {
      t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( l_val ) );
     }
     CHECK_FUNC_RESULT( t_6 );
     ASS_REC( l_obj, RNamObj(t_5), t_6 );
     
     /* nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) ); */
     t_6 = GF_AND__FLAGS;
     t_8 = GF_FLAGS__FILTER;
     t_10 = GF_Tester;
     if ( TNUM_OBJ( t_10 ) == T_FUNCTION ) {
      t_9 = CALL_1ARGS( t_10, l_attr );
     }
     else {
      t_9 = DoOperation2Args( CallFuncListOper, t_10, NewPlistFromArgs( l_attr ) );
     }
     CHECK_FUNC_RESULT( t_9 );
     if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
      t_7 = CALL_1ARGS( t_8, t_9 );
     }
     else {
      t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( t_9 ) );
     }
     CHECK_FUNC_RESULT( t_7 );
     if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
      t_5 = CALL_2ARGS( t_6, l_nflags, t_7 );
     }
     else {
      t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( l_nflags, t_7 ) );
     }
     CHECK_FUNC_RESULT( t_5 );
     l_nflags = t_5;
     
    }
   }
   /* fi */
   
  }
  /* od */
  
  /* if not IS_SUBSET_FLAGS( flags, nflags ) then */
  t_4 = GF_IS__SUBSET__FLAGS;
  if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
   t_3 = CALL_2ARGS( t_4, l_flags, l_nflags );
  }
  else {
   t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( l_flags, l_nflags ) );
  }
  CHECK_FUNC_RESULT( t_3 );
  CHECK_BOOL( t_3 );
  t_2 = (Obj)(UInt)(t_3 != False);
  t_1 = (Obj)(UInt)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* flags := WITH_IMPS_FLAGS( AND_FLAGS( flags, nflags ) ); */
   t_2 = GF_WITH__IMPS__FLAGS;
   t_4 = GF_AND__FLAGS;
   if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
    t_3 = CALL_2ARGS( t_4, l_flags, l_nflags );
   }
   else {
    t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( l_flags, l_nflags ) );
   }
   CHECK_FUNC_RESULT( t_3 );
   if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
    t_1 = CALL_1ARGS( t_2, t_3 );
   }
   else {
    t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
   }
   CHECK_FUNC_RESULT( t_1 );
   l_flags = t_1;
   
   /* type := NEW_TYPE( FamilyType( type ), flags, DataType( type ), fail ); */
   t_2 = GF_NEW__TYPE;
   t_4 = GF_FamilyType;
   if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
    t_3 = CALL_1ARGS( t_4, l_type );
   }
   else {
    t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( l_type ) );
   }
   CHECK_FUNC_RESULT( t_3 );
   t_5 = GF_DataType;
   if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
    t_4 = CALL_1ARGS( t_5, l_type );
   }
   else {
    t_4 = DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( l_type ) );
   }
   CHECK_FUNC_RESULT( t_4 );
   t_5 = GC_fail;
   CHECK_BOUND( t_5, "fail" );
   if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
    t_1 = CALL_4ARGS( t_2, t_3, l_flags, t_4, t_5 );
   }
   else {
    t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, l_flags, t_4, t_5 ) );
   }
   CHECK_FUNC_RESULT( t_1 );
   l_type = t_1;
   
  }
  /* fi */
  
  /* Objectify( type, obj ); */
  t_1 = GF_Objectify;
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_2ARGS( t_1, l_type, l_obj );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_type, l_obj ) );
  }
  
 }
 /* fi */
 
 /* for i in [ 1, 3 .. LEN_LIST( extra ) - 1 ] do */
 t_7 = GF_LEN__LIST;
 if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
  t_6 = CALL_1ARGS( t_7, l_extra );
 }
 else {
  t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( l_extra ) );
 }
 CHECK_FUNC_RESULT( t_6 );
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
  CHECK_INT_POS( l_i );
  C_ELM_LIST_FPL( t_9, l_extra, l_i )
  if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
   t_7 = CALL_1ARGS( t_8, t_9 );
  }
  else {
   t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( t_9 ) );
  }
  CHECK_FUNC_RESULT( t_7 );
  if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
   t_6 = CALL_1ARGS( t_7, l_obj );
  }
  else {
   t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( l_obj ) );
  }
  CHECK_FUNC_RESULT( t_6 );
  CHECK_BOOL( t_6 );
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* INFO_OWA( "#W  Supplied type has tester of ", NAME_FUNC( extra[i] ), "with non-standard setter\n" ); */
   t_5 = GF_INFO__OWA;
   t_6 = MakeString( "#W  Supplied type has tester of " );
   t_8 = GF_NAME__FUNC;
   C_ELM_LIST_FPL( t_9, l_extra, l_i )
   if ( TNUM_OBJ( t_8 ) == T_FUNCTION ) {
    t_7 = CALL_1ARGS( t_8, t_9 );
   }
   else {
    t_7 = DoOperation2Args( CallFuncListOper, t_8, NewPlistFromArgs( t_9 ) );
   }
   CHECK_FUNC_RESULT( t_7 );
   t_8 = MakeString( "with non-standard setter\n" );
   if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
    CALL_3ARGS( t_5, t_6, t_7, t_8 );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( t_6, t_7, t_8 ) );
   }
   
   /* ResetFilterObj( obj, Tester( extra[i] ) ); */
   t_5 = GF_ResetFilterObj;
   t_7 = GF_Tester;
   C_ELM_LIST_FPL( t_8, l_extra, l_i )
   if ( TNUM_OBJ( t_7 ) == T_FUNCTION ) {
    t_6 = CALL_1ARGS( t_7, t_8 );
   }
   else {
    t_6 = DoOperation2Args( CallFuncListOper, t_7, NewPlistFromArgs( t_8 ) );
   }
   CHECK_FUNC_RESULT( t_6 );
   if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
    CALL_2ARGS( t_5, l_obj, t_6 );
   }
   else {
    DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( l_obj, t_6 ) );
   }
   
  }
  /* fi */
  
  /* Setter( extra[i] )( obj, extra[i + 1] ); */
  t_6 = GF_Setter;
  C_ELM_LIST_FPL( t_7, l_extra, l_i )
  if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
   t_5 = CALL_1ARGS( t_6, t_7 );
  }
  else {
   t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( t_7 ) );
  }
  CHECK_FUNC_RESULT( t_5 );
  C_SUM_FIA( t_7, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_7 );
  C_ELM_LIST_FPL( t_6, l_extra, t_7 )
  if ( TNUM_OBJ( t_5 ) == T_FUNCTION ) {
   CALL_2ARGS( t_5, l_obj, t_6 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_5, NewPlistFromArgs( l_obj, t_6 ) );
  }
  
 }
 /* od */
 
 /* return obj; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_obj;
 
 /* return; */
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
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* InstallAttributeFunction( function ( name, filter, getter, setter, tester, mutflag )
      InstallOtherMethod( getter, "system getter", true, [ IsAttributeStoringRep and tester ], GETTER_FLAGS, GETTER_FUNCTION( name ) );
      return;
  end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[2], 6, ArgStringToList("name,filter,getter,setter,tester,mutflag"), HdlrFunc2 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 20);
 SET_ENDLINE_BODY(t_3, 27);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + (6 + 2); */
 t_2 = GC_LENGTH__SETTER__METHODS__2;
 CHECK_BOUND( t_2, "LENGTH_SETTER_METHODS_2" );
 C_SUM_INTOBJS( t_3, INTOBJ_INT(6), INTOBJ_INT(2) )
 C_SUM_FIA( t_1, t_2, t_3 )
 AssGVar( G_LENGTH__SETTER__METHODS__2, t_1 );
 
 /* InstallAttributeFunction( function ( name, filter, getter, setter, tester, mutflag )
      if mutflag then
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
 t_2 = NewFunction( NameFunc[3], 6, ArgStringToList("name,filter,getter,setter,tester,mutflag"), HdlrFunc3 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 32);
 SET_ENDLINE_BODY(t_3, 53);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Subtype := "defined below"; */
 t_1 = MakeString( "defined below" );
 AssGVar( G_Subtype, t_1 );
 
 /* DS_TYPE_CACHE := ShareSpecialObj( [  ] ); */
 t_2 = GF_ShareSpecialObj;
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_1ARGS( t_2, t_3 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 AssGVar( G_DS__TYPE__CACHE, t_1 );
 
 /* BIND_GLOBAL( "NEW_FAMILY", function ( typeOfFamilies, name, req_filter, imp_filter )
      local lock, type, pair, family;
      imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) );
      type := Subtype( typeOfFamilies, IsAttributeStoringRep );
      lock := READ_LOCK( CATEGORIES_FAMILY );
      for pair in CATEGORIES_FAMILY do
          if IS_SUBSET_FLAGS( imp_filter, pair[1] ) then
              type := Subtype( type, pair[2] );
          fi;
      od;
      UNLOCK( lock );
      family := AtomicRecord(  );
      SET_TYPE_COMOBJ( family, type );
      family!.NAME := IMMUTABLE_COPY_OBJ( name );
      family!.REQ_FLAGS := req_filter;
      family!.IMP_FLAGS := imp_filter;
      family!.nTYPES := 0;
      family!.HASH_SIZE := 32;
      lock := WRITE_LOCK( DS_TYPE_CACHE );
      family!.TYPES := MIGRATE_RAW( [  ], DS_TYPE_CACHE );
      UNLOCK( lock );
      family!.TYPES_LIST_FAM := MakeWriteOnceAtomic( AtomicList( 27 ) );
      return family;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "NEW_FAMILY" );
 t_3 = NewFunction( NameFunc[5], 4, ArgStringToList("typeOfFamilies,name,req_filter,imp_filter"), HdlrFunc5 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 92);
 SET_ENDLINE_BODY(t_4, 143);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "NewFamily", function ( arg... )
      local typeOfFamilies, name, req, imp, filter;
      if not LEN_LIST( arg ) in [ 1 .. 4 ] then
          Error( "usage: NewFamily( <name> [, <req> [, <imp> [, <famfilter> ] ] ] )" );
      fi;
      name := arg[1];
      if LEN_LIST( arg ) >= 2 then
          req := FLAGS_FILTER( arg[2] );
      else
          req := EMPTY_FLAGS;
      fi;
      if LEN_LIST( arg ) >= 3 then
          imp := FLAGS_FILTER( arg[3] );
      else
          imp := EMPTY_FLAGS;
      fi;
      if LEN_LIST( arg ) = 4 then
          typeOfFamilies := Subtype( TypeOfFamilies, arg[4] );
      else
          typeOfFamilies := TypeOfFamilies;
      fi;
      return NEW_FAMILY( typeOfFamilies, name, req, imp );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "NewFamily" );
 t_3 = NewFunction( NameFunc[6], -1, ArgStringToList("arg"), HdlrFunc6 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 146);
 SET_ENDLINE_BODY(t_4, 175);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* NEW_TYPE_CACHE_MISS := 0; */
 AssGVar( G_NEW__TYPE__CACHE__MISS, INTOBJ_INT(0) );
 
 /* NEW_TYPE_CACHE_HIT := 0; */
 AssGVar( G_NEW__TYPE__CACHE__HIT, INTOBJ_INT(0) );
 
 /* BIND_GLOBAL( "NEW_TYPE", function ( family, flags, data, parent )
      local lock, hash, cache, cached, type, ncache, ncl, t, i, match;
      lock := WRITE_LOCK( DS_TYPE_CACHE );
      cache := family!.TYPES;
      hash := HASH_FLAGS( flags ) mod family!.HASH_SIZE + 1;
      if IsBound( cache[hash] ) then
          cached := cache[hash];
          if IS_EQUAL_FLAGS( flags, cached![2] ) then
              flags := cached![2];
              if IS_IDENTICAL_OBJ( data, cached![3] ) and IS_IDENTICAL_OBJ( TypeOfTypes, TYPE_OBJ( cached ) ) then
                  if IS_IDENTICAL_OBJ( parent, fail ) then
                      match := true;
                      for i in [ 5 .. LEN_POSOBJ( cached ) ] do
                          if IsBound( cached![i] ) then
                              match := false;
                              break;
                          fi;
                      od;
                      if match then
                          NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1;
                          UNLOCK( lock );
                          return cached;
                      fi;
                  fi;
                  if LEN_POSOBJ( parent ) = LEN_POSOBJ( cached ) then
                      match := true;
                      for i in [ 5 .. LEN_POSOBJ( parent ) ] do
                          if IsBound( parent![i] ) <> IsBound( cached![i] ) then
                              match := false;
                              break;
                          fi;
                          if IsBound( parent![i] ) and IsBound( cached![i] ) and not IS_IDENTICAL_OBJ( parent![i], cached![i] ) then
                              match := false;
                              break;
                          fi;
                      od;
                      if match then
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
      if NEW_TYPE_NEXT_ID >= NEW_TYPE_ID_LIMIT then
          GASMAN( "collect" );
          FLUSH_ALL_METHOD_CACHES(  );
          NEW_TYPE_NEXT_ID := COMPACT_TYPE_IDS(  );
      fi;
      type := [ family, flags ];
      data := MakeReadOnlyObj( data );
      type[3] := data;
      type[4] := NEW_TYPE_NEXT_ID;
      if not IS_IDENTICAL_OBJ( parent, fail ) then
          for i in [ 5 .. LEN_POSOBJ( parent ) ] do
              if IsBound( parent![i] ) and not IsBound( type[i] ) then
                  type[i] := parent![i];
              fi;
          od;
      fi;
      SET_TYPE_POSOBJ( type, TypeOfTypes );
      if 3 * family!.nTYPES > family!.HASH_SIZE then
          ncache := [  ];
          MIGRATE_RAW( ncache, DS_TYPE_CACHE );
          ncl := 3 * family!.HASH_SIZE + 1;
          for t in cache do
              ncache[HASH_FLAGS( t![2] ) mod ncl + 1] := t;
          od;
          family!.HASH_SIZE := ncl;
          family!.TYPES := ncache;
          ncache[HASH_FLAGS( flags ) mod ncl + 1] := type;
      else
          cache[hash] := type;
      fi;
      family!.nTYPES := family!.nTYPES + 1;
      MakeReadOnlySingleObj( type );
      UNLOCK( lock );
      return type;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "NEW_TYPE" );
 t_3 = NewFunction( NameFunc[7], 4, ArgStringToList("family,flags,data,parent"), HdlrFunc7 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 203);
 SET_ENDLINE_BODY(t_4, 320);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "NewType", function ( family, filter, data... )
      if not IsFamily( family ) then
          Error( "<family> must be a family" );
      fi;
      if LEN_LIST( data ) = 0 then
          data := fail;
      elif LEN_LIST( data ) = 1 then
          data := data[1];
      else
          Error( "usage: NewType( <family>, <filter> [, <data> ] )" );
      fi;
      return NEW_TYPE( family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), data, fail );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "NewType" );
 t_3 = NewFunction( NameFunc[8], -3, ArgStringToList("family,filter,data"), HdlrFunc8 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 323);
 SET_ENDLINE_BODY(t_4, 350);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Unbind( Subtype ); */
 AssGVar( G_Subtype, 0 );
 
 /* BIND_GLOBAL( "Subtype", function ( type, filter )
      if not IsType( type ) then
          Error( "<type> must be a type" );
      fi;
      return NEW_TYPE( type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), type![3], type );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "Subtype" );
 t_3 = NewFunction( NameFunc[9], 2, ArgStringToList("type,filter"), HdlrFunc9 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 364);
 SET_ENDLINE_BODY(t_4, 377);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "SupType", function ( type, filter )
      if not IsType( type ) then
          Error( "<type> must be a type" );
      fi;
      return NEW_TYPE( type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), type![3], type );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "SupType" );
 t_3 = NewFunction( NameFunc[10], 2, ArgStringToList("type,filter"), HdlrFunc10 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 391);
 SET_ENDLINE_BODY(t_4, 404);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "FamilyType", function ( K )
      return K![1];
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "FamilyType" );
 t_3 = NewFunction( NameFunc[11], 1, ArgStringToList("K"), HdlrFunc11 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 418);
 SET_ENDLINE_BODY(t_4, 418);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "FlagsType", function ( K )
      return K![2];
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "FlagsType" );
 t_3 = NewFunction( NameFunc[12], 1, ArgStringToList("K"), HdlrFunc12 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 432);
 SET_ENDLINE_BODY(t_4, 432);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "DataType", function ( K )
      return K![3];
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "DataType" );
 t_3 = NewFunction( NameFunc[13], 1, ArgStringToList("K"), HdlrFunc13 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 448);
 SET_ENDLINE_BODY(t_4, 448);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "SetDataType", function ( K, data )
      StrictBindOnce( K, 3, MakeImmutable( data ) );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "SetDataType" );
 t_3 = NewFunction( NameFunc[14], 2, ArgStringToList("K,data"), HdlrFunc14 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 450);
 SET_ENDLINE_BODY(t_4, 456);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "TypeObj", TYPE_OBJ ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "TypeObj" );
 t_3 = GC_TYPE__OBJ;
 CHECK_BOUND( t_3, "TYPE_OBJ" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "FamilyObj", FAMILY_OBJ ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "FamilyObj" );
 t_3 = GC_FAMILY__OBJ;
 CHECK_BOUND( t_3, "FAMILY_OBJ" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "FlagsObj", function ( obj )
      return FlagsType( TypeObj( obj ) );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "FlagsObj" );
 t_3 = NewFunction( NameFunc[15], 1, ArgStringToList("obj"), HdlrFunc15 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 555);
 SET_ENDLINE_BODY(t_4, 555);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "DataObj", function ( obj )
      return DataType( TypeObj( obj ) );
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "DataObj" );
 t_3 = NewFunction( NameFunc[16], 1, ArgStringToList("obj"), HdlrFunc16 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 569);
 SET_ENDLINE_BODY(t_4, 569);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "IsNonAtomicComponentObjectRepFlags", FLAGS_FILTER( IsNonAtomicComponentObjectRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "IsNonAtomicComponentObjectRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsNonAtomicComponentObjectRep;
 CHECK_BOUND( t_5, "IsNonAtomicComponentObjectRep" );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "IsAtomicPositionalObjectRepFlags", FLAGS_FILTER( IsAtomicPositionalObjectRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "IsAtomicPositionalObjectRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsAtomicPositionalObjectRep;
 CHECK_BOUND( t_5, "IsAtomicPositionalObjectRep" );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "IsReadOnlyPositionalObjectRepFlags", FLAGS_FILTER( IsReadOnlyPositionalObjectRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "IsReadOnlyPositionalObjectRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsReadOnlyPositionalObjectRep;
 CHECK_BOUND( t_5, "IsReadOnlyPositionalObjectRep" );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "Objectify", function ( type, obj )
      local flags;
      if not IsType( type ) then
          Error( "<type> must be a type" );
      fi;
      flags := FlagsType( type );
      if IS_LIST( obj ) then
          if IS_SUBSET_FLAGS( flags, IsAtomicPositionalObjectRepFlags ) then
              FORCE_SWITCH_OBJ( obj, FixedAtomicList( obj ) );
          fi;
      elif IS_REC( obj ) then
          if IS_ATOMIC_RECORD( obj ) then
              if IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags ) then
                  FORCE_SWITCH_OBJ( obj, FromAtomicRecord( obj ) );
              fi;
          elif not IS_SUBSET_FLAGS( flags, IsNonAtomicComponentObjectRepFlags ) then
              FORCE_SWITCH_OBJ( obj, AtomicRecord( obj ) );
          fi;
      fi;
      if IS_LIST( obj ) then
          SET_TYPE_POSOBJ( obj, type );
      elif IS_REC( obj ) then
          SET_TYPE_COMOBJ( obj, type );
      fi;
      if not IsNoImmediateMethodsObject( obj ) then
          RunImmediateMethods( obj, type![2] );
      fi;
      if IsReadOnlyPositionalObjectRep( obj ) then
          MakeReadOnlySingleObj( obj );
      fi;
      return obj;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "Objectify" );
 t_3 = NewFunction( NameFunc[17], 2, ArgStringToList("type,obj"), HdlrFunc17 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 590);
 SET_ENDLINE_BODY(t_4, 625);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Unbind( SetFilterObj ); */
 AssGVar( G_SetFilterObj, 0 );
 
 /* BIND_GLOBAL( "SetFilterObj", function ( obj, filter )
      local type, newtype;
      type := TYPE_OBJ( obj );
      newtype := Subtype( type, filter );
      if IS_POSOBJ( obj ) then
          SET_TYPE_POSOBJ( obj, newtype );
      elif IS_COMOBJ( obj ) then
          SET_TYPE_COMOBJ( obj, newtype );
      elif IS_DATOBJ( obj ) then
          SET_TYPE_DATOBJ( obj, newtype );
      else
          ErrorNoReturn( "cannot set filter for internal object" );
      fi;
      if not (IGNORE_IMMEDIATE_METHODS or IsNoImmediateMethodsObject( obj )) then
          RunImmediateMethods( obj, SUB_FLAGS( newtype![2], type![2] ) );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "SetFilterObj" );
 t_3 = NewFunction( NameFunc[18], 2, ArgStringToList("obj,filter"), HdlrFunc18 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 647);
 SET_ENDLINE_BODY(t_4, 667);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "ResetFilterObj", function ( obj, filter )
      local type, newtype;
      if IS_AND_FILTER( filter ) then
          Error( "You can't reset an \"and-filter\". Reset components individually." );
      fi;
      type := TYPE_OBJ( obj );
      newtype := SupType( type, filter );
      if IS_POSOBJ( obj ) then
          SET_TYPE_POSOBJ( obj, newtype );
      elif IS_COMOBJ( obj ) then
          SET_TYPE_COMOBJ( obj, newtype );
      elif IS_DATOBJ( obj ) then
          SET_TYPE_DATOBJ( obj, newtype );
      else
          Error( "cannot reset filter for internal object" );
      fi;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "ResetFilterObj" );
 t_3 = NewFunction( NameFunc[19], 2, ArgStringToList("obj,filter"), HdlrFunc19 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 687);
 SET_ENDLINE_BODY(t_4, 705);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "IsAttributeStoringRepFlags", FLAGS_FILTER( IsAttributeStoringRep ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "IsAttributeStoringRepFlags" );
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_5, "IsAttributeStoringRep" );
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_1ARGS( t_4, t_5 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( t_5 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BIND_GLOBAL( "INFO_OWA", Ignore ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "INFO_OWA" );
 t_3 = GC_Ignore;
 CHECK_BOUND( t_3, "Ignore" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* MAKE_READ_WRITE_GLOBAL( "INFO_OWA" ); */
 t_1 = GF_MAKE__READ__WRITE__GLOBAL;
 t_2 = MakeString( "INFO_OWA" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* BIND_GLOBAL( "ObjectifyWithAttributes", function ( arg... )
      local obj, type, flags, attr, val, i, extra, nflags;
      obj := arg[1];
      type := arg[2];
      flags := FlagsType( type );
      extra := [  ];
      if not IS_SUBSET_FLAGS( flags, IsAttributeStoringRepFlags ) then
          extra := arg{[ 3 .. LEN_LIST( arg ) ]};
          INFO_OWA( "#W ObjectifyWithAttributes called ", "for non-attribute storing rep\n" );
          Objectify( type, obj );
      else
          nflags := EMPTY_FLAGS;
          for i in [ 3, 5 .. LEN_LIST( arg ) - 1 ] do
              attr := arg[i];
              val := arg[i + 1];
              if 0 <> FLAG1_FILTER( attr ) then
                  if val then
                      nflags := AND_FLAGS( nflags, FLAGS_FILTER( attr ) );
                  else
                      nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) );
                  fi;
              elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2 ) ) <> LENGTH_SETTER_METHODS_2 then
                  ADD_LIST( extra, attr );
                  ADD_LIST( extra, val );
              else
                  obj.(NAME_FUNC( attr )) := IMMUTABLE_COPY_OBJ( val );
                  nflags := AND_FLAGS( nflags, FLAGS_FILTER( Tester( attr ) ) );
              fi;
          od;
          if not IS_SUBSET_FLAGS( flags, nflags ) then
              flags := WITH_IMPS_FLAGS( AND_FLAGS( flags, nflags ) );
              type := NEW_TYPE( FamilyType( type ), flags, DataType( type ), fail );
          fi;
          Objectify( type, obj );
      fi;
      for i in [ 1, 3 .. LEN_LIST( extra ) - 1 ] do
          if Tester( extra[i] )( obj ) then
              INFO_OWA( "#W  Supplied type has tester of ", NAME_FUNC( extra[i] ), "with non-standard setter\n" );
              ResetFilterObj( obj, Tester( extra[i] ) );
          fi;
          Setter( extra[i] )( obj, extra[i + 1] );
      od;
      return obj;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "ObjectifyWithAttributes" );
 t_3 = NewFunction( NameFunc[20], -1, ArgStringToList("arg"), HdlrFunc20 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 753);
 SET_ENDLINE_BODY(t_4, 815);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 G_SetFilterObj = GVarName( "SetFilterObj" );
 G_ResetFilterObj = GVarName( "ResetFilterObj" );
 G_IS__REC = GVarName( "IS_REC" );
 G_IS__LIST = GVarName( "IS_LIST" );
 G_ADD__LIST = GVarName( "ADD_LIST" );
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
 G_WITH__IMPS__FLAGS = GVarName( "WITH_IMPS_FLAGS" );
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
 G_GASMAN = GVarName( "GASMAN" );
 G_WRITE__LOCK = GVarName( "WRITE_LOCK" );
 G_READ__LOCK = GVarName( "READ_LOCK" );
 G_UNLOCK = GVarName( "UNLOCK" );
 G_MIGRATE__RAW = GVarName( "MIGRATE_RAW" );
 G_MakeReadOnlyObj = GVarName( "MakeReadOnlyObj" );
 G_MakeReadOnlySingleObj = GVarName( "MakeReadOnlySingleObj" );
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
 G_Subtype = GVarName( "Subtype" );
 G_DS__TYPE__CACHE = GVarName( "DS_TYPE_CACHE" );
 G_ShareSpecialObj = GVarName( "ShareSpecialObj" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_CATEGORIES__FAMILY = GVarName( "CATEGORIES_FAMILY" );
 G_EMPTY__FLAGS = GVarName( "EMPTY_FLAGS" );
 G_TypeOfFamilies = GVarName( "TypeOfFamilies" );
 G_NEW__FAMILY = GVarName( "NEW_FAMILY" );
 G_NEW__TYPE__CACHE__MISS = GVarName( "NEW_TYPE_CACHE_MISS" );
 G_NEW__TYPE__CACHE__HIT = GVarName( "NEW_TYPE_CACHE_HIT" );
 G_TypeOfTypes = GVarName( "TypeOfTypes" );
 G_NEW__TYPE__NEXT__ID = GVarName( "NEW_TYPE_NEXT_ID" );
 G_NEW__TYPE__ID__LIMIT = GVarName( "NEW_TYPE_ID_LIMIT" );
 G_FLUSH__ALL__METHOD__CACHES = GVarName( "FLUSH_ALL_METHOD_CACHES" );
 G_IsFamily = GVarName( "IsFamily" );
 G_NEW__TYPE = GVarName( "NEW_TYPE" );
 G_IsType = GVarName( "IsType" );
 G_FlagsType = GVarName( "FlagsType" );
 G_TypeObj = GVarName( "TypeObj" );
 G_DataType = GVarName( "DataType" );
 G_IsNonAtomicComponentObjectRep = GVarName( "IsNonAtomicComponentObjectRep" );
 G_IsAtomicPositionalObjectRep = GVarName( "IsAtomicPositionalObjectRep" );
 G_IsReadOnlyPositionalObjectRep = GVarName( "IsReadOnlyPositionalObjectRep" );
 G_IsAtomicPositionalObjectRepFlags = GVarName( "IsAtomicPositionalObjectRepFlags" );
 G_IsNonAtomicComponentObjectRepFlags = GVarName( "IsNonAtomicComponentObjectRepFlags" );
 G_IsNoImmediateMethodsObject = GVarName( "IsNoImmediateMethodsObject" );
 G_RunImmediateMethods = GVarName( "RunImmediateMethods" );
 G_ErrorNoReturn = GVarName( "ErrorNoReturn" );
 G_IGNORE__IMMEDIATE__METHODS = GVarName( "IGNORE_IMMEDIATE_METHODS" );
 G_SupType = GVarName( "SupType" );
 G_Ignore = GVarName( "Ignore" );
 G_MAKE__READ__WRITE__GLOBAL = GVarName( "MAKE_READ_WRITE_GLOBAL" );
 G_IsAttributeStoringRepFlags = GVarName( "IsAttributeStoringRepFlags" );
 G_INFO__OWA = GVarName( "INFO_OWA" );
 G_Objectify = GVarName( "Objectify" );
 G_Tester = GVarName( "Tester" );
 G_Setter = GVarName( "Setter" );
 G_FamilyType = GVarName( "FamilyType" );
 
 /* record names used in handlers */
 R_TYPES__LIST__FAM = RNamName( "TYPES_LIST_FAM" );
 R_NAME = RNamName( "NAME" );
 R_REQ__FLAGS = RNamName( "REQ_FLAGS" );
 R_IMP__FLAGS = RNamName( "IMP_FLAGS" );
 R_nTYPES = RNamName( "nTYPES" );
 R_HASH__SIZE = RNamName( "HASH_SIZE" );
 R_TYPES = RNamName( "TYPES" );
 
 /* information for the functions */
 NameFunc[1] = 0;
 NameFunc[2] = 0;
 NameFunc[3] = 0;
 NameFunc[4] = 0;
 NameFunc[5] = 0;
 NameFunc[6] = 0;
 NameFunc[7] = 0;
 NameFunc[8] = 0;
 NameFunc[9] = 0;
 NameFunc[10] = 0;
 NameFunc[11] = 0;
 NameFunc[12] = 0;
 NameFunc[13] = 0;
 NameFunc[14] = 0;
 NameFunc[15] = 0;
 NameFunc[16] = 0;
 NameFunc[17] = 0;
 NameFunc[18] = 0;
 NameFunc[19] = 0;
 NameFunc[20] = 0;
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "NAME_FUNC", &GF_NAME__FUNC );
 InitFopyGVar( "SetFilterObj", &GF_SetFilterObj );
 InitFopyGVar( "ResetFilterObj", &GF_ResetFilterObj );
 InitFopyGVar( "IS_REC", &GF_IS__REC );
 InitFopyGVar( "IS_LIST", &GF_IS__LIST );
 InitFopyGVar( "ADD_LIST", &GF_ADD__LIST );
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
 InitFopyGVar( "WITH_IMPS_FLAGS", &GF_WITH__IMPS__FLAGS );
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
 InitFopyGVar( "GASMAN", &GF_GASMAN );
 InitFopyGVar( "WRITE_LOCK", &GF_WRITE__LOCK );
 InitFopyGVar( "READ_LOCK", &GF_READ__LOCK );
 InitFopyGVar( "UNLOCK", &GF_UNLOCK );
 InitFopyGVar( "MIGRATE_RAW", &GF_MIGRATE__RAW );
 InitFopyGVar( "MakeReadOnlyObj", &GF_MakeReadOnlyObj );
 InitFopyGVar( "MakeReadOnlySingleObj", &GF_MakeReadOnlySingleObj );
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
 InitCopyGVar( "GETTER_FLAGS", &GC_GETTER__FLAGS );
 InitCopyGVar( "LENGTH_SETTER_METHODS_2", &GC_LENGTH__SETTER__METHODS__2 );
 InitFopyGVar( "Subtype", &GF_Subtype );
 InitCopyGVar( "DS_TYPE_CACHE", &GC_DS__TYPE__CACHE );
 InitFopyGVar( "ShareSpecialObj", &GF_ShareSpecialObj );
 InitFopyGVar( "BIND_GLOBAL", &GF_BIND__GLOBAL );
 InitCopyGVar( "CATEGORIES_FAMILY", &GC_CATEGORIES__FAMILY );
 InitCopyGVar( "EMPTY_FLAGS", &GC_EMPTY__FLAGS );
 InitCopyGVar( "TypeOfFamilies", &GC_TypeOfFamilies );
 InitFopyGVar( "NEW_FAMILY", &GF_NEW__FAMILY );
 InitCopyGVar( "NEW_TYPE_CACHE_MISS", &GC_NEW__TYPE__CACHE__MISS );
 InitCopyGVar( "NEW_TYPE_CACHE_HIT", &GC_NEW__TYPE__CACHE__HIT );
 InitCopyGVar( "TypeOfTypes", &GC_TypeOfTypes );
 InitCopyGVar( "NEW_TYPE_NEXT_ID", &GC_NEW__TYPE__NEXT__ID );
 InitCopyGVar( "NEW_TYPE_ID_LIMIT", &GC_NEW__TYPE__ID__LIMIT );
 InitFopyGVar( "FLUSH_ALL_METHOD_CACHES", &GF_FLUSH__ALL__METHOD__CACHES );
 InitFopyGVar( "IsFamily", &GF_IsFamily );
 InitFopyGVar( "NEW_TYPE", &GF_NEW__TYPE );
 InitFopyGVar( "IsType", &GF_IsType );
 InitFopyGVar( "FlagsType", &GF_FlagsType );
 InitFopyGVar( "TypeObj", &GF_TypeObj );
 InitFopyGVar( "DataType", &GF_DataType );
 InitCopyGVar( "IsNonAtomicComponentObjectRep", &GC_IsNonAtomicComponentObjectRep );
 InitCopyGVar( "IsAtomicPositionalObjectRep", &GC_IsAtomicPositionalObjectRep );
 InitCopyGVar( "IsReadOnlyPositionalObjectRep", &GC_IsReadOnlyPositionalObjectRep );
 InitFopyGVar( "IsReadOnlyPositionalObjectRep", &GF_IsReadOnlyPositionalObjectRep );
 InitCopyGVar( "IsAtomicPositionalObjectRepFlags", &GC_IsAtomicPositionalObjectRepFlags );
 InitCopyGVar( "IsNonAtomicComponentObjectRepFlags", &GC_IsNonAtomicComponentObjectRepFlags );
 InitFopyGVar( "IsNoImmediateMethodsObject", &GF_IsNoImmediateMethodsObject );
 InitFopyGVar( "RunImmediateMethods", &GF_RunImmediateMethods );
 InitFopyGVar( "ErrorNoReturn", &GF_ErrorNoReturn );
 InitCopyGVar( "IGNORE_IMMEDIATE_METHODS", &GC_IGNORE__IMMEDIATE__METHODS );
 InitFopyGVar( "SupType", &GF_SupType );
 InitCopyGVar( "Ignore", &GC_Ignore );
 InitFopyGVar( "MAKE_READ_WRITE_GLOBAL", &GF_MAKE__READ__WRITE__GLOBAL );
 InitCopyGVar( "IsAttributeStoringRepFlags", &GC_IsAttributeStoringRepFlags );
 InitFopyGVar( "INFO_OWA", &GF_INFO__OWA );
 InitFopyGVar( "Objectify", &GF_Objectify );
 InitFopyGVar( "Tester", &GF_Tester );
 InitFopyGVar( "Setter", &GF_Setter );
 InitFopyGVar( "FamilyType", &GF_FamilyType );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "GAPROOT/lib/type1.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/type1.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/type1.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/type1.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/type1.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/type1.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/type1.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "GAPROOT/lib/type1.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "GAPROOT/lib/type1.g:NameFunc[4]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc5, "GAPROOT/lib/type1.g:HdlrFunc5("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[5]), "GAPROOT/lib/type1.g:NameFunc[5]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc6, "GAPROOT/lib/type1.g:HdlrFunc6("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[6]), "GAPROOT/lib/type1.g:NameFunc[6]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc7, "GAPROOT/lib/type1.g:HdlrFunc7("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[7]), "GAPROOT/lib/type1.g:NameFunc[7]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc8, "GAPROOT/lib/type1.g:HdlrFunc8("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[8]), "GAPROOT/lib/type1.g:NameFunc[8]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc9, "GAPROOT/lib/type1.g:HdlrFunc9("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[9]), "GAPROOT/lib/type1.g:NameFunc[9]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc10, "GAPROOT/lib/type1.g:HdlrFunc10("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[10]), "GAPROOT/lib/type1.g:NameFunc[10]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc11, "GAPROOT/lib/type1.g:HdlrFunc11("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[11]), "GAPROOT/lib/type1.g:NameFunc[11]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc12, "GAPROOT/lib/type1.g:HdlrFunc12("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[12]), "GAPROOT/lib/type1.g:NameFunc[12]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc13, "GAPROOT/lib/type1.g:HdlrFunc13("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[13]), "GAPROOT/lib/type1.g:NameFunc[13]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc14, "GAPROOT/lib/type1.g:HdlrFunc14("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[14]), "GAPROOT/lib/type1.g:NameFunc[14]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc15, "GAPROOT/lib/type1.g:HdlrFunc15("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[15]), "GAPROOT/lib/type1.g:NameFunc[15]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc16, "GAPROOT/lib/type1.g:HdlrFunc16("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[16]), "GAPROOT/lib/type1.g:NameFunc[16]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc17, "GAPROOT/lib/type1.g:HdlrFunc17("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[17]), "GAPROOT/lib/type1.g:NameFunc[17]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc18, "GAPROOT/lib/type1.g:HdlrFunc18("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[18]), "GAPROOT/lib/type1.g:NameFunc[18]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc19, "GAPROOT/lib/type1.g:HdlrFunc19("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[19]), "GAPROOT/lib/type1.g:NameFunc[19]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc20, "GAPROOT/lib/type1.g:HdlrFunc20("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[20]), "GAPROOT/lib/type1.g:NameFunc[20]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "GAPROOT/lib/type1.g" );
 PostRestore(module);
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],0,0,HdlrFunc1);
 SET_ENVI_FUNC( func1, STATE(CurrLVars) );
 body1 = NewFunctionBody();
 SET_BODY_FUNC( func1, body1 );
 CHANGED_BAG( func1 );
 CALL_0ARGS( func1 );
 
 /* return success */
 return 0;
 
}

/* <name> returns the description of this module */
static StructInitInfo module = {
 .type        = MODULE_STATIC,
 .name        = "GAPROOT/lib/type1.g",
 .crc         = -88497608,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__type1 ( void )
{
 return &module;
}

/* compiled code ends here */
#endif
