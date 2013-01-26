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
#include        <assert.h>
#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */
#include        <string.h>              /* memcpy */
#include        <stdlib.h>
#include	"systhread.h"		/* system thread primitives	   */

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

#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */
#include        "funcs.h"               /* functions                       */

#include	"fibhash.h"

#include	"string.h"

#include        "thread.h"
#include        "tls.h"
#include        "vars.h"                /* variables                       */


#include        "intrprtr.h"            /* interpreter                     */

#include        "compiler.h"            /* compiler                        */

#include        "objset.h"

Obj TYPE_OBJSET;
Obj TYPE_OBJMAP;

static Int AlwaysMutable(Obj obj) {
  return 1;
}

static Int NeverMutable(Obj obj) {
  return 1;
}

static Obj TypeObjSet(Obj obj) {
  return TYPE_OBJSET;
}

static Obj TypeObjMap(Obj obj) {
  return TYPE_OBJMAP;
}


#define DEFAULT_OBJSET_BITS 2
#define DEFAULT_OBJSET_SIZE (1 << DEFAULT_OBJSET_BITS)

#define OBJSET_SIZE 0
#define OBJSET_BITS 1
#define OBJSET_USED 2
#define OBJSET_DIRTY 3
#define OBJSET_HDRSIZE 4

#define ADDR_WORD(obj) ((UInt *)(ADDR_OBJ(obj)))

static void PrintObjSet(Obj set) {
  UInt i, size = ADDR_WORD(set)[OBJSET_SIZE];
  Pr("OBJ_SET([ ", 0L, 0L);
  for (i=0; i < size; i++) {
    Obj obj = ADDR_OBJ(set)[OBJSET_HDRSIZE + i ];
    if (obj && obj != Undefined) {
      PrintObj(obj);
      Pr(", ", 0L, 0L);
    }
  }
  Pr("])", 0L, 0L);
}

static void PrintObjMap(Obj map) {
  UInt i, size = ADDR_WORD(map)[OBJSET_SIZE];
  Pr("OBJ_MAP([ ", 0L, 0L);
  for (i=0; i < size; i++) {
    Obj obj = ADDR_OBJ(map)[OBJSET_HDRSIZE + i * 2 ];
    if (obj && obj != Undefined) {
      PrintObj(obj);
      Pr(", ", 0L, 0L);
      PrintObj(ADDR_OBJ(map)[OBJSET_HDRSIZE + i * 2 + 1]);
      Pr(", ", 0L, 0L);
    }
  }
  Pr("])", 0L, 0L);
}

static void MarkObjSet(Obj obj) {
}

static void MarkObjMap(Obj obj) {
}

static inline UInt ObjHash(Obj set, Obj obj) {
  return FibHash((UInt) obj, ADDR_WORD(set)[OBJSET_BITS]);
}

Obj NewObjSet() {
  Obj result = NewBag(T_OBJSET,
    (OBJSET_HDRSIZE+DEFAULT_OBJSET_SIZE)*sizeof(Bag));
  ADDR_WORD(result)[OBJSET_SIZE] = DEFAULT_OBJSET_SIZE;
  ADDR_WORD(result)[OBJSET_BITS] = DEFAULT_OBJSET_BITS;
  ADDR_WORD(result)[OBJSET_USED] = 0;
  ADDR_WORD(result)[OBJSET_DIRTY] = 0;
  return result;
}

static void ResizeObjSet(Obj set, UInt bits);

static void CheckObjSetForCleanUp(Obj set, UInt expand) {
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt bits = ADDR_WORD(set)[OBJSET_BITS];
  UInt used = ADDR_WORD(set)[OBJSET_USED] + expand;
  UInt dirty = ADDR_WORD(set)[OBJSET_DIRTY];
  if (used * 3 >= size * 2)
    ResizeObjSet(set, bits+1);
  else if (dirty && dirty >= used)
    ResizeObjSet(set, bits);
}

