#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include <src/compiled.h>

/* global variables used in handlers */
static GVar G_METHOD__0ARGS;
static GVar G_METHOD__1ARGS;
static GVar G_METHOD__2ARGS;
static GVar G_METHOD__3ARGS;
static GVar G_METHOD__4ARGS;
static GVar G_METHOD__5ARGS;
static GVar G_METHOD__6ARGS;
static GVar G_METHOD__XARGS;
static GVar G_NEXT__METHOD__0ARGS;
static GVar G_NEXT__METHOD__1ARGS;
static GVar G_NEXT__METHOD__2ARGS;
static GVar G_NEXT__METHOD__3ARGS;
static GVar G_NEXT__METHOD__4ARGS;
static GVar G_NEXT__METHOD__5ARGS;
static GVar G_NEXT__METHOD__6ARGS;
static GVar G_NEXT__METHOD__XARGS;
static GVar G_CONSTRUCTOR__0ARGS;
static GVar G_CONSTRUCTOR__1ARGS;
static GVar G_CONSTRUCTOR__2ARGS;
static GVar G_CONSTRUCTOR__3ARGS;
static GVar G_CONSTRUCTOR__4ARGS;
static GVar G_CONSTRUCTOR__5ARGS;
static GVar G_CONSTRUCTOR__6ARGS;
static GVar G_CONSTRUCTOR__XARGS;
static GVar G_NEXT__CONSTRUCTOR__0ARGS;
static GVar G_NEXT__CONSTRUCTOR__1ARGS;
static GVar G_NEXT__CONSTRUCTOR__2ARGS;
static GVar G_NEXT__CONSTRUCTOR__3ARGS;
static GVar G_NEXT__CONSTRUCTOR__4ARGS;
static GVar G_NEXT__CONSTRUCTOR__5ARGS;
static GVar G_NEXT__CONSTRUCTOR__6ARGS;
static GVar G_NEXT__CONSTRUCTOR__XARGS;
static GVar G_Error;
static Obj  GF_Error;
static GVar G_IS__IDENTICAL__OBJ;
static Obj  GF_IS__IDENTICAL__OBJ;
static GVar G_TRY__NEXT__METHOD;
static Obj  GC_TRY__NEXT__METHOD;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_METHODS__OPERATION;
static Obj  GF_METHODS__OPERATION;
static GVar G_fail;
static Obj  GC_fail;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_AttributeValueNotSet;
static GVar G_TypeObj;
static Obj  GF_TypeObj;
static GVar G_FamilyObj;
static Obj  GF_FamilyObj;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[35];
static Obj  NamsFunc[35];
static Int  NargFunc[35];
static Obj  DefaultName;
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_operation )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 5 .. LEN_LIST( methods ) - 3 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(3) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(5), t_5 );
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
  
  /* if methods[i](  ) then */
  CHECK_INT_POS( l_i )
  C_ELM_LIST_FPL( t_7, l_methods, l_i )
  CHECK_FUNC( t_7 )
  t_6 = CALL_0ARGS( t_7 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* return methods[i + 1]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 6 .. LEN_LIST( methods ) - 4 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(4) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(6), t_5 );
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and methods[i]( type1![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_SUM_FIA( t_11, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, t_11 )
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_9, l_methods, l_i )
   CHECK_FUNC( t_9 )
   C_ELM_POSOBJ_NLE( t_10, a_type1, 1 );
   t_8 = CALL_1ARGS( t_9, t_10 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  if ( t_5 ) {
   
   /* return methods[i + 2]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(2) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 4 */
static Obj  HdlrFunc4 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 7 .. LEN_LIST( methods ) - 5 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(5) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(7), t_5 );
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and methods[i]( type1![1], type2![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_SUM_FIA( t_12, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, t_12 )
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_SUM_FIA( t_13, l_i, INTOBJ_INT(2) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_9, l_methods, l_i )
   CHECK_FUNC( t_9 )
   C_ELM_POSOBJ_NLE( t_10, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type2, 1 );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  if ( t_5 ) {
   
   /* return methods[i + 3]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(3) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 5 */
static Obj  HdlrFunc5 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 8 .. LEN_LIST( methods ) - 6 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(6) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(8), t_5 );
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and methods[i]( type1![1], type2![1], type3![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_SUM_FIA( t_13, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, t_13 )
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_SUM_FIA( t_14, l_i, INTOBJ_INT(2) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_SUM_FIA( t_13, l_i, INTOBJ_INT(3) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_9, l_methods, l_i )
   CHECK_FUNC( t_9 )
   C_ELM_POSOBJ_NLE( t_10, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type3, 1 );
   t_8 = CALL_3ARGS( t_9, t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  if ( t_5 ) {
   
   /* return methods[i + 4]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(4) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 9 .. LEN_LIST( methods ) - 7 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(7) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(9), t_5 );
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and IS_SUBSET_FLAGS( type4![2], methods[i + 4] ) and methods[i]( type1![1], type2![1], type3![1], 
   type4![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_SUM_FIA( t_14, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_14 )
  C_ELM_LIST_FPL( t_13, l_methods, t_14 )
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_SUM_FIA( t_15, l_i, INTOBJ_INT(2) )
   CHECK_INT_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, t_15 )
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_11 )
   CHECK_BOOL( t_11 )
   t_10 = (Obj)(UInt)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_SUM_FIA( t_14, l_i, INTOBJ_INT(3) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_SUM_FIA( t_13, l_i, INTOBJ_INT(4) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_9, l_methods, l_i )
   CHECK_FUNC( t_9 )
   C_ELM_POSOBJ_NLE( t_10, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type4, 1 );
   t_8 = CALL_4ARGS( t_9, t_10, t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  if ( t_5 ) {
   
   /* return methods[i + 5]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(5) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4,
 Obj  a_type5 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 10 .. LEN_LIST( methods ) - 8 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(8) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(10), t_5 );
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and IS_SUBSET_FLAGS( type4![2], methods[i + 4] ) and IS_SUBSET_FLAGS( type5![2], methods[i + 5] ) 
and methods[i]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_12 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_13, a_type1, 2 );
  C_SUM_FIA( t_15, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_15 )
  C_ELM_LIST_FPL( t_14, l_methods, t_15 )
  t_11 = CALL_2ARGS( t_12, t_13, t_14 );
  CHECK_FUNC_RESULT( t_11 )
  CHECK_BOOL( t_11 )
  t_10 = (Obj)(UInt)(t_11 != False);
  t_9 = t_10;
  if ( t_9 ) {
   t_13 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_14, a_type2, 2 );
   C_SUM_FIA( t_16, l_i, INTOBJ_INT(2) )
   CHECK_INT_POS( t_16 )
   C_ELM_LIST_FPL( t_15, l_methods, t_16 )
   t_12 = CALL_2ARGS( t_13, t_14, t_15 );
   CHECK_FUNC_RESULT( t_12 )
   CHECK_BOOL( t_12 )
   t_11 = (Obj)(UInt)(t_12 != False);
   t_9 = t_11;
  }
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type3, 2 );
   C_SUM_FIA( t_15, l_i, INTOBJ_INT(3) )
   CHECK_INT_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, t_15 )
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_11 )
   CHECK_BOOL( t_11 )
   t_10 = (Obj)(UInt)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type4, 2 );
   C_SUM_FIA( t_14, l_i, INTOBJ_INT(4) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type5, 2 );
   C_SUM_FIA( t_13, l_i, INTOBJ_INT(5) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_9, l_methods, l_i )
   CHECK_FUNC( t_9 )
   C_ELM_POSOBJ_NLE( t_10, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_14, a_type5, 1 );
   t_8 = CALL_5ARGS( t_9, t_10, t_11, t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  if ( t_5 ) {
   
   /* return methods[i + 6]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(6) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  args )
{
 Obj  a_operation;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_type1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1, 11 .. LEN_LIST( methods ) - 9 ] do */
 t_7 = GF_LEN__LIST;
 t_6 = CALL_1ARGS( t_7, l_methods );
 CHECK_FUNC_RESULT( t_6 )
 C_DIFF_FIA( t_5, t_6, INTOBJ_INT(9) )
 t_4 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(11), t_5 );
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and IS_SUBSET_FLAGS( type4![2], methods[i + 4] ) and IS_SUBSET_FLAGS( type5![2], methods[i + 5] ) 
  and IS_SUBSET_FLAGS( type6![2], methods[i + 6] ) and methods[i]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_13 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_14, a_type1, 2 );
  C_SUM_FIA( t_16, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_16 )
  C_ELM_LIST_FPL( t_15, l_methods, t_16 )
  t_12 = CALL_2ARGS( t_13, t_14, t_15 );
  CHECK_FUNC_RESULT( t_12 )
  CHECK_BOOL( t_12 )
  t_11 = (Obj)(UInt)(t_12 != False);
  t_10 = t_11;
  if ( t_10 ) {
   t_14 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_15, a_type2, 2 );
   C_SUM_FIA( t_17, l_i, INTOBJ_INT(2) )
   CHECK_INT_POS( t_17 )
   C_ELM_LIST_FPL( t_16, l_methods, t_17 )
   t_13 = CALL_2ARGS( t_14, t_15, t_16 );
   CHECK_FUNC_RESULT( t_13 )
   CHECK_BOOL( t_13 )
   t_12 = (Obj)(UInt)(t_13 != False);
   t_10 = t_12;
  }
  t_9 = t_10;
  if ( t_9 ) {
   t_13 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_14, a_type3, 2 );
   C_SUM_FIA( t_16, l_i, INTOBJ_INT(3) )
   CHECK_INT_POS( t_16 )
   C_ELM_LIST_FPL( t_15, l_methods, t_16 )
   t_12 = CALL_2ARGS( t_13, t_14, t_15 );
   CHECK_FUNC_RESULT( t_12 )
   CHECK_BOOL( t_12 )
   t_11 = (Obj)(UInt)(t_12 != False);
   t_9 = t_11;
  }
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type4, 2 );
   C_SUM_FIA( t_15, l_i, INTOBJ_INT(4) )
   CHECK_INT_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, t_15 )
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_11 )
   CHECK_BOOL( t_11 )
   t_10 = (Obj)(UInt)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type5, 2 );
   C_SUM_FIA( t_14, l_i, INTOBJ_INT(5) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type6, 2 );
   C_SUM_FIA( t_13, l_i, INTOBJ_INT(6) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_9, l_methods, l_i )
   CHECK_FUNC( t_9 )
   C_ELM_POSOBJ_NLE( t_10, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_14, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_15, a_type6, 1 );
   t_8 = CALL_6ARGS( t_9, t_10, t_11, t_12, t_13, t_14, t_15 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  if ( t_5 ) {
   
   /* return methods[i + 7]; */
   C_SUM_FIA( t_6, l_i, INTOBJ_INT(7) )
   CHECK_INT_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, t_6 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 t_2 = MakeString( "not supported yet" );
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 10 */
static Obj  HdlrFunc10 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, t_6 )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 11 */
static Obj  HdlrFunc11 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(5), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, t_9 )
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(6), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, t_10 )
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, t_8, t_9 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, t_11 )
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, t_12 )
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, t_8, t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 15 */
static Obj  HdlrFunc15 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, t_13 )
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, t_8, t_9, t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
  C_SUM_FIA( t_14, t_15, INTOBJ_INT(2) )
  CHECK_INT_POS( t_14 )
  C_ELM_LIST_FPL( t_13, l_methods, t_14 )
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, t_15 )
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_11 )
   CHECK_BOOL( t_11 )
   t_10 = (Obj)(UInt)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, t_8, t_9, t_10, t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 t_2 = MakeString( "not supported yet" );
 CALL_1ARGS( t_1, t_2 );
 
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
 Obj  a_attr,
 Obj  a_obj )
{
 Obj l_type = 0;
 Obj l_fam = 0;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_flag = 0;
 Obj l_erg = 0;
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
 
 /* type := TypeObj( obj ); */
 t_2 = GF_TypeObj;
 t_1 = CALL_1ARGS( t_2, a_obj );
 CHECK_FUNC_RESULT( t_1 )
 l_type = t_1;
 
 /* fam := FamilyObj( obj ); */
 t_2 = GF_FamilyObj;
 t_1 = CALL_1ARGS( t_2, a_obj );
 CHECK_FUNC_RESULT( t_1 )
 l_fam = t_1;
 
 /* methods := METHODS_OPERATION( attr, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_attr, INTOBJ_INT(1) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* flag := true; */
  t_3 = True;
  l_flag = t_3;
  
  /* flag := flag and IS_SUBSET_FLAGS( type![2], methods[5 * (i - 1) + 2] ); */
  if ( l_flag == False ) {
   t_3 = l_flag;
  }
  else if ( l_flag == True ) {
   t_5 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_6, l_type, 2 );
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   t_4 = CALL_2ARGS( t_5, t_6, t_7 );
   CHECK_FUNC_RESULT( t_4 )
   CHECK_BOOL( t_4 )
   t_3 = t_4;
  }
  else {
   CHECK_FUNC( l_flag )
   t_6 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_7, l_type, 2 );
   C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_10, INTOBJ_INT(5), t_11 )
   C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
   CHECK_INT_POS( t_9 )
   C_ELM_LIST_FPL( t_8, l_methods, t_9 )
   t_5 = CALL_2ARGS( t_6, t_7, t_8 );
   CHECK_FUNC_RESULT( t_5 )
   CHECK_FUNC( t_5 )
   t_3 = NewAndFilter( l_flag, t_5 );
  }
  l_flag = t_3;
  
  /* if flag then */
  CHECK_BOOL( l_flag )
  t_3 = (Obj)(UInt)(l_flag != False);
  if ( t_3 ) {
   
   /* flag := flag and methods[5 * (i - 1) + 1]( fam ); */
   if ( l_flag == False ) {
    t_3 = l_flag;
   }
   else if ( l_flag == True ) {
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(5), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
    CHECK_INT_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, t_6 )
    CHECK_FUNC( t_5 )
    t_4 = CALL_1ARGS( t_5, l_fam );
    CHECK_FUNC_RESULT( t_4 )
    CHECK_BOOL( t_4 )
    t_3 = t_4;
   }
   else {
    CHECK_FUNC( l_flag )
    C_DIFF_INTOBJS( t_9, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_8, INTOBJ_INT(5), t_9 )
    C_SUM_FIA( t_7, t_8, INTOBJ_INT(1) )
    CHECK_INT_POS( t_7 )
    C_ELM_LIST_FPL( t_6, l_methods, t_7 )
    CHECK_FUNC( t_6 )
    t_5 = CALL_1ARGS( t_6, l_fam );
    CHECK_FUNC_RESULT( t_5 )
    CHECK_FUNC( t_5 )
    t_3 = NewAndFilter( l_flag, t_5 );
   }
   l_flag = t_3;
   
  }
  /* fi */
  
  /* if flag then */
  CHECK_BOOL( l_flag )
  t_3 = (Obj)(UInt)(l_flag != False);
  if ( t_3 ) {
   
   /* attr := methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   a_attr = t_3;
   
   /* erg := attr( obj ); */
   CHECK_FUNC( a_attr )
   t_3 = CALL_1ARGS( a_attr, a_obj );
   CHECK_FUNC_RESULT( t_3 )
   l_erg = t_3;
   
   /* if not IS_IDENTICAL_OBJ( erg, TRY_NEXT_METHOD ) then */
   t_6 = GF_IS__IDENTICAL__OBJ;
   t_7 = GC_TRY__NEXT__METHOD;
   CHECK_BOUND( t_7, "TRY_NEXT_METHOD" )
   t_5 = CALL_2ARGS( t_6, l_erg, t_7 );
   CHECK_FUNC_RESULT( t_5 )
   CHECK_BOOL( t_5 )
   t_4 = (Obj)(UInt)(t_5 != False);
   t_3 = (Obj)(UInt)( ! ((Int)t_4) );
   if ( t_3 ) {
    
    /* return erg; */
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return l_erg;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "No applicable method found for attribute" ); */
 t_1 = GF_Error;
 t_2 = MakeString( "No applicable method found for attribute" );
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 19 */
static Obj  HdlrFunc19 (
 Obj  self,
 Obj  a_operation )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, t_6 )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_flags1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
  C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
  CHECK_INT_POS( t_8 )
  C_ELM_LIST_FPL( t_7, l_methods, t_8 )
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 21 */
static Obj  HdlrFunc21 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(6), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, t_9 )
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(7), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, t_10 )
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, a_flags1, t_8, t_9 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, t_11 )
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, a_flags1, t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4,
 Obj  a_type5 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, t_12 )
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 25 */
static Obj  HdlrFunc25 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_flags1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, t_13 )
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, t_15 )
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_11 )
   CHECK_BOOL( t_11 )
   t_10 = (Obj)(UInt)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
   CHECK_INT_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, t_4 )
   RES_BRK_CURR_STAT();
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
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
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 t_2 = MakeString( "not supported yet" );
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 27 */
static Obj  HdlrFunc27 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, t_6 )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 28 */
static Obj  HdlrFunc28 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
  C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
  CHECK_INT_POS( t_8 )
  C_ELM_LIST_FPL( t_7, l_methods, t_8 )
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 29 */
static Obj  HdlrFunc29 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(6), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, t_9 )
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 30 */
static Obj  HdlrFunc30 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(7), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, t_10 )
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, a_flags1, t_8, t_9 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 31 */
static Obj  HdlrFunc31 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, t_11 )
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, a_flags1, t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 32 */
static Obj  HdlrFunc32 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, t_12 )
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 33 */
static Obj  HdlrFunc33 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 CHECK_INT_SMALL( t_2 )
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, t_13 )
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, t_15 )
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   CHECK_FUNC_RESULT( t_11 )
   CHECK_BOOL( t_11 )
   t_10 = (Obj)(UInt)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, t_14 )
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   CHECK_FUNC_RESULT( t_10 )
   CHECK_BOOL( t_10 )
   t_9 = (Obj)(UInt)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, t_13 )
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_9 )
   CHECK_BOOL( t_9 )
   t_8 = (Obj)(UInt)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, t_12 )
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, t_11 )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, t_8 )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11, t_12 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return fail; */
 t_1 = GC_fail;
 CHECK_BOUND( t_1, "fail" )
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
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
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 t_2 = MakeString( "not supported yet" );
 CALL_1ARGS( t_1, t_2 );
 
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* METHOD_0ARGS := function ( operation )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 0 );
      for i  in [ 1, 5 .. LEN_LIST( methods ) - 3 ]  do
          if methods[i](  )  then
              return methods[i + 1];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(19));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(30));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__0ARGS, t_1 );
 
 /* METHOD_1ARGS := function ( operation, type1 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 1 );
      for i  in [ 1, 6 .. LEN_LIST( methods ) - 4 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and methods[i]( type1![1] )  then
              return methods[i + 2];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(37));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(49));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__1ARGS, t_1 );
 
 /* METHOD_2ARGS := function ( operation, type1, type2 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 2 );
      for i  in [ 1, 7 .. LEN_LIST( methods ) - 5 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and methods[i]( type1![1], type2![1] )  then
              return methods[i + 3];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(56));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(69));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__2ARGS, t_1 );
 
 /* METHOD_3ARGS := function ( operation, type1, type2, type3 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 3 );
      for i  in [ 1, 8 .. LEN_LIST( methods ) - 6 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and methods[i]( type1![1], type2![1], type3![1] )  then
              return methods[i + 4];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(76));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(90));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__3ARGS, t_1 );
 
 /* METHOD_4ARGS := function ( operation, type1, type2, type3, type4 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 4 );
      for i  in [ 1, 9 .. LEN_LIST( methods ) - 7 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and IS_SUBSET_FLAGS( type4![2], methods[i + 4] ) 
              and methods[i]( type1![1], type2![1], type3![1], type4![1] )  then
              return methods[i + 5];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[6], NargFunc[6], NamsFunc[6], HdlrFunc6 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(97));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(114));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__4ARGS, t_1 );
 
 /* METHOD_5ARGS := function ( operation, type1, type2, type3, type4, type5 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 5 );
      for i  in [ 1, 10 .. LEN_LIST( methods ) - 8 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and IS_SUBSET_FLAGS( type4![2], methods[i + 4] ) and IS_SUBSET_FLAGS( type5![2], methods[i + 5] )
              and methods[i]( type1![1], type2![1], type3![1], type4![1], type5![1] )  then
              return methods[i + 6];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[7], NargFunc[7], NamsFunc[7], HdlrFunc7 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(121));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(139));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__5ARGS, t_1 );
 
 /* METHOD_6ARGS := function ( operation, type1, type2, type3, type4, type5, type6 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 6 );
      for i  in [ 1, 11 .. LEN_LIST( methods ) - 9 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[i + 1] ) and IS_SUBSET_FLAGS( type2![2], methods[i + 2] ) and IS_SUBSET_FLAGS( type3![2], methods[i + 3] ) and IS_SUBSET_FLAGS( type4![2], methods[i + 4] ) and IS_SUBSET_FLAGS( type5![2], methods[i + 5] )
                and IS_SUBSET_FLAGS( type6![2], methods[i + 6] ) and methods[i]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] )  then
              return methods[i + 7];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[8], NargFunc[8], NamsFunc[8], HdlrFunc8 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(146));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(165));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__6ARGS, t_1 );
 
 /* METHOD_XARGS := function ( arg... )
      Error( "not supported yet" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[9], NargFunc[9], NamsFunc[9], HdlrFunc9 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(172));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(174));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_METHOD__XARGS, t_1 );
 
 /* NEXT_METHOD_0ARGS := function ( operation, k )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 0 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 4 ]  do
          if methods[4 * (i - 1) + 1](  )  then
              if k = j  then
                  return methods[4 * (i - 1) + 2];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[10], NargFunc[10], NamsFunc[10], HdlrFunc10 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(189));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(205));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__0ARGS, t_1 );
 
 /* NEXT_METHOD_1ARGS := function ( operation, k, type1 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 1 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 5 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] )  then
              if k = j  then
                  return methods[5 * (i - 1) + 3];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[11], NargFunc[11], NamsFunc[11], HdlrFunc11 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(212));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(229));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__1ARGS, t_1 );
 
 /* NEXT_METHOD_2ARGS := function ( operation, k, type1, type2 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 2 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 6 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] )  then
              if k = j  then
                  return methods[6 * (i - 1) + 4];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[12], NargFunc[12], NamsFunc[12], HdlrFunc12 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(236));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(254));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__2ARGS, t_1 );
 
 /* NEXT_METHOD_3ARGS := function ( operation, k, type1, type2, type3 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 3 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 7 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] )
               then
              if k = j  then
                  return methods[7 * (i - 1) + 5];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[13], NargFunc[13], NamsFunc[13], HdlrFunc13 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(261));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(280));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__3ARGS, t_1 );
 
 /* NEXT_METHOD_4ARGS := function ( operation, k, type1, type2, type3, type4 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 4 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 8 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
              and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] )  then
              if k = j  then
                  return methods[8 * (i - 1) + 6];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[14], NargFunc[14], NamsFunc[14], HdlrFunc14 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(287));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(309));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__4ARGS, t_1 );
 
 /* NEXT_METHOD_5ARGS := function ( operation, k, type1, type2, type3, type4, type5 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 5 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 9 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
                and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] )  then
              if k = j  then
                  return methods[9 * (i - 1) + 7];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[15], NargFunc[15], NamsFunc[15], HdlrFunc15 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(316));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(339));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__5ARGS, t_1 );
 
 /* NEXT_METHOD_6ARGS := function ( operation, k, type1, type2, type3, type4, type5, type6 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 6 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 10 ]  do
          if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
                  and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] )  then
              if k = j  then
                  return methods[10 * (i - 1) + 8];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[16], NargFunc[16], NamsFunc[16], HdlrFunc16 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(346));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(370));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__6ARGS, t_1 );
 
 /* NEXT_METHOD_XARGS := function ( arg... )
      Error( "not supported yet" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[17], NargFunc[17], NamsFunc[17], HdlrFunc17 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(377));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(379));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__METHOD__XARGS, t_1 );
 
 /* AttributeValueNotSet := function ( attr, obj )
      local  type, fam, methods, i, flag, erg;
      type := TypeObj( obj );
      fam := FamilyObj( obj );
      methods := METHODS_OPERATION( attr, 1 );
      for i  in [ 1 .. LEN_LIST( methods ) / 5 ]  do
          flag := true;
          flag := flag and IS_SUBSET_FLAGS( type![2], methods[5 * (i - 1) + 2] );
          if flag  then
              flag := flag and methods[5 * (i - 1) + 1]( fam );
          fi;
          if flag  then
              attr := methods[5 * (i - 1) + 3];
              erg := attr( obj );
              if not IS_IDENTICAL_OBJ( erg, TRY_NEXT_METHOD )  then
                  return erg;
              fi;
          fi;
      od;
      Error( "No applicable method found for attribute" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[18], NargFunc[18], NamsFunc[18], HdlrFunc18 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(385));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(406));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_AttributeValueNotSet, t_1 );
 
 /* CONSTRUCTOR_0ARGS := function ( operation )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 0 );
      for i  in [ 1 .. LEN_LIST( methods ) / 4 ]  do
          if methods[4 * (i - 1) + 1](  )  then
              return methods[4 * (i - 1) + 2];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[19], NargFunc[19], NamsFunc[19], HdlrFunc19 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(419));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(430));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__0ARGS, t_1 );
 
 /* CONSTRUCTOR_1ARGS := function ( operation, flags1 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 1 );
      for i  in [ 1 .. LEN_LIST( methods ) / 5 ]  do
          if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 )  then
              return methods[5 * (i - 1) + 3];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[20], NargFunc[20], NamsFunc[20], HdlrFunc20 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(437));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(449));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__1ARGS, t_1 );
 
 /* CONSTRUCTOR_2ARGS := function ( operation, flags1, type2 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 2 );
      for i  in [ 1 .. LEN_LIST( methods ) / 6 ]  do
          if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] )  then
              return methods[6 * (i - 1) + 4];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[21], NargFunc[21], NamsFunc[21], HdlrFunc21 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(456));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(469));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__2ARGS, t_1 );
 
 /* CONSTRUCTOR_3ARGS := function ( operation, flags1, type2, type3 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 3 );
      for i  in [ 1 .. LEN_LIST( methods ) / 7 ]  do
          if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] )  then
              return methods[7 * (i - 1) + 5];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[22], NargFunc[22], NamsFunc[22], HdlrFunc22 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(476));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(490));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__3ARGS, t_1 );
 
 /* CONSTRUCTOR_4ARGS := function ( operation, flags1, type2, type3, type4 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 4 );
      for i  in [ 1 .. LEN_LIST( methods ) / 8 ]  do
          if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
              and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] )  then
              return methods[8 * (i - 1) + 6];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[23], NargFunc[23], NamsFunc[23], HdlrFunc23 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(497));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(514));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__4ARGS, t_1 );
 
 /* CONSTRUCTOR_5ARGS := function ( operation, flags1, type2, type3, type4, type5 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 5 );
      for i  in [ 1 .. LEN_LIST( methods ) / 9 ]  do
          if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
                and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] )  then
              return methods[9 * (i - 1) + 7];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[24], NargFunc[24], NamsFunc[24], HdlrFunc24 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(521));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(539));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__5ARGS, t_1 );
 
 /* CONSTRUCTOR_6ARGS := function ( operation, flags1, type2, type3, type4, type5, type6 )
      local  methods, i;
      methods := METHODS_OPERATION( operation, 6 );
      for i  in [ 1 .. LEN_LIST( methods ) / 10 ]  do
          if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
                  and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] )  then
              return methods[10 * (i - 1) + 8];
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[25], NargFunc[25], NamsFunc[25], HdlrFunc25 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(546));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(565));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__6ARGS, t_1 );
 
 /* CONSTRUCTOR_XARGS := function ( arg... )
      Error( "not supported yet" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[26], NargFunc[26], NamsFunc[26], HdlrFunc26 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(572));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(574));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_CONSTRUCTOR__XARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_0ARGS := function ( operation, k )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 0 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 4 ]  do
          if methods[4 * (i - 1) + 1](  )  then
              if k = j  then
                  return methods[4 * (i - 1) + 2];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[27], NargFunc[27], NamsFunc[27], HdlrFunc27 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(589));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(605));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__0ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_1ARGS := function ( operation, k, flags1 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 1 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 5 ]  do
          if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 )  then
              if k = j  then
                  return methods[5 * (i - 1) + 3];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[28], NargFunc[28], NamsFunc[28], HdlrFunc28 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(612));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(629));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__1ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_2ARGS := function ( operation, k, flags1, type2 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 2 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 6 ]  do
          if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] )  then
              if k = j  then
                  return methods[6 * (i - 1) + 4];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[29], NargFunc[29], NamsFunc[29], HdlrFunc29 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(636));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(654));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__2ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_3ARGS := function ( operation, k, flags1, type2, type3 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 3 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 7 ]  do
          if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] )  then
              if k = j  then
                  return methods[7 * (i - 1) + 5];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[30], NargFunc[30], NamsFunc[30], HdlrFunc30 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(661));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(680));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__3ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_4ARGS := function ( operation, k, flags1, type2, type3, type4 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 4 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 8 ]  do
          if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
              and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] )  then
              if k = j  then
                  return methods[8 * (i - 1) + 6];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[31], NargFunc[31], NamsFunc[31], HdlrFunc31 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(687));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(709));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__4ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_5ARGS := function ( operation, k, flags1, type2, type3, type4, type5 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 5 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 9 ]  do
          if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
                and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] )  then
              if k = j  then
                  return methods[9 * (i - 1) + 7];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[32], NargFunc[32], NamsFunc[32], HdlrFunc32 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(716));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(739));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__5ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_6ARGS := function ( operation, k, flags1, type2, type3, type4, type5, type6 )
      local  methods, i, j;
      methods := METHODS_OPERATION( operation, 6 );
      j := 0;
      for i  in [ 1 .. LEN_LIST( methods ) / 10 ]  do
          if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
                  and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] )  then
              if k = j  then
                  return methods[10 * (i - 1) + 8];
              else
                  j := j + 1;
              fi;
          fi;
      od;
      return fail;
  end; */
 t_1 = NewFunction( NameFunc[33], NargFunc[33], NamsFunc[33], HdlrFunc33 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(746));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(770));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__6ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_XARGS := function ( arg... )
      Error( "not supported yet" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[34], NargFunc[34], NamsFunc[34], HdlrFunc34 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(777));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(779));
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_NEXT__CONSTRUCTOR__XARGS, t_1 );
 
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
 InitFopyGVar( "Error", &GF_Error );
 InitFopyGVar( "IS_IDENTICAL_OBJ", &GF_IS__IDENTICAL__OBJ );
 InitCopyGVar( "TRY_NEXT_METHOD", &GC_TRY__NEXT__METHOD );
 InitFopyGVar( "IS_SUBSET_FLAGS", &GF_IS__SUBSET__FLAGS );
 InitFopyGVar( "METHODS_OPERATION", &GF_METHODS__OPERATION );
 InitCopyGVar( "fail", &GC_fail );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitFopyGVar( "TypeObj", &GF_TypeObj );
 InitFopyGVar( "FamilyObj", &GF_FamilyObj );
 
 /* information for the functions */
 InitGlobalBag( &DefaultName, "GAPROOT/lib/methsel1.g:DefaultName(102657344)" );
 InitGlobalBag( &FileName, "GAPROOT/lib/methsel1.g:FileName(102657344)" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/methsel1.g:HdlrFunc1(102657344)" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/methsel1.g:NameFunc[1](102657344)" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/methsel1.g:HdlrFunc2(102657344)" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/methsel1.g:NameFunc[2](102657344)" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/methsel1.g:HdlrFunc3(102657344)" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/methsel1.g:NameFunc[3](102657344)" );
 InitHandlerFunc( HdlrFunc4, "GAPROOT/lib/methsel1.g:HdlrFunc4(102657344)" );
 InitGlobalBag( &(NameFunc[4]), "GAPROOT/lib/methsel1.g:NameFunc[4](102657344)" );
 InitHandlerFunc( HdlrFunc5, "GAPROOT/lib/methsel1.g:HdlrFunc5(102657344)" );
 InitGlobalBag( &(NameFunc[5]), "GAPROOT/lib/methsel1.g:NameFunc[5](102657344)" );
 InitHandlerFunc( HdlrFunc6, "GAPROOT/lib/methsel1.g:HdlrFunc6(102657344)" );
 InitGlobalBag( &(NameFunc[6]), "GAPROOT/lib/methsel1.g:NameFunc[6](102657344)" );
 InitHandlerFunc( HdlrFunc7, "GAPROOT/lib/methsel1.g:HdlrFunc7(102657344)" );
 InitGlobalBag( &(NameFunc[7]), "GAPROOT/lib/methsel1.g:NameFunc[7](102657344)" );
 InitHandlerFunc( HdlrFunc8, "GAPROOT/lib/methsel1.g:HdlrFunc8(102657344)" );
 InitGlobalBag( &(NameFunc[8]), "GAPROOT/lib/methsel1.g:NameFunc[8](102657344)" );
 InitHandlerFunc( HdlrFunc9, "GAPROOT/lib/methsel1.g:HdlrFunc9(102657344)" );
 InitGlobalBag( &(NameFunc[9]), "GAPROOT/lib/methsel1.g:NameFunc[9](102657344)" );
 InitHandlerFunc( HdlrFunc10, "GAPROOT/lib/methsel1.g:HdlrFunc10(102657344)" );
 InitGlobalBag( &(NameFunc[10]), "GAPROOT/lib/methsel1.g:NameFunc[10](102657344)" );
 InitHandlerFunc( HdlrFunc11, "GAPROOT/lib/methsel1.g:HdlrFunc11(102657344)" );
 InitGlobalBag( &(NameFunc[11]), "GAPROOT/lib/methsel1.g:NameFunc[11](102657344)" );
 InitHandlerFunc( HdlrFunc12, "GAPROOT/lib/methsel1.g:HdlrFunc12(102657344)" );
 InitGlobalBag( &(NameFunc[12]), "GAPROOT/lib/methsel1.g:NameFunc[12](102657344)" );
 InitHandlerFunc( HdlrFunc13, "GAPROOT/lib/methsel1.g:HdlrFunc13(102657344)" );
 InitGlobalBag( &(NameFunc[13]), "GAPROOT/lib/methsel1.g:NameFunc[13](102657344)" );
 InitHandlerFunc( HdlrFunc14, "GAPROOT/lib/methsel1.g:HdlrFunc14(102657344)" );
 InitGlobalBag( &(NameFunc[14]), "GAPROOT/lib/methsel1.g:NameFunc[14](102657344)" );
 InitHandlerFunc( HdlrFunc15, "GAPROOT/lib/methsel1.g:HdlrFunc15(102657344)" );
 InitGlobalBag( &(NameFunc[15]), "GAPROOT/lib/methsel1.g:NameFunc[15](102657344)" );
 InitHandlerFunc( HdlrFunc16, "GAPROOT/lib/methsel1.g:HdlrFunc16(102657344)" );
 InitGlobalBag( &(NameFunc[16]), "GAPROOT/lib/methsel1.g:NameFunc[16](102657344)" );
 InitHandlerFunc( HdlrFunc17, "GAPROOT/lib/methsel1.g:HdlrFunc17(102657344)" );
 InitGlobalBag( &(NameFunc[17]), "GAPROOT/lib/methsel1.g:NameFunc[17](102657344)" );
 InitHandlerFunc( HdlrFunc18, "GAPROOT/lib/methsel1.g:HdlrFunc18(102657344)" );
 InitGlobalBag( &(NameFunc[18]), "GAPROOT/lib/methsel1.g:NameFunc[18](102657344)" );
 InitHandlerFunc( HdlrFunc19, "GAPROOT/lib/methsel1.g:HdlrFunc19(102657344)" );
 InitGlobalBag( &(NameFunc[19]), "GAPROOT/lib/methsel1.g:NameFunc[19](102657344)" );
 InitHandlerFunc( HdlrFunc20, "GAPROOT/lib/methsel1.g:HdlrFunc20(102657344)" );
 InitGlobalBag( &(NameFunc[20]), "GAPROOT/lib/methsel1.g:NameFunc[20](102657344)" );
 InitHandlerFunc( HdlrFunc21, "GAPROOT/lib/methsel1.g:HdlrFunc21(102657344)" );
 InitGlobalBag( &(NameFunc[21]), "GAPROOT/lib/methsel1.g:NameFunc[21](102657344)" );
 InitHandlerFunc( HdlrFunc22, "GAPROOT/lib/methsel1.g:HdlrFunc22(102657344)" );
 InitGlobalBag( &(NameFunc[22]), "GAPROOT/lib/methsel1.g:NameFunc[22](102657344)" );
 InitHandlerFunc( HdlrFunc23, "GAPROOT/lib/methsel1.g:HdlrFunc23(102657344)" );
 InitGlobalBag( &(NameFunc[23]), "GAPROOT/lib/methsel1.g:NameFunc[23](102657344)" );
 InitHandlerFunc( HdlrFunc24, "GAPROOT/lib/methsel1.g:HdlrFunc24(102657344)" );
 InitGlobalBag( &(NameFunc[24]), "GAPROOT/lib/methsel1.g:NameFunc[24](102657344)" );
 InitHandlerFunc( HdlrFunc25, "GAPROOT/lib/methsel1.g:HdlrFunc25(102657344)" );
 InitGlobalBag( &(NameFunc[25]), "GAPROOT/lib/methsel1.g:NameFunc[25](102657344)" );
 InitHandlerFunc( HdlrFunc26, "GAPROOT/lib/methsel1.g:HdlrFunc26(102657344)" );
 InitGlobalBag( &(NameFunc[26]), "GAPROOT/lib/methsel1.g:NameFunc[26](102657344)" );
 InitHandlerFunc( HdlrFunc27, "GAPROOT/lib/methsel1.g:HdlrFunc27(102657344)" );
 InitGlobalBag( &(NameFunc[27]), "GAPROOT/lib/methsel1.g:NameFunc[27](102657344)" );
 InitHandlerFunc( HdlrFunc28, "GAPROOT/lib/methsel1.g:HdlrFunc28(102657344)" );
 InitGlobalBag( &(NameFunc[28]), "GAPROOT/lib/methsel1.g:NameFunc[28](102657344)" );
 InitHandlerFunc( HdlrFunc29, "GAPROOT/lib/methsel1.g:HdlrFunc29(102657344)" );
 InitGlobalBag( &(NameFunc[29]), "GAPROOT/lib/methsel1.g:NameFunc[29](102657344)" );
 InitHandlerFunc( HdlrFunc30, "GAPROOT/lib/methsel1.g:HdlrFunc30(102657344)" );
 InitGlobalBag( &(NameFunc[30]), "GAPROOT/lib/methsel1.g:NameFunc[30](102657344)" );
 InitHandlerFunc( HdlrFunc31, "GAPROOT/lib/methsel1.g:HdlrFunc31(102657344)" );
 InitGlobalBag( &(NameFunc[31]), "GAPROOT/lib/methsel1.g:NameFunc[31](102657344)" );
 InitHandlerFunc( HdlrFunc32, "GAPROOT/lib/methsel1.g:HdlrFunc32(102657344)" );
 InitGlobalBag( &(NameFunc[32]), "GAPROOT/lib/methsel1.g:NameFunc[32](102657344)" );
 InitHandlerFunc( HdlrFunc33, "GAPROOT/lib/methsel1.g:HdlrFunc33(102657344)" );
 InitGlobalBag( &(NameFunc[33]), "GAPROOT/lib/methsel1.g:NameFunc[33](102657344)" );
 InitHandlerFunc( HdlrFunc34, "GAPROOT/lib/methsel1.g:HdlrFunc34(102657344)" );
 InitGlobalBag( &(NameFunc[34]), "GAPROOT/lib/methsel1.g:NameFunc[34](102657344)" );
 
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
 G_METHOD__0ARGS = GVarName( "METHOD_0ARGS" );
 G_METHOD__1ARGS = GVarName( "METHOD_1ARGS" );
 G_METHOD__2ARGS = GVarName( "METHOD_2ARGS" );
 G_METHOD__3ARGS = GVarName( "METHOD_3ARGS" );
 G_METHOD__4ARGS = GVarName( "METHOD_4ARGS" );
 G_METHOD__5ARGS = GVarName( "METHOD_5ARGS" );
 G_METHOD__6ARGS = GVarName( "METHOD_6ARGS" );
 G_METHOD__XARGS = GVarName( "METHOD_XARGS" );
 G_NEXT__METHOD__0ARGS = GVarName( "NEXT_METHOD_0ARGS" );
 G_NEXT__METHOD__1ARGS = GVarName( "NEXT_METHOD_1ARGS" );
 G_NEXT__METHOD__2ARGS = GVarName( "NEXT_METHOD_2ARGS" );
 G_NEXT__METHOD__3ARGS = GVarName( "NEXT_METHOD_3ARGS" );
 G_NEXT__METHOD__4ARGS = GVarName( "NEXT_METHOD_4ARGS" );
 G_NEXT__METHOD__5ARGS = GVarName( "NEXT_METHOD_5ARGS" );
 G_NEXT__METHOD__6ARGS = GVarName( "NEXT_METHOD_6ARGS" );
 G_NEXT__METHOD__XARGS = GVarName( "NEXT_METHOD_XARGS" );
 G_CONSTRUCTOR__0ARGS = GVarName( "CONSTRUCTOR_0ARGS" );
 G_CONSTRUCTOR__1ARGS = GVarName( "CONSTRUCTOR_1ARGS" );
 G_CONSTRUCTOR__2ARGS = GVarName( "CONSTRUCTOR_2ARGS" );
 G_CONSTRUCTOR__3ARGS = GVarName( "CONSTRUCTOR_3ARGS" );
 G_CONSTRUCTOR__4ARGS = GVarName( "CONSTRUCTOR_4ARGS" );
 G_CONSTRUCTOR__5ARGS = GVarName( "CONSTRUCTOR_5ARGS" );
 G_CONSTRUCTOR__6ARGS = GVarName( "CONSTRUCTOR_6ARGS" );
 G_CONSTRUCTOR__XARGS = GVarName( "CONSTRUCTOR_XARGS" );
 G_NEXT__CONSTRUCTOR__0ARGS = GVarName( "NEXT_CONSTRUCTOR_0ARGS" );
 G_NEXT__CONSTRUCTOR__1ARGS = GVarName( "NEXT_CONSTRUCTOR_1ARGS" );
 G_NEXT__CONSTRUCTOR__2ARGS = GVarName( "NEXT_CONSTRUCTOR_2ARGS" );
 G_NEXT__CONSTRUCTOR__3ARGS = GVarName( "NEXT_CONSTRUCTOR_3ARGS" );
 G_NEXT__CONSTRUCTOR__4ARGS = GVarName( "NEXT_CONSTRUCTOR_4ARGS" );
 G_NEXT__CONSTRUCTOR__5ARGS = GVarName( "NEXT_CONSTRUCTOR_5ARGS" );
 G_NEXT__CONSTRUCTOR__6ARGS = GVarName( "NEXT_CONSTRUCTOR_6ARGS" );
 G_NEXT__CONSTRUCTOR__XARGS = GVarName( "NEXT_CONSTRUCTOR_XARGS" );
 G_Error = GVarName( "Error" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_TRY__NEXT__METHOD = GVarName( "TRY_NEXT_METHOD" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_fail = GVarName( "fail" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_AttributeValueNotSet = GVarName( "AttributeValueNotSet" );
 G_TypeObj = GVarName( "TypeObj" );
 G_FamilyObj = GVarName( "FamilyObj" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 DefaultName = MakeString( "local function" );
 FileName = MakeString( "GAPROOT/lib/methsel1.g" );
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 1;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 2;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 3;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 4;
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = 5;
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = 6;
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 7;
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = -1;
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = 2;
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 3;
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 4;
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 5;
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = 6;
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 7;
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 8;
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = -1;
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = 2;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 1;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 2;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 3;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 4;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 5;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 6;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = 7;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = -1;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 3;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 4;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 5;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 6;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 7;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = 8;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = -1;
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);
 SET_ENVI_FUNC( func1, STATE(CurrLVars) );
 CHANGED_BAG( STATE(CurrLVars) );
 body1 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj));
 SET_BODY_FUNC( func1, body1 );
 CHANGED_BAG( func1 );
 CALL_0ARGS( func1 );
 
 /* return success */
 return 0;
 
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_METHOD__0ARGS = GVarName( "METHOD_0ARGS" );
 G_METHOD__1ARGS = GVarName( "METHOD_1ARGS" );
 G_METHOD__2ARGS = GVarName( "METHOD_2ARGS" );
 G_METHOD__3ARGS = GVarName( "METHOD_3ARGS" );
 G_METHOD__4ARGS = GVarName( "METHOD_4ARGS" );
 G_METHOD__5ARGS = GVarName( "METHOD_5ARGS" );
 G_METHOD__6ARGS = GVarName( "METHOD_6ARGS" );
 G_METHOD__XARGS = GVarName( "METHOD_XARGS" );
 G_NEXT__METHOD__0ARGS = GVarName( "NEXT_METHOD_0ARGS" );
 G_NEXT__METHOD__1ARGS = GVarName( "NEXT_METHOD_1ARGS" );
 G_NEXT__METHOD__2ARGS = GVarName( "NEXT_METHOD_2ARGS" );
 G_NEXT__METHOD__3ARGS = GVarName( "NEXT_METHOD_3ARGS" );
 G_NEXT__METHOD__4ARGS = GVarName( "NEXT_METHOD_4ARGS" );
 G_NEXT__METHOD__5ARGS = GVarName( "NEXT_METHOD_5ARGS" );
 G_NEXT__METHOD__6ARGS = GVarName( "NEXT_METHOD_6ARGS" );
 G_NEXT__METHOD__XARGS = GVarName( "NEXT_METHOD_XARGS" );
 G_CONSTRUCTOR__0ARGS = GVarName( "CONSTRUCTOR_0ARGS" );
 G_CONSTRUCTOR__1ARGS = GVarName( "CONSTRUCTOR_1ARGS" );
 G_CONSTRUCTOR__2ARGS = GVarName( "CONSTRUCTOR_2ARGS" );
 G_CONSTRUCTOR__3ARGS = GVarName( "CONSTRUCTOR_3ARGS" );
 G_CONSTRUCTOR__4ARGS = GVarName( "CONSTRUCTOR_4ARGS" );
 G_CONSTRUCTOR__5ARGS = GVarName( "CONSTRUCTOR_5ARGS" );
 G_CONSTRUCTOR__6ARGS = GVarName( "CONSTRUCTOR_6ARGS" );
 G_CONSTRUCTOR__XARGS = GVarName( "CONSTRUCTOR_XARGS" );
 G_NEXT__CONSTRUCTOR__0ARGS = GVarName( "NEXT_CONSTRUCTOR_0ARGS" );
 G_NEXT__CONSTRUCTOR__1ARGS = GVarName( "NEXT_CONSTRUCTOR_1ARGS" );
 G_NEXT__CONSTRUCTOR__2ARGS = GVarName( "NEXT_CONSTRUCTOR_2ARGS" );
 G_NEXT__CONSTRUCTOR__3ARGS = GVarName( "NEXT_CONSTRUCTOR_3ARGS" );
 G_NEXT__CONSTRUCTOR__4ARGS = GVarName( "NEXT_CONSTRUCTOR_4ARGS" );
 G_NEXT__CONSTRUCTOR__5ARGS = GVarName( "NEXT_CONSTRUCTOR_5ARGS" );
 G_NEXT__CONSTRUCTOR__6ARGS = GVarName( "NEXT_CONSTRUCTOR_6ARGS" );
 G_NEXT__CONSTRUCTOR__XARGS = GVarName( "NEXT_CONSTRUCTOR_XARGS" );
 G_Error = GVarName( "Error" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_TRY__NEXT__METHOD = GVarName( "TRY_NEXT_METHOD" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_fail = GVarName( "fail" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_AttributeValueNotSet = GVarName( "AttributeValueNotSet" );
 G_TypeObj = GVarName( "TypeObj" );
 G_FamilyObj = GVarName( "FamilyObj" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 1;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 2;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 3;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 4;
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = 5;
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = 6;
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 7;
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = -1;
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = 2;
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 3;
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 4;
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 5;
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = 6;
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 7;
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 8;
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = -1;
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = 2;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 1;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 2;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 3;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 4;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 5;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 6;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = 7;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = -1;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 3;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 4;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 5;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 6;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 7;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = 8;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = -1;
 
 /* return success */
 return 0;
 
}


/* <name> returns the description of this module */
static StructInitInfo module = {
 /* type        = */ 2,
 /* name        = */ "GAPROOT/lib/methsel1.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 102657344,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__methsel1 ( void )
{
 return &module;
}

/* compiled code ends here */
#endif
