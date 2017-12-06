/****************************************************************************
**
*W  objccoll.c                  GAP source                      Werner Nickel
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file  contains  the collection functions of  combinatorial collectors
**  for finite p-groups.  The code in this file  is an extension to the single
**  collector module.  All necessary initialisations  are done in that module.
**  The interface to a combinatorial collection function is identical with the
**  interface to the corresponding single collector function.
**
*/

#include <src/objccoll.h>

#include <src/intobj.h>
#include <src/gapstate.h>
#include <src/objfgelm.h>
#include <src/objscoll.h>


#define AddWordIntoExpVec   C8Bits_AddWordIntoExpVec
#define AddCommIntoExpVec   C8Bits_AddCommIntoExpVec
#define AddPartIntoExpVec   C8Bits_AddPartIntoExpVec
#define CombiCollectWord    C8Bits_CombiCollectWord
#define UIntN       UInt1
#include <src/objccoll-impl.h>

#define AddWordIntoExpVec   C16Bits_AddWordIntoExpVec
#define AddCommIntoExpVec   C16Bits_AddCommIntoExpVec
#define AddPartIntoExpVec   C16Bits_AddPartIntoExpVec
#define CombiCollectWord    C16Bits_CombiCollectWord
#define UIntN       UInt2
#include <src/objccoll-impl.h>

#define AddWordIntoExpVec   C32Bits_AddWordIntoExpVec
#define AddCommIntoExpVec   C32Bits_AddCommIntoExpVec
#define AddPartIntoExpVec   C32Bits_AddPartIntoExpVec
#define CombiCollectWord    C32Bits_CombiCollectWord
#define UIntN       UInt4
#include <src/objccoll-impl.h>


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
**
**  This module does  not   need much initialisation  because  all  necessary
**  initialisations are done in the single collector module.
*/


/****************************************************************************
**
*F  InitInfoCombiCollector()  . . . . . . . . . . . . table of init functions
**
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "objccoll",
};

StructInitInfo * InitInfoCombiCollector ( void )
{
    return &module;
}
