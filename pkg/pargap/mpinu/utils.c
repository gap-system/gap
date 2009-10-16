#include "mpi.h"
#include "mpiimpl.h"

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
    case MPI_TAG_UB: *(int *)attr_value = ~(1 << (8 * sizeof(INT) - 1) );
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
