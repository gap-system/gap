#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include <src/compiled.h>

/* global variables used in handlers */
static GVar G_REREADING;
static Obj  GC_REREADING;
static GVar G_SHALLOW__COPY__OBJ;
static Obj  GF_SHALLOW__COPY__OBJ;
static GVar G_PRINT__OBJ;
static Obj  GC_PRINT__OBJ;
static GVar G_GAPInfo;
static Obj  GC_GAPInfo;
static GVar G_IS__FUNCTION;
static Obj  GF_IS__FUNCTION;
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
static GVar G_NARG__FUNC;
static Obj  GF_NARG__FUNC;
static GVar G_IS__OPERATION;
static Obj  GF_IS__OPERATION;
static GVar G_AINV;
static Obj  GF_AINV;
static GVar G_IS__INT;
static Obj  GF_IS__INT;
static GVar G_IS__LIST;
static Obj  GF_IS__LIST;
static GVar G_ADD__LIST;
static Obj  GF_ADD__LIST;
static GVar G_IS__STRING__REP;
static Obj  GF_IS__STRING__REP;
static GVar G_Error;
static Obj  GF_Error;
static GVar G_TYPE__OBJ;
static Obj  GF_TYPE__OBJ;
static GVar G_IMMUTABLE__COPY__OBJ;
static Obj  GF_IMMUTABLE__COPY__OBJ;
static GVar G_IS__IDENTICAL__OBJ;
static Obj  GF_IS__IDENTICAL__OBJ;
static GVar G_MakeImmutable;
static Obj  GF_MakeImmutable;
static GVar G_IS__OBJECT;
static Obj  GC_IS__OBJECT;
static GVar G_TRY__NEXT__METHOD;
static Obj  GC_TRY__NEXT__METHOD;
static GVar G_SUB__FLAGS;
static Obj  GF_SUB__FLAGS;
static GVar G_WITH__HIDDEN__IMPS__FLAGS;
static Obj  GF_WITH__HIDDEN__IMPS__FLAGS;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_TRUES__FLAGS;
static Obj  GF_TRUES__FLAGS;
static GVar G_SIZE__FLAGS;
static Obj  GF_SIZE__FLAGS;
static GVar G_LEN__FLAGS;
static Obj  GF_LEN__FLAGS;
static GVar G_ELM__FLAGS;
static Obj  GF_ELM__FLAGS;
static GVar G_FLAG1__FILTER;
static Obj  GF_FLAG1__FILTER;
static GVar G_FLAGS__FILTER;
static Obj  GF_FLAGS__FILTER;
static GVar G_METHODS__OPERATION;
static Obj  GF_METHODS__OPERATION;
static GVar G_SET__METHODS__OPERATION;
static Obj  GF_SET__METHODS__OPERATION;
static GVar G_DO__NOTHING__SETTER;
static Obj  GC_DO__NOTHING__SETTER;
static GVar G_QUO__INT;
static Obj  GF_QUO__INT;
static GVar G_RETURN__TRUE;
static Obj  GC_RETURN__TRUE;
static GVar G_RETURN__FALSE;
static Obj  GC_RETURN__FALSE;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_APPEND__LIST__INTR;
static Obj  GF_APPEND__LIST__INTR;
static GVar G_CONV__STRING;
static Obj  GF_CONV__STRING;
static GVar G_Print;
static Obj  GF_Print;
static GVar G_ViewObj;
static Obj  GC_ViewObj;
static GVar G_DO__LOCK;
static Obj  GF_DO__LOCK;
static GVar G_WRITE__LOCK;
static Obj  GF_WRITE__LOCK;
static GVar G_READ__LOCK;
static Obj  GF_READ__LOCK;
static GVar G_UNLOCK;
static Obj  GF_UNLOCK;
static GVar G_MakeReadOnlyObj;
static Obj  GF_MakeReadOnlyObj;
static GVar G_RUN__IMMEDIATE__METHODS__CHECKS;
static Obj  GC_RUN__IMMEDIATE__METHODS__CHECKS;
static GVar G_RUN__IMMEDIATE__METHODS__HITS;
static Obj  GC_RUN__IMMEDIATE__METHODS__HITS;
static GVar G_BIND__GLOBAL;
static Obj  GF_BIND__GLOBAL;
static GVar G_IGNORE__IMMEDIATE__METHODS;
static Obj  GC_IGNORE__IMMEDIATE__METHODS;
static GVar G_IMM__FLAGS;
static Obj  GC_IMM__FLAGS;
static GVar G_IMMEDIATES;
static Obj  GC_IMMEDIATES;
static GVar G_IMMEDIATE__METHODS;
static Obj  GC_IMMEDIATE__METHODS;
static GVar G_TRACE__IMMEDIATE__METHODS;
static Obj  GC_TRACE__IMMEDIATE__METHODS;
static GVar G_NewSpecialRegion;
static Obj  GF_NewSpecialRegion;
static GVar G_METHODS__OPERATION__REGION;
static Obj  GC_METHODS__OPERATION__REGION;
static GVar G_IS__CONSTRUCTOR;
static Obj  GF_IS__CONSTRUCTOR;
static GVar G_RankFilter;
static Obj  GF_RankFilter;
static GVar G_CHECK__INSTALL__METHOD;
static Obj  GC_CHECK__INSTALL__METHOD;
static GVar G_INSTALL__METHOD;
static Obj  GF_INSTALL__METHOD;
static GVar G_DeclareGlobalFunction;
static Obj  GF_DeclareGlobalFunction;
static GVar G_OPERATIONS__REGION;
static Obj  GC_OPERATIONS__REGION;
static GVar G_EvalString;
static Obj  GF_EvalString;
static GVar G_WRAPPER__OPERATIONS;
static Obj  GC_WRAPPER__OPERATIONS;
static GVar G_INFO__DEBUG;
static Obj  GF_INFO__DEBUG;
static GVar G_OPERATIONS;
static Obj  GC_OPERATIONS;
static GVar G_NamesFilter;
static Obj  GF_NamesFilter;
static GVar G_Ordinal;
static Obj  GF_Ordinal;
static GVar G_INSTALL__METHOD__FLAGS;
static Obj  GF_INSTALL__METHOD__FLAGS;
static GVar G_LENGTH__SETTER__METHODS__2;
static Obj  GC_LENGTH__SETTER__METHODS__2;
static GVar G_InstallAttributeFunction;
static Obj  GF_InstallAttributeFunction;
static GVar G_FILTER__REGION;
static Obj  GC_FILTER__REGION;
static GVar G_CATS__AND__REPS;
static Obj  GC_CATS__AND__REPS;
static GVar G_FILTERS;
static Obj  GC_FILTERS;
static GVar G_NUMBERS__PROPERTY__GETTERS;
static Obj  GC_NUMBERS__PROPERTY__GETTERS;
static GVar G_InstallOtherMethod;
static Obj  GF_InstallOtherMethod;
static GVar G_Tester;
static Obj  GF_Tester;
static GVar G_IsPrimeInt;
static Obj  GF_IsPrimeInt;
static GVar G_DeclareOperation;
static Obj  GF_DeclareOperation;
static GVar G_VALUE__GLOBAL;
static Obj  GF_VALUE__GLOBAL;
static GVar G_DeclareAttribute;
static Obj  GF_DeclareAttribute;
static GVar G_InstallMethod;
static Obj  GF_InstallMethod;
static GVar G_PositionSortedOddPositions;
static Obj  GF_PositionSortedOddPositions;
static GVar G_CallFuncList;
static Obj  GF_CallFuncList;

/* record names used in handlers */
static RNam R_MaxNrArgsMethod;

