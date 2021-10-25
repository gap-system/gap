/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**
**  This file will contains the functions for communicating with other
**  processes via ptys and sockets
**
**  The eventual intent is that there will be InputOutputStreams at the GAP
**  level with some API to be defined, and two ways of creating them. One is
**  like Process except that the external process is left running, the other
**  connects as client to a specified socket.
**
**  At this level, we provide the two interfaces separately. For each we have
**  an integer identifer for each open connection, and creation, read and
**  write functions, and possibly some sort of probe function.
**
*/

#include "iostream.h"

#include "bool.h"
#include "error.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "stringobj.h"
#include "sysenv.h"

#include "hpc/thread.h"

#include "config.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <termios.h>
#include <unistd.h>

#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#ifdef HAVE_OPENPTY
  #if defined(HAVE_UTIL_H)
    #include <util.h>     /* for openpty() on Mac OS X, OpenBSD and NetBSD */
  #elif defined(HAVE_LIBUTIL_H)
    #include <libutil.h>  /* for openpty() on FreeBSD */
  #elif defined(HAVE_PTY_H)
    #include <pty.h>      /* for openpty() on Cygwin, Interix, OSF/1 4 and 5 */
  #endif
#endif

#ifdef HAVE_SPAWN_H
#define __USE_GNU    // ensures glibc exports posix_spawn_file_actions_addchdir_np
#include <spawn.h>
#endif


// LOCKING
// In HPC-GAP, be sure to HashLock PtyIOStreams before accessing any of
// the IOStream related variables, including FreeptyIOStreams

typedef struct {
  pid_t childPID;   /* Also used as a link to make a linked free list */
  int ptyFD;      /* GAP reading from external prog */
  int inuse;      /* we need to scan all the "live" structures when we have
                     had SIGCHLD so, for now, we just walk the array for
                     the ones marked in use */
  int changed;    /* set non-zero by the signal handler if our child has
                     done something -- stopped or exited */
  int status;     /* status from wait3 -- meaningful only if changed is 1 */
  int blocked;    /* we have already reported a problem, which is still there */
  int alive;      /* gets set after waiting for a child actually fails
                     implying that the child has vanished under our noses */
} PtyIOStream;

enum {
    /* maximal number of pseudo ttys we will allocate */
    MAX_PTYS = 64,

    /* maximal length of argument string for CREATE_PTY_IOSTREAM */
    MAX_ARGS = 1000
};

static PtyIOStream PtyIOStreams[MAX_PTYS];

// FreePtyIOStreams is the index of the first unused slot of the PtyIOStreams
// array, or else -1 if there is none. The childPID field of each free slot in
// turn is set to the position of the next free slot (or -1), so that the free
// slots form a linked list.
static Int FreePtyIOStreams;

static Int NewStream(void)
{
    Int stream = -1;
    if (FreePtyIOStreams != -1) {
        stream = FreePtyIOStreams;
        FreePtyIOStreams = PtyIOStreams[stream].childPID;
    }
    return stream;
}

static void FreeStream(UInt stream)
{
    PtyIOStreams[stream].childPID = FreePtyIOStreams;
    FreePtyIOStreams = stream;
}

/****************************************************************************
**
*F  SignalChild(<stream>) . .. . . . . . . . . .  interrupt the child process
*/
static void SignalChild(UInt stream, UInt sig)
{
    if (PtyIOStreams[stream].childPID != -1) {
        kill(PtyIOStreams[stream].childPID, sig);
    }
}

/****************************************************************************
**
*F  KillChild(<stream>) . . . . . . . . . . . . . . .  kill the child process
*/
static void KillChild(UInt stream)
{
    if (PtyIOStreams[stream].childPID != -1) {
        close(PtyIOStreams[stream].ptyFD);
        SignalChild(stream, SIGKILL);
    }
}


/****************************************************************************
**
*/
#define PErr(msg)                                                            \
    Pr(msg ": %s (errno %d)\n", (Int)strerror(errno), (Int)errno);

