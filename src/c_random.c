#ifndef AVOID_PRECOMPILED
/* C file produced by GAC */
#include "compiled.h"

/* global variables used in handlers */
static GVar G_QUO__INT;
static Obj  GF_QUO__INT;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_R__N;
static Obj  GC_R__N;
static GVar G_R__X;
static Obj  GC_R__X;
static GVar G_R__228;
static Obj  GC_R__228;
static GVar G_RANDOM__LIST;
static GVar G_RANDOM__SEED;
static Obj  GF_RANDOM__SEED;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[4];
static Obj  NamsFunc[4];
static Int  NargFunc[4];
static Obj  DefaultName;
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_list )
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
 
 /* R_N := R_N mod 55 + 1; */
 t_3 = GC_R__N;
 CHECK_BOUND( t_3, "R_N" )
 t_2 = MOD( t_3, INTOBJ_INT(55) );
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_R__N, t_1 );
 
 /* R_X[R_N] := (R_X[R_N] + R_X[((R_N + 30) mod 55 + 1)]) mod R_228; */
 t_1 = GC_R__X;
 CHECK_BOUND( t_1, "R_X" )
 t_2 = GC_R__N;
 CHECK_BOUND( t_2, "R_N" )
 CHECK_INT_POS( t_2 )
 t_6 = GC_R__X;
 CHECK_BOUND( t_6, "R_X" )
 t_7 = GC_R__N;
 CHECK_BOUND( t_7, "R_N" )
 CHECK_INT_POS( t_7 )
 C_ELM_LIST_FPL( t_5, t_6, t_7 )
 t_7 = GC_R__X;
 CHECK_BOUND( t_7, "R_X" )
 t_11 = GC_R__N;
 CHECK_BOUND( t_11, "R_N" )
 C_SUM_FIA( t_10, t_11, INTOBJ_INT(30) )
 t_9 = MOD( t_10, INTOBJ_INT(55) );
 C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
 CHECK_INT_POS( t_8 )
 C_ELM_LIST_FPL( t_6, t_7, t_8 )
 C_SUM_FIA( t_4, t_5, t_6 )
 t_5 = GC_R__228;
 CHECK_BOUND( t_5, "R_228" )
 t_3 = MOD( t_4, t_5 );
 C_ASS_LIST_FPL( t_1, t_2, t_3 )
 
 /* return list[QUO_INT( R_X[R_N] * LEN_LIST( list ), R_228 ) + 1]; */
 t_4 = GF_QUO__INT;
 t_7 = GC_R__X;
 CHECK_BOUND( t_7, "R_X" )
 t_8 = GC_R__N;
 CHECK_BOUND( t_8, "R_N" )
 CHECK_INT_POS( t_8 )
 C_ELM_LIST_FPL( t_6, t_7, t_8 )
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

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self,
 Obj  a_n )
{
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* R_N := 1; */
 AssGVar( G_R__N, INTOBJ_INT(1) );
 
 /* R_X := [ n mod R_228 ]; */
 t_1 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_1, 1 );
 t_3 = GC_R__228;
 CHECK_BOUND( t_3, "R_228" )
 t_2 = MOD( a_n, t_3 );
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 AssGVar( G_R__X, t_1 );
 
 /* for i in [ 2 .. 55 ] do */
 for ( t_1 = INTOBJ_INT(2);
       ((Int)t_1) <= ((Int)INTOBJ_INT(55));
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* R_X[i] := (1664525 * R_X[(i - 1)] + 1) mod R_228; */
  t_2 = GC_R__X;
  CHECK_BOUND( t_2, "R_X" )
  t_7 = GC_R__X;
  CHECK_BOUND( t_7, "R_X" )
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  CHECK_INT_POS( t_8 )
  C_ELM_LIST_FPL( t_6, t_7, t_8 )
  C_PROD_FIA( t_5, INTOBJ_INT(1664525), t_6 )
  C_SUM_FIA( t_4, t_5, INTOBJ_INT(1) )
  t_5 = GC_R__228;
  CHECK_BOUND( t_5, "R_228" )
  t_3 = MOD( t_4, t_5 );
  C_ASS_LIST_FPL( t_2, l_i, t_3 )
  
 }
 /* od */
 
 /* for i in [ 1 .. 99 ] do */
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)INTOBJ_INT(99));
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* R_N := R_N mod 55 + 1; */
  t_4 = GC_R__N;
  CHECK_BOUND( t_4, "R_N" )
  t_3 = MOD( t_4, INTOBJ_INT(55) );
  C_SUM_FIA( t_2, t_3, INTOBJ_INT(1) )
  AssGVar( G_R__N, t_2 );
  
  /* R_X[R_N] := (R_X[R_N] + R_X[((R_N + 30) mod 55 + 1)]) mod R_228; */
  t_2 = GC_R__X;
  CHECK_BOUND( t_2, "R_X" )
  t_3 = GC_R__N;
  CHECK_BOUND( t_3, "R_N" )
  CHECK_INT_POS( t_3 )
  t_7 = GC_R__X;
  CHECK_BOUND( t_7, "R_X" )
  t_8 = GC_R__N;
  CHECK_BOUND( t_8, "R_N" )
  CHECK_INT_POS( t_8 )
  C_ELM_LIST_FPL( t_6, t_7, t_8 )
  t_8 = GC_R__X;
  CHECK_BOUND( t_8, "R_X" )
  t_12 = GC_R__N;
  CHECK_BOUND( t_12, "R_N" )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(30) )
  t_10 = MOD( t_11, INTOBJ_INT(55) );
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(1) )
  CHECK_INT_POS( t_9 )
  C_ELM_LIST_FPL( t_7, t_8, t_9 )
  C_SUM_FIA( t_5, t_6, t_7 )
  t_6 = GC_R__228;
  CHECK_BOUND( t_6, "R_228" )
  t_4 = MOD( t_5, t_6 );
  C_ASS_LIST_FPL( t_2, t_3, t_4 )
  
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* R_N := 1; */
 AssGVar( G_R__N, INTOBJ_INT(1) );
 
 /* R_X := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 AssGVar( G_R__X, t_1 );
 
 /* R_228 := 2 ^ 28; */
 t_1 = POW( INTOBJ_INT(2), INTOBJ_INT(28) );
 AssGVar( G_R__228, t_1 );
 
 /* RANDOM_LIST := function ( list )
      R_N := R_N mod 55 + 1;
      R_X[R_N] := (R_X[R_N] + R_X[((R_N + 30) mod 55 + 1)]) mod R_228;
      return list[QUO_INT( R_X[R_N] * LEN_LIST( list ), R_228 ) + 1];
  end; */
 t_1 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2 );
 ENVI_FUNC( t_1 ) = TLS(CurrLVars);
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 STARTLINE_BODY(t_2) = INTOBJ_INT(23);
 ENDLINE_BODY(t_2) = INTOBJ_INT(27);
 FILENAME_BODY(t_2) = FileName;
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( TLS(CurrLVars) );
 AssGVar( G_RANDOM__LIST, t_1 );
 
 /* RANDOM_SEED := function ( n )
      local  i;
      R_N := 1;
      R_X := [ n mod R_228 ];
      for i  in [ 2 .. 55 ]  do
          R_X[i] := (1664525 * R_X[(i - 1)] + 1) mod R_228;
      od;
      for i  in [ 1 .. 99 ]  do
          R_N := R_N mod 55 + 1;
          R_X[R_N] := (R_X[R_N] + R_X[((R_N + 30) mod 55 + 1)]) mod R_228;
      od;
      return;
  end; */
 t_1 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3 );
 ENVI_FUNC( t_1 ) = TLS(CurrLVars);
 t_2 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
 STARTLINE_BODY(t_2) = INTOBJ_INT(29);
 ENDLINE_BODY(t_2) = INTOBJ_INT(39);
 FILENAME_BODY(t_2) = FileName;
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( TLS(CurrLVars) );
 AssGVar( G_RANDOM__SEED, t_1 );
 
 /* if R_X = [  ] then */
 t_2 = GC_R__X;
 CHECK_BOUND( t_2, "R_X" )
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 t_1 = (Obj)(UInt)(EQ( t_2, t_3 ));
 if ( t_1 ) {
  
  /* RANDOM_SEED( 1 ); */
  t_1 = GF_RANDOM__SEED;
  CALL_1ARGS( t_1, INTOBJ_INT(1) );
  
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

/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "QUO_INT", &GF_QUO__INT );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitCopyGVar( "R_N", &GC_R__N );
 InitCopyGVar( "R_X", &GC_R__X );
 InitCopyGVar( "R_228", &GC_R__228 );
 InitFopyGVar( "RANDOM_SEED", &GF_RANDOM__SEED );
 
 /* information for the functions */
 InitGlobalBag( &DefaultName, "GAPROOT/lib/random.g:DefaultName(-48550429)" );
 InitGlobalBag( &FileName, "GAPROOT/lib/random.g:FileName(-48550429)" );
 InitHandlerFunc( HdlrFunc1, "GAPROOT/lib/random.g:HdlrFunc1(-48550429)" );
 InitGlobalBag( &(NameFunc[1]), "GAPROOT/lib/random.g:NameFunc[1](-48550429)" );
 InitHandlerFunc( HdlrFunc2, "GAPROOT/lib/random.g:HdlrFunc2(-48550429)" );
 InitGlobalBag( &(NameFunc[2]), "GAPROOT/lib/random.g:NameFunc[2](-48550429)" );
 InitHandlerFunc( HdlrFunc3, "GAPROOT/lib/random.g:HdlrFunc3(-48550429)" );
 InitGlobalBag( &(NameFunc[3]), "GAPROOT/lib/random.g:NameFunc[3](-48550429)" );
 
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
 G_QUO__INT = GVarName( "QUO_INT" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_R__N = GVarName( "R_N" );
 G_R__X = GVarName( "R_X" );
 G_R__228 = GVarName( "R_228" );
 G_RANDOM__LIST = GVarName( "RANDOM_LIST" );
 G_RANDOM__SEED = GVarName( "RANDOM_SEED" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" );
 C_NEW_STRING( FileName, 20, "GAPROOT/lib/random.g" );
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 1;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 1;
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);
 ENVI_FUNC( func1 ) = TLS(CurrLVars);
 CHANGED_BAG( TLS(CurrLVars) );
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
 G_QUO__INT = GVarName( "QUO_INT" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_R__N = GVarName( "R_N" );
 G_R__X = GVarName( "R_X" );
 G_R__228 = GVarName( "R_228" );
 G_RANDOM__LIST = GVarName( "RANDOM_LIST" );
 G_RANDOM__SEED = GVarName( "RANDOM_SEED" );
 
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
 NargFunc[3] = 1;
 
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
 /* crc         = */ -48550429,
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
