 /**********************************************************************
  * MPINU				                               *
  * Copyright (c) 2004-2005 Gene Cooperman <gene@ccs.neu.edu>          *
  *                                                                    *
  * This library is free software; you can redistribute it and/or      *
  * modify it under the terms of the GNU Lesser General Public         *
  * License as published by the Free Software Foundation; either       *
  * version 2.1 of the License, or (at your option) any later version. *
  *                                                                    *
  * This library is distributed in the hope that it will be useful,    *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of     *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU   *
  * Lesser General Public License for more details.                    *
  *                                                                    *
  * You should have received a copy of the GNU Lesser General Public   *
  * License along with this library (see file COPYING); if not, write  *
  * to the Free Software Foundation, Inc., 59 Temple Place, Suite      *
  * 330, Boston, MA 02111-1307 USA, or contact Gene Cooperman          *
  * <gene@ccs.neu.edu>.                                                *
  **********************************************************************/

// TODO:  See MPI_Recv and thread-safe issue.

// MPI_Send calls MPINU_send_nonblock(), which in turn calls MPINU_sendall().
// MPI_Recv calls read_msg_hdr() followed by MPINU_recv_msg_body_with_cache()
//   MPINU_recv_msg_body_with_cache() is a wrapper for MPINU_recvall(), which
//                  is a wrapper for recv().
//   read_msg_hdr() calls read_msg_hdr_setup(), read_msg_hdr_select()
//                  read_msg_hdr_get_buf(), and read_msg_hdr_post_check().
//     read_msg_hdr_get_buf() calls MPINU_recv_msg_hdr_with_cache(), which is
//                    a wrapper for MPINU_recvall(), which is a wrapper
//                    for recv().
// NOTE: read_msg_hdr() sets source from MPI_ANY_SOURCE to actual source.
//       When this becomes thread-safe, read_msg_hdr could be asked to
//       try again, and so this will have to be fixed.

#include "mpi.h"
#include "mpiimpl.h"

/* When the NEW version has been run a lot, we will delete the
 * else branch (OLD). */
#define NEW /* Use recv_..._with_cache() */

/* These must correspond with MPI_XXX  in mpi.h */
static int datatype_size[] = {-1, sizeof(char), sizeof(unsigned char),
				sizeof(char),
			sizeof(short), sizeof(unsigned short), sizeof(int),
			sizeof(unsigned), sizeof(long), sizeof(unsigned long),
		        sizeof(float), sizeof(double),
			sizeof(long double), sizeof(long long), -1};
/* Included long double and long long for ANSI C version */

// ============================================================
// Utilities for checking if socket is dead, or declaring it dead

int  MPINU_socket_dead(int fd){
  int dest = 0;
  while( fd != MPINU_pg_array[dest].sd ) 
    dest++;
  MPINU_pg_array[dest].sd = PG_NOSOCKET;
  FD_CLR( fd, &MPINU_fdset);
  return 0;
}

static int IS_SOCKET_CONNECTED(int socket) {
  socklen_t mpi_tmp_namelen = 0;
  struct sockaddr mpi_tmp_name;
int retval = getpeername( socket, &mpi_tmp_name, &mpi_tmp_namelen ); 
if (retval == -1) {fprintf(stderr, "errno: %d: \n", errno); perror("getpeername");}
  return 1 + getpeername( socket, &mpi_tmp_name, &mpi_tmp_namelen );
}

// ============================================================
// list_accept_new_socket, list_connect_new_socket
// Each process has listener socket.  Any other process can call it
//  to set up the initial connection, or to create a new one if the
//  old one dies.

