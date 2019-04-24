/* C file produced by GAC */
#include "compiled.h"
#define FILE_CRC  "77795076"

/* global variables used in handlers */
static GVar G_CALL__WITH__CATCH;
static Obj  GF_CALL__WITH__CATCH;
static GVar G_range2;
static Obj  GC_range2;
static GVar G_range3;
static Obj  GC_range3;
static GVar G_runtest;
static GVar G_BreakOnError;
static GVar G_Display;
static Obj  GF_Display;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[5];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_a,
 Obj  a_b )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return [ a .. b ]; */
 t_1 = Range2Check( a_a, a_b );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self,
 Obj  a_a,
 Obj  a_b,
 Obj  a_c )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return [ a, b .. c ]; */
 t_1 = Range3Check( a_a, a_b, a_c );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 4 */
static Obj  HdlrFunc4 (
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
 
 /* BreakOnError := false; */
 t_1 = False;
 AssGVar( G_BreakOnError, t_1 );
 
 /* CALL_WITH_CATCH( range2, [ 1, 2 ^ 80 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range2;
 CHECK_BOUND( t_2, "range2" );
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(1) );
 t_4 = POW( INTOBJ_INT(2), INTOBJ_INT(80) );
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( range2, [ - 2 ^ 80, 0 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range2;
 CHECK_BOUND( t_2, "range2" );
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 t_5 = POW( INTOBJ_INT(2), INTOBJ_INT(80) );
 C_AINV_FIA( t_4, t_5 )
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(0) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( range3, [ 1, 2, 2 ^ 80 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range3;
 CHECK_BOUND( t_2, "range3" );
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(1) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(2) );
 t_4 = POW( INTOBJ_INT(2), INTOBJ_INT(80) );
 SET_ELM_PLIST( t_3, 3, t_4 );
 CHANGED_BAG( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( range3, [ - 2 ^ 80, 0, 1 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range3;
 CHECK_BOUND( t_2, "range3" );
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 t_5 = POW( INTOBJ_INT(2), INTOBJ_INT(80) );
 C_AINV_FIA( t_4, t_5 )
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(0) );
 SET_ELM_PLIST( t_3, 3, INTOBJ_INT(1) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* CALL_WITH_CATCH( range3, [ 0, 2 ^ 80, 2 ^ 81 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range3;
 CHECK_BOUND( t_2, "range3" );
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(0) );
 t_4 = POW( INTOBJ_INT(2), INTOBJ_INT(80) );
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = POW( INTOBJ_INT(2), INTOBJ_INT(81) );
 SET_ELM_PLIST( t_3, 3, t_4 );
 CHANGED_BAG( t_3 );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Display( [ 1, 2 .. 2 ] ); */
 t_1 = GF_Display;
 t_2 = Range3Check( INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(2) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* CALL_WITH_CATCH( range3, [ 2, 2, 2 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range3;
 CHECK_BOUND( t_2, "range3" );
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_3, 3, INTOBJ_INT(2) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Display( [ 2, 4 .. 6 ] ); */
 t_1 = GF_Display;
 t_2 = Range3Check( INTOBJ_INT(2), INTOBJ_INT(4), INTOBJ_INT(6) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* CALL_WITH_CATCH( range3, [ 2, 4, 7 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range3;
 CHECK_BOUND( t_2, "range3" );
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_3, 3, INTOBJ_INT(7) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Display( [ 2, 4 .. 2 ] ); */
 t_1 = GF_Display;
 t_2 = Range3Check( INTOBJ_INT(2), INTOBJ_INT(4), INTOBJ_INT(2) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( [ 2, 4 .. 0 ] ); */
 t_1 = GF_Display;
 t_2 = Range3Check( INTOBJ_INT(2), INTOBJ_INT(4), INTOBJ_INT(0) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* CALL_WITH_CATCH( range3, [ 4, 2, 1 ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = GC_range3;
 CHECK_BOUND( t_2, "range3" );
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(4) );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(2) );
 SET_ELM_PLIST( t_3, 3, INTOBJ_INT(1) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Display( [ 4, 2 .. 0 ] ); */
 t_1 = GF_Display;
 t_2 = Range3Check( INTOBJ_INT(4), INTOBJ_INT(2), INTOBJ_INT(0) );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, t_2 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2 ) );
 }
 
 /* Display( [ 4, 2 .. 8 ] ); */
 t_1 = GF_Display;
 t_2 = Range3Check( INTOBJ_INT(4), INTOBJ_INT(2), INTOBJ_INT(8) );
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

/* handler for function 1 */
static Obj  HdlrFunc1 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* range2 := function ( a, b )
      return [ a .. b ];
  end; */
 t_1 = NewFunction( NameFunc[2], 2, ArgStringToList("a,b"), HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 1);
 SET_ENDLINE_BODY(t_2, 1);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_range2, t_1 );
 
 /* range3 := function ( a, b, c )
      return [ a, b .. c ];
  end; */
 t_1 = NewFunction( NameFunc[3], 3, ArgStringToList("a,b,c"), HdlrFunc3 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 2);
 SET_ENDLINE_BODY(t_2, 2);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 AssGVar( G_range3, t_1 );
 
 /* runtest := function (  )
      BreakOnError := false;
      CALL_WITH_CATCH( range2, [ 1, 2 ^ 80 ] );
      CALL_WITH_CATCH( range2, [ - 2 ^ 80, 0 ] );
      CALL_WITH_CATCH( range3, [ 1, 2, 2 ^ 80 ] );
      CALL_WITH_CATCH( range3, [ - 2 ^ 80, 0, 1 ] );
      CALL_WITH_CATCH( range3, [ 0, 2 ^ 80, 2 ^ 81 ] );
      Display( [ 1, 2 .. 2 ] );
      CALL_WITH_CATCH( range3, [ 2, 2, 2 ] );
      Display( [ 2, 4 .. 6 ] );
      CALL_WITH_CATCH( range3, [ 2, 4, 7 ] );
      Display( [ 2, 4 .. 2 ] );
      Display( [ 2, 4 .. 0 ] );
      CALL_WITH_CATCH( range3, [ 4, 2, 1 ] );
      Display( [ 4, 2 .. 0 ] );
      Display( [ 4, 2 .. 8 ] );
      return;
  end; */
 t_1 = NewFunction( NameFunc[4], 0, 0, HdlrFunc4 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 4);
 SET_ENDLINE_BODY(t_2, 26);
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
 G_CALL__WITH__CATCH = GVarName( "CALL_WITH_CATCH" );
 G_range2 = GVarName( "range2" );
 G_range3 = GVarName( "range3" );
 G_runtest = GVarName( "runtest" );
 G_BreakOnError = GVarName( "BreakOnError" );
 G_Display = GVarName( "Display" );
 
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
 InitFopyGVar( "CALL_WITH_CATCH", &GF_CALL__WITH__CATCH );
 InitCopyGVar( "range2", &GC_range2 );
 InitCopyGVar( "range3", &GC_range3 );
 InitFopyGVar( "Display", &GF_Display );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "ranges.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "ranges.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "ranges.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "ranges.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "ranges.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "ranges.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "ranges.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "ranges.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "ranges.g:NameFunc[4]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "ranges.g" );
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
 .type        = MODULE_DYNAMIC,
 .name        = "ranges.g",
 .crc         = 77795076,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}

/* compiled code ends here */
