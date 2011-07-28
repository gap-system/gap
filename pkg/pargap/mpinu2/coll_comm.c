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
