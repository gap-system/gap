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

//EXPORTS: MPINU_recv_msg_hdr_with_cache() and MPINU_recv_msg_body_with_cache()
//  They can read from the network and store in a local queue of buffers if
//  the caller does not want the message (e.g. wrong tag).  On the next call,
//  they transparently look in the local queue first before going to the
//  network.
//      These are both wrappers for MPINU_recvall(), which is in turn a
//  wrapper for the system call recv().  MPINU_recv_msg_body_with_cache
//  uses the argument source (source rank), instead of fd.
//  MPINU_recv_msg_hdr_with_cache() uses fd, but adds
//  an additional argument, tag.  We need to export two functions
//  because a call to recv() for the msg_hdr must first call buf_reset(rank)
//  to begin looking again from the beginning of the local queue of buffers.
//  If the call to recv() was for a msg_body, then we simply pick up the
//  next buffer from the queue (or the network if the queue is empty).

#include "mpi.h"
#include "mpiimpl.h"

typedef enum { BUF_TAG_EQUAL, BUF_TAG_NOT_EQUAL } buf_tag_equality_t;

static void buf_init ();
static buf_tag_equality_t buf_tag_compare(int rank, int tag);
static void buf_reset(int source, int tag);
static int buf_avail (int source, int len);
static int buf_avail_tag(int source, int len, int tag);
static void buf_enqueue(int rank, void *buf, int len);
static void buf_dequeue(int rank, void *buf, int len, int peek_msg);
static void *buf_peek(int rank, int len);
static void buf_skip(int rank, int len);

/* non-blocking, returns socket descriptor or -1 if none available
 * NOTE:  This function assumes that the cursor of all buf's is zero,
 *        and it can call buf_reset(source, tag).
 */
int MPINU_rank_of_msg_avail_in_cache(int source, int tag) {
    if (source != MPI_ANY_SOURCE) {
      if (tag == MPI_ANY_TAG) {
	if (buf_avail(source, sizeof(struct msg_hdr)))
          return source;
      }
      else
	while (buf_avail(source, sizeof(struct msg_hdr))) {
	  struct msg_hdr *hdr = buf_peek(source, sizeof(struct msg_hdr));
	  if ( ntohl( hdr->tag ) == tag ) {
	    buf_reset(source, tag); /* clean up for next caller */
	    return source;
	  } else { /* Else skip header and body */
	    buf_skip( source, sizeof(struct msg_hdr) + ntohl(hdr->size) );
	  }
	}
      buf_reset(source, tag); /* clean up for next caller */
    }
    else /* else source == MPI_ANY_SOURCE */
      for (source = 0; source < MPINU_num_slaves; source++) {
	int rank = MPINU_rank_of_msg_avail_in_cache(source, tag);
	if (rank != -1)
	  return rank;
      }
    /* if no source had buf_avail, then no msg avail */
    return -1;
}

/* On receiving a msg_hdr, we first do buf_reset(source, tag),
 * but _not_ on receiving a msg_body */
ssize_t MPINU_recv_msg_hdr_with_cache(int s, int tag,
				      void *buf, size_t len, int flags) {
    int msg_found = 0;
    int source = MPINU_rank_from_socket(s);
    buf_reset(source, tag);
    while ( !msg_found && buf_avail(source, len) ) {
      if ( ntohl( ((struct msg_hdr *)buf_peek(source, len))->tag ) == tag
	   || tag == MPI_ANY_TAG ) {
	buf_dequeue(source, buf, len, flags & MSG_PEEK);
	msg_found = 1;
      }
      else {
        int body_len;
	buf_skip(source, len); /* Skip header */
	body_len = ntohl( ((struct msg_hdr *)buf)->size );
	buf_skip(source, body_len); /* Skip body */
      }
    }
    if ( !msg_found )
      assert( !buf_avail(source, len) );
    while ( !msg_found ) {
      len = MPINU_recvall(MPINU_pg_array[source].sd, buf, len, flags);
      assert( len == sizeof(struct msg_hdr) );
      if ( ntohl( ((struct msg_hdr *)buf)->tag ) == tag
	   || tag == MPI_ANY_TAG )
	msg_found = 1;
      else if ( ! (flags & MSG_PEEK) ) {
#       define STATIC_SIZE 1000
        static char body_buf_array[STATIC_SIZE];
	void *body_buf;
	int body_len;
	buf_enqueue(source, buf, len);  /* Store header */
	/* After storing the header, we have to store the corresponding body */
	body_len = ntohl( ((struct msg_hdr *)buf)->size );
	if (body_len > STATIC_SIZE)
          body_buf = malloc(body_len);
	else
          body_buf = body_buf_array;
        body_len = MPINU_recvall(MPINU_pg_array[source].sd, body_buf, body_len,
			         flags);
	buf_enqueue(source, body_buf, body_len);  /* Store body */
	if (body_len > STATIC_SIZE)
          free(body_buf);
      }
    }
    return len;
}

ssize_t MPINU_recv_msg_body_with_cache(int source, void *buf, size_t len) {
    if ( buf_avail(source, len) ) {
      buf_dequeue(source, buf, len, 0); /* flags = 0: Never peek for body */
      return len;
    } else {
      /* Body cannot be split between buf and network;
       * If len bytes weren't available in buf, then expect 0 bytes in buf */
      assert( !buf_avail(source, 1) );
      /* flags = 0: Never peek for body */
      len = MPINU_recvall(MPINU_pg_array[source].sd, buf, len, 0);
      return len;
    }
}

