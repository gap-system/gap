#ifdef USE_PRECOMPILED

/* C file produced by GAC */
#include "compiled.h"

/* global variables used in handlers */
static GVar G_TYPE__OBJ;
static Obj  GC_TYPE__OBJ;
static Obj  GF_TYPE__OBJ;
static GVar G_FAMILY__OBJ;
static Obj  GC_FAMILY__OBJ;
static GVar G_SHALLOW__COPY__OBJ;
static Obj  GF_SHALLOW__COPY__OBJ;
static GVar G_PRINT__OBJ;
static Obj  GC_PRINT__OBJ;
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
static GVar G_TNUM__OBJ;
static Obj  GF_TNUM__OBJ;
static GVar G_NAME__FUNC;
static Obj  GF_NAME__FUNC;
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
static GVar G_IS__OBJECT;
static Obj  GC_IS__OBJECT;
static GVar G_SET__FILTER__OBJ;
static GVar G_RESET__FILTER__OBJ;
static GVar G_IS__REC;
static Obj  GF_IS__REC;
static GVar G_IS__LIST;
static Obj  GF_IS__LIST;
static GVar G_LEN__LIST;
static Obj  GF_LEN__LIST;
static GVar G_ADD__LIST;
static Obj  GF_ADD__LIST;
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
static GVar G_POS__DATA__TYPE;
static Obj  GC_POS__DATA__TYPE;
static GVar G_POS__NUMB__TYPE;
static Obj  GC_POS__NUMB__TYPE;
static GVar G_POS__FIRST__FREE__TYPE;
static Obj  GC_POS__FIRST__FREE__TYPE;
static GVar G_NEW__TYPE__NEXT__ID;
static Obj  GC_NEW__TYPE__NEXT__ID;
static GVar G_NewCategoryKernel;
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
static GVar G_NewCategory;
static Obj  GF_NewCategory;
static GVar G_InstallTrueMethodNewFilter;
static Obj  GF_InstallTrueMethodNewFilter;
static GVar G_NewRepresentationKernel;
static GVar G_NewRepresentation;
static Obj  GF_NewRepresentation;
static GVar G_IsInternalRep;
static GVar G_IsPositionalObjectRep;
static Obj  GC_IsPositionalObjectRep;
static GVar G_IsComponentObjectRep;
static Obj  GC_IsComponentObjectRep;
static GVar G_IsDataObjectRep;
static GVar G_IsAttributeStoringRep;
static Obj  GC_IsAttributeStoringRep;
static GVar G_InstallAttributeFunction;
static Obj  GF_InstallAttributeFunction;
static GVar G_InstallOtherMethod;
static Obj  GF_InstallOtherMethod;
static GVar G_SUM__FLAGS;
static Obj  GC_SUM__FLAGS;
static GVar G_SetFilterObj;
static Obj  GC_SetFilterObj;
static Obj  GF_SetFilterObj;
static GVar G_EMPTY__FLAGS;
static Obj  GC_EMPTY__FLAGS;
static GVar G_IsFamily;
static Obj  GC_IsFamily;
static Obj  GF_IsFamily;
static GVar G_IsType;
static Obj  GC_IsType;
static Obj  GF_IsType;
static GVar G_IsFamilyOfFamilies;
static Obj  GC_IsFamilyOfFamilies;
static GVar G_IsFamilyOfTypes;
static Obj  GC_IsFamilyOfTypes;
static GVar G_IsFamilyDefaultRep;
static Obj  GC_IsFamilyDefaultRep;
static GVar G_IsTypeDefaultRep;
static Obj  GC_IsTypeDefaultRep;
static GVar G_FamilyOfFamilies;
static Obj  GC_FamilyOfFamilies;
static GVar G_TypeOfFamilies;
static Obj  GC_TypeOfFamilies;
static GVar G_WITH__IMPS__FLAGS;
static Obj  GF_WITH__IMPS__FLAGS;
static GVar G_TypeOfFamilyOfFamilies;
static Obj  GC_TypeOfFamilyOfFamilies;
static GVar G_FamilyOfTypes;
static Obj  GC_FamilyOfTypes;
static GVar G_TypeOfTypes;
static Obj  GC_TypeOfTypes;
static GVar G_TypeOfFamilyOfTypes;
static Obj  GC_TypeOfFamilyOfTypes;
static GVar G_CATEGORIES__FAMILY;
static Obj  GC_CATEGORIES__FAMILY;
static GVar G_CategoryFamily;
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
static GVar G_NewFamily;
static GVar G_NEW__TYPE__CACHE__MISS;
static Obj  GC_NEW__TYPE__CACHE__MISS;
static GVar G_NEW__TYPE__CACHE__HIT;
static Obj  GC_NEW__TYPE__CACHE__HIT;
static GVar G_NEW__TYPE;
static Obj  GF_NEW__TYPE;
static GVar G_NewType2;
static Obj  GF_NewType2;
static GVar G_NewType3;
static Obj  GF_NewType3;
static GVar G_NewType4;
static Obj  GF_NewType4;
static GVar G_NewType5;
static Obj  GF_NewType5;
static GVar G_NewType;
static GVar G_Subtype2;
static Obj  GF_Subtype2;
static GVar G_Subtype3;
static Obj  GF_Subtype3;
static GVar G_SupType2;
static Obj  GF_SupType2;
static GVar G_SupType3;
static Obj  GF_SupType3;
static GVar G_SupType;
static GVar G_FamilyType;
static GVar G_FlagsType;
static Obj  GF_FlagsType;
static GVar G_DataType;
static Obj  GF_DataType;
static GVar G_SetDataType;
static GVar G_SharedType;
static Obj  GF_SharedType;
static GVar G_TypeObj;
static Obj  GF_TypeObj;
static GVar G_FamilyObj;
static GVar G_FlagsObj;
static GVar G_DataObj;
static GVar G_SharedObj;
static GVar G_SetTypeObj;
static Obj  GC_SetTypeObj;
static GVar G_RunImmediateMethods;
static Obj  GF_RunImmediateMethods;
static GVar G_Objectify;
static GVar G_ChangeTypeObj;
static Obj  GC_ChangeTypeObj;
static GVar G_ReObjectify;
static GVar G_ResetFilterObj;
static Obj  GC_ResetFilterObj;
static Obj  GF_ResetFilterObj;
static GVar G_SetFeatureObj;
static GVar G_InstallMethodsFunction2;
static GVar G_RunMethodsFunction2;

/* record names used in handlers */
static RNam R_TYPES__LIST__FAM;
static RNam R_type__g;
static RNam R_NAME;
static RNam R_REQ__FLAGS;
static RNam R_IMP__FLAGS;
static RNam R_TYPES;

/* information for the functions */
static Obj  NameFunc[47];
static Obj  NamsFunc[47];
static Int  NargFunc[47];
static Obj  DefaultName;