/* information for the functions */
static Obj  NameFunc[19];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_obj,
 Obj  a_flags )
{
 Obj l_flagspos = 0;
 Obj l_tried = 0;
 Obj l_type = 0;
 Obj l_j = 0;
 Obj l_imm = 0;
 Obj l_i = 0;
 Obj l_res = 0;
 Obj l_newflags = 0;
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
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if IGNORE_IMMEDIATE_METHODS then */
 t_2 = GC_IGNORE__IMMEDIATE__METHODS;
 CHECK_BOUND( t_2, "IGNORE_IMMEDIATE_METHODS" )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* return; */
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return 0;
  
 }
 /* fi */
 
 /* if IS_SUBSET_FLAGS( IMM_FLAGS, flags ) then */
 t_3 = GF_IS__SUBSET__FLAGS;
 t_4 = GC_IMM__FLAGS;
 CHECK_BOUND( t_4, "IMM_FLAGS" )
 t_2 = CALL_2ARGS( t_3, t_4, a_flags );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* return; */
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return 0;
  
 }
 /* fi */
 
 /* flags := SUB_FLAGS( flags, IMM_FLAGS ); */
 t_2 = GF_SUB__FLAGS;
 t_3 = GC_IMM__FLAGS;
 CHECK_BOUND( t_3, "IMM_FLAGS" )
 t_1 = CALL_2ARGS( t_2, a_flags, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 a_flags = t_1;
 
 /* flagspos := SHALLOW_COPY_OBJ( TRUES_FLAGS( flags ) ); */
 t_2 = GF_SHALLOW__COPY__OBJ;
 t_4 = GF_TRUES__FLAGS;
 t_3 = CALL_1ARGS( t_4, a_flags );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_flagspos = t_1;
 
 /* tried := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 l_tried = t_1;
 
 /* type := TYPE_OBJ( obj ); */
 t_2 = GF_TYPE__OBJ;
 t_1 = CALL_1ARGS( t_2, a_obj );
 CHECK_FUNC_RESULT( t_1 )
 l_type = t_1;
 
 /* flags := type![2]; */
 C_ELM_POSOBJ_NLE( t_1, l_type, 2 );
 a_flags = t_1;
 
 /* for j in flagspos do */
 t_4 = l_flagspos;
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
  l_j = t_2;
  
  /* if IsBound( IMMEDIATES[j] ) then */
  t_7 = GC_IMMEDIATES;
  CHECK_BOUND( t_7, "IMMEDIATES" )
  CHECK_INT_POS( l_j )
  t_6 = C_ISB_LIST( t_7, l_j );
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* imm := IMMEDIATES[j]; */
   t_6 = GC_IMMEDIATES;
   CHECK_BOUND( t_6, "IMMEDIATES" )
   C_ELM_LIST_FPL( t_5, t_6, l_j )
   l_imm = t_5;
   
   /* for i in [ 0, 7 .. LEN_LIST( imm ) - 7 ] do */
   t_11 = GF_LEN__LIST;
   t_10 = CALL_1ARGS( t_11, l_imm );
   CHECK_FUNC_RESULT( t_10 )
   C_DIFF_FIA( t_9, t_10, INTOBJ_INT(7) )
   t_8 = Range3Check( INTOBJ_INT(0), INTOBJ_INT(7), t_9 );
   if ( IS_SMALL_LIST(t_8) ) {
    t_7 = (Obj)(UInt)1;
    t_5 = INTOBJ_INT(1);
   }
   else {
    t_7 = (Obj)(UInt)0;
    t_5 = CALL_1ARGS( GF_ITERATOR, t_8 );
   }
   while ( 1 ) {
    if ( t_7 ) {
     if ( LEN_LIST(t_8) < INT_INTOBJ(t_5) )  break;
     t_6 = ELMV0_LIST( t_8, INT_INTOBJ(t_5) );
     t_5 = (Obj)(((UInt)t_5)+4);
     if ( t_6 == 0 )  continue;
    }
    else {
     if ( CALL_1ARGS( GF_IS_DONE_ITER, t_5 ) != False )  break;
     t_6 = CALL_1ARGS( GF_NEXT_ITER, t_5 );
    }
    l_i = t_6;
    
    /* if IS_SUBSET_FLAGS( flags, imm[i + 4] ) and not IS_SUBSET_FLAGS( flags, imm[i + 3] ) and not imm[i + 6] in tried then */
    t_13 = GF_IS__SUBSET__FLAGS;
    C_SUM_FIA( t_15, l_i, INTOBJ_INT(4) )
    CHECK_INT_POS( t_15 )
    C_ELM_LIST_FPL( t_14, l_imm, t_15 )
    t_12 = CALL_2ARGS( t_13, a_flags, t_14 );
    CHECK_FUNC_RESULT( t_12 )
    CHECK_BOOL( t_12 )
    t_11 = (Obj)(UInt)(t_12 != False);
    t_10 = t_11;
    if ( t_10 ) {
     t_15 = GF_IS__SUBSET__FLAGS;
     C_SUM_FIA( t_17, l_i, INTOBJ_INT(3) )
     CHECK_INT_POS( t_17 )
     C_ELM_LIST_FPL( t_16, l_imm, t_17 )
     t_14 = CALL_2ARGS( t_15, a_flags, t_16 );
     CHECK_FUNC_RESULT( t_14 )
     CHECK_BOOL( t_14 )
     t_13 = (Obj)(UInt)(t_14 != False);
     t_12 = (Obj)(UInt)( ! ((Int)t_13) );
     t_10 = t_12;
    }
    t_9 = t_10;
    if ( t_9 ) {
     C_SUM_FIA( t_14, l_i, INTOBJ_INT(6) )
     CHECK_INT_POS( t_14 )
     C_ELM_LIST_FPL( t_13, l_imm, t_14 )
     t_12 = (Obj)(UInt)(IN( t_13, l_tried ));
     t_11 = (Obj)(UInt)( ! ((Int)t_12) );
     t_9 = t_11;
    }
    if ( t_9 ) {
     
     /* res := IMMEDIATE_METHODS[imm[i + 6]]( obj ); */
     t_11 = GC_IMMEDIATE__METHODS;
     CHECK_BOUND( t_11, "IMMEDIATE_METHODS" )
     C_SUM_FIA( t_13, l_i, INTOBJ_INT(6) )
     CHECK_INT_POS( t_13 )
     C_ELM_LIST_FPL( t_12, l_imm, t_13 )
     CHECK_INT_POS( t_12 )
     C_ELM_LIST_FPL( t_10, t_11, t_12 )
     CHECK_FUNC( t_10 )
     t_9 = CALL_1ARGS( t_10, a_obj );
     CHECK_FUNC_RESULT( t_9 )
     l_res = t_9;
     
     /* ADD_LIST( tried, imm[i + 6] ); */
     t_9 = GF_ADD__LIST;
     C_SUM_FIA( t_11, l_i, INTOBJ_INT(6) )
     CHECK_INT_POS( t_11 )
     C_ELM_LIST_FPL( t_10, l_imm, t_11 )
     CALL_2ARGS( t_9, l_tried, t_10 );
     
     /* RUN_IMMEDIATE_METHODS_CHECKS := RUN_IMMEDIATE_METHODS_CHECKS + 1; */
     t_10 = GC_RUN__IMMEDIATE__METHODS__CHECKS;
     CHECK_BOUND( t_10, "RUN_IMMEDIATE_METHODS_CHECKS" )
     C_SUM_FIA( t_9, t_10, INTOBJ_INT(1) )
     AssGVar( G_RUN__IMMEDIATE__METHODS__CHECKS, t_9 );
     
     /* if TRACE_IMMEDIATE_METHODS then */
     t_10 = GC_TRACE__IMMEDIATE__METHODS;
     CHECK_BOUND( t_10, "TRACE_IMMEDIATE_METHODS" )
     CHECK_BOOL( t_10 )
     t_9 = (Obj)(UInt)(t_10 != False);
     if ( t_9 ) {
      
      /* if imm[i + 7] = false then */
      C_SUM_FIA( t_11, l_i, INTOBJ_INT(7) )
      CHECK_INT_POS( t_11 )
      C_ELM_LIST_FPL( t_10, l_imm, t_11 )
      t_11 = False;
      t_9 = (Obj)(UInt)(EQ( t_10, t_11 ));
      if ( t_9 ) {
       
       /* Print( "#I  immediate: ", NAME_FUNC( imm[i + 1] ), "\n" ); */
       t_9 = GF_Print;
       t_10 = MakeString( "#I  immediate: " );
       t_12 = GF_NAME__FUNC;
       C_SUM_FIA( t_14, l_i, INTOBJ_INT(1) )
       CHECK_INT_POS( t_14 )
       C_ELM_LIST_FPL( t_13, l_imm, t_14 )
       t_11 = CALL_1ARGS( t_12, t_13 );
       CHECK_FUNC_RESULT( t_11 )
       t_12 = MakeString( "\n" );
       CALL_3ARGS( t_9, t_10, t_11, t_12 );
       
      }
      
      /* else */
      else {
       
       /* Print( "#I  immediate: ", NAME_FUNC( imm[i + 1] ), ": ", imm[i + 7], "\n" ); */
       t_9 = GF_Print;
       t_10 = MakeString( "#I  immediate: " );
       t_12 = GF_NAME__FUNC;
       C_SUM_FIA( t_14, l_i, INTOBJ_INT(1) )
       CHECK_INT_POS( t_14 )
       C_ELM_LIST_FPL( t_13, l_imm, t_14 )
       t_11 = CALL_1ARGS( t_12, t_13 );
       CHECK_FUNC_RESULT( t_11 )
       t_12 = MakeString( ": " );
       C_SUM_FIA( t_14, l_i, INTOBJ_INT(7) )
       CHECK_INT_POS( t_14 )
       C_ELM_LIST_FPL( t_13, l_imm, t_14 )
       t_14 = MakeString( "\n" );
       CALL_5ARGS( t_9, t_10, t_11, t_12, t_13, t_14 );
       
      }
      /* fi */
      
     }
     /* fi */
     
     /* if res <> TRY_NEXT_METHOD then */
     t_10 = GC_TRY__NEXT__METHOD;
     CHECK_BOUND( t_10, "TRY_NEXT_METHOD" )
     t_9 = (Obj)(UInt)( ! EQ( l_res, t_10 ));
     if ( t_9 ) {
      
      /* IGNORE_IMMEDIATE_METHODS := true; */
      t_9 = True;
      AssGVar( G_IGNORE__IMMEDIATE__METHODS, t_9 );
      
      /* imm[i + 2]( obj, res ); */
      C_SUM_FIA( t_10, l_i, INTOBJ_INT(2) )
      CHECK_INT_POS( t_10 )
      C_ELM_LIST_FPL( t_9, l_imm, t_10 )
      CHECK_FUNC( t_9 )
      CALL_2ARGS( t_9, a_obj, l_res );
      
      /* IGNORE_IMMEDIATE_METHODS := false; */
      t_9 = False;
      AssGVar( G_IGNORE__IMMEDIATE__METHODS, t_9 );
      
      /* RUN_IMMEDIATE_METHODS_HITS := RUN_IMMEDIATE_METHODS_HITS + 1; */
      t_10 = GC_RUN__IMMEDIATE__METHODS__HITS;
      CHECK_BOUND( t_10, "RUN_IMMEDIATE_METHODS_HITS" )
      C_SUM_FIA( t_9, t_10, INTOBJ_INT(1) )
      AssGVar( G_RUN__IMMEDIATE__METHODS__HITS, t_9 );
      
      /* if not IS_IDENTICAL_OBJ( TYPE_OBJ( obj ), type ) then */
      t_12 = GF_IS__IDENTICAL__OBJ;
      t_14 = GF_TYPE__OBJ;
      t_13 = CALL_1ARGS( t_14, a_obj );
      CHECK_FUNC_RESULT( t_13 )
      t_11 = CALL_2ARGS( t_12, t_13, l_type );
      CHECK_FUNC_RESULT( t_11 )
      CHECK_BOOL( t_11 )
      t_10 = (Obj)(UInt)(t_11 != False);
      t_9 = (Obj)(UInt)( ! ((Int)t_10) );
      if ( t_9 ) {
       
       /* type := TYPE_OBJ( obj ); */
       t_10 = GF_TYPE__OBJ;
       t_9 = CALL_1ARGS( t_10, a_obj );
       CHECK_FUNC_RESULT( t_9 )
       l_type = t_9;
       
       /* newflags := SUB_FLAGS( type![2], IMM_FLAGS ); */
       t_10 = GF_SUB__FLAGS;
       C_ELM_POSOBJ_NLE( t_11, l_type, 2 );
       t_12 = GC_IMM__FLAGS;
       CHECK_BOUND( t_12, "IMM_FLAGS" )
       t_9 = CALL_2ARGS( t_10, t_11, t_12 );
       CHECK_FUNC_RESULT( t_9 )
       l_newflags = t_9;
       
       /* newflags := SUB_FLAGS( newflags, flags ); */
       t_10 = GF_SUB__FLAGS;
       t_9 = CALL_2ARGS( t_10, l_newflags, a_flags );
       CHECK_FUNC_RESULT( t_9 )
       l_newflags = t_9;
       
       /* APPEND_LIST_INTR( flagspos, TRUES_FLAGS( newflags ) ); */
       t_9 = GF_APPEND__LIST__INTR;
       t_11 = GF_TRUES__FLAGS;
       t_10 = CALL_1ARGS( t_11, l_newflags );
       CHECK_FUNC_RESULT( t_10 )
       CALL_2ARGS( t_9, l_flagspos, t_10 );
       
       /* flags := type![2]; */
       C_ELM_POSOBJ_NLE( t_9, l_type, 2 );
       a_flags = t_9;
       
      }
      /* fi */
      
     }
     /* fi */
     
    }
    /* fi */
    
   }
   /* od */
   
  }
  /* fi */
  
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

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self,
 Obj  a_opr,
 Obj  a_info,
 Obj  a_rel,
 Obj  a_flags,
 Obj  a_rank,
 Obj  a_method )
{
 Obj l_methods = 0;
 Obj l_narg = 0;
 Obj l_i = 0;
 Obj l_k = 0;
 Obj l_tmp = 0;
 Obj l_replace = 0;
 Obj l_match = 0;
 Obj l_j = 0;
 Obj l_lk = 0;
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
 
 /* lk := WRITE_LOCK( METHODS_OPERATION_REGION ); */
 t_2 = GF_WRITE__LOCK;
 t_3 = GC_METHODS__OPERATION__REGION;
 CHECK_BOUND( t_3, "METHODS_OPERATION_REGION" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_lk = t_1;
 
 /* if IS_CONSTRUCTOR( opr ) then */
 t_3 = GF_IS__CONSTRUCTOR;
 t_2 = CALL_1ARGS( t_3, a_opr );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* if 0 < LEN_LIST( flags ) then */
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_flags );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(LT( INTOBJ_INT(0), t_2 ));
  if ( t_1 ) {
   
   /* rank := rank - RankFilter( flags[1] ); */
   t_3 = GF_RankFilter;
   C_ELM_LIST_FPL( t_4, a_flags, INTOBJ_INT(1) )
   t_2 = CALL_1ARGS( t_3, t_4 );
   CHECK_FUNC_RESULT( t_2 )
   C_DIFF_FIA( t_1, a_rank, t_2 )
   a_rank = t_1;
   
  }
  /* fi */
  
 }
 
 /* else */
 else {
  
  /* for i in flags do */
  t_4 = a_flags;
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
   
   /* rank := rank + RankFilter( i ); */
   t_7 = GF_RankFilter;
   t_6 = CALL_1ARGS( t_7, l_i );
   CHECK_FUNC_RESULT( t_6 )
   C_SUM_FIA( t_5, a_rank, t_6 )
   a_rank = t_5;
   
  }
  /* od */
  
 }
 /* fi */
 
 /* narg := LEN_LIST( flags ); */
 t_2 = GF_LEN__LIST;
 t_1 = CALL_1ARGS( t_2, a_flags );
 CHECK_FUNC_RESULT( t_1 )
 l_narg = t_1;
 
 /* methods := METHODS_OPERATION( opr, narg ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_opr, l_narg );
 CHECK_FUNC_RESULT( t_1 )
 l_methods = t_1;
 
 /* methods := methods{[ 1 .. LEN_LIST( methods ) ]}; */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = Range2Check( INTOBJ_INT(1), t_3 );
 t_1 = ElmsListCheck( l_methods, t_2 );
 l_methods = t_1;
 
 /* if info = false then */
 t_2 = False;
 t_1 = (Obj)(UInt)(EQ( a_info, t_2 ));
 if ( t_1 ) {
  
  /* info := NAME_FUNC( opr ); */
  t_2 = GF_NAME__FUNC;
  t_1 = CALL_1ARGS( t_2, a_opr );
  CHECK_FUNC_RESULT( t_1 )
  a_info = t_1;
  
 }
 
 /* else */
 else {
  
  /* k := SHALLOW_COPY_OBJ( NAME_FUNC( opr ) ); */
  t_2 = GF_SHALLOW__COPY__OBJ;
  t_4 = GF_NAME__FUNC;
  t_3 = CALL_1ARGS( t_4, a_opr );
  CHECK_FUNC_RESULT( t_3 )
  t_1 = CALL_1ARGS( t_2, t_3 );
  CHECK_FUNC_RESULT( t_1 )
  l_k = t_1;
  
  /* APPEND_LIST_INTR( k, ": " ); */
  t_1 = GF_APPEND__LIST__INTR;
  t_2 = MakeString( ": " );
  CALL_2ARGS( t_1, l_k, t_2 );
  
  /* APPEND_LIST_INTR( k, info ); */
  t_1 = GF_APPEND__LIST__INTR;
  CALL_2ARGS( t_1, l_k, a_info );
  
  /* info := k; */
  a_info = l_k;
  
  /* CONV_STRING( info ); */
  t_1 = GF_CONV__STRING;
  CALL_1ARGS( t_1, a_info );
  
 }
 /* fi */
 
 /* i := 0; */
 l_i = INTOBJ_INT(0);
 
 /* while i < LEN_LIST( methods ) and rank < methods[i + (narg + 3)] od */
 while ( 1 ) {
  t_4 = GF_LEN__LIST;
  t_3 = CALL_1ARGS( t_4, l_methods );
  CHECK_FUNC_RESULT( t_3 )
  t_2 = (Obj)(UInt)(LT( l_i, t_3 ));
  t_1 = t_2;
  if ( t_1 ) {
   C_SUM_FIA( t_6, l_narg, INTOBJ_INT(3) )
   C_SUM_FIA( t_5, l_i, t_6 )
   CHECK_INT_POS( t_5 )
   C_ELM_LIST_FPL( t_4, l_methods, t_5 )
   t_3 = (Obj)(UInt)(LT( a_rank, t_4 ));
   t_1 = t_3;
  }
  if ( ! t_1 ) break;
  
  /* i := i + (narg + 4); */
  C_SUM_FIA( t_2, l_narg, INTOBJ_INT(4) )
  C_SUM_FIA( t_1, l_i, t_2 )
  l_i = t_1;
  
 }
 /* od */
 
 /* replace := false; */
 t_1 = False;
 l_replace = t_1;
 
 /* if REREADING then */
 t_2 = GC_REREADING;
 CHECK_BOUND( t_2, "REREADING" )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* k := i; */
  l_k = l_i;
  
  /* while k < LEN_LIST( methods ) and rank = methods[k + narg + 3] od */
  while ( 1 ) {
   t_4 = GF_LEN__LIST;
   t_3 = CALL_1ARGS( t_4, l_methods );
   CHECK_FUNC_RESULT( t_3 )
   t_2 = (Obj)(UInt)(LT( l_k, t_3 ));
   t_1 = t_2;
   if ( t_1 ) {
    C_SUM_FIA( t_6, l_k, l_narg )
    C_SUM_FIA( t_5, t_6, INTOBJ_INT(3) )
    CHECK_INT_POS( t_5 )
    C_ELM_LIST_FPL( t_4, l_methods, t_5 )
    t_3 = (Obj)(UInt)(EQ( a_rank, t_4 ));
    t_1 = t_3;
   }
   if ( ! t_1 ) break;
   
   /* if info = methods[k + narg + 4] then */
   C_SUM_FIA( t_4, l_k, l_narg )
   C_SUM_FIA( t_3, t_4, INTOBJ_INT(4) )
   CHECK_INT_POS( t_3 )
   C_ELM_LIST_FPL( t_2, l_methods, t_3 )
   t_1 = (Obj)(UInt)(EQ( a_info, t_2 ));
   if ( t_1 ) {
    
    /* match := false; */
    t_1 = False;
    l_match = t_1;
    
    /* for j in [ 1 .. narg ] do */
    CHECK_INT_SMALL( l_narg )
    t_2 = l_narg;
    for ( t_1 = INTOBJ_INT(1);
          ((Int)t_1) <= ((Int)t_2);
          t_1 = (Obj)(((UInt)t_1)+4) ) {
     l_j = t_1;
     
     /* match := match and methods[k + j + 1] = flags[j]; */
     if ( l_match == False ) {
      t_3 = l_match;
     }
     else if ( l_match == True ) {
      C_SUM_FIA( t_7, l_k, l_j )
      C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
      CHECK_INT_POS( t_6 )
      C_ELM_LIST_FPL( t_5, l_methods, t_6 )
      C_ELM_LIST_FPL( t_6, a_flags, l_j )
      t_4 = (EQ( t_5, t_6 ) ? True : False);
      t_3 = t_4;
     }
     else {
      CHECK_FUNC( l_match )
      C_SUM_FIA( t_8, l_k, l_j )
      C_SUM_FIA( t_7, t_8, INTOBJ_INT(1) )
      CHECK_INT_POS( t_7 )
      C_ELM_LIST_FPL( t_6, l_methods, t_7 )
      C_ELM_LIST_FPL( t_7, a_flags, l_j )
      t_5 = (EQ( t_6, t_7 ) ? True : False);
      CHECK_FUNC( t_5 )
      t_3 = NewAndFilter( l_match, t_5 );
     }
     l_match = t_3;
     
    }
    /* od */
    
    /* if match then */
    CHECK_BOOL( l_match )
    t_1 = (Obj)(UInt)(l_match != False);
    if ( t_1 ) {
     
     /* replace := true; */
     t_1 = True;
     l_replace = t_1;
     
     /* i := k; */
     l_i = l_k;
     
     /* break; */
     break;
     
    }
    /* fi */
    
   }
   /* fi */
   
   /* k := k + narg + 4; */
   C_SUM_FIA( t_2, l_k, l_narg )
   C_SUM_FIA( t_1, t_2, INTOBJ_INT(4) )
   l_k = t_1;
   
  }
  /* od */
  
 }
 /* fi */
 
 /* if not REREADING or not replace then */
 t_4 = GC_REREADING;
 CHECK_BOUND( t_4, "REREADING" )
 CHECK_BOOL( t_4 )
 t_3 = (Obj)(UInt)(t_4 != False);
 t_2 = (Obj)(UInt)( ! ((Int)t_3) );
 t_1 = t_2;
 if ( ! t_1 ) {
  t_4 = (Obj)(UInt)(l_replace != False);
  t_3 = (Obj)(UInt)( ! ((Int)t_4) );
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* methods{[ narg + 4 + i + 1 .. narg + 4 + LEN_LIST( methods ) ]} := methods{[ i + 1 .. LEN_LIST( methods ) ]}; */
  C_SUM_FIA( t_4, l_narg, INTOBJ_INT(4) )
  C_SUM_FIA( t_3, t_4, l_i )
  C_SUM_FIA( t_2, t_3, INTOBJ_INT(1) )
  C_SUM_FIA( t_4, l_narg, INTOBJ_INT(4) )
  t_6 = GF_LEN__LIST;
  t_5 = CALL_1ARGS( t_6, l_methods );
  CHECK_FUNC_RESULT( t_5 )
  C_SUM_FIA( t_3, t_4, t_5 )
  t_1 = Range2Check( t_2, t_3 );
  C_SUM_FIA( t_4, l_i, INTOBJ_INT(1) )
  t_6 = GF_LEN__LIST;
  t_5 = CALL_1ARGS( t_6, l_methods );
  CHECK_FUNC_RESULT( t_5 )
  t_3 = Range2Check( t_4, t_5 );
  t_2 = ElmsListCheck( l_methods, t_3 );
  AsssListCheck( l_methods, t_1, t_2 );
  
 }
 /* fi */
 
 /* if rel = true then */
 t_2 = True;
 t_1 = (Obj)(UInt)(EQ( a_rel, t_2 ));
 if ( t_1 ) {
  
  /* methods[i + 1] := RETURN_TRUE; */
  C_SUM_FIA( t_1, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_1 )
  t_2 = GC_RETURN__TRUE;
  CHECK_BOUND( t_2, "RETURN_TRUE" )
  C_ASS_LIST_FPL( l_methods, t_1, t_2 )
  
 }
 
 /* elif rel = false then */
 else {
  t_2 = False;
  t_1 = (Obj)(UInt)(EQ( a_rel, t_2 ));
  if ( t_1 ) {
   
   /* methods[i + 1] := RETURN_FALSE; */
   C_SUM_FIA( t_1, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_1 )
   t_2 = GC_RETURN__FALSE;
   CHECK_BOUND( t_2, "RETURN_FALSE" )
   C_ASS_LIST_FPL( l_methods, t_1, t_2 )
   
  }
  
  /* elif IS_FUNCTION( rel ) then */
  else {
   t_3 = GF_IS__FUNCTION;
   t_2 = CALL_1ARGS( t_3, a_rel );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* if CHECK_INSTALL_METHOD then */
    t_2 = GC_CHECK__INSTALL__METHOD;
    CHECK_BOUND( t_2, "CHECK_INSTALL_METHOD" )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* tmp := NARG_FUNC( rel ); */
     t_2 = GF_NARG__FUNC;
     t_1 = CALL_1ARGS( t_2, a_rel );
     CHECK_FUNC_RESULT( t_1 )
     l_tmp = t_1;
     
     /* if tmp < AINV( narg ) - 1 or tmp >= 0 and tmp <> narg then */
     t_5 = GF_AINV;
     t_4 = CALL_1ARGS( t_5, l_narg );
     CHECK_FUNC_RESULT( t_4 )
     C_DIFF_FIA( t_3, t_4, INTOBJ_INT(1) )
     t_2 = (Obj)(UInt)(LT( l_tmp, t_3 ));
     t_1 = t_2;
     if ( ! t_1 ) {
      t_4 = (Obj)(UInt)(! LT( l_tmp, INTOBJ_INT(0) ));
      t_3 = t_4;
      if ( t_3 ) {
       t_5 = (Obj)(UInt)( ! EQ( l_tmp, l_narg ));
       t_3 = t_5;
      }
      t_1 = t_3;
     }
     if ( t_1 ) {
      
      /* Error( NAME_FUNC( opr ), ": <famrel> must accept ", narg, " arguments" ); */
      t_1 = GF_Error;
      t_3 = GF_NAME__FUNC;
      t_2 = CALL_1ARGS( t_3, a_opr );
      CHECK_FUNC_RESULT( t_2 )
      t_3 = MakeString( ": <famrel> must accept " );
      t_4 = MakeString( " arguments" );
      CALL_4ARGS( t_1, t_2, t_3, l_narg, t_4 );
      
     }
     /* fi */
     
    }
    /* fi */
    
    /* methods[i + 1] := rel; */
    C_SUM_FIA( t_1, l_i, INTOBJ_INT(1) )
    CHECK_INT_POS( t_1 )
    C_ASS_LIST_FPL( l_methods, t_1, a_rel )
    
   }
   
   /* else */
   else {
    
    /* Error( NAME_FUNC( opr ), ": <famrel> must be a function, `true', or `false'" ); */
    t_1 = GF_Error;
    t_3 = GF_NAME__FUNC;
    t_2 = CALL_1ARGS( t_3, a_opr );
    CHECK_FUNC_RESULT( t_2 )
    t_3 = MakeString( ": <famrel> must be a function, `true', or `false'" );
    CALL_2ARGS( t_1, t_2, t_3 );
    
   }
  }
 }
 /* fi */
 
 /* for k in [ 1 .. narg ] do */
 CHECK_INT_SMALL( l_narg )
 t_2 = l_narg;
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_k = t_1;
  
  /* methods[i + k + 1] := flags[k]; */
  C_SUM_FIA( t_4, l_i, l_k )
  C_SUM_FIA( t_3, t_4, INTOBJ_INT(1) )
  CHECK_INT_POS( t_3 )
  C_ELM_LIST_FPL( t_4, a_flags, l_k )
  C_ASS_LIST_FPL( l_methods, t_3, t_4 )
  
 }
 /* od */
 
 /* if method = true then */
 t_2 = True;
 t_1 = (Obj)(UInt)(EQ( a_method, t_2 ));
 if ( t_1 ) {
  
  /* methods[i + (narg + 2)] := RETURN_TRUE; */
  C_SUM_INTOBJS( t_2, l_narg, INTOBJ_INT(2) )
  C_SUM_FIA( t_1, l_i, t_2 )
  CHECK_INT_POS( t_1 )
  t_2 = GC_RETURN__TRUE;
  CHECK_BOUND( t_2, "RETURN_TRUE" )
  C_ASS_LIST_FPL( l_methods, t_1, t_2 )
  
 }
 
 /* elif method = false then */
 else {
  t_2 = False;
  t_1 = (Obj)(UInt)(EQ( a_method, t_2 ));
  if ( t_1 ) {
   
   /* methods[i + (narg + 2)] := RETURN_FALSE; */
   C_SUM_INTOBJS( t_2, l_narg, INTOBJ_INT(2) )
   C_SUM_FIA( t_1, l_i, t_2 )
   CHECK_INT_POS( t_1 )
   t_2 = GC_RETURN__FALSE;
   CHECK_BOUND( t_2, "RETURN_FALSE" )
   C_ASS_LIST_FPL( l_methods, t_1, t_2 )
   
  }
  
  /* elif IS_FUNCTION( method ) then */
  else {
   t_3 = GF_IS__FUNCTION;
   t_2 = CALL_1ARGS( t_3, a_method );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* if CHECK_INSTALL_METHOD and not IS_OPERATION( method ) then */
    t_3 = GC_CHECK__INSTALL__METHOD;
    CHECK_BOUND( t_3, "CHECK_INSTALL_METHOD" )
    CHECK_BOOL( t_3 )
    t_2 = (Obj)(UInt)(t_3 != False);
    t_1 = t_2;
    if ( t_1 ) {
     t_6 = GF_IS__OPERATION;
     t_5 = CALL_1ARGS( t_6, a_method );
     CHECK_FUNC_RESULT( t_5 )
     CHECK_BOOL( t_5 )
     t_4 = (Obj)(UInt)(t_5 != False);
     t_3 = (Obj)(UInt)( ! ((Int)t_4) );
     t_1 = t_3;
    }
    if ( t_1 ) {
     
     /* tmp := NARG_FUNC( method ); */
     t_2 = GF_NARG__FUNC;
     t_1 = CALL_1ARGS( t_2, a_method );
     CHECK_FUNC_RESULT( t_1 )
     l_tmp = t_1;
     
     /* if tmp < AINV( narg ) - 1 or tmp >= 0 and tmp <> narg then */
     t_5 = GF_AINV;
     t_4 = CALL_1ARGS( t_5, l_narg );
     CHECK_FUNC_RESULT( t_4 )
     C_DIFF_FIA( t_3, t_4, INTOBJ_INT(1) )
     t_2 = (Obj)(UInt)(LT( l_tmp, t_3 ));
     t_1 = t_2;
     if ( ! t_1 ) {
      t_4 = (Obj)(UInt)(! LT( l_tmp, INTOBJ_INT(0) ));
      t_3 = t_4;
      if ( t_3 ) {
       t_5 = (Obj)(UInt)( ! EQ( l_tmp, l_narg ));
       t_3 = t_5;
      }
      t_1 = t_3;
     }
     if ( t_1 ) {
      
      /* Error( NAME_FUNC( opr ), ": <method> must accept ", narg, " arguments" ); */
      t_1 = GF_Error;
      t_3 = GF_NAME__FUNC;
      t_2 = CALL_1ARGS( t_3, a_opr );
      CHECK_FUNC_RESULT( t_2 )
      t_3 = MakeString( ": <method> must accept " );
      t_4 = MakeString( " arguments" );
      CALL_4ARGS( t_1, t_2, t_3, l_narg, t_4 );
      
     }
     /* fi */
     
    }
    /* fi */
    
    /* methods[i + (narg + 2)] := method; */
    C_SUM_INTOBJS( t_2, l_narg, INTOBJ_INT(2) )
    C_SUM_FIA( t_1, l_i, t_2 )
    CHECK_INT_POS( t_1 )
    C_ASS_LIST_FPL( l_methods, t_1, a_method )
    
   }
   
   /* else */
   else {
    
    /* Error( NAME_FUNC( opr ), ": <method> must be a function, `true', or `false'" ); */
    t_1 = GF_Error;
    t_3 = GF_NAME__FUNC;
    t_2 = CALL_1ARGS( t_3, a_opr );
    CHECK_FUNC_RESULT( t_2 )
    t_3 = MakeString( ": <method> must be a function, `true', or `false'" );
    CALL_2ARGS( t_1, t_2, t_3 );
    
   }
  }
 }
 /* fi */
 
 /* methods[i + (narg + 3)] := rank; */
 C_SUM_INTOBJS( t_2, l_narg, INTOBJ_INT(3) )
 C_SUM_FIA( t_1, l_i, t_2 )
 CHECK_INT_POS( t_1 )
 C_ASS_LIST_FPL( l_methods, t_1, a_rank )
 
 /* methods[i + (narg + 4)] := IMMUTABLE_COPY_OBJ( info ); */
 C_SUM_INTOBJS( t_2, l_narg, INTOBJ_INT(4) )
 C_SUM_FIA( t_1, l_i, t_2 )
 CHECK_INT_POS( t_1 )
 t_3 = GF_IMMUTABLE__COPY__OBJ;
 t_2 = CALL_1ARGS( t_3, a_info );
 CHECK_FUNC_RESULT( t_2 )
 C_ASS_LIST_FPL( l_methods, t_1, t_2 )
 
 /* SET_METHODS_OPERATION( opr, narg, MakeReadOnlyObj( methods ) ); */
 t_1 = GF_SET__METHODS__OPERATION;
 t_3 = GF_MakeReadOnlyObj;
 t_2 = CALL_1ARGS( t_3, l_methods );
 CHECK_FUNC_RESULT( t_2 )
 CALL_3ARGS( t_1, a_opr, l_narg, t_2 );
 
 /* UNLOCK( lk ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_lk );
 
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
 
 /* INSTALL_METHOD( arg, true ); */
 t_1 = GF_INSTALL__METHOD;
 t_2 = True;
 CALL_2ARGS( t_1, a_arg, t_2 );
 
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
 
 /* INSTALL_METHOD( arg, false ); */
 t_1 = GF_INSTALL__METHOD;
 t_2 = False;
 CALL_2ARGS( t_1, a_arg, t_2 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
 Obj  self,
 Obj  a_arglist,
 Obj  a_check )
{
 Obj l_len = 0;
 Obj l_opr = 0;
 Obj l_info = 0;
 Obj l_pos = 0;
 Obj l_rel = 0;
 Obj l_filters = 0;
 Obj l_info1 = 0;
 Obj l_isstr = 0;
 Obj l_flags = 0;
 Obj l_i = 0;
 Obj l_rank = 0;
 Obj l_method = 0;
 Obj l_oreqs = 0;
 Obj l_req = 0;
 Obj l_reqs = 0;
 Obj l_match = 0;
 Obj l_j = 0;
 Obj l_k = 0;
 Obj l_imp = 0;
 Obj l_notmatch = 0;
 Obj l_lk = 0;
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
 
 /* lk := READ_LOCK( OPERATIONS_REGION ); */
 t_2 = GF_READ__LOCK;
 t_3 = GC_OPERATIONS__REGION;
 CHECK_BOUND( t_3, "OPERATIONS_REGION" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_lk = t_1;
 
 /* len := LEN_LIST( arglist ); */
 t_2 = GF_LEN__LIST;
 t_1 = CALL_1ARGS( t_2, a_arglist );
 CHECK_FUNC_RESULT( t_1 )
 l_len = t_1;
 
 /* if len < 3 then */
 t_1 = (Obj)(UInt)(LT( l_len, INTOBJ_INT(3) ));
 if ( t_1 ) {
  
  /* Error( "too few arguments given in <arglist>" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "too few arguments given in <arglist>" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* opr := arglist[1]; */
 C_ELM_LIST_FPL( t_1, a_arglist, INTOBJ_INT(1) )
 l_opr = t_1;
 
 /* if not IS_OPERATION( opr ) then */
 t_4 = GF_IS__OPERATION;
 t_3 = CALL_1ARGS( t_4, l_opr );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<opr> is not an operation" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "<opr> is not an operation" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if IS_STRING_REP( arglist[2] ) then */
 t_3 = GF_IS__STRING__REP;
 C_ELM_LIST_FPL( t_4, a_arglist, INTOBJ_INT(2) )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* info := arglist[2]; */
  C_ELM_LIST_FPL( t_1, a_arglist, INTOBJ_INT(2) )
  l_info = t_1;
  
  /* pos := 3; */
  l_pos = INTOBJ_INT(3);
  
 }
 
 /* else */
 else {
  
  /* info := false; */
  t_1 = False;
  l_info = t_1;
  
  /* pos := 2; */
  l_pos = INTOBJ_INT(2);
  
 }
 /* fi */
 
 /* if arglist[pos] = true or IS_FUNCTION( arglist[pos] ) then */
 C_ELM_LIST_FPL( t_3, a_arglist, l_pos )
 t_4 = True;
 t_2 = (Obj)(UInt)(EQ( t_3, t_4 ));
 t_1 = t_2;
 if ( ! t_1 ) {
  t_5 = GF_IS__FUNCTION;
  C_ELM_LIST_FPL( t_6, a_arglist, l_pos )
  t_4 = CALL_1ARGS( t_5, t_6 );
  CHECK_FUNC_RESULT( t_4 )
  CHECK_BOOL( t_4 )
  t_3 = (Obj)(UInt)(t_4 != False);
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* rel := arglist[pos]; */
  C_ELM_LIST_FPL( t_1, a_arglist, l_pos )
  l_rel = t_1;
  
  /* pos := pos + 1; */
  C_SUM_INTOBJS( t_1, l_pos, INTOBJ_INT(1) )
  l_pos = t_1;
  
 }
 
 /* else */
 else {
  
  /* rel := true; */
  t_1 = True;
  l_rel = t_1;
  
 }
 /* fi */
 
 /* if not IsBound( arglist[pos] ) or not IS_LIST( arglist[pos] ) then */
 CHECK_INT_POS( l_pos )
 t_4 = C_ISB_LIST( a_arglist, l_pos );
 t_3 = (Obj)(UInt)(t_4 != False);
 t_2 = (Obj)(UInt)( ! ((Int)t_3) );
 t_1 = t_2;
 if ( ! t_1 ) {
  t_6 = GF_IS__LIST;
  C_ELM_LIST_FPL( t_7, a_arglist, l_pos )
  t_5 = CALL_1ARGS( t_6, t_7 );
  CHECK_FUNC_RESULT( t_5 )
  CHECK_BOOL( t_5 )
  t_4 = (Obj)(UInt)(t_5 != False);
  t_3 = (Obj)(UInt)( ! ((Int)t_4) );
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* Error( "<arglist>[", pos, "] must be a list of filters" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "<arglist>[" );
  t_3 = MakeString( "] must be a list of filters" );
  CALL_3ARGS( t_1, t_2, l_pos, t_3 );
  
 }
 /* fi */
 
 /* filters := arglist[pos]; */
 C_ELM_LIST_FPL( t_1, a_arglist, l_pos )
 l_filters = t_1;
 
 /* if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then */
 t_3 = GC_GAPInfo;
 CHECK_BOUND( t_3, "GAPInfo" )
 t_2 = ELM_REC( t_3, R_MaxNrArgsMethod );
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_filters );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = (Obj)(UInt)(LT( t_2, t_3 ));
 if ( t_1 ) {
  
  /* Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod, " arguments" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "methods can have at most " );
  t_4 = GC_GAPInfo;
  CHECK_BOUND( t_4, "GAPInfo" )
  t_3 = ELM_REC( t_4, R_MaxNrArgsMethod );
  t_4 = MakeString( " arguments" );
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
  
 }
 /* fi */
 
 /* if 0 < LEN_LIST( filters ) then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, l_filters );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(LT( INTOBJ_INT(0), t_2 ));
 if ( t_1 ) {
  
  /* info1 := "[ "; */
  t_1 = MakeString( "[ " );
  l_info1 = t_1;
  
  /* isstr := true; */
  t_1 = True;
  l_isstr = t_1;
  
  /* for i in [ 1 .. LEN_LIST( filters ) ] do */
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, l_filters );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_INT_SMALL( t_2 )
  for ( t_1 = INTOBJ_INT(1);
        ((Int)t_1) <= ((Int)t_2);
        t_1 = (Obj)(((UInt)t_1)+4) ) {
   l_i = t_1;
   
   /* if IS_STRING_REP( filters[i] ) then */
   t_5 = GF_IS__STRING__REP;
   C_ELM_LIST_FPL( t_6, l_filters, l_i )
   t_4 = CALL_1ARGS( t_5, t_6 );
   CHECK_FUNC_RESULT( t_4 )
   CHECK_BOOL( t_4 )
   t_3 = (Obj)(UInt)(t_4 != False);
   if ( t_3 ) {
    
    /* APPEND_LIST_INTR( info1, filters[i] ); */
    t_3 = GF_APPEND__LIST__INTR;
    C_ELM_LIST_FPL( t_4, l_filters, l_i )
    CALL_2ARGS( t_3, l_info1, t_4 );
    
    /* APPEND_LIST_INTR( info1, ", " ); */
    t_3 = GF_APPEND__LIST__INTR;
    t_4 = MakeString( ", " );
    CALL_2ARGS( t_3, l_info1, t_4 );
    
    /* filters[i] := EvalString( filters[i] ); */
    t_4 = GF_EvalString;
    C_ELM_LIST_FPL( t_5, l_filters, l_i )
    t_3 = CALL_1ARGS( t_4, t_5 );
    CHECK_FUNC_RESULT( t_3 )
    C_ASS_LIST_FPL( l_filters, l_i, t_3 )
    
    /* if not IS_FUNCTION( filters[i] ) then */
    t_6 = GF_IS__FUNCTION;
    C_ELM_LIST_FPL( t_7, l_filters, l_i )
    t_5 = CALL_1ARGS( t_6, t_7 );
    CHECK_FUNC_RESULT( t_5 )
    CHECK_BOOL( t_5 )
    t_4 = (Obj)(UInt)(t_5 != False);
    t_3 = (Obj)(UInt)( ! ((Int)t_4) );
    if ( t_3 ) {
     
     /* Error( "string does not evaluate to a function" ); */
     t_3 = GF_Error;
     t_4 = MakeString( "string does not evaluate to a function" );
     CALL_1ARGS( t_3, t_4 );
     
    }
    /* fi */
    
   }
   
   /* else */
   else {
    
    /* isstr := false; */
    t_3 = False;
    l_isstr = t_3;
    
    /* break; */
    break;
    
   }
   /* fi */
   
  }
  /* od */
  
  /* if isstr and info = false then */
  t_2 = (Obj)(UInt)(l_isstr != False);
  t_1 = t_2;
  if ( t_1 ) {
   t_4 = False;
   t_3 = (Obj)(UInt)(EQ( l_info, t_4 ));
   t_1 = t_3;
  }
  if ( t_1 ) {
   
   /* info1[LEN_LIST( info1 ) - 1] := ' '; */
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, l_info1 );
   CHECK_FUNC_RESULT( t_2 )
   C_DIFF_FIA( t_1, t_2, INTOBJ_INT(1) )
   CHECK_INT_POS( t_1 )
   t_2 = ObjsChar[32];
   C_ASS_LIST_FPL( l_info1, t_1, t_2 )
   
   /* info1[LEN_LIST( info1 )] := ']'; */
   t_2 = GF_LEN__LIST;
   t_1 = CALL_1ARGS( t_2, l_info1 );
   CHECK_FUNC_RESULT( t_1 )
   CHECK_INT_POS( t_1 )
   t_2 = ObjsChar[93];
   C_ASS_LIST_FPL( l_info1, t_1, t_2 )
   
   /* info := info1; */
   l_info = l_info1;
   
  }
  /* fi */
  
 }
 /* fi */
 
 /* pos := pos + 1; */
 C_SUM_FIA( t_1, l_pos, INTOBJ_INT(1) )
 l_pos = t_1;
 
 /* flags := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 l_flags = t_1;
 
 /* for i in filters do */
 t_4 = l_filters;
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
  
  /* ADD_LIST( flags, FLAGS_FILTER( i ) ); */
  t_5 = GF_ADD__LIST;
  t_7 = GF_FLAGS__FILTER;
  t_6 = CALL_1ARGS( t_7, l_i );
  CHECK_FUNC_RESULT( t_6 )
  CALL_2ARGS( t_5, l_flags, t_6 );
  
 }
 /* od */
 
 /* if not IsBound( arglist[pos] ) then */
 CHECK_INT_POS( l_pos )
 t_3 = C_ISB_LIST( a_arglist, l_pos );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "the method is missing in <arglist>" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "the method is missing in <arglist>" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 
 /* elif IS_INT( arglist[pos] ) then */
 else {
  t_3 = GF_IS__INT;
  C_ELM_LIST_FPL( t_4, a_arglist, l_pos )
  t_2 = CALL_1ARGS( t_3, t_4 );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* rank := arglist[pos]; */
   C_ELM_LIST_FPL( t_1, a_arglist, l_pos )
   l_rank = t_1;
   
   /* pos := pos + 1; */
   C_SUM_FIA( t_1, l_pos, INTOBJ_INT(1) )
   l_pos = t_1;
   
  }
  
  /* else */
  else {
   
   /* rank := 0; */
   l_rank = INTOBJ_INT(0);
   
  }
 }
 /* fi */
 
 /* if not IsBound( arglist[pos] ) then */
 CHECK_INT_POS( l_pos )
 t_3 = C_ISB_LIST( a_arglist, l_pos );
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "the method is missing in <arglist>" ); */
  t_1 = GF_Error;
  t_2 = MakeString( "the method is missing in <arglist>" );
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* method := arglist[pos]; */
 C_ELM_LIST_FPL( t_1, a_arglist, l_pos )
 l_method = t_1;
 
 /* if FLAG1_FILTER( opr ) <> 0 and (rel = true or rel = RETURN_TRUE) and LEN_LIST( filters ) = 1 and (method = true or method = RETURN_TRUE) then */
 t_6 = GF_FLAG1__FILTER;
 t_5 = CALL_1ARGS( t_6, l_opr );
 CHECK_FUNC_RESULT( t_5 )
 t_4 = (Obj)(UInt)( ! EQ( t_5, INTOBJ_INT(0) ));
 t_3 = t_4;
 if ( t_3 ) {
  t_7 = True;
  t_6 = (Obj)(UInt)(EQ( l_rel, t_7 ));
  t_5 = t_6;
  if ( ! t_5 ) {
   t_8 = GC_RETURN__TRUE;
   CHECK_BOUND( t_8, "RETURN_TRUE" )
   t_7 = (Obj)(UInt)(EQ( l_rel, t_8 ));
   t_5 = t_7;
  }
  t_3 = t_5;
 }
 t_2 = t_3;
 if ( t_2 ) {
  t_6 = GF_LEN__LIST;
  t_5 = CALL_1ARGS( t_6, l_filters );
  CHECK_FUNC_RESULT( t_5 )
  t_4 = (Obj)(UInt)(EQ( t_5, INTOBJ_INT(1) ));
  t_2 = t_4;
 }
 t_1 = t_2;
 if ( t_1 ) {
  t_5 = True;
  t_4 = (Obj)(UInt)(EQ( l_method, t_5 ));
  t_3 = t_4;
  if ( ! t_3 ) {
   t_6 = GC_RETURN__TRUE;
   CHECK_BOUND( t_6, "RETURN_TRUE" )
   t_5 = (Obj)(UInt)(EQ( l_method, t_6 ));
   t_3 = t_5;
  }
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* Error( NAME_FUNC( opr ), ": use `InstallTrueMethod' for <opr>" ); */
  t_1 = GF_Error;
  t_3 = GF_NAME__FUNC;
  t_2 = CALL_1ARGS( t_3, l_opr );
  CHECK_FUNC_RESULT( t_2 )
  t_3 = MakeString( ": use `InstallTrueMethod' for <opr>" );
  CALL_2ARGS( t_1, t_2, t_3 );
  
 }
 /* fi */
 
 /* if CHECK_INSTALL_METHOD and check then */
 t_3 = GC_CHECK__INSTALL__METHOD;
 CHECK_BOUND( t_3, "CHECK_INSTALL_METHOD" )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = t_2;
 if ( t_1 ) {
  CHECK_BOOL( a_check )
  t_3 = (Obj)(UInt)(a_check != False);
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* if opr in WRAPPER_OPERATIONS then */
  t_2 = GC_WRAPPER__OPERATIONS;
  CHECK_BOUND( t_2, "WRAPPER_OPERATIONS" )
  t_1 = (Obj)(UInt)(IN( l_opr, t_2 ));
  if ( t_1 ) {
   
   /* INFO_DEBUG( 1, "a method is installed for the wrapper operation ", NAME_FUNC( opr ), "\n", "#I  probably it should be installed for (one of) its\n", "#I  underlying operation(s)" ); */
   t_1 = GF_INFO__DEBUG;
   t_2 = MakeString( "a method is installed for the wrapper operation " );
   t_4 = GF_NAME__FUNC;
   t_3 = CALL_1ARGS( t_4, l_opr );
   CHECK_FUNC_RESULT( t_3 )
   t_4 = MakeString( "\n" );
   t_5 = MakeString( "#I  probably it should be installed for (one of) its\n" );
   t_6 = MakeString( "#I  underlying operation(s)" );
   CALL_6ARGS( t_1, INTOBJ_INT(1), t_2, t_3, t_4, t_5, t_6 );
   
  }
  /* fi */
  
  /* req := false; */
  t_1 = False;
  l_req = t_1;
  
  /* for i in [ 1, 3 .. LEN_LIST( OPERATIONS ) - 1 ] do */
  t_7 = GF_LEN__LIST;
  t_8 = GC_OPERATIONS;
  CHECK_BOUND( t_8, "OPERATIONS" )
  t_6 = CALL_1ARGS( t_7, t_8 );
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
   
   /* if IS_IDENTICAL_OBJ( OPERATIONS[i], opr ) then */
   t_7 = GF_IS__IDENTICAL__OBJ;
   t_9 = GC_OPERATIONS;
   CHECK_BOUND( t_9, "OPERATIONS" )
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_8, t_9, l_i )
   t_6 = CALL_2ARGS( t_7, t_8, l_opr );
   CHECK_FUNC_RESULT( t_6 )
   CHECK_BOOL( t_6 )
   t_5 = (Obj)(UInt)(t_6 != False);
   if ( t_5 ) {
    
    /* req := OPERATIONS[i + 1]; */
    t_6 = GC_OPERATIONS;
    CHECK_BOUND( t_6, "OPERATIONS" )
    C_SUM_FIA( t_7, l_i, INTOBJ_INT(1) )
    CHECK_INT_POS( t_7 )
    C_ELM_LIST_FPL( t_5, t_6, t_7 )
    l_req = t_5;
    
    /* break; */
    break;
    
   }
   /* fi */
   
  }
  /* od */
  
  /* if req = false then */
  t_2 = False;
  t_1 = (Obj)(UInt)(EQ( l_req, t_2 ));
  if ( t_1 ) {
   
   /* Error( "unknown operation ", NAME_FUNC( opr ) ); */
   t_1 = GF_Error;
   t_2 = MakeString( "unknown operation " );
   t_4 = GF_NAME__FUNC;
   t_3 = CALL_1ARGS( t_4, l_opr );
   CHECK_FUNC_RESULT( t_3 )
   CALL_2ARGS( t_1, t_2, t_3 );
   
  }
  /* fi */
  
  /* imp := [  ]; */
  t_1 = NEW_PLIST( T_PLIST, 0 );
  SET_LEN_PLIST( t_1, 0 );
  l_imp = t_1;
  
  /* for i in flags do */
  t_4 = l_flags;
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
   
   /* ADD_LIST( imp, WITH_HIDDEN_IMPS_FLAGS( i ) ); */
   t_5 = GF_ADD__LIST;
   t_7 = GF_WITH__HIDDEN__IMPS__FLAGS;
   t_6 = CALL_1ARGS( t_7, l_i );
   CHECK_FUNC_RESULT( t_6 )
   CALL_2ARGS( t_5, l_imp, t_6 );
   
  }
  /* od */
  
  /* j := 0; */
  l_j = INTOBJ_INT(0);
  
  /* match := false; */
  t_1 = False;
  l_match = t_1;
  
  /* notmatch := 0; */
  l_notmatch = INTOBJ_INT(0);
  
  /* while j < LEN_LIST( req ) and not match od */
  while ( 1 ) {
   t_4 = GF_LEN__LIST;
   t_3 = CALL_1ARGS( t_4, l_req );
   CHECK_FUNC_RESULT( t_3 )
   t_2 = (Obj)(UInt)(LT( l_j, t_3 ));
   t_1 = t_2;
   if ( t_1 ) {
    t_4 = (Obj)(UInt)(l_match != False);
    t_3 = (Obj)(UInt)( ! ((Int)t_4) );
    t_1 = t_3;
   }
   if ( ! t_1 ) break;
   
   /* j := j + 1; */
   C_SUM_FIA( t_1, l_j, INTOBJ_INT(1) )
   l_j = t_1;
   
   /* reqs := req[j]; */
   CHECK_INT_POS( l_j )
   C_ELM_LIST_FPL( t_1, l_req, l_j )
   l_reqs = t_1;
   
   /* if LEN_LIST( reqs ) = LEN_LIST( imp ) then */
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, l_reqs );
   CHECK_FUNC_RESULT( t_2 )
   t_4 = GF_LEN__LIST;
   t_3 = CALL_1ARGS( t_4, l_imp );
   CHECK_FUNC_RESULT( t_3 )
   t_1 = (Obj)(UInt)(EQ( t_2, t_3 ));
   if ( t_1 ) {
    
    /* match := true; */
    t_1 = True;
    l_match = t_1;
    
    /* for i in [ 1 .. LEN_LIST( reqs ) ] do */
    t_3 = GF_LEN__LIST;
    t_2 = CALL_1ARGS( t_3, l_reqs );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_INT_SMALL( t_2 )
    for ( t_1 = INTOBJ_INT(1);
          ((Int)t_1) <= ((Int)t_2);
          t_1 = (Obj)(((UInt)t_1)+4) ) {
     l_i = t_1;
     
     /* if not IS_SUBSET_FLAGS( imp[i], reqs[i] ) then */
     t_6 = GF_IS__SUBSET__FLAGS;
     C_ELM_LIST_FPL( t_7, l_imp, l_i )
     C_ELM_LIST_FPL( t_8, l_reqs, l_i )
     t_5 = CALL_2ARGS( t_6, t_7, t_8 );
     CHECK_FUNC_RESULT( t_5 )
     CHECK_BOOL( t_5 )
     t_4 = (Obj)(UInt)(t_5 != False);
     t_3 = (Obj)(UInt)( ! ((Int)t_4) );
     if ( t_3 ) {
      
      /* match := false; */
      t_3 = False;
      l_match = t_3;
      
      /* notmatch := i; */
      l_notmatch = l_i;
      
      /* break; */
      break;
      
     }
     /* fi */
     
    }
    /* od */
    
    /* if match then */
    t_1 = (Obj)(UInt)(l_match != False);
    if ( t_1 ) {
     
     /* break; */
     break;
     
    }
    /* fi */
    
   }
   /* fi */
   
  }
  /* od */
  
  /* if not match then */
  t_2 = (Obj)(UInt)(l_match != False);
  t_1 = (Obj)(UInt)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* if notmatch = 0 then */
   t_1 = (Obj)(UInt)(((Int)l_notmatch) == ((Int)INTOBJ_INT(0)));
   if ( t_1 ) {
    
    /* Error( "the number of arguments does not match a declaration of ", NAME_FUNC( opr ) ); */
    t_1 = GF_Error;
    t_2 = MakeString( "the number of arguments does not match a declaration of " );
    t_4 = GF_NAME__FUNC;
    t_3 = CALL_1ARGS( t_4, l_opr );
    CHECK_FUNC_RESULT( t_3 )
    CALL_2ARGS( t_1, t_2, t_3 );
    
   }
   
   /* else */
   else {
    
    /* Error( "required filters ", NamesFilter( imp[notmatch] ), "\nfor ", Ordinal( notmatch ), " argument do not match a declaration of ", NAME_FUNC( opr ) ); */
    t_1 = GF_Error;
    t_2 = MakeString( "required filters " );
    t_4 = GF_NamesFilter;
    CHECK_INT_POS( l_notmatch )
    C_ELM_LIST_FPL( t_5, l_imp, l_notmatch )
    t_3 = CALL_1ARGS( t_4, t_5 );
    CHECK_FUNC_RESULT( t_3 )
    t_4 = MakeString( "\nfor " );
    t_6 = GF_Ordinal;
    t_5 = CALL_1ARGS( t_6, l_notmatch );
    CHECK_FUNC_RESULT( t_5 )
    t_6 = MakeString( " argument do not match a declaration of " );
    t_8 = GF_NAME__FUNC;
    t_7 = CALL_1ARGS( t_8, l_opr );
    CHECK_FUNC_RESULT( t_7 )
    CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, t_6, t_7 );
    
   }
   /* fi */
   
  }
  
  /* else */
  else {
   
   /* oreqs := reqs; */
   l_oreqs = l_reqs;
   
   /* for k in [ j + 1 .. LEN_LIST( req ) ] do */
   C_SUM_FIA( t_2, l_j, INTOBJ_INT(1) )
   CHECK_INT_SMALL( t_2 )
   t_4 = GF_LEN__LIST;
   t_3 = CALL_1ARGS( t_4, l_req );
   CHECK_FUNC_RESULT( t_3 )
   CHECK_INT_SMALL( t_3 )
   for ( t_1 = t_2;
         ((Int)t_1) <= ((Int)t_3);
         t_1 = (Obj)(((UInt)t_1)+4) ) {
    l_k = t_1;
    
    /* reqs := req[k]; */
    CHECK_INT_POS( l_k )
    C_ELM_LIST_FPL( t_4, l_req, l_k )
    l_reqs = t_4;
    
    /* if LEN_LIST( reqs ) = LEN_LIST( imp ) then */
    t_6 = GF_LEN__LIST;
    t_5 = CALL_1ARGS( t_6, l_reqs );
    CHECK_FUNC_RESULT( t_5 )
    t_7 = GF_LEN__LIST;
    t_6 = CALL_1ARGS( t_7, l_imp );
    CHECK_FUNC_RESULT( t_6 )
    t_4 = (Obj)(UInt)(EQ( t_5, t_6 ));
    if ( t_4 ) {
     
     /* match := true; */
     t_4 = True;
     l_match = t_4;
     
     /* for i in [ 1 .. LEN_LIST( reqs ) ] do */
     t_6 = GF_LEN__LIST;
     t_5 = CALL_1ARGS( t_6, l_reqs );
     CHECK_FUNC_RESULT( t_5 )
     CHECK_INT_SMALL( t_5 )
     for ( t_4 = INTOBJ_INT(1);
           ((Int)t_4) <= ((Int)t_5);
           t_4 = (Obj)(((UInt)t_4)+4) ) {
      l_i = t_4;
      
      /* if not IS_SUBSET_FLAGS( imp[i], reqs[i] ) then */
      t_9 = GF_IS__SUBSET__FLAGS;
      C_ELM_LIST_FPL( t_10, l_imp, l_i )
      C_ELM_LIST_FPL( t_11, l_reqs, l_i )
      t_8 = CALL_2ARGS( t_9, t_10, t_11 );
      CHECK_FUNC_RESULT( t_8 )
      CHECK_BOOL( t_8 )
      t_7 = (Obj)(UInt)(t_8 != False);
      t_6 = (Obj)(UInt)( ! ((Int)t_7) );
      if ( t_6 ) {
       
       /* match := false; */
       t_6 = False;
       l_match = t_6;
       
       /* break; */
       break;
       
      }
      /* fi */
      
     }
     /* od */
     
     /* if match and reqs <> oreqs then */
     t_5 = (Obj)(UInt)(l_match != False);
     t_4 = t_5;
     if ( t_4 ) {
      t_6 = (Obj)(UInt)( ! EQ( l_reqs, l_oreqs ));
      t_4 = t_6;
     }
     if ( t_4 ) {
      
      /* INFO_DEBUG( 1, "method installed for ", NAME_FUNC( opr ), " matches more than one declaration" ); */
      t_4 = GF_INFO__DEBUG;
      t_5 = MakeString( "method installed for " );
      t_7 = GF_NAME__FUNC;
      t_6 = CALL_1ARGS( t_7, l_opr );
      CHECK_FUNC_RESULT( t_6 )
      t_7 = MakeString( " matches more than one declaration" );
      CALL_4ARGS( t_4, INTOBJ_INT(1), t_5, t_6, t_7 );
      
     }
     /* fi */
     
    }
    /* fi */
    
   }
   /* od */
   
  }
  /* fi */
  
 }
 /* fi */
 
 /* INSTALL_METHOD_FLAGS( opr, info, rel, flags, rank, method ); */
 t_1 = GF_INSTALL__METHOD__FLAGS;
 CHECK_BOUND( l_rank, "rank" )
 CALL_6ARGS( t_1, l_opr, l_info, l_rel, l_flags, l_rank, l_method );
 
 /* UNLOCK( lk ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_lk );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self,
 Obj  a_obj )
{
 Obj l_found = 0;
 Obj l_prop = 0;
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
 
 /* found := false; */
 t_1 = False;
 l_found = t_1;
 
 /* for prop in props do */
 t_4 = OBJ_LVAR_1UP( 2 );
 CHECK_BOUND( t_4, "props" )
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
  l_prop = t_2;
  
  /* if not Tester( prop )( obj ) then */
  t_9 = GF_Tester;
  t_8 = CALL_1ARGS( t_9, l_prop );
  CHECK_FUNC_RESULT( t_8 )
  CHECK_FUNC( t_8 )
  t_7 = CALL_1ARGS( t_8, a_obj );
  CHECK_FUNC_RESULT( t_7 )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = (Obj)(UInt)( ! ((Int)t_6) );
  if ( t_5 ) {
   
   /* found := true; */
   t_5 = True;
   l_found = t_5;
   
   /* if not (prop( obj ) and Tester( prop )( obj )) then */
   CHECK_FUNC( l_prop )
   t_8 = CALL_1ARGS( l_prop, a_obj );
   CHECK_FUNC_RESULT( t_8 )
   CHECK_BOOL( t_8 )
   t_7 = (Obj)(UInt)(t_8 != False);
   t_6 = t_7;
   if ( t_6 ) {
    t_11 = GF_Tester;
    t_10 = CALL_1ARGS( t_11, l_prop );
    CHECK_FUNC_RESULT( t_10 )
    CHECK_FUNC( t_10 )
    t_9 = CALL_1ARGS( t_10, a_obj );
    CHECK_FUNC_RESULT( t_9 )
    CHECK_BOOL( t_9 )
    t_8 = (Obj)(UInt)(t_9 != False);
    t_6 = t_8;
   }
   t_5 = (Obj)(UInt)( ! ((Int)t_6) );
   if ( t_5 ) {
    
    /* TryNextMethod(); */
    t_5 = GC_TRY__NEXT__METHOD;
    CHECK_BOUND( t_5, "TRY_NEXT_METHOD" )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_5;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* if found then */
 t_1 = (Obj)(UInt)(l_found != False);
 if ( t_1 ) {
  
  /* return getter( obj ); */
  t_2 = OBJ_LVAR_1UP( 1 );
  CHECK_BOUND( t_2, "getter" )
  CHECK_FUNC( t_2 )
  t_1 = CALL_1ARGS( t_2, a_obj );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* TryNextMethod(); */
  t_1 = GC_TRY__NEXT__METHOD;
  CHECK_BOUND( t_1, "TRY_NEXT_METHOD" )
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

/* handler for function 7 */
static Obj  HdlrFunc7 (
 Obj  self,
 Obj  a_name,
 Obj  a_filter,
 Obj  a_getter,
 Obj  a_setter,
 Obj  a_tester,
 Obj  a_mutflag )
{
 Obj l_flags = 0;
 Obj l_rank = 0;
 Obj l_cats = 0;
 Obj l_i = 0;
 Obj l_lk = 0;
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
 SWITCH_TO_NEW_FRAME(self,2,0,oldFrame);
 ASS_LVAR( 1, a_getter );
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if not IS_IDENTICAL_OBJ( filter, IS_OBJECT ) then */
 t_4 = GF_IS__IDENTICAL__OBJ;
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 t_3 = CALL_2ARGS( t_4, a_filter, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* flags := FLAGS_FILTER( filter ); */
  t_2 = GF_FLAGS__FILTER;
  t_1 = CALL_1ARGS( t_2, a_filter );
  CHECK_FUNC_RESULT( t_1 )
  l_flags = t_1;
  
  /* rank := 0; */
  l_rank = INTOBJ_INT(0);
  
  /* cats := IS_OBJECT; */
  t_1 = GC_IS__OBJECT;
  CHECK_BOUND( t_1, "IS_OBJECT" )
  l_cats = t_1;
  
  /* props := [  ]; */
  t_1 = NEW_PLIST( T_PLIST, 0 );
  SET_LEN_PLIST( t_1, 0 );
  ASS_LVAR( 2, t_1 );
  
  /* lk := DO_LOCK( FILTER_REGION, false, CATS_AND_REPS ); */
  t_2 = GF_DO__LOCK;
  t_3 = GC_FILTER__REGION;
  CHECK_BOUND( t_3, "FILTER_REGION" )
  t_4 = False;
  t_5 = GC_CATS__AND__REPS;
  CHECK_BOUND( t_5, "CATS_AND_REPS" )
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
  CHECK_FUNC_RESULT( t_1 )
  l_lk = t_1;
  
  /* for i in [ 1 .. LEN_FLAGS( flags ) ] do */
  t_3 = GF_LEN__FLAGS;
  t_2 = CALL_1ARGS( t_3, l_flags );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_INT_SMALL( t_2 )
  for ( t_1 = INTOBJ_INT(1);
        ((Int)t_1) <= ((Int)t_2);
        t_1 = (Obj)(((UInt)t_1)+4) ) {
   l_i = t_1;
   
   /* if ELM_FLAGS( flags, i ) then */
   t_5 = GF_ELM__FLAGS;
   t_4 = CALL_2ARGS( t_5, l_flags, l_i );
   CHECK_FUNC_RESULT( t_4 )
   CHECK_BOOL( t_4 )
   t_3 = (Obj)(UInt)(t_4 != False);
   if ( t_3 ) {
    
    /* if i in CATS_AND_REPS then */
    t_4 = GC_CATS__AND__REPS;
    CHECK_BOUND( t_4, "CATS_AND_REPS" )
    t_3 = (Obj)(UInt)(IN( l_i, t_4 ));
    if ( t_3 ) {
     
     /* cats := cats and FILTERS[i]; */
     if ( l_cats == False ) {
      t_3 = l_cats;
     }
     else if ( l_cats == True ) {
      t_5 = GC_FILTERS;
      CHECK_BOUND( t_5, "FILTERS" )
      C_ELM_LIST_FPL( t_4, t_5, l_i )
      CHECK_BOOL( t_4 )
      t_3 = t_4;
     }
     else {
      CHECK_FUNC( l_cats )
      t_6 = GC_FILTERS;
      CHECK_BOUND( t_6, "FILTERS" )
      C_ELM_LIST_FPL( t_5, t_6, l_i )
      CHECK_FUNC( t_5 )
      t_3 = NewAndFilter( l_cats, t_5 );
     }
     l_cats = t_3;
     
     /* rank := rank - RankFilter( FILTERS[i] ); */
     t_5 = GF_RankFilter;
     t_7 = GC_FILTERS;
     CHECK_BOUND( t_7, "FILTERS" )
     C_ELM_LIST_FPL( t_6, t_7, l_i )
     t_4 = CALL_1ARGS( t_5, t_6 );
     CHECK_FUNC_RESULT( t_4 )
     C_DIFF_FIA( t_3, l_rank, t_4 )
     l_rank = t_3;
     
    }
    
    /* elif i in NUMBERS_PROPERTY_GETTERS then */
    else {
     t_4 = GC_NUMBERS__PROPERTY__GETTERS;
     CHECK_BOUND( t_4, "NUMBERS_PROPERTY_GETTERS" )
     t_3 = (Obj)(UInt)(IN( l_i, t_4 ));
     if ( t_3 ) {
      
      /* ADD_LIST( props, FILTERS[i] ); */
      t_3 = GF_ADD__LIST;
      t_4 = OBJ_LVAR( 2 );
      CHECK_BOUND( t_4, "props" )
      t_6 = GC_FILTERS;
      CHECK_BOUND( t_6, "FILTERS" )
      C_ELM_LIST_FPL( t_5, t_6, l_i )
      CALL_2ARGS( t_3, t_4, t_5 );
      
     }
    }
    /* fi */
    
   }
   /* fi */
   
  }
  /* od */
  
  /* UNLOCK( lk ); */
  t_1 = GF_UNLOCK;
  CALL_1ARGS( t_1, l_lk );
  
  /* MakeImmutable( props ); */
  t_1 = GF_MakeImmutable;
  t_2 = OBJ_LVAR( 2 );
  CHECK_BOUND( t_2, "props" )
  CALL_1ARGS( t_1, t_2 );
  
  /* if 0 < LEN_LIST( props ) then */
  t_3 = GF_LEN__LIST;
  t_4 = OBJ_LVAR( 2 );
  CHECK_BOUND( t_4, "props" )
  t_2 = CALL_1ARGS( t_3, t_4 );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(LT( INTOBJ_INT(0), t_2 ));
  if ( t_1 ) {
   
   /* InstallOtherMethod( getter, "default method requiring categories and checking properties", true, [ cats ], rank, function ( obj )
      local  found, prop;
      found := false;
      for prop  in props  do
          if not Tester( prop )( obj )  then
              found := true;
              if not (prop( obj ) and Tester( prop )( obj ))  then
                  TryNextMethod();
              fi;
          fi;
      od;
      if found  then
          return getter( obj );
      else
          TryNextMethod();
      fi;
      return;
  end ); */
   t_1 = GF_InstallOtherMethod;
   t_2 = OBJ_LVAR( 1 );
   CHECK_BOUND( t_2, "getter" )
   t_3 = MakeString( "default method requiring categories and checking properties" );
   t_4 = True;
   t_5 = NEW_PLIST( T_PLIST, 1 );
   SET_LEN_PLIST( t_5, 1 );
   SET_ELM_PLIST( t_5, 1, l_cats );
   CHANGED_BAG( t_5 );
   t_6 = NewFunction( NameFunc[8], 1, 0, HdlrFunc8 );
   SET_ENVI_FUNC( t_6, STATE(CurrLVars) );
   t_7 = NewBag( T_BODY, sizeof(BodyHeader) );
   SET_STARTLINE_BODY(t_7, 606);
   SET_ENDLINE_BODY(t_7, 624);
   SET_FILENAME_BODY(t_7, FileName);
   SET_BODY_FUNC(t_6, t_7);
   CHANGED_BAG( STATE(CurrLVars) );
   CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, l_rank, t_6 );
   
  }
  /* fi */
  
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

/* handler for function 9 */
static Obj  HdlrFunc9 (
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* InstallOtherMethod( setter, "default method, does nothing", true, [ IS_OBJECT, IS_OBJECT ], 0, DO_NOTHING_SETTER ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = MakeString( "default method, does nothing" );
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_4, 2 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 SET_ELM_PLIST( t_4, 2, t_5 );
 CHANGED_BAG( t_4 );
 t_5 = GC_DO__NOTHING__SETTER;
 CHECK_BOUND( t_5, "DO_NOTHING_SETTER" )
 CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
 
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
 Obj  a_list,
 Obj  a_elm )
{
 Obj l_i = 0;
 Obj l_j = 0;
 Obj l_k = 0;
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
 
 /* k := LEN_LIST( list ) + 1; */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_list );
 CHECK_FUNC_RESULT( t_2 )
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 l_k = t_1;
 
 /* if k mod 2 = 0 then */
 t_2 = MOD( l_k, INTOBJ_INT(2) );
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(0) ));
 if ( t_1 ) {
  
  /* k := k + 1; */
  C_SUM_FIA( t_1, l_k, INTOBJ_INT(1) )
  l_k = t_1;
  
 }
 /* fi */
 
 /* i := -1; */
 l_i = INTOBJ_INT(-1);
 
 /* while i + 2 < k od */
 while ( 1 ) {
  C_SUM_FIA( t_2, l_i, INTOBJ_INT(2) )
  t_1 = (Obj)(UInt)(LT( t_2, l_k ));
  if ( ! t_1 ) break;
  
  /* j := 2 * QUO_INT( (i + k + 2), 4 ) - 1; */
  t_4 = GF_QUO__INT;
  C_SUM_FIA( t_6, l_i, l_k )
  C_SUM_FIA( t_5, t_6, INTOBJ_INT(2) )
  t_3 = CALL_2ARGS( t_4, t_5, INTOBJ_INT(4) );
  CHECK_FUNC_RESULT( t_3 )
  C_PROD_FIA( t_2, INTOBJ_INT(2), t_3 )
  C_DIFF_FIA( t_1, t_2, INTOBJ_INT(1) )
  l_j = t_1;
  
  /* if list[j] < elm then */
  CHECK_INT_POS( l_j )
  C_ELM_LIST_FPL( t_2, a_list, l_j )
  t_1 = (Obj)(UInt)(LT( t_2, a_elm ));
  if ( t_1 ) {
   
   /* i := j; */
   l_i = l_j;
   
  }
  
  /* else */
  else {
   
   /* k := j; */
   l_k = l_j;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return k; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_k;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self,
 Obj  a_key )
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
 
 /* if not IsPrimeInt( key ) then */
 t_4 = GF_IsPrimeInt;
 t_3 = CALL_1ARGS( t_4, a_key );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( name, ": <p> must be a prime" ); */
  t_1 = GF_Error;
  t_2 = OBJ_LVAR_1UP( 1 );
  CHECK_BOUND( t_2, "name" )
  t_3 = MakeString( ": <p> must be a prime" );
  CALL_2ARGS( t_1, t_2, t_3 );
  
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

/* handler for function 13 */
static Obj  HdlrFunc13 (
 Obj  self,
 Obj  a_D )
{
 Obj t_1 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* return [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
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
 Obj  a_D,
 Obj  a_key )
{
 Obj l_known = 0;
 Obj l_i = 0;
 Obj l_erg = 0;
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
 
 /* keytest( key ); */
 t_1 = OBJ_LVAR_1UP( 2 );
 CHECK_BOUND( t_1, "keytest" )
 CHECK_FUNC( t_1 )
 CALL_1ARGS( t_1, a_key );
 
 /* known := attr( D ); */
 t_2 = OBJ_LVAR_1UP( 4 );
 CHECK_BOUND( t_2, "attr" )
 CHECK_FUNC( t_2 )
 t_1 = CALL_1ARGS( t_2, a_D );
 CHECK_FUNC_RESULT( t_1 )
 l_known = t_1;
 
 /* i := PositionSortedOddPositions( known, key ); */
 t_2 = GF_PositionSortedOddPositions;
 t_1 = CALL_2ARGS( t_2, l_known, a_key );
 CHECK_FUNC_RESULT( t_1 )
 l_i = t_1;
 
 /* if LEN_LIST( known ) < i or known[i] <> key then */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_known );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = (Obj)(UInt)(LT( t_3, l_i ));
 t_1 = t_2;
 if ( ! t_1 ) {
  CHECK_INT_POS( l_i )
  C_ELM_LIST_FPL( t_4, l_known, l_i )
  t_3 = (Obj)(UInt)( ! EQ( t_4, a_key ));
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* erg := oper( D, key ); */
  t_2 = OBJ_LVAR_1UP( 3 );
  CHECK_BOUND( t_2, "oper" )
  CHECK_FUNC( t_2 )
  t_1 = CALL_2ARGS( t_2, a_D, a_key );
  CHECK_FUNC_RESULT( t_1 )
  l_erg = t_1;
  
  /* i := PositionSortedOddPositions( known, key ); */
  t_2 = GF_PositionSortedOddPositions;
  t_1 = CALL_2ARGS( t_2, l_known, a_key );
  CHECK_FUNC_RESULT( t_1 )
  l_i = t_1;
  
  /* if LEN_LIST( known ) < i or known[i] <> key then */
  t_4 = GF_LEN__LIST;
  t_3 = CALL_1ARGS( t_4, l_known );
  CHECK_FUNC_RESULT( t_3 )
  t_2 = (Obj)(UInt)(LT( t_3, l_i ));
  t_1 = t_2;
  if ( ! t_1 ) {
   CHECK_INT_POS( l_i )
   C_ELM_LIST_FPL( t_4, l_known, l_i )
   t_3 = (Obj)(UInt)( ! EQ( t_4, a_key ));
   t_1 = t_3;
  }
  if ( t_1 ) {
   
   /* known{[ i + 2 .. LEN_LIST( known ) + 2 ]} := known{[ i .. LEN_LIST( known ) ]}; */
   C_SUM_FIA( t_2, l_i, INTOBJ_INT(2) )
   t_5 = GF_LEN__LIST;
   t_4 = CALL_1ARGS( t_5, l_known );
   CHECK_FUNC_RESULT( t_4 )
   C_SUM_FIA( t_3, t_4, INTOBJ_INT(2) )
   t_1 = Range2Check( t_2, t_3 );
   t_5 = GF_LEN__LIST;
   t_4 = CALL_1ARGS( t_5, l_known );
   CHECK_FUNC_RESULT( t_4 )
   t_3 = Range2Check( l_i, t_4 );
   t_2 = ElmsListCheck( l_known, t_3 );
   AsssListCheck( l_known, t_1, t_2 );
   
   /* known[i] := IMMUTABLE_COPY_OBJ( key ); */
   CHECK_INT_POS( l_i )
   t_2 = GF_IMMUTABLE__COPY__OBJ;
   t_1 = CALL_1ARGS( t_2, a_key );
   CHECK_FUNC_RESULT( t_1 )
   C_ASS_LIST_FPL( l_known, l_i, t_1 )
   
   /* known[i + 1] := IMMUTABLE_COPY_OBJ( erg ); */
   C_SUM_FIA( t_1, l_i, INTOBJ_INT(1) )
   CHECK_INT_POS( t_1 )
   t_3 = GF_IMMUTABLE__COPY__OBJ;
   t_2 = CALL_1ARGS( t_3, l_erg );
   CHECK_FUNC_RESULT( t_2 )
   C_ASS_LIST_FPL( l_known, t_1, t_2 )
   
  }
  /* fi */
  
 }
 /* fi */
 
 /* return known[i + 1]; */
 C_SUM_FIA( t_2, l_i, INTOBJ_INT(1) )
 CHECK_INT_POS( t_2 )
 C_ELM_LIST_FPL( t_1, l_known, t_2 )
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
 Obj  a_D,
 Obj  a_key )
{
 Obj l_known = 0;
 Obj l_i = 0;
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
 
 /* keytest( key ); */
 t_1 = OBJ_LVAR_1UP( 2 );
 CHECK_BOUND( t_1, "keytest" )
 CHECK_FUNC( t_1 )
 CALL_1ARGS( t_1, a_key );
 
 /* known := attr( D ); */
 t_2 = OBJ_LVAR_1UP( 4 );
 CHECK_BOUND( t_2, "attr" )
 CHECK_FUNC( t_2 )
 t_1 = CALL_1ARGS( t_2, a_D );
 CHECK_FUNC_RESULT( t_1 )
 l_known = t_1;
 
 /* i := PositionSortedOddPositions( known, key ); */
 t_2 = GF_PositionSortedOddPositions;
 t_1 = CALL_2ARGS( t_2, l_known, a_key );
 CHECK_FUNC_RESULT( t_1 )
 l_i = t_1;
 
 /* return i <= LEN_LIST( known ) and known[i] = key; */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_known );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = (LT( t_3, l_i ) ?  False : True);
 if ( t_2 == False ) {
  t_1 = t_2;
 }
 else if ( t_2 == True ) {
  CHECK_INT_POS( l_i )
  C_ELM_LIST_FPL( t_4, l_known, l_i )
  t_3 = (EQ( t_4, a_key ) ? True : False);
  t_1 = t_3;
 }
 else {
  CHECK_FUNC( t_2 )
  C_ELM_LIST_FPL( t_5, l_known, l_i )
  t_4 = (EQ( t_5, a_key ) ? True : False);
  CHECK_FUNC( t_4 )
  t_1 = NewAndFilter( t_2, t_4 );
 }
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
 Obj  a_D,
 Obj  a_key,
 Obj  a_obj )
{
 Obj l_known = 0;
 Obj l_i = 0;
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
 
 /* keytest( key ); */
 t_1 = OBJ_LVAR_1UP( 2 );
 CHECK_BOUND( t_1, "keytest" )
 CHECK_FUNC( t_1 )
 CALL_1ARGS( t_1, a_key );
 
 /* known := attr( D ); */
 t_2 = OBJ_LVAR_1UP( 4 );
 CHECK_BOUND( t_2, "attr" )
 CHECK_FUNC( t_2 )
 t_1 = CALL_1ARGS( t_2, a_D );
 CHECK_FUNC_RESULT( t_1 )
 l_known = t_1;
 
 /* i := PositionSortedOddPositions( known, key ); */
 t_2 = GF_PositionSortedOddPositions;
 t_1 = CALL_2ARGS( t_2, l_known, a_key );
 CHECK_FUNC_RESULT( t_1 )
 l_i = t_1;
 
 /* if LEN_LIST( known ) < i or known[i] <> key then */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_known );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = (Obj)(UInt)(LT( t_3, l_i ));
 t_1 = t_2;
 if ( ! t_1 ) {
  CHECK_INT_POS( l_i )
  C_ELM_LIST_FPL( t_4, l_known, l_i )
  t_3 = (Obj)(UInt)( ! EQ( t_4, a_key ));
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* known{[ i + 2 .. LEN_LIST( known ) + 2 ]} := known{[ i .. LEN_LIST( known ) ]}; */
  C_SUM_FIA( t_2, l_i, INTOBJ_INT(2) )
  t_5 = GF_LEN__LIST;
  t_4 = CALL_1ARGS( t_5, l_known );
  CHECK_FUNC_RESULT( t_4 )
  C_SUM_FIA( t_3, t_4, INTOBJ_INT(2) )
  t_1 = Range2Check( t_2, t_3 );
  t_5 = GF_LEN__LIST;
  t_4 = CALL_1ARGS( t_5, l_known );
  CHECK_FUNC_RESULT( t_4 )
  t_3 = Range2Check( l_i, t_4 );
  t_2 = ElmsListCheck( l_known, t_3 );
  AsssListCheck( l_known, t_1, t_2 );
  
  /* known[i] := IMMUTABLE_COPY_OBJ( key ); */
  CHECK_INT_POS( l_i )
  t_2 = GF_IMMUTABLE__COPY__OBJ;
  t_1 = CALL_1ARGS( t_2, a_key );
  CHECK_FUNC_RESULT( t_1 )
  C_ASS_LIST_FPL( l_known, l_i, t_1 )
  
  /* known[i + 1] := IMMUTABLE_COPY_OBJ( obj ); */
  C_SUM_FIA( t_1, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_1 )
  t_3 = GF_IMMUTABLE__COPY__OBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  C_ASS_LIST_FPL( l_known, t_1, t_2 )
  
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
 Obj  a_name,
 Obj  a_domreq,
 Obj  a_keyreq,
 Obj  a_keytest )
{
 Obj l_str = 0;
 Obj l_lk = 0;
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
 SWITCH_TO_NEW_FRAME(self,4,0,oldFrame);
 ASS_LVAR( 1, a_name );
 ASS_LVAR( 2, a_keytest );
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if keytest = "prime" then */
 t_2 = OBJ_LVAR( 2 );
 CHECK_BOUND( t_2, "keytest" )
 t_3 = MakeString( "prime" );
 t_1 = (Obj)(UInt)(EQ( t_2, t_3 ));
 if ( t_1 ) {
  
  /* keytest := function ( key )
      if not IsPrimeInt( key )  then
          Error( name, ": <p> must be a prime" );
      fi;
      return;
  end; */
  t_1 = NewFunction( NameFunc[12], 1, 0, HdlrFunc12 );
  SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
  t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
  SET_STARTLINE_BODY(t_2, 803);
  SET_ENDLINE_BODY(t_2, 807);
  SET_FILENAME_BODY(t_2, FileName);
  SET_BODY_FUNC(t_1, t_2);
  CHANGED_BAG( STATE(CurrLVars) );
  ASS_LVAR( 2, t_1 );
  
 }
 /* fi */
 
 /* str := SHALLOW_COPY_OBJ( name ); */
 t_2 = GF_SHALLOW__COPY__OBJ;
 t_3 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_3, "name" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_str = t_1;
 
 /* APPEND_LIST_INTR( str, "Op" ); */
 t_1 = GF_APPEND__LIST__INTR;
 t_2 = MakeString( "Op" );
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* DeclareOperation( str, [ domreq, keyreq ] ); */
 t_1 = GF_DeclareOperation;
 t_2 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_2, 2 );
 SET_ELM_PLIST( t_2, 1, a_domreq );
 CHANGED_BAG( t_2 );
 SET_ELM_PLIST( t_2, 2, a_keyreq );
 CHANGED_BAG( t_2 );
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* oper := VALUE_GLOBAL( str ); */
 t_2 = GF_VALUE__GLOBAL;
 t_1 = CALL_1ARGS( t_2, l_str );
 CHECK_FUNC_RESULT( t_1 )
 ASS_LVAR( 3, t_1 );
 
 /* str := "Computed"; */
 t_1 = MakeString( "Computed" );
 l_str = t_1;
 
 /* APPEND_LIST_INTR( str, name ); */
 t_1 = GF_APPEND__LIST__INTR;
 t_2 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_2, "name" )
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* APPEND_LIST_INTR( str, "s" ); */
 t_1 = GF_APPEND__LIST__INTR;
 t_2 = MakeString( "s" );
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* DeclareAttribute( str, domreq, "mutable" ); */
 t_1 = GF_DeclareAttribute;
 t_2 = MakeString( "mutable" );
 CALL_3ARGS( t_1, l_str, a_domreq, t_2 );
 
 /* attr := VALUE_GLOBAL( str ); */
 t_2 = GF_VALUE__GLOBAL;
 t_1 = CALL_1ARGS( t_2, l_str );
 CHECK_FUNC_RESULT( t_1 )
 ASS_LVAR( 4, t_1 );
 
 /* InstallMethod( attr, "default method", true, [ domreq ], 0, function ( D )
      return [  ];
  end ); */
 t_1 = GF_InstallMethod;
 t_2 = OBJ_LVAR( 4 );
 CHECK_BOUND( t_2, "attr" )
 t_3 = MakeString( "default method" );
 t_4 = True;
 t_5 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_5, 1 );
 SET_ELM_PLIST( t_5, 1, a_domreq );
 CHANGED_BAG( t_5 );
 t_6 = NewFunction( NameFunc[13], 1, 0, HdlrFunc13 );
 SET_ENVI_FUNC( t_6, STATE(CurrLVars) );
 t_7 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_7, 824);
 SET_ENDLINE_BODY(t_7, 824);
 SET_FILENAME_BODY(t_7, FileName);
 SET_BODY_FUNC(t_6, t_7);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, INTOBJ_INT(0), t_6 );
 
 /* DeclareOperation( name, [ domreq, keyreq ] ); */
 t_1 = GF_DeclareOperation;
 t_2 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_2, "name" )
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_3, 1, a_domreq );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 2, a_keyreq );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* lk := WRITE_LOCK( OPERATIONS_REGION ); */
 t_2 = GF_WRITE__LOCK;
 t_3 = GC_OPERATIONS__REGION;
 CHECK_BOUND( t_3, "OPERATIONS_REGION" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_lk = t_1;
 
 /* ADD_LIST( WRAPPER_OPERATIONS, VALUE_GLOBAL( name ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_WRAPPER__OPERATIONS;
 CHECK_BOUND( t_2, "WRAPPER_OPERATIONS" )
 t_4 = GF_VALUE__GLOBAL;
 t_5 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_5, "name" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* UNLOCK( lk ); */
 t_1 = GF_UNLOCK;
 CALL_1ARGS( t_1, l_lk );
 
 /* InstallOtherMethod( VALUE_GLOBAL( name ), "default method", true, [ domreq, keyreq ], 0, function ( D, key )
      local  known, i, erg;
      keytest( key );
      known := attr( D );
      i := PositionSortedOddPositions( known, key );
      if LEN_LIST( known ) < i or known[i] <> key  then
          erg := oper( D, key );
          i := PositionSortedOddPositions( known, key );
          if LEN_LIST( known ) < i or known[i] <> key  then
              known{[ i + 2 .. LEN_LIST( known ) + 2 ]} := known{[ i .. LEN_LIST( known ) ]};
              known[i] := IMMUTABLE_COPY_OBJ( key );
              known[i + 1] := IMMUTABLE_COPY_OBJ( erg );
          fi;
      fi;
      return known[i + 1];
  end ); */
 t_1 = GF_InstallOtherMethod;
 t_3 = GF_VALUE__GLOBAL;
 t_4 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_4, "name" )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 t_3 = MakeString( "default method" );
 t_4 = True;
 t_5 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_5, 2 );
 SET_ELM_PLIST( t_5, 1, a_domreq );
 CHANGED_BAG( t_5 );
 SET_ELM_PLIST( t_5, 2, a_keyreq );
 CHANGED_BAG( t_5 );
 t_6 = NewFunction( NameFunc[14], 2, 0, HdlrFunc14 );
 SET_ENVI_FUNC( t_6, STATE(CurrLVars) );
 t_7 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_7, 840);
 SET_ENDLINE_BODY(t_7, 863);
 SET_FILENAME_BODY(t_7, FileName);
 SET_BODY_FUNC(t_6, t_7);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, INTOBJ_INT(0), t_6 );
 
 /* str := "Has"; */
 t_1 = MakeString( "Has" );
 l_str = t_1;
 
 /* APPEND_LIST_INTR( str, name ); */
 t_1 = GF_APPEND__LIST__INTR;
 t_2 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_2, "name" )
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* DeclareOperation( str, [ domreq, keyreq ] ); */
 t_1 = GF_DeclareOperation;
 t_2 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_2, 2 );
 SET_ELM_PLIST( t_2, 1, a_domreq );
 CHANGED_BAG( t_2 );
 SET_ELM_PLIST( t_2, 2, a_keyreq );
 CHANGED_BAG( t_2 );
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* InstallOtherMethod( VALUE_GLOBAL( str ), "default method", true, [ domreq, keyreq ], 0, function ( D, key )
      local  known, i;
      keytest( key );
      known := attr( D );
      i := PositionSortedOddPositions( known, key );
      return i <= LEN_LIST( known ) and known[i] = key;
  end ); */
 t_1 = GF_InstallOtherMethod;
 t_3 = GF_VALUE__GLOBAL;
 t_2 = CALL_1ARGS( t_3, l_str );
 CHECK_FUNC_RESULT( t_2 )
 t_3 = MakeString( "default method" );
 t_4 = True;
 t_5 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_5, 2 );
 SET_ELM_PLIST( t_5, 1, a_domreq );
 CHANGED_BAG( t_5 );
 SET_ELM_PLIST( t_5, 2, a_keyreq );
 CHANGED_BAG( t_5 );
 t_6 = NewFunction( NameFunc[15], 2, 0, HdlrFunc15 );
 SET_ENVI_FUNC( t_6, STATE(CurrLVars) );
 t_7 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_7, 873);
 SET_ENDLINE_BODY(t_7, 881);
 SET_FILENAME_BODY(t_7, FileName);
 SET_BODY_FUNC(t_6, t_7);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, INTOBJ_INT(0), t_6 );
 
 /* str := "Set"; */
 t_1 = MakeString( "Set" );
 l_str = t_1;
 
 /* APPEND_LIST_INTR( str, name ); */
 t_1 = GF_APPEND__LIST__INTR;
 t_2 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_2, "name" )
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* DeclareOperation( str, [ domreq, keyreq, IS_OBJECT ] ); */
 t_1 = GF_DeclareOperation;
 t_2 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_2, 3 );
 SET_ELM_PLIST( t_2, 1, a_domreq );
 CHANGED_BAG( t_2 );
 SET_ELM_PLIST( t_2, 2, a_keyreq );
 CHANGED_BAG( t_2 );
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 SET_ELM_PLIST( t_2, 3, t_3 );
 CHANGED_BAG( t_2 );
 CALL_2ARGS( t_1, l_str, t_2 );
 
 /* InstallOtherMethod( VALUE_GLOBAL( str ), "default method", true, [ domreq, keyreq, IS_OBJECT ], 0, function ( D, key, obj )
      local  known, i;
      keytest( key );
      known := attr( D );
      i := PositionSortedOddPositions( known, key );
      if LEN_LIST( known ) < i or known[i] <> key  then
          known{[ i + 2 .. LEN_LIST( known ) + 2 ]} := known{[ i .. LEN_LIST( known ) ]};
          known[i] := IMMUTABLE_COPY_OBJ( key );
          known[i + 1] := IMMUTABLE_COPY_OBJ( obj );
      fi;
      return;
  end ); */
 t_1 = GF_InstallOtherMethod;
 t_3 = GF_VALUE__GLOBAL;
 t_2 = CALL_1ARGS( t_3, l_str );
 CHECK_FUNC_RESULT( t_2 )
 t_3 = MakeString( "default method" );
 t_4 = True;
 t_5 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_5, 3 );
 SET_ELM_PLIST( t_5, 1, a_domreq );
 CHANGED_BAG( t_5 );
 SET_ELM_PLIST( t_5, 2, a_keyreq );
 CHANGED_BAG( t_5 );
 t_6 = GC_IS__OBJECT;
 CHECK_BOUND( t_6, "IS_OBJECT" )
 SET_ELM_PLIST( t_5, 3, t_6 );
 CHANGED_BAG( t_5 );
 t_6 = NewFunction( NameFunc[16], 3, 0, HdlrFunc16 );
 SET_ENVI_FUNC( t_6, STATE(CurrLVars) );
 t_7 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_7, 890);
 SET_ENDLINE_BODY(t_7, 903);
 SET_FILENAME_BODY(t_7, FileName);
 SET_BODY_FUNC(t_6, t_7);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, INTOBJ_INT(0), t_6 );
 
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
 Obj  a_arg )
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
 Obj t_12 = 0;
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Obj t_18 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* re := false; */
 t_1 = False;
 ASS_LVAR_1UP( 4, t_1 );
 
 /* for i in [ 1 .. LEN_LIST( reqs ) ] do */
 t_6 = GF_LEN__LIST;
 t_7 = OBJ_LVAR_1UP( 2 );
 CHECK_BOUND( t_7, "reqs" )
 t_5 = CALL_1ARGS( t_6, t_7 );
 CHECK_FUNC_RESULT( t_5 )
 t_4 = Range2Check( INTOBJ_INT(1), t_5 );
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
  ASS_LVAR_1UP( 5, t_2 );
  
  /* re := re or IsBound( cond[i] ) and not Tester( cond[i] )( arg[i] ) and cond[i]( arg[i] ) and Tester( cond[i] )( arg[i] ); */
  t_7 = OBJ_LVAR_1UP( 4 );
  CHECK_BOUND( t_7, "re" )
  CHECK_BOOL( t_7 )
  t_6 = (Obj)(UInt)(t_7 != False);
  t_5 = (t_6 ? True : False);
  if ( t_5 == False ) {
   t_12 = OBJ_LVAR_1UP( 3 );
   CHECK_BOUND( t_12, "cond" )
   t_13 = OBJ_LVAR_1UP( 5 );
   CHECK_BOUND( t_13, "i" )
   CHECK_INT_POS( t_13 )
   t_11 = C_ISB_LIST( t_12, t_13 );
   t_10 = (Obj)(UInt)(t_11 != False);
   t_9 = t_10;
   if ( t_9 ) {
    t_15 = GF_Tester;
    t_17 = OBJ_LVAR_1UP( 3 );
    CHECK_BOUND( t_17, "cond" )
    t_18 = OBJ_LVAR_1UP( 5 );
    CHECK_BOUND( t_18, "i" )
    CHECK_INT_POS( t_18 )
    C_ELM_LIST_FPL( t_16, t_17, t_18 )
    t_14 = CALL_1ARGS( t_15, t_16 );
    CHECK_FUNC_RESULT( t_14 )
    CHECK_FUNC( t_14 )
    t_16 = OBJ_LVAR_1UP( 5 );
    CHECK_BOUND( t_16, "i" )
    CHECK_INT_POS( t_16 )
    C_ELM_LIST_FPL( t_15, a_arg, t_16 )
    t_13 = CALL_1ARGS( t_14, t_15 );
    CHECK_FUNC_RESULT( t_13 )
    CHECK_BOOL( t_13 )
    t_12 = (Obj)(UInt)(t_13 != False);
    t_11 = (Obj)(UInt)( ! ((Int)t_12) );
    t_9 = t_11;
   }
   t_8 = t_9;
   if ( t_8 ) {
    t_13 = OBJ_LVAR_1UP( 3 );
    CHECK_BOUND( t_13, "cond" )
    t_14 = OBJ_LVAR_1UP( 5 );
    CHECK_BOUND( t_14, "i" )
    CHECK_INT_POS( t_14 )
    C_ELM_LIST_FPL( t_12, t_13, t_14 )
    CHECK_FUNC( t_12 )
    t_14 = OBJ_LVAR_1UP( 5 );
    CHECK_BOUND( t_14, "i" )
    CHECK_INT_POS( t_14 )
    C_ELM_LIST_FPL( t_13, a_arg, t_14 )
    t_11 = CALL_1ARGS( t_12, t_13 );
    CHECK_FUNC_RESULT( t_11 )
    CHECK_BOOL( t_11 )
    t_10 = (Obj)(UInt)(t_11 != False);
    t_8 = t_10;
   }
   t_7 = t_8;
   if ( t_7 ) {
    t_12 = GF_Tester;
    t_14 = OBJ_LVAR_1UP( 3 );
    CHECK_BOUND( t_14, "cond" )
    t_15 = OBJ_LVAR_1UP( 5 );
    CHECK_BOUND( t_15, "i" )
    CHECK_INT_POS( t_15 )
    C_ELM_LIST_FPL( t_13, t_14, t_15 )
    t_11 = CALL_1ARGS( t_12, t_13 );
    CHECK_FUNC_RESULT( t_11 )
    CHECK_FUNC( t_11 )
    t_13 = OBJ_LVAR_1UP( 5 );
    CHECK_BOUND( t_13, "i" )
    CHECK_INT_POS( t_13 )
    C_ELM_LIST_FPL( t_12, a_arg, t_13 )
    t_10 = CALL_1ARGS( t_11, t_12 );
    CHECK_FUNC_RESULT( t_10 )
    CHECK_BOOL( t_10 )
    t_9 = (Obj)(UInt)(t_10 != False);
    t_7 = t_9;
   }
   t_5 = (t_7 ? True : False);
  }
  ASS_LVAR_1UP( 4, t_5 );
  
 }
 /* od */
 
 /* if re then */
 t_2 = OBJ_LVAR_1UP( 4 );
 CHECK_BOUND( t_2, "re" )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* return CallFuncList( oper, arg ); */
  t_2 = GF_CallFuncList;
  t_3 = OBJ_LVAR_1UP( 1 );
  CHECK_BOUND( t_3, "oper" )
  t_1 = CALL_2ARGS( t_2, t_3, a_arg );
  CHECK_FUNC_RESULT( t_1 )
  RES_BRK_CURR_STAT();
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* TryNextMethod(); */
  t_1 = GC_TRY__NEXT__METHOD;
  CHECK_BOUND( t_1, "TRY_NEXT_METHOD" )
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

