/****************************************************************************
**
*W  sysfiles.c                  GAP source                       Frank Celler
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  The  files  "system.c" and  "sysfiles.c"   contain  all operating  system
**  dependent functions.  File and  stream operations are implemented in this
**  files, all the other system dependent functions in "system.c".  There are
**  various  labels determine which operating  system is  actually used, they
**  are described in "system.c".
*/
#include        "system.h"              /* system dependent part           */

const char * Revision_sysfiles_c =
   "@(#)$Id$";

#define INCLUDE_DECLARATION_PART
#include        "sysfiles.h"            /* file input/output               */
#undef  INCLUDE_DECLARATION_PART

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "lists.h"               /* generic lists                   */
#include        "listfunc.h"            /* functions for generic lists     */

#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "records.h"             /* generic records                 */


#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include <stdio.h>
# define SYS_STDIO_H
#endif


#ifndef SYS_UNISTD_H                    /* definition of 'R_OK'            */
# include <unistd.h>
# define SYS_UNISTD_H
#endif


#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
#endif


#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif


#ifndef SYS_HAS_STDIO_PROTO             /* ANSI/TRAD decl. from H&S 15     */
extern FILE * fopen ( const char *, const char * );
extern int    fclose ( FILE * );
extern void   setbuf ( FILE *, char * );
extern char * fgets ( char *, int, FILE * );
extern int    fputs ( const char *, FILE * );
#endif


#ifndef SYS_HAS_READ_PROTO              /* UNIX decl. from 'man'           */
extern int read ( int, char *, int );
extern int write ( int, char *, int );
#endif

#if HAVE_VFORK_H
# include <vfork.h>
#endif

/* HP-UX already defines SYS_FORK */

#ifdef SYS_HAS_NO_VFORK
# define SYS_MY_FORK    fork
#else
# define SYS_MY_FORK    vfork
#endif


#if HAVE_LIBC_H
#include <libc.h>
#endif

#ifndef SYS_HAS_EXEC_PROTO
extern int SYS_MY_FORK ( void );
#ifndef SYS_HAS_BROKEN_EXEC_PROTO
extern int execve (const char*,char * const [],char * const []);
#else
extern int execve (char*, char * [], char * [] );
#endif
#endif


#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern sig_handler_t * signal ( int, sig_handler_t * );
extern int             getpid ( void );
extern int             kill ( int, int );
#endif


/****************************************************************************
**


*F * * * * * * * * * * * * * * dynamic loading  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyFindOrLinkGapRootFile( <filename>, <crc>, <res>, <len> )   load or link
**
**  'SyFindOrLinkGapRootFile'  tries to find a GAP  file in the root area and
**  check  if   there is a corresponding    statically  or dynamically linked
**  module.  If the CRC matches this module  is loaded otherwise the filename
**  is returned.
**
**  The function returns:
**
**  0: no file or module was found
**  1: if a dynamically linked module was found
**  2: if a statically linked module was found
**  3: a GAP file was found
**  4: a GAP file was found and the CRC value didn't match
*/
#include        "compstat.h"            /* statically linked modules       */

Int SyFindOrLinkGapRootFile (
    Char *              filename,
    Int4                crc_gap,
    Char *              result, 
    Int                 len )
{
    UInt4               crc_dyn = 0;
    UInt4               crc_sta = 0;
    Int                 found_gap = 0;
    Int                 found_dyn = 0;
    Int                 found_sta = 0;
    Char *              tmp;
    Char                module [256];
    Char                name [256];
    StructInitInfo *    info_dyn = 0;
    StructInitInfo *    info_sta = 0;
    Int                 k;

#if defined(SYS_HAS_DL_LIBRARY) || defined(SYS_HAS_RLD_LIBRARY) || HAVE_DLOPEN
    Char *              p;
    Char *              dot;
    Int                 pos;
    Int                 pot = 0;
    InitInfoFunc        init;
#endif

    /* find the GAP file                                                   */
    result[0] = '\0';
    tmp = SyFindGapRootFile(filename);
    if ( tmp ) {
        SyStrncat( result, tmp, len );
        name[0] = '\0';
        SyStrncat( name, tmp, 255 );
    }
    if ( result[0] ) {
        if ( SyIsReadableFile(result) == 0 ) {
            found_gap = 1;
        }
        else {
            result[0] = '\0';
        }
    }
    if ( ! SyUseModule ) {
        return ( found_gap ? 3 : 0 );
    }

    /* try to find any statically link module                              */
    module[0] = '\0';
    SyStrncat( module, "GAPROOT/", 8 );
    SyStrncat( module, filename, SyStrlen(filename) );
    for ( k = 0;  CompInitFuncs[k];  k++ ) {
        info_sta = (*(CompInitFuncs[k]))();
        if ( info_sta == 0 ) {
            continue;
        }
        if ( ! SyStrcmp( module, info_sta->name ) ) {
            crc_sta   = info_sta->crc;
            found_sta = 1;
            break;
        }
    }
    

    /* try to find any dynamically loadable module for filename            */
#if defined(SYS_HAS_DL_LIBRARY) || defined(SYS_HAS_RLD_LIBRARY) || HAVE_DLOPEN
    pos = SyStrlen(filename);
    p   = filename + pos;
    dot = 0;
    while ( filename <= p && *p != '/' ) {
        if ( *p == '.' ) {
            dot = p;
            pot = pos;
        }
        p--;
        pos--;
    }
    if ( dot ) {
        module[0] = '\0';
        SyStrncat( module, "bin/", 4 );
        SyStrncat( module, SyArchitecture, SyStrlen(SyArchitecture) );
        SyStrncat( module, "/compiled/", 10 );
        if ( p < filename ) {
            SyStrncat( module, dot+1, SyStrlen(dot+1) );
            SyStrncat( module, "/", 1 );
            SyStrncat( module, filename, pot );
            SyStrncat( module, ".so", 3 );
        }
        else {
            SyStrncat( module, filename, pos );
            SyStrncat( module, "/", 1 );
            SyStrncat( module, dot+1, SyStrlen(dot+1) );
            SyStrncat( module, filename+pos, pot-pos );
            SyStrncat( module, ".so", 3 );
        }
    }
    else {
        module[0] = '\0';
        SyStrncat( module, "bin/", 4 );
        SyStrncat( module, SyArchitecture, SyStrlen(SyArchitecture) );
        SyStrncat( module, "/compiled/", 1 );
        SyStrncat( module, filename, SyStrlen(filename) );
        SyStrncat( module, ".so", 3 );
    }
    tmp = SyFindGapRootFile(module);
    if ( tmp ) {
        init = SyLoadModule(tmp);
        if ( ( (Int)init & 1 ) == 0 ) {
            info_dyn  = (*init)();
            crc_dyn   = info_dyn->crc;
            found_dyn = 1;
        }
    }
#endif

    /* check if we have to compute the crc                                 */
    if ( found_gap && ( found_dyn || found_sta ) ) {
        if ( crc_gap == 0 ) {
            crc_gap = SyGAPCRC(name);
        } else if ( SyCheckCompletionCrcComp || SyCheckCompletionCrcRead ) {
            if ( crc_gap != SyGAPCRC(name) ) {
                return 4;
            }
        }
    }


    /* now decide what to do                                               */
    if ( found_gap && found_dyn && crc_gap != crc_dyn ) {
        found_dyn = 0;
    }
    if ( found_gap && found_sta && crc_gap != crc_sta ) {
        found_sta = 0;
    }
    if ( found_gap && found_sta ) {
        *(StructInitInfo**)result = info_sta;
        return 2;
    }
    if ( found_gap && found_dyn ) {
        *(StructInitInfo**)result = info_dyn;
        return 1;
    }
    if ( found_gap ) {
        return 3;
    }
    if ( found_sta ) {
        *(StructInitInfo**)result = info_sta;
        return 2;
    }
    if ( found_dyn ) {
        *(StructInitInfo**)result = info_dyn;
        return 1;
    }
    return 0;
}


/****************************************************************************
**
*F  SyGAPCRC( <name> )  . . . . . . . . . . . . . . . . . . crc of a GAP file
**
**  This function should  be clever and handle  white spaces and comments but
**  one has to make certain that such characters are not ignored in strings.
**
**  This function *never* returns a 0 unless an error occurred.
*/
static UInt4 syCcitt32[ 256 ] = 
{
0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L, 0xe0d5e91eL,
0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L, 0x90bf1d91L, 0x1db71064L,
0x6ab020f2L, 0xf3b97148L, 0x84be41deL, 0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L,
0x83d385c7L, 0x136c9856L, 0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL,
0x63066cd9L, 0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL, 0x35b5a8faL,
0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L, 0x45df5c75L, 0xdcd60dcfL,
0xabd13d59L, 0x26d930acL, 0x51de003aL, 0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L,
0x56b3c423L, 0xcfba9599L, 0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L,
0xb10be924L, 0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL, 0x9fbfe4a5L,
0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL, 0xe10e9818L, 0x7f6a0dbbL,
0x086d3d2dL, 0x91646c97L, 0xe6635c01L, 0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L,
0xf262004eL, 0x6c0695edL, 0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L,
0x12b7e950L, 0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L, 0x4adfa541L,
0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL, 0x346ed9fcL, 0xad678846L,
0xda60b8d0L, 0x44042d73L, 0x33031de5L, 0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL,
0x270241aaL, 0xbe0b1010L, 0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L,
0xce61e49fL, 0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L, 0x03b6e20cL,
0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L, 0x73dc1683L, 0xe3630b12L,
0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L, 0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L,
0x7d079eb1L, 0xf00f9344L, 0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL,
0x806567cbL, 0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L, 0xd6d6a3e8L,
0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L, 0xa6bc5767L, 0x3fb506ddL,
0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL, 0x36034af6L, 0x41047a60L, 0xdf60efc3L,
0xa867df55L, 0x316e8eefL, 0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L,
0x5268e236L, 0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L, 0x2cd99e8bL,
0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL, 0x026d930aL, 0x9c0906a9L,
0xeb0e363fL, 0x72076785L, 0x05005713L, 0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL,
0x0cb61b38L, 0x92d28e9bL, 0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L,
0xf1d4e242L, 0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL, 0x8f659effL,
0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L, 0xd70dd2eeL, 0x4e048354L,
0x3903b3c2L, 0xa7672661L, 0xd06016f7L, 0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL,
0xd9d65adcL, 0x40df0b66L, 0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL,
0x30b5ffe9L, 0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L, 0x5d681b02L,
0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL, 0x2d02ef8dL
};

Int4 SyGAPCRC( Char * name )
{
    UInt4       crc;
    UInt4       old;
    UInt4       new;
    Int4        ch;
    Int         fid;
    Int         seen_nl;

    /* the CRC of a non existing file is 0                                 */
    fid = SyFopen( name, "r" );
    if ( fid == -1 ) {
        return 0;
    }

    /* read in the file byte by byte and compute the CRC                   */
    crc = 0x12345678L;
    seen_nl = 0;
    while ( ( ch = fgetc(syBuf[fid].fp) ) != EOF ) {
        if ( ch == '\377' || ch == '\n' || ch == '\r' )
            ch = '\n';
        if ( ch == '\n' ) {
            if ( seen_nl )
                continue;
            else
                seen_nl = 1;
        }
        else
            seen_nl = 0;
        old = (crc >> 8) & 0x00FFFFFFL;
        new = syCcitt32[ ( (UInt4)( crc ^ ch ) ) & 0xff ];
        crc = old ^ new;
    }
    if ( crc == 0 ) {
        crc = 1;
    }

    /* and close it again                                                  */
    SyFclose( fid );
    return ((Int4) crc) >> 4;
}


/****************************************************************************
**
*F  SyLoadModule( <name> )  . . . . . . . . . . . . link a module dynamically
*/
#ifndef SYS_INIT_DYNAMIC
#define SYS_INIT_DYNAMIC        "_Init__Dynamic"
#endif


/****************************************************************************
**
*f  SyLoadModule( <name> )  . . . . . . . . . . . . . . . . . . . . .  dlopen
*/
#if defined(SYS_HAS_DL_LIBRARY) || HAVE_DLOPEN

#include <dlfcn.h>

#ifndef RTLD_LAZY
#define RTLD_LAZY               1
#endif

InitInfoFunc SyLoadModule ( Char * name )
{
    void *          init;
    void *          handle;

    handle = dlopen( name, RTLD_LAZY );
    if ( handle == 0 )  return (InitInfoFunc) 1;

    init = dlsym( handle, SYS_INIT_DYNAMIC );
    if ( init == 0 )  return (InitInfoFunc) 3;

    return (InitInfoFunc) init;
}

#endif


/****************************************************************************
**
*f  SyLoadModule( <name> )  . . . . . . . . . . . . . . . . . . . .  rld_load
*/
#if defined(SYS_HAS_RLD_LIBRARY) || HAVE_RLD_LOAD

#include <mach-o/rld.h>

InitInfoFunc SyLoadModule ( Char * name )
{
    const Char *    names[2];
    unsigned long   init;

    names[0] = name;
    names[1] = 0;
    if ( rld_load( 0, 0,  names, 0 ) == 0 ) {
        return (InitInfoFunc) 1;
    }
    if ( rld_lookup( 0, SYS_INIT_DYNAMIC, &init ) == 0 ) {
        return (InitInfoFunc) 3;
    }
    if ( rld_forget_symbol( 0, SYS_INIT_DYNAMIC ) == 0 ) {
        return (InitInfoFunc) 5;
    }
    return (InitInfoFunc) init;
}

#endif


/****************************************************************************
**
*f  SyLoadModule( <name> )  . . . . . . . . . . . . . . . . . . .  no support
*/
#if !defined(SYS_HAS_RLD_LIBRARY) && !defined(SYS_HAS_DL_LIBRARY) && !HAVE_DLOPEN && !HAVE_RLD_LOAD

