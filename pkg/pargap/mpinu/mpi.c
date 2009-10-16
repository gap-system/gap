#include "mpi.h"
#include "mpiimpl.h"

/* index into MPINU_pg_array is same as process rank in MPI_Comm_world */
struct pg_struct MPINU_pg_array[PG_ARRAY_SIZE];

int MPINU_myrank = 0;
int MPINU_num_slaves;
static int rsh_slaves; /* num orig slaves, not counting MPI_Spawn2() */
int MPINU_coll_comm_flag = 0;
int MPINU_my_list_sd;
fd_set MPINU_fdset;
int MPINU_max_sd;
int MPINU_is_spawn2 = 0; /* Set inside mpi_spawn2 before unexec, then reset */
		/* Used by slave.c to determine if slave from mpi_spawn2 */
int MPINU_is_initialized = 0;

int MPI_Init(argc_ptr, argv_ptr)
int *argc_ptr;
char ***argv_ptr;
{ char *p4pg_file = "procgroup";
  int i, p4pg_flag = 0;

#ifdef DEBUG
  system("hostname");
  printf("entering MPI_Init\n");
  printf(" argc: %d\n", *argc_ptr);
  printf("last argv: %s\n", (*argv_ptr)[*argc_ptr - 1]);
  fflush(stdout);
#endif

  if ( sizeof(INT) != 4 ) {
    printf("sizeof(INT) != 4:  re-define INT in mpiimpl.h\n");
    exit(1);
  }

  if (MPINU_is_initialized) {
    printf("MPI_Init:  can't call MPI_Init after it's already started.\n");
    exit(1);
  }
  for( i = 0; i < PG_ARRAY_SIZE; i++ ) {
    MPINU_pg_array[i].processor = NULL; /* initialize all entries */
    MPINU_pg_array[i].sd = PG_NOSOCKET;
  }

  if ( 0 != strcmp( (*argv_ptr)[*argc_ptr - 1], "-p4amslave" )
       && ! MPINU_is_spawn2 ) {
    for( i = 0; i < *argc_ptr; i++ ) {
      if ( p4pg_flag )
	(*argv_ptr)[i] = (*argv_ptr)[i+2];
      else if ( ! strcmp( (*argv_ptr)[i], "-p4pg" ) ) {
        p4pg_file = (*argv_ptr)[i+1];
        i--;
        *argc_ptr -= 2;
        p4pg_flag = 1;
      }
    }
    if ( p4pg_flag ) (*argv_ptr)[*argc_ptr] = NULL;
#ifdef DEBUG
printf("p4pg_file: %s\n", p4pg_file);fflush(stdout);
#endif
    { struct stat buf;
      if ( 0 != stat( p4pg_file, &buf ) || ! buf.st_mode & S_IFREG
           || ! buf.st_mode & S_IRUSR ) {
        fprintf( stderr, "*** MPINU:  can't read procgroup file:  %s\n",
                 p4pg_file );
        if (  0 != strcmp( p4pg_file, "procgroup" ) ) {
	  fprintf( stderr,
		   "  Either create \"progroup\" in current directory:\n"
		   "    %s/procgroup\n",
		   getcwd( NULL, 256 ) );
	  fprintf( stderr,
		   "  or else add a command line arg:"
                      "  -p4pg  ABSOLUTE_PATH_OF_PROCGROUP_FILE\n");
        }
	return MPI_FAIL; 
      }
    }
    MPINU_mpi_master(p4pg_file, *argc_ptr, *argv_ptr);
    rsh_slaves = MPINU_num_slaves;
  }
  else {  /* else slave */
#ifdef DEBUG
    printf("calling MPINU_mpi_slave(%s, %s): %d\n",
	   (*argv_ptr)[*argc_ptr - 3], (*argv_ptr)[*argc_ptr - 2] );
    fflush(stdout);
#endif
    if ( MPINU_is_spawn2 ) MPINU_mpi_slave( NULL, NULL );
    else {
      MPINU_mpi_slave( (*argv_ptr)[*argc_ptr - 3], (*argv_ptr)[*argc_ptr - 2] );
      (*argv_ptr)[*argc_ptr - 3] = NULL;
      *argc_ptr -= 3;
    }
  }
  MPINU_is_initialized = 1;
  return MPI_SUCCESS;
}