Int FindObjSet(Obj set, Obj obj) {
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt hash = ObjHash(set, obj);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(set)[OBJSET_HDRSIZE+hash];
    if (!current)
      return -1;
    if (current == obj)
      return (Int) hash;
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

static void AddObjSetNew(Obj set, Obj obj) {
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt hash = ObjHash(set, obj);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(set)[OBJSET_HDRSIZE+hash];
    if (!current) {
      ADDR_OBJ(set)[OBJSET_HDRSIZE+hash] = obj;
      ADDR_WORD(set)[OBJSET_USED]++;
      CHANGED_BAG(set);
      return;
    }
    if (current == Undefined) {
      ADDR_OBJ(set)[OBJSET_HDRSIZE+hash] = obj;
      ADDR_WORD(set)[OBJSET_USED]++;
      ADDR_WORD(set)[OBJSET_DIRTY]--;
      CHANGED_BAG(set);
      return;
    }
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

void AddObjSet(Obj set, Obj obj) {
  if (FindObjSet(set, obj) >= 0)
    return;
  CheckObjSetForCleanUp(set, 1);
  AddObjSetNew(set, obj);
}

void RemoveObjSet(Obj set, Obj obj) {
  Int pos = FindObjSet(set, obj);
  if (pos >= 0) {
    ADDR_OBJ(set)[OBJSET_HDRSIZE+pos] = Undefined;
    ADDR_WORD(set)[OBJSET_USED]--;
    ADDR_WORD(set)[OBJSET_DIRTY]++;
    CHANGED_BAG(set);
    CheckObjSetForCleanUp(set, 0);
  }
}

void ClearObjSet(Obj set) {
  Obj *old = PTR_BAG(set);
  Obj new = NewObjSet();
  PTR_BAG(set) = PTR_BAG(new);
  PTR_BAG(new) = old;
  CHANGED_BAG(new);
  CHANGED_BAG(set);
}

static void ResizeObjSet(Obj set, UInt bits) {
  UInt i, new_size = (1 << bits);
  Obj *old = PTR_BAG(set);
  Obj new = NewBag(T_OBJSET,
    (OBJSET_HDRSIZE+new_size)*sizeof(Bag));
  ADDR_WORD(new)[OBJSET_SIZE] = new_size;
  ADDR_WORD(new)[OBJSET_BITS] = bits;
  ADDR_WORD(new)[OBJSET_USED] = 0;
  ADDR_WORD(new)[OBJSET_DIRTY] = 0;
  for (i = OBJSET_HDRSIZE + ADDR_WORD(set)[OBJSET_SIZE] - 1;
       i >=OBJSET_HDRSIZE; i--) {
    Obj obj = ADDR_OBJ(set)[i];
    if (obj && obj != Undefined) {
      AddObjSetNew(new, obj);
    }
  }
  PTR_BAG(set) = PTR_BAG(new);
  PTR_BAG(new) = old;
  CHANGED_BAG(set);
  CHANGED_BAG(new);
}

Obj NewObjMap() {
  Obj result = NewBag(T_OBJMAP, (4+2*DEFAULT_OBJSET_SIZE)*sizeof(Bag));
  ADDR_WORD(result)[OBJSET_SIZE] = DEFAULT_OBJSET_SIZE;
  ADDR_WORD(result)[OBJSET_BITS] = DEFAULT_OBJSET_BITS;
  ADDR_WORD(result)[OBJSET_USED] = 0;
  ADDR_WORD(result)[OBJSET_DIRTY] = 0;
  return result;
}

static void ResizeObjMap(Obj map, UInt bits);

static void CheckObjMapForCleanUp(Obj map, UInt expand) {
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  UInt bits = ADDR_WORD(map)[OBJSET_BITS];
  UInt used = ADDR_WORD(map)[OBJSET_USED] + expand;
  UInt dirty = ADDR_WORD(map)[OBJSET_DIRTY];
  if (used * 3 >= size * 2)
    ResizeObjMap(map, bits+1);
  else if (dirty && dirty >= used)
    ResizeObjMap(map, bits);
}

Int FindObjMap(Obj map, Obj obj) {
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  UInt hash = ObjHash(map, obj);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2];
    if (!current)
      return -1;
    if (current == obj)
      return (Int) hash;
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

static void AddObjMapNew(Obj map, Obj key, Obj value) {
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  UInt hash = ObjHash(map, key);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(map)[OBJSET_HDRSIZE+hash * 2];
    if (!current) {
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2] = key;
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2+1] = value;
      ADDR_WORD(map)[OBJSET_USED]++;
      CHANGED_BAG(map);
      return;
    }
    if (current == Undefined) {
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2] = key;
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2+1] = value;
      ADDR_WORD(map)[OBJSET_USED]++;
      ADDR_WORD(map)[OBJSET_DIRTY]--;
      CHANGED_BAG(map);
      return;
    }
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