static void list_accept_new_socket(int list_sd)
{ struct sockaddr_in new_sin;
  int ns, source;
  socklen_t fromlen = sizeof(new_sin);
  char buf[sizeof(INT)];

#ifdef DEBUG
  printf("Rank(%d): accepting new socket\n", MPINU_myrank);fflush(stdout);
#endif
  CALL_CHK( ns = accept, (list_sd, (struct sockaddr *)&new_sin, &fromlen) );
  CALL_CHK( MPINU_recvall, (ns, buf, sizeof(INT), 0) );
  source = ntohl(*((INT *)buf));

  if ( source < 0 || source > MPINU_num_slaves )
    printf("list_accept_new_socket:  Bad sender rank received: %d\n", source);
  else {
#ifdef DEBUG
    printf("accepted socket (%d) from %d\n", ns, source);fflush(stdout);
#endif
    if ( MPINU_pg_array[source].sd != PG_NOSOCKET ) {
      FD_CLR( MPINU_pg_array[source].sd, &MPINU_fdset );
      CALL_CHK( close, (MPINU_pg_array[source].sd) );
    }
    MPINU_pg_array[source].sd = ns;
    FD_SET(ns, &MPINU_fdset);
    if ( ns > MPINU_max_sd )
      MPINU_max_sd = ns;
  }
}

static int list_connect_new_socket( int myrank, int dest_rank )
{ int sd;
  char buf[sizeof(long)];

#ifdef DEBUG
  printf("connecting new socket from %d to %d\n", myrank, dest_rank);fflush(stdout);
#endif
  *((INT *)buf) = htonl(myrank);
  CALL_CHK( sd = socket, (AF_INET, SOCK_STREAM, IPPROTO_TCP) );
  SETSOCKOPT(sd);
  while(-1 == connect(sd,
		  (struct sockaddr *)&MPINU_pg_array[dest_rank].listener_addr,
		  sizeof(struct sockaddr_in) ) ) {
    if ( errno == EALREADY || errno == EISCONN ) break;
    if ( errno != EINTR ) return( -1 ); /* return failure */
  }
  CALL_CHK( send, (sd, buf, sizeof(INT), 0) );

#ifdef DEBUG
  printf("connected new socket(%d) from %d to %d\n", sd, myrank, dest_rank);
  fflush(stdout);
#endif
  if ( MPINU_pg_array[dest_rank].sd != PG_NOSOCKET ) {
    FD_CLR( MPINU_pg_array[dest_rank].sd, &MPINU_fdset );
    for (errno = 0; errno == EINTR; )
      close(MPINU_pg_array[dest_rank].sd);
    if (errno > 0) perror("close");
  }
  MPINU_pg_array[dest_rank].sd = sd;
  FD_SET(sd, &MPINU_fdset);
  if ( sd > MPINU_max_sd )
    MPINU_max_sd = sd;
  return( 0 );
}

/* ============================================================ */
/* This blocks certain signals while inside select()	        */
/* Note that a signal in the middle of a system call that is    */
/*   caught and returns, may either restart the signal or else  */
/*   exit the system call.  In particular, SIGINT appears to    */
/*   cause select to return with some of readfds being set.     */
/* Note also that recv() is called only after read_msg_hdr()    */
/*   guarantees that a message is available, or else after a    */
/*   select() inside read_msg_hdr() that guarantees a message   */
/*   is available.  So, recv() should never block.		*/

/* When this works, eliminate re-start after EINTR in mpiimpl.h */
/* SIGINT may have user-installed signal handler.  Call it after
 *   catching the signal.  If we're still here after that, go
 *   go back and re-start the system call.  This can be done
 *   generically with a single MPINU signal handler, since it
 *   can check what signal it caught.  But we must first save all
 *   old signal handlers in an array, to raise them or restore them
 *   later.
 */
/* When this works, do the same for SIGCONT, SIGSTOP, SIGTSTP (^Z)
 *  SIGPIPE ("broken pipe" => broken socket), if those have other
 *  signal handlers that should be called;
 * I've been told that SO_KEEPALIVE causes a SIGPIPE if no
 *  activity within a certain time
 */

typedef void (*sighandler_t)(int);
static int IsSIGINT;
static void null_handler(int signum) {
  IsSIGINT = 1;
}

/* TEMPORARY FOR DEBUGGING */
static void *curr_signal()
{ struct sigaction action;
  sigaction( SIGINT, NULL, &action );
  return (void *)action.sa_handler;
}

/* Under POSIX, the system calls used here that are interruptible (EINTR)
   are:  connect(), recv(), select()
   */
