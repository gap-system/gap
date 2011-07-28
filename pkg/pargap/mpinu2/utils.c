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

#include "mpi.h"
#include "mpiimpl.h"

#define true 1
#define false 0
#define bool int
#define UINT32 int
// #include "tivlog.h"

/*====================================================================*/
/* MPI Utility Functions */

int MPI_Comm_rank( comm, rank )
     MPI_Comm comm;
     int *rank;
{ *rank = MPINU_myrank;
  return 0;
}

int MPI_Comm_size( comm, size)
     MPI_Comm comm;
     int *size;
{ *size = 1 + MPINU_num_slaves;
  return 0;
}

int MPI_Get_processor_name( name, resultlen )
     char *name;
     int *resultlen;
{ gethostname( name, MPI_MAX_PROCESSOR_NAME );
  *resultlen = strlen( name );
  if ( *resultlen < MPI_MAX_PROCESSOR_NAME ) return 0;
  else return -1;
}

int MPI_Abort( comm, errorcode )
     MPI_Comm comm;
     int errorcode;
{ printf("MPI_Abort called with errorcode: %d\n", errorcode);
  abort();
  return( 0 ); /* return for lint */
}

/* MPI_TAG_UB, MPI_HOST <- MPI_PROC_NULL, MPI_IO (myrank), MPI_WTIME_IS_GLOBAL
								<- 0
  attr_value can be (int *) */
int MPI_Attr_get ( comm, keyval, attr_value, flag )
     MPI_Comm comm;
     int keyval;
     void *attr_value;
     int *flag;
{ *flag = 1;
  switch( keyval ) {
    case MPI_TAG_UB: *(int *)attr_value = ~(1u << (8 * sizeof(INT) - 1) );
      break;
    case MPI_HOST: *(int *)attr_value = MPI_PROC_NULL;
      break;
    case MPI_IO: *(int *)attr_value = MPINU_myrank;
      break;
    case MPI_WTIME_IS_GLOBAL: *(int *)attr_value = 0;
      break;
    default: *flag = 0;
  }
  return( 0 );
}

int MPI_Error_string( errorcode, string, resultlen )
     int  errorcode, *resultlen;
     char *string;
{ static char err[] = "MPINU:  MPI_Error_string not implemented.\n";
  string = err;
  *resultlen = strlen(err);
  return( 0 );
}

/*====================================================================*/
/* Utilities for implementation */

int MPINU_rank_from_socket(int s) {
    int i;
    for (i = 0; i <= MPINU_num_slaves; i++)
        if (MPINU_pg_array[i].sd == s)
            return i;
    return -1; /* socket not found */
}

#define TRIES 100
ssize_t MPINU_recvall(int s, void *buf, size_t len, int flags) {
    int result = 0; /* if while loop not executed, len was 0 */
    int received = 0;
    int timeout = TRIES;
    int zero_recvd = 0;
    int peek_not_recvd = 0;

    assert(s >= 0);
    assert(len >= 0);
    while (received < len && timeout > 0) {
      result = recv(s, (char *)buf + received, len - received, flags);
      if ( (flags & MSG_PEEK) && result != len ) {
	if (result > 0)
	  peek_not_recvd++;
	result = 0;
      }
      timeout--;
      if (result >= 0) {
	if (result == 0) zero_recvd++;
	received += result;
      }
      else if (result == -1 && ( errno == EINTR || errno == EAGAIN ) )
	continue;
      else
        break;
    }
    if (timeout == 0) {
      int i;
      if (received == 0 && peek_not_recvd > TRIES - 5 && TRIES > 6)
        fprintf(stderr, "MPINU_recvall(rank %d): many attempts to peek, "
			"but only partial buffer receved;\n", MPINU_myrank);
      else if (received == 0 && zero_recvd > TRIES - 5 && TRIES > 6)
        fprintf(stderr, "MPINU_recvall(rank %d): no receive;"
	       " peer performed orderly shutdown.\n", MPINU_myrank);
      else
        fprintf(stderr, "MPINU_recvall(rank %d):  %d tries;"
	       "  Only received %d bytes out of %d.\n",
	       MPINU_myrank, TRIES, received, len);
      for (i = 0; i <= MPINU_num_slaves; i++)
        if (MPINU_pg_array[i].sd == s)
          fprintf(stderr, " receiving from rank %d: ", i);
      errno = ECONNRESET; // On Linux, recv can return 0,
			  // instead of -1 and setting errno = ECONNRESET
      return -1;
    }
    if (result == -1) {
      int i;
      fprintf(stderr, "Rank %d: ", MPINU_myrank);
      for (i = 0; i <= MPINU_num_slaves; i++)
        if (MPINU_pg_array[i].sd == s)
          fprintf(stderr, " receiving from rank %d: ", i);
      perror("MPINU_recvall");
    }
    if (result >= 0 && received == len)
      result = len;

    return result;
}

ssize_t MPINU_sendall(int s, void *buf, size_t len, int flags) {
  int result = 0; /* if while loop not executed, len was 0 */
  int sent = 0;
  int timeout = TRIES;
  int zero_sent = 0;
  while (sent < len && timeout > 0) {
    result = send(s, (char *)buf + sent, len - sent, flags);
    timeout--;
    if (result >= 0) {
      if (result == 0) zero_sent++;
      sent += result;
    }
    else if (result == -1 && ( errno == EINTR || errno == EAGAIN ) )
      continue;
    else
      break;
  }
  if (timeout == 0) {
    if (sent == 0 && zero_sent > TRIES - 5 && TRIES > 6)
      printf("MPINU_sendall(rank %d): nothing sent after %d tries\n",
	     MPINU_myrank, TRIES);
    else
      printf("MPINU_sendall(rank %d):  %d tries;"
	     "  Only sent %d bytes out of %d.\n",
	     MPINU_myrank, TRIES, sent, len);
    errno = -1;
    return -1;
  }
  assert( timeout > 0 && ( sent == len || result == -1 ) );
  if (result == -1) {
    int i;
    fprintf(stderr, "Rank %d: ", MPINU_myrank);
    for (i = 0; i <= MPINU_num_slaves; i++)
      if (MPINU_pg_array[i].sd == s)
        fprintf(stderr, " sending to rank %d: ", i);
    perror("MPINU_sendall");
  }
  if (result >= 0 && sent == len)
    result = sent;
  return result;
}

