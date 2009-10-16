




















/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/


#include <stdio.h>
#ifndef __CEXTRACT__
/* some protos here are misleading for cextract */
#include <errno.h>
#include <sys/types.h>
#ifdef RS6000
#include <sys/select.h>
#endif

#ifndef WIN32
#include <sys/time.h>
#include <sys/param.h>
#include <sys/un.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#else /* WIN32 */
#include <winsock.h>
#define EADDRINUSE WSAEADDRINUSE
#define MAXHOSTNAMELEN 255
#define MAXPATHLEN 255
struct sockaddr_un {
  unsigned short sun_family;	/* AF_UNIX */
  char sun_path[MAXPATHLEN];	/* pathname */
};
#endif /* WIN32 */
#endif /* __CEXTRACT__ */

#include "OM.h"
#include "OMconn.h"
#include "OMconnP.h"



/* The default encoding used.
 * Should be the most efficient one for network transmission, of course...
 */
#define DEFAULT_ENCODING OMencodingBinary


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/* To avoid the blocking accept, we use select with a timeout (in millisecond)
 * returns 0 if a timeout occurs or "select" returns an error (this is the 
 * case if it is interrupted...).
 */
static int OMwaitOn(int fd, int ms);
/* "GetHostAddress (buf)" returns the internet address of 
 * the host we are running on as a string in the x.x.x.x form in "buf".
 * "buf" should be thus at least 16 characters long.
 * Inability to find this address is fatal. 
 */
static void OMgetLocalHostAddress(char *buf);
/* used as the "redirect thing" for a rsh */
/* ".OM.log" should be user-configurable... */
static OMstatus OMlaunchEnvRemote(OMconn conn, char *machine, char *cmd, char *env);
/* getenv sur temp plutot qoe /top en fir */
static OMstatus ONlaunchEnvLocal(OMconn conn, char *cmd, char *env);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#ifdef WIN32

#define getErrno() WSAGetLastError()
#define EADDRINUSE WSAEADDRINUSE

/* used for windows socket initialisation */
WSADATA wsadata;
OMbool winInitDone = OMfalse;

Lib void
winInit(void)
{
  if (!winInitDone) {
    /* Initialize Winsock (1.1) */
    if (WSAStartup(MAKEWORD(1, 1), &wsadata) != 0)
      OMfatalInternal(OMerrorSys, "Cannot initialyze win socket 1.1.");
    winInitDone = OMtrue;
  }
}
#else
/* no init needed for unix */
#define winInit()
#define getErrno() errno
#endif


/*
 */
World OMconn
OMmakeConn(int timeout)
{
  OMconn res;
  static connNum = 0;

  res = OMmallocWarn(sizeof(OMconnStruct), "Cannot allocate new connection (%d).", connNum);
  connNum++;
  res->timeout = timeout;
  return res;
}

World OMdev
OMconnIn(OMconn conn)
{
  return conn->in;
}

World OMdev
OMconnOut(OMconn conn)
{
  return conn->out;
}

World OMstatus
OMconnClose(OMconn conn)
{
  return OMsuccess;
}

World OMstatus
OMbindUnix(OMconn conn, char *file)
{
  OMdev indev, outdev;
  int nsd, ansd;
  int dummy;
  struct sockaddr_un nad;
  struct sockaddr_un target;

  winInit();
  nsd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (nsd < 0) {
    conn->error = OMerrorSys;
    return OMfailed;
  }
  /* fill the address */
  ZERO(nad);
  nad.sun_family = AF_UNIX;
  strcpy(nad.sun_path, file);

  /* bind "nsd" at the UNIX-domain address. "+2" seems necessary... */
  if (bind(nsd, (struct sockaddr *) &nad, strlen(nad.sun_path) + 2) != 0) {
    if (getErrno() == EADDRINUSE) {
      conn->error = OMaddrInUse;
      return OMaddrInUse;
    }
    else {
      conn->error = OMerrorSys;
      return OMfailed;
    }
  }
  listen(nsd, 1);
  /* now, we can accept */
  dummy = sizeof(target);
  ansd = accept(nsd, (struct sockaddr *) &target, &dummy);
  if (ansd < 0) {
    conn->error = OMerrorSys;
    return OMfailed;
  }
  /* don't need it anymore */
  close(nsd);

  indev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  outdev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  conn->in = indev;
  conn->out = outdev;

  return OMsuccess;

}