/* 'Link' links this module to GAP */
static void Link ( void )
{
 
 /* global variables used in handlers */
 G_TYPE__OBJ = GVarName( "TYPE_OBJ" );
 InitCopyGVar( G_TYPE__OBJ, &GC_TYPE__OBJ );
 InitFopyGVar( G_TYPE__OBJ, &GF_TYPE__OBJ );
 G_FAMILY__OBJ = GVarName( "FAMILY_OBJ" );
 InitCopyGVar( G_FAMILY__OBJ, &GC_FAMILY__OBJ );
 G_SHALLOW__COPY__OBJ = GVarName( "SHALLOW_COPY_OBJ" );
 InitFopyGVar( G_SHALLOW__COPY__OBJ, &GF_SHALLOW__COPY__OBJ );
 G_PRINT__OBJ = GVarName( "PRINT_OBJ" );
 InitCopyGVar( G_PRINT__OBJ, &GC_PRINT__OBJ );
 G_IS__IDENTICAL__OBJ = GVarName( "IS_IDENTICAL_OBJ" );
 InitFopyGVar( G_IS__IDENTICAL__OBJ, &GF_IS__IDENTICAL__OBJ );
 G_IS__COMOBJ = GVarName( "IS_COMOBJ" );
 InitFopyGVar( G_IS__COMOBJ, &GF_IS__COMOBJ );
 G_SET__TYPE__COMOBJ = GVarName( "SET_TYPE_COMOBJ" );
 InitFopyGVar( G_SET__TYPE__COMOBJ, &GF_SET__TYPE__COMOBJ );
 G_IS__POSOBJ = GVarName( "IS_POSOBJ" );
 InitFopyGVar( G_IS__POSOBJ, &GF_IS__POSOBJ );
 G_SET__TYPE__POSOBJ = GVarName( "SET_TYPE_POSOBJ" );
 InitFopyGVar( G_SET__TYPE__POSOBJ, &GF_SET__TYPE__POSOBJ );
 G_LEN__POSOBJ = GVarName( "LEN_POSOBJ" );
 InitFopyGVar( G_LEN__POSOBJ, &GF_LEN__POSOBJ );
 G_IS__DATOBJ = GVarName( "IS_DATOBJ" );
 InitFopyGVar( G_IS__DATOBJ, &GF_IS__DATOBJ );
 G_SET__TYPE__DATOBJ = GVarName( "SET_TYPE_DATOBJ" );
 InitFopyGVar( G_SET__TYPE__DATOBJ, &GF_SET__TYPE__DATOBJ );
 G_TNUM__OBJ = GVarName( "TNUM_OBJ" );
 InitFopyGVar( G_TNUM__OBJ, &GF_TNUM__OBJ );
 G_NAME__FUNC = GVarName( "NAME_FUNC" );
 InitFopyGVar( G_NAME__FUNC, &GF_NAME__FUNC );
 G_AND__FLAGS = GVarName( "AND_FLAGS" );
 InitFopyGVar( G_AND__FLAGS, &GF_AND__FLAGS );
 G_SUB__FLAGS = GVarName( "SUB_FLAGS" );
 InitFopyGVar( G_SUB__FLAGS, &GF_SUB__FLAGS );
 G_HASH__FLAGS = GVarName( "HASH_FLAGS" );
 InitFopyGVar( G_HASH__FLAGS, &GF_HASH__FLAGS );
 G_IS__EQUAL__FLAGS = GVarName( "IS_EQUAL_FLAGS" );
 InitFopyGVar( G_IS__EQUAL__FLAGS, &GF_IS__EQUAL__FLAGS );
 G_IS__SUBSET__FLAGS = GVarName( "IS_SUBSET_FLAGS" );
 InitFopyGVar( G_IS__SUBSET__FLAGS, &GF_IS__SUBSET__FLAGS );
 G_TRUES__FLAGS = GVarName( "TRUES_FLAGS" );
 InitFopyGVar( G_TRUES__FLAGS, &GF_TRUES__FLAGS );
 G_FLAG1__FILTER = GVarName( "FLAG1_FILTER" );
 InitFopyGVar( G_FLAG1__FILTER, &GF_FLAG1__FILTER );
 G_FLAGS__FILTER = GVarName( "FLAGS_FILTER" );
 InitFopyGVar( G_FLAGS__FILTER, &GF_FLAGS__FILTER );
 G_NEW__FILTER = GVarName( "NEW_FILTER" );
 InitFopyGVar( G_NEW__FILTER, &GF_NEW__FILTER );
 G_SETTER__FUNCTION = GVarName( "SETTER_FUNCTION" );
 InitFopyGVar( G_SETTER__FUNCTION, &GF_SETTER__FUNCTION );
 G_GETTER__FUNCTION = GVarName( "GETTER_FUNCTION" );
 InitFopyGVar( G_GETTER__FUNCTION, &GF_GETTER__FUNCTION );
 G_IS__OBJECT = GVarName( "IS_OBJECT" );
 InitCopyGVar( G_IS__OBJECT, &GC_IS__OBJECT );
 G_SET__FILTER__OBJ = GVarName( "SET_FILTER_OBJ" );
 G_RESET__FILTER__OBJ = GVarName( "RESET_FILTER_OBJ" );
 G_IS__REC = GVarName( "IS_REC" );
 InitFopyGVar( G_IS__REC, &GF_IS__REC );
 G_IS__LIST = GVarName( "IS_LIST" );
 InitFopyGVar( G_IS__LIST, &GF_IS__LIST );
 G_LEN__LIST = GVarName( "LEN_LIST" );
 InitFopyGVar( G_LEN__LIST, &GF_LEN__LIST );
 G_ADD__LIST = GVarName( "ADD_LIST" );
 InitFopyGVar( G_ADD__LIST, &GF_ADD__LIST );
 G_APPEND__LIST__INTR = GVarName( "APPEND_LIST_INTR" );
 InitFopyGVar( G_APPEND__LIST__INTR, &GF_APPEND__LIST__INTR );
 G_ADD__SET = GVarName( "ADD_SET" );
 InitFopyGVar( G_ADD__SET, &GF_ADD__SET );
 G_CONV__STRING = GVarName( "CONV_STRING" );
 InitFopyGVar( G_CONV__STRING, &GF_CONV__STRING );
 G_Print = GVarName( "Print" );
 InitFopyGVar( G_Print, &GF_Print );
 G_Revision = GVarName( "Revision" );
 InitCopyGVar( G_Revision, &GC_Revision );
 G_Error = GVarName( "Error" );
 InitFopyGVar( G_Error, &GF_Error );
 G_POS__DATA__TYPE = GVarName( "POS_DATA_TYPE" );
 InitCopyGVar( G_POS__DATA__TYPE, &GC_POS__DATA__TYPE );
 G_POS__NUMB__TYPE = GVarName( "POS_NUMB_TYPE" );
 InitCopyGVar( G_POS__NUMB__TYPE, &GC_POS__NUMB__TYPE );
 G_POS__FIRST__FREE__TYPE = GVarName( "POS_FIRST_FREE_TYPE" );
 InitCopyGVar( G_POS__FIRST__FREE__TYPE, &GC_POS__FIRST__FREE__TYPE );
 G_NEW__TYPE__NEXT__ID = GVarName( "NEW_TYPE_NEXT_ID" );
 InitCopyGVar( G_NEW__TYPE__NEXT__ID, &GC_NEW__TYPE__NEXT__ID );
 G_NewCategoryKernel = GVarName( "NewCategoryKernel" );
 G_CATS__AND__REPS = GVarName( "CATS_AND_REPS" );
 InitCopyGVar( G_CATS__AND__REPS, &GC_CATS__AND__REPS );
 G_FILTERS = GVarName( "FILTERS" );
 InitCopyGVar( G_FILTERS, &GC_FILTERS );
 G_INFO__FILTERS = GVarName( "INFO_FILTERS" );
 InitCopyGVar( G_INFO__FILTERS, &GC_INFO__FILTERS );
 G_RANK__FILTERS = GVarName( "RANK_FILTERS" );
 InitCopyGVar( G_RANK__FILTERS, &GC_RANK__FILTERS );
 G_InstallTrueMethod = GVarName( "InstallTrueMethod" );
 InitFopyGVar( G_InstallTrueMethod, &GF_InstallTrueMethod );
 G_NewCategory = GVarName( "NewCategory" );
 InitFopyGVar( G_NewCategory, &GF_NewCategory );
 G_InstallTrueMethodNewFilter = GVarName( "InstallTrueMethodNewFilter" );
 InitFopyGVar( G_InstallTrueMethodNewFilter, &GF_InstallTrueMethodNewFilter );
 G_NewRepresentationKernel = GVarName( "NewRepresentationKernel" );
 G_NewRepresentation = GVarName( "NewRepresentation" );
 InitFopyGVar( G_NewRepresentation, &GF_NewRepresentation );
 G_IsInternalRep = GVarName( "IsInternalRep" );
 G_IsPositionalObjectRep = GVarName( "IsPositionalObjectRep" );
 InitCopyGVar( G_IsPositionalObjectRep, &GC_IsPositionalObjectRep );
 G_IsComponentObjectRep = GVarName( "IsComponentObjectRep" );
 InitCopyGVar( G_IsComponentObjectRep, &GC_IsComponentObjectRep );
 G_IsDataObjectRep = GVarName( "IsDataObjectRep" );
 G_IsAttributeStoringRep = GVarName( "IsAttributeStoringRep" );
 InitCopyGVar( G_IsAttributeStoringRep, &GC_IsAttributeStoringRep );
 G_InstallAttributeFunction = GVarName( "InstallAttributeFunction" );
 InitFopyGVar( G_InstallAttributeFunction, &GF_InstallAttributeFunction );
 G_InstallOtherMethod = GVarName( "InstallOtherMethod" );
 InitFopyGVar( G_InstallOtherMethod, &GF_InstallOtherMethod );
 G_SUM__FLAGS = GVarName( "SUM_FLAGS" );
 InitCopyGVar( G_SUM__FLAGS, &GC_SUM__FLAGS );
 G_SetFilterObj = GVarName( "SetFilterObj" );
 InitCopyGVar( G_SetFilterObj, &GC_SetFilterObj );
 InitFopyGVar( G_SetFilterObj, &GF_SetFilterObj );
 G_EMPTY__FLAGS = GVarName( "EMPTY_FLAGS" );
 InitCopyGVar( G_EMPTY__FLAGS, &GC_EMPTY__FLAGS );
 G_IsFamily = GVarName( "IsFamily" );
 InitCopyGVar( G_IsFamily, &GC_IsFamily );
 InitFopyGVar( G_IsFamily, &GF_IsFamily );
 G_IsType = GVarName( "IsType" );
 InitCopyGVar( G_IsType, &GC_IsType );
 InitFopyGVar( G_IsType, &GF_IsType );
 G_IsFamilyOfFamilies = GVarName( "IsFamilyOfFamilies" );
 InitCopyGVar( G_IsFamilyOfFamilies, &GC_IsFamilyOfFamilies );
 G_IsFamilyOfTypes = GVarName( "IsFamilyOfTypes" );
 InitCopyGVar( G_IsFamilyOfTypes, &GC_IsFamilyOfTypes );
 G_IsFamilyDefaultRep = GVarName( "IsFamilyDefaultRep" );
 InitCopyGVar( G_IsFamilyDefaultRep, &GC_IsFamilyDefaultRep );
 G_IsTypeDefaultRep = GVarName( "IsTypeDefaultRep" );
 InitCopyGVar( G_IsTypeDefaultRep, &GC_IsTypeDefaultRep );
 G_FamilyOfFamilies = GVarName( "FamilyOfFamilies" );
 InitCopyGVar( G_FamilyOfFamilies, &GC_FamilyOfFamilies );
 G_TypeOfFamilies = GVarName( "TypeOfFamilies" );
 InitCopyGVar( G_TypeOfFamilies, &GC_TypeOfFamilies );
 G_WITH__IMPS__FLAGS = GVarName( "WITH_IMPS_FLAGS" );
 InitFopyGVar( G_WITH__IMPS__FLAGS, &GF_WITH__IMPS__FLAGS );
 G_TypeOfFamilyOfFamilies = GVarName( "TypeOfFamilyOfFamilies" );
 InitCopyGVar( G_TypeOfFamilyOfFamilies, &GC_TypeOfFamilyOfFamilies );
 G_FamilyOfTypes = GVarName( "FamilyOfTypes" );
 InitCopyGVar( G_FamilyOfTypes, &GC_FamilyOfTypes );
 G_TypeOfTypes = GVarName( "TypeOfTypes" );
 InitCopyGVar( G_TypeOfTypes, &GC_TypeOfTypes );
 G_TypeOfFamilyOfTypes = GVarName( "TypeOfFamilyOfTypes" );
 InitCopyGVar( G_TypeOfFamilyOfTypes, &GC_TypeOfFamilyOfTypes );
 G_CATEGORIES__FAMILY = GVarName( "CATEGORIES_FAMILY" );
 InitCopyGVar( G_CATEGORIES__FAMILY, &GC_CATEGORIES__FAMILY );
 G_CategoryFamily = GVarName( "CategoryFamily" );
 G_Subtype = GVarName( "Subtype" );
 InitFopyGVar( G_Subtype, &GF_Subtype );
 G_NEW__FAMILY = GVarName( "NEW_FAMILY" );
 InitFopyGVar( G_NEW__FAMILY, &GF_NEW__FAMILY );
 G_NewFamily2 = GVarName( "NewFamily2" );
 InitFopyGVar( G_NewFamily2, &GF_NewFamily2 );
 G_NewFamily3 = GVarName( "NewFamily3" );
 InitFopyGVar( G_NewFamily3, &GF_NewFamily3 );
 G_NewFamily4 = GVarName( "NewFamily4" );
 InitFopyGVar( G_NewFamily4, &GF_NewFamily4 );
 G_NewFamily5 = GVarName( "NewFamily5" );
 InitFopyGVar( G_NewFamily5, &GF_NewFamily5 );
 G_NewFamily = GVarName( "NewFamily" );
 G_NEW__TYPE__CACHE__MISS = GVarName( "NEW_TYPE_CACHE_MISS" );
 InitCopyGVar( G_NEW__TYPE__CACHE__MISS, &GC_NEW__TYPE__CACHE__MISS );
 G_NEW__TYPE__CACHE__HIT = GVarName( "NEW_TYPE_CACHE_HIT" );
 InitCopyGVar( G_NEW__TYPE__CACHE__HIT, &GC_NEW__TYPE__CACHE__HIT );
 G_NEW__TYPE = GVarName( "NEW_TYPE" );
 InitFopyGVar( G_NEW__TYPE, &GF_NEW__TYPE );
 G_NewType2 = GVarName( "NewType2" );
 InitFopyGVar( G_NewType2, &GF_NewType2 );
 G_NewType3 = GVarName( "NewType3" );
 InitFopyGVar( G_NewType3, &GF_NewType3 );
 G_NewType4 = GVarName( "NewType4" );
 InitFopyGVar( G_NewType4, &GF_NewType4 );
 G_NewType5 = GVarName( "NewType5" );
 InitFopyGVar( G_NewType5, &GF_NewType5 );
 G_NewType = GVarName( "NewType" );
 G_Subtype2 = GVarName( "Subtype2" );
 InitFopyGVar( G_Subtype2, &GF_Subtype2 );
 G_Subtype3 = GVarName( "Subtype3" );
 InitFopyGVar( G_Subtype3, &GF_Subtype3 );
 G_SupType2 = GVarName( "SupType2" );
 InitFopyGVar( G_SupType2, &GF_SupType2 );
 G_SupType3 = GVarName( "SupType3" );
 InitFopyGVar( G_SupType3, &GF_SupType3 );
 G_SupType = GVarName( "SupType" );
 G_FamilyType = GVarName( "FamilyType" );
 G_FlagsType = GVarName( "FlagsType" );
 InitFopyGVar( G_FlagsType, &GF_FlagsType );
 G_DataType = GVarName( "DataType" );
 InitFopyGVar( G_DataType, &GF_DataType );
 G_SetDataType = GVarName( "SetDataType" );
 G_SharedType = GVarName( "SharedType" );
 InitFopyGVar( G_SharedType, &GF_SharedType );
 G_TypeObj = GVarName( "TypeObj" );
 InitFopyGVar( G_TypeObj, &GF_TypeObj );
 G_FamilyObj = GVarName( "FamilyObj" );
 G_FlagsObj = GVarName( "FlagsObj" );
 G_DataObj = GVarName( "DataObj" );
 G_SharedObj = GVarName( "SharedObj" );
 G_SetTypeObj = GVarName( "SetTypeObj" );
 InitCopyGVar( G_SetTypeObj, &GC_SetTypeObj );
 G_RunImmediateMethods = GVarName( "RunImmediateMethods" );
 InitFopyGVar( G_RunImmediateMethods, &GF_RunImmediateMethods );
 G_Objectify = GVarName( "Objectify" );
 G_ChangeTypeObj = GVarName( "ChangeTypeObj" );
 InitCopyGVar( G_ChangeTypeObj, &GC_ChangeTypeObj );
 G_ReObjectify = GVarName( "ReObjectify" );
 G_ResetFilterObj = GVarName( "ResetFilterObj" );
 InitCopyGVar( G_ResetFilterObj, &GC_ResetFilterObj );
 InitFopyGVar( G_ResetFilterObj, &GF_ResetFilterObj );
 G_SetFeatureObj = GVarName( "SetFeatureObj" );
 G_InstallMethodsFunction2 = GVarName( "InstallMethodsFunction2" );
 G_RunMethodsFunction2 = GVarName( "RunMethodsFunction2" );
 
 /* record names used in handlers */
 R_TYPES__LIST__FAM = RNamName( "TYPES_LIST_FAM" );
 R_type__g = RNamName( "type_g" );
 R_NAME = RNamName( "NAME" );
 R_REQ__FLAGS = RNamName( "REQ_FLAGS" );
 R_IMP__FLAGS = RNamName( "IMP_FLAGS" );
 R_TYPES = RNamName( "TYPES" );
 
 /* information for the functions */
 C_NEW_STRING( DefaultName, 14, "local function" )
 InitGlobalBag( &DefaultName, ": DefaultName (17006909)" );
 InitGlobalBag( &(NameFunc[1]), ": NameFunc[1] (170069090)" );
 NameFunc[1] = DefaultName;
 NamsFunc[1] = 0;
 NargFunc[1] = 0;
 InitGlobalBag( &(NameFunc[2]), ": NameFunc[2] (170069090)" );
 NameFunc[2] = DefaultName;
 NamsFunc[2] = 0;
 NargFunc[2] = 3;
 InitGlobalBag( &(NameFunc[3]), ": NameFunc[3] (170069090)" );
 NameFunc[3] = DefaultName;
 NamsFunc[3] = 0;
 NargFunc[3] = 2;
 InitGlobalBag( &(NameFunc[4]), ": NameFunc[4] (170069090)" );
 NameFunc[4] = DefaultName;
 NamsFunc[4] = 0;
 NargFunc[4] = -1;
 InitGlobalBag( &(NameFunc[5]), ": NameFunc[5] (170069090)" );
 NameFunc[5] = DefaultName;
 NamsFunc[5] = 0;
 NargFunc[5] = -1;
 InitGlobalBag( &(NameFunc[6]), ": NameFunc[6] (170069090)" );
 NameFunc[6] = DefaultName;
 NamsFunc[6] = 0;
 NargFunc[6] = 6;
 InitGlobalBag( &(NameFunc[7]), ": NameFunc[7] (170069090)" );
 NameFunc[7] = DefaultName;
 NamsFunc[7] = 0;
 NargFunc[7] = 6;
 InitGlobalBag( &(NameFunc[8]), ": NameFunc[8] (170069090)" );
 NameFunc[8] = DefaultName;
 NamsFunc[8] = 0;
 NargFunc[8] = 2;
 InitGlobalBag( &(NameFunc[9]), ": NameFunc[9] (170069090)" );
 NameFunc[9] = DefaultName;
 NamsFunc[9] = 0;
 NargFunc[9] = 1;
 InitGlobalBag( &(NameFunc[10]), ": NameFunc[10] (170069090)" );
 NameFunc[10] = DefaultName;
 NamsFunc[10] = 0;
 NargFunc[10] = 4;
 InitGlobalBag( &(NameFunc[11]), ": NameFunc[11] (170069090)" );
 NameFunc[11] = DefaultName;
 NamsFunc[11] = 0;
 NargFunc[11] = 2;
 InitGlobalBag( &(NameFunc[12]), ": NameFunc[12] (170069090)" );
 NameFunc[12] = DefaultName;
 NamsFunc[12] = 0;
 NargFunc[12] = 3;
 InitGlobalBag( &(NameFunc[13]), ": NameFunc[13] (170069090)" );
 NameFunc[13] = DefaultName;
 NamsFunc[13] = 0;
 NargFunc[13] = 4;
 InitGlobalBag( &(NameFunc[14]), ": NameFunc[14] (170069090)" );
 NameFunc[14] = DefaultName;
 NamsFunc[14] = 0;
 NargFunc[14] = 5;
 InitGlobalBag( &(NameFunc[15]), ": NameFunc[15] (170069090)" );
 NameFunc[15] = DefaultName;
 NamsFunc[15] = 0;
 NargFunc[15] = -1;
 InitGlobalBag( &(NameFunc[16]), ": NameFunc[16] (170069090)" );
 NameFunc[16] = DefaultName;
 NamsFunc[16] = 0;
 NargFunc[16] = 1;
 InitGlobalBag( &(NameFunc[17]), ": NameFunc[17] (170069090)" );
 NameFunc[17] = DefaultName;
 NamsFunc[17] = 0;
 NargFunc[17] = 4;
 InitGlobalBag( &(NameFunc[18]), ": NameFunc[18] (170069090)" );
 NameFunc[18] = DefaultName;
 NamsFunc[18] = 0;
 NargFunc[18] = 2;
 InitGlobalBag( &(NameFunc[19]), ": NameFunc[19] (170069090)" );
 NameFunc[19] = DefaultName;
 NamsFunc[19] = 0;
 NargFunc[19] = 3;
 InitGlobalBag( &(NameFunc[20]), ": NameFunc[20] (170069090)" );
 NameFunc[20] = DefaultName;
 NamsFunc[20] = 0;
 NargFunc[20] = 4;
 InitGlobalBag( &(NameFunc[21]), ": NameFunc[21] (170069090)" );
 NameFunc[21] = DefaultName;
 NamsFunc[21] = 0;
 NargFunc[21] = 5;
 InitGlobalBag( &(NameFunc[22]), ": NameFunc[22] (170069090)" );
 NameFunc[22] = DefaultName;
 NamsFunc[22] = 0;
 NargFunc[22] = -1;
 InitGlobalBag( &(NameFunc[23]), ": NameFunc[23] (170069090)" );
 NameFunc[23] = DefaultName;
 NamsFunc[23] = 0;
 NargFunc[23] = 1;
 InitGlobalBag( &(NameFunc[24]), ": NameFunc[24] (170069090)" );
 NameFunc[24] = DefaultName;
 NamsFunc[24] = 0;
 NargFunc[24] = 2;
 InitGlobalBag( &(NameFunc[25]), ": NameFunc[25] (170069090)" );
 NameFunc[25] = DefaultName;
 NamsFunc[25] = 0;
 NargFunc[25] = 3;
 InitGlobalBag( &(NameFunc[26]), ": NameFunc[26] (170069090)" );
 NameFunc[26] = DefaultName;
 NamsFunc[26] = 0;
 NargFunc[26] = -1;
 InitGlobalBag( &(NameFunc[27]), ": NameFunc[27] (170069090)" );
 NameFunc[27] = DefaultName;
 NamsFunc[27] = 0;
 NargFunc[27] = 2;
 InitGlobalBag( &(NameFunc[28]), ": NameFunc[28] (170069090)" );
 NameFunc[28] = DefaultName;
 NamsFunc[28] = 0;
 NargFunc[28] = 3;
 InitGlobalBag( &(NameFunc[29]), ": NameFunc[29] (170069090)" );
 NameFunc[29] = DefaultName;
 NamsFunc[29] = 0;
 NargFunc[29] = -1;
 InitGlobalBag( &(NameFunc[30]), ": NameFunc[30] (170069090)" );
 NameFunc[30] = DefaultName;
 NamsFunc[30] = 0;
 NargFunc[30] = 1;
 InitGlobalBag( &(NameFunc[31]), ": NameFunc[31] (170069090)" );
 NameFunc[31] = DefaultName;
 NamsFunc[31] = 0;
 NargFunc[31] = 1;
 InitGlobalBag( &(NameFunc[32]), ": NameFunc[32] (170069090)" );
 NameFunc[32] = DefaultName;
 NamsFunc[32] = 0;
 NargFunc[32] = 1;
 InitGlobalBag( &(NameFunc[33]), ": NameFunc[33] (170069090)" );
 NameFunc[33] = DefaultName;
 NamsFunc[33] = 0;
 NargFunc[33] = 2;
 InitGlobalBag( &(NameFunc[34]), ": NameFunc[34] (170069090)" );
 NameFunc[34] = DefaultName;
 NamsFunc[34] = 0;
 NargFunc[34] = 1;
 InitGlobalBag( &(NameFunc[35]), ": NameFunc[35] (170069090)" );
 NameFunc[35] = DefaultName;
 NamsFunc[35] = 0;
 NargFunc[35] = 1;
 InitGlobalBag( &(NameFunc[36]), ": NameFunc[36] (170069090)" );
 NameFunc[36] = DefaultName;
 NamsFunc[36] = 0;
 NargFunc[36] = 1;
 InitGlobalBag( &(NameFunc[37]), ": NameFunc[37] (170069090)" );
 NameFunc[37] = DefaultName;
 NamsFunc[37] = 0;
 NargFunc[37] = 1;
 InitGlobalBag( &(NameFunc[38]), ": NameFunc[38] (170069090)" );
 NameFunc[38] = DefaultName;
 NamsFunc[38] = 0;
 NargFunc[38] = 2;
 InitGlobalBag( &(NameFunc[39]), ": NameFunc[39] (170069090)" );
 NameFunc[39] = DefaultName;
 NamsFunc[39] = 0;
 NargFunc[39] = 2;
 InitGlobalBag( &(NameFunc[40]), ": NameFunc[40] (170069090)" );
 NameFunc[40] = DefaultName;
 NamsFunc[40] = 0;
 NargFunc[40] = 2;
 InitGlobalBag( &(NameFunc[41]), ": NameFunc[41] (170069090)" );
 NameFunc[41] = DefaultName;
 NamsFunc[41] = 0;
 NargFunc[41] = 2;
 InitGlobalBag( &(NameFunc[42]), ": NameFunc[42] (170069090)" );
 NameFunc[42] = DefaultName;
 NamsFunc[42] = 0;
 NargFunc[42] = 3;
 InitGlobalBag( &(NameFunc[43]), ": NameFunc[43] (170069090)" );
 NameFunc[43] = DefaultName;
 NamsFunc[43] = 0;
 NargFunc[43] = 1;
 InitGlobalBag( &(NameFunc[44]), ": NameFunc[44] (170069090)" );
 NameFunc[44] = DefaultName;
 NamsFunc[44] = 0;
 NargFunc[44] = 3;
 InitGlobalBag( &(NameFunc[45]), ": NameFunc[45] (170069090)" );
 NameFunc[45] = DefaultName;
 NamsFunc[45] = 0;
 NargFunc[45] = 1;
 InitGlobalBag( &(NameFunc[46]), ": NameFunc[46] (170069090)" );
 NameFunc[46] = DefaultName;
 NamsFunc[46] = 0;
 NargFunc[46] = 2;
 
}


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
 t_3 = CALL_2ARGS( t_4, a_cat, t_5 );
 t_2 = (Obj)(t_3 != False);
 t_1 = (Obj)( ! ((Int)t_2) );
 if ( t_1 ) {
  
  /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) ); */
  t_1 = GF_ADD__LIST;
  t_2 = GC_CATS__AND__REPS;
  t_4 = GF_FLAG1__FILTER;
  t_3 = CALL_1ARGS( t_4, a_cat );
  CALL_2ARGS( t_1, t_2, t_3 );
  
  /* FILTERS[FLAG1_FILTER( cat )] := cat; */
  t_1 = GC_FILTERS;
  t_3 = GF_FLAG1__FILTER;
  t_2 = CALL_1ARGS( t_3, a_cat );
  C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), a_cat )
  
  /* INFO_FILTERS[FLAG1_FILTER( cat )] := 1; */
  t_1 = GC_INFO__FILTERS;
  t_3 = GF_FLAG1__FILTER;
  t_2 = CALL_1ARGS( t_3, a_cat );
  C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
  
  /* RANK_FILTERS[FLAG1_FILTER( cat )] := 1; */
  t_1 = GC_RANK__FILTERS;
  t_3 = GF_FLAG1__FILTER;
  t_2 = CALL_1ARGS( t_3, a_cat );
  C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
  
  /* InstallTrueMethod( super, cat ); */
  t_1 = GF_InstallTrueMethod;
  CALL_2ARGS( t_1, a_super, a_cat );
  
 }
 /* fi */
 
 /* return cat; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return a_cat;
 
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
 l_cat = t_1;
 
 /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATS__AND__REPS;
 t_4 = GF_FLAG1__FILTER;
 t_3 = CALL_1ARGS( t_4, l_cat );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FILTERS[FLAG1_FILTER( cat )] := cat; */
 t_1 = GC_FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_cat );
 C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), l_cat )
 
 /* RANK_FILTERS[FLAG1_FILTER( cat )] := 1; */
 t_1 = GC_RANK__FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_cat );
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
 
 /* INFO_FILTERS[FLAG1_FILTER( cat )] := 2; */
 t_1 = GC_INFO__FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_cat );
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
 Obj  a_arg )
{
 Obj l_rep = 0;
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if LEN_LIST( arg ) = 4 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 t_1 = (Obj)(EQ( t_2, INTOBJ_INT(4) ));
 if ( t_1 ) {
  
  /* rep := arg[4]; */
  C_ELM_LIST_NLE_FPL( t_1, a_arg, 4 );
  l_rep = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 5 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  t_1 = (Obj)(EQ( t_2, INTOBJ_INT(5) ));
  if ( t_1 ) {
   
   /* rep := arg[5]; */
   C_ELM_LIST_NLE_FPL( t_1, a_arg, 5 );
   l_rep = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "usage: NewRepresentation(<name>,<super>,<slots>[,<req>])" ); */
   t_1 = GF_Error;
   C_NEW_STRING( t_2, 56, "usage: NewRepresentation(<name>,<super>,<slots>[,<req>])" )
   CALL_1ARGS( t_1, t_2 );
   
  }
 }
 /* fi */
 
 /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATS__AND__REPS;
 t_4 = GF_FLAG1__FILTER;
 t_3 = CALL_1ARGS( t_4, l_rep );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FILTERS[FLAG1_FILTER( rep )] := rep; */
 t_1 = GC_FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), l_rep )
 
 /* RANK_FILTERS[FLAG1_FILTER( rep )] := 1; */
 t_1 = GC_RANK__FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
 
 /* INFO_FILTERS[FLAG1_FILTER( rep )] := 3; */
 t_1 = GC_INFO__FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(3) )
 
 /* InstallTrueMethod( arg[2], rep ); */
 t_1 = GF_InstallTrueMethod;
 C_ELM_LIST_NLE_FPL( t_2, a_arg, 2 );
 CALL_2ARGS( t_1, t_2, l_rep );
 
 /* return rep; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_rep;
 
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
 Obj t_1 = 0;
 Obj t_2 = 0;
 Obj t_3 = 0;
 Obj t_4 = 0;
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* if LEN_LIST( arg ) = 3 then */
 t_3 = GF_LEN__LIST;
 t_2 = CALL_1ARGS( t_3, a_arg );
 t_1 = (Obj)(EQ( t_2, INTOBJ_INT(3) ));
 if ( t_1 ) {
  
  /* rep := NEW_FILTER( arg[1] ); */
  t_2 = GF_NEW__FILTER;
  C_ELM_LIST_NLE_FPL( t_3, a_arg, 1 );
  t_1 = CALL_1ARGS( t_2, t_3 );
  l_rep = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 4 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  t_1 = (Obj)(EQ( t_2, INTOBJ_INT(4) ));
  if ( t_1 ) {
   
   /* rep := NEW_FILTER( arg[1] ); */
   t_2 = GF_NEW__FILTER;
   C_ELM_LIST_NLE_FPL( t_3, a_arg, 1 );
   t_1 = CALL_1ARGS( t_2, t_3 );
   l_rep = t_1;
   
  }
  
  /* else */
  else {
   
   /* Error( "usage: NewRepresentation(<name>,<super>,<slots>[,<req>])" ); */
   t_1 = GF_Error;
   C_NEW_STRING( t_2, 56, "usage: NewRepresentation(<name>,<super>,<slots>[,<req>])" )
   CALL_1ARGS( t_1, t_2 );
   
  }
 }
 /* fi */
 
 /* ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATS__AND__REPS;
 t_4 = GF_FLAG1__FILTER;
 t_3 = CALL_1ARGS( t_4, l_rep );
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* FILTERS[FLAG1_FILTER( rep )] := rep; */
 t_1 = GC_FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 C_ASS_LIST_FPL( t_1, INT_INTOBJ(t_2), l_rep )
 
 /* RANK_FILTERS[FLAG1_FILTER( rep )] := 1; */
 t_1 = GC_RANK__FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(1) )
 
 /* INFO_FILTERS[FLAG1_FILTER( rep )] := 4; */
 t_1 = GC_INFO__FILTERS;
 t_3 = GF_FLAG1__FILTER;
 t_2 = CALL_1ARGS( t_3, l_rep );
 C_ASS_LIST_FPL_INTOBJ( t_1, INT_INTOBJ(t_2), INTOBJ_INT(4) )
 
 /* InstallTrueMethodNewFilter( arg[2], rep ); */
 t_1 = GF_InstallTrueMethodNewFilter;
 C_ELM_LIST_NLE_FPL( t_2, a_arg, 2 );
 CALL_2ARGS( t_1, t_2, l_rep );
 
 /* return rep; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_rep;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 6 */
