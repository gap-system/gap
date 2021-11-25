/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions concerned with saving and loading
**  the workspace. There are support functions in gasman.c and elsewhere
**  throughout the kernel
*/

#include "saveload.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "finfield.h"
#ifdef USE_GASMAN
#include "gasman_intern.h"
#endif
#include "gvars.h"
#include "io.h"
#include "modules.h"
#include "read.h"
#include "streams.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "sysopt.h"
#include "sysstr.h"
#include "version.h"

#include <stdio.h>
#include <unistd.h>


#ifdef GAP_ENABLE_SAVELOAD

/***************************************************************************
**
** Temporary Stuff which will probably be revised to tie in with sysfiles
*/


static Int SaveFile;
static Int LoadFile = -1;
static UInt1 LoadBuffer[100000];
static UInt1* LBPointer;
static UInt1* LBEnd;
static Obj userHomeExpand;

static Int OpenForSave( Obj fname ) 
{
  if (SaveFile != -1)
    {
      Pr("Already saving\n", 0, 0);
      return 1;
    }
    SaveFile = SyFopen(CONST_CSTR_STRING(fname), "wb", TRUE);
    if (SaveFile == -1) {
        Pr("Couldn't open file %s to save workspace\n",
           (UInt)CONST_CSTR_STRING(fname), 0);
        return 1;
    }
  LBPointer = LoadBuffer;
  LBEnd = LBPointer+sizeof(LoadBuffer);
  return 0;
}

static void CloseAfterSave( void )
{
  if (SaveFile == -1)
    {
      Panic("Internal error -- this should never happen");
    }

  if (SyWrite(SaveFile, LoadBuffer, LBPointer - LoadBuffer) < 0)
    ErrorQuit("Cannot write to file, see 'LastSystemError();'\n", 0, 0);
  SyFclose(SaveFile);
  SaveFile = -1;
}

static void OpenForLoad( const Char *fname ) 
{
  if (LoadFile != -1)
    {
      Panic("Internal error -- this should never happen");
    }
    LoadFile = SyFopen(fname, "rb", TRUE);
    if (LoadFile == -1) {
        Pr("Couldn't open saved workspace %s\n", (Int)fname, 0);
        SyExit(1);
    }
}


static void CloseAfterLoad( void )
{
  if (!LoadFile)
    {
      Panic("Internal error -- this should never happen");
    }
  SyFclose(LoadFile);
  LoadFile = -1;
}

static void SAVE_BYTE_BUF(void)
{
  if (SyWrite(SaveFile, LoadBuffer, LBEnd - LoadBuffer) < 0)
    ErrorQuit("Cannot write to file, see 'LastSystemError();'\n", 0, 0);
  LBPointer = LoadBuffer;
  return;
}

#define SAVE_BYTE(byte) {if (LBPointer >= LBEnd) {SAVE_BYTE_BUF();} \
                          *LBPointer++ = (UInt1)(byte);}

static UInt1 LOAD_BYTE_BUF(void)
{
  Int ret;
  ret = SyRead(LoadFile, LoadBuffer, sizeof(LoadBuffer));
  if (ret <= 0)
    {
      Panic("Unexpected End of File in Load");
    }
  LBEnd = LoadBuffer + ret;
  LBPointer = LoadBuffer;
  return *LBPointer++;   
}

#define LOAD_BYTE()    (UInt1)((LBPointer >= LBEnd) ?\
                                  (LOAD_BYTE_BUF()) : (*LBPointer++))

/***************************************************************************
**
**  Low level saving routines
*/

void SaveUInt1( UInt1 data )
{
  SAVE_BYTE( data );
}

UInt1 LoadUInt1( void )
{
  return LOAD_BYTE( );
}

void SaveUInt2( UInt2 data )
{
  SAVE_BYTE( (UInt1) (data & 0xFF) );
  SAVE_BYTE( (UInt1) (data >> 8) );
}

UInt2 LoadUInt2 ( void )
{
  UInt2 res;
  res = (UInt2)LOAD_BYTE();
  res |= (UInt2)LOAD_BYTE()<<8;
  return res;
}

void SaveUInt4( UInt4 data )
{
  SAVE_BYTE( (UInt1) (data & 0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 8) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 16) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 24) &0xFF) );
}

UInt4 LoadUInt4 ( void )
{
  UInt4 res;
  res = (UInt)LOAD_BYTE();
  res |= (UInt)LOAD_BYTE() << 8;
  res |= (UInt)LOAD_BYTE() << 16;
  res |= (UInt)LOAD_BYTE() << 24;
  return res;
}