static int select_block_sigs( int n, fd_set *readfds, fd_set *writefds,
			      fd_set *exceptfds, struct timeval *timeout )
{ sigset_t sigset, oldsigset;
  sighandler_t real_handler;
  int answer;
  fd_set origreadfds;
  fd_set origwritefds;
  fd_set origexceptfds;

  /* save fdsets */
  memcpy( (char *)&origreadfds, (char *)readfds, sizeof(*readfds) );
  if (writefds != NULL)
    memcpy( (char *)&origwritefds, (char *)writefds, sizeof(*writefds) );
  if (exceptfds != NULL)
    memcpy( (char *)&origexceptfds, (char *)exceptfds, sizeof(*exceptfds) );

  do {
    real_handler = signal( SIGINT, null_handler );
    sigfillset( &sigset );
    sigdelset( &sigset, SIGINT );
    /* SO_KEEPALIVE can generate SIGPIPE.  If this fnc is called
       through mpiimpl.h:CALL_CHK() let it re-start this automatically.
    */
    sigdelset( &sigset, SIGPIPE );
    sigprocmask( SIG_BLOCK, &sigset, &oldsigset );
    /* If a blocked signal arrives during select, it returns -1
     * with errno == EINTR.  In principle, if a blocked signal arrives
     * before then, for which there is no signal handler, then we block
     * forever here.  Something similar happens if a signal arrives after
     * select and before sigprocmask restores old mask.  This could be fixed
     * by installing a signal handler
     * that writes the signal number to a pipe, and allows us to read
     * and propagate the signal later.  But so far, this hasn't been a problem.
     * pselect() was created to solve this, but Linux pselect() is not
     * yet native, and so still has the race condition.
     */

    IsSIGINT= 0;
    while (1) {
      /* On EINTR (interrupted by signal), just try again */
      /* On EAGAIN, kernel wants us to just try again */
      /* On ECHILD (error no child in wait), ignore error */
      /* On EADDRINUSE (bind <= stale address), caller fixes and tries again */
      /* On ECONNRESET || EPIPE (broken connection), caller can return MPI_FAIL */
      errno = 0;
      answer = select( n, readfds, writefds, exceptfds, timeout );

      if ( answer == -1 ) {

	/* restore fdsets on error from select */
	memcpy( (char *)readfds, (char *)&origreadfds, sizeof(origreadfds) );
  	if (writefds != NULL)
	  memcpy( (char *)writefds, (char *)&origwritefds,
		  sizeof(origwritefds) );
  	if (exceptfds != NULL)
	  memcpy( (char *)exceptfds, (char *)&origexceptfds,
	          sizeof(origexceptfds) );

	/* Remove first if, and fall through, when have confidence it works */
	/* printf("errno: %d; ",errno); */
	if ( (errno == EADDRINUSE) ) {
	  PERROR(function); errno = EADDRINUSE; break; }
	if ( (errno == ECHILD) || (errno == EADDRINUSE) ) break;
	if ( (errno == ECONNRESET) || (errno == EPIPE))  break;
	if ( errno == EINTR ) continue;
	if ( errno == EAGAIN ) continue;
	PERROR(function); exit(1);
      }
      else break; /* successful system call */
    }
    
#ifdef DEBUG
    printf("Trying to catch select which had SIGINT; isSIGINT=%d\n", IsSIGINT);
    {int i;
     if (exceptfds != NULL)
       for ( i = 0; i <= MPINU_max_sd; i++ )
        if (  FD_ISSET( i, exceptfds) )
          printf("FD_ISSET( %d, &exceptfds): %d\n", i, FD_ISSET(i, exceptfds) );
    }
    {int i;
     if (readfds != NULL)
       for ( i = 0; i <= MPINU_max_sd; i++ )
        if (  FD_ISSET( i, readfds) )
          printf("FD_ISSET( %d, &readfds): %d\n", i, FD_ISSET(i, readfds) );
    }
    { int sig_found = 0;
      int i;
      sigpending( &sigset );
      for ( i = 1; i <= 31; i++ ) {
        if ( sigismember( &sigset, i ) ) {
          if ( ! sig_found ) {
	    sig_found = 1;
            printf("sigpending after select:  %d\n", sigset);
	  }
	  printf("  Signal %d\n", i);
        }
      }
    }
#endif

    sigprocmask( SIG_SETMASK, &oldsigset, NULL );
    signal( SIGINT, real_handler );
#ifdef DEBUG
    if ( IsSIGINT ) printf("Rank(%d): select_block_sigs(): Interrupt caught\n",
			   MPINU_myrank);
    if (IsSIGINT) printf("  real_handler:  %x\n", real_handler);
    if (IsSIGINT) printf("  curr_handler:  %x\n", curr_signal() );
    printf("num sd's:  %d; FD_ISSET( MPINU_my_list_sd, &fd_readset ): %d\n",
	answer, FD_ISSET( MPINU_my_list_sd, readfds ) );
#endif
    if ( IsSIGINT ) kill( getpid(), SIGINT );  /* ANSI C calls it raise() */
  } while ( IsSIGINT == 1 ); /* null_handler could have set IsSIGINT = 1 */

  return answer;
}