InitInfoFunc SyLoadModule ( Char * name )
{
    return (InitInfoFunc) 7;
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * * window handler * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  IS_SEP( <C> ) . . . . . . . . . . . . . . . . . . . .  is <C> a separator
*/
#define IS_SEP(C)       (!IsAlpha(C) && !IsDigit(C) && (C)!='_')


/****************************************************************************
**
*F  CTR( <V> )  . . . . . . . . . . . . . . . .  convert <V> into control-<V>
*/
#define CTR(C)          ((C) & 0x1F)    /* <ctr> character                 */


/****************************************************************************
**
*F  ESC( <V> )  . . . . . . . . . . . . . . . . . convert <V> into escape-<V>
*/
#define ESC(C)          ((C) | 0x100)   /* <esc> character                 */


/****************************************************************************
**
*F  CTV( <V> )  . . . . . . . . . . . . . . . . .  convert <V> into quote <V>
*/
#define CTV(C)          ((C) | 0x200)   /* <ctr>V quotes characters        */


/****************************************************************************
**

*F  syWinPut( <fid>, <cmd>, <str> ) . . . . send a line to the window handler
**
**  'syWinPut'  send the command   <cmd> and the  string  <str> to the window
**  handler associated with the  file identifier <fid>.   In the string <str>
**  '@'  characters are duplicated, and   control characters are converted to
**  '@<chr>', e.g., <newline> is converted to '@J'.
*/
#if ! (SYS_MAC_MPW || SYS_MAC_SYC)

void syWinPut (
    Int                 fid,
    const Char *        cmd,
    const Char *        str )
{
    Int                 fd;             /* file descriptor                 */
    Char                tmp [130];      /* temporary buffer                */
    const Char *        s;              /* pointer into the string         */
    Char *              t;              /* pointer into the temporary      */

    /* if not running under a window handler, don't do anything            */
    if ( ! SyWindow || 4 <= fid )
        return;

    /* get the file descriptor                                             */
    if ( fid == 0 || fid == 2 )  fd = fileno(syBuf[fid].echo);
    else                         fd = fileno(syBuf[fid].fp);

    /* print the cmd                                                       */
    write( fd, (Char*)cmd, SyStrlen(cmd) );

    /* print the output line, duplicate '@' and handle <ctr>-<chr>         */
    s = str;  t = tmp;
    while ( *s != '\0' ) {
        if ( *s == '@' ) {
            *t++ = '@';  *t++ = *s++;
        }
        else if ( CTR('A') <= *s && *s <= CTR('Z') ) {
            *t++ = '@';  *t++ = *s++ - CTR('A') + 'A';
        }
        else {
            *t++ = *s++;
        }
        if ( 128 <= t-tmp ) {
            write( fd, tmp, t-tmp );
            t = tmp;
        }
    }
    if ( 0 < t-tmp ) {
        write( fd, tmp, t-tmp );
    }
}

#endif

#if SYS_MAC_MPW || SYS_MAC_SYC

void            syWinPut (
    Int                 fid,
    Char *              cmd,
    Char *              str )
{
}

#endif


/****************************************************************************
**
*F  SyWinCmd( <str>, <len> )  . . . . . . . . . . . . .  execute a window cmd
**
**  'SyWinCmd' send   the  command <str> to  the   window  handler (<len>  is
**  ignored).  In the string <str> '@' characters are duplicated, and control
**  characters  are converted to  '@<chr>', e.g.,  <newline> is converted  to
**  '@J'.  Then  'SyWinCmd' waits for  the window handlers answer and returns
**  that string.
*/
#if ! (SYS_MAC_MPW || SYS_MAC_SYC)

Char WinCmdBuffer [8000];

Char * SyWinCmd (
    const Char *        str,
    UInt                len )
{
    Char                buf [130];      /* temporary buffer                */
    const Char *        s;              /* pointer into the string         */
    const Char *        bb;             /* pointer into the temporary      */
    Char *              b;              /* pointer into the temporary      */
    UInt                i;              /* loop variable                   */

    /* if not running under a window handler, don't do nothing             */
    if ( ! SyWindow )
        return "I1+S52+No Window Handler Present";

    /* compute the length of the (expanded) string (and ignore argument)   */
    len = 0;
    for ( s = str; *s != '\0'; s++ )
        len += 1 + (*s == '@' || (CTR('A') <= *s && *s <= CTR('Z')));

    /* send the length to the window handler                               */
    b = buf;
    for ( ; 0 < len;  len /= 10 ) {
        *b++ = (len % 10) + '0';
    }
    *b++ = '+';
    *b++ = '\0';
    syWinPut( 1, "@w", buf );

    /* send the string to the window handler                               */
    syWinPut( 1, "", str );

    /* read the length of the answer                                       */
    b = WinCmdBuffer;
    i = 3;
    while ( 0 < i ) {
	len = read( 0, b, i );
	i  -= len;
	b  += len;
    }
    if ( WinCmdBuffer[0] != '@' || WinCmdBuffer[1] != 'a' )
        return "I1+S41+Illegal Answer";
    b = WinCmdBuffer+2;
    for ( i=1,len=0; '0' <= *b && *b <= '9';  i *= 10 ) {
        len += (*b-'0')*i;
	while ( read( 0, b, 1 ) != 1 )  ;
    }

    /* read the arguments of the answer                                    */
    b = WinCmdBuffer;
    i = len;
    while ( 0 < i ) {
        len = read( 0, b, i );
        i  -= len;
        s  += len;
    }

    /* shrink '@@' into '@'                                                */
    for ( bb = b = WinCmdBuffer;  0 < len;  len-- ) {
        if ( *bb == '@' ) {
            bb++;
            if ( *bb == '@' )
                *b++ = '@';
            else if ( 'A' <= *bb && *bb <= 'Z' )
                *b++ = CTR(*bb);
            bb++;
        }
        else {
            *b++ = *bb++;
        }
    }
    *b = 0;

    /* return the string                                                   */
    return WinCmdBuffer;
}

#endif

#if SYS_MAC_MPW || SYS_MAC_SYC

Char * SyWinCmd (
    Char *              str,
    UInt                len )
{
    return "I1+S52+No Window Handler Present";
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * * * open/close * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  syBuf . . . . . . . . . . . . . .  buffer and other info for files, local
**
**  'syBuf' is  a array used as  buffers for  file I/O to   prevent the C I/O
**  routines  from   allocating their  buffers  using  'malloc',  which would
**  otherwise confuse Gasman.
*/
SYS_SY_BUF syBuf [256];


/****************************************************************************
**
*F  SyFopen( <name>, <mode> ) . . . . . . . .  open the file with name <name>
**
**  The function 'SyFopen'  is called to open the file with the name  <name>.
**  If <mode> is "r" it is opened for reading, in this case  it  must  exist.
**  If <mode> is "w" it is opened for writing, it is created  if  neccessary.
**  If <mode> is "a" it is opened for appending, i.e., it is  not  truncated.
**
**  'SyFopen' returns an integer used by the scanner to  identify  the  file.
**  'SyFopen' returns -1 if it cannot open the file.
**
**  The following standard files names and file identifiers  are  guaranteed:
**  'SyFopen( "*stdin*", "r")' returns 0 identifying the standard input file.
**  'SyFopen( "*stdout*","w")' returns 1 identifying the standard outpt file.
**  'SyFopen( "*errin*", "r")' returns 2 identifying the brk loop input file.
**  'SyFopen( "*errout*","w")' returns 3 identifying the error messages file.
**
**  If it is necessary  to adjust the filename  this should be done here, the
**  filename convention used in GAP is that '/' is the directory separator.
**
**  Right now GAP does not read nonascii files, but if this changes sometimes
**  'SyFopen' must adjust the mode argument to open the file in binary mode.
*/
Int SyFopen (
    Char *              name,
    Char *              mode )
{
    Int                 fid;
    Char                namegz [1024];
    Char                cmd [1024];

    /* handle standard files                                               */
    if ( SyStrcmp( name, "*stdin*" ) == 0 ) {
        if ( SyStrcmp( mode, "r" ) != 0 )
          return -1;
        else
          return 0;
    }
    else if ( SyStrcmp( name, "*stdout*" ) == 0 ) {
        if ( SyStrcmp( mode, "w" ) != 0 )
          return -1;
        else
          return 1;
    }
    else if ( SyStrcmp( name, "*errin*" ) == 0 ) {
        if ( SyStrcmp( mode, "r" ) != 0 )
          return -1;
        else if ( syBuf[2].fp == (FILE*)0 )
          return -1;
        else
          return 2;
    }
    else if ( SyStrcmp( name, "*errout*" ) == 0 ) {
        if ( SyStrcmp( mode, "w" ) != 0 )
          return -1;
        else
          return 3;
    }

    /* try to find an unused file identifier                               */
    for ( fid = 4; fid < sizeof(syBuf)/sizeof(syBuf[0]); ++fid )
        if ( syBuf[fid].fp == (FILE*)0 )
          break;
    if ( fid == sizeof(syBuf)/sizeof(syBuf[0]) )
        return (Int)-1;

    /* set up <namegz> and <cmd> for pipe command                          */
    namegz[0] = '\0';
    SyStrncat( namegz, name, sizeof(namegz)-5 );
    SyStrncat( namegz, ".gz", 4 );
    cmd[0] = '\0';
    SyStrncat( cmd, "gunzip <", 9 );
    SyStrncat( cmd, namegz, sizeof(cmd)-10 );

    /* try to open the file                                                */
    if ( (syBuf[fid].fp = fopen(name,mode)) ) {
        syBuf[fid].pipe = 0;
        syBuf[fid].echo = syBuf[fid].fp;
    }
#if SYS_BSD || SYS_MACH || SYS_USG || HAVE_POPEN
   else if ( SyStrncmp(mode,"r",1) == 0
           && SyIsReadableFile(namegz) == 0
           && (syBuf[fid].fp = popen(cmd,"r")
	       ) ) {
        syBuf[fid].pipe = 1;
    }
#endif
    else {
        return (Int)-1;
    }

    /* allocate the buffer                                                 */
    setbuf( syBuf[fid].fp, syBuf[fid].buf );

    /* return file identifier                                              */
    return fid;
}


/****************************************************************************
**
*F  SyFclose( <fid> ) . . . . . . . . . . . . . . . . .  close the file <fid>
**
**  'SyFclose' closes the file with the identifier <fid>  which  is  obtained
**  from 'SyFopen'.
*/
Int SyFclose (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        fputs("gap: panic 'SyFclose' asked to close illegal fid!\n",stderr);
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        fputs("gap: panic 'SyFclose' asked to close closed file!\n",stderr);
        return -1;
    }

    /* refuse to close the standard files                                  */
    if ( fid == 0 || fid == 1 || fid == 2 || fid == 3 ) {
        return -1;
    }

    /* try to close the file                                               */
    if ( (syBuf[fid].pipe == 0 && fclose( syBuf[fid].fp ) == EOF)
      || (syBuf[fid].pipe == 1 && pclose( syBuf[fid].fp ) == -1) )
    {
        fputs("gap: 'SyFclose' cannot close file, ",stderr);
        fputs("maybe your file system is full?\n",stderr);
        syBuf[fid].fp = (FILE*)0;
        return -1;
    }

    /* mark the buffer as unused                                           */
    syBuf[fid].fp = (FILE*)0;
    return 0;
}


/****************************************************************************
**
*F  SyIsEndOfFile( <fid> )  . . . . . . . . . . . . . . . end of file reached
*/
Int SyIsEndOfFile (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* *stdin* and *errin* are never at end of file                        */
    if ( fid < 4 )
        return 0;

    return feof(syBuf[fid].fp);
}


/****************************************************************************
**

*F  syStartraw( <fid> ) . . . . . . start raw mode on input file <fid>, local
**
**  The  following four  functions are  the  actual system  dependent part of
**  'SyFgets'.
**
**  'syStartraw' tries to put the file with the file  identifier  <fid>  into
**  raw mode.  I.e.,  disabling  echo  and  any  buffering.  It also finds  a
**  place to put the echoing  for  'syEchoch'.  If  'syStartraw'  succedes it
**  returns 1, otherwise, e.g., if the <fid> is not a terminal, it returns 0.
**
**  'syStopraw' stops the raw mode for the file  <fid>  again,  switching  it
**  back into whatever mode the terminal had before 'syStartraw'.
**
**  'syGetch' reads one character from the file <fid>, which must  have  been
**  turned into raw mode before, and returns it.
**
**  'syEchoch' puts the character <ch> to the file opened by 'syStartraw' for
**  echoing.  Note that if the user redirected 'stdout' but not 'stdin',  the
**  echo for 'stdin' must go to 'ttyname(fileno(stdin))' instead of 'stdout'.
*/
extern UInt syStartraw (
            Int                 fid );

extern void syStopraw (
            Int                 fid );


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . .  BSD/MACH
**
**  For Berkeley UNIX, input/output redirection and typeahead are  supported.
**  We switch the terminal line into 'CBREAK' mode and also disable the echo.
**  We do not switch to 'RAW'  mode because  this would flush  all typeahead.
**  Because 'CBREAK' leaves signals enabled we have to disable the characters
**  for interrupt and quit, which are usually set to '<ctr>-C' and '<ctr>-B'.
**  We also turn  off  the  xon/xoff  start and  stop characters,  which  are
**  usually set  to '<ctr>-S' and '<ctr>-Q' so  we can get  those characters.
**  We  do not  change the  suspend  character, which  is usually  '<ctr>-Z',
**  instead we catch the signal, so that we  can turn  the terminal line back
**  to cooked mode before stopping GAP and back to raw mode when continueing.
*/
#if SYS_BSD || SYS_MACH || HAVE_SGTTY_H

#ifndef SYS_SGTTY_H                     /* terminal control functions      */
# include       <sgtty.h>
# define SYS_SGTTY_H
#endif

#ifndef SYS_HAS_IOCTL_PROTO             /* UNIX decl. from 'man'           */
extern  int             ioctl ( int, unsigned long, char * );
#endif

struct sgttyb   syOld, syNew;           /* old and new terminal state      */
struct tchars   syOldT, syNewT;         /* old and new special characters  */

#ifdef SIGTSTP

Int syFid;

SYS_SIG_T syAnswerCont (
    int                 signr )
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
#if defined(SYS_HAS_SIG_T) && ! HAVE_SIGNAL_VOID
    return 0;                           /* is ignored                      */
#endif
}

