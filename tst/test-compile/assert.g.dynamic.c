/* C file produced by GAC */
#include "compiled.h"
#define FILE_CRC  "47091879"

/* global variables used in handlers */
static GVar G_Print;
static Obj  GF_Print;
static GVar G_SetAssertionLevel;
static Obj  GF_SetAssertionLevel;
static GVar G_AssertionLevel;
static Obj  GF_AssertionLevel;
static GVar G_runtest;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[3];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* Print( AssertionLevel(  ), "\n" ); */
 t_1 = GF_Print;
 t_3 = GF_AssertionLevel;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_0ARGS( t_3 );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 1 ) {
  t_2 = False;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   t_2 = MakeString( "fail-A" );
   if ( t_2 != (Obj)(UInt)0 ){
     if ( IS_STRING_REP ( t_2 ) )
       PrintString1( t_2);
     else
       PrintObj(t_2);
   }
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 1 ) {
  t_2 = False;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   AssertionFailure();
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 0 ) {
  t_2 = True;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   t_2 = MakeString( "fail-B" );
   if ( t_2 != (Obj)(UInt)0 ){
     if ( IS_STRING_REP ( t_2 ) )
       PrintString1( t_2);
     else
       PrintObj(t_2);
   }
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 0 ) {
  t_2 = True;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   AssertionFailure();
  }
 }
 
 /* SetAssertionLevel( 2 ); */
 t_1 = GF_SetAssertionLevel;
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_1ARGS( t_1, INTOBJ_INT(2) );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( INTOBJ_INT(2) ) );
 }
 
 /* Print( AssertionLevel(  ), "\n" ); */
 t_1 = GF_Print;
 t_3 = GF_AssertionLevel;
 if ( TNUM_OBJ( t_3 ) == T_FUNCTION ) {
  t_2 = CALL_0ARGS( t_3 );
 }
 else {
  t_2 = DoOperation2Args( CallFuncListOper, t_3, NewPlistFromArgs( ) );
 }
 CHECK_FUNC_RESULT( t_2 );
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 3 ) {
  t_2 = False;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   t_2 = MakeString( "fail-C" );
   if ( t_2 != (Obj)(UInt)0 ){
     if ( IS_STRING_REP ( t_2 ) )
       PrintString1( t_2);
     else
       PrintObj(t_2);
   }
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 3 ) {
  t_2 = False;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   AssertionFailure();
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 2 ) {
  t_2 = True;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   t_2 = MakeString( "fail-D" );
   if ( t_2 != (Obj)(UInt)0 ){
     if ( IS_STRING_REP ( t_2 ) )
       PrintString1( t_2);
     else
       PrintObj(t_2);
   }
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 2 ) {
  t_2 = True;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   AssertionFailure();
  }
 }
 
 /* Assert( ... ); */
 if ( STATE(CurrentAssertionLevel) >= 2 ) {
  t_2 = False;
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( ! t_1 ) {
   t_2 = MakeString( "pass!\n" );
   if ( t_2 != (Obj)(UInt)0 ){
     if ( IS_STRING_REP ( t_2 ) )
       PrintString1( t_2);
     else
       PrintObj(t_2);
   }
  }
 }
 
 /* Print( "end of function\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "end of function\n" );
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
 
 /* runtest := function (  )
      Print( AssertionLevel(  ), "\n" );
      Assert( 1, false, "fail-A" );
      Assert( 1, false );
      Assert( 0, true, "fail-B" );
      Assert( 0, true );
      SetAssertionLevel( 2 );
      Print( AssertionLevel(  ), "\n" );
      Assert( 3, false, "fail-C" );
      Assert( 3, false );
      Assert( 2, true, "fail-D" );
      Assert( 2, true );
      Assert( 2, false, "pass!\n" );
      Print( "end of function\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 1);
 SET_ENDLINE_BODY(t_2, 18);
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
 G_Print = GVarName( "Print" );
 G_SetAssertionLevel = GVarName( "SetAssertionLevel" );
 G_AssertionLevel = GVarName( "AssertionLevel" );
 G_runtest = GVarName( "runtest" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 NameFunc[1] = 0;
 NameFunc[2] = 0;
 
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "Print", &GF_Print );
 InitFopyGVar( "SetAssertionLevel", &GF_SetAssertionLevel );
 InitFopyGVar( "AssertionLevel", &GF_AssertionLevel );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "assert.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "assert.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "assert.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "assert.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "assert.g:NameFunc[2]("FILE_CRC")" );
 
 return 0;
 
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
 Obj func1;
 Obj body1;
 
 /* Complete Copy/Fopy registration */
 UpdateCopyFopyInfo();
 FileName = MakeImmString( "assert.g" );
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
 .name        = "assert.g",
 .crc         = 47091879,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}

/* compiled code ends here */
