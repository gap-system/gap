/***************************************************************************
**
*A  io.c               IO-package                            Max Neunhoeffer
**
**  
**  Copyright (C) by Max Neunhoeffer
**  This file is free software, see license information at the end.
**  
*/

const char * Revision_io_c =
   "io.c, V4.0";

/* Try to use as much of the GNU C library as possible: */
#define _GNU_SOURCE

#include "src/compiled.h"          /* GAP headers                */

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION

#include "pkgconfig.h"    /* our own autoconf results */

/* Note that SIZEOF_VOID_P comes from GAP's config.h whereas
 * SIZEOF_VOID_PP comes from pkgconfig.h! */
#if SIZEOF_VOID_PP != SIZEOF_VOID_P
#error GAPs word size is different from ours, 64bit/32bit mismatch
#endif

#include "src/aobjects.h"
#include <stdlib.h>
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
#include <sys/socket.h>
#endif
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_TIME_H
#include <time.h>
#endif
#include <errno.h>
#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif
#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_DIRENT_H
#include <dirent.h>
#endif
#ifdef HAVE_NETDB_H
#include <netdb.h>
#endif
#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif
#ifdef HAVE_SIGNAL_H
/* Maybe the GAP kernel headers have already included it: */
#ifndef SYS_SIGNAL_H
#include <signal.h>
#endif
#endif
/* We should test for existence of netinet/in.h and netinet/tcp.h, but
 * this would require a change in the GAP configure script, which is
 * tedious. */
#ifdef HAVE_NETINET_IN_H
#include <netinet/in.h>
/* #include <netinet/ip.h> */
#endif
#ifdef HAVE_NETINET_TCP_H
#include <netinet/tcp.h>
#endif
#if SYS_IS_CYGWIN32
#include <cygwin/in.h>
#endif

/* The following seems to be necessary to run under modern gcc compilers
 * which have the ssp stack checking enabled. Hopefully this does not
 * hurt in future or other versions... */
#ifdef __GNUC__
#if (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 1))
#if SYS_IS_CYGWIN32 == 0
extern void __stack_chk_fail();
void __stack_chk_fail_local (void)
{
  __stack_chk_fail ();
}
#endif
#endif
#endif


/* Functions that are done:
 * open, creat, read, write, close, unlink, lseek, opendir, readdir, 
 * closedir, rewinddir, telldir, seekdir, link, rename, symlink, readlink,
 * rmdir, mkdir, stat, lstat, fstat, chmod, fchmod, chown, fchown, lchown,
 * mknod, mkfifo, dup, dup2, socket, bind, connect, gethostbyname, listen,
 * accept, recv, recvfrom, send, sendto, getsockopt, setsockopt, select,
 * fork, execv, execvp, execve, pipe, exit, getsockname, gethostname,
 *
 * Additional helper functions:
 * make_sockaddr_in, MakeEnvList, environ,
 */

/* Functions that are to do (maybe later):
 *   
 * and perhaps:
 *   socketpair, getsockname, poll, setrlimit, getrlimit, getrusage, ulimit, 
 * NOTE: There are some problems with respect to signal handling,
 *       because the code for InputOutputLocalProcess and things
 *       has a signal handler for SIGCHLD, which interferes with
 *       things. This is solved in the sense that our SIGCHLD handler
 *       can be switched on and off, thereby providing support for
 *       either InputOutputLocalProcess *or* fork/exec and friends.
 * not for the moment (portability or implementation problems):
 *   remove, scandir, ioctl? (absolutely unportable, as it seems), 
 *   fcntl? (for file locking purposes), recvmsg, sendmsg, 
 */

/***********************************************************************
 * First we have our own SIGCHLD handler. It is a copy of the one in the
 * GAP kernel, however, information about all children that are not 
 * coming from streams is stored in one data structure here, such that
 * we can read it out from GAP using IO.Wait. 
 ***********************************************************************/

#define MAXCHLDS 1024
/* The following arrays make a FIFO structure: */
static int maxstats = MAXCHLDS;    /* This number must always be the same */
static int stats[MAXCHLDS];        /* than this number */
static int pids[MAXCHLDS];         /* and this number! */
static int fistats = 0;            /* First used entry */
static int lastats = 0;            /* First unused entry */
static int statsfull = 0;          /* Flag, whether stats FIFO full */
static RETSIGTYPE (*oldhandler)(int whichsig) = 0;  /* the old handler */

#ifdef HAVE_SIGNAL
RETSIGTYPE IO_SIGCHLDHandler( int whichsig )
{
  int retcode,status;
  /* We collect information about our child processes that have
     terminated: */
  do {
    retcode = waitpid(-1, &status, WNOHANG);
    if (retcode > 0) {   /* One of our child processes terminated */
        if (WIFEXITED(status) || WIFSIGNALED(status)) {
            if (!statsfull) {
                stats[lastats] = status;
                pids[lastats++] = retcode;
                if (lastats >= maxstats) lastats = 0;
                if (lastats == fistats) statsfull = 1;
            } else 
                Pr("#E Overflow in table of terminated processes\n",0,0);
        }
    }
  } while (retcode > 0);
  
  signal(SIGCHLD, IO_SIGCHLDHandler);
}

Obj FuncIO_InstallSIGCHLDHandler( Obj self )
{
  /* Do not install ourselves twice: */
  if (oldhandler == 0) {
      oldhandler = signal(SIGCHLD, IO_SIGCHLDHandler);
      signal(SIGPIPE,SIG_IGN);
      return True;
  } else
      return False;
}

Obj FuncIO_RestoreSIGCHLDHandler( Obj self )
{
  if (oldhandler == 0)
      return False;
  else {
      signal(SIGCHLD,oldhandler);
      oldhandler = 0;
      signal(SIGPIPE,SIG_DFL);
      return True;
  }
}

Obj FuncIO_WaitPid(Obj self,Obj pid,Obj wait)
{
  Int pidc;
  int pos,newpos;
  Obj tmp;
  int retcode,status;
  int reallytried;
  if (!IS_INTOBJ(pid)) {
      SyClearErrorNo();
      return Fail;
  }
  /* First set SIGCHLD to default action to avoid clashes with access: */
  signal(SIGCHLD,SIG_DFL);
  reallytried = 0;
  do {
      pidc = INT_INTOBJ(pid);
      if (fistats == lastats && !statsfull) /* queue empty */
          pos = -1;
      else if (pidc == -1)  /* queue not empty and any entry welcome */
          pos = fistats;
      else {  /* Queue nonempty, so look for matching entry: */
          pos = fistats;
          do {
              if (pids[pos] == pidc) break;
              pos++;
              if (pos >= maxstats) pos = 0;
              if (pos == lastats) {
                  pos = -1;  /* None found */
                  break;
              }
          } while (1);
      }
      if (pos != -1) break;  /* we found something! */
      if (reallytried && wait != True) {
          /* Reinstantiate our handler: */
          signal(SIGCHLD,IO_SIGCHLDHandler);
          return False;
      }
      /* Really wait for something, blocking: */
      if (wait == True)
          retcode = waitpid(-1, &status, 0);
      else
          retcode = waitpid(-1, &status, WNOHANG);
      if (retcode > 0) {   /* One of our child processes terminated */
          if (WIFEXITED(status) || WIFSIGNALED(status)) {
              /* Append it to the queue: */
              if (!statsfull) {
                  stats[lastats] = status;
                  pids[lastats++] = retcode;
                  if (lastats >= maxstats) lastats = 0;
                  if (lastats == fistats) statsfull = 1;
              } else 
                  Pr("#E Overflow in table of terminated processes\n",0,0);
          }
      }
      reallytried = 1;  /* Do not try again. */
  } while (1);  /* Left by break */
  tmp = NEW_PREC(0);
  AssPRec(tmp,RNamName("pid"),INTOBJ_INT(pids[pos]));
  AssPRec(tmp,RNamName("status"),INTOBJ_INT(stats[pos]));
  /* Dequeue element: */
  if (pos == fistats) {  /* this is the easy case: */
      fistats++;
      if (fistats >= maxstats) fistats = 0;
  } else {  /* The more difficult case: */
      do {
          newpos = pos+1;
          if (newpos >= maxstats) newpos = 0;
          if (newpos == lastats) break;
          stats[pos] = stats[newpos];
          pids[pos] = pids[newpos];
          pos = newpos;
      } while(1);
      lastats = pos;
  }
  statsfull = 0;
  /* Reinstantiate our handler: */
  signal(SIGCHLD,IO_SIGCHLDHandler);
  return tmp;
} 
#endif 

Obj FuncIO_open(Obj self,Obj path,Obj flags,Obj mode)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) || !IS_INTOBJ(flags) ||
      !IS_INTOBJ(mode) ) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = open((char *) CHARS_STRING(path),
                 INT_INTOBJ(flags),INT_INTOBJ(mode));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return INTOBJ_INT(res);
  }
}

Obj FuncIO_creat(Obj self,Obj path,Obj mode)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) || !IS_INTOBJ(mode) ) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = creat((char *) CHARS_STRING(path),INT_INTOBJ(mode));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return INTOBJ_INT(res);
  }
}

Obj FuncIO_read(Obj self,Obj fd,Obj st,Obj offset,Obj count)
{
  Int bytes;
  Int len;

  if (!IS_INTOBJ(fd) || !IS_STRING(st) || !IS_STRING_REP(st) ||
      !IS_INTOBJ(count)) {
      SyClearErrorNo();
      return Fail;
  }

  len = INT_INTOBJ(offset)+INT_INTOBJ(count);
  if (len > GET_LEN_STRING(st)) GrowString(st,len);
  bytes = read(INT_INTOBJ(fd),CHARS_STRING(st)+INT_INTOBJ(offset),
               INT_INTOBJ(count));
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else {
      if (bytes + INT_INTOBJ(offset) > GET_LEN_STRING(st)) {
          SET_LEN_STRING(st,bytes + INT_INTOBJ(offset));
          CHARS_STRING(st)[len] = 0;
      }
      return INTOBJ_INT(bytes);
  }
}

Obj FuncIO_write(Obj self,Obj fd,Obj st,Obj offset,Obj count)
{
  Int bytes;

  if (!IS_INTOBJ(fd) || !IS_STRING(st) || !IS_STRING_REP(st) ||
      !IS_INTOBJ(offset) || !IS_INTOBJ(count)) {
      SyClearErrorNo();
      return Fail;
  }
  if (GET_LEN_STRING(st) < INT_INTOBJ(offset)+INT_INTOBJ(count)) {
      SyClearErrorNo();
      return Fail;
  }
  bytes = (Int) write(INT_INTOBJ(fd),CHARS_STRING(st)+INT_INTOBJ(offset),
                      INT_INTOBJ(count));
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else
      return INTOBJ_INT(bytes);
}

