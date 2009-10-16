#include "mpi.h"
#include "mpiimpl.h"

void MPINU_mpi_master(p4pg_file, argc, argv)
int argc;
char *p4pg_file, *argv[];
{
  int sd, ns;                /* socket descriptors            */
  struct init_msg msg1;
  char new_port[8];         /* port on which master listens, ASCII number */
  int fromlen, rank, port;
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

  sprintf( outfile, "/tmp/pargapmpi-rsh.%d", (int)getpid() );
  MPINU_parse( p4pg_file );             /* read the procgroup file */
  /* create rsh commands and execute them */
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
  { fromlen = sizeof(new_sin);
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
    send(ns, (char *)&msg1, 7, 0);
    printf("rank: %d, htonl(rank): %d\n", rank, htonl(rank));
#endif

    /* Recv slave's listener_addr and store in field of MPINU_pg_array[rank] */
    CALL_CHK( recv, (ns, (char *)&(MPINU_pg_array[rank].listener_addr),
	      sizeof(struct sockaddr_in), 0) );

    msg1.len = htonl(sizeof(msg1));
    msg1.rank = htonl(rank);
    msg1.num_slaves = htonl(MPINU_num_slaves);
    send(ns, (char *)&msg1, sizeof(msg1), 0);
  }

  unlink( outfile );
    
  /* Send listener_addr fields to slave */
  { char buf[PG_ARRAY_SIZE * sizeof(struct sockaddr_in)], *ptr;
    int i;

    ptr = buf;
    for ( i=0; i <= MPINU_num_slaves; i++ ) {
      memcpy( ptr, (char *)&(MPINU_pg_array[i].listener_addr),
	           sizeof(struct sockaddr_in) );
      ptr += sizeof(struct sockaddr_in);
    }
    for ( i=1; i <= MPINU_num_slaves; i++ )
      send( MPINU_pg_array[i].sd, buf,
	    (1+MPINU_num_slaves)*sizeof(struct sockaddr_in), 0 );

    /* Acknowledge that master and slave are synchronized */
    *((INT *)buf) = htonl( sizeof(struct sockaddr_in) );
    for ( i=1; i <= MPINU_num_slaves; i++ )
      send( MPINU_pg_array[i].sd, buf, sizeof(INT), 0);
  }
}
