#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include <src/compiled.h>
#define FILE_CRC  "74044960"

/* global variables used in handlers */
static GVar G_IS__FUNCTION;
static Obj  GF_IS__FUNCTION;
static GVar G_IS__IDENTICAL__OBJ;
static Obj  GF_IS__IDENTICAL__OBJ;
static GVar G_AND__FLAGS;
static Obj  GF_AND__FLAGS;
static GVar G_HASH__FLAGS;
static Obj  GF_HASH__FLAGS;
static GVar G_WITH__HIDDEN__IMPS__FLAGS;
static Obj  GF_WITH__HIDDEN__IMPS__FLAGS;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_TRUES__FLAGS;
static Obj  GF_TRUES__FLAGS;
static GVar G_FLAGS__FILTER;
static Obj  GF_FLAGS__FILTER;
static GVar G_WITH__HIDDEN__IMPS__FLAGS__COUNT;
static GVar G_WITH__HIDDEN__IMPS__FLAGS__CACHE__MISS;
static GVar G_WITH__HIDDEN__IMPS__FLAGS__CACHE__HIT;
static GVar G_IMPLICATIONS;
static Obj  GC_IMPLICATIONS;
static GVar G_WITH__IMPS__FLAGS__CACHE;
static Obj  GC_WITH__IMPS__FLAGS__CACHE;
static GVar G_WITH__IMPS__FLAGS__COUNT;
static Obj  GC_WITH__IMPS__FLAGS__COUNT;
static GVar G_WITH__IMPS__FLAGS__CACHE__HIT;
static Obj  GC_WITH__IMPS__FLAGS__CACHE__HIT;
static GVar G_WITH__IMPS__FLAGS__CACHE__MISS;
static Obj  GC_WITH__IMPS__FLAGS__CACHE__MISS;
static GVar G_CLEAR__IMP__CACHE;
static GVar G_BIND__GLOBAL;
static Obj  GF_BIND__GLOBAL;
static GVar G_RANK__FILTERS;
static Obj  GC_RANK__FILTERS;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[5];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self )
{
 Obj t_1 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* WITH_IMPS_FLAGS_CACHE := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 AssGVar( G_WITH__IMPS__FLAGS__CACHE, t_1 );
 
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
 Obj  a_flags )
{
 Obj l_with = 0;
 Obj l_changed = 0;
 Obj l_imp = 0;
 Obj l_hash = 0;
 Obj l_hash2 = 0;
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
 
 /* hash := HASH_FLAGS( flags ) mod 11001; */
 t_3 = GF_HASH__FLAGS;
 t_2 = CALL_1ARGS( t_3, a_flags );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = MOD( t_2, INTOBJ_INT(11001) );
 l_hash = t_1;
 
 /* for i in [ 0 .. 3 ] do */
 for ( t_1 = INTOBJ_INT(0);
       ((Int)t_1) <= ((Int)INTOBJ_INT(3));
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* hash2 := 2 * ((hash + 31 * i) mod 11001) + 1; */
  C_PROD_INTOBJS( t_6, INTOBJ_INT(31), l_i )
  C_SUM_FIA( t_5, l_hash, t_6 )
  t_4 = MOD( t_5, INTOBJ_INT(11001) );
  C_PROD_FIA( t_3, INTOBJ_INT(2), t_4 )
  C_SUM_FIA( t_2, t_3, INTOBJ_INT(1) )
  l_hash2 = t_2;
  
  /* if IsBound( WITH_IMPS_FLAGS_CACHE[hash2] ) then */
  t_4 = GC_WITH__IMPS__FLAGS__CACHE;
  CHECK_BOUND( t_4, "WITH_IMPS_FLAGS_CACHE" )
  CHECK_INT_POS( l_hash2 )
  t_3 = C_ISB_LIST( t_4, l_hash2 );
  t_2 = (Obj)(UInt)(t_3 != False);
  if ( t_2 ) {
   
   /* if IS_IDENTICAL_OBJ( WITH_IMPS_FLAGS_CACHE[hash2], flags ) then */
   t_4 = GF_IS__IDENTICAL__OBJ;
   t_6 = GC_WITH__IMPS__FLAGS__CACHE;
   CHECK_BOUND( t_6, "WITH_IMPS_FLAGS_CACHE" )
   C_ELM_LIST_FPL( t_5, t_6, l_hash2 )
   t_3 = CALL_2ARGS( t_4, t_5, a_flags );
   CHECK_FUNC_RESULT( t_3 )
   CHECK_BOOL( t_3 )
   t_2 = (Obj)(UInt)(t_3 != False);
   if ( t_2 ) {
    
    /* WITH_IMPS_FLAGS_CACHE_HIT := WITH_IMPS_FLAGS_CACHE_HIT + 1; */
    t_3 = GC_WITH__IMPS__FLAGS__CACHE__HIT;
    CHECK_BOUND( t_3, "WITH_IMPS_FLAGS_CACHE_HIT" )
    C_SUM_FIA( t_2, t_3, INTOBJ_INT(1) )
    AssGVar( G_WITH__IMPS__FLAGS__CACHE__HIT, t_2 );
    
    /* return WITH_IMPS_FLAGS_CACHE[hash2 + 1]; */
    t_3 = GC_WITH__IMPS__FLAGS__CACHE;
    CHECK_BOUND( t_3, "WITH_IMPS_FLAGS_CACHE" )
    C_SUM_FIA( t_4, l_hash2, INTOBJ_INT(1) )
    CHECK_INT_POS( t_4 )
    C_ELM_LIST_FPL( t_2, t_3, t_4 )
    RES_BRK_CURR_STAT();
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_2;
    
   }
   /* fi */
   
  }
  
  /* else */
  else {
   
   /* break; */
   break;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* if i = 3 then */
 t_1 = (Obj)(UInt)(((Int)l_i) == ((Int)INTOBJ_INT(3)));
 if ( t_1 ) {
  
  /* WITH_IMPS_FLAGS_COUNT := (WITH_IMPS_FLAGS_COUNT + 1) mod 4; */
  t_3 = GC_WITH__IMPS__FLAGS__COUNT;
  CHECK_BOUND( t_3, "WITH_IMPS_FLAGS_COUNT" )
  C_SUM_FIA( t_2, t_3, INTOBJ_INT(1) )
  t_1 = MOD( t_2, INTOBJ_INT(4) );
  AssGVar( G_WITH__IMPS__FLAGS__COUNT, t_1 );
  
  /* i := WITH_IMPS_FLAGS_COUNT; */
  t_1 = GC_WITH__IMPS__FLAGS__COUNT;
  CHECK_BOUND( t_1, "WITH_IMPS_FLAGS_COUNT" )
  l_i = t_1;
  
  /* hash2 := 2 * ((hash + 31 * i) mod 11001) + 1; */
  C_PROD_FIA( t_5, INTOBJ_INT(31), l_i )
  C_SUM_FIA( t_4, l_hash, t_5 )
  t_3 = MOD( t_4, INTOBJ_INT(11001) );
  C_PROD_FIA( t_2, INTOBJ_INT(2), t_3 )
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  l_hash2 = t_1;
  
 }
 /* fi */
 
 /* WITH_IMPS_FLAGS_CACHE_MISS := WITH_IMPS_FLAGS_CACHE_MISS + 1; */
 t_2 = GC_WITH__IMPS__FLAGS__CACHE__MISS;
 CHECK_BOUND( t_2, "WITH_IMPS_FLAGS_CACHE_MISS" )
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_WITH__IMPS__FLAGS__CACHE__MISS, t_1 );
 
 /* with := flags; */
 l_with = a_flags;
 
 /* changed := true; */
 t_1 = True;
 l_changed = t_1;
 
 /* while changed od */
 while ( 1 ) {
  t_1 = (Obj)(UInt)(l_changed != False);
  if ( ! t_1 ) break;
  
  /* changed := false; */
  t_1 = False;
  l_changed = t_1;
  
  /* for imp in IMPLICATIONS do */
  t_4 = GC_IMPLICATIONS;
  CHECK_BOUND( t_4, "IMPLICATIONS" )
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
   l_imp = t_2;
   
   /* if IS_SUBSET_FLAGS( with, imp[2] ) and not IS_SUBSET_FLAGS( with, imp[1] ) then */
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_LIST_FPL( t_9, l_imp, INTOBJ_INT(2) )
   t_7 = CALL_2ARGS( t_8, l_with, t_9 );
   CHECK_FUNC_RESULT( t_7 )
   CHECK_BOOL( t_7 )
   t_6 = (Obj)(UInt)(t_7 != False);
   t_5 = t_6;
   if ( t_5 ) {
    t_10 = GF_IS__SUBSET__FLAGS;
    C_ELM_LIST_FPL( t_11, l_imp, INTOBJ_INT(1) )
    t_9 = CALL_2ARGS( t_10, l_with, t_11 );
    CHECK_FUNC_RESULT( t_9 )
    CHECK_BOOL( t_9 )
    t_8 = (Obj)(UInt)(t_9 != False);
    t_7 = (Obj)(UInt)( ! ((Int)t_8) );
    t_5 = t_7;
   }
   if ( t_5 ) {
    
    /* with := AND_FLAGS( with, imp[1] ); */
    t_6 = GF_AND__FLAGS;
    C_ELM_LIST_FPL( t_7, l_imp, INTOBJ_INT(1) )
    t_5 = CALL_2ARGS( t_6, l_with, t_7 );
    CHECK_FUNC_RESULT( t_5 )
    l_with = t_5;
    
    /* changed := true; */
    t_5 = True;
    l_changed = t_5;
    
   }
   /* fi */
   
  }
  /* od */
  
 }
 /* od */
 
 /* WITH_IMPS_FLAGS_CACHE[hash2] := flags; */
 t_1 = GC_WITH__IMPS__FLAGS__CACHE;
 CHECK_BOUND( t_1, "WITH_IMPS_FLAGS_CACHE" )
 CHECK_INT_POS( l_hash2 )
 C_ASS_LIST_FPL( t_1, l_hash2, a_flags )
 
 /* WITH_IMPS_FLAGS_CACHE[hash2 + 1] := with; */
 t_1 = GC_WITH__IMPS__FLAGS__CACHE;
 CHECK_BOUND( t_1, "WITH_IMPS_FLAGS_CACHE" )
 C_SUM_FIA( t_2, l_hash2, INTOBJ_INT(1) )
 CHECK_INT_POS( t_2 )
 C_ASS_LIST_FPL( t_1, t_2, l_with )
 
 /* return with; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_with;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 4 */
static Obj  HdlrFunc4 (
 Obj  self,
 Obj  a_filter )
{
 Obj l_rank = 0;
 Obj l_flags = 0;
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
 
 /* rank := 0; */
 l_rank = INTOBJ_INT(0);
 
 /* if IS_FUNCTION( filter ) then */
 t_3 = GF_IS__FUNCTION;
 t_2 = CALL_1ARGS( t_3, a_filter );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* flags := FLAGS_FILTER( filter ); */
  t_2 = GF_FLAGS__FILTER;
  t_1 = CALL_1ARGS( t_2, a_filter );
  CHECK_FUNC_RESULT( t_1 )
  l_flags = t_1;
  
 }
 
 /* else */
 else {
  
  /* flags := filter; */
  l_flags = a_filter;
  
 }
 /* fi */
 
 /* for i in TRUES_FLAGS( WITH_HIDDEN_IMPS_FLAGS( flags ) ) do */
 t_5 = GF_TRUES__FLAGS;
 t_7 = GF_WITH__HIDDEN__IMPS__FLAGS;
 t_6 = CALL_1ARGS( t_7, l_flags );
 CHECK_FUNC_RESULT( t_6 )
 t_4 = CALL_1ARGS( t_5, t_6 );
 CHECK_FUNC_RESULT( t_4 )
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
  
  /* if IsBound( RANK_FILTERS[i] ) then */
  t_7 = GC_RANK__FILTERS;
  CHECK_BOUND( t_7, "RANK_FILTERS" )
  CHECK_INT_POS( l_i )
  t_6 = C_ISB_LIST( t_7, l_i );
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* rank := rank + RANK_FILTERS[i]; */
   t_7 = GC_RANK__FILTERS;
   CHECK_BOUND( t_7, "RANK_FILTERS" )
   C_ELM_LIST_FPL( t_6, t_7, l_i )
   C_SUM_FIA( t_5, l_rank, t_6 )
   l_rank = t_5;
   
  }
  
  /* else */
  else {
   
   /* rank := rank + 1; */
   C_SUM_FIA( t_5, l_rank, INTOBJ_INT(1) )
   l_rank = t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return rank; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_rank;
 
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* WITH_HIDDEN_IMPS_FLAGS_COUNT := 0; */
 AssGVar( G_WITH__HIDDEN__IMPS__FLAGS__COUNT, INTOBJ_INT(0) );
 
 /* WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS := 0; */
 AssGVar( G_WITH__HIDDEN__IMPS__FLAGS__CACHE__MISS, INTOBJ_INT(0) );
 
 /* WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT := 0; */
 AssGVar( G_WITH__HIDDEN__IMPS__FLAGS__CACHE__HIT, INTOBJ_INT(0) );
 
 /* IMPLICATIONS := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 AssGVar( G_IMPLICATIONS, t_1 );
 
 /* WITH_IMPS_FLAGS_CACHE := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 AssGVar( G_WITH__IMPS__FLAGS__CACHE, t_1 );
 
 /* WITH_IMPS_FLAGS_COUNT := 0; */
 AssGVar( G_WITH__IMPS__FLAGS__COUNT, INTOBJ_INT(0) );
 
 /* WITH_IMPS_FLAGS_CACHE_HIT := 0; */
 AssGVar( G_WITH__IMPS__FLAGS__CACHE__HIT, INTOBJ_INT(0) );
 
 /* WITH_IMPS_FLAGS_CACHE_MISS := 0; */
 AssGVar( G_WITH__IMPS__FLAGS__CACHE__MISS, INTOBJ_INT(0) );
 
 /* Unbind( CLEAR_IMP_CACHE ); */
 AssGVar( G_CLEAR__IMP__CACHE, 0 );
 
 /* BIND_GLOBAL( "CLEAR_IMP_CACHE", function (  )
      WITH_IMPS_FLAGS_CACHE := [  ];
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "CLEAR_IMP_CACHE" );
 t_3 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 38);
 SET_ENDLINE_BODY(t_4, 40);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "WITH_IMPS_FLAGS", function ( flags )
      local with, changed, imp, hash, hash2, i;
      hash := HASH_FLAGS( flags ) mod 11001;
      for i in [ 0 .. 3 ] do
          hash2 := 2 * ((hash + 31 * i) mod 11001) + 1;
          if IsBound( WITH_IMPS_FLAGS_CACHE[hash2] ) then
              if IS_IDENTICAL_OBJ( WITH_IMPS_FLAGS_CACHE[hash2], flags ) then
                  WITH_IMPS_FLAGS_CACHE_HIT := WITH_IMPS_FLAGS_CACHE_HIT + 1;
                  return WITH_IMPS_FLAGS_CACHE[hash2 + 1];
              fi;
          else
              break;
          fi;
      od;
      if i = 3 then
          WITH_IMPS_FLAGS_COUNT := (WITH_IMPS_FLAGS_COUNT + 1) mod 4;
          i := WITH_IMPS_FLAGS_COUNT;
          hash2 := 2 * ((hash + 31 * i) mod 11001) + 1;
      fi;
      WITH_IMPS_FLAGS_CACHE_MISS := WITH_IMPS_FLAGS_CACHE_MISS + 1;
      with := flags;
      changed := true;
      while changed do
          changed := false;
          for imp in IMPLICATIONS do
              if IS_SUBSET_FLAGS( with, imp[2] ) and not IS_SUBSET_FLAGS( with, imp[1] ) then
                  with := AND_FLAGS( with, imp[1] );
                  changed := true;
              fi;
          od;
      od;
      WITH_IMPS_FLAGS_CACHE[hash2] := flags;
      WITH_IMPS_FLAGS_CACHE[hash2 + 1] := with;
      return with;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "WITH_IMPS_FLAGS" );
 t_3 = NewFunction( NameFunc[3], 1, 0, HdlrFunc3 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 43);
 SET_ENDLINE_BODY(t_4, 82);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "RankFilter", function ( filter )
      local rank, flags, i;
      rank := 0;
      if IS_FUNCTION( filter ) then
          flags := FLAGS_FILTER( filter );
      else
          flags := filter;
      fi;
      for i in TRUES_FLAGS( WITH_HIDDEN_IMPS_FLAGS( flags ) ) do
          if IsBound( RANK_FILTERS[i] ) then
              rank := rank + RANK_FILTERS[i];
          else
              rank := rank + 1;
          fi;
      od;
      return rank;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 t_2 = MakeString( "RankFilter" );
 t_3 = NewFunction( NameFunc[4], 1, 0, HdlrFunc4 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_4, 91);
 SET_ENDLINE_BODY(t_4, 108);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
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

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_IS__FUNCTION = GVarName( "IS_FUNCTION" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_AND__FLAGS = GVarName( "AND_FLAGS" );
 G_HASH__FLAGS = GVarName( "HASH_FLAGS" );
 G_WITH__HIDDEN__IMPS__FLAGS = GVarName( "WITH_HIDDEN_IMPS_FLAGS" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_TRUES__FLAGS = GVarName( "TRUES_FLAGS" );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 G_WITH__HIDDEN__IMPS__FLAGS__COUNT = GVarName( "WITH_HIDDEN_IMPS_FLAGS_COUNT" );
 G_WITH__HIDDEN__IMPS__FLAGS__CACHE__MISS = GVarName( "WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS" );
 G_WITH__HIDDEN__IMPS__FLAGS__CACHE__HIT = GVarName( "WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT" );
 G_IMPLICATIONS = GVarName( "IMPLICATIONS" );
 G_WITH__IMPS__FLAGS__CACHE = GVarName( "WITH_IMPS_FLAGS_CACHE" );
 G_WITH__IMPS__FLAGS__COUNT = GVarName( "WITH_IMPS_FLAGS_COUNT" );
 G_WITH__IMPS__FLAGS__CACHE__HIT = GVarName( "WITH_IMPS_FLAGS_CACHE_HIT" );
 G_WITH__IMPS__FLAGS__CACHE__MISS = GVarName( "WITH_IMPS_FLAGS_CACHE_MISS" );
 G_CLEAR__IMP__CACHE = GVarName( "CLEAR_IMP_CACHE" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_RANK__FILTERS = GVarName( "RANK_FILTERS" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 NameFunc[1] = 0;
 NameFunc[2] = 0;
 NameFunc[3] = 0;
 NameFunc[4] = 0;
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "IS_FUNCTION", &GF_IS__FUNCTION );
 InitFopyGVar( "IS_IDENTICAL_OBJ", &GF_IS__IDENTICAL__OBJ );
 InitFopyGVar( "AND_FLAGS", &GF_AND__FLAGS );
 InitFopyGVar( "HASH_FLAGS", &GF_HASH__FLAGS );
 InitFopyGVar( "WITH_HIDDEN_IMPS_FLAGS", &GF_WITH__HIDDEN__IMPS__FLAGS );
 InitFopyGVar( "IS_SUBSET_FLAGS", &GF_IS__SUBSET__FLAGS );
 InitFopyGVar( "TRUES_FLAGS", &GF_TRUES__FLAGS );
 InitFopyGVar( "FLAGS_FILTER", &GF_FLAGS__FILTER );
 InitCopyGVar( "IMPLICATIONS", &GC_IMPLICATIONS );
 InitCopyGVar( "WITH_IMPS_FLAGS_CACHE", &GC_WITH__IMPS__FLAGS__CACHE );
 InitCopyGVar( "WITH_IMPS_FLAGS_COUNT", &GC_WITH__IMPS__FLAGS__COUNT );
 InitCopyGVar( "WITH_IMPS_FLAGS_CACHE_HIT", &GC_WITH__IMPS__FLAGS__CACHE__HIT );
 InitCopyGVar( "WITH_IMPS_FLAGS_CACHE_MISS", &GC_WITH__IMPS__FLAGS__CACHE__MISS );
 InitFopyGVar( "BIND_GLOBAL", &GF_BIND__GLOBAL );
 InitCopyGVar( "RANK_FILTERS", &GC_RANK__FILTERS );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "GAPROOT/lib/filter1.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/filter1.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/filter1.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/filter1.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/filter1.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/filter1.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/filter1.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "GAPROOT/lib/filter1.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "GAPROOT/lib/filter1.g:NameFunc[4]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "GAPROOT/lib/filter1.g" );
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
 /* type        = */ MODULE_STATIC,
 /* name        = */ "GAPROOT/lib/filter1.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 74044960,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__filter1 ( void )
{
 return &module;
}

/* compiled code ends here */
#endif
