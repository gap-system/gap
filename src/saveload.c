/****************************************************************************
**
*W  saveload.c                  GAP source                       Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions concerned with saving and loading
**  the workspace. There are support functions in gasman.c and elsewhere
**  throughout the kernel
*/
#include        "system.h"              /* system dependent part           */

SYS_CONST char * Revision_saveload_c =
   "@(#)$Id$";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "bool.h"                /* booleans                        */
#include        "calls.h"               /* generic call mechanism          */
#include        "gap.h"                 /* error handling, initialisation  */
#include        "gvars.h"               /* global variables                */
#include        "string.h"              /* strings                         */
#include        "scanner.h"             /* scanner                         */
#include        "sysfiles.h"            /* file input/output               */
#include        "plist.h"               /* plain lists                     */

#define INCLUDE_DECLARATION_PART
#include        "saveload.h"            /* saving and loading              */
#undef  INCLUDE_DECLARATION_PART


/***************************************************************************
**
** Temporary Stuff which will probably be revised to tie in with sysfiles
*/
#include <stdio.h>

static FILE * SaveFile = NULL;

static void OpenForSave( Obj fname ) 
{
  if (SaveFile)
    ErrorQuit("Already saving",0L,0L);
  SaveFile = fopen(CSTR_STRING(fname), "wb");
  if (!SaveFile)
    ErrorQuit("Panic: Couldn't open file %s ",(UInt)CSTR_STRING(fname),0L);
}


static void CloseAfterSave( void )
{
  if (!SaveFile)
    ErrorQuit("Not saving",0L,0L);
  fclose(SaveFile);
  SaveFile = NULL;
}

static FILE *LoadFile;


static void OpenForLoad( Obj fname ) 
{
  if (LoadFile)
    ErrorQuit("Already saving",0L,0L);
  LoadFile = fopen(CSTR_STRING(fname), "rb");
  if (!LoadFile)
    ErrorQuit("Panic: Couldn't open file %s ",(UInt)CSTR_STRING(fname),0L);
}


static void CloseAfterLoad( void )
{
  if (!LoadFile)
    ErrorQuit("Not saving",0L,0L);
  fclose(LoadFile);
  LoadFile = NULL;
}

#define SAVE_BYTE( byte ) (fputc((int) (byte), SaveFile))


UInt1 LOAD_BYTE ( void )
{
  int c;
  c = fgetc(LoadFile);
  if (c == EOF)
    ErrorQuit("Unexpected End of File in Load", 0L, 0L );
  return c;
}

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


#ifdef SYS_IS_64BIT

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
  res = (UInt)LOAD_BYTE();
  res |= (UInt)LOAD_BYTE() << 8;
  res |= (UInt)LOAD_BYTE() << 16;
  res |= (UInt)LOAD_BYTE() << 24;
  res |= (UInt)LOAD_BYTE() << 32;
  res |= (UInt)LOAD_BYTE() << 40;
  res |= (UInt)LOAD_BYTE() << 48;
  res |= (UInt)LOAD_BYTE() << 56;

  return res;
}


void SaveUInt( UInt data )
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

UInt8 LoadUInt ( void )
{
  UInt res;
  res = (UInt)LOAD_BYTE();
  res |= (UInt)LOAD_BYTE() << 8;
  res |= (UInt)LOAD_BYTE() << 16;
  res |= (UInt)LOAD_BYTE() << 24;
  res |= (UInt)LOAD_BYTE() << 32;
  res |= (UInt)LOAD_BYTE() << 40;
  res |= (UInt)LOAD_BYTE() << 48;
  res |= (UInt)LOAD_BYTE() << 56;

  return res;
}

#else

void SaveUInt( UInt data )
{
  SAVE_BYTE( (UInt1) (data & 0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 8) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 16) &0xFF) );
  SAVE_BYTE( (UInt1) ((data >> 24) &0xFF) );
}

UInt LoadUInt ( void )
{
  UInt res;
  res = (UInt)LOAD_BYTE();
  res |= (UInt)LOAD_BYTE() << 8;
  res |= (UInt)LOAD_BYTE() << 16;
  res |= (UInt)LOAD_BYTE() << 24;
  return res;
}

#endif

void SaveCStr( Char * str)
{
  do {
    SAVE_BYTE( (UInt1) *str);
  } while (*(str++));
}

