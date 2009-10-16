/* NEEDED CHANGES:  MPINU_fdset2 -> fd_readset;  clean up read_msg_hdr()
     add Part 0 (check types), Part I (do select), Part II (check fds's),
     Part III (cleanup on exit)
*/

#include "mpi.h"
#include "mpiimpl.h"

/* These must correspond with MPI_XXX  in mpi.h */
static int datatype_size[] = {-1, sizeof(char), sizeof(unsigned char),
				sizeof(char),
			sizeof(short), sizeof(unsigned short), sizeof(int),
			sizeof(unsigned), sizeof(long), sizeof(unsigned long),
		        sizeof(float), sizeof(double)};
/* Add long double and long long for ANSI C version */

/* ============================================================ */

static void list_accept_new_socket(list_sd)
int list_sd;
{ struct sockaddr_in new_sin;
  int ns, source, fromlen = sizeof(new_sin);
  char buf[sizeof(INT)];

#ifdef DEBUG
  printf("Rank(%d): accepting new socket\n", MPINU_myrank);fflush(stdout);
#endif
  CALL_CHK( ns = accept, (list_sd, (struct sockaddr *)&new_sin, &fromlen) );
  CALL_CHK( recv, (ns, buf, sizeof(INT), 0) );
  source = ntohl(*((INT *)buf));

  if ( source < 0 || source > MPINU_num_slaves )
    printf("list_accept_new_socket:  Bad sender rank received: %d\n", fromlen);
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

static int list_connect_new_socket( myrank, dest_rank )
int myrank, dest_rank;
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
    CALL_CHK( close, (MPINU_pg_array[dest_rank].sd) );
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
   are:  connect), recv(), select()
   */
static int select_block_sigs( n, readfds, writefds, exceptfds, timeout )
    int n;
    fd_set *readfds;
    fd_set *writefds;
    fd_set *exceptfds;
    struct timeval *timeout;
{ sigset_t sigset, oldsigset;
  sighandler_t real_handler;
  int answer;

  do {
    real_handler = signal( SIGINT, null_handler );
    sigfillset( &sigset );
    sigdelset( &sigset, SIGINT );
    /* SO_KEEPALIVE can generate SIGPIPE.  If this fnc is called
       through mpiimpl.h:CALL_CHK() let it re-start this automatically.
    */
    sigdelset( &sigset, SIGPIPE );
    sigprocmask( SIG_BLOCK, &sigset, &oldsigset );

    IsSIGINT= 0;
    answer = select( n, readfds, writefds, exceptfds, timeout );

#ifdef DEBUG
    printf("Trying to catch select which had SIGINT\n");
    {int i;
     for ( i = 0; i <= MPINU_max_sd; i++ )
      if (  FD_ISSET( i, exceptfds) )
        printf("FD_ISSET( %d, &exceptfds): %d\n", i, FD_ISSET( i, exceptfds) );
    }
    {int i;
     for ( i = 0; i <= MPINU_max_sd; i++ )
      if (  FD_ISSET( i, readfds) )
        printf("FD_ISSET( %d, &readfds): %d\n", i, FD_ISSET( i, readfds) );
    }
  sigpending( &sigset );
  if ( sigset != emptysigset ) {
    printf("sigpending after select:  %d\n", sigset);
    for ( i = 1; i <= 30; i++ )
      if ( sigismember( &sigset, i ) ) printf("  Signal %d\n", i);
  }
#endif

    sigprocmask( SIG_SETMASK, &oldsigset, NULL );
    signal( SIGINT, real_handler );
#ifdef DEBUG
    if ( IsSIGINT ) printf("Rank(%d): select_block_sigs(): Interrupt caught\n",
			   MPINU_myrank);
    if (IsSIGINT) printf("  real_handler:  %x\n", real_handler);
    if (IsSIGINT) printf("  curr_handler:  %x\n", curr_signal() );
    printf("num sd's:  %d; FD_ISSET( MPINU_my_list_sd, &MPINU_fdset2 ): %d\n",
	answer, FD_ISSET( MPINU_my_list_sd, readfds ) );
#endif
    if ( IsSIGINT ) kill( getpid(), SIGINT );  /* ANSI C calls it raise() */
  } while ( IsSIGINT == 1 ); /* null_handler could have set IsSIGINT = 1 */