// ==============================================================
// MPI_Send (thread-safe, checks for dead sockets)

int MPI_Send(void *buf, int count, MPI_Datatype datatype, int dest,
	     int tag, MPI_Comm comm)
{ struct msg_hdr buf_hdr;
  int num_bytes;

  if ( dest > MPINU_num_slaves || dest < 0 || count < 0
      || datatype <= MPI_MIN_DATATYPE || datatype >= MPI_MAX_DATATYPE
      || ( (tag < 0)
           && ( ! MPINU_coll_comm_flag || tag != MPI_COLL_COMM_TAG ) ) ) {
    printf("MPI_Send( .., %d, %d, %d, %d, ..): invalid argument\n",
	    count, datatype, dest, tag);
    exit(1);
  }
#ifdef DEBUG
printf("MPI_Send: source: %d, dest:  %d, count: %d, size: %d, tag: %d\n",
        MPINU_myrank, dest, count, count * datatype_size[(int)datatype], tag );
#endif
  if (dest == MPINU_myrank) {
    return MPINU_send_to_self_with_cache(tag,
		                 buf, count * datatype_size[(int)datatype], 0);
  }
  if ( MPINU_pg_array[dest].sd == PG_NOSOCKET ) {
    if (dest != MPINU_myrank) {
      if ( -1 == list_connect_new_socket( MPINU_myrank, dest ) )
        return MPI_FAIL; /* Return failure if can't connect to dest */
    }
    else
      assert( 1 );  /* no socket to self, and special case code above */
  }

#ifdef DEBUG
if ( count * datatype_size[(int)datatype] < 0 ) {
  printf("sending negative length message.\n");
  printf("datatype: %d, size for it:  %d.\n", datatype, datatype_size[(int)datatype]);
  exit(1);
}
#endif
  if ( ! IS_SOCKET_CONNECTED(MPINU_pg_array[dest].sd) ) {
    MPINU_socket_dead(MPINU_pg_array[dest].sd);
    return MPI_FAIL;
  }
  buf_hdr.tag = htonl(tag);
  buf_hdr.size = htonl(count * datatype_size[(int)datatype]);
  buf_hdr.rank = htonl(MPINU_myrank);

  { static pthread_mutex_t send_mutex = PTHREAD_MUTEX_INITIALIZER; 
    // After initialization, _all_ sends must go through this mutex.
    // Don't separate send of message header and message
    pthread_mutex_lock(&send_mutex);
#if 1
    num_bytes = MPINU_send_nonblock(MPINU_pg_array[dest].sd,
		   		    (char *)&buf_hdr, sizeof(buf_hdr), 0);
#else
    CALL_CHK( num_bytes = send, (MPINU_pg_array[dest].sd,
		     (char *)&buf_hdr, sizeof(buf_hdr), 0) );
#endif
 
    if ((num_bytes == - 1)|| (!IS_SOCKET_CONNECTED(MPINU_pg_array[dest].sd))) {
      MPINU_socket_dead(MPINU_pg_array[dest].sd);
      pthread_mutex_unlock(&send_mutex);
      return MPI_FAIL;
    }
    assert( num_bytes == sizeof(buf_hdr) );

#if 1
    num_bytes = MPINU_send_nonblock(MPINU_pg_array[dest].sd, (char *)buf,
		                    count * datatype_size[(int)datatype], 0);
#else
    CALL_CHK( num_bytes = send, (MPINU_pg_array[dest].sd, (char *)buf,
	                  count * datatype_size[(int)datatype], 0) );
#endif

    if((num_bytes == -1) || (!IS_SOCKET_CONNECTED(MPINU_pg_array[dest].sd))) {
      MPINU_socket_dead(MPINU_pg_array[dest].sd);
      pthread_mutex_unlock(&send_mutex);
      return MPI_FAIL;
    }
    pthread_mutex_unlock(&send_mutex);
  }
  assert( num_bytes == count * datatype_size[(int)datatype] );

  return MPI_SUCCESS;
}

