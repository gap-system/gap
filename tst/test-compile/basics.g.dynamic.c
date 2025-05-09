/* C file produced by GAC */
#include "compiled.h"
#define FILE_CRC  "-52605173"

/* global variables used in handlers */
static GVar G_PushOptions;
static Obj  GF_PushOptions;
static GVar G_PopOptions;
static Obj  GF_PopOptions;
static GVar G_Print;
static Obj  GF_Print;
static GVar G_test__int__constants;
static Obj  GF_test__int__constants;
static GVar G_test__func__calls;
static Obj  GF_test__func__calls;
static GVar G_Display;
static Obj  GF_Display;
static GVar G_test__cmp__ops;
static Obj  GF_test__cmp__ops;
static GVar G_test__arith;
static Obj  GF_test__arith;
static GVar G_test__tilde;
static Obj  GF_test__tilde;
static GVar G_test__list__rec__exprs;
static Obj  GF_test__list__rec__exprs;
static GVar G_myglobal;
static Obj  GC_myglobal;
static GVar G_test__IsBound__Unbind;
static Obj  GF_test__IsBound__Unbind;
static GVar G_test__loops;
static Obj  GF_test__loops;
static GVar G_runtest;

/* record names used in handlers */
static RNam R_myopt;
static RNam R_x;
static RNam R_a;
static RNam R_b;
static RNam R_d;

/* information for the functions */
static Obj  NameFunc[13];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self )
{
 Obj l_x = 0;
 Obj l_y = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 (void)l_x;
 (void)l_y;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* x := 10 ^ 5; */
 t_1 = POW( INTOBJ_INT(10), INTOBJ_INT(5) );
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_x, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x, t_2 ) );
 }
 
 /* y := 100000; */
 l_y = INTOBJ_INT(100000);
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_y, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_y, t_2 ) );
 }
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* x := - 10 ^ 5; */
 t_2 = POW( INTOBJ_INT(10), INTOBJ_INT(5) );
 C_AINV_FIA( t_1, t_2 )
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_x, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x, t_2 ) );
 }
 
 /* y := -100000; */
 l_y = INTOBJ_INT(-100000);
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_y, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_y, t_2 ) );
 }
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* x := 10 ^ 10; */
 t_1 = POW( INTOBJ_INT(10), INTOBJ_INT(10) );
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_x, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x, t_2 ) );
 }
 
 /* y := 10000000000; */
 l_y = ObjInt_Int8(10000000000);
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_y, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_y, t_2 ) );
 }
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* x := - 10 ^ 10; */
 t_2 = POW( INTOBJ_INT(10), INTOBJ_INT(10) );
 C_AINV_FIA( t_1, t_2 )
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_x, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x, t_2 ) );
 }
 
 /* y := -10000000000; */
 l_y = ObjInt_Int8(-10000000000);
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_y, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_y, t_2 ) );
 }
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* x := 10 ^ 20; */
 t_1 = POW( INTOBJ_INT(10), INTOBJ_INT(20) );
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_x, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x, t_2 ) );
 }
 
 /* y := 100000000000000000000; */
 t_1 = NewWordSizedBag(T_INTPOS, 16);
 C_SET_LIMB8( t_1, 0, 7766279631452241920LL);
 C_SET_LIMB8( t_1, 1, 5LL);
 l_y = t_1;
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_y, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_y, t_2 ) );
 }
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* x := - 10 ^ 20; */
 t_2 = POW( INTOBJ_INT(10), INTOBJ_INT(20) );
 C_AINV_FIA( t_1, t_2 )
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_x, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x, t_2 ) );
 }
 
 /* y := - 100000000000000000000; */
 t_2 = NewWordSizedBag(T_INTPOS, 16);
 C_SET_LIMB8( t_2, 0, 7766279631452241920LL);
 C_SET_LIMB8( t_2, 1, 5LL);
 C_AINV_FIA( t_1, t_2 )
 l_y = t_1;
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, l_y, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_y, t_2 ) );
 }
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 4 */
static Obj  HdlrFunc4 (
 Obj  self,
 Obj  a_args )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return Length( args ); */
 C_LEN_LIST_FPL( t_1, a_args )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
}