  return answer;
}


/* ============================================================ */

int MPI_Send( buf, count, datatype, dest, tag, comm )
     void             *buf;
     int              count, dest, tag;
     MPI_Datatype     datatype;
     MPI_Comm         comm;
{ struct msg_hdr buf_hdr;

  if ( dest > MPINU_num_slaves || dest < 0 || count < 0 || datatype < 1
      || datatype > MPI_DOUBLE /* change MPI_DOUBLE for above */
      || ( (tag < 0)
           && ( ! MPINU_coll_comm_flag || tag == MPI_COLL_COMM_TAG ) ) ) {
    printf("MPI_Send( .., %d, %d, %d, %d, ..): invalid argument\n",
	    count, datatype, dest, tag);
    exit(1);
  }
#ifdef DEBUG
printf("MPI_Send: source: %d, dest:  %d, count: %d, size: %d, tag: %d\n",
        MPINU_myrank, dest, count, count * datatype_size[(int)datatype], tag );
#endif
  if ( MPINU_pg_array[dest].sd == PG_NOSOCKET ) {
    if (dest != MPINU_myrank) {
      if ( -1 == list_connect_new_socket( MPINU_myrank, dest ) )
        return MPI_FAIL; /* Return failure if can't connect to dest */
    }
    else {
      printf("Attempt to send to self ( %d -> %d ) --\n",
	     MPINU_myrank, dest );
      printf("  not supported in this version.\n");
      exit(1);
    }
  }

#ifdef DEBUG
if ( count * datatype_size[(int)datatype] < 0 ) {
  printf("sending negative length message.\n");
  printf("datatype: %d, size for it:  %d.\n", datatype, datatype_size[(int)datatype]);
  exit(1);
}
#endif
  if ( ! IS_SOCKET_CONNECTED(MPINU_pg_array[dest].sd) ) {
    printf("Socket died;  Not ready for writing.  Will try to create a new one.\n"); fflush(stdout);
    list_connect_new_socket( MPINU_myrank, dest );
  }
  buf_hdr.tag = htonl(tag);
  buf_hdr.size = htonl(count * datatype_size[(int)datatype]);
  buf_hdr.rank = htonl(MPINU_myrank);
  CALL_CHK( send, (MPINU_pg_array[dest].sd,
		   (char *)&buf_hdr, sizeof(buf_hdr), 0) );
  CALL_CHK( send, (MPINU_pg_array[dest].sd, (char *)buf,
	           count * datatype_size[(int)datatype], 0) );
  return MPI_SUCCESS;
}