void AddObjMap(Obj map, Obj key, Obj value) {
  Int pos;
  pos = FindObjMap(map, key);
  if (pos >= 0) {
    ADDR_OBJ(map)[OBJSET_HDRSIZE+pos*2+1] = value;
    CHANGED_BAG(map);
    return;
  }
  CheckObjMapForCleanUp(map, 1);
  AddObjMapNew(map, key, value);
}

void RemoveObjMap(Obj map, Obj key) {
  Int pos = FindObjMap(map, key);
  if (pos >= 0) {
    ADDR_OBJ(map)[OBJSET_HDRSIZE+pos*2] = Undefined;
    ADDR_OBJ(map)[OBJSET_HDRSIZE+pos*2+1] = (Obj) 0;
    ADDR_WORD(map)[OBJSET_USED]--;
    ADDR_WORD(map)[OBJSET_DIRTY]++;
    CHANGED_BAG(map);
    CheckObjMapForCleanUp(map, 0);
  }
}

void ClearObjMap(Obj map) {
  Obj *old = PTR_BAG(map);
  Obj new = NewObjMap();
  PTR_BAG(map) = PTR_BAG(new);
  PTR_BAG(new) = old;
  CHANGED_BAG(new);
  CHANGED_BAG(map);
}

static void ResizeObjMap(Obj map, UInt bits) {
  UInt i, new_size = (1 << bits);
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  Obj *old = PTR_BAG(map);
  Obj new = NewBag(T_OBJMAP,
    (OBJSET_HDRSIZE+2*new_size)*sizeof(Bag));
  ADDR_WORD(new)[OBJSET_SIZE] = new_size;
  ADDR_WORD(new)[OBJSET_BITS] = bits;
  ADDR_WORD(new)[OBJSET_USED] = 0;
  ADDR_WORD(new)[OBJSET_DIRTY] = 0;
  for (i = 0; i < size; i++) {
    Obj obj = ADDR_OBJ(map)[OBJSET_HDRSIZE+i*2];
    if (obj && obj != Undefined) {
      AddObjMapNew(new, obj,
        ADDR_OBJ(map)[OBJSET_HDRSIZE+i*2+1]);
    }
  }
  PTR_BAG(map) = PTR_BAG(new);
  PTR_BAG(new) = old;
  CHANGED_BAG(map);
  CHANGED_BAG(new);
}


static Obj FuncOBJ_SET(Obj self, Obj arg) {
  Obj result;
  Obj list;
  UInt i, len;
  switch (LEN_PLIST(arg)) {
    case 0:
      return NewObjSet();
    case 1:
      list = ELM_PLIST(arg, 1);
      if (!IS_LIST(list))
        ErrorQuit("OBJ_SET: Argument must be a list", 0L, 0L);
      result = NewObjSet();
      len = LEN_LIST(list);
      for (i = 1; i <= len; i++) {
        Obj obj = ELM_LIST(list, i);
	if (obj)
	  AddObjSet(result, obj);
      }
      return result;
    default:
      ErrorQuit("OBJ_SET: Too many arguments", 0L, 0L);
      return (Obj) 0; /* flow control hint */
  }
}

