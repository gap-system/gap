#ifdef USE_PRECOMPILED

/* C file produced by GAC */
#include "compiled.h"

/* global variables used in handlers */
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_METHODS__OPERATION;
static Obj  GF_METHODS__OPERATION;
static GVar G_METHOD__0ARGS;
static GVar G_METHOD__1ARGS;
static GVar G_METHOD__2ARGS;
static GVar G_METHOD__3ARGS;
static GVar G_METHOD__4ARGS;
static GVar G_METHOD__5ARGS;
static GVar G_METHOD__6ARGS;
static GVar G_METHOD__XARGS;
static GVar G_NEXT__METHOD__0ARGS;
static GVar G_NEXT__METHOD__1ARGS;
static GVar G_NEXT__METHOD__2ARGS;
static GVar G_NEXT__METHOD__3ARGS;
static GVar G_NEXT__METHOD__4ARGS;
static GVar G_NEXT__METHOD__5ARGS;
static GVar G_NEXT__METHOD__6ARGS;
static GVar G_NEXT__METHOD__XARGS;
static GVar G_VMETHOD__0ARGS;
static GVar G_VMETHOD__1ARGS;
static GVar G_VMETHOD__2ARGS;
static GVar G_VMETHOD__3ARGS;
static GVar G_VMETHOD__4ARGS;
static GVar G_VMETHOD__5ARGS;
static GVar G_VMETHOD__6ARGS;
static GVar G_VMETHOD__XARGS;
static GVar G_NEXT__VMETHOD__0ARGS;
static GVar G_NEXT__VMETHOD__1ARGS;
static GVar G_NEXT__VMETHOD__2ARGS;
static GVar G_NEXT__VMETHOD__3ARGS;
static GVar G_NEXT__VMETHOD__4ARGS;
static GVar G_NEXT__VMETHOD__5ARGS;
static GVar G_NEXT__VMETHOD__6ARGS;
static GVar G_NEXT__VMETHOD__XARGS;
static GVar G_CONSTRUCTOR__0ARGS;
static GVar G_CONSTRUCTOR__1ARGS;
static GVar G_CONSTRUCTOR__2ARGS;
static GVar G_CONSTRUCTOR__3ARGS;
static GVar G_CONSTRUCTOR__4ARGS;
static GVar G_CONSTRUCTOR__5ARGS;
static GVar G_CONSTRUCTOR__6ARGS;
static GVar G_CONSTRUCTOR__XARGS;
static GVar G_NEXT__CONSTRUCTOR__0ARGS;
static GVar G_NEXT__CONSTRUCTOR__1ARGS;
static GVar G_NEXT__CONSTRUCTOR__2ARGS;
static GVar G_NEXT__CONSTRUCTOR__3ARGS;
static GVar G_NEXT__CONSTRUCTOR__4ARGS;
static GVar G_NEXT__CONSTRUCTOR__5ARGS;
static GVar G_NEXT__CONSTRUCTOR__6ARGS;
static GVar G_NEXT__CONSTRUCTOR__XARGS;
static GVar G_VCONSTRUCTOR__0ARGS;
static GVar G_VCONSTRUCTOR__1ARGS;
static GVar G_VCONSTRUCTOR__2ARGS;
static GVar G_VCONSTRUCTOR__3ARGS;
static GVar G_VCONSTRUCTOR__4ARGS;
static GVar G_VCONSTRUCTOR__5ARGS;
static GVar G_VCONSTRUCTOR__6ARGS;
static GVar G_VCONSTRUCTOR__XARGS;
static GVar G_NEXT__VCONSTRUCTOR__0ARGS;
static GVar G_NEXT__VCONSTRUCTOR__1ARGS;
static GVar G_NEXT__VCONSTRUCTOR__2ARGS;
static GVar G_NEXT__VCONSTRUCTOR__3ARGS;
static GVar G_NEXT__VCONSTRUCTOR__4ARGS;
static GVar G_NEXT__VCONSTRUCTOR__5ARGS;
static GVar G_NEXT__VCONSTRUCTOR__6ARGS;
static GVar G_NEXT__VCONSTRUCTOR__XARGS;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_Print;
static Obj  GF_Print;
static GVar G_Revision;
static Obj  GC_Revision;
static GVar G_Error;
static Obj  GF_Error;

/* record names used in handlers */
static RNam R_methsel__g;

/* information for the functions */
static Obj  NameFunc[66];
static Obj  NamsFunc[66];
static Int  NargFunc[66];
static Obj  DefaultName;

