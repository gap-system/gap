/* C file produced by GAC */
#include "compiled.h"

#ifndef AVOID_PRECOMPILED

/* global variables used in handlers */
static GVar G_REREADING;
static Obj  GC_REREADING;
static GVar G_SHALLOW__COPY__OBJ;
static Obj  GF_SHALLOW__COPY__OBJ;
static GVar G_PRINT__OBJ;
static Obj  GC_PRINT__OBJ;
static GVar G_CALL__FUNC__LIST;
static Obj  GF_CALL__FUNC__LIST;
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
static GVar G_IS__REC;
static Obj  GF_IS__REC;
static GVar G_IS__LIST;
static Obj  GF_IS__LIST;
static GVar G_ADD__LIST;
static Obj  GF_ADD__LIST;
static GVar G_IS__PLIST__REP;
static Obj  GF_IS__PLIST__REP;
static GVar G_IS__BLIST;
static Obj  GF_IS__BLIST;
static GVar G_IS__RANGE;
static Obj  GF_IS__RANGE;
static GVar G_IS__STRING__REP;
static Obj  GF_IS__STRING__REP;
static GVar G_TYPE__OBJ;
static Obj  GC_TYPE__OBJ;
static Obj  GF_TYPE__OBJ;
static GVar G_FAMILY__OBJ;
static Obj  GC_FAMILY__OBJ;
static GVar G_IS__IDENTICAL__OBJ;
static Obj  GF_IS__IDENTICAL__OBJ;
static GVar G_IS__COMOBJ;
static Obj  GF_IS__COMOBJ;
static GVar G_SET__TYPE__COMOBJ;
static Obj  GF_SET__TYPE__COMOBJ;
static GVar G_IS__POSOBJ;
static Obj  GF_IS__POSOBJ;
static GVar G_SET__TYPE__POSOBJ;
static Obj  GF_SET__TYPE__POSOBJ;
static GVar G_LEN__POSOBJ;
static Obj  GF_LEN__POSOBJ;
static GVar G_IS__DATOBJ;
static Obj  GF_IS__DATOBJ;
static GVar G_SET__TYPE__DATOBJ;
static Obj  GF_SET__TYPE__DATOBJ;
static GVar G_IS__OBJECT;
static Obj  GC_IS__OBJECT;
static GVar G_AND__FLAGS;
static Obj  GF_AND__FLAGS;
static GVar G_SUB__FLAGS;
static Obj  GF_SUB__FLAGS;
static GVar G_HASH__FLAGS;
static Obj  GF_HASH__FLAGS;
static GVar G_IS__EQUAL__FLAGS;
static Obj  GF_IS__EQUAL__FLAGS;
static GVar G_IS__SUBSET__FLAGS;
static Obj  GF_IS__SUBSET__FLAGS;
static GVar G_TRUES__FLAGS;
static Obj  GF_TRUES__FLAGS;
static GVar G_FLAG1__FILTER;
static Obj  GF_FLAG1__FILTER;
static GVar G_FLAGS__FILTER;
static Obj  GF_FLAGS__FILTER;
static GVar G_NEW__FILTER;
static Obj  GF_NEW__FILTER;
static GVar G_SETTER__FUNCTION;
static Obj  GF_SETTER__FUNCTION;
static GVar G_GETTER__FUNCTION;
static Obj  GF_GETTER__FUNCTION;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_SET__FILTER__LIST;
static Obj  GF_SET__FILTER__LIST;
static GVar G_RESET__FILTER__LIST;
static Obj  GF_RESET__FILTER__LIST;
static GVar G_APPEND__LIST__INTR;
static Obj  GF_APPEND__LIST__INTR;
static GVar G_ADD__SET;
static Obj  GF_ADD__SET;
static GVar G_CONV__STRING;
static Obj  GF_CONV__STRING;
static GVar G_Print;
static Obj  GF_Print;
static GVar G_Revision;
static Obj  GC_Revision;
static GVar G_Error;
static Obj  GF_Error;
static GVar G_TNUM__OBJ;
static Obj  GF_TNUM__OBJ;
static GVar G_BIND__GLOBAL;
static Obj  GF_BIND__GLOBAL;
static GVar G_NEW__TYPE__NEXT__ID;
static Obj  GC_NEW__TYPE__NEXT__ID;
static GVar G_CATS__AND__REPS;
static Obj  GC_CATS__AND__REPS;
static GVar G_FILTERS;
static Obj  GC_FILTERS;
static GVar G_INFO__FILTERS;
static Obj  GC_INFO__FILTERS;
static GVar G_RANK__FILTERS;
static Obj  GC_RANK__FILTERS;
static GVar G_InstallTrueMethod;
static Obj  GF_InstallTrueMethod;
static GVar G_InstallTrueMethodNewFilter;
static Obj  GF_InstallTrueMethodNewFilter;
static GVar G_NewCategory;
static Obj  GF_NewCategory;
static GVar G_NewRepresentation;
static Obj  GC_NewRepresentation;
static GVar G_DeclareRepresentation;
static Obj  GF_DeclareRepresentation;
static GVar G_IsComponentObjectRep;
static Obj  GC_IsComponentObjectRep;
static GVar G_InstallAttributeFunction;
static Obj  GF_InstallAttributeFunction;
static GVar G_InstallOtherMethod;
static Obj  GF_InstallOtherMethod;
static GVar G_IsAttributeStoringRep;
static Obj  GC_IsAttributeStoringRep;
static GVar G_SUM__FLAGS;
static Obj  GC_SUM__FLAGS;
static GVar G_SetFilterObj;
static Obj  GC_SetFilterObj;
static Obj  GF_SetFilterObj;
static GVar G_DeclareCategory;
static Obj  GF_DeclareCategory;
static GVar G_IsFamily;
static Obj  GC_IsFamily;
static Obj  GF_IsFamily;
static GVar G_IsPositionalObjectRep;
static Obj  GC_IsPositionalObjectRep;
static GVar G_IsType;
static Obj  GC_IsType;
static Obj  GF_IsType;
static GVar G_FamilyOfFamilies;
static Obj  GC_FamilyOfFamilies;
static GVar G_WITH__IMPS__FLAGS;
static Obj  GF_WITH__IMPS__FLAGS;
static GVar G_IsFamilyDefaultRep;
static Obj  GC_IsFamilyDefaultRep;
static GVar G_EMPTY__FLAGS;
static Obj  GC_EMPTY__FLAGS;
static GVar G_IsFamilyOfFamilies;
static Obj  GC_IsFamilyOfFamilies;
static GVar G_FamilyOfTypes;
static Obj  GC_FamilyOfTypes;
static GVar G_IsTypeDefaultRep;
static Obj  GC_IsTypeDefaultRep;
static GVar G_TypeOfFamilyOfTypes;
static Obj  GC_TypeOfFamilyOfTypes;
static GVar G_IsFamilyOfTypes;
static Obj  GC_IsFamilyOfTypes;
static GVar G_TypeOfFamilyOfFamilies;
static Obj  GC_TypeOfFamilyOfFamilies;
static GVar G_TypeOfFamilies;
static Obj  GC_TypeOfFamilies;
static GVar G_TypeOfTypes;
static Obj  GC_TypeOfTypes;
static GVar G_CATEGORIES__FAMILY;
static Obj  GC_CATEGORIES__FAMILY;
static GVar G_CategoryFamily;
static Obj  GF_CategoryFamily;
static GVar G_VALUE__GLOBAL;
static Obj  GF_VALUE__GLOBAL;
static GVar G_Subtype;
static Obj  GF_Subtype;
static GVar G_NEW__FAMILY;
static Obj  GF_NEW__FAMILY;
static GVar G_NewFamily2;
static Obj  GF_NewFamily2;
static GVar G_NewFamily3;
static Obj  GF_NewFamily3;
static GVar G_NewFamily4;
static Obj  GF_NewFamily4;
static GVar G_NewFamily5;
static Obj  GF_NewFamily5;
static GVar G_NEW__TYPE__CACHE__MISS;
static Obj  GC_NEW__TYPE__CACHE__MISS;
static GVar G_NEW__TYPE__CACHE__HIT;
static Obj  GC_NEW__TYPE__CACHE__HIT;
static GVar G_POS__DATA__TYPE;
static Obj  GC_POS__DATA__TYPE;
static GVar G_POS__NUMB__TYPE;
static Obj  GC_POS__NUMB__TYPE;
static GVar G_NEW__TYPE;
static Obj  GF_NEW__TYPE;
static GVar G_POS__FIRST__FREE__TYPE;
static Obj  GC_POS__FIRST__FREE__TYPE;
static GVar G_NewType2;
static Obj  GF_NewType2;
static GVar G_NewType3;
static Obj  GF_NewType3;
static GVar G_NewType4;
static Obj  GF_NewType4;
static GVar G_NewType5;
static Obj  GF_NewType5;
static GVar G_Subtype2;
static Obj  GF_Subtype2;
static GVar G_Subtype3;
static Obj  GF_Subtype3;
static GVar G_SupType2;
static Obj  GF_SupType2;
static GVar G_SupType3;
static Obj  GF_SupType3;
static GVar G_FlagsType;
static Obj  GF_FlagsType;
static GVar G_TypeObj;
static Obj  GF_TypeObj;
static GVar G_DataType;
static Obj  GF_DataType;
static GVar G_SharedType;
static Obj  GF_SharedType;
static GVar G_RunImmediateMethods;
static Obj  GF_RunImmediateMethods;
static GVar G_SetTypeObj;
static Obj  GC_SetTypeObj;
static GVar G_ChangeTypeObj;
static Obj  GC_ChangeTypeObj;
static GVar G_ResetFilterObj;
static Obj  GC_ResetFilterObj;
static Obj  GF_ResetFilterObj;

/* record names used in handlers */
static RNam R_TYPES__LIST__FAM;
static RNam R_type__g;
static RNam R_NAME;
static RNam R_REQ__FLAGS;
static RNam R_IMP__FLAGS;
static RNam R_TYPES;

/* information for the functions */
static Obj  NameFunc[50];
static Obj  NamsFunc[50];
static Int  NargFunc[50];
static Obj  DefaultName;