// ==============================================================
// read_msg_hdr and helper functions

#define EAT_HDR 1
#define DONT_EAT_HDR 0
#define BLOCKING 0
#define NOT_BLOCKING 1
// These next two are the values of flag in MPI_Iprobe, and must be 1 and 0
#define MSG_WAITING 1
#define NO_MSG_WAITING 0
MPI_Status dummy_status;

static struct timeval * read_msg_hdr_setup( int source, int tag,
					    int blocking ) {
  static struct timeval zerotime;
  /* MUST ALSO HANDLE MPI_ANY_TAG and MPI_COLL_COMM_TAG */
  if ( source > MPINU_num_slaves || source < MPI_ANY_SOURCE ||
       tag < MPI_COLL_COMM_TAG ) {
    printf("read_msg_hdr: invalid argument\n");
    exit(1);
  }
  if ( blocking == BLOCKING )
    return NULL; /* NULL timeout means wait forever in select (block) */
  else { /* poll and return */
    zerotime.tv_sec = 0;
    zerotime.tv_usec = 0;
    return &zerotime;
  }
}

static int read_msg_hdr_select(int source, int tag, fd_set *fd_readset_ptr,
		       int *blocking, struct timeval *timeout, int *rank) {
  int tmp, fd, num_sd;
  tmp = MPINU_rank_of_msg_avail_in_cache(source, tag);
  if (tmp != -1) {
    *rank = tmp; /* in case source was MPI_ANY_SOURCE */
    *blocking = MSG_WAITING;
    return MPINU_pg_array[tmp].sd;
  } else
    *rank = source;
  if (source == MPINU_myrank) { /* If want msg from self and not in cache ... */
    if ( *blocking == BLOCKING ) {
      printf("read_msg_hdr:  rank %d BLOCKING waiting for msg from self.\n",
	     MPINU_myrank);
      exit(1);
    } else {
      *blocking = NO_MSG_WAITING;  /* no messages, return */
      return -1;
    }
  }

  if ( source == MPI_ANY_SOURCE ) {
    /* Copy global MPINU_fdset (with everything set) to local fd_readset */
    memcpy( (char *)fd_readset_ptr, (char *)&MPINU_fdset,
	    sizeof(MPINU_fdset) );
  } else {
    fd = MPINU_pg_array[source].sd;
    FD_ZERO( fd_readset_ptr );
    if ( fd != PG_NOSOCKET )
      FD_SET( fd, fd_readset_ptr );
    /* if no socket, hopefully listener will accept new connection */
    FD_SET( MPINU_my_list_sd, fd_readset_ptr );
  }
#ifdef DEBUG
  printf("entering select(%d)\n",MPINU_myrank);fflush(stdout);
  { struct sockaddr_in sin;
    int i = sizeof(struct sockaddr_in);
    CALL_CHK( getsockname, (MPINU_my_list_sd, (struct sockaddr *)&sin, &i) );
    printf("CHECKING(%d) listener port w/ sd(%d): sin.sin_port: %d\n",
    	   MPINU_myrank, MPINU_my_list_sd, sin.sin_port);fflush(stdout);
  }
#endif

  CALL_CHK( num_sd = select_block_sigs, (MPINU_max_sd+1, fd_readset_ptr,
					 NULL, NULL, timeout) );
  if ( FD_ISSET( MPINU_my_list_sd, fd_readset_ptr ) ) {
    assert( source != MPI_ANY_SOURCE );
    /* A msg on this socket is a request to open a new socket. */
    list_accept_new_socket(MPINU_my_list_sd);
    // If after list_accept_..., there's now a socket for source, register it;
    // Else it was a new socket, but not one for source, and do nothing
    if (MPINU_pg_array[source].sd != PG_NOSOCKET)
      FD_SET( MPINU_pg_array[source].sd, fd_readset_ptr );
    errno = EAGAIN;
    return -1;
  }

  /* Given *blocking with value of BLOCKING or NOT_BLOCKING,
     change to MSG_WAITING or NO_MSG_WAITING */
  if ( num_sd == 0 ) {
    if ( *blocking == BLOCKING ) {
      printf("read_msg_hdr:  rank %d BLOCKING exiting without recv'd msg.\n",
	     MPINU_myrank);
      exit(1);
    } else {
      *blocking = NO_MSG_WAITING;  /* no messages, return */
      return -1;
    }
  } else if ( num_sd > 0 )
    *blocking = MSG_WAITING;

  return num_sd;
}