SYS_SIG_T syAnswerTstp (
    int                 signr )
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
#if defined(SYS_HAS_SIG_T) && ! HAVE_SIGNAL_VOID
    return 0;                           /* is ignored                      */
#endif
}

#endif

UInt syStartraw (
    Int                 fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCGETP, (char*)&syOld ) == -1 )
        return 0;

    /* disable interrupt, quit, start and stop output characters           */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCGETC, (char*)&syOldT ) == -1 )
        return 0;
    syNewT = syOldT;
    syNewT.t_intrc  = -1;
    syNewT.t_quitc  = -1;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNewT.t_startc = -1;                                              */
    /*C syNewT.t_stopc  = -1;                                              */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETC, (char*)&syNewT ) == -1 )
        return 0;

    /* disable input buffering, line editing and echo                      */
    syNew = syOld;
    syNew.sg_flags |= CBREAK;
    syNew.sg_flags &= ~ECHO;
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETN, (char*)&syNew ) == -1 )
        return 0;

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . . . USG
**
**  For UNIX System V, input/output redirection and typeahead are  supported.
**  We  turn off input buffering  and canonical input editing and  also echo.
**  Because we leave the signals enabled  we  have  to disable the characters
**  for interrupt and quit, which are usually set to '<ctr>-C' and '<ctr>-B'.
**  We   also turn off the  xon/xoff  start  and  stop  characters, which are
**  usually set to  '<ctr>-S'  and '<ctr>-Q' so we  can get those characters.
**  We do  not turn of  signals  'ISIG' because  we want   to catch  stop and
**  continue signals if this particular version  of UNIX supports them, so we
**  can turn the terminal line back to cooked mode before stopping GAP.
*/
#if SYS_USG || HAVE_TERMIO_H

#ifndef SYS_TERMIO_H                    /* terminal control functions      */
# include       <termio.h>
# define SYS_TERMIO_H
#endif

/* fix by L. Johansson */
#if defined(linux) && defined(alpha)
#define termio termios
#endif

#ifndef SYS_HAS_IOCTL_PROTO             /* UNIX decl. from 'man'           */
extern  int             ioctl ( int, int, struct termio * );
#endif

struct termio   syOld, syNew;           /* old and new terminal state      */

#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif

#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern  sig_handler_t * signal ( int, sig_handler_t * );
extern  int             getpid ( void );
extern  int             kill ( int, int );
#endif

#ifdef SIGTSTP

Int syFid;

SYS_SIG_T syAnswerCont (
    int                 signr )
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
#if defined(SYS_HAS_SIG_T) && ! HAVE_SIGNAL_VOID
    return 0;                           /* is ignored                      */
#endif
}

SYS_SIG_T syAnswerTstp (
    int                 signr )
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
#if defined(SYS_HAS_SIG_T) && ! HAVE_SIGNAL_VOID
    return 0;                           /* is ignored                      */
#endif
}

#endif

UInt syStartraw (
    Int                 fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    if ( ioctl( fileno(syBuf[fid].fp), TCGETA, &syOld ) == -1 )   return 0;

    /* disable interrupt, quit, start and stop output characters           */
    syNew = syOld;
    syNew.c_cc[VINTR] = 0377;
    syNew.c_cc[VQUIT] = 0377;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNew.c_iflag    &= ~(IXON|INLCR|ICRNL);                           */
    syNew.c_iflag    &= ~(INLCR|ICRNL);

    /* disable input buffering, line editing and echo                      */
    syNew.c_cc[VMIN]  = 1;
    syNew.c_cc[VTIME] = 0;
    syNew.c_lflag    &= ~(ECHO|ICANON);

    /* cygwin32 provides no SETAW. Try using SETA instead in that case */
#ifdef TCSETAW
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syNew ) == -1 )  return 0;
#else
    if ( ioctl( fileno(syBuf[fid].fp), TCSETA, &syNew ) == -1 )  return 0;
#endif

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . OS2 EMX
**
**  OS/2 is almost the same as UNIX System V, except for function keys.
*/
#if SYS_OS2_EMX

#ifndef SYS_TERMIO_H                    /* terminal control functions      */
# include       <termio.h>
# define SYS_TERMIO_H
#endif
#ifndef SYS_HAS_IOCTL_PROTO             /* UNIX decl. from 'man'           */
extern  int             ioctl ( int, int, struct termio * );
#endif

struct termio   syOld, syNew;           /* old and new terminal state      */

#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif
#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern  sig_handler_t * signal ( int, sig_handler_t * );
extern  int             getpid ( void );
extern  int             kill ( int, int );
#endif

#ifdef SIGTSTP

Int             syFid;

SYS_SIG_T syAnswerCont (
    int                 signr )
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

SYS_SIG_T syAnswerTstp (
    int                 signr )
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

#endif

UInt syStartraw (
    Int                 fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    if ( ioctl( fileno(syBuf[fid].fp), TCGETA, &syOld ) == -1 )   return 0;

    /* disable interrupt, quit, start and stop output characters           */
    syNew = syOld;
    syNew.c_cc[VINTR] = 0377;
    syNew.c_cc[VQUIT] = 0377;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNew.c_iflag    &= ~(IXON|INLCR|ICRNL);                           */
    syNew.c_iflag    &= ~(INLCR|ICRNL);

    /* disable input buffering, line editing and echo                      */
    syNew.c_cc[VMIN]  = 1;
    syNew.c_cc[VTIME] = 0;
    syNew.c_lflag    &= ~(ECHO|ICANON|IDEFAULT);
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syNew ) == -1 )  return 0;

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS
**
**  For MS-DOS we read  directly  from the  keyboard.   Note that the  window
**  handler is not currently supported.
*/
#if SYS_MSDOS_DJGPP

#ifndef SYS_KBD_H                       /* keyboard functions              */
# include       <pc.h>
# define GETKEY()       getkey()
# define PUTCHAR(C)     putchar(C)
# define KBHIT()        kbhit()
# define SYS_KBD_H
#endif

UInt            syStopout;              /* output is stopped by <ctr>-'S'  */

Char            syTypeahead [256];      /* characters read by 'SyIsIntr'   */

Char            syAltMap [35] = "QWERTYUIOP    ASDFGHJKL     ZXCVBNM";

