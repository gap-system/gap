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
#include "listfunc.h"
#include "plist.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "sysstr.h"
#include "system.h"

#include <stdlib.h>


/****************************************************************************
**
*V  SyDefaultRootPath
**
**  Default initial root path. Default is the current directory, if we have
**  no other idea, for backwards compatibility.
*/
char SyDefaultRootPath[GAP_PATH_MAX] = "./";


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
Obj SyGapRootPaths;


/****************************************************************************
**
*F  SyFindGapRootFile( <filename> ) . . . . . . . .  find file in system area
**
**  This function searches for a readable file with the name <filename> in
**  the system area. If such a file is found then its absolute path is
**  returned as a string object. If no file is found then NULL is returned.
*/
Obj SyFindGapRootFile(const Char * filename)
{
    int len = strlen(filename);
    int npaths = LEN_PLIST(SyGapRootPaths);
    for (int k = 1; k <= npaths; k++) {
        Obj path = CopyToStringRep(ELM_PLIST(SyGapRootPaths, k));
        AppendCStr(path, filename, len);
        if (SyIsReadableFile(CSTR_STRING(path)) == 0) {
            return path;
        }
    }
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
    Int pos = 1;

    if (SyGapRootPaths == 0) {
        SyGapRootPaths = NEW_PLIST(T_PLIST_EMPTY, 0); // FIXME
    }


    // set string to a default value if unset
    if (string == 0 || *string == 0) {
        string = "./";
    }

    // check if we append, prepend or overwrite.
    if (string[0] == ';') {
        // append
        pos = LEN_PLIST(SyGapRootPaths) + 1;

        // Skip leading semicolon.
        string++;
    }
    else if (string[strlen(string) - 1] == ';') {
        // prepend
    }
    else {
        SET_LEN_PLIST(SyGapRootPaths, 0);
        RetypeBagSM(SyGapRootPaths, T_PLIST_EMPTY);
        // TODO: also adjust filters...
    }

    // unpack the argument
    const Char * p = string;
    while (*p) {
        Obj path;

        // locate next semicolon or string end
        const Char * q = p;
        while (*q && *q != ';') {
            q++;
        }

        if (q == p) {
            // empty string treated as ./
            path = MakeString("./");
            // TODO: insert output of getcwd??
        } else {
            if (*p == '~') {
                const char * userhome = getenv("HOME");
                if (!userhome)
                    userhome = "";
                path = MakeString(userhome);
                p++;
                AppendCStr(path, p, q - p);
            }
            else {
                path = MakeStringWithLen(p, q - p);
            }

            Char * r = CSTR_STRING(path);
    #ifdef SYS_IS_CYGWIN32
            while (*r) {
                // change backslash to slash for Windows
                if (*r == '\\')
                    *r = '/';
                r++;
            }
    #endif

            // ensure path ends with a slash
            r = CSTR_STRING(path) + GET_LEN_STRING(path) - 1;
            if (*r != '/') {
                AppendCStr(path, "/", 1);
            }
        }

        p = *q ? q + 1 : q;

        AddPlist3(SyGapRootPaths, path, pos);
        pos++;

#ifdef HPCGAP
        // for each root <ROOT> to be added, we first add <ROOT/hpcgap> as a root
        path = CopyToStringRep(path);
        AppendCStr(path, "hpcgap/", 7);

        AddPlist3(SyGapRootPaths, path, pos);
        pos++;
#endif
    }
}


/****************************************************************************
**
*F  SyGetGapRootPaths()
*/
Obj SyGetGapRootPaths(void)
{
    return SyGapRootPaths;
}
