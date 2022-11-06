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

#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern int realmain(int argc, char * argv[]);

/****************************************************************************
**
*F * * * * * * * * * * finding location of executable * * * * * * * * * * * *
*/

#ifdef SYS_DEFAULT_PATHS

static void SetupInitialGapRoot(const char * argv0)
{
    SySetGapRootPath(SYS_DEFAULT_PATHS);
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
        if (realpath(argv0, result) && !access(result, F_OK)) {
            return;    // success
        }
    }
    // relative path, like 'bin/gap.sh'
    else if (strchr(argv0, '/')) {
        if (!getcwd(tmpbuf, sizeof(tmpbuf)))
            return;
        gap_strlcat(tmpbuf, "/", sizeof(tmpbuf));
        gap_strlcat(tmpbuf, argv0, sizeof(tmpbuf));
        if (realpath(tmpbuf, result) && !access(result, F_OK)) {
            return;    // success
        }
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
            if (realpath(tmpbuf, result) && !access(result, F_OK)) {
                return;    // success
            }
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
        ssize_t ret = readlink("/proc/self/exe", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
    }

    // try FreeBSD / DragonFly BSD procfs
    if (!*locBuf) {
        ssize_t ret = readlink("/proc/curproc/file", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
    }

    // try NetBSD procfs
    if (!*locBuf) {
        ssize_t ret = readlink("/proc/curproc/exe", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
    }

    // if we are still failing, go and search the path
    if (!*locBuf) {
        find_yourself(argv0, locBuf, GAP_PATH_MAX);
    }

    // resolve symlinks (if present)
    if (!realpath(locBuf, GAPExecLocation))
        *GAPExecLocation = 0;    // reset buffer after error

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
                SySetGapRootPath(pathbuf);
                // escape from loop
                return;
            }
            // try up a directory level
            strxcat(pathbuf, "../", sizeof(pathbuf));
        }
    }

    // Set GAP root path to current directory, if we have no other
    // idea, and for backwards compatibility.
    // Note that GAPExecLocation must always end with a slash.
    SySetGapRootPath("./");
}

static void SetupInitialGapRoot(const char * argv0)
{
    char GAPExecLocation[GAP_PATH_MAX] = "";
    SetupGAPLocation(argv0, GAPExecLocation);
    SySetInitialGapRootPaths(GAPExecLocation);
}
#endif

int main(int argc, char * argv[])
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