World OMstatus
OMconnUnix(OMconn conn, char *socketpath)
{
  OMdev indev, outdev;
  int nsd;
  struct sockaddr_un nad;

  winInit();
  nsd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (nsd < 0) {
    conn->error = OMerrorSys;
    return OMfailed;
  }

  ZERO(nad);
  nad.sun_family = AF_UNIX;

  strcpy(nad.sun_path, socketpath);
  if (connect(nsd, (struct sockaddr *) &nad, sizeof nad) < 0) {
    return OMfailed;
  }

  indev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(nsd));
  outdev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(nsd));
  conn->in = indev;
  conn->out = outdev;

  return OMsuccess;
}

World OMstatus
OMconnTCP(OMconn conn, char *machine, int port)
{
  OMdev indev, outdev;
  int nsd;
  struct sockaddr_in nad;

  winInit();
  nsd = socket(AF_INET, SOCK_STREAM, 0);

  ZERO(nad);
  nad.sin_family = AF_INET;
  nad.sin_port = htons((unsigned short) port);
  {
    unsigned long addr;
    /* if we are lucky, the machine is XXX.XXX.XXX.XXX ... */
    if ((addr = inet_addr(machine)) == -1) {
      struct hostent *host;

      if ((host = gethostbyname(machine)) == (struct hostent *) NULL) {
	return OMconnectFailed;
      }
      memcpy((char *) &nad.sin_addr, host->h_addr, host->h_length);
    }
    else {
      memcpy((char *) &nad.sin_addr, (char *) &addr, sizeof addr);
    }
  }

  if (connect(nsd, (struct sockaddr *) &nad, sizeof nad) < 0) {
    return OMconnectFailed;
  }

  indev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(nsd));
  outdev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(nsd));
  conn->in = indev;
  conn->out = outdev;

  return OMsuccess;
}


World OMstatus
OMbindTCP(OMconn conn, int port)
{
  OMdev indev, outdev;
  int nsd, ansd, dummy;
  struct sockaddr_in nad;
  struct sockaddr_un target;

  winInit();
  nsd = socket(AF_INET, SOCK_STREAM, 0);

  ZERO(nad);
  nad.sin_family = AF_INET;
  nad.sin_addr.s_addr = INADDR_ANY;
  nad.sin_port = htons((unsigned short) port);

  if (bind(nsd, (struct sockaddr *) &nad, sizeof nad) != 0) {
    close(nsd);
    if (getErrno() == EADDRINUSE) {
      conn->error = OMaddrInUse;
      return OMaddrInUse;
    }
    else {
      conn->error = OMerrorSys;
      return OMfailed;
    }
  }

  listen(nsd, 1);
  dummy = sizeof(target);
  ansd = accept(nsd, (struct sockaddr *) &target, &dummy);
  close(nsd);

  indev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  outdev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  conn->in = indev;
  conn->out = outdev;

  return OMsuccess;
}


/* To avoid the blocking accept, we use select with a timeout (in millisecond)
 * returns 0 if a timeout occurs or "select" returns an error (this is the 
 * case if it is interrupted...).
 */
Module int
OMwaitOn(int fd, int ms)
{
  int r;
  fd_set readfd, writefd, excepfd;
  struct timeval time;

  time.tv_sec = (long) ms / 1000;
  time.tv_usec = (long) (ms % 1000) * 1000;
  FD_ZERO(&readfd);
  FD_ZERO(&writefd);
  FD_ZERO(&excepfd);
  FD_SET(fd, &readfd);
#ifdef HP
  if ((r = select(fd + 1, (int *) (&readfd), (int *) (&writefd), (int *) (&excepfd), &time)) < 0) {
    /* error */
    return 0;
  }
#else
  if ((r = select(fd + 1, &readfd, &writefd, &excepfd, &time)) < 0) {
    /* error */
    return 0;
  }
#endif
  else {
    if (r == 0)			/* timeout */
      return 0;
    else
      return 1;
  }
}