#define EAT_HDR 0
#define DONT_EAT_HDR 1
#define BLOCKING 0
#define NOT_BLOCKING 1
#define MSG_WAITING 1
#define NO_MSG_WAITING 0
/* returns size (in bytes) of data that follows, or -1 if no msg */
static int read_msg_hdr ( count, datatype, source, tag, comm, flag,
			  status, eat_hdr )
     int         count;
     MPI_Datatype datatype;
     int         *source; /* On entry, MPI_Rank; on exit, fd */
     int         tag;
     int         *flag; /* On entry, non-zero means iprobe (zero timeout) */
			/* On exit, 1 if msg waiting, else 0 */
     MPI_Comm    comm;
     MPI_Status  *status; /* Set on exit */
     int         eat_hdr; /* eat_hdr non-zero means not consume msg header */
{ struct msg_hdr buf_hdr;
  int size, fd, recv_flags, num_bytes, num_sd;
  fd_set MPINU_fdset2;
  struct timeval zerotime;
  struct timeval *timeout;

  /* MUST ALSO HANDLE MPI_ANY_TAG and MPI_COLL_COMM_TAG */
  if ( *flag == BLOCKING )
    timeout = NULL; /* wait forever (block) */
  else { /* poll and return */
    zerotime.tv_sec = 0;
    zerotime.tv_usec = 0;
    timeout = &zerotime;
  }
#ifdef DEBUG
  printf("Entering read_msg_hdr(): MPINU_myrank: %d, source: %d, tag: %d\n",
	 MPINU_myrank, *source, tag);fflush(stdout);
#endif
#if (MPI_ANY_SOURCE != -1) || (MPI_ANY_TAG != -1) || (MPI_COLL_COMM_TAG != -2)
  printf("sendrecv: read_msg_hdr: inconsistent C constant macros\n");
  exit(1);
#endif
  if ( *source > MPINU_num_slaves || *source < MPI_ANY_SOURCE ||
       tag < MPI_COLL_COMM_TAG ) {
    printf("read_msg_hdr: invalid argument\n");
    exit(1);
  }

  /* Use select to find active port; if BLOCKING && not MPI_ANY_SOURCE,
     then we could have skipped this and gone directly to recv(), except
     that we also need to check the listener port */
  TRYAGAIN: ;
  if ( *source == MPI_ANY_SOURCE ) {
    /* Copy global MPINU_fdset (with everything set) to local MPINU_fdset2 */
    memcpy( (char *)&MPINU_fdset2, (char *)&MPINU_fdset, sizeof(MPINU_fdset) );
  }
  else {
    fd = MPINU_pg_array[*source].sd;
    FD_ZERO( &MPINU_fdset2 );
    if ( fd != PG_NOSOCKET )
      FD_SET( fd, &MPINU_fdset2 );
    /* if no socket, hopefully listener will accept new connection */
    FD_SET( MPINU_my_list_sd, &MPINU_fdset2 );
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

#if 0
if (MPINU_myrank == 2) {
  { struct sockaddr_in sin; int len; fd_set MPINU_fdset5;
    printf("SLAVE 2 starting again\n");fflush(stdout);
    printf("MPINU_my_list_sd: %d, MPINU_max_sd: %d\n",
	   MPINU_my_list_sd, MPINU_max_sd);
    fflush(stdout);
    FD_ZERO(&MPINU_fdset5);
    FD_SET(MPINU_my_list_sd, &MPINU_fdset5);
    CALL_CHK( select, (MPINU_max_sd + 1, &MPINU_fdset5, NULL, NULL, NULL) );
    /* CALL_CHK(accept,(MPINU_my_list_sd, (struct sockaddr_in *)&sin, &len));*/
    printf("accept would have succeeded again\n");fflush(stdout);
  }
  CALL_CHK( select, (MPINU_max_sd + 1, &MPINU_fdset, NULL, NULL, NULL) );
  printf("select succeeded\n");fflush(stdout);
}
#endif

  CALL_CHK( num_sd = select_block_sigs, (MPINU_max_sd+1, &MPINU_fdset2,
					 NULL, NULL, timeout) );
  if ( (num_sd == 0) && (*flag == BLOCKING ) ) {
    printf("read_msg_hdr:  BLOCKING exiting without recv'd msg.\n");
    exit(1);
  }
#ifdef DEBUG
  printf("exiting select(%d)\n",MPINU_myrank);fflush(stdout);
  printf("timeout == NULL: %d; num_sd: %d; *flag: %d\n", timeout == NULL, num_sd, *flag);
#endif
  if ( FD_ISSET( MPINU_my_list_sd, &MPINU_fdset2 ) ) {
    /* A msg on this socket is a request to open a new socket. */
#if 0
    {int i;
     for ( i = 0; i <= MPINU_max_sd; i++ )
      printf("FD_ISSET( %d, &MPINU_fdset2): %d\n",
	     i, FD_ISSET( i, &MPINU_fdset2) );
    }
#endif
    list_accept_new_socket(MPINU_my_list_sd);
    FD_SET( MPINU_pg_array[*source].sd, &MPINU_fdset2 );/*in case new socket*/
    goto TRYAGAIN;
  }
#if 0
  {int i;
   for ( i = 0; i <= MPINU_max_sd; i++ )
    printf("FD_ISSET( %d, &MPINU_fdset2): %d\n",
	   i, FD_ISSET( i, &MPINU_fdset2) );
  }
#endif
  if ( num_sd > 0 )
    *flag = MSG_WAITING;
  else {
    *flag = NO_MSG_WAITING;  /* no messages, return */
    return( -1 );
  }
  TRY_NEXT_SOCKET: ;
  if ( *source == MPI_ANY_SOURCE ) { /* Determine source, fd */
    FD_CLR( MPINU_my_list_sd, &MPINU_fdset2 ); /* listener not legit source */
    for ( fd = 0; fd <= MPINU_max_sd+1; fd++)
      if ( FD_ISSET( fd, &MPINU_fdset2 ) ) break;
    if ( fd > MPINU_max_sd ) {
      printf("Unknown socket descriptor from select.\n");
      exit(1);
    }
  }
#ifdef DEBUG
  printf("receiving on socket %d out of MPINU_max_sd %d\n", fd, MPINU_max_sd);
#endif
  if ( eat_hdr == DONT_EAT_HDR ) recv_flags = MSG_PEEK;
  else recv_flags = 0;
#if 1
  CALL_CHK( num_bytes = recv,
	    ( fd, (char *)&buf_hdr, sizeof(buf_hdr), recv_flags ) );
#else
  num_bytes = recv( fd, (char *)&buf_hdr, sizeof(buf_hdr), recv_flags );
  if ( num_bytes == -1 ) {
    printf("Socket died;  Not ready for reading.  Will try to create a new one.\n");
    printf("errno(%d): %d, socket: %d\n", MPINU_myrank, errno, fd);
    perror("num_bytes = recv");
    printf("errno(%d): %d, socket: %d\n", MPINU_myrank, errno, fd);
    fflush(stderr);fflush(stdout);
    { int dest = 0;
      while( fd != MPINU_pg_array[dest].sd ) { dest++; }
      printf("dest: %d\n", dest);
      list_connect_new_socket( MPINU_myrank, dest );
      goto TRYAGAIN;
    }
    /* exit(1); */
  }
#endif
#ifdef DEBUG
if ( num_bytes == 0 ) printf("rank(%d): recv returned 0\n", MPINU_myrank );
#endif
  /* If 0 characters received and another socket available */
  /* Why do these "ping"'s to extra sockets occur? */
  if ( num_bytes == 0 && num_sd > 1 ) {
    FD_CLR( fd, &MPINU_fdset2 ); /* Clear empty socket and try again */
    num_sd--;
    goto TRY_NEXT_SOCKET;
  }
  if ( num_bytes == 0 && timeout != NULL ) { /* if no msg and non-blocking */
    *flag = NO_MSG_WAITING;  /* no messages, return */
    return( -1 );
  }
  /* if 0 characters received and a blocking call (timeout == NULL) */
  if ( num_bytes == 0 && timeout == NULL ) goto TRYAGAIN; /* Why does this happen? */
  if ( num_bytes != sizeof(buf_hdr) ) {
    /* Possible non-local error or loss of socket? */
    printf("read_msg_hdr(%d):  Header of size %d received instead of %d.\n",
           MPINU_myrank, num_bytes, sizeof(buf_hdr));
    FD_ZERO(&MPINU_fdset2);
    FD_SET( fd, &MPINU_fdset2);
    zerotime.tv_sec = 0;
    zerotime.tv_usec = 0;
    CALL_CHK( num_sd=select,(MPINU_max_sd+1,
			     NULL, NULL, &MPINU_fdset2, &zerotime) );
    printf("Exceptional condition on socket %d?: %d\n", fd, num_sd);
    FD_SET( fd, &MPINU_fdset2);
    CALL_CHK( num_sd = select, (MPINU_max_sd+1,
				NULL, &MPINU_fdset2, NULL, &zerotime) );
    printf("Write condition on socket %d?: %d\n", fd, num_sd);
    FD_SET( fd, &MPINU_fdset2);
    CALL_CHK( num_sd = select, (MPINU_max_sd+1,
				&MPINU_fdset2, NULL, NULL, &zerotime) );
    printf("Read condition on socket %d?: %d\n", fd, num_sd);
  CALL_CHK( num_bytes = recv, ( fd, (char *)&buf_hdr, 1, recv_flags ) );
printf("num_bytes = recv now returns %d\n", num_bytes);
printf("NDELAY (non-blocking): %d\n", O_NDELAY & fcntl( fd, F_GETFL, 0));
    exit(1);
  }
  status->MPI_TAG = ntohl(buf_hdr.tag);
  size = ntohl(buf_hdr.size);
  status->mpi_size = size;
  status->MPI_SOURCE = ntohl(buf_hdr.rank);

  if (size == -1) { printf("size was -1\n"); exit(1); }
  if ( (tag != MPI_ANY_TAG) && (tag != status->MPI_TAG) ) {
    printf("Msg received with tag (%d) from source (%d) \
	    incompatible with requested tag (%d).\n",
	    status->MPI_TAG, status->MPI_SOURCE, tag );
    exit(1);
  }
  if ( eat_hdr == EAT_HDR ) {
    if ( count < 0 || datatype < 1 || datatype > MPI_DOUBLE) {/* change for ANSI, cf above*/
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
  if ( ( *source != status->MPI_SOURCE ) && ( *source != MPI_ANY_SOURCE ) ) {
    printf("read_msg_hdr:  inconsistent source,\n");
    printf("  expecting source(%d) and received from source(%d) on proc. %d\n",
	    *source, status->MPI_SOURCE, MPINU_myrank);
    exit(1);
  }
#ifdef DEBUG
  printf("read_msg_hdr: source: %d, dest: %d, size: %d, tag: %d\n",
	 status->MPI_SOURCE, MPINU_myrank, size, status->MPI_TAG );fflush(stdout);
#endif
  *source = fd; /* *source set to fd on exit */
  return( size );
}

int MPI_Recv( buf, count, datatype, source, tag, comm, status )
     void             *buf;
     int              count, source, tag;
     MPI_Datatype     datatype;
     MPI_Comm         comm;
     MPI_Status       *status;
{ int size, i;
  int is_non_blocking = 0;

#ifdef DEBUG
printf("MPI_Recv (MPINU_myrank=%d)\n", MPINU_myrank);fflush(stdout);
#endif
  size = read_msg_hdr( count, datatype, &source, tag, comm,
			    &is_non_blocking, status, EAT_HDR );
  /* source was modified to be fd */
#ifdef DEBUG
printf("fd: %d, *flag: %d\n", source, is_non_blocking);fflush(stdout);
#endif
  if ( size < 0 ) {
    printf("MPI_Recv(%d):  read_msg_hdr claims no message waiting.\n",
	    MPINU_myrank);
    exit(1);
  }
  while ( size > 0 ) {
    CALL_CHK( i = recv, ( source, (char *)buf, size, 0 ) );
    buf = (char *)buf + i; /* FreeBSD didn't like: (char *)buf += 1; */
    size -= i;
#ifdef DEBUG
printf("Read i chars: %d; Remaining size: %d\n", i, size);fflush(stdout);
#endif
  }
#if 0
 /* For debugging, kill a socket and see if MPI recovers */
  printf("socket %d connected?: %d\n", source, IS_SOCKET_CONNECTED(source) );
 {static int cont = 1;
  if (cont)
    printf("KILLING socket %d from %d to %d for debugging\n",
	   source, status->MPI_SOURCE, MPINU_myrank);
  cont = 0;
 }
  shutdown( source, 2); /* FOR DEBUGGING */
  printf("socket %d connected?: %d\n", source, IS_SOCKET_CONNECTED(source) );
#endif
  return MPI_SUCCESS;
}

/* MUST SET STATUS FOR TWO PROBE COMMANDS */
int MPI_Probe( source, tag, comm, status )
     int         source;
     int         tag;
     MPI_Comm    comm;
     MPI_Status  *status;
{ int flag_val = BLOCKING;

#ifdef DEBUG
printf("MPI_Probe (MPINU_myrank=%d)\n", MPINU_myrank);
#endif
  read_msg_hdr( 0, 1, &source, tag, comm, &flag_val, status, DONT_EAT_HDR );
  return MPI_SUCCESS;
}

int MPI_Iprobe( source, tag, comm, flag, status )
     int         source;
     int         tag;
     int         *flag;
     MPI_Comm    comm;
     MPI_Status  *status;
{ *flag = NOT_BLOCKING; /* on entry */
#ifdef DEBUG
printf("MPI_IProbe (MPINU_myrank=%d)\n", MPINU_myrank);
#endif
  read_msg_hdr( 0, 1, &source, tag, comm, flag, status, DONT_EAT_HDR );
  /* flag updated by read_msg_hdr, can be checked by caller */
  return MPI_SUCCESS;
}

int MPI_Get_count( status, datatype, count )
     MPI_Status   *status;
     MPI_Datatype datatype;
     int          *count;
{ *count = status->mpi_size / datatype_size[(int)datatype];
#ifdef DEBUG
printf("MPI_Get_count:  count: %d\n", *count);fflush(stdout);
#endif
  return MPI_SUCCESS; }