#include <assert.h>

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
      Pr("Buffer overflow reading workspace",0L,0L);
      SyExit(1);
    }
}

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
           subobj > (Bag)OldBags ||
           (Bag *)PTR_BAG(subobj) < OldBags)
    {
      Pr("#W bad bag id %d found, 0 saved\n", (Int)subobj, 0L);
      SaveUInt(0);
    }
  else
    SaveUInt(((UInt)((PTR_BAG(subobj))[-1])) << 2);

}

Obj LoadSubObj()
{
  UInt word = LoadUInt();
  if (word == 0)
    return (Obj) 0;
  if ((word & 0x3) == 1 || (word & 0x3) == 2)
    return (Obj) word;
  else
    return (Obj)(MptrBags + (word >> 2));
}

void SaveHandler( ObjFunc hdlr )
{
  if (hdlr == (ObjFunc)0)
    SaveCStr("");
  else
    SaveCStr((Char *)CookieOfHandler(hdlr));
}


ObjFunc LoadHandler( )
{
  Char buf[256];
  LoadCStr(buf, 256);
  if (buf[0] == '\0')
    return (ObjFunc) 0;
  else
    return HandlerOfCookie(buf);
}


static UInt NextSaveIndex;

static void AddSaveIndex( Bag bag)
{
  PTR_BAG(bag)[-1] = (Obj)NextSaveIndex++;
}

static void RemoveSaveIndex( Bag bag)
{
  PTR_BAG(bag)[-1] = bag;
}


static void SaveBagData (Bag bag)
{
  /* Size-type word first */
  SaveUInt((UInt)PTR_BAG(bag)[-2]);

  /* dispatch */
  (*(SaveObjFuncs[ TNUM_BAG( bag )]))(bag);

}

/* temporary fudge */

static Bag NextBagRestoring(  UInt sizetype)
{
  return (Bag) 0;
}

static void LoadBagData ( )
{
  Bag bag;
  UInt sizetype;
  
  /* Recover the sizetype word */
  sizetype=LoadUInt();

  /* Get GASMAN to set up the bag for me */
  bag = NextBagRestoring( sizetype );
  
  /* despatch */
  (*(LoadObjFuncs[ sizetype & 0xFFL ]))(bag);
  
  return;
}


#define MAX_LOADED_MODULE_INFO 10000

static Char LoadedModuleInfo[MAX_LOADED_MODULE_INFO];
static Char *EndLoadedModuleInfo;
static UInt NLoadedModules;


void RecordLoadedModule( Obj filename, UInt4 crc )
{
  UInt len = SyStrlen(CSTR_STRING(filename));
  if (EndLoadedModuleInfo + len +1 >= LoadedModuleInfo + MAX_LOADED_MODULE_INFO)
    ErrorQuit("Panic: No room to record loaded module %d %s", 
              NLoadedModules,
              (Int)CSTR_STRING(filename));
  SyStrncat(EndLoadedModuleInfo, CSTR_STRING(filename), len+1);
  EndLoadedModuleInfo += len+1;
  *EndLoadedModuleInfo = '\0';
  NLoadedModules++;
  return;
}

Obj FuncLoadedModules( Obj self )
{
  Obj list, str;
  UInt i,len;
  Char *name;
  list = NEW_PLIST(T_PLIST_HOM+IMMUTABLE, NLoadedModules);
  name = LoadedModuleInfo;
  for (i = 1; i <= NLoadedModules; i++)
    {
      len = SyStrlen(name);
      str = NEW_STRING(len + 1);
      RetypeBag(str, T_STRING+IMMUTABLE);
      *CSTR_STRING(str) = '\0';
      SyStrncat(CSTR_STRING(str), name, len+1);
      name += len+1;
      SET_ELM_PLIST(list,i,str);
      CHANGED_BAG(list);
    }
  SET_LEN_PLIST(list,NLoadedModules);
  if (NLoadedModules == 0)
    RetypeBag(list,T_PLIST_EMPTY+IMMUTABLE);
  return list;
}

/***************************************************************************
**

*F  WriteSaveHeader( )
**
*/

