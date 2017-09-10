/****************************************************************************
**
*W  saveload.c                  GAP source                       Steve Linton
**
**
*Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions concerned with saving and loading
**  the workspace. There are support functions in gasman.c and elsewhere
**  throughout the kernel
*/
#include <src/system.h>                 /* system dependent part */


#include <unistd.h>                     /* write, read */
   
#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/bool.h>                   /* booleans */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/gap.h>                    /* error handling, initialisation */
#include <src/gvars.h>                  /* global variables */
#include <src/streams.h>                /* streams */
#include <src/stringobj.h>              /* strings */
#include <src/scanner.h>                /* scanner */
#include <src/sysfiles.h>               /* file input/output */
#include <src/plist.h>                  /* plain lists */
#include <src/macfloat.h>               /* floating points */
#include <src/compstat.h>               /* statically compiled modules */
#include <src/read.h>                   /* to call function from library */

#include <src/saveload.h>               /* saving and loading */

#include <src/code.h>                   /* coder */

#include <src/gaputils.h>

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

#if !defined(BOEHM_GC)

static Int OpenForSave( Obj fname ) 
{
  if (SaveFile != -1)
    {
      Pr("Already saving",0L,0L);
      return 1;
    }
  SaveFile = SyFopen(CSTR_STRING(fname), "wb");
  if (SaveFile == -1)
    {
      Pr("Couldn't open file %s to save workspace",
	 (UInt)CSTR_STRING(fname),0L);
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
      Pr("Internal error -- this should never happen",0L,0L);
      SyExit(2);
    }

  if (write(syBuf[SaveFile].fp, LoadBuffer, LBPointer-LoadBuffer) < 0)
    ErrorQuit("Cannot write to file descriptor %d, see 'LastSystemError();'\n",
               syBuf[SaveFile].fp, 0L);
  SyFclose(SaveFile);
  SaveFile = -1;
}

#endif

static void OpenForLoad( Char *fname ) 
{
  if (LoadFile != -1)
    {
      Pr("Internal error -- this should never happen\n",0L,0L);
      SyExit(2);
    }
  LoadFile = SyFopen(fname, "rb");
  if (LoadFile == -1)
    {
      Pr("Couldn't open saved workspace %s\n",(Int)fname,0L);
      SyExit(1);
    }
}


static void CloseAfterLoad( void )
{
  if (!LoadFile)
    {
      Pr("Internal error -- this should never happen\n",0L,0L);
      SyExit(2);
    }
  SyFclose(LoadFile);
  LoadFile = -1;
}

void SAVE_BYTE_BUF( void )
{
  if (write(syBuf[SaveFile].fp, LoadBuffer, LBEnd-LoadBuffer) < 0)
    ErrorQuit("Cannot write to file descriptor %d, see 'LastSystemError();'\n",
               syBuf[SaveFile].fp, 0L);
  LBPointer = LoadBuffer;
  return;
}

#define SAVE_BYTE(byte) {if (LBPointer >= LBEnd) {SAVE_BYTE_BUF();} \
                          *LBPointer++ = (UInt1)(byte);}

const Char * LoadByteErrorMessage = "Unexpected End of File in Load\n";

UInt1 LOAD_BYTE_BUF( void )
{
  Int ret;
  ret = read(syBuf[LoadFile].fp, LoadBuffer, 100000);
  if (ret <= 0)
    {
      Pr(LoadByteErrorMessage, 0L, 0L );
      SyExit(2);
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


#ifdef SYS_IS_64_BIT

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

void SaveCStr( const Char * str)
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
      Pr("Buffer overflow reading workspace\n",0L,0L);
      SyExit(1);
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
  UInt1 *p = (UInt1*)CHARS_STRING(string);
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

void SaveSubObj( Obj subobj )
{
#ifdef BOEHM_GC
  // FIXME: HACK
  assert(0);
#else
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
    SaveUInt(((UInt)LINK_BAG(subobj)) << 2);
#endif
}

Obj LoadSubObj( void )
{
#ifdef BOEHM_GC
  // FIXME: HACK
  assert(0);
#else
  UInt word = LoadUInt();
  if (word == 0)
    return (Obj) 0;
  if ((word & 0x3) == 1 || (word & 0x3) == 2)
    return (Obj) word;
  else
    return (Obj)(MptrBags + (word >> 2)-1);
#endif
}

void SaveHandler( ObjFunc hdlr )
{
  const Char * cookie;
  if (hdlr == (ObjFunc)0)
    SaveCStr("");
  else
    {
      cookie = CookieOfHandler(hdlr);
      if (!cookie)
	{
	  Pr("No cookie for Handler -- workspace will be corrupt\n",0,0);
	  SaveCStr("");
	}
      SaveCStr(cookie);
    }
}


ObjFunc LoadHandler( void )
{
  Char buf[256];
  LoadCStr(buf, 256);
  if (buf[0] == '\0')
    return (ObjFunc) 0;
  else
    return HandlerOfCookie(buf);
}


void SaveDouble( Double d)
{
  UInt i;
  UInt1 buf[sizeof(Double)];
  memcpy((void *) buf, (void *)&d, sizeof(Double));
  for (i = 0; i < sizeof(Double); i++)
    SAVE_BYTE(buf[i]);
}

Double LoadDouble( void )
{
  UInt i;
  UInt1 buf[sizeof(Double)];
  Double d;
  for (i = 0; i < sizeof(Double); i++)
    buf[i] = LOAD_BYTE();
  memcpy((void *)&d, (void *)buf, sizeof(Double));
  return d;
}

/***************************************************************************
**
**  Bag level saving routines
*/

#if !defined(BOEHM_GC)

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

#ifdef DEBUG_LOADING
  {
    if (InfoBags[type].name == NULL)
      {
        Pr("Bad type %d, size %d\n",type,size);
        exit(1);
      }
  }
  
#endif  

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

#if !defined(BOEHM_GC)

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

#endif


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
      Pr("Saved workspace with incompatible byte order\n",0L,0L);
      SyExit(1);
    }
}


