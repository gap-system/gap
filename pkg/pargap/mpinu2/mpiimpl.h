/* This is the private portion of the MPI include file */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>  /* Needed for struct timeval for select */
#include <time.h>    /* Needed for struct timespec for nanosleep */
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h> /* Needed with fcntl.h for Sys V */
#include <errno.h>
#include <sys/wait.h>
#include <signal.h>
#include <assert.h>
#include <ctype.h>


// Default is HAVE_PTHREAD.  Need to   #define HAVE_PTHREAD 0   to disable
#ifndef HAVE_PTHREAD
# define HAVE_PTHREAD 1
#endif

#if HAVE_PTHREAD
# include <pthread.h>
// # include <semaphore.h> /* See note in BUG for why this isn't used. */
#     include "sem-pthread.h"
#else
# define pthread_mutex_t int /* any pthread_mutex_t won't be used anyway. */
# define PTHREAD_MUTEX_INITIALIZER 0
# define pthread_mutex_lock(x) 0 /* success return value */
# define pthread_mutex_unlock(x) 0 /* success return value */
# define sem_t int /* any sem_t won't be used anyway. */
# define sem_init(x,y,z) 0 /* success return value */
# define sem_wait(x) 0 /* success return value */
# define sem_post(x) 0 /* success return value */
#endif

/* Want to disguise `"' because ANSI C won't do substitution inside quotes.
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
#define PERROR(function) fprintf(stderr,__FILE__ "(line %d): ", __LINE__); \
			 perror(#function)
#else
#define PERROR(function) perror("function")
#endif
*/

/* We use assert_perror with system calls.  Never set NDEBUG. */
#ifdef NDEBUG
  "NDEBUG WAS SET.  IT SHOULD NOT BE SET."
#endif
#ifndef assert_perror
# ifdef NDEBUG
#  define assert_perror(x) (x)
# else
#  define assert_perror(x) \
     { if ( (long int)(x) == 0L ) { \
       char str[1000]; \
       sprintf( str, "%s:%d", __FILE__, __LINE__ ); \
       perror( str ); \
       fprintf( stderr, "  " ); \
       assert( #x == NULL ); /* Force assert to trigger */ } }
# endif
#endif

/* Re-write this based on select_block_sigs() in sendrecv.c */
#define CALL_CHK(function,args) \
  while (1) { \
    /* On EINTR (interrupted by signal), just try again */ \
    /* On EAGAIN, kernel wants us to just try again */ \
    /* On ECHILD (error no child in wait), ignore error */ \
    /* On EADDRINUSE (bind <= stale address), caller fixes and tries again */ \
    /* On ECONNRESET || EPIPE (broken connection), caller can return MPI_FAIL */ \
    errno = 0; \
    if ( (function args) == -1 ) { \
      /* Remove first if, and fall through, when have confidence it works */ \
      /* printf("errno: %d; ",errno); */ \
      if ( (errno == EADDRINUSE) ) { \
        PERROR(function); errno = EADDRINUSE; break; } \
      if ( (errno == ECHILD) || (errno == EADDRINUSE) ) break; \
      if ((errno == ECONNRESET) || (errno == EPIPE))  break; \
      if ( errno == EINTR ) continue; \
      if ( errno == EAGAIN ) continue; \
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

void MPINU_mpi_master();
void MPINU_mpi_slave();
int MPINU_parse();
int MPINU_new_listener();
int MPINU_set_and_exec_cmds();

void MPINU_send_thread_exit(void);

	/* from utils.c : */
int MPINU_rank_of_msg_avail_in_cache(int source, int tag);
ssize_t MPINU_recv_msg_hdr_with_cache(int s, int tag,
				      void *buf, size_t len, int flags);
ssize_t MPINU_recv_msg_body_with_cache(int source, void *buf, size_t len);
ssize_t MPINU_send_to_self_with_cache(int tag, void *buf,
		                      size_t len, int flags);
int MPINU_rank_from_socket(int s);
ssize_t MPINU_recvall(int s, void *buf, size_t len, int flags);
ssize_t MPINU_sendall(int s, void *buf, size_t len, int flags);
ssize_t MPINU_send_nonblock(int s, const void *buf, size_t len, int flags);