/* handler for function 2 */
static Obj  HdlrFunc2 (
 Obj  self,
 Obj  a_name,
 Obj  a_super,
 Obj  a_cat )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if not IS_IDENTICAL_OBJ( cat, IS_OBJECT ) then */
 t_4 = GF_IS__IDENTICAL__OBJ;
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 t_3 = CALL_2ARGS( t_4, a_cat, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) ); */
  t_1 = GF_ADD__LIST;
  t_2 = GC_CATS__AND__REPS;
  CHECK_BOUND( t_2, "CATS_AND_REPS" )
  t_4 = GF_FLAG1__FILTER;
  t_3 = CALL_1ARGS( t_4, a_cat );
  CHECK_FUNC_RESULT( t_3 )
  CALL_2ARGS( t_1, t_2, t_3 );
  
  /* FILTERS[FLAG1_FILTER( cat )] := cat; */
  t_1 = GC_FILTERS;
  CHECK_BOUND( t_1, "FILTERS" )
  t_3 = GF_FLAG1__FILTER;
  t_2 = CALL_1ARGS( t_3, a_cat );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_INT_SMALL_POS( t_2 )
  C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), a_cat )
  
  /* INFO_FILTERS[FLAG1_FILTER( cat )] := 1; */
  t_1 = GC_INFO__FILTERS;
  CHECK_BOUND( t_1, "INFO_FILTERS" )
  t_3 = GF_FLAG1__FILTER;
  t_2 = CALL_1ARGS( t_3, a_cat );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_INT_SMALL_POS( t_2 )
  C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
  
  /* RANK_FILTERS[FLAG1_FILTER( cat )] := 1; */
  t_1 = GC_RANK__FILTERS;
  CHECK_BOUND( t_1, "RANK_FILTERS" )
  t_3 = GF_FLAG1__FILTER;
  t_2 = CALL_1ARGS( t_3, a_cat );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_INT_SMALL_POS( t_2 )
  C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
  
  /* InstallTrueMethod( super, cat ); */
  t_1 = GF_InstallTrueMethod;
  CALL_2ARGS( t_1, a_super, a_cat );
  
 }
 /* fi */
 
 /* BIND_GLOBAL( name, cat ); */
 t_1 = GF_BIND__GLOBAL;
 CALL_2ARGS( t_1, a_name, a_cat );
 
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
 Obj  a_name,
 Obj  a_super )
{
 Obj l_cat = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* cat := NEW_FILTER( name ); */
 t_2 = GF_NEW__FILTER;
 t_1 = CALL_1ARGS( t_2, a_name );
 CHECK_FUNC_RESULT( t_1 )
 l_cat = t_1;
 
 /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATS__AND__REPS;
 CHECK_BOUND( t_2, "CATS_AND_REPS" )
 t_4 = GF_FLAG1__FILTER;
 t_3 = CALL_1ARGS( t_4, l_cat );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FILTERS[FLAG1_FILTER( cat )] := cat; */
 t_1 = GC_FILTERS;
 CHECK_BOUND( t_1, "FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_cat );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), l_cat )
 
 /* RANK_FILTERS[FLAG1_FILTER( cat )] := 1; */
 t_1 = GC_RANK__FILTERS;
 CHECK_BOUND( t_1, "RANK_FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_cat );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
 
 /* INFO_FILTERS[FLAG1_FILTER( cat )] := 2; */
 t_1 = GC_INFO__FILTERS;
 CHECK_BOUND( t_1, "INFO_FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_cat );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(2) )
 
 /* InstallTrueMethodNewFilter( super, cat ); */
 t_1 = GF_InstallTrueMethodNewFilter;
 CALL_2ARGS( t_1, a_super, l_cat );
 
 /* return cat; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_cat;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 4 */
static Obj  HdlrFunc4 (
 Obj  self,
 Obj  a_name,
 Obj  a_super )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* BIND_GLOBAL( name, NewCategory( name, super ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_3 = GF_NewCategory;
 t_2 = CALL_2ARGS( t_3, a_name, a_super );
 CHECK_FUNC_RESULT( t_2 )
 CALL_2ARGS( t_1, a_name, t_2 );
 
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
 Obj  a_arg )
{
 Obj l_rep = 0;
 Obj l_filt = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if REREADING then */
 t_2 = GC_REREADING;
 CHECK_BOUND( t_2, "REREADING" )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* for filt in CATS_AND_REPS do */
  t_4 = GC_CATS__AND__REPS;
  CHECK_BOUND( t_4, "CATS_AND_REPS" )
  if ( IS_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_filt = t_2;
   
   /* if NAME_FUNC( FILTERS[filt] ) = arg[1] then */
   t_7 = GF_NAME__FUNC;
   t_9 = GC_FILTERS;
   CHECK_BOUND( t_9, "FILTERS" )
   CHECK_INT_SMALL_POS( l_filt )
   C_ELM_LIST_FPL( t_8, t_9, INT_INTOBJ(l_filt) )
   t_6 = CALL_1ARGS( t_7, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   C_ELM_LIST_FPL( t_7, a_arg, 1 )
   t_5 = (Obj)(UInt)(EQ( t_6, t_7 ));
   if ( t_5 ) {
    
    /* Print( "#W DeclareRepresentationKernel \"", arg[1], "\" in Reread. " ); */
    t_5 = GF_Print;
    C_NEW_STRING( t_6, 32, "#W DeclareRepresentationKernel \"" )
    C_ELM_LIST_FPL( t_7, a_arg, 1 )
    C_NEW_STRING( t_8, 13, "\" in Reread. " )
    CALL_3ARGS( t_5, t_6, t_7, t_8 );
    
    /* Print( "Change of Super-rep not handled\n" ); */
    t_5 = GF_Print;
    C_NEW_STRING( t_6, 32, "Change of Super-rep not handled\n" )
    CALL_1ARGS( t_5, t_6 );
    
    /* return FILTERS[filt]; */
    t_6 = GC_FILTERS;
    CHECK_BOUND( t_6, "FILTERS" )
    C_ELM_LIST_FPL( t_5, t_6, INT_INTOBJ(l_filt) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_5;
    
   }
   /* fi */
   
  }
  /* od */
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 4 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(4) ));
 if ( t_1 ) {
  
  /* rep := arg[4]; */
  C_ELM_LIST_FPL( t_1, a_arg, 4 )
  l_rep = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 5 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(5) ));
  if ( t_1 ) {
   
   /* rep := arg[5]; */
   C_ELM_LIST_FPL( t_1, a_arg, 5 )
   l_rep = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "usage:DeclareRepresentation(<name>,<super>,<slots>[,<req>])" ); */
   t_1 = GF_Error;
   C_NEW_STRING( t_2, 59, "usage:DeclareRepresentation(<name>,<super>,<slots>[,<req>])" )
   CALL_1ARGS( t_1, t_2 );
   
  }
 }
 /* fi */
 
 /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATS__AND__REPS;
 CHECK_BOUND( t_2, "CATS_AND_REPS" )
 t_4 = GF_FLAG1__FILTER;
 CHECK_BOUND( l_rep, "rep" )
 t_3 = CALL_1ARGS( t_4, l_rep );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FILTERS[FLAG1_FILTER( rep )] := rep; */
 t_1 = GC_FILTERS;
 CHECK_BOUND( t_1, "FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), l_rep )
 
 /* RANK_FILTERS[FLAG1_FILTER( rep )] := 1; */
 t_1 = GC_RANK__FILTERS;
 CHECK_BOUND( t_1, "RANK_FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
 
 /* INFO_FILTERS[FLAG1_FILTER( rep )] := 3; */
 t_1 = GC_INFO__FILTERS;
 CHECK_BOUND( t_1, "INFO_FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(3) )
 
 /* InstallTrueMethod( arg[2], rep ); */
 t_1 = GF_InstallTrueMethod;
 C_ELM_LIST_FPL( t_2, a_arg, 2 )
 CALL_2ARGS( t_1, t_2, l_rep );
 
 /* BIND_GLOBAL( arg[1], rep ); */
 t_1 = GF_BIND__GLOBAL;
 C_ELM_LIST_FPL( t_2, a_arg, 1 )
 CALL_2ARGS( t_1, t_2, l_rep );
 
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
 Obj  a_arg )
{
 Obj l_rep = 0;
 Obj l_filt = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if REREADING then */
 t_2 = GC_REREADING;
 CHECK_BOUND( t_2, "REREADING" )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* for filt in CATS_AND_REPS do */
  t_4 = GC_CATS__AND__REPS;
  CHECK_BOUND( t_4, "CATS_AND_REPS" )
  if ( IS_LIST(t_4) ) {
   t_3 = (Obj)(UInt)1;
   t_1 = INTOBJ_INT(1);
  }
  else {
   t_3 = (Obj)(UInt)0;
   t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
  }
  while ( 1 ) {
   if ( t_3 ) {
    if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
    t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
    t_1 = (Obj)(((UInt)t_1)+4);
    if ( t_2 == 0 )  continue;
   }
   else {
    if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
    t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
   }
   l_filt = t_2;
   
   /* if NAME_FUNC( FILTERS[filt] ) = arg[1] then */
   t_7 = GF_NAME__FUNC;
   t_9 = GC_FILTERS;
   CHECK_BOUND( t_9, "FILTERS" )
   CHECK_INT_SMALL_POS( l_filt )
   C_ELM_LIST_FPL( t_8, t_9, INT_INTOBJ(l_filt) )
   t_6 = CALL_1ARGS( t_7, t_8 );
   CHECK_FUNC_RESULT( t_6 )
   C_ELM_LIST_FPL( t_7, a_arg, 1 )
   t_5 = (Obj)(UInt)(EQ( t_6, t_7 ));
   if ( t_5 ) {
    
    /* Print( "#W NewRepresentation \"", arg[1], "\" in Reread. " ); */
    t_5 = GF_Print;
    C_NEW_STRING( t_6, 22, "#W NewRepresentation \"" )
    C_ELM_LIST_FPL( t_7, a_arg, 1 )
    C_NEW_STRING( t_8, 13, "\" in Reread. " )
    CALL_3ARGS( t_5, t_6, t_7, t_8 );
    
    /* Print( "Change of Super-rep not handled\n" ); */
    t_5 = GF_Print;
    C_NEW_STRING( t_6, 32, "Change of Super-rep not handled\n" )
    CALL_1ARGS( t_5, t_6 );
    
    /* return FILTERS[filt]; */
    t_6 = GC_FILTERS;
    CHECK_BOUND( t_6, "FILTERS" )
    C_ELM_LIST_FPL( t_5, t_6, INT_INTOBJ(l_filt) )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_5;
    
   }
   /* fi */
   
  }
  /* od */
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 3 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(3) ));
 if ( t_1 ) {
  
  /* rep := NEW_FILTER( arg[1] ); */
  t_2 = GF_NEW__FILTER;
  C_ELM_LIST_FPL( t_3, a_arg, 1 )
  t_1 = CALL_1ARGS( t_2, t_3 );
  CHECK_FUNC_RESULT( t_1 )
  l_rep = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 4 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(4) ));
  if ( t_1 ) {
   
   /* rep := NEW_FILTER( arg[1] ); */
   t_2 = GF_NEW__FILTER;
   C_ELM_LIST_FPL( t_3, a_arg, 1 )
   t_1 = CALL_1ARGS( t_2, t_3 );
   CHECK_FUNC_RESULT( t_1 )
   l_rep = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "usage:NewRepresentation(<name>,<super>,<slots>[,<req>])" ); */
   t_1 = GF_Error;
   C_NEW_STRING( t_2, 55, "usage:NewRepresentation(<name>,<super>,<slots>[,<req>])" )
   CALL_1ARGS( t_1, t_2 );
   
  }
 }
 /* fi */
 
 /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATS__AND__REPS;
 CHECK_BOUND( t_2, "CATS_AND_REPS" )
 t_4 = GF_FLAG1__FILTER;
 CHECK_BOUND( l_rep, "rep" )
 t_3 = CALL_1ARGS( t_4, l_rep );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FILTERS[FLAG1_FILTER( rep )] := rep; */
 t_1 = GC_FILTERS;
 CHECK_BOUND( t_1, "FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), l_rep )
 
 /* RANK_FILTERS[FLAG1_FILTER( rep )] := 1; */
 t_1 = GC_RANK__FILTERS;
 CHECK_BOUND( t_1, "RANK_FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
 
 /* INFO_FILTERS[FLAG1_FILTER( rep )] := 4; */
 t_1 = GC_INFO__FILTERS;
 CHECK_BOUND( t_1, "INFO_FILTERS" )
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_INT_SMALL_POS( t_2 )
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(4) )
 
 /* InstallTrueMethodNewFilter( arg[2], rep ); */
 t_1 = GF_InstallTrueMethodNewFilter;
 C_ELM_LIST_FPL( t_2, a_arg, 2 )
 CALL_2ARGS( t_1, t_2, l_rep );
 
 /* return rep; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_rep;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 7 */
static Obj  HdlrFunc7 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* BIND_GLOBAL( arg[1], CALL_FUNC_LIST( NewRepresentation, arg ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_ELM_LIST_FPL( t_2, a_arg, 1 )
 t_4 = GF_CALL__FUNC__LIST;
 t_5 = GC_NewRepresentation;
 CHECK_BOUND( t_5, "NewRepresentation" )
 t_3 = CALL_2ARGS( t_4, t_5, a_arg );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
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
 Obj  a_name,
 Obj  a_filter,
 Obj  a_getter,
 Obj  a_setter,
 Obj  a_tester,
 Obj  a_mutflag )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* InstallOtherMethod( getter, "system getter", true, [ IsAttributeStoringRep and tester ], 2 * SUM_FLAGS, GETTER_FUNCTION( name ) ); */
 t_1 = GF_InstallOtherMethod;
 C_NEW_STRING( t_2, 13, "system getter" )
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_6 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_6, "IsAttributeStoringRep" )
 if ( t_6 == False ) {
  t_5 = t_6;
 }
 else if ( t_6 == True ) {
  CHECK_BOOL( a_tester )
  t_5 = a_tester;
 }
 else {
  CHECK_FUNC( t_6 )
  CHECK_FUNC( a_tester )
  t_5 = NewAndFilter( t_6, a_tester );
 }
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_6 = GC_SUM__FLAGS;
 CHECK_BOUND( t_6, "SUM_FLAGS" )
 C_PROD( t_5, INTOBJ_INT(2), t_6 )
 t_7 = GF_GETTER__FUNCTION;
 t_6 = CALL_1ARGS( t_7, a_name );
 CHECK_FUNC_RESULT( t_6 )
 CALL_6ARGS( t_1, a_getter, t_2, t_3, t_4, t_5, t_6 );
 
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
 Obj  a_obj,
 Obj  a_val )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* obj!.(name) := val; */
 t_1 = OBJ_LVAR_0UP( 1 );
 CHECK_BOUND( t_1, "name" )
 if ( TNUM_OBJ(a_obj) == T_COMOBJ ) {
  AssPRec( a_obj, RNamObj(t_1), a_val );
 }
 else {
  ASS_REC( a_obj, RNamObj(t_1), a_val );
 }
 
 /* SetFilterObj( obj, tester ); */
 t_1 = GF_SetFilterObj;
 t_2 = OBJ_LVAR_0UP( 2 );
 CHECK_BOUND( t_2, "tester" )
 CALL_2ARGS( t_1, a_obj, t_2 );
 
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
 Obj  a_name,
 Obj  a_filter,
 Obj  a_getter,
 Obj  a_setter,
 Obj  a_tester,
 Obj  a_mutflag )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,2,0,oldFrame);
 ASS_LVAR( 1, a_name );
 ASS_LVAR( 2, a_tester );
 
 /* if mutflag then */
 CHECK_BOOL( a_mutflag )
 t_1 = (Obj)(UInt)(a_mutflag != False);
 if ( t_1 ) {
  
  /* InstallOtherMethod( setter, "system mutable setter", true, [ IsAttributeStoringRep, IS_OBJECT ], SUM_FLAGS, function ... end ); */
  t_1 = GF_InstallOtherMethod;
  C_NEW_STRING( t_2, 21, "system mutable setter" )
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_5, "IsAttributeStoringRep" )
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  CHECK_BOUND( t_5, "IS_OBJECT" )
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_SUM__FLAGS;
  CHECK_BOUND( t_5, "SUM_FLAGS" )
  t_6 = NewFunction( NameFunc[10], NargFunc[10], NamsFunc[10], HdlrFunc10 );
  ENVI_FUNC( t_6 ) = CurrLVars;
  t_7 = NewBag( T_BODY, 0 );
  BODY_FUNC(t_6) = t_7;
  CHANGED_BAG( CurrLVars );
  CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, t_5, t_6 );
  
 }
 
 /* else */
 else {
  
  /* InstallOtherMethod( setter, "system setter", true, [ IsAttributeStoringRep, IS_OBJECT ], SUM_FLAGS, SETTER_FUNCTION( name, tester ) ); */
  t_1 = GF_InstallOtherMethod;
  C_NEW_STRING( t_2, 13, "system setter" )
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_5, "IsAttributeStoringRep" )
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  CHECK_BOUND( t_5, "IS_OBJECT" )
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_SUM__FLAGS;
  CHECK_BOUND( t_5, "SUM_FLAGS" )
  t_7 = GF_SETTER__FUNCTION;
  t_8 = OBJ_LVAR( 1 );
  CHECK_BOUND( t_8, "name" )
  t_9 = OBJ_LVAR( 2 );
  CHECK_BOUND( t_9, "tester" )
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
  CHECK_FUNC_RESULT( t_6 )
  CALL_6ARGS( t_1, a_setter, t_2, t_3, t_4, t_5, t_6 );
  
 }
 /* fi */
 
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
 Obj  a_elms__filter )
{
 Obj l_pair = 0;
 Obj l_fam__filter = 0;
 Obj l_super = 0;
 Obj l_flags = 0;
 Obj l_name = 0;
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
 
 /* name := "CategoryFamily("; */
 C_NEW_STRING( t_1, 15, "CategoryFamily(" )
 l_name = t_1;
 
 /* APPEND_LIST_INTR( name, SHALLOW_COPY_OBJ( NAME_FUNC( elms_filter ) ) ); */
 t_1 = GF_APPEND__LIST__INTR;
 t_3 = GF_SHALLOW__COPY__OBJ;
 t_5 = GF_NAME__FUNC;
 t_4 = CALL_1ARGS( t_5, a_elms__filter );
 CHECK_FUNC_RESULT( t_4 )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 CALL_2ARGS( t_1, l_name, t_2 );
 
 /* APPEND_LIST_INTR( name, ")" ); */
 t_1 = GF_APPEND__LIST__INTR;
 C_NEW_STRING( t_2, 1, ")" )
 CALL_2ARGS( t_1, l_name, t_2 );
 
 /* CONV_STRING( name ); */
 t_1 = GF_CONV__STRING;
 CALL_1ARGS( t_1, l_name );
 
 /* elms_filter := FLAGS_FILTER( elms_filter ); */
 t_2 = GF_FLAGS__FILTER;
 t_1 = CALL_1ARGS( t_2, a_elms__filter );
 CHECK_FUNC_RESULT( t_1 )
 a_elms__filter = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_4, "CATEGORIES_FAMILY" )
 if ( IS_LIST(t_4) ) {
  t_3 = (Obj)(UInt)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)(UInt)0;
  t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
 }
 while ( 1 ) {
  if ( t_3 ) {
   if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
   t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
   t_1 = (Obj)(((UInt)t_1)+4);
   if ( t_2 == 0 )  continue;
  }
  else {
   if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
   t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
  }
  l_pair = t_2;
  
  /* if pair[1] = elms_filter then */
  C_ELM_LIST_FPL( t_6, l_pair, 1 )
  t_5 = (Obj)(UInt)(EQ( t_6, a_elms__filter ));
  if ( t_5 ) {
   
   /* return pair[2]; */
   C_ELM_LIST_FPL( t_5, l_pair, 2 )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* super := IsFamily; */
 t_1 = GC_IsFamily;
 CHECK_BOUND( t_1, "IsFamily" )
 l_super = t_1;
 
 /* flags := WITH_IMPS_FLAGS( elms_filter ); */
 t_2 = GF_WITH__IMPS__FLAGS;
 t_1 = CALL_1ARGS( t_2, a_elms__filter );
 CHECK_FUNC_RESULT( t_1 )
 l_flags = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_4, "CATEGORIES_FAMILY" )
 if ( IS_LIST(t_4) ) {
  t_3 = (Obj)(UInt)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)(UInt)0;
  t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
 }
 while ( 1 ) {
  if ( t_3 ) {
   if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
   t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
   t_1 = (Obj)(((UInt)t_1)+4);
   if ( t_2 == 0 )  continue;
  }
  else {
   if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
   t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
  }
  l_pair = t_2;
  
  /* if IS_SUBSET_FLAGS( flags, pair[1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_LIST_FPL( t_8, l_pair, 1 )
  t_6 = CALL_2ARGS( t_7, l_flags, t_8 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* super := super and pair[2]; */
   if ( l_super == False ) {
    t_5 = l_super;
   }
   else if ( l_super == True ) {
    C_ELM_LIST_FPL( t_6, l_pair, 2 )
    CHECK_BOOL( t_6 )
    t_5 = t_6;
   }
   else {
    CHECK_FUNC( l_super )
    C_ELM_LIST_FPL( t_7, l_pair, 2 )
    CHECK_FUNC( t_7 )
    t_5 = NewAndFilter( l_super, t_7 );
   }
   l_super = t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* fam_filter := NewCategory( name, super ); */
 t_2 = GF_NewCategory;
 t_1 = CALL_2ARGS( t_2, l_name, l_super );
 CHECK_FUNC_RESULT( t_1 )
 l_fam__filter = t_1;
 
 /* ADD_LIST( CATEGORIES_FAMILY, [ elms_filter, fam_filter ] ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_2, "CATEGORIES_FAMILY" )
 t_3 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_3, 2 );
 SET_ELM_PLIST( t_3, 1, a_elms__filter );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 2, l_fam__filter );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* return fam_filter; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_fam__filter;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
 Obj  self,
 Obj  a_name )
{
 Obj l_nname = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* nname := SHALLOW_COPY_OBJ( name ); */
 t_2 = GF_SHALLOW__COPY__OBJ;
 t_1 = CALL_1ARGS( t_2, a_name );
 CHECK_FUNC_RESULT( t_1 )
 l_nname = t_1;
 
 /* APPEND_LIST_INTR( nname, "Family" ); */
 t_1 = GF_APPEND__LIST__INTR;
 C_NEW_STRING( t_2, 6, "Family" )
 CALL_2ARGS( t_1, l_nname, t_2 );
 
 /* BIND_GLOBAL( nname, CategoryFamily( VALUE_GLOBAL( name ) ) ); */
 t_1 = GF_BIND__GLOBAL;
 t_3 = GF_CategoryFamily;
 t_5 = GF_VALUE__GLOBAL;
 t_4 = CALL_1ARGS( t_5, a_name );
 CHECK_FUNC_RESULT( t_4 )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 CALL_2ARGS( t_1, l_nname, t_2 );
 
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
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req__filter,
 Obj  a_imp__filter )
{
 Obj l_type = 0;
 Obj l_pair = 0;
 Obj l_family = 0;
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
 
 /* imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) ); */
 t_2 = GF_WITH__IMPS__FLAGS;
 t_4 = GF_AND__FLAGS;
 t_3 = CALL_2ARGS( t_4, a_imp__filter, a_req__filter );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 a_imp__filter = t_1;
 
 /* type := Subtype( typeOfFamilies, IsAttributeStoringRep ); */
 t_2 = GF_Subtype;
 t_3 = GC_IsAttributeStoringRep;
 CHECK_BOUND( t_3, "IsAttributeStoringRep" )
 t_1 = CALL_2ARGS( t_2, a_typeOfFamilies, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 l_type = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 CHECK_BOUND( t_4, "CATEGORIES_FAMILY" )
 if ( IS_LIST(t_4) ) {
  t_3 = (Obj)(UInt)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)(UInt)0;
  t_1 = CALL_1ARGS( GF_ITERATOR, t_4 );
 }
 while ( 1 ) {
  if ( t_3 ) {
   if ( LEN_LIST(t_4) < INT_INTOBJ(t_1) )  break;
   t_2 = ELMV0_LIST( t_4, INT_INTOBJ(t_1) );
   t_1 = (Obj)(((UInt)t_1)+4);
   if ( t_2 == 0 )  continue;
  }
  else {
   if ( CALL_1ARGS( GF_IS_DONE_ITER, t_1 ) != False )  break;
   t_2 = CALL_1ARGS( GF_NEXT_ITER, t_1 );
  }
  l_pair = t_2;
  
  /* if IS_SUBSET_FLAGS( imp_filter, pair[1] ) then */
  t_7 = GF_IS__SUBSET__FLAGS;
  C_ELM_LIST_FPL( t_8, l_pair, 1 )
  t_6 = CALL_2ARGS( t_7, a_imp__filter, t_8 );
  CHECK_FUNC_RESULT( t_6 )
  CHECK_BOOL( t_6 )
  t_5 = (Obj)(UInt)(t_6 != False);
  if ( t_5 ) {
   
   /* type := Subtype( type, pair[2] ); */
   t_6 = GF_Subtype;
   C_ELM_LIST_FPL( t_7, l_pair, 2 )
   t_5 = CALL_2ARGS( t_6, l_type, t_7 );
   CHECK_FUNC_RESULT( t_5 )
   l_type = t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* family := rec(
     ); */
 t_1 = NEW_PREC( 0 );
 l_family = t_1;
 
 /* SET_TYPE_COMOBJ( family, type ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 CALL_2ARGS( t_1, l_family, l_type );
 
 /* family!.NAME := name; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_NAME, a_name );
 }
 else {
  ASS_REC( l_family, R_NAME, a_name );
 }
 
 /* family!.REQ_FLAGS := req_filter; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_REQ__FLAGS, a_req__filter );
 }
 else {
  ASS_REC( l_family, R_REQ__FLAGS, a_req__filter );
 }
 
 /* family!.IMP_FLAGS := imp_filter; */
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_IMP__FLAGS, a_imp__filter );
 }
 else {
  ASS_REC( l_family, R_IMP__FLAGS, a_imp__filter );
 }
 
 /* family!.TYPES := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_TYPES, t_1 );
 }
 else {
  ASS_REC( l_family, R_TYPES, t_1 );
 }
 
 /* family!.TYPES_LIST_FAM := [ ,,,,,,,,,,,,,,,,,, false ]; */
 t_1 = NEW_PLIST( T_PLIST, 19 );
 SET_LEN_PLIST( t_1, 19 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 19, t_2 );
 CHANGED_BAG( t_1 );
 if ( TNUM_OBJ(l_family) == T_COMOBJ ) {
  AssPRec( l_family, R_TYPES__LIST__FAM, t_1 );
 }
 else {
  ASS_REC( l_family, R_TYPES__LIST__FAM, t_1 );
 }
 
 /* return family; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_family;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 14 */
static Obj  HdlrFunc14 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_FAMILY( typeOfFamilies, name, EMPTY_FLAGS, EMPTY_FLAGS ); */
 t_2 = GF_NEW__FAMILY;
 t_3 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_3, "EMPTY_FLAGS" )
 t_4 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_4, "EMPTY_FLAGS" )
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 15 */
static Obj  HdlrFunc15 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_FAMILY( typeOfFamilies, name, FLAGS_FILTER( req ), EMPTY_FLAGS ); */
 t_2 = GF_NEW__FAMILY;
 t_4 = GF_FLAGS__FILTER;
 t_3 = CALL_1ARGS( t_4, a_req );
 CHECK_FUNC_RESULT( t_3 )
 t_4 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_4, "EMPTY_FLAGS" )
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 16 */
static Obj  HdlrFunc16 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req,
 Obj  a_imp )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_FAMILY( typeOfFamilies, name, FLAGS_FILTER( req ), FLAGS_FILTER( imp ) ); */
 t_2 = GF_NEW__FAMILY;
 t_4 = GF_FLAGS__FILTER;
 t_3 = CALL_1ARGS( t_4, a_req );
 CHECK_FUNC_RESULT( t_3 )
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_imp );
 CHECK_FUNC_RESULT( t_4 )
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 17 */
static Obj  HdlrFunc17 (
 Obj  self,
 Obj  a_typeOfFamilies,
 Obj  a_name,
 Obj  a_req,
 Obj  a_imp,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_FAMILY( Subtype( typeOfFamilies, filter ), name, FLAGS_FILTER( req ), FLAGS_FILTER( imp ) ); */
 t_2 = GF_NEW__FAMILY;
 t_4 = GF_Subtype;
 t_3 = CALL_2ARGS( t_4, a_typeOfFamilies, a_filter );
 CHECK_FUNC_RESULT( t_3 )
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_req );
 CHECK_FUNC_RESULT( t_4 )
 t_6 = GF_FLAGS__FILTER;
 t_5 = CALL_1ARGS( t_6, a_imp );
 CHECK_FUNC_RESULT( t_5 )
 t_1 = CALL_4ARGS( t_2, t_3, a_name, t_4, t_5 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 18 */
static Obj  HdlrFunc18 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if LEN_LIST( arg ) = 1 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(1) ));
 if ( t_1 ) {
  
  /* return NewFamily2( TypeOfFamilies, arg[1] ); */
  t_2 = GF_NewFamily2;
  t_3 = GC_TypeOfFamilies;
  CHECK_BOUND( t_3, "TypeOfFamilies" )
  C_ELM_LIST_FPL( t_4, a_arg, 1 )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 2 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
  if ( t_1 ) {
   
   /* return NewFamily3( TypeOfFamilies, arg[1], arg[2] ); */
   t_2 = GF_NewFamily3;
   t_3 = GC_TypeOfFamilies;
   CHECK_BOUND( t_3, "TypeOfFamilies" )
   C_ELM_LIST_FPL( t_4, a_arg, 1 )
   C_ELM_LIST_FPL( t_5, a_arg, 2 )
   t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
   CHECK_FUNC_RESULT( t_1 )
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_1;
   
  }
  
  /* elif LEN_LIST( arg ) = 3 then */
  else {
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, a_arg );
   CHECK_FUNC_RESULT( t_2 )
   t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(3) ));
   if ( t_1 ) {
    
    /* return NewFamily4( TypeOfFamilies, arg[1], arg[2], arg[3] ); */
    t_2 = GF_NewFamily4;
    t_3 = GC_TypeOfFamilies;
    CHECK_BOUND( t_3, "TypeOfFamilies" )
    C_ELM_LIST_FPL( t_4, a_arg, 1 )
    C_ELM_LIST_FPL( t_5, a_arg, 2 )
    C_ELM_LIST_FPL( t_6, a_arg, 3 )
    t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
    CHECK_FUNC_RESULT( t_1 )
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_1;
    
   }
   
   /* elif LEN_LIST( arg ) = 4 then */
   else {
    t_3 = GF_LEN__LIST;
    t_2 = CALL_1ARGS( t_3, a_arg );
    CHECK_FUNC_RESULT( t_2 )
    t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(4) ));
    if ( t_1 ) {
     
     /* return NewFamily5( TypeOfFamilies, arg[1], arg[2], arg[3], arg[4] ); */
     t_2 = GF_NewFamily5;
     t_3 = GC_TypeOfFamilies;
     CHECK_BOUND( t_3, "TypeOfFamilies" )
     C_ELM_LIST_FPL( t_4, a_arg, 1 )
     C_ELM_LIST_FPL( t_5, a_arg, 2 )
     C_ELM_LIST_FPL( t_6, a_arg, 3 )
     C_ELM_LIST_FPL( t_7, a_arg, 4 )
     t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, t_7 );
     CHECK_FUNC_RESULT( t_1 )
     SWITCH_TO_OLD_FRAME(oldFrame);
     return t_1;
     
    }
    
    /* else */
    else {
     
     /* Error( "usage: NewFamily( <name>, [ <req> [, <imp> ]] )" ); */
     t_1 = GF_Error;
     C_NEW_STRING( t_2, 47, "usage: NewFamily( <name>, [ <req> [, <imp> ]] )" )
     CALL_1ARGS( t_1, t_2 );
     
    }
   }
  }
 }
 /* fi */
 
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
 Obj  a_family )
{
 Obj l_req__flags = 0;
 Obj l_imp__flags = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Print( "NewFamily( " ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 11, "NewFamily( " )
 CALL_1ARGS( t_1, t_2 );
 
 /* Print( "\"", family!.NAME, "\"" ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 1, "\"" )
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_3 = ElmPRec( a_family, R_NAME );
 }
 else {
  t_3 = ELM_REC( a_family, R_NAME );
 }
 C_NEW_STRING( t_4, 1, "\"" )
 CALL_3ARGS( t_1, t_2, t_3, t_4 );
 
 /* req_flags := family!.REQ_FLAGS; */
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_1 = ElmPRec( a_family, R_REQ__FLAGS );
 }
 else {
  t_1 = ELM_REC( a_family, R_REQ__FLAGS );
 }
 l_req__flags = t_1;
 
 /* Print( ", ", TRUES_FLAGS( req_flags ) ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 2, ", " )
 t_4 = GF_TRUES__FLAGS;
 t_3 = CALL_1ARGS( t_4, l_req__flags );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* imp_flags := family!.IMP_FLAGS; */
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_1 = ElmPRec( a_family, R_IMP__FLAGS );
 }
 else {
  t_1 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 l_imp__flags = t_1;
 
 /* if imp_flags <> [  ] then */
 t_2 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_2, 0 );
 t_1 = (Obj)(UInt)( ! EQ( l_imp__flags, t_2 ));
 if ( t_1 ) {
  
  /* Print( ", ", TRUES_FLAGS( imp_flags ) ); */
  t_1 = GF_Print;
  C_NEW_STRING( t_2, 2, ", " )
  t_4 = GF_TRUES__FLAGS;
  t_3 = CALL_1ARGS( t_4, l_imp__flags );
  CHECK_FUNC_RESULT( t_3 )
  CALL_2ARGS( t_1, t_2, t_3 );
  
 }
 /* fi */
 
 /* Print( " )" ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 2, " )" )
 CALL_1ARGS( t_1, t_2 );
 
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
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_flags,
 Obj  a_data )
{
 Obj l_hash = 0;
 Obj l_cache = 0;
 Obj l_cached = 0;
 Obj l_type = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* hash := HASH_FLAGS( flags ) mod 3001 + 1; */
 t_4 = GF_HASH__FLAGS;
 t_3 = CALL_1ARGS( t_4, a_flags );
 CHECK_FUNC_RESULT( t_3 )
 t_2 = MOD( t_3, INTOBJ_INT(3001) );
 C_SUM( t_1, t_2, INTOBJ_INT(1) )
 l_hash = t_1;
 
 /* cache := family!.TYPES; */
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_1 = ElmPRec( a_family, R_TYPES );
 }
 else {
  t_1 = ELM_REC( a_family, R_TYPES );
 }
 l_cache = t_1;
 
 /* if IsBound( cache[hash]) then */
 CHECK_INT_SMALL_POS( l_hash )
 t_2 = (ISB_LIST( l_cache, INT_INTOBJ(l_hash) ) ? True : False);
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* cached := cache[hash]; */
  C_ELM_LIST_FPL( t_1, l_cache, INT_INTOBJ(l_hash) )
  l_cached = t_1;
  
  /* if IS_EQUAL_FLAGS( flags, cached![2] ) then */
  t_3 = GF_IS__EQUAL__FLAGS;
  C_ELM_POSOBJ_NLE( t_4, l_cached, 2 );
  t_2 = CALL_2ARGS( t_3, a_flags, t_4 );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* if IS_IDENTICAL_OBJ( data, cached![POS_DATA_TYPE] ) and IS_IDENTICAL_OBJ( typeOfTypes, TYPE_OBJ( cached ) ) then */
   t_4 = GF_IS__IDENTICAL__OBJ;
   t_6 = GC_POS__DATA__TYPE;
   CHECK_BOUND( t_6, "POS_DATA_TYPE" )
   CHECK_INT_SMALL_POS( t_6 )
   C_ELM_POSOBJ_NLE( t_5, l_cached, INT_INTOBJ(t_6) );
   t_3 = CALL_2ARGS( t_4, a_data, t_5 );
   CHECK_FUNC_RESULT( t_3 )
   CHECK_BOOL( t_3 )
   t_2 = (Obj)(UInt)(t_3 != False);
   t_1 = t_2;
   if ( t_1 ) {
    t_5 = GF_IS__IDENTICAL__OBJ;
    t_7 = GF_TYPE__OBJ;
    t_6 = CALL_1ARGS( t_7, l_cached );
    CHECK_FUNC_RESULT( t_6 )
    t_4 = CALL_2ARGS( t_5, a_typeOfTypes, t_6 );
    CHECK_FUNC_RESULT( t_4 )
    CHECK_BOOL( t_4 )
    t_3 = (Obj)(UInt)(t_4 != False);
    t_1 = t_3;
   }
   if ( t_1 ) {
    
    /* NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1; */
    t_2 = GC_NEW__TYPE__CACHE__HIT;
    CHECK_BOUND( t_2, "NEW_TYPE_CACHE_HIT" )
    C_SUM( t_1, t_2, INTOBJ_INT(1) )
    AssGVar( G_NEW__TYPE__CACHE__HIT, t_1 );
    
    /* return cached; */
    SWITCH_TO_OLD_FRAME(oldFrame);
    return l_cached;
    
   }
   
   /* else */
   else {
    
    /* flags := cached![2]; */
    C_ELM_POSOBJ_NLE( t_1, l_cached, 2 );
    a_flags = t_1;
    
   }
   /* fi */
   
  }
  /* fi */
  
  /* NEW_TYPE_CACHE_MISS := NEW_TYPE_CACHE_MISS + 1; */
  t_2 = GC_NEW__TYPE__CACHE__MISS;
  CHECK_BOUND( t_2, "NEW_TYPE_CACHE_MISS" )
  C_SUM( t_1, t_2, INTOBJ_INT(1) )
  AssGVar( G_NEW__TYPE__CACHE__MISS, t_1 );
  
 }
 /* fi */
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_SUM( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* if TNUM_OBJ( NEW_TYPE_NEXT_ID )[1] <> 0 then */
 t_4 = GF_TNUM__OBJ;
 t_5 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_5, "NEW_TYPE_NEXT_ID" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 C_ELM_LIST_FPL( t_2, t_3, 1 )
 t_1 = (Obj)(UInt)( ! EQ( t_2, INTOBJ_INT(0) ));
 if ( t_1 ) {
  
  /* Error( "too many types" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 14, "too many types" )
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* type := [ family, flags ]; */
 t_1 = NEW_PLIST( T_PLIST, 2 );
 SET_LEN_PLIST( t_1, 2 );
 SET_ELM_PLIST( t_1, 1, a_family );
 CHANGED_BAG( t_1 );
 SET_ELM_PLIST( t_1, 2, a_flags );
 CHANGED_BAG( t_1 );
 l_type = t_1;
 
 /* type[POS_DATA_TYPE] := data; */
 t_1 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_1, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_1 )
 C_ASS_LIST_FPL( l_type, INT_INTOBJ(t_1), a_data )
 
 /* type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID; */
 t_1 = GC_POS__NUMB__TYPE;
 CHECK_BOUND( t_1, "POS_NUMB_TYPE" )
 CHECK_INT_SMALL_POS( t_1 )
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_ASS_LIST_FPL( l_type, INT_INTOBJ(t_1), t_2 )
 
 /* SET_TYPE_POSOBJ( type, typeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 CALL_2ARGS( t_1, l_type, a_typeOfTypes );
 
 /* cache[hash] := type; */
 C_ASS_LIST_FPL( l_cache, INT_INTOBJ(l_hash), l_type )
 
 /* return type; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 21 */
static Obj  HdlrFunc21 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_TYPE( typeOfTypes, family, family!.IMP_FLAGS, false ); */
 t_2 = GF_NEW__TYPE;
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_3 = ElmPRec( a_family, R_IMP__FLAGS );
 }
 else {
  t_3 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 t_4 = False;
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 22 */
static Obj  HdlrFunc22 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), false ); */
 t_2 = GF_NEW__TYPE;
 t_4 = GF_WITH__IMPS__FLAGS;
 t_6 = GF_AND__FLAGS;
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_7 = ElmPRec( a_family, R_IMP__FLAGS );
 }
 else {
  t_7 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 t_4 = False;
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, t_4 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 23 */
static Obj  HdlrFunc23 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_filter,
 Obj  a_data )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), data ); */
 t_2 = GF_NEW__TYPE;
 t_4 = GF_WITH__IMPS__FLAGS;
 t_6 = GF_AND__FLAGS;
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_7 = ElmPRec( a_family, R_IMP__FLAGS );
 }
 else {
  t_7 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, a_data );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 24 */
