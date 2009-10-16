/* This is the private portion of the MPI include file */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h> /* Needed with fcntl.h for Sys V */
#include <errno.h>
#include <sys/wait.h>
#include <signal.h>
#include <assert.h>

/* Want to disguise `"' because ANSI C won't do substitution insides quotes.
 * #ifdef __STDC__
 *  #define quote(arg) #arg
 * #else
 *   #define quote(arg) "arg"
 * #endif
 * THEN USE:    perror(quote(function))  */
#define ANSIC ( -1 < (unsigned char) 1 )
#define PERROR(function) if (ANSIC) \
	  {fprintf(stderr,__FILE__ "(line %d): ", __LINE__); perror(#function);} \
          else perror("function")
/*
#if ANSIC
#define PERROR(function) fprintf(stderr,__FILE__ "(line %d): ", __LINE__); perror(#function)
#else
#define PERROR(function) perror("function")
#endif
*/

#if 0
/* Plain version:  nothing fancy. */
  #define CALL_CHK(function,args) \
    if ( (function args) == -1 ) \
      if ( (errno != EINTR) && (errno != ECHILD) ) \
        { PERROR(function); exit(1); }
#endif

/* Re-write this based on select_block_sigs() in sendrecv.c */
#define CALL_CHK(function,args) \
  while (1) { \
    /* On EINTR (interrupted by signal), just try again */ \
    /* On ECHILD (error no child in wait), ignore error */ \
    /* On EADDRINUSE (bind <= stale address), caller fixes and tries again */ \
    errno = 0; \
    if ( (function args) == -1 ) { \
      /* Remove first if, and fall through, when have confidence it works */ \
      if ( (errno == EADDRINUSE) ) { \
        printf("errno: %d; ",errno); \
        PERROR(function); errno = EADDRINUSE; break; } \
      if ( (errno == ECHILD) || (errno == EADDRINUSE) ) break; \
      if ( errno == EINTR ) continue; \
      PERROR(function); exit(1); \
    } \
    else break; /* successful system call */ \
  }

extern int MPINU_num_slaves;
extern int MPINU_myrank;
extern int MPINU_coll_comm_flag;
extern int MPINU_my_list_sd;
extern fd_set MPINU_fdset;
extern int MPINU_max_sd;
extern int MPINU_is_spawn2;
extern int MPINU_is_initialized;

#define MPI_COLL_COMM_TAG -2

#define MPI_MAX_PROCESSOR_NAME 256
#define PG_ARRAY_SIZE  1000
#define PROCGROUP_LEN 10000
#define PG_NOSOCKET -1 /* must not coincide with socket descriptor int */

struct pg_struct {
  char *processor;
  char *num_threads;
  char *process;
  int sd; /* socket descriptor */
  int MPINU_max_sd; /* max value of socket descriptor -- used with select() */
  struct sockaddr_in listener_addr; /* listener port to create new sockets */
}; 

/* index into MPINU_pg_array is same as process rank in MPI_Comm_world */
extern struct pg_struct MPINU_pg_array[];

/* INT must be 32-bit quantity.  Re-define to long if necessary. */
#if (1 << 31) == 0
#define INT long
#else
#define INT int
#endif

struct init_msg { /* Initial message from master to slave */
  INT len; /* For consistency check;  This should equal sizeof(init_msg) */
  INT rank;
  INT num_slaves;
};

struct msg_hdr {
  INT tag;
  INT size;
  INT rank;
};

#if 0
#define SETSOCKOPT(sd) \
  { int i = 1; \
    struct timeval timeout; \
    timeout.tv_sec = 2; \
    timeout.tv_usec = 0; \
    CALL_CHK( setsockopt, (sd, SOL_SOCKET, SO_KEEPALIVE, \
                           (void *)&i, sizeof(i)) ); \
    CALL_CHK( setsockopt, (sd, SOL_SOCKET, SO_RCVTIMEO, \
                           (void *)&timeout, sizeof(timeout)) ); \
  }
#else
#define SETSOCKOPT(sd) \
  { int i = 1; \
    CALL_CHK( setsockopt, (sd, SOL_SOCKET, SO_KEEPALIVE, \
                           (void *)&i, sizeof(i)) ); \
  }
#endif

/* MPI_TMP_NAMELEN used here, but not in *.c source */
/* This is ugly.  It allocates data in each C file in which it's included. */
static int MPI_TMP_NAMELEN = 0;
static struct sockaddr MPI_TMP_NAME;
#define IS_SOCKET_CONNECTED(socket) \
    ( 1 + getpeername( socket, &MPI_TMP_NAME, &MPI_TMP_NAMELEN ) )

void MPINU_mpi_master();
void MPINU_mpi_slave();
int MPINU_parse();
int MPINU_new_listener();
int MPINU_set_and_exec_cmds();