/***************************************************************************
**
**  FuncBagStats
*/

static FILE *file;

static void report( Bag bag)
{
  fprintf(file,"%li %li\n", (long) TNUM_BAG(bag), (long) SIZE_BAG(bag));
}

Obj FuncBagStats(Obj self, Obj filename)
{
  file = fopen((Char *)CHARS_STRING(filename),"w");
  CallbackForAllBags(report);
  fclose(file);
  return (Obj) 0;
}

/***************************************************************************
**
**  Find Bags -- a useful debugging tool -- scan for a bag of specified
**   type and size and return it to the GAP level. Could be a problem
**  if the bag is not a valid GAP object -- eg a local variables bag or
**  a functions body.
*/


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

#if !defined(BOEHM_GC)

static UInt NextSaveIndex = 1;

static void AddSaveIndex( Bag bag)
{
  LINK_BAG(bag) = (Obj)NextSaveIndex++;
}

static void RemoveSaveIndex( Bag bag)
{
  LINK_BAG(bag) = bag;
}

static void WriteSaveHeader( void )
{
  UInt i;
  UInt globalcount = 0;
  
  SaveCStr("GAP workspace");
  SaveCStr(SyKernelVersion);

#ifdef SYS_IS_64_BIT             
  SaveCStr("64 bit");
#else
  SaveCStr("32 bit");
#endif

  WriteEndiannessMarker();
  
  SaveCStr("Counts and Sizes");
  SaveUInt(NrModules - NrBuiltinModules);
  for (i = 0; i < GlobalBags.nr; i++)
    if (GlobalBags.cookie[i] != NULL)
      globalcount++;
  SaveUInt(globalcount);
  SaveUInt(NextSaveIndex-1);
  SaveUInt(AllocBags - OldBags);
  
  SaveCStr("Loaded Modules");

  for ( i = NrBuiltinModules; i < NrModules; i++)
    {
      SaveUInt(Modules[i].info->type);
      SaveUInt(Modules[i].isGapRootRelative);
      SaveCStr(Modules[i].filename);
    }

  SaveCStr("Kernel to WS refs");
  for (i = 0; i < GlobalBags.nr; i++)
    {
      if (GlobalBags.cookie[i] != NULL)
	{
	  SaveCStr((const Char *)GlobalBags.cookie[i]);
	  SaveSubObj(*(GlobalBags.addr[i]));
	}
    }
}
#endif

Obj SaveWorkspace( Obj fname )
{
#ifdef BOEHM_GC
  Pr("SaveWorkspace is not currently supported when Boehm GC is in use",0,0);
  return Fail;

#else
  Int i;
  Obj fullname;
  StructInitInfo * info;

  if (!IsStringConv(fname))
    ErrorQuit("usage: SaveWorkspace( <filename> )",0,0);
  /* maybe expand fname starting with ~/...   */
  fullname = Call1ArgsInNewReader(userHomeExpand, fname);
  
  for (i = 0; i < NrModules; i++) {
    info = Modules[i].info;
    if (info->preSave != NULL && info->preSave(info)) {
        Pr("Failed to save workspace -- problem reported in %s\n",
           (Int)info->name, 0L);
        for ( i--; i >= 0; i--)
          info->postSave(info);
        return Fail;
    }
  }

  /* Do a full garbage collection */
  CollectBags( 0, 1);
  
  /* Add indices in link words of all bags, for saving inter-bag references */
  NextSaveIndex = 1;
  CallbackForAllBags( AddSaveIndex );

  /* Now do the work */
  if (!OpenForSave( fullname ))
    {
      WriteSaveHeader();
      SaveCStr("Bag data");
      SortHandlers( 1 ); /* Sort by address to speed up CookieOfHandler */
      CallbackForAllBags( SaveBagData );
      CloseAfterSave();
    }
      
  /* Finally, reset all the link words */
  CallbackForAllBags( RemoveSaveIndex );
  
  /* Restore situation by calling all post-save methods */
  for (i = 0; i < NrModules; i++) {
    info = Modules[i].info;
    if (info->postSave != NULL)
      info->postSave(info);
  }

  return True;
#endif
}