static Obj  HdlrFunc24 (
 Obj  self,
 Obj  a_typeOfTypes,
 Obj  a_family,
 Obj  a_filter,
 Obj  a_data,
 Obj  a_stuff )
{
 Obj l_type = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Obj t_8 = 0;
 Obj t_9 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* type := NEW_TYPE( typeOfTypes, family, WITH_IMPS_FLAGS( AND_FLAGS( family!.IMP_FLAGS, FLAGS_FILTER( filter ) ) ), data ); */
 t_2 = GF_NEW__TYPE;
 t_4 = GF_WITH__IMPS__FLAGS;
 t_6 = GF_AND__FLAGS;
 if ( TNUM_OBJ(a_family) == T_COMOBJ ) {
  t_7 = ElmPRec( a_family, R_IMP__FLAGS );
 }
 else {
  t_7 = ELM_REC( a_family, R_IMP__FLAGS );
 }
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, a_data );
 CHECK_FUNC_RESULT( t_1 )
 l_type = t_1;
 
 /* type![POS_FIRST_FREE_TYPE] := stuff; */
 t_1 = GC_POS__FIRST__FREE__TYPE;
 CHECK_BOUND( t_1, "POS_FIRST_FREE_TYPE" )
 CHECK_INT_SMALL_POS( t_1 )
 C_ASS_POSOBJ( l_type, INT_INTOBJ(t_1), a_stuff )
 
 /* return type; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 25 */
static Obj  HdlrFunc25 (
 Obj  self,
 Obj  a_arg )
{
 Obj l_type = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Obj t_7 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if not IsFamily( arg[1] ) then */
 t_4 = GF_IsFamily;
 C_ELM_LIST_FPL( t_5, a_arg, 1 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<family> must be a family" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 25, "<family> must be a family" )
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 1 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(1) ));
 if ( t_1 ) {
  
  /* type := NewType2( TypeOfTypes, arg[1] ); */
  t_2 = GF_NewType2;
  t_3 = GC_TypeOfTypes;
  CHECK_BOUND( t_3, "TypeOfTypes" )
  C_ELM_LIST_FPL( t_4, a_arg, 1 )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  l_type = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 2 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
  if ( t_1 ) {
   
   /* type := NewType3( TypeOfTypes, arg[1], arg[2] ); */
   t_2 = GF_NewType3;
   t_3 = GC_TypeOfTypes;
   CHECK_BOUND( t_3, "TypeOfTypes" )
   C_ELM_LIST_FPL( t_4, a_arg, 1 )
   C_ELM_LIST_FPL( t_5, a_arg, 2 )
   t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
   CHECK_FUNC_RESULT( t_1 )
   l_type = t_1;
   
  }
  
  /* elif LEN_LIST( arg ) = 3 then */
  else {
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, a_arg );
   CHECK_FUNC_RESULT( t_2 )
   t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(3) ));
   if ( t_1 ) {
    
    /* type := NewType4( TypeOfTypes, arg[1], arg[2], arg[3] ); */
    t_2 = GF_NewType4;
    t_3 = GC_TypeOfTypes;
    CHECK_BOUND( t_3, "TypeOfTypes" )
    C_ELM_LIST_FPL( t_4, a_arg, 1 )
    C_ELM_LIST_FPL( t_5, a_arg, 2 )
    C_ELM_LIST_FPL( t_6, a_arg, 3 )
    t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
    CHECK_FUNC_RESULT( t_1 )
    l_type = t_1;
    
   }
   
   /* elif LEN_LIST( arg ) = 4 then */
   else {
    t_3 = GF_LEN__LIST;
    t_2 = CALL_1ARGS( t_3, a_arg );
    CHECK_FUNC_RESULT( t_2 )
    t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(4) ));
    if ( t_1 ) {
     
     /* type := NewType5( TypeOfTypes, arg[1], arg[2], arg[3], arg[4] ); */
     t_2 = GF_NewType5;
     t_3 = GC_TypeOfTypes;
     CHECK_BOUND( t_3, "TypeOfTypes" )
     C_ELM_LIST_FPL( t_4, a_arg, 1 )
     C_ELM_LIST_FPL( t_5, a_arg, 2 )
     C_ELM_LIST_FPL( t_6, a_arg, 3 )
     C_ELM_LIST_FPL( t_7, a_arg, 4 )
     t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, t_7 );
     CHECK_FUNC_RESULT( t_1 )
     l_type = t_1;
     
    }
    
    /* else */
    else {
     
     /* Error( "usage: NewType( <family> [, <filter> [, <data> ]] )" ); */
     t_1 = GF_Error;
     C_NEW_STRING( t_2, 51, "usage: NewType( <family> [, <filter> [, <data> ]] )" )
     CALL_1ARGS( t_1, t_2 );
     
    }
   }
  }
 }
 /* fi */
 
 /* return type; */
 CHECK_BOUND( l_type, "type" )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 26 */