/* handler for function 17 */
static Obj  HdlrFunc17 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_info = 0;
 Obj l_fampred = 0;
 Obj l_val = 0;
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,5,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* if LEN_LIST( arg ) = 5 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(5) ));
 if ( t_1 ) {
  
  /* oper := arg[1]; */
  C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(1) )
  ASS_LVAR( 1, t_1 );
  
  /* info := " fallback method to test conditions"; */
  t_1 = MakeString( " fallback method to test conditions" );
  l_info = t_1;
  
  /* fampred := arg[2]; */
  C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(2) )
  l_fampred = t_1;
  
  /* reqs := arg[3]; */
  C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(3) )
  ASS_LVAR( 2, t_1 );
  
  /* cond := arg[4]; */
  C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(4) )
  ASS_LVAR( 3, t_1 );
  
  /* val := arg[5]; */
  C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(5) )
  l_val = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 6 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(6) ));
  if ( t_1 ) {
   
   /* oper := arg[1]; */
   C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(1) )
   ASS_LVAR( 1, t_1 );
   
   /* info := arg[2]; */
   C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(2) )
   l_info = t_1;
   
   /* fampred := arg[3]; */
   C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(3) )
   l_fampred = t_1;
   
   /* reqs := arg[4]; */
   C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(4) )
   ASS_LVAR( 2, t_1 );
   
   /* cond := arg[5]; */
   C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(5) )
   ASS_LVAR( 3, t_1 );
   
   /* val := arg[6]; */
   C_ELM_LIST_FPL( t_1, a_arg, INTOBJ_INT(6) )
   l_val = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "Usage: RedispatchOnCondition(oper[,info],fampred,reqs,cond,val)" ); */
   t_1 = GF_Error;
   t_2 = MakeString( "Usage: RedispatchOnCondition(oper[,info],fampred,reqs,cond,val)" );
   CALL_1ARGS( t_1, t_2 );
   
  }
 }
 /* fi */
 
 /* for i in reqs do */
 t_4 = OBJ_LVAR( 2 );
 CHECK_BOUND( t_4, "reqs" )
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
  ASS_LVAR( 5, t_2 );
  
  /* val := val - SIZE_FLAGS( WITH_HIDDEN_IMPS_FLAGS( FLAGS_FILTER( i ) ) ); */
  CHECK_BOUND( l_val, "val" )
  t_7 = GF_SIZE__FLAGS;
  t_9 = GF_WITH__HIDDEN__IMPS__FLAGS;
  t_11 = GF_FLAGS__FILTER;
  t_12 = OBJ_LVAR( 5 );
  CHECK_BOUND( t_12, "i" )
  t_10 = CALL_1ARGS( t_11, t_12 );
  CHECK_FUNC_RESULT( t_10 )
  t_8 = CALL_1ARGS( t_9, t_10 );
  CHECK_FUNC_RESULT( t_8 )
  t_6 = CALL_1ARGS( t_7, t_8 );
  CHECK_FUNC_RESULT( t_6 )
  C_DIFF_FIA( t_5, l_val, t_6 )
  l_val = t_5;
  
 }
 /* od */
 
 /* InstallOtherMethod( oper, info, fampred, reqs, val, function ( arg... )
      re := false;
      for i  in [ 1 .. LEN_LIST( reqs ) ]  do
          re := re or IsBound( cond[i] ) and not Tester( cond[i] )( arg[i] ) and cond[i]( arg[i] ) and Tester( cond[i] )( arg[i] );
      od;
      if re  then
          return CallFuncList( oper, arg );
      else
          TryNextMethod();
      fi;
      return;
  end ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = OBJ_LVAR( 1 );
 CHECK_BOUND( t_2, "oper" )
 CHECK_BOUND( l_info, "info" )
 CHECK_BOUND( l_fampred, "fampred" )
 t_3 = OBJ_LVAR( 2 );
 CHECK_BOUND( t_3, "reqs" )
 t_4 = NewFunction( NameFunc[18], -1, 0, HdlrFunc18 );
 SET_ENVI_FUNC( t_4, STATE(CurrLVars) );
 t_5 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_5, 971);
 SET_ENDLINE_BODY(t_5, 987);
 SET_FILENAME_BODY(t_5, FileName);
 SET_BODY_FUNC(t_4, t_5);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_6ARGS( t_1, t_2, l_info, l_fampred, t_3, l_val, t_4 );
 
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
 Obj t_6 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* RUN_IMMEDIATE_METHODS_CHECKS := 0; */
 AssGVar( G_RUN__IMMEDIATE__METHODS__CHECKS, INTOBJ_INT(0) );
 
 /* RUN_IMMEDIATE_METHODS_HITS := 0; */
 AssGVar( G_RUN__IMMEDIATE__METHODS__HITS, INTOBJ_INT(0) );
 
 /* BIND_GLOBAL( "RunImmediateMethods", function ( obj, flags )
      local  flagspos, tried, type, j, imm, i, res, newflags;
      if IGNORE_IMMEDIATE_METHODS  then
          return;
      fi;
      if IS_SUBSET_FLAGS( IMM_FLAGS, flags )  then
          return;
      fi;
      flags := SUB_FLAGS( flags, IMM_FLAGS );
      flagspos := SHALLOW_COPY_OBJ( TRUES_FLAGS( flags ) );
      tried := [  ];
      type := TYPE_OBJ( obj );
      flags := type![2];
      for j  in flagspos  do
          if IsBound( IMMEDIATES[j] )  then
              imm := IMMEDIATES[j];
              for i  in [ 0, 7 .. LEN_LIST( imm ) - 7 ]  do
                  if IS_SUBSET_FLAGS( flags, imm[i + 4] ) and not IS_SUBSET_FLAGS( flags, imm[i + 3] ) and not imm[i + 6] in tried  then
                      res := IMMEDIATE_METHODS[imm[i + 6]]( obj );
                      ADD_LIST( tried, imm[i + 6] );
                      RUN_IMMEDIATE_METHODS_CHECKS := RUN_IMMEDIATE_METHODS_CHECKS + 1;
                      if TRACE_IMMEDIATE_METHODS  then
                          if imm[i + 7] = false  then
                              Print( "#I  immediate: ", NAME_FUNC( imm[i + 1] ), "\n" );
                          else
                              Print( "#I  immediate: ", NAME_FUNC( imm[i + 1] ), ": ", imm[i + 7], "\n" );
                          fi;
                      fi;
                      if res <> TRY_NEXT_METHOD  then
                          IGNORE_IMMEDIATE_METHODS := true;
                          imm[i + 2]( obj, res );
                          IGNORE_IMMEDIATE_METHODS := false;
                          RUN_IMMEDIATE_METHODS_HITS := RUN_IMMEDIATE_METHODS_HITS + 1;
                          if not IS_IDENTICAL_OBJ( TYPE_OBJ( obj ), type )  then
                              type := TYPE_OBJ( obj );
                              newflags := SUB_FLAGS( type![2], IMM_FLAGS );
                              newflags := SUB_FLAGS( newflags, flags );
                              APPEND_LIST_INTR( flagspos, TRUES_FLAGS( newflags ) );
                              flags := type![2];
                          fi;
                      fi;
                  fi;
              od;
          fi;
      od;
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "RunImmediateMethods" );
 t_3 = NewFunction( NameFunc[2], 2, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 26);
 SET_ENDLINE_BODY(t_4, 117);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "METHODS_OPERATION_REGION", NewSpecialRegion( "operation methods" ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "METHODS_OPERATION_REGION" );
 t_4 = GF_NewSpecialRegion;
 t_5 = MakeString( "operation methods" );
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "INSTALL_METHOD_FLAGS", function ( opr, info, rel, flags, rank, method )
      local  methods, narg, i, k, tmp, replace, match, j, lk;
      lk := WRITE_LOCK( METHODS_OPERATION_REGION );
      if IS_CONSTRUCTOR( opr )  then
          if 0 < LEN_LIST( flags )  then
              rank := rank - RankFilter( flags[1] );
          fi;
      else
          for i  in flags  do
              rank := rank + RankFilter( i );
          od;
      fi;
      narg := LEN_LIST( flags );
      methods := METHODS_OPERATION( opr, narg );
      methods := methods{[ 1 .. LEN_LIST( methods ) ]};
      if info = false  then
          info := NAME_FUNC( opr );
      else
          k := SHALLOW_COPY_OBJ( NAME_FUNC( opr ) );
          APPEND_LIST_INTR( k, ": " );
          APPEND_LIST_INTR( k, info );
          info := k;
          CONV_STRING( info );
      fi;
      i := 0;
      while i < LEN_LIST( methods ) and rank < methods[i + (narg + 3)]  do
          i := i + (narg + 4);
      od;
      replace := false;
      if REREADING  then
          k := i;
          while k < LEN_LIST( methods ) and rank = methods[k + narg + 3]  do
              if info = methods[k + narg + 4]  then
                  match := false;
                  for j  in [ 1 .. narg ]  do
                      match := match and methods[k + j + 1] = flags[j];
                  od;
                  if match  then
                      replace := true;
                      i := k;
                      break;
                  fi;
              fi;
              k := k + narg + 4;
          od;
      fi;
      if not REREADING or not replace  then
          methods{[ narg + 4 + i + 1 .. narg + 4 + LEN_LIST( methods ) ]} := methods{[ i + 1 .. LEN_LIST( methods ) ]};
      fi;
      if rel = true  then
          methods[i + 1] := RETURN_TRUE;
      elif rel = false  then
          methods[i + 1] := RETURN_FALSE;
      elif IS_FUNCTION( rel )  then
          if CHECK_INSTALL_METHOD  then
              tmp := NARG_FUNC( rel );
              if tmp < AINV( narg ) - 1 or tmp >= 0 and tmp <> narg  then
                  Error( NAME_FUNC( opr ), ": <famrel> must accept ", narg, " arguments" );
              fi;
          fi;
          methods[i + 1] := rel;
      else
          Error( NAME_FUNC( opr ), ": <famrel> must be a function, `true', or `false'" );
      fi;
      for k  in [ 1 .. narg ]  do
          methods[i + k + 1] := flags[k];
      od;
      if method = true  then
          methods[i + (narg + 2)] := RETURN_TRUE;
      elif method = false  then
          methods[i + (narg + 2)] := RETURN_FALSE;
      elif IS_FUNCTION( method )  then
          if CHECK_INSTALL_METHOD and not IS_OPERATION( method )  then
              tmp := NARG_FUNC( method );
              if tmp < AINV( narg ) - 1 or tmp >= 0 and tmp <> narg  then
                  Error( NAME_FUNC( opr ), ": <method> must accept ", narg, " arguments" );
              fi;
          fi;
          methods[i + (narg + 2)] := method;
      else
          Error( NAME_FUNC( opr ), ": <method> must be a function, `true', or `false'" );
      fi;
      methods[i + (narg + 3)] := rank;
      methods[i + (narg + 4)] := IMMUTABLE_COPY_OBJ( info );
      SET_METHODS_OPERATION( opr, narg, MakeReadOnlyObj( methods ) );
      UNLOCK( lk );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "INSTALL_METHOD_FLAGS" );
 t_3 = NewFunction( NameFunc[3], 6, 0, HdlrFunc3 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 136);
 SET_ENDLINE_BODY(t_4, 250);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "InstallMethod", function ( arg... )
      INSTALL_METHOD( arg, true );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "InstallMethod" );
 t_3 = NewFunction( NameFunc[4], -1, 0, HdlrFunc4 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 297);
 SET_ENDLINE_BODY(t_4, 299);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "InstallOtherMethod", function ( arg... )
      INSTALL_METHOD( arg, false );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "InstallOtherMethod" );
 t_3 = NewFunction( NameFunc[5], -1, 0, HdlrFunc5 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 324);
 SET_ENDLINE_BODY(t_4, 326);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareGlobalFunction( "EvalString" ); */
 t_1 = GF_DeclareGlobalFunction;
 t_2 = MakeString( "EvalString" );
 CALL_1ARGS( t_1, t_2 );
 
 /* Unbind( INSTALL_METHOD ); */
 AssGVar( G_INSTALL__METHOD, 0 );
 
 /* BIND_GLOBAL( "INSTALL_METHOD", function ( arglist, check )
      local  len, opr, info, pos, rel, filters, info1, isstr, flags, i, rank, method, oreqs, req, reqs, match, j, k, imp, notmatch, lk;
      lk := READ_LOCK( OPERATIONS_REGION );
      len := LEN_LIST( arglist );
      if len < 3  then
          Error( "too few arguments given in <arglist>" );
      fi;
      opr := arglist[1];
      if not IS_OPERATION( opr )  then
          Error( "<opr> is not an operation" );
      fi;
      if IS_STRING_REP( arglist[2] )  then
          info := arglist[2];
          pos := 3;
      else
          info := false;
          pos := 2;
      fi;
      if arglist[pos] = true or IS_FUNCTION( arglist[pos] )  then
          rel := arglist[pos];
          pos := pos + 1;
      else
          rel := true;
      fi;
      if not IsBound( arglist[pos] ) or not IS_LIST( arglist[pos] )  then
          Error( "<arglist>[", pos, "] must be a list of filters" );
      fi;
      filters := arglist[pos];
      if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters )  then
          Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod, " arguments" );
      fi;
      if 0 < LEN_LIST( filters )  then
          info1 := "[ ";
          isstr := true;
          for i  in [ 1 .. LEN_LIST( filters ) ]  do
              if IS_STRING_REP( filters[i] )  then
                  APPEND_LIST_INTR( info1, filters[i] );
                  APPEND_LIST_INTR( info1, ", " );
                  filters[i] := EvalString( filters[i] );
                  if not IS_FUNCTION( filters[i] )  then
                      Error( "string does not evaluate to a function" );
                  fi;
              else
                  isstr := false;
                  break;
              fi;
          od;
          if isstr and info = false  then
              info1[LEN_LIST( info1 ) - 1] := ' ';
              info1[LEN_LIST( info1 )] := ']';
              info := info1;
          fi;
      fi;
      pos := pos + 1;
      flags := [  ];
      for i  in filters  do
          ADD_LIST( flags, FLAGS_FILTER( i ) );
      od;
      if not IsBound( arglist[pos] )  then
          Error( "the method is missing in <arglist>" );
      elif IS_INT( arglist[pos] )  then
          rank := arglist[pos];
          pos := pos + 1;
      else
          rank := 0;
      fi;
      if not IsBound( arglist[pos] )  then
          Error( "the method is missing in <arglist>" );
      fi;
      method := arglist[pos];
      if FLAG1_FILTER( opr ) <> 0 and (rel = true or rel = RETURN_TRUE) and LEN_LIST( filters ) = 1 and (method = true or method = RETURN_TRUE)  then
          Error( NAME_FUNC( opr ), ": use `InstallTrueMethod' for <opr>" );
      fi;
      if CHECK_INSTALL_METHOD and check  then
          if opr in WRAPPER_OPERATIONS  then
              INFO_DEBUG( 1, "a method is installed for the wrapper operation ", NAME_FUNC( opr ), "\n", "#I  probably it should be installed for (one of) its\n", "#I  underlying operation(s)" );
          fi;
          req := false;
          for i  in [ 1, 3 .. LEN_LIST( OPERATIONS ) - 1 ]  do
              if IS_IDENTICAL_OBJ( OPERATIONS[i], opr )  then
                  req := OPERATIONS[i + 1];
                  break;
              fi;
          od;
          if req = false  then
              Error( "unknown operation ", NAME_FUNC( opr ) );
          fi;
          imp := [  ];
          for i  in flags  do
              ADD_LIST( imp, WITH_HIDDEN_IMPS_FLAGS( i ) );
          od;
          j := 0;
          match := false;
          notmatch := 0;
          while j < LEN_LIST( req ) and not match  do
              j := j + 1;
              reqs := req[j];
              if LEN_LIST( reqs ) = LEN_LIST( imp )  then
                  match := true;
                  for i  in [ 1 .. LEN_LIST( reqs ) ]  do
                      if not IS_SUBSET_FLAGS( imp[i], reqs[i] )  then
                          match := false;
                          notmatch := i;
                          break;
                      fi;
                  od;
                  if match  then
                      break;
                  fi;
              fi;
          od;
          if not match  then
              if notmatch = 0  then
                  Error( "the number of arguments does not match a declaration of ", NAME_FUNC( opr ) );
              else
                  Error( "required filters ", NamesFilter( imp[notmatch] ), "\nfor ", Ordinal( notmatch ), " argument do not match a declaration of ", NAME_FUNC( opr ) );
              fi;
          else
              oreqs := reqs;
              for k  in [ j + 1 .. LEN_LIST( req ) ]  do
                  reqs := req[k];
                  if LEN_LIST( reqs ) = LEN_LIST( imp )  then
                      match := true;
                      for i  in [ 1 .. LEN_LIST( reqs ) ]  do
                          if not IS_SUBSET_FLAGS( imp[i], reqs[i] )  then
                              match := false;
                              break;
                          fi;
                      od;
                      if match and reqs <> oreqs  then
                          INFO_DEBUG( 1, "method installed for ", NAME_FUNC( opr ), " matches more than one declaration" );
                      fi;
                  fi;
              od;
          fi;
      fi;
      INSTALL_METHOD_FLAGS( opr, info, rel, flags, rank, method );
      UNLOCK( lk );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "INSTALL_METHOD" );
 t_3 = NewFunction( NameFunc[6], 2, 0, HdlrFunc6 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 337);
 SET_ENDLINE_BODY(t_4, 548);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + 6; */
 t_2 = GC_LENGTH__SETTER__METHODS__2;
 CHECK_BOUND( t_2, "LENGTH_SETTER_METHODS_2" )
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(6) )
 AssGVar( G_LENGTH__SETTER__METHODS__2, t_1 );
 
 /* InstallAttributeFunction( function ( name, filter, getter, setter, tester, mutflag )
      local  flags, rank, cats, props, i, lk;
      if not IS_IDENTICAL_OBJ( filter, IS_OBJECT )  then
          flags := FLAGS_FILTER( filter );
          rank := 0;
          cats := IS_OBJECT;
          props := [  ];
          lk := DO_LOCK( FILTER_REGION, false, CATS_AND_REPS );
          for i  in [ 1 .. LEN_FLAGS( flags ) ]  do
              if ELM_FLAGS( flags, i )  then
                  if i in CATS_AND_REPS  then
                      cats := cats and FILTERS[i];
                      rank := rank - RankFilter( FILTERS[i] );
                  elif i in NUMBERS_PROPERTY_GETTERS  then
                      ADD_LIST( props, FILTERS[i] );
                  fi;
              fi;
          od;
          UNLOCK( lk );
          MakeImmutable( props );
          if 0 < LEN_LIST( props )  then
              InstallOtherMethod( getter, "default method requiring categories and checking properties", true, [ cats ], rank, function ( obj )
                    local  found, prop;
                    found := false;
                    for prop  in props  do
                        if not Tester( prop )( obj )  then
                            found := true;
                            if not (prop( obj ) and Tester( prop )( obj ))  then
                                TryNextMethod();
                            fi;
                        fi;
                    od;
                    if found  then
                        return getter( obj );
                    else
                        TryNextMethod();
                    fi;
                    return;
                end );
          fi;
      fi;
      return;
  end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[7], 6, 0, HdlrFunc7 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_3, 567);
 SET_ENDLINE_BODY(t_3, 628);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_1ARGS( t_1, t_2 );
 
 /* InstallAttributeFunction( function ( name, filter, getter, setter, tester, mutflag )
      InstallOtherMethod( setter, "default method, does nothing", true, [ IS_OBJECT, IS_OBJECT ], 0, DO_NOTHING_SETTER );
      return;
  end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[9], 6, 0, HdlrFunc9 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_3, 631);
 SET_ENDLINE_BODY(t_3, 637);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_1ARGS( t_1, t_2 );
 
 /* BIND_GLOBAL( "PositionSortedOddPositions", function ( list, elm )
      local  i, j, k;
      k := LEN_LIST( list ) + 1;
      if k mod 2 = 0  then
          k := k + 1;
      fi;
      i := -1;
      while i + 2 < k  do
          j := 2 * QUO_INT( (i + k + 2), 4 ) - 1;
          if list[j] < elm  then
              i := j;
          else
              k := j;
          fi;
      od;
      return k;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "PositionSortedOddPositions" );
 t_3 = NewFunction( NameFunc[10], 2, 0, HdlrFunc10 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 650);
 SET_ENDLINE_BODY(t_4, 674);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* IsPrimeInt := "2b defined"; */
 t_1 = MakeString( "2b defined" );
 AssGVar( G_IsPrimeInt, t_1 );
 
 /* BIND_GLOBAL( "KeyDependentOperation", function ( name, domreq, keyreq, keytest )
      local  str, oper, attr, lk;
      if keytest = "prime"  then
          keytest := function ( key )
                if not IsPrimeInt( key )  then
                    Error( name, ": <p> must be a prime" );
                fi;
                return;
            end;
      fi;
      str := SHALLOW_COPY_OBJ( name );
      APPEND_LIST_INTR( str, "Op" );
      DeclareOperation( str, [ domreq, keyreq ] );
      oper := VALUE_GLOBAL( str );
      str := "Computed";
      APPEND_LIST_INTR( str, name );
      APPEND_LIST_INTR( str, "s" );
      DeclareAttribute( str, domreq, "mutable" );
      attr := VALUE_GLOBAL( str );
      InstallMethod( attr, "default method", true, [ domreq ], 0, function ( D )
            return [  ];
        end );
      DeclareOperation( name, [ domreq, keyreq ] );
      lk := WRITE_LOCK( OPERATIONS_REGION );
      ADD_LIST( WRAPPER_OPERATIONS, VALUE_GLOBAL( name ) );
      UNLOCK( lk );
      InstallOtherMethod( VALUE_GLOBAL( name ), "default method", true, [ domreq, keyreq ], 0, function ( D, key )
            local  known, i, erg;
            keytest( key );
            known := attr( D );
            i := PositionSortedOddPositions( known, key );
            if LEN_LIST( known ) < i or known[i] <> key  then
                erg := oper( D, key );
                i := PositionSortedOddPositions( known, key );
                if LEN_LIST( known ) < i or known[i] <> key  then
                    known{[ i + 2 .. LEN_LIST( known ) + 2 ]} := known{[ i .. LEN_LIST( known ) ]};
                    known[i] := IMMUTABLE_COPY_OBJ( key );
                    known[i + 1] := IMMUTABLE_COPY_OBJ( erg );
                fi;
            fi;
            return known[i + 1];
        end );
      str := "Has";
      APPEND_LIST_INTR( str, name );
      DeclareOperation( str, [ domreq, keyreq ] );
      InstallOtherMethod( VALUE_GLOBAL( str ), "default method", true, [ domreq, keyreq ], 0, function ( D, key )
            local  known, i;
            keytest( key );
            known := attr( D );
            i := PositionSortedOddPositions( known, key );
            return i <= LEN_LIST( known ) and known[i] = key;
        end );
      str := "Set";
      APPEND_LIST_INTR( str, name );
      DeclareOperation( str, [ domreq, keyreq, IS_OBJECT ] );
      InstallOtherMethod( VALUE_GLOBAL( str ), "default method", true, [ domreq, keyreq, IS_OBJECT ], 0, function ( D, key, obj )
            local  known, i;
            keytest( key );
            known := attr( D );
            i := PositionSortedOddPositions( known, key );
            if LEN_LIST( known ) < i or known[i] <> key  then
                known{[ i + 2 .. LEN_LIST( known ) + 2 ]} := known{[ i .. LEN_LIST( known ) ]};
                known[i] := IMMUTABLE_COPY_OBJ( key );
                known[i + 1] := IMMUTABLE_COPY_OBJ( obj );
            fi;
            return;
        end );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "KeyDependentOperation" );
 t_3 = NewFunction( NameFunc[11], 4, 0, HdlrFunc11 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 799);
 SET_ENDLINE_BODY(t_4, 904);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* CallFuncList := "2b defined"; */
 t_1 = MakeString( "2b defined" );
 AssGVar( G_CallFuncList, t_1 );
 
 /* BIND_GLOBAL( "RedispatchOnCondition", function ( arg... )
      local  oper, info, fampred, reqs, cond, val, re, i;
      if LEN_LIST( arg ) = 5  then
          oper := arg[1];
          info := " fallback method to test conditions";
          fampred := arg[2];
          reqs := arg[3];
          cond := arg[4];
          val := arg[5];
      elif LEN_LIST( arg ) = 6  then
          oper := arg[1];
          info := arg[2];
          fampred := arg[3];
          reqs := arg[4];
          cond := arg[5];
          val := arg[6];
      else
          Error( "Usage: RedispatchOnCondition(oper[,info],fampred,reqs,cond,val)" );
      fi;
      for i  in reqs  do
          val := val - SIZE_FLAGS( WITH_HIDDEN_IMPS_FLAGS( FLAGS_FILTER( i ) ) );
      od;
      InstallOtherMethod( oper, info, fampred, reqs, val, function ( arg... )
            re := false;
            for i  in [ 1 .. LEN_LIST( reqs ) ]  do
                re := re or IsBound( cond[i] ) and not Tester( cond[i] )( arg[i] ) and cond[i]( arg[i] ) and Tester( cond[i] )( arg[i] );
            od;
            if re  then
                return CallFuncList( oper, arg );
            else
                TryNextMethod();
            fi;
            return;
        end );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "RedispatchOnCondition" );
 t_3 = NewFunction( NameFunc[17], -1, 0, HdlrFunc17 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 939);
 SET_ENDLINE_BODY(t_4, 988);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* InstallMethod( ViewObj, "default method using `PrintObj'", true, [ IS_OBJECT ], 0, PRINT_OBJ ); */
 t_1 = GF_InstallMethod;
 t_2 = GC_ViewObj;
 CHECK_BOUND( t_2, "ViewObj" )
 t_3 = MakeString( "default method using `PrintObj'" );
 t_4 = True;
 t_5 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_5, 1 );
 t_6 = GC_IS__OBJECT;
 CHECK_BOUND( t_6, "IS_OBJECT" )
 SET_ELM_PLIST( t_5, 1, t_6 );
 CHANGED_BAG( t_5 );
 t_6 = GC_PRINT__OBJ;
 CHECK_BOUND( t_6, "PRINT_OBJ" )
 CALL_6ARGS( t_1, t_2, t_3, t_4, t_5, INTOBJ_INT(0), t_6 );
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_REREADING = GVarName( "REREADING" );
 G_SHALLOW__COPY__OBJ = GVarName( "SHALLOW_COPY_OBJ" );
 G_PRINT__OBJ = GVarName( "PRINT_OBJ" );
 G_GAPInfo = GVarName( "GAPInfo" );
 G_IS__FUNCTION = GVarName( "IS_FUNCTION" );
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 G_NARG__FUNC = GVarName( "NARG_FUNC" );
 G_IS__OPERATION = GVarName( "IS_OPERATION" );
 G_AINV = GVarName( "AINV" );
 G_IS__INT = GVarName( "IS_INT" );
 G_IS__LIST = GVarName( "IS_LIST" );
 G_ADD__LIST = GVarName( "ADD_LIST" );
 G_IS__STRING__REP = GVarName( "IS_STRING_REP" );
 G_Error = GVarName( "Error" );
 G_TYPE__OBJ = GVarName( "TYPE_OBJ" );
 G_IMMUTABLE__COPY__OBJ = GVarName( "IMMUTABLE_COPY_OBJ" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_MakeImmutable = GVarName( "MakeImmutable" );
 G_IS__OBJECT = GVarName( "IS_OBJECT" );
 G_TRY__NEXT__METHOD = GVarName( "TRY_NEXT_METHOD" );
 G_SUB__FLAGS = GVarName( "SUB_FLAGS" );
 G_WITH__HIDDEN__IMPS__FLAGS = GVarName( "WITH_HIDDEN_IMPS_FLAGS" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_TRUES__FLAGS = GVarName( "TRUES_FLAGS" );
 G_SIZE__FLAGS = GVarName( "SIZE_FLAGS" );
 G_LEN__FLAGS = GVarName( "LEN_FLAGS" );
 G_ELM__FLAGS = GVarName( "ELM_FLAGS" );
 G_FLAG1__FILTER = GVarName( "FLAG1_FILTER" );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 G_SET__METHODS__OPERATION = GVarName( "SET_METHODS_OPERATION" );
 G_DO__NOTHING__SETTER = GVarName( "DO_NOTHING_SETTER" );
 G_QUO__INT = GVarName( "QUO_INT" );
 G_RETURN__TRUE = GVarName( "RETURN_TRUE" );
 G_RETURN__FALSE = GVarName( "RETURN_FALSE" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_APPEND__LIST__INTR = GVarName( "APPEND_LIST_INTR" );
 G_CONV__STRING = GVarName( "CONV_STRING" );
 G_Print = GVarName( "Print" );
 G_ViewObj = GVarName( "ViewObj" );
 G_DO__LOCK = GVarName( "DO_LOCK" );
 G_WRITE__LOCK = GVarName( "WRITE_LOCK" );
 G_READ__LOCK = GVarName( "READ_LOCK" );
 G_UNLOCK = GVarName( "UNLOCK" );
 G_MakeReadOnlyObj = GVarName( "MakeReadOnlyObj" );
 G_RUN__IMMEDIATE__METHODS__CHECKS = GVarName( "RUN_IMMEDIATE_METHODS_CHECKS" );
 G_RUN__IMMEDIATE__METHODS__HITS = GVarName( "RUN_IMMEDIATE_METHODS_HITS" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_IGNORE__IMMEDIATE__METHODS = GVarName( "IGNORE_IMMEDIATE_METHODS" );
 G_IMM__FLAGS = GVarName( "IMM_FLAGS" );
 G_IMMEDIATES = GVarName( "IMMEDIATES" );
 G_IMMEDIATE__METHODS = GVarName( "IMMEDIATE_METHODS" );
 G_TRACE__IMMEDIATE__METHODS = GVarName( "TRACE_IMMEDIATE_METHODS" );
 G_NewSpecialRegion = GVarName( "NewSpecialRegion" );
 G_METHODS__OPERATION__REGION = GVarName( "METHODS_OPERATION_REGION" );
 G_IS__CONSTRUCTOR = GVarName( "IS_CONSTRUCTOR" );
 G_RankFilter = GVarName( "RankFilter" );
 G_CHECK__INSTALL__METHOD = GVarName( "CHECK_INSTALL_METHOD" );
 G_INSTALL__METHOD = GVarName( "INSTALL_METHOD" );
 G_DeclareGlobalFunction = GVarName( "DeclareGlobalFunction" );
 G_OPERATIONS__REGION = GVarName( "OPERATIONS_REGION" );
 G_EvalString = GVarName( "EvalString" );
 G_WRAPPER__OPERATIONS = GVarName( "WRAPPER_OPERATIONS" );
 G_INFO__DEBUG = GVarName( "INFO_DEBUG" );
 G_OPERATIONS = GVarName( "OPERATIONS" );
 G_NamesFilter = GVarName( "NamesFilter" );
 G_Ordinal = GVarName( "Ordinal" );
 G_INSTALL__METHOD__FLAGS = GVarName( "INSTALL_METHOD_FLAGS" );
 G_LENGTH__SETTER__METHODS__2 = GVarName( "LENGTH_SETTER_METHODS_2" );
 G_InstallAttributeFunction = GVarName( "InstallAttributeFunction" );
 G_FILTER__REGION = GVarName( "FILTER_REGION" );
 G_CATS__AND__REPS = GVarName( "CATS_AND_REPS" );
 G_FILTERS = GVarName( "FILTERS" );
 G_NUMBERS__PROPERTY__GETTERS = GVarName( "NUMBERS_PROPERTY_GETTERS" );
 G_InstallOtherMethod = GVarName( "InstallOtherMethod" );
 G_Tester = GVarName( "Tester" );
 G_IsPrimeInt = GVarName( "IsPrimeInt" );
 G_DeclareOperation = GVarName( "DeclareOperation" );
 G_VALUE__GLOBAL = GVarName( "VALUE_GLOBAL" );
 G_DeclareAttribute = GVarName( "DeclareAttribute" );
 G_InstallMethod = GVarName( "InstallMethod" );
 G_PositionSortedOddPositions = GVarName( "PositionSortedOddPositions" );
 G_CallFuncList = GVarName( "CallFuncList" );
 
 /* record names used in handlers */
 R_MaxNrArgsMethod = RNamName( "MaxNrArgsMethod" );
 
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
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitCopyGVar( "REREADING", &GC_REREADING );
 InitFopyGVar( "SHALLOW_COPY_OBJ", &GF_SHALLOW__COPY__OBJ );
 InitCopyGVar( "PRINT_OBJ", &GC_PRINT__OBJ );
 InitCopyGVar( "GAPInfo", &GC_GAPInfo );
 InitFopyGVar( "IS_FUNCTION", &GF_IS__FUNCTION );
 InitFopyGVar( "NAME_FUNC", &GF_NAME__FUNC );
 InitFopyGVar( "NARG_FUNC", &GF_NARG__FUNC );
 InitFopyGVar( "IS_OPERATION", &GF_IS__OPERATION );
 InitFopyGVar( "AINV", &GF_AINV );
 InitFopyGVar( "IS_INT", &GF_IS__INT );
 InitFopyGVar( "IS_LIST", &GF_IS__LIST );
 InitFopyGVar( "ADD_LIST", &GF_ADD__LIST );
 InitFopyGVar( "IS_STRING_REP", &GF_IS__STRING__REP );
 InitFopyGVar( "Error", &GF_Error );
 InitFopyGVar( "TYPE_OBJ", &GF_TYPE__OBJ );
 InitFopyGVar( "IMMUTABLE_COPY_OBJ", &GF_IMMUTABLE__COPY__OBJ );
 InitFopyGVar( "IS_IDENTICAL_OBJ", &GF_IS__IDENTICAL__OBJ );
 InitFopyGVar( "MakeImmutable", &GF_MakeImmutable );
 InitCopyGVar( "IS_OBJECT", &GC_IS__OBJECT );
 InitCopyGVar( "TRY_NEXT_METHOD", &GC_TRY__NEXT__METHOD );
 InitFopyGVar( "SUB_FLAGS", &GF_SUB__FLAGS );
 InitFopyGVar( "WITH_HIDDEN_IMPS_FLAGS", &GF_WITH__HIDDEN__IMPS__FLAGS );
 InitFopyGVar( "IS_SUBSET_FLAGS", &GF_IS__SUBSET__FLAGS );
 InitFopyGVar( "TRUES_FLAGS", &GF_TRUES__FLAGS );
 InitFopyGVar( "SIZE_FLAGS", &GF_SIZE__FLAGS );
 InitFopyGVar( "LEN_FLAGS", &GF_LEN__FLAGS );
 InitFopyGVar( "ELM_FLAGS", &GF_ELM__FLAGS );
 InitFopyGVar( "FLAG1_FILTER", &GF_FLAG1__FILTER );
 InitFopyGVar( "FLAGS_FILTER", &GF_FLAGS__FILTER );
 InitFopyGVar( "METHODS_OPERATION", &GF_METHODS__OPERATION );
 InitFopyGVar( "SET_METHODS_OPERATION", &GF_SET__METHODS__OPERATION );
 InitCopyGVar( "DO_NOTHING_SETTER", &GC_DO__NOTHING__SETTER );
 InitFopyGVar( "QUO_INT", &GF_QUO__INT );
 InitCopyGVar( "RETURN_TRUE", &GC_RETURN__TRUE );
 InitCopyGVar( "RETURN_FALSE", &GC_RETURN__FALSE );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitFopyGVar( "APPEND_LIST_INTR", &GF_APPEND__LIST__INTR );
 InitFopyGVar( "CONV_STRING", &GF_CONV__STRING );
 InitFopyGVar( "Print", &GF_Print );
 InitCopyGVar( "ViewObj", &GC_ViewObj );
 InitFopyGVar( "DO_LOCK", &GF_DO__LOCK );
 InitFopyGVar( "WRITE_LOCK", &GF_WRITE__LOCK );
 InitFopyGVar( "READ_LOCK", &GF_READ__LOCK );
 InitFopyGVar( "UNLOCK", &GF_UNLOCK );
 InitFopyGVar( "MakeReadOnlyObj", &GF_MakeReadOnlyObj );
 InitCopyGVar( "RUN_IMMEDIATE_METHODS_CHECKS", &GC_RUN__IMMEDIATE__METHODS__CHECKS );
 InitCopyGVar( "RUN_IMMEDIATE_METHODS_HITS", &GC_RUN__IMMEDIATE__METHODS__HITS );
 InitFopyGVar( "BIND_GLOBAL", &GF_BIND__GLOBAL );
 InitCopyGVar( "IGNORE_IMMEDIATE_METHODS", &GC_IGNORE__IMMEDIATE__METHODS );
 InitCopyGVar( "IMM_FLAGS", &GC_IMM__FLAGS );
 InitCopyGVar( "IMMEDIATES", &GC_IMMEDIATES );
 InitCopyGVar( "IMMEDIATE_METHODS", &GC_IMMEDIATE__METHODS );
 InitCopyGVar( "TRACE_IMMEDIATE_METHODS", &GC_TRACE__IMMEDIATE__METHODS );
 InitFopyGVar( "NewSpecialRegion", &GF_NewSpecialRegion );
 InitCopyGVar( "METHODS_OPERATION_REGION", &GC_METHODS__OPERATION__REGION );
 InitFopyGVar( "IS_CONSTRUCTOR", &GF_IS__CONSTRUCTOR );
 InitFopyGVar( "RankFilter", &GF_RankFilter );
 InitCopyGVar( "CHECK_INSTALL_METHOD", &GC_CHECK__INSTALL__METHOD );
 InitFopyGVar( "INSTALL_METHOD", &GF_INSTALL__METHOD );
 InitFopyGVar( "DeclareGlobalFunction", &GF_DeclareGlobalFunction );
 InitCopyGVar( "OPERATIONS_REGION", &GC_OPERATIONS__REGION );
 InitFopyGVar( "EvalString", &GF_EvalString );
 InitCopyGVar( "WRAPPER_OPERATIONS", &GC_WRAPPER__OPERATIONS );
 InitFopyGVar( "INFO_DEBUG", &GF_INFO__DEBUG );
 InitCopyGVar( "OPERATIONS", &GC_OPERATIONS );
 InitFopyGVar( "NamesFilter", &GF_NamesFilter );
 InitFopyGVar( "Ordinal", &GF_Ordinal );
 InitFopyGVar( "INSTALL_METHOD_FLAGS", &GF_INSTALL__METHOD__FLAGS );
 InitCopyGVar( "LENGTH_SETTER_METHODS_2", &GC_LENGTH__SETTER__METHODS__2 );
 InitFopyGVar( "InstallAttributeFunction", &GF_InstallAttributeFunction );
 InitCopyGVar( "FILTER_REGION", &GC_FILTER__REGION );
 InitCopyGVar( "CATS_AND_REPS", &GC_CATS__AND__REPS );
 InitCopyGVar( "FILTERS", &GC_FILTERS );
 InitCopyGVar( "NUMBERS_PROPERTY_GETTERS", &GC_NUMBERS__PROPERTY__GETTERS );
 InitFopyGVar( "InstallOtherMethod", &GF_InstallOtherMethod );
 InitFopyGVar( "Tester", &GF_Tester );
 InitFopyGVar( "IsPrimeInt", &GF_IsPrimeInt );
 InitFopyGVar( "DeclareOperation", &GF_DeclareOperation );
 InitFopyGVar( "VALUE_GLOBAL", &GF_VALUE__GLOBAL );
 InitFopyGVar( "DeclareAttribute", &GF_DeclareAttribute );
 InitFopyGVar( "InstallMethod", &GF_InstallMethod );
 InitFopyGVar( "PositionSortedOddPositions", &GF_PositionSortedOddPositions );
 InitFopyGVar( "CallFuncList", &GF_CallFuncList );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "GAPROOT/lib/oper1.g:FileName(-6121159)" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/oper1.g:HdlrFunc1(-6121159)" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/oper1.g:NameFunc[1](-6121159)" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/oper1.g:HdlrFunc2(-6121159)" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/oper1.g:NameFunc[2](-6121159)" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/oper1.g:HdlrFunc3(-6121159)" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/oper1.g:NameFunc[3](-6121159)" );
 InitHandlerFunc( HdlrFunc4, "GAPROOT/lib/oper1.g:HdlrFunc4(-6121159)" );
 InitGlobalBag( &(NameFunc[4]), "GAPROOT/lib/oper1.g:NameFunc[4](-6121159)" );
 InitHandlerFunc( HdlrFunc5, "GAPROOT/lib/oper1.g:HdlrFunc5(-6121159)" );
 InitGlobalBag( &(NameFunc[5]), "GAPROOT/lib/oper1.g:NameFunc[5](-6121159)" );
 InitHandlerFunc( HdlrFunc6, "GAPROOT/lib/oper1.g:HdlrFunc6(-6121159)" );
 InitGlobalBag( &(NameFunc[6]), "GAPROOT/lib/oper1.g:NameFunc[6](-6121159)" );
 InitHandlerFunc( HdlrFunc7, "GAPROOT/lib/oper1.g:HdlrFunc7(-6121159)" );
 InitGlobalBag( &(NameFunc[7]), "GAPROOT/lib/oper1.g:NameFunc[7](-6121159)" );
 InitHandlerFunc( HdlrFunc8, "GAPROOT/lib/oper1.g:HdlrFunc8(-6121159)" );
 InitGlobalBag( &(NameFunc[8]), "GAPROOT/lib/oper1.g:NameFunc[8](-6121159)" );
 InitHandlerFunc( HdlrFunc9, "GAPROOT/lib/oper1.g:HdlrFunc9(-6121159)" );
 InitGlobalBag( &(NameFunc[9]), "GAPROOT/lib/oper1.g:NameFunc[9](-6121159)" );
 InitHandlerFunc( HdlrFunc10, "GAPROOT/lib/oper1.g:HdlrFunc10(-6121159)" );
 InitGlobalBag( &(NameFunc[10]), "GAPROOT/lib/oper1.g:NameFunc[10](-6121159)" );
 InitHandlerFunc( HdlrFunc11, "GAPROOT/lib/oper1.g:HdlrFunc11(-6121159)" );
 InitGlobalBag( &(NameFunc[11]), "GAPROOT/lib/oper1.g:NameFunc[11](-6121159)" );
 InitHandlerFunc( HdlrFunc12, "GAPROOT/lib/oper1.g:HdlrFunc12(-6121159)" );
 InitGlobalBag( &(NameFunc[12]), "GAPROOT/lib/oper1.g:NameFunc[12](-6121159)" );
 InitHandlerFunc( HdlrFunc13, "GAPROOT/lib/oper1.g:HdlrFunc13(-6121159)" );
 InitGlobalBag( &(NameFunc[13]), "GAPROOT/lib/oper1.g:NameFunc[13](-6121159)" );
 InitHandlerFunc( HdlrFunc14, "GAPROOT/lib/oper1.g:HdlrFunc14(-6121159)" );
 InitGlobalBag( &(NameFunc[14]), "GAPROOT/lib/oper1.g:NameFunc[14](-6121159)" );
 InitHandlerFunc( HdlrFunc15, "GAPROOT/lib/oper1.g:HdlrFunc15(-6121159)" );
 InitGlobalBag( &(NameFunc[15]), "GAPROOT/lib/oper1.g:NameFunc[15](-6121159)" );
 InitHandlerFunc( HdlrFunc16, "GAPROOT/lib/oper1.g:HdlrFunc16(-6121159)" );
 InitGlobalBag( &(NameFunc[16]), "GAPROOT/lib/oper1.g:NameFunc[16](-6121159)" );
 InitHandlerFunc( HdlrFunc17, "GAPROOT/lib/oper1.g:HdlrFunc17(-6121159)" );
 InitGlobalBag( &(NameFunc[17]), "GAPROOT/lib/oper1.g:NameFunc[17](-6121159)" );
 InitHandlerFunc( HdlrFunc18, "GAPROOT/lib/oper1.g:HdlrFunc18(-6121159)" );
 InitGlobalBag( &(NameFunc[18]), "GAPROOT/lib/oper1.g:NameFunc[18](-6121159)" );
 
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
 FileName = MakeImmString( "GAPROOT/lib/oper1.g" );
 PostRestore(module);
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],0,0,HdlrFunc1);
 SET_ENVI_FUNC( func1, STATE(CurrLVars) );
 CHANGED_BAG( STATE(CurrLVars) );
 body1 = NewBag( T_BODY, sizeof(BodyHeader));
 SET_BODY_FUNC( func1, body1 );
 CHANGED_BAG( func1 );
 CALL_0ARGS( func1 );
 
 /* return success */
 return 0;
 
}

/* <name> returns the description of this module */
static StructInitInfo module = {
 /* type        = */ 2,
 /* name        = */ "GAPROOT/lib/oper1.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ -6121159,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__oper1 ( void )
{
 return &module;
}

/* compiled code ends here */
#endif