/****************************************************************************
**
*F  OpenPty( <parent>, <child> ) . . . . . . . . open a pseudo terminal
*/

#ifdef HAVE_OPENPTY

static UInt OpenPty(int * parent, int * child)
{
    /* openpty is available on OpenBSD, NetBSD and FreeBSD, Mac OS X,
       Cygwin, Interix, OSF/1 4 and 5, and glibc (since 1998), and hence
       on most modern Linux systems. See also:
       https://www.gnu.org/software/gnulib/manual/html_node/openpty.html */
    return (openpty(parent, child, NULL, NULL, NULL) < 0);
}

#elif defined(HAVE_POSIX_OPENPT)

static UInt OpenPty(int * parent, int * child)
{
    /* Attempt to use POSIX 98 pseudo ttys. Opening a parent tty is done
       via posix_openpt, which is available on virtually every current
       UNIX system; indeed, according to gnulib, it is available on at
       least the following systems:
         - glibc >= 2.2.1 (released January 2001; but is a stub on GNU/Hurd),
         - Mac OS X >= 10.4 (released April 2005),
         - FreeBSD >= 5.1 (released June 2003),
         - NetBSD >= 3.0 (released December 2005),
         - AIX >= 5.2 (released October 2002),
         - HP-UX >= 11.31 (released February 2007),
         - Solaris >= 10 (released January 2005),
         - Cygwin >= 1.7 (released December 2009).
       Systems lacking posix_openpt (in addition to older versions of
       the systems listed above) include:
         - OpenBSD
         - Minix 3.1.8
         - IRIX 6.5
         - OSF/1 5.1
         - mingw
         - MSVC 9
         - Interix 3.5
         - BeOS
       */
    *parent = posix_openpt(O_RDWR | O_NOCTTY);
    if (*parent < 0) {
        PErr("OpenPty: posix_openpt failed");
        return 1;
    }

    if (grantpt(*parent)) {
        PErr("OpenPty: grantpt failed");
        goto error;
    }
    if (unlockpt(*parent)) {
        close(*parent);
        PErr("OpenPty: unlockpt failed");
        goto error;
    }

    *child = open(ptsname(*parent), O_RDWR, 0);
    if (*child < 0) {
        PErr("OpenPty: opening child tty failed");
        goto error;
    }
    return 0;

error:
    close(*parent);
    return 1;
}

#else

static UInt OpenPty(int * parent, int * child)
{
    Pr("no pseudo tty support available\n", 0, 0);
    return 1;
}

#endif


/****************************************************************************
**
*F  StartChildProcess( <dir>, <name>, <args> )
**  Start a subprocess using ptys. Returns the stream number of the IOStream
**  that is connected to the new processs
*/


// Clean up a signalled or exited child process
// CheckChildStatusChanged must be called by libraries which replace GAP's
// signal handler, or call 'waitpid'.
// The function should be passed a PID, and the return value of waitpid.
// Returns 1 if that PID was a child owned by GAP, or 0 otherwise.
int CheckChildStatusChanged(int childPID, int status)
{
    GAP_ASSERT(childPID > 0);
    GAP_ASSERT((WIFEXITED(status) || WIFSIGNALED(status)));
    HashLock(PtyIOStreams);
    for (UInt i = 0; i < MAX_PTYS; i++) {
        if (PtyIOStreams[i].inuse && PtyIOStreams[i].childPID == childPID) {
            PtyIOStreams[i].changed = 1;
            PtyIOStreams[i].status = status;
            PtyIOStreams[i].blocked = 0;
            HashUnlock(PtyIOStreams);
            return 1;
        }
    }
    HashUnlock(PtyIOStreams);
    return 0;
}

