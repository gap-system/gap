/* C file produced by GAC */
#include "compiled.h"

#ifndef AVOID_PRECOMPILED

/* global variables used in handlers */
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
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
static GVar G_VMETHOD__0ARGS;
static GVar G_VMETHOD__1ARGS;
static GVar G_VMETHOD__2ARGS;
static GVar G_VMETHOD__3ARGS;
static GVar G_VMETHOD__4ARGS;
static GVar G_VMETHOD__5ARGS;
static GVar G_VMETHOD__6ARGS;
static GVar G_VMETHOD__XARGS;
static GVar G_NEXT__VMETHOD__0ARGS;
static GVar G_NEXT__VMETHOD__1ARGS;
static GVar G_NEXT__VMETHOD__2ARGS;
static GVar G_NEXT__VMETHOD__3ARGS;
static GVar G_NEXT__VMETHOD__4ARGS;
static GVar G_NEXT__VMETHOD__5ARGS;
static GVar G_NEXT__VMETHOD__6ARGS;
static GVar G_NEXT__VMETHOD__XARGS;
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
static GVar G_VCONSTRUCTOR__0ARGS;
static GVar G_VCONSTRUCTOR__1ARGS;
static GVar G_VCONSTRUCTOR__2ARGS;
static GVar G_VCONSTRUCTOR__3ARGS;
static GVar G_VCONSTRUCTOR__4ARGS;
static GVar G_VCONSTRUCTOR__5ARGS;
static GVar G_VCONSTRUCTOR__6ARGS;
static GVar G_VCONSTRUCTOR__XARGS;
static GVar G_NEXT__VCONSTRUCTOR__0ARGS;
static GVar G_NEXT__VCONSTRUCTOR__1ARGS;
static GVar G_NEXT__VCONSTRUCTOR__2ARGS;
static GVar G_NEXT__VCONSTRUCTOR__3ARGS;
static GVar G_NEXT__VCONSTRUCTOR__4ARGS;
static GVar G_NEXT__VCONSTRUCTOR__5ARGS;
static GVar G_NEXT__VCONSTRUCTOR__6ARGS;
static GVar G_NEXT__VCONSTRUCTOR__XARGS;
static GVar G_IS__IDENTICAL__OBJ;
static Obj  GF_IS__IDENTICAL__OBJ;
static GVar G_TRY__NEXT__METHOD;
static Obj  GC_TRY__NEXT__METHOD;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_METHODS__OPERATION;
static Obj  GF_METHODS__OPERATION;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_Print;
static Obj  GF_Print;
static GVar G_Revision;
static Obj  GC_Revision;
static GVar G_Error;
static Obj  GF_Error;
static GVar G_AttributeValueNotSet;
static GVar G_TypeObj;
static Obj  GF_TypeObj;
static GVar G_FamilyObj;
static Obj  GF_FamilyObj;

/* record names used in handlers */
static RNam R_methsel__g;

