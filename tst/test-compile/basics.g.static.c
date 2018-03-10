/* C file produced by GAC */
#include <src/compiled.h>
#define FILE_CRC  "-76725219"

/* global variables used in handlers */
static GVar G_Print;
static Obj  GF_Print;
static GVar G_runtest;

/* record names used in handlers */

/* information for the functions */
static Obj  NameFunc[3];
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
 OLD_BRK_CURR_STAT
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,0,0,oldFrame);
 REM_BRK_CURR_STAT();
 SET_BRK_CURR_STAT(0);
 
 /* x := 10 ^ 10; */
 t_1 = POW( INTOBJ_INT(10), INTOBJ_INT(10) );
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 CALL_2ARGS( t_1, l_x, t_2 );
 
 /* y := 10000000000; */
 l_y = C_MAKE_MED_INT(10000000000);
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 CALL_2ARGS( t_1, l_y, t_2 );
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
 t_3 = MakeString( "\n" );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* x := 10 ^ 20; */
 t_1 = POW( INTOBJ_INT(10), INTOBJ_INT(20) );
 l_x = t_1;
 
 /* Print( x, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 CALL_2ARGS( t_1, l_x, t_2 );
 
 /* y := 100000000000000000000; */
 t_1 = C_MAKE_INTEGER_BAG(16, 1);
 C_SET_LIMB8( t_1, 0, 7766279631452241920LL);
 C_SET_LIMB8( t_1, 1, 5LL);
 l_y = t_1;
 
 /* Print( y, "\n" ); */
 t_1 = GF_Print;
 t_2 = MakeString( "\n" );
 CALL_2ARGS( t_1, l_y, t_2 );
 
 /* Print( x = y, "\n" ); */
 t_1 = GF_Print;
 t_2 = (EQ( l_x, l_y ) ? True : False);
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
      local x, y;
      x := 10 ^ 10;
      Print( x, "\n" );
      y := 10000000000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      x := 10 ^ 20;
      Print( x, "\n" );
      y := 100000000000000000000;
      Print( y, "\n" );
      Print( x = y, "\n" );
      return;
  end; */
 t_1 = NewFunction( NameFunc[2], 0, 0, HdlrFunc2 );
 SET_ENVI_FUNC( t_1, STATE(CurrLVars) );
 t_2 = NewBag( T_BODY, sizeof(BodyHeader) );
 SET_STARTLINE_BODY(t_2, 3);
 SET_ENDLINE_BODY(t_2, 20);
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
 
 /* information for the functions */
 InitGlobalBag( &FileName, "basics.g:FileName("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc1, "basics.g:HdlrFunc1("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[1]), "basics.g:NameFunc[1]("FILE_CRC")" );
 InitHandlerFunc( HdlrFunc2, "basics.g:HdlrFunc2("FILE_CRC")" );
 InitGlobalBag( &(NameFunc[2]), "basics.g:NameFunc[2]("FILE_CRC")" );
 
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
 FileName = MakeImmString( "basics.g" );
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
 .name        = "basics.g",
 .crc         = -76725219,
 .initKernel  = InitKernel,
 .initLibrary = InitLibrary,
 .postRestore = PostRestore,
};

StructInitInfo * Init__basics ( void )
{
 return &module;
}

/* compiled code ends here */
