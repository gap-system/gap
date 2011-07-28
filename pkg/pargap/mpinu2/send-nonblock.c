// TODO:  define MAX_QUEUE_LENGTH 10000, currently
//        Set it back to 100 (small footprint), and dynamically grow it
//          when assert would normally violate MAX_QUEUE_LENGTH.

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

// EXPORTS:  MPINU_send_nonblock(), MPINU_send_thread_exit()
// NOTE: This facility allows a send thread to work on one pending send,
//   while the process goes on.  If there are two pending sends, then
//   the second pending send will still block.  This should be fixed in
//   the future by a queue of sends, and a warning if it fills up.
// NOTE: This facility conflicts with the ability of MPI_Send to detect
//   a failure to send.  A future version should fix this.
// This nonblocking send is needed to prevent circular deadlock, that would
//   occur in a cycle of processes, with each wanting to finish its
//   send to the next one before receiving from the previous process.

// MPINU_send_nonblock() has the same API as send(), and can be used
//    in the same place.  (It is primarily used inside MPI_Send().)
// Its only differences are: (a) that it doesn't block; and (b) that it should
//    finish a send, even after being interrupted by a signal
//    (due to macro, CALL_CHK).
// If MPINU_send_thread_exit() is to be used, it should called from
//     inside MPI_Finalize.

#include "mpiimpl.h"

/* When the NEW version has been run a lot, we will delete the
 * else branch (OLD). */
#define NEW /* Use send queue of length longer than 1 */
#define MAX_QUEUE_LENGTH 10000

#define true 1
#define false 0
#define bool int
#define UINT32 int
// #define LOG_STRING
// #define DEBUG_LEVEL 4
// #include "tivlog.h"

#ifdef NEW
static struct send_args {
    int sd;
    void * buf;
    int len;
    int flags;
} send_args[MAX_QUEUE_LENGTH];
static void enqueue(int s, const void *buf, int len, int flags, char *t);
static void dequeue(char *t);
static struct send_args * queue_head();
static queue_length();
#endif

static void send_thread_create(void);
static pthread_t send_thread_id;
static int send_thread_init = 0;

#if defined(__APPLE__)
static const char *send_producer_sem_name = "MPINU_producer_%d";
static const char *send_consumer_sem_name = "MPINU_consumer_%d";
static sem_t *send_producer_sem = NULL;
static sem_t *send_consumer_sem = NULL;
#else
static sem_t send_producer_semaphore;
static sem_t send_consumer_semaphore;
static sem_t *send_producer_sem = &send_producer_semaphore;
static sem_t *send_consumer_sem = &send_consumer_semaphore;
#endif
/* for MPINU_sendall */
static pthread_mutex_t send_mutex = PTHREAD_MUTEX_INITIALIZER;
/* for enqueue, dequeue, pthread_create/sem_init */
static pthread_mutex_t send_queue_mutex = PTHREAD_MUTEX_INITIALIZER;

// Primary declaration and initialization in section:  enqueue and dequeue
static int head; // value is next empty slot in send_args
static int tail; // value is last occupied slot in send_args

static volatile void *send_tmp_buf = NULL;
static volatile int send_tmp_buf_size = 0;
static volatile int DBG_COUNT = 0; // for debugging and maintenance
#ifdef NEW
# define SEND_DONE (-2) /* Unique socket descriptor indicating exit from send */
#else
static char * send_done = "SENDS ARE DONE"; // send_done is unique pointer
static volatile int send_sd = -1;
static volatile int send_len = -1;
static volatile int send_flags = -1;
#endif

/* wrap sem_wait() so that EINTRs are ignored */
static int nu_sem_wait (sem_t *sem) {
    int retval;
    while ( (retval = sem_wait(sem)) == -1 && errno == EINTR ) {}
    return retval;
    }