void SaveUInt8( UInt8 data )
{
  SAVE_BYTE( (UInt1) (data & 0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 8) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 16) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 24) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 32) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 40) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 48) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 56) &0xFF) );
}

UInt8 LoadUInt8 ( void )
{
  UInt8 res;
  res = (UInt8)LOAD_BYTE();
  res |= (UInt8)LOAD_BYTE() << 8;
  res |= (UInt8)LOAD_BYTE() << 16;
  res |= (UInt8)LOAD_BYTE() << 24;
  res |= (UInt8)LOAD_BYTE() << 32;
  res |= (UInt8)LOAD_BYTE() << 40;
  res |= (UInt8)LOAD_BYTE() << 48;
  res |= (UInt8)LOAD_BYTE() << 56;

  return res;
}

void SaveUInt( UInt data )
{
#ifdef SYS_IS_64_BIT
    SaveUInt8(data);
#else
    SaveUInt4(data);
#endif
}

UInt LoadUInt ( void )
{
#ifdef SYS_IS_64_BIT
    return LoadUInt8();
#else
    return LoadUInt4();
#endif
}

void SaveCStr( const Char * str)
{
  do {
    SAVE_BYTE( (UInt1) *str);
  } while (*(str++));
}

void LoadCStr( Char *buf, UInt maxsize)
{
  UInt nread = 0;
  UInt1 c = 1;
  assert(maxsize > 0);
  while (c != '\0' && nread < maxsize )
    {
      c = LOAD_BYTE();
      *buf++ = (Char) c;
      nread++;
    }
  if (c != '\0')
    {
      Panic("Buffer overflow reading workspace");
    }
}


/****************************************************************************
**
*F  SaveString( <string> )  . . . . . . . . . . . . . . . . . . save a string
**
*/
void SaveString ( Obj string )
{
  UInt i, len = GET_LEN_STRING(string);
  const UInt1 *p = CONST_CHARS_STRING(string);
  SaveUInt(len);
  for (i=0; i<len; i++)
    SAVE_BYTE(p[i]);
}

/****************************************************************************
**
*F  LoadString( <string> )
**
*/
void LoadString ( Obj string )
{
  UInt i, len;
  UInt1 c;
  UInt1 *p = (UInt1*)CHARS_STRING(string);
  len = LoadUInt();
  SET_LEN_STRING(string, len);
  for (i=0; i<len; i++) {
    c = LOAD_BYTE();
    p[i] = c;
  }
}

#ifdef USE_GASMAN

void SaveSubObj( Obj subobj )
{
  if (!subobj)
    SaveUInt(0);
  else if (IS_INTOBJ(subobj))
    SaveUInt((UInt) subobj);
  else if (IS_FFE(subobj))
    SaveUInt((UInt) subobj);
  else if ((((UInt)subobj & 3) != 0) || 
           subobj < (Bag)MptrBags || 
           subobj > (Bag)MptrEndBags ||
           (Bag *)PTR_BAG(subobj) < MptrEndBags)
    {
      Pr("#W bad bag id %d found, 0 saved\n", (Int)subobj, 0);
      GAP_ASSERT(0);
      SaveUInt(0);
    }
  else
    SaveUInt(((UInt)LINK_BAG(subobj)) << 2);
}

Obj LoadSubObj( void )
{
  UInt word = LoadUInt();
  if (word == 0)
    return (Obj) 0;
  if ((word & 0x3) == 1 || (word & 0x3) == 2)
    return (Obj) word;
  else
    return (Obj)(MptrBags + (word >> 2)-1);
}

#endif

/***************************************************************************
**
**  Bag level saving routines
*/

#ifdef USE_GASMAN

static void SaveBagData (Bag bag )
{
  BagHeader * header = BAG_HEADER(bag);
  SaveUInt1(header->type);
  SaveUInt1(header->flags);
  SaveUInt(header->size);

  /* dispatch */
  (*(SaveObjFuncs[ header->type]))(bag);
}


static void LoadBagData ( void )
{
  Bag bag;
  UInt type, flags, size;
  
  /* Recover the size & type */
  type = LoadUInt1();
  flags = LoadUInt1();
  size = LoadUInt();

  if (TNAM_TNUM(type) == NULL)
    Panic("Bad type %d, size %d\n", (int)type, (int)size);

  /* Get GASMAN to set up the bag for me */
  bag = NextBagRestoring( type, flags, size );
  
  /* dispatch */
  (*(LoadObjFuncs[ type ]))(bag);
}

#endif

