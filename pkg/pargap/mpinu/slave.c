#include "mpi.h"
#include "mpiimpl.h"

void MPINU_mpi_slave(master_host, port)
char *master_host;      /* master host               */
char *port;             /* port to connect to        */
{
  int sd;                 /* socket descriptor       */
  struct init_msg msg1;
  struct hostent *mhp;  /* ptr to host info structure*/
  struct sockaddr_in sin, list_addr; /* inet info structures */
  int i, size;

  if ( ! MPINU_is_spawn2 ) {
#ifdef DEBUG
    printf("slave: host: %s; port: %s\n", master_host, port);
    fflush(stdout);
#endif

    /* get the host info such as IP address */
    mhp = gethostbyname(master_host);

#if 0
    memset( (char *)&sin, (char)0, sizeof(sin) );
#else
    for ( i = 0; (unsigned int)i < sizeof(sin); i++ )
      ((char *)&sin)[i] = 0;
#endif
  
    /* copy the IP address in hp to sin */  
    memcpy( (char *)&sin.sin_addr, mhp->h_addr, mhp->h_length);

    /* assign port ID */
    sin.sin_port = htons(atoi(port));
#ifdef DEBUG
    printf("slave: sin.sin_port: %d\n", ntohs(sin.sin_port));fflush(stdout);
#endif

    /* specify address type */
    sin.sin_family = mhp->h_addrtype;
#ifdef DEBUG
    printf("sin_family (%d) and AF_INET (%d) should compare.\n", sin.sin_family, AF_INET);fflush(stdout);
#endif
  } /* end: if ( ! MPINU_is_spawn2 ) */

  /* we are using the default protocol 6 = IPPROTO_TCP */
  CALL_CHK( sd = socket, (AF_INET, SOCK_STREAM, IPPROTO_TCP) );
  SETSOCKOPT(sd);

  CALL_CHK( connect,
    (sd, (struct sockaddr *)( MPINU_is_spawn2
			      ? &MPINU_pg_array[0].listener_addr : &sin ),
     sizeof(sin) ) );
  MPINU_is_spawn2 = 0; /* Will never be used again in this call to spawn2(). */
  MPINU_pg_array[0].sd = sd;
  FD_ZERO(&MPINU_fdset); /* initialize, MPINU_new_listener() will modify */
  FD_SET(sd, &MPINU_fdset);
  if ( sd > MPINU_max_sd )
    MPINU_max_sd = sd;

#ifdef DEBUG
  printf("slave:  slave connected\n");fflush(stdout);
  CALL_CHK( recv, (sd, (char *)&msg1, 7, 0) );
  printf("slave msg1: %s\n", &msg1);fflush(stdout);
#endif

  /* slave sets up listener and sends list_addr to master */
  MPINU_new_listener( &MPINU_my_list_sd, &list_addr, &i ); /* Throw away i val */
  FD_SET(MPINU_my_list_sd, &MPINU_fdset);
  send( sd, (char *)&list_addr, sizeof(list_addr), 0);

  CALL_CHK( size = recv, (sd, (char *)&msg1, sizeof(msg1), 0) );
  if (size != sizeof(msg1)) {
    printf("Incomplete message received.\n");
    exit(1);
  }
  if ( ntohl(msg1.len) != sizeof(msg1) ) {
    printf("Size of struct or int not preserved across architectures.\n");
    printf("Either contact maintainer or use homogeneous architecture.\n");
    exit(1);
  }
  MPINU_myrank = ntohl(msg1.rank);
  MPINU_num_slaves = ntohl(msg1.num_slaves);
  if (MPINU_myrank > 100000) {
    printf("error:  Bad rank received: %d\n", MPINU_myrank);
    exit(1);
  }
#ifdef DEBUG
  printf("MPINU_myrank: %d\n", MPINU_myrank);fflush(stdout);
#endif

  /* Set listener_addr field of MPINU_pg_array field on slave */
  for ( i=0; i <= MPINU_num_slaves; i++ )
    CALL_CHK( size = recv, (sd, (char *)&(MPINU_pg_array[i].listener_addr),
                 	    sizeof(struct sockaddr_in), 0) );
  if (size != sizeof(struct sockaddr_in)) {
    printf("Incomplete message received.\n");
    exit(1);
  }
#ifdef DEBUG
for (i=0;i<=MPINU_num_slaves;i++) {
  printf("slave(%d)[%d]: listener port: sin.sin_port: %d\n",
	 MPINU_myrank, i, ntohs(MPINU_pg_array[i].listener_addr.sin_port));
  fflush(stdout); }
#endif
  { INT buf[1];
    /* Acknowledge that master and slave are synchronized */
    CALL_CHK( recv, (sd, (char *)buf, sizeof(INT), 0) );
    if ( ntohl(buf[0]) != sizeof(struct sockaddr_in) ) {
      printf("MPI_Init: slave %d not synchronized.\n", MPINU_myrank);
      exit(1);
    }
#ifdef DEBUG
    printf("MPI_Init: slave %d synchronized.\n", MPINU_myrank);fflush(stdout);
#endif
  }
}