static void ChildStatusChanged(int whichsig)
{
    UInt i;
    int  status;
    int  retcode;
    assert(whichsig == SIGCHLD);
    HashLock(PtyIOStreams);
    for (i = 0; i < MAX_PTYS; i++) {
        if (PtyIOStreams[i].inuse) {
            retcode = waitpid(PtyIOStreams[i].childPID, &status,
                              WNOHANG | WUNTRACED);
            if (retcode != -1 && retcode != 0 &&
                (WIFEXITED(status) || WIFSIGNALED(status))) {
                PtyIOStreams[i].changed = 1;
                PtyIOStreams[i].status = status;
                PtyIOStreams[i].blocked = 0;
            }
        }
    }
    HashUnlock(PtyIOStreams);

#if !defined(HPCGAP)
    /* Collect up any other zombie children */
    do {
        retcode = waitpid(-1, &status, WNOHANG);
        if (retcode == -1 && errno != ECHILD)
            Pr("#E Unexpected waitpid error %d\n", errno, 0);
    } while (retcode != 0 && retcode != -1);

    signal(SIGCHLD, ChildStatusChanged);
#endif
}

#ifdef HPCGAP
static Obj FuncDEFAULT_SIGCHLD_HANDLER(Obj self)
{
    ChildStatusChanged(SIGCHLD);
    return (Obj)0;
}
#endif


//
// posix_spawn_file_actions_addchdir was only recently added to POSIX, and
// most implementations therefore do not yet use this final name, but instead
// provide the functionality under the alternate name
// posix_spawn_file_actions_addchdir_np. To keep things simple, we detect this
// case and use some preprocessor tricks to make things work in either case.
//
#if !defined(HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR) &&                      \
    defined(HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP)
#define HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR
#define posix_spawn_file_actions_addchdir(f, d)                              \
    posix_spawn_file_actions_addchdir_np(f, d)
#endif


// Disable posix_spawn in HPC-GAP if we can't use it in a thread-safe manner
#if defined(HPCGAP) && !defined(HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR)
#undef HAVE_POSIX_SPAWN
#endif

// if neither posix_spawn_file_actions_addchdir nor O_CLOEXEC are available,
// our posix_spawn code should not be used. This affects e.g. Linux systems
// with an old glibc, see https://github.com/gap-system/gap/issues/3918.
#if !defined(HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR) && !defined(O_CLOEXEC)
#undef HAVE_POSIX_SPAWN
#endif


#ifdef HAVE_POSIX_SPAWN

// O_DIRECTORY is not available in old Linux / glibc versions, but the way we
// use it below, it is optional anyway
#ifndef O_DIRECTORY
#define O_DIRECTORY 0
#endif


