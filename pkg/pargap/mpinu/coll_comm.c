/* Collective communication implemented by blocking send and receive
   for point-to-point communication.  For an Ethernet-style LAN, it
   would be difficult to do better without significant extra complication.
   These routines use MPI_COLL_COMM_TAG, which is not available to end-user
   programs.  */

#include "mpi.h"
#include "mpiimpl.h"

int MPI_Bcast ( buffer, count, datatype, root, comm )
     void             *buffer;
     int               count;
     MPI_Datatype      datatype;
     int               root;
     MPI_Comm          comm;
{ int dest_rank;
  MPI_Status status;

  MPINU_coll_comm_flag = 1;
  if (MPINU_myrank == root)
    for ( dest_rank = 0; dest_rank <= MPINU_num_slaves; dest_rank++ )
      if ( dest_rank != root )
        MPI_Send(buffer, count, datatype, dest_rank, MPI_COLL_COMM_TAG, comm);
  else
    MPI_Recv(buffer, count, datatype, root, MPI_COLL_COMM_TAG, comm, &status);
  MPINU_coll_comm_flag = 0;
}

MPI_Barrier ( comm )
     MPI_Comm          comm;
{ MPI_Bcast("a", 0, MPI_CHAR, 0, comm); /* count == 0, so buf can be const */
}
