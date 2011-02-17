/****************************************************************************
**
*W  threadapi.c                 GAP source                    Reimer Behrends
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the GAP interface for thread primitives.
*/
#include        <stdio.h>
#include        <assert.h>
#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */
#include        <string.h>              /* memcpy */
#include        <stdlib.h>
#include	<pthread.h>
#include	<atomic_ops.h>

#include        "system.h"              /* system dependent part           */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "read.h"                /* reader                          */
#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */
#include        "ariths.h"              /* basic arithmetic                */

#include        "integer.h"             /* integers                        */
#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "listoper.h"            /* operations for generic lists    */
#include        "listfunc.h"            /* functions for generic lists     */
#include        "plist.h"               /* plain lists                     */

#include        "code.h"                /* coder                           */

#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */
#include        "funcs.h"               /* functions                       */

#include        "thread.h"
#include        "tls.h"


#include        "intrprtr.h"            /* interpreter                     */

#include        "compiler.h"            /* compiler                        */

Obj TYPE_ALIST;
Obj TYPE_ARECORD;

#ifndef WARD_ENABLED

Obj TypeAList(Obj obj)
{
  Obj result = ADDR_OBJ(obj)[1];
  return result != NULL ? result : TYPE_ALIST;
}

Obj TypeARecord(Obj obj)
{
  Obj result = ADDR_OBJ(obj)[0];
  return result != NULL ? result : TYPE_ARECORD;
}

static Int AlwaysMutable( Obj obj)
{
  return 1;
}

static void ArgumentError(char *message)
{
  ErrorQuit(message, 0, 0);
}

static Obj NewAtomicList(UInt length)
{
  return NewBag(T_ALIST, sizeof(Obj) * (length + 2));
}

static Obj FuncNewAtomicList(Obj self, Obj args)
{
  Obj init;
  Obj result;
  Obj *data;
  UInt i, len;
  switch (LEN_PLIST(args)) {
    case 1:
      init = ELM_PLIST(args, 1);
      if (!IS_DENSE_LIST(init))
        ArgumentError("NewAtomicList: Argument must be dense list");
      len = LEN_LIST(init);
      result = NewAtomicList(len);
      data = ADDR_OBJ(result);
      *data++ = (Obj) len;
      *data++ = NULL;
      for (i=1; i<= len; i++)
        *data++ = ELM_LIST(init, i);
      return result;
    case 2:
      if (!IS_INTOBJ(ELM_PLIST(args, 1)))
        ArgumentError("NewAtomicList: First argument must be a non-negative integer");
      len = INT_INTOBJ(ELM_PLIST(args, 1));
      if (len < 0)
        ArgumentError("NewAtomicList: First argument must be a non-negative integer");
      result = NewAtomicList(len);
      init = ELM_PLIST(args, 2);
      data = ADDR_OBJ(result);
      *data++ = (Obj) len;
      *data++ = NULL;
      for (i=1; i<=len; i++)
        *data++ = init;
      return result;
    default:
      ArgumentError("NewAtomicList: Too many arguments");
  }
}

static Obj FuncGET_ATOMIC_LIST(Obj self, Obj list, Obj index)
{
  UInt n;
  UInt len;
  Obj result;
  if (TNUM_OBJ(list) != T_ALIST)
    ArgumentError("GET_ATOMIC_LIST: First argument must be an atomic list");
  len = (UInt) ADDR_OBJ(list)[0];
  if (!IS_INTOBJ(index))
    ArgumentError("GET_ATOMIC_LIST: Second argument must be an integer");
  n = INT_INTOBJ(index);
  if (n <= 0 || n > len)
    ArgumentError("GET_ATOMIC_LIST: Index out of range");
  result = ADDR_OBJ(list)[n+1];
  AO_nop_read(); /* read barrier */
  return result;
}

static Obj FuncSET_ATOMIC_LIST(Obj self, Obj list, Obj index, Obj value)
{
  UInt n;
  UInt len;
  if (TNUM_OBJ(list) != T_ALIST)
    ArgumentError("SET_ATOMIC_LIST: First argument must be an atomic list");
  len = (UInt) ADDR_OBJ(list)[0];
  if (!IS_INTOBJ(index))
    ArgumentError("SET_ATOMIC_LIST: Second argument must be an integer");
  n = INT_INTOBJ(index);
  if (n <= 0 || n > len)
    ArgumentError("SET_ATOMIC_LIST: Index out of range");
  ADDR_OBJ(list)[n+1] = value;
  AO_nop_write(); /* write barrier */
  return (Obj) 0;
}

static Obj FuncFromAtomicList(Obj self, Obj list)
{
  Obj result;
  Obj *data;
  UInt i, len;
  if (TNUM_OBJ(list) != T_ALIST)
    ArgumentError("FromAtomicList: First argument must be an atomic list");
  data = ADDR_OBJ(list);
  len = (UInt) *data++;
  result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=1; i<=len; i++)
    SET_ELM_PLIST(result, i, data[i]);
  return result;
}

static void MarkAtomicList(Bag bag)
{
  UInt i, len;
  Bag *ptr, *ptrend;
  ptr = PTR_BAG(bag);
  ptrend = ptr + SIZE_BAG(bag);
  ptr++; /* skip length field */
  while (ptr < ptrend)
    MARK_BAG(*ptr++);
}