static void CheckArgument(char *func, Obj obj, Int t1, Int t2) {
  Int tnum = TNUM_OBJ(obj);
  if (t2 < 0 && tnum == t1+IMMUTABLE) {
    ErrorQuit("%s: First argument must be a mutable %s",
      (Int) func,
      (Int) InfoBags[t1].name);
  }
  if (tnum != t1 && tnum != t2) {
    ErrorQuit("%s: First argument must be an %s",
      (Int) func,
      (Int) InfoBags[t1].name);
  }
}

static Obj FuncADD_OBJ_SET(Obj self, Obj set, Obj obj) {
  CheckArgument("ADD_OBJ_SET", set, T_OBJSET, -1);
  AddObjSet(set, obj);
  return (Obj) 0;
}

static Obj FuncREMOVE_OBJ_SET(Obj self, Obj set, Obj obj) {
  CheckArgument("REMOVE_OBJ_SET", set, T_OBJSET, -1);
  RemoveObjSet(set, obj);
  return (Obj) 0;
}

static Obj FuncFIND_OBJ_SET(Obj self, Obj set, Obj obj) {
  Int pos;
  CheckArgument("FIND_OBJ_SET", set, T_OBJSET, T_OBJSET+IMMUTABLE);
  pos = FindObjSet(set, obj);
  return pos >= 0 ? True : False;
}

static Obj FuncCLEAR_OBJ_SET(Obj self, Obj set) {
  CheckArgument("CLEAR_OBJ_SET", set, T_OBJSET, -1);
  ClearObjSet(set);
  return (Obj) 0;
}

static Obj FuncOBJ_MAP(Obj self, Obj arg) {
  Obj result;
  Obj list;
  UInt i, len;
  switch (LEN_PLIST(arg)) {
    case 0:
      return NewObjMap();
    case 1:
      list = ELM_PLIST(arg, 1);
      if (!IS_LIST(list) || LEN_LIST(list) % 2 != 0)
        ErrorQuit("OBJ_MAP: Argument must be a list with even length", 0L, 0L);
      result = NewObjMap();
      len = LEN_LIST(list);
      for (i = 1; i <= len; i += 2) {
        Obj key = ELM_LIST(list, i);
        Obj value = ELM_LIST(list, i+1);
	if (key && value)
	  AddObjMap(result, key, value);
      }
      return result;
    default:
      ErrorQuit("OBJ_MAP: Too many arguments", 0L, 0L);
      return (Obj) 0; /* flow control hint */
  }
}

static Obj FuncADD_OBJ_MAP(Obj self, Obj map, Obj key, Obj value) {
  CheckArgument("ADD_OBJ_MAP", map, T_OBJMAP, -1);
  AddObjMap(map, key, value);
  return (Obj) 0;
}

static Obj FuncFIND_OBJ_MAP(Obj self, Obj map, Obj key, Obj defvalue) {
  Int pos;
  CheckArgument("FIND_OBJ_MAP", map, T_OBJMAP, T_OBJMAP+IMMUTABLE);
  pos = FindObjMap(map, key);
  if (pos < 0)
    return defvalue;
  return ADDR_OBJ(map)[OBJSET_HDRSIZE + 2 * pos + 1];
}

static Obj FuncREMOVE_OBJ_MAP(Obj self, Obj map, Obj key) {
  CheckArgument("REMOVE_OBJ_MAP", map, T_OBJMAP, -1);
  RemoveObjMap(map, key);
  return (Obj) 0;
}