UInt syStartraw (
    Int                 fid )
{
    /* check if the file is a terminal                                     */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return 0;

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . . . TOS
**
**  For TOS we read directly from the keyboard.  Note that the window handler
**  is not currently supported.
*/
#if SYS_TOS_GCC2

#ifndef SYS_KBD_H                       /* keyboard functions              */
# include       <unixlib.h>             /* declaration of 'isatty'         */
# include       <osbind.h>              /* operating system binding        */
# define GETKEY()       Bconin( 2 )
# define PUTCHAR(C)     do{if(C=='\n')Bconout(2,'\r');Bconout(2,C);}while(0)
# define KBHIT()        Bconstat( 2 )
# define SYS_KBD_H
#endif

UInt syStopout;                         /* output is stopped by <ctr>-'S'  */

Char syTypeahead [256];                 /* characters read by 'SyIsIntr'   */

Int syStartraw (
    Int                 fid )
{
    /* check if the file is a terminal                                     */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return 0;

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . . . VMS
**
**  For VMS we use a virtual keyboard to read and  write from the unique tty.
**  We do not support the window handler.
*/
#if SYS_VMS

#ifndef SYS_HAS_MISC_PROTO              /* UNIX decl. from 'man'           */
extern  int             isatty ( int );
#endif

UInt syVirKbd;                          /* virtual (raw) keyboard          */

UInt syStartraw (
    Int                 fid )
{
    /* test whether the file is connected to a terminal                    */
    return isatty( fileno(syBuf[fid].fp) );
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
**
**  For the MAC with MPW we do not really know how to do this.
*/
#if SYS_MAC_MPW

Int syStartraw (
    Int                 fid )
{
    /* clear away pending <command>-'.'                                    */
    SyIsIntr();

    return 0;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
**
**  For the MAC with Symantec C we use the  console input/output package.  We
**  must  set the console to  raw mode and  back to echo   mode.  In raw mode
**  there is no cursor, so we reverse the current character.
*/
#if SYS_MAC_SYC

#ifndef SYS_UNIX_H                      /* unix stuff:                     */
# include       <unix.h>                /* 'isatty'                        */
# define SYS_UNIX_H
#endif

#ifndef SYS_CONSOLE_H                   /* console stuff:                  */
# include       <Console.h>             /* 'csetmode'                      */
# define SYS_CONSOLE_H
#endif

#ifndef SYS_OSUTILS_H                   /* system utils:                   */
# include       <OSUtils.h>             /* 'SysBeep'                       */
# define SYS_OSUTILS_H
#endif

UInt syStartraw (
    Int                 fid )
{

    /* cannot switch ordinary files to raw mode                            */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return 0;

    /* turn terminal to raw mode                                           */
    csetmode( C_RAW, syBuf[fid].fp );
    return 1;
}

#endif


/****************************************************************************
**

*F  syStopraw( <fid> )  . . . . . .  stop raw mode on input file <fid>, local
*/


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . .  BSD/MACH
*/
#if SYS_BSD || SYS_MACH || HAVE_SGTTY_H

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETN, (char*)&syOld ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);

    /* enable interrupt, quit, start and stop output characters again      */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETC, (char*)&syOldT ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#if SYS_USG || HAVE_TERMIO_H

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
#ifdef TCSETAW
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syOld ) == -1 )
#else
    if ( ioctl( fileno(syBuf[fid].fp), TCSETA, &syOld ) == -1 )
#endif
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . OS2 EMX
*/
#if SYS_OS2_EMX

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syOld ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS
*/
#if SYS_MSDOS_DJGPP

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . TOS
*/
#if SYS_TOS_GCC2

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#if SYS_VMS

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
*/
#if SYS_MAC_MPW

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
*/
#if SYS_MAC_SYC

void syStopraw (
    Int                 fid )
{
    /* probably only paranoid                                              */
    if ( isatty( fileno(syBuf[fid].fp) ) )
        return;

    /* turn terminal back to echo mode                                     */
    csetmode( C_ECHO, syBuf[fid].fp );
}

#endif


/****************************************************************************
**

*F  SyIsIntr()  . . . . . . . . . . . . . . . . check wether user hit <ctr>-C
**
**  'SyIsIntr' is called from the evaluator at  regular  intervals  to  check
**  wether the user hit '<ctr>-C' to interrupt a computation.
**
**  'SyIsIntr' returns 1 if the user typed '<ctr>-C' and 0 otherwise.
*/


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . .  BSD/MACH/USG/OS2 EMX/VMS
**
**  For  UNIX, OS/2  and VMS  we  install 'syAnswerIntr' to  answer interrupt
**  'SIGINT'.   If two interrupts  occur within 1 second 'syAnswerIntr' exits
**  GAP.
*/
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || SYS_VMS || HAVE_SIGNAL

#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif

#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern  sig_handler_t * signal ( int, sig_handler_t * );
extern  int             getpid ( void );
extern  int             kill ( int, int );
#endif

#ifndef SYS_TIME_H                      /* time functions                  */
# if SYS_VMS
#  include      <types.h>               /* declaration of type 'time_t'    */
# endif
# include       <time.h>
# define SYS_TIME_H
#endif

#ifndef SYS_HAS_TIME_PROTO              /* ANSI/TRAD decl. from H&S 18.1    */
# if SYS_ANSI
extern  time_t          time ( time_t * buf );
# else
extern  long            time ( long * buf );
# endif
#endif

UInt            syLastIntr;             /* time of the last interrupt      */

extern void     InterruptExecStat ( void );


SYS_SIG_T syAnswerIntr (
    int                 signr )
{
    UInt                nowIntr;

    /* get the current wall clock time                                     */
    nowIntr = time(0);

    /* if the last '<ctr>-C' was less than a second ago, exit GAP          */
    if ( syLastIntr && nowIntr-syLastIntr < 1 ) {
        fputs("gap: you hit '<ctr>-C' twice in a second, goodbye.\n",stderr);
        SyExit( 1 );
    }

    /* reinstall 'syAnswerIntr' as signal handler                          */
#if ! SYS_OS2_EMX
    signal( SIGINT, syAnswerIntr );
#else
    signal( signr, SIG_ACK );
#endif

    /* remember time of this interrupt                                     */
    syLastIntr = nowIntr;

#if HAVE_SIGNAL
    /* interrupt the executor                                              */
    InterruptExecStat();
#endif

#if defined(SYS_HAS_SIG_T) && ! HAVE_SIGNAL_VOID
    return 0;                           /* is ignored                      */
#endif
}


void SyInstallAnswerIntr ( void )
{
    if ( signal( SIGINT, SIG_IGN ) != SIG_IGN )
        signal( SIGINT, syAnswerIntr );
#if SYS_OS2_EMX
    /* under OS/2, pressing <ctr>-Break sometimes generates SIGBREAK       */
    signal( SIGBREAK, syAnswerIntr );
#endif
}


UInt SyIsIntr ( void )
{
    UInt                isIntr;

    isIntr = (syLastIntr != 0);
    syLastIntr = 0;
    return isIntr;
}

#endif


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS/TOS
**
**  In DOS we check the input queue to look for <ctr>-'C', chars read are put
**  on the 'osTNumahead' buffer. The buffer is flushed if <ctr>-'C' is found.
**  Actually with the current DOS extender we cannot trap  <ctr>-'C', because
**  the DOS extender does so already, so be use <ctr>-'Z' and <alt>-'C'.
**
**  In TOS we check the input queue to look for <ctr>-'C', chars read are put
**  on the 'osTNumahead' buffer. The buffer is flushed if <ctr>-'C' is found.
**  There is however a problem, if 2 or  more characters are pending (that is
**  waiting to be read by either 'SyIsIntr' or 'SyGetch') and the second is a
**  <ctr>-'C', GAP will be killed when 'SyIsIntr' or  'syGetch' tries to read
**  the first character.  Thus  if you typed ahead  and want to interrupt the
**  computation, wait some time to make sure that  the typed ahead characters
**  have been read by 'SyIsIntr' befor you hit <ctr>-'C'.
*/
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2

UInt syIsIntrFreq = 20;

UInt syIsIntrCount = 0;

UInt SyIsIntr ( void )
{
    Int                 ch;
    UInt                i;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( 0 < --syIsIntrCount )
        return 0;
    syIsIntrCount = syIsIntrFreq;

    /* check for interrupts stuff the rest in typeahead buffer             */
    if ( SyLineEdit && KBHIT() ) {
        while ( KBHIT() ) {
            ch = GETKEY();
            if ( ch == CTR('C') || ch == CTR('Z') || ch == 0x12E ) {
                PUTCHAR('^'); PUTCHAR('C');
                syTypeahead[0] = '\0';
                syStopout = 0;
                return 1L;
            }
            else if ( ch == CTR('X') ) {
                PUTCHAR('^'); PUTCHAR('X');
                syTypeahead[0] = '\0';
                syStopout = 0;
            }
            else if ( ch == CTR('S') ) {
                syStopout = 1;
            }
            else if ( syStopout ) {
                syStopout = 0;
            }
            else {
                for ( i = 0; i < sizeof(syTypeahead)-1; ++i ) {
                    if ( syTypeahead[i] == '\0' ) {
                        PUTCHAR(ch);
                        syTypeahead[i] = ch;
                        syTypeahead[i+1] = '\0';
                        break;
                    }
                }
            }
        }
        return 0L;
    }
    return 0L;
}

#endif


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
**
**  For a  MPW Tool, we install 'syAnswerIntr'  to answer interrupt 'SIGINT'.
**  However, the interrupt is  only delivered when  the system has a control,
**  namely  when  we call the  toolbox   function 'SpinCursor' in 'SyIsIntr'.
**  Thus the mechanism is effectively polling.
**
**  For a MPW SIOW, we search the event queue for a <cmd>-'.' or a <cnt>-'C'.
**  If one is found, all keyboard events are flushed.
**
*/
#if SYS_MAC_MPW

#ifdef  SYS_HAS_TOOL

#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <Signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif

#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern  sig_handler_t * signal ( int, sig_handler_t * );
#endif

#ifndef SYS_CURSORCTL_H                 /* cursor control functions:       */
# include       <CursorCtl.h>           /* 'Show_Cursor', 'SpinCursor'     */
# define SYS_CURSORCTL_H
#endif

UInt            syNrIntr;               /* number of interrupts            */

UInt            syLastIntr;             /* time of the last interrupt      */

UInt            syIsIntrFreq = 100;     /* frequency to test interrupts    */

UInt            syIsIntrCount =  0;     /* countdown to test interrupts    */


void syAnswerIntr (
    int                 signr )
{
    /* reinstall the signal handler                                        */
    signal( SIGINT, &syAnswerIntr );

    /* exit if two interrupts happen within one second                     */
    /*N 1993/05/28 martin this doesn't work, because interrupts are only   */
    /*N                   delivered when we call 'SpinCursor' below        */
    if ( syNrIntr && SyTime()-syLastIntr <= 1000 )
        SyExit( 1 );

    /* got one more interrupt                                              */
    syNrIntr   = syNrIntr + 1;
    syLastIntr = SyTime();
}

void SyInstallAnswerIntr ( void )
{
#if SYS_MAC_MPW
# ifdef SYS_HAS_TOOL
    signal( SIGINT, &syAnswerIntr );
# endif
#endif
#if SYS_MAC_SYC
    signal( SIGINT, &syAnswerIntr );
#endif
}

UInt SyIsIntr ( void )
{
    UInt                syIsIntr;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( 0 < --syIsIntrCount )
        return 0;
    syIsIntrCount = syIsIntrFreq;

    /* spin the beachball                                                  */
    Show_Cursor( HIDDEN_CURSOR );
    SpinCursor( 8 );

    /* check for interrupts                                                */
    syIsIntr = (syNrIntr != 0);

    /* every interrupt leaves a <eof>, which we want to remove             */
    while ( syNrIntr ) {
        while ( getchar() != EOF ) ;
        clearerr( stdin );
        syNrIntr = syNrIntr - 1;
    }

    /* return whether an interrupt has happened                            */
    return syIsIntr;
}

#else

#ifndef SYS_TNUMS_H                     /* various types                   */
# include       <TNums.h>
# define SYS_TNUMS_H
#endif

#ifndef SYS_OSUTILS_H                   /* system utils:                   */
# include       <OSUtils.h>             /* 'QHdr'                          */
# define SYS_OSUTILS_H
#endif

#ifndef SYS_OSEVENTS_H                  /* system events, low level:       */
# include       <OSEvents.h>            /* 'EvQEl', 'GetEvQHdr',           */
                                        /* 'FlushEvents'                   */
# define SYS_OSEVENTS_H
#endif

#ifndef SYS_EVENTS_H                    /* system events, high level:      */
# include       <Events.h>              /* 'EventRecord', 'GetNextEvent'   */
# define SYS_EVENTS_H
#endif

UInt            syNrIntr;               /* number of interrupts            */

UInt            syLastIntr;             /* time of the last interrupt      */

UInt            syIsIntrFreq = 100;     /* frequency to test interrupts    */

UInt            syIsIntrCount =  0;     /* countdown to test interrupts    */


UInt SyIsIntr ( void )
{
    UInt                syIsIntr;
    struct QHdr *       queue;
    struct EvQEl *      qentry;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( 0 < --syIsIntrCount )
        return 0;
    syIsIntrCount = syIsIntrFreq;

    /* look through the event queue for <command>-'.' or <control>-'C'     */
    queue = GetEvQHdr();
    qentry = (struct EvQEl *)(queue->qHead);
    while ( qentry ) {
        if ( qentry->evtQWhat == keyDown
            &&   ( ((qentry->evtQModifiers & controlKey) != 0)
                && ((qentry->evtQMessage & charCodeMask) ==   3))
              || ( ((qentry->evtQModifiers & cmdKey    ) != 0)
                && ((qentry->evtQMessage & charCodeMask) == '.')) ) {
            syNrIntr++;
        }
        qentry = (struct EvQEl *)(qentry->qLink);
    }

    /* check for interrupts                                                */
    syIsIntr = (syNrIntr != 0);

    /* flush away all keyboard events after an interrupt                   */
    if ( syNrIntr ) {
        FlushEvents( keyDownMask, 0 );
        syNrIntr = 0;
    }

    /* return whether an interrupt has happened                            */
    return syIsIntr;
}

#endif

#endif


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
**
**  For Symantec C, we search the event queue for a <cmd>-'.' or a <cnt>-'C'.
**  If one is found, all keyboard events are flushed, and 'true' is returned.
**  We also  check for signals  just to  be safe.   Because signals are  only
**  delivered when the system is in control, e.g., when we call 'SystemTask',
**  there is no point to test for two interrupts within a second.
*/
#if SYS_MAC_SYC

#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif

#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern  sig_handler_t * signal ( int, sig_handler_t * );
#endif

#ifndef SYS_TNUMS_H                     /* various types                   */
# include       <TNums.h>
# define SYS_TNUMS_H
#endif

#ifndef SYS_LOWMEM_H                    /* variables in low memory:        */
# include       <LowMem.h>              /* 'LMGetTicks'                    */
# define SYS_LOWMEM_H
#endif

#ifndef SYS_OSUTILS_H                   /* system utils:                   */
# include       <OSUtils.h>             /* 'QHdr'                          */
# define SYS_OSUTILS_H
#endif

#ifndef SYS_OSEVENTS_H                  /* system events, low level:       */
# include       <OSEvents.h>            /* 'EvQEl', 'GetEvQHdr',           */
                                        /* 'FlushEvents'                   */
# define SYS_OSEVENTS_H
#endif

#ifndef SYS_EVENTS_H                    /* system events, high level:      */
# include       <Events.h>              /* 'EventRecord', 'GetNextEvent'   */
# define SYS_EVENTS_H
#endif

#ifndef SYS_LOMEM_H                     /* variables in low memory         */
# include       <LoMem.h>               /* 'SEvtEnb'                       */
# define SYS_LOMEM_H
#endif

#ifndef SYS_DESK_H
# include       <Desk.h>                /* 'SystemTask'                    */
# define SYS_DESK_H
#endif

UInt            syNrIntr;               /* number of interrupts            */

UInt            syIsIntrFreq  =  60;    /* frequency to test interrupts    */

UInt            syIsIntrCount =   0;    /* countdown to test interrupts    */

UInt            syIsBackFreq  = 600;    /* frequence background switching  */

UInt            syIsBackCount =   0;    /* countdown background switching  */


void syAnswerIntr (
    int                 signr )
{
    /* reinstall the signal handler                                        */
    signal( SIGINT, &syAnswerIntr );

    /* got one more interrupt                                              */
    syNrIntr = syNrIntr + 1;
}


UInt SyIsIntr ( void )
{
    UInt                syIsIntr;
    struct QHdr *       queue;
    struct EvQEl *      qentry;
    EventRecord         theEvent;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( (*(unsigned long*)0x016A) <= syIsIntrCount )
        return 0;
    syIsIntrCount = (*(unsigned long*)0x016A) + syIsIntrFreq;

    /* allow for system activities                                         */
    if ( syIsBackCount < (*(unsigned long*)0x016A) ) {
        syIsBackCount = (*(unsigned long*)0x016A) + syIsBackFreq;
        SystemTask();
        SEvtEnb = false;
        GetNextEvent( activMask, &theEvent );
    }

    /* check for caught interrupts                                         */
    syIsIntr = (syNrIntr != 0);

    /* every caught interrupt leaves a <eof>, which we want to remove      */
    while ( syNrIntr ) {
        while ( getchar() != EOF ) ;
        clearerr( stdin );
        syNrIntr = syNrIntr - 1;
    }

    /* look through the event queue for <command>-'.' or <control>-'C'     */
    queue = GetEvQHdr();
    qentry = (struct EvQEl *)(queue->qHead);
    while ( qentry ) {
        if ( qentry->evtQWhat == keyDown
            &&   ( ((qentry->evtQModifiers & controlKey) != 0)
                && ((qentry->evtQMessage & charCodeMask) ==   3))
              || ( ((qentry->evtQModifiers & cmdKey    ) != 0)
                && ((qentry->evtQMessage & charCodeMask) == '.')) ) {
            syNrIntr++;
        }
        qentry = (struct EvQEl *)(qentry->qLink);
    }

    /* check for interrupts                                                */
    syIsIntr = syIsIntr || (syNrIntr != 0);

    /* flush away all keyboard events after an interrupt                   */
    if ( syNrIntr ) {
        FlushEvents( keyDownMask, 0 );
        syNrIntr = 0;
    }

    /* return whether an interrupt has happened                            */
    return syIsIntr;
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * * * * output * * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  syEchoch( <ch>, <fid> ) . . . . . . . . . . . echo a char to <fid>, local
*/


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . .  BSD/MACH
*/
#if SYS_BSD || SYS_MACH || HAVE_SGTTY_H

void syEchoch (
    Int                 ch,
    Int                 fid )
{
    Char                ch2;

    /* write the character to the associate echo output device             */
    ch2 = ch;
    write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );

    /* if running under a window handler, duplicate '@'                    */
    if ( SyWindow && ch == '@' ) {
        ch2 = ch;
        write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );
    }
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#if SYS_USG || HAVE_TERMIO_H

void syEchoch (
    Int                 ch,
    Int                 fid )
{
    Char                ch2;

    /* write the character to the associate echo output device             */
    ch2 = ch;
    write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );

    /* if running under a window handler, duplicate '@'                    */
    if ( SyWindow && ch == '@' ) {
        ch2 = ch;
        write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );
    }
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . . OS2 EMX
*/
#if SYS_OS2_EMX

void syEchoch (
    Int                 ch,
    Int                 fid )
{
    Char                ch2;

    /* write the character to the associate echo output device             */
    ch2 = ch;
    write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );

    /* if running under a window handler, duplicate '@'                    */
    if ( SyWindow && ch == '@' ) {
        ch2 = ch;
        write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );
    }
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . .  MS-DOS
*/
#if SYS_MSDOS_DJGPP