static void MarkAtomicRecord(Bag bag)
{
  /* TODO: Fill in */
  return;
}

static void PrintAtomicList(Obj obj)
{
  Pr("<atomic list of size %d>", (UInt)(ADDR_OBJ(obj)[0]), 0L);
}

static void PrintAtomicRecord(Obj obj)
{
  Pr("<atomic record>", 0L, 0L);
}



static Obj FuncNewAtomicRecord(Obj self)
{
  return NULL;
}

#endif /* WARD_ENABLED */

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs [] = {

    { "NewAtomicList", -1, "list|count, obj",
      FuncNewAtomicList, "src/aobjects.c:NewAtomicList" },

    { "FromAtomicList", 1, "list",
      FuncFromAtomicList, "src/aobjects.c:FromAtomicList" },

    { "GET_ATOMIC_LIST", 2, "list, index",
      FuncGET_ATOMIC_LIST, "src/aobjects.c:GET_ATOMIC_LIST" },

    { "SET_ATOMIC_LIST", 3, "list, index, value",
      FuncSET_ATOMIC_LIST, "src/aobjects.c:SET_ATOMIC_LIST" },

    { "NewAtomicRecord", 0, "",
      FuncNewAtomicRecord, "src/aobjects.c:NewAtomicRecord" },

    { 0 }

};

static Int IsListAList(Obj list)
{
  return 1;
}

static Int IsSmallListAList(Obj list)
{
  return 1;
}

static Obj LengthAList(Obj list)
{
  return INTOBJ_INT(ADDR_OBJ(list)[0]);
}

static Obj Elm0AList(Obj list, Int pos)
{
  UInt len = (UInt) ADDR_OBJ(list)[0];
  if (pos < 1 || pos > len)
    return 0;
  return ADDR_OBJ(list)[1+pos];
}

static Obj ElmAList(Obj list, Int pos)
{
  UInt len = (UInt)ADDR_OBJ(list)[0];
  while (pos < 1 || pos > len) {
    Obj posobj;
    do {
      posobj = ErrorReturnObj(
	"Atomic List Element: <pos>=%d is an invalid index for <list>",
	(Int) pos, 0L,
	"you can replace value <pos> via 'return <pos>;'" );
    } while (!IS_INTOBJ(posobj));
    pos = INT_INTOBJ(posobj);
  }
  return ADDR_OBJ(list)[1+pos];
}

static void AssAList(Obj list, Int pos, Obj obj)
{
  UInt len = (UInt)ADDR_OBJ(list)[0];
  while (pos < 1 || pos > len) {
    Obj posobj;
    do {
      posobj = ErrorReturnObj(
	"Atomic List Element: <pos>=%d is an invalid index for <list>",
	(Int) pos, 0L,
	"you can replace value <pos> via 'return <pos>;'" );
    } while (!IS_INTOBJ(posobj));
    pos = INT_INTOBJ(posobj);
  }
  ADDR_OBJ(list)[1+pos] = obj;
}


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  /* install info string */
  InfoBags[T_ALIST].name = "atomic list";
  InfoBags[T_AREC].name = "atomic record";
  
    /* install the kind methods */
    TypeObjFuncs[ T_ALIST ] = TypeAList;
    TypeObjFuncs[ T_BARRIER ] = TypeARecord;
    /* install global variables */
    InitCopyGVar("TYPE_ALIST", &TYPE_ALIST);
    InitCopyGVar("TYPE_ARECORD", &TYPE_ARECORD);
    /* install mark functions */
    InitMarkFuncBags(T_ALIST, MarkAtomicList);
    InitMarkFuncBags(T_AREC, MarkAtomicRecord);
    /* install print functions */
    PrintObjFuncs[ T_ALIST ] = PrintAtomicList;
    PrintObjFuncs[ T_AREC ] = PrintAtomicRecord;
    /* install mutability functions */
    IsMutableObjFuncs [ T_ALIST ] = AlwaysMutable;
    IsMutableObjFuncs [ T_AREC ] = AlwaysMutable;
    MakeBagTypePublic(T_ALIST);
    MakeBagTypePublic(T_AREC);
    /* install list functions */
    IsListFuncs[T_ALIST] = IsListAList;
    IsSmallListFuncs[T_ALIST] = IsSmallListAList;
    LenListFuncs[T_ALIST] = LengthAList;
    LengthFuncs[T_ALIST] = LengthAList;
    Elm0ListFuncs[T_ALIST] = Elm0AList;
    Elm0vListFuncs[T_ALIST] = Elm0AList;
    ElmListFuncs[T_ALIST] = ElmAList;
    ElmvListFuncs[T_ALIST] = ElmAList;
    ElmwListFuncs[T_ALIST] = ElmAList;
    AssListFuncs[T_ALIST] = AssAList;
    /* AsssListFuncs[T_ALIST] = AsssAList; */
    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitInfoAObjects() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "aobjects",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                         		/* postRestore                    */
};

StructInitInfo * InitInfoAObjects ( void )
{
    /* TODO: Insert proper revision numbers. */
    module.revision_c = "@(#)$Id: aobjects.c,v 1.0 ";
    module.revision_h = "@(#)$Id: aobjects.h,v 1.0 ";
    FillInVersion( &module );
    return &module;
}
