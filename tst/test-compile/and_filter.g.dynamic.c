/* C file produced by GAC */
#include "compiled.h"
#define FILE_CRC  "-101028112"

/* global variables used in handlers */
static GVar G_Print;
static Obj  GF_Print;
static GVar G_CALL__WITH__CATCH;
static Obj  GF_CALL__WITH__CATCH;
static GVar G_runtest;
static GVar G_IsAssociative;
static Obj  GC_IsAssociative;
static GVar G_BreakOnError;
static GVar G_Center;
static Obj  GC_Center;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[9];
static Obj FileName;

/* handler for function 3 */
static Obj  HdlrFunc3 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return false and 1; */
 t_2 = False;
 if ( t_2 == False ) {
  t_1 = t_2;
 }
 else if ( t_2 == True ) {
  CHECK_BOOL( INTOBJ_INT(1) );
  t_1 = INTOBJ_INT(1);
 }
 else if (IS_FILTER( t_2 ) ) {
  t_1 = NewAndFilter( t_2, INTOBJ_INT(1) );
 }
 else {
  RequireArgumentEx(0, t_2, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
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
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return true or 1; */
 t_3 = True;
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (t_2 ? True : False);
 if ( t_1 == False ) {
  CHECK_BOOL( INTOBJ_INT(1) );
  t_3 = (Obj)(UInt)(INTOBJ_INT(1) != False);
  t_1 = (t_3 ? True : False);
 }
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
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
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return Center and IsAssociative; */
 t_2 = GC_Center;
 CHECK_BOUND( t_2, "Center" );
 if ( t_2 == False ) {
  t_1 = t_2;
 }
 else if ( t_2 == True ) {
  t_3 = GC_IsAssociative;
  CHECK_BOUND( t_3, "IsAssociative" );
  CHECK_BOOL( t_3 );
  t_1 = t_3;
 }
 else if (IS_FILTER( t_2 ) ) {
  t_4 = GC_IsAssociative;
  CHECK_BOUND( t_4, "IsAssociative" );
  t_1 = NewAndFilter( t_2, t_4 );
 }
 else {
  RequireArgumentEx(0, t_2, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return IsAssociative and Center; */
 t_2 = GC_IsAssociative;
 CHECK_BOUND( t_2, "IsAssociative" );
 if ( t_2 == False ) {
  t_1 = t_2;
 }
 else if ( t_2 == True ) {
  t_3 = GC_Center;
  CHECK_BOUND( t_3, "Center" );
  CHECK_BOOL( t_3 );
  t_1 = t_3;
 }
 else if (IS_FILTER( t_2 ) ) {
  t_4 = GC_Center;
  CHECK_BOUND( t_4, "Center" );
  t_1 = NewAndFilter( t_2, t_4 );
 }
 else {
  RequireArgumentEx(0, t_2, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 7 */
static Obj  HdlrFunc7 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return 1 and false; */
 if ( INTOBJ_INT(1) == False ) {
  t_1 = INTOBJ_INT(1);
 }
 else if ( INTOBJ_INT(1) == True ) {
  t_2 = False;
  t_1 = t_2;
 }
 else if (IS_FILTER( INTOBJ_INT(1) ) ) {
  t_3 = False;
  t_1 = NewAndFilter( INTOBJ_INT(1), t_3 );
 }
 else {
  RequireArgumentEx(0, INTOBJ_INT(1), "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 
 /* return 1 or true; */
 CHECK_BOOL( INTOBJ_INT(1) );
 t_2 = (Obj)(UInt)(INTOBJ_INT(1) != False);
 t_1 = (t_2 ? True : False);
 if ( t_1 == False ) {
  t_4 = True;
  t_3 = (Obj)(UInt)(t_4 != False);
  t_1 = (t_3 ? True : False);
 }
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 2 */
static Obj  HdlrFunc2 (
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
 
 /* Print( false and 1, "\n" ); */
 t_1 = GF_Print;
 t_3 = False;
 if ( t_3 == False ) {
  t_2 = t_3;
 }
 else if ( t_3 == True ) {
  CHECK_BOOL( INTOBJ_INT(1) );
  t_2 = INTOBJ_INT(1);
 }
 else if (IS_FILTER( t_3 ) ) {
  t_2 = NewAndFilter( t_3, INTOBJ_INT(1) );
 }
 else {
  RequireArgumentEx(0, t_3, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( true or 1, "\n" ); */
 t_1 = GF_Print;
 t_4 = True;
 t_3 = (Obj)(UInt)(t_4 != False);
 t_2 = (t_3 ? True : False);
 if ( t_2 == False ) {
  CHECK_BOOL( INTOBJ_INT(1) );
  t_4 = (Obj)(UInt)(INTOBJ_INT(1) != False);
  t_2 = (t_4 ? True : False);
 }
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* Print( function (  )
        return false and 1;
    end(  ), "\n" ); */
 t_1 = GF_Print;
 t_3 = NewFunction( NameFunc[3], 0, 0, HdlrFunc3 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 5);
 SET_ENDLINE_BODY(t_4, 5);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
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
 
 /* Print( function (  )
        return true or 1;
    end(  ), "\n" ); */
 t_1 = GF_Print;
 t_3 = NewFunction( NameFunc[4], 0, 0, HdlrFunc4 );
 SET_ENVI_FUNC( t_3, STATE(CurrLVars) );
 t_4 = NewFunctionBody();
 SET_STARTLINE_BODY(t_4, 6);
 SET_ENDLINE_BODY(t_4, 6);
 SET_FILENAME_BODY(t_4, FileName);
 SET_BODY_FUNC(t_3, t_4);
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
 
 /* Print( IsAssociative and IsAssociative, "\n" ); */
 t_1 = GF_Print;
 t_3 = GC_IsAssociative;
 CHECK_BOUND( t_3, "IsAssociative" );
 if ( t_3 == False ) {
  t_2 = t_3;
 }
 else if ( t_3 == True ) {
  t_4 = GC_IsAssociative;
  CHECK_BOUND( t_4, "IsAssociative" );
  CHECK_BOOL( t_4 );
  t_2 = t_4;
 }
 else if (IS_FILTER( t_3 ) ) {
  t_5 = GC_IsAssociative;
  CHECK_BOUND( t_5, "IsAssociative" );
  t_2 = NewAndFilter( t_3, t_5 );
 }
 else {
  RequireArgumentEx(0, t_3, "<expr>",
  "must be 'true' or 'false' or a filter" );
 }
 t_3 = MakeString( "\n" );
 if ( TNUM_OBJ( t_1 ) == T_FUNCTION ) {
  CALL_2ARGS( t_1, t_2, t_3 );
 }
 else {
  DoOperation2Args( CallFuncListOper, t_1, NewPlistFromArgs( t_2, t_3 ) );
 }
 
 /* BreakOnError := false; */
 t_1 = False;
 AssGVar( G_BreakOnError, t_1 );
 
 /* CALL_WITH_CATCH( function (  )
      return Center and IsAssociative;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[5], 0, 0, HdlrFunc5 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 13);
 SET_ENDLINE_BODY(t_3, 13);
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
      return IsAssociative and Center;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[6], 0, 0, HdlrFunc6 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 16);
 SET_ENDLINE_BODY(t_3, 16);
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
      return 1 and false;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[7], 0, 0, HdlrFunc7 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 18);
 SET_ENDLINE_BODY(t_3, 18);
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
      return 1 or true;
  end, [  ] ); */
 t_1 = GF_CALL__WITH__CATCH;
 t_2 = NewFunction( NameFunc[8], 0, 0, HdlrFunc8 );
 SET_ENVI_FUNC( t_2, STATE(CurrLVars) );
 t_3 = NewFunctionBody();
 SET_STARTLINE_BODY(t_3, 19);
 SET_ENDLINE_BODY(t_3, 19);
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
 
 /* runtest := function (  )
      Print( false and 1, "\n" );
      Print( true or 1, "\n" );
      Print( function (  )
              return false and 1;
          end(  ), "\n" );
      Print( function (  )
              return true or 1;
          end(  ), "\n" );
      Print( IsAssociative and IsAssociative, "\n" );
      BreakOnError := false;
      CALL_WITH_CATCH( function (  )
            return Center and IsAssociative;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            return IsAssociative and Center;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            return 1 and false;
        end, [  ] );
      CALL_WITH_CATCH( function (  )
            return 1 or true;
        end, [  ] );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewFunctionBody();
 SET_STARTLINE_BODY(t_2, 1);
 SET_ENDLINE_BODY(t_2, 21);
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
 G_CALL__WITH__CATCH = GVarName( "CALL_WITH_CATCH" );
 G_runtest = GVarName( "runtest" );
 G_IsAssociative = GVarName( "IsAssociative" );
 G_BreakOnError = GVarName( "BreakOnError" );
 G_Center = GVarName( "Center" );
 
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
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "Print", &GF_Print );
 InitFopyGVar( "CALL_WITH_CATCH", &GF_CALL__WITH__CATCH );
 InitCopyGVar( "IsAssociative", &GC_IsAssociative );
 InitCopyGVar( "Center", &GC_Center );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "and_filter.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "and_filter.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "and_filter.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "and_filter.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "and_filter.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "and_filter.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "and_filter.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "and_filter.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "and_filter.g:NameFunc[4]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc5, "and_filter.g:HdlrFunc5("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[5]), "and_filter.g:NameFunc[5]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc6, "and_filter.g:HdlrFunc6("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[6]), "and_filter.g:NameFunc[6]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc7, "and_filter.g:HdlrFunc7("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[7]), "and_filter.g:NameFunc[7]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc8, "and_filter.g:HdlrFunc8("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[8]), "and_filter.g:NameFunc[8]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "and_filter.g" );
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
 .name        = "and_filter.g",
 .crc         = -101028112,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}

/* compiled code ends here */