/***************************************************************************
**
*F  WriteSaveHeader() . . . . .  and utility functions, and loading functions
**
*/

static void WriteEndiannessMarker( void )
{
  UInt x;
#ifdef SYS_IS_64_BIT
  x = 0x0102030405060708L;
#else
  x = 0x01020304L;
#endif
  SAVE_BYTE(((UInt1 *)&x)[0]);
  SAVE_BYTE(((UInt1 *)&x)[1]);
  SAVE_BYTE(((UInt1 *)&x)[2]);
  SAVE_BYTE(((UInt1 *)&x)[3]);
#ifdef SYS_IS_64_BIT
  SAVE_BYTE(((UInt1 *)&x)[4]);
  SAVE_BYTE(((UInt1 *)&x)[5]);
  SAVE_BYTE(((UInt1 *)&x)[6]);
  SAVE_BYTE(((UInt1 *)&x)[7]);
#endif
}


static void CheckEndiannessMarker( void )
{
  UInt x;
  ((UInt1 *)&x)[0] = LOAD_BYTE();
  ((UInt1 *)&x)[1] = LOAD_BYTE();
  ((UInt1 *)&x)[2] = LOAD_BYTE();
  ((UInt1 *)&x)[3] = LOAD_BYTE();
#ifdef SYS_IS_64_BIT
  ((UInt1 *)&x)[4] = LOAD_BYTE();
  ((UInt1 *)&x)[5] = LOAD_BYTE();
  ((UInt1 *)&x)[6] = LOAD_BYTE();
  ((UInt1 *)&x)[7] = LOAD_BYTE();
  if (x != 0x0102030405060708L)
#else
  if (x != 0x01020304L)
#endif  
    {
      Panic("Saved workspace with incompatible byte order");
    }
}


/***************************************************************************
**
**  FuncBagStats
*/

#ifdef USE_GASMAN

static FILE *file;

static void report( Bag bag)
{
  fprintf(file,"%li %li\n", (long) TNUM_BAG(bag), (long) SIZE_BAG(bag));
}

static Obj FuncBagStats(Obj self, Obj filename)
{
  file = fopen((Char *)CHARS_STRING(filename),"w");
  CallbackForAllBags(report);
  fclose(file);
  return (Obj) 0;
}

#endif


/***************************************************************************
**
**  Find Bags -- a useful debugging tool -- scan for a bag of specified
**   type and size and return it to the GAP level. Could be a problem
**  if the bag is not a valid GAP object -- eg a local variables bag or
**  a functions body.
*/

#ifdef USE_GASMAN

static UInt fb_minsize, fb_maxsize, fb_tnum;
static Bag hit;

static void ScanBag( Bag bag)
{
  if (hit == (Bag)0 && 
      SIZE_BAG(bag) >= fb_minsize && 
      SIZE_BAG(bag) <= fb_maxsize && 
      TNUM_BAG(bag) == fb_tnum) 
    hit = bag;
}

static Obj FuncFindBag(Obj self, Obj minsize, Obj maxsize, Obj tnum)
{
  hit = (Bag) 0;
  fb_minsize = INT_INTOBJ(minsize);
  fb_maxsize = INT_INTOBJ(maxsize);
  fb_tnum = INT_INTOBJ(tnum);
  CallbackForAllBags(ScanBag);
  return (hit != (Bag) 0) ? hit : Fail;
}

#endif


/***************************************************************************
**
*F  SaveWorkspace( <fname> )  . . . . .  save the workspace to the named file
**
**  'SaveWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead as a keyword, so that we can be
**  sure it is only being called from the top-most prompt level
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
**  The return value is either True or Fail
*/

#ifdef USE_GASMAN

static UInt NextSaveIndex = 1;

static void AddSaveIndex( Bag bag)
{
  LINK_BAG(bag) = (Obj)NextSaveIndex++;
}

static void RemoveSaveIndex( Bag bag)
{
  LINK_BAG(bag) = bag;
}

#endif

static Char * GetKernelDescription(void)
{
    static Char SyKernelDescription[256];
    strcpy(SyKernelDescription, SyKernelVersion);
    if (SyUseReadline) {
        strcat(SyKernelDescription, " with readline");
    }
    return SyKernelDescription;
}

