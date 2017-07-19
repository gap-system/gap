#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include "compiled.h"

/* global variables used in handlers */
static GVar G_ASS__GVAR;
static Obj  GF_ASS__GVAR;
static GVar G_VAL__GVAR;
static Obj  GF_VAL__GVAR;
static GVar G_QUO__INT;
static Obj  GF_QUO__INT;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_MakeThreadLocal;
static Obj  GF_MakeThreadLocal;
static GVar G_FixedAtomicList;
static Obj  GF_FixedAtomicList;
static GVar G_ATOMIC__ADDITION;
static Obj  GF_ATOMIC__ADDITION;
static GVar G_BIND__GLOBAL;
static Obj  GF_BIND__GLOBAL;
static GVar G_MakeLiteral;
static Obj  GF_MakeLiteral;
static GVar G___R__N;
static Obj  GC___R__N;
static GVar G___R__X;
static Obj  GC___R__X;
static GVar G_RANDOM__SEED__COUNTER;
static Obj  GC_RANDOM__SEED__COUNTER;
static GVar G_R__228;
static Obj  GC_R__228;
static GVar G_RANDOM__LIST;
static GVar G_RANDOM__SEED;
static Obj  GF_RANDOM__SEED;
static GVar G_GET__RANDOM__SEED__COUNTER;
static Obj  GF_GET__RANDOM__SEED__COUNTER;
static GVar G_BindThreadLocalConstructor;
static Obj  GF_BindThreadLocalConstructor;
static GVar G_RANDOM__SEED__CONSTRUCTOR;
static Obj  GC_RANDOM__SEED__CONSTRUCTOR;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[6];
static Obj  NamsFunc[6];
static Int  NargFunc[6];
static Obj  DefaultName;
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self )
{
 Obj l_r = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* r := ATOMIC_ADDITION( RANDOM_SEED_COUNTER, 1, 1 ); */
 t_2 = GF_ATOMIC__ADDITION;
 t_3 = GC_RANDOM__SEED__COUNTER;
 CHECK_BOUND( t_3, "RANDOM_SEED_COUNTER" )
 t_1 = CALL_3ARGS( t_2, t_3, INTOBJ_INT(1), INTOBJ_INT(1) );
 CHECK_FUNC_RESULT( t_1 )
 l_r = t_1;
 
 /* return r; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_r;
 
 /* return; */
 RES_BRK_CURR_STAT();
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self,
 Obj  a_list )
{
 Obj l_r__n = 0;
 Obj l_r__x = 0;
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
 
 /* r_n := VAL_GVAR( _R_N ); */
 t_2 = GF_VAL__GVAR;
 t_3 = GC___R__N;
 CHECK_BOUND( t_3, "_R_N" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_r__n = t_1;
 
 /* r_x := VAL_GVAR( _R_X ); */
 t_2 = GF_VAL__GVAR;
 t_3 = GC___R__X;
 CHECK_BOUND( t_3, "_R_X" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_r__x = t_1;
 
 /* ASS_GVAR( _R_N, r_n mod 55 + 1 ); */
 t_1 = GF_ASS__GVAR;
 t_2 = GC___R__N;
 CHECK_BOUND( t_2, "_R_N" )
 t_4 = MOD( l_r__n, INTOBJ_INT(55) );
 C_SUM_FIA( t_3, t_4, INTOBJ_INT(1) )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* r_x[r_n] := (r_x[r_n] + r_x[((r_n + 30) mod 55 + 1)]) mod R_228; */
 CHECK_INT_POS( l_r__n )
 C_ELM_LIST_FPL( t_3, l_r__x, l_r__n )
 C_SUM_FIA( t_7, l_r__n, INTOBJ_INT(30) )
 t_6 = MOD( t_7, INTOBJ_INT(55) );
 C_SUM_FIA( t_5, t_6, INTOBJ_INT(1) )
 CHECK_INT_POS( t_5 )
 C_ELM_LIST_FPL( t_4, l_r__x, t_5 )
 C_SUM_FIA( t_2, t_3, t_4 )
 t_3 = GC_R__228;
 CHECK_BOUND( t_3, "R_228" )
 t_1 = MOD( t_2, t_3 );
 C_ASS_LIST_FPL( l_r__x, l_r__n, t_1 )
 
 /* return list[QUO_INT( r_x[r_n] * LEN_LIST( list ), R_228 ) + 1]; */
 t_4 = GF_QUO__INT;
 C_ELM_LIST_FPL( t_6, l_r__x, l_r__n )
 t_8 = GF_LEN__LIST;
 t_7 = CALL_1ARGS( t_8, a_list );
 CHECK_FUNC_RESULT( t_7 )
 C_PROD_FIA( t_5, t_6, t_7 )
 t_6 = GC_R__228;
 CHECK_BOUND( t_6, "R_228" )
 t_3 = CALL_2ARGS( t_4, t_5, t_6 );
 CHECK_FUNC_RESULT( t_3 )
 C_SUM_FIA( t_2, t_3, INTOBJ_INT(1) )
 CHECK_INT_POS( t_2 )
 C_ELM_LIST_FPL( t_1, a_list, t_2 )
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
 Obj  a_n )
{
 Obj l_i = 0;
 Obj l_r__n = 0;
 Obj l_r__x = 0;
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
 
 /* ASS_GVAR( _R_N, 1 ); */
 t_1 = GF_ASS__GVAR;
 t_2 = GC___R__N;
 CHECK_BOUND( t_2, "_R_N" )
 CALL_2ARGS( t_1, t_2, INTOBJ_INT(1) );
 
 /* ASS_GVAR( _R_X, [ n mod R_228 ] ); */
 t_1 = GF_ASS__GVAR;
 t_2 = GC___R__X;
 CHECK_BOUND( t_2, "_R_X" )
 t_3 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_3, 1 );
 t_5 = GC_R__228;
 CHECK_BOUND( t_5, "R_228" )
 t_4 = MOD( a_n, t_5 );
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* r_n := VAL_GVAR( _R_N ); */
 t_2 = GF_VAL__GVAR;
 t_3 = GC___R__N;
 CHECK_BOUND( t_3, "_R_N" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_r__n = t_1;
 
 /* r_x := VAL_GVAR( _R_X ); */
 t_2 = GF_VAL__GVAR;
 t_3 = GC___R__X;
 CHECK_BOUND( t_3, "_R_X" )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_r__x = t_1;
 
 /* for i in [ 2 .. 55 ] do */
 for ( t_1 = INTOBJ_INT(2);
       ((Int)t_1) <= ((Int)INTOBJ_INT(55));
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* r_x[i] := (1664525 * r_x[(i - 1)] + 1) mod R_228; */
  C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_r__x, t_6 )
  C_PROD_FIA( t_4, INTOBJ_INT(1664525), t_5 )
  C_SUM_FIA( t_3, t_4, INTOBJ_INT(1) )
  t_4 = GC_R__228;
  CHECK_BOUND( t_4, "R_228" )
  t_2 = MOD( t_3, t_4 );
  C_ASS_LIST_FPL( l_r__x, l_i, t_2 )
  
 }
 /* od */
 
 /* for i in [ 1 .. 99 ] do */
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)INTOBJ_INT(99));
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* ASS_GVAR( _R_N, r_n mod 55 + 1 ); */
  t_2 = GF_ASS__GVAR;
  t_3 = GC___R__N;
  CHECK_BOUND( t_3, "_R_N" )
  t_5 = MOD( l_r__n, INTOBJ_INT(55) );
  C_SUM_FIA( t_4, t_5, INTOBJ_INT(1) )
  CALL_2ARGS( t_2, t_3, t_4 );
  
  /* r_x[r_n] := (r_x[r_n] + r_x[((r_n + 30) mod 55 + 1)]) mod R_228; */
  CHECK_INT_POS( l_r__n )
  C_ELM_LIST_FPL( t_4, l_r__x, l_r__n )
  C_SUM_FIA( t_8, l_r__n, INTOBJ_INT(30) )
  t_7 = MOD( t_8, INTOBJ_INT(55) );
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  CHECK_INT_POS( t_6 )
  C_ELM_LIST_FPL( t_5, l_r__x, t_6 )
  C_SUM_FIA( t_3, t_4, t_5 )
  t_4 = GC_R__228;
  CHECK_BOUND( t_4, "R_228" )
  t_2 = MOD( t_3, t_4 );
  C_ASS_LIST_FPL( l_r__x, l_r__n, t_2 )
  
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

