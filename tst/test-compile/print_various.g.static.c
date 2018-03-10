/* C file produced by GAC */
#include <src/compiled.h>
#define FILE_CRC  "71331546"

/* global variables used in handlers */
static GVar G_Print;
static Obj  GF_Print;
static GVar G_runtest;
static GVar G_Group;
static Obj  GF_Group;

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
 Obj t_5 = 0;
 Obj t_6 = 0;
 Bag oldFrame;
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* Print( 1, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 CALL_2ARGS( t_1, INTOBJ_INT(1), t_2 );
 
 /* Print( "abc", "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "abc" );
 t_3 = MakeString( "\n" );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Print( (1,2)(5,6), "\n" ); */
 t_1 = GF_Print;
 t_2 = IdentityPerm;
 t_4 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_4, 2 );
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_4, 1, t_3 );
 CHANGED_BAG( t_4 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(1) );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(2) );
 CHANGED_BAG( t_3 );
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_4, 2, t_3 );
 CHANGED_BAG( t_4 );
 SET_ELM_PLIST( t_3, 1, INTOBJ_INT(5) );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 2, INTOBJ_INT(6) );
 CHANGED_BAG( t_3 );
 t_2 = Array2Perm( t_4 );
 t_3 = MakeString( "\n" );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Print( [ 1, "abc" ], "\n" ); */
 t_1 = GF_Print;
 t_2 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_2, 2 );
 SET_ELM_PLIST( t_2, 1, INTOBJ_INT(1) );
 t_3 = MakeString( "abc" );
 SET_ELM_PLIST( t_2, 2, t_3 );
 CHANGED_BAG( t_2 );
 t_3 = MakeString( "\n" );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Print( Group( (1,2,3) ), "\n" ); */
 t_1 = GF_Print;
 t_3 = GF_Group;
 t_4 = IdentityPerm;
 t_6 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_6, 1 );
 t_5 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_5, 3 );
 SET_ELM_PLIST( t_6, 1, t_5 );
 CHANGED_BAG( t_6 );
 SET_ELM_PLIST( t_5, 1, INTOBJ_INT(1) );
 CHANGED_BAG( t_5 );
 SET_ELM_PLIST( t_5, 2, INTOBJ_INT(2) );
 CHANGED_BAG( t_5 );
 SET_ELM_PLIST( t_5, 3, INTOBJ_INT(3) );
 CHANGED_BAG( t_5 );
 t_4 = Array2Perm( t_6 );
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 t_3 = MakeString( "\n" );
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
      Print( 1, "\n" );
      Print( "abc", "\n" );
      Print( (1,2)(5,6), "\n" );
      Print( [ 1, "abc" ], "\n" );
      Print( Group( (1,2,3) ), "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 1);
 SET_ENDLINE_BODY(t_2, 7);
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
 G_Group = GVarName( "Group" );
 
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
 InitFopyGVar( "Group", &GF_Group );
 
 /* information for the functions */
 InitGlobalBag( &FileName, "print_various.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "print_various.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "print_various.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "print_various.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "print_various.g:NameFunc[2]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "print_various.g" );
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
 .type        = MODULE_STATIC,
 .name        = "print_various.g",
 .crc         = 71331546,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__print__various ( void )
{
 return &module;
}

/* compiled code ends here */