static struct msg_hdr * read_msg_hdr_get_buf(int source, int tag,
				        fd_set *fd_readset_ptr, int eat_hdr) {
  int fd, recv_flags, num_bytes, dest;
  static struct msg_hdr buf_hdr; // static since we return this to caller

  if ( eat_hdr == DONT_EAT_HDR ) recv_flags = MSG_PEEK;
  else recv_flags = 0;

  if ( source == MPI_ANY_SOURCE ) { /* Determine source, fd */
    FD_CLR( MPINU_my_list_sd, fd_readset_ptr ); /* listener not legit source */
    for ( fd = 0; fd <= MPINU_max_sd+1; fd++)
      if ( FD_ISSET( fd, fd_readset_ptr ) ) break;
    if ( fd > MPINU_max_sd ) {
      printf("Unknown socket descriptor from select: %d MAX_SD:%d.\n", fd, MPINU_max_sd);
      exit(1);
    }
  } else
    fd = MPINU_pg_array[source].sd;
#ifdef DEBUG
  printf("receiving on socket %d out of MPINU_max_sd %d\n", fd, MPINU_max_sd);
#endif
#ifdef NEW
  CALL_CHK( num_bytes = MPINU_recv_msg_hdr_with_cache,
    	    ( fd, tag, (char *)&buf_hdr, sizeof(buf_hdr), recv_flags ) );  
#else
  CALL_CHK( num_bytes = MPINU_recvall,
    	    ( fd, (char *)&buf_hdr, sizeof(buf_hdr), recv_flags ) );  
#endif

  if ( (num_bytes == 0) || (num_bytes == -1) ) {
    { int dest = 0;
      while( fd != MPINU_pg_array[dest].sd ) { dest++; }
      if( list_connect_new_socket( MPINU_myrank, dest) == -1)
	MPINU_socket_dead(fd); 
    }
    return NULL; /* failed to receive; return NULL and try again upstairs */
  }
  // Confirm that the source for that socket is the same as source in buf_hdr
  for ( dest = 0; dest <= MPINU_num_slaves; dest++ )
    if ( MPINU_pg_array[dest].sd == fd )
      assert( dest == ntohl(buf_hdr.rank) );
  return &buf_hdr;
}