// The following function behaves like posix_spawn, but also
// changes the working directory temporarily to 'dir'.
static int posix_spawn_with_dir(pid_t *                      pid,
                                const char *                 path,
                                posix_spawn_file_actions_t * file_actions,
                                const posix_spawnattr_t *    attrp,
                                char * const                 argv[],
                                char * const                 envp[],
                                const char *                 dir)
{
    // For systems that don't support fork+exec well (e.g. embedded systems,
    // but also Windows), the POSIX Issue 6 (~2001) added posix_spawn() and
    // friends. These can be used as a replacement for fork+exec in many
    // applications. However, they curiously miss one very common demand when
    // launching subprocesses: there is no way to override the working
    // directory for the child process. This well-known deficiency has finally
    // been realized as a problem by POSIX in 2018, just about 17 years after
    // posix_spawn was first put into the standard, and so we might see a
    // proper fix for this soon, i.e., possibly even within the next decade!
    // See also <http://austingroupbugs.net/view.php?id=1208>.
    //
    // UPDATE: musl libc 1.1.24, glibc 2.29 and macOS 10.15 added preview
    // versions of these new APIs (with suffix `_np` to indicate it), so we
    // can actually start using them.

#ifdef HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR
    if (posix_spawn_file_actions_addchdir(file_actions, dir)) {
        PErr("StartChildProcess: addchdir failed");
        return 1;
    }
#else
    // For older systems that lack posix_spawn_file_actions_addchdir or
    // posix_spawn_file_actions_addchdir_np, we use the following fallback
    // code.
    //
    // WARNING: This is not thread safe! As explained above, until recently,
    // there was no portable way to do this race free, without using an
    // external shim executable which sets the wd and then calls the actually
    // target executable.
    int oldwd = open(".", O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (oldwd == -1) {
        PErr("StartChildProcess: cannot open current working directory");
        return 1;
    }
    if (chdir(dir) == -1) {
        PErr("StartChildProcess: cannot change working "
             "directory for subprocess");
        return 1;
    }
#endif

    // spawn subprocess
    int res = posix_spawn(pid, path, file_actions, attrp, argv, envp);
    if (res) {
        PErr("StartChildProcess: posix_spawn failed");
    }

#ifndef HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR
    // restore working directory
    if (fchdir(oldwd)) {
        PErr("StartChildProcess: failed to restore working dir");
    }
    close(oldwd);    // ignore error
#endif
    return res;
}

#endif


static Int
StartChildProcess(const Char * dir, const Char * prg, Char * args[])
{
    int child; /* pipe to child                   */
    Int stream;

    struct termios tst; /* old and new terminal state      */

    HashLock(PtyIOStreams);

    /* Get a stream record */
    stream = NewStream();
    if (stream == -1) {
        HashUnlock(PtyIOStreams);
        return -1;
    }

    /* open pseudo terminal for communication with gap */
    if (OpenPty(&PtyIOStreams[stream].ptyFD, &child)) {
        PErr("StartChildProcess: open pseudo tty failed");
        FreeStream(stream);
        HashUnlock(PtyIOStreams);
        return -1;
    }

    /* Now fiddle with the terminal sessions on the pty */
    if (tcgetattr(child, &tst) == -1) {
        PErr("StartChildProcess: tcgetattr on child pty failed");
        goto cleanup;
    }
    tst.c_cc[VINTR] = 0377;
    tst.c_cc[VQUIT] = 0377;
    tst.c_iflag    &= ~(INLCR|ICRNL);
    tst.c_cc[VMIN]  = 1;
    tst.c_cc[VTIME] = 0;
    tst.c_lflag    &= ~(ECHO|ICANON);
    tst.c_oflag    &= ~(ONLCR);
    if (tcsetattr(child, TCSANOW, &tst) == -1) {
        PErr("StartChildProcess: tcsetattr on child pty failed");
        goto cleanup;
    }

    /* set input to non blocking operation */
    /* Not any more */

    PtyIOStreams[stream].inuse = 1;
    PtyIOStreams[stream].alive = 1;
    PtyIOStreams[stream].blocked = 0;
    PtyIOStreams[stream].changed = 0;
    /* fork */
#ifdef HAVE_POSIX_SPAWN
    posix_spawn_file_actions_t file_actions;

    // setup file actions
    if (posix_spawn_file_actions_init(&file_actions)) {
        PErr("StartChildProcess: posix_spawn_file_actions_init failed");
        goto cleanup;
    }

    if (posix_spawn_file_actions_addclose(&file_actions,
                                          PtyIOStreams[stream].ptyFD)) {
        PErr("StartChildProcess: addclose failed");
        posix_spawn_file_actions_destroy(&file_actions);
        goto cleanup;
    }

    if (posix_spawn_file_actions_adddup2(&file_actions, child, 0)) {
        PErr("StartChildProcess: adddup2(child, 0) failed");
        posix_spawn_file_actions_destroy(&file_actions);
        goto cleanup;
    }

    if (posix_spawn_file_actions_adddup2(&file_actions, child, 1)) {
        PErr("StartChildProcess: adddup2(child, 1) failed");
        posix_spawn_file_actions_destroy(&file_actions);
        goto cleanup;
    }

    // spawn subprocess
    if (posix_spawn_with_dir(&PtyIOStreams[stream].childPID, prg,
                             &file_actions, 0, args, environ, dir)) {
        PErr("StartChildProcess: posix_spawn_with_dir failed");
        goto cleanup;
    }

    // cleanup
    if (posix_spawn_file_actions_destroy(&file_actions)) {
        PErr("StartChildProcess: posix_spawn_file_actions_destroy failed");
        goto cleanup;
    }
#else
    PtyIOStreams[stream].childPID = fork();
    if (PtyIOStreams[stream].childPID == 0) {
        /* Set up the child */
        close(PtyIOStreams[stream].ptyFD);
        if (dup2(child, 0) == -1)
            _exit(-1);
        fcntl(0, F_SETFD, 0);

        if (dup2(child, 1) == -1)
            _exit(-1);
        fcntl(1, F_SETFD, 0);

        if (chdir(dir) == -1) {
            _exit(-1);
        }

#ifdef HAVE_SETPGID
        setpgid(0, 0);
#endif

        execv(prg, args);

        /* This should never happen */
        close(child);
        _exit(1);
    }
#endif

    /* Now we're back in the parent */
    /* check if the fork was successful */
    if (PtyIOStreams[stream].childPID == -1) {
        PErr("StartChildProcess: cannot fork to subprocess");
        goto cleanup;
    }
    close(child);


    HashUnlock(PtyIOStreams);
    return stream;

cleanup:
    close(child);
    close(PtyIOStreams[stream].ptyFD);
    PtyIOStreams[stream].inuse = 0;
    FreeStream(stream);
    HashUnlock(PtyIOStreams);
    return -1;
}


// This function assumes that the caller invoked HashLock(PtyIOStreams).
// It unlocks just before throwing any error.
static void HandleChildStatusChanges(UInt pty)
{
    /* common error handling, when we are asked to read or write to a stopped
       or dead child */
    if (PtyIOStreams[pty].alive == 0) {
        PtyIOStreams[pty].changed = 0;
        PtyIOStreams[pty].blocked = 0;
        HashUnlock(PtyIOStreams);
        ErrorQuit("Child Process is unexpectedly dead", 0, 0);
    }
    else if (PtyIOStreams[pty].blocked) {
        HashUnlock(PtyIOStreams);
        ErrorQuit("Child Process is still dead", 0, 0);
    }
    else if (PtyIOStreams[pty].changed) {
        PtyIOStreams[pty].blocked = 1;
        PtyIOStreams[pty].changed = 0;
        Int cPID = PtyIOStreams[pty].childPID;
        Int status = PtyIOStreams[pty].status;
        HashUnlock(PtyIOStreams);
        ErrorQuit("Child Process %d has stopped or died, status %d", cPID,
                  status);
    }
}

static Obj FuncCREATE_PTY_IOSTREAM(Obj self, Obj dir, Obj prog, Obj args)
{
    Obj    allargs[MAX_ARGS + 1];
    Char * argv[MAX_ARGS + 2];
    UInt   i, len;
    Int    pty;
    len = LEN_LIST(args);
    if (len > MAX_ARGS)
        ErrorQuit("Too many arguments", 0, 0);
    ConvString(dir);
    ConvString(prog);
    for (i = 1; i <= len; i++) {
        allargs[i] = ELM_LIST(args, i);
        ConvString(allargs[i]);
    }
    /* From here we cannot afford to have a garbage collection */
    argv[0] = CSTR_STRING(prog);
    for (i = 1; i <= len; i++) {
        argv[i] = CSTR_STRING(allargs[i]);
    }
    argv[i] = (Char *)0;
    pty = StartChildProcess(CONST_CSTR_STRING(dir), CONST_CSTR_STRING(prog),
                            argv);
    if (pty < 0)
        return Fail;
    else
        return ObjInt_Int(pty);
}


static Int ReadFromPty2(UInt stream, Char * buf, Int maxlen, UInt block)
{
    /* read at most maxlen bytes from stream, into buf.
      If block is non-zero then wait for at least one byte
      to be available. Otherwise don't. Return the number of
      bytes read, or -1 for error. A blocking return having read zero bytes
      definitely indicates an end of file */

    Int nread = 0;
    int ret;

    while (maxlen > 0) {
#ifdef HAVE_SELECT
        if (!block || nread > 0) {
            fd_set         set;
            struct timeval tv;
            do {
                FD_ZERO(&set);
                FD_SET(PtyIOStreams[stream].ptyFD, &set);
                tv.tv_sec = 0;
                tv.tv_usec = 0;
                ret = select(PtyIOStreams[stream].ptyFD + 1, &set, NULL, NULL,
                             &tv);
            } while (ret == -1 && errno == EAGAIN);
            if (ret == -1 && nread == 0)
                return -1;
            if (ret < 1)
                return nread ? nread : -1;
        }
#endif
        do {
            ret = read(PtyIOStreams[stream].ptyFD, buf, maxlen);
        } while (ret == -1 && errno == EAGAIN);
        if (ret == -1 && nread == 0)
            return -1;
        if (ret < 1)
            return nread;
        nread += ret;
        buf += ret;
        maxlen -= ret;
    }
    return nread;
}


static UInt WriteToPty(UInt stream, Char * buf, Int len)
{
    Int res;
    Int old;
    if (len < 0) {
        // FIXME: why allow 'len' to be negative here? To allow
        // invoking a "raw" version of `write` perhaps? But we don't
        // seem to use that anywhere. So perhaps get rid of it or
        // even turn it into an error?!
        return write(PtyIOStreams[stream].ptyFD, buf, -len);
    }
    old = len;
    while (0 < len) {
        res = write(PtyIOStreams[stream].ptyFD, buf, len);
        if (res < 0) {
            HandleChildStatusChanges(stream);
            if (errno == EAGAIN) {
                continue;
            }
            else
                // FIXME: by returning errno, we make it impossible for the
                // caller to detect errors.
                return errno;
        }
        len -= res;
        buf += res;
    }
    return old;
}

static UInt HashLockStreamIfAvailable(Obj stream)
{
    UInt pty = INT_INTOBJ(stream);
    HashLock(PtyIOStreams);
    if (!PtyIOStreams[pty].inuse) {
        HashUnlock(PtyIOStreams);
        ErrorMayQuit("IOSTREAM %d is not in use", pty, 0);
    }
    return pty;
}

static Obj FuncWRITE_IOSTREAM(Obj self, Obj stream, Obj string, Obj len)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    HandleChildStatusChanges(pty);
    ConvString(string);
    UInt result = WriteToPty(pty, CSTR_STRING(string), INT_INTOBJ(len));
    HashUnlock(PtyIOStreams);
    return ObjInt_Int(result);
}

