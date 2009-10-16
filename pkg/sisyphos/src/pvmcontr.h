/* 	$Id: pvmcontr.h,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: pvmcontr.h,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:57:12  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:30:03  pluto
 * Initial version under RCS control.
 *	 */

typedef struct {
    int nrho;
    int scut;
    int start;
    int end;
    int dim;
    int h1dim;
    int tail_len;
    int count_init;
} BHEADER;

typedef struct {
    int blocks;
    int jobs;
    int h1dim;
} LTI;

typedef struct {
    int job_id;
    int tid;
    int dtid;
    char *j_name;
} JTE;

typedef struct host_info {
    char *name;
    int dtid;
} HINFO;

#define SPVM_BLOCK    701
#define SPVM_JOB      702
#define SPVM_GDATA    703
#define SPVM_NEWHOST  704
#define SPVM_REGISTER 705
#define SPVM_READY    706
#define SPVM_FAILHOST 707
#define SPVM_FINISH   799

#define gid2hname( gid )      Hosts[Gids[(gid)]].name
#define tid2hname( tid )      Hosts[Gids[pvm_getinst("sisyphos",(tid))]].name

void pvm_get_automorphisms 	_(( void ));
void pvm_get_centralizer 	_(( void ));
void pvm_get_all_op_mats 	_(( void ));
void pvm_do_control 		_(( BHEADER *bdesc, VEC block ));
void pvm_set_files 			_(( int from, int to ));
char *pvm_swap_file 		_(( char *name, int section, int j_id, int part, int subpart ));
int get_block_size 			_(( BHEADER *bdesc ));
int get_item_size 			_(( BHEADER *bdesc ));
void pvm_save_block 		_(( char *fname, BHEADER *bdesc, VEC block ));
VEC pvm_read_block 			_(( char *fname, BHEADER **bdesc ));
void pvm_send_block 		_(( int dest, char *group, int index, int j_id, BHEADER *bdesc, VEC block ));
VEC pvm_receive_block 		_(( int *index, int *j_id, BHEADER **bdesc ));
VEC *pvm_split_block 		_(( int parts, int **lnrho, BHEADER *bdesc, VEC block ));
void pvm_get_rho 			_(( VEC rho[], VEC h1[], int n, int fend, BHEADER *bdesc, VEC block ));
void pvm_put_rho 			_(( VEC rho[], VEC h1[], int h1dim, IHEADER *inf_header, FILE *out_f ));
FILE *pvm_put_header 		_(( char *f_name, BHEADER *bdesc ));
void pvm_show_homomorphisms 	_(( GRPDSC *h, BHEADER *bdesc, VEC block, char *file_n ));
void do_pvm	 	    	_(( GRPDSC *h, int from, int to, int lahead, int smallgrpring, int npr ));
void pvm_lift_control 		_(( GRPDSC *h, int first, int last, int lookahead ));
void dowork				_(( int me, int nproc ));
void slave_work               _(( void ));
void master_work              _(( void ));          






