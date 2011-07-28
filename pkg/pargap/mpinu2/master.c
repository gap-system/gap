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

#define SLAVE_INIT_TIMEOUT 15

void MPINU_mpi_master(p4pg_file, argc, argv)
int argc;
char *p4pg_file, *argv[];
{
  int new_slaves;/* Used for MPINU_set_and_exec_cmds */
  int sd, ns;                /* socket descriptors            */
  struct init_msg msg1;
  char new_port[8];         /* port on which master listens, ASCII number */
  socklen_t fromlen;
  int rank, port;
  char host[256];		/* hostname                       */
  char outfile[256];		/* outfile                        */
  struct hostent *hp;           /* ptr to host info structure     */
  struct sockaddr_in sin;       /* inet info structure            */
  struct sockaddr_in new_sin;   /* used for each new connection   */

  FD_ZERO(&MPINU_fdset); /* initialize, MPINU_new_listener() will modify */
  MPINU_new_listener(&sd, &sin, &port);
  MPINU_my_list_sd = sd;
  memcpy( (char *)&(MPINU_pg_array[0].listener_addr),
	  (char *)&sin, sizeof(sin) );

  CALL_CHK(gethostname, (host, 256));
  hp = gethostbyname(host);
  port = ntohs(sin.sin_port);
  sprintf(new_port, "%d", port);
#ifdef DEBUG
  printf("master now listening.\n");
  printf("master port: %d\n", port);
#endif

  sprintf( outfile, "/tmp/pargapmpi-ssh.%d", (int)getpid() );
  MPINU_parse( p4pg_file );             /* read the procgroup file */
  /* create ssh commands and execute them,
     cmd.c:NUM_SLAVES_TO_CREATE_AT_ONCE at a time */
  MPINU_num_slaves = MPINU_set_and_exec_cmds(hp->h_name, new_port,
                                             argc, argv, outfile);

  if (MPINU_num_slaves > SOMAXCONN) {
    printf("WARNING:  This architecture allows only SOMAXCONN=%d connections"
	   " before\n",
	   SOMAXCONN);
    printf(" connections are dropped from the queue.  There are %d slaves.\n",
	   MPINU_num_slaves);
    printf(" Some connections may be lost.\n");
    printf(" (SOMAXCONN is an operating system parameter.)\n");
  }

  for(rank = 1; rank <= MPINU_num_slaves; rank++)
  { fd_set zerofds, readfds;
    struct timeval timeout;
    int is_pending_connection = 0;

    FD_ZERO(&zerofds);
    FD_ZERO(&readfds);
    FD_SET(sd, &readfds);
    timeout.tv_sec = ( rank == 1 ? 120 : SLAVE_INIT_TIMEOUT );
    timeout.tv_usec = 0;
    CALL_CHK(is_pending_connection = select,
               (sd+1, &readfds, &zerofds, &zerofds, &timeout));
    if ( ! is_pending_connection ) {
      MPINU_num_slaves = rank - 1; /* Only rank-1 slaves replied */
      if (MPINU_num_slaves == 0) {
        fprintf( stderr, "*** MPINU:  No slaves replied after 2 minutes.\n" );
        exit(1);
      } else {
        fprintf( stderr, "\n*** MPINU:  Only %d slaves replied after %d sec.\n"
                           "***         (master.c:SLAVE_INIT_TIMEOUT = %d s)\n"
                           "***         Will execute with only %d slaves.\n\n",
                     MPINU_num_slaves, SLAVE_INIT_TIMEOUT, SLAVE_INIT_TIMEOUT,
                     MPINU_num_slaves );
        break;
      }
    }

    fromlen = sizeof(new_sin);
    CALL_CHK( ns = accept, (sd, (struct sockaddr *)&new_sin, &fromlen) );
    MPINU_pg_array[rank].sd = ns;
    FD_SET(ns, &MPINU_fdset);
    if ( ns > MPINU_max_sd )
      MPINU_max_sd = ns;
#ifdef DEBUG
    printf("master:  accepted a connection\n");
    printf("master:  slave %d: new ns:  %d, current MPINU_max_sd: %d\n",
	   rank, ns, MPINU_max_sd);
    strcpy( (char *)&msg1, "MSG #1");
    printf("master msg1: %s\n", (char *)&msg1);
    assert( 7 == send(ns, (char *)&msg1, 7, 0) );
    printf("rank: %d, htonl(rank): %d\n", rank, htonl(rank));
#endif

    /* Recv slave's listener_addr and store in field of MPINU_pg_array[rank] */
    CALL_CHK( MPINU_recvall, (ns, (char *)&(MPINU_pg_array[rank].listener_addr),
	      sizeof(struct sockaddr_in), 0) );
  }

  /* Leave outfile for debugging until all slaves reported back. */
  unlink( outfile );
    
  /* Send all listener_addr fields, other info, to slave */
  { struct sockaddr_in buf[PG_ARRAY_SIZE];
    int rank, i;
    INT nl_buf; /* INT is nl: network long int */

    for ( i=0; i <= MPINU_num_slaves; i++ )
      memcpy( &(buf[i]), (char *)&(MPINU_pg_array[i].listener_addr),
	      sizeof(*buf) );
    for ( rank=1; rank <= MPINU_num_slaves; rank++ ) {
      int tmp;
      msg1.len = htonl(sizeof(msg1));
      msg1.rank = htonl(rank);
      msg1.num_slaves = htonl(MPINU_num_slaves);
      /* Pause between sends or some O/S (Linux kernel 2.4.20 ??) can
       * disconnect socket if many slaves */
      { struct timespec req;
	req.tv_sec = 0;
	req.tv_nsec = 100000000; /* 100 million ns = 0.1 s */
        nanosleep( &req, NULL );
      }
      assert( MPINU_sendall(MPINU_pg_array[rank].sd, (char *)&msg1,
			      sizeof(msg1), 0) == sizeof(msg1) );
      tmp = MPINU_sendall( MPINU_pg_array[rank].sd, (char *)buf,
	          (1+MPINU_num_slaves)*sizeof(*buf), 0 );
      if ( tmp != (1+MPINU_num_slaves)*sizeof(*buf) ) {
        printf("MPINU_mpi_master:  bad send\n"); fflush(stdout); exit(1);
      }
    }

    /* Acknowledge that master and slave are synchronized */
    nl_buf = htonl( sizeof(struct sockaddr_in) );
    for ( i=1; i <= MPINU_num_slaves; i++ ) {
      int tmp =  MPINU_sendall( MPINU_pg_array[i].sd, (void *)&nl_buf,
			      sizeof(nl_buf), 0);
      if (tmp != sizeof(nl_buf) )
	      perror("MPINU_sendall");
      assert (tmp == sizeof(nl_buf) );
    }
  }
}