static Obj FuncREAD_IOSTREAM(Obj self, Obj stream, Obj len)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    /* HandleChildStatusChanges(pty);   Omit this to allow picking up
     * "trailing" bytes*/
    Obj string = NEW_STRING(INT_INTOBJ(len));
    Int ret = ReadFromPty2(pty, CSTR_STRING(string), INT_INTOBJ(len), 1);
    HashUnlock(PtyIOStreams);
    if (ret == -1)
        return Fail;
    SET_LEN_STRING(string, ret);
    ResizeBag(string, SIZEBAG_STRINGLEN(ret));
    return string;
}

static Obj FuncREAD_IOSTREAM_NOWAIT(Obj self, Obj stream, Obj len)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    /* HandleChildStatusChanges(pty);   Omit this to allow picking up
     * "trailing" bytes*/
    Obj string = NEW_STRING(INT_INTOBJ(len));
    Int ret = ReadFromPty2(pty, CSTR_STRING(string), INT_INTOBJ(len), 0);
    HashUnlock(PtyIOStreams);
    if (ret == -1)
        return Fail;
    SET_LEN_STRING(string, ret);
    ResizeBag(string, SIZEBAG_STRINGLEN(ret));
    return string;
}

static Obj FuncKILL_CHILD_IOSTREAM(Obj self, Obj stream)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    /* Don't check for child having changes status */
    KillChild(pty);

    HashUnlock(PtyIOStreams);
    return 0;
}