void syEchoch (
    Int                 ch,
    Int                 fid )
{
    PUTCHAR( ch );
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . . . . TOS
*/
#if SYS_TOS_GCC2

void syEchoch (
    Int                 ch,
    Int                 fid )
{
    PUTCHAR( ch );
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#if SYS_VMS

void syEchoch (
    Int                 ch,
    Int                 fid )
{
    Char                ch2;

    /* write the character to the associate echo output device             */
    ch2 = ch;
    write( fileno(syBuf[fid].echo), (char*)&ch2, 1 );
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . . MAC MPW
*/
#if SYS_MAC_MPW

void syEchoch (
    Int                 ch,
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> ) . . . . . . . . . . . . . . . . . . . . . MAC SYC
*/
#if SYS_MAC_SYC

void syEchoch (
    Int                 ch,
    Int                 fid )
{

    /* probably only paranoid                                              */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return;

    /* echo the character                                                  */
    if ( 31 < (ch & 0x7F) || ch == '\b' || ch == '\n' || ch == '\r' )
        putchar( ch );
    else if ( ch == CTR('G') )
        SysBeep( 1 );
    else
        putchar( '?' );

}

#endif


/****************************************************************************
**
*F  SyEchoch( <ch>, <fid> ) . . . . . . . . . . . . .  echo a char from <fid>
*/
Int SyEchoch (
    Int                 ch,
    Int                 fid )
{
    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }
    syEchoch(ch,fid);
    return 0;
}



/****************************************************************************
**
*F  syEchos( <ch>, <fid> )  . . . . . . . . . . . echo a char to <fid>, local
*/


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . .  BSD/MACH
*/
#if SYS_BSD || SYS_MACH || HAVE_SGTTY_H

void syEchos (
    Char *              str,
    Int                 fid )
{
    /* if running under a window handler, send the line to it              */
    if ( SyWindow && fid < 4 )
        syWinPut( fid, (fid == 1 ? "@n" : "@f"), str );

    /* otherwise, write it to the associate echo output device             */
    else
        write( fileno(syBuf[fid].echo), str, SyStrlen(str) );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#if SYS_USG || HAVE_TERMIO_H

void syEchos (
    Char *              str,
    Int                 fid )
{
    /* if running under a window handler, send the line to it              */
    if ( SyWindow && fid < 4 )
        syWinPut( fid, (fid == 1 ? "@n" : "@f"), str );

    /* otherwise, write it to the associate echo output device             */
    else
        write( fileno(syBuf[fid].echo), str, SyStrlen(str) );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . . OS2 EMX
*/
#if SYS_OS2_EMX

void syEchos (
    Char *              str,
    Int                 fid )
{
    /* if running under a window handler, send the line to it              */
    if ( SyWindow && fid < 4 )
        syWinPut( fid, (fid == 1 ? "@n" : "@f"), str );

    /* otherwise, write it to the associate echo output device             */
    else
        write( fileno(syBuf[fid].echo), str, SyStrlen(str) );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . .  MS-DOS
*/
#if SYS_MSDOS_DJGPP

void syEchos (
    Char *              str,
    Int                 fid )
{
    Char *              s;

    /* handle stopped output                                               */
    while ( syStopout )  syStopout = (GETKEY() == CTR('S'));

    /* echo the string                                                     */
    for ( s = str; *s != '\0'; s++ )
        PUTCHAR( *s );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . . . . TOS
*/
#if SYS_TOS_GCC2

void syEchos (
    Char *              str,
    Int                 fid )
{
    Char *              s;

    /* handle stopped output                                               */
    while ( syStopout )  syStopout = (GETKEY() == CTR('S'));

    /* echo the string                                                     */
    for ( s = str; *s != '\0'; s++ )
        PUTCHAR( *s );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#if SYS_VMS

void            syEchos (
    Char *              str,
    Int                 fid )
{
    write( fileno(syBuf[fid].echo), str, SyStrlen(str) );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . . MAC MPW
*/
#if SYS_MAC_MPW

void syEchos (
    Char *              str,
    Int                 fid )
{
    Char *              s;
    for ( s = str; *s != '\0'; s++ )
        putchar( *s );
    fflush( stdout );
}

#endif


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )  . . . . . . . . . . . . . . . . . . . . . MAC SYC
*/
#if SYS_MAC_SYC

void syEchos (
    Char *              str,
    Int                 fid )
{
    Char *              s;

    /* probably only paranoid                                              */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return;

    /* print the string                                                    */
    for ( s = str; *s != '\0'; s++ )
        putchar( *s );

}

#endif


/****************************************************************************
**
*F  SyFputs( <line>, <fid> )  . . . . . . . .  write a line to the file <fid>
**
**  'SyFputs' is called to put the  <line>  to the file identified  by <fid>.
*/
UInt   syNrchar;                        /* nr of chars already on the line */
Char   syPrompt [256];                  /* characters alread on the line   */



/****************************************************************************
**
*f  SyFputs( <line>, <fid> )  . . .  BSD/MACH/USG/OS2 EMX/VMS/MAC MPW/MAC SYC
*/
#if SYS_BSD||SYS_MACH||SYS_USG||SYS_OS2_EMX||SYS_VMS||SYS_MAC_MPW||SYS_MAC_SYC||HAVE_SGTTY_H||HAVE_TERMIO_H

void SyFputs (
    Char *              line,
    Int                 fid )
{
    UInt                i;

    /* if outputing to the terminal compute the cursor position and length */
    if ( fid == 1 || fid == 3 ) {
        syNrchar = 0;
        for ( i = 0; line[i] != '\0'; i++ ) {
            if ( line[i] == '\n' )  syNrchar = 0;
            else                    syPrompt[syNrchar++] = line[i];
        }
        syPrompt[syNrchar] = '\0';
    }

    /* otherwise compute only the length                                   */
    else {
        for ( i = 0; line[i] != '\0'; i++ )
            ;
    }

    /* if running under a window handler, send the line to it              */
    if ( SyWindow && fid < 4 )
        syWinPut( fid, (fid == 1 ? "@n" : "@f"), line );

    /* otherwise, write it to the output file                              */
    else
#if ! (SYS_MAC_MPW || SYS_MAC_SYC)
        write( fileno(syBuf[fid].fp), line, i );
#endif
#if SYS_MAC_MPW || SYS_MAC_SYC
        fputs( line, syBuf[fid].fp );
#endif
}

#endif


/****************************************************************************
**
*f  SyFputs( <line>, <fid> )  . . . . . . . . . . . . . . . . . . . MSDOS/TOS
*/
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2

void SyFputs (
    Char *              line,
    Int                 fid )
{
    UInt                i;
    Char *              s;

    /* handle the console                                                  */
    if ( isatty( fileno(syBuf[fid].fp) ) ) {

        /* test whether this is a line with a prompt                       */
        syNrchar = 0;
        for ( i = 0; line[i] != '\0'; i++ ) {
            if ( line[i] == '\n' )  syNrchar = 0;
            else                    syPrompt[syNrchar++] = line[i];
        }
        syPrompt[syNrchar] = '\0';

        /* handle stopped output                                           */
        while ( syStopout )  syStopout = (GETKEY() == CTR('S'));

        /* output the line                                                 */
        for ( s = line; *s != '\0'; s++ )
            PUTCHAR( *s );
    }

    /* ordinary file                                                       */
    else {
        fputs( line, syBuf[fid].fp );
    }

}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * * * * input  * * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyFtell( <fid> )  . . . . . . . . . . . . . . . . . .  position of stream
*/
Int SyFtell (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* cannot seek in a pipe                                               */
    if ( syBuf[fid].pipe ) {
        return -1;
    }

    /* get the position                                                    */
    return (Int) ftell(syBuf[fid].fp);
}


/****************************************************************************
**
*F  SyFseek( <fid>, <pos> )   . . . . . . . . . . . seek a position of stream
*/
Int SyFseek (
    Int                 fid,
    Int                 pos )
{
    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* cannot seek in a pipe                                               */
    if ( syBuf[fid].pipe ) {
        return -1;
    }

    /* get the position                                                    */
    fseek( syBuf[fid].fp, pos, SEEK_SET );
    return 0;
}


/****************************************************************************
**
*F  syGetch( <fid> )  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetch' reads a character from <fid>, which is switch to raw mode if it
**  is *stdin* or *errin*.
*/



/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . .  BSD/MACH
*/
#if SYS_BSD || SYS_MACH || HAVE_SGTTY_H

Int syGetch (
    Int                 fid )
{
    Char                ch;
    Char                str[2];

    /* read a character                                                    */
    while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 || ch == '\0' )
        ;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 || ch == '\0' )
                ;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
	    do {
		while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 || ch == '\0' )
		    ;
	    } while ( ch < '@' || 'z' < ch );
	    str[0] = ch;
	    str[1] = 0;
            syWinPut( fileno(syBuf[fid].echo), "@s", str );
            ch = syGetch(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

    /* return the character                                                */
    return (UChar)ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#if SYS_USG || HAVE_TERMIO_H

Int syGetch (
    Int                 fid )
{
    Char                ch;
    Char                str[2];

    /* read a character                                                    */
    while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 || ch == '\0' )
        ;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 || ch == '\0' )
                ;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
	    do {
		while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 || ch == '\0' )
		    ;
	    } while ( ch < '@' || 'z' < ch );
	    str[0] = ch;
	    str[1] = 0;
            syWinPut( fileno(syBuf[fid].echo), "@s", str );
            ch = syGetch(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

    /* return the character                                                */
    return (UChar)ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . OS2 EMX
*/
#if SYS_OS2_EMX

#ifndef SYS_KBD_H                       /* keyboard scan codes             */
# include       <sys/kbdscan.h>
# define SYS_KBD_H
#endif

Int syGetch (
    Int                 fid )
{
    UChar               ch;
    Int                 ch2;

syGetchAgain:
    /* read a character                                                    */
    while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 )
        ;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 )
                ;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
            syWinPut( fileno(syBuf[fid].echo), "@s", "" );
            ch = syGetch(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

    ch2 = ch;

    /* handle function keys                                                */
    if ( ch == '\0' ) {
        while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 )
            ;
        switch ( ch ) {
        case K_LEFT:            ch2 = CTR('B');  break;
        case K_RIGHT:           ch2 = CTR('F');  break;
        case K_UP:
        case K_PAGEUP:          ch2 = CTR('P');  break;
        case K_DOWN:
        case K_PAGEDOWN:        ch2 = CTR('N');  break;
        case K_DEL:             ch2 = CTR('D');  break;
        case K_HOME:            ch2 = CTR('A');  break;
        case K_END:             ch2 = CTR('E');  break;
        case K_CTRL_END:        ch2 = CTR('K');  break;
        case K_CTRL_LEFT:
        case K_ALT_B:           ch2 = ESC('B');  break;
        case K_CTRL_RIGHT:
        case K_ALT_F:           ch2 = ESC('F');  break;
        case K_ALT_D:           ch2 = ESC('D');  break;
        case K_ALT_DEL:
        case K_ALT_BACKSPACE:   ch2 = ESC(127);  break;
        case K_ALT_U:           ch2 = ESC('U');  break;
        case K_ALT_L:           ch2 = ESC('L');  break;
        case K_ALT_C:           ch2 = ESC('C');  break;
        case K_CTRL_PAGEUP:     ch2 = ESC('<');  break;
        case K_CTRL_PAGEDOWN:   ch2 = ESC('>');  break;
        default:                goto syGetchAgain;
        }
    }

    /* return the character                                                */
    return (UChar)ch2;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS
*/
#if SYS_MSDOS_DJGPP

Int syGetch (
    Int                 fid )
{
    Int                 ch;

    /* if chars have been typed ahead and read by 'SyIsIntr' read them     */
    if ( syTypeahead[0] != '\0' ) {
        ch = syTypeahead[0];
        strcpy( syTypeahead, syTypeahead+1 );
    }

    /* otherwise read from the keyboard                                    */
    else {
        ch = GETKEY();
    }

    /* postprocess the character                                           */
    if ( 0x110 <= ch && ch <= 0x132 )   ch = ESC( syAltMap[ch-0x110] );
    else if ( ch == 0x147 )             ch = CTR('A');
    else if ( ch == 0x14f )             ch = CTR('E');
    else if ( ch == 0x148 )             ch = CTR('P');
    else if ( ch == 0x14b )             ch = CTR('B');
    else if ( ch == 0x14d )             ch = CTR('F');
    else if ( ch == 0x150 )             ch = CTR('N');
    else if ( ch == 0x153 )             ch = CTR('D');
    else                                ch &= 0xFF;

    /* return the character                                                */
    return ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . . TOS
*/
#if SYS_TOS_GCC2

Int syGetch (
    Int                 fid )
{
    Int                 ch;

    /* if chars have been typed ahead and read by 'SyIsIntr' read them     */
    if ( syTypeahead[0] != '\0' ) {
        ch = syTypeahead[0];
        strcpy( syTypeahead, syTypeahead+1 );
    }

    /* otherwise read from the keyboard                                    */
    else {
        ch = GETKEY();
    }

    /* postprocess the character                                           */
    if (      ch == 0x00480000 )        ch = CTR('P');
    else if ( ch == 0x004B0000 )        ch = CTR('B');
    else if ( ch == 0x004D0000 )        ch = CTR('F');
    else if ( ch == 0x00500000 )        ch = CTR('N');
    else if ( ch == 0x00730000 )        ch = CTR('Y');
    else if ( ch == 0x00740000 )        ch = CTR('Z');
    else                                ch = ch & 0xFF;

    /* return the character                                                */
    return ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#if SYS_VMS

Int syGetch (
    Int                 fid )
{
    Char                ch;

    /* read a character                                                    */
    smg$read_keystroke( &syVirKbd, &ch );

    /* return the character                                                */
    return (UChar)ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
*/
#if SYS_MAC_MPW

int syGetch (
    Int                 fid )
{
    return 0;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
*/
#if SYS_MAC_SYC

Int syGetch2 (
    Int                 fid,
    Int                 cur )
{
    Int                 ch;

    /* probably only paranoid                                              */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return EOF;

    /* make the current character reverse to simulate a cursor             */
    syEchoch( (cur != '\0' ? cur : ' ') | 0x80, fid );
    syEchoch( '\b', fid );

    /* get a character, ignore EOF and chars beyond 0x7F (reverse video)   */
    while ( ((ch = getchar()) == EOF) || (0x7F < ch) )
        ;

    /* handle special characters                                           */
    if (      ch == 28 )  ch = CTR('B');
    else if ( ch == 29 )  ch = CTR('F');
    else if ( ch == 30 )  ch = CTR('P');
    else if ( ch == 31 )  ch = CTR('N');

    /* make the current character normal again                             */
    syEchoch( (cur != '\0' ? cur : ' '), fid );
    syEchoch( '\b', fid );

    /* return the character                                                */
    return ch;
}

Int syGetch (
    Int                 fid )
{
    /* return character                                                    */
    return syGetch2( fid, '\0' );
}

#endif


/****************************************************************************
**
*F  SyGetch( <fid> )  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetch' reads a character from <fid>, which is switch to raw mode if it
**  is *stdin* or *errin*.
*/
Int SyGetch (
    Int                 fid )
{
    Int                 ch;

    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* if we are reading stdin or errin use raw mode                       */
    if ( fid == 0 || fid == 2 ) {
        syStartraw(fid);
    }
    ch = syGetch(fid);
    if ( fid == 0 || fid == 2 ) {
        syStopraw(fid);
    }
    return ch;
}


/****************************************************************************
**
*F  SyGetc( <fid> ).  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetc' reads a character from <fid>, without any translation or
**   interference
*/

Int SyGetc
(
    Int                 fid )
{
  return getc(syBuf[fid].fp);
}


/****************************************************************************
**
*F  SyPutc( <fid>, <char> ).. . . . . . . . . . . . . . . put a char to <fid>
**
**  'SyPutc' writes a character to <fid>, without any translation or
**   interference
*/

extern Int SyPutc
(
    Int                 fid,
    Char                c )
{
  return putc(c,syBuf[fid].fp);
}


/****************************************************************************
**
*F  SyFgets( <line>, <lenght>, <fid> )  . . . . .  get a line from file <fid>
**
**  'SyFgets' is called to read a line from the file  with  identifier <fid>.
**  'SyFgets' (like 'fgets') reads characters until either  <length>-1  chars
**  have been read or until a <newline> or an  <eof> character is encoutered.
**  It retains the '\n' (unlike 'gets'), if any, and appends '\0' to  <line>.
**  'SyFgets' returns <line> if any char has been read, otherwise '(char*)0'.
**
**  'SyFgets'  allows to edit  the input line if the  file  <fid> refers to a
**  terminal with the following commands:
**
**      <ctr>-A move the cursor to the beginning of the line.
**      <esc>-B move the cursor to the beginning of the previous word.
**      <ctr>-B move the cursor backward one character.
**      <ctr>-F move the cursor forward  one character.
**      <esc>-F move the cursor to the end of the next word.
**      <ctr>-E move the cursor to the end of the line.
**
**      <ctr>-H, <del> delete the character left of the cursor.
**      <ctr>-D delete the character under the cursor.
**      <ctr>-K delete up to the end of the line.
**      <esc>-D delete forward to the end of the next word.
**      <esc>-<del> delete backward to the beginning of the last word.
**      <ctr>-X delete entire input line, and discard all pending input.
**      <ctr>-Y insert (yank) a just killed text.
**
**      <ctr>-T exchange (twiddle) current and previous character.
**      <esc>-U uppercase next word.
**      <esc>-L lowercase next word.
**      <esc>-C capitalize next word.
**
**      <tab>   complete the identifier before the cursor.
**      <ctr>-L insert last input line before current character.
**      <ctr>-P redisplay the last input line, another <ctr>-P will redisplay
**              the line before that, etc.  If the cursor is not in the first
**              column only the lines starting with the string to the left of
**              the cursor are taken. The history is limitied to ~8000 chars.
**      <ctr>-N Like <ctr>-P but goes the other way round through the history
**      <esc>-< goes to the beginning of the history.
**      <esc>-> goes to the end of the history.
**      <ctr>-O accept this line and perform a <ctr>-N.
**
**      <ctr>-V enter next character literally.
**      <ctr>-U execute the next command 4 times.
**      <esc>-<num> execute the next command <num> times.
**      <esc>-<ctr>-L repaint input line.
**
**  Not yet implemented commands:
**
**      <ctr>-S search interactive for a string forward.
**      <ctr>-R search interactive for a string backward.
**      <esc>-Y replace yanked string with previously killed text.
**      <ctr>-_ undo a command.
**      <esc>-T exchange two words.
*/
Char   syHistory [8192];                /* history of command lines        */
Char * syHi = syHistory;                /* actual position in history      */
UInt   syCTRO;                          /* number of '<ctr>-O' pending     */


Char * SyFgets (
    Char *              line,
    UInt                length,
    Int                 fid )
{
    Int                 ch,  ch2,  ch3, last;
    Char                * p,  * q,  * r,  * s,  * t;
    Char                * h;
    static Char         yank [512];
    Char                old [512],  new [512];
    Int                 oldc,  newc;
    Int                 rep;
    Char                buffer [512];
    Int                 rn;

    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return (Char*)0;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return (Char*)0;
    }

    /* no line editing if the file is not '*stdin*' or '*errin*'           */
    if ( fid != 0 && fid != 2 ) {
        p = fgets( line, (int)length, syBuf[fid].fp );
        return p;
    }

    /* no line editing if the user disabled it                             */
    if ( SyLineEdit == 0 ) {
        SyStopTime = SyTime();
        p = fgets( line, (int)length, syBuf[fid].fp );
        SyStartTime += SyTime() - SyStopTime;
        return p;
    }

    /* no line editing if the file cannot be turned to raw mode            */
    if ( SyLineEdit == 1 && ! syStartraw(fid) ) {
        SyStopTime = SyTime();
        p = fgets( line, (int)length, syBuf[fid].fp );
        SyStartTime += SyTime() - SyStopTime;
        return p;
    }

    /* stop the clock, reading should take no time                         */
    SyStopTime = SyTime();

    /* the line starts out blank                                           */
    line[0] = '\0';  p = line;  h = syHistory;
    for ( q = old; q < old+sizeof(old); ++q )  *q = ' ';
    oldc = 0;
    last = 0;

    while ( 1 ) {

        /* get a character, handle <ctr>V<chr>, <esc><num> and <ctr>U<num> */
        rep = 1;  ch2 = 0;
        do {
            if ( syCTRO % 2 == 1  )  { ch = CTR('N'); syCTRO = syCTRO - 1; }
            else if ( syCTRO != 0 )  { ch = CTR('O'); rep = syCTRO / 2; }
#if ! SYS_MAC_SYC
            else ch = syGetch(fid);
#endif
#if SYS_MAC_SYC
            else ch = syGetch2(fid,*p);
#endif
            if ( ch2==0        && ch==CTR('V') ) {             ch2=ch; ch=0;}
            if ( ch2==0        && ch==CTR('[') ) {             ch2=ch; ch=0;}
            if ( ch2==0        && ch==CTR('U') ) {             ch2=ch; ch=0;}
            if ( ch2==CTR('[') && ch==CTR('V') ) { ch2=ESC(CTR('V'));  ch=0;}
            if ( ch2==CTR('[') && isdigit(ch)  ) { rep=ch-'0'; ch2=ch; ch=0;}
            if ( ch2==CTR('[') && ch=='['      ) {             ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('V') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('[') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('U') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && isdigit(ch)  ) { rep=ch-'0'; ch2=ch; ch=0;}
            if ( isdigit(ch2)  && ch==CTR('V') ) {             ch2=ch; ch=0;}
            if ( isdigit(ch2)  && ch==CTR('[') ) {             ch2=ch; ch=0;}
            if ( isdigit(ch2)  && ch==CTR('U') ) {             ch2=ch; ch=0;}
            if ( isdigit(ch2)  && isdigit(ch)  ) { rep=10*rep+ch-'0';  ch=0;}
        } while ( ch == 0 );
        if ( ch2==CTR('V') )       ch  = CTV(ch);
        if ( ch2==ESC(CTR('V')) )  ch  = CTV(ch | 0x80);
        if ( ch2==CTR('[') )       ch  = ESC(ch);
        if ( ch2==CTR('U') )       rep = 4*rep;
        if ( ch2=='[' && ch=='A')  ch  = CTR('P');
        if ( ch2=='[' && ch=='B')  ch  = CTR('N');
        if ( ch2=='[' && ch=='C')  ch  = CTR('F');
        if ( ch2=='[' && ch=='D')  ch  = CTR('B');

        /* now perform the requested action <rep> times in the input line  */
        while ( rep-- > 0 ) {
            switch ( ch ) {

            case CTR('A'): /* move cursor to the start of the line         */
                while ( p > line )  --p;
                break;

            case ESC('B'): /* move cursor one word to the left             */
            case ESC('b'):
                if ( p > line ) do {
                    --p;
                } while ( p>line && (!IS_SEP(*(p-1)) || IS_SEP(*p)));
                break;

            case CTR('B'): /* move cursor one character to the left        */
                if ( p > line )  --p;
                break;

            case CTR('F'): /* move cursor one character to the right       */
                if ( *p != '\0' )  ++p;
                break;

            case ESC('F'): /* move cursor one word to the right            */
            case ESC('f'):
                if ( *p != '\0' ) do {
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case CTR('E'): /* move cursor to the end of the line           */
                while ( *p != '\0' )  ++p;
                break;

            case CTR('H'): /* delete the character left of the cursor      */
            case 127:
                if ( p == line ) break;
                --p;
                /* let '<ctr>-D' do the work                               */

            case CTR('D'): /* delete the character at the cursor           */
                           /* on an empty line '<ctr>-D' is <eof>          */
                if ( p == line && *p == '\0' && SyCTRD ) {
                    ch = EOF; rep = 0; break;
                }
                if ( *p != '\0' ) {
                    for ( q = p; *(q+1) != '\0'; ++q )
                        *q = *(q+1);
                    *q = '\0';
                }
                break;

            case CTR('X'): /* delete the line                              */
                p = line;
                /* let '<ctr>-K' do the work                               */

            case CTR('K'): /* delete to end of line                        */
                if ( last!=CTR('X') && last!=CTR('K') && last!=ESC(127)
                  && last!=ESC('D') && last!=ESC('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( s = p; *s != '\0'; ++s )  r[s-p] = *s;
                r[s-p] = '\0';
                *p = '\0';
                break;

            case ESC(127): /* delete the word left of the cursor           */
                q = p;
                if ( p > line ) do {
                    --p;
                } while ( p>line && (!IS_SEP(*(p-1)) || IS_SEP(*p)));
                if ( last!=CTR('X') && last!=CTR('K') && last!=ESC(127)
                  && last!=ESC('D') && last!=ESC('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( ; yank <= r; --r )  r[q-p] = *r;
                for ( s = p; s < q; ++s )  yank[s-p] = *s;
                for ( r = p; *q != '\0'; ++q, ++r )
                    *r = *q;
                *r = '\0';
                break;

            case ESC('D'): /* delete the word right of the cursor          */
            case ESC('d'):
                q = p;
                if ( *q != '\0' ) do {
                    ++q;
                } while ( *q!='\0' && (IS_SEP(*(q-1)) || !IS_SEP(*q)));
                if ( last!=CTR('X') && last!=CTR('K') && last!=ESC(127)
                  && last!=ESC('D') && last!=ESC('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( s = p; s < q; ++s )  r[s-p] = *s;
                r[s-p] = '\0';
                for ( r = p; *q != '\0'; ++q, ++r )
                    *r = *q;
                *r = '\0';
                break;

            case CTR('T'): /* twiddle characters                           */
                if ( p == line )  break;
                if ( *p == '\0' )  --p;
                if ( p == line )  break;
                ch2 = *(p-1);  *(p-1) = *p;  *p = ch2;
                ++p;
                break;

            case CTR('L'): /* insert last input line                       */
                for ( r = syHistory; *r != '\0' && *r != '\n'; ++r ) {
                    ch2 = *r;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                break;

            case CTR('Y'): /* insert (yank) deleted text                   */
                for ( r = yank; *r != '\0' && *r != '\n'; ++r ) {
                    ch2 = *r;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                break;

            case CTR('P'): /* fetch old input line                         */
                while ( *h != '\0' ) {
                    for ( q = line; q < p; ++q )
                        if ( *q != h[q-line] )  break;
                    if ( q == p )  break;
                    while ( *h != '\n' && *h != '\0' )  ++h;
                    if ( *h == '\n' ) ++h;
                }
                q = p;
                while ( *h!='\0' && h[q-line]!='\n' && h[q-line]!='\0' ) {
                    *q = h[q-line];  ++q;
                }
                *q = '\0';
                while ( *h != '\0' && *h != '\n' )  ++h;
                if ( *h == '\n' ) ++h;  else h = syHistory;
                syHi = h;
                break;

            case CTR('N'): /* fetch next input line                        */
                h = syHi;
                if ( h > syHistory ) {
                    do {--h;} while (h>syHistory && *(h-1)!='\n');
                    if ( h==syHistory )  while ( *h != '\0' ) ++h;
                }
                while ( *h != '\0' ) {
                    if ( h==syHistory )  while ( *h != '\0' ) ++h;
                    do {--h;} while (h>syHistory && *(h-1)!='\n');
                    for ( q = line; q < p; ++q )
                        if ( *q != h[q-line] )  break;
                    if ( q == p )  break;
                    if ( h==syHistory )  while ( *h != '\0' ) ++h;
                }
                q = p;
                while ( *h!='\0' && h[q-line]!='\n' && h[q-line]!='\0' ) {
                    *q = h[q-line];  ++q;
                }
                *q = '\0';
                while ( *h != '\0' && *h != '\n' )  ++h;
                if ( *h == '\n' ) ++h;  else h = syHistory;
                syHi = h;
                break;

            case ESC('<'): /* goto beginning of the history                */
                while ( *h != '\0' ) ++h;
                do {--h;} while (h>syHistory && *(h-1)!='\n');
                q = p = line;
                while ( *h!='\0' && h[q-line]!='\n' && h[q-line]!='\0' ) {
                    *q = h[q-line];  ++q;
                }
                *q = '\0';
                while ( *h != '\0' && *h != '\n' )  ++h;
                if ( *h == '\n' ) ++h;  else h = syHistory;
                syHi = h;
                break;

            case ESC('>'): /* goto end of the history                      */
                h = syHistory;
                p = line;
                *p = '\0';
                syHi = h;
                break;

            case CTR('S'): /* search for a line forward                    */
                /* search for a line forward, not fully implemented !!!    */
                if ( *p != '\0' ) {
                    ch2 = syGetch(fid);
                    q = p+1;
                    while ( *q != '\0' && *q != ch2 )  ++q;
                    if ( *q == ch2 )  p = q;
                }
                break;

            case CTR('R'): /* search for a line backward                   */
                /* search for a line backward, not fully implemented !!!   */
                if ( p > line ) {
                    ch2 = syGetch(fid);
                    q = p-1;
                    while ( q > line && *q != ch2 )  --q;
                    if ( *q == ch2 )  p = q;
                }
                break;

            case ESC('U'): /* uppercase word                               */
            case ESC('u'):
                if ( *p != '\0' ) do {
                    if ('a' <= *p && *p <= 'z')  *p = *p + 'A' - 'a';
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case ESC('C'): /* capitalize word                              */
            case ESC('c'):
                while ( *p!='\0' && IS_SEP(*p) )  ++p;
                if ( 'a' <= *p && *p <= 'z' )  *p = *p + 'A'-'a';
                if ( *p != '\0' ) ++p;
                /* lowercase rest of the word                              */

            case ESC('L'): /* lowercase word                               */
            case ESC('l'):
                if ( *p != '\0' ) do {
                    if ('A' <= *p && *p <= 'Z')  *p = *p + 'a' - 'A';
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case ESC(CTR('L')): /* repaint input line                      */
                syEchoch('\n',fid);
                for ( q = syPrompt; q < syPrompt+syNrchar; ++q )
                    syEchoch( *q, fid );
                for ( q = old; q < old+sizeof(old); ++q )  *q = ' ';
                oldc = 0;
                break;

            case EOF:     /* end of file on input                          */
                break;

            case CTR('M'): /* append \n and exit                           */
            case CTR('J'):
                while ( *p != '\0' )  ++p;
                *p++ = '\n'; *p = '\0';
                rep = 0;
                break;

            case CTR('O'): /* accept line, perform '<ctr>-N' next time     */
                while ( *p != '\0' )  ++p;
                *p++ = '\n'; *p = '\0';
                syCTRO = 2 * rep + 1;
                rep = 0;
                break;

            case CTR('I'): /* try to complete the identifier before dot    */
                if ( p == line || IS_SEP(p[-1]) ) {
                    ch2 = ch & 0xff;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                else {
                    if ( (q = p) > line ) do {
                        --q;
                    } while ( q>line && (!IS_SEP(*(q-1)) || IS_SEP(*q)));
                    rn = (line < q && *(q-1) == '.');
                    r = buffer;  s = q;
                    while ( s < p )  *r++ = *s++;
                    *r = '\0';
                    if ( (rn ? iscomplete_rnam( buffer, p-q )
                             : iscomplete_gvar( buffer, p-q )) ) {
                           if ( last != CTR('I') )
                            syEchoch( CTR('G'), fid );
                        else {
                            syWinPut( fid, "@c", "" );
                            syEchos( "\n    ", fid );
                            syEchos( buffer, fid );
                            while ( (rn ? completion_rnam( buffer, p-q )
                                        : completion_gvar( buffer, p-q )) ) {
                                syEchos( "\n    ", fid );
                                syEchos( buffer, fid );
                            }
                            syEchos( "\n", fid );
                            for ( q=syPrompt; q<syPrompt+syNrchar; ++q )
                                syEchoch( *q, fid );
                            for ( q = old; q < old+sizeof(old); ++q )
                                *q = ' ';
                            oldc = 0;
                            syWinPut( fid, (fid == 0 ? "@i" : "@e"), "" );
                        }
                    }
                    else if ( (rn ? ! completion_rnam( buffer, p-q )
                                  : ! completion_gvar( buffer, p-q )) ) {
                        if ( last != CTR('I') )
                            syEchoch( CTR('G'), fid );
                        else {
                            syWinPut( fid, "@c", "" );
                            syEchos("\n    identifier has no completions\n",
                                    fid);
                            for ( q=syPrompt; q<syPrompt+syNrchar; ++q )
                                syEchoch( *q, fid );
                            for ( q = old; q < old+sizeof(old); ++q )
                                *q = ' ';
                            oldc = 0;
                            syWinPut( fid, (fid == 0 ? "@i" : "@e"), "" );
                        }
                    }
                    else {
                        t = p;
                        for ( s = buffer+(p-q); *s != '\0'; s++ ) {
                            ch2 = *s;
                            for ( r = p; ch2; r++ ) {
                                ch3 = *r; *r = ch2; ch2 = ch3;
                            }
                            *r = '\0'; p++;
                        }
                        while ( t < p
                             && (rn ? completion_rnam( buffer, t-q )
                                    : completion_gvar( buffer, t-q )) ) {
                            r = t;  s = buffer+(t-q);
                            while ( r < p && *r == *s ) {
                                r++; s++;
                            }
                            s = p;  p = r;
                            while ( *s != '\0' )  *r++ = *s++;
                            *r = '\0';
                        }
                        if ( t == p ) {
                            if ( last != CTR('I') )
                                syEchoch( CTR('G'), fid );
                            else {
                                syWinPut( fid, "@c", "" );
                                buffer[t-q] = '\0';
                                while (
                                  (rn ? completion_rnam( buffer, t-q )
                                      : completion_gvar( buffer, t-q )) ) {
                                    syEchos( "\n    ", fid );
                                    syEchos( buffer, fid );
                                }
                                syEchos( "\n", fid );
                                for ( q=syPrompt; q<syPrompt+syNrchar; ++q )
                                    syEchoch( *q, fid );
                                for ( q = old; q < old+sizeof(old); ++q )
                                    *q = ' ';
                                oldc = 0;
                                syWinPut( fid, (fid == 0 ? "@i" : "@e"), "");
                            }
                        }
                    }
                }
                break;

            default:      /* default, insert normal character              */
                ch2 = ch & 0xff;
                for ( q = p; ch2; ++q ) {
                    ch3 = *q; *q = ch2; ch2 = ch3;
                }
                *q = '\0'; ++p;
                break;

            } /* switch ( ch ) */

            last = ch;

        }

        if ( ch==EOF || ch=='\n' || ch=='\r' || ch==CTR('O') ) {
            syEchoch('\r',fid);  syEchoch('\n',fid);  break;
        }

        /* now update the screen line according to the differences         */
        for ( q = line, r = new, newc = 0; *q != '\0'; ++q ) {
            if ( q == p )  newc = r-new;
            if ( *q==CTR('I') )  { do *r++=' '; while ((r-new+syNrchar)%8); }
            else if ( *q==0x7F ) { *r++ = '^'; *r++ = '?'; }
            else if ( '\0'<=*q && *q<' '  ) { *r++ = '^'; *r++ = *q+'@'; }
            else if ( ' ' <=*q && *q<0x7F ) { *r++ = *q; }
            else {
                *r++ = '\\';                 *r++ = '0'+*(UChar*)q/64%4;
                *r++ = '0'+*(UChar*)q/8 %8;  *r++ = '0'+*(UChar*)q   %8;
            }
            if ( r >= new+SyNrCols-syNrchar-2 ) {
                if ( q >= p ) { q++; break; }
                new[0] = '$';   new[1] = r[-5]; new[2] = r[-4];
                new[3] = r[-3]; new[4] = r[-2]; new[5] = r[-1];
                r = new+6;
            }
        }
        if ( q == p )  newc = r-new;
        for (      ; r < new+sizeof(new); ++r )  *r = ' ';
        if ( q[0] != '\0' && q[1] != '\0' )
            new[SyNrCols-syNrchar-2] = '$';
        else if ( q[1] == '\0' && ' ' <= *q && *q < 0x7F )
            new[SyNrCols-syNrchar-2] = *q;
        else if ( q[1] == '\0' && q[0] != '\0' )
            new[SyNrCols-syNrchar-2] = '$';
        for ( q = old, r = new; r < new+sizeof(new); ++r, ++q ) {
            if ( *q == *r )  continue;
            while (oldc<(q-old)) { syEchoch(old[oldc],fid);  ++oldc; }
            while (oldc>(q-old)) { syEchoch('\b',fid);       --oldc; }
            *q = *r;  syEchoch( *q, fid ); ++oldc;
        }
        while ( oldc < newc ) { syEchoch(old[oldc],fid);  ++oldc; }
        while ( oldc > newc ) { syEchoch('\b',fid);       --oldc; }

    }

    /* Now we put the new string into the history,  first all old strings  */
    /* are moved backwards,  then we enter the new string in syHistory[].  */
    for ( q = syHistory+sizeof(syHistory)-3; q >= syHistory+(p-line); --q )
        *q = *(q-(p-line));
    for ( p = line, q = syHistory; *p != '\0'; ++p, ++q )
        *q = *p;
    syHistory[sizeof(syHistory)-3] = '\n';
    if ( syHi != syHistory )
        syHi = syHi + (p-line);
    if ( syHi > syHistory+sizeof(syHistory)-2 )
        syHi = syHistory+sizeof(syHistory)-2;

    /* send the whole line (unclipped) to the window handler               */
    syWinPut( fid, (*line != '\0' ? "@r" : "@x"), line );

    /* strip away prompts (usefull for pasting old stuff)                  */
    if (line[0]=='g'&&line[1]=='a'&&line[2]=='p'&&line[3]=='>'&&line[4]==' ')
        for ( p = line, q = line+5; q[-1] != '\0'; p++, q++ )  *p = *q;
    if (line[0]=='b'&&line[1]=='r'&&line[2]=='k'&&line[3]=='>'&&line[4]==' ')
        for ( p = line, q = line+5; q[-1] != '\0'; p++, q++ )  *p = *q;
    if (line[0]=='>'&&line[1]==' ')
        for ( p = line, q = line+2; q[-1] != '\0'; p++, q++ )  *p = *q;

    /* switch back to cooked mode                                          */
    if ( SyLineEdit == 1 )
        syStopraw(fid);

    /* start the clock again                                               */
    SyStartTime += SyTime() - SyStopTime;

    /* return the line (or '0' at end-of-file)                             */
    if ( *line == '\0' )
        return (Char*)0;
    return line;
}


/****************************************************************************
**

*F * * * * * * * * * * * * system error messages  * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  SyLastErrorNo . . . . . . . . . . . . . . . . . . . . . last error number
*/
Int SyLastErrorNo;


/****************************************************************************
**
*V  SyLastErrorMessage  . . . . . . . . . . . . . . . . .  last error message
*/
Char SyLastErrorMessage [ 1024 ];


/****************************************************************************
**
*F  SyClearErrorNo()  . . . . . . . . . . . . . . . . .  clear error messages
*/
extern int errno;

#ifndef SYS_ERRNO_H
# include <sys/errno.h>
#endif

void SyClearErrorNo ( void )
{
    errno = 0;
    SyLastErrorNo = 0;
    SyLastErrorMessage[0] = '\0';
    SyStrncat( SyLastErrorMessage, "no error", 8 );
}


/****************************************************************************
**
*F  SySetErrorNo()  . . . . . . . . . . . . . . . . . . . . set error message
*/
#ifndef SYS_STRING_H                    /* string functions                */
# include <string.h>
# define SYS_STRING_H
#endif

#if defined(SYS_HAS_NO_STRERROR) || ! HAVE_STRERROR
extern char * sys_errlist[];
#endif

void SySetErrorNo ( void )
{
    const Char *        err;

    if ( errno != 0 ) {
        SyLastErrorNo = errno;
#if defined(SYS_HAS_NO_STRERROR) || ! HAVE_STRERROR
        err = sys_errlist[errno];
#else
        err = strerror(errno);
#endif
        SyLastErrorMessage[0] = '\0';
        SyStrncat( SyLastErrorMessage, err, 1023 );
    }
    else {
        SyClearErrorNo();
    }
}


/****************************************************************************
**


*F * * * * * * * * * * * * * file and execution * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyExec( <cmd> ) . . . . . . . . . . . execute command in operating system
**
**  'SyExec' executes the command <cmd> (a string) in the operating system.
**
**  'SyExec'  should call a command  interpreter  to execute the command,  so
**  that file name expansion and other common  actions take place.  If the OS
**  does not support this 'SyExec' should print a message and return.
**
**  For UNIX we can use 'system', which does exactly what we want.
*/
#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
#endif
#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 19.2   */
extern  int             system ( const char * );
#endif

#if ! (SYS_MAC_MPW || SYS_MAC_SYC)

void SyExec (
    Char *              cmd )
{
    Int                 ignore;

    syWinPut( 0, "@z", "" );
    ignore = system( cmd );
    syWinPut( 0, "@mAgIc", "" );
}

#endif

#if SYS_MAC_MPW || SYS_MAC_SYC

void SyExec (
    Char *              cmd;
{
}

#endif


/****************************************************************************
**
*F  SyExecuteProcess( <dir>, <prg>, <in>, <out>, <args> ) . . . . new process
**
**  Start  <prg> in  directory <dir>  with  standard input connected to <in>,
**  standard  output  connected to <out>   and arguments.  No  path search is
**  performed, the return  value of the process  is returned if the operation
**  system supports such a concept.
*/


/****************************************************************************
**
*f  SyExecuteProcess( <dir>, <prg>, <in>, <out>, <args> ) . . .  BSD/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || HAVE_FORK

#ifndef SYS_PID_T
#define SYS_PID_T       pid_t
#endif

#if  SYS_OS2_EMX
#include <sys/types.h>
#endif

#ifndef CONFIG_H

#include        <sys/wait.h>

#else

#if HAVE_UNION_WAIT
# include <sys/wait.h>
#else
# include <sys/types.h>
# if HAVE_SYS_WAIT_H
#  include <sys/wait.h>
# endif
# ifndef WEXITSTATUS
#  define WEXITSTATUS(stat_val) ((unsigned)(stat_val) >> 8)
# endif
# ifndef WIFEXITED
#  define WIFEXITED(stat_val) (((stat_val) & 255) == 0)
# endif
#endif

#endif

#ifndef SYS_FCNTL_H
#include        <fcntl.h>
#endif

#ifndef SYS_HAS_WAIT_PROTO
# ifdef SYS_HAS_WAIT4
   extern int wait4(int, int *, int, struct rusage *);
# endif
#endif

extern char ** environ;


UInt SyExecuteProcess (
    Char *                  dir,
    Char *                  prg,
    Int                     in,
    Int                     out,
    Char *                  args[] )
{
    SYS_PID_T               pid;                    /* process id          */
#if HAVE_UNION_WAIT
    union wait              status;                 /* non POSIX           */
#else
    int                     status;                 /* do not use `Int'    */
#endif
    Int                     tin;                    /* temp in             */
    Int                     tout;                   /* temp out            */
    SYS_SIG_T               (*func)(int);

#if defined(SYS_HAS_WAIT4) || HAVE_WAIT4
    struct rusage           usage;
#endif


    /* clone the process                                                   */
    pid = SYS_MY_FORK();
    if ( pid == -1 ) {
        return -1;
    }

    /* we are the parent                                                   */
    if ( pid != 0 ) {

        /* ignore a CTRL-C                                                 */
        func = signal( SIGINT, SIG_IGN );

        /* wait for some action                                            */
#if defined(SYS_HAS_WAIT4) || HAVE_WAIT4

        if ( wait4( pid, &status, 0, &usage ) == -1 ) {
            signal( SIGINT, func );
            return -1;
        }
        if ( WIFSIGNALED(status) ) {
            signal( SIGINT, func );
            return -1;
        }
        signal( SIGINT, func );
        return WEXITSTATUS(status);

#else

        if ( waitpid( pid, &status, 0 ) == -1 ) {
            signal( SIGINT, func );
            return -1;
        }
        if ( WIFSIGNALED(status) ) {
            signal( SIGINT, func );
            return -1;
        }
        signal( SIGINT, func );
        return WEXITSTATUS(status);

#endif
    }

    /* we are the child                                                    */
    else {

        /* change the working directory                                    */
        if ( chdir(dir) == -1 ) {
            _exit(-1);
        }

        /* if <in> is -1 open "/dev/null"                                  */
        if ( in == -1 ) {
            tin = open( "/dev/null", O_RDONLY );
            if ( tin == -1 ) {
                _exit(-1);
            }
        }
        else {
            tin = SyFileno(in);
        }

        /* if <out> is -1 open "/dev/null"                                 */
        if ( out == -1 ) {
            tout = open( "/dev/null", O_WRONLY );
            if ( tout == -1 ) {
                _exit(-1);
            }
        }
        else {
            tout = SyFileno(out);
        }

        /* set standard input to <in>, standard output to <out>            */
        if ( tin != 0 ) {
            if ( dup2( tin, 0 ) == -1 ) {
                _exit(-1);
            }
        }
        fcntl( 0, F_SETFD, 0 );

        if ( tout != 1 ) {
            if ( dup2( tout, 1 ) == -1 ) {
                _exit(-1);
            }
        }
        fcntl( 1, F_SETFD, 0 );

        /* now try to execute the program                                  */
        execve( prg, args, environ );
        _exit(-1);
    }

    /* this should not happen                                              */
    return -1;
}
    
#endif


/****************************************************************************
**

*F  SyIsExistingFile( <name> )  . . . . . . . . . . . does file <name> exists
**
**  'SyIsExistingFile' returns 1 if the  file <name> exists and 0  otherwise.
**  It does not check if the file is readable, writable or excuteable. <name>
**  is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsExistingFile( <name> )  . . . . . . . . . . . . . . .  using `access'
*/
#if HAVE_ACCESS

Int SyIsExistingFile ( Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, F_OK );
    if ( res == -1 ) {
        if ( errno != ENOENT ) {
            SySetErrorNo();
        }
        else {
            res = 1;
        }
    }
    return res;
}

#endif


/****************************************************************************
**
*F  SyIsReadableFile( <name> )  . . . . . . . . . . . is file <name> readable
**
**  'SyIsReadableFile'   returns 1  if the   file  <name> is   readable and 0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsReadableFile( <name> )  . . . . . . . . . . . . . . .  using `access'
*/
#if HAVE_ACCESS

Int SyIsReadableFile ( Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, R_OK );
    if ( res == -1 ) {
        SySetErrorNo();
    }
    return res;
}

#endif


/****************************************************************************
**
*F  SyIsWritableFile( <name> )  . . . . . . . . . is the file <name> writable
**
**  'SyIsWritableFile'   returns  1  if  the  file  <name> is  writable and 0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsWritableFile( <name> )  . . . . . . . . . . . . . . .  using `access'
*/
#if HAVE_ACCESS

Int SyIsWritableFile ( Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, W_OK );
    if ( res == -1 ) {
        if ( errno != EROFS && errno != EACCES ) {
            SySetErrorNo();
        }
        else {
            res = 1;
        }
    }
    return res;
}

#endif


/****************************************************************************
**
*F  SyIsExecutableFile( <name> )  . . . . . . . . . is file <name> executable
**
**  'SyIsExecutableFile' returns 1 if the  file <name>  is  executable and  0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsExecutableFile( <name> )  . . . . . . . . . . . . . .  using `access'
*/
#if HAVE_ACCESS

Int SyIsExecutableFile ( Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, X_OK );
    if ( res == -1 ) {
        if ( errno == EACCES ) {
            if ( SyIsExistingFile(name) == 0 ) {
                res = 1;
            }
            else {
                errno = EACCES;
                SySetErrorNo();
            }
        }
        else {
            SySetErrorNo();
        }
    }
    return res;
}

#endif


/****************************************************************************
**
*F  SyIsDirectoryPath( <name> ) . . . . . . . . .  is file <name> a directory
**
**  'SyIsDirectoryPath' returns 1 if the  file <name>  is a directory  and  0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsDirectoryPath( <name> ) . . . . . . . . . . . . . . . .  using `stat'
*/
#if SYS_OS2_EMX
#include <sys/types.h>
#endif

#if HAVE_STAT

#include <sys/stat.h>

Int SyIsDirectoryPath ( Char * name )
{
    struct stat     buf;                /* buffer for `stat'               */

    SyClearErrorNo();
    if ( stat( name, &buf ) == -1 ) {
        SySetErrorNo();
        return -1;
    }
    return S_ISDIR(buf.st_mode) ? 0 : 1;
}

#endif


/****************************************************************************
**
*F  SyRemoveFile( <name> )  . . . . . . . . . . . . . . .  remove file <name>
*/


/****************************************************************************
**
*f  SyRemoveFile( <name> )  . . . . . . . . . . . . . . . . .  using `unlink'
*/
#if HAVE_UNLINK

Int SyRemoveFile ( Char * name )
{
    return unlink(name);
}

#endif


/****************************************************************************
**
*F  SyFindGapRootFile( <filename> ) . . . . . . . .  find file in system area
*/
Char * SyFindGapRootFile ( Char * filename )
{
    static Char     result [256];
    Int             k;

    for ( k=0;  k<sizeof(SyGapRootPaths)/sizeof(SyGapRootPaths[0]);  k++ ) {
        if ( SyGapRootPaths[k][0] ) {
            result[0] = '\0';
            SyStrncat( result, SyGapRootPaths[k], sizeof(result) );
            if ( sizeof(result) <= SyStrlen(filename)+SyStrlen(result)-1 )
                continue;
            SyStrncat( result, filename, SyStrlen(filename) );
            if ( SyIsReadableFile(result) == 0 ) {
                return result;
            }
        }
    }
    return 0;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * * directories  * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyTmpname() . . . . . . . . . . . . . . . . . return a temporary filename
**
**  'SyTmpname' creates and returns  a new temporary name.  Subsequent  calls
**  to 'SyTmpname'  should  produce different  file names  *even* if no files
**  were created.
*/
#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include       <stdio.h>
# define SYS_STDIO_H
#endif

#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 15.16  */
extern  char * tmpnam ( char * );
#endif

Char * SyTmpname ( void )
{
    static Char   * base = 0;
    static Char     name[1024];
    static Int      count = 0;
    Char            cnt[5];

    SyClearErrorNo();
    count++;
    if ( base == 0 ) {
        base = tmpnam( (char*)0 );
    }
    if ( base == 0 ) {
        SySetErrorNo();
        return 0;
    }
    name[0] = 0;
    SyStrncat( name, base, SyStrlen(base) );
    SyStrncat( name, ".", 1 );
    cnt[0] = (count/1000) % 10 + '0';
    cnt[1] = (count/ 100) % 10 + '0';
    cnt[2] = (count/  10) % 10 + '0';
    cnt[3] = (count/   1) % 10 + '0';
    cnt[4] = 0;
    SyStrncat( name, cnt, 5 );
    return name;
}


/****************************************************************************
**
*F  SyTmpdir( <hint> )  . . . . . . . . . . . .  return a temporary directory
**
**  'SyTmpdir'  returns the directory   for  a temporary directory.  This  is
**  guaranteed  to be newly  created and empty  immediately after the call to
**  'SyTmpdir'. <hint> should be used by 'SyTmpdir' to  construct the name of
**  the directory (but 'SyTmpdir' is free to use only  a part of <hint>), and
**  must be a string of at most 8 alphanumerical characters.  Under UNIX this
**  would   usually   represent   '/usr/tmp/<hint>_<proc_id>_<cnt>/',   e.g.,
**  '/usr/tmp/guava_17188_1/'.
*/


/****************************************************************************
**
*f  SyTmpdir( <hint> )  . . . . . . . . . . . . . . . . . . . . using `mkdir'
*/
#if HAVE_MKDIR

Char * SyTmpdir ( Char * hint )
{
    Char *      tmp;
    int         res;                    /* result of `mkdir'               */

    /* for the moment ignore <hint>                                        */
    tmp = SyTmpname();
    if ( tmp == 0 )
        return 0;

    /* create a new directory                                              */
    res = mkdir( tmp, 0777 );
    if ( res == -1 ) {
        SySetErrorNo();
        return 0;
    }

    return tmp;
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    Obj             list;
    Obj             tmp;
    UInt            gvar;
    Int             len;
    Int             i;
    Int             j;
    Char *          p;
    Char *          q;

    /* GAP_ARCHITECTURE                                                    */
    tmp = NEW_STRING(SyStrlen(SyArchitecture));
    RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
    SyStrncat( CSTR_STRING(tmp), SyArchitecture, SyStrlen(SyArchitecture) );
    gvar = GVarName("GAP_ARCHITECTURE");
    AssGVar( gvar, tmp );
    MakeReadOnlyGVar(gvar);

    /* GAP_ROOT_PATH                                                       */
    list = NEW_PLIST( T_PLIST+IMMUTABLE, MAX_GAP_DIRS );
    for ( i = 0, j = 1;  i < MAX_GAP_DIRS;  i++ ) {
        if ( SyGapRootPaths[i][0] ) {
            len = SyStrlen(SyGapRootPaths[i]);
            tmp = NEW_STRING(len);
            RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
            SyStrncat( CSTR_STRING(tmp), SyGapRootPaths[i], len );
            SET_ELM_PLIST( list, j, tmp );
            j++;
        }
    }
    SET_LEN_PLIST( list, j-1 );
    gvar = GVarName("GAP_ROOT_PATHS");
    AssGVar( gvar, list );
    MakeReadOnlyGVar(gvar);

    /* DIRECTORIES_SYSTEM_PROGRAMS                                         */
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || HAVE_PATH_ENV
    list = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( list, 0 );
    for ( p = getenv("PATH"), i = 0, q = p;  ;  p++, i++ ) {
        if ( *p == ':' || *p == '\0' ) {
            if ( i == 0 ) {
                tmp = NEW_STRING(2);
                RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
                SyStrncat( CSTR_STRING(tmp), "./", 2 );
            }
            else {
                if ( q[-1] == '/' ) {
                    tmp = NEW_STRING(i);
                    RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
                    SyStrncat( CSTR_STRING(tmp), q, i );
                }
                else {
                    tmp = NEW_STRING(i+1);
                    RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
                    SyStrncat( CSTR_STRING(tmp), q, i );
                    SyStrncat( CSTR_STRING(tmp), "/", 1 );
                }
            }
            AddPlist( list, tmp );
            i = -1;
            q = p+1;
        }
        if ( *p == '\0' )
            break;
    }
#endif
    RetypeBag( list, IMMUTABLE_TNUM(TNUM_OBJ(list)) );
    gvar = GVarName("DIRECTORIES_SYSTEM_PROGRAMS");
    AssGVar( gvar, list );
    MakeReadOnlyGVar(gvar);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoSysFiles()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "sysfiles",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    0,                                  /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoSysFiles ( void )
{
    module.revision_c = Revision_sysfiles_c;
    module.revision_h = Revision_sysfiles_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  sysfiles.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