/* "GetHostAddress (buf)" returns the internet address of 
 * the host we are running on as a string in the x.x.x.x form in "buf".
 * "buf" should be thus at least 16 characters long.
 * Inability to find this address is fatal. 
 */
Module void
OMgetLocalHostAddress(char *buf)
{
  char hostname[MAXHOSTNAMELEN + 1];
  struct hostent *hostent;

  buf[0] = '\0';
  if (gethostname(hostname, MAXHOSTNAMELEN + 1) < 0) {
    OMfatalInternal(OMerrorSys, "Cannot find local host name.");
  }

  if ((hostent = gethostbyname(hostname)) == (struct hostent *) 0) {
    OMfatalInternal(OMerrorSys, "Cannot find local host address.", stderr);
  }
  else {
    unsigned long *paddr, horder;
    paddr = (unsigned long *) *hostent->h_addr_list;
    horder = ntohl(*paddr);
    sprintf(buf, "%lu.%lu.%lu.%lu", horder >> 24, (horder >> 16) & 0xff,
	    (horder >> 8) & 0xff, horder & 0xff);
  }
}

#define MAXCMDLEN 1024
/* used as the "redirect thing" for a rsh */
/* ".OM.log" should be user-configurable... */
#define REDIRECT "2>&1 3>&1 4>&1 5>&1 6>&1 7>&1 8>&1 9>&1 3>&- 4>&- 5>&- 6>&- 7>&- 8>&- 9>&- < /dev/null >.OM.log"
#define MAXPORT 9000
#define RSH "rsh -n"

Module OMstatus
OMlaunchEnvRemote(OMconn conn, char *machine, char *cmd, char *env)
{
  OMdev indev, outdev;
  int nsd, dummy, ansd;
  struct sockaddr_in nad, target;
  char local[MAXHOSTNAMELEN + 1];
  int port;
  char rshcmd[MAXCMDLEN];
  int i;

  winInit();
  nsd = socket(AF_INET, SOCK_STREAM, 0);
  ZERO(nad);
  nad.sin_family = AF_INET;
  nad.sin_addr.s_addr = INADDR_ANY;
  for (i = IPPORT_RESERVED + 1; i < MAXPORT; i++) {
    nad.sin_port = htons((unsigned short) i);
    if (bind(nsd, (struct sockaddr *) &nad, sizeof nad) == 0) {
      break;
    }
    else {
      /* when "bind" failed, we obtain a "fresh" socket to avoid 
         strange problems... */
      close(nsd);
      nsd = socket(AF_INET, SOCK_STREAM, 0);
    }
  }
  if (i < MAXPORT)
    port = i;
  else
    return OMfailed;		/* we where unable to find a free local IP port. */

  listen(nsd, 1);

  /* get our host IP address or IP name */
  OMgetLocalHostAddress(local);

  /* Now, we can launch the service */
  /* this computation is wrong... */
  if (MAXCMDLEN <
      (strlen(RSH) + strlen(machine) +
       ((env == (char *) 0) ? 0 : strlen(env)) +
       strlen(cmd) + 10 + strlen(local) +
       strlen(REDIRECT))) {
    return OMfailed;
  }
  if (env != (char *) 0)
    sprintf(rshcmd,
    "%s %s OM_CALLER_MACHINE=%s OM_CALLER_PORT=%d %s 'sh -c \" %s %s &\"' &",
	    RSH, machine, local, port, env, cmd, REDIRECT);
  else
    sprintf(rshcmd,
      "%s %s OM_CALLER_MACHINE=%s OM_CALLER_PORT=%d 'sh -c \" %s %s &\"' &",
	    RSH, machine, local, port, cmd, REDIRECT);

  printf("OMlaunchEnvRemote: %s\n", OMlaunchEnvRemote);
  system(rshcmd);

  if (!OMwaitOn(nsd, conn->timeout))
    return OMfailed;

  dummy = sizeof(target);
  ansd = accept(nsd, (struct sockaddr *) &target, &dummy);
  close(nsd);

  indev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  outdev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  conn->in = indev;
  conn->out = outdev;

  return OMsuccess;
}