static void WriteSaveHeader( void )
{
  UInt i;
  
  SaveCStr("GAP workspace");
  SaveCStr(GetKernelDescription());

#ifdef SYS_IS_64_BIT             
  SaveCStr("64 bit");
#else
  SaveCStr("32 bit");
#endif

  WriteEndiannessMarker();
  
  SaveCStr("Counts and Sizes");
  for (i = 0; i < GlobalBags.nr; i++) {
      GAP_ASSERT(GlobalBags.cookie[i] != NULL);
  }
  SaveUInt(GlobalBags.nr);
  SaveUInt(NextSaveIndex-1);
  SaveUInt(AllocBags - MptrEndBags);

  SaveCStr("Loaded Modules");
  SaveModules();

  SaveCStr("Kernel to WS refs");
  for (i = 0; i < GlobalBags.nr; i++)
    {
      GAP_ASSERT(GlobalBags.cookie[i] != NULL);
      SaveCStr((const Char *)GlobalBags.cookie[i]);
      SaveSubObj(*(GlobalBags.addr[i]));
    }
}

Obj SaveWorkspace( Obj fname )
{
  Obj fullname;
  Obj result;

  if (!IsStringConv(fname))
    ErrorQuit("usage: SaveWorkspace( <filename> )",0,0);
  /* maybe expand fname starting with ~/...   */
  fullname = Call1ArgsInNewReader(userHomeExpand, fname);
  
  if (ModulesPreSave())
    return Fail;

  /* Do a full garbage collection */
  CollectBags( 0, 1);
  
  /* Add indices in link words of all bags, for saving inter-bag references */
  NextSaveIndex = 1;
  CallbackForAllBags( AddSaveIndex );

  /* Now do the work */
  result = Fail;
  if (!OpenForSave( fullname ))
    {
      result = True;
      WriteSaveHeader();
      SaveCStr("Bag data");
      SortHandlers( 1 ); /* Sort by address to speed up CookieOfHandler */
      CallbackForAllBags( SaveBagData );
      CloseAfterSave();
    }
      
  /* Finally, reset all the link words */
  CallbackForAllBags( RemoveSaveIndex );
  
  /* Restore situation by calling all post-save methods */
  ModulesPostSave();

  return result;
}


/***************************************************************************
**
*F  LoadWorkspace( <fname> )  . . . . .  load the workspace to the named file
**
**  'LoadWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead called from InitializeGap when
**  the -L command-line flag is given
**
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
*/
void LoadWorkspace( Char * fname )
{
  UInt nGlobs, nBags, i, maxSize;
  Char buf[256];
  Obj * glob;

  /* Open saved workspace  */
  OpenForLoad( fname );

  /* Check file header */

  LoadCStr(buf,256);
  if (strncmp (buf, "GAP ", 4) != 0) {
     Panic("File %s does not appear to be a GAP workspace", fname);
  }

  if (streq(buf, "GAP workspace")) {

     LoadCStr(buf,256);
     if (!streq(buf, GetKernelDescription())) {
         Panic("This workspace is not compatible with GAP kernel (%s, present: "
            "%s)", buf, GetKernelDescription());
     }

     LoadCStr(buf,256);
#ifdef SYS_IS_64_BIT             
     if (!streq(buf,"64 bit"))
#else
     if (!streq(buf,"32 bit"))
#endif
        {
           Panic("This workspace was created by a %s version of GAP", buf);
        }
  } else {
     Panic("File %s probably isn't a GAP workspace", fname);
  } 
  
  CheckEndiannessMarker();
  
  LoadCStr(buf,256);
  if (!streq(buf,"Counts and Sizes"))
    {
      Panic("Bad divider");
    }
  
  nGlobs = LoadUInt();
  nBags = LoadUInt();
  maxSize = LoadUInt();

  /* Make sure there is enough room, and signal GASMAN that
     we are starting a restore */
  StartRestoringBags(nBags, maxSize);

  /* The restoring kernel must have at least as many compiled modules
     as the saving one. */
  LoadCStr(buf,256);
  if (!streq(buf,"Loaded Modules"))
    {
      Panic("Bad divider");
    }
  LoadModules();

  /* Now the kernel variables that point into the workspace */
  LoadCStr(buf,256);
  if (!streq(buf,"Kernel to WS refs"))
    {
      Panic("Bad divider");
    }
    SortGlobals();    // globals by cookie for quick lookup
    // TODO: the goal here is to stop exporting `GlobalBags` completely...
    if (nGlobs != GlobalBags.nr) {
        Panic("Wrong number of global bags in saved workspace %d %d",
              (int)nGlobs, (int)GlobalBags.nr);
    }
    for (i = 0; i < nGlobs; i++) {
        LoadCStr(buf, 256);
        glob = GlobalByCookie(buf);
        if (glob == (Obj *)0) {
            Panic(
                "Global object cookie from workspace not found in kernel %s",
                buf);
        }
      *glob = LoadSubObj();
      if (SyDebugLoading)
          Pr("Restored global %s\n", (Int)buf, 0);
    }

  LoadCStr(buf,256);
  if (!streq(buf,"Bag data"))
    {
      Panic("Bad divider");
    }
  
  SortHandlers(2);
  for (i = 0; i < nBags; i++)
    LoadBagData();

  FinishedRestoringBags();

  CloseAfterLoad();

    ModulesPostRestore();
}