static Obj FuncSIGNAL_CHILD_IOSTREAM(Obj self, Obj stream, Obj sig)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    /* Don't check for child having changes status */
    SignalChild(pty, INT_INTOBJ(sig));

    HashUnlock(PtyIOStreams);
    return 0;
}

static Obj FuncCLOSE_PTY_IOSTREAM(Obj self, Obj stream)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    /* Close down the child */
    int status;
    int retcode = close(PtyIOStreams[pty].ptyFD);
    if (retcode)
        Pr("Strange close return code %d\n", retcode, 0);
    kill(PtyIOStreams[pty].childPID, SIGTERM);
    // GAP (or another library) might wait on this PID before
    // we handle it. If that happens, waitpid will return -1.
    retcode = waitpid(PtyIOStreams[pty].childPID, &status, WNOHANG);
    if (retcode == 0) {
        // Give process a second to quit
        sleep(1);
        retcode = waitpid(PtyIOStreams[pty].childPID, &status, WNOHANG);
    }
    if (retcode == 0) {
        // Hard kill process
        kill(PtyIOStreams[pty].childPID, SIGKILL);
        retcode = waitpid(PtyIOStreams[pty].childPID, &status, 0);
    }

    PtyIOStreams[pty].inuse = 0;

    FreeStream(pty);
    HashUnlock(PtyIOStreams);
    return 0;
}

