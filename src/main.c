/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "common.h"
#include "sysfiles.h"
#include "sysroots.h"
#include "sysstr.h"
#include "system.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#endif

#include "config.h"

#include <stdlib.h>     // for getenv, realpath, ...
#include <string.h>     // for snprintf
#include <unistd.h>     // for access, readlink, ...

#if defined(__APPLE__) && defined(__MACH__)
// Workaround: TRUE / FALSE are also defined by the macOS Mach-O headers
#define ENUM_DYLD_BOOL
#include <mach-o/dyld.h>
#endif

extern int realmain(int argc, const char * argv[]);

/****************************************************************************
**
*F * * * * * * * * * * finding location of executable * * * * * * * * * * * *
*/

#ifdef SYS_DEFAULT_PATHS

static void SetupInitialGapRoot(const char * argv0)
{
    gap_strlcpy(SyDefaultRootPath, SYS_DEFAULT_PATHS, sizeof(SyDefaultRootPath));
}

#else

/****************************************************************************
**
** The function 'find_yourself' is based on code (C) 2015 Mark Whitis, under
** the MIT License : https://stackoverflow.com/a/34271901/928031
*/
static void
find_yourself(const char * argv0, char * result, size_t resultsize)
{
    GAP_ASSERT(resultsize >= GAP_PATH_MAX);

    char tmpbuf[GAP_PATH_MAX];

    // absolute path, like '/usr/bin/gap'
    if (argv0[0] == '/') {
#ifdef HAVE_REALPATH
        if (realpath(argv0, result) && !access(result, F_OK)) {
            return;    // success
        }
#else
        // Fallback: just copy the path and check if it exists
        gap_strlcpy(result, argv0, resultsize);
        if (!access(result, F_OK)) {
            return;    // success
        }
#endif
    }
    // relative path, like 'bin/gap.sh'
    else if (strchr(argv0, '/')) {
        if (!getcwd(tmpbuf, sizeof(tmpbuf)))
            return;
        gap_strlcat(tmpbuf, "/", sizeof(tmpbuf));
        gap_strlcat(tmpbuf, argv0, sizeof(tmpbuf));
#ifdef HAVE_REALPATH
        if (realpath(tmpbuf, result) && !access(result, F_OK)) {
            return;    // success
        }
#else
        // Fallback: just copy the constructed path and check if it exists
        gap_strlcpy(result, tmpbuf, resultsize);
        if (!access(result, F_OK)) {
            return;    // success
        }
#endif
    }
    // executable name, like 'gap'
    else {
        char pathenv[GAP_PATH_MAX], *saveptr, *pathitem;
        gap_strlcpy(pathenv, getenv("PATH"), sizeof(pathenv));
        pathitem = strtok_r(pathenv, ":", &saveptr);
        for (; pathitem; pathitem = strtok_r(NULL, ":", &saveptr)) {
            gap_strlcpy(tmpbuf, pathitem, sizeof(tmpbuf));
            gap_strlcat(tmpbuf, "/", sizeof(tmpbuf));
            gap_strlcat(tmpbuf, argv0, sizeof(tmpbuf));
#ifdef HAVE_REALPATH
            if (realpath(tmpbuf, result) && !access(result, F_OK)) {
                return;    // success
            }
#else
            // Fallback: just copy the constructed path and check if it exists
            gap_strlcpy(result, tmpbuf, resultsize);
            if (!access(result, F_OK)) {
                return;    // success
            }
#endif
        }
    }

    *result = 0;    // reset buffer after error
}

static void SetupGAPLocation(const char * argv0, char * GAPExecLocation)
{
    // In the code below, we keep resetting locBuf, as some of the methods we
    // try do not promise to leave the buffer empty on a failed return.
    char locBuf[GAP_PATH_MAX] = "";
    Int4 length = 0;

#if defined(__APPLE__) && defined(__MACH__)
    uint32_t len = sizeof(locBuf);
    if (_NSGetExecutablePath(locBuf, &len) != 0) {
        *locBuf = 0;    // reset buffer after error
    }
#endif

    // try Linux procfs
    if (!*locBuf) {
#ifdef HAVE_READLINK
        ssize_t ret = readlink("/proc/self/exe", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
#endif
    }

    // try FreeBSD / DragonFly BSD procfs
    if (!*locBuf) {
#ifdef HAVE_READLINK
        ssize_t ret = readlink("/proc/curproc/file", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
#endif
    }

    // try NetBSD procfs
    if (!*locBuf) {
#ifdef HAVE_READLINK
        ssize_t ret = readlink("/proc/curproc/exe", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
#endif
    }

    // if we are still failing, go and search the path
    if (!*locBuf) {
        find_yourself(argv0, locBuf, GAP_PATH_MAX);
    }

    // resolve symlinks (if present)
#ifdef HAVE_REALPATH
    if (!realpath(locBuf, GAPExecLocation))
        *GAPExecLocation = 0;    // reset buffer after error
#else
    // Fallback: just copy the path without resolving symlinks
    gap_strlcpy(GAPExecLocation, locBuf, GAP_PATH_MAX);
#endif

    // now strip the executable name off
    length = strlen(GAPExecLocation);
    while (length > 0 && GAPExecLocation[length] != '/') {
        GAPExecLocation[length] = 0;
        length--;
    }
}

/****************************************************************************
**
*F  SySetInitialGapRootPaths( <string> )  . . . . .  set the root directories
**
**  Set up GAP's initial root paths, based on the location of the
**  GAP executable.
*/
static void SySetInitialGapRootPaths(const char * GAPExecLocation)
{
    if (GAPExecLocation[0] != 0) {
        // GAPExecLocation might be a subdirectory of GAP root,
        // so we will go and search for the true GAP root.
        // We try stepping back up to two levels.
        char pathbuf[GAP_PATH_MAX];
        char initgbuf[GAP_PATH_MAX];
        strxcpy(pathbuf, GAPExecLocation, sizeof(pathbuf));
        for (Int i = 0; i < 3; ++i) {
            strxcpy(initgbuf, pathbuf, sizeof(initgbuf));
            strxcat(initgbuf, "lib/init.g", sizeof(initgbuf));

            if (SyIsReadableFile(initgbuf) == 0) {
                gap_strlcpy(SyDefaultRootPath, pathbuf, sizeof(SyDefaultRootPath));
                // escape from loop
                return;
            }
            // try up a directory level
            strxcat(pathbuf, "../", sizeof(pathbuf));
        }
    }
}

static void SetupInitialGapRoot(const char * argv0)
{
    char GAPExecLocation[GAP_PATH_MAX] = "";
    SetupGAPLocation(argv0, GAPExecLocation);
    SySetInitialGapRootPaths(GAPExecLocation);
}
#endif

int main(int argc, const char * argv[])
{
    InstallBacktraceHandlers();
    SetupInitialGapRoot(argv[0]);

#ifdef HPCGAP
    RunThreadedMain(realmain, argc, argv);
    return 0;
#else
    return realmain(argc, argv);
#endif
}
