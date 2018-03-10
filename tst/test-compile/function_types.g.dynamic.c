/* C file produced by GAC */
#include <src/compiled.h>
#define FILE_CRC  "94037544"

/* global variables used in handlers */
static GVar G_Print;
static Obj  GF_Print;
static GVar G_f1;
static Obj  GF_f1;
static GVar G_f2;
static Obj  GF_f2;
static GVar G_f3;
static Obj  GF_f3;
static GVar G_f4;
static Obj  GF_f4;
static GVar G_runtest;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[7];
static Obj FileName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_a )
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
 
 /* Print( "f1:", a, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f1:" );
 t_3 = MakeString( "\n" );
 CALL_3ARGS( t_1, t_2, a_a, t_3 );
 
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
 Obj  a_a,
 Obj  a_b )
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
 
 /* Print( "f2:", a, ":", b, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f2:" );
 t_3 = MakeString( ":" );
 t_4 = MakeString( "\n" );
 CALL_5ARGS( t_1, t_2, a_a, t_3, a_b, t_4 );
 
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
 Obj  a_a )
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
 
 /* Print( "f3:", a, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f3:" );
 t_3 = MakeString( "\n" );
 CALL_3ARGS( t_1, t_2, a_a, t_3 );
 
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
 Obj  args )
{
 Obj  a_a;
 Obj  a_b;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 CHECK_NR_AT_LEAST_ARGS( 2, args )
 a_a = ELM_PLIST( args, 1 );
 Obj x_temp_range = Range2Check(INTOBJ_INT(2), INTOBJ_INT(LEN_PLIST(args)));
 a_b = ELMS_LIST(args , x_temp_range);
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Print( "f4:", a, ":", b, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "f4:" );
 t_3 = MakeString( ":" );
 t_4 = MakeString( "\n" );
 CALL_5ARGS( t_1, t_2, a_a, t_3, a_b, t_4 );
 
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
 Obj  self )
{
 Obj t_1 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* f1( 2 ); */
 t_1 = GF_f1;
 CALL_1ARGS( t_1, INTOBJ_INT(2) );
 
 /* f2( 2, 3 ); */
 t_1 = GF_f2;
 CALL_2ARGS( t_1, INTOBJ_INT(2), INTOBJ_INT(3) );
 
 /* f3(  ); */
 t_1 = GF_f3;
 CALL_0ARGS( t_1 );
 
 /* f3( 2 ); */
 t_1 = GF_f3;
 CALL_1ARGS( t_1, INTOBJ_INT(2) );
 
 /* f3( 2, 3, 4 ); */
 t_1 = GF_f3;
 CALL_3ARGS( t_1, INTOBJ_INT(2), INTOBJ_INT(3), INTOBJ_INT(4) );
 
 /* f4( 1 ); */
 t_1 = GF_f4;
 CALL_1ARGS( t_1, INTOBJ_INT(1) );
 
 /* f4( 1, 2 ); */
 t_1 = GF_f4;
 CALL_2ARGS( t_1, INTOBJ_INT(1), INTOBJ_INT(2) );
 
 /* f4( 1, 2, 3 ); */
 t_1 = GF_f4;
 CALL_3ARGS( t_1, INTOBJ_INT(1), INTOBJ_INT(2), INTOBJ_INT(3) );
 
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
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* f1 := function ( a )
      Print( "f1:", a, "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 1, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 1);
 SET_ENDLINE_BODY(t_2, 3);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_f1, t_1 );
 
 /* f2 := function ( a, b )
      Print( "f2:", a, ":", b, "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[3], 2, 0, HdlrFunc3 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 5);
 SET_ENDLINE_BODY(t_2, 7);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_f2, t_1 );
 
 /* f3 := function ( a... )
      Print( "f3:", a, "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[4], -1, 0, HdlrFunc4 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 9);
 SET_ENDLINE_BODY(t_2, 11);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_f3, t_1 );
 
 /* f4 := function ( a, b... )
      Print( "f4:", a, ":", b, "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[5], -2, 0, HdlrFunc5 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 13);
 SET_ENDLINE_BODY(t_2, 15);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_f4, t_1 );
 
 /* runtest := function (  )
      f1( 2 );
      f2( 2, 3 );
      f3(  );
      f3( 2 );
      f3( 2, 3, 4 );
      f4( 1 );
      f4( 1, 2 );
      f4( 1, 2, 3 );
      return;
  end; */
 t_1 = NewFunction( NameFunc[6], 0, 0, HdlrFunc6 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 17);
 SET_ENDLINE_BODY(t_2, 26);
 SET_FILENAME_BODY(t_2, FileName);
 SET_BODY_FUNC(t_1, t_2);
 CHANGED_BAG( STATE(CurrLVars) );
 AssGVar( G_runtest, t_1 );
 
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
 G_Print = GVarName( "Print" );
 G_f1 = GVarName( "f1" );
 G_f2 = GVarName( "f2" );
 G_f3 = GVarName( "f3" );
 G_f4 = GVarName( "f4" );
 G_runtest = GVarName( "runtest" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 NameFunc[1] = 0;
 NameFunc[2] = 0;
 NameFunc[3] = 0;
 NameFunc[4] = 0;
 NameFunc[5] = 0;
 NameFunc[6] = 0;
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "Print", &GF_Print );
 InitFopyGVar( "f1", &GF_f1 );
 InitFopyGVar( "f2", &GF_f2 );
 InitFopyGVar( "f3", &GF_f3 );
 InitFopyGVar( "f4", &GF_f4 );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "function_types.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "function_types.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "function_types.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "function_types.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "function_types.g:NameFunc[2]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc3, "function_types.g:HdlrFunc3("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[3]), "function_types.g:NameFunc[3]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc4, "function_types.g:HdlrFunc4("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[4]), "function_types.g:NameFunc[4]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc5, "function_types.g:HdlrFunc5("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[5]), "function_types.g:NameFunc[5]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc6, "function_types.g:HdlrFunc6("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[6]), "function_types.g:NameFunc[6]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "function_types.g" );
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
 .type        = MODULE_DYNAMIC,
 .name        = "function_types.g",
 .crc         = 94037544,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}

/* compiled code ends here */