static Obj FuncIS_BLOCKED_IOSTREAM(Obj self, Obj stream)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    int isBlocked = (PtyIOStreams[pty].blocked || PtyIOStreams[pty].changed ||
                     !PtyIOStreams[pty].alive);
    HashUnlock(PtyIOStreams);
    return isBlocked ? True : False;
}

static Obj FuncFD_OF_IOSTREAM(Obj self, Obj stream)
{
    UInt pty = HashLockStreamIfAvailable(stream);

    Obj result = ObjInt_Int(PtyIOStreams[pty].ptyFD);
    HashUnlock(PtyIOStreams);
    return result;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_3ARGS(CREATE_PTY_IOSTREAM, dir, prog, args),
    GVAR_FUNC_3ARGS(WRITE_IOSTREAM, stream, string, len),
    GVAR_FUNC_2ARGS(READ_IOSTREAM, stream, len),
    GVAR_FUNC_2ARGS(READ_IOSTREAM_NOWAIT, stream, len),
    GVAR_FUNC_1ARGS(KILL_CHILD_IOSTREAM, stream),
    GVAR_FUNC_1ARGS(CLOSE_PTY_IOSTREAM, stream),
    GVAR_FUNC_2ARGS(SIGNAL_CHILD_IOSTREAM, stream, signal),
    GVAR_FUNC_1ARGS(IS_BLOCKED_IOSTREAM, stream),
    GVAR_FUNC_1ARGS(FD_OF_IOSTREAM, stream),
#ifdef HPCGAP
    GVAR_FUNC_0ARGS(DEFAULT_SIGCHLD_HANDLER),
#endif

    { 0, 0, 0, 0, 0 }
};
  
/* FIXME/TODO: should probably do some checks preSave for open files etc and
   refuse to save if any are found */

/****************************************************************************
**
*F  InitKernel( <module> ) . . . . . . .  initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    UInt i;
    PtyIOStreams[0].childPID = -1;
    for (i = 1; i < MAX_PTYS; i++) {
        PtyIOStreams[i].childPID = i - 1;
        PtyIOStreams[i].inuse = 0;
    }
    FreePtyIOStreams = MAX_PTYS - 1;

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable(GVarFuncs);

#if !defined(HPCGAP)
    /* Set up the trap to detect future dying children */
    signal(SIGCHLD, ChildStatusChanged);
#endif

    return 0;
}

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/

static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);

    return 0;
}

/****************************************************************************
**
*F  InitInfoSysFiles()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "iostream",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoIOStream(void)
{
    return &module;
}