Obj FuncSaveWorkspace(Obj self, Obj filename )
{
  return SaveWorkspace( filename );
}


/***************************************************************************
**
*F  LoadWorkspace( <fname> )  . . . . .  load the workspace to the named file
**
**  'LoadWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead called from InitGap when the
**  -L commad-line flag is given
**
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
*/


void LoadWorkspace( Char * fname )
{
#ifdef BOEHM_GC
  Pr("LoadWorkspace is not currently supported when Boehm GC is in use",0,0);
  return;

#else
  UInt nMods, nGlobs, nBags, i, maxSize;
  UInt globalcount = 0;
  Char buf[256];
  Obj * glob;
  Int res;

  /* Open saved workspace  */
  OpenForLoad( fname );

  /* Check file header */

  LoadCStr(buf,256);
  if (strncmp (buf, "GAP ", 4) != 0) {
     Pr("File %s does not appear to be a GAP workspae.\n", (long) fname, 0L);
     SyExit(1);
  }

  if (strcmp (buf, "GAP workspace") == 0) {

     LoadCStr(buf,256);
     if (strcmp (buf, SyKernelVersion) != 0) {
        Pr("This workspace is not compatible with GAP kernel (%s, present: %s).\n", 
           (long)buf, (long)SyKernelVersion);
        SyExit(1);
     }

     LoadCStr(buf,256);
#ifdef SYS_IS_64_BIT             
     if (strcmp(buf,"64 bit") != 0)
#else
     if (strcmp(buf,"32 bit") != 0)
#endif
        {
           Pr("This workspace was created by a %s version of GAP.\n", (long)buf, 0L);
           SyExit(1);
        }
  } else {
     Pr("File %s probably isn't a GAP workspace.\n", (long)fname, 0L);
     SyExit(1);
  } 
  
  CheckEndiannessMarker();
  
  LoadCStr(buf,256);
  if (strcmp(buf,"Counts and Sizes") != 0)
    {
      Pr("Bad divider\n",0L,0L);
      SyExit(1);
    }
  
  nMods = LoadUInt();
  nGlobs = LoadUInt();
  nBags = LoadUInt();
  maxSize = LoadUInt();

  /* Make sure there is enough room, and signal GASMAN that
     we are starting a restore */
  StartRestoringBags(nBags, maxSize);

  /* The restoring kernel must have at least as many compiled modules
     as the saving one. */
  LoadCStr(buf,256);
  if (strcmp(buf,"Loaded Modules") != 0)
    {
      Pr("Bad divider\n",0L,0L);
      SyExit(1);
    }

  for (i = 0; i < nMods; i++)
    {
      UInt type = LoadUInt();
      UInt isGapRootRelative = LoadUInt();
      LoadCStr(buf,256);
      if (isGapRootRelative)
        READ_GAP_ROOT( buf);
      else
	{
	  StructInitInfo *info = NULL;
 	  /* Search for user module static case first */
          if (IS_MODULE_STATIC(type)) {
              UInt k;
              for (k = 0; CompInitFuncs[k]; k++) {
                  info = (*(CompInitFuncs[k]))();
                  if (info == 0) {
                      continue;
                  }
                  if (!strcmp(buf, info->name)) {
                      break;
                  }
              }
              if (CompInitFuncs[k] == 0) {
                  Pr("Static module %s not found in loading kernel\n",
                     (Int)buf, 0L);
                  SyExit(1);
              }
	
	  } else {
	    /* and dynamic case */
	    InitInfoFunc init; 
	
	    res = SyLoadModule(buf, &init);
	    
	    if (res != 0)
	      {
		Pr("Failed to load needed dynamic module %s, error code %d\n",
		   (Int)buf, res);
		SyExit(1);
	      }
	    info = (*init)();
	     if (info == 0 )
	       {
		Pr("Failed to init needed dynamic module %s, error code %d\n",
		   (Int)buf, (Int) info);
		SyExit(1);
	       }
	  }
	/* link and init me                                                    */
	(info->initKernel)(info);
	RecordLoadedModule(info, 0, buf);
      }
      
    }

  /* Now the kernel variables that point into the workspace */
  LoadCStr(buf,256);
  if (strcmp(buf,"Kernel to WS refs") != 0)
    {
      Pr("Bad divider\n",0L,0L);
       SyExit(1);
    }
  SortGlobals(2);               /* globals by cookie for quick
                                 lookup */
  for (i = 0; i < GlobalBags.nr; i++)
    {
      if (GlobalBags.cookie[i] != NULL)
	globalcount++;
      else
	*(GlobalBags.addr[i]) = (Bag) 0;
    }
  if (nGlobs != globalcount)
    {
      Pr("Wrong number of global bags in saved workspace %d %d\n",
         nGlobs, globalcount);
      SyExit(1);
    }
  for (i = 0; i < globalcount; i++)
    {
      LoadCStr(buf,256);
      glob = GlobalByCookie(buf);
      if (glob == (Obj *)0)
        {
          Pr("Global object cookie from workspace not found in kernel %s\n",
             (Int)buf,0L);
          SyExit(1);
        }
      *glob = LoadSubObj();
#ifdef DEBUG_LOADING
      Pr("Restored global %s\n",(Int)buf,0L);
#endif
    }

  LoadCStr(buf,256);
  if (strcmp(buf,"Bag data") != 0)
    {
      Pr("Bad divider\n",0L,0L);
      SyExit(1);
    }
  
  SortHandlers(2);
  for (i = 0; i < nBags; i++)
    LoadBagData();

  FinishedRestoringBags();

  /* Post restore methods are called elsewhere */
  
  CloseAfterLoad();
#endif
}