int MPI_Initialized( flag )
     int *flag;
{ *flag = MPINU_is_initialized;
  return MPI_SUCCESS;
}

int MPI_Finalize()
{ int i, statusp;

  MPINU_is_initialized = 0;
  for (i = 0; i<= MPINU_num_slaves; i++)
    if ( MPINU_pg_array[i].sd != PG_NOSOCKET )
      close(MPINU_pg_array[i].sd);
  close(MPINU_my_list_sd);
  if (MPINU_myrank == 0) /* master waits for slaves to finish */
    for (i = 1; i<= rsh_slaves; i++)
      CALL_CHK( wait, (&statusp) );
  return MPI_SUCCESS;
}

/* Fill in all three on exit */
int MPINU_new_listener(sd, sin, port)
int *sd, *port;
struct sockaddr_in *sin;       /* inet info structure            */
{ char host[256];		/* hostname for this process      */
  struct hostent *hp;           /* ptr to host info structure     */
  int i;

  /* use the default protocol 6 = IPPROTO_TCP */
  *sd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  SETSOCKOPT(*sd);
  FD_SET( *sd, &MPINU_fdset );
  if ( *sd > MPINU_max_sd )
    MPINU_max_sd = *sd;
#ifdef DEBUG
  printf("MPINU_new_listener: socket: %d\n", *sd);fflush(stdout);
#endif

  CALL_CHK(gethostname, (host, 256));
  hp = gethostbyname(host);

#if 0
  memset( (char *)sin, (char)0, sizeof(*sin) );
#else
  for ( i = 0; i < (signed)sizeof(*sin); i++ )
    ((char *)sin)[i] = 0;
#endif

  /* Is this next line (h_addr) needed? */
  memcpy( (char *)&(sin->sin_addr), hp->h_addr, hp->h_length);
  sin->sin_port = htons(0);
  sin->sin_family = hp->h_addrtype;
  /* Since INADDR_ANY is 0, zeroing out sin accomplished this, anyway. */
  sin->sin_addr.s_addr = INADDR_ANY;

#if 0
  printf("sin_family (%d) and AF_INET (%d) should compare.\n", sin->sin_family, AF_INET);
  printf("master: hp->h_name: %s\n", hp->h_name);
#endif

  do {
    sin->sin_addr.s_addr = INADDR_ANY;
    CALL_CHK( bind, (*sd, (struct sockaddr *)sin, sizeof(*sin)) );
    /* CALL_CHK sets errno = 0; O/S sometimes assigns a stale address */
  } while(errno == EADDRINUSE);

  /* i acts as dummy for sin_len below */
  i = sizeof(struct sockaddr_in);
  CALL_CHK( getsockname, (*sd, (struct sockaddr *)sin, &i) );
  *port = ntohs(sin->sin_port);
#ifdef DEBUG
  printf("MPINU_new_listener: port: %d == %d; sin_len: %d\n",
	 ntohs(sin->sin_port), *port, i); fflush(stdout);
#endif
  if ( sin->sin_port == 0 ) {
    printf("LISTENER FAILED TO GET NEW PORT!!\n");
    exit(1);
  }

  /* Under SunOS 4.1, SOMAXCONN = 5; Could have slaves re-try after timeout */
  CALL_CHK( listen, (*sd, SOMAXCONN) );
  /* On Solaris 2.6, getsockname (and maybe bind?) zero out sin->sin_addr
    (converting it to localhost for efficiency?); So copy it back in */
  memcpy( (char *)&(sin->sin_addr), hp->h_addr, hp->h_length);
  return 0;
}
