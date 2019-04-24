/* C file produced by GAC */
#include "compiled.h"
#define FILE_CRC  "6760218"

/* global variables used in handlers */
static GVar G_ReturnTrue;
static Obj  GC_ReturnTrue;
static GVar G_fail;
static Obj  GC_fail;
static GVar G_Print;
static Obj  GF_Print;
static GVar G_CALL__WITH__CATCH;
static Obj  GF_CALL__WITH__CATCH;
static GVar G_p0;
static Obj  GF_p0;
static GVar G_p1;
static Obj  GF_p1;
static GVar G_p7;
static Obj  GF_p7;
static GVar G_f0;
static Obj  GF_f0;
static GVar G_Display;
static Obj  GF_Display;
static GVar G_f1;
static Obj  GF_f1;
static GVar G_f7;
static Obj  GF_f7;
static GVar G_runtest;
static GVar G_NewCategory;
static Obj  GF_NewCategory;
static GVar G_IsFunction;
static Obj  GC_IsFunction;
static GVar G_InstallMethod;
static Obj  GF_InstallMethod;
static GVar G_CallFuncList;
static Obj  GC_CallFuncList;
static GVar G_IsList;
static Obj  GC_IsList;
static GVar G_Objectify;
static Obj  GF_Objectify;
static GVar G_NewType;
static Obj  GF_NewType;
static GVar G_NewFamily;
static Obj  GF_NewFamily;
static GVar G_IsPositionalObjectRep;
static Obj  GC_IsPositionalObjectRep;
static GVar G_BreakOnError;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[16];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_f )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "p0\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "p0\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* f(  ); */
 if ( TNUM_OBJ( a_f ) == T_FUNCTION ) {
  CALL_0ARGS( a_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, a_f, NewPlistFromArgs( ) );
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
 Obj  a_f )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "p1\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "p1\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* f( 1 ); */
 if ( TNUM_OBJ( a_f ) == T_FUNCTION ) {
  CALL_1ARGS( a_f, INTOBJ_INT(1) );
 }
 else {
  DoOperation2Args( CallFuncListOper, a_f, NewPlistFromArgs( INTOBJ_INT(1) ) );
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
 Obj  a_f )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "p7\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "p7\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* f( 1, 2, 3, 4, 5, 6, 7 ); */
 t_1 = NEW_PLIST( T_PLIST, 7 );
 SET_LEN_PLIST( t_1, 7 );
 SET_ELM_PLIST( t_1, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_1, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_1, 3, INTOBJ_INT(3) );
 SET_ELM_PLIST( t_1, 4, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_1, 5, INTOBJ_INT(5) );
 SET_ELM_PLIST( t_1, 6, INTOBJ_INT(6) );
 SET_ELM_PLIST( t_1, 7, INTOBJ_INT(7) );
 if ( TNUM_OBJ( a_f ) == T_FUNCTION ) {
  CALL_XARGS( a_f, t_1 );
 }
 else {
  DoOperation2Args( CallFuncListOper, a_f, t_1 );
 }
 
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
 Obj  a_f )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "f0\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f0\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( f(  ) ); */
 t_1 = GF_Display;
 if ( TNUM_OBJ( a_f ) == T_FUNCTION ) {
  t_2 = CALL_0ARGS( a_f );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, a_f, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
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
 Obj  a_f )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "f1\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f1\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( f( 1 ) ); */
 t_1 = GF_Display;
 if ( TNUM_OBJ( a_f ) == T_FUNCTION ) {
  t_2 = CALL_1ARGS( a_f, INTOBJ_INT(1) );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, a_f, NewPlistFromArgs( INTOBJ_INT(1) ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
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
 Obj  a_f )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "f7\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f7\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( f( 1, 2, 3, 4, 5, 6, 7 ) ); */
 t_1 = GF_Display;
 t_3 = NEW_PLIST( T_PLIST, 7 );
 SET_LEN_PLIST( t_3, 7 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_3, 3, INTOBJ_INT(3) );
 SET_ELM_PLIST( t_3, 4, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_3, 5, INTOBJ_INT(5) );
 SET_ELM_PLIST( t_3, 6, INTOBJ_INT(6) );
 SET_ELM_PLIST( t_3, 7, INTOBJ_INT(7) );
 if ( TNUM_OBJ( a_f ) == T_FUNCTION ) {
  t_2 = CALL_XARGS( a_f, t_3 );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, a_f, t_3 );
 }
 CHECK_FUNC_RESULT( t_2 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
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
 Obj  a_func,
 Obj  a_args )
{
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return args; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_args;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 10 */
static Obj  HdlrFunc10 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* p0( fail ); */
 t_1 = GF_p0;
 t_2 = GC_fail;
 CHECK_BOUND( t_2, "fail" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 11 */
static Obj  HdlrFunc11 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* p1( fail ); */
 t_1 = GF_p1;
 t_2 = GC_fail;
 CHECK_BOUND( t_2, "fail" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
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
 
 /* p7( fail ); */
 t_1 = GF_p7;
 t_2 = GC_fail;
 CHECK_BOUND( t_2, "fail" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 13 */
static Obj  HdlrFunc13 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* f0( fail ); */
 t_1 = GF_f0;
 t_2 = GC_fail;
 CHECK_BOUND( t_2, "fail" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 14 */
static Obj  HdlrFunc14 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* f1( fail ); */
 t_1 = GF_f1;
 t_2 = GC_fail;
 CHECK_BOUND( t_2, "fail" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
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
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* f7( fail ); */
 t_1 = GF_f7;
 t_2 = GC_fail;
 CHECK_BOUND( t_2, "fail" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self )
{
 Obj l_IsCustomFunction = 0;
 Obj l_f = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 (void)l_IsCustomFunction;
 (void)l_f;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( "test with a regular function\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "test with a regular function\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* f := ReturnTrue; */
 t_1 = GC_ReturnTrue;
 CHECK_BOUND( t_1, "ReturnTrue" );
 l_f = t_1;
 
 /* p0( f ); */
 t_1 = GF_p0;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* p1( f ); */
 t_1 = GF_p1;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* p7( f ); */
 t_1 = GF_p7;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* f0( f ); */
 t_1 = GF_f0;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* f1( f ); */
 t_1 = GF_f1;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* f7( f ); */
 t_1 = GF_f7;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* Print( "test with a custom function\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "test with a custom function\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* IsCustomFunction := NewCategory( "IsCustomFunction", IsFunction ); */
 t_2 = GF_NewCategory;
 t_3 = MakeString( "IsCustomFunction" );
 t_4 = GC_IsFunction;
 CHECK_BOUND( t_4, "IsFunction" );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, t_4 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_IsCustomFunction = t_1;
 
 /* InstallMethod( CallFuncList, [ IsCustomFunction, IsList ], function ( func, args )
      return args;
  end ); */
 t_1 = GF_InstallMethod;
 t_2 = GC_CallFuncList;
 CHECK_BOUND( t_2, "CallFuncList" );
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_3, 1, l_IsCustomFunction );
 CHANGED_BAG( t_3 );
 t_4 = GC_IsList;
 CHECK_BOUND( t_4, "IsList" );
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = NewFunction( NameFunc[9], 2, ArgStringToList("func,args"), HdlrFunc9 );
 SET_ENVI_FUNC( t_4, STATE(CurrLVars) );
 t_5 = NewFunctionBody();
 SET_STARTLINE_BODY(t_5, 49);
 SET_ENDLINE_BODY(t_5, 49);
 SET_FILENAME_BODY(t_5, FileName);
 SET_BODY_FUNC(t_4, t_5);
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_3ARGS( t_1, t_2, t_3, t_4 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3, t_4 ) );
 }
 
 /* f := Objectify( NewType( NewFamily( "CustomFunctionFamily" ), IsCustomFunction and IsPositionalObjectRep ), [  ] ); */
 t_2 = GF_Objectify;
 t_4 = GF_NewType;
 t_6 = GF_NewFamily;
 t_7 = MakeString( "CustomFunctionFamily" );
 if ( TNUM_OBJ( t_6 ) == T_FUNCTION ) {
  t_5 = CALL_1ARGS( t_6, t_7 );
 }
 else {
  t_5 = DoOperation2Args( CallFuncListOper, t_6, NewPlistFromArgs( t_7 ) );
 }
 CHECK_FUNC_RESULT( t_5 );
 if ( l_IsCustomFunction == False ) {
  t_6 = l_IsCustomFunction;
 }
 else if ( l_IsCustomFunction == True ) {
  t_7 = GC_IsPositionalObjectRep;
  CHECK_BOUND( t_7, "IsPositionalObjectRep" );
  CHECK_BOOL( t_7 );
  t_6 = t_7;
 }
 else if (IS_FILTER( l_IsCustomFunction ) ) {
  t_8 = GC_IsPositionalObjectRep;
  CHECK_BOUND( t_8, "IsPositionalObjectRep" );
  t_6 = NewAndFilter( l_IsCustomFunction, t_8 );
 }
 else {
  RequireArgumentEx(0, l_IsCustomFunction, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 if ( TNUM_OBJ( t_4 ) == T_FUNCTION ) {
  t_3 = CALL_2ARGS( t_4, t_5, t_6 );
 }
 else {
  t_3 = DoOperation2Args( CallFuncListOper, t_4, NewPlistFromArgs( t_5, t_6 ) );
 }
 CHECK_FUNC_RESULT( t_3 );
 t_4 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_4, 0 );
 if ( TNUM_OBJ( t_2 ) == T_FUNCTION ) {
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 }
 else {
  t_1 = DoOperation2Args( CallFuncListOper, t_2, NewPlistFromArgs( t_3, t_4 ) );
 }
 CHECK_FUNC_RESULT( t_1 );
 l_f = t_1;
 
 /* p0( f ); */
 t_1 = GF_p0;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* p1( f ); */
 t_1 = GF_p1;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* p7( f ); */
 t_1 = GF_p7;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* f0( f ); */
 t_1 = GF_f0;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* f1( f ); */
 t_1 = GF_f1;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* f7( f ); */
 t_1 = GF_f7;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, l_f );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( l_f ) );
 }
 
 /* BreakOnError := false; */
 t_1 = False;
 AssGVar( G_BreakOnError, t_1 );
 
 /* Print( "test with a non-function\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "test with a non-function\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* CALL_WITH_CATCH( function (  )
      p0( fail );
      return;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[10], 0, 0, HdlrFunc10 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 64);
 SET_ENDLINE_BODY(t_3, 64);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( function (  )
      p1( fail );
      return;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[11], 0, 0, HdlrFunc11 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 65);
 SET_ENDLINE_BODY(t_3, 65);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( function (  )
      p7( fail );
      return;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[12], 0, 0, HdlrFunc12 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 66);
 SET_ENDLINE_BODY(t_3, 66);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( function (  )
      f0( fail );
      return;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[13], 0, 0, HdlrFunc13 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 68);
 SET_ENDLINE_BODY(t_3, 68);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( function (  )
      f1( fail );
      return;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[14], 0, 0, HdlrFunc14 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 69);
 SET_ENDLINE_BODY(t_3, 69);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( function (  )
      f7( fail );
      return;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[15], 0, 0, HdlrFunc15 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 70);
 SET_ENDLINE_BODY(t_3, 70);
 SET_FILENAME_BODY(t_3, FileName);
 SET_BODY_FUNC(t_2, t_3);
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
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

/* handler for function 1 */
static Obj  HdlrFunc1 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* p0 := function ( f )
      Print( "p0\n" );
      f(  );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 1, ArgStringToList("f"), HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 2);
 SET_ENDLINE_BODY(t_2, 5);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_p0, t_1 );
 
 /* p1 := function ( f )
      Print( "p1\n" );
      f( 1 );
      return;
  end; */
 t_1 = NewFunction( NameFunc[3], 1, ArgStringToList("f"), HdlrFunc3 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 7);
 SET_ENDLINE_BODY(t_2, 10);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_p1, t_1 );
 
 /* p7 := function ( f )
      Print( "p7\n" );
      f( 1, 2, 3, 4, 5, 6, 7 );
      return;
  end; */
 t_1 = NewFunction( NameFunc[4], 1, ArgStringToList("f"), HdlrFunc4 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 12);
 SET_ENDLINE_BODY(t_2, 15);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_p7, t_1 );
 
 /* f0 := function ( f )
      Print( "f0\n" );
      Display( f(  ) );
      return;
  end; */
 t_1 = NewFunction( NameFunc[5], 1, ArgStringToList("f"), HdlrFunc5 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 18);
 SET_ENDLINE_BODY(t_2, 21);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_f0, t_1 );
 
 /* f1 := function ( f )
      Print( "f1\n" );
      Display( f( 1 ) );
      return;
  end; */
 t_1 = NewFunction( NameFunc[6], 1, ArgStringToList("f"), HdlrFunc6 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 23);
 SET_ENDLINE_BODY(t_2, 26);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_f1, t_1 );
 
 /* f7 := function ( f )
      Print( "f7\n" );
      Display( f( 1, 2, 3, 4, 5, 6, 7 ) );
      return;
  end; */
 t_1 = NewFunction( NameFunc[7], 1, ArgStringToList("f"), HdlrFunc7 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 28);
 SET_ENDLINE_BODY(t_2, 31);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_f7, t_1 );
 
 /* runtest := function (  )
      local IsCustomFunction, f;
      Print( "test with a regular function\n" );
      f := ReturnTrue;
      p0( f );
      p1( f );
      p7( f );
      f0( f );
      f1( f );
      f7( f );
      Print( "test with a custom function\n" );
      IsCustomFunction := NewCategory( "IsCustomFunction", IsFunction );
      InstallMethod( CallFuncList, [ IsCustomFunction, IsList ], function ( func, args )
            return args;
        end );
      f := Objectify( NewType( NewFamily( "CustomFunctionFamily" ), IsCustomFunction and IsPositionalObjectRep ), [  ] );
      p0( f );
      p1( f );
      p7( f );
      f0( f );
      f1( f );
      f7( f );
      BreakOnError := false;
      Print( "test with a non-function\n" );
      CALL_WITH_CATCH( function (  )
            p0( fail );
            return;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            p1( fail );
            return;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            p7( fail );
            return;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            f0( fail );
            return;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            f1( fail );
            return;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            f7( fail );
            return;
        end, [  ] );
      return;
  end; */
 t_1 = NewFunction( NameFunc[8], 0, 0, HdlrFunc8 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 33);
 SET_ENDLINE_BODY(t_2, 72);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_runtest, t_1 );
 
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
 G_ReturnTrue = GVarName( "ReturnTrue" );
 G_fail = GVarName( "fail" );
 G_Print = GVarName( "Print" );
 G_CALL__WITH__CATCH = GVarName( "CALL_WITH_CATCH" );
 G_p0 = GVarName( "p0" );
 G_p1 = GVarName( "p1" );
 G_p7 = GVarName( "p7" );
 G_f0 = GVarName( "f0" );
 G_Display = GVarName( "Display" );
 G_f1 = GVarName( "f1" );
 G_f7 = GVarName( "f7" );
 G_runtest = GVarName( "runtest" );
 G_NewCategory = GVarName( "NewCategory" );
 G_IsFunction = GVarName( "IsFunction" );
 G_InstallMethod = GVarName( "InstallMethod" );
 G_CallFuncList = GVarName( "CallFuncList" );
 G_IsList = GVarName( "IsList" );
 G_Objectify = GVarName( "Objectify" );
 G_NewType = GVarName( "NewType" );
 G_NewFamily = GVarName( "NewFamily" );
 G_IsPositionalObjectRep = GVarName( "IsPositionalObjectRep" );
 G_BreakOnError = GVarName( "BreakOnError" );
 
 /* record names used in handlers */
 
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
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitCopyGVar( "ReturnTrue", &GC_ReturnTrue );
 InitCopyGVar( "fail", &GC_fail );
 InitFopyGVar( "Print", &GF_Print );
 InitFopyGVar( "CALL_WITH_CATCH", &GF_CALL__WITH__CATCH );
 InitFopyGVar( "p0", &GF_p0 );
 InitFopyGVar( "p1", &GF_p1 );
 InitFopyGVar( "p7", &GF_p7 );
 InitFopyGVar( "f0", &GF_f0 );
 InitFopyGVar( "Display", &GF_Display );
 InitFopyGVar( "f1", &GF_f1 );
 InitFopyGVar( "f7", &GF_f7 );
 InitFopyGVar( "NewCategory", &GF_NewCategory );
 InitCopyGVar( "IsFunction", &GC_IsFunction );
 InitFopyGVar( "InstallMethod", &GF_InstallMethod );
 InitCopyGVar( "CallFuncList", &GC_CallFuncList );
 InitCopyGVar( "IsList", &GC_IsList );
 InitFopyGVar( "Objectify", &GF_Objectify );
 InitFopyGVar( "NewType", &GF_NewType );
 InitFopyGVar( "NewFamily", &GF_NewFamily );
 InitCopyGVar( "IsPositionalObjectRep", &GC_IsPositionalObjectRep );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "callfunc.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "callfunc.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "callfunc.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "callfunc.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "callfunc.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "callfunc.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "callfunc.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "callfunc.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "callfunc.g:NameFunc[4]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc5, "callfunc.g:HdlrFunc5("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[5]), "callfunc.g:NameFunc[5]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc6, "callfunc.g:HdlrFunc6("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[6]), "callfunc.g:NameFunc[6]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc7, "callfunc.g:HdlrFunc7("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[7]), "callfunc.g:NameFunc[7]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc8, "callfunc.g:HdlrFunc8("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[8]), "callfunc.g:NameFunc[8]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc9, "callfunc.g:HdlrFunc9("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[9]), "callfunc.g:NameFunc[9]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc10, "callfunc.g:HdlrFunc10("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[10]), "callfunc.g:NameFunc[10]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc11, "callfunc.g:HdlrFunc11("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[11]), "callfunc.g:NameFunc[11]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc12, "callfunc.g:HdlrFunc12("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[12]), "callfunc.g:NameFunc[12]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc13, "callfunc.g:HdlrFunc13("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[13]), "callfunc.g:NameFunc[13]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc14, "callfunc.g:HdlrFunc14("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[14]), "callfunc.g:NameFunc[14]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc15, "callfunc.g:HdlrFunc15("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[15]), "callfunc.g:NameFunc[15]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "callfunc.g" );
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
 .name        = "callfunc.g",
 .crc         = 6760218,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__callfunc ( void )
{
 return &module;
}

/* compiled code ends here */
