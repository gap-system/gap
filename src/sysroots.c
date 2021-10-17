/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
*/

#include "sysroots.h"

#include "gaputils.h"
#include "plist.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "sysstr.h"

#include <stdlib.h>


/****************************************************************************
**
*V  SyGapRootPaths  . . . . . . . . . . . . . . . . . . . array of root paths
**
**  'SyGapRootPaths' contains the  names   of the directories where   the GAP
**  files are located.
**
**  It is modified by the command line option -l.
**
**  It is copied into the GAP variable 'GAPInfo.RootPaths' and used by
**  'SyFindGapRootFile'.
**
**  Each entry must end  with the pathname separator, e.g. if 'init.g' is the
**  name of a library file 'strcat( SyGapRootPaths[i], "lib/init.g" );'  must
**  be a valid filename.
*/
enum { MAX_GAP_DIRS = 16 };
static Char SyGapRootPaths[MAX_GAP_DIRS][GAP_PATH_MAX];


/****************************************************************************
**
*F  SyFindGapRootFile( <filename>, <buf>, <size> ) . find file in system area
**
**  <buf> must point to a buffer of at least <size> characters. This function
**  then searches for a readable file with the name <filename> in the system
**  area. If sich a file is found then its absolute path is copied into
**  <buf>, and <buf> is returned. If no file is found or if <buf> is not big
**  enough, then <buf> is set to an empty string and NULL is returned.
*/
Char * SyFindGapRootFile(const Char * filename, Char * buf, size_t size)
{
    for (int k = 0; k < ARRAY_SIZE(SyGapRootPaths); k++) {
        if (SyGapRootPaths[k][0]) {
            if (gap_strlcpy(buf, SyGapRootPaths[k], size) >= size)
                continue;
            if (gap_strlcat(buf, filename, size) >= size)
                continue;
            if (SyIsReadableFile(buf) == 0) {
                return buf;
            }
        }
    }
    buf[0] = '\0';
    return 0;
}


/****************************************************************************
**
*F  SySetGapRootPath( <string> )  . . . . . . . . .  set the root directories
**
**  'SySetGapRootPath' takes a string and modifies a list of root directories
**  in 'SyGapRootPaths'.
**
**  A  leading semicolon in  <string> means  that the list  of directories in
**  <string> is  appended  to the  existing list  of  root paths.  A trailing
**  semicolon means they are prepended.   If there is  no leading or trailing
**  semicolon, then the root paths are overwritten.
**
**  This function assumes that the system uses '/' as path separator.
**  Currently, we support nothing else. For Windows (or rather: Cygwin), we
**  rely on a small hack which converts the path separator '\' used there
**  on '/' on the fly. Put differently: Systems that use completely different
**  path separators, or none at all, are currently not supported.
*/
void SySetGapRootPath(const Char * string)
{
    const Char * p;
    Char *       q;
    Int          i;
    Int          n;

    /* set string to a default value if unset                              */
    if (string == 0 || *string == 0) {
        string = "./";
    }

    /*
    ** check if we append, prepend or overwrite.
    */
    if (string[0] == ';') {
        /* Count the number of root directories already present.           */
        n = 0;
        while (SyGapRootPaths[n][0] != '\0')
            n++;

        /* Skip leading semicolon.                                        */
        string++;
    }
    else if (string[strlen(string) - 1] == ';') {
        /* Count the number of directories in 'string'.                    */
        n = 0;
        p = string;
        while (*p)
            if (*p++ == ';')
                n++;

        /* Find last root path.                                            */
        for (i = 0; i < MAX_GAP_DIRS; i++)
            if (SyGapRootPaths[i][0] == '\0')
                break;
        i--;

#ifdef HPCGAP
        n *= 2;    // for each root <ROOT> we also add <ROOT/hpcgap> as a root
#endif

        /* Move existing root paths to the back                            */
        if (i + n >= MAX_GAP_DIRS)
            return;
        while (i >= 0) {
            memcpy(SyGapRootPaths[i + n], SyGapRootPaths[i],
                   sizeof(SyGapRootPaths[i + n]));
            i--;
        }

        n = 0;
    }
    else {
        /* Make sure to wipe out all possibly existing root paths          */
        for (i = 0; i < MAX_GAP_DIRS; i++)
            SyGapRootPaths[i][0] = '\0';
        n = 0;
    }

    /* unpack the argument                                                 */
    p = string;
    while (*p) {
        if (n >= MAX_GAP_DIRS)
            return;

        q = SyGapRootPaths[n];
        while (*p && *p != ';') {
            *q = *p++;

#ifdef SYS_IS_CYGWIN32
            // change backslash to slash for Windows
            if (*q == '\\')
                *q = '/';
#endif

            q++;
        }
        if (q == SyGapRootPaths[n]) {
            strxcpy(SyGapRootPaths[n], "./", sizeof(SyGapRootPaths[n]));
        }
        else if (q[-1] != '/') {
            *q++ = '/';
            *q = '\0';
        }
        else {
            *q = '\0';
        }
        if (*p) {
            p++;
        }
        n++;
#ifdef HPCGAP
        // for each root <ROOT> to be added, we first add <ROOT/hpcgap> as a root
        if (n < MAX_GAP_DIRS) {
            gap_strlcpy(SyGapRootPaths[n], SyGapRootPaths[n - 1],
                    sizeof(SyGapRootPaths[n]));
        }
        strxcat(SyGapRootPaths[n - 1], "hpcgap/",
                sizeof(SyGapRootPaths[n - 1]));
        n++;
#endif
    }

    // replace leading tilde ~ by HOME environment variable
    // TODO; instead of iterating over all entries each time, just
    // do this for the new entries
    char * userhome = getenv("HOME");
    if (!userhome || !*userhome)
        return;
    const UInt userhomelen = strlen(userhome);
    for (i = 0; i < MAX_GAP_DIRS && SyGapRootPaths[i][0]; i++) {
        const UInt pathlen = strlen(SyGapRootPaths[i]);
        if (SyGapRootPaths[i][0] == '~' &&
            userhomelen + pathlen < sizeof(SyGapRootPaths[i])) {
            SyMemmove(SyGapRootPaths[i] + userhomelen,
                      /* don't copy the ~ but the trailing '\0' */
                      SyGapRootPaths[i] + 1, pathlen);
            memcpy(SyGapRootPaths[i], userhome, userhomelen);
        }
    }
}


/****************************************************************************
**
*F  SyGetGapRootPaths()
*/
Obj SyGetGapRootPaths(void)
{
    Obj tmp = NEW_PLIST_IMM(T_PLIST, MAX_GAP_DIRS);
    for (int i = 0; i < MAX_GAP_DIRS; i++) {
        if (SyGapRootPaths[i][0]) {
            PushPlist(tmp, MakeImmString(SyGapRootPaths[i]));
        }
    }
    MakeImmutableNoRecurse(tmp);
    return tmp;
}