#include <src/finfield.h>               /* finite fields and ff elements */

static void PrSavedObj( UInt x)
{
  if ((x & 3) == 1)
    Pr("Immediate  integer %d\n", INT_INTOBJ((Obj)x),0L);
  else if ((x & 3) == 2)
    Pr("Immediate FFE %d %d\n", VAL_FFE(x), SIZE_FF(FLD_FFE(x)));
  else
    Pr("Reference to bag number %d\n",x>>2,0L);
}

Obj FuncDumpWorkspace( Obj self, Obj fname )
{
  UInt nMods, nGlobs, nBags, i, relative;
  Char buf[256];
  OpenForLoad( CSTR_STRING(fname) );
  LoadCStr(buf,256);
  Pr("Header string: %s\n",(Int) buf, 0L);
  LoadCStr(buf,256);
  Pr("GAP Version: %s\n",(Int)buf, 0L);
  LoadCStr(buf,256);
  Pr("Word length: %s\n",(Int)buf, 0L);
  CheckEndiannessMarker();
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf,0L);
  if (strcmp(buf,"Counts and Sizes") != 0)
    ErrorQuit("Bad divider",0L,0L);
  Pr("Loaded modules: %d\n",nMods = LoadUInt(), 0L);
  Pr("Global Bags   : %d\n",nGlobs = LoadUInt(), 0L);
  Pr("Total Bags    : %d\n",nBags = LoadUInt(), 0L);
  Pr("Maximum Size  : %d\n",sizeof(Bag)*LoadUInt(), 0L);
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf, 0L);
  if (strcmp(buf,"Loaded Modules") != 0)
    ErrorQuit("Bad divider",0L,0L);
  for (i = 0; i < nMods; i++)
    {
      UInt type;
      type = LoadUInt();
      Pr("Type: %d ",type,0);
      relative = LoadUInt();
      if (relative)
	Pr("GAP root relative ", 0L, 0L);
      else
	Pr("absolute ", 0L, 0L);
      LoadCStr(buf,256);
      Pr("  %s\n",(Int)buf,0L);
    }
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf,0L);
  if (strcmp(buf,"Kernel to WS refs") != 0)
    ErrorQuit("Bad divider",0L,0L);
  for (i = 0; i < nGlobs; i++)
    {
      LoadCStr(buf,256);
      Pr("  %s ",(Int)buf,0L);
      PrSavedObj(LoadUInt());
    }
  LoadCStr(buf,256);
  Pr("Divider string: %s\n",(Int)buf,0L);
  if (strcmp(buf,"Bag data") != 0)
    ErrorQuit("Bad divider",0L,0L);
  CloseAfterLoad();
  return (Obj) 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(SaveWorkspace, 1, "fname"),
    GVAR_FUNC(DumpWorkspace, 1, "fname"),
    GVAR_FUNC(FindBag, 3, "minsize, maxsize, tnum"),
    GVAR_FUNC(BagStats, 1, "filename"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    SaveFile = -1;
    LBPointer = LoadBuffer;
    LBEnd = LoadBuffer;
  
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );
    /* allow ~/... expansion in SaveWorkspace                              */ 
    ImportFuncFromLibrary("UserHomeExpand", &userHomeExpand);

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
    /* Create dummy variable, to support tab-completion */
    (void)GVarName("SaveWorkspace");

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoSaveLoad()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "saveload",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoSaveLoad ( void )
{
    return &module;
}