static void read_msg_hdr_post_check( int eat_hdr, int source, int tag,
				     int size, MPI_Datatype datatype,
				     int count, MPI_Status  *status ) {
  assert( size != -1 );
  if ( (tag != MPI_ANY_TAG) && (tag != status->MPI_TAG) ) {
    printf("MPINU(rank %d): Msg received with tag (%d) from source (%d)\n"
	   "                incompatible with requested tag (%d).\n",
	   MPINU_myrank, status->MPI_TAG, status->MPI_SOURCE, tag );
    exit(1);
  }
  if ( eat_hdr == EAT_HDR ) {
    if ( count < 0
	 || datatype <= MPI_MIN_DATATYPE || datatype >= MPI_MAX_DATATYPE ) {
      printf("read_msg_hdr: invalid count or datatype argument\n");
      exit(1);
    }
    if (size > count * datatype_size[(int)datatype]) {
      printf("read_msg_hdr:  User buffer (size: %d)\n",
              count * datatype_size[(int)datatype]);
      printf("  not large enough to hold message (size: %d) on processor %d.\n",
	     size, MPINU_myrank);
      exit(1);
    }
  }
  if ( ( source != status->MPI_SOURCE ) && ( source != MPI_ANY_SOURCE ) ) {
    printf("read_msg_hdr:  inconsistent source,\n");
    printf("  expecting source(%d) and received from source(%d) on proc. %d\n",
	    source, status->MPI_SOURCE, MPINU_myrank);
    exit(1);
  }
}

/* returns size (in bytes) of data that follows, or -1 if no msg */
/*  *source:  on entry, MPI_Rank; on exit, fd
 *  *flag:    on entry, NOT_BLOCKING means Iprobe (zero timeout)
 *	                BLOCKING means Probe or Recv (NULL timeout)
 *	      on exit, set to MSG_WAITING or NO_MSG_WAITING
 *   MPI_Status  *status:  set on exit
 *   eat_hdr:  eat_hdr == DONT_EAT_HDR means don't consume msg header
 */
static int read_msg_hdr ( int count, MPI_Datatype datatype,
			  int *source, int tag, MPI_Comm comm, int *blocking,
			  MPI_Status *status, int eat_hdr ) {
  int size, fd, num_bytes, num_sd, rank;
  fd_set fd_readset;
  struct timeval *timeout;
  struct msg_hdr * buf_hdr = NULL;

#ifdef DEBUG
  printf("Entering read_msg_hdr(): MPINU_myrank: %d, source: %d, tag: %d\n",
	 MPINU_myrank, *source, tag);fflush(stdout);
#endif
#if (MPI_ANY_SOURCE != -1) || (MPI_ANY_TAG != -1) || (MPI_COLL_COMM_TAG != -2)
  printf("sendrecv: read_msg_hdr: inconsistent C constant macros\n");
  exit(1);
#endif

  timeout = read_msg_hdr_setup( *source, tag, *blocking );

  while ( buf_hdr == NULL ) {
    /* Use select to find active port; if BLOCKING && not MPI_ANY_SOURCE,
       then we could have skipped this and gone directly to recv(), except
       that we also need to check the listener port */
    /* num_sd is number of socket descriptors with available messages;
     * num_sd is used only for debugging */
    do {
      num_sd = read_msg_hdr_select(*source, tag,
				   &fd_readset, blocking, timeout, &rank);
    } while ( ( -1 == num_sd ) && ( errno == EAGAIN ) );
#ifdef DEBUG
    printf("exiting select(%d)\n",MPINU_myrank);fflush(stdout);
    printf("timeout == NULL: %d; num_sd: %d; *blocking: %d\n",
	   timeout == NULL, num_sd, *blocking);
#endif

    if (*blocking == NO_MSG_WAITING)
      return 0; /* This was MPI_Iprobe;  It doesn't expect a buffer or status*/
    buf_hdr = read_msg_hdr_get_buf(rank, tag, &fd_readset, eat_hdr);
  }
  status->MPI_TAG = ntohl(buf_hdr->tag);
  size = ntohl(buf_hdr->size);
  status->mpi_size = size;
  status->MPI_SOURCE = ntohl(buf_hdr->rank);

  read_msg_hdr_post_check( eat_hdr, *source, tag, size, datatype, count,
			   status );

#ifdef DEBUG
  printf("read_msg_hdr: source: %d, dest: %d, size: %d, tag: %d\n",
	 status->MPI_SOURCE, MPINU_myrank, size, status->MPI_TAG );fflush(stdout);
#endif
  *source = status->MPI_SOURCE;
  return( size );
}

// ==============================================================
// MPI_Recv, MPI_Probe, etc. (thread-safe, checks for dead sockets)