/* handler for function 5 */
static Obj  HdlrFunc5 (
 Obj  self,
 Obj  a_args )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Display( Length( args ) ); */
 t_1 = GF_Display;
 C_LEN_LIST_FPL( t_2, a_args )
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self )
{
 Obj l_vararg__fun = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 (void)l_vararg__fun;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* vararg_fun := function ( args... )
      return Length( args );
  end; */
 t_1 = NewFunction( NameFunc[4], -1, NewPlistFromArgs(MakeImmString("args")), HdlrFunc4 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 58);
 SET_ENDLINE_BODY(t_2, 60);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 l_vararg__fun = t_1;
 
 /* Print( vararg_fun(  ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_0ARGS( l_vararg__fun );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1 ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( l_vararg__fun, INTOBJ_INT(1) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1, 2 ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_2ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1, 2, 3 ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_3ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1, 2, 3, 4 ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_4ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1, 2, 3, 4, 5 ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_5ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1, 2, 3, 4, 5, 6 ), "\n" ); */
 t_1 = GF_Print;
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_6ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5), INTOBJ_INT(6) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5), INTOBJ_INT(6) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( 1, 2, 3, 4, 5, 6, 7 ), "\n" ); */
 t_1 = GF_Print;
 t_3 = NEW_PLIST( T_PLIST, 7 );
 SET_LEN_PLIST( t_3, 7 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_3, 3, INTOBJ_INT(3) );
 SET_ELM_PLIST( t_3, 4, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_3, 5, INTOBJ_INT(5) );
 SET_ELM_PLIST( t_3, 6, INTOBJ_INT(6) );
 SET_ELM_PLIST( t_3, 7, INTOBJ_INT(7) );
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_XARGS( l_vararg__fun, t_3 );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, t_3 );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun( "x", true, vararg_fun, 4, 5, 6, 7 ), "\n" ); */
 t_1 = GF_Print;
 t_3 = NEW_PLIST( T_PLIST, 7 );
 SET_LEN_PLIST( t_3, 7 );
 t_4 = MakeString( "x" );
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = True;
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 3, l_vararg__fun );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 4, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_3, 5, INTOBJ_INT(5) );
 SET_ELM_PLIST( t_3, 6, INTOBJ_INT(6) );
 SET_ELM_PLIST( t_3, 7, INTOBJ_INT(7) );
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_XARGS( l_vararg__fun, t_3 );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, t_3 );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun(  : myopt := true ), "\n" ); */
 t_1 = GF_Print;
 t_2 = NEW_PREC( 1 );
 t_3 = (Obj)R_myopt;
 t_4 = True;
 AssPRec( t_2, (UInt)t_3, t_4 );
 SortPRecRNam( t_2 );
 CALL_1ARGS( GF_PushOptions, t_2 );
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_0ARGS( l_vararg__fun );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CALL_0ARGS( GF_PopOptions );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( vararg_fun(  : myopt := "value" ), "\n" ); */
 t_1 = GF_Print;
 t_2 = NEW_PREC( 1 );
 t_3 = (Obj)R_myopt;
 t_4 = MakeString( "value" );
 AssPRec( t_2, (UInt)t_3, t_4 );
 SortPRecRNam( t_2 );
 CALL_1ARGS( GF_PushOptions, t_2 );
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  t_2 = CALL_0ARGS( l_vararg__fun );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 CALL_0ARGS( GF_PopOptions );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* vararg_fun := function ( args... )
      Display( Length( args ) );
      return;
  end; */
 t_1 = NewFunction( NameFunc[5], -1, NewPlistFromArgs(MakeImmString("args")), HdlrFunc5 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 89);
 SET_ENDLINE_BODY(t_2, 91);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 l_vararg__fun = t_1;
 
 /* vararg_fun(  ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_0ARGS( l_vararg__fun );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( ) );
 }
 
 /* vararg_fun( 1 ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_1ARGS( l_vararg__fun, INTOBJ_INT(1) );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1) ) );
 }
 
 /* vararg_fun( 1, 2 ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_2ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2) );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2) ) );
 }
 
 /* vararg_fun( 1, 2, 3 ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_3ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3) );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3) ) );
 }
 
 /* vararg_fun( 1, 2, 3, 4 ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_4ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4) );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4) ) );
 }
 
 /* vararg_fun( 1, 2, 3, 4, 5 ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_5ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5) );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5) ) );
 }
 
 /* vararg_fun( 1, 2, 3, 4, 5, 6 ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_6ARGS( l_vararg__fun, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5), INTOBJ_INT(6) );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4), INTOBJ_INT(5), INTOBJ_INT(6) ) );
 }
 
 /* vararg_fun( 1, 2, 3, 4, 5, 6, 7 ); */
 t_1 = NEW_PLIST( T_PLIST, 7 );
 SET_LEN_PLIST( t_1, 7 );
 SET_ELM_PLIST( t_1, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_1, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_1, 3, INTOBJ_INT(3) );
 SET_ELM_PLIST( t_1, 4, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_1, 5, INTOBJ_INT(5) );
 SET_ELM_PLIST( t_1, 6, INTOBJ_INT(6) );
 SET_ELM_PLIST( t_1, 7, INTOBJ_INT(7) );
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_XARGS( l_vararg__fun, t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, t_1 );
 }
 
 /* vararg_fun( "x", true, vararg_fun, 4, 5, 6, 7 ); */
 t_1 = NEW_PLIST( T_PLIST, 7 );
 SET_LEN_PLIST( t_1, 7 );
 t_2 = MakeString( "x" );
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = True;
 SET_ELM_PLIST( t_1, 2, t_2 );
 CHANGED_BAG( t_1 );
 SET_ELM_PLIST( t_1, 3, l_vararg__fun );
 CHANGED_BAG( t_1 );
 SET_ELM_PLIST( t_1, 4, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_1, 5, INTOBJ_INT(5) );
 SET_ELM_PLIST( t_1, 6, INTOBJ_INT(6) );
 SET_ELM_PLIST( t_1, 7, INTOBJ_INT(7) );
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_XARGS( l_vararg__fun, t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, t_1 );
 }
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_myopt;
 t_3 = True;
 AssPRec( t_1, (UInt)t_2, t_3 );
 SortPRecRNam( t_1 );
 CALL_1ARGS( GF_PushOptions, t_1 );
 
 /* vararg_fun(  ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_0ARGS( l_vararg__fun );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( ) );
 }
 CALL_0ARGS( GF_PopOptions );
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_myopt;
 t_3 = MakeString( "value" );
 AssPRec( t_1, (UInt)t_2, t_3 );
 SortPRecRNam( t_1 );
 CALL_1ARGS( GF_PushOptions, t_1 );
 
 /* vararg_fun(  ); */
 if ( TNUM_OBJ( l_vararg__fun ) == T_FUNCTION ) {
  CALL_0ARGS( l_vararg__fun );
 }
 else {
  DoOperation2Args( CallFuncListOper, l_vararg__fun, NewPlistFromArgs( ) );
 }
 CALL_0ARGS( GF_PopOptions );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
 Obj  self )
{
 Obj l_x = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 (void)l_x;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "setting x to 2 ...\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "setting x to 2 ...\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := 2; */
 l_x = INTOBJ_INT(2);
 
 /* Print( "1 = 2 is ", 1 = 2, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 = 2 is " );
 t_3 = ((((Int)INTOBJ_INT(1)) == ((Int)INTOBJ_INT(2))) ? True : False);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 = x is ", 1 = x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 = x is " );
 t_3 = ((((Int)INTOBJ_INT(1)) == ((Int)l_x)) ? True : False);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 = 2 via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 = 2 via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 = 2 then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) == ((Int)INTOBJ_INT(2)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 = x via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 = x via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 = x then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) == ((Int)l_x));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 <> 2 is ", 1 <> 2, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <> 2 is " );
 t_3 = ((((Int)INTOBJ_INT(1)) == ((Int)INTOBJ_INT(2))) ? False : True);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 <> x is ", 1 <> x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <> x is " );
 t_3 = ((((Int)INTOBJ_INT(1)) == ((Int)l_x)) ? False : True);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 <> 2 via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <> 2 via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 <> 2 then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) != ((Int)INTOBJ_INT(2)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 <> x via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <> x via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 <> x then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) != ((Int)l_x));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 < 2 is ", 1 < 2, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 < 2 is " );
 t_3 = ((((Int)INTOBJ_INT(1)) < ((Int)INTOBJ_INT(2))) ? True : False);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 < x is ", 1 < x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 < x is " );
 t_3 = ((((Int)INTOBJ_INT(1)) < ((Int)l_x)) ? True : False);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 < 2 via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 < 2 via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 < 2 then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) < ((Int)INTOBJ_INT(2)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 < x via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 < x via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 < x then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) < ((Int)l_x));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 <= 2 is ", 1 <= 2, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <= 2 is " );
 t_3 = ((((Int)INTOBJ_INT(2)) < ((Int)INTOBJ_INT(1))) ?  False : True);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 <= x is ", 1 <= x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <= x is " );
 t_3 = ((((Int)l_x) < ((Int)INTOBJ_INT(1))) ?  False : True);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 <= 2 via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <= 2 via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 <= 2 then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(2)) >= ((Int)INTOBJ_INT(1)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 <= x via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 <= x via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 <= x then */
 t_1 = (Obj)(UInt)(((Int)l_x) >= ((Int)INTOBJ_INT(1)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 > 2 is ", 1 > 2, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 > 2 is " );
 t_3 = ((((Int)INTOBJ_INT(2)) < ((Int)INTOBJ_INT(1))) ? True : False);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 > x is ", 1 > x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 > x is " );
 t_3 = ((((Int)l_x) < ((Int)INTOBJ_INT(1))) ? True : False);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 > 2 via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 > 2 via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 > 2 then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(2)) < ((Int)INTOBJ_INT(1)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 > x via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 > x via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 > x then */
 t_1 = (Obj)(UInt)(((Int)l_x) < ((Int)INTOBJ_INT(1)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 >= 2 is ", 1 >= 2, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 >= 2 is " );
 t_3 = ((((Int)INTOBJ_INT(1)) < ((Int)INTOBJ_INT(2))) ? False : True);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 >= x is ", 1 >= x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 >= x is " );
 t_3 = ((((Int)INTOBJ_INT(1)) < ((Int)l_x)) ? False : True);
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "1 >= 2 via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 >= 2 via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 >= 2 then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) >= ((Int)INTOBJ_INT(2)));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* Print( "1 >= x via if is " ); */
 t_1 = GF_Print;
 t_2 = MakeString( "1 >= x via if is " );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* if 1 >= x then */
 t_1 = (Obj)(UInt)(((Int)INTOBJ_INT(1)) >= ((Int)l_x));
 if ( t_1 ) {
  
  /* Print( "true\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "true\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 
 /* else */
 else {
  
  /* Print( "false\n" ); */
  t_1 = GF_Print;
  t_2 = MakeString( "false\n" );
  if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
   CALL_1ARGS( t_1, t_2 );
  }
  else {
   DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
  }
  
 }
 /* fi */
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 7 */
static Obj  HdlrFunc7 (
 Obj  self )
{
 Obj l_x = 0;
 Obj t_1 = 0;
 (void)l_x;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* x := 5; */
 l_x = INTOBJ_INT(5);
 
 /* x := - x; */
 C_AINV_INTOBJS( t_1, l_x )
 l_x = t_1;
 
 /* x := 1 / 2; */
 t_1 = QUO( INTOBJ_INT(1), INTOBJ_INT(2) );
 l_x = t_1;
 
 /* x := - x; */
 C_AINV_FIA( t_1, l_x )
 l_x = t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self )
{
 Obj l_x = 0;
 (void)l_x;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 9 */
static Obj  HdlrFunc9 (
 Obj  self )
{
 Obj l_l = 0;
 Obj l_x = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 (void)l_l;
 (void)l_x;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Display( [  ] ); */
 t_1 = GF_Display;
 t_2 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_2, 0 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( [ 1, 2, 3 ] ); */
 t_1 = GF_Display;
 t_2 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_2, 3 );
 SET_ELM_PLIST( t_2, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_2, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_2, 3, INTOBJ_INT(3) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( [ 1,, 3, [ 4, 5 ], rec(
        x := [ 6, rec(
                 ) ] ) ] ); */
 t_1 = GF_Display;
 t_2 = NEW_PLIST( T_PLIST, 5 );
 SET_LEN_PLIST( t_2, 5 );
 SET_ELM_PLIST( t_2, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_2, 3, INTOBJ_INT(3) );
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_2, 4, t_3 );
 CHANGED_BAG( t_2 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(5) );
 t_3 = NEW_PREC( 1 );
 SET_ELM_PLIST( t_2, 5, t_3 );
 CHANGED_BAG( t_2 );
 t_4 = (Obj)R_x;
 t_5 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_5, 2 );
 AssPRec( t_3, (UInt)t_4, t_5 );
 SET_ELM_PLIST( t_5, 1, INTOBJ_INT(6) );
 t_6 = NEW_PREC( 0 );
 SET_ELM_PLIST( t_5, 2, t_6 );
 CHANGED_BAG( t_5 );
 SortPRecRNam( t_6 );
 SortPRecRNam( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* l := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 l_l = t_1;
 
 /* l[1] := 1; */
 C_ASS_LIST_FPL_INTOBJ( l_l, INTOBJ_INT(1), INTOBJ_INT(1) )
 
 /* l[1 + 1] := 2; */
 C_SUM_INTOBJS( t_1, INTOBJ_INT(1), INTOBJ_INT(1) )
 CHECK_INT_POS( t_1 );
 C_ASS_LIST_FPL_INTOBJ( l_l, t_1, INTOBJ_INT(2) )
 
 /* l![3] := 3; */
 AssPosObj( l_l, 3, INTOBJ_INT(3) );
 
 /* l![2 + 2] := 4; */
 C_SUM_INTOBJS( t_1, INTOBJ_INT(2), INTOBJ_INT(2) )
 CHECK_INT_SMALL_POS( t_1 );
 AssPosObj( l_l, Int_ObjInt(t_1), INTOBJ_INT(4) );
 
 /* Display( l ); */
 t_1 = GF_Display;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_l );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_l ) );
 }
 
 /* Print( "l[1] = ", l[1], "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "l[1] = " );
 C_ELM_LIST_FPL( t_3, l_l, INTOBJ_INT(1) )
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "l[2] = ", l[1 + 1], "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "l[2] = " );
 C_SUM_INTOBJS( t_4, INTOBJ_INT(1), INTOBJ_INT(1) )
 CHECK_INT_POS( t_4 );
 C_ELM_LIST_FPL( t_3, l_l, t_4 )
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "l[3] = ", l![3], "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "l[3] = " );
 t_3 = ElmPosObj( l_l, 3 );
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "l[4] = ", l![2 + 2], "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "l[4] = " );
 C_SUM_INTOBJS( t_4, INTOBJ_INT(2), INTOBJ_INT(2) )
 CHECK_INT_SMALL_POS( t_4 );
 t_3 = ElmPosObj( l_l, Int_ObjInt(t_4) );
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* x := rec(
    a := 1 ); */
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_a;
 AssPRec( t_1, (UInt)t_2, INTOBJ_INT(1) );
 SortPRecRNam( t_1 );
 l_x = t_1;
 
 /* x.b := 2; */
 ASS_REC( l_x, R_b, INTOBJ_INT(2) );
 
 /* x.("c") := x.a + x.("b"); */
 t_1 = MakeString( "c" );
 t_3 = ELM_REC( l_x, R_a );
 t_5 = MakeString( "b" );
 t_4 = ELM_REC( l_x, RNamObj(t_5) );
 C_SUM_FIA( t_2, t_3, t_4 )
 ASS_REC( l_x, RNamObj(t_1), t_2 );
 
 /* x!.d := 42; */
 AssComObj( l_x, R_d, INTOBJ_INT(42) );
 
 /* x!.("e") := 23; */
 t_1 = MakeString( "e" );
 AssComObj( l_x, RNamObj(t_1), INTOBJ_INT(23) );
 
 /* Display( x ); */
 t_1 = GF_Display;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_x );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x ) );
 }
 
 /* Print( "x.a = ", x.a, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "x.a = " );
 t_3 = ELM_REC( l_x, R_a );
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "x.b = ", x.("b"), "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "x.b = " );
 t_4 = MakeString( "b" );
 t_3 = ELM_REC( l_x, RNamObj(t_4) );
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "x.d = ", x!.d, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "x.d = " );
 t_3 = ElmComObj( l_x, R_d );
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* Print( "x.e = ", x!.("e"), "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "x.e = " );
 t_4 = MakeString( "e" );
 t_3 = ElmComObj( l_x, RNamObj(t_4) );
 t_4 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 10 */