static Obj  HdlrFunc26 (
 Obj  self,
 Obj  a_type )
{
 Obj l_family = 0;
 Obj l_flags = 0;
 Obj l_data = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* family := type![1]; */
 C_ELM_POSOBJ_NLE( t_1, a_type, 1 );
 l_family = t_1;
 
 /* flags := type![2]; */
 C_ELM_POSOBJ_NLE( t_1, a_type, 2 );
 l_flags = t_1;
 
 /* data := type![POS_DATA_TYPE]; */
 t_2 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_2, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_2 )
 C_ELM_POSOBJ_NLE( t_1, a_type, INT_INTOBJ(t_2) );
 l_data = t_1;
 
 /* Print( "NewType( ", family ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 9, "NewType( " )
 CALL_2ARGS( t_1, t_2, l_family );
 
 /* if flags <> [  ] or data <> false then */
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 t_2 = (Obj)(UInt)( ! EQ( l_flags, t_3 ));
 t_1 = t_2;
 if ( ! t_1 ) {
  t_4 = False;
  t_3 = (Obj)(UInt)( ! EQ( l_data, t_4 ));
  t_1 = t_3;
 }
 if ( t_1 ) {
  
  /* Print( ", " ); */
  t_1 = GF_Print;
  C_NEW_STRING( t_2, 2, ", " )
  CALL_1ARGS( t_1, t_2 );
  
  /* Print( TRUES_FLAGS( flags ) ); */
  t_1 = GF_Print;
  t_3 = GF_TRUES__FLAGS;
  t_2 = CALL_1ARGS( t_3, l_flags );
  CHECK_FUNC_RESULT( t_2 )
  CALL_1ARGS( t_1, t_2 );
  
  /* if data <> false then */
  t_2 = False;
  t_1 = (Obj)(UInt)( ! EQ( l_data, t_2 ));
  if ( t_1 ) {
   
   /* Print( ", " ); */
   t_1 = GF_Print;
   C_NEW_STRING( t_2, 2, ", " )
   CALL_1ARGS( t_1, t_2 );
   
   /* Print( data ); */
   t_1 = GF_Print;
   CALL_1ARGS( t_1, l_data );
   
  }
  /* fi */
  
 }
 /* fi */
 
 /* Print( " )" ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 2, " )" )
 CALL_1ARGS( t_1, t_2 );
 
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
 Obj  a_type,
 Obj  a_filter )
{
 Obj l_new = 0;
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
 
 /* new := NEW_TYPE( TypeOfTypes, type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), type![POS_DATA_TYPE] ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_WITH__IMPS__FLAGS;
 t_8 = GF_AND__FLAGS;
 C_ELM_POSOBJ_NLE( t_9, a_type, 2 );
 t_11 = GF_FLAGS__FILTER;
 t_10 = CALL_1ARGS( t_11, a_filter );
 CHECK_FUNC_RESULT( t_10 )
 t_7 = CALL_2ARGS( t_8, t_9, t_10 );
 CHECK_FUNC_RESULT( t_7 )
 t_5 = CALL_1ARGS( t_6, t_7 );
 CHECK_FUNC_RESULT( t_5 )
 t_7 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_7, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_7 )
 C_ELM_POSOBJ_NLE( t_6, a_type, INT_INTOBJ(t_7) );
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 CHECK_FUNC_RESULT( t_1 )
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 CHECK_BOUND( t_2, "POS_FIRST_FREE_TYPE" )
 CHECK_INT_SMALL( t_2 )
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_INT_SMALL( t_3 )
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  CHECK_INT_SMALL_POS( l_i )
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(UInt)(t_5 != False);
  if ( t_4 ) {
   
   /* new![i] := type![i]; */
   C_ELM_POSOBJ_NLE( t_4, a_type, INT_INTOBJ(l_i) );
   C_ASS_POSOBJ( l_new, INT_INTOBJ(l_i), t_4 )
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return new; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_new;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 28 */
static Obj  HdlrFunc28 (
 Obj  self,
 Obj  a_type,
 Obj  a_filter,
 Obj  a_data )
{
 Obj l_new = 0;
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
 
 /* new := NEW_TYPE( TypeOfTypes, type![1], WITH_IMPS_FLAGS( AND_FLAGS( type![2], FLAGS_FILTER( filter ) ) ), data ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_WITH__IMPS__FLAGS;
 t_8 = GF_AND__FLAGS;
 C_ELM_POSOBJ_NLE( t_9, a_type, 2 );
 t_11 = GF_FLAGS__FILTER;
 t_10 = CALL_1ARGS( t_11, a_filter );
 CHECK_FUNC_RESULT( t_10 )
 t_7 = CALL_2ARGS( t_8, t_9, t_10 );
 CHECK_FUNC_RESULT( t_7 )
 t_5 = CALL_1ARGS( t_6, t_7 );
 CHECK_FUNC_RESULT( t_5 )
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, a_data );
 CHECK_FUNC_RESULT( t_1 )
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 CHECK_BOUND( t_2, "POS_FIRST_FREE_TYPE" )
 CHECK_INT_SMALL( t_2 )
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_INT_SMALL( t_3 )
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  CHECK_INT_SMALL_POS( l_i )
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(UInt)(t_5 != False);
  if ( t_4 ) {
   
   /* new![i] := type![i]; */
   C_ELM_POSOBJ_NLE( t_4, a_type, INT_INTOBJ(l_i) );
   C_ASS_POSOBJ( l_new, INT_INTOBJ(l_i), t_4 )
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return new; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_new;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 29 */
static Obj  HdlrFunc29 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if not IsType( arg[1] ) then */
 t_4 = GF_IsType;
 C_ELM_LIST_FPL( t_5, a_arg, 1 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" )
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 2 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* return Subtype2( arg[1], arg[2] ); */
  t_2 = GF_Subtype2;
  C_ELM_LIST_FPL( t_3, a_arg, 1 )
  C_ELM_LIST_FPL( t_4, a_arg, 2 )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* return Subtype3( arg[1], arg[2], arg[3] ); */
  t_2 = GF_Subtype3;
  C_ELM_LIST_FPL( t_3, a_arg, 1 )
  C_ELM_LIST_FPL( t_4, a_arg, 2 )
  C_ELM_LIST_FPL( t_5, a_arg, 3 )
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
  CHECK_FUNC_RESULT( t_1 )
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 /* fi */
 
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
 Obj  a_type,
 Obj  a_filter )
{
 Obj l_new = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* new := NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), type![POS_DATA_TYPE] ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_SUB__FLAGS;
 C_ELM_POSOBJ_NLE( t_7, a_type, 2 );
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_7 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_7, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_7 )
 C_ELM_POSOBJ_NLE( t_6, a_type, INT_INTOBJ(t_7) );
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 CHECK_FUNC_RESULT( t_1 )
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 CHECK_BOUND( t_2, "POS_FIRST_FREE_TYPE" )
 CHECK_INT_SMALL( t_2 )
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_INT_SMALL( t_3 )
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  CHECK_INT_SMALL_POS( l_i )
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(UInt)(t_5 != False);
  if ( t_4 ) {
   
   /* new![i] := type![i]; */
   C_ELM_POSOBJ_NLE( t_4, a_type, INT_INTOBJ(l_i) );
   C_ASS_POSOBJ( l_new, INT_INTOBJ(l_i), t_4 )
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return new; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_new;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 31 */
static Obj  HdlrFunc31 (
 Obj  self,
 Obj  a_type,
 Obj  a_filter,
 Obj  a_data )
{
 Obj l_new = 0;
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* new := NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), data ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_SUB__FLAGS;
 C_ELM_POSOBJ_NLE( t_7, a_type, 2 );
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 CHECK_FUNC_RESULT( t_8 )
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 CHECK_FUNC_RESULT( t_5 )
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, a_data );
 CHECK_FUNC_RESULT( t_1 )
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 CHECK_BOUND( t_2, "POS_FIRST_FREE_TYPE" )
 CHECK_INT_SMALL( t_2 )
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_INT_SMALL( t_3 )
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  CHECK_INT_SMALL_POS( l_i )
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(UInt)(t_5 != False);
  if ( t_4 ) {
   
   /* new![i] := type![i]; */
   C_ELM_POSOBJ_NLE( t_4, a_type, INT_INTOBJ(l_i) );
   C_ASS_POSOBJ( l_new, INT_INTOBJ(l_i), t_4 )
   
  }
  /* fi */
  
 }
 /* od */
 
 /* return new; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_new;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 32 */
static Obj  HdlrFunc32 (
 Obj  self,
 Obj  a_arg )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if not IsType( arg[1] ) then */
 t_4 = GF_IsType;
 C_ELM_LIST_FPL( t_5, a_arg, 1 )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" )
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if LEN_LIST( arg ) = 2 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 CHECK_FUNC_RESULT( t_2 )
 t_1 = (Obj)(UInt)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* return SupType2( arg[1], arg[2] ); */
  t_2 = GF_SupType2;
  C_ELM_LIST_FPL( t_3, a_arg, 1 )
  C_ELM_LIST_FPL( t_4, a_arg, 2 )
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  CHECK_FUNC_RESULT( t_1 )
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* return SupType3( arg[1], arg[2], arg[3] ); */
  t_2 = GF_SupType3;
  C_ELM_LIST_FPL( t_3, a_arg, 1 )
  C_ELM_LIST_FPL( t_4, a_arg, 2 )
  C_ELM_LIST_FPL( t_5, a_arg, 3 )
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
  CHECK_FUNC_RESULT( t_1 )
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 /* fi */
 
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
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return K![1]; */
 C_ELM_POSOBJ_NLE( t_1, a_K, 1 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 34 */
static Obj  HdlrFunc34 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return K![2]; */
 C_ELM_POSOBJ_NLE( t_1, a_K, 2 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 35 */
static Obj  HdlrFunc35 (
 Obj  self,
 Obj  a_K )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return K![POS_DATA_TYPE]; */
 t_2 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_2, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_2 )
 C_ELM_POSOBJ_NLE( t_1, a_K, INT_INTOBJ(t_2) );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 36 */
static Obj  HdlrFunc36 (
 Obj  self,
 Obj  a_K,
 Obj  a_data )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* K![POS_DATA_TYPE] := data; */
 t_1 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_1, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_1 )
 C_ASS_POSOBJ( a_K, INT_INTOBJ(t_1), a_data )
 
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
 Obj  a_K )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return K![POS_DATA_TYPE]; */
 t_2 = GC_POS__DATA__TYPE;
 CHECK_BOUND( t_2, "POS_DATA_TYPE" )
 CHECK_INT_SMALL_POS( t_2 )
 C_ELM_POSOBJ_NLE( t_1, a_K, INT_INTOBJ(t_2) );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 38 */
static Obj  HdlrFunc38 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return FlagsType( TypeObj( obj ) ); */
 t_2 = GF_FlagsType;
 t_4 = GF_TypeObj;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 39 */
static Obj  HdlrFunc39 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return DataType( TypeObj( obj ) ); */
 t_2 = GF_DataType;
 t_4 = GF_TypeObj;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 40 */
static Obj  HdlrFunc40 (
 Obj  self,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* return SharedType( TypeObj( obj ) ); */
 t_2 = GF_SharedType;
 t_4 = GF_TypeObj;
 t_3 = CALL_1ARGS( t_4, a_obj );
 CHECK_FUNC_RESULT( t_3 )
 t_1 = CALL_1ARGS( t_2, t_3 );
 CHECK_FUNC_RESULT( t_1 )
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 41 */
static Obj  HdlrFunc41 (
 Obj  self,
 Obj  a_type,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" )
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if IS_LIST( obj ) then */
 t_3 = GF_IS__LIST;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_REC( obj ) then */
 else {
  t_3 = GF_IS__REC;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, a_type );
   
  }
 }
 /* fi */
 
 /* RunImmediateMethods( obj, type![2] ); */
 t_1 = GF_RunImmediateMethods;
 C_ELM_POSOBJ_NLE( t_2, a_type, 2 );
 CALL_2ARGS( t_1, a_obj, t_2 );
 
 /* return obj; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_obj;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 42 */
static Obj  HdlrFunc42 (
 Obj  self,
 Obj  a_type,
 Obj  a_obj )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if not IsType( type ) then */
 t_4 = GF_IsType;
 t_3 = CALL_1ARGS( t_4, a_type );
 CHECK_FUNC_RESULT( t_3 )
 CHECK_BOOL( t_3 )
 t_2 = (Obj)(UInt)(t_3 != False);
 t_1 = (Obj)(UInt)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* Error( "<type> must be a type" ); */
  t_1 = GF_Error;
  C_NEW_STRING( t_2, 21, "<type> must be a type" )
  CALL_1ARGS( t_1, t_2 );
  
 }
 /* fi */
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, a_type );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, type ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    CALL_2ARGS( t_1, a_obj, a_type );
    
   }
  }
 }
 /* fi */
 
 /* RunImmediateMethods( obj, type![2] ); */
 t_1 = GF_RunImmediateMethods;
 C_ELM_POSOBJ_NLE( t_2, a_type, 2 );
 CALL_2ARGS( t_1, a_obj, t_2 );
 
 /* return obj; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_obj;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 43 */
