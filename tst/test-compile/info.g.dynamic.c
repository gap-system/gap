/* C file produced by GAC */
#include <src/compiled.h>
#define FILE_CRC  "58141340"

/* global variables used in handlers */
static GVar G_Print;
static Obj  GF_Print;
static GVar G_runtest;
static GVar G_InfoLevel;
static Obj  GF_InfoLevel;
static GVar G_InfoDebug;
static Obj  GC_InfoDebug;
static GVar G_SetInfoLevel;
static Obj  GF_SetInfoLevel;

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
 Obj t_4 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Print( InfoLevel( InfoDebug ), "\n" ); */
 t_1 = GF_Print;
 t_3 = GF_InfoLevel;
 t_4 = GC_InfoDebug;
 CHECK_BOUND( t_4, "InfoDebug" )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 t_3 = MakeString( "\n" );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Info( ... ); */
 t_1 = GC_InfoDebug;
 CHECK_BOUND( t_1, "InfoDebug" )
 t_3 = InfoCheckLevel( t_1, INTOBJ_INT(2) );
 if ( t_3 == True ) {
  t_2 = NEW_PLIST( T_PLIST, 1 );
  SET_LEN_PLIST( t_2, 1 );
  t_3 = MakeString( "Do not print" );
  SET_ELM_PLIST( t_2, 1, t_3 );
  CHANGED_BAG(t_2);
  InfoDoPrint( t_1, INTOBJ_INT(2), t_2 );
 }
 
 /* Info( ... ); */
 t_1 = GC_InfoDebug;
 CHECK_BOUND( t_1, "InfoDebug" )
 t_3 = InfoCheckLevel( t_1, INTOBJ_INT(1) );
 if ( t_3 == True ) {
  t_2 = NEW_PLIST( T_PLIST, 1 );
  SET_LEN_PLIST( t_2, 1 );
  t_3 = MakeString( "print this A" );
  SET_ELM_PLIST( t_2, 1, t_3 );
  CHANGED_BAG(t_2);
  InfoDoPrint( t_1, INTOBJ_INT(1), t_2 );
 }
 
 /* SetInfoLevel( InfoDebug, 2 ); */
 t_1 = GF_SetInfoLevel;
 t_2 = GC_InfoDebug;
 CHECK_BOUND( t_2, "InfoDebug" )
 CALL_2ARGS( t_1, t_2, INTOBJ_INT(2) );
 
 /* Print( InfoLevel( InfoDebug ), "\n" ); */
 t_1 = GF_Print;
 t_3 = GF_InfoLevel;
 t_4 = GC_InfoDebug;
 CHECK_BOUND( t_4, "InfoDebug" )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 t_3 = MakeString( "\n" );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Info( ... ); */
 t_1 = GC_InfoDebug;
 CHECK_BOUND( t_1, "InfoDebug" )
 t_3 = InfoCheckLevel( t_1, INTOBJ_INT(3) );
 if ( t_3 == True ) {
  t_2 = NEW_PLIST( T_PLIST, 1 );
  SET_LEN_PLIST( t_2, 1 );
  t_3 = MakeString( "Do not print" );
  SET_ELM_PLIST( t_2, 1, t_3 );
  CHANGED_BAG(t_2);
  InfoDoPrint( t_1, INTOBJ_INT(3), t_2 );
 }
 
 /* Info( ... ); */
 t_1 = GC_InfoDebug;
 CHECK_BOUND( t_1, "InfoDebug" )
 t_3 = InfoCheckLevel( t_1, INTOBJ_INT(2) );
 if ( t_3 == True ) {
  t_2 = NEW_PLIST( T_PLIST, 1 );
  SET_LEN_PLIST( t_2, 1 );
  t_3 = MakeString( "print this B" );
  SET_ELM_PLIST( t_2, 1, t_3 );
  CHANGED_BAG(t_2);
  InfoDoPrint( t_1, INTOBJ_INT(2), t_2 );
 }
 
 /* Info( ... ); */
 t_1 = GC_InfoDebug;
 CHECK_BOUND( t_1, "InfoDebug" )
 t_3 = InfoCheckLevel( t_1, INTOBJ_INT(1) );
 if ( t_3 == True ) {
  t_2 = NEW_PLIST( T_PLIST, 1 );
  SET_LEN_PLIST( t_2, 1 );
  t_3 = MakeString( "print this C" );
  SET_ELM_PLIST( t_2, 1, t_3 );
  CHANGED_BAG(t_2);
  InfoDoPrint( t_1, INTOBJ_INT(1), t_2 );
 }
 
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
 
 /* runtest := function (  )
      Print( InfoLevel( InfoDebug ), "\n" );
      Info( InfoDebug, 2, "Do not print" );
      Info( InfoDebug, 1, "print this A" );
      SetInfoLevel( InfoDebug, 2 );
      Print( InfoLevel( InfoDebug ), "\n" );
      Info( InfoDebug, 3, "Do not print" );
      Info( InfoDebug, 2, "print this B" );
      Info( InfoDebug, 1, "print this C" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 1);
 SET_ENDLINE_BODY(t_2, 10);
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
 G_runtest = GVarName( "runtest" );
 G_InfoLevel = GVarName( "InfoLevel" );
 G_InfoDebug = GVarName( "InfoDebug" );
 G_SetInfoLevel = GVarName( "SetInfoLevel" );
 
 /* record names used in handlers */
 
 /* information for the functions */
 NameFunc[1] = 0;
 NameFunc[2] = 0;
 
 /* return success */
 return 0;
 
}


/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitFopyGVar( "Print", &GF_Print );
 InitFopyGVar( "InfoLevel", &GF_InfoLevel );
 InitCopyGVar( "InfoDebug", &GC_InfoDebug );
 InitFopyGVar( "SetInfoLevel", &GF_SetInfoLevel );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "info.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "info.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "info.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "info.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "info.g:NameFunc[2]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "info.g" );
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
 .name        = "info.g",
 .crc         = 58141340,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}

/* compiled code ends here */