/* information for the functions */
static Obj  NameFunc[67];
static Obj  NamsFunc[67];
static Int  NargFunc[67];
static Obj  DefaultName;

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
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(4), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(2) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD( t_10, INTOBJ_INT(5), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(5), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD( t_11, INTOBJ_INT(6), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(6), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD( t_12, INTOBJ_INT(7), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(7), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD( t_13, INTOBJ_INT(8), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(8), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD( t_14, INTOBJ_INT(9), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(9), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_type1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD( t_15, INTOBJ_INT(10), t_16 )
  C_SUM( t_14, t_15, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_14 )
  C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(10), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(8) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
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
    C_PROD( t_5, INTOBJ_INT(4), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(2) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_10, INTOBJ_INT(5), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(5), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(3) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_11, INTOBJ_INT(6), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(6), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(4) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_12, INTOBJ_INT(7), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(7), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(5) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_13, INTOBJ_INT(8), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(8), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(6) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_14, INTOBJ_INT(9), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(9), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(7) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_15, INTOBJ_INT(10), t_16 )
  C_SUM( t_14, t_15, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_14 )
  C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(10), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(8) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 18 */
static Obj  HdlrFunc18 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[4 * (i - 1) + 4], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(4), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(4), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(2) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD( t_10, INTOBJ_INT(5), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[5 * (i - 1) + 5], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(5), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(5), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD( t_11, INTOBJ_INT(6), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[6 * (i - 1) + 6], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(6), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(6), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 21 */
static Obj  HdlrFunc21 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD( t_12, INTOBJ_INT(7), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[7 * (i - 1) + 7], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(7), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(7), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 22 */
static Obj  HdlrFunc22 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD( t_13, INTOBJ_INT(8), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[8 * (i - 1) + 8], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(8), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(8) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(8), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 23 */
static Obj  HdlrFunc23 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD( t_14, INTOBJ_INT(9), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[9 * (i - 1) + 9], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(9), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(9) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(9), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 24 */
static Obj  HdlrFunc24 (
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_type1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD( t_15, INTOBJ_INT(10), t_16 )
  C_SUM( t_14, t_15, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_14 )
  C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[10 * (i - 1) + 10], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(10), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(10) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(10), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(8) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 25 */
static Obj  HdlrFunc25 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 26 */
static Obj  HdlrFunc26 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[4 * (i - 1) + 4], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(4), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(4) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(4), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(2) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 27 */
static Obj  HdlrFunc27 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_10, INTOBJ_INT(5), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[5 * (i - 1) + 5], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(5), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(5) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(5), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(3) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 28 */
static Obj  HdlrFunc28 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_11, INTOBJ_INT(6), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[6 * (i - 1) + 6], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(6), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(6) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(6), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(4) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 29 */
static Obj  HdlrFunc29 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_12, INTOBJ_INT(7), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[7 * (i - 1) + 7], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(7), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(7) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(7), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(5) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 30 */
static Obj  HdlrFunc30 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_13, INTOBJ_INT(8), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[8 * (i - 1) + 8], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(8), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(8) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(8), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(6) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 31 */
static Obj  HdlrFunc31 (
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_14, INTOBJ_INT(9), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[9 * (i - 1) + 9], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(9), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(9) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(9), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(7) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
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
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_15, INTOBJ_INT(10), t_16 )
  C_SUM( t_14, t_15, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_14 )
  C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[10 * (i - 1) + 10], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(10), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(10) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(10), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(8) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 33 */
static Obj  HdlrFunc33 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 34 */
static Obj  HdlrFunc34 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(2) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_10, INTOBJ_INT(5), t_11 )
   C_SUM( t_9, t_10, INTOBJ_INT(2) )
   CHECK_INT_SMALL_POS( t_9 )
   C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
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
    C_PROD( t_7, INTOBJ_INT(5), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(1) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    CHECK_FUNC( t_5 )
    t_4 = CALL_1ARGS( t_5, l_fam );
    CHECK_FUNC_RESULT( t_4 )
    CHECK_BOOL( t_4 )
    t_3 = t_4;
   }
   else {
    CHECK_FUNC( l_flag )
    C_DIFF_INTOBJS( t_9, l_i, INTOBJ_INT(1) )
    C_PROD( t_8, INTOBJ_INT(5), t_9 )
    C_SUM( t_7, t_8, INTOBJ_INT(1) )
    CHECK_INT_SMALL_POS( t_7 )
    C_ELM_LIST_FPL( t_6, l_methods, INT_INTOBJ(t_7) )
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
   C_PROD( t_5, INTOBJ_INT(5), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
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
 C_NEW_STRING( t_2, 40, "No applicable method found for attribute" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 35 */
static Obj  HdlrFunc35 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(4), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(2) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 36 */
static Obj  HdlrFunc36 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_9, INTOBJ_INT(5), t_10 )
  C_SUM( t_8, t_9, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_8 )
  C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_5, INTOBJ_INT(5), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 37 */
static Obj  HdlrFunc37 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_10, INTOBJ_INT(6), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_5, INTOBJ_INT(6), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 38 */
static Obj  HdlrFunc38 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_11, INTOBJ_INT(7), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_5, INTOBJ_INT(7), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 39 */
static Obj  HdlrFunc39 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_12, INTOBJ_INT(8), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_5, INTOBJ_INT(8), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 40 */
static Obj  HdlrFunc40 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_13, INTOBJ_INT(9), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_5, INTOBJ_INT(9), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 41 */
static Obj  HdlrFunc41 (
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_flags1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_14, INTOBJ_INT(10), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   C_PROD( t_5, INTOBJ_INT(10), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(8) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 42 */
static Obj  HdlrFunc42 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 43 */
static Obj  HdlrFunc43 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
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
    C_PROD( t_5, INTOBJ_INT(4), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(2) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 44 */
static Obj  HdlrFunc44 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_9, INTOBJ_INT(5), t_10 )
  C_SUM( t_8, t_9, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_8 )
  C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(5), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(3) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 45 */
static Obj  HdlrFunc45 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_10, INTOBJ_INT(6), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(6), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(4) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 46 */
static Obj  HdlrFunc46 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_11, INTOBJ_INT(7), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(7), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(5) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 47 */
static Obj  HdlrFunc47 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_12, INTOBJ_INT(8), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(8), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(6) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 48 */
static Obj  HdlrFunc48 (
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_13, INTOBJ_INT(9), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(9), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(7) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 49 */
static Obj  HdlrFunc49 (
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
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_14, INTOBJ_INT(10), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    C_PROD( t_5, INTOBJ_INT(10), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(8) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 50 */
static Obj  HdlrFunc50 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 51 */
static Obj  HdlrFunc51 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[4 * (i - 1) + 4], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(4), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(4), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(2) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 52 */
static Obj  HdlrFunc52 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_9, INTOBJ_INT(5), t_10 )
  C_SUM( t_8, t_9, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_8 )
  C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
   CHECK_FUNC( t_7 )
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[5 * (i - 1) + 5], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(5), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(5), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 53 */
static Obj  HdlrFunc53 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_10, INTOBJ_INT(6), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
   CHECK_FUNC( t_7 )
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[6 * (i - 1) + 6], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(6), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(6), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 54 */
static Obj  HdlrFunc54 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_11, INTOBJ_INT(7), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[7 * (i - 1) + 7], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(7), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(7), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 55 */
static Obj  HdlrFunc55 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_12, INTOBJ_INT(8), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[8 * (i - 1) + 8], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(8), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(8) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(8), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 56 */
static Obj  HdlrFunc56 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_13, INTOBJ_INT(9), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[9 * (i - 1) + 9], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(9), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(9) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(9), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 57 */
static Obj  HdlrFunc57 (
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_flags1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_14, INTOBJ_INT(10), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
   
   /* Print( "#I  ", methods[10 * (i - 1) + 10], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD( t_7, INTOBJ_INT(10), t_8 )
   C_SUM( t_6, t_7, INTOBJ_INT(10) )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD( t_5, INTOBJ_INT(10), t_6 )
   C_SUM( t_4, t_5, INTOBJ_INT(8) )
   CHECK_INT_SMALL_POS( t_4 )
   C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 58 */
static Obj  HdlrFunc58 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 59 */
static Obj  HdlrFunc59 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_7, INTOBJ_INT(4), t_8 )
  C_SUM( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_SMALL_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
  CHECK_FUNC( t_5 )
  t_4 = CALL_0ARGS( t_5 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(UInt)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[4 * (i - 1) + 4], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(4), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(4) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(4), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(2) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 60 */
static Obj  HdlrFunc60 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_9, INTOBJ_INT(5), t_10 )
  C_SUM( t_8, t_9, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_8 )
  C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(5), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[5 * (i - 1) + 5], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(5), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(5) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(5), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(3) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 61 */
static Obj  HdlrFunc61 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_10, INTOBJ_INT(6), t_11 )
  C_SUM( t_9, t_10, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_9 )
  C_ELM_LIST_FPL( t_8, l_methods, INT_INTOBJ(t_9) )
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD( t_12, INTOBJ_INT(6), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(6), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[6 * (i - 1) + 6], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(6), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(6) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(6), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(4) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 62 */
static Obj  HdlrFunc62 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_11, INTOBJ_INT(7), t_12 )
  C_SUM( t_10, t_11, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_10 )
  C_ELM_LIST_FPL( t_9, l_methods, INT_INTOBJ(t_10) )
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD( t_13, INTOBJ_INT(7), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(7), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(7), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[7 * (i - 1) + 7], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(7), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(7) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(7), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(5) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 63 */
static Obj  HdlrFunc63 (
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_12, INTOBJ_INT(8), t_13 )
  C_SUM( t_11, t_12, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_11 )
  C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_BOOL( t_8 )
  t_7 = (Obj)(UInt)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD( t_14, INTOBJ_INT(8), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(8), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(8), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(8), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[8 * (i - 1) + 8], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(8), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(8) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(8), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(6) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 64 */
static Obj  HdlrFunc64 (
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
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_13, INTOBJ_INT(9), t_14 )
  C_SUM( t_12, t_13, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_12 )
  C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  CHECK_FUNC_RESULT( t_9 )
  CHECK_BOOL( t_9 )
  t_8 = (Obj)(UInt)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD( t_15, INTOBJ_INT(9), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(9), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(9), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(9), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(9), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[9 * (i - 1) + 9], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(9), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(9) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(9), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(7) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 65 */
static Obj  HdlrFunc65 (
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
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
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
  C_PROD( t_14, INTOBJ_INT(10), t_15 )
  C_SUM( t_13, t_14, INTOBJ_INT(2) )
  CHECK_INT_SMALL_POS( t_13 )
  C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  CHECK_FUNC_RESULT( t_10 )
  CHECK_BOOL( t_10 )
  t_9 = (Obj)(UInt)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD( t_16, INTOBJ_INT(10), t_17 )
   C_SUM( t_15, t_16, INTOBJ_INT(3) )
   CHECK_INT_SMALL_POS( t_15 )
   C_ELM_LIST_FPL( t_14, l_methods, INT_INTOBJ(t_15) )
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
   C_PROD( t_15, INTOBJ_INT(10), t_16 )
   C_SUM( t_14, t_15, INTOBJ_INT(4) )
   CHECK_INT_SMALL_POS( t_14 )
   C_ELM_LIST_FPL( t_13, l_methods, INT_INTOBJ(t_14) )
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
   C_PROD( t_14, INTOBJ_INT(10), t_15 )
   C_SUM( t_13, t_14, INTOBJ_INT(5) )
   CHECK_INT_SMALL_POS( t_13 )
   C_ELM_LIST_FPL( t_12, l_methods, INT_INTOBJ(t_13) )
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
   C_PROD( t_13, INTOBJ_INT(10), t_14 )
   C_SUM( t_12, t_13, INTOBJ_INT(6) )
   CHECK_INT_SMALL_POS( t_12 )
   C_ELM_LIST_FPL( t_11, l_methods, INT_INTOBJ(t_12) )
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
   C_PROD( t_12, INTOBJ_INT(10), t_13 )
   C_SUM( t_11, t_12, INTOBJ_INT(7) )
   CHECK_INT_SMALL_POS( t_11 )
   C_ELM_LIST_FPL( t_10, l_methods, INT_INTOBJ(t_11) )
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD( t_9, INTOBJ_INT(10), t_10 )
   C_SUM( t_8, t_9, INTOBJ_INT(1) )
   CHECK_INT_SMALL_POS( t_8 )
   C_ELM_LIST_FPL( t_7, l_methods, INT_INTOBJ(t_8) )
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
    
    /* Print( "#I  trying next: ", methods[10 * (i - 1) + 10], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD( t_7, INTOBJ_INT(10), t_8 )
    C_SUM( t_6, t_7, INTOBJ_INT(10) )
    CHECK_INT_SMALL_POS( t_6 )
    C_ELM_LIST_FPL( t_5, l_methods, INT_INTOBJ(t_6) )
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD( t_5, INTOBJ_INT(10), t_6 )
    C_SUM( t_4, t_5, INTOBJ_INT(8) )
    CHECK_INT_SMALL_POS( t_4 )
    C_ELM_LIST_FPL( t_3, l_methods, INT_INTOBJ(t_4) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 CHECK_FUNC_RESULT( t_3 )
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 66 */
static Obj  HdlrFunc66 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Revision.methsel_g := "@(#)$Id$"; */
 t_1 = GC_Revision;
 CHECK_BOUND( t_1, "Revision" )
 C_NEW_STRING( t_2, 59, "@(#)$Id$" )
 ASS_REC( t_1, R_methsel__g, t_2 );
 
 /* METHOD_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__0ARGS, t_1 );
 
 /* METHOD_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__1ARGS, t_1 );
 
 /* METHOD_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__2ARGS, t_1 );
 
 /* METHOD_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__3ARGS, t_1 );
 
 /* METHOD_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[6], NargFunc[6], NamsFunc[6], HdlrFunc6 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__4ARGS, t_1 );
 
 /* METHOD_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[7], NargFunc[7], NamsFunc[7], HdlrFunc7 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__5ARGS, t_1 );
 
 /* METHOD_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[8], NargFunc[8], NamsFunc[8], HdlrFunc8 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__6ARGS, t_1 );
 
 /* METHOD_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[9], NargFunc[9], NamsFunc[9], HdlrFunc9 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__XARGS, t_1 );
 
 /* NEXT_METHOD_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[10], NargFunc[10], NamsFunc[10], HdlrFunc10 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__0ARGS, t_1 );
 
 /* NEXT_METHOD_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[11], NargFunc[11], NamsFunc[11], HdlrFunc11 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__1ARGS, t_1 );
 
 /* NEXT_METHOD_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[12], NargFunc[12], NamsFunc[12], HdlrFunc12 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__2ARGS, t_1 );
 
 /* NEXT_METHOD_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[13], NargFunc[13], NamsFunc[13], HdlrFunc13 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__3ARGS, t_1 );
 
 /* NEXT_METHOD_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[14], NargFunc[14], NamsFunc[14], HdlrFunc14 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__4ARGS, t_1 );
 
 /* NEXT_METHOD_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[15], NargFunc[15], NamsFunc[15], HdlrFunc15 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__5ARGS, t_1 );
 
 /* NEXT_METHOD_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[16], NargFunc[16], NamsFunc[16], HdlrFunc16 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__6ARGS, t_1 );
 
 /* NEXT_METHOD_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[17], NargFunc[17], NamsFunc[17], HdlrFunc17 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__XARGS, t_1 );
 
 /* VMETHOD_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[18], NargFunc[18], NamsFunc[18], HdlrFunc18 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__0ARGS, t_1 );
 
 /* VMETHOD_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[19], NargFunc[19], NamsFunc[19], HdlrFunc19 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__1ARGS, t_1 );
 
 /* VMETHOD_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[20], NargFunc[20], NamsFunc[20], HdlrFunc20 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__2ARGS, t_1 );
 
 /* VMETHOD_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[21], NargFunc[21], NamsFunc[21], HdlrFunc21 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__3ARGS, t_1 );
 
 /* VMETHOD_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[22], NargFunc[22], NamsFunc[22], HdlrFunc22 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__4ARGS, t_1 );
 
 /* VMETHOD_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[23], NargFunc[23], NamsFunc[23], HdlrFunc23 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__5ARGS, t_1 );
 
 /* VMETHOD_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[24], NargFunc[24], NamsFunc[24], HdlrFunc24 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__6ARGS, t_1 );
 
 /* VMETHOD_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[25], NargFunc[25], NamsFunc[25], HdlrFunc25 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__XARGS, t_1 );
 
 /* NEXT_VMETHOD_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[26], NargFunc[26], NamsFunc[26], HdlrFunc26 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__0ARGS, t_1 );
 
 /* NEXT_VMETHOD_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[27], NargFunc[27], NamsFunc[27], HdlrFunc27 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__1ARGS, t_1 );
 
 /* NEXT_VMETHOD_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[28], NargFunc[28], NamsFunc[28], HdlrFunc28 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__2ARGS, t_1 );
 
 /* NEXT_VMETHOD_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[29], NargFunc[29], NamsFunc[29], HdlrFunc29 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__3ARGS, t_1 );
 
 /* NEXT_VMETHOD_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[30], NargFunc[30], NamsFunc[30], HdlrFunc30 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__4ARGS, t_1 );
 
 /* NEXT_VMETHOD_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[31], NargFunc[31], NamsFunc[31], HdlrFunc31 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__5ARGS, t_1 );
 
 /* NEXT_VMETHOD_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[32], NargFunc[32], NamsFunc[32], HdlrFunc32 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__6ARGS, t_1 );
 
 /* NEXT_VMETHOD_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[33], NargFunc[33], NamsFunc[33], HdlrFunc33 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__XARGS, t_1 );
 
 /* AttributeValueNotSet := function ... end; */
 t_1 = NewFunction( NameFunc[34], NargFunc[34], NamsFunc[34], HdlrFunc34 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_AttributeValueNotSet, t_1 );
 
 /* CONSTRUCTOR_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[35], NargFunc[35], NamsFunc[35], HdlrFunc35 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__0ARGS, t_1 );
 
 /* CONSTRUCTOR_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[36], NargFunc[36], NamsFunc[36], HdlrFunc36 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__1ARGS, t_1 );
 
 /* CONSTRUCTOR_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[37], NargFunc[37], NamsFunc[37], HdlrFunc37 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__2ARGS, t_1 );
 
 /* CONSTRUCTOR_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[38], NargFunc[38], NamsFunc[38], HdlrFunc38 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__3ARGS, t_1 );
 
 /* CONSTRUCTOR_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[39], NargFunc[39], NamsFunc[39], HdlrFunc39 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__4ARGS, t_1 );
 
 /* CONSTRUCTOR_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[40], NargFunc[40], NamsFunc[40], HdlrFunc40 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__5ARGS, t_1 );
 
 /* CONSTRUCTOR_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[41], NargFunc[41], NamsFunc[41], HdlrFunc41 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__6ARGS, t_1 );
 
 /* CONSTRUCTOR_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[42], NargFunc[42], NamsFunc[42], HdlrFunc42 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__XARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[43], NargFunc[43], NamsFunc[43], HdlrFunc43 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__0ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[44], NargFunc[44], NamsFunc[44], HdlrFunc44 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__1ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[45], NargFunc[45], NamsFunc[45], HdlrFunc45 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__2ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[46], NargFunc[46], NamsFunc[46], HdlrFunc46 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__3ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[47], NargFunc[47], NamsFunc[47], HdlrFunc47 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__4ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[48], NargFunc[48], NamsFunc[48], HdlrFunc48 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__5ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[49], NargFunc[49], NamsFunc[49], HdlrFunc49 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__6ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[50], NargFunc[50], NamsFunc[50], HdlrFunc50 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__XARGS, t_1 );
 
 /* VCONSTRUCTOR_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[51], NargFunc[51], NamsFunc[51], HdlrFunc51 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__0ARGS, t_1 );
 
 /* VCONSTRUCTOR_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[52], NargFunc[52], NamsFunc[52], HdlrFunc52 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__1ARGS, t_1 );
 
 /* VCONSTRUCTOR_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[53], NargFunc[53], NamsFunc[53], HdlrFunc53 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__2ARGS, t_1 );
 
 /* VCONSTRUCTOR_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[54], NargFunc[54], NamsFunc[54], HdlrFunc54 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__3ARGS, t_1 );
 
 /* VCONSTRUCTOR_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[55], NargFunc[55], NamsFunc[55], HdlrFunc55 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__4ARGS, t_1 );
 
 /* VCONSTRUCTOR_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[56], NargFunc[56], NamsFunc[56], HdlrFunc56 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__5ARGS, t_1 );
 
 /* VCONSTRUCTOR_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[57], NargFunc[57], NamsFunc[57], HdlrFunc57 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__6ARGS, t_1 );
 
 /* VCONSTRUCTOR_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[58], NargFunc[58], NamsFunc[58], HdlrFunc58 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__XARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_0ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[59], NargFunc[59], NamsFunc[59], HdlrFunc59 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__0ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_1ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[60], NargFunc[60], NamsFunc[60], HdlrFunc60 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__1ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_2ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[61], NargFunc[61], NamsFunc[61], HdlrFunc61 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__2ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_3ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[62], NargFunc[62], NamsFunc[62], HdlrFunc62 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__3ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_4ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[63], NargFunc[63], NamsFunc[63], HdlrFunc63 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__4ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_5ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[64], NargFunc[64], NamsFunc[64], HdlrFunc64 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__5ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_6ARGS := function ... end; */
 t_1 = NewFunction( NameFunc[65], NargFunc[65], NamsFunc[65], HdlrFunc65 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__6ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_XARGS := function ... end; */
 t_1 = NewFunction( NameFunc[66], NargFunc[66], NamsFunc[66], HdlrFunc66 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__XARGS, t_1 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "NAME_FUNC", &GF_NAME__FUNC );
 InitFopyGVar( "IS_IDENTICAL_OBJ", &GF_IS__IDENTICAL__OBJ );
 InitCopyGVar( "TRY_NEXT_METHOD", &GC_TRY__NEXT__METHOD );
 InitFopyGVar( "IS_SUBSET_FLAGS", &GF_IS__SUBSET__FLAGS );
 InitFopyGVar( "METHODS_OPERATION", &GF_METHODS__OPERATION );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitFopyGVar( "Print", &GF_Print );
 InitCopyGVar( "Revision", &GC_Revision );
 InitFopyGVar( "Error", &GF_Error );
 InitFopyGVar( "TypeObj", &GF_TypeObj );
 InitFopyGVar( "FamilyObj", &GF_FamilyObj );
 
 /* information for the functions */
 InitGlobalBag( &DefaultName, "methsel.g:DefaultName(22351317)" );
 InitHandlerFunc( HdlrFunc1, "methsel.g:HdlrFunc1(22351317)" );
 InitGlobalBag( &(NameFunc[1]), "methsel.g:NameFunc[1](22351317)" );
 InitHandlerFunc( HdlrFunc2, "methsel.g:HdlrFunc2(22351317)" );
 InitGlobalBag( &(NameFunc[2]), "methsel.g:NameFunc[2](22351317)" );
 InitHandlerFunc( HdlrFunc3, "methsel.g:HdlrFunc3(22351317)" );
 InitGlobalBag( &(NameFunc[3]), "methsel.g:NameFunc[3](22351317)" );
 InitHandlerFunc( HdlrFunc4, "methsel.g:HdlrFunc4(22351317)" );
 InitGlobalBag( &(NameFunc[4]), "methsel.g:NameFunc[4](22351317)" );
 InitHandlerFunc( HdlrFunc5, "methsel.g:HdlrFunc5(22351317)" );
 InitGlobalBag( &(NameFunc[5]), "methsel.g:NameFunc[5](22351317)" );
 InitHandlerFunc( HdlrFunc6, "methsel.g:HdlrFunc6(22351317)" );
 InitGlobalBag( &(NameFunc[6]), "methsel.g:NameFunc[6](22351317)" );
 InitHandlerFunc( HdlrFunc7, "methsel.g:HdlrFunc7(22351317)" );
 InitGlobalBag( &(NameFunc[7]), "methsel.g:NameFunc[7](22351317)" );
 InitHandlerFunc( HdlrFunc8, "methsel.g:HdlrFunc8(22351317)" );
 InitGlobalBag( &(NameFunc[8]), "methsel.g:NameFunc[8](22351317)" );
 InitHandlerFunc( HdlrFunc9, "methsel.g:HdlrFunc9(22351317)" );
 InitGlobalBag( &(NameFunc[9]), "methsel.g:NameFunc[9](22351317)" );
 InitHandlerFunc( HdlrFunc10, "methsel.g:HdlrFunc10(22351317)" );
 InitGlobalBag( &(NameFunc[10]), "methsel.g:NameFunc[10](22351317)" );
 InitHandlerFunc( HdlrFunc11, "methsel.g:HdlrFunc11(22351317)" );
 InitGlobalBag( &(NameFunc[11]), "methsel.g:NameFunc[11](22351317)" );
 InitHandlerFunc( HdlrFunc12, "methsel.g:HdlrFunc12(22351317)" );
 InitGlobalBag( &(NameFunc[12]), "methsel.g:NameFunc[12](22351317)" );
 InitHandlerFunc( HdlrFunc13, "methsel.g:HdlrFunc13(22351317)" );
 InitGlobalBag( &(NameFunc[13]), "methsel.g:NameFunc[13](22351317)" );
 InitHandlerFunc( HdlrFunc14, "methsel.g:HdlrFunc14(22351317)" );
 InitGlobalBag( &(NameFunc[14]), "methsel.g:NameFunc[14](22351317)" );
 InitHandlerFunc( HdlrFunc15, "methsel.g:HdlrFunc15(22351317)" );
 InitGlobalBag( &(NameFunc[15]), "methsel.g:NameFunc[15](22351317)" );
 InitHandlerFunc( HdlrFunc16, "methsel.g:HdlrFunc16(22351317)" );
 InitGlobalBag( &(NameFunc[16]), "methsel.g:NameFunc[16](22351317)" );
 InitHandlerFunc( HdlrFunc17, "methsel.g:HdlrFunc17(22351317)" );
 InitGlobalBag( &(NameFunc[17]), "methsel.g:NameFunc[17](22351317)" );
 InitHandlerFunc( HdlrFunc18, "methsel.g:HdlrFunc18(22351317)" );
 InitGlobalBag( &(NameFunc[18]), "methsel.g:NameFunc[18](22351317)" );
 InitHandlerFunc( HdlrFunc19, "methsel.g:HdlrFunc19(22351317)" );
 InitGlobalBag( &(NameFunc[19]), "methsel.g:NameFunc[19](22351317)" );
 InitHandlerFunc( HdlrFunc20, "methsel.g:HdlrFunc20(22351317)" );
 InitGlobalBag( &(NameFunc[20]), "methsel.g:NameFunc[20](22351317)" );
 InitHandlerFunc( HdlrFunc21, "methsel.g:HdlrFunc21(22351317)" );
 InitGlobalBag( &(NameFunc[21]), "methsel.g:NameFunc[21](22351317)" );
 InitHandlerFunc( HdlrFunc22, "methsel.g:HdlrFunc22(22351317)" );
 InitGlobalBag( &(NameFunc[22]), "methsel.g:NameFunc[22](22351317)" );
 InitHandlerFunc( HdlrFunc23, "methsel.g:HdlrFunc23(22351317)" );
 InitGlobalBag( &(NameFunc[23]), "methsel.g:NameFunc[23](22351317)" );
 InitHandlerFunc( HdlrFunc24, "methsel.g:HdlrFunc24(22351317)" );
 InitGlobalBag( &(NameFunc[24]), "methsel.g:NameFunc[24](22351317)" );
 InitHandlerFunc( HdlrFunc25, "methsel.g:HdlrFunc25(22351317)" );
 InitGlobalBag( &(NameFunc[25]), "methsel.g:NameFunc[25](22351317)" );
 InitHandlerFunc( HdlrFunc26, "methsel.g:HdlrFunc26(22351317)" );
 InitGlobalBag( &(NameFunc[26]), "methsel.g:NameFunc[26](22351317)" );
 InitHandlerFunc( HdlrFunc27, "methsel.g:HdlrFunc27(22351317)" );
 InitGlobalBag( &(NameFunc[27]), "methsel.g:NameFunc[27](22351317)" );
 InitHandlerFunc( HdlrFunc28, "methsel.g:HdlrFunc28(22351317)" );
 InitGlobalBag( &(NameFunc[28]), "methsel.g:NameFunc[28](22351317)" );
 InitHandlerFunc( HdlrFunc29, "methsel.g:HdlrFunc29(22351317)" );
 InitGlobalBag( &(NameFunc[29]), "methsel.g:NameFunc[29](22351317)" );
 InitHandlerFunc( HdlrFunc30, "methsel.g:HdlrFunc30(22351317)" );
 InitGlobalBag( &(NameFunc[30]), "methsel.g:NameFunc[30](22351317)" );
 InitHandlerFunc( HdlrFunc31, "methsel.g:HdlrFunc31(22351317)" );
 InitGlobalBag( &(NameFunc[31]), "methsel.g:NameFunc[31](22351317)" );
 InitHandlerFunc( HdlrFunc32, "methsel.g:HdlrFunc32(22351317)" );
 InitGlobalBag( &(NameFunc[32]), "methsel.g:NameFunc[32](22351317)" );
 InitHandlerFunc( HdlrFunc33, "methsel.g:HdlrFunc33(22351317)" );
 InitGlobalBag( &(NameFunc[33]), "methsel.g:NameFunc[33](22351317)" );
 InitHandlerFunc( HdlrFunc34, "methsel.g:HdlrFunc34(22351317)" );
 InitGlobalBag( &(NameFunc[34]), "methsel.g:NameFunc[34](22351317)" );
 InitHandlerFunc( HdlrFunc35, "methsel.g:HdlrFunc35(22351317)" );
 InitGlobalBag( &(NameFunc[35]), "methsel.g:NameFunc[35](22351317)" );
 InitHandlerFunc( HdlrFunc36, "methsel.g:HdlrFunc36(22351317)" );
 InitGlobalBag( &(NameFunc[36]), "methsel.g:NameFunc[36](22351317)" );
 InitHandlerFunc( HdlrFunc37, "methsel.g:HdlrFunc37(22351317)" );
 InitGlobalBag( &(NameFunc[37]), "methsel.g:NameFunc[37](22351317)" );
 InitHandlerFunc( HdlrFunc38, "methsel.g:HdlrFunc38(22351317)" );
 InitGlobalBag( &(NameFunc[38]), "methsel.g:NameFunc[38](22351317)" );
 InitHandlerFunc( HdlrFunc39, "methsel.g:HdlrFunc39(22351317)" );
 InitGlobalBag( &(NameFunc[39]), "methsel.g:NameFunc[39](22351317)" );
 InitHandlerFunc( HdlrFunc40, "methsel.g:HdlrFunc40(22351317)" );
 InitGlobalBag( &(NameFunc[40]), "methsel.g:NameFunc[40](22351317)" );
 InitHandlerFunc( HdlrFunc41, "methsel.g:HdlrFunc41(22351317)" );
 InitGlobalBag( &(NameFunc[41]), "methsel.g:NameFunc[41](22351317)" );
 InitHandlerFunc( HdlrFunc42, "methsel.g:HdlrFunc42(22351317)" );
 InitGlobalBag( &(NameFunc[42]), "methsel.g:NameFunc[42](22351317)" );
 InitHandlerFunc( HdlrFunc43, "methsel.g:HdlrFunc43(22351317)" );
 InitGlobalBag( &(NameFunc[43]), "methsel.g:NameFunc[43](22351317)" );
 InitHandlerFunc( HdlrFunc44, "methsel.g:HdlrFunc44(22351317)" );
 InitGlobalBag( &(NameFunc[44]), "methsel.g:NameFunc[44](22351317)" );
 InitHandlerFunc( HdlrFunc45, "methsel.g:HdlrFunc45(22351317)" );
 InitGlobalBag( &(NameFunc[45]), "methsel.g:NameFunc[45](22351317)" );
 InitHandlerFunc( HdlrFunc46, "methsel.g:HdlrFunc46(22351317)" );
 InitGlobalBag( &(NameFunc[46]), "methsel.g:NameFunc[46](22351317)" );
 InitHandlerFunc( HdlrFunc47, "methsel.g:HdlrFunc47(22351317)" );
 InitGlobalBag( &(NameFunc[47]), "methsel.g:NameFunc[47](22351317)" );
 InitHandlerFunc( HdlrFunc48, "methsel.g:HdlrFunc48(22351317)" );
 InitGlobalBag( &(NameFunc[48]), "methsel.g:NameFunc[48](22351317)" );
 InitHandlerFunc( HdlrFunc49, "methsel.g:HdlrFunc49(22351317)" );
 InitGlobalBag( &(NameFunc[49]), "methsel.g:NameFunc[49](22351317)" );
 InitHandlerFunc( HdlrFunc50, "methsel.g:HdlrFunc50(22351317)" );
 InitGlobalBag( &(NameFunc[50]), "methsel.g:NameFunc[50](22351317)" );
 InitHandlerFunc( HdlrFunc51, "methsel.g:HdlrFunc51(22351317)" );
 InitGlobalBag( &(NameFunc[51]), "methsel.g:NameFunc[51](22351317)" );
 InitHandlerFunc( HdlrFunc52, "methsel.g:HdlrFunc52(22351317)" );
 InitGlobalBag( &(NameFunc[52]), "methsel.g:NameFunc[52](22351317)" );
 InitHandlerFunc( HdlrFunc53, "methsel.g:HdlrFunc53(22351317)" );
 InitGlobalBag( &(NameFunc[53]), "methsel.g:NameFunc[53](22351317)" );
 InitHandlerFunc( HdlrFunc54, "methsel.g:HdlrFunc54(22351317)" );
 InitGlobalBag( &(NameFunc[54]), "methsel.g:NameFunc[54](22351317)" );
 InitHandlerFunc( HdlrFunc55, "methsel.g:HdlrFunc55(22351317)" );
 InitGlobalBag( &(NameFunc[55]), "methsel.g:NameFunc[55](22351317)" );
 InitHandlerFunc( HdlrFunc56, "methsel.g:HdlrFunc56(22351317)" );
 InitGlobalBag( &(NameFunc[56]), "methsel.g:NameFunc[56](22351317)" );
 InitHandlerFunc( HdlrFunc57, "methsel.g:HdlrFunc57(22351317)" );
 InitGlobalBag( &(NameFunc[57]), "methsel.g:NameFunc[57](22351317)" );
 InitHandlerFunc( HdlrFunc58, "methsel.g:HdlrFunc58(22351317)" );
 InitGlobalBag( &(NameFunc[58]), "methsel.g:NameFunc[58](22351317)" );
 InitHandlerFunc( HdlrFunc59, "methsel.g:HdlrFunc59(22351317)" );
 InitGlobalBag( &(NameFunc[59]), "methsel.g:NameFunc[59](22351317)" );
 InitHandlerFunc( HdlrFunc60, "methsel.g:HdlrFunc60(22351317)" );
 InitGlobalBag( &(NameFunc[60]), "methsel.g:NameFunc[60](22351317)" );
 InitHandlerFunc( HdlrFunc61, "methsel.g:HdlrFunc61(22351317)" );
 InitGlobalBag( &(NameFunc[61]), "methsel.g:NameFunc[61](22351317)" );
 InitHandlerFunc( HdlrFunc62, "methsel.g:HdlrFunc62(22351317)" );
 InitGlobalBag( &(NameFunc[62]), "methsel.g:NameFunc[62](22351317)" );
 InitHandlerFunc( HdlrFunc63, "methsel.g:HdlrFunc63(22351317)" );
 InitGlobalBag( &(NameFunc[63]), "methsel.g:NameFunc[63](22351317)" );
 InitHandlerFunc( HdlrFunc64, "methsel.g:HdlrFunc64(22351317)" );
 InitGlobalBag( &(NameFunc[64]), "methsel.g:NameFunc[64](22351317)" );
 InitHandlerFunc( HdlrFunc65, "methsel.g:HdlrFunc65(22351317)" );
 InitGlobalBag( &(NameFunc[65]), "methsel.g:NameFunc[65](22351317)" );
 InitHandlerFunc( HdlrFunc66, "methsel.g:HdlrFunc66(22351317)" );
 InitGlobalBag( &(NameFunc[66]), "methsel.g:NameFunc[66](22351317)" );
 
 /* return success */
 return 0;
 
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
 Obj func1;
 
 /* Complete Copy/Fopy registration */
 UpdateCopyFopyInfo();
 
 /* global variables used in handlers */
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
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
 G_VMETHOD__0ARGS = GVarName( "VMETHOD_0ARGS" );
 G_VMETHOD__1ARGS = GVarName( "VMETHOD_1ARGS" );
 G_VMETHOD__2ARGS = GVarName( "VMETHOD_2ARGS" );
 G_VMETHOD__3ARGS = GVarName( "VMETHOD_3ARGS" );
 G_VMETHOD__4ARGS = GVarName( "VMETHOD_4ARGS" );
 G_VMETHOD__5ARGS = GVarName( "VMETHOD_5ARGS" );
 G_VMETHOD__6ARGS = GVarName( "VMETHOD_6ARGS" );
 G_VMETHOD__XARGS = GVarName( "VMETHOD_XARGS" );
 G_NEXT__VMETHOD__0ARGS = GVarName( "NEXT_VMETHOD_0ARGS" );
 G_NEXT__VMETHOD__1ARGS = GVarName( "NEXT_VMETHOD_1ARGS" );
 G_NEXT__VMETHOD__2ARGS = GVarName( "NEXT_VMETHOD_2ARGS" );
 G_NEXT__VMETHOD__3ARGS = GVarName( "NEXT_VMETHOD_3ARGS" );
 G_NEXT__VMETHOD__4ARGS = GVarName( "NEXT_VMETHOD_4ARGS" );
 G_NEXT__VMETHOD__5ARGS = GVarName( "NEXT_VMETHOD_5ARGS" );
 G_NEXT__VMETHOD__6ARGS = GVarName( "NEXT_VMETHOD_6ARGS" );
 G_NEXT__VMETHOD__XARGS = GVarName( "NEXT_VMETHOD_XARGS" );
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
 G_VCONSTRUCTOR__0ARGS = GVarName( "VCONSTRUCTOR_0ARGS" );
 G_VCONSTRUCTOR__1ARGS = GVarName( "VCONSTRUCTOR_1ARGS" );
 G_VCONSTRUCTOR__2ARGS = GVarName( "VCONSTRUCTOR_2ARGS" );
 G_VCONSTRUCTOR__3ARGS = GVarName( "VCONSTRUCTOR_3ARGS" );
 G_VCONSTRUCTOR__4ARGS = GVarName( "VCONSTRUCTOR_4ARGS" );
 G_VCONSTRUCTOR__5ARGS = GVarName( "VCONSTRUCTOR_5ARGS" );
 G_VCONSTRUCTOR__6ARGS = GVarName( "VCONSTRUCTOR_6ARGS" );
 G_VCONSTRUCTOR__XARGS = GVarName( "VCONSTRUCTOR_XARGS" );
 G_NEXT__VCONSTRUCTOR__0ARGS = GVarName( "NEXT_VCONSTRUCTOR_0ARGS" );
 G_NEXT__VCONSTRUCTOR__1ARGS = GVarName( "NEXT_VCONSTRUCTOR_1ARGS" );
 G_NEXT__VCONSTRUCTOR__2ARGS = GVarName( "NEXT_VCONSTRUCTOR_2ARGS" );
 G_NEXT__VCONSTRUCTOR__3ARGS = GVarName( "NEXT_VCONSTRUCTOR_3ARGS" );
 G_NEXT__VCONSTRUCTOR__4ARGS = GVarName( "NEXT_VCONSTRUCTOR_4ARGS" );
 G_NEXT__VCONSTRUCTOR__5ARGS = GVarName( "NEXT_VCONSTRUCTOR_5ARGS" );
 G_NEXT__VCONSTRUCTOR__6ARGS = GVarName( "NEXT_VCONSTRUCTOR_6ARGS" );
 G_NEXT__VCONSTRUCTOR__XARGS = GVarName( "NEXT_VCONSTRUCTOR_XARGS" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_TRY__NEXT__METHOD = GVarName( "TRY_NEXT_METHOD" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_Print = GVarName( "Print" );
 G_Revision = GVarName( "Revision" );
 G_Error = GVarName( "Error" );
 G_AttributeValueNotSet = GVarName( "AttributeValueNotSet" );
 G_TypeObj = GVarName( "TypeObj" );
 G_FamilyObj = GVarName( "FamilyObj" );
 
 /* record names used in handlers */
 R_methsel__g = RNamName( "methsel_g" );
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" )
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
 NargFunc[18] = 1;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 2;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 3;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 4;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 5;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 6;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 7;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = -1;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 2;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 3;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 4;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 5;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 6;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 7;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 8;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = -1;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = 2;
 NameFunc[35] = DefaultName;
 NamsFunc[35] = 0;
 NargFunc[35] = 1;
 NameFunc[36] = DefaultName;
 NamsFunc[36] = 0;
 NargFunc[36] = 2;
 NameFunc[37] = DefaultName;
 NamsFunc[37] = 0;
 NargFunc[37] = 3;
 NameFunc[38] = DefaultName;
 NamsFunc[38] = 0;
 NargFunc[38] = 4;
 NameFunc[39] = DefaultName;
 NamsFunc[39] = 0;
 NargFunc[39] = 5;
 NameFunc[40] = DefaultName;
 NamsFunc[40] = 0;
 NargFunc[40] = 6;
 NameFunc[41] = DefaultName;
 NamsFunc[41] = 0;
 NargFunc[41] = 7;
 NameFunc[42] = DefaultName;
 NamsFunc[42] = 0;
 NargFunc[42] = -1;
 NameFunc[43] = DefaultName;
 NamsFunc[43] = 0;
 NargFunc[43] = 2;
 NameFunc[44] = DefaultName;
 NamsFunc[44] = 0;
 NargFunc[44] = 3;
 NameFunc[45] = DefaultName;
 NamsFunc[45] = 0;
 NargFunc[45] = 4;
 NameFunc[46] = DefaultName;
 NamsFunc[46] = 0;
 NargFunc[46] = 5;
 NameFunc[47] = DefaultName;
 NamsFunc[47] = 0;
 NargFunc[47] = 6;
 NameFunc[48] = DefaultName;
 NamsFunc[48] = 0;
 NargFunc[48] = 7;
 NameFunc[49] = DefaultName;
 NamsFunc[49] = 0;
 NargFunc[49] = 8;
 NameFunc[50] = DefaultName;
 NamsFunc[50] = 0;
 NargFunc[50] = -1;
 NameFunc[51] = DefaultName;
 NamsFunc[51] = 0;
 NargFunc[51] = 1;
 NameFunc[52] = DefaultName;
 NamsFunc[52] = 0;
 NargFunc[52] = 2;
 NameFunc[53] = DefaultName;
 NamsFunc[53] = 0;
 NargFunc[53] = 3;
 NameFunc[54] = DefaultName;
 NamsFunc[54] = 0;
 NargFunc[54] = 4;
 NameFunc[55] = DefaultName;
 NamsFunc[55] = 0;
 NargFunc[55] = 5;
 NameFunc[56] = DefaultName;
 NamsFunc[56] = 0;
 NargFunc[56] = 6;
 NameFunc[57] = DefaultName;
 NamsFunc[57] = 0;
 NargFunc[57] = 7;
 NameFunc[58] = DefaultName;
 NamsFunc[58] = 0;
 NargFunc[58] = -1;
 NameFunc[59] = DefaultName;
 NamsFunc[59] = 0;
 NargFunc[59] = 2;
 NameFunc[60] = DefaultName;
 NamsFunc[60] = 0;
 NargFunc[60] = 3;
 NameFunc[61] = DefaultName;
 NamsFunc[61] = 0;
 NargFunc[61] = 4;
 NameFunc[62] = DefaultName;
 NamsFunc[62] = 0;
 NargFunc[62] = 5;
 NameFunc[63] = DefaultName;
 NamsFunc[63] = 0;
 NargFunc[63] = 6;
 NameFunc[64] = DefaultName;
 NamsFunc[64] = 0;
 NargFunc[64] = 7;
 NameFunc[65] = DefaultName;
 NamsFunc[65] = 0;
 NargFunc[65] = 8;
 NameFunc[66] = DefaultName;
 NamsFunc[66] = 0;
 NargFunc[66] = -1;
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);
 ENVI_FUNC( func1 ) = CurrLVars;
 CHANGED_BAG( CurrLVars );
 CALL_0ARGS( func1 );
 
 /* return success */
 return 0;
 
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
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
 G_VMETHOD__0ARGS = GVarName( "VMETHOD_0ARGS" );
 G_VMETHOD__1ARGS = GVarName( "VMETHOD_1ARGS" );
 G_VMETHOD__2ARGS = GVarName( "VMETHOD_2ARGS" );
 G_VMETHOD__3ARGS = GVarName( "VMETHOD_3ARGS" );
 G_VMETHOD__4ARGS = GVarName( "VMETHOD_4ARGS" );
 G_VMETHOD__5ARGS = GVarName( "VMETHOD_5ARGS" );
 G_VMETHOD__6ARGS = GVarName( "VMETHOD_6ARGS" );
 G_VMETHOD__XARGS = GVarName( "VMETHOD_XARGS" );
 G_NEXT__VMETHOD__0ARGS = GVarName( "NEXT_VMETHOD_0ARGS" );
 G_NEXT__VMETHOD__1ARGS = GVarName( "NEXT_VMETHOD_1ARGS" );
 G_NEXT__VMETHOD__2ARGS = GVarName( "NEXT_VMETHOD_2ARGS" );
 G_NEXT__VMETHOD__3ARGS = GVarName( "NEXT_VMETHOD_3ARGS" );
 G_NEXT__VMETHOD__4ARGS = GVarName( "NEXT_VMETHOD_4ARGS" );
 G_NEXT__VMETHOD__5ARGS = GVarName( "NEXT_VMETHOD_5ARGS" );
 G_NEXT__VMETHOD__6ARGS = GVarName( "NEXT_VMETHOD_6ARGS" );
 G_NEXT__VMETHOD__XARGS = GVarName( "NEXT_VMETHOD_XARGS" );
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
 G_VCONSTRUCTOR__0ARGS = GVarName( "VCONSTRUCTOR_0ARGS" );
 G_VCONSTRUCTOR__1ARGS = GVarName( "VCONSTRUCTOR_1ARGS" );
 G_VCONSTRUCTOR__2ARGS = GVarName( "VCONSTRUCTOR_2ARGS" );
 G_VCONSTRUCTOR__3ARGS = GVarName( "VCONSTRUCTOR_3ARGS" );
 G_VCONSTRUCTOR__4ARGS = GVarName( "VCONSTRUCTOR_4ARGS" );
 G_VCONSTRUCTOR__5ARGS = GVarName( "VCONSTRUCTOR_5ARGS" );
 G_VCONSTRUCTOR__6ARGS = GVarName( "VCONSTRUCTOR_6ARGS" );
 G_VCONSTRUCTOR__XARGS = GVarName( "VCONSTRUCTOR_XARGS" );
 G_NEXT__VCONSTRUCTOR__0ARGS = GVarName( "NEXT_VCONSTRUCTOR_0ARGS" );
 G_NEXT__VCONSTRUCTOR__1ARGS = GVarName( "NEXT_VCONSTRUCTOR_1ARGS" );
 G_NEXT__VCONSTRUCTOR__2ARGS = GVarName( "NEXT_VCONSTRUCTOR_2ARGS" );
 G_NEXT__VCONSTRUCTOR__3ARGS = GVarName( "NEXT_VCONSTRUCTOR_3ARGS" );
 G_NEXT__VCONSTRUCTOR__4ARGS = GVarName( "NEXT_VCONSTRUCTOR_4ARGS" );
 G_NEXT__VCONSTRUCTOR__5ARGS = GVarName( "NEXT_VCONSTRUCTOR_5ARGS" );
 G_NEXT__VCONSTRUCTOR__6ARGS = GVarName( "NEXT_VCONSTRUCTOR_6ARGS" );
 G_NEXT__VCONSTRUCTOR__XARGS = GVarName( "NEXT_VCONSTRUCTOR_XARGS" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_TRY__NEXT__METHOD = GVarName( "TRY_NEXT_METHOD" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_Print = GVarName( "Print" );
 G_Revision = GVarName( "Revision" );
 G_Error = GVarName( "Error" );
 G_AttributeValueNotSet = GVarName( "AttributeValueNotSet" );
 G_TypeObj = GVarName( "TypeObj" );
 G_FamilyObj = GVarName( "FamilyObj" );
 
 /* record names used in handlers */
 R_methsel__g = RNamName( "methsel_g" );
 
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
 NargFunc[18] = 1;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 2;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 3;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 4;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 5;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 6;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 7;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = -1;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 2;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 3;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 4;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 5;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 6;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 7;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 8;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = -1;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = 2;
 NameFunc[35] = DefaultName;
 NamsFunc[35] = 0;
 NargFunc[35] = 1;
 NameFunc[36] = DefaultName;
 NamsFunc[36] = 0;
 NargFunc[36] = 2;
 NameFunc[37] = DefaultName;
 NamsFunc[37] = 0;
 NargFunc[37] = 3;
 NameFunc[38] = DefaultName;
 NamsFunc[38] = 0;
 NargFunc[38] = 4;
 NameFunc[39] = DefaultName;
 NamsFunc[39] = 0;
 NargFunc[39] = 5;
 NameFunc[40] = DefaultName;
 NamsFunc[40] = 0;
 NargFunc[40] = 6;
 NameFunc[41] = DefaultName;
 NamsFunc[41] = 0;
 NargFunc[41] = 7;
 NameFunc[42] = DefaultName;
 NamsFunc[42] = 0;
 NargFunc[42] = -1;
 NameFunc[43] = DefaultName;
 NamsFunc[43] = 0;
 NargFunc[43] = 2;
 NameFunc[44] = DefaultName;
 NamsFunc[44] = 0;
 NargFunc[44] = 3;
 NameFunc[45] = DefaultName;
 NamsFunc[45] = 0;
 NargFunc[45] = 4;
 NameFunc[46] = DefaultName;
 NamsFunc[46] = 0;
 NargFunc[46] = 5;
 NameFunc[47] = DefaultName;
 NamsFunc[47] = 0;
 NargFunc[47] = 6;
 NameFunc[48] = DefaultName;
 NamsFunc[48] = 0;
 NargFunc[48] = 7;
 NameFunc[49] = DefaultName;
 NamsFunc[49] = 0;
 NargFunc[49] = 8;
 NameFunc[50] = DefaultName;
 NamsFunc[50] = 0;
 NargFunc[50] = -1;
 NameFunc[51] = DefaultName;
 NamsFunc[51] = 0;
 NargFunc[51] = 1;
 NameFunc[52] = DefaultName;
 NamsFunc[52] = 0;
 NargFunc[52] = 2;
 NameFunc[53] = DefaultName;
 NamsFunc[53] = 0;
 NargFunc[53] = 3;
 NameFunc[54] = DefaultName;
 NamsFunc[54] = 0;
 NargFunc[54] = 4;
 NameFunc[55] = DefaultName;
 NamsFunc[55] = 0;
 NargFunc[55] = 5;
 NameFunc[56] = DefaultName;
 NamsFunc[56] = 0;
 NargFunc[56] = 6;
 NameFunc[57] = DefaultName;
 NamsFunc[57] = 0;
 NargFunc[57] = 7;
 NameFunc[58] = DefaultName;
 NamsFunc[58] = 0;
 NargFunc[58] = -1;
 NameFunc[59] = DefaultName;
 NamsFunc[59] = 0;
 NargFunc[59] = 2;
 NameFunc[60] = DefaultName;
 NamsFunc[60] = 0;
 NargFunc[60] = 3;
 NameFunc[61] = DefaultName;
 NamsFunc[61] = 0;
 NargFunc[61] = 4;
 NameFunc[62] = DefaultName;
 NamsFunc[62] = 0;
 NargFunc[62] = 5;
 NameFunc[63] = DefaultName;
 NamsFunc[63] = 0;
 NargFunc[63] = 6;
 NameFunc[64] = DefaultName;
 NamsFunc[64] = 0;
 NargFunc[64] = 7;
 NameFunc[65] = DefaultName;
 NamsFunc[65] = 0;
 NargFunc[65] = 8;
 NameFunc[66] = DefaultName;
 NamsFunc[66] = 0;
 NargFunc[66] = -1;
 
 /* return success */
 return 0;
 
}


/* <name> returns the description of this module */
static StructInitInfo module = {
 /* type        = */ 2,
 /* name        = */ "methsel.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 22351317,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__methsel ( void )
{
 return &module;
}

#endif

/* compiled code ends here */
