#include "mpi.h"
#include "mpiimpl.h"

#define WORKTAG		1
#define DIETAG		2

void master(), slave();

int main(argc, argv)

int			argc;
char			*argv[];

{	int myrank; /* SunOS has problems with this local decl. */

	MPI_Init(&argc, &argv);		/* initialize MPI */
	MPI_Comm_rank(MPI_COMM_WORLD,	/* always use this */
			&myrank);	/* process rank, 0 thru N-1 */
printf("MPI_Init done on %d; %d cmd line args\n", myrank, argc);fflush(stdout);
	if (myrank == 0) {
		master();
	} else {
		slave();
	}
	MPI_Finalize();			/* cleanup MPI */
	exit(0);
}

void master()

{
	int		ntasks, rank, work, iter=1;
	double		result;
	MPI_Status	status;

	MPI_Comm_size(MPI_COMM_WORLD,	/* always use this */
			&ntasks);	/* #processes in application */

#if 0
	for (rank = 1; rank < ntasks; ++rank) {
		MPI_Recv(&result, 1, MPI_DOUBLE, MPI_ANY_SOURCE,
				MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	      }
#endif
/*
 * Seed the slaves.
 */
	for (rank = 1; rank < ntasks; ++rank) {

		work = 17 /* get_next_work_request */;

		MPI_Send(&work,		/* message buffer */
			1,		/* one data item */
			MPI_INT,	/* data item is an integer */
			rank,		/* destination process rank */
			WORKTAG,	/* user chosen message tag */
			MPI_COMM_WORLD);/* always use this */
	}
/*
 * Receive a result from any slave and dispatch a new work request
 * work requests have been exhausted.
 */
	work = 17 /* get_next_work_request */;

	while ( iter-- /* valid new work request */) {

		MPI_Recv(&result,	/* message buffer */
			1,		/* one data item */
			MPI_DOUBLE,	/* data item is a double real */
			MPI_ANY_SOURCE,	/* receive from any sender */
			MPI_ANY_TAG,	/* receive any type of message */
			MPI_COMM_WORLD,	/* always use this */
			&status);	/* info about received message */

		MPI_Send(&work, 1, MPI_INT, status.MPI_SOURCE,
				WORKTAG, MPI_COMM_WORLD);

		work = 17 /* get_next_work_request */;
	}
/*
 * Receive results for outstanding work requests.
 */
	for (rank = 1; rank < ntasks; ++rank) {
		MPI_Recv(&result, 1, MPI_DOUBLE, MPI_ANY_SOURCE,
				MPI_ANY_TAG, MPI_COMM_WORLD, &status);
#ifdef DEBUG
printf("hello_mpi: master: received result for rank %d.\n", rank); fflush(stdout);
#endif
	}

#if 0
	{ int i;
	  for (i = 0; i < 120; ++i) {
            if (poll_new_slaves())
              MPI_Spawn2();
            sleep(1);
          }
	}
#endif
/*
 * Tell all the slaves to exit.
 */
	for (rank = 1; rank < ntasks; ++rank) {
		MPI_Send(0, 0, MPI_INT, rank, DIETAG, MPI_COMM_WORLD);
	}
}

void slave()

{
	double		result;
	int		work;
	MPI_Status	status;

        {int any = 45;
	 if ( (MPINU_myrank == 1) && (MPINU_num_slaves >= 2) )
	   MPI_Send(&any, 1, MPI_INT, 2, WORKTAG, MPI_COMM_WORLD); }
        {int any = 0;
         MPI_Status status;
	 if (MPINU_myrank == 2) {
           fd_set MPINU_fdset5;

           printf("SLAVE 2 starting\n");fflush(stdout);
           printf("MPINU_my_list_sd: %d, MPINU_max_sd: %d\n",
		  MPINU_my_list_sd, MPINU_max_sd);
	   FD_ZERO(&MPINU_fdset5);
	   FD_SET(MPINU_my_list_sd, &MPINU_fdset5);
	   CALL_CHK( select, (MPINU_max_sd+1, &MPINU_fdset5,NULL,NULL,NULL) );
	   printf("accept would have succeeded\n");fflush(stdout);
	   MPI_Recv(&any, 1, MPI_INT, 1, WORKTAG, MPI_COMM_WORLD, &status);
           printf("SLAVE 2 received %d (45 is right)\n", any);fflush(stdout);
         }
       }

#if 0
	for (rank = 1; rank < ntasks; ++rank) {
		result = 23 /* do the work */;
		MPI_Send(&result, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
      }
#endif
	MPI_Probe( 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	{int i; MPI_Get_count(&status, 1, &i); printf("hello: count: %d\n", i);}
        {int i, flag; MPI_Attr_get( MPI_COMM_WORLD, MPI_TAG_UB, &i, &flag );
          printf("MPI_TAG_UB: %d; flag: %d\n", i, flag); }
	MPI_Probe( 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	for (;;) {
		MPI_Recv(&work, 1, MPI_INT, 0, MPI_ANY_TAG,
				MPI_COMM_WORLD, &status);
/*
 * Check the tag of the received message.
 */
#ifdef DEBUG
printf("hello_mpi: slave: work: %d; status.MPI_TAG: %d\n", work, status.MPI_TAG);fflush(stdout);
#endif
		if (status.MPI_TAG == DIETAG) {
			return;
		}
#ifdef DEBUG
printf("hello_mpi: slave: work continuing\n");fflush(stdout);
#endif

		result = 23 /* do the work */;
		MPI_Send(&result, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
#ifdef DEBUG
printf("hello_mpi: slave: message sent\n");fflush(stdout);
#endif
	}
}