static void WriteEndiannessMarker( void )
{
  UInt x;
#ifdef SYS_IS_64BIT
  x = 0x0102030405060708L;
#else
  x = 0x01020304L;
#endif
  SAVE_BYTE(((UInt1 *)&x)[0]);
  SAVE_BYTE(((UInt1 *)&x)[1]);
  SAVE_BYTE(((UInt1 *)&x)[2]);
  SAVE_BYTE(((UInt1 *)&x)[3]);
#if SYS_IS_64BIT
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
#ifdef SYS_IS_64BIT
  ((UInt1 *)&x)[4] = LOAD_BYTE();
  ((UInt1 *)&x)[5] = LOAD_BYTE();
  ((UInt1 *)&x)[6] = LOAD_BYTE();
  ((UInt1 *)&x)[7] = LOAD_BYTE();
  if (x != 0x0102030405060708L)
    ErrorQuit("Saved workspace with incompatible byte order %d",x,0L);
#else
  if (x != 0x01020304L)
    ErrorQuit("Saved workspace with incompatible byte order %d",x,0L);
#endif  
}

static void WriteSaveHeader( void )
{
  UInt i;
  Char *name;
#ifdef SYS_IS_64BIT
  SaveCStr( "GAP 4.0 beta 64 bit");
#else
  SaveCStr("GAP 4.0 beta 32 bit");
#endif
  WriteEndiannessMarker();
  
  SaveCStr("Counts and Sizes");
  SaveUInt(NLoadedModules);
  SaveUInt(GlobalBags.nr);
  SaveUInt(NextSaveIndex);
  SaveUInt(AllocBags - OldBags);
  
  SaveCStr("Loaded Modules");

  name = LoadedModuleInfo;
  for (i = 1; i <= NLoadedModules; i++)
    {
      SaveCStr(name);
      name += SyStrlen(name) + 1;
    }

  SaveCStr("Kernel to WS refs");
  for (i = 0; i < GlobalBags.nr; i++)
    {
      SaveCStr((Char *)GlobalBags.cookie[i]);
      SaveSubObj(*(GlobalBags.addr[i]));
    }
}


static UInt fb_minsize, fb_maxsize, fb_tnum;
static Bag hit;

static void ScanBag( Bag bag)
{
  if (hit == (Bag)0 && 
      SIZE_BAG(bag) >= fb_minsize && 
      SIZE_BAG(bag) <= fb_maxsize && 
      TNUM_BAG(bag) == fb_tnum) 
    hit = bag;
  return;
}

Obj FuncFindBag( Obj self, Obj minsize, Obj maxsize, Obj tnum )
{
  hit = (Bag) 0;
  fb_minsize = INT_INTOBJ(minsize);
  fb_maxsize = INT_INTOBJ(maxsize);
  fb_tnum = INT_INTOBJ(tnum);
  CallbackForAllBags(ScanBag);
  return (hit != (Bag) 0) ? hit : Fail;
}


/***************************************************************************
**
*F  SaveWorkspace( <fname> )  . . . . . save the workspace to the named file
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


Obj SaveWorkspace( Obj fname )
{

  /* Clean the copy and fopy info (which includes kernel refs) 
     out of the workspace */
  RemoveCopyFopyInfo( );

  /* Do a full garbage collection */
  CollectBags( 0, 1);
  
  /* Add indices in link words of all bags, for saving inter-bag references */
  NextSaveIndex = 0;
  CallbackForAllBags( AddSaveIndex );

  /* Now do the work */
  OpenForSave( fname );
  WriteSaveHeader();
  SaveCStr("Bag data");
  SortHandlers( 1 ); /* Sort by address to speed up CookieOfHandler */
  CallbackForAllBags( SaveBagData );
  CloseAfterSave();
  
  /* Finally, reset all the link words */
  CallbackForAllBags( RemoveSaveIndex );
  
  /* And reset the Copy and Fopy info, using the kernel copy */
  RestoreCopyFopyInfo ();

  /* Not all working yet */
  return Fail;
}




/***************************************************************************
**
*F  LoadWorkspace( <fname> )  . . . . . load the workspace to the named file
**
**  'LoadWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead as a keyword, so that we can be
**  sure it is only being called from the top-most prompt level
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
**  It may return Fail, in the original workspace, True, in the new workspace
**  or abort the system if an error arises too late to be safely averted
*/

static Obj IsReadableFile;

Obj LoadWorkspace( Obj fname )
{
  Obj fileok;
  fileok = CALL_1ARGS(IsReadableFile, fname);
  if (fileok == True)
    return False;
  else if (fileok == False)
    return Fail;
  else
    ErrorQuit("Panic: invalid return from IsReadable",0L,0L);  
  return 0; /* please lint */
}

#include        "finfield.h"            /* finite fields and ff elements   */