/* handler for function 5 */
static Obj  HdlrFunc5 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* ASS_GVAR( _R_N, 1 ); */
 t_1 = GF_ASS__GVAR;
 t_2 = GC___R__N;
 CHECK_BOUND( t_2, "_R_N" )
 CALL_2ARGS( t_1, t_2, INTOBJ_INT(1) );
 
 /* RANDOM_SEED( GET_RANDOM_SEED_COUNTER(  ) ); */
 t_1 = GF_RANDOM__SEED;
 t_3 = GF_GET__RANDOM__SEED__COUNTER;
 t_2 = CALL_0ARGS( t_3 );
 CHECK_FUNC_RESULT( t_2 )
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
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* BIND_GLOBAL( "_R_N", MakeLiteral( "R_N" ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 4, "_R_N" );
 t_4 = GF_MakeLiteral;
 C_NEW_STRING( t_5, 3, "R_N" );
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "_R_X", MakeLiteral( "R_X" ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 4, "_R_X" );
 t_4 = GF_MakeLiteral;
 C_NEW_STRING( t_5, 3, "R_X" );
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* MakeThreadLocal( _R_N ); */
 t_1 = GF_MakeThreadLocal;
 t_2 = GC___R__N;
 CHECK_BOUND( t_2, "_R_N" )
 CALL_1ARGS( t_1, t_2 );
 
 /* MakeThreadLocal( _R_X ); */
 t_1 = GF_MakeThreadLocal;
 t_2 = GC___R__X;
 CHECK_BOUND( t_2, "_R_X" )
 CALL_1ARGS( t_1, t_2 );
 
 /* BIND_GLOBAL( "RANDOM_SEED_COUNTER", FixedAtomicList( 1, 0 ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 19, "RANDOM_SEED_COUNTER" );
 t_4 = GF_FixedAtomicList;
 t_3 = CALL_2ARGS( t_4, INTOBJ_INT(1), INTOBJ_INT(0) );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "GET_RANDOM_SEED_COUNTER", function (  )
      local  r;
      r := ATOMIC_ADDITION( RANDOM_SEED_COUNTER, 1, 1 );
      return r;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 23, "GET_RANDOM_SEED_COUNTER" );
 t_3 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(25));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(29));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* R_228 := 2 ^ 28; */
 t_1 = POW( INTOBJ_INT(2), INTOBJ_INT(28) );
 AssGVar( G_R__228, t_1 );
 
 /* RANDOM_LIST := function ( list )
      local  r_n, r_x;
      r_n := VAL_GVAR( _R_N );
      r_x := VAL_GVAR( _R_X );
      ASS_GVAR( _R_N, r_n mod 55 + 1 );
      r_x[r_n] := (r_x[r_n] + r_x[((r_n + 30) mod 55 + 1)]) mod R_228;
      return list[QUO_INT( r_x[r_n] * LEN_LIST( list ), R_228 ) + 1];
  end; */
 t_1 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3 );
 ENVI_FUNC( t_1 ) = STATE(CurrLVars);
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(34));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(41));
 SET_FILENAME_BODY(t_2, FileName);
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_RANDOM__LIST, t_1 );
 
 /* RANDOM_SEED := function ( n )
      local  i, r_n, r_x;
      ASS_GVAR( _R_N, 1 );
      ASS_GVAR( _R_X, [ n mod R_228 ] );
      r_n := VAL_GVAR( _R_N );
      r_x := VAL_GVAR( _R_X );
      for i  in [ 2 .. 55 ]  do
          r_x[i] := (1664525 * r_x[(i - 1)] + 1) mod R_228;
      od;
      for i  in [ 1 .. 99 ]  do
          ASS_GVAR( _R_N, r_n mod 55 + 1 );
          r_x[r_n] := (r_x[r_n] + r_x[((r_n + 30) mod 55 + 1)]) mod R_228;
      od;
      return;
  end; */
 t_1 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4 );
 ENVI_FUNC( t_1 ) = STATE(CurrLVars);
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_2, INTOBJ_INT(43));
 SET_ENDLINE_BODY(t_2, INTOBJ_INT(55));
 SET_FILENAME_BODY(t_2, FileName);
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_RANDOM__SEED, t_1 );
 
 /* BIND_GLOBAL( "RANDOM_SEED_CONSTRUCTOR", function (  )
      ASS_GVAR( _R_N, 1 );
      RANDOM_SEED( GET_RANDOM_SEED_COUNTER(  ) );
      return;
  end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 23, "RANDOM_SEED_CONSTRUCTOR" );
 t_3 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5 );
 ENVI_FUNC( t_3 ) = STATE(CurrLVars);
 t_4 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 SET_STARTLINE_BODY(t_4, INTOBJ_INT(57));
 SET_ENDLINE_BODY(t_4, INTOBJ_INT(60));
 SET_FILENAME_BODY(t_4, FileName);
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( STATE(CurrLVars) );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BindThreadLocalConstructor( _R_N, RANDOM_SEED_CONSTRUCTOR ); */
 t_1 = GF_BindThreadLocalConstructor;
 t_2 = GC___R__N;
 CHECK_BOUND( t_2, "_R_N" )
 t_3 = GC_RANDOM__SEED__CONSTRUCTOR;
 CHECK_BOUND( t_3, "RANDOM_SEED_CONSTRUCTOR" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BindThreadLocalConstructor( _R_X, RANDOM_SEED_CONSTRUCTOR ); */
 t_1 = GF_BindThreadLocalConstructor;
 t_2 = GC___R__X;
 CHECK_BOUND( t_2, "_R_X" )
 t_3 = GC_RANDOM__SEED__CONSTRUCTOR;
 CHECK_BOUND( t_3, "RANDOM_SEED_CONSTRUCTOR" )
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
 InitFopyGVar( "ASS_GVAR", &GF_ASS__GVAR );
 InitFopyGVar( "VAL_GVAR", &GF_VAL__GVAR );
 InitFopyGVar( "QUO_INT", &GF_QUO__INT );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitFopyGVar( "MakeThreadLocal", &GF_MakeThreadLocal );
 InitFopyGVar( "FixedAtomicList", &GF_FixedAtomicList );
 InitFopyGVar( "ATOMIC_ADDITION", &GF_ATOMIC__ADDITION );
 InitFopyGVar( "BIND_GLOBAL", &GF_BIND__GLOBAL );
 InitFopyGVar( "MakeLiteral", &GF_MakeLiteral );
 InitCopyGVar( "_R_N", &GC___R__N );
 InitCopyGVar( "_R_X", &GC___R__X );
 InitCopyGVar( "RANDOM_SEED_COUNTER", &GC_RANDOM__SEED__COUNTER );
 InitCopyGVar( "R_228", &GC_R__228 );
 InitFopyGVar( "RANDOM_SEED", &GF_RANDOM__SEED );
 InitFopyGVar( "GET_RANDOM_SEED_COUNTER", &GF_GET__RANDOM__SEED__COUNTER );
 InitFopyGVar( "BindThreadLocalConstructor", &GF_BindThreadLocalConstructor );
 InitCopyGVar( "RANDOM_SEED_CONSTRUCTOR", &GC_RANDOM__SEED__CONSTRUCTOR );
 
 /* information for the functions */
 InitGlobalBag( &DefaultName, "GAPROOT/lib/random.g:DefaultName(-107735305)" );
 InitGlobalBag( &FileName, "GAPROOT/lib/random.g:FileName(-107735305)" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/random.g:HdlrFunc1(-107735305)" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/random.g:NameFunc[1](-107735305)" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/random.g:HdlrFunc2(-107735305)" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/random.g:NameFunc[2](-107735305)" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/random.g:HdlrFunc3(-107735305)" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/random.g:NameFunc[3](-107735305)" );
 InitHandlerFunc( HdlrFunc4, "GAPROOT/lib/random.g:HdlrFunc4(-107735305)" );
 InitGlobalBag( &(NameFunc[4]), "GAPROOT/lib/random.g:NameFunc[4](-107735305)" );
 InitHandlerFunc( HdlrFunc5, "GAPROOT/lib/random.g:HdlrFunc5(-107735305)" );
 InitGlobalBag( &(NameFunc[5]), "GAPROOT/lib/random.g:NameFunc[5](-107735305)" );
 
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
 G_ASS__GVAR = GVarName( "ASS_GVAR" );
 G_VAL__GVAR = GVarName( "VAL_GVAR" );
 G_QUO__INT = GVarName( "QUO_INT" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_MakeThreadLocal = GVarName( "MakeThreadLocal" );
 G_FixedAtomicList = GVarName( "FixedAtomicList" );
 G_ATOMIC__ADDITION = GVarName( "ATOMIC_ADDITION" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_MakeLiteral = GVarName( "MakeLiteral" );
 G___R__N = GVarName( "_R_N" );
 G___R__X = GVarName( "_R_X" );
 G_RANDOM__SEED__COUNTER = GVarName( "RANDOM_SEED_COUNTER" );
 G_R__228 = GVarName( "R_228" );
 G_RANDOM__LIST = GVarName( "RANDOM_LIST" );
 G_RANDOM__SEED = GVarName( "RANDOM_SEED" );
 G_GET__RANDOM__SEED__COUNTER = GVarName( "GET_RANDOM_SEED_COUNTER" );
 G_BindThreadLocalConstructor = GVarName( "BindThreadLocalConstructor" );
 G_RANDOM__SEED__CONSTRUCTOR = GVarName( "RANDOM_SEED_CONSTRUCTOR" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" );
 C_NEW_STRING( FileName, 20, "GAPROOT/lib/random.g" );
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 0;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 1;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 1;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 0;
 
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
 G_ASS__GVAR = GVarName( "ASS_GVAR" );
 G_VAL__GVAR = GVarName( "VAL_GVAR" );
 G_QUO__INT = GVarName( "QUO_INT" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_MakeThreadLocal = GVarName( "MakeThreadLocal" );
 G_FixedAtomicList = GVarName( "FixedAtomicList" );
 G_ATOMIC__ADDITION = GVarName( "ATOMIC_ADDITION" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_MakeLiteral = GVarName( "MakeLiteral" );
 G___R__N = GVarName( "_R_N" );
 G___R__X = GVarName( "_R_X" );
 G_RANDOM__SEED__COUNTER = GVarName( "RANDOM_SEED_COUNTER" );
 G_R__228 = GVarName( "R_228" );
 G_RANDOM__LIST = GVarName( "RANDOM_LIST" );
 G_RANDOM__SEED = GVarName( "RANDOM_SEED" );
 G_GET__RANDOM__SEED__COUNTER = GVarName( "GET_RANDOM_SEED_COUNTER" );
 G_BindThreadLocalConstructor = GVarName( "BindThreadLocalConstructor" );
 G_RANDOM__SEED__CONSTRUCTOR = GVarName( "RANDOM_SEED_CONSTRUCTOR" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 0;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 1;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 1;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 0;
 
 /* return success */
 return 0;
 
}


/* <name> returns the description of this module */
static StructInitInfo module = {
 /* type        = */ 2,
 /* name        = */ "GAPROOT/lib/random.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ -107735305,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__random ( void )
{
 return &module;
}

/* compiled code ends here */
#endif