ssize_t MPINU_send_nonblock(int s, const void *buf, size_t len, int flags) {

/* In TOP-C, we don't need nonblocking sends, and we can avoid extra threads */
#if defined(TOPC) || ! HAVE_PTHREAD
    { int num_bytes;
      CALL_CHK( num_bytes = send, (s, buf, len, flags) );
      // Caller will check if errno != 0, or socket not connected.
      return num_bytes;
    }
#endif

    if (len == 0)
	return len;
    // Initialize thread and semaphores if not done yet.
    assert( pthread_mutex_lock( &send_queue_mutex ) == 0 );
    if (! send_thread_init) {
#ifdef NEW
# if defined(__APPLE__)
	{
	    char	name[PATH_MAX];
	    snprintf (name, sizeof (name), send_producer_sem_name, getpid ());
	    send_producer_sem = sem_open( name, O_CREAT|O_EXCL, 0777,
		    MAX_QUEUE_LENGTH - 1 );
	    if (send_producer_sem == NULL) {
		int errval = errno;
		fprintf (stderr, "%s: sem_open() failed with %d (%s)\n",
			__func__, errval, strerror (errval));
		return errno;
	    }
	}
# else
        assert( sem_init( send_producer_sem, 0, MAX_QUEUE_LENGTH - 1 ) == 0 );
# endif
#else
        assert( sem_init( send_producer_sem, 0, 1 ) == 0 );
#endif
#if defined(__APPLE__)
	{
	    char	name[PATH_MAX];
	    snprintf (name, sizeof (name), send_consumer_sem_name, getpid ());
	    send_consumer_sem = sem_open( name, O_CREAT|O_EXCL, 0777, 0 );
	    if (send_consumer_sem == NULL) {
		int errval = errno;
		fprintf (stderr, "%s: sem_open() failed with %d (%s)\n",
			__func__, errval, strerror (errval));
		return errno;
	    }
	}
#else
        assert( sem_init( send_consumer_sem, 0, 0 ) == 0 );
#endif
        send_thread_create();
	send_thread_init = 1;
    }
    assert( pthread_mutex_unlock( &send_queue_mutex ) == 0 );

    // We are the producer; We wait until our semaphore gives us permission.
    assert( nu_sem_wait( send_producer_sem ) == 0  );
    assert( pthread_mutex_lock( &send_queue_mutex ) == 0 );
#ifdef NEW
    enqueue(s, buf, len, flags, "send");
    assert(DBG_COUNT>=0);
#else
    if (len > send_tmp_buf_size) {
    	assert( send_tmp_buf = realloc((void *)send_tmp_buf, len) );
	send_tmp_buf_size = len;
    }
    assert( send_tmp_buf_size >= len );
    assert( memcpy( (void *)send_tmp_buf, buf, len) );
    send_sd = s;
    send_len = len;
    send_flags = flags;
    assert(DBG_COUNT==0);
#endif
    DBG_COUNT += len;
    assert( pthread_mutex_unlock( &send_queue_mutex ) == 0 );
    assert( sem_post( send_consumer_sem ) == 0 );

    return len;
}