/* 'Link' links this module to GAP */
static void Link ( void )
{
 
 /* global variables used in handlers */
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 InitFopyGVar( G_NAME__FUNC, &GF_NAME__FUNC );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 InitFopyGVar( G_IS__SUBSET__FLAGS, &GF_IS__SUBSET__FLAGS );
 G_METHODS__OPERATION = GVarName( "METHODS_OPERATION" );
 InitFopyGVar( G_METHODS__OPERATION, &GF_METHODS__OPERATION );
 G_METHOD__0ARGS = GVarName( "METHOD_0ARGS" );
 G_METHOD__1ARGS = GVarName( "METHOD_1ARGS" );
 G_METHOD__2ARGS = GVarName( "METHOD_2ARGS" );
 G_METHOD__3ARGS = GVarName( "METHOD_3ARGS" );
 G_METHOD__4ARGS = GVarName( "METHOD_4ARGS" );
 G_METHOD__5ARGS = GVarName( "METHOD_5ARGS" );
 G_METHOD__6ARGS = GVarName( "METHOD_6ARGS" );
 G_METHOD__XARGS = GVarName( "METHOD_XARGS" );
 G_NEXT__METHOD__0ARGS = GVarName( "NEXT_METHOD_0ARGS" );
 G_NEXT__METHOD__1ARGS = GVarName( "NEXT_METHOD_1ARGS" );
 G_NEXT__METHOD__2ARGS = GVarName( "NEXT_METHOD_2ARGS" );
 G_NEXT__METHOD__3ARGS = GVarName( "NEXT_METHOD_3ARGS" );
 G_NEXT__METHOD__4ARGS = GVarName( "NEXT_METHOD_4ARGS" );
 G_NEXT__METHOD__5ARGS = GVarName( "NEXT_METHOD_5ARGS" );
 G_NEXT__METHOD__6ARGS = GVarName( "NEXT_METHOD_6ARGS" );
 G_NEXT__METHOD__XARGS = GVarName( "NEXT_METHOD_XARGS" );
 G_VMETHOD__0ARGS = GVarName( "VMETHOD_0ARGS" );
 G_VMETHOD__1ARGS = GVarName( "VMETHOD_1ARGS" );
 G_VMETHOD__2ARGS = GVarName( "VMETHOD_2ARGS" );
 G_VMETHOD__3ARGS = GVarName( "VMETHOD_3ARGS" );
 G_VMETHOD__4ARGS = GVarName( "VMETHOD_4ARGS" );
 G_VMETHOD__5ARGS = GVarName( "VMETHOD_5ARGS" );
 G_VMETHOD__6ARGS = GVarName( "VMETHOD_6ARGS" );
 G_VMETHOD__XARGS = GVarName( "VMETHOD_XARGS" );
 G_NEXT__VMETHOD__0ARGS = GVarName( "NEXT_VMETHOD_0ARGS" );
 G_NEXT__VMETHOD__1ARGS = GVarName( "NEXT_VMETHOD_1ARGS" );
 G_NEXT__VMETHOD__2ARGS = GVarName( "NEXT_VMETHOD_2ARGS" );
 G_NEXT__VMETHOD__3ARGS = GVarName( "NEXT_VMETHOD_3ARGS" );
 G_NEXT__VMETHOD__4ARGS = GVarName( "NEXT_VMETHOD_4ARGS" );
 G_NEXT__VMETHOD__5ARGS = GVarName( "NEXT_VMETHOD_5ARGS" );
 G_NEXT__VMETHOD__6ARGS = GVarName( "NEXT_VMETHOD_6ARGS" );
 G_NEXT__VMETHOD__XARGS = GVarName( "NEXT_VMETHOD_XARGS" );
 G_CONSTRUCTOR__0ARGS = GVarName( "CONSTRUCTOR_0ARGS" );
 G_CONSTRUCTOR__1ARGS = GVarName( "CONSTRUCTOR_1ARGS" );
 G_CONSTRUCTOR__2ARGS = GVarName( "CONSTRUCTOR_2ARGS" );
 G_CONSTRUCTOR__3ARGS = GVarName( "CONSTRUCTOR_3ARGS" );
 G_CONSTRUCTOR__4ARGS = GVarName( "CONSTRUCTOR_4ARGS" );
 G_CONSTRUCTOR__5ARGS = GVarName( "CONSTRUCTOR_5ARGS" );
 G_CONSTRUCTOR__6ARGS = GVarName( "CONSTRUCTOR_6ARGS" );
 G_CONSTRUCTOR__XARGS = GVarName( "CONSTRUCTOR_XARGS" );
 G_NEXT__CONSTRUCTOR__0ARGS = GVarName( "NEXT_CONSTRUCTOR_0ARGS" );
 G_NEXT__CONSTRUCTOR__1ARGS = GVarName( "NEXT_CONSTRUCTOR_1ARGS" );
 G_NEXT__CONSTRUCTOR__2ARGS = GVarName( "NEXT_CONSTRUCTOR_2ARGS" );
 G_NEXT__CONSTRUCTOR__3ARGS = GVarName( "NEXT_CONSTRUCTOR_3ARGS" );
 G_NEXT__CONSTRUCTOR__4ARGS = GVarName( "NEXT_CONSTRUCTOR_4ARGS" );
 G_NEXT__CONSTRUCTOR__5ARGS = GVarName( "NEXT_CONSTRUCTOR_5ARGS" );
 G_NEXT__CONSTRUCTOR__6ARGS = GVarName( "NEXT_CONSTRUCTOR_6ARGS" );
 G_NEXT__CONSTRUCTOR__XARGS = GVarName( "NEXT_CONSTRUCTOR_XARGS" );
 G_VCONSTRUCTOR__0ARGS = GVarName( "VCONSTRUCTOR_0ARGS" );
 G_VCONSTRUCTOR__1ARGS = GVarName( "VCONSTRUCTOR_1ARGS" );
 G_VCONSTRUCTOR__2ARGS = GVarName( "VCONSTRUCTOR_2ARGS" );
 G_VCONSTRUCTOR__3ARGS = GVarName( "VCONSTRUCTOR_3ARGS" );
 G_VCONSTRUCTOR__4ARGS = GVarName( "VCONSTRUCTOR_4ARGS" );
 G_VCONSTRUCTOR__5ARGS = GVarName( "VCONSTRUCTOR_5ARGS" );
 G_VCONSTRUCTOR__6ARGS = GVarName( "VCONSTRUCTOR_6ARGS" );
 G_VCONSTRUCTOR__XARGS = GVarName( "VCONSTRUCTOR_XARGS" );
 G_NEXT__VCONSTRUCTOR__0ARGS = GVarName( "NEXT_VCONSTRUCTOR_0ARGS" );
 G_NEXT__VCONSTRUCTOR__1ARGS = GVarName( "NEXT_VCONSTRUCTOR_1ARGS" );
 G_NEXT__VCONSTRUCTOR__2ARGS = GVarName( "NEXT_VCONSTRUCTOR_2ARGS" );
 G_NEXT__VCONSTRUCTOR__3ARGS = GVarName( "NEXT_VCONSTRUCTOR_3ARGS" );
 G_NEXT__VCONSTRUCTOR__4ARGS = GVarName( "NEXT_VCONSTRUCTOR_4ARGS" );
 G_NEXT__VCONSTRUCTOR__5ARGS = GVarName( "NEXT_VCONSTRUCTOR_5ARGS" );
 G_NEXT__VCONSTRUCTOR__6ARGS = GVarName( "NEXT_VCONSTRUCTOR_6ARGS" );
 G_NEXT__VCONSTRUCTOR__XARGS = GVarName( "NEXT_VCONSTRUCTOR_XARGS" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 InitFopyGVar( G_LEN__LIST, &GF_LEN__LIST );
 G_Print = GVarName( "Print" );
 InitFopyGVar( G_Print, &GF_Print );
 G_Revision = GVarName( "Revision" );
 InitCopyGVar( G_Revision, &GC_Revision );
 G_Error = GVarName( "Error" );
 InitFopyGVar( G_Error, &GF_Error );
 
 /* record names used in handlers */
 R_methsel__g = RNamName( "methsel_g" );
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" )
 InitGlobalBag( &DefaultName, ": DefaultName (232810754)" );
 InitGlobalBag( &(NameFunc[1]), ": NameFunc[1] (2328107544)" );
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 InitGlobalBag( &(NameFunc[2]), ": NameFunc[2] (2328107544)" );
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 1;
 InitGlobalBag( &(NameFunc[3]), ": NameFunc[3] (2328107544)" );
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 2;
 InitGlobalBag( &(NameFunc[4]), ": NameFunc[4] (2328107544)" );
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 3;
 InitGlobalBag( &(NameFunc[5]), ": NameFunc[5] (2328107544)" );
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = 4;
 InitGlobalBag( &(NameFunc[6]), ": NameFunc[6] (2328107544)" );
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = 5;
 InitGlobalBag( &(NameFunc[7]), ": NameFunc[7] (2328107544)" );
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = 6;
 InitGlobalBag( &(NameFunc[8]), ": NameFunc[8] (2328107544)" );
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 7;
 InitGlobalBag( &(NameFunc[9]), ": NameFunc[9] (2328107544)" );
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = -1;
 InitGlobalBag( &(NameFunc[10]), ": NameFunc[10] (2328107544)" );
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = 2;
 InitGlobalBag( &(NameFunc[11]), ": NameFunc[11] (2328107544)" );
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 3;
 InitGlobalBag( &(NameFunc[12]), ": NameFunc[12] (2328107544)" );
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 4;
 InitGlobalBag( &(NameFunc[13]), ": NameFunc[13] (2328107544)" );
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 5;
 InitGlobalBag( &(NameFunc[14]), ": NameFunc[14] (2328107544)" );
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = 6;
 InitGlobalBag( &(NameFunc[15]), ": NameFunc[15] (2328107544)" );
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 7;
 InitGlobalBag( &(NameFunc[16]), ": NameFunc[16] (2328107544)" );
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 8;
 InitGlobalBag( &(NameFunc[17]), ": NameFunc[17] (2328107544)" );
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = -1;
 InitGlobalBag( &(NameFunc[18]), ": NameFunc[18] (2328107544)" );
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = 1;
 InitGlobalBag( &(NameFunc[19]), ": NameFunc[19] (2328107544)" );
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 2;
 InitGlobalBag( &(NameFunc[20]), ": NameFunc[20] (2328107544)" );
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 3;
 InitGlobalBag( &(NameFunc[21]), ": NameFunc[21] (2328107544)" );
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 4;
 InitGlobalBag( &(NameFunc[22]), ": NameFunc[22] (2328107544)" );
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 5;
 InitGlobalBag( &(NameFunc[23]), ": NameFunc[23] (2328107544)" );
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 6;
 InitGlobalBag( &(NameFunc[24]), ": NameFunc[24] (2328107544)" );
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 7;
 InitGlobalBag( &(NameFunc[25]), ": NameFunc[25] (2328107544)" );
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = -1;
 InitGlobalBag( &(NameFunc[26]), ": NameFunc[26] (2328107544)" );
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 2;
 InitGlobalBag( &(NameFunc[27]), ": NameFunc[27] (2328107544)" );
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 3;
 InitGlobalBag( &(NameFunc[28]), ": NameFunc[28] (2328107544)" );
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 4;
 InitGlobalBag( &(NameFunc[29]), ": NameFunc[29] (2328107544)" );
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = 5;
 InitGlobalBag( &(NameFunc[30]), ": NameFunc[30] (2328107544)" );
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 6;
 InitGlobalBag( &(NameFunc[31]), ": NameFunc[31] (2328107544)" );
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 7;
 InitGlobalBag( &(NameFunc[32]), ": NameFunc[32] (2328107544)" );
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 8;
 InitGlobalBag( &(NameFunc[33]), ": NameFunc[33] (2328107544)" );
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = -1;
 InitGlobalBag( &(NameFunc[34]), ": NameFunc[34] (2328107544)" );
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = 1;
 InitGlobalBag( &(NameFunc[35]), ": NameFunc[35] (2328107544)" );
 NameFunc[35] = DefaultName;
 NamsFunc[35] = 0;
 NargFunc[35] = 2;
 InitGlobalBag( &(NameFunc[36]), ": NameFunc[36] (2328107544)" );
 NameFunc[36] = DefaultName;
 NamsFunc[36] = 0;
 NargFunc[36] = 3;
 InitGlobalBag( &(NameFunc[37]), ": NameFunc[37] (2328107544)" );
 NameFunc[37] = DefaultName;
 NamsFunc[37] = 0;
 NargFunc[37] = 4;
 InitGlobalBag( &(NameFunc[38]), ": NameFunc[38] (2328107544)" );
 NameFunc[38] = DefaultName;
 NamsFunc[38] = 0;
 NargFunc[38] = 5;
 InitGlobalBag( &(NameFunc[39]), ": NameFunc[39] (2328107544)" );
 NameFunc[39] = DefaultName;
 NamsFunc[39] = 0;
 NargFunc[39] = 6;
 InitGlobalBag( &(NameFunc[40]), ": NameFunc[40] (2328107544)" );
 NameFunc[40] = DefaultName;
 NamsFunc[40] = 0;
 NargFunc[40] = 7;
 InitGlobalBag( &(NameFunc[41]), ": NameFunc[41] (2328107544)" );
 NameFunc[41] = DefaultName;
 NamsFunc[41] = 0;
 NargFunc[41] = -1;
 InitGlobalBag( &(NameFunc[42]), ": NameFunc[42] (2328107544)" );
 NameFunc[42] = DefaultName;
 NamsFunc[42] = 0;
 NargFunc[42] = 2;
 InitGlobalBag( &(NameFunc[43]), ": NameFunc[43] (2328107544)" );
 NameFunc[43] = DefaultName;
 NamsFunc[43] = 0;
 NargFunc[43] = 3;
 InitGlobalBag( &(NameFunc[44]), ": NameFunc[44] (2328107544)" );
 NameFunc[44] = DefaultName;
 NamsFunc[44] = 0;
 NargFunc[44] = 4;
 InitGlobalBag( &(NameFunc[45]), ": NameFunc[45] (2328107544)" );
 NameFunc[45] = DefaultName;
 NamsFunc[45] = 0;
 NargFunc[45] = 5;
 InitGlobalBag( &(NameFunc[46]), ": NameFunc[46] (2328107544)" );
 NameFunc[46] = DefaultName;
 NamsFunc[46] = 0;
 NargFunc[46] = 6;
 InitGlobalBag( &(NameFunc[47]), ": NameFunc[47] (2328107544)" );
 NameFunc[47] = DefaultName;
 NamsFunc[47] = 0;
 NargFunc[47] = 7;
 InitGlobalBag( &(NameFunc[48]), ": NameFunc[48] (2328107544)" );
 NameFunc[48] = DefaultName;
 NamsFunc[48] = 0;
 NargFunc[48] = 8;
 InitGlobalBag( &(NameFunc[49]), ": NameFunc[49] (2328107544)" );
 NameFunc[49] = DefaultName;
 NamsFunc[49] = 0;
 NargFunc[49] = -1;
 InitGlobalBag( &(NameFunc[50]), ": NameFunc[50] (2328107544)" );
 NameFunc[50] = DefaultName;
 NamsFunc[50] = 0;
 NargFunc[50] = 1;
 InitGlobalBag( &(NameFunc[51]), ": NameFunc[51] (2328107544)" );
 NameFunc[51] = DefaultName;
 NamsFunc[51] = 0;
 NargFunc[51] = 2;
 InitGlobalBag( &(NameFunc[52]), ": NameFunc[52] (2328107544)" );
 NameFunc[52] = DefaultName;
 NamsFunc[52] = 0;
 NargFunc[52] = 3;
 InitGlobalBag( &(NameFunc[53]), ": NameFunc[53] (2328107544)" );
 NameFunc[53] = DefaultName;
 NamsFunc[53] = 0;
 NargFunc[53] = 4;
 InitGlobalBag( &(NameFunc[54]), ": NameFunc[54] (2328107544)" );
 NameFunc[54] = DefaultName;
 NamsFunc[54] = 0;
 NargFunc[54] = 5;
 InitGlobalBag( &(NameFunc[55]), ": NameFunc[55] (2328107544)" );
 NameFunc[55] = DefaultName;
 NamsFunc[55] = 0;
 NargFunc[55] = 6;
 InitGlobalBag( &(NameFunc[56]), ": NameFunc[56] (2328107544)" );
 NameFunc[56] = DefaultName;
 NamsFunc[56] = 0;
 NargFunc[56] = 7;
 InitGlobalBag( &(NameFunc[57]), ": NameFunc[57] (2328107544)" );
 NameFunc[57] = DefaultName;
 NamsFunc[57] = 0;
 NargFunc[57] = -1;
 InitGlobalBag( &(NameFunc[58]), ": NameFunc[58] (2328107544)" );
 NameFunc[58] = DefaultName;
 NamsFunc[58] = 0;
 NargFunc[58] = 2;
 InitGlobalBag( &(NameFunc[59]), ": NameFunc[59] (2328107544)" );
 NameFunc[59] = DefaultName;
 NamsFunc[59] = 0;
 NargFunc[59] = 3;
 InitGlobalBag( &(NameFunc[60]), ": NameFunc[60] (2328107544)" );
 NameFunc[60] = DefaultName;
 NamsFunc[60] = 0;
 NargFunc[60] = 4;
 InitGlobalBag( &(NameFunc[61]), ": NameFunc[61] (2328107544)" );
 NameFunc[61] = DefaultName;
 NamsFunc[61] = 0;
 NargFunc[61] = 5;
 InitGlobalBag( &(NameFunc[62]), ": NameFunc[62] (2328107544)" );
 NameFunc[62] = DefaultName;
 NamsFunc[62] = 0;
 NargFunc[62] = 6;
 InitGlobalBag( &(NameFunc[63]), ": NameFunc[63] (2328107544)" );
 NameFunc[63] = DefaultName;
 NamsFunc[63] = 0;
 NargFunc[63] = 7;
 InitGlobalBag( &(NameFunc[64]), ": NameFunc[64] (2328107544)" );
 NameFunc[64] = DefaultName;
 NamsFunc[64] = 0;
 NargFunc[64] = 8;
 InitGlobalBag( &(NameFunc[65]), ": NameFunc[65] (2328107544)" );
 NameFunc[65] = DefaultName;
 NamsFunc[65] = 0;
 NargFunc[65] = -1;
 
}


/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_operation )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 Obj  a_operation,
 Obj  a_type1 )
{
 Obj l_methods = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(5), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(6), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4,
 Obj  a_type5 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 8 */
static Obj  HdlrFunc8 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_type1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
  C_SUM_FIA( t_14, t_15, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, t_8, t_9, t_10, t_11, t_12, t_13 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
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
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 10 */
static Obj  HdlrFunc10 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 11 */
static Obj  HdlrFunc11 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(5), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(6), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 13 */
static Obj  HdlrFunc13 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 14 */
static Obj  HdlrFunc14 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 15 */
static Obj  HdlrFunc15 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 16 */
static Obj  HdlrFunc16 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
  C_SUM_FIA( t_14, t_15, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, t_8, t_9, t_10, t_11, t_12, t_13 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 17 */
static Obj  HdlrFunc17 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 18 */
static Obj  HdlrFunc18 (
 Obj  self,
 Obj  a_operation )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[4 * (i - 1) + 4], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 19 */
static Obj  HdlrFunc19 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1 )
{
 Obj l_methods = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(5), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[5 * (i - 1) + 5], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(5), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 20 */
static Obj  HdlrFunc20 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(6), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[6 * (i - 1) + 6], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(6), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 21 */
static Obj  HdlrFunc21 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[7 * (i - 1) + 7], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(7), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 22 */
static Obj  HdlrFunc22 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[8 * (i - 1) + 8], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(8), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(8) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 23 */
static Obj  HdlrFunc23 (
 Obj  self,
 Obj  a_operation,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4,
 Obj  a_type5 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[9 * (i - 1) + 9], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(9), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(9) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 24 */
static Obj  HdlrFunc24 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_type1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
  C_SUM_FIA( t_14, t_15, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, t_8, t_9, t_10, t_11, t_12, t_13 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[10 * (i - 1) + 10], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(10), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(10) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 25 */
static Obj  HdlrFunc25 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 26 */
static Obj  HdlrFunc26 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[4 * (i - 1) + 4], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(4) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 27 */
static Obj  HdlrFunc27 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[5 * (i - 1) + 2] ) and methods[5 * (i - 1) + 1]( type1![1] ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_7, a_type1, 2 );
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(5), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_5 = CALL_2ARGS( t_6, t_7, t_8 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   t_6 = CALL_1ARGS( t_7, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[5 * (i - 1) + 5], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(5), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(5) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 28 */
static Obj  HdlrFunc28 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[6 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( type1![1], type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_8, a_type1, 2 );
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(6), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[6 * (i - 1) + 6], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(6), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(6) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 29 */
static Obj  HdlrFunc29 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[7 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( type1![1], type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_9, a_type1, 2 );
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_7 = CALL_2ARGS( t_8, t_9, t_10 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[7 * (i - 1) + 7], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(7), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(7) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 30 */
static Obj  HdlrFunc30 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_type1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[8 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_10, a_type1, 2 );
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_8 = CALL_2ARGS( t_9, t_10, t_11 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[8 * (i - 1) + 8], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(8), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(8) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 31 */
static Obj  HdlrFunc31 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[9 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_11, a_type1, 2 );
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_9 = CALL_2ARGS( t_10, t_11, t_12 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[9 * (i - 1) + 9], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(9), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(9) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 32 */
static Obj  HdlrFunc32 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_type1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_type1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( type1![2], methods[10 * (i - 1) + 2] ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( type1![1], type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_ELM_POSOBJ_NLE( t_12, a_type1, 2 );
  C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
  C_SUM_FIA( t_14, t_15, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
  t_10 = CALL_2ARGS( t_11, t_12, t_13 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type1, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_13, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, t_8, t_9, t_10, t_11, t_12, t_13 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[10 * (i - 1) + 10], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(10), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(10) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 33 */
static Obj  HdlrFunc33 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 34 */
static Obj  HdlrFunc34 (
 Obj  self,
 Obj  a_operation )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 35 */
static Obj  HdlrFunc35 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1 )
{
 Obj l_methods = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
  C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 36 */
static Obj  HdlrFunc36 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(6), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 37 */
static Obj  HdlrFunc37 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(7), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, a_flags1, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 38 */
static Obj  HdlrFunc38 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, a_flags1, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 39 */
static Obj  HdlrFunc39 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4,
 Obj  a_type5 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 40 */
static Obj  HdlrFunc40 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_flags1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 41 */
static Obj  HdlrFunc41 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 42 */
static Obj  HdlrFunc42 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 43 */
static Obj  HdlrFunc43 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
  C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 44 */
static Obj  HdlrFunc44 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(6), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 45 */
static Obj  HdlrFunc45 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(7), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, a_flags1, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 46 */
static Obj  HdlrFunc46 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, a_flags1, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 47 */
static Obj  HdlrFunc47 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 48 */
static Obj  HdlrFunc48 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 49 */
static Obj  HdlrFunc49 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 50 */
static Obj  HdlrFunc50 (
 Obj  self,
 Obj  a_operation )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[4 * (i - 1) + 4], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[4 * (i - 1) + 2]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 51 */
static Obj  HdlrFunc51 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1 )
{
 Obj l_methods = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
  C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[5 * (i - 1) + 5], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(5), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[5 * (i - 1) + 3]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 52 */
static Obj  HdlrFunc52 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(6), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[6 * (i - 1) + 6], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(6), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[6 * (i - 1) + 4]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 53 */
static Obj  HdlrFunc53 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(7), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, a_flags1, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[7 * (i - 1) + 7], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(7), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[7 * (i - 1) + 5]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 54 */
static Obj  HdlrFunc54 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, a_flags1, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[8 * (i - 1) + 8], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(8), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(8) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[8 * (i - 1) + 6]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 55 */
static Obj  HdlrFunc55 (
 Obj  self,
 Obj  a_operation,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4,
 Obj  a_type5 )
{
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[9 * (i - 1) + 9], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(9), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(9) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[9 * (i - 1) + 7]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 56 */
static Obj  HdlrFunc56 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_flags1 = ELM_PLIST( args, 2 );
 a_type2 = ELM_PLIST( args, 3 );
 a_type3 = ELM_PLIST( args, 4 );
 a_type4 = ELM_PLIST( args, 5 );
 a_type5 = ELM_PLIST( args, 6 );
 a_type6 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* Print( "#I  ", methods[10 * (i - 1) + 10], "\n" ); */
   t_3 = GF_Print;
   C_NEW_STRING( t_4, 4, "#I  " )
   C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_7, INTOBJ_INT(10), t_8 )
   C_SUM_FIA( t_6, t_7, INTOBJ_INT(10) )
   C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
   C_NEW_STRING( t_6, 1, "\n" )
   CALL_3ARGS( t_3, t_4, t_5, t_6 );
   
   /* return methods[10 * (i - 1) + 8]; */
   C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
   C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
   C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_3;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 57 */
static Obj  HdlrFunc57 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 58 */
static Obj  HdlrFunc58 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 0 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(0) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 4 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(4) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if methods[4 * (i - 1) + 1](  ) then */
  C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
  C_SUM_FIA( t_6, t_7, INTOBJ_INT(1) )
  C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
  t_4 = CALL_0ARGS( t_5 );
  t_3 = (Obj)(t_4 != False);
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[4 * (i - 1) + 4], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(4), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(4) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[4 * (i - 1) + 2]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(4), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(2) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 0 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 0 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 59 */
static Obj  HdlrFunc59 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 1 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(1) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 5 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(5) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[5 * (i - 1) + 2], flags1 ) and methods[5 * (i - 1) + 1]( flags1 ) then */
  t_6 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
  C_SUM_FIA( t_8, t_9, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
  t_5 = CALL_2ARGS( t_6, t_7, a_flags1 );
  t_4 = (Obj)(t_5 != False);
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(5), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   t_6 = CALL_1ARGS( t_7, a_flags1 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[5 * (i - 1) + 5], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(5), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(5) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[5 * (i - 1) + 3]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(5), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(3) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 1 argument" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 16, " with 1 argument" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 60 */
static Obj  HdlrFunc60 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 2 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(2) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 6 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(6) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[6 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[6 * (i - 1) + 3] ) and methods[6 * (i - 1) + 1]( flags1, type2![1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_11, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_10, INTOBJ_INT(6), t_11 )
  C_SUM_FIA( t_9, t_10, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_8, l_methods, INT_INTOBJ(t_9) );
  t_6 = CALL_2ARGS( t_7, t_8, a_flags1 );
  t_5 = (Obj)(t_6 != False);
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type2, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(6), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(6), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   t_6 = CALL_2ARGS( t_7, a_flags1, t_8 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[6 * (i - 1) + 6], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(6), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(6) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[6 * (i - 1) + 4]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(6), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(4) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 2 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 2 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 61 */
static Obj  HdlrFunc61 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 3 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(3) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 7 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(7) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[7 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[7 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[7 * (i - 1) + 4] ) and methods[7 * (i - 1) + 1]( flags1, type2![1], type3![1] ) then */
  t_8 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_12, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_11, INTOBJ_INT(7), t_12 )
  C_SUM_FIA( t_10, t_11, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_9, l_methods, INT_INTOBJ(t_10) );
  t_7 = CALL_2ARGS( t_8, t_9, a_flags1 );
  t_6 = (Obj)(t_7 != False);
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type2, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(7), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type3, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(7), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(7), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   t_6 = CALL_3ARGS( t_7, a_flags1, t_8, t_9 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[7 * (i - 1) + 7], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(7), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(7) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[7 * (i - 1) + 5]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(7), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(5) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 3 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 3 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 62 */
static Obj  HdlrFunc62 (
 Obj  self,
 Obj  a_operation,
 Obj  a_k,
 Obj  a_flags1,
 Obj  a_type2,
 Obj  a_type3,
 Obj  a_type4 )
{
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 4 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(4) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 8 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(8) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[8 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[8 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[8 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[8 * (i - 1) + 5] ) 
and methods[8 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1] ) then */
  t_9 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
  C_SUM_FIA( t_11, t_12, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
  t_8 = CALL_2ARGS( t_9, t_10, a_flags1 );
  t_7 = (Obj)(t_8 != False);
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type2, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(8), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type3, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(8), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type4, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(8), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(8), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   t_6 = CALL_4ARGS( t_7, a_flags1, t_8, t_9, t_10 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[8 * (i - 1) + 8], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(8), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(8) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[8 * (i - 1) + 6]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(8), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(6) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 4 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 4 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 63 */
static Obj  HdlrFunc63 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 7, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 5 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(5) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 9 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(9) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[9 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[9 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[9 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[9 * (i - 1) + 5] ) 
  and IS_SUBSET_FLAGS( type5![2], methods[9 * (i - 1) + 6] ) and methods[9 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1] ) then */
  t_10 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
  C_SUM_FIA( t_12, t_13, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
  t_9 = CALL_2ARGS( t_10, t_11, a_flags1 );
  t_8 = (Obj)(t_9 != False);
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type2, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(9), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type3, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(9), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type4, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(9), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type5, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(9), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(9), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   t_6 = CALL_5ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[9 * (i - 1) + 9], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(9), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(9) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[9 * (i - 1) + 7]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(9), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(7) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 5 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 5 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 64 */
static Obj  HdlrFunc64 (
 Obj  self,
 Obj  args )
{
 Obj  a_operation;
 Obj  a_k;
 Obj  a_flags1;
 Obj  a_type2;
 Obj  a_type3;
 Obj  a_type4;
 Obj  a_type5;
 Obj  a_type6;
 Obj l_methods = 0;
 Obj l_i = 0;
 Obj l_j = 0;
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
 Obj t_13 = 0;
 Obj t_14 = 0;
 Obj t_15 = 0;
 Obj t_16 = 0;
 Obj t_17 = 0;
 Bag oldFrame;
 CHECK_NR_ARGS( 8, args )
 a_operation = ELM_PLIST( args, 1 );
 a_k = ELM_PLIST( args, 2 );
 a_flags1 = ELM_PLIST( args, 3 );
 a_type2 = ELM_PLIST( args, 4 );
 a_type3 = ELM_PLIST( args, 5 );
 a_type4 = ELM_PLIST( args, 6 );
 a_type5 = ELM_PLIST( args, 7 );
 a_type6 = ELM_PLIST( args, 8 );
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* methods := METHODS_OPERATION( operation, 6 ); */
 t_2 = GF_METHODS__OPERATION;
 t_1 = CALL_2ARGS( t_2, a_operation, INTOBJ_INT(6) );
 l_methods = t_1;
 
 /* j := 0; */
 l_j = INTOBJ_INT(0);
 
 /* for i in [ 1 .. LEN_LIST( methods ) / 10 ] do */
 t_4 = GF_LEN__LIST;
 t_3 = CALL_1ARGS( t_4, l_methods );
 t_2 = QUO( t_3, INTOBJ_INT(10) );
 for ( t_1 = INTOBJ_INT(1);
       ((Int)t_1) <= ((Int)t_2);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IS_SUBSET_FLAGS( methods[10 * (i - 1) + 2], flags1 ) and IS_SUBSET_FLAGS( type2![2], methods[10 * (i - 1) + 3] ) and IS_SUBSET_FLAGS( type3![2], methods[10 * (i - 1) + 4] ) and IS_SUBSET_FLAGS( type4![2], methods[10 * (i - 1) + 5] ) 
    and IS_SUBSET_FLAGS( type5![2], methods[10 * (i - 1) + 6] ) and IS_SUBSET_FLAGS( type6![2], methods[10 * (i - 1) + 7] ) and methods[10 * (i - 1) + 1]( flags1, type2![1], type3![1], type4![1], type5![1], type6![1] ) then */
  t_11 = GF_IS__SUBSET__FLAGS;
  C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
  C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
  C_SUM_FIA( t_13, t_14, INTOBJ_INT(2) )
  C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
  t_10 = CALL_2ARGS( t_11, t_12, a_flags1 );
  t_9 = (Obj)(t_10 != False);
  t_8 = t_9;
  if ( t_8 ) {
   t_12 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_13, a_type2, 2 );
   C_DIFF_INTOBJS( t_17, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_16, INTOBJ_INT(10), t_17 )
   C_SUM_FIA( t_15, t_16, INTOBJ_INT(3) )
   C_ELM_LIST_NLE_FPL( t_14, l_methods, INT_INTOBJ(t_15) );
   t_11 = CALL_2ARGS( t_12, t_13, t_14 );
   t_10 = (Obj)(t_11 != False);
   t_8 = t_10;
  }
  t_7 = t_8;
  if ( t_7 ) {
   t_11 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_12, a_type3, 2 );
   C_DIFF_INTOBJS( t_16, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_15, INTOBJ_INT(10), t_16 )
   C_SUM_FIA( t_14, t_15, INTOBJ_INT(4) )
   C_ELM_LIST_NLE_FPL( t_13, l_methods, INT_INTOBJ(t_14) );
   t_10 = CALL_2ARGS( t_11, t_12, t_13 );
   t_9 = (Obj)(t_10 != False);
   t_7 = t_9;
  }
  t_6 = t_7;
  if ( t_6 ) {
   t_10 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_11, a_type4, 2 );
   C_DIFF_INTOBJS( t_15, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_14, INTOBJ_INT(10), t_15 )
   C_SUM_FIA( t_13, t_14, INTOBJ_INT(5) )
   C_ELM_LIST_NLE_FPL( t_12, l_methods, INT_INTOBJ(t_13) );
   t_9 = CALL_2ARGS( t_10, t_11, t_12 );
   t_8 = (Obj)(t_9 != False);
   t_6 = t_8;
  }
  t_5 = t_6;
  if ( t_5 ) {
   t_9 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_10, a_type5, 2 );
   C_DIFF_INTOBJS( t_14, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_13, INTOBJ_INT(10), t_14 )
   C_SUM_FIA( t_12, t_13, INTOBJ_INT(6) )
   C_ELM_LIST_NLE_FPL( t_11, l_methods, INT_INTOBJ(t_12) );
   t_8 = CALL_2ARGS( t_9, t_10, t_11 );
   t_7 = (Obj)(t_8 != False);
   t_5 = t_7;
  }
  t_4 = t_5;
  if ( t_4 ) {
   t_8 = GF_IS__SUBSET__FLAGS;
   C_ELM_POSOBJ_NLE( t_9, a_type6, 2 );
   C_DIFF_INTOBJS( t_13, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_12, INTOBJ_INT(10), t_13 )
   C_SUM_FIA( t_11, t_12, INTOBJ_INT(7) )
   C_ELM_LIST_NLE_FPL( t_10, l_methods, INT_INTOBJ(t_11) );
   t_7 = CALL_2ARGS( t_8, t_9, t_10 );
   t_6 = (Obj)(t_7 != False);
   t_4 = t_6;
  }
  t_3 = t_4;
  if ( t_3 ) {
   C_DIFF_INTOBJS( t_10, l_i, INTOBJ_INT(1) )
   C_PROD_FIA( t_9, INTOBJ_INT(10), t_10 )
   C_SUM_FIA( t_8, t_9, INTOBJ_INT(1) )
   C_ELM_LIST_NLE_FPL( t_7, l_methods, INT_INTOBJ(t_8) );
   C_ELM_POSOBJ_NLE( t_8, a_type2, 1 );
   C_ELM_POSOBJ_NLE( t_9, a_type3, 1 );
   C_ELM_POSOBJ_NLE( t_10, a_type4, 1 );
   C_ELM_POSOBJ_NLE( t_11, a_type5, 1 );
   C_ELM_POSOBJ_NLE( t_12, a_type6, 1 );
   t_6 = CALL_6ARGS( t_7, a_flags1, t_8, t_9, t_10, t_11, t_12 );
   t_5 = (Obj)(t_6 != False);
   t_3 = t_5;
  }
  if ( t_3 ) {
   
   /* if k = j then */
   t_3 = (Obj)(EQ( a_k, l_j ));
   if ( t_3 ) {
    
    /* Print( "#I  trying next: ", methods[10 * (i - 1) + 10], "\n" ); */
    t_3 = GF_Print;
    C_NEW_STRING( t_4, 17, "#I  trying next: " )
    C_DIFF_INTOBJS( t_8, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_7, INTOBJ_INT(10), t_8 )
    C_SUM_FIA( t_6, t_7, INTOBJ_INT(10) )
    C_ELM_LIST_NLE_FPL( t_5, l_methods, INT_INTOBJ(t_6) );
    C_NEW_STRING( t_6, 1, "\n" )
    CALL_3ARGS( t_3, t_4, t_5, t_6 );
    
    /* return methods[10 * (i - 1) + 8]; */
    C_DIFF_INTOBJS( t_6, l_i, INTOBJ_INT(1) )
    C_PROD_FIA( t_5, INTOBJ_INT(10), t_6 )
    C_SUM_FIA( t_4, t_5, INTOBJ_INT(8) )
    C_ELM_LIST_NLE_FPL( t_3, l_methods, INT_INTOBJ(t_4) );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_3;
    
   }
   
   /* else */
   else {
    
    /* j := j + 1; */
    C_SUM_FIA( t_3, l_j, INTOBJ_INT(1) )
    l_j = t_3;
    
   }
   /* fi */
   
  }
  /* fi */
  
 }
 /* od */
 
 /* Error( "no method found for operation ", NAME_FUNC( operation ), " with 6 arguments" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 30, "no method found for operation " )
 t_4 = GF_NAME__FUNC;
 t_3 = CALL_1ARGS( t_4, a_operation );
 C_NEW_STRING( t_4, 17, " with 6 arguments" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 65 */
static Obj  HdlrFunc65 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Error( "not supported yet" ); */
 t_1 = GF_Error;
 C_NEW_STRING( t_2, 17, "not supported yet" )
 CALL_1ARGS( t_1, t_2 );
 
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
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Revision.methsel_g := "@(#)$Id$"; */
 t_1 = GC_Revision;
 C_NEW_STRING( t_2, 58, "@(#)$Id$" )
 ASS_REC( t_1, R_methsel__g, t_2 );
 
 /* METHOD_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc2, ": HdlrFunc2 (2328107544)" );
 t_1 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__0ARGS, t_1 );
 
 /* METHOD_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc3, ": HdlrFunc3 (2328107544)" );
 t_1 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__1ARGS, t_1 );
 
 /* METHOD_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc4, ": HdlrFunc4 (2328107544)" );
 t_1 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__2ARGS, t_1 );
 
 /* METHOD_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc5, ": HdlrFunc5 (2328107544)" );
 t_1 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__3ARGS, t_1 );
 
 /* METHOD_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc6, ": HdlrFunc6 (2328107544)" );
 t_1 = NewFunction( NameFunc[6], NargFunc[6], NamsFunc[6], HdlrFunc6);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__4ARGS, t_1 );
 
 /* METHOD_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc7, ": HdlrFunc7 (2328107544)" );
 t_1 = NewFunction( NameFunc[7], NargFunc[7], NamsFunc[7], HdlrFunc7);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__5ARGS, t_1 );
 
 /* METHOD_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc8, ": HdlrFunc8 (2328107544)" );
 t_1 = NewFunction( NameFunc[8], NargFunc[8], NamsFunc[8], HdlrFunc8);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__6ARGS, t_1 );
 
 /* METHOD_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc9, ": HdlrFunc9 (2328107544)" );
 t_1 = NewFunction( NameFunc[9], NargFunc[9], NamsFunc[9], HdlrFunc9);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_METHOD__XARGS, t_1 );
 
 /* NEXT_METHOD_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc10, ": HdlrFunc10 (2328107544)" );
 t_1 = NewFunction( NameFunc[10], NargFunc[10], NamsFunc[10], HdlrFunc10);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__0ARGS, t_1 );
 
 /* NEXT_METHOD_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc11, ": HdlrFunc11 (2328107544)" );
 t_1 = NewFunction( NameFunc[11], NargFunc[11], NamsFunc[11], HdlrFunc11);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__1ARGS, t_1 );
 
 /* NEXT_METHOD_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc12, ": HdlrFunc12 (2328107544)" );
 t_1 = NewFunction( NameFunc[12], NargFunc[12], NamsFunc[12], HdlrFunc12);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__2ARGS, t_1 );
 
 /* NEXT_METHOD_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc13, ": HdlrFunc13 (2328107544)" );
 t_1 = NewFunction( NameFunc[13], NargFunc[13], NamsFunc[13], HdlrFunc13);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__3ARGS, t_1 );
 
 /* NEXT_METHOD_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc14, ": HdlrFunc14 (2328107544)" );
 t_1 = NewFunction( NameFunc[14], NargFunc[14], NamsFunc[14], HdlrFunc14);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__4ARGS, t_1 );
 
 /* NEXT_METHOD_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc15, ": HdlrFunc15 (2328107544)" );
 t_1 = NewFunction( NameFunc[15], NargFunc[15], NamsFunc[15], HdlrFunc15);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__5ARGS, t_1 );
 
 /* NEXT_METHOD_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc16, ": HdlrFunc16 (2328107544)" );
 t_1 = NewFunction( NameFunc[16], NargFunc[16], NamsFunc[16], HdlrFunc16);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__6ARGS, t_1 );
 
 /* NEXT_METHOD_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc17, ": HdlrFunc17 (2328107544)" );
 t_1 = NewFunction( NameFunc[17], NargFunc[17], NamsFunc[17], HdlrFunc17);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__METHOD__XARGS, t_1 );
 
 /* VMETHOD_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc18, ": HdlrFunc18 (2328107544)" );
 t_1 = NewFunction( NameFunc[18], NargFunc[18], NamsFunc[18], HdlrFunc18);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__0ARGS, t_1 );
 
 /* VMETHOD_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc19, ": HdlrFunc19 (2328107544)" );
 t_1 = NewFunction( NameFunc[19], NargFunc[19], NamsFunc[19], HdlrFunc19);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__1ARGS, t_1 );
 
 /* VMETHOD_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc20, ": HdlrFunc20 (2328107544)" );
 t_1 = NewFunction( NameFunc[20], NargFunc[20], NamsFunc[20], HdlrFunc20);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__2ARGS, t_1 );
 
 /* VMETHOD_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc21, ": HdlrFunc21 (2328107544)" );
 t_1 = NewFunction( NameFunc[21], NargFunc[21], NamsFunc[21], HdlrFunc21);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__3ARGS, t_1 );
 
 /* VMETHOD_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc22, ": HdlrFunc22 (2328107544)" );
 t_1 = NewFunction( NameFunc[22], NargFunc[22], NamsFunc[22], HdlrFunc22);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__4ARGS, t_1 );
 
 /* VMETHOD_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc23, ": HdlrFunc23 (2328107544)" );
 t_1 = NewFunction( NameFunc[23], NargFunc[23], NamsFunc[23], HdlrFunc23);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__5ARGS, t_1 );
 
 /* VMETHOD_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc24, ": HdlrFunc24 (2328107544)" );
 t_1 = NewFunction( NameFunc[24], NargFunc[24], NamsFunc[24], HdlrFunc24);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__6ARGS, t_1 );
 
 /* VMETHOD_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc25, ": HdlrFunc25 (2328107544)" );
 t_1 = NewFunction( NameFunc[25], NargFunc[25], NamsFunc[25], HdlrFunc25);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VMETHOD__XARGS, t_1 );
 
 /* NEXT_VMETHOD_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc26, ": HdlrFunc26 (2328107544)" );
 t_1 = NewFunction( NameFunc[26], NargFunc[26], NamsFunc[26], HdlrFunc26);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__0ARGS, t_1 );
 
 /* NEXT_VMETHOD_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc27, ": HdlrFunc27 (2328107544)" );
 t_1 = NewFunction( NameFunc[27], NargFunc[27], NamsFunc[27], HdlrFunc27);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__1ARGS, t_1 );
 
 /* NEXT_VMETHOD_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc28, ": HdlrFunc28 (2328107544)" );
 t_1 = NewFunction( NameFunc[28], NargFunc[28], NamsFunc[28], HdlrFunc28);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__2ARGS, t_1 );
 
 /* NEXT_VMETHOD_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc29, ": HdlrFunc29 (2328107544)" );
 t_1 = NewFunction( NameFunc[29], NargFunc[29], NamsFunc[29], HdlrFunc29);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__3ARGS, t_1 );
 
 /* NEXT_VMETHOD_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc30, ": HdlrFunc30 (2328107544)" );
 t_1 = NewFunction( NameFunc[30], NargFunc[30], NamsFunc[30], HdlrFunc30);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__4ARGS, t_1 );
 
 /* NEXT_VMETHOD_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc31, ": HdlrFunc31 (2328107544)" );
 t_1 = NewFunction( NameFunc[31], NargFunc[31], NamsFunc[31], HdlrFunc31);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__5ARGS, t_1 );
 
 /* NEXT_VMETHOD_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc32, ": HdlrFunc32 (2328107544)" );
 t_1 = NewFunction( NameFunc[32], NargFunc[32], NamsFunc[32], HdlrFunc32);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__6ARGS, t_1 );
 
 /* NEXT_VMETHOD_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc33, ": HdlrFunc33 (2328107544)" );
 t_1 = NewFunction( NameFunc[33], NargFunc[33], NamsFunc[33], HdlrFunc33);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VMETHOD__XARGS, t_1 );
 
 /* CONSTRUCTOR_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc34, ": HdlrFunc34 (2328107544)" );
 t_1 = NewFunction( NameFunc[34], NargFunc[34], NamsFunc[34], HdlrFunc34);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__0ARGS, t_1 );
 
 /* CONSTRUCTOR_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc35, ": HdlrFunc35 (2328107544)" );
 t_1 = NewFunction( NameFunc[35], NargFunc[35], NamsFunc[35], HdlrFunc35);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__1ARGS, t_1 );
 
 /* CONSTRUCTOR_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc36, ": HdlrFunc36 (2328107544)" );
 t_1 = NewFunction( NameFunc[36], NargFunc[36], NamsFunc[36], HdlrFunc36);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__2ARGS, t_1 );
 
 /* CONSTRUCTOR_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc37, ": HdlrFunc37 (2328107544)" );
 t_1 = NewFunction( NameFunc[37], NargFunc[37], NamsFunc[37], HdlrFunc37);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__3ARGS, t_1 );
 
 /* CONSTRUCTOR_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc38, ": HdlrFunc38 (2328107544)" );
 t_1 = NewFunction( NameFunc[38], NargFunc[38], NamsFunc[38], HdlrFunc38);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__4ARGS, t_1 );
 
 /* CONSTRUCTOR_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc39, ": HdlrFunc39 (2328107544)" );
 t_1 = NewFunction( NameFunc[39], NargFunc[39], NamsFunc[39], HdlrFunc39);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__5ARGS, t_1 );
 
 /* CONSTRUCTOR_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc40, ": HdlrFunc40 (2328107544)" );
 t_1 = NewFunction( NameFunc[40], NargFunc[40], NamsFunc[40], HdlrFunc40);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__6ARGS, t_1 );
 
 /* CONSTRUCTOR_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc41, ": HdlrFunc41 (2328107544)" );
 t_1 = NewFunction( NameFunc[41], NargFunc[41], NamsFunc[41], HdlrFunc41);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CONSTRUCTOR__XARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc42, ": HdlrFunc42 (2328107544)" );
 t_1 = NewFunction( NameFunc[42], NargFunc[42], NamsFunc[42], HdlrFunc42);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__0ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc43, ": HdlrFunc43 (2328107544)" );
 t_1 = NewFunction( NameFunc[43], NargFunc[43], NamsFunc[43], HdlrFunc43);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__1ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc44, ": HdlrFunc44 (2328107544)" );
 t_1 = NewFunction( NameFunc[44], NargFunc[44], NamsFunc[44], HdlrFunc44);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__2ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc45, ": HdlrFunc45 (2328107544)" );
 t_1 = NewFunction( NameFunc[45], NargFunc[45], NamsFunc[45], HdlrFunc45);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__3ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc46, ": HdlrFunc46 (2328107544)" );
 t_1 = NewFunction( NameFunc[46], NargFunc[46], NamsFunc[46], HdlrFunc46);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__4ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc47, ": HdlrFunc47 (2328107544)" );
 t_1 = NewFunction( NameFunc[47], NargFunc[47], NamsFunc[47], HdlrFunc47);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__5ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc48, ": HdlrFunc48 (2328107544)" );
 t_1 = NewFunction( NameFunc[48], NargFunc[48], NamsFunc[48], HdlrFunc48);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__6ARGS, t_1 );
 
 /* NEXT_CONSTRUCTOR_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc49, ": HdlrFunc49 (2328107544)" );
 t_1 = NewFunction( NameFunc[49], NargFunc[49], NamsFunc[49], HdlrFunc49);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__CONSTRUCTOR__XARGS, t_1 );
 
 /* VCONSTRUCTOR_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc50, ": HdlrFunc50 (2328107544)" );
 t_1 = NewFunction( NameFunc[50], NargFunc[50], NamsFunc[50], HdlrFunc50);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__0ARGS, t_1 );
 
 /* VCONSTRUCTOR_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc51, ": HdlrFunc51 (2328107544)" );
 t_1 = NewFunction( NameFunc[51], NargFunc[51], NamsFunc[51], HdlrFunc51);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__1ARGS, t_1 );
 
 /* VCONSTRUCTOR_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc52, ": HdlrFunc52 (2328107544)" );
 t_1 = NewFunction( NameFunc[52], NargFunc[52], NamsFunc[52], HdlrFunc52);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__2ARGS, t_1 );
 
 /* VCONSTRUCTOR_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc53, ": HdlrFunc53 (2328107544)" );
 t_1 = NewFunction( NameFunc[53], NargFunc[53], NamsFunc[53], HdlrFunc53);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__3ARGS, t_1 );
 
 /* VCONSTRUCTOR_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc54, ": HdlrFunc54 (2328107544)" );
 t_1 = NewFunction( NameFunc[54], NargFunc[54], NamsFunc[54], HdlrFunc54);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__4ARGS, t_1 );
 
 /* VCONSTRUCTOR_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc55, ": HdlrFunc55 (2328107544)" );
 t_1 = NewFunction( NameFunc[55], NargFunc[55], NamsFunc[55], HdlrFunc55);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__5ARGS, t_1 );
 
 /* VCONSTRUCTOR_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc56, ": HdlrFunc56 (2328107544)" );
 t_1 = NewFunction( NameFunc[56], NargFunc[56], NamsFunc[56], HdlrFunc56);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__6ARGS, t_1 );
 
 /* VCONSTRUCTOR_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc57, ": HdlrFunc57 (2328107544)" );
 t_1 = NewFunction( NameFunc[57], NargFunc[57], NamsFunc[57], HdlrFunc57);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_VCONSTRUCTOR__XARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_0ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc58, ": HdlrFunc58 (2328107544)" );
 t_1 = NewFunction( NameFunc[58], NargFunc[58], NamsFunc[58], HdlrFunc58);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__0ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_1ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc59, ": HdlrFunc59 (2328107544)" );
 t_1 = NewFunction( NameFunc[59], NargFunc[59], NamsFunc[59], HdlrFunc59);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__1ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_2ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc60, ": HdlrFunc60 (2328107544)" );
 t_1 = NewFunction( NameFunc[60], NargFunc[60], NamsFunc[60], HdlrFunc60);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__2ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_3ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc61, ": HdlrFunc61 (2328107544)" );
 t_1 = NewFunction( NameFunc[61], NargFunc[61], NamsFunc[61], HdlrFunc61);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__3ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_4ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc62, ": HdlrFunc62 (2328107544)" );
 t_1 = NewFunction( NameFunc[62], NargFunc[62], NamsFunc[62], HdlrFunc62);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__4ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_5ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc63, ": HdlrFunc63 (2328107544)" );
 t_1 = NewFunction( NameFunc[63], NargFunc[63], NamsFunc[63], HdlrFunc63);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__5ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_6ARGS := function ... end; */
 InitHandlerFunc( HdlrFunc64, ": HdlrFunc64 (2328107544)" );
 t_1 = NewFunction( NameFunc[64], NargFunc[64], NamsFunc[64], HdlrFunc64);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__6ARGS, t_1 );
 
 /* NEXT_VCONSTRUCTOR_XARGS := function ... end; */
 InitHandlerFunc( HdlrFunc65, ": HdlrFunc65 (2328107544)" );
 t_1 = NewFunction( NameFunc[65], NargFunc[65], NamsFunc[65], HdlrFunc65);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEXT__VCONSTRUCTOR__XARGS, t_1 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'Function1' returns the main function of this module */
static Obj  Function1 ( void )
{
 Obj  func1;
 InitHandlerFunc( HdlrFunc1, ": HdlrFunc1 (2328107544)" );
 func1 = NewFunction( NameFunc[1], NargFunc[1], NamsFunc[1], HdlrFunc1 );
 ENVI_FUNC( func1 ) = CurrLVars;
 CHANGED_BAG( CurrLVars );
 return func1;
}


/* <name> returns the description of this module */
static StructCompInitInfo Description = {
 /* magic1    = */ 2328107544UL,
 /* magic2    = */ "GAPROOT/lib/methsel.g",
 /* link      = */ Link,
 /* function1 = */ (Int(*)())Function1,
 /* functions = */ 0 };

StructCompInitInfo *  Init_lib_methsel_g ( void )
{
 return &Description;
}

/* compiled code ends here */

#endif