// LOCK THREAD AFTER SELECT, WHEN READING MESSAGE HEADER.
// IF MESSAGE HEADER IS A TAG MATCH, DON'T PTHREAD_MUTEX_UNLOCK
//   UNTIL BODY HAS BEEN READ.
// STILL HAVE TO WORRY IF ONE THREAD DOES SELECT, GETS socket descriptor,
//   AND THEN THE OTHER THREAD GETS SAME ONE, STEALS SOCKET RESULT
//   AND CAUSES FIRST TO FIND NOTHING AND BLOCK.
// TEST THIS BY HAVING THREADS TO SEND AND RECEIVE, EACH USING
//   DISTINCT TAGS, BUT SAME SOURCE AND DEST.
static  pthread_mutex_t recv_mutex = PTHREAD_MUTEX_INITIALIZER; 
int MPI_Recv(void *buf, int count, MPI_Datatype datatype, int source,
	     int tag, MPI_Comm comm, MPI_Status *status)
{ int size, i, fd;
  int is_blocking = BLOCKING;

  if (status == MPI_STATUS_IGNORE)
    status = &dummy_status;
  pthread_mutex_lock(&recv_mutex);
  // After initialization, _all_ receives must go through this mutex.
  // Don't separate receive of message header and message
#ifdef DEBUG
printf("MPI_Recv (MPINU_myrank=%d)\n", MPINU_myrank);fflush(stdout);
#endif
  size = read_msg_hdr( count, datatype, &source, tag, comm,
		       &is_blocking, status, EAT_HDR );
  // if source == MPI_ANY_SOURCE, read_msg_hdr reset it to actual source.
  fd = MPINU_pg_array[source].sd;
#ifdef DEBUG
printf("fd: %d, *flag: %d\n", fd, is_blocking);fflush(stdout);
#endif
  if ( size < 0 ) {
    printf("MPI_Recv(%d):  read_msg_hdr claims no message waiting.\n",
           MPINU_myrank);
    pthread_mutex_unlock(&recv_mutex);
    exit(1);
  }
#ifdef NEW
  assert( source != MPI_ANY_SOURCE );
  CALL_CHK(i = MPINU_recv_msg_body_with_cache, (source, (char *)buf, size));
#else
  CALL_CHK( i = MPINU_recvall, ( fd, (char *)buf, size, 0 ) );
#endif
  if ( i < 0 || (i == 0 && size > 0) ) {
    MPINU_socket_dead(fd);
    pthread_mutex_unlock(&recv_mutex);
    return MPI_FAIL;
  }
  pthread_mutex_unlock(&recv_mutex);

  return MPI_SUCCESS;
}

/* MUST SET STATUS FOR TWO PROBE COMMANDS */
int MPI_Probe(int source, int tag, MPI_Comm comm, MPI_Status *status)
{ int flag_val = BLOCKING;
int i;
#ifdef DEBUG
printf("MPI_Probe (MPINU_myrank=%d)\n", MPINU_myrank);
#endif    
  if (status == MPI_STATUS_IGNORE)
    status = &dummy_status;
  read_msg_hdr( 0, 1, &source, tag, comm, &flag_val, status, DONT_EAT_HDR );
  return MPI_SUCCESS;
}
 
int MPI_Iprobe(int source, int tag, MPI_Comm comm, int *flag,
	       MPI_Status *status)
{ *flag = NOT_BLOCKING; /* on entry */
#ifdef DEBUG
printf("MPI_IProbe (MPINU_myrank=%d)\n", MPINU_myrank);
#endif
  if (status == MPI_STATUS_IGNORE)
    status = &dummy_status;
  read_msg_hdr( 0, 1, &source, tag, comm, flag, status, DONT_EAT_HDR );
  /* flag updated by read_msg_hdr, can be checked by caller */
  return MPI_SUCCESS;
}

int MPI_Get_count(MPI_Status *status, MPI_Datatype datatype, int *count)
{ *count = status->mpi_size / datatype_size[(int)datatype];
#ifdef DEBUG
printf("MPI_Get_count:  count: %d\n", *count);fflush(stdout);
#endif
  return MPI_SUCCESS; }