static void PrSavedObj( UInt x)
{
  if ((x & 3) == 1)
    Pr("Immediate integer %d\n", INT_INTOBJ((Obj)x), 0);
  else if ((x & 3) == 2)
    Pr("Immediate FFE %d %d\n", VAL_FFE((Obj)x), SIZE_FF(FLD_FFE((Obj)x)));
  else
    Pr("Reference to bag number %d\n",x>>2, 0);
}

static Obj FuncDumpWorkspace(Obj self, Obj fname)
{
  UInt nMods, nGlobs, nBags, i, relative;
  Char buf[256];
  OpenForLoad( CONST_CSTR_STRING(fname) );
  LoadCStr(buf,256);
  Pr("Header string: %s\n", (Int)buf, 0);
  LoadCStr(buf,256);
  Pr("GAP Version: %s\n", (Int)buf, 0);
  LoadCStr(buf,256);
  Pr("Word length: %s\n", (Int)buf, 0);
  CheckEndiannessMarker();
  LoadCStr(buf,256);
  Pr("Divider string: %s\n", (Int)buf, 0);
  if (!streq(buf, "Counts and Sizes"))
      ErrorQuit("Bad divider", 0, 0);
  Pr("Loaded modules: %d\n", nMods = LoadUInt(), 0);
  Pr("Global Bags   : %d\n", nGlobs = LoadUInt(), 0);
  Pr("Total Bags    : %d\n", nBags = LoadUInt(), 0);
  Pr("Maximum Size  : %d\n", sizeof(Bag) * LoadUInt(), 0);
  LoadCStr(buf,256);
  Pr("Divider string: %s\n", (Int)buf, 0);
  if (!streq(buf, "Loaded Modules"))
      ErrorQuit("Bad divider", 0, 0);
  for (i = 0; i < nMods; i++)
    {
      UInt type;
      type = LoadUInt();
      Pr("Type: %d ",type,0);
      relative = LoadUInt();
      if (relative)
        Pr("GAP root relative ", 0, 0);
      else
        Pr("absolute ", 0, 0);
      LoadCStr(buf,256);
      Pr("  %s\n",(Int)buf, 0);
    }
  LoadCStr(buf,256);
  Pr("Divider string: %s\n", (Int)buf, 0);
  if (!streq(buf, "Kernel to WS refs"))
      ErrorQuit("Bad divider", 0, 0);
  for (i = 0; i < nGlobs; i++)
    {
      LoadCStr(buf,256);
      Pr("  %s ", (Int)buf, 0);
      PrSavedObj(LoadUInt());
    }
  LoadCStr(buf,256);
  Pr("Divider string: %s\n", (Int)buf, 0);
  if (!streq(buf, "Bag data"))
      ErrorQuit("Bad divider", 0, 0);
  CloseAfterLoad();
  return (Obj) 0;
}

#endif // GAP_ENABLE_SAVELOAD


static Obj FuncSaveWorkspace(Obj self, Obj filename)
{
#ifdef GAP_ENABLE_SAVELOAD
    return SaveWorkspace(filename);
#else
    ErrorMayQuit("SaveWorkspace is only supported when GASMAN is in use", 0, 0);
    return Fail;
#endif
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(SaveWorkspace, fname),
#ifdef GAP_ENABLE_SAVELOAD
    GVAR_FUNC_1ARGS(DumpWorkspace, fname),
#ifdef USE_GASMAN
    GVAR_FUNC_3ARGS(FindBag, minsize, maxsize, tnum),
    GVAR_FUNC_1ARGS(BagStats, filename),
#endif
#endif
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
#ifdef GAP_ENABLE_SAVELOAD
    SaveFile = -1;
    LBPointer = LoadBuffer;
    LBEnd = LoadBuffer;

    /* allow ~/... expansion in SaveWorkspace                              */ 
    ImportFuncFromLibrary("UserHomeExpand", &userHomeExpand);
#endif

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

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

    return 0;
}


/****************************************************************************
**
*F  InitInfoSaveLoad()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "saveload",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoSaveLoad ( void )
{
    return &module;
}