static Obj  HdlrFunc43 (
 Obj  self,
 Obj  a_obj,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, Subtype2( TYPE_OBJ( obj ), filter ) ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  t_3 = GF_Subtype2;
  t_5 = GF_TYPE__OBJ;
  t_4 = CALL_1ARGS( t_5, a_obj );
  CHECK_FUNC_RESULT( t_4 )
  t_2 = CALL_2ARGS( t_3, t_4, a_filter );
  CHECK_FUNC_RESULT( t_2 )
  CALL_2ARGS( t_1, a_obj, t_2 );
  
  /* RunImmediateMethods( obj, FLAGS_FILTER( filter ) ); */
  t_1 = GF_RunImmediateMethods;
  t_3 = GF_FLAGS__FILTER;
  t_2 = CALL_1ARGS( t_3, a_filter );
  CHECK_FUNC_RESULT( t_2 )
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, Subtype2( TYPE_OBJ( obj ), filter ) ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   t_3 = GF_Subtype2;
   t_5 = GF_TYPE__OBJ;
   t_4 = CALL_1ARGS( t_5, a_obj );
   CHECK_FUNC_RESULT( t_4 )
   t_2 = CALL_2ARGS( t_3, t_4, a_filter );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, a_obj, t_2 );
   
   /* RunImmediateMethods( obj, FLAGS_FILTER( filter ) ); */
   t_1 = GF_RunImmediateMethods;
   t_3 = GF_FLAGS__FILTER;
   t_2 = CALL_1ARGS( t_3, a_filter );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, Subtype2( TYPE_OBJ( obj ), filter ) ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    t_3 = GF_Subtype2;
    t_5 = GF_TYPE__OBJ;
    t_4 = CALL_1ARGS( t_5, a_obj );
    CHECK_FUNC_RESULT( t_4 )
    t_2 = CALL_2ARGS( t_3, t_4, a_filter );
    CHECK_FUNC_RESULT( t_2 )
    CALL_2ARGS( t_1, a_obj, t_2 );
    
    /* RunImmediateMethods( obj, FLAGS_FILTER( filter ) ); */
    t_1 = GF_RunImmediateMethods;
    t_3 = GF_FLAGS__FILTER;
    t_2 = CALL_1ARGS( t_3, a_filter );
    CHECK_FUNC_RESULT( t_2 )
    CALL_2ARGS( t_1, a_obj, t_2 );
    
   }
   
   /* elif IS_PLIST_REP( obj ) then */
   else {
    t_3 = GF_IS__PLIST__REP;
    t_2 = CALL_1ARGS( t_3, a_obj );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* SET_FILTER_LIST( obj, filter ); */
     t_1 = GF_SET__FILTER__LIST;
     CALL_2ARGS( t_1, a_obj, a_filter );
     
    }
    
    /* elif IS_STRING_REP( obj ) then */
    else {
     t_3 = GF_IS__STRING__REP;
     t_2 = CALL_1ARGS( t_3, a_obj );
     CHECK_FUNC_RESULT( t_2 )
     CHECK_BOOL( t_2 )
     t_1 = (Obj)(UInt)(t_2 != False);
     if ( t_1 ) {
      
      /* SET_FILTER_LIST( obj, filter ); */
      t_1 = GF_SET__FILTER__LIST;
      CALL_2ARGS( t_1, a_obj, a_filter );
      
     }
     
     /* elif IS_BLIST( obj ) then */
     else {
      t_3 = GF_IS__BLIST;
      t_2 = CALL_1ARGS( t_3, a_obj );
      CHECK_FUNC_RESULT( t_2 )
      CHECK_BOOL( t_2 )
      t_1 = (Obj)(UInt)(t_2 != False);
      if ( t_1 ) {
       
       /* SET_FILTER_LIST( obj, filter ); */
       t_1 = GF_SET__FILTER__LIST;
       CALL_2ARGS( t_1, a_obj, a_filter );
       
      }
      
      /* elif IS_RANGE( obj ) then */
      else {
       t_3 = GF_IS__RANGE;
       t_2 = CALL_1ARGS( t_3, a_obj );
       CHECK_FUNC_RESULT( t_2 )
       CHECK_BOOL( t_2 )
       t_1 = (Obj)(UInt)(t_2 != False);
       if ( t_1 ) {
        
        /* SET_FILTER_LIST( obj, filter ); */
        t_1 = GF_SET__FILTER__LIST;
        CALL_2ARGS( t_1, a_obj, a_filter );
        
       }
       
       /* else */
       else {
        
        /* Error( "cannot set filter for internal object" ); */
        t_1 = GF_Error;
        C_NEW_STRING( t_2, 37, "cannot set filter for internal object" )
        CALL_1ARGS( t_1, t_2 );
        
       }
      }
     }
    }
   }
  }
 }
 /* fi */
 
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
 Obj  a_obj,
 Obj  a_filter )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if IS_POSOBJ( obj ) then */
 t_3 = GF_IS__POSOBJ;
 t_2 = CALL_1ARGS( t_3, a_obj );
 CHECK_FUNC_RESULT( t_2 )
 CHECK_BOOL( t_2 )
 t_1 = (Obj)(UInt)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  t_3 = GF_SupType2;
  t_5 = GF_TYPE__OBJ;
  t_4 = CALL_1ARGS( t_5, a_obj );
  CHECK_FUNC_RESULT( t_4 )
  t_2 = CALL_2ARGS( t_3, t_4, a_filter );
  CHECK_FUNC_RESULT( t_2 )
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  CHECK_FUNC_RESULT( t_2 )
  CHECK_BOOL( t_2 )
  t_1 = (Obj)(UInt)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   t_3 = GF_SupType2;
   t_5 = GF_TYPE__OBJ;
   t_4 = CALL_1ARGS( t_5, a_obj );
   CHECK_FUNC_RESULT( t_4 )
   t_2 = CALL_2ARGS( t_3, t_4, a_filter );
   CHECK_FUNC_RESULT( t_2 )
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    t_3 = GF_SupType2;
    t_5 = GF_TYPE__OBJ;
    t_4 = CALL_1ARGS( t_5, a_obj );
    CHECK_FUNC_RESULT( t_4 )
    t_2 = CALL_2ARGS( t_3, t_4, a_filter );
    CHECK_FUNC_RESULT( t_2 )
    CALL_2ARGS( t_1, a_obj, t_2 );
    
   }
   
   /* elif IS_PLIST_REP( obj ) then */
   else {
    t_3 = GF_IS__PLIST__REP;
    t_2 = CALL_1ARGS( t_3, a_obj );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* RESET_FILTER_LIST( obj, filter ); */
     t_1 = GF_RESET__FILTER__LIST;
     CALL_2ARGS( t_1, a_obj, a_filter );
     
    }
    
    /* elif IS_STRING_REP( obj ) then */
    else {
     t_3 = GF_IS__STRING__REP;
     t_2 = CALL_1ARGS( t_3, a_obj );
     CHECK_FUNC_RESULT( t_2 )
     CHECK_BOOL( t_2 )
     t_1 = (Obj)(UInt)(t_2 != False);
     if ( t_1 ) {
      
      /* RESET_FILTER_LIST( obj, filter ); */
      t_1 = GF_RESET__FILTER__LIST;
      CALL_2ARGS( t_1, a_obj, a_filter );
      
     }
     
     /* elif IS_BLIST( obj ) then */
     else {
      t_3 = GF_IS__BLIST;
      t_2 = CALL_1ARGS( t_3, a_obj );
      CHECK_FUNC_RESULT( t_2 )
      CHECK_BOOL( t_2 )
      t_1 = (Obj)(UInt)(t_2 != False);
      if ( t_1 ) {
       
       /* RESET_FILTER_LIST( obj, filter ); */
       t_1 = GF_RESET__FILTER__LIST;
       CALL_2ARGS( t_1, a_obj, a_filter );
       
      }
      
      /* elif IS_RANGE( obj ) then */
      else {
       t_3 = GF_IS__RANGE;
       t_2 = CALL_1ARGS( t_3, a_obj );
       CHECK_FUNC_RESULT( t_2 )
       CHECK_BOOL( t_2 )
       t_1 = (Obj)(UInt)(t_2 != False);
       if ( t_1 ) {
        
        /* RESET_FILTER_LIST( obj, filter ); */
        t_1 = GF_RESET__FILTER__LIST;
        CALL_2ARGS( t_1, a_obj, a_filter );
        
       }
       
       /* else */
       else {
        
        /* Error( "cannot reset filter for internal object" ); */
        t_1 = GF_Error;
        C_NEW_STRING( t_2, 39, "cannot reset filter for internal object" )
        CALL_1ARGS( t_1, t_2 );
        
       }
      }
     }
    }
   }
  }
 }
 /* fi */
 
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
 Obj  a_obj,
 Obj  a_filter,
 Obj  a_val )
{
 Obj t_1 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if val then */
 CHECK_BOOL( a_val )
 t_1 = (Obj)(UInt)(a_val != False);
 if ( t_1 ) {
  
  /* SetFilterObj( obj, filter ); */
  t_1 = GF_SetFilterObj;
  CALL_2ARGS( t_1, a_obj, a_filter );
  
 }
 
 /* else */
 else {
  
  /* ResetFilterObj( obj, filter ); */
  t_1 = GF_ResetFilterObj;
  CALL_2ARGS( t_1, a_obj, a_filter );
  
 }
 /* fi */
 
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
 Obj  a_to,
 Obj  a_from,
 Obj  a_func )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* ADD_LIST( list, [ FLAGS_FILTER( to ), FLAGS_FILTER( from ), func ] ); */
 t_1 = GF_ADD__LIST;
 t_2 = OBJ_LVAR_0UP( 1 );
 CHECK_BOUND( t_2, "list" )
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_to );
 CHECK_FUNC_RESULT( t_4 )
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_from );
 CHECK_FUNC_RESULT( t_4 )
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 SET_ELM_PLIST( t_3, 3, a_func );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
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
 Obj  a_list )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,1,0,oldFrame);
 ASS_LVAR( 1, a_list );
 
 /* return function ... end; */
 t_1 = NewFunction( NameFunc[47], NargFunc[47], NamsFunc[47], HdlrFunc47 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 49 */
static Obj  HdlrFunc49 (
 Obj  self,
 Obj  a_sup,
 Obj  a_sub )
{
 Obj l_done = 0;
 Obj l_fsup = 0;
 Obj l_fsub = 0;
 Obj l_i = 0;
 Obj l_tmp = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Obj t_5 = 0;
 Obj t_6 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* done := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 l_done = t_1;
 
 /* fsup := TypeObj( sup )![2]; */
 t_3 = GF_TypeObj;
 t_2 = CALL_1ARGS( t_3, a_sup );
 CHECK_FUNC_RESULT( t_2 )
 C_ELM_POSOBJ_NLE( t_1, t_2, 2 );
 l_fsup = t_1;
 
 /* fsub := TypeObj( sub )![2]; */
 t_3 = GF_TypeObj;
 t_2 = CALL_1ARGS( t_3, a_sub );
 CHECK_FUNC_RESULT( t_2 )
 C_ELM_POSOBJ_NLE( t_1, t_2, 2 );
 l_fsub = t_1;
 
 /* i := 1; */
 l_i = INTOBJ_INT(1);
 
 /* while i <= LEN_LIST( list ) od */
 while ( 1 ) {
  t_3 = GF_LEN__LIST;
  t_4 = OBJ_LVAR_0UP( 1 );
  CHECK_BOUND( t_4, "list" )
  t_2 = CALL_1ARGS( t_3, t_4 );
  CHECK_FUNC_RESULT( t_2 )
  t_1 = (Obj)(UInt)(! LT( t_2, l_i ));
  if ( ! t_1 ) break;
  
  /* if not i in done then */
  t_2 = (Obj)(UInt)(IN( l_i, l_done ));
  t_1 = (Obj)(UInt)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* if IS_SUBSET_FLAGS( fsup, list[i][1] ) then */
   t_3 = GF_IS__SUBSET__FLAGS;
   t_6 = OBJ_LVAR_0UP( 1 );
   CHECK_BOUND( t_6, "list" )
   CHECK_INT_SMALL_POS( l_i )
   C_ELM_LIST_FPL( t_5, t_6, INT_INTOBJ(l_i) )
   C_ELM_LIST_FPL( t_4, t_5, 1 )
   t_2 = CALL_2ARGS( t_3, l_fsup, t_4 );
   CHECK_FUNC_RESULT( t_2 )
   CHECK_BOOL( t_2 )
   t_1 = (Obj)(UInt)(t_2 != False);
   if ( t_1 ) {
    
    /* if IS_SUBSET_FLAGS( fsub, list[i][2] ) then */
    t_3 = GF_IS__SUBSET__FLAGS;
    t_6 = OBJ_LVAR_0UP( 1 );
    CHECK_BOUND( t_6, "list" )
    C_ELM_LIST_FPL( t_5, t_6, INT_INTOBJ(l_i) )
    C_ELM_LIST_FPL( t_4, t_5, 2 )
    t_2 = CALL_2ARGS( t_3, l_fsub, t_4 );
    CHECK_FUNC_RESULT( t_2 )
    CHECK_BOOL( t_2 )
    t_1 = (Obj)(UInt)(t_2 != False);
    if ( t_1 ) {
     
     /* ADD_SET( done, i ); */
     t_1 = GF_ADD__SET;
     CALL_2ARGS( t_1, l_done, l_i );
     
     /* list[i][3]( sup, sub ); */
     t_3 = OBJ_LVAR_0UP( 1 );
     CHECK_BOUND( t_3, "list" )
     C_ELM_LIST_FPL( t_2, t_3, INT_INTOBJ(l_i) )
     C_ELM_LIST_FPL( t_1, t_2, 3 )
     CHECK_FUNC( t_1 )
     CALL_2ARGS( t_1, a_sup, a_sub );
     
     /* tmp := TypeObj( sub )![2]; */
     t_3 = GF_TypeObj;
     t_2 = CALL_1ARGS( t_3, a_sub );
     CHECK_FUNC_RESULT( t_2 )
     C_ELM_POSOBJ_NLE( t_1, t_2, 2 );
     l_tmp = t_1;
     
     /* if tmp = fsub then */
     t_1 = (Obj)(UInt)(EQ( l_tmp, l_fsub ));
     if ( t_1 ) {
      
      /* i := i + 1; */
      C_SUM_INTOBJS( t_1, l_i, INTOBJ_INT(1) )
      l_i = t_1;
      
     }
     
     /* else */
     else {
      
      /* i := 1; */
      l_i = INTOBJ_INT(1);
      
     }
     /* fi */
     
    }
    
    /* else */
    else {
     
     /* i := i + 1; */
     C_SUM_INTOBJS( t_1, l_i, INTOBJ_INT(1) )
     l_i = t_1;
     
    }
    /* fi */
    
   }
   
   /* else */
   else {
    
    /* ADD_SET( done, i ); */
    t_1 = GF_ADD__SET;
    CALL_2ARGS( t_1, l_done, l_i );
    
    /* i := i + 1; */
    C_SUM_INTOBJS( t_1, l_i, INTOBJ_INT(1) )
    l_i = t_1;
    
   }
   /* fi */
   
  }
  
  /* else */
  else {
   
   /* i := i + 1; */
   C_SUM( t_1, l_i, INTOBJ_INT(1) )
   l_i = t_1;
   
  }
  /* fi */
  
 }
 /* od */
 
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
 Obj  a_list )
{
 Obj t_1 = 0;
 Obj t_2 = 0;
 Bag oldFrame;
 
 /* allocate new stack frame */
 SWITCH_TO_NEW_FRAME(self,1,0,oldFrame);
 ASS_LVAR( 1, a_list );
 
 /* return function ... end; */
 t_1 = NewFunction( NameFunc[49], NargFunc[49], NamsFunc[49], HdlrFunc49 );
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Revision.type_g := "@(#)$Id$"; */
 t_1 = GC_Revision;
 CHECK_BOUND( t_1, "Revision" )
 C_NEW_STRING( t_2, 52, "@(#)$Id$" )
 ASS_REC( t_1, R_type__g, t_2 );
 
 /* BIND_GLOBAL( "POS_DATA_TYPE", 3 ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "POS_DATA_TYPE" )
 CALL_2ARGS( t_1, t_2, INTOBJ_INT(3) );
 
 /* BIND_GLOBAL( "POS_NUMB_TYPE", 4 ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "POS_NUMB_TYPE" )
 CALL_2ARGS( t_1, t_2, INTOBJ_INT(4) );
 
 /* BIND_GLOBAL( "POS_FIRST_FREE_TYPE", 5 ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 19, "POS_FIRST_FREE_TYPE" )
 CALL_2ARGS( t_1, t_2, INTOBJ_INT(5) );
 
 /* NEW_TYPE_NEXT_ID := - 2 ^ 28; */
 t_2 = POW( INTOBJ_INT(2), INTOBJ_INT(28) );
 C_AINV( t_1, t_2 )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* BIND_GLOBAL( "DeclareCategoryKernel", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 21, "DeclareCategoryKernel" )
 t_3 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewCategory", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "NewCategory" )
 t_3 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DeclareCategory", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 15, "DeclareCategory" )
 t_3 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DeclareRepresentationKernel", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 27, "DeclareRepresentationKernel" )
 t_3 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewRepresentation", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 17, "NewRepresentation" )
 t_3 = NewFunction( NameFunc[6], NargFunc[6], NamsFunc[6], HdlrFunc6 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DeclareRepresentation", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 21, "DeclareRepresentation" )
 t_3 = NewFunction( NameFunc[7], NargFunc[7], NamsFunc[7], HdlrFunc7 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareRepresentation( "IsInternalRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 13, "IsInternalRep" )
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 t_4 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_4, 0 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* DeclareRepresentation( "IsPositionalObjectRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 21, "IsPositionalObjectRep" )
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 t_4 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_4, 0 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* DeclareRepresentation( "IsComponentObjectRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 20, "IsComponentObjectRep" )
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 t_4 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_4, 0 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* DeclareRepresentation( "IsDataObjectRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 15, "IsDataObjectRep" )
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 t_4 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_4, 0 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* DeclareRepresentation( "IsAttributeStoringRep", IsComponentObjectRep, [  ], IS_OBJECT ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 21, "IsAttributeStoringRep" )
 t_3 = GC_IsComponentObjectRep;
 CHECK_BOUND( t_3, "IsComponentObjectRep" )
 t_4 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_4, 0 );
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* InstallAttributeFunction( function ... end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[8], NargFunc[8], NamsFunc[8], HdlrFunc8 );
 ENVI_FUNC( t_2 ) = CurrLVars;
 t_3 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_2) = t_3;
 CHANGED_BAG( CurrLVars );
 CALL_1ARGS( t_1, t_2 );
 
 /* InstallAttributeFunction( function ... end ); */
 t_1 = GF_InstallAttributeFunction;
 t_2 = NewFunction( NameFunc[9], NargFunc[9], NamsFunc[9], HdlrFunc9 );
 ENVI_FUNC( t_2 ) = CurrLVars;
 t_3 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_2) = t_3;
 CHANGED_BAG( CurrLVars );
 CALL_1ARGS( t_1, t_2 );
 
 /* BIND_GLOBAL( "EMPTY_FLAGS", FLAGS_FILTER( IS_OBJECT ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "EMPTY_FLAGS" )
 t_4 = GF_FLAGS__FILTER;
 t_5 = GC_IS__OBJECT;
 CHECK_BOUND( t_5, "IS_OBJECT" )
 t_3 = CALL_1ARGS( t_4, t_5 );
 CHECK_FUNC_RESULT( t_3 )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareCategory( "IsFamily", IS_OBJECT ); */
 t_1 = GF_DeclareCategory;
 C_NEW_STRING( t_2, 8, "IsFamily" )
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareCategory( "IsType", IS_OBJECT ); */
 t_1 = GF_DeclareCategory;
 C_NEW_STRING( t_2, 6, "IsType" )
 t_3 = GC_IS__OBJECT;
 CHECK_BOUND( t_3, "IS_OBJECT" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareCategory( "IsFamilyOfFamilies", IsFamily ); */
 t_1 = GF_DeclareCategory;
 C_NEW_STRING( t_2, 18, "IsFamilyOfFamilies" )
 t_3 = GC_IsFamily;
 CHECK_BOUND( t_3, "IsFamily" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareCategory( "IsFamilyOfTypes", IsFamily ); */
 t_1 = GF_DeclareCategory;
 C_NEW_STRING( t_2, 15, "IsFamilyOfTypes" )
 t_3 = GC_IsFamily;
 CHECK_BOUND( t_3, "IsFamily" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* DeclareRepresentation( "IsFamilyDefaultRep", IsComponentObjectRep, "NAME,REQ_FLAGS,IMP_FLAGS,TYPES,TYPES_LIST_FAM", IsFamily ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 18, "IsFamilyDefaultRep" )
 t_3 = GC_IsComponentObjectRep;
 CHECK_BOUND( t_3, "IsComponentObjectRep" )
 C_NEW_STRING( t_4, 45, "NAME,REQ_FLAGS,IMP_FLAGS,TYPES,TYPES_LIST_FAM" )
 t_5 = GC_IsFamily;
 CHECK_BOUND( t_5, "IsFamily" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* DeclareRepresentation( "IsTypeDefaultRep", IsPositionalObjectRep, "", IsType ); */
 t_1 = GF_DeclareRepresentation;
 C_NEW_STRING( t_2, 16, "IsTypeDefaultRep" )
 t_3 = GC_IsPositionalObjectRep;
 CHECK_BOUND( t_3, "IsPositionalObjectRep" )
 C_NEW_STRING( t_4, 0, "" )
 t_5 = GC_IsType;
 CHECK_BOUND( t_5, "IsType" )
 CALL_4ARGS( t_1, t_2, t_3, t_4, t_5 );
 
 /* BIND_GLOBAL( "FamilyOfFamilies", rec(
     ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 16, "FamilyOfFamilies" )
 t_3 = NEW_PREC( 0 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_SUM( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* BIND_GLOBAL( "TypeOfFamilies", [ FamilyOfFamilies, WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamily and IsFamilyDefaultRep ) ), false, NEW_TYPE_NEXT_ID ] ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 14, "TypeOfFamilies" )
 t_3 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_3, 4 );
 t_4 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_4, "FamilyOfFamilies" )
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 t_5 = GF_WITH__IMPS__FLAGS;
 t_7 = GF_FLAGS__FILTER;
 t_9 = GC_IsFamily;
 CHECK_BOUND( t_9, "IsFamily" )
 if ( t_9 == False ) {
  t_8 = t_9;
 }
 else if ( t_9 == True ) {
  t_10 = GC_IsFamilyDefaultRep;
  CHECK_BOUND( t_10, "IsFamilyDefaultRep" )
  CHECK_BOOL( t_10 )
  t_8 = t_10;
 }
 else {
  CHECK_FUNC( t_9 )
  t_11 = GC_IsFamilyDefaultRep;
  CHECK_BOUND( t_11, "IsFamilyDefaultRep" )
  CHECK_FUNC( t_11 )
  t_8 = NewAndFilter( t_9, t_11 );
 }
 t_6 = CALL_1ARGS( t_7, t_8 );
 CHECK_FUNC_RESULT( t_6 )
 t_4 = CALL_1ARGS( t_5, t_6 );
 CHECK_FUNC_RESULT( t_4 )
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = False;
 SET_ELM_PLIST( t_3, 3, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_4, "NEW_TYPE_NEXT_ID" )
 SET_ELM_PLIST( t_3, 4, t_4 );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FamilyOfFamilies!.NAME := "FamilyOfFamilies"; */
 t_1 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_1, "FamilyOfFamilies" )
 C_NEW_STRING( t_2, 16, "FamilyOfFamilies" )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_NAME, t_2 );
 }
 else {
  ASS_REC( t_1, R_NAME, t_2 );
 }
 
 /* FamilyOfFamilies!.REQ_FLAGS := FLAGS_FILTER( IsFamily ); */
 t_1 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_1, "FamilyOfFamilies" )
 t_3 = GF_FLAGS__FILTER;
 t_4 = GC_IsFamily;
 CHECK_BOUND( t_4, "IsFamily" )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_REQ__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_REQ__FLAGS, t_2 );
 }
 
 /* FamilyOfFamilies!.IMP_FLAGS := EMPTY_FLAGS; */
 t_1 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_1, "FamilyOfFamilies" )
 t_2 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_2, "EMPTY_FLAGS" )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_IMP__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_IMP__FLAGS, t_2 );
 }
 
 /* FamilyOfFamilies!.TYPES := [  ]; */
 t_1 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_1, "FamilyOfFamilies" )
 t_2 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_2, 0 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES, t_2 );
 }
 
 /* FamilyOfFamilies!.TYPES_LIST_FAM := [ ,,,,,,,,,,,,,,,,,, false ]; */
 t_1 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_1, "FamilyOfFamilies" )
 t_2 = NEW_PLIST( T_PLIST, 19 );
 SET_LEN_PLIST( t_2, 19 );
 t_3 = False;
 SET_ELM_PLIST( t_2, 19, t_3 );
 CHANGED_BAG( t_2 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_SUM( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* BIND_GLOBAL( "TypeOfFamilyOfFamilies", [ FamilyOfFamilies, WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep and IsAttributeStoringRep ) ), false, NEW_TYPE_NEXT_ID ] ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 22, "TypeOfFamilyOfFamilies" )
 t_3 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_3, 4 );
 t_4 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_4, "FamilyOfFamilies" )
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 t_5 = GF_WITH__IMPS__FLAGS;
 t_7 = GF_FLAGS__FILTER;
 t_10 = GC_IsFamilyOfFamilies;
 CHECK_BOUND( t_10, "IsFamilyOfFamilies" )
 if ( t_10 == False ) {
  t_9 = t_10;
 }
 else if ( t_10 == True ) {
  t_11 = GC_IsFamilyDefaultRep;
  CHECK_BOUND( t_11, "IsFamilyDefaultRep" )
  CHECK_BOOL( t_11 )
  t_9 = t_11;
 }
 else {
  CHECK_FUNC( t_10 )
  t_12 = GC_IsFamilyDefaultRep;
  CHECK_BOUND( t_12, "IsFamilyDefaultRep" )
  CHECK_FUNC( t_12 )
  t_9 = NewAndFilter( t_10, t_12 );
 }
 if ( t_9 == False ) {
  t_8 = t_9;
 }
 else if ( t_9 == True ) {
  t_10 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_10, "IsAttributeStoringRep" )
  CHECK_BOOL( t_10 )
  t_8 = t_10;
 }
 else {
  CHECK_FUNC( t_9 )
  t_11 = GC_IsAttributeStoringRep;
  CHECK_BOUND( t_11, "IsAttributeStoringRep" )
  CHECK_FUNC( t_11 )
  t_8 = NewAndFilter( t_9, t_11 );
 }
 t_6 = CALL_1ARGS( t_7, t_8 );
 CHECK_FUNC_RESULT( t_6 )
 t_4 = CALL_1ARGS( t_5, t_6 );
 CHECK_FUNC_RESULT( t_4 )
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = False;
 SET_ELM_PLIST( t_3, 3, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_4, "NEW_TYPE_NEXT_ID" )
 SET_ELM_PLIST( t_3, 4, t_4 );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FamilyOfTypes", rec(
     ) ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "FamilyOfTypes" )
 t_3 = NEW_PREC( 0 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_SUM( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* BIND_GLOBAL( "TypeOfTypes", [ FamilyOfTypes, WITH_IMPS_FLAGS( FLAGS_FILTER( IsType and IsTypeDefaultRep ) ), false, NEW_TYPE_NEXT_ID ] ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "TypeOfTypes" )
 t_3 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_3, 4 );
 t_4 = GC_FamilyOfTypes;
 CHECK_BOUND( t_4, "FamilyOfTypes" )
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 t_5 = GF_WITH__IMPS__FLAGS;
 t_7 = GF_FLAGS__FILTER;
 t_9 = GC_IsType;
 CHECK_BOUND( t_9, "IsType" )
 if ( t_9 == False ) {
  t_8 = t_9;
 }
 else if ( t_9 == True ) {
  t_10 = GC_IsTypeDefaultRep;
  CHECK_BOUND( t_10, "IsTypeDefaultRep" )
  CHECK_BOOL( t_10 )
  t_8 = t_10;
 }
 else {
  CHECK_FUNC( t_9 )
  t_11 = GC_IsTypeDefaultRep;
  CHECK_BOUND( t_11, "IsTypeDefaultRep" )
  CHECK_FUNC( t_11 )
  t_8 = NewAndFilter( t_9, t_11 );
 }
 t_6 = CALL_1ARGS( t_7, t_8 );
 CHECK_FUNC_RESULT( t_6 )
 t_4 = CALL_1ARGS( t_5, t_6 );
 CHECK_FUNC_RESULT( t_4 )
 SET_ELM_PLIST( t_3, 2, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = False;
 SET_ELM_PLIST( t_3, 3, t_4 );
 CHANGED_BAG( t_3 );
 t_4 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_4, "NEW_TYPE_NEXT_ID" )
 SET_ELM_PLIST( t_3, 4, t_4 );
 CHANGED_BAG( t_3 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FamilyOfTypes!.NAME := "FamilyOfTypes"; */
 t_1 = GC_FamilyOfTypes;
 CHECK_BOUND( t_1, "FamilyOfTypes" )
 C_NEW_STRING( t_2, 13, "FamilyOfTypes" )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_NAME, t_2 );
 }
 else {
  ASS_REC( t_1, R_NAME, t_2 );
 }
 
 /* FamilyOfTypes!.REQ_FLAGS := FLAGS_FILTER( IsType ); */
 t_1 = GC_FamilyOfTypes;
 CHECK_BOUND( t_1, "FamilyOfTypes" )
 t_3 = GF_FLAGS__FILTER;
 t_4 = GC_IsType;
 CHECK_BOUND( t_4, "IsType" )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_REQ__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_REQ__FLAGS, t_2 );
 }
 
 /* FamilyOfTypes!.IMP_FLAGS := EMPTY_FLAGS; */
 t_1 = GC_FamilyOfTypes;
 CHECK_BOUND( t_1, "FamilyOfTypes" )
 t_2 = GC_EMPTY__FLAGS;
 CHECK_BOUND( t_2, "EMPTY_FLAGS" )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_IMP__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_IMP__FLAGS, t_2 );
 }
 
 /* FamilyOfTypes!.TYPES := [  ]; */
 t_1 = GC_FamilyOfTypes;
 CHECK_BOUND( t_1, "FamilyOfTypes" )
 t_2 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_2, 0 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES, t_2 );
 }
 
 /* FamilyOfTypes!.TYPES_LIST_FAM := [ ,,,,,,,,,,,,,,,,,, false ]; */
 t_1 = GC_FamilyOfTypes;
 CHECK_BOUND( t_1, "FamilyOfTypes" )
 t_2 = NEW_PLIST( T_PLIST, 19 );
 SET_LEN_PLIST( t_2, 19 );
 t_3 = False;
 SET_ELM_PLIST( t_2, 19, t_3 );
 CHANGED_BAG( t_2 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 C_SUM( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* TypeOfFamilyOfTypes := [ FamilyOfFamilies, WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfTypes and IsTypeDefaultRep ) ), false, NEW_TYPE_NEXT_ID ]; */
 t_1 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_1, 4 );
 t_2 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_2, "FamilyOfFamilies" )
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 t_3 = GF_WITH__IMPS__FLAGS;
 t_5 = GF_FLAGS__FILTER;
 t_7 = GC_IsFamilyOfTypes;
 CHECK_BOUND( t_7, "IsFamilyOfTypes" )
 if ( t_7 == False ) {
  t_6 = t_7;
 }
 else if ( t_7 == True ) {
  t_8 = GC_IsTypeDefaultRep;
  CHECK_BOUND( t_8, "IsTypeDefaultRep" )
  CHECK_BOOL( t_8 )
  t_6 = t_8;
 }
 else {
  CHECK_FUNC( t_7 )
  t_9 = GC_IsTypeDefaultRep;
  CHECK_BOUND( t_9, "IsTypeDefaultRep" )
  CHECK_FUNC( t_9 )
  t_6 = NewAndFilter( t_7, t_9 );
 }
 t_4 = CALL_1ARGS( t_5, t_6 );
 CHECK_FUNC_RESULT( t_4 )
 t_2 = CALL_1ARGS( t_3, t_4 );
 CHECK_FUNC_RESULT( t_2 )
 SET_ELM_PLIST( t_1, 2, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 3, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = GC_NEW__TYPE__NEXT__ID;
 CHECK_BOUND( t_2, "NEW_TYPE_NEXT_ID" )
 SET_ELM_PLIST( t_1, 4, t_2 );
 CHANGED_BAG( t_1 );
 AssGVar( G_TypeOfFamilyOfTypes, t_1 );
 
 /* SET_TYPE_COMOBJ( FamilyOfFamilies, TypeOfFamilyOfFamilies ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 t_2 = GC_FamilyOfFamilies;
 CHECK_BOUND( t_2, "FamilyOfFamilies" )
 t_3 = GC_TypeOfFamilyOfFamilies;
 CHECK_BOUND( t_3, "TypeOfFamilyOfFamilies" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* SET_TYPE_POSOBJ( TypeOfFamilies, TypeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 t_2 = GC_TypeOfFamilies;
 CHECK_BOUND( t_2, "TypeOfFamilies" )
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* SET_TYPE_COMOBJ( FamilyOfTypes, TypeOfFamilyOfTypes ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 t_2 = GC_FamilyOfTypes;
 CHECK_BOUND( t_2, "FamilyOfTypes" )
 t_3 = GC_TypeOfFamilyOfTypes;
 CHECK_BOUND( t_3, "TypeOfFamilyOfTypes" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* SET_TYPE_POSOBJ( TypeOfTypes, TypeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 t_2 = GC_TypeOfTypes;
 CHECK_BOUND( t_2, "TypeOfTypes" )
 t_3 = GC_TypeOfTypes;
 CHECK_BOUND( t_3, "TypeOfTypes" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "CATEGORIES_FAMILY", [  ] ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 17, "CATEGORIES_FAMILY" )
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "CategoryFamily", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 14, "CategoryFamily" )
 t_3 = NewFunction( NameFunc[11], NargFunc[11], NamsFunc[11], HdlrFunc11 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DeclareCategoryFamily", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 21, "DeclareCategoryFamily" )
 t_3 = NewFunction( NameFunc[12], NargFunc[12], NamsFunc[12], HdlrFunc12 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Subtype := "defined below"; */
 C_NEW_STRING( t_1, 13, "defined below" )
 AssGVar( G_Subtype, t_1 );
 
 /* BIND_GLOBAL( "NEW_FAMILY", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NEW_FAMILY" )
 t_3 = NewFunction( NameFunc[13], NargFunc[13], NamsFunc[13], HdlrFunc13 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily2", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily2" )
 t_3 = NewFunction( NameFunc[14], NargFunc[14], NamsFunc[14], HdlrFunc14 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily3", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily3" )
 t_3 = NewFunction( NameFunc[15], NargFunc[15], NamsFunc[15], HdlrFunc15 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily4", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily4" )
 t_3 = NewFunction( NameFunc[16], NargFunc[16], NamsFunc[16], HdlrFunc16 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily5", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "NewFamily5" )
 t_3 = NewFunction( NameFunc[17], NargFunc[17], NamsFunc[17], HdlrFunc17 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewFamily", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "NewFamily" )
 t_3 = NewFunction( NameFunc[18], NargFunc[18], NamsFunc[18], HdlrFunc18 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* InstallOtherMethod( PRINT_OBJ, true, [ IsFamily ], 0, function ... end ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = GC_PRINT__OBJ;
 CHECK_BOUND( t_2, "PRINT_OBJ" )
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_5 = GC_IsFamily;
 CHECK_BOUND( t_5, "IsFamily" )
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_5 = NewFunction( NameFunc[19], NargFunc[19], NamsFunc[19], HdlrFunc19 );
 ENVI_FUNC( t_5 ) = CurrLVars;
 t_6 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_5) = t_6;
 CHANGED_BAG( CurrLVars );
 CALL_5ARGS( t_1, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
 
 /* NEW_TYPE_CACHE_MISS := 0; */
 AssGVar( G_NEW__TYPE__CACHE__MISS, INTOBJ_INT(0) );
 
 /* NEW_TYPE_CACHE_HIT := 0; */
 AssGVar( G_NEW__TYPE__CACHE__HIT, INTOBJ_INT(0) );
 
 /* BIND_GLOBAL( "NEW_TYPE", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NEW_TYPE" )
 t_3 = NewFunction( NameFunc[20], NargFunc[20], NamsFunc[20], HdlrFunc20 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType2", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NewType2" )
 t_3 = NewFunction( NameFunc[21], NargFunc[21], NamsFunc[21], HdlrFunc21 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType3", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NewType3" )
 t_3 = NewFunction( NameFunc[22], NargFunc[22], NamsFunc[22], HdlrFunc22 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType4", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NewType4" )
 t_3 = NewFunction( NameFunc[23], NargFunc[23], NamsFunc[23], HdlrFunc23 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType5", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "NewType5" )
 t_3 = NewFunction( NameFunc[24], NargFunc[24], NamsFunc[24], HdlrFunc24 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "NewType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "NewType" )
 t_3 = NewFunction( NameFunc[25], NargFunc[25], NamsFunc[25], HdlrFunc25 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* InstallOtherMethod( PRINT_OBJ, true, [ IsType ], 0, function ... end ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = GC_PRINT__OBJ;
 CHECK_BOUND( t_2, "PRINT_OBJ" )
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_5 = GC_IsType;
 CHECK_BOUND( t_5, "IsType" )
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_5 = NewFunction( NameFunc[26], NargFunc[26], NamsFunc[26], HdlrFunc26 );
 ENVI_FUNC( t_5 ) = CurrLVars;
 t_6 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_5) = t_6;
 CHANGED_BAG( CurrLVars );
 CALL_5ARGS( t_1, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
 
 /* BIND_GLOBAL( "Subtype2", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "Subtype2" )
 t_3 = NewFunction( NameFunc[27], NargFunc[27], NamsFunc[27], HdlrFunc27 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "Subtype3", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "Subtype3" )
 t_3 = NewFunction( NameFunc[28], NargFunc[28], NamsFunc[28], HdlrFunc28 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Unbind( Subtype) */
 AssGVar( G_Subtype, 0 );
 
 /* BIND_GLOBAL( "Subtype", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "Subtype" )
 t_3 = NewFunction( NameFunc[29], NargFunc[29], NamsFunc[29], HdlrFunc29 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SupType2", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "SupType2" )
 t_3 = NewFunction( NameFunc[30], NargFunc[30], NamsFunc[30], HdlrFunc30 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SupType3", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "SupType3" )
 t_3 = NewFunction( NameFunc[31], NargFunc[31], NamsFunc[31], HdlrFunc31 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SupType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "SupType" )
 t_3 = NewFunction( NameFunc[32], NargFunc[32], NamsFunc[32], HdlrFunc32 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FamilyType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "FamilyType" )
 t_3 = NewFunction( NameFunc[33], NargFunc[33], NamsFunc[33], HdlrFunc33 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FlagsType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "FlagsType" )
 t_3 = NewFunction( NameFunc[34], NargFunc[34], NamsFunc[34], HdlrFunc34 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DataType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "DataType" )
 t_3 = NewFunction( NameFunc[35], NargFunc[35], NamsFunc[35], HdlrFunc35 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetDataType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "SetDataType" )
 t_3 = NewFunction( NameFunc[36], NargFunc[36], NamsFunc[36], HdlrFunc36 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SharedType", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "SharedType" )
 t_3 = NewFunction( NameFunc[37], NargFunc[37], NamsFunc[37], HdlrFunc37 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "TypeObj", TYPE_OBJ ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "TypeObj" )
 t_3 = GC_TYPE__OBJ;
 CHECK_BOUND( t_3, "TYPE_OBJ" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FamilyObj", FAMILY_OBJ ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "FamilyObj" )
 t_3 = GC_FAMILY__OBJ;
 CHECK_BOUND( t_3, "FAMILY_OBJ" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "FlagsObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 8, "FlagsObj" )
 t_3 = NewFunction( NameFunc[38], NargFunc[38], NamsFunc[38], HdlrFunc38 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "DataObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 7, "DataObj" )
 t_3 = NewFunction( NameFunc[39], NargFunc[39], NamsFunc[39], HdlrFunc39 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SharedObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "SharedObj" )
 t_3 = NewFunction( NameFunc[40], NargFunc[40], NamsFunc[40], HdlrFunc40 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetTypeObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 10, "SetTypeObj" )
 t_3 = NewFunction( NameFunc[41], NargFunc[41], NamsFunc[41], HdlrFunc41 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "Objectify", SetTypeObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 9, "Objectify" )
 t_3 = GC_SetTypeObj;
 CHECK_BOUND( t_3, "SetTypeObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "ChangeTypeObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "ChangeTypeObj" )
 t_3 = NewFunction( NameFunc[42], NargFunc[42], NamsFunc[42], HdlrFunc42 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "ReObjectify", ChangeTypeObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 11, "ReObjectify" )
 t_3 = GC_ChangeTypeObj;
 CHECK_BOUND( t_3, "ChangeTypeObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* Unbind( SetFilterObj) */
 AssGVar( G_SetFilterObj, 0 );
 
 /* BIND_GLOBAL( "SetFilterObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 12, "SetFilterObj" )
 t_3 = NewFunction( NameFunc[43], NargFunc[43], NamsFunc[43], HdlrFunc43 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SET_FILTER_OBJ", SetFilterObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 14, "SET_FILTER_OBJ" )
 t_3 = GC_SetFilterObj;
 CHECK_BOUND( t_3, "SetFilterObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "ResetFilterObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 14, "ResetFilterObj" )
 t_3 = NewFunction( NameFunc[44], NargFunc[44], NamsFunc[44], HdlrFunc44 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "RESET_FILTER_OBJ", ResetFilterObj ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 16, "RESET_FILTER_OBJ" )
 t_3 = GC_ResetFilterObj;
 CHECK_BOUND( t_3, "ResetFilterObj" )
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "SetFeatureObj", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 13, "SetFeatureObj" )
 t_3 = NewFunction( NameFunc[45], NargFunc[45], NamsFunc[45], HdlrFunc45 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "InstallMethodsFunction2", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 23, "InstallMethodsFunction2" )
 t_3 = NewFunction( NameFunc[46], NargFunc[46], NamsFunc[46], HdlrFunc46 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* BIND_GLOBAL( "RunMethodsFunction2", function ... end ); */
 t_1 = GF_BIND__GLOBAL;
 C_NEW_STRING( t_2, 19, "RunMethodsFunction2" )
 t_3 = NewFunction( NameFunc[48], NargFunc[48], NamsFunc[48], HdlrFunc48 );
 ENVI_FUNC( t_3 ) = CurrLVars;
 t_4 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_3) = t_4;
 CHANGED_BAG( CurrLVars );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* 'InitKernel' sets up data structures, fopies, copies, handlers */