static Obj FuncCLEAR_OBJ_MAP(Obj self, Obj map) {
  CheckArgument("CLEAR_OBJ_MAP", map, T_OBJMAP, -1);
  ClearObjMap(map);
  return (Obj) 0;
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs [] = {

    { "OBJ_SET", -1, "[list]",
      FuncOBJ_SET, "src/objset.c:OBJ_SET" },

    { "ADD_OBJ_SET", 2, "objset, obj",
      FuncADD_OBJ_SET, "src/objset.c:ADD_OBJ_SET" },

    { "REMOVE_OBJ_SET", 2, "objset, obj",
      FuncREMOVE_OBJ_SET, "src/objset.c:REMOVE_OBJ_SET" },

    { "FIND_OBJ_SET", 2, "objset, obj",
      FuncFIND_OBJ_SET, "src/objset.c:FIND_OBJ_SET" },

    { "CLEAR_OBJ_SET", 1, "objset",
      FuncCLEAR_OBJ_SET, "src/objset.c:CLEAR_OBJ_SET" },

    { "OBJ_MAP", -1, "[list]",
      FuncOBJ_MAP, "src/objset.c:OBJ_MAP" },

    { "ADD_OBJ_MAP", 3, "objset, key, value",
      FuncADD_OBJ_MAP, "src/objset.c:ADD_OBJ_MAP" },

    { "REMOVE_OBJ_MAP", 2, "objset, obj",
      FuncREMOVE_OBJ_MAP, "src/objset.c:REMOVE_OBJ_MAP" },

    { "FIND_OBJ_MAP", 3, "objset, obj, default",
      FuncFIND_OBJ_MAP, "src/objset.c:FIND_OBJ_MAP" },

    { "CLEAR_OBJ_MAP", 1, "objset",
      FuncCLEAR_OBJ_MAP, "src/objset.c:CLEAR_OBJ_MAP" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  /* install info string */
  InfoBags[T_OBJSET].name = "object set";
  InfoBags[T_OBJSET+IMMUTABLE].name = "immutable object set";
  InfoBags[T_OBJMAP].name = "object map";
  InfoBags[T_OBJMAP+IMMUTABLE].name = "immutable object map";
  /* install kind functions */
  TypeObjFuncs[T_OBJSET] = TypeObjSet;
  TypeObjFuncs[T_OBJSET+IMMUTABLE] = TypeObjSet;
  TypeObjFuncs[T_OBJMAP] = TypeObjMap;
  TypeObjFuncs[T_OBJMAP+IMMUTABLE] = TypeObjMap;
  /* install global variables */
  InitCopyGVar("TYPE_OBJSET", &TYPE_OBJSET);
  InitCopyGVar("TYPE_OBJMAP", &TYPE_OBJMAP);
  /* install mark functions */
  InitMarkFuncBags(T_OBJSET, MarkObjSet);
  InitMarkFuncBags(T_OBJMAP, MarkObjMap);
  InitMarkFuncBags(T_OBJSET+IMMUTABLE, MarkObjSet);
  InitMarkFuncBags(T_OBJMAP+IMMUTABLE, MarkObjMap);
  /* install print functions */
  PrintObjFuncs[ T_OBJSET ] = PrintObjSet;
  PrintObjFuncs[ T_OBJSET+IMMUTABLE ] = PrintObjSet;
  PrintObjFuncs[ T_OBJMAP ] = PrintObjMap;
  PrintObjFuncs[ T_OBJMAP+IMMUTABLE ] = PrintObjMap;
  /* install mutability functions */
  IsMutableObjFuncs [ T_OBJSET ] = AlwaysMutable;
  IsMutableObjFuncs [ T_OBJSET+IMMUTABLE ] = NeverMutable;
  IsMutableObjFuncs [ T_OBJMAP ] = AlwaysMutable;
  IsMutableObjFuncs [ T_OBJMAP+IMMUTABLE ] = NeverMutable;
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
*F  InitInfoObjSet() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objset",                           /* name                           */
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

StructInitInfo * InitInfoObjSets ( void )
{
    FillInVersion( &module );
    return &module;
}