Obj FuncIO_close(Obj self,Obj fd)
{
  Int res;

  if (!IS_INTOBJ(fd)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = close(INT_INTOBJ(fd));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}

Obj FuncIO_lseek(Obj self,Obj fd,Obj offset,Obj whence)
{
  Int bytes;

  if (!IS_INTOBJ(fd) || !IS_INTOBJ(offset) || !IS_INTOBJ(whence)) {
      SyClearErrorNo();
      return Fail;
  }

  bytes = lseek(INT_INTOBJ(fd),INT_INTOBJ(offset),INT_INTOBJ(whence));
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else {
      return INTOBJ_INT(bytes);
  }
}

#ifdef HAVE_DIRENT_H 
static DIR *ourDIR = 0;
static struct dirent *ourdirent;

#ifdef HAVE_OPENDIR
Obj FuncIO_opendir(Obj self,Obj name)
{
  if (!IS_STRING(name) || !IS_STRING_REP(name)) {
      SyClearErrorNo();
      return Fail;
  } else {
      ourDIR = opendir((char *) CHARS_STRING(name));
      if (ourDIR == 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif     /* HAVE_OPENDIR */

#ifdef HAVE_READDIR
Obj FuncIO_readdir(Obj self)
{
  Obj res;
  Int olderrno;
  if (ourDIR == 0) {
      SyClearErrorNo();
      return Fail;
  }
  olderrno = errno;
  ourdirent = readdir(ourDIR);
  if (ourdirent == 0) {
      /* This is a bit of a hack, but how should this be done? */
      if (errno == EBADF && olderrno != EBADF) {
          SySetErrorNo();
          return Fail;
      } else {
          SyClearErrorNo();
          return False;
      }
  }
  C_NEW_STRING(res,strlen(ourdirent->d_name),ourdirent->d_name);
  return res;
}
#endif     /* HAVE_READDIR */

#ifdef HAVE_CLOSEDIR
Obj FuncIO_closedir(Obj self)
{
  Int res;

  if (ourDIR == 0) {
      SyClearErrorNo();
      return Fail;
  }
  res = closedir(ourDIR);
  if (res < 0) {
      SySetErrorNo();
      return Fail;
  } else 
      return True;
}
#endif     /* HAVE_CLOSEDIR */

#ifdef HAVE_REWINDDIR
Obj FuncIO_rewinddir(Obj self)
{
  if (ourDIR == 0) {
      SyClearErrorNo();
      return Fail;
  }
  rewinddir(ourDIR);
  return True;
}
#endif     /* HAVE_REWINDDIR */

#ifdef HAVE_TELLDIR
Obj FuncIO_telldir(Obj self)
{
  Int o;
  if (ourDIR == 0) {
      SyClearErrorNo();
      return Fail;
  }
  o = telldir(ourDIR);
  if (o < 0) {
      SySetErrorNo();
      return Fail;
  } else
      return INTOBJ_INT(o);
}
#endif     /* HAVE_TELLDIR */

#ifdef HAVE_SEEKDIR
Obj FuncIO_seekdir(Obj self,Obj offset)
{
  if (!IS_INTOBJ(offset)) {
      SyClearErrorNo();
      return Fail;
  }
  if (ourDIR == 0) {
      SyClearErrorNo();
      return Fail;
  }
  seekdir(ourDIR,INT_INTOBJ(offset));
  return True;
}
#endif     /* HAVE_SEEKDIR */

#endif     /* HAVE_DIRENT_H */

#ifdef HAVE_UNLINK
Obj FuncIO_unlink(Obj self,Obj path)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = unlink((char *) CHARS_STRING(path));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_LINK
Obj FuncIO_link(Obj self,Obj oldpath,Obj newpath)
{
  Int res;
  if (!IS_STRING(oldpath) || !IS_STRING_REP(oldpath) ||
      !IS_STRING(newpath) || !IS_STRING_REP(newpath)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = link((char *) CHARS_STRING(oldpath),(char *) CHARS_STRING(newpath));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_RENAME
Obj FuncIO_rename(Obj self,Obj oldpath,Obj newpath)
{
  Int res;
  if (!IS_STRING(oldpath) || !IS_STRING_REP(oldpath) ||
      !IS_STRING(newpath) || !IS_STRING_REP(newpath)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = rename((char *) CHARS_STRING(oldpath),
                   (char *) CHARS_STRING(newpath));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_SYMLINK
Obj FuncIO_symlink(Obj self,Obj oldpath,Obj newpath)
{
  Int res;
  if (!IS_STRING(oldpath) || !IS_STRING_REP(oldpath) ||
      !IS_STRING(newpath) || !IS_STRING_REP(newpath)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = symlink((char *) CHARS_STRING(oldpath),
                    (char *) CHARS_STRING(newpath));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_READLINK
Obj FuncIO_readlink(Obj self,Obj path,Obj buf,Obj bufsize)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) ||
      !IS_STRING(buf) || !IS_STRING_REP(buf) || !IS_INTOBJ(bufsize)) {
      SyClearErrorNo();
      return Fail;
  } else {
      GrowString(buf,INT_INTOBJ(bufsize));
      res = readlink((char *) CHARS_STRING(path),
                     (char *) CHARS_STRING(buf),INT_INTOBJ(bufsize));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else {
          SET_LEN_STRING(buf,res);
          CHARS_STRING(buf)[res] = 0;
          return INTOBJ_INT(res);
      }
  }
}
#endif

Obj FuncIO_chdir(Obj self,Obj pathname)
{
  Int res;
  if (!IS_STRING(pathname) || !IS_STRING_REP(pathname)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = chdir((char *) CHARS_STRING(pathname));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}

#ifdef HAVE_MKDIR
Obj FuncIO_mkdir(Obj self,Obj pathname,Obj mode)
{
  Int res;
  if (!IS_STRING(pathname) || !IS_STRING_REP(pathname) || !IS_INTOBJ(mode)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = mkdir((char *) CHARS_STRING(pathname),INT_INTOBJ(mode));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_RMDIR
Obj FuncIO_rmdir(Obj self,Obj path)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = rmdir((char *) CHARS_STRING(path));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifndef ADDR_INT
#define ADDR_INT(op)    ((TypDigit*)ADDR_OBJ(op))
#endif

#ifndef USE_GMP
static Obj MyObjInt_Int(Int i)
{
    Obj n;
    Int bound = 1L << NR_SMALL_INT_BITS;
    if (i >= bound) {
        /* We have to make a big integer */
        n = NewBag(T_INTPOS,4*sizeof(TypDigit));
        ADDR_INT(n)[0] = (TypDigit) (i & ((Int) INTBASE - 1L));
        ADDR_INT(n)[1] = (TypDigit) (i >> NR_DIGIT_BITS);
        ADDR_INT(n)[2] = 0;
        ADDR_INT(n)[3] = 0;
        return n;
    } else if (-i > bound) {
        n = NewBag(T_INTNEG,4*sizeof(TypDigit));
        ADDR_INT(n)[0] = (TypDigit) ((-i) & ((Int) INTBASE - 1L));
        ADDR_INT(n)[1] = (TypDigit) ((-i) >> NR_DIGIT_BITS);
        ADDR_INT(n)[2] = 0;
        ADDR_INT(n)[3] = 0;
        return n;
    } else {
        return INTOBJ_INT(i);
    }
}
#else
#define MyObjInt_Int(i) ObjInt_Int(i)
#endif

#ifdef HAVE_STAT
static struct stat ourstatbuf;
Obj FuncIO_stat(Obj self,Obj filename)
{
  Int res;
  Obj rec;
  if (!IS_STRING(filename) || !IS_STRING_REP(filename)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = stat((char *) CHARS_STRING(filename),&ourstatbuf);
      if (res < 0) {
        SySetErrorNo();
        return Fail;
      }
      rec = NEW_PREC(0);
      AssPRec(rec,RNamName("dev"),MyObjInt_Int((Int) ourstatbuf.st_dev));
      AssPRec(rec,RNamName("ino"),MyObjInt_Int((Int) ourstatbuf.st_ino));
      AssPRec(rec,RNamName("mode"),MyObjInt_Int((Int) ourstatbuf.st_mode));
      AssPRec(rec,RNamName("nlink"),MyObjInt_Int((Int) ourstatbuf.st_nlink));
      AssPRec(rec,RNamName("uid"),MyObjInt_Int((Int) ourstatbuf.st_uid));
      AssPRec(rec,RNamName("gid"),MyObjInt_Int((Int) ourstatbuf.st_gid));
      AssPRec(rec,RNamName("rdev"),MyObjInt_Int((Int) ourstatbuf.st_rdev));
      AssPRec(rec,RNamName("size"),MyObjInt_Int((Int) ourstatbuf.st_size));
      AssPRec(rec,RNamName("blksize"),MyObjInt_Int((Int)ourstatbuf.st_blksize));
      AssPRec(rec,RNamName("blocks"),MyObjInt_Int((Int) ourstatbuf.st_blocks));
      AssPRec(rec,RNamName("atime"),MyObjInt_Int((Int) ourstatbuf.st_atime));
      AssPRec(rec,RNamName("mtime"),MyObjInt_Int((Int) ourstatbuf.st_mtime));
      AssPRec(rec,RNamName("ctime"),MyObjInt_Int((Int) ourstatbuf.st_ctime));
      return rec;
  }
}
#endif

#ifdef HAVE_FSTAT
static struct stat ourfstatbuf;
Obj FuncIO_fstat(Obj self,Obj fd)
{
  Int res;
  Obj rec;
  if (!IS_INTOBJ(fd)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = fstat(INT_INTOBJ(fd),&ourfstatbuf);
      if (res < 0) {
        SySetErrorNo();
        return Fail;
      }
      rec = NEW_PREC(0);
      AssPRec(rec,RNamName("dev"),MyObjInt_Int((Int) ourfstatbuf.st_dev));
      AssPRec(rec,RNamName("ino"),MyObjInt_Int((Int) ourfstatbuf.st_ino));
      AssPRec(rec,RNamName("mode"),MyObjInt_Int((Int) ourfstatbuf.st_mode));
      AssPRec(rec,RNamName("nlink"),MyObjInt_Int((Int) ourfstatbuf.st_nlink));
      AssPRec(rec,RNamName("uid"),MyObjInt_Int((Int) ourfstatbuf.st_uid));
      AssPRec(rec,RNamName("gid"),MyObjInt_Int((Int) ourfstatbuf.st_gid));
      AssPRec(rec,RNamName("rdev"),MyObjInt_Int((Int) ourfstatbuf.st_rdev));
      AssPRec(rec,RNamName("size"),MyObjInt_Int((Int) ourfstatbuf.st_size));
      AssPRec(rec,RNamName("blksize"),MyObjInt_Int((Int)ourfstatbuf.st_blksize));
      AssPRec(rec,RNamName("blocks"),MyObjInt_Int((Int) ourfstatbuf.st_blocks));
      AssPRec(rec,RNamName("atime"),MyObjInt_Int((Int) ourfstatbuf.st_atime));
      AssPRec(rec,RNamName("mtime"),MyObjInt_Int((Int) ourfstatbuf.st_mtime));
      AssPRec(rec,RNamName("ctime"),MyObjInt_Int((Int) ourfstatbuf.st_ctime));
      return rec;
  }
}
#endif

#ifdef HAVE_LSTAT
static struct stat ourlstatbuf;
Obj FuncIO_lstat(Obj self,Obj filename)
{
  Int res;
  Obj rec;
  if (!IS_STRING(filename) || !IS_STRING_REP(filename)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = lstat((char *) CHARS_STRING(filename),&ourlstatbuf);
      if (res < 0) {
        SySetErrorNo();
        return Fail;
      }
      rec = NEW_PREC(0);
      AssPRec(rec,RNamName("dev"),MyObjInt_Int((Int) ourlstatbuf.st_dev));
      AssPRec(rec,RNamName("ino"),MyObjInt_Int((Int) ourlstatbuf.st_ino));
      AssPRec(rec,RNamName("mode"),MyObjInt_Int((Int) ourlstatbuf.st_mode));
      AssPRec(rec,RNamName("nlink"),MyObjInt_Int((Int) ourlstatbuf.st_nlink));
      AssPRec(rec,RNamName("uid"),MyObjInt_Int((Int) ourlstatbuf.st_uid));
      AssPRec(rec,RNamName("gid"),MyObjInt_Int((Int) ourlstatbuf.st_gid));
      AssPRec(rec,RNamName("rdev"),MyObjInt_Int((Int) ourlstatbuf.st_rdev));
      AssPRec(rec,RNamName("size"),MyObjInt_Int((Int) ourlstatbuf.st_size));
      AssPRec(rec,RNamName("blksize"),MyObjInt_Int((Int)ourlstatbuf.st_blksize));
      AssPRec(rec,RNamName("blocks"),MyObjInt_Int((Int) ourlstatbuf.st_blocks));
      AssPRec(rec,RNamName("atime"),MyObjInt_Int((Int) ourlstatbuf.st_atime));
      AssPRec(rec,RNamName("mtime"),MyObjInt_Int((Int) ourlstatbuf.st_mtime));
      AssPRec(rec,RNamName("ctime"),MyObjInt_Int((Int) ourlstatbuf.st_ctime));
      return rec;
  }
}
#endif

#ifdef HAVE_CHMOD
Obj FuncIO_chmod(Obj self,Obj pathname,Obj mode)
{
  Int res;
  if (!IS_STRING(pathname) || !IS_STRING_REP(pathname) || !IS_INTOBJ(mode)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = chmod((char *) CHARS_STRING(pathname),INT_INTOBJ(mode));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_FCHMOD
Obj FuncIO_fchmod(Obj self,Obj fd,Obj mode)
{
  Int res;
  if (!IS_INTOBJ(fd) || !IS_INTOBJ(mode)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = fchmod(INT_INTOBJ(fd),INT_INTOBJ(mode));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else
          return True;
  }
}
#endif

#ifdef HAVE_CHOWN
Obj FuncIO_chown(Obj self,Obj path,Obj owner,Obj group)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) ||
      !IS_INTOBJ(owner) || !IS_INTOBJ(group)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = chown((char *) CHARS_STRING(path),
                  INT_INTOBJ(owner),INT_INTOBJ(group));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_FCHOWN
Obj FuncIO_fchown(Obj self,Obj fd,Obj owner,Obj group)
{
  Int res;
  if (!IS_INTOBJ(fd) || !IS_INTOBJ(owner) || !IS_INTOBJ(group)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = fchown(INT_INTOBJ(fd),INT_INTOBJ(owner),INT_INTOBJ(group));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_LCHOWN
Obj FuncIO_lchown(Obj self,Obj path,Obj owner,Obj group)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) ||
      !IS_INTOBJ(owner) || !IS_INTOBJ(group)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = lchown((char *) CHARS_STRING(path),
                   INT_INTOBJ(owner),INT_INTOBJ(group));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_MKNOD
Obj FuncIO_mknod(Obj self,Obj path,Obj mode,Obj dev)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) ||
      !IS_INTOBJ(mode) || !IS_INTOBJ(dev)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = mknod((char *) CHARS_STRING(path),INT_INTOBJ(mode),INT_INTOBJ(dev));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_MKFIFO
Obj FuncIO_mkfifo(Obj self,Obj path,Obj mode)
{
  Int res;
  if (!IS_STRING(path) || !IS_STRING_REP(path) || !IS_INTOBJ(mode)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = mkfifo((char *) CHARS_STRING(path),INT_INTOBJ(mode));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_DUP
Obj FuncIO_dup(Obj self,Obj oldfd)
{
  Int res;
  if (!IS_INTOBJ(oldfd)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = dup(INT_INTOBJ(oldfd));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return INTOBJ_INT(res);
  }
}
#endif

#ifdef HAVE_DUP2
Obj FuncIO_dup2(Obj self,Obj oldfd,Obj newfd)
{
  Int res;
  if (!IS_INTOBJ(oldfd) || !IS_INTOBJ(newfd)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = dup2(INT_INTOBJ(oldfd),INT_INTOBJ(newfd));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_SOCKET
Obj FuncIO_socket(Obj self,Obj domain,Obj type,Obj protocol)
{
  Int res;
#ifdef HAVE_GETPROTOBYNAME
  struct protoent *pe;
#endif
  Int proto;
  if (!IS_INTOBJ(domain) || !IS_INTOBJ(type) || 
      !(IS_INTOBJ(protocol) 
#ifdef HAVE_GETPROTOBYNAME
        || (IS_STRING(protocol) && IS_STRING_REP(protocol))
#endif
       )) {
      SyClearErrorNo();
      return Fail;
  } else {
#ifdef HAVE_GETPROTOBYNAME
      if (IS_STRING(protocol)) { /* we have to look up the protocol */
           pe = getprotobyname((char *) CHARS_STRING(protocol));
           if (pe == NULL) {
               SySetErrorNo();
               return Fail;
           }
           proto = pe->p_proto;
      } else
#endif
      proto = INT_INTOBJ(protocol);
      res = socket(INT_INTOBJ(domain),INT_INTOBJ(type),proto);
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return INTOBJ_INT(res);
  }
}
#endif

#ifdef HAVE_BIND
Obj FuncIO_bind(Obj self,Obj fd,Obj my_addr)
{
  Int res;
  Int len;
  if (!IS_INTOBJ(fd) || !IS_STRING(my_addr) || !IS_STRING_REP(my_addr)) {
      SyClearErrorNo();
      return Fail;
  } else {
      len = GET_LEN_STRING(my_addr);
      res = bind(INT_INTOBJ(fd),(struct sockaddr *)CHARS_STRING(my_addr),len);
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_CONNECT
Obj FuncIO_connect(Obj self,Obj fd,Obj serv_addr)
{
  Int res;
  Int len;
  if (!IS_INTOBJ(fd) || !IS_STRING(serv_addr) || !IS_STRING_REP(serv_addr)) {
      SyClearErrorNo();
      return Fail;
  } else {
      len = GET_LEN_STRING(serv_addr);
      res = connect(INT_INTOBJ(fd),
                    (struct sockaddr *)(CHARS_STRING(serv_addr)),len);
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_SOCKET
Obj FuncIO_make_sockaddr_in(Obj self,Obj ip,Obj port)
{
  struct sockaddr_in sa;
  Obj res;
  if (!IS_INTOBJ(port) || !IS_STRING(ip) || !IS_STRING_REP(ip) ||
      GET_LEN_STRING(ip) != 4) {
      SyClearErrorNo();
      return Fail;
  } else {
      memset(&sa,0,sizeof(sa));
      sa.sin_family = AF_INET;
      sa.sin_port = htons(INT_INTOBJ(port));
      memcpy(&(sa.sin_addr.s_addr),CHARS_STRING(ip),4);
      res = NEW_STRING(sizeof(sa));
      memcpy(CHARS_STRING(res),&sa,sizeof(sa));
      return res;
  }
}
#endif

#ifdef HAVE_GETHOSTBYNAME
Obj FuncIO_gethostbyname(Obj self,Obj name)
{
  struct hostent *he;
  Obj res;
  Obj tmp;
  Obj tmp2;
  char **p;
  Int i;
  Int len;
  if (!IS_STRING(name) || !IS_STRING_REP(name)) {
      SyClearErrorNo();
      return Fail;
  } else {
      he = gethostbyname((char *) CHARS_STRING(name));
      if (he == NULL) {
          SySetErrorNo();
          return Fail;
      }
      res = NEW_PREC(0);
      C_NEW_STRING(tmp,strlen(he->h_name),he->h_name);
      AssPRec(res,RNamName("name"),tmp);
      for (len = 0,p = he->h_aliases; *p != NULL ; len++, p++) ;
      tmp2 = NEW_PLIST(T_PLIST_DENSE,len);
      SET_LEN_PLIST(tmp2,len);
      for (i = 1,p = he->h_aliases; i <= len; i++,p++) {
          C_NEW_STRING(tmp,strlen(*p),*p);
          SET_ELM_PLIST(tmp2,i,tmp);
          CHANGED_BAG(tmp2);
      }
      AssPRec(res,RNamName("aliases"),tmp2);
      AssPRec(res,RNamName("addrtype"),INTOBJ_INT(he->h_addrtype));
      AssPRec(res,RNamName("length"),INTOBJ_INT(he->h_length));
      for (len = 0,p = he->h_addr_list; *p != NULL ; len++, p++) ;
      tmp2 = NEW_PLIST(T_PLIST_DENSE,len);
      SET_LEN_PLIST(tmp2,len);
      for (i = 1,p = he->h_addr_list; i <= len; i++,p++) {
          C_NEW_STRING(tmp,he->h_length,*p);
          SET_ELM_PLIST(tmp2,i,tmp);
          CHANGED_BAG(tmp2);
      }
      AssPRec(res,RNamName("addr"),tmp2);
      return res;
  }
}
#endif

#ifdef HAVE_LISTEN
Obj FuncIO_listen(Obj self,Obj s,Obj backlog)
{
  Int res;
  if (!IS_INTOBJ(s) || !IS_INTOBJ(backlog)) {
      SyClearErrorNo();
      return Fail;
  } else {
      res = listen(INT_INTOBJ(s),INT_INTOBJ(backlog));
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return True;
  }
}
#endif

#ifdef HAVE_ACCEPT
Obj FuncIO_accept(Obj self,Obj fd,Obj addr)
{
  Int res;
  socklen_t len;
  if (!IS_INTOBJ(fd) || !IS_STRING(addr) || !IS_STRING_REP(addr)) {
      SyClearErrorNo();
      return Fail;
  } else {
      len = GET_LEN_STRING(addr);
      res = accept(INT_INTOBJ(fd),
                   (struct sockaddr *)(CHARS_STRING(addr)),&len);
      if (res < 0) {
          SySetErrorNo();
          return Fail;
      } else 
          return INTOBJ_INT(res);
  }
}
#endif

#ifdef HAVE_RECV
Obj FuncIO_recv(Obj self,Obj fd,Obj st,Obj offset,Obj count,Obj flags)
{
  Int bytes;
  Int len;

  if (!IS_INTOBJ(fd) || !IS_STRING(st) || !IS_STRING_REP(st) ||
      !IS_INTOBJ(count) || !IS_INTOBJ(flags)) {
      SyClearErrorNo();
      return Fail;
  }

  len = INT_INTOBJ(offset)+INT_INTOBJ(count);
  if (len > GET_LEN_STRING(st)) GrowString(st,len);
  bytes = recv(INT_INTOBJ(fd),CHARS_STRING(st)+INT_INTOBJ(offset),
               INT_INTOBJ(count),INT_INTOBJ(flags));
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else {
      if (bytes + INT_INTOBJ(offset) > GET_LEN_STRING(st)) {
          SET_LEN_STRING(st,bytes + INT_INTOBJ(offset));
          CHARS_STRING(st)[len] = 0;
      }
      return INTOBJ_INT(bytes);
  }
}
#endif

#ifdef HAVE_RECVFROM
Obj FuncIO_recvfrom(Obj self,Obj fd,Obj st,Obj offset,Obj count,Obj flags,
                    Obj from)
{
  Int bytes;
  Int len;
  socklen_t fromlen;

  if (!IS_INTOBJ(fd) || !IS_STRING(st) || !IS_STRING_REP(st) ||
      !IS_INTOBJ(count) || !IS_INTOBJ(flags) || !IS_STRING(from) ||
      !IS_STRING_REP(from)) {
      SyClearErrorNo();
      return Fail;
  }

  len = INT_INTOBJ(offset)+INT_INTOBJ(count);
  if (len > GET_LEN_STRING(st)) GrowString(st,len);
  fromlen = GET_LEN_STRING(from);
  bytes = recvfrom(INT_INTOBJ(fd),(char *) CHARS_STRING(st)+INT_INTOBJ(offset),
                   INT_INTOBJ(count),INT_INTOBJ(flags),
                   (struct sockaddr *)CHARS_STRING(from),&fromlen);
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else {
      if (bytes + INT_INTOBJ(offset) > GET_LEN_STRING(st)) {
          SET_LEN_STRING(st,bytes + INT_INTOBJ(offset));
          CHARS_STRING(st)[len] = 0;
      }
      return INTOBJ_INT(bytes);
  }
}
#endif

#ifdef HAVE_SEND
Obj FuncIO_send(Obj self,Obj fd,Obj st,Obj offset,Obj count,Obj flags)
{
  Int bytes;

  if (!IS_INTOBJ(fd) || !IS_STRING(st) || !IS_STRING_REP(st) ||
      !IS_INTOBJ(offset) || !IS_INTOBJ(count) || !IS_INTOBJ(flags)) {
      SyClearErrorNo();
      return Fail;
  }
  if (GET_LEN_STRING(st) < INT_INTOBJ(offset)+INT_INTOBJ(count)) {
      SyClearErrorNo();
      return Fail;
  }
  bytes = (Int) send(INT_INTOBJ(fd),
                     (char *) CHARS_STRING(st)+INT_INTOBJ(offset),
                     INT_INTOBJ(count),INT_INTOBJ(flags));
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else
      return INTOBJ_INT(bytes);
}
#endif

#ifdef HAVE_SENDTO
Obj FuncIO_sendto(Obj self,Obj fd,Obj st,Obj offset,Obj count,Obj flags,
                  Obj to)
{
  Int bytes;
  socklen_t fromlen;

  if (!IS_INTOBJ(fd) || !IS_STRING(st) || !IS_STRING_REP(st) ||
      !IS_INTOBJ(offset) || !IS_INTOBJ(count) || !IS_INTOBJ(flags) ||
      !IS_STRING(to) || !IS_STRING_REP(to)) {
      SyClearErrorNo();
      return Fail;
  }
  if (GET_LEN_STRING(st) < INT_INTOBJ(offset)+INT_INTOBJ(count)) {
      SyClearErrorNo();
      return Fail;
  }
  fromlen = GET_LEN_STRING(to);
  bytes = (Int) sendto(INT_INTOBJ(fd),
                       (char *) CHARS_STRING(st)+INT_INTOBJ(offset),
                       INT_INTOBJ(count),INT_INTOBJ(flags),
                       (struct sockaddr *)CHARS_STRING(to),fromlen);
  if (bytes < 0) {
      SySetErrorNo();
      return Fail;
  } else
      return INTOBJ_INT(bytes);
}
#endif

#ifdef HAVE_GETSOCKOPT
Obj FuncIO_getsockopt(Obj self,Obj fd,Obj level,Obj optname,
                      Obj optval,Obj optlen)
{
  Int res;
  socklen_t olen;

  if (!IS_INTOBJ(fd) || !IS_INTOBJ(level) || !IS_INTOBJ(optname) ||
      !IS_INTOBJ(optlen) || !IS_STRING(optval) || !IS_STRING_REP(optval)) {
      SyClearErrorNo();
      return Fail;
  }
  olen = INT_INTOBJ(optlen);
  if (olen > GET_LEN_STRING(optval)) GrowString(optval,olen);
  res = (Int) getsockopt(INT_INTOBJ(fd),INT_INTOBJ(level),INT_INTOBJ(optname),
                         (char *) CHARS_STRING(optval),&olen);
  if (res < 0) {
      SySetErrorNo();
      return Fail;
  } else {
      SET_LEN_STRING(optval,olen);
      return True;
  }
}
#endif

#ifdef HAVE_SETSOCKOPT
Obj FuncIO_setsockopt(Obj self,Obj fd,Obj level,Obj optname, Obj optval)
{
  Int res;
  socklen_t olen;

  if (!IS_INTOBJ(fd) || !IS_INTOBJ(level) || !IS_INTOBJ(optname) ||
      !IS_STRING(optval) || !IS_STRING_REP(optval)) {
      SyClearErrorNo();
      return Fail;
  }
  olen = GET_LEN_STRING(optval);
  res = (Int) setsockopt(INT_INTOBJ(fd),INT_INTOBJ(level),INT_INTOBJ(optname),
                         (char *) CHARS_STRING(optval),olen);
  if (res < 0) {
      SySetErrorNo();
      return Fail;
  } else 
      return True;
}
#endif

#ifdef HAVE_SELECT
Obj FuncIO_select(Obj self, Obj inlist, Obj outlist, Obj exclist, 
                  Obj timeoutsec, Obj timeoutusec)
{
  fd_set infds,outfds,excfds;
  struct timeval tv;
  int n,maxfd;
  Int i,j;
  Obj o;

  while (inlist == (Obj) 0 || !(IS_PLIST(inlist)))
    inlist = ErrorReturnObj(
           "<inlist> must be a list of small integers (not a %s)",
           (Int)TNAM_OBJ(inlist),0L,
           "you can replace <inlist> via 'return <inlist>;'" );
  while (outlist == (Obj) 0 || !(IS_PLIST(outlist)))
    outlist = ErrorReturnObj(
           "<outlist> must be a list of small integers (not a %s)",
           (Int)TNAM_OBJ(outlist),0L,
           "you can replace <outlist> via 'return <outlist>;'" );
  while (exclist == (Obj) 0 || !(IS_PLIST(exclist)))
    exclist = ErrorReturnObj(
           "<exclist> must be a list of small integers (not a %s)",
           (Int)TNAM_OBJ(exclist),0L,
           "you can replace <exclist> via 'return <exclist>;'" );

  FD_ZERO(&infds);
  FD_ZERO(&outfds);
  FD_ZERO(&excfds);
  maxfd = 0;
  /* Handle input file descriptors: */
  for (i = 1;i <= LEN_PLIST(inlist);i++) {
    o = ELM_PLIST(inlist,i);
    if (o != (Obj) 0 && IS_INTOBJ(o)) {
      j = INT_INTOBJ(o);  /* a UNIX file descriptor */
      FD_SET(j,&infds);
      if (j > maxfd) maxfd = j;
    }
  }
  /* Handle output file descriptors: */
  for (i = 1;i <= LEN_PLIST(outlist);i++) {
    o = ELM_PLIST(outlist,i);
    if (o != (Obj) 0 && IS_INTOBJ(o)) {
      j = INT_INTOBJ(o);  /* a UNIX file descriptor */
      FD_SET(j,&outfds);
      if (j > maxfd) maxfd = j;
    }
  }
  /* Handle exception file descriptors: */
  for (i = 1;i <= LEN_PLIST(exclist);i++) {
    o = ELM_PLIST(exclist,i);
    if (o != (Obj) 0 && IS_INTOBJ(o)) {
      j = INT_INTOBJ(o);  /* a UNIX file descriptor */
      FD_SET(j,&excfds);
      if (j > maxfd) maxfd = j;
    }
  }
  /* Handle the timeout: */
  if (timeoutsec != (Obj) 0 && IS_INTOBJ(timeoutsec) &&
      timeoutusec != (Obj) 0 && IS_INTOBJ(timeoutusec)) {
    tv.tv_sec = INT_INTOBJ(timeoutsec);
    tv.tv_usec = INT_INTOBJ(timeoutusec);
    n = select(maxfd+1,&infds,&outfds,&excfds,&tv);
  } else {
    n = select(maxfd+1,&infds,&outfds,&excfds,NULL);
  }
    
  if (n >= 0) {
    /* Now run through the lists and call functions if ready: */

    for (i = 1;i <= LEN_PLIST(inlist);i++) {
      o = ELM_PLIST(inlist,i);
      if (o != (Obj) 0 && IS_INTOBJ(o)) {
        j = INT_INTOBJ(o);  /* a UNIX file descriptor */
        if (!(FD_ISSET(j,&infds))) {
          SET_ELM_PLIST(inlist,i,Fail);
          CHANGED_BAG(inlist);
        }
      }
    }
    /* Handle output file descriptors: */
    for (i = 1;i <= LEN_PLIST(outlist);i++) {
      o = ELM_PLIST(outlist,i);
      if (o != (Obj) 0 && IS_INTOBJ(o)) {
        j = INT_INTOBJ(o);  /* a UNIX file descriptor */
        if (!(FD_ISSET(j,&outfds))) {
          SET_ELM_PLIST(outlist,i,Fail);
          CHANGED_BAG(outlist);
        }
      }
    }
    /* Handle exception file descriptors: */
    for (i = 1;i <= LEN_PLIST(exclist);i++) {
      o = ELM_PLIST(exclist,i);
      if (o != (Obj) 0 && IS_INTOBJ(o)) {
        j = INT_INTOBJ(o);  /* a UNIX file descriptor */
        if (!(FD_ISSET(j,&excfds))) {
          SET_ELM_PLIST(exclist,i,Fail);
          CHANGED_BAG(exclist);
        }
      }
    }
    return INTOBJ_INT(n);
  } else {
    SySetErrorNo();
    return Fail;
  }
}
#endif

#ifdef HAVE_FORK
Obj FuncIO_fork(Obj self)
{
  int res;
  res = fork();
  if (res == -1) {
      SySetErrorNo();
      return Fail;
  }
  if (res != 0) {   /* we are the parent */
      return INTOBJ_INT(res);
  } else {
      /* we are the child */
      return INTOBJ_INT(0);
  }
}
#endif

static char *argv[1024];   /* Up to 1024 arguments */
static char *envp[1024];   /* Up to 1024 environment entries */

Obj FuncIO_execv(Obj self,Obj path,Obj Argv)
{
    int argc;
    int i;
    Obj tmp;

    if (!IS_STRING(path) || !IS_STRING_REP(path) || !IS_PLIST(Argv)) {
        SyClearErrorNo();
        return Fail;
    }
    argv[0] = (char *) CHARS_STRING(path);
    argc = LEN_PLIST(Argv);
    if (argc > 1022) {
        Pr("#E Ignored arguments after the 1022th.\n",0,0);
        argc = 1022;
    }
    for (i = 1;i <= argc;i++) {
        tmp = ELM_PLIST(Argv,i);
        if (!IS_STRING(tmp) || !IS_STRING_REP(tmp)) {
            SyClearErrorNo();
            return Fail;
        }
        argv[i] = (char *) CHARS_STRING(tmp);
    }
    argv[i] = 0;
    i = execv((char *) CHARS_STRING(path),argv);
    if (i == -1) {
        SySetErrorNo();
        return INTOBJ_INT(i);
    }
    /* This will never happen: */
    return Fail;
}

extern char **environ;

Obj FuncIO_execvp(Obj self,Obj file,Obj Argv)
{
    int argc;
    int i;
    Obj tmp;

    if (!IS_STRING(file) || !IS_STRING_REP(file) || !IS_PLIST(Argv)) {
        SyClearErrorNo();
        return Fail;
    }
    argv[0] = (char *) CHARS_STRING(file);
    argc = LEN_PLIST(Argv);
    if (argc > 1022) {
        Pr("#E Ignored arguments after the 1022th.\n",0,0);
        argc = 1022;
    }
    for (i = 1;i <= argc;i++) {
        tmp = ELM_PLIST(Argv,i);
        if (!IS_STRING(tmp) || !IS_STRING_REP(tmp)) {
            SyClearErrorNo();
            return Fail;
        }
        argv[i] = (char *) CHARS_STRING(tmp);
    }
    argv[i] = 0;
    i = execvp((char *) CHARS_STRING(file),argv);
    if (i == -1) {
        SySetErrorNo();
        return Fail;
    }
    /* This will never happen: */
    return Fail;
}

Obj FuncIO_execve(Obj self,Obj path,Obj Argv,Obj Envp)
{
    int argc;
    int i;
    Obj tmp;

    if (!IS_STRING(path) || !IS_STRING_REP(path) || !IS_PLIST(Argv) ||
        !IS_PLIST(Envp) ) {
        SyClearErrorNo();
        return Fail;
    }
    argv[0] = (char *) CHARS_STRING(path);
    argc = LEN_PLIST(Argv);
    if (argc > 1022) {
        Pr("#E Ignored arguments after the 1022th.\n",0,0);
        argc = 1022;
    }
    for (i = 1;i <= argc;i++) {
        tmp = ELM_PLIST(Argv,i);
        if (!IS_STRING(tmp) || !IS_STRING_REP(tmp)) {
            SyClearErrorNo();
            return Fail;
        }
        argv[i] = (char *) CHARS_STRING(tmp);
    }
    argv[i] = 0;
    argc = LEN_PLIST(Envp);
    if (argc > 1022) {
        Pr("#E Ignored environment strings after the 1022th.\n",0,0);
        argc = 1022;
    }
    for (i = 1;i <= argc;i++) {
        tmp = ELM_PLIST(Envp,i);
        if (!IS_STRING(tmp) || !IS_STRING_REP(tmp)) {
            SyClearErrorNo();
            return Fail;
        }
        envp[i-1] = (char *) CHARS_STRING(tmp);
    }
    envp[i-1] = 0;
    i = execve((char *) CHARS_STRING(path),argv,envp);
    if (i == -1) {
        SySetErrorNo();
        return Fail;
    }
    /* This will never happen: */
    return Fail;
}

Obj FuncIO_environ(Obj self)
{
    Int i,len;
    char **p;
    Obj tmp,tmp2;

    /* First count the entries: */
    for (len = 0,p = environ;*p;p++,len++) ;

    /* Now make a list: */
    tmp = NEW_PLIST(T_PLIST_DENSE,len);
    tmp2 = tmp;   /* Just to please the compiler */
    SET_LEN_PLIST(tmp2,len);
    for (i = 1, p = environ;i <= len;i++,p++) {
        C_NEW_STRING(tmp2,strlen(*p),*p);
        SET_ELM_PLIST(tmp,i,tmp2);
        CHANGED_BAG(tmp);
    }
    return tmp;
}

Obj FuncIO_pipe(Obj self)
{
    Obj tmp;
    int fds[2];
    int res;

    res = pipe(fds);
    if (res == -1) {
        SySetErrorNo();
        return Fail;
    }
    tmp = NEW_PREC(0);
    AssPRec(tmp,RNamName("toread"),INTOBJ_INT(fds[0]));
    AssPRec(tmp,RNamName("towrite"),INTOBJ_INT(fds[1]));
    return tmp;
}

Obj FuncIO_exit(Obj self,Obj status)
{
    if (!IS_INTOBJ(status)) {
        SyClearErrorNo();
        return Fail;
    }
    exit(INT_INTOBJ(status));
    /* This never happens: */
    return True;
}

Obj FuncIO_MasterPointerNumber(Obj self, Obj o)
{
    if ((void **) o >= (void **) MptrBags && (void **) o < (void **) OldBags) {
        return INTOBJ_INT( ((void **) o - (void **) MptrBags) + 1 );
    } else {
        return INTOBJ_INT( 0 );
    }
}

#ifdef HAVE_FCNTL_H
Obj FuncIO_fcntl(Obj self, Obj fd, Obj cmd, Obj arg)
{
    Int ret;
    if (!IS_INTOBJ(fd) || !IS_INTOBJ(cmd) || !IS_INTOBJ(arg)) {
        SyClearErrorNo();
        return Fail;
    }
    ret = fcntl(INT_INTOBJ(fd),INT_INTOBJ(cmd),INT_INTOBJ(arg));
    if (ret == -1) {
        SySetErrorNo();
        return Fail;
    } else
        return INTOBJ_INT(ret);
}
#endif

#ifdef HAVE_GETPID
Obj FuncIO_getpid(Obj self)
{
    return INTOBJ_INT(getpid());
}
#endif

#ifdef HAVE_GETPPID
Obj FuncIO_getppid(Obj self)
{
    return INTOBJ_INT(getppid());
}
#endif

#ifdef HAVE_KILL
Obj FuncIO_kill(Obj self, Obj pid, Obj sig)
{
    Int ret;
    if (!IS_INTOBJ(pid) || !IS_INTOBJ(sig)) {
        SyClearErrorNo();
        return Fail;
    }
    ret = kill((pid_t) INT_INTOBJ(pid),(int) INT_INTOBJ(sig));
    if (ret == -1) {
        SySetErrorNo();
        return Fail;
    } else
        return True;
}
#endif
    
#ifdef HAVE_GETTIMEOFDAY
Obj FuncIO_gettimeofday( Obj self )
{
   Obj tmp;
   struct timeval tv;
   gettimeofday(&tv, NULL);
   tmp = NEW_PREC(0);
   AssPRec(tmp, RNamName("tv_sec"), MyObjInt_Int( tv.tv_sec ));
   AssPRec(tmp, RNamName("tv_usec"), MyObjInt_Int( tv.tv_usec ));
   return tmp;
}
#endif

#ifdef HAVE_GMTIME
Obj FuncIO_gmtime( Obj self, Obj time )
{
    Obj tmp;
    time_t t;
    struct tm *s;
    if (!IS_INTOBJ(time)) {
        tmp = QuoInt(time,INTOBJ_INT(256));
        if (!IS_INTOBJ(tmp)) return Fail;
        t = INT_INTOBJ(tmp)*256 + INT_INTOBJ(ModInt(time,INTOBJ_INT(256)));
    } else t = INT_INTOBJ(time);
    s = gmtime(&t);
    if (s == NULL) return Fail;
    tmp = NEW_PREC(0);
    AssPRec(tmp, RNamName("tm_sec"), INTOBJ_INT(s->tm_sec));
    AssPRec(tmp, RNamName("tm_min"), INTOBJ_INT(s->tm_min));
    AssPRec(tmp, RNamName("tm_hour"), INTOBJ_INT(s->tm_hour));
    AssPRec(tmp, RNamName("tm_mday"), INTOBJ_INT(s->tm_mday));
    AssPRec(tmp, RNamName("tm_mon"), INTOBJ_INT(s->tm_mon));
    AssPRec(tmp, RNamName("tm_year"), INTOBJ_INT(s->tm_year));
    AssPRec(tmp, RNamName("tm_wday"), INTOBJ_INT(s->tm_wday));
    AssPRec(tmp, RNamName("tm_yday"), INTOBJ_INT(s->tm_yday));
    AssPRec(tmp, RNamName("tm_isdst"), INTOBJ_INT(s->tm_isdst));
    return tmp;
}
#endif

#ifdef HAVE_LOCALTIME
Obj FuncIO_localtime( Obj self, Obj time )
{
    Obj tmp;
    time_t t;
    struct tm *s;
    if (!IS_INTOBJ(time)) {
        tmp = QuoInt(time,INTOBJ_INT(256));
        if (!IS_INTOBJ(tmp)) return Fail;
        t = INT_INTOBJ(tmp)*256 + INT_INTOBJ(ModInt(time,INTOBJ_INT(256)));
    } else t = INT_INTOBJ(time);
    s = localtime(&t);
    if (s == NULL) return Fail;
    tmp = NEW_PREC(0);
    AssPRec(tmp, RNamName("tm_sec"), INTOBJ_INT(s->tm_sec));
    AssPRec(tmp, RNamName("tm_min"), INTOBJ_INT(s->tm_min));
    AssPRec(tmp, RNamName("tm_hour"), INTOBJ_INT(s->tm_hour));
    AssPRec(tmp, RNamName("tm_mday"), INTOBJ_INT(s->tm_mday));
    AssPRec(tmp, RNamName("tm_mon"), INTOBJ_INT(s->tm_mon));
    AssPRec(tmp, RNamName("tm_year"), INTOBJ_INT(s->tm_year));
    AssPRec(tmp, RNamName("tm_wday"), INTOBJ_INT(s->tm_wday));
    AssPRec(tmp, RNamName("tm_yday"), INTOBJ_INT(s->tm_yday));
    AssPRec(tmp, RNamName("tm_isdst"), INTOBJ_INT(s->tm_isdst));
    return tmp;
}
#endif

#ifdef HAVE_GETSOCKNAME
Obj FuncIO_getsockname(Obj self, Obj fd)
{
  struct sockaddr_in sa;
  socklen_t sa_len;
  Obj res;
  if (!IS_INTOBJ(fd)) {
      SyClearErrorNo();
      return Fail;
  } else {
      sa_len = sizeof sa;
      getsockname (INT_INTOBJ(fd), (struct sockaddr *) (&sa), &sa_len);
      res = NEW_STRING(sa_len);
      memcpy(CHARS_STRING(res),&sa,sa_len);
      return res;
  }
}
#endif

#ifdef HAVE_GETHOSTNAME
Obj FuncIO_gethostname(Obj self)
{
  char name[256];
  Obj res;
  int i,r;
  r = gethostname(name, 256);
  if (r < 0) {
      return Fail;
  }
  i = strlen(name);
  res = NEW_STRING(i);
  memcpy(CHARS_STRING(res),name,i);
  return res;
}
#endif

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  { "IO_open", 3, "pathname, flags, mode", 
    FuncIO_open, 
    "io.c:IO_open" },

  { "IO_creat", 2, "pathname, mode", 
    FuncIO_creat, 
    "io.c:IO_creat" },

  { "IO_read", 4, "fd, st, offset, count", 
    FuncIO_read, 
    "io.c:IO_read" },

  { "IO_write", 4, "fd, st, offset, count", 
    FuncIO_write, 
    "io.c:IO_write" },

  { "IO_close", 1, "fd", 
    FuncIO_close, 
    "io.c:IO_close" },

  { "IO_lseek", 3, "fd, offset, whence", 
    FuncIO_lseek, 
    "io.c:IO_lseek" },

#ifdef HAVE_DIRENT_H

#ifdef HAVE_OPENDIR
  { "IO_opendir", 1, "name",
    FuncIO_opendir, 
    "io.c:IO_opendir" },
#endif

#ifdef HAVE_READDIR
  { "IO_readdir", 0, "",
    FuncIO_readdir, 
    "io.c:IO_readdir" },
#endif

#ifdef HAVE_REWINDDIR
  { "IO_rewinddir", 0, "",
    FuncIO_rewinddir, 
    "io.c:IO_rewinddir" },
#endif

#ifdef HAVE_CLOSEDIR
  { "IO_closedir", 0, "",
    FuncIO_closedir, 
    "io.c:IO_closedir" },
#endif

#ifdef HAVE_TELLDIR
  { "IO_telldir", 0, "",
    FuncIO_telldir, 
    "io.c:IO_telldir" },
#endif

#ifdef HAVE_SEEKDIR
  { "IO_seekdir", 1, "offset",
    FuncIO_seekdir, 
    "io.c:IO_seekdir" },
#endif

#endif   /* HAVE_DIRENT_H */

#ifdef HAVE_UNLINK
  { "IO_unlink", 1, "pathname", 
    FuncIO_unlink, 
    "io.c:IO_unlink" },
#endif

#ifdef HAVE_LINK
  { "IO_link", 2, "oldpath, newpath", 
    FuncIO_link, 
    "io.c:IO_link" },
#endif

#ifdef HAVE_RENAME
  { "IO_rename", 2, "oldpath, newpath", 
    FuncIO_rename, 
    "io.c:IO_rename" },
#endif

#ifdef HAVE_SYMLINK
  { "IO_symlink", 2, "oldpath, newpath", 
    FuncIO_symlink, 
    "io.c:IO_symlink" },
#endif

#ifdef HAVE_READLINK
  { "IO_readlink", 3, "path, buf, bufsize", 
    FuncIO_readlink, 
    "io.c:IO_readlink" },
#endif

#ifdef HAVE_MKDIR
  { "IO_mkdir", 2, "pathname, mode", 
    FuncIO_mkdir, 
    "io.c:IO_mkdir" },
#endif

  { "IO_chdir", 1, "path", 
    FuncIO_chdir, 
    "io.c:IO_chdir" },

#ifdef HAVE_RMDIR
  { "IO_rmdir", 1, "pathname", 
    FuncIO_rmdir, 
    "io.c:IO_rmdir" },
#endif

#ifdef HAVE_STAT
  { "IO_stat", 1, "pathname", 
    FuncIO_stat, 
    "io.c:IO_stat" },
#endif

#ifdef HAVE_FSTAT
  { "IO_fstat", 1, "fd", 
    FuncIO_fstat, 
    "io.c:IO_fstat" },
#endif

#ifdef HAVE_LSTAT
  { "IO_lstat", 1, "pathname", 
    FuncIO_lstat, 
    "io.c:IO_lstat" },
#endif

#ifdef HAVE_CHMOD
  { "IO_chmod", 2, "path, mode", 
    FuncIO_chmod, 
    "io.c:IO_chmod" },
#endif

#ifdef HAVE_FCHMOD
  { "IO_fchmod", 2, "fd, mode", 
    FuncIO_fchmod, 
    "io.c:IO_fchmod" },
#endif

#ifdef HAVE_CHOWN
  { "IO_chown", 3, "path, owner, group", 
    FuncIO_chown, 
    "io.c:IO_chown" },
#endif

#ifdef HAVE_FCHOWN
  { "IO_fchown", 3, "fd, owner, group", 
    FuncIO_fchown, 
    "io.c:IO_fchown" },
#endif

#ifdef HAVE_LCHOWN
  { "IO_lchown", 3, "path, owner, group", 
    FuncIO_lchown, 
    "io.c:IO_lchown" },
#endif

#ifdef HAVE_MKNOD
  { "IO_mknod", 3, "path, mode, dev", 
    FuncIO_mknod, 
    "io.c:IO_mknod" },
#endif

#ifdef HAVE_MKFIFO
  { "IO_mkfifo", 2, "path, mode", 
    FuncIO_mkfifo, 
    "io.c:IO_mkfifo" },
#endif

#ifdef HAVE_DUP
  { "IO_dup", 1, "oldfd", 
    FuncIO_dup, 
    "io.c:IO_dup" },
#endif

#ifdef HAVE_DUP2
  { "IO_dup2", 2, "oldfd, newfd", 
    FuncIO_dup2, 
    "io.c:IO_dup2" },
#endif

#ifdef HAVE_SOCKET
  { "IO_socket", 3, "domain, type, protocol", 
    FuncIO_socket, 
    "io.c:IO_socket" },
#endif

#ifdef HAVE_BIND
  { "IO_bind", 2, "fd, my_addr", 
    FuncIO_bind, 
    "io.c:IO_bind" },
#endif
  
#ifdef HAVE_CONNECT
  { "IO_connect", 2, "fd, serv_addr", 
    FuncIO_connect, 
    "io.c:IO_connect" },
#endif

#ifdef HAVE_SOCKET
  { "IO_make_sockaddr_in", 2, "ip, port", 
    FuncIO_make_sockaddr_in, 
    "io.c:IO_make_sockaddr_in" },
#endif

#ifdef HAVE_GETHOSTBYNAME
  { "IO_gethostbyname", 1, "name", 
    FuncIO_gethostbyname, 
    "io.c:IO_gethostbyname" },
#endif

#ifdef HAVE_LISTEN
  { "IO_listen", 2, "s, backlog", 
    FuncIO_listen, 
    "io.c:IO_listen" },
#endif

#ifdef HAVE_ACCEPT
  { "IO_accept", 2, "fd, addr", 
    FuncIO_accept, 
    "io.c:IO_accept" },
#endif

#ifdef HAVE_RECV
  { "IO_recv", 5, "fd, st, offset, len, flags", 
    FuncIO_recv, 
    "io.c:IO_recv" },
#endif

#ifdef HAVE_RECVFROM
  { "IO_recvfrom", 6, "fd, st, offset, len, flags, from", 
    FuncIO_recvfrom, 
    "io.c:IO_recvfrom" },
#endif

#ifdef HAVE_SEND
  { "IO_send", 5, "fd, st, offset, len, flags", 
    FuncIO_send, 
    "io.c:IO_send" },
#endif

#ifdef HAVE_SENDTO
  { "IO_sendto", 6, "fd, st, offset, len, flags, to", 
    FuncIO_sendto, 
    "io.c:IO_sendto" },
#endif

#ifdef HAVE_GETSOCKOPT
  { "IO_getsockopt", 5, "fd, level, optname, optval, optlen", 
    FuncIO_getsockopt, 
    "io.c:IO_getsockopt" },
#endif

#ifdef HAVE_SETSOCKOPT
  { "IO_setsockopt", 4, "fd, level, optname, optval", 
    FuncIO_setsockopt, 
    "io.c:IO_setsockopt" },
#endif

#ifdef HAVE_SELECT
  { "IO_select", 5, "inlist, outlist, exclist, timeoutsec, timeoutusec",
    FuncIO_select, 
    "io.c:IO_select" },
#endif

  { "IO_WaitPid", 2, "pid, wait",
    FuncIO_WaitPid, 
    "io.c:IO_WaitPid" },

#ifdef HAVE_FORK
  { "IO_fork", 0, "",
    FuncIO_fork, 
    "io.c:IO_fork" },
#endif

  { "IO_execv", 2, "path, argv",
    FuncIO_execv,
    "io.c:IO_execv" },

  { "IO_execvp", 2, "path, argv",
    FuncIO_execvp,
    "io.c:IO_execvp" },

  { "IO_execve", 3, "path, argv, envp",
    FuncIO_execve,
    "io.c:IO_execve" },

  { "IO_environ", 0, "",
    FuncIO_environ,
    "io.c:IO_environ" },

#ifdef HAVE_SIGNAL
  { "IO_InstallSIGCHLDHandler", 0, "",
    FuncIO_InstallSIGCHLDHandler,
    "io.c:IO_InstallSIGCHLDHandler" },

  { "IO_RestoreSIGCHLDHandler", 0, "",
    FuncIO_RestoreSIGCHLDHandler,
    "io.c:IO_RestoreSIGCHLDHandler" },
#endif 

  { "IO_pipe", 0, "",
    FuncIO_pipe,
    "io.c:IO_pipe" },

  { "IO_exit", 1, "status",
    FuncIO_exit,
    "io.c:IO_exit" },

  { "IO_MasterPointerNumber", 1, "obj",
    FuncIO_MasterPointerNumber,
    "io.c:IO_MasterPointerNumber" },

#ifdef HAVE_FCNTL_H
  { "IO_fcntl", 3, "fd, cmd, arg",
    FuncIO_fcntl,
    "io.c:IO_fcntl" },
#endif

#ifdef HAVE_GETPID
  { "IO_getpid", 0, "",
    FuncIO_getpid,
    "io.c:IO_getpid" },
#endif

#ifdef HAVE_GETPPID
  { "IO_getppid", 0, "",
    FuncIO_getppid,
    "io.c:IO_getppid" },
#endif

#ifdef HAVE_KILL
  { "IO_kill", 2, "pid, sig",
    FuncIO_kill,
    "io.c:IO_kill" },
#endif

#ifdef HAVE_GETTIMEOFDAY
  { "IO_gettimeofday", 0, "",
    FuncIO_gettimeofday,
    "io.c:IO_gettimeofday" },
#endif

#ifdef HAVE_GMTIME
  { "IO_gmtime", 1, "seconds",
    FuncIO_gmtime,
    "io.c:IO_gmtime" },
#endif

#ifdef HAVE_LOCALTIME
  { "IO_localtime", 1, "seconds",
    FuncIO_localtime,
    "io.c:IO_localtime" },
#endif

#ifdef HAVE_GETSOCKNAME
  { "IO_getsockname", 1, "fd",
    FuncIO_getsockname,
    "io.c:IO_getsockname" },
#endif

#ifdef HAVE_GETHOSTNAME
  { "IO_gethostname", 0, "",
    FuncIO_gethostname,
    "io.c:IO_gethostname" },
#endif

  { 0 }

};

/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo *module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *module )
{
    Int             i, gvar;
    Obj             tmp;

    /* init filters and functions
       we assign the functions to components of a record "IO"         */
    for ( i = 0; GVarFuncs[i].name != 0;  i++ ) {
      gvar = GVarName(GVarFuncs[i].name);
      AssGVar(gvar,NewFunctionC( GVarFuncs[i].name, GVarFuncs[i].nargs,
                                 GVarFuncs[i].args, GVarFuncs[i].handler )); 
      MakeReadOnlyGVar(gvar);
    }
    
    tmp = NewAtomicRecord(0);
    //tmp = NEW_PREC(0);
    /* Constants for the flags: */
    //AssPRec(tmp, RNamName("O_RDONLY"), INTOBJ_INT((Int) O_RDONLY));
    SetARecordField(tmp, RNamName("O_RDONLY"), INTOBJ_INT((Int) O_RDONLY));
    SetARecordField(tmp, RNamName("O_WRONLY"), INTOBJ_INT((Int) O_WRONLY));
    SetARecordField(tmp, RNamName("O_RDWR"), INTOBJ_INT((Int) O_RDWR));
#ifdef O_CREAT
    SetARecordField(tmp, RNamName("O_CREAT"), INTOBJ_INT((Int) O_CREAT));
#endif
#ifdef O_APPEND
    SetARecordField(tmp, RNamName("O_APPEND"), INTOBJ_INT((Int) O_APPEND));
#endif
#ifdef O_ASYNC
    SetARecordField(tmp, RNamName("O_ASYNC"), INTOBJ_INT((Int) O_ASYNC));
#endif
#ifdef O_DIRECT
    SetARecordField(tmp, RNamName("O_DIRECT"), INTOBJ_INT((Int) O_DIRECT));
#endif
#ifdef O_DIRECTORY
    SetARecordField(tmp, RNamName("O_DIRECTORY"), INTOBJ_INT((Int) O_DIRECTORY));
#endif
#ifdef O_EXCL
    SetARecordField(tmp, RNamName("O_EXCL"), INTOBJ_INT((Int) O_EXCL));
#endif
#ifdef O_LARGEFILE
    SetARecordField(tmp, RNamName("O_LARGEFILE"), INTOBJ_INT((Int) O_LARGEFILE));
#endif
#ifdef O_NOATIME
    SetARecordField(tmp, RNamName("O_NOATIME"), INTOBJ_INT((Int) O_NOATIME));
#endif
#ifdef O_NOCTTY
    SetARecordField(tmp, RNamName("O_NOCTTY"), INTOBJ_INT((Int) O_NOCTTY));
#endif
#ifdef O_NOFOLLOW
    SetARecordField(tmp, RNamName("O_NOFOLLOW"), INTOBJ_INT((Int) O_NOFOLLOW));
#endif
#ifdef O_NONBLOCK
    SetARecordField(tmp, RNamName("O_NONBLOCK"), INTOBJ_INT((Int) O_NONBLOCK));
#endif
#ifdef O_NDELAY
    SetARecordField(tmp, RNamName("O_NDELAY"), INTOBJ_INT((Int) O_NDELAY));
#endif
#ifdef O_SYNC
    SetARecordField(tmp, RNamName("O_SYNC"), INTOBJ_INT((Int) O_SYNC));
#endif
#ifdef O_TRUNC
    SetARecordField(tmp, RNamName("O_TRUNC"), INTOBJ_INT((Int) O_TRUNC));
#endif
#ifdef SEEK_SET
    SetARecordField(tmp, RNamName("SEEK_SET"), INTOBJ_INT((Int) SEEK_SET));
#endif
#ifdef SEEK_CUR
    SetARecordField(tmp, RNamName("SEEK_CUR"), INTOBJ_INT((Int) SEEK_CUR));
#endif
#ifdef SEEK_END
    SetARecordField(tmp, RNamName("SEEK_END"), INTOBJ_INT((Int) SEEK_END));
#endif

    /* Constants for the mode: */
#ifdef S_IRWXU
    SetARecordField(tmp, RNamName("S_IRWXU"), INTOBJ_INT((Int) S_IRWXU));
#endif
#ifdef S_IRUSR
    SetARecordField(tmp, RNamName("S_IRUSR"), INTOBJ_INT((Int) S_IRUSR));
#endif
#ifdef S_IWUSR
    SetARecordField(tmp, RNamName("S_IWUSR"), INTOBJ_INT((Int) S_IWUSR));
#endif
#ifdef S_IXUSR
    SetARecordField(tmp, RNamName("S_IXUSR"), INTOBJ_INT((Int) S_IXUSR));
#endif
#ifdef S_IRWXG
    SetARecordField(tmp, RNamName("S_IRWXG"), INTOBJ_INT((Int) S_IRWXG));
#endif
#ifdef S_IRGRP
    SetARecordField(tmp, RNamName("S_IRGRP"), INTOBJ_INT((Int) S_IRGRP));
#endif
#ifdef S_IWGRP
    SetARecordField(tmp, RNamName("S_IWGRP"), INTOBJ_INT((Int) S_IWGRP));
#endif
#ifdef S_IXGRP
    SetARecordField(tmp, RNamName("S_IXGRP"), INTOBJ_INT((Int) S_IXGRP));
#endif
#ifdef S_IRWXO
    SetARecordField(tmp, RNamName("S_IRWXO"), INTOBJ_INT((Int) S_IRWXO));
#endif
#ifdef S_IROTH
    SetARecordField(tmp, RNamName("S_IROTH"), INTOBJ_INT((Int) S_IROTH));
#endif
#ifdef S_IWOTH
    SetARecordField(tmp, RNamName("S_IWOTH"), INTOBJ_INT((Int) S_IWOTH));
#endif
#ifdef S_IXOTH
    SetARecordField(tmp, RNamName("S_IXOTH"), INTOBJ_INT((Int) S_IXOTH));
#endif
#ifdef S_IFMT
    SetARecordField(tmp, RNamName("S_IFMT"), INTOBJ_INT((Int) S_IFMT));
#endif
#ifdef S_IFSOCK
    SetARecordField(tmp, RNamName("S_IFSOCK"), INTOBJ_INT((Int) S_IFSOCK));
#endif
#ifdef S_IFLNK
    SetARecordField(tmp, RNamName("S_IFLNK"), INTOBJ_INT((Int) S_IFLNK));
#endif
#ifdef S_IFREG
    SetARecordField(tmp, RNamName("S_IFREG"), INTOBJ_INT((Int) S_IFREG));
#endif
#ifdef S_IFBLK
    SetARecordField(tmp, RNamName("S_IFBLK"), INTOBJ_INT((Int) S_IFBLK));
#endif
#ifdef S_IFDIR
    SetARecordField(tmp, RNamName("S_IFDIR"), INTOBJ_INT((Int) S_IFDIR));
#endif
#ifdef S_IFCHR
    SetARecordField(tmp, RNamName("S_IFCHR"), INTOBJ_INT((Int) S_IFCHR));
#endif
#ifdef S_IFIFO
    SetARecordField(tmp, RNamName("S_IFIFO"), INTOBJ_INT((Int) S_IFIFO));
#endif
#ifdef S_ISUID
    SetARecordField(tmp, RNamName("S_ISUID"), INTOBJ_INT((Int) S_ISUID));
#endif
#ifdef S_ISGID
    SetARecordField(tmp, RNamName("S_ISGID"), INTOBJ_INT((Int) S_ISGID));
#endif
#ifdef S_ISVTX
    SetARecordField(tmp, RNamName("S_ISVTX"), INTOBJ_INT((Int) S_ISVTX));
#endif

    /* Constants for the errors: */
#ifdef EACCES
    SetARecordField(tmp, RNamName("EACCES"), INTOBJ_INT((Int) EACCES));
#endif
#ifdef EEXIST
    SetARecordField(tmp, RNamName("EEXIST"), INTOBJ_INT((Int) EEXIST));
#endif
#ifdef EFAULT
    SetARecordField(tmp, RNamName("EFAULT"), INTOBJ_INT((Int) EFAULT));
#endif
#ifdef EISDIR
    SetARecordField(tmp, RNamName("EISDIR"), INTOBJ_INT((Int) EISDIR));
#endif
#ifdef ELOOP
    SetARecordField(tmp, RNamName("ELOOP"), INTOBJ_INT((Int) ELOOP));
#endif
#ifdef EMFILE
    SetARecordField(tmp, RNamName("EMFILE"), INTOBJ_INT((Int) EMFILE));
#endif
#ifdef ENAMETOOLONG
    SetARecordField(tmp, RNamName("ENAMETOOLONG"), INTOBJ_INT((Int) ENAMETOOLONG));
#endif
#ifdef ENFILE
    SetARecordField(tmp, RNamName("ENFILE"), INTOBJ_INT((Int) ENFILE));
#endif
#ifdef ENODEV
    SetARecordField(tmp, RNamName("ENODEV"), INTOBJ_INT((Int) ENODEV));
#endif
#ifdef ENOENT
    SetARecordField(tmp, RNamName("ENOENT"), INTOBJ_INT((Int) ENOENT));
#endif
#ifdef ENOMEM
    SetARecordField(tmp, RNamName("ENOMEM"), INTOBJ_INT((Int) ENOMEM));
#endif
#ifdef ENOSPC
    SetARecordField(tmp, RNamName("ENOSPC"), INTOBJ_INT((Int) ENOSPC));
#endif
#ifdef ENOTDIR
    SetARecordField(tmp, RNamName("ENOTDIR"), INTOBJ_INT((Int) ENOTDIR));
#endif
#ifdef ENXIO
    SetARecordField(tmp, RNamName("ENXIO"), INTOBJ_INT((Int) ENXIO));
#endif
#ifdef EOVERFLOW
    SetARecordField(tmp, RNamName("EOVERFLOW"), INTOBJ_INT((Int) EOVERFLOW));
#endif
#ifdef EPERM
    SetARecordField(tmp, RNamName("EPERM"), INTOBJ_INT((Int) EPERM));
#endif
#ifdef EROFS
    SetARecordField(tmp, RNamName("EROFS"), INTOBJ_INT((Int) EROFS));
#endif
#ifdef ETXTBSY
    SetARecordField(tmp, RNamName("ETXTBSY"), INTOBJ_INT((Int) ETXTBSY));
#endif
#ifdef EAGAIN
    SetARecordField(tmp, RNamName("EAGAIN"), INTOBJ_INT((Int) EAGAIN));
#endif
#ifdef EBADF
    SetARecordField(tmp, RNamName("EBADF"), INTOBJ_INT((Int) EBADF));
#endif
#ifdef EINTR
    SetARecordField(tmp, RNamName("EINTR"), INTOBJ_INT((Int) EINTR));
#endif
#ifdef EINVAL
    SetARecordField(tmp, RNamName("EINVAL"), INTOBJ_INT((Int) EINVAL));
#endif
#ifdef EIO
    SetARecordField(tmp, RNamName("EIO"), INTOBJ_INT((Int) EIO));
#endif
#ifdef EFBIG
    SetARecordField(tmp, RNamName("EFBIG"), INTOBJ_INT((Int) EFBIG));
#endif
#ifdef ENOSPC
    SetARecordField(tmp, RNamName("ENOSPC"), INTOBJ_INT((Int) ENOSPC));
#endif
#ifdef EPIPE
    SetARecordField(tmp, RNamName("EPIPE"), INTOBJ_INT((Int) EPIPE));
#endif
#ifdef EBUSY
    SetARecordField(tmp, RNamName("EBUSY"), INTOBJ_INT((Int) EBUSY));
#endif
#ifdef ESPIPE
    SetARecordField(tmp, RNamName("ESPIPE"), INTOBJ_INT((Int) ESPIPE));
#endif
#ifdef EMLINK
    SetARecordField(tmp, RNamName("EMLINK"), INTOBJ_INT((Int) EMLINK));
#endif
#ifdef EXDEV
    SetARecordField(tmp, RNamName("EXDEV"), INTOBJ_INT((Int) EXDEV));
#endif
#ifdef ENOTEMPTY
    SetARecordField(tmp, RNamName("ENOTEMPTY"), INTOBJ_INT((Int) ENOTEMPTY));
#endif
#ifdef EAFNOSUPPORT 
    SetARecordField(tmp, RNamName("EAFNOSUPPORT"), INTOBJ_INT((Int) EAFNOSUPPORT));
#endif
#ifdef ENOBUGS 
    SetARecordField(tmp, RNamName("ENOBUGS"), INTOBJ_INT((Int) ENOBUGS));
#endif
#ifdef EPROTONOSUPPORT 
    SetARecordField(tmp, RNamName("EPROTONOSUPPORT"),INTOBJ_INT((Int) EPROTONOSUPPORT));
#endif
#ifdef ENOTSOCK 
    SetARecordField(tmp, RNamName("ENOTSOCK"),INTOBJ_INT((Int) ENOTSOCK));
#endif
#ifdef EADDRINUSE
    SetARecordField(tmp, RNamName("EADDRINUSE"), INTOBJ_INT((Int) EADDRINUSE));
#endif
#ifdef EALREADY
    SetARecordField(tmp, RNamName("EALREADY"), INTOBJ_INT((Int) EALREADY));
#endif
#ifdef ECONNREFUSED
    SetARecordField(tmp, RNamName("ECONNREFUSED"), INTOBJ_INT((Int) ECONNREFUSED));
#endif
#ifdef EINPROGRESS
    SetARecordField(tmp, RNamName("EINPROGRESS"), INTOBJ_INT((Int) EINPROGRESS));
#endif
#ifdef EISCONN
    SetARecordField(tmp, RNamName("EISCONN"), INTOBJ_INT((Int) EISCONN));
#endif
#ifdef ETIMEDOUT
    SetARecordField(tmp, RNamName("ETIMEDOUT"), INTOBJ_INT((Int) ETIMEDOUT));
#endif
#ifdef EOPNOTSUPP
    SetARecordField(tmp, RNamName("EOPNOTSUPP"), INTOBJ_INT((Int) EOPNOTSUPP));
#endif
#ifdef EPROTO 
    SetARecordField(tmp, RNamName("EPROTO"), INTOBJ_INT((Int) EPROTO));
#endif
#ifdef ECONNABORTED 
    SetARecordField(tmp, RNamName("ECONNABORTED"), INTOBJ_INT((Int) ECONNABORTED));
#endif
#ifdef ECHILD 
    SetARecordField(tmp, RNamName("ECHILD"), INTOBJ_INT((Int) ECHILD));
#endif
#ifdef EWOULDBLOCK 
    SetARecordField(tmp, RNamName("EWOULDBLOCK"), INTOBJ_INT((Int) EWOULDBLOCK));
#endif
#ifdef HOST_NOT_FOUND
    SetARecordField(tmp, RNamName("HOST_NOT_FOUND"), INTOBJ_INT((Int) HOST_NOT_FOUND));
#endif
#ifdef NO_ADDRESS
    SetARecordField(tmp, RNamName("NO_ADDRESS"), INTOBJ_INT((Int) NO_ADDRESS));
#endif
#ifdef NO_DATA
    SetARecordField(tmp, RNamName("NO_DATA"), INTOBJ_INT((Int) NO_DATA));
#endif
#ifdef NO_RECOVERY
    SetARecordField(tmp, RNamName("NO_RECOVERY"), INTOBJ_INT((Int) NO_RECOVERY));
#endif
#ifdef TRY_AGAIN
    SetARecordField(tmp, RNamName("TRY_AGAIN"), INTOBJ_INT((Int) TRY_AGAIN));
#endif

    /* Constants for networking: */
#ifdef AF_APPLETALK 
    SetARecordField(tmp, RNamName("AF_APPLETALK"), INTOBJ_INT((Int) AF_APPLETALK));
#endif
#ifdef AF_ASH 
    SetARecordField(tmp, RNamName("AF_ASH"), INTOBJ_INT((Int) AF_ASH));
#endif
#ifdef AF_ATMPVC 
    SetARecordField(tmp, RNamName("AF_ATMPVC"), INTOBJ_INT((Int) AF_ATMPVC));
#endif
#ifdef AF_ATMSVC 
    SetARecordField(tmp, RNamName("AF_ATMSVC"), INTOBJ_INT((Int) AF_ATMSVC));
#endif
#ifdef AF_AX25 
    SetARecordField(tmp, RNamName("AF_AX25"), INTOBJ_INT((Int) AF_AX25));
#endif
#ifdef AF_BLUETOOTH 
    SetARecordField(tmp, RNamName("AF_BLUETOOTH"), INTOBJ_INT((Int) AF_BLUETOOTH));
#endif
#ifdef AF_BRIDGE 
    SetARecordField(tmp, RNamName("AF_BRIDGE"), INTOBJ_INT((Int) AF_BRIDGE));
#endif
#ifdef AF_DECnet 
    SetARecordField(tmp, RNamName("AF_DECnet"), INTOBJ_INT((Int) AF_DECnet));
#endif
#ifdef AF_ECONET 
    SetARecordField(tmp, RNamName("AF_ECONET"), INTOBJ_INT((Int) AF_ECONET));
#endif
#ifdef AF_FILE 
    SetARecordField(tmp, RNamName("AF_FILE"), INTOBJ_INT((Int) AF_FILE));
#endif
#ifdef AF_INET 
    SetARecordField(tmp, RNamName("AF_INET"), INTOBJ_INT((Int) AF_INET));
#endif
#ifdef AF_INET6 
    SetARecordField(tmp, RNamName("AF_INET6"), INTOBJ_INT((Int) AF_INET6));
#endif
#ifdef AF_IPX 
    SetARecordField(tmp, RNamName("AF_IPX"), INTOBJ_INT((Int) AF_IPX));
#endif
#ifdef AF_IRDA 
    SetARecordField(tmp, RNamName("AF_IRDA"), INTOBJ_INT((Int) AF_IRDA));
#endif
#ifdef AF_KEY 
    SetARecordField(tmp, RNamName("AF_KEY"), INTOBJ_INT((Int) AF_KEY));
#endif
#ifdef AF_LOCAL 
    SetARecordField(tmp, RNamName("AF_LOCAL"), INTOBJ_INT((Int) AF_LOCAL));
#endif
#ifdef AF_MAX 
    SetARecordField(tmp, RNamName("AF_MAX"), INTOBJ_INT((Int) AF_MAX));
#endif
#ifdef AF_NETBEUI 
    SetARecordField(tmp, RNamName("AF_NETBEUI"), INTOBJ_INT((Int) AF_NETBEUI));
#endif
#ifdef AF_NETLINK 
    SetARecordField(tmp, RNamName("AF_NETLINK"), INTOBJ_INT((Int) AF_NETLINK));
#endif
#ifdef AF_NETROM 
    SetARecordField(tmp, RNamName("AF_NETROM"), INTOBJ_INT((Int) AF_NETROM));
#endif
#ifdef AF_PACKET 
    SetARecordField(tmp, RNamName("AF_PACKET"), INTOBJ_INT((Int) AF_PACKET));
#endif
#ifdef AF_PPPOX 
    SetARecordField(tmp, RNamName("AF_PPPOX"), INTOBJ_INT((Int) AF_PPPOX));
#endif
#ifdef AF_ROSE 
    SetARecordField(tmp, RNamName("AF_ROSE"), INTOBJ_INT((Int) AF_ROSE));
#endif
#ifdef AF_ROUTE 
    SetARecordField(tmp, RNamName("AF_ROUTE"), INTOBJ_INT((Int) AF_ROUTE));
#endif
#ifdef AF_SECURITY 
    SetARecordField(tmp, RNamName("AF_SECURITY"), INTOBJ_INT((Int) AF_SECURITY));
#endif
#ifdef AF_SNA 
    SetARecordField(tmp, RNamName("AF_SNA"), INTOBJ_INT((Int) AF_SNA));
#endif
#ifdef AF_UNIX 
    SetARecordField(tmp, RNamName("AF_UNIX"), INTOBJ_INT((Int) AF_UNIX));
#endif
#ifdef AF_UNSPEC 
    SetARecordField(tmp, RNamName("AF_UNSPEC"), INTOBJ_INT((Int) AF_UNSPEC));
#endif
#ifdef AF_WANPIPE 
    SetARecordField(tmp, RNamName("AF_WANPIPE"), INTOBJ_INT((Int) AF_WANPIPE));
#endif
#ifdef AF_X25 
    SetARecordField(tmp, RNamName("AF_X25"), INTOBJ_INT((Int) AF_X25));
#endif
#ifdef PF_APPLETALK 
    SetARecordField(tmp, RNamName("PF_APPLETALK"), INTOBJ_INT((Int) PF_APPLETALK));
#endif
#ifdef PF_ASH 
    SetARecordField(tmp, RNamName("PF_ASH"), INTOBJ_INT((Int) PF_ASH));
#endif
#ifdef PF_ATMPVC 
    SetARecordField(tmp, RNamName("PF_ATMPVC"), INTOBJ_INT((Int) PF_ATMPVC));
#endif
#ifdef PF_ATMSVC 
    SetARecordField(tmp, RNamName("PF_ATMSVC"), INTOBJ_INT((Int) PF_ATMSVC));
#endif
#ifdef PF_AX25 
    SetARecordField(tmp, RNamName("PF_AX25"), INTOBJ_INT((Int) PF_AX25));
#endif
#ifdef PF_BLUETOOTH 
    SetARecordField(tmp, RNamName("PF_BLUETOOTH"), INTOBJ_INT((Int) PF_BLUETOOTH));
#endif
#ifdef PF_BRIDGE 
    SetARecordField(tmp, RNamName("PF_BRIDGE"), INTOBJ_INT((Int) PF_BRIDGE));
#endif
#ifdef PF_DECnet 
    SetARecordField(tmp, RNamName("PF_DECnet"), INTOBJ_INT((Int) PF_DECnet));
#endif
#ifdef PF_ECONET 
    SetARecordField(tmp, RNamName("PF_ECONET"), INTOBJ_INT((Int) PF_ECONET));
#endif
#ifdef PF_FILE 
    SetARecordField(tmp, RNamName("PF_FILE"), INTOBJ_INT((Int) PF_FILE));
#endif
#ifdef PF_INET 
    SetARecordField(tmp, RNamName("PF_INET"), INTOBJ_INT((Int) PF_INET));
#endif
#ifdef PF_INET6 
    SetARecordField(tmp, RNamName("PF_INET6"), INTOBJ_INT((Int) PF_INET6));
#endif
#ifdef PF_IPX 
    SetARecordField(tmp, RNamName("PF_IPX"), INTOBJ_INT((Int) PF_IPX));
#endif
#ifdef PF_IRDA 
    SetARecordField(tmp, RNamName("PF_IRDA"), INTOBJ_INT((Int) PF_IRDA));
#endif
#ifdef PF_KEY 
    SetARecordField(tmp, RNamName("PF_KEY"), INTOBJ_INT((Int) PF_KEY));
#endif
#ifdef PF_LOCAL 
    SetARecordField(tmp, RNamName("PF_LOCAL"), INTOBJ_INT((Int) PF_LOCAL));
#endif
#ifdef PF_MAX 
    SetARecordField(tmp, RNamName("PF_MAX"), INTOBJ_INT((Int) PF_MAX));
#endif
#ifdef PF_NETBEUI 
    SetARecordField(tmp, RNamName("PF_NETBEUI"), INTOBJ_INT((Int) PF_NETBEUI));
#endif
#ifdef PF_NETLINK 
    SetARecordField(tmp, RNamName("PF_NETLINK"), INTOBJ_INT((Int) PF_NETLINK));
#endif
#ifdef PF_NETROM 
    SetARecordField(tmp, RNamName("PF_NETROM"), INTOBJ_INT((Int) PF_NETROM));
#endif
#ifdef PF_PACKET 
    SetARecordField(tmp, RNamName("PF_PACKET"), INTOBJ_INT((Int) PF_PACKET));
#endif
#ifdef PF_PPPOX 
    SetARecordField(tmp, RNamName("PF_PPPOX"), INTOBJ_INT((Int) PF_PPPOX));
#endif
#ifdef PF_ROSE 
    SetARecordField(tmp, RNamName("PF_ROSE"), INTOBJ_INT((Int) PF_ROSE));
#endif
#ifdef PF_ROUTE 
    SetARecordField(tmp, RNamName("PF_ROUTE"), INTOBJ_INT((Int) PF_ROUTE));
#endif
#ifdef PF_SECURITY 
    SetARecordField(tmp, RNamName("PF_SECURITY"), INTOBJ_INT((Int) PF_SECURITY));
#endif
#ifdef PF_SNA 
    SetARecordField(tmp, RNamName("PF_SNA"), INTOBJ_INT((Int) PF_SNA));
#endif
#ifdef PF_UNIX 
    SetARecordField(tmp, RNamName("PF_UNIX"), INTOBJ_INT((Int) PF_UNIX));
#endif
#ifdef PF_WANPIPE 
    SetARecordField(tmp, RNamName("PF_WANPIPE"), INTOBJ_INT((Int) PF_WANPIPE));
#endif
#ifdef PF_X25 
    SetARecordField(tmp, RNamName("PF_X25"), INTOBJ_INT((Int) PF_X25));
#endif
#ifdef SOCK_DGRAM 
    SetARecordField(tmp, RNamName("SOCK_DGRAM"), INTOBJ_INT((Int) SOCK_DGRAM));
#endif
#ifdef SOCK_PACKET 
    SetARecordField(tmp, RNamName("SOCK_PACKET"), INTOBJ_INT((Int) SOCK_PACKET));
#endif
#ifdef SOCK_RAW 
    SetARecordField(tmp, RNamName("SOCK_RAW"), INTOBJ_INT((Int) SOCK_RAW));
#endif
#ifdef SOCK_RDM 
    SetARecordField(tmp, RNamName("SOCK_RDM"), INTOBJ_INT((Int) SOCK_RDM));
#endif
#ifdef SOCK_SEQPACKET 
    SetARecordField(tmp, RNamName("SOCK_SEQPACKET"), INTOBJ_INT((Int) SOCK_SEQPACKET));
#endif
#ifdef SOCK_STREAM 
    SetARecordField(tmp, RNamName("SOCK_STREAM"), INTOBJ_INT((Int) SOCK_STREAM));
#endif
#ifdef SOL_SOCKET 
    SetARecordField(tmp, RNamName("SOL_SOCKET"), INTOBJ_INT((Int) SOL_SOCKET));
#endif
#ifdef IP_OPTIONS 
    SetARecordField(tmp, RNamName("IP_OPTIONS"), INTOBJ_INT((Int) IP_OPTIONS));
#endif
#ifdef IP_PKTINFO 
    SetARecordField(tmp, RNamName("IP_PKTINFO"), INTOBJ_INT((Int) IP_PKTINFO));
#endif
#ifdef IP_RECVTOS 
    SetARecordField(tmp, RNamName("IP_RECVTOS"), INTOBJ_INT((Int) IP_RECVTOS));
#endif
#ifdef IP_RECVTTL 
    SetARecordField(tmp, RNamName("IP_RECVTTL"), INTOBJ_INT((Int) IP_RECVTTL));
#endif
#ifdef IP_RECVOPTS 
    SetARecordField(tmp, RNamName("IP_RECVOPTS"), INTOBJ_INT((Int) IP_RECVOPTS));
#endif
#ifdef IP_RETOPTS 
    SetARecordField(tmp, RNamName("IP_RETOPTS"), INTOBJ_INT((Int) IP_RETOPTS));
#endif
#ifdef IP_TOS 
    SetARecordField(tmp, RNamName("IP_TOS"), INTOBJ_INT((Int) IP_TOS));
#endif
#ifdef IP_TTL 
    SetARecordField(tmp, RNamName("IP_TTL"), INTOBJ_INT((Int) IP_TTL));
#endif
#ifdef IP_HDRINCL 
    SetARecordField(tmp, RNamName("IP_HDRINCL"), INTOBJ_INT((Int) IP_HDRINCL));
#endif
#ifdef IP_RECVERR 
    SetARecordField(tmp, RNamName("IP_RECVERR"), INTOBJ_INT((Int) IP_RECVERR));
#endif
#ifdef IP_MTU_DISCOVER 
    SetARecordField(tmp, RNamName("IP_MTU_DISCOVER"), 
                 INTOBJ_INT((Int) IP_MTU_DISCOVER));
#endif
#ifdef IP_MTU 
    SetARecordField(tmp, RNamName("IP_MTU"), INTOBJ_INT((Int) IP_MTU));
#endif
#ifdef IP_ROUTER_ALERT 
    SetARecordField(tmp, RNamName("IP_ROUTER_ALERT"), 
                 INTOBJ_INT((Int) IP_ROUTER_ALERT));
#endif
#ifdef IP_MULTICAST_TTL 
    SetARecordField(tmp, RNamName("IP_MULTICAST_TTL"), 
                 INTOBJ_INT((Int) IP_MULTICAST_TTL));
#endif
#ifdef IP_MULTICAST_LOOP 
    SetARecordField(tmp, RNamName("IP_MULTICAST_LOOP"), 
                 INTOBJ_INT((Int) IP_MULTICAST_LOOP));
#endif
#ifdef IP_ADD_MEMBERSHIP 
    SetARecordField(tmp, RNamName("IP_ADD_MEMBERSHIP"), 
                 INTOBJ_INT((Int) IP_ADD_MEMBERSHIP));
#endif
#ifdef IP_DROP_MEMBERSHIP 
    SetARecordField(tmp, RNamName("IP_DROP_MEMBERSHIP"),
                 INTOBJ_INT((Int)IP_DROP_MEMBERSHIP));
#endif
#ifdef IP_MULTICAST_IF 
    SetARecordField(tmp, RNamName("IP_MULTICAST_IF"),INTOBJ_INT((Int) IP_MULTICAST_IF));
#endif
#ifdef SO_RCVBUF 
    SetARecordField(tmp, RNamName("SO_RCVBUF"), INTOBJ_INT((Int) SO_RCVBUF));
#endif
#ifdef SO_SNDBUF 
    SetARecordField(tmp, RNamName("SO_SNDBUF"), INTOBJ_INT((Int) SO_SNDBUF));
#endif
#ifdef SO_SNDLOWAT 
    SetARecordField(tmp, RNamName("SO_SNDLOWAT"), INTOBJ_INT((Int) SO_SNDLOWAT));
#endif
#ifdef SO_RCVLOWAT 
    SetARecordField(tmp, RNamName("SO_RCVLOWAT"), INTOBJ_INT((Int) SO_RCVLOWAT));
#endif
#ifdef SO_SNDTIMEO 
    SetARecordField(tmp, RNamName("SO_SNDTIMEO"), INTOBJ_INT((Int) SO_SNDTIMEO));
#endif
#ifdef SO_RCVTIMEO 
    SetARecordField(tmp, RNamName("SO_RCVTIMEO"), INTOBJ_INT((Int) SO_RCVTIMEO));
#endif
#ifdef SO_REUSEADDR 
    SetARecordField(tmp, RNamName("SO_REUSEADDR"), INTOBJ_INT((Int) SO_REUSEADDR));
#endif
#ifdef SO_KEEPALIVE 
    SetARecordField(tmp, RNamName("SO_KEEPALIVE"), INTOBJ_INT((Int) SO_KEEPALIVE));
#endif
#ifdef SO_OOBINLINE 
    SetARecordField(tmp, RNamName("SO_OOBINLINE"), INTOBJ_INT((Int) SO_OOBINLINE));
#endif
#ifdef SO_BSDCOMPAT 
    SetARecordField(tmp, RNamName("SO_BSDCOMPAT"), INTOBJ_INT((Int) SO_BSDCOMPAT));
#endif
#ifdef SO_PASSCRED 
    SetARecordField(tmp, RNamName("SO_PASSCRED"), INTOBJ_INT((Int) SO_PASSCRED));
#endif
#ifdef SO_PEERCRED 
    SetARecordField(tmp, RNamName("SO_PEERCRED"), INTOBJ_INT((Int) SO_PEERCRED));
#endif
#ifdef SO_BINDTODEVICE 
    SetARecordField(tmp, RNamName("SO_BINDTODEVICE"),INTOBJ_INT((Int) SO_BINDTODEVICE));
#endif
#ifdef SO_DEBUG 
    SetARecordField(tmp, RNamName("SO_DEBUG"), INTOBJ_INT((Int) SO_DEBUG));
#endif
#ifdef SO_TYPE 
    SetARecordField(tmp, RNamName("SO_TYPE"), INTOBJ_INT((Int) SO_TYPE));
#endif
#ifdef SO_ACCEPTCONN 
    SetARecordField(tmp, RNamName("SO_ACCEPTCONN"), INTOBJ_INT((Int) SO_ACCEPTCONN));
#endif
#ifdef SO_DONTROUTE 
    SetARecordField(tmp, RNamName("SO_DONTROUTE"), INTOBJ_INT((Int) SO_DONTROUTE));
#endif
#ifdef SO_BROADCAST 
    SetARecordField(tmp, RNamName("SO_BROADCAST"), INTOBJ_INT((Int) SO_BROADCAST));
#endif
#ifdef SO_LINGER 
    SetARecordField(tmp, RNamName("SO_LINGER"), INTOBJ_INT((Int) SO_LINGER));
#endif
#ifdef SO_PRIORITY 
    SetARecordField(tmp, RNamName("SO_PRIORITY"), INTOBJ_INT((Int) SO_PRIORITY));
#endif
#ifdef SO_ERROR 
    SetARecordField(tmp, RNamName("SO_ERROR"), INTOBJ_INT((Int) SO_ERROR));
#endif

#ifdef TCP_CORK 
    SetARecordField(tmp, RNamName("TCP_CORK"), INTOBJ_INT((Int) TCP_CORK));
#endif
#ifdef TCP_DEFER_ACCEPT 
    SetARecordField(tmp,RNamName("TCP_DEFER_ACCEPT"),INTOBJ_INT((Int)TCP_DEFER_ACCEPT));
#endif
#ifdef TCP_INFO 
    SetARecordField(tmp, RNamName("TCP_INFO"), INTOBJ_INT((Int) TCP_INFO));
#endif
#ifdef TCP_KEEPCNT 
    SetARecordField(tmp, RNamName("TCP_KEEPCNT"), INTOBJ_INT((Int) TCP_KEEPCNT));
#endif
#ifdef TCP_KEEPIDLE 
    SetARecordField(tmp, RNamName("TCP_KEEPIDLE"), INTOBJ_INT((Int) TCP_KEEPIDLE));
#endif
#ifdef TCP_KEEPINTVL 
    SetARecordField(tmp, RNamName("TCP_KEEPINTVL"), INTOBJ_INT((Int) TCP_KEEPINTVL));
#endif
#ifdef TCP_LINGER2 
    SetARecordField(tmp, RNamName("TCP_LINGER2"), INTOBJ_INT((Int) TCP_LINGER2));
#endif
#ifdef TCP_MAXSEG 
    SetARecordField(tmp, RNamName("TCP_MAXSEG"), INTOBJ_INT((Int) TCP_MAXSEG));
#endif
#ifdef TCP_NODELAY 
    SetARecordField(tmp, RNamName("TCP_NODELAY"), INTOBJ_INT((Int) TCP_NODELAY));
#endif
#ifdef TCP_QUICKACK 
    SetARecordField(tmp, RNamName("TCP_QUICKACK"), INTOBJ_INT((Int) TCP_QUICKACK));
#endif
#ifdef TCP_SYNCNT 
    SetARecordField(tmp, RNamName("TCP_SYNCNT"), INTOBJ_INT((Int) TCP_SYNCNT));
#endif
#ifdef TCP_WINDOW_CLAMP 
    SetARecordField(tmp,RNamName("TCP_WINDOW_CLAMP"),INTOBJ_INT((Int)TCP_WINDOW_CLAMP));
#endif
#ifdef ICMP_FILTER 
    SetARecordField(tmp, RNamName("ICMP_FILTER"), INTOBJ_INT((Int) ICMP_FILTER));
#endif
    
    /* Constants for messages for recv and send: */
#ifdef MSG_OOB 
    SetARecordField(tmp, RNamName("MSG_OOB"), INTOBJ_INT((Int) MSG_OOB));
#endif
#ifdef MSG_PEEK 
    SetARecordField(tmp, RNamName("MSG_PEEK"), INTOBJ_INT((Int) MSG_PEEK));
#endif
#ifdef MSG_WAITALL 
    SetARecordField(tmp, RNamName("MSG_WAITALL"), INTOBJ_INT((Int) MSG_WAITALL));
#endif
#ifdef MSG_TRUNC 
    SetARecordField(tmp, RNamName("MSG_TRUNC"), INTOBJ_INT((Int) MSG_TRUNC));
#endif
#ifdef MSG_ERRQUEUE 
    SetARecordField(tmp, RNamName("MSG_ERRQUEUE"), INTOBJ_INT((Int) MSG_ERRQUEUE));
#endif
#ifdef MSG_EOR 
    SetARecordField(tmp, RNamName("MSG_EOR"), INTOBJ_INT((Int) MSG_EOR));
#endif
#ifdef MSG_CTRUNC 
    SetARecordField(tmp, RNamName("MSG_CTRUNC"), INTOBJ_INT((Int) MSG_CTRUNC));
#endif
#ifdef MSG_OOB 
    SetARecordField(tmp, RNamName("MSG_OOB"), INTOBJ_INT((Int) MSG_OOB));
#endif
#ifdef MSG_ERRQUEUE 
    SetARecordField(tmp, RNamName("MSG_ERRQUEUE"), INTOBJ_INT((Int) MSG_ERRQUEUE));
#endif
#ifdef MSG_DONTWAIT 
    SetARecordField(tmp, RNamName("MSG_DONTWAIT"), INTOBJ_INT((Int) MSG_DONTWAIT));
#endif
#ifdef PIPE_BUF
    SetARecordField(tmp, RNamName("PIPE_BUF"), INTOBJ_INT((Int) PIPE_BUF));
#endif
#ifdef F_DUPFD
    SetARecordField(tmp, RNamName("F_DUPFD"), INTOBJ_INT((Int) F_DUPFD));
#endif
#ifdef F_GETFD
    SetARecordField(tmp, RNamName("F_GETFD"), INTOBJ_INT((Int) F_GETFD));
#endif
#ifdef F_SETFD
    SetARecordField(tmp, RNamName("F_SETFD"), INTOBJ_INT((Int) F_SETFD));
#endif
#ifdef FD_CLOEXEC
    SetARecordField(tmp, RNamName("FD_CLOEXEC"), INTOBJ_INT((Int) FD_CLOEXEC));
#endif
#ifdef F_GETFL
    SetARecordField(tmp, RNamName("F_GETFL"), INTOBJ_INT((Int) F_GETFL));
#endif
#ifdef F_SETFL
    SetARecordField(tmp, RNamName("F_SETFL"), INTOBJ_INT((Int) F_SETFL));
#endif
#ifdef F_GETOWN
    SetARecordField(tmp, RNamName("F_GETOWN"), INTOBJ_INT((Int) F_GETOWN));
#endif
#ifdef F_SETOWN
    SetARecordField(tmp, RNamName("F_SETOWN"), INTOBJ_INT((Int) F_SETOWN));
#endif
#ifdef F_GETSIG
    SetARecordField(tmp, RNamName("F_GETSIG"), INTOBJ_INT((Int) F_GETSIG));
#endif
#ifdef F_SETSIG
    SetARecordField(tmp, RNamName("F_SETSIG"), INTOBJ_INT((Int) F_SETSIG));
#endif
#ifdef F_GETLEASE
    SetARecordField(tmp, RNamName("F_GETLEASE"), INTOBJ_INT((Int) F_GETLEASE));
#endif
#ifdef F_SETLEASE
    SetARecordField(tmp, RNamName("F_SETLEASE"), INTOBJ_INT((Int) F_SETLEASE));
#endif
#ifdef F_RDLCK
    SetARecordField(tmp, RNamName("F_RDLCK"), INTOBJ_INT((Int) F_RDLCK));
#endif
#ifdef F_WRLCK
    SetARecordField(tmp, RNamName("F_WRLCK"), INTOBJ_INT((Int) F_WRLCK));
#endif
#ifdef F_UNLCK
    SetARecordField(tmp, RNamName("F_UNLCK"), INTOBJ_INT((Int) F_UNLCK));
#endif
#ifdef __GNUC__
    SetARecordField(tmp, RNamName("__GNUC__"), INTOBJ_INT((Int) __GNUC__));
#endif
#ifdef __GNUC_MINOR__
    SetARecordField(tmp, RNamName("__GNUC_MINOR__"), INTOBJ_INT((Int) __GNUC_MINOR__));
#endif
#ifdef SIGHUP
    SetARecordField(tmp, RNamName("SIGHUP"), INTOBJ_INT((Int) SIGHUP));
#endif
#ifdef SIGINT
    SetARecordField(tmp, RNamName("SIGINT"), INTOBJ_INT((Int) SIGINT));
#endif
#ifdef SIGQUIT
    SetARecordField(tmp, RNamName("SIGQUIT"), INTOBJ_INT((Int) SIGQUIT));
#endif
#ifdef SIGILL
    SetARecordField(tmp, RNamName("SIGILL"), INTOBJ_INT((Int) SIGILL));
#endif
#ifdef SIGABRT
    SetARecordField(tmp, RNamName("SIGABRT"), INTOBJ_INT((Int) SIGABRT));
#endif
#ifdef SIGFPE
    SetARecordField(tmp, RNamName("SIGFPE"), INTOBJ_INT((Int) SIGFPE));
#endif
#ifdef SIGKILL
    SetARecordField(tmp, RNamName("SIGKILL"), INTOBJ_INT((Int) SIGKILL));
#endif
#ifdef SIGSEGV
    SetARecordField(tmp, RNamName("SIGSEGV"), INTOBJ_INT((Int) SIGSEGV));
#endif
#ifdef SIGPIPE
    SetARecordField(tmp, RNamName("SIGPIPE"), INTOBJ_INT((Int) SIGPIPE));
#endif
#ifdef SIGALRM
    SetARecordField(tmp, RNamName("SIGALRM"), INTOBJ_INT((Int) SIGALRM));
#endif
#ifdef SIGTERM
    SetARecordField(tmp, RNamName("SIGTERM"), INTOBJ_INT((Int) SIGTERM));
#endif
#ifdef SIGUSR1
    SetARecordField(tmp, RNamName("SIGUSR1"), INTOBJ_INT((Int) SIGUSR1));
#endif
#ifdef SIGUSR2
    SetARecordField(tmp, RNamName("SIGUSR2"), INTOBJ_INT((Int) SIGUSR2));
#endif
#ifdef SIGCHLD
    SetARecordField(tmp, RNamName("SIGCHLD"), INTOBJ_INT((Int) SIGCHLD));
#endif
#ifdef SIGCONT
    SetARecordField(tmp, RNamName("SIGCONT"), INTOBJ_INT((Int) SIGCONT));
#endif
#ifdef SIGSTOP
    SetARecordField(tmp, RNamName("SIGSTOP"), INTOBJ_INT((Int) SIGSTOP));
#endif
#ifdef SIGTSTP
    SetARecordField(tmp, RNamName("SIGTSTP"), INTOBJ_INT((Int) SIGTSTP));
#endif
#ifdef SIGTTIN
    SetARecordField(tmp, RNamName("SIGTTIN"), INTOBJ_INT((Int) SIGTTIN));
#endif
#ifdef SIGTTOU
    SetARecordField(tmp, RNamName("SIGTTOU"), INTOBJ_INT((Int) SIGTTOU));
#endif
#ifdef SIGBUS
    SetARecordField(tmp, RNamName("SIGBUS"), INTOBJ_INT((Int) SIGBUS));
#endif
#ifdef SIGPOLL
    SetARecordField(tmp, RNamName("SIGPOLL"), INTOBJ_INT((Int) SIGPOLL));
#endif
#ifdef SIGPROF
    SetARecordField(tmp, RNamName("SIGPROF"), INTOBJ_INT((Int) SIGPROF));
#endif
#ifdef SIGSYS
    SetARecordField(tmp, RNamName("SIGSYS"), INTOBJ_INT((Int) SIGSYS));
#endif
#ifdef SIGTRAP
    SetARecordField(tmp, RNamName("SIGTRAP"), INTOBJ_INT((Int) SIGTRAP));
#endif
#ifdef SIGURG
    SetARecordField(tmp, RNamName("SIGURG"), INTOBJ_INT((Int) SIGURG));
#endif
#ifdef SIGVTALRM
    SetARecordField(tmp, RNamName("SIGVTALRM"), INTOBJ_INT((Int) SIGVTALRM));
#endif
#ifdef SIGXCPU
    SetARecordField(tmp, RNamName("SIGXCPU"), INTOBJ_INT((Int) SIGXCPU));
#endif
#ifdef SIGXFSZ
    SetARecordField(tmp, RNamName("SIGXFSZ"), INTOBJ_INT((Int) SIGXFSZ));
#endif
#ifdef SIGIOT
    SetARecordField(tmp, RNamName("SIGIOT"), INTOBJ_INT((Int) SIGIOT));
#endif
#ifdef SIGEMT
    SetARecordField(tmp, RNamName("SIGEMT"), INTOBJ_INT((Int) SIGEMT));
#endif
#ifdef SIGSTKFLT
    SetARecordField(tmp, RNamName("SIGSTKFLT"), INTOBJ_INT((Int) SIGSTKFLT));
#endif
#ifdef SIGIO
    SetARecordField(tmp, RNamName("SIGIO"), INTOBJ_INT((Int) SIGIO));
#endif
#ifdef SIGCLD
    SetARecordField(tmp, RNamName("SIGCLD"), INTOBJ_INT((Int) SIGCLD));
#endif
#ifdef SIGPWR
    SetARecordField(tmp, RNamName("SIGPWR"), INTOBJ_INT((Int) SIGPWR));
#endif
#ifdef SIGINFO
    SetARecordField(tmp, RNamName("SIGINFO"), INTOBJ_INT((Int) SIGINFO));
#endif
#ifdef SIGLOST
    SetARecordField(tmp, RNamName("SIGLOST"), INTOBJ_INT((Int) SIGLOST));
#endif
#ifdef SIGWINCH
    SetARecordField(tmp, RNamName("SIGWINCH"), INTOBJ_INT((Int) SIGWINCH));
#endif
#ifdef SIGUNUSED
    SetARecordField(tmp, RNamName("SIGUNUSED"), INTOBJ_INT((Int) SIGUNUSED));
#endif

    gvar = GVarName("IO");
    MakeReadWriteGVar( gvar);
    AssGVar( gvar, tmp );
    MakeReadOnlyGVar(gvar);
    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
#ifdef IOSTATIC
 /* type        = */ MODULE_STATIC,
#else
 /* type        = */ MODULE_DYNAMIC,
#endif
 /* name        = */ "io",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0
};

#ifndef IOSTATIC
StructInitInfo * Init__Dynamic ( void )
{
  module.revision_c = Revision_io_c;
  return &module;
}
#endif

StructInitInfo * Init__io ( void )
{
  module.revision_c = Revision_io_c;
  return &module;
}


/*
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