ssize_t MPINU_send_to_self_with_cache(int tag, void *buf,
				      size_t len, int flags) {
    struct msg_hdr hdr_buf;
    buf_init(); /* Will do nothing if already initialized */
    hdr_buf.size = htonl( len );
    hdr_buf.tag = htonl( tag );
    hdr_buf.rank = htonl( MPINU_myrank );
    buf_enqueue(MPINU_myrank, &hdr_buf, sizeof(struct msg_hdr)); /* Store hdr */
    buf_enqueue(MPINU_myrank, buf, len); /* Store body */
}

//======================================================================
static struct buf_queue {
    void * buf;
    int end;
    int curs;
    int tag;
} * recv_buf;

static void buf_init () {
    int i;
    if (recv_buf != NULL)
      return;
    assert_perror( recv_buf
      = (struct buf_queue *)malloc((MPINU_num_slaves+1)
				   * sizeof(struct buf_queue)) );
    for ( i = 0; i <= MPINU_num_slaves; i++ ) {
      recv_buf[i].buf = NULL;
      recv_buf[i].end = 0;
      recv_buf[i].curs = 0;
    }
}
/* Reset to search beginning of buffer, looking for tag */
static void buf_reset(int source, int tag) {
    assert( source != MPI_ANY_SOURCE );
    if ( recv_buf == NULL )
      buf_init();
    recv_buf[source].curs = 0;
    recv_buf[source].tag = tag;
}
static int buf_avail (int source, int len) {
    if ( recv_buf == NULL ) /* if recv_buf never init'ed, then nothing avail */
      return 0;
    return recv_buf[source].curs + len <= recv_buf[source].end;
}
/*
 * If the tags are not equal, then check the entire buffer.
 * If the tags are equal, buf_reset() was called for this tag.  Continue
 *    searching starting at cursor.
 */
static int buf_avail_tag(int source, int len, int tag) {
    if ( recv_buf == NULL ) /* if recv_buf never init'ed, then nothing avail */
      return 0;
    assert( source != MPI_ANY_SOURCE );
    assert( recv_buf[source].curs == 0 || recv_buf[source].tag != MPI_ANY_TAG);
    /* I DON'T UNDERSTAND THIS FIRST CASE.  IF curs == 0, THEN BOTH
       CASES DO THE SAME THING.  IF curs > 0, THEN THE TAGS DON'T MATCH,
       AND SO THEN SHOULDN'T WE RETURN FALSE AND THEN FORCE A SEARCH FURTHER
       INTO buf BY OUR CALLING FUNCTION?  - Gene */
    if (buf_tag_compare(source, tag) == BUF_TAG_NOT_EQUAL)
      return len <= recv_buf[source].end;
    else
      return recv_buf[source].curs + len <= recv_buf[source].end;
}
/*
 * Compare the given tag with the tag of the cursor for the specified rank. If
 * the cursor is at the beginning then declare
 * that the tag does not match. Otherwise, if an actual tag comparison doesn't
 * match, return that fact, else the tags do match.
 */
static buf_tag_equality_t buf_tag_compare(int rank, int tag) {
    assert( rank != MPI_ANY_SOURCE );
    if ( recv_buf[rank].curs == 0 || recv_buf[rank].tag != tag )
	return BUF_TAG_NOT_EQUAL;
    else
	return BUF_TAG_EQUAL;
}
static void buf_finalize () {
    free( recv_buf );
}

static void buf_enqueue(int rank, void *buf, int len) {
    assert_perror( recv_buf[rank].buf
      = (struct buf_queue *)realloc( recv_buf[rank].buf,
				     recv_buf[rank].end + len ) );
    assert_perror( memcpy( recv_buf[rank].buf + recv_buf[rank].end,
                           buf, len ) );
    if ( rank != MPINU_myrank ) {
      /* We read from network and enqueue only after we have searched buf */
      assert( recv_buf[rank].end == recv_buf[rank].curs );
      recv_buf[rank].end += len;
      recv_buf[rank].curs = recv_buf[rank].end;
    } else /* If message from self, it did not arrive via network. */
      recv_buf[rank].end += len;
}
static void buf_dequeue(int rank, void *buf, int len, int peek_msg) {
    int i, j;
    char * buf_queue = recv_buf[rank].buf;
    assert( recv_buf[rank].curs + len <= recv_buf[rank].end );
    memcpy( buf, recv_buf[rank].buf + recv_buf[rank].curs, len );
    if ( !peek_msg ) {
      for ( i = recv_buf[rank].curs, j = recv_buf[rank].curs+len; 
            j < recv_buf[rank].end; i++, j++ )
        buf_queue[i] = buf_queue[j];
      assert( i + len == recv_buf[rank].end );
      recv_buf[rank].end = i;
      if ( recv_buf[rank].end == 0 )
        free( recv_buf[rank].buf );
    }
}
static void *buf_peek(int rank, int len) {
    assert( recv_buf[rank].curs + len <= recv_buf[rank].end );
    assert( recv_buf[rank].curs == 0 || recv_buf[rank].tag != MPI_ANY_TAG );
    return (char *)recv_buf[rank].buf + recv_buf[rank].curs;
}
static void buf_skip(int rank, int len) {
    recv_buf[rank].curs += len;
    assert( recv_buf[rank].curs <= recv_buf[rank].end );
}

//=============================================================

#ifdef STANDALONE
# define PEEK 1
# define DONT_JUST_PEEK 0
int main() {
  char buf[100];
  buf_init();
  buf_enqueue( 1, "abcde", 5 );
  buf_enqueue( 1, "fghij", 5  );
  buf_enqueue( 1, "klmno", 5  );
  buf_skip( 1, 5 );
  buf_dequeue( 1, buf, 5, DONT_JUST_PEEK  );
  buf[5] = '\0';
  printf(buf);
  buf_dequeue( 1, buf, 5, DONT_JUST_PEEK  );
  buf_reset( 1 );
  buf_dequeue( 1, buf, 5, DONT_JUST_PEEK  );
  return 0;
}
#endif