static Int InitKernel ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 InitCopyGVar( "REREADING", &GC_REREADING );
 InitFopyGVar( "SHALLOW_COPY_OBJ", &GF_SHALLOW__COPY__OBJ );
 InitCopyGVar( "PRINT_OBJ", &GC_PRINT__OBJ );
 InitFopyGVar( "CALL_FUNC_LIST", &GF_CALL__FUNC__LIST );
 InitFopyGVar( "NAME_FUNC", &GF_NAME__FUNC );
 InitFopyGVar( "IS_REC", &GF_IS__REC );
 InitFopyGVar( "IS_LIST", &GF_IS__LIST );
 InitFopyGVar( "ADD_LIST", &GF_ADD__LIST );
 InitFopyGVar( "IS_PLIST_REP", &GF_IS__PLIST__REP );
 InitFopyGVar( "IS_BLIST", &GF_IS__BLIST );
 InitFopyGVar( "IS_RANGE", &GF_IS__RANGE );
 InitFopyGVar( "IS_STRING_REP", &GF_IS__STRING__REP );
 InitCopyGVar( "TYPE_OBJ", &GC_TYPE__OBJ );
 InitFopyGVar( "TYPE_OBJ", &GF_TYPE__OBJ );
 InitCopyGVar( "FAMILY_OBJ", &GC_FAMILY__OBJ );
 InitFopyGVar( "IS_IDENTICAL_OBJ", &GF_IS__IDENTICAL__OBJ );
 InitFopyGVar( "IS_COMOBJ", &GF_IS__COMOBJ );
 InitFopyGVar( "SET_TYPE_COMOBJ", &GF_SET__TYPE__COMOBJ );
 InitFopyGVar( "IS_POSOBJ", &GF_IS__POSOBJ );
 InitFopyGVar( "SET_TYPE_POSOBJ", &GF_SET__TYPE__POSOBJ );
 InitFopyGVar( "LEN_POSOBJ", &GF_LEN__POSOBJ );
 InitFopyGVar( "IS_DATOBJ", &GF_IS__DATOBJ );
 InitFopyGVar( "SET_TYPE_DATOBJ", &GF_SET__TYPE__DATOBJ );
 InitCopyGVar( "IS_OBJECT", &GC_IS__OBJECT );
 InitFopyGVar( "AND_FLAGS", &GF_AND__FLAGS );
 InitFopyGVar( "SUB_FLAGS", &GF_SUB__FLAGS );
 InitFopyGVar( "HASH_FLAGS", &GF_HASH__FLAGS );
 InitFopyGVar( "IS_EQUAL_FLAGS", &GF_IS__EQUAL__FLAGS );
 InitFopyGVar( "IS_SUBSET_FLAGS", &GF_IS__SUBSET__FLAGS );
 InitFopyGVar( "TRUES_FLAGS", &GF_TRUES__FLAGS );
 InitFopyGVar( "FLAG1_FILTER", &GF_FLAG1__FILTER );
 InitFopyGVar( "FLAGS_FILTER", &GF_FLAGS__FILTER );
 InitFopyGVar( "NEW_FILTER", &GF_NEW__FILTER );
 InitFopyGVar( "SETTER_FUNCTION", &GF_SETTER__FUNCTION );
 InitFopyGVar( "GETTER_FUNCTION", &GF_GETTER__FUNCTION );
 InitFopyGVar( "LEN_LIST", &GF_LEN__LIST );
 InitFopyGVar( "SET_FILTER_LIST", &GF_SET__FILTER__LIST );
 InitFopyGVar( "RESET_FILTER_LIST", &GF_RESET__FILTER__LIST );
 InitFopyGVar( "APPEND_LIST_INTR", &GF_APPEND__LIST__INTR );
 InitFopyGVar( "ADD_SET", &GF_ADD__SET );
 InitFopyGVar( "CONV_STRING", &GF_CONV__STRING );
 InitFopyGVar( "Print", &GF_Print );
 InitCopyGVar( "Revision", &GC_Revision );
 InitFopyGVar( "Error", &GF_Error );
 InitFopyGVar( "TNUM_OBJ", &GF_TNUM__OBJ );
 InitFopyGVar( "BIND_GLOBAL", &GF_BIND__GLOBAL );
 InitCopyGVar( "NEW_TYPE_NEXT_ID", &GC_NEW__TYPE__NEXT__ID );
 InitCopyGVar( "CATS_AND_REPS", &GC_CATS__AND__REPS );
 InitCopyGVar( "FILTERS", &GC_FILTERS );
 InitCopyGVar( "INFO_FILTERS", &GC_INFO__FILTERS );
 InitCopyGVar( "RANK_FILTERS", &GC_RANK__FILTERS );
 InitFopyGVar( "InstallTrueMethod", &GF_InstallTrueMethod );
 InitFopyGVar( "InstallTrueMethodNewFilter", &GF_InstallTrueMethodNewFilter );
 InitFopyGVar( "NewCategory", &GF_NewCategory );
 InitCopyGVar( "NewRepresentation", &GC_NewRepresentation );
 InitFopyGVar( "DeclareRepresentation", &GF_DeclareRepresentation );
 InitCopyGVar( "IsComponentObjectRep", &GC_IsComponentObjectRep );
 InitFopyGVar( "InstallAttributeFunction", &GF_InstallAttributeFunction );
 InitFopyGVar( "InstallOtherMethod", &GF_InstallOtherMethod );
 InitCopyGVar( "IsAttributeStoringRep", &GC_IsAttributeStoringRep );
 InitCopyGVar( "SUM_FLAGS", &GC_SUM__FLAGS );
 InitCopyGVar( "SetFilterObj", &GC_SetFilterObj );
 InitFopyGVar( "SetFilterObj", &GF_SetFilterObj );
 InitFopyGVar( "DeclareCategory", &GF_DeclareCategory );
 InitCopyGVar( "IsFamily", &GC_IsFamily );
 InitFopyGVar( "IsFamily", &GF_IsFamily );
 InitCopyGVar( "IsPositionalObjectRep", &GC_IsPositionalObjectRep );
 InitCopyGVar( "IsType", &GC_IsType );
 InitFopyGVar( "IsType", &GF_IsType );
 InitCopyGVar( "FamilyOfFamilies", &GC_FamilyOfFamilies );
 InitFopyGVar( "WITH_IMPS_FLAGS", &GF_WITH__IMPS__FLAGS );
 InitCopyGVar( "IsFamilyDefaultRep", &GC_IsFamilyDefaultRep );
 InitCopyGVar( "EMPTY_FLAGS", &GC_EMPTY__FLAGS );
 InitCopyGVar( "IsFamilyOfFamilies", &GC_IsFamilyOfFamilies );
 InitCopyGVar( "FamilyOfTypes", &GC_FamilyOfTypes );
 InitCopyGVar( "IsTypeDefaultRep", &GC_IsTypeDefaultRep );
 InitCopyGVar( "TypeOfFamilyOfTypes", &GC_TypeOfFamilyOfTypes );
 InitCopyGVar( "IsFamilyOfTypes", &GC_IsFamilyOfTypes );
 InitCopyGVar( "TypeOfFamilyOfFamilies", &GC_TypeOfFamilyOfFamilies );
 InitCopyGVar( "TypeOfFamilies", &GC_TypeOfFamilies );
 InitCopyGVar( "TypeOfTypes", &GC_TypeOfTypes );
 InitCopyGVar( "CATEGORIES_FAMILY", &GC_CATEGORIES__FAMILY );
 InitFopyGVar( "CategoryFamily", &GF_CategoryFamily );
 InitFopyGVar( "VALUE_GLOBAL", &GF_VALUE__GLOBAL );
 InitFopyGVar( "Subtype", &GF_Subtype );
 InitFopyGVar( "NEW_FAMILY", &GF_NEW__FAMILY );
 InitFopyGVar( "NewFamily2", &GF_NewFamily2 );
 InitFopyGVar( "NewFamily3", &GF_NewFamily3 );
 InitFopyGVar( "NewFamily4", &GF_NewFamily4 );
 InitFopyGVar( "NewFamily5", &GF_NewFamily5 );
 InitCopyGVar( "NEW_TYPE_CACHE_MISS", &GC_NEW__TYPE__CACHE__MISS );
 InitCopyGVar( "NEW_TYPE_CACHE_HIT", &GC_NEW__TYPE__CACHE__HIT );
 InitCopyGVar( "POS_DATA_TYPE", &GC_POS__DATA__TYPE );
 InitCopyGVar( "POS_NUMB_TYPE", &GC_POS__NUMB__TYPE );
 InitFopyGVar( "NEW_TYPE", &GF_NEW__TYPE );
 InitCopyGVar( "POS_FIRST_FREE_TYPE", &GC_POS__FIRST__FREE__TYPE );
 InitFopyGVar( "NewType2", &GF_NewType2 );
 InitFopyGVar( "NewType3", &GF_NewType3 );
 InitFopyGVar( "NewType4", &GF_NewType4 );
 InitFopyGVar( "NewType5", &GF_NewType5 );
 InitFopyGVar( "Subtype2", &GF_Subtype2 );
 InitFopyGVar( "Subtype3", &GF_Subtype3 );
 InitFopyGVar( "SupType2", &GF_SupType2 );
 InitFopyGVar( "SupType3", &GF_SupType3 );
 InitFopyGVar( "FlagsType", &GF_FlagsType );
 InitFopyGVar( "TypeObj", &GF_TypeObj );
 InitFopyGVar( "DataType", &GF_DataType );
 InitFopyGVar( "SharedType", &GF_SharedType );
 InitFopyGVar( "RunImmediateMethods", &GF_RunImmediateMethods );
 InitCopyGVar( "SetTypeObj", &GC_SetTypeObj );
 InitCopyGVar( "ChangeTypeObj", &GC_ChangeTypeObj );
 InitCopyGVar( "ResetFilterObj", &GC_ResetFilterObj );
 InitFopyGVar( "ResetFilterObj", &GF_ResetFilterObj );
 
 /* information for the functions */
 InitGlobalBag( &DefaultName, "type.g:DefaultName(131998840)" );
 InitHandlerFunc( HdlrFunc1, "type.g:HdlrFunc1(131998840)" );
 InitGlobalBag( &(NameFunc[1]), "type.g:NameFunc[1](131998840)" );
 InitHandlerFunc( HdlrFunc2, "type.g:HdlrFunc2(131998840)" );
 InitGlobalBag( &(NameFunc[2]), "type.g:NameFunc[2](131998840)" );
 InitHandlerFunc( HdlrFunc3, "type.g:HdlrFunc3(131998840)" );
 InitGlobalBag( &(NameFunc[3]), "type.g:NameFunc[3](131998840)" );
 InitHandlerFunc( HdlrFunc4, "type.g:HdlrFunc4(131998840)" );
 InitGlobalBag( &(NameFunc[4]), "type.g:NameFunc[4](131998840)" );
 InitHandlerFunc( HdlrFunc5, "type.g:HdlrFunc5(131998840)" );
 InitGlobalBag( &(NameFunc[5]), "type.g:NameFunc[5](131998840)" );
 InitHandlerFunc( HdlrFunc6, "type.g:HdlrFunc6(131998840)" );
 InitGlobalBag( &(NameFunc[6]), "type.g:NameFunc[6](131998840)" );
 InitHandlerFunc( HdlrFunc7, "type.g:HdlrFunc7(131998840)" );
 InitGlobalBag( &(NameFunc[7]), "type.g:NameFunc[7](131998840)" );
 InitHandlerFunc( HdlrFunc8, "type.g:HdlrFunc8(131998840)" );
 InitGlobalBag( &(NameFunc[8]), "type.g:NameFunc[8](131998840)" );
 InitHandlerFunc( HdlrFunc9, "type.g:HdlrFunc9(131998840)" );
 InitGlobalBag( &(NameFunc[9]), "type.g:NameFunc[9](131998840)" );
 InitHandlerFunc( HdlrFunc10, "type.g:HdlrFunc10(131998840)" );
 InitGlobalBag( &(NameFunc[10]), "type.g:NameFunc[10](131998840)" );
 InitHandlerFunc( HdlrFunc11, "type.g:HdlrFunc11(131998840)" );
 InitGlobalBag( &(NameFunc[11]), "type.g:NameFunc[11](131998840)" );
 InitHandlerFunc( HdlrFunc12, "type.g:HdlrFunc12(131998840)" );
 InitGlobalBag( &(NameFunc[12]), "type.g:NameFunc[12](131998840)" );
 InitHandlerFunc( HdlrFunc13, "type.g:HdlrFunc13(131998840)" );
 InitGlobalBag( &(NameFunc[13]), "type.g:NameFunc[13](131998840)" );
 InitHandlerFunc( HdlrFunc14, "type.g:HdlrFunc14(131998840)" );
 InitGlobalBag( &(NameFunc[14]), "type.g:NameFunc[14](131998840)" );
 InitHandlerFunc( HdlrFunc15, "type.g:HdlrFunc15(131998840)" );
 InitGlobalBag( &(NameFunc[15]), "type.g:NameFunc[15](131998840)" );
 InitHandlerFunc( HdlrFunc16, "type.g:HdlrFunc16(131998840)" );
 InitGlobalBag( &(NameFunc[16]), "type.g:NameFunc[16](131998840)" );
 InitHandlerFunc( HdlrFunc17, "type.g:HdlrFunc17(131998840)" );
 InitGlobalBag( &(NameFunc[17]), "type.g:NameFunc[17](131998840)" );
 InitHandlerFunc( HdlrFunc18, "type.g:HdlrFunc18(131998840)" );
 InitGlobalBag( &(NameFunc[18]), "type.g:NameFunc[18](131998840)" );
 InitHandlerFunc( HdlrFunc19, "type.g:HdlrFunc19(131998840)" );
 InitGlobalBag( &(NameFunc[19]), "type.g:NameFunc[19](131998840)" );
 InitHandlerFunc( HdlrFunc20, "type.g:HdlrFunc20(131998840)" );
 InitGlobalBag( &(NameFunc[20]), "type.g:NameFunc[20](131998840)" );
 InitHandlerFunc( HdlrFunc21, "type.g:HdlrFunc21(131998840)" );
 InitGlobalBag( &(NameFunc[21]), "type.g:NameFunc[21](131998840)" );
 InitHandlerFunc( HdlrFunc22, "type.g:HdlrFunc22(131998840)" );
 InitGlobalBag( &(NameFunc[22]), "type.g:NameFunc[22](131998840)" );
 InitHandlerFunc( HdlrFunc23, "type.g:HdlrFunc23(131998840)" );
 InitGlobalBag( &(NameFunc[23]), "type.g:NameFunc[23](131998840)" );
 InitHandlerFunc( HdlrFunc24, "type.g:HdlrFunc24(131998840)" );
 InitGlobalBag( &(NameFunc[24]), "type.g:NameFunc[24](131998840)" );
 InitHandlerFunc( HdlrFunc25, "type.g:HdlrFunc25(131998840)" );
 InitGlobalBag( &(NameFunc[25]), "type.g:NameFunc[25](131998840)" );
 InitHandlerFunc( HdlrFunc26, "type.g:HdlrFunc26(131998840)" );
 InitGlobalBag( &(NameFunc[26]), "type.g:NameFunc[26](131998840)" );
 InitHandlerFunc( HdlrFunc27, "type.g:HdlrFunc27(131998840)" );
 InitGlobalBag( &(NameFunc[27]), "type.g:NameFunc[27](131998840)" );
 InitHandlerFunc( HdlrFunc28, "type.g:HdlrFunc28(131998840)" );
 InitGlobalBag( &(NameFunc[28]), "type.g:NameFunc[28](131998840)" );
 InitHandlerFunc( HdlrFunc29, "type.g:HdlrFunc29(131998840)" );
 InitGlobalBag( &(NameFunc[29]), "type.g:NameFunc[29](131998840)" );
 InitHandlerFunc( HdlrFunc30, "type.g:HdlrFunc30(131998840)" );
 InitGlobalBag( &(NameFunc[30]), "type.g:NameFunc[30](131998840)" );
 InitHandlerFunc( HdlrFunc31, "type.g:HdlrFunc31(131998840)" );
 InitGlobalBag( &(NameFunc[31]), "type.g:NameFunc[31](131998840)" );
 InitHandlerFunc( HdlrFunc32, "type.g:HdlrFunc32(131998840)" );
 InitGlobalBag( &(NameFunc[32]), "type.g:NameFunc[32](131998840)" );
 InitHandlerFunc( HdlrFunc33, "type.g:HdlrFunc33(131998840)" );
 InitGlobalBag( &(NameFunc[33]), "type.g:NameFunc[33](131998840)" );
 InitHandlerFunc( HdlrFunc34, "type.g:HdlrFunc34(131998840)" );
 InitGlobalBag( &(NameFunc[34]), "type.g:NameFunc[34](131998840)" );
 InitHandlerFunc( HdlrFunc35, "type.g:HdlrFunc35(131998840)" );
 InitGlobalBag( &(NameFunc[35]), "type.g:NameFunc[35](131998840)" );
 InitHandlerFunc( HdlrFunc36, "type.g:HdlrFunc36(131998840)" );
 InitGlobalBag( &(NameFunc[36]), "type.g:NameFunc[36](131998840)" );
 InitHandlerFunc( HdlrFunc37, "type.g:HdlrFunc37(131998840)" );
 InitGlobalBag( &(NameFunc[37]), "type.g:NameFunc[37](131998840)" );
 InitHandlerFunc( HdlrFunc38, "type.g:HdlrFunc38(131998840)" );
 InitGlobalBag( &(NameFunc[38]), "type.g:NameFunc[38](131998840)" );
 InitHandlerFunc( HdlrFunc39, "type.g:HdlrFunc39(131998840)" );
 InitGlobalBag( &(NameFunc[39]), "type.g:NameFunc[39](131998840)" );
 InitHandlerFunc( HdlrFunc40, "type.g:HdlrFunc40(131998840)" );
 InitGlobalBag( &(NameFunc[40]), "type.g:NameFunc[40](131998840)" );
 InitHandlerFunc( HdlrFunc41, "type.g:HdlrFunc41(131998840)" );
 InitGlobalBag( &(NameFunc[41]), "type.g:NameFunc[41](131998840)" );
 InitHandlerFunc( HdlrFunc42, "type.g:HdlrFunc42(131998840)" );
 InitGlobalBag( &(NameFunc[42]), "type.g:NameFunc[42](131998840)" );
 InitHandlerFunc( HdlrFunc43, "type.g:HdlrFunc43(131998840)" );
 InitGlobalBag( &(NameFunc[43]), "type.g:NameFunc[43](131998840)" );
 InitHandlerFunc( HdlrFunc44, "type.g:HdlrFunc44(131998840)" );
 InitGlobalBag( &(NameFunc[44]), "type.g:NameFunc[44](131998840)" );
 InitHandlerFunc( HdlrFunc45, "type.g:HdlrFunc45(131998840)" );
 InitGlobalBag( &(NameFunc[45]), "type.g:NameFunc[45](131998840)" );
 InitHandlerFunc( HdlrFunc46, "type.g:HdlrFunc46(131998840)" );
 InitGlobalBag( &(NameFunc[46]), "type.g:NameFunc[46](131998840)" );
 InitHandlerFunc( HdlrFunc47, "type.g:HdlrFunc47(131998840)" );
 InitGlobalBag( &(NameFunc[47]), "type.g:NameFunc[47](131998840)" );
 InitHandlerFunc( HdlrFunc48, "type.g:HdlrFunc48(131998840)" );
 InitGlobalBag( &(NameFunc[48]), "type.g:NameFunc[48](131998840)" );
 InitHandlerFunc( HdlrFunc49, "type.g:HdlrFunc49(131998840)" );
 InitGlobalBag( &(NameFunc[49]), "type.g:NameFunc[49](131998840)" );
 
 /* return success */
 return 0;
 
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
 Obj func1;
 
 /* Complete Copy/Fopy registration */
 UpdateCopyFopyInfo();
 
 /* global variables used in handlers */
 G_REREADING = GVarName( "REREADING" );
 G_SHALLOW__COPY__OBJ = GVarName( "SHALLOW_COPY_OBJ" );
 G_PRINT__OBJ = GVarName( "PRINT_OBJ" );
 G_CALL__FUNC__LIST = GVarName( "CALL_FUNC_LIST" );
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 G_IS__REC = GVarName( "IS_REC" );
 G_IS__LIST = GVarName( "IS_LIST" );
 G_ADD__LIST = GVarName( "ADD_LIST" );
 G_IS__PLIST__REP = GVarName( "IS_PLIST_REP" );
 G_IS__BLIST = GVarName( "IS_BLIST" );
 G_IS__RANGE = GVarName( "IS_RANGE" );
 G_IS__STRING__REP = GVarName( "IS_STRING_REP" );
 G_TYPE__OBJ = GVarName( "TYPE_OBJ" );
 G_FAMILY__OBJ = GVarName( "FAMILY_OBJ" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_IS__COMOBJ = GVarName( "IS_COMOBJ" );
 G_SET__TYPE__COMOBJ = GVarName( "SET_TYPE_COMOBJ" );
 G_IS__POSOBJ = GVarName( "IS_POSOBJ" );
 G_SET__TYPE__POSOBJ = GVarName( "SET_TYPE_POSOBJ" );
 G_LEN__POSOBJ = GVarName( "LEN_POSOBJ" );
 G_IS__DATOBJ = GVarName( "IS_DATOBJ" );
 G_SET__TYPE__DATOBJ = GVarName( "SET_TYPE_DATOBJ" );
 G_IS__OBJECT = GVarName( "IS_OBJECT" );
 G_AND__FLAGS = GVarName( "AND_FLAGS" );
 G_SUB__FLAGS = GVarName( "SUB_FLAGS" );
 G_HASH__FLAGS = GVarName( "HASH_FLAGS" );
 G_IS__EQUAL__FLAGS = GVarName( "IS_EQUAL_FLAGS" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_TRUES__FLAGS = GVarName( "TRUES_FLAGS" );
 G_FLAG1__FILTER = GVarName( "FLAG1_FILTER" );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 G_NEW__FILTER = GVarName( "NEW_FILTER" );
 G_SETTER__FUNCTION = GVarName( "SETTER_FUNCTION" );
 G_GETTER__FUNCTION = GVarName( "GETTER_FUNCTION" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_SET__FILTER__LIST = GVarName( "SET_FILTER_LIST" );
 G_RESET__FILTER__LIST = GVarName( "RESET_FILTER_LIST" );
 G_APPEND__LIST__INTR = GVarName( "APPEND_LIST_INTR" );
 G_ADD__SET = GVarName( "ADD_SET" );
 G_CONV__STRING = GVarName( "CONV_STRING" );
 G_Print = GVarName( "Print" );
 G_Revision = GVarName( "Revision" );
 G_Error = GVarName( "Error" );
 G_TNUM__OBJ = GVarName( "TNUM_OBJ" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_NEW__TYPE__NEXT__ID = GVarName( "NEW_TYPE_NEXT_ID" );
 G_CATS__AND__REPS = GVarName( "CATS_AND_REPS" );
 G_FILTERS = GVarName( "FILTERS" );
 G_INFO__FILTERS = GVarName( "INFO_FILTERS" );
 G_RANK__FILTERS = GVarName( "RANK_FILTERS" );
 G_InstallTrueMethod = GVarName( "InstallTrueMethod" );
 G_InstallTrueMethodNewFilter = GVarName( "InstallTrueMethodNewFilter" );
 G_NewCategory = GVarName( "NewCategory" );
 G_NewRepresentation = GVarName( "NewRepresentation" );
 G_DeclareRepresentation = GVarName( "DeclareRepresentation" );
 G_IsComponentObjectRep = GVarName( "IsComponentObjectRep" );
 G_InstallAttributeFunction = GVarName( "InstallAttributeFunction" );
 G_InstallOtherMethod = GVarName( "InstallOtherMethod" );
 G_IsAttributeStoringRep = GVarName( "IsAttributeStoringRep" );
 G_SUM__FLAGS = GVarName( "SUM_FLAGS" );
 G_SetFilterObj = GVarName( "SetFilterObj" );
 G_DeclareCategory = GVarName( "DeclareCategory" );
 G_IsFamily = GVarName( "IsFamily" );
 G_IsPositionalObjectRep = GVarName( "IsPositionalObjectRep" );
 G_IsType = GVarName( "IsType" );
 G_FamilyOfFamilies = GVarName( "FamilyOfFamilies" );
 G_WITH__IMPS__FLAGS = GVarName( "WITH_IMPS_FLAGS" );
 G_IsFamilyDefaultRep = GVarName( "IsFamilyDefaultRep" );
 G_EMPTY__FLAGS = GVarName( "EMPTY_FLAGS" );
 G_IsFamilyOfFamilies = GVarName( "IsFamilyOfFamilies" );
 G_FamilyOfTypes = GVarName( "FamilyOfTypes" );
 G_IsTypeDefaultRep = GVarName( "IsTypeDefaultRep" );
 G_TypeOfFamilyOfTypes = GVarName( "TypeOfFamilyOfTypes" );
 G_IsFamilyOfTypes = GVarName( "IsFamilyOfTypes" );
 G_TypeOfFamilyOfFamilies = GVarName( "TypeOfFamilyOfFamilies" );
 G_TypeOfFamilies = GVarName( "TypeOfFamilies" );
 G_TypeOfTypes = GVarName( "TypeOfTypes" );
 G_CATEGORIES__FAMILY = GVarName( "CATEGORIES_FAMILY" );
 G_CategoryFamily = GVarName( "CategoryFamily" );
 G_VALUE__GLOBAL = GVarName( "VALUE_GLOBAL" );
 G_Subtype = GVarName( "Subtype" );
 G_NEW__FAMILY = GVarName( "NEW_FAMILY" );
 G_NewFamily2 = GVarName( "NewFamily2" );
 G_NewFamily3 = GVarName( "NewFamily3" );
 G_NewFamily4 = GVarName( "NewFamily4" );
 G_NewFamily5 = GVarName( "NewFamily5" );
 G_NEW__TYPE__CACHE__MISS = GVarName( "NEW_TYPE_CACHE_MISS" );
 G_NEW__TYPE__CACHE__HIT = GVarName( "NEW_TYPE_CACHE_HIT" );
 G_POS__DATA__TYPE = GVarName( "POS_DATA_TYPE" );
 G_POS__NUMB__TYPE = GVarName( "POS_NUMB_TYPE" );
 G_NEW__TYPE = GVarName( "NEW_TYPE" );
 G_POS__FIRST__FREE__TYPE = GVarName( "POS_FIRST_FREE_TYPE" );
 G_NewType2 = GVarName( "NewType2" );
 G_NewType3 = GVarName( "NewType3" );
 G_NewType4 = GVarName( "NewType4" );
 G_NewType5 = GVarName( "NewType5" );
 G_Subtype2 = GVarName( "Subtype2" );
 G_Subtype3 = GVarName( "Subtype3" );
 G_SupType2 = GVarName( "SupType2" );
 G_SupType3 = GVarName( "SupType3" );
 G_FlagsType = GVarName( "FlagsType" );
 G_TypeObj = GVarName( "TypeObj" );
 G_DataType = GVarName( "DataType" );
 G_SharedType = GVarName( "SharedType" );
 G_RunImmediateMethods = GVarName( "RunImmediateMethods" );
 G_SetTypeObj = GVarName( "SetTypeObj" );
 G_ChangeTypeObj = GVarName( "ChangeTypeObj" );
 G_ResetFilterObj = GVarName( "ResetFilterObj" );
 
 /* record names used in handlers */
 R_TYPES__LIST__FAM = RNamName( "TYPES_LIST_FAM" );
 R_type__g = RNamName( "type_g" );
 R_NAME = RNamName( "NAME" );
 R_REQ__FLAGS = RNamName( "REQ_FLAGS" );
 R_IMP__FLAGS = RNamName( "IMP_FLAGS" );
 R_TYPES = RNamName( "TYPES" );
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" )
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 3;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 2;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 2;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = -1;
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = -1;
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = -1;
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 6;
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = 6;
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = 2;
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 1;
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 1;
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 4;
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = 2;
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 3;
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 4;
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = 5;
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = -1;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 1;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 4;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 2;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 3;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 4;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 5;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = -1;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 1;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 3;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = -1;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 2;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 3;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = -1;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = 1;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = 1;
 NameFunc[35] = DefaultName;
 NamsFunc[35] = 0;
 NargFunc[35] = 1;
 NameFunc[36] = DefaultName;
 NamsFunc[36] = 0;
 NargFunc[36] = 2;
 NameFunc[37] = DefaultName;
 NamsFunc[37] = 0;
 NargFunc[37] = 1;
 NameFunc[38] = DefaultName;
 NamsFunc[38] = 0;
 NargFunc[38] = 1;
 NameFunc[39] = DefaultName;
 NamsFunc[39] = 0;
 NargFunc[39] = 1;
 NameFunc[40] = DefaultName;
 NamsFunc[40] = 0;
 NargFunc[40] = 1;
 NameFunc[41] = DefaultName;
 NamsFunc[41] = 0;
 NargFunc[41] = 2;
 NameFunc[42] = DefaultName;
 NamsFunc[42] = 0;
 NargFunc[42] = 2;
 NameFunc[43] = DefaultName;
 NamsFunc[43] = 0;
 NargFunc[43] = 2;
 NameFunc[44] = DefaultName;
 NamsFunc[44] = 0;
 NargFunc[44] = 2;
 NameFunc[45] = DefaultName;
 NamsFunc[45] = 0;
 NargFunc[45] = 3;
 NameFunc[46] = DefaultName;
 NamsFunc[46] = 0;
 NargFunc[46] = 1;
 NameFunc[47] = DefaultName;
 NamsFunc[47] = 0;
 NargFunc[47] = 3;
 NameFunc[48] = DefaultName;
 NamsFunc[48] = 0;
 NargFunc[48] = 1;
 NameFunc[49] = DefaultName;
 NamsFunc[49] = 0;
 NargFunc[49] = 2;
 
 /* create all the functions defined in this module */
 func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);
 ENVI_FUNC( func1 ) = CurrLVars;
 CHANGED_BAG( CurrLVars );
 CALL_0ARGS( func1 );
 
 /* return success */
 return 0;
 
}

/* 'PostRestore' restore gvars, rnams, functions */
static Int PostRestore ( StructInitInfo * module )
{
 
 /* global variables used in handlers */
 G_REREADING = GVarName( "REREADING" );
 G_SHALLOW__COPY__OBJ = GVarName( "SHALLOW_COPY_OBJ" );
 G_PRINT__OBJ = GVarName( "PRINT_OBJ" );
 G_CALL__FUNC__LIST = GVarName( "CALL_FUNC_LIST" );
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 G_IS__REC = GVarName( "IS_REC" );
 G_IS__LIST = GVarName( "IS_LIST" );
 G_ADD__LIST = GVarName( "ADD_LIST" );
 G_IS__PLIST__REP = GVarName( "IS_PLIST_REP" );
 G_IS__BLIST = GVarName( "IS_BLIST" );
 G_IS__RANGE = GVarName( "IS_RANGE" );
 G_IS__STRING__REP = GVarName( "IS_STRING_REP" );
 G_TYPE__OBJ = GVarName( "TYPE_OBJ" );
 G_FAMILY__OBJ = GVarName( "FAMILY_OBJ" );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 G_IS__COMOBJ = GVarName( "IS_COMOBJ" );
 G_SET__TYPE__COMOBJ = GVarName( "SET_TYPE_COMOBJ" );
 G_IS__POSOBJ = GVarName( "IS_POSOBJ" );
 G_SET__TYPE__POSOBJ = GVarName( "SET_TYPE_POSOBJ" );
 G_LEN__POSOBJ = GVarName( "LEN_POSOBJ" );
 G_IS__DATOBJ = GVarName( "IS_DATOBJ" );
 G_SET__TYPE__DATOBJ = GVarName( "SET_TYPE_DATOBJ" );
 G_IS__OBJECT = GVarName( "IS_OBJECT" );
 G_AND__FLAGS = GVarName( "AND_FLAGS" );
 G_SUB__FLAGS = GVarName( "SUB_FLAGS" );
 G_HASH__FLAGS = GVarName( "HASH_FLAGS" );
 G_IS__EQUAL__FLAGS = GVarName( "IS_EQUAL_FLAGS" );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 G_TRUES__FLAGS = GVarName( "TRUES_FLAGS" );
 G_FLAG1__FILTER = GVarName( "FLAG1_FILTER" );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 G_NEW__FILTER = GVarName( "NEW_FILTER" );
 G_SETTER__FUNCTION = GVarName( "SETTER_FUNCTION" );
 G_GETTER__FUNCTION = GVarName( "GETTER_FUNCTION" );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 G_SET__FILTER__LIST = GVarName( "SET_FILTER_LIST" );
 G_RESET__FILTER__LIST = GVarName( "RESET_FILTER_LIST" );
 G_APPEND__LIST__INTR = GVarName( "APPEND_LIST_INTR" );
 G_ADD__SET = GVarName( "ADD_SET" );
 G_CONV__STRING = GVarName( "CONV_STRING" );
 G_Print = GVarName( "Print" );
 G_Revision = GVarName( "Revision" );
 G_Error = GVarName( "Error" );
 G_TNUM__OBJ = GVarName( "TNUM_OBJ" );
 G_BIND__GLOBAL = GVarName( "BIND_GLOBAL" );
 G_NEW__TYPE__NEXT__ID = GVarName( "NEW_TYPE_NEXT_ID" );
 G_CATS__AND__REPS = GVarName( "CATS_AND_REPS" );
 G_FILTERS = GVarName( "FILTERS" );
 G_INFO__FILTERS = GVarName( "INFO_FILTERS" );
 G_RANK__FILTERS = GVarName( "RANK_FILTERS" );
 G_InstallTrueMethod = GVarName( "InstallTrueMethod" );
 G_InstallTrueMethodNewFilter = GVarName( "InstallTrueMethodNewFilter" );
 G_NewCategory = GVarName( "NewCategory" );
 G_NewRepresentation = GVarName( "NewRepresentation" );
 G_DeclareRepresentation = GVarName( "DeclareRepresentation" );
 G_IsComponentObjectRep = GVarName( "IsComponentObjectRep" );
 G_InstallAttributeFunction = GVarName( "InstallAttributeFunction" );
 G_InstallOtherMethod = GVarName( "InstallOtherMethod" );
 G_IsAttributeStoringRep = GVarName( "IsAttributeStoringRep" );
 G_SUM__FLAGS = GVarName( "SUM_FLAGS" );
 G_SetFilterObj = GVarName( "SetFilterObj" );
 G_DeclareCategory = GVarName( "DeclareCategory" );
 G_IsFamily = GVarName( "IsFamily" );
 G_IsPositionalObjectRep = GVarName( "IsPositionalObjectRep" );
 G_IsType = GVarName( "IsType" );
 G_FamilyOfFamilies = GVarName( "FamilyOfFamilies" );
 G_WITH__IMPS__FLAGS = GVarName( "WITH_IMPS_FLAGS" );
 G_IsFamilyDefaultRep = GVarName( "IsFamilyDefaultRep" );
 G_EMPTY__FLAGS = GVarName( "EMPTY_FLAGS" );
 G_IsFamilyOfFamilies = GVarName( "IsFamilyOfFamilies" );
 G_FamilyOfTypes = GVarName( "FamilyOfTypes" );
 G_IsTypeDefaultRep = GVarName( "IsTypeDefaultRep" );
 G_TypeOfFamilyOfTypes = GVarName( "TypeOfFamilyOfTypes" );
 G_IsFamilyOfTypes = GVarName( "IsFamilyOfTypes" );
 G_TypeOfFamilyOfFamilies = GVarName( "TypeOfFamilyOfFamilies" );
 G_TypeOfFamilies = GVarName( "TypeOfFamilies" );
 G_TypeOfTypes = GVarName( "TypeOfTypes" );
 G_CATEGORIES__FAMILY = GVarName( "CATEGORIES_FAMILY" );
 G_CategoryFamily = GVarName( "CategoryFamily" );
 G_VALUE__GLOBAL = GVarName( "VALUE_GLOBAL" );
 G_Subtype = GVarName( "Subtype" );
 G_NEW__FAMILY = GVarName( "NEW_FAMILY" );
 G_NewFamily2 = GVarName( "NewFamily2" );
 G_NewFamily3 = GVarName( "NewFamily3" );
 G_NewFamily4 = GVarName( "NewFamily4" );
 G_NewFamily5 = GVarName( "NewFamily5" );
 G_NEW__TYPE__CACHE__MISS = GVarName( "NEW_TYPE_CACHE_MISS" );
 G_NEW__TYPE__CACHE__HIT = GVarName( "NEW_TYPE_CACHE_HIT" );
 G_POS__DATA__TYPE = GVarName( "POS_DATA_TYPE" );
 G_POS__NUMB__TYPE = GVarName( "POS_NUMB_TYPE" );
 G_NEW__TYPE = GVarName( "NEW_TYPE" );
 G_POS__FIRST__FREE__TYPE = GVarName( "POS_FIRST_FREE_TYPE" );
 G_NewType2 = GVarName( "NewType2" );
 G_NewType3 = GVarName( "NewType3" );
 G_NewType4 = GVarName( "NewType4" );
 G_NewType5 = GVarName( "NewType5" );
 G_Subtype2 = GVarName( "Subtype2" );
 G_Subtype3 = GVarName( "Subtype3" );
 G_SupType2 = GVarName( "SupType2" );
 G_SupType3 = GVarName( "SupType3" );
 G_FlagsType = GVarName( "FlagsType" );
 G_TypeObj = GVarName( "TypeObj" );
 G_DataType = GVarName( "DataType" );
 G_SharedType = GVarName( "SharedType" );
 G_RunImmediateMethods = GVarName( "RunImmediateMethods" );
 G_SetTypeObj = GVarName( "SetTypeObj" );
 G_ChangeTypeObj = GVarName( "ChangeTypeObj" );
 G_ResetFilterObj = GVarName( "ResetFilterObj" );
 
 /* record names used in handlers */
 R_TYPES__LIST__FAM = RNamName( "TYPES_LIST_FAM" );
 R_type__g = RNamName( "type_g" );
 R_NAME = RNamName( "NAME" );
 R_REQ__FLAGS = RNamName( "REQ_FLAGS" );
 R_IMP__FLAGS = RNamName( "IMP_FLAGS" );
 R_TYPES = RNamName( "TYPES" );
 
 /* information for the functions */
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 3;
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 2;
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = 2;
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = -1;
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = -1;
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = -1;
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 6;
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = 6;
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = 2;
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 1;
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 1;
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 4;
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = 2;
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = 3;
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 4;
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = 5;
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = -1;
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 1;
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 4;
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 2;
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = 3;
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 4;
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 5;
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = -1;
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = 1;
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 3;
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = -1;
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 2;
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 3;
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = -1;
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = 1;
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = 1;
 NameFunc[35] = DefaultName;
 NamsFunc[35] = 0;
 NargFunc[35] = 1;
 NameFunc[36] = DefaultName;
 NamsFunc[36] = 0;
 NargFunc[36] = 2;
 NameFunc[37] = DefaultName;
 NamsFunc[37] = 0;
 NargFunc[37] = 1;
 NameFunc[38] = DefaultName;
 NamsFunc[38] = 0;
 NargFunc[38] = 1;
 NameFunc[39] = DefaultName;
 NamsFunc[39] = 0;
 NargFunc[39] = 1;
 NameFunc[40] = DefaultName;
 NamsFunc[40] = 0;
 NargFunc[40] = 1;
 NameFunc[41] = DefaultName;
 NamsFunc[41] = 0;
 NargFunc[41] = 2;
 NameFunc[42] = DefaultName;
 NamsFunc[42] = 0;
 NargFunc[42] = 2;
 NameFunc[43] = DefaultName;
 NamsFunc[43] = 0;
 NargFunc[43] = 2;
 NameFunc[44] = DefaultName;
 NamsFunc[44] = 0;
 NargFunc[44] = 2;
 NameFunc[45] = DefaultName;
 NamsFunc[45] = 0;
 NargFunc[45] = 3;
 NameFunc[46] = DefaultName;
 NamsFunc[46] = 0;
 NargFunc[46] = 1;
 NameFunc[47] = DefaultName;
 NamsFunc[47] = 0;
 NargFunc[47] = 3;
 NameFunc[48] = DefaultName;
 NamsFunc[48] = 0;
 NargFunc[48] = 1;
 NameFunc[49] = DefaultName;
 NamsFunc[49] = 0;
 NargFunc[49] = 2;
 
 /* return success */
 return 0;
 
}


/* <name> returns the description of this module */
static StructInitInfo module = {
 /* type        = */ 2,
 /* name        = */ "GAPROOT/lib/type.g",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 131998840,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ PostRestore
};

StructInitInfo * Init__type ( void )
{
 return &module;
}

#endif

/* compiled code ends here */