static void * send_thread_body(void *dummy) {
    while(1) {
        int num_bytes, tmplen, status, loopcnt = 0;
#ifdef NEW
        struct send_args * args;
#endif
        //We are the consumer; We wait until our semaphore gives us permission.
        assert( nu_sem_wait( send_consumer_sem ) == 0 );
        assert( pthread_mutex_lock( &send_queue_mutex ) == 0 );
#ifdef NEW
	if ( queue_length() == MAX_QUEUE_LENGTH-1 ) {
	    sleep(60);  // If queue full, hope it will go away in 1 minute
	    if ( queue_length() == MAX_QUEUE_LENGTH-1 )
                printf( "MPINU:send_thread_body:  %d messages still in queue"
			" after 1 minute.\n"
	 		"Change __FILE__:MAX_QUEUE_LENGTH and recompile"
			" to raise this limit.\n", MAX_QUEUE_LENGTH-1 );
	    if (queue_length() >= MAX_QUEUE_LENGTH-1) {
		fprintf (stderr, "%s: assert queue_length() < "
			 "MAX_QUEUE_LENGTH-1: tail = %d, head = %d\n",
			 __func__, tail, head);
		assert ( queue_length() < MAX_QUEUE_LENGTH-1 );
	    }
	}
	if (queue_length() <= 0) {
	    fprintf (stderr, "%s: assert queue_length() > 0:"
		     " tail = %d, head = %d\n", __func__, tail, head);
	    assert( queue_length() > 0 );
	}
	args = queue_head();
        if( args->sd == SEND_DONE ) {
	    args->buf = NULL;
#else
        if( send_tmp_buf == NULL && send_len > 0 ) {
            fprintf(stderr, "MPINU(rank %d):  send_thread_body:"
			    "  Sending NULL buffer of length %d.\n",
			    MPINU_myrank, send_len);
	    assert(!(send_tmp_buf == NULL && send_len > 0));
	}
        if( send_tmp_buf == send_done ) {
	    send_tmp_buf = NULL;
#endif
	    send_thread_init = 0; // Allow restart later.
	    return "send is done";
	}
        assert( pthread_mutex_unlock( &send_queue_mutex ) == 0 );

#ifdef NEW
//printf( "queue_length(): %d\n", queue_length() );
//printf( "args->sd: %d; rank: %d\n", args->sd, MPINU_myrank );
        assert( pthread_mutex_lock( &send_mutex ) == 0 );
        CALL_CHK( num_bytes = MPINU_sendall,
		  (args->sd, args->buf, args->len, args->flags) );
        assert( pthread_mutex_unlock( &send_mutex ) == 0 );

        assert( pthread_mutex_lock( &send_queue_mutex ) == 0 );
	DBG_COUNT -= args->len;
	assert(DBG_COUNT>=0);
	tmplen = args->len;
	dequeue("body");
        assert( pthread_mutex_unlock( &send_queue_mutex ) == 0 );
#else
        assert( pthread_mutex_lock( &send_mutex ) == 0 );
        CALL_CHK( num_bytes = MPINU_sendall,
		  (send_sd, (void *)send_tmp_buf, send_len, send_flags) );
        assert( pthread_mutex_unlock( &send_mutex ) == 0 );

        assert( pthread_mutex_lock( &send_queue_mutex ) == 0 );
	DBG_COUNT -= send_len;
	assert(DBG_COUNT==0);
        assert( pthread_mutex_unlock( &send_queue_mutex ) == 0 );
#endif
        // Original thread no longer available to handle error conditions:
        if ( num_bytes == -1 ) {
	    printf("Rank %d: ", MPINU_myrank);
            perror("MPINU_send_nonblock");
	}
#ifdef NEW
	else if ( num_bytes > 0 && num_bytes < tmplen )
            printf("MPINU_send_nonblock: only %d bytes out of %d received.\n",
		   num_bytes, tmplen);
//fprintf(stderr, "num_bytes, tmplen, args->sd, args->flags, args->buf, queue_length(), head, tail: %d, %d %d %d %x %d %d %d\n", num_bytes, args->len, args->sd, args->flags, args->flags, queue_length(), head, tail);
	assert( num_bytes == tmplen );
#else
	else if ( num_bytes > 0 && num_bytes < send_len )
            printf("MPINU_send_nonblock: only %d bytes out of %d received.\n",
		   num_bytes, send_len);
	assert( num_bytes == send_len );
#endif
        assert( sem_post( send_producer_sem ) == 0 );
    }
}

static void send_thread_create() {
    int pthread_create_retval;

    pthread_create_retval
	= pthread_create(&send_thread_id, NULL, send_thread_body, 0);
    if (pthread_create_retval) {
	printf("MPINU: pthread_create: %s\n", strerror(pthread_create_retval));
	assert(pthread_create_retval == 0);
    }
}

void MPINU_send_thread_exit() {
    void *thread_return;
#if ! HAVE_PTHREAD
    return;
#endif
    assert( nu_sem_wait( send_producer_sem ) == 0);
#ifdef NEW
    assert( pthread_mutex_lock( &send_queue_mutex ) == 0 );
    enqueue( SEND_DONE, "send is done", strlen("send is done")+1, -1, "exit" );
    assert( pthread_mutex_unlock( &send_queue_mutex ) == 0 );
#else
    free( (void *)send_tmp_buf );
    send_tmp_buf = send_done;
    send_len = 0;
#endif
    assert( sem_post( send_consumer_sem ) == 0);
    assert( pthread_join( send_thread_id, &thread_return ) == 0);
}

#ifdef NEW
//========================================================================
// enqueue and dequeue
// STILL NEED TO IMPLEMENT main send buffer (such as send_tmp_buf)
// THEN IF AT MOST ONE PENDING SEND (COMMON CASE), CAN USE send_tmp_buf

static int head = 0; // value is next empty slot in send_args
static int tail = 0; // value is last occupied slot in send_args

// POST_INCR returns  index%MAX_QUEUE_LENGTH, but also increments index
#define POST_INCR(index) (index++ % MAX_QUEUE_LENGTH)
#define VALUE(index) (index % MAX_QUEUE_LENGTH)
#define QUEUE_LENGTH ((tail + MAX_QUEUE_LENGTH - head) % MAX_QUEUE_LENGTH)

// main buffer initialized to NULL, for use by realloc
// main buffer size initialized to 0
// main buffer isUsed initialized to 0

static void enqueue(int s, const void *buf, int len, int flags, char *t) {
    // if main buffer not used, call realloc on it instead of malloc
//fprintf(stderr, "enqueue: VALUE(tail): %d; buf: %x; len: %d\n",
//		  VALUE(tail), buf, len);
    assert( tail >= head );
    assert( tail+1 - head < MAX_QUEUE_LENGTH );
    assert( send_args[VALUE(tail)].buf = malloc(len) );
    memcpy( send_args[VALUE(tail)].buf, buf, len );
    send_args[VALUE(tail)].sd = s;
    send_args[VALUE(tail)].len = len;
    send_args[VALUE(tail)].flags = flags;
    POST_INCR(tail);
    // fprintf(stderr, "%s(%s)[%d]: tail = %d, head = %d\n",
    //        __func__, t, getpid(), tail, head);
}
// returns next buffer and takes it off queue
static void dequeue(char *t) {
//fprintf(stderr, "dequeue: VALUE(head): %d; buf: %x; len: %d\n",
//	  VALUE(head), send_args[VALUE(head)].buf, send_args[VALUE(head)].len);
    // if main buffer, do not free
    assert( tail >= head+1 );
    free( send_args[VALUE(head)].buf );
    send_args[VALUE(head)].buf = NULL;
    send_args[VALUE(head)].sd = -1;
    send_args[VALUE(head)].len = -1;
    send_args[VALUE(head)].flags = -1;
    POST_INCR(head);
    // fprintf(stderr, "%s(%s)[%d]: tail = %d, head = %d\n",
    //        __func__, t, getpid(), tail, head);
}
static struct send_args * queue_head() {
//printf("queue_head(%d): VALUE(head): %d; send_args[VALUE(head)].buf: %x\n",
//		MPINU_myrank, VALUE(head), send_args[VALUE(head)].buf);
    assert( send_args[VALUE(head)].buf );
    return &(send_args[VALUE(head)]);
}
static queue_length() {
    assert( tail >= head );
    assert( tail - head < MAX_QUEUE_LENGTH );
    return QUEUE_LENGTH; }
#endif

#if 0
//THIS IS CODE FOR NEXT VERSION.  (MAYBE NOT NEEDED)
// IT IMPLEMENTS main send buffer (send_tmp_buf)
//========================================================================
// enqueue and dequeue
// send_producer_sem should be initialized to MAX_QUEUE_LENGTH - 1

static void *send_tmp_buf[MAX_QUEUE_LENGTH];
static int head = 0; // value is next empty slot in send_tmp_buf
static int tail = 0; // value is last occupied slot in send_tmp_buf

// POST_INCR returns  index%MAX_QUEUE_LENGTH, but also increments index
#define POST_INCR(index) (index++ % MAX_QUEUE_LENGTH)
#define QUEUE_LENGTH ((head + MAX_QUEUE_LENGTH - tail) % MAX_QUEUE_LENGTH)

// main buffer initialized to NULL, for use by realloc
// main buffer size initialized to 0
// main buffer isUsed initialized to 0

static void enqueue(void *buf, int len) {
    // if main buffer not used, call realloc on it instead of malloc
    assert( send_tmp_buf[POST_INCR(head)] = malloc(len) );
}
static void dequeue() {
    // if main buffer, do not free
    assert( free( send_tmp_buf[POST_INCR(tail)] ) );
}
#endif