static Obj  HdlrFunc10 (
 Obj  self )
{
 Obj l_x = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 (void)l_x;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "Testing IsBound and Unbind for lvar\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for lvar\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := 42; */
 l_x = INTOBJ_INT(42);
 
 /* Display( IsBound( x ) ); */
 t_1 = GF_Display;
 t_2 = ((l_x != 0) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x ); */
 l_x = 0;
 
 /* Display( IsBound( x ) ); */
 t_1 = GF_Display;
 t_2 = ((l_x != 0) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for gvar\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for gvar\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* myglobal := 42; */
 AssGVar( G_myglobal, INTOBJ_INT(42) );
 
 /* Display( IsBound( myglobal ) ); */
 t_1 = GF_Display;
 t_3 = GC_myglobal;
 t_2 = ((t_3 != 0) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( myglobal ); */
 AssGVar( G_myglobal, 0 );
 
 /* Display( IsBound( myglobal ) ); */
 t_1 = GF_Display;
 t_3 = GC_myglobal;
 t_2 = ((t_3 != 0) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for list\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for list\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := [ 1, 2, 3 ]; */
 t_1 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_1, 3 );
 SET_ELM_PLIST( t_1, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_1, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_1, 3, INTOBJ_INT(3) );
 l_x = t_1;
 
 /* Display( IsBound( x[2] ) ); */
 t_1 = GF_Display;
 t_2 = C_ISB_LIST( l_x, INTOBJ_INT(2) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x[2] ); */
 C_UNB_LIST( l_x, INTOBJ_INT(2) );
 
 /* Display( IsBound( x[2] ) ); */
 t_1 = GF_Display;
 t_2 = C_ISB_LIST( l_x, INTOBJ_INT(2) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for list with bang\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for list with bang\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := [ 1, 2, 3 ]; */
 t_1 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_1, 3 );
 SET_ELM_PLIST( t_1, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_1, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_1, 3, INTOBJ_INT(3) );
 l_x = t_1;
 
 /* Display( IsBound( x![2] ) ); */
 t_1 = GF_Display;
 t_2 = IsbPosObj( l_x, 2 ) ? True : False;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x![2] ); */
 UnbPosObj( l_x, 2 );
 
 /* Display( IsBound( x![2] ) ); */
 t_1 = GF_Display;
 t_2 = IsbPosObj( l_x, 2 ) ? True : False;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for record\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for record\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := rec(
    a := 1 ); */
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_a;
 AssPRec( t_1, (UInt)t_2, INTOBJ_INT(1) );
 SortPRecRNam( t_1 );
 l_x = t_1;
 
 /* Display( IsBound( x.a ) ); */
 t_1 = GF_Display;
 t_2 = (ISB_REC( l_x, R_a ) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x.a ); */
 UNB_REC( l_x, R_a );
 
 /* Display( IsBound( x.a ) ); */
 t_1 = GF_Display;
 t_2 = (ISB_REC( l_x, R_a ) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for record with expr\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for record with expr\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := rec(
    a := 1 ); */
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_a;
 AssPRec( t_1, (UInt)t_2, INTOBJ_INT(1) );
 SortPRecRNam( t_1 );
 l_x = t_1;
 
 /* Display( IsBound( x.("a") ) ); */
 t_1 = GF_Display;
 t_3 = MakeString( "a" );
 t_2 = (ISB_REC( l_x, RNamObj(t_3) ) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x.("a") ); */
 t_1 = MakeString( "a" );
 UNB_REC( l_x, RNamObj(t_1) );
 
 /* Display( IsBound( x.("a") ) ); */
 t_1 = GF_Display;
 t_3 = MakeString( "a" );
 t_2 = (ISB_REC( l_x, RNamObj(t_3) ) ? True : False);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for record with bang\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for record with bang\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := rec(
    a := 1 ); */
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_a;
 AssPRec( t_1, (UInt)t_2, INTOBJ_INT(1) );
 SortPRecRNam( t_1 );
 l_x = t_1;
 
 /* Display( IsBound( x!.a ) ); */
 t_1 = GF_Display;
 t_2 = IsbComObj( l_x, R_a ) ? True : False;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x!.a ); */
 UnbComObj( l_x, R_a );
 
 /* Display( IsBound( x!.a ) ); */
 t_1 = GF_Display;
 t_2 = IsbComObj( l_x, R_a ) ? True : False;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Print( "Testing IsBound and Unbind for record with bang and expr\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "Testing IsBound and Unbind for record with bang and expr\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := rec(
    a := 1 ); */
 t_1 = NEW_PREC( 1 );
 t_2 = (Obj)R_a;
 AssPRec( t_1, (UInt)t_2, INTOBJ_INT(1) );
 SortPRecRNam( t_1 );
 l_x = t_1;
 
 /* Display( IsBound( x!.("a") ) ); */
 t_1 = GF_Display;
 t_3 = MakeString( "a" );
 t_2 = IsbComObj( l_x, RNamObj(t_3) ) ? True : False;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Unbind( x!.("a") ); */
 t_1 = MakeString( "a" );
 UnbComObj( l_x, RNamObj(t_1) );
 
 /* Display( IsBound( x!.("a") ) ); */
 t_1 = GF_Display;
 t_3 = MakeString( "a" );
 t_2 = IsbComObj( l_x, RNamObj(t_3) ) ? True : False;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 11 */
static Obj  HdlrFunc11 (
 Obj  self )
{
 Obj l_x = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 (void)l_x;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Display( "testing repeat loop" ); */
 t_1 = GF_Display;
 t_2 = MakeString( "testing repeat loop" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := 0; */
 l_x = INTOBJ_INT(0);
 
 /* repeat */
 do {
  
  /* x := x + 1; */
  C_SUM_FIA( t_1, l_x, INTOBJ_INT(1) )
  l_x = t_1;
  
  /* if x = 1 then */
  t_1 = (Obj)(UInt)(EQ( l_x, INTOBJ_INT(1) ));
  if ( t_1 ) {
   
   /* continue; */
   continue;
   
  }
  
  /* elif x = 4 then */
  else {
   t_1 = (Obj)(UInt)(EQ( l_x, INTOBJ_INT(4) ));
   if ( t_1 ) {
    
    /* break; */
    break;
    
   }
   
   /* else */
   else {
    
    /* Display( x ); */
    t_1 = GF_Display;
    if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
     CALL_1ARGS( t_1, l_x );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x ) );
    }
    
   }
  }
  /* fi */
  
  /* until x >= 100 */
  t_1 = (Obj)(UInt)(! LT( l_x, INTOBJ_INT(100) ));
  if ( t_1 ) break;
 } while ( 1 );
 
 /* Display( "testing while loop" ); */
 t_1 = GF_Display;
 t_2 = MakeString( "testing while loop" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* x := 0; */
 l_x = INTOBJ_INT(0);
 
 /* while x < 100 do */
 while ( 1 ) {
  t_1 = (Obj)(UInt)(LT( l_x, INTOBJ_INT(100) ));
  if ( ! t_1 ) break;
  
  /* x := x + 1; */
  C_SUM_FIA( t_1, l_x, INTOBJ_INT(1) )
  l_x = t_1;
  
  /* if x = 1 then */
  t_1 = (Obj)(UInt)(EQ( l_x, INTOBJ_INT(1) ));
  if ( t_1 ) {
   
   /* continue; */
   continue;
   
  }
  
  /* elif x = 4 then */
  else {
   t_1 = (Obj)(UInt)(EQ( l_x, INTOBJ_INT(4) ));
   if ( t_1 ) {
    
    /* break; */
    break;
    
   }
   
   /* else */
   else {
    
    /* Display( x ); */
    t_1 = GF_Display;
    if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
     CALL_1ARGS( t_1, l_x );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_x ) );
    }
    
   }
  }
  /* fi */
  
 }
 /* od */
 
 /* Display( "testing for loop" ); */
 t_1 = GF_Display;
 t_2 = MakeString( "testing for loop" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* for x in [ 1 .. 100 ] do */
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)INTOBJ_INT(100));
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_x = t_1;
  
  /* if x = 1 then */
  t_2 = (Obj)(UInt)(((Int)l_x) == ((Int)INTOBJ_INT(1)));
  if ( t_2 ) {
   
   /* continue; */
   continue;
   
  }
  
  /* elif x = 4 then */
  else {
   t_2 = (Obj)(UInt)(((Int)l_x) == ((Int)INTOBJ_INT(4)));
   if ( t_2 ) {
    
    /* break; */
    break;
    
   }
   
   /* else */
   else {
    
    /* Display( x ); */
    t_2 = GF_Display;
    if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
     CALL_1ARGS( t_2, l_x );
    }
    else {
     DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( l_x ) );
    }
    
   }
  }
  /* fi */
  
 }
 /* od */
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* test_int_constants(  ); */
 t_1 = GF_test__int__constants;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_func_calls(  ); */
 t_1 = GF_test__func__calls;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_cmp_ops(  ); */
 t_1 = GF_test__cmp__ops;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_arith(  ); */
 t_1 = GF_test__arith;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_tilde(  ); */
 t_1 = GF_test__tilde;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_list_rec_exprs(  ); */
 t_1 = GF_test__list__rec__exprs;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_IsBound_Unbind(  ); */
 t_1 = GF_test__IsBound__Unbind;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* test_loops(  ); */
 t_1 = GF_test__loops;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_0ARGS( t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( ) );
 }
 
 /* Display( () ); */
 t_1 = GF_Display;
 t_2 = IdentityPerm;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
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
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* test_int_constants := function (  )
      local x, y;
      x := 10 ^ 5;
      Print( x, "\n" );
      y := 100000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      x := - 10 ^ 5;
      Print( x, "\n" );
      y := -100000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      x := 10 ^ 10;
      Print( x, "\n" );
      y := 10000000000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      x := - 10 ^ 10;
      Print( x, "\n" );
      y := -10000000000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      x := 10 ^ 20;
      Print( x, "\n" );
      y := 100000000000000000000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      x := - 10 ^ 20;
      Print( x, "\n" );
      y := - 100000000000000000000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 7);
 SET_ENDLINE_BODY(t_2, 48);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__int__constants, t_1 );
 
 /* test_func_calls := function (  )
      local vararg_fun;
      vararg_fun := function ( args... )
            return Length( args );
        end;
      Print( vararg_fun(  ), "\n" );
      Print( vararg_fun( 1 ), "\n" );
      Print( vararg_fun( 1, 2 ), "\n" );
      Print( vararg_fun( 1, 2, 3 ), "\n" );
      Print( vararg_fun( 1, 2, 3, 4 ), "\n" );
      Print( vararg_fun( 1, 2, 3, 4, 5 ), "\n" );
      Print( vararg_fun( 1, 2, 3, 4, 5, 6 ), "\n" );
      Print( vararg_fun( 1, 2, 3, 4, 5, 6, 7 ), "\n" );
      Print( vararg_fun( "x", true, vararg_fun, 4, 5, 6, 7 ), "\n" );
      Print( vararg_fun(  : myopt := true ), "\n" );
      Print( vararg_fun(  : myopt := "value" ), "\n" );
      vararg_fun := function ( args... )
            Display( Length( args ) );
            return;
        end;
      vararg_fun(  );
      vararg_fun( 1 );
      vararg_fun( 1, 2 );
      vararg_fun( 1, 2, 3 );
      vararg_fun( 1, 2, 3, 4 );
      vararg_fun( 1, 2, 3, 4, 5 );
      vararg_fun( 1, 2, 3, 4, 5, 6 );
      vararg_fun( 1, 2, 3, 4, 5, 6, 7 );
      vararg_fun( "x", true, vararg_fun, 4, 5, 6, 7 );
      vararg_fun(  : myopt := true );
      vararg_fun(  : myopt := "value" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[3], 0, 0, HdlrFunc3 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 54);
 SET_ENDLINE_BODY(t_2, 112);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__func__calls, t_1 );
 
 /* test_cmp_ops := function (  )
      local x;
      Print( "setting x to 2 ...\n" );
      x := 2;
      Print( "1 = 2 is ", 1 = 2, "\n" );
      Print( "1 = x is ", 1 = x, "\n" );
      Print( "1 = 2 via if is " );
      if 1 = 2 then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 = x via if is " );
      if 1 = x then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 <> 2 is ", 1 <> 2, "\n" );
      Print( "1 <> x is ", 1 <> x, "\n" );
      Print( "1 <> 2 via if is " );
      if 1 <> 2 then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 <> x via if is " );
      if 1 <> x then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 < 2 is ", 1 < 2, "\n" );
      Print( "1 < x is ", 1 < x, "\n" );
      Print( "1 < 2 via if is " );
      if 1 < 2 then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 < x via if is " );
      if 1 < x then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 <= 2 is ", 1 <= 2, "\n" );
      Print( "1 <= x is ", 1 <= x, "\n" );
      Print( "1 <= 2 via if is " );
      if 1 <= 2 then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 <= x via if is " );
      if 1 <= x then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 > 2 is ", 1 > 2, "\n" );
      Print( "1 > x is ", 1 > x, "\n" );
      Print( "1 > 2 via if is " );
      if 1 > 2 then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 > x via if is " );
      if 1 > x then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 >= 2 is ", 1 >= 2, "\n" );
      Print( "1 >= x is ", 1 >= x, "\n" );
      Print( "1 >= 2 via if is " );
      if 1 >= 2 then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      Print( "1 >= x via if is " );
      if 1 >= x then
          Print( "true\n" );
      else
          Print( "false\n" );
      fi;
      return;
  end; */
 t_1 = NewFunction( NameFunc[6], 0, 0, HdlrFunc6 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 122);
 SET_ENDLINE_BODY(t_2, 163);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__cmp__ops, t_1 );
 
 /* test_arith := function (  )
      local x;
      x := 5;
      x := - x;
      x := 1 / 2;
      x := - x;
      return;
  end; */
 t_1 = NewFunction( NameFunc[7], 0, 0, HdlrFunc7 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 169);
 SET_ENDLINE_BODY(t_2, 177);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__arith, t_1 );
 
 /* test_tilde := function (  )
      local x;
      return;
  end; */
 t_1 = NewFunction( NameFunc[8], 0, 0, HdlrFunc8 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 183);
 SET_ENDLINE_BODY(t_2, 199);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__tilde, t_1 );
 
 /* test_list_rec_exprs := function (  )
      local l, x;
      Display( [  ] );
      Display( [ 1, 2, 3 ] );
      Display( [ 1,, 3, [ 4, 5 ], rec(
              x := [ 6, rec(
                       ) ] ) ] );
      l := [  ];
      l[1] := 1;
      l[1 + 1] := 2;
      l![3] := 3;
      l![2 + 2] := 4;
      Display( l );
      Print( "l[1] = ", l[1], "\n" );
      Print( "l[2] = ", l[1 + 1], "\n" );
      Print( "l[3] = ", l![3], "\n" );
      Print( "l[4] = ", l![2 + 2], "\n" );
      x := rec(
          a := 1 );
      x.b := 2;
      x.("c") := x.a + x.("b");
      x!.d := 42;
      x!.("e") := 23;
      Display( x );
      Print( "x.a = ", x.a, "\n" );
      Print( "x.b = ", x.("b"), "\n" );
      Print( "x.d = ", x!.d, "\n" );
      Print( "x.e = ", x!.("e"), "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[9], 0, 0, HdlrFunc9 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 205);
 SET_ENDLINE_BODY(t_2, 233);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__list__rec__exprs, t_1 );
 
 /* myglobal := 1; */
 AssGVar( G_myglobal, INTOBJ_INT(1) );
 
 /* test_IsBound_Unbind := function (  )
      local x;
      Print( "Testing IsBound and Unbind for lvar\n" );
      x := 42;
      Display( IsBound( x ) );
      Unbind( x );
      Display( IsBound( x ) );
      Print( "Testing IsBound and Unbind for gvar\n" );
      myglobal := 42;
      Display( IsBound( myglobal ) );
      Unbind( myglobal );
      Display( IsBound( myglobal ) );
      Print( "Testing IsBound and Unbind for list\n" );
      x := [ 1, 2, 3 ];
      Display( IsBound( x[2] ) );
      Unbind( x[2] );
      Display( IsBound( x[2] ) );
      Print( "Testing IsBound and Unbind for list with bang\n" );
      x := [ 1, 2, 3 ];
      Display( IsBound( x![2] ) );
      Unbind( x![2] );
      Display( IsBound( x![2] ) );
      Print( "Testing IsBound and Unbind for record\n" );
      x := rec(
          a := 1 );
      Display( IsBound( x.a ) );
      Unbind( x.a );
      Display( IsBound( x.a ) );
      Print( "Testing IsBound and Unbind for record with expr\n" );
      x := rec(
          a := 1 );
      Display( IsBound( x.("a") ) );
      Unbind( x.("a") );
      Display( IsBound( x.("a") ) );
      Print( "Testing IsBound and Unbind for record with bang\n" );
      x := rec(
          a := 1 );
      Display( IsBound( x!.a ) );
      Unbind( x!.a );
      Display( IsBound( x!.a ) );
      Print( "Testing IsBound and Unbind for record with bang and expr\n" );
      x := rec(
          a := 1 );
      Display( IsBound( x!.("a") ) );
      Unbind( x!.("a") );
      Display( IsBound( x!.("a") ) );
      return;
  end; */
 t_1 = NewFunction( NameFunc[10], 0, 0, HdlrFunc10 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 240);
 SET_ENDLINE_BODY(t_2, 299);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__IsBound__Unbind, t_1 );
 
 /* test_loops := function (  )
      local x;
      Display( "testing repeat loop" );
      x := 0;
      repeat
          x := x + 1;
          if x = 1 then
              continue;
          elif x = 4 then
              break;
          else
              Display( x );
          fi;
      until x >= 100;
      Display( "testing while loop" );
      x := 0;
      while x < 100 do
          x := x + 1;
          if x = 1 then
              continue;
          elif x = 4 then
              break;
          else
              Display( x );
          fi;
      od;
      Display( "testing for loop" );
      for x in [ 1 .. 100 ] do
          if x = 1 then
              continue;
          elif x = 4 then
              break;
          else
              Display( x );
          fi;
      od;
      return;
  end; */
 t_1 = NewFunction( NameFunc[11], 0, 0, HdlrFunc11 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 305);
 SET_ENDLINE_BODY(t_2, 346);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_test__loops, t_1 );
 
 /* runtest := function (  )
      test_int_constants(  );
      test_func_calls(  );
      test_cmp_ops(  );
      test_arith(  );
      test_tilde(  );
      test_list_rec_exprs(  );
      test_IsBound_Unbind(  );
      test_loops(  );
      Display( () );
      return;
  end; */
 t_1 = NewFunction( NameFunc[12], 0, 0, HdlrFunc12 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 352);
 SET_ENDLINE_BODY(t_2, 364);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_runtest, t_1 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_PushOptions = GVarName( "PushOptions" );
 G_PopOptions = GVarName( "PopOptions" );
 G_Print = GVarName( "Print" );
 G_test__int__constants = GVarName( "test_int_constants" );
 G_test__func__calls = GVarName( "test_func_calls" );
 G_Display = GVarName( "Display" );
 G_test__cmp__ops = GVarName( "test_cmp_ops" );
 G_test__arith = GVarName( "test_arith" );
 G_test__tilde = GVarName( "test_tilde" );
 G_test__list__rec__exprs = GVarName( "test_list_rec_exprs" );
 G_myglobal = GVarName( "myglobal" );
 G_test__IsBound__Unbind = GVarName( "test_IsBound_Unbind" );
 G_test__loops = GVarName( "test_loops" );
 G_runtest = GVarName( "runtest" );
 
 /* record names used in handlers */
 R_myopt = RNamName( "myopt" );
 R_x = RNamName( "x" );
 R_a = RNamName( "a" );
 R_b = RNamName( "b" );
 R_d = RNamName( "d" );
 
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
 
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "PushOptions", &GF_PushOptions );
 InitFopyGVar( "PopOptions", &GF_PopOptions );
 InitFopyGVar( "Print", &GF_Print );
 InitFopyGVar( "test_int_constants", &GF_test__int__constants );
 InitFopyGVar( "test_func_calls", &GF_test__func__calls );
 InitFopyGVar( "Display", &GF_Display );
 InitFopyGVar( "test_cmp_ops", &GF_test__cmp__ops );
 InitFopyGVar( "test_arith", &GF_test__arith );
 InitFopyGVar( "test_tilde", &GF_test__tilde );
 InitFopyGVar( "test_list_rec_exprs", &GF_test__list__rec__exprs );
 InitCopyGVar( "myglobal", &GC_myglobal );
 InitFopyGVar( "test_IsBound_Unbind", &GF_test__IsBound__Unbind );
 InitFopyGVar( "test_loops", &GF_test__loops );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "basics.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "basics.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "basics.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "basics.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "basics.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "basics.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "basics.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "basics.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "basics.g:NameFunc[4]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc5, "basics.g:HdlrFunc5("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[5]), "basics.g:NameFunc[5]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc6, "basics.g:HdlrFunc6("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[6]), "basics.g:NameFunc[6]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc7, "basics.g:HdlrFunc7("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[7]), "basics.g:NameFunc[7]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc8, "basics.g:HdlrFunc8("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[8]), "basics.g:NameFunc[8]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc9, "basics.g:HdlrFunc9("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[9]), "basics.g:NameFunc[9]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc10, "basics.g:HdlrFunc10("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[10]), "basics.g:NameFunc[10]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc11, "basics.g:HdlrFunc11("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[11]), "basics.g:NameFunc[11]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc12, "basics.g:HdlrFunc12("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[12]), "basics.g:NameFunc[12]("FILE_CRC")" );
 
 return 0;
 
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
 Obj func1;
 Obj body1;
 
 /* Complete Copy/Fopy registration */
 UpdateCopyFopyInfo();
 FileName = MakeImmString( "basics.g" );
 PostRestore(module);
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],0,0,HdlrFunc1);
 SET_ENVI_FUNC( func1, STATE(CurrLVars) );
 body1 = NewFunctionBody();
 SET_BODY_FUNC( func1, body1 );
 CHANGED_BAG( func1 );
 CALL_0ARGS( func1 );
 
 return 0;
 
}

/* <name> returns the description of this module */
static StructInitInfo module = {
 .type        = MODULE_DYNAMIC,
 .name        = "basics.g",
 .crc         = -52605173,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}

/* compiled code ends here */