static Obj  HdlrFunc6 (
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
 if ( t_6 == False ) {
  t_5 = t_6;
 }
 else if ( t_6 == True ) {
  t_5 = a_tester;
 }
 else {
  t_5 = NewAndFilter( t_6, a_tester );
 }
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 t_6 = GC_SUM__FLAGS;
 C_PROD_FIA( t_5, INTOBJ_INT(2), t_6 )
 t_7 = GF_GETTER__FUNCTION;
 t_6 = CALL_1ARGS( t_7, a_name );
 CALL_6ARGS( t_1, a_getter, t_2, t_3, t_4, t_5, t_6 );
 
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
 if ( TNUM_OBJ(a_obj) == T_COMOBJ ) {
  AssPRec( a_obj, RNamObj(t_1), a_val );
 }
 else {
  ASS_REC( a_obj, RNamObj(t_1), a_val );
 }
 
 /* SetFilterObj( obj, tester ); */
 t_1 = GF_SetFilterObj;
 t_2 = OBJ_LVAR_0UP( 2 );
 CALL_2ARGS( t_1, a_obj, t_2 );
 
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
 t_1 = (Obj)(a_mutflag != False);
 if ( t_1 ) {
  
  /* InstallOtherMethod( setter, "system mutable setter", true, [ IsAttributeStoringRep, IS_OBJECT ], SUM_FLAGS, function ... end ); */
  t_1 = GF_InstallOtherMethod;
  C_NEW_STRING( t_2, 21, "system mutable setter" )
  t_3 = True;
  t_4 = NEW_PLIST( T_PLIST, 2 );
  SET_LEN_PLIST( t_4, 2 );
  t_5 = GC_IsAttributeStoringRep;
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_SUM__FLAGS;
  InitHandlerFunc( HdlrFunc8, ": HdlrFunc8 (170069090)" );
  t_6 = NewFunction( NameFunc[8], NargFunc[8], NamsFunc[8], HdlrFunc8);
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
  SET_ELM_PLIST( t_4, 1, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_IS__OBJECT;
  SET_ELM_PLIST( t_4, 2, t_5 );
  CHANGED_BAG( t_4 );
  t_5 = GC_SUM__FLAGS;
  t_7 = GF_SETTER__FUNCTION;
  t_8 = OBJ_LVAR( 1 );
  t_9 = OBJ_LVAR( 2 );
  t_6 = CALL_2ARGS( t_7, t_8, t_9 );
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

/* handler for function 9 */
static Obj  HdlrFunc9 (
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
 t_2 = CALL_1ARGS( t_3, t_4 );
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
 a_elms__filter = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 if ( IS_LIST(t_4) ) {
  t_3 = (Obj)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)0;
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
  C_ELM_LIST_NLE_FPL( t_6, l_pair, 1 );
  t_5 = (Obj)(EQ( t_6, a_elms__filter ));
  if ( t_5 ) {
   
   /* return pair[2]; */
   C_ELM_LIST_NLE_FPL( t_5, l_pair, 2 );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_5;
   
  }
  /* fi */
  
 }
 /* od */
 
 /* super := IsFamily; */
 t_1 = GC_IsFamily;
 l_super = t_1;
 
 /* flags := WITH_IMPS_FLAGS( elms_filter ); */
 t_2 = GF_WITH__IMPS__FLAGS;
 t_1 = CALL_1ARGS( t_2, a_elms__filter );
 l_flags = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 if ( IS_LIST(t_4) ) {
  t_3 = (Obj)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)0;
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
  C_ELM_LIST_NLE_FPL( t_8, l_pair, 1 );
  t_6 = CALL_2ARGS( t_7, l_flags, t_8 );
  t_5 = (Obj)(t_6 != False);
  if ( t_5 ) {
   
   /* super := super and pair[2]; */
   if ( l_super == False ) {
    t_5 = l_super;
   }
   else if ( l_super == True ) {
    C_ELM_LIST_NLE_FPL( t_6, l_pair, 2 );
    t_5 = t_6;
   }
   else {
    C_ELM_LIST_NLE_FPL( t_7, l_pair, 2 );
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
 l_fam__filter = t_1;
 
 /* ADD_LIST( CATEGORIES_FAMILY, [ elms_filter, fam_filter ] ); */
 t_1 = GF_ADD__LIST;
 t_2 = GC_CATEGORIES__FAMILY;
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

/* handler for function 10 */
static Obj  HdlrFunc10 (
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
 t_1 = CALL_1ARGS( t_2, t_3 );
 a_imp__filter = t_1;
 
 /* type := Subtype( typeOfFamilies, IsAttributeStoringRep ); */
 t_2 = GF_Subtype;
 t_3 = GC_IsAttributeStoringRep;
 t_1 = CALL_2ARGS( t_2, a_typeOfFamilies, t_3 );
 l_type = t_1;
 
 /* for pair in CATEGORIES_FAMILY do */
 t_4 = GC_CATEGORIES__FAMILY;
 if ( IS_LIST(t_4) ) {
  t_3 = (Obj)1;
  t_1 = INTOBJ_INT(1);
 }
 else {
  t_3 = (Obj)0;
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
  C_ELM_LIST_NLE_FPL( t_8, l_pair, 1 );
  t_6 = CALL_2ARGS( t_7, a_imp__filter, t_8 );
  t_5 = (Obj)(t_6 != False);
  if ( t_5 ) {
   
   /* type := Subtype( type, pair[2] ); */
   t_6 = GF_Subtype;
   C_ELM_LIST_NLE_FPL( t_7, l_pair, 2 );
   t_5 = CALL_2ARGS( t_6, l_type, t_7 );
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
 
 /* family!.TYPES_LIST_FAM := [ ,,,,,,,,,,,, false ]; */
 t_1 = NEW_PLIST( T_PLIST, 13 );
 SET_LEN_PLIST( t_1, 13 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 13, t_2 );
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

/* handler for function 11 */
static Obj  HdlrFunc11 (
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
 t_4 = GC_EMPTY__FLAGS;
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 12 */
static Obj  HdlrFunc12 (
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
 t_4 = GC_EMPTY__FLAGS;
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 13 */
static Obj  HdlrFunc13 (
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
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_imp );
 t_1 = CALL_4ARGS( t_2, a_typeOfFamilies, a_name, t_3, t_4 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 14 */
static Obj  HdlrFunc14 (
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
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_req );
 t_6 = GF_FLAGS__FILTER;
 t_5 = CALL_1ARGS( t_6, a_imp );
 t_1 = CALL_4ARGS( t_2, t_3, a_name, t_4, t_5 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 15 */
static Obj  HdlrFunc15 (
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
 t_1 = (Obj)(EQ( t_2, INTOBJ_INT(1) ));
 if ( t_1 ) {
  
  /* return NewFamily2( TypeOfFamilies, arg[1] ); */
  t_2 = GF_NewFamily2;
  t_3 = GC_TypeOfFamilies;
  C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 2 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  t_1 = (Obj)(EQ( t_2, INTOBJ_INT(2) ));
  if ( t_1 ) {
   
   /* return NewFamily3( TypeOfFamilies, arg[1], arg[2] ); */
   t_2 = GF_NewFamily3;
   t_3 = GC_TypeOfFamilies;
   C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
   C_ELM_LIST_NLE_FPL( t_5, a_arg, 2 );
   t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
   SWITCH_TO_OLD_FRAME(oldFrame);
   return t_1;
   
  }
  
  /* elif LEN_LIST( arg ) = 3 then */
  else {
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, a_arg );
   t_1 = (Obj)(EQ( t_2, INTOBJ_INT(3) ));
   if ( t_1 ) {
    
    /* return NewFamily4( TypeOfFamilies, arg[1], arg[2], arg[3] ); */
    t_2 = GF_NewFamily4;
    t_3 = GC_TypeOfFamilies;
    C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
    C_ELM_LIST_NLE_FPL( t_5, a_arg, 2 );
    C_ELM_LIST_NLE_FPL( t_6, a_arg, 3 );
    t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
    SWITCH_TO_OLD_FRAME(oldFrame);
    return t_1;
    
   }
   
   /* elif LEN_LIST( arg ) = 4 then */
   else {
    t_3 = GF_LEN__LIST;
    t_2 = CALL_1ARGS( t_3, a_arg );
    t_1 = (Obj)(EQ( t_2, INTOBJ_INT(4) ));
    if ( t_1 ) {
     
     /* return NewFamily5( TypeOfFamilies, arg[1], arg[2], arg[3], arg[4] ); */
     t_2 = GF_NewFamily5;
     t_3 = GC_TypeOfFamilies;
     C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
     C_ELM_LIST_NLE_FPL( t_5, a_arg, 2 );
     C_ELM_LIST_NLE_FPL( t_6, a_arg, 3 );
     C_ELM_LIST_NLE_FPL( t_7, a_arg, 4 );
     t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, t_7 );
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

/* handler for function 16 */
static Obj  HdlrFunc16 (
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
 t_1 = (Obj)( ! EQ( l_imp__flags, t_2 ));
 if ( t_1 ) {
  
  /* Print( ", ", TRUES_FLAGS( imp_flags ) ); */
  t_1 = GF_Print;
  C_NEW_STRING( t_2, 2, ", " )
  t_4 = GF_TRUES__FLAGS;
  t_3 = CALL_1ARGS( t_4, l_imp__flags );
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

/* handler for function 17 */
static Obj  HdlrFunc17 (
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
 t_2 = MOD( t_3, INTOBJ_INT(3001) );
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
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
 t_2 = (ISB_LIST( l_cache, INT_INTOBJ(l_hash) ) ? True : False);
 t_1 = (Obj)(t_2 != False);
 if ( t_1 ) {
  
  /* cached := cache[hash]; */
  C_ELM_LIST_NLE_FPL( t_1, l_cache, INT_INTOBJ(l_hash) );
  l_cached = t_1;
  
  /* if IS_EQUAL_FLAGS( flags, cached![2] ) then */
  t_3 = GF_IS__EQUAL__FLAGS;
  C_ELM_POSOBJ_NLE( t_4, l_cached, 2 );
  t_2 = CALL_2ARGS( t_3, a_flags, t_4 );
  t_1 = (Obj)(t_2 != False);
  if ( t_1 ) {
   
   /* if IS_IDENTICAL_OBJ( data, cached![POS_DATA_TYPE] ) and IS_IDENTICAL_OBJ( typeOfTypes, TYPE_OBJ( cached ) ) then */
   t_4 = GF_IS__IDENTICAL__OBJ;
   t_6 = GC_POS__DATA__TYPE;
   C_ELM_POSOBJ_NLE( t_5, l_cached, INT_INTOBJ(t_6) );
   t_3 = CALL_2ARGS( t_4, a_data, t_5 );
   t_2 = (Obj)(t_3 != False);
   t_1 = t_2;
   if ( t_1 ) {
    t_5 = GF_IS__IDENTICAL__OBJ;
    t_7 = GF_TYPE__OBJ;
    t_6 = CALL_1ARGS( t_7, l_cached );
    t_4 = CALL_2ARGS( t_5, a_typeOfTypes, t_6 );
    t_3 = (Obj)(t_4 != False);
    t_1 = t_3;
   }
   if ( t_1 ) {
    
    /* NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1; */
    t_2 = GC_NEW__TYPE__CACHE__HIT;
    C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
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
  C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
  AssGVar( G_NEW__TYPE__CACHE__MISS, t_1 );
  
 }
 /* fi */
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* if TNUM_OBJ( NEW_TYPE_NEXT_ID )[1] <> 0 then */
 t_4 = GF_TNUM__OBJ;
 t_5 = GC_NEW__TYPE__NEXT__ID;
 t_3 = CALL_1ARGS( t_4, t_5 );
 C_ELM_LIST_NLE_FPL( t_2, t_3, 1 );
 t_1 = (Obj)( ! EQ( t_2, INTOBJ_INT(0) ));
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
 C_ASS_LIST_FPL( l_type, INT_INTOBJ(t_1), a_data )
 
 /* type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID; */
 t_1 = GC_POS__NUMB__TYPE;
 t_2 = GC_NEW__TYPE__NEXT__ID;
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

/* handler for function 18 */
static Obj  HdlrFunc18 (
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
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 19 */
static Obj  HdlrFunc19 (
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
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 t_3 = CALL_1ARGS( t_4, t_5 );
 t_4 = False;
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, t_4 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 20 */
static Obj  HdlrFunc20 (
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
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 t_3 = CALL_1ARGS( t_4, t_5 );
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, a_data );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 21 */
static Obj  HdlrFunc21 (
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
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 t_3 = CALL_1ARGS( t_4, t_5 );
 t_1 = CALL_4ARGS( t_2, a_typeOfTypes, a_family, t_3, a_data );
 l_type = t_1;
 
 /* type![POS_FIRST_FREE_TYPE] := stuff; */
 t_1 = GC_POS__FIRST__FREE__TYPE;
 C_ASS_POSOBJ( l_type, INT_INTOBJ(t_1), a_stuff )
 
 /* return type; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 22 */
static Obj  HdlrFunc22 (
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
 C_ELM_LIST_NLE_FPL( t_5, a_arg, 1 );
 t_3 = CALL_1ARGS( t_4, t_5 );
 t_2 = (Obj)(t_3 != False);
 t_1 = (Obj)( ! ((Int)t_2) );
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
 t_1 = (Obj)(EQ( t_2, INTOBJ_INT(1) ));
 if ( t_1 ) {
  
  /* type := NewType2( TypeOfTypes, arg[1] ); */
  t_2 = GF_NewType2;
  t_3 = GC_TypeOfTypes;
  C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  l_type = t_1;
  
 }
 
 /* elif LEN_LIST( arg ) = 2 then */
 else {
  t_3 = GF_LEN__LIST;
  t_2 = CALL_1ARGS( t_3, a_arg );
  t_1 = (Obj)(EQ( t_2, INTOBJ_INT(2) ));
  if ( t_1 ) {
   
   /* type := NewType3( TypeOfTypes, arg[1], arg[2] ); */
   t_2 = GF_NewType3;
   t_3 = GC_TypeOfTypes;
   C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
   C_ELM_LIST_NLE_FPL( t_5, a_arg, 2 );
   t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
   l_type = t_1;
   
  }
  
  /* elif LEN_LIST( arg ) = 3 then */
  else {
   t_3 = GF_LEN__LIST;
   t_2 = CALL_1ARGS( t_3, a_arg );
   t_1 = (Obj)(EQ( t_2, INTOBJ_INT(3) ));
   if ( t_1 ) {
    
    /* type := NewType4( TypeOfTypes, arg[1], arg[2], arg[3] ); */
    t_2 = GF_NewType4;
    t_3 = GC_TypeOfTypes;
    C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
    C_ELM_LIST_NLE_FPL( t_5, a_arg, 2 );
    C_ELM_LIST_NLE_FPL( t_6, a_arg, 3 );
    t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
    l_type = t_1;
    
   }
   
   /* elif LEN_LIST( arg ) = 4 then */
   else {
    t_3 = GF_LEN__LIST;
    t_2 = CALL_1ARGS( t_3, a_arg );
    t_1 = (Obj)(EQ( t_2, INTOBJ_INT(4) ));
    if ( t_1 ) {
     
     /* type := NewType5( TypeOfTypes, arg[1], arg[2], arg[3], arg[4] ); */
     t_2 = GF_NewType5;
     t_3 = GC_TypeOfTypes;
     C_ELM_LIST_NLE_FPL( t_4, a_arg, 1 );
     C_ELM_LIST_NLE_FPL( t_5, a_arg, 2 );
     C_ELM_LIST_NLE_FPL( t_6, a_arg, 3 );
     C_ELM_LIST_NLE_FPL( t_7, a_arg, 4 );
     t_1 = CALL_5ARGS( t_2, t_3, t_4, t_5, t_6, t_7 );
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
 SWITCH_TO_OLD_FRAME(oldFrame);
 return l_type;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 23 */
static Obj  HdlrFunc23 (
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
 C_ELM_POSOBJ_NLE( t_1, a_type, INT_INTOBJ(t_2) );
 l_data = t_1;
 
 /* Print( "NewType( ", family ); */
 t_1 = GF_Print;
 C_NEW_STRING( t_2, 9, "NewType( " )
 CALL_2ARGS( t_1, t_2, l_family );
 
 /* if flags <> [  ] or data <> false then */
 t_3 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_3, 0 );
 t_2 = (Obj)( ! EQ( l_flags, t_3 ));
 t_1 = t_2;
 if ( ! t_1 ) {
  t_4 = False;
  t_3 = (Obj)( ! EQ( l_data, t_4 ));
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
  CALL_1ARGS( t_1, t_2 );
  
  /* if data <> false then */
  t_2 = False;
  t_1 = (Obj)( ! EQ( l_data, t_2 ));
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

/* handler for function 24 */
static Obj  HdlrFunc24 (
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
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_WITH__IMPS__FLAGS;
 t_8 = GF_AND__FLAGS;
 C_ELM_POSOBJ_NLE( t_9, a_type, 2 );
 t_11 = GF_FLAGS__FILTER;
 t_10 = CALL_1ARGS( t_11, a_filter );
 t_7 = CALL_2ARGS( t_8, t_9, t_10 );
 t_5 = CALL_1ARGS( t_6, t_7 );
 t_7 = GC_POS__DATA__TYPE;
 C_ELM_POSOBJ_NLE( t_6, a_type, INT_INTOBJ(t_7) );
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(t_5 != False);
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

/* handler for function 25 */
static Obj  HdlrFunc25 (
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
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_WITH__IMPS__FLAGS;
 t_8 = GF_AND__FLAGS;
 C_ELM_POSOBJ_NLE( t_9, a_type, 2 );
 t_11 = GF_FLAGS__FILTER;
 t_10 = CALL_1ARGS( t_11, a_filter );
 t_7 = CALL_2ARGS( t_8, t_9, t_10 );
 t_5 = CALL_1ARGS( t_6, t_7 );
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, a_data );
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(t_5 != False);
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

/* handler for function 26 */
static Obj  HdlrFunc26 (
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
 C_ELM_LIST_NLE_FPL( t_5, a_arg, 1 );
 t_3 = CALL_1ARGS( t_4, t_5 );
 t_2 = (Obj)(t_3 != False);
 t_1 = (Obj)( ! ((Int)t_2) );
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
 t_1 = (Obj)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* return Subtype2( arg[1], arg[2] ); */
  t_2 = GF_Subtype2;
  C_ELM_LIST_NLE_FPL( t_3, a_arg, 1 );
  C_ELM_LIST_NLE_FPL( t_4, a_arg, 2 );
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* return Subtype3( arg[1], arg[2], arg[3] ); */
  t_2 = GF_Subtype3;
  C_ELM_LIST_NLE_FPL( t_3, a_arg, 1 );
  C_ELM_LIST_NLE_FPL( t_4, a_arg, 2 );
  C_ELM_LIST_NLE_FPL( t_5, a_arg, 3 );
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* new := NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), type![POS_DATA_TYPE] ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_SUB__FLAGS;
 C_ELM_POSOBJ_NLE( t_7, a_type, 2 );
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 t_7 = GC_POS__DATA__TYPE;
 C_ELM_POSOBJ_NLE( t_6, a_type, INT_INTOBJ(t_7) );
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(t_5 != False);
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* new := NEW_TYPE( TypeOfTypes, type![1], SUB_FLAGS( type![2], FLAGS_FILTER( filter ) ), data ); */
 t_2 = GF_NEW__TYPE;
 t_3 = GC_TypeOfTypes;
 C_ELM_POSOBJ_NLE( t_4, a_type, 1 );
 t_6 = GF_SUB__FLAGS;
 C_ELM_POSOBJ_NLE( t_7, a_type, 2 );
 t_9 = GF_FLAGS__FILTER;
 t_8 = CALL_1ARGS( t_9, a_filter );
 t_5 = CALL_2ARGS( t_6, t_7, t_8 );
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, a_data );
 l_new = t_1;
 
 /* for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do */
 t_2 = GC_POS__FIRST__FREE__TYPE;
 t_4 = GF_LEN__POSOBJ;
 t_3 = CALL_1ARGS( t_4, a_type );
 for ( t_1 = t_2;
       ((Int)t_1) <= ((Int)t_3);
       t_1 = (Obj)(((UInt)t_1)+4) ) {
  l_i = t_1;
  
  /* if IsBound( type![i]) then */
  if ( TNUM_OBJ(a_type) == T_POSOBJ ) {
   t_5 = (INT_INTOBJ(l_i) <= SIZE_OBJ(a_type)/sizeof(Obj)-1
      && ELM_PLIST(a_type,INT_INTOBJ(l_i)) != 0 ? True : False);
  }
  else {
   t_5 = (ISB_LIST( a_type, INT_INTOBJ(l_i) ) ? True : False);
  }
  t_4 = (Obj)(t_5 != False);
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
 C_ELM_LIST_NLE_FPL( t_5, a_arg, 1 );
 t_3 = CALL_1ARGS( t_4, t_5 );
 t_2 = (Obj)(t_3 != False);
 t_1 = (Obj)( ! ((Int)t_2) );
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
 t_1 = (Obj)(EQ( t_2, INTOBJ_INT(2) ));
 if ( t_1 ) {
  
  /* return SupType2( arg[1], arg[2] ); */
  t_2 = GF_SupType2;
  C_ELM_LIST_NLE_FPL( t_3, a_arg, 1 );
  C_ELM_LIST_NLE_FPL( t_4, a_arg, 2 );
  t_1 = CALL_2ARGS( t_2, t_3, t_4 );
  SWITCH_TO_OLD_FRAME(oldFrame);
  return t_1;
  
 }
 
 /* else */
 else {
  
  /* return SupType3( arg[1], arg[2], arg[3] ); */
  t_2 = GF_SupType3;
  C_ELM_LIST_NLE_FPL( t_3, a_arg, 1 );
  C_ELM_LIST_NLE_FPL( t_4, a_arg, 2 );
  C_ELM_LIST_NLE_FPL( t_5, a_arg, 3 );
  t_1 = CALL_3ARGS( t_2, t_3, t_4, t_5 );
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

/* handler for function 31 */
static Obj  HdlrFunc31 (
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

/* handler for function 32 */
static Obj  HdlrFunc32 (
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
 C_ELM_POSOBJ_NLE( t_1, a_K, INT_INTOBJ(t_2) );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 33 */
static Obj  HdlrFunc33 (
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
 C_ASS_POSOBJ( a_K, INT_INTOBJ(t_1), a_data )
 
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
 C_ELM_POSOBJ_NLE( t_1, a_K, INT_INTOBJ(t_2) );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 35 */
static Obj  HdlrFunc35 (
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
 t_1 = CALL_1ARGS( t_2, t_3 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 36 */
static Obj  HdlrFunc36 (
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
 t_1 = CALL_1ARGS( t_2, t_3 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 37 */
static Obj  HdlrFunc37 (
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
 t_1 = CALL_1ARGS( t_2, t_3 );
 SWITCH_TO_OLD_FRAME(oldFrame);
 return t_1;
 
 /* return; */
 SWITCH_TO_OLD_FRAME(oldFrame);
 return 0;
}

/* handler for function 38 */
static Obj  HdlrFunc38 (
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
 t_2 = (Obj)(t_3 != False);
 t_1 = (Obj)( ! ((Int)t_2) );
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
 t_1 = (Obj)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_REC( obj ) then */
 else {
  t_3 = GF_IS__REC;
  t_2 = CALL_1ARGS( t_3, a_obj );
  t_1 = (Obj)(t_2 != False);
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

/* handler for function 39 */
static Obj  HdlrFunc39 (
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
 t_2 = (Obj)(t_3 != False);
 t_1 = (Obj)( ! ((Int)t_2) );
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
 t_1 = (Obj)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, type ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  CALL_2ARGS( t_1, a_obj, a_type );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  t_1 = (Obj)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, type ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   CALL_2ARGS( t_1, a_obj, a_type );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   t_1 = (Obj)(t_2 != False);
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

/* handler for function 40 */
static Obj  HdlrFunc40 (
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
 t_1 = (Obj)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, Subtype2( TYPE_OBJ( obj ), filter ) ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  t_3 = GF_Subtype2;
  t_5 = GF_TYPE__OBJ;
  t_4 = CALL_1ARGS( t_5, a_obj );
  t_2 = CALL_2ARGS( t_3, t_4, a_filter );
  CALL_2ARGS( t_1, a_obj, t_2 );
  
  /* RunImmediateMethods( obj, FLAGS_FILTER( filter ) ); */
  t_1 = GF_RunImmediateMethods;
  t_3 = GF_FLAGS__FILTER;
  t_2 = CALL_1ARGS( t_3, a_filter );
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  t_1 = (Obj)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, Subtype2( TYPE_OBJ( obj ), filter ) ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   t_3 = GF_Subtype2;
   t_5 = GF_TYPE__OBJ;
   t_4 = CALL_1ARGS( t_5, a_obj );
   t_2 = CALL_2ARGS( t_3, t_4, a_filter );
   CALL_2ARGS( t_1, a_obj, t_2 );
   
   /* RunImmediateMethods( obj, FLAGS_FILTER( filter ) ); */
   t_1 = GF_RunImmediateMethods;
   t_3 = GF_FLAGS__FILTER;
   t_2 = CALL_1ARGS( t_3, a_filter );
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   t_1 = (Obj)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, Subtype2( TYPE_OBJ( obj ), filter ) ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    t_3 = GF_Subtype2;
    t_5 = GF_TYPE__OBJ;
    t_4 = CALL_1ARGS( t_5, a_obj );
    t_2 = CALL_2ARGS( t_3, t_4, a_filter );
    CALL_2ARGS( t_1, a_obj, t_2 );
    
    /* RunImmediateMethods( obj, FLAGS_FILTER( filter ) ); */
    t_1 = GF_RunImmediateMethods;
    t_3 = GF_FLAGS__FILTER;
    t_2 = CALL_1ARGS( t_3, a_filter );
    CALL_2ARGS( t_1, a_obj, t_2 );
    
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
 /* fi */
 
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
 t_1 = (Obj)(t_2 != False);
 if ( t_1 ) {
  
  /* SET_TYPE_POSOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
  t_1 = GF_SET__TYPE__POSOBJ;
  t_3 = GF_SupType2;
  t_5 = GF_TYPE__OBJ;
  t_4 = CALL_1ARGS( t_5, a_obj );
  t_2 = CALL_2ARGS( t_3, t_4, a_filter );
  CALL_2ARGS( t_1, a_obj, t_2 );
  
 }
 
 /* elif IS_COMOBJ( obj ) then */
 else {
  t_3 = GF_IS__COMOBJ;
  t_2 = CALL_1ARGS( t_3, a_obj );
  t_1 = (Obj)(t_2 != False);
  if ( t_1 ) {
   
   /* SET_TYPE_COMOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
   t_1 = GF_SET__TYPE__COMOBJ;
   t_3 = GF_SupType2;
   t_5 = GF_TYPE__OBJ;
   t_4 = CALL_1ARGS( t_5, a_obj );
   t_2 = CALL_2ARGS( t_3, t_4, a_filter );
   CALL_2ARGS( t_1, a_obj, t_2 );
   
  }
  
  /* elif IS_DATOBJ( obj ) then */
  else {
   t_3 = GF_IS__DATOBJ;
   t_2 = CALL_1ARGS( t_3, a_obj );
   t_1 = (Obj)(t_2 != False);
   if ( t_1 ) {
    
    /* SET_TYPE_DATOBJ( obj, SupType2( TYPE_OBJ( obj ), filter ) ); */
    t_1 = GF_SET__TYPE__DATOBJ;
    t_3 = GF_SupType2;
    t_5 = GF_TYPE__OBJ;
    t_4 = CALL_1ARGS( t_5, a_obj );
    t_2 = CALL_2ARGS( t_3, t_4, a_filter );
    CALL_2ARGS( t_1, a_obj, t_2 );
    
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
 /* fi */
 
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
 t_1 = (Obj)(a_val != False);
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

/* handler for function 44 */
static Obj  HdlrFunc44 (
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
 t_3 = NEW_PLIST( T_PLIST, 3 );
 SET_LEN_PLIST( t_3, 3 );
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_to );
 SET_ELM_PLIST( t_3, 1, t_4 );
 CHANGED_BAG( t_3 );
 t_5 = GF_FLAGS__FILTER;
 t_4 = CALL_1ARGS( t_5, a_from );
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

/* handler for function 43 */
static Obj  HdlrFunc43 (
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
 InitHandlerFunc( HdlrFunc44, ": HdlrFunc44 (170069090)" );
 t_1 = NewFunction( NameFunc[44], NargFunc[44], NamsFunc[44], HdlrFunc44);
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

/* handler for function 46 */
static Obj  HdlrFunc46 (
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
 C_ELM_POSOBJ_NLE( t_1, t_2, 2 );
 l_fsup = t_1;
 
 /* fsub := TypeObj( sub )![2]; */
 t_3 = GF_TypeObj;
 t_2 = CALL_1ARGS( t_3, a_sub );
 C_ELM_POSOBJ_NLE( t_1, t_2, 2 );
 l_fsub = t_1;
 
 /* i := 1; */
 l_i = INTOBJ_INT(1);
 
 /* while i <= LEN_LIST( list ) od */
 while ( 1 ) {
  t_3 = GF_LEN__LIST;
  t_4 = OBJ_LVAR_0UP( 1 );
  t_2 = CALL_1ARGS( t_3, t_4 );
  t_1 = (Obj)(! LT( t_2, l_i ));
  if ( ! t_1 ) break;
  
  /* if not i in done then */
  t_2 = (Obj)(IN( l_i, l_done ));
  t_1 = (Obj)( ! ((Int)t_2) );
  if ( t_1 ) {
   
   /* if IS_SUBSET_FLAGS( fsup, list[i][1] ) then */
   t_3 = GF_IS__SUBSET__FLAGS;
   t_6 = OBJ_LVAR_0UP( 1 );
   C_ELM_LIST_NLE_FPL( t_5, t_6, INT_INTOBJ(l_i) );
   C_ELM_LIST_NLE_FPL( t_4, t_5, 1 );
   t_2 = CALL_2ARGS( t_3, l_fsup, t_4 );
   t_1 = (Obj)(t_2 != False);
   if ( t_1 ) {
    
    /* if IS_SUBSET_FLAGS( fsub, list[i][2] ) then */
    t_3 = GF_IS__SUBSET__FLAGS;
    t_6 = OBJ_LVAR_0UP( 1 );
    C_ELM_LIST_NLE_FPL( t_5, t_6, INT_INTOBJ(l_i) );
    C_ELM_LIST_NLE_FPL( t_4, t_5, 2 );
    t_2 = CALL_2ARGS( t_3, l_fsub, t_4 );
    t_1 = (Obj)(t_2 != False);
    if ( t_1 ) {
     
     /* ADD_SET( done, i ); */
     t_1 = GF_ADD__SET;
     CALL_2ARGS( t_1, l_done, l_i );
     
     /* list[i][3]( sup, sub ); */
     t_3 = OBJ_LVAR_0UP( 1 );
     C_ELM_LIST_NLE_FPL( t_2, t_3, INT_INTOBJ(l_i) );
     C_ELM_LIST_NLE_FPL( t_1, t_2, 3 );
     CALL_2ARGS( t_1, a_sup, a_sub );
     
     /* tmp := TypeObj( sub )![2]; */
     t_3 = GF_TypeObj;
     t_2 = CALL_1ARGS( t_3, a_sub );
     C_ELM_POSOBJ_NLE( t_1, t_2, 2 );
     l_tmp = t_1;
     
     /* if tmp = fsub then */
     t_1 = (Obj)(EQ( l_tmp, l_fsub ));
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
   C_SUM_FIA( t_1, l_i, INTOBJ_INT(1) )
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

/* handler for function 45 */
static Obj  HdlrFunc45 (
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
 InitHandlerFunc( HdlrFunc46, ": HdlrFunc46 (170069090)" );
 t_1 = NewFunction( NameFunc[46], NargFunc[46], NamsFunc[46], HdlrFunc46);
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
 Bag oldFrame;
 
 /* restoring old stack frame */
 oldFrame = CurrLVars;
 SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));
 
 /* Revision.type_g := "@(#)$Id$"; */
 t_1 = GC_Revision;
 C_NEW_STRING( t_2, 52, "@(#)$Id$" )
 ASS_REC( t_1, R_type__g, t_2 );
 
 /* POS_DATA_TYPE := 3; */
 AssGVar( G_POS__DATA__TYPE, INTOBJ_INT(3) );
 
 /* POS_NUMB_TYPE := 4; */
 AssGVar( G_POS__NUMB__TYPE, INTOBJ_INT(4) );
 
 /* POS_FIRST_FREE_TYPE := 5; */
 AssGVar( G_POS__FIRST__FREE__TYPE, INTOBJ_INT(5) );
 
 /* NEW_TYPE_NEXT_ID := - 2 ^ 28; */
 t_2 = POW( INTOBJ_INT(2), INTOBJ_INT(28) );
 C_AINV_FIA( t_1, t_2 )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* NewCategoryKernel := function ... end; */
 InitHandlerFunc( HdlrFunc2, ": HdlrFunc2 (170069090)" );
 t_1 = NewFunction( NameFunc[2], NargFunc[2], NamsFunc[2], HdlrFunc2);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewCategoryKernel, t_1 );
 
 /* NewCategory := function ... end; */
 InitHandlerFunc( HdlrFunc3, ": HdlrFunc3 (170069090)" );
 t_1 = NewFunction( NameFunc[3], NargFunc[3], NamsFunc[3], HdlrFunc3);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewCategory, t_1 );
 
 /* NewRepresentationKernel := function ... end; */
 InitHandlerFunc( HdlrFunc4, ": HdlrFunc4 (170069090)" );
 t_1 = NewFunction( NameFunc[4], NargFunc[4], NamsFunc[4], HdlrFunc4);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewRepresentationKernel, t_1 );
 
 /* NewRepresentation := function ... end; */
 InitHandlerFunc( HdlrFunc5, ": HdlrFunc5 (170069090)" );
 t_1 = NewFunction( NameFunc[5], NargFunc[5], NamsFunc[5], HdlrFunc5);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewRepresentation, t_1 );
 
 /* IsInternalRep := NewRepresentation( "IsInternalRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 13, "IsInternalRep" )
 t_4 = GC_IS__OBJECT;
 t_5 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_5, 0 );
 t_6 = GC_IS__OBJECT;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsInternalRep, t_1 );
 
 /* IsPositionalObjectRep := NewRepresentation( "IsPositionalObjectRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 21, "IsPositionalObjectRep" )
 t_4 = GC_IS__OBJECT;
 t_5 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_5, 0 );
 t_6 = GC_IS__OBJECT;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsPositionalObjectRep, t_1 );
 
 /* IsComponentObjectRep := NewRepresentation( "IsComponentObjectRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 20, "IsComponentObjectRep" )
 t_4 = GC_IS__OBJECT;
 t_5 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_5, 0 );
 t_6 = GC_IS__OBJECT;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsComponentObjectRep, t_1 );
 
 /* IsDataObjectRep := NewRepresentation( "IsDataObjectRep", IS_OBJECT, [  ], IS_OBJECT ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 15, "IsDataObjectRep" )
 t_4 = GC_IS__OBJECT;
 t_5 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_5, 0 );
 t_6 = GC_IS__OBJECT;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsDataObjectRep, t_1 );
 
 /* IsAttributeStoringRep := NewRepresentation( "IsAttributeStoringRep", IsComponentObjectRep, [  ], IS_OBJECT ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 21, "IsAttributeStoringRep" )
 t_4 = GC_IsComponentObjectRep;
 t_5 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_5, 0 );
 t_6 = GC_IS__OBJECT;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsAttributeStoringRep, t_1 );
 
 /* InstallAttributeFunction( function ... end ); */
 t_1 = GF_InstallAttributeFunction;
 InitHandlerFunc( HdlrFunc6, ": HdlrFunc6 (170069090)" );
 t_2 = NewFunction( NameFunc[6], NargFunc[6], NamsFunc[6], HdlrFunc6);
 ENVI_FUNC( t_2 ) = CurrLVars;
 t_3 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_2) = t_3;
 CHANGED_BAG( CurrLVars );
 CALL_1ARGS( t_1, t_2 );
 
 /* InstallAttributeFunction( function ... end ); */
 t_1 = GF_InstallAttributeFunction;
 InitHandlerFunc( HdlrFunc7, ": HdlrFunc7 (170069090)" );
 t_2 = NewFunction( NameFunc[7], NargFunc[7], NamsFunc[7], HdlrFunc7);
 ENVI_FUNC( t_2 ) = CurrLVars;
 t_3 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_2) = t_3;
 CHANGED_BAG( CurrLVars );
 CALL_1ARGS( t_1, t_2 );
 
 /* EMPTY_FLAGS := FLAGS_FILTER( IS_OBJECT ); */
 t_2 = GF_FLAGS__FILTER;
 t_3 = GC_IS__OBJECT;
 t_1 = CALL_1ARGS( t_2, t_3 );
 AssGVar( G_EMPTY__FLAGS, t_1 );
 
 /* IsFamily := NewCategory( "IsFamily", IS_OBJECT ); */
 t_2 = GF_NewCategory;
 C_NEW_STRING( t_3, 8, "IsFamily" )
 t_4 = GC_IS__OBJECT;
 t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 AssGVar( G_IsFamily, t_1 );
 
 /* IsType := NewCategory( "IsType", IS_OBJECT ); */
 t_2 = GF_NewCategory;
 C_NEW_STRING( t_3, 6, "IsType" )
 t_4 = GC_IS__OBJECT;
 t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 AssGVar( G_IsType, t_1 );
 
 /* IsFamilyOfFamilies := NewCategory( "IsFamilyOfFamilies", IsFamily ); */
 t_2 = GF_NewCategory;
 C_NEW_STRING( t_3, 18, "IsFamilyOfFamilies" )
 t_4 = GC_IsFamily;
 t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 AssGVar( G_IsFamilyOfFamilies, t_1 );
 
 /* IsFamilyOfTypes := NewCategory( "IsFamilyOfTypes", IsFamily ); */
 t_2 = GF_NewCategory;
 C_NEW_STRING( t_3, 15, "IsFamilyOfTypes" )
 t_4 = GC_IsFamily;
 t_1 = CALL_2ARGS( t_2, t_3, t_4 );
 AssGVar( G_IsFamilyOfTypes, t_1 );
 
 /* IsFamilyDefaultRep := NewRepresentation( "IsFamilyDefaultRep", IsComponentObjectRep, "NAME,REQ_FLAGS,IMP_FLAGS,TYPES,TYPES_LIST_FAM", IsFamily ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 18, "IsFamilyDefaultRep" )
 t_4 = GC_IsComponentObjectRep;
 C_NEW_STRING( t_5, 45, "NAME,REQ_FLAGS,IMP_FLAGS,TYPES,TYPES_LIST_FAM" )
 t_6 = GC_IsFamily;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsFamilyDefaultRep, t_1 );
 
 /* IsTypeDefaultRep := NewRepresentation( "IsTypeDefaultRep", IsPositionalObjectRep, "", IsType ); */
 t_2 = GF_NewRepresentation;
 C_NEW_STRING( t_3, 16, "IsTypeDefaultRep" )
 t_4 = GC_IsPositionalObjectRep;
 C_NEW_STRING( t_5, 0, "" )
 t_6 = GC_IsType;
 t_1 = CALL_4ARGS( t_2, t_3, t_4, t_5, t_6 );
 AssGVar( G_IsTypeDefaultRep, t_1 );
 
 /* FamilyOfFamilies := rec(
     ); */
 t_1 = NEW_PREC( 0 );
 AssGVar( G_FamilyOfFamilies, t_1 );
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* TypeOfFamilies := [ FamilyOfFamilies, WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamily and IsFamilyDefaultRep ) ), false, NEW_TYPE_NEXT_ID ]; */
 t_1 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_1, 4 );
 t_2 = GC_FamilyOfFamilies;
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 t_3 = GF_WITH__IMPS__FLAGS;
 t_5 = GF_FLAGS__FILTER;
 t_7 = GC_IsFamily;
 if ( t_7 == False ) {
  t_6 = t_7;
 }
 else if ( t_7 == True ) {
  t_8 = GC_IsFamilyDefaultRep;
  t_6 = t_8;
 }
 else {
  t_9 = GC_IsFamilyDefaultRep;
  t_6 = NewAndFilter( t_7, t_9 );
 }
 t_4 = CALL_1ARGS( t_5, t_6 );
 t_2 = CALL_1ARGS( t_3, t_4 );
 SET_ELM_PLIST( t_1, 2, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 3, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = GC_NEW__TYPE__NEXT__ID;
 SET_ELM_PLIST( t_1, 4, t_2 );
 CHANGED_BAG( t_1 );
 AssGVar( G_TypeOfFamilies, t_1 );
 
 /* FamilyOfFamilies!.NAME := "FamilyOfFamilies"; */
 t_1 = GC_FamilyOfFamilies;
 C_NEW_STRING( t_2, 16, "FamilyOfFamilies" )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_NAME, t_2 );
 }
 else {
  ASS_REC( t_1, R_NAME, t_2 );
 }
 
 /* FamilyOfFamilies!.REQ_FLAGS := FLAGS_FILTER( IsFamily ); */
 t_1 = GC_FamilyOfFamilies;
 t_3 = GF_FLAGS__FILTER;
 t_4 = GC_IsFamily;
 t_2 = CALL_1ARGS( t_3, t_4 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_REQ__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_REQ__FLAGS, t_2 );
 }
 
 /* FamilyOfFamilies!.IMP_FLAGS := EMPTY_FLAGS; */
 t_1 = GC_FamilyOfFamilies;
 t_2 = GC_EMPTY__FLAGS;
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_IMP__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_IMP__FLAGS, t_2 );
 }
 
 /* FamilyOfFamilies!.TYPES := [  ]; */
 t_1 = GC_FamilyOfFamilies;
 t_2 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_2, 0 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES, t_2 );
 }
 
 /* FamilyOfFamilies!.TYPES_LIST_FAM := [ ,,,,,,,,,,,, false ]; */
 t_1 = GC_FamilyOfFamilies;
 t_2 = NEW_PLIST( T_PLIST, 13 );
 SET_LEN_PLIST( t_2, 13 );
 t_3 = False;
 SET_ELM_PLIST( t_2, 13, t_3 );
 CHANGED_BAG( t_2 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* TypeOfFamilyOfFamilies := [ FamilyOfFamilies, WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep and IsAttributeStoringRep ) ), false, NEW_TYPE_NEXT_ID ]; */
 t_1 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_1, 4 );
 t_2 = GC_FamilyOfFamilies;
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 t_3 = GF_WITH__IMPS__FLAGS;
 t_5 = GF_FLAGS__FILTER;
 t_8 = GC_IsFamilyOfFamilies;
 if ( t_8 == False ) {
  t_7 = t_8;
 }
 else if ( t_8 == True ) {
  t_9 = GC_IsFamilyDefaultRep;
  t_7 = t_9;
 }
 else {
  t_10 = GC_IsFamilyDefaultRep;
  t_7 = NewAndFilter( t_8, t_10 );
 }
 if ( t_7 == False ) {
  t_6 = t_7;
 }
 else if ( t_7 == True ) {
  t_8 = GC_IsAttributeStoringRep;
  t_6 = t_8;
 }
 else {
  t_9 = GC_IsAttributeStoringRep;
  t_6 = NewAndFilter( t_7, t_9 );
 }
 t_4 = CALL_1ARGS( t_5, t_6 );
 t_2 = CALL_1ARGS( t_3, t_4 );
 SET_ELM_PLIST( t_1, 2, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 3, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = GC_NEW__TYPE__NEXT__ID;
 SET_ELM_PLIST( t_1, 4, t_2 );
 CHANGED_BAG( t_1 );
 AssGVar( G_TypeOfFamilyOfFamilies, t_1 );
 
 /* FamilyOfTypes := rec(
     ); */
 t_1 = NEW_PREC( 0 );
 AssGVar( G_FamilyOfTypes, t_1 );
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* TypeOfTypes := [ FamilyOfTypes, WITH_IMPS_FLAGS( FLAGS_FILTER( IsType and IsTypeDefaultRep ) ), false, NEW_TYPE_NEXT_ID ]; */
 t_1 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_1, 4 );
 t_2 = GC_FamilyOfTypes;
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 t_3 = GF_WITH__IMPS__FLAGS;
 t_5 = GF_FLAGS__FILTER;
 t_7 = GC_IsType;
 if ( t_7 == False ) {
  t_6 = t_7;
 }
 else if ( t_7 == True ) {
  t_8 = GC_IsTypeDefaultRep;
  t_6 = t_8;
 }
 else {
  t_9 = GC_IsTypeDefaultRep;
  t_6 = NewAndFilter( t_7, t_9 );
 }
 t_4 = CALL_1ARGS( t_5, t_6 );
 t_2 = CALL_1ARGS( t_3, t_4 );
 SET_ELM_PLIST( t_1, 2, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 3, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = GC_NEW__TYPE__NEXT__ID;
 SET_ELM_PLIST( t_1, 4, t_2 );
 CHANGED_BAG( t_1 );
 AssGVar( G_TypeOfTypes, t_1 );
 
 /* FamilyOfTypes!.NAME := "FamilyOfTypes"; */
 t_1 = GC_FamilyOfTypes;
 C_NEW_STRING( t_2, 13, "FamilyOfTypes" )
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_NAME, t_2 );
 }
 else {
  ASS_REC( t_1, R_NAME, t_2 );
 }
 
 /* FamilyOfTypes!.REQ_FLAGS := FLAGS_FILTER( IsType ); */
 t_1 = GC_FamilyOfTypes;
 t_3 = GF_FLAGS__FILTER;
 t_4 = GC_IsType;
 t_2 = CALL_1ARGS( t_3, t_4 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_REQ__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_REQ__FLAGS, t_2 );
 }
 
 /* FamilyOfTypes!.IMP_FLAGS := EMPTY_FLAGS; */
 t_1 = GC_FamilyOfTypes;
 t_2 = GC_EMPTY__FLAGS;
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_IMP__FLAGS, t_2 );
 }
 else {
  ASS_REC( t_1, R_IMP__FLAGS, t_2 );
 }
 
 /* FamilyOfTypes!.TYPES := [  ]; */
 t_1 = GC_FamilyOfTypes;
 t_2 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_2, 0 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES, t_2 );
 }
 
 /* FamilyOfTypes!.TYPES_LIST_FAM := [ ,,,,,,,,,,,, false ]; */
 t_1 = GC_FamilyOfTypes;
 t_2 = NEW_PLIST( T_PLIST, 13 );
 SET_LEN_PLIST( t_2, 13 );
 t_3 = False;
 SET_ELM_PLIST( t_2, 13, t_3 );
 CHANGED_BAG( t_2 );
 if ( TNUM_OBJ(t_1) == T_COMOBJ ) {
  AssPRec( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 else {
  ASS_REC( t_1, R_TYPES__LIST__FAM, t_2 );
 }
 
 /* NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1; */
 t_2 = GC_NEW__TYPE__NEXT__ID;
 C_SUM_FIA( t_1, t_2, INTOBJ_INT(1) )
 AssGVar( G_NEW__TYPE__NEXT__ID, t_1 );
 
 /* TypeOfFamilyOfTypes := [ FamilyOfFamilies, WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfTypes and IsTypeDefaultRep ) ), false, NEW_TYPE_NEXT_ID ]; */
 t_1 = NEW_PLIST( T_PLIST, 4 );
 SET_LEN_PLIST( t_1, 4 );
 t_2 = GC_FamilyOfFamilies;
 SET_ELM_PLIST( t_1, 1, t_2 );
 CHANGED_BAG( t_1 );
 t_3 = GF_WITH__IMPS__FLAGS;
 t_5 = GF_FLAGS__FILTER;
 t_7 = GC_IsFamilyOfTypes;
 if ( t_7 == False ) {
  t_6 = t_7;
 }
 else if ( t_7 == True ) {
  t_8 = GC_IsTypeDefaultRep;
  t_6 = t_8;
 }
 else {
  t_9 = GC_IsTypeDefaultRep;
  t_6 = NewAndFilter( t_7, t_9 );
 }
 t_4 = CALL_1ARGS( t_5, t_6 );
 t_2 = CALL_1ARGS( t_3, t_4 );
 SET_ELM_PLIST( t_1, 2, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = False;
 SET_ELM_PLIST( t_1, 3, t_2 );
 CHANGED_BAG( t_1 );
 t_2 = GC_NEW__TYPE__NEXT__ID;
 SET_ELM_PLIST( t_1, 4, t_2 );
 CHANGED_BAG( t_1 );
 AssGVar( G_TypeOfFamilyOfTypes, t_1 );
 
 /* SET_TYPE_COMOBJ( FamilyOfFamilies, TypeOfFamilyOfFamilies ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 t_2 = GC_FamilyOfFamilies;
 t_3 = GC_TypeOfFamilyOfFamilies;
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* SET_TYPE_POSOBJ( TypeOfFamilies, TypeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 t_2 = GC_TypeOfFamilies;
 t_3 = GC_TypeOfTypes;
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* SET_TYPE_COMOBJ( FamilyOfTypes, TypeOfFamilyOfTypes ); */
 t_1 = GF_SET__TYPE__COMOBJ;
 t_2 = GC_FamilyOfTypes;
 t_3 = GC_TypeOfFamilyOfTypes;
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* SET_TYPE_POSOBJ( TypeOfTypes, TypeOfTypes ); */
 t_1 = GF_SET__TYPE__POSOBJ;
 t_2 = GC_TypeOfTypes;
 t_3 = GC_TypeOfTypes;
 CALL_2ARGS( t_1, t_2, t_3 );
 
 /* CATEGORIES_FAMILY := [  ]; */
 t_1 = NEW_PLIST( T_PLIST, 0 );
 SET_LEN_PLIST( t_1, 0 );
 AssGVar( G_CATEGORIES__FAMILY, t_1 );
 
 /* CategoryFamily := function ... end; */
 InitHandlerFunc( HdlrFunc9, ": HdlrFunc9 (170069090)" );
 t_1 = NewFunction( NameFunc[9], NargFunc[9], NamsFunc[9], HdlrFunc9);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_CategoryFamily, t_1 );
 
 /* Subtype := "defined below"; */
 C_NEW_STRING( t_1, 13, "defined below" )
 AssGVar( G_Subtype, t_1 );
 
 /* NEW_FAMILY := function ... end; */
 InitHandlerFunc( HdlrFunc10, ": HdlrFunc10 (170069090)" );
 t_1 = NewFunction( NameFunc[10], NargFunc[10], NamsFunc[10], HdlrFunc10);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEW__FAMILY, t_1 );
 
 /* NewFamily2 := function ... end; */
 InitHandlerFunc( HdlrFunc11, ": HdlrFunc11 (170069090)" );
 t_1 = NewFunction( NameFunc[11], NargFunc[11], NamsFunc[11], HdlrFunc11);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewFamily2, t_1 );
 
 /* NewFamily3 := function ... end; */
 InitHandlerFunc( HdlrFunc12, ": HdlrFunc12 (170069090)" );
 t_1 = NewFunction( NameFunc[12], NargFunc[12], NamsFunc[12], HdlrFunc12);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewFamily3, t_1 );
 
 /* NewFamily4 := function ... end; */
 InitHandlerFunc( HdlrFunc13, ": HdlrFunc13 (170069090)" );
 t_1 = NewFunction( NameFunc[13], NargFunc[13], NamsFunc[13], HdlrFunc13);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewFamily4, t_1 );
 
 /* NewFamily5 := function ... end; */
 InitHandlerFunc( HdlrFunc14, ": HdlrFunc14 (170069090)" );
 t_1 = NewFunction( NameFunc[14], NargFunc[14], NamsFunc[14], HdlrFunc14);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewFamily5, t_1 );
 
 /* NewFamily := function ... end; */
 InitHandlerFunc( HdlrFunc15, ": HdlrFunc15 (170069090)" );
 t_1 = NewFunction( NameFunc[15], NargFunc[15], NamsFunc[15], HdlrFunc15);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewFamily, t_1 );
 
 /* InstallOtherMethod( PRINT_OBJ, true, [ IsFamily ], 0, function ... end ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = GC_PRINT__OBJ;
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_5 = GC_IsFamily;
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 InitHandlerFunc( HdlrFunc16, ": HdlrFunc16 (170069090)" );
 t_5 = NewFunction( NameFunc[16], NargFunc[16], NamsFunc[16], HdlrFunc16);
 ENVI_FUNC( t_5 ) = CurrLVars;
 t_6 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_5) = t_6;
 CHANGED_BAG( CurrLVars );
 CALL_5ARGS( t_1, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
 
 /* NEW_TYPE_CACHE_MISS := 0; */
 AssGVar( G_NEW__TYPE__CACHE__MISS, INTOBJ_INT(0) );
 
 /* NEW_TYPE_CACHE_HIT := 0; */
 AssGVar( G_NEW__TYPE__CACHE__HIT, INTOBJ_INT(0) );
 
 /* NEW_TYPE := function ... end; */
 InitHandlerFunc( HdlrFunc17, ": HdlrFunc17 (170069090)" );
 t_1 = NewFunction( NameFunc[17], NargFunc[17], NamsFunc[17], HdlrFunc17);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NEW__TYPE, t_1 );
 
 /* NewType2 := function ... end; */
 InitHandlerFunc( HdlrFunc18, ": HdlrFunc18 (170069090)" );
 t_1 = NewFunction( NameFunc[18], NargFunc[18], NamsFunc[18], HdlrFunc18);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewType2, t_1 );
 
 /* NewType3 := function ... end; */
 InitHandlerFunc( HdlrFunc19, ": HdlrFunc19 (170069090)" );
 t_1 = NewFunction( NameFunc[19], NargFunc[19], NamsFunc[19], HdlrFunc19);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewType3, t_1 );
 
 /* NewType4 := function ... end; */
 InitHandlerFunc( HdlrFunc20, ": HdlrFunc20 (170069090)" );
 t_1 = NewFunction( NameFunc[20], NargFunc[20], NamsFunc[20], HdlrFunc20);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewType4, t_1 );
 
 /* NewType5 := function ... end; */
 InitHandlerFunc( HdlrFunc21, ": HdlrFunc21 (170069090)" );
 t_1 = NewFunction( NameFunc[21], NargFunc[21], NamsFunc[21], HdlrFunc21);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewType5, t_1 );
 
 /* NewType := function ... end; */
 InitHandlerFunc( HdlrFunc22, ": HdlrFunc22 (170069090)" );
 t_1 = NewFunction( NameFunc[22], NargFunc[22], NamsFunc[22], HdlrFunc22);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_NewType, t_1 );
 
 /* InstallOtherMethod( PRINT_OBJ, true, [ IsType ], 0, function ... end ); */
 t_1 = GF_InstallOtherMethod;
 t_2 = GC_PRINT__OBJ;
 t_3 = True;
 t_4 = NEW_PLIST( T_PLIST, 1 );
 SET_LEN_PLIST( t_4, 1 );
 t_5 = GC_IsType;
 SET_ELM_PLIST( t_4, 1, t_5 );
 CHANGED_BAG( t_4 );
 InitHandlerFunc( HdlrFunc23, ": HdlrFunc23 (170069090)" );
 t_5 = NewFunction( NameFunc[23], NargFunc[23], NamsFunc[23], HdlrFunc23);
 ENVI_FUNC( t_5 ) = CurrLVars;
 t_6 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_5) = t_6;
 CHANGED_BAG( CurrLVars );
 CALL_5ARGS( t_1, t_2, t_3, t_4, INTOBJ_INT(0), t_5 );
 
 /* Subtype2 := function ... end; */
 InitHandlerFunc( HdlrFunc24, ": HdlrFunc24 (170069090)" );
 t_1 = NewFunction( NameFunc[24], NargFunc[24], NamsFunc[24], HdlrFunc24);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_Subtype2, t_1 );
 
 /* Subtype3 := function ... end; */
 InitHandlerFunc( HdlrFunc25, ": HdlrFunc25 (170069090)" );
 t_1 = NewFunction( NameFunc[25], NargFunc[25], NamsFunc[25], HdlrFunc25);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_Subtype3, t_1 );
 
 /* Subtype := function ... end; */
 InitHandlerFunc( HdlrFunc26, ": HdlrFunc26 (170069090)" );
 t_1 = NewFunction( NameFunc[26], NargFunc[26], NamsFunc[26], HdlrFunc26);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_Subtype, t_1 );
 
 /* SupType2 := function ... end; */
 InitHandlerFunc( HdlrFunc27, ": HdlrFunc27 (170069090)" );
 t_1 = NewFunction( NameFunc[27], NargFunc[27], NamsFunc[27], HdlrFunc27);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SupType2, t_1 );
 
 /* SupType3 := function ... end; */
 InitHandlerFunc( HdlrFunc28, ": HdlrFunc28 (170069090)" );
 t_1 = NewFunction( NameFunc[28], NargFunc[28], NamsFunc[28], HdlrFunc28);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SupType3, t_1 );
 
 /* SupType := function ... end; */
 InitHandlerFunc( HdlrFunc29, ": HdlrFunc29 (170069090)" );
 t_1 = NewFunction( NameFunc[29], NargFunc[29], NamsFunc[29], HdlrFunc29);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SupType, t_1 );
 
 /* FamilyType := function ... end; */
 InitHandlerFunc( HdlrFunc30, ": HdlrFunc30 (170069090)" );
 t_1 = NewFunction( NameFunc[30], NargFunc[30], NamsFunc[30], HdlrFunc30);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_FamilyType, t_1 );
 
 /* FlagsType := function ... end; */
 InitHandlerFunc( HdlrFunc31, ": HdlrFunc31 (170069090)" );
 t_1 = NewFunction( NameFunc[31], NargFunc[31], NamsFunc[31], HdlrFunc31);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_FlagsType, t_1 );
 
 /* DataType := function ... end; */
 InitHandlerFunc( HdlrFunc32, ": HdlrFunc32 (170069090)" );
 t_1 = NewFunction( NameFunc[32], NargFunc[32], NamsFunc[32], HdlrFunc32);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_DataType, t_1 );
 
 /* SetDataType := function ... end; */
 InitHandlerFunc( HdlrFunc33, ": HdlrFunc33 (170069090)" );
 t_1 = NewFunction( NameFunc[33], NargFunc[33], NamsFunc[33], HdlrFunc33);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SetDataType, t_1 );
 
 /* SharedType := function ... end; */
 InitHandlerFunc( HdlrFunc34, ": HdlrFunc34 (170069090)" );
 t_1 = NewFunction( NameFunc[34], NargFunc[34], NamsFunc[34], HdlrFunc34);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SharedType, t_1 );
 
 /* TypeObj := TYPE_OBJ; */
 t_1 = GC_TYPE__OBJ;
 AssGVar( G_TypeObj, t_1 );
 
 /* FamilyObj := FAMILY_OBJ; */
 t_1 = GC_FAMILY__OBJ;
 AssGVar( G_FamilyObj, t_1 );
 
 /* FlagsObj := function ... end; */
 InitHandlerFunc( HdlrFunc35, ": HdlrFunc35 (170069090)" );
 t_1 = NewFunction( NameFunc[35], NargFunc[35], NamsFunc[35], HdlrFunc35);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_FlagsObj, t_1 );
 
 /* DataObj := function ... end; */
 InitHandlerFunc( HdlrFunc36, ": HdlrFunc36 (170069090)" );
 t_1 = NewFunction( NameFunc[36], NargFunc[36], NamsFunc[36], HdlrFunc36);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_DataObj, t_1 );
 
 /* SharedObj := function ... end; */
 InitHandlerFunc( HdlrFunc37, ": HdlrFunc37 (170069090)" );
 t_1 = NewFunction( NameFunc[37], NargFunc[37], NamsFunc[37], HdlrFunc37);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SharedObj, t_1 );
 
 /* SetTypeObj := function ... end; */
 InitHandlerFunc( HdlrFunc38, ": HdlrFunc38 (170069090)" );
 t_1 = NewFunction( NameFunc[38], NargFunc[38], NamsFunc[38], HdlrFunc38);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SetTypeObj, t_1 );
 
 /* Objectify := SetTypeObj; */
 t_1 = GC_SetTypeObj;
 AssGVar( G_Objectify, t_1 );
 
 /* ChangeTypeObj := function ... end; */
 InitHandlerFunc( HdlrFunc39, ": HdlrFunc39 (170069090)" );
 t_1 = NewFunction( NameFunc[39], NargFunc[39], NamsFunc[39], HdlrFunc39);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_ChangeTypeObj, t_1 );
 
 /* ReObjectify := ChangeTypeObj; */
 t_1 = GC_ChangeTypeObj;
 AssGVar( G_ReObjectify, t_1 );
 
 /* SetFilterObj := function ... end; */
 InitHandlerFunc( HdlrFunc40, ": HdlrFunc40 (170069090)" );
 t_1 = NewFunction( NameFunc[40], NargFunc[40], NamsFunc[40], HdlrFunc40);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SetFilterObj, t_1 );
 
 /* SET_FILTER_OBJ := SetFilterObj; */
 t_1 = GC_SetFilterObj;
 AssGVar( G_SET__FILTER__OBJ, t_1 );
 
 /* ResetFilterObj := function ... end; */
 InitHandlerFunc( HdlrFunc41, ": HdlrFunc41 (170069090)" );
 t_1 = NewFunction( NameFunc[41], NargFunc[41], NamsFunc[41], HdlrFunc41);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_ResetFilterObj, t_1 );
 
 /* RESET_FILTER_OBJ := ResetFilterObj; */
 t_1 = GC_ResetFilterObj;
 AssGVar( G_RESET__FILTER__OBJ, t_1 );
 
 /* SetFeatureObj := function ... end; */
 InitHandlerFunc( HdlrFunc42, ": HdlrFunc42 (170069090)" );
 t_1 = NewFunction( NameFunc[42], NargFunc[42], NamsFunc[42], HdlrFunc42);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_SetFeatureObj, t_1 );
 
 /* InstallMethodsFunction2 := function ... end; */
 InitHandlerFunc( HdlrFunc43, ": HdlrFunc43 (170069090)" );
 t_1 = NewFunction( NameFunc[43], NargFunc[43], NamsFunc[43], HdlrFunc43);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_InstallMethodsFunction2, t_1 );
 
 /* RunMethodsFunction2 := function ... end; */
 InitHandlerFunc( HdlrFunc45, ": HdlrFunc45 (170069090)" );
 t_1 = NewFunction( NameFunc[45], NargFunc[45], NamsFunc[45], HdlrFunc45);
 ENVI_FUNC( t_1 ) = CurrLVars;
 t_2 = NewBag( T_BODY, 0 );
 BODY_FUNC(t_1) = t_2;
 CHANGED_BAG( CurrLVars );
 AssGVar( G_RunMethodsFunction2, t_1 );
 
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
 InitHandlerFunc( HdlrFunc1, ": HdlrFunc1 (170069090)" );
 func1 = NewFunction( NameFunc[1], NargFunc[1], NamsFunc[1], HdlrFunc1 );
 ENVI_FUNC( func1 ) = CurrLVars;
 CHANGED_BAG( CurrLVars );
 return func1;
}


/* <name> returns the description of this module */
static StructCompInitInfo Description = {
 /* magic1    = */ 170069090UL,
 /* magic2    = */ "GAPROOT/lib/type.g",
 /* link      = */ Link,
 /* function1 = */ (Int(*)())Function1,
 /* functions = */ 0 };

StructCompInitInfo *  Init_lib_type_g ( void )
{
 return &Description;
}

/* compiled code ends here */

#endif