static void PrSavedObj( UInt x)
{
  if ((x & 3) == 1)
    Pr("Immediate  integer %d\n", INT_INTOBJ((Obj)x),0L);
  else if ((x & 3) == 2)
    Pr("Immedate FFE %d %d\n", VAL_FFE(x), SIZE_FF(FLD_FFE(x)));
  else
    Pr("Reference to bag number %d\n",x>>2,0L);
}

Obj FuncDumpWorkspace( Obj self, Obj fname )
{
  Obj fileok;
  UInt nMods, nGlobs, nBags, i;
  Char buf[256];
  fileok = CALL_1ARGS(IsReadableFile, fname);
  if (fileok == False)
    return Fail;
  else if (fileok != True)
    ErrorQuit("Panic: invalid return from IsReadable",0L,0L);  
  OpenForLoad( fname );
  LoadCStr(buf,256);
  Pr("Header string: %s\n",(Int) buf, 0L);
#ifdef SYS_IS_64BIT
  if (SyStrcmp(buf,"GAP 4.0 beta 64 bit") != 0)
#else
  if (SyStrcmp(buf,"GAP 4.0 beta 32 bit") != 0)
#endif
    ErrorQuit("Header is bad",0L,0L);
  CheckEndiannessMarker();
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf,0L);
  if (SyStrcmp(buf,"Counts and Sizes") != 0)
    ErrorQuit("Bad divider",0L,0L);
  Pr("Loaded modules: %d\n",nMods = LoadUInt(), 0L);
  Pr("Global Bags   : %d\n",nGlobs = LoadUInt(), 0L);
  Pr("Total Bags    : %d\n",nBags = LoadUInt(), 0L);
  Pr("Maximum Size  : %d\n",sizeof(Bag)*LoadUInt(), 0L);
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf, 0L);
  if (SyStrcmp(buf,"Loaded Modules") != 0)
    ErrorQuit("Bad divider",0L,0L);
  for (i = 0; i < nMods; i++)
    {
      LoadCStr(buf,256);
      Pr("  %s\n",(Int)buf,0L);
    }
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf,0L);
  if (SyStrcmp(buf,"Kernel to WS refs") != 0)
    ErrorQuit("Bad divider",0L,0L);
  for (i = 0; i < nGlobs; i++)
    {
      LoadCStr(buf,256);
      Pr("  %s ",(Int)buf,0L);
      PrSavedObj(LoadUInt());
    }
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf,0L);
  if (SyStrcmp(buf,"Bag data") != 0)
    ErrorQuit("Bad divider",0L,0L);
#if 0
  for (i = 0; i < nBags; i++)
    {
      sizetype = LoadUInt();
      Pr("Size %d type %s\n",sizetype >> 8, (Int)InfoBags[sizetype & 0xFF].name);
      if (LoadUInt() != 0xFFFFFFFF)
        ErrorQuit("Something saved in a bag body\n",0L,0L);
    }
#endif
  CloseAfterLoad();
  return (Obj) 0;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupSaveLoad( void ) . . . . . . . .  initialize the save/load workspace
*/
void SetupSaveLoad( void )
{
}
               

/****************************************************************************
**
*F  InitSaveLoad( void )  . . . . . . . .  initialize the save/load workspace
*/
void InitSaveLoad ( void )
{
  /* Initialize Fopys of file handling and other functions */
  InitFopyGVar( "IsReadableFile", &IsReadableFile );

  /* Create dummy variable, to support tab-completion */
  (void)GVarName("SaveWorkspace");

  /* Clean up the setup for RecordLoadedModule */
  NLoadedModules = 0;
  *LoadedModuleInfo = '\0';
  EndLoadedModuleInfo = LoadedModuleInfo;

  C_NEW_GVAR_FUNC( "LoadedModules", 0, "", 
                FuncLoadedModules,
    "src/saveload.c:LoadedModules" );

  C_NEW_GVAR_FUNC( "DumpWorkspace", 1, "fname", 
                FuncDumpWorkspace, 
    "src/saveload.c:DumpWorkspace" );

  C_NEW_GVAR_FUNC( "FindBag", 3, "minsize, maxsize, tnum", 
                FuncFindBag,
    "src/saveload.c:FindBag"  );
}
               

/****************************************************************************
**
*F  CheckSaveLoad( void ) check the initialisation of the save/load workspace
*/
void CheckSaveLoad ( void )
{
}
               

/****************************************************************************
**

*E  saveload.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