/* getenv sur temp plutot qoe /top en fir */
#define OM_UNIX_PATH "/tmp/.omsock"
#define MAXNB 3000

Module OMstatus
ONlaunchEnvLocal(OMconn conn, char *cmd, char *env)
{
  OMdev indev, outdev;
  int nsd, ansd, dummy;
  struct sockaddr_un nad, target;
  char basename[MAXPATHLEN];
  char cmdline[MAXCMDLEN];
  int i, len;

  winInit();
  nsd = socket(AF_UNIX, SOCK_STREAM, 0);

  ZERO(nad);
  nad.sun_family = AF_UNIX;
  /* construct the basename of the UNIX socket */
  /* FIXME */
#ifndef WIN32
  sprintf(basename, "%s%d", OM_UNIX_PATH, (int) getuid());
#else
  {
    char tmp[255];

    len = sizeof(tmp);
    if (!GetUserName(tmp, &len)) {
      sprintf(tmp, "winuser");
    }
    sprintf(basename, "%s%s", OM_UNIX_PATH, tmp);
  }
#endif

  strcpy(nad.sun_path, basename);

  /* try to bind */
  len = strlen(basename);
  for (i = 0; i < MAXNB; i++) {
    sprintf(nad.sun_path + len, "_%d", i);
    /* the +2 is still a mystery for me... */
    if (bind(nsd, (struct sockaddr *) &nad, strlen(nad.sun_path) + 2) == 0) {
      break;
    }
    else {
      close(nsd);
      nsd = socket(AF_UNIX, SOCK_STREAM, 0);
      /* Check... */
    }
  }
  /* store the socket name to pass to the server */
  if (i < MAXNB)
    sprintf(basename + len, "_%d", i);
  else				/* FIXME */
    ;

  listen(nsd, 1);
  /* Now, we can launch the service */
  /* FIXME redirections ? */
  sprintf(cmdline, "OM_CALLER_UNIX_SOCKET=%s %s &", basename, cmd);
  system(cmdline);
  /* and accept connections ... */
  dummy = sizeof(target);
  ansd = accept(nsd, (struct sockaddr *) &target, &dummy);

  indev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  outdev = OMmakeDevice(DEFAULT_ENCODING, OMmakeIOFd(ansd));
  conn->in = indev;
  conn->out = outdev;

  return OMsuccess;
}


World OMstatus
OMlaunchEnv(OMconn conn, char *machine, char *cmd, char *env)
{
  if (EQSTRING(machine, "localhost")) {
    return ONlaunchEnvLocal(conn, cmd, env);
  }
  else {
    return OMlaunchEnvRemote(conn, machine, cmd, env);
  }
}

World OMstatus
OMlaunch(OMconn conn, char *machine, char *cmd)
{
  return OMlaunchEnv(conn, machine, cmd, (char *) 0);
}

World OMstatus
OMserveClient(OMconn conn)
{
  char *sf, *mach, *port;
  int portnum;

  /* First, get the address of the client that calls us. This address is 
     passed as environment variables */
  if ((sf = getenv("OM_CALLER_UNIX_SOCKET")) != (char *) 0) {
    /* unix domain (local) connection */
    return OMconnUnix(conn, sf);

  }
  else {
    if (((mach = getenv("OM_CALLER_MACHINE")) == (char *) 0) ||
	((port = getenv("OM_CALLER_PORT")) == (char *) 0)) {
      /* something obviously wrong... */
      return OMfailed;
    }
    /* convert "port" to a numeric value */
    portnum = atoi(port);
    return OMconnTCP(conn, mach, portnum);
  }
}
