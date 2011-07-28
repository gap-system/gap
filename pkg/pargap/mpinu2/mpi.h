/* This is public portion of mpi.h */

/* Keep C++ compilers from getting confused */
#if defined(__cplusplus)
extern "C" {
#endif

typedef int MPI_Comm;
typedef struct { int MPI_SOURCE;
		 int MPI_TAG;
		 int mpi_size;
	       } MPI_Status;
#define MPI_STATUS_IGNORE ((MPI_Status *)0)

#define MPI_SUCCESS 0
#define MPI_FAIL 1

#define MPI_COMM_WORLD 0
#define MPI_ANY_TAG -1
#define MPI_ANY_SOURCE -1

#define MPI_HOST 1
#define MPI_TAG_UB 2
#define MPI_IO 3
#define MPI_WTIME_IS_GLOBAL 4
#define MPI_PROC_NULL 0

/* Datatypes:  */
/* These must correspond with datatype_size[] in sendrecv.c */
enum MPINU_Datatype {
	MPI_MIN_DATATYPE = 0,
	MPI_CHAR = 1,
	MPI_UNSIGNED_CHAR,
	MPI_BYTE,
	MPI_SHORT,
	MPI_UNSIGNED_SHORT,
	MPI_INT,
	MPI_UNSIGNED,
	MPI_LONG,
	MPI_UNSIGNED_LONG,
	MPI_FLOAT,
	MPI_DOUBLE,
	MPI_LONG_DOUBLE,
	MPI_LONG_LONG_INT,
	MPI_MAX_DATATYPE
};
typedef enum MPINU_Datatype MPI_Datatype;

int MPI_Abort(MPI_Comm comm, int errorcode);
int MPI_Attr_get(MPI_Comm comm, int keyval, void *attribute_val, int *flag);
int MPI_Comm_rank(MPI_Comm comm, int *rank);
int MPI_Comm_size(MPI_Comm comm, int *size);
#define MPI_MAX_ERROR_STRING 20;
int MPI_Error_string(int errorcode, char *string, int *resultlen);
int MPI_Finalize(void);
int MPI_Get_count(MPI_Status *status, MPI_Datatype datatype, int *count);
int MPI_Get_processor_name(char *name, int *resultlen);
int MPI_Init(int *argc_ptr, char ***argv_ptr);
int MPI_Initialized(int *flag);
int MPI_Iprobe(int source, int tag, MPI_Comm comm, int *flag, MPI_Status *status
);
int MPI_Probe(int source, int tag, MPI_Comm comm, MPI_Status *status);
int MPI_Recv(void *buf, int count, MPI_Datatype datatype, int source, int tag, MPI_Comm comm, MPI_Status *status);
int MPI_Send(void *buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm);

#if defined(__cplusplus)
}
#endif
