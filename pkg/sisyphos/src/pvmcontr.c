/********************************************************************/
/*                                                                  */
/*  Module	     : PVM Lift control                              */
/*                                                                  */
/*  Description :                                                   */
/*    Main module for pvm versions of lifting routines.             */
/*                                                                  */
/********************************************************************/

/* 	$Id: pvmcontr.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: pvmcontr.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 09:58:27  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Some functions have been moved to other files.
 *
 * Revision 1.2  1995/01/05  17:21:52  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: pvmcontr.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include "config.h"

#include "aglobals.h"
#include "fdecla.h"
#include	"pc.h"
#include	"hgroup.h"
#include	"grpring.h"
#include	"storage.h"
#include  "solve.h"
#include	"pvm3.h"
#include	"pvmcontr.h"
#include	<stdlib.h>
#include  <unistd.h>

void get_op_mats 		_(( void ));
void save_set			_(( void ));
void restore_set		_(( void ));
void small_grpring		_(( VEC mask ));
void prepare_aut         _(( PCGRPDESC *g ));
VEC sn_group_mul		_(( VEC vec1, VEC vec2, int cut ));
VEC sngroup_exp		_(( VEC vector, int power, int cut ));
void memory_usage        _(( void ));
symbol *find_symbol      _(( char *symname ));
int ppot                 _(( int n ));

extern FILE *proto;
extern int verbose;
extern char out_n[13];
extern char in_n[13];
extern FILE *out_f, *in_f;
extern long n_rho[MAXGRAD];
extern int s_int;
extern VEC *l_matrix, *r_matrix;
extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern GRPDSC *h_desc;

extern VEC h1[H1MAX];
extern VEC old_rho[MAXGEN], org_rho[MAXGEN];
extern int cut, fend, prime, card;
extern int start, part_start, rho_dim, dim, dquad;
extern int new_xdim, new_cut;
extern VEC h1_mod;
extern int param_dim, red_param, all_liftable;
extern IHEADER h_in, h_out;
extern int old_xdim;
extern VEC svec;
extern int use_pvm;
extern int elim_central_involutions;

extern HOM *dgroup_auts;
extern OPTION aut_pres_style;

extern VEC *centre;
extern VEC *i_centre;
extern int cent_dim;

#define LIMIT 8
#define SPLITSIZE 1000
#define NPROC 8
#define MAXNPROC 200

extern VEC **lcentre;
extern VEC **li_centre;
extern int *lc_dim;

extern VEC **al_matrix, **ar_matrix;
extern char pvm_in_n[80];
extern char pvm_out_n[80];
extern char pcgroup_lib[256];
extern char group_lib[256];
extern int pcgroup_num, group_num;

static int lif_rho, bad_rho;
static int me;
static char hostname[80];
static int job_num = -1;
static int *tids;             /* array of task id */
static int nproc = 0;
static HINFO *Hosts;
static int Nhosts;
static int *Gids;
static int Gsize;
static int lift_limit = LIMIT;
static int lift_start = 2;
static int start_from_beginning = TRUE;
static int lookahead = 0;
static LTI *ltree_info;

FILE *slavelog;

void pvm_get_automorphisms (void)
{
    int g_gens, i, auts;
    int dest;

    g_gens = group_desc->defs ? GMINGEN : GNUMGEN;
 
    if ( me == 0 ) {
	   prepare_aut ( group_desc );
	   pvm_initsend ( 0 );
	   pvm_pkint ( &dgroup_auts->auts, 1, 1 );
	   pvm_pkint ( &dgroup_auts->inn_log, 1, 1 );
	   pvm_pkint ( &dgroup_auts->out_log, 1, 1 );
	   auts = dgroup_auts->aut_gens_dim[1];
	   pvm_pkint ( &auts, 1, 1);
	   for ( i = 0; i < auts; i++ ) 
		  pvm_pkbyte ( dgroup_auts->aut_gens[1][i], g_gens * GNUMGEN, 1 );
	   for ( i = 2; i <= MAX_ID; i++ )
		  pvm_pkint ( dgroup_auts->stabs[i], auts + 1, 1 ); 
	   pvm_bcast ( "sisyphos", 3000 );
    }
    else {
	   aut_pres_style = IMAGES;
	   dgroup_auts = ALLOCATE ( sizeof ( HOM ) );
	   dest = pvm_gettid ( "sisyphos", 0 );
	   pvm_recv ( dest, 3000 );
	   pvm_upkint ( &dgroup_auts->auts, 1, 1 );
	   pvm_upkint ( &dgroup_auts->inn_log, 1, 1 );
	   pvm_upkint ( &dgroup_auts->out_log, 1, 1 );
	   dgroup_auts->g = group_desc;
	   dgroup_auts->aut_gens = ARRAY ( group_desc->exp_p_class+1, VEC* );
	   dgroup_auts->aut_gens_dim = ARRAY ( group_desc->exp_p_class+1, int );
	   dgroup_auts->out_gens_dim = ARRAY ( group_desc->exp_p_class+1, int );
	   pvm_upkint ( &auts, 1, 1 );
	   dgroup_auts->aut_gens_dim[1] = dgroup_auts->out_gens_dim[1] = auts;
	   dgroup_auts->aut_gens[1] = ARRAY ( auts, VEC );
	   for ( i = 0; i < auts; i++ ) {
		  dgroup_auts->aut_gens[1][i] = ALLOCATE ( g_gens * GNUMGEN );
		  pvm_upkbyte ( dgroup_auts->aut_gens[1][i], g_gens * GNUMGEN, 1 );
	   }
	   dgroup_auts->stabs = ARRAY ( MAX_ID+1, int* );
	   for ( i = 2; i <= MAX_ID; i++ ) {
		  dgroup_auts->stabs[i] = ARRAY ( auts+1, int );
		  pvm_upkint ( dgroup_auts->stabs[i], auts + 1, 1 );
	   }
	   dgroup_auts->elements = TRUE;
	   dgroup_auts->h = NULL;
    }
}

void pvm_get_centralizer (void)
{
    int i, j, xd;
    int dest;

    lcentre = ARRAY ( MAX_ID+1, VEC* );
    li_centre = ARRAY ( MAX_ID+1, VEC* );
    lc_dim = ARRAY ( MAX_ID+1, int );
    
    lcentre[0] = lcentre[1] = lcentre[2] = NULL;
    li_centre[0] = li_centre[1] = li_centre[2] = NULL;

    for ( i = 3; i <= MAX_ID; i++ ) {
	   xd = FILTRATION[i].i_start;
	   if ( me == 0 ) {
		  printf ( "centralizer no. %d\n", i );
		  centralizer ( NGEN_VEC, i, GMINGEN );
		  pvm_initsend ( 0 );
		  pvm_pkint ( &cent_dim, 1, 1 );
		  for ( j = 0; j < cent_dim; j++ ) {
			 pvm_pkbyte ( centre[j], xd, 1 );
			 pvm_pkbyte ( i_centre[j], xd, 1 );
		  }
		  pvm_bcast ( "sisyphos", 2000+i );
	   }
	   else {
		  dest = pvm_gettid ( "sisyphos", 0 );
		  pvm_recv ( dest, 2000+i );
		  pvm_upkint ( &cent_dim, 1, 1 );
		  centre = ARRAY ( cent_dim, VEC );
		  i_centre = ARRAY ( cent_dim, VEC );
		  for ( j = 0; j < cent_dim; j++ ) {
			 centre[j] = ALLOCATE ( xd );
			 i_centre[j] = ALLOCATE ( xd );
			 pvm_upkbyte ( centre[j], xd, 1 );
			 pvm_upkbyte ( i_centre[j], xd, 1 );
		  }
	   }
	   lcentre[i] = centre;
	   li_centre[i] = i_centre;
	   lc_dim[i] = cent_dim;
    }
}

void pvm_get_all_op_mats (void)
{
    int i, j;
    int dest = 0;
    
    al_matrix = ARRAY ( MAX_ID+1, VEC* );
    ar_matrix = ARRAY ( MAX_ID+1, VEC* );
    
    al_matrix[0] = al_matrix[1] = ar_matrix[0] = ar_matrix[1] = NULL;

    /* e = (MAX_ID & 1) == 0 ? MAX_ID >> 1 : (MAX_ID >> 1) + 1; */
    for ( i = 2; i < lift_limit; i++ ) {
	   cut = i<<1;
	   if ( cut > MAX_ID )
		  cut = MAX_ID;
	   start = rho_dim = FILTRATION[i].i_start;
	   fend	= FILTRATION[cut].i_start;
	   dim = fend - start;
	   dquad = dim * dim;
	   l_matrix = ARRAY ( rho_dim, VEC );
	   r_matrix = ARRAY ( rho_dim, VEC );
	   for ( j = rho_dim; j--; ) {
		  l_matrix[j] = ALLOCATE ( dquad );
		  r_matrix[j] = ALLOCATE ( dquad );
	   }
	   
	   if ( me == 0 ) {
		  printf ( "op_mats for ideal no. %d\n", i );
		  get_op_mats();
		  pvm_initsend ( 0 );
		  for ( j = 0; j < rho_dim; j++ ) {
			 pvm_pkbyte ( l_matrix[j], dquad, 1 );
			 pvm_pkbyte ( r_matrix[j], dquad, 1 );
		  }
		  pvm_bcast ( "sisyphos", 1000+i );
		  memory_usage();
	   }
	   else {
		  dest = pvm_gettid ( "sisyphos", 0 );
		  pvm_recv ( dest, 1000+i );
		  for ( j = 0; j < rho_dim; j++ ) {
			 pvm_upkbyte ( l_matrix[j], dquad, 1 );
			 pvm_upkbyte ( r_matrix[j], dquad, 1 );
		  } 
	   }
	   al_matrix[i] = l_matrix;
	   ar_matrix[i] = r_matrix;
    }
}

void pvm_save_global_data (void)
{
    int i, j, scut, g_gens, dquad;
    char name[80];
    char *pvm_root;
    char *pvm_arch;
    FILE *glf;

    g_gens = group_desc->defs ? GMINGEN : GNUMGEN;

    pvm_root = getenv ( "PVM_ROOT" );
    pvm_arch = getenv ( "PVM_ARCH" );
    sprintf ( name, "%s/bin/%s/GLOBAL_DATA", pvm_root, pvm_arch );
    
    glf = fopen ( name, "wb" );
    
    /* several global variables */
    fwrite ( &lift_limit, sizeof ( int ), 1, glf );
    fwrite ( &start_from_beginning, sizeof ( int ), 1, glf );
    fwrite ( &lookahead, sizeof ( int ), 1, glf );

    /* multiplication table */
    for ( i = 0; i < GCARD; i++ )
	   fwrite ( group_ring->mul_table[i], sizeof ( int ), GCARD, glf );

    /* information about automorphism group */
    fwrite ( &dgroup_auts->auts, sizeof ( int ), 1, glf );
    fwrite ( &dgroup_auts->inn_log, sizeof ( int ), 1, glf );
    fwrite ( &dgroup_auts->out_log, sizeof ( int ), 1, glf );
    fwrite ( &dgroup_auts->aut_gens_dim[1], sizeof ( int ), 1, glf );
    for ( i = 0; i < dgroup_auts->aut_gens_dim[1]; i++ )
	   fwrite ( dgroup_auts->aut_gens[1][i], 1, g_gens * GNUMGEN, glf );

    /* information about stabilizing automorphisms */
    for ( i = 2; i <= MAX_ID; i++ )
	   fwrite ( dgroup_auts->stabs[i], sizeof ( int ), dgroup_auts->aut_gens_dim[1]+1, glf );

    /* centralizer data */
    fwrite ( lc_dim, sizeof ( int ), MAX_ID+1, glf );
    for ( i = 3; i <=MAX_ID; i++ ) {
	   for ( j = 0; j < lc_dim[i]; j++ ) {
		  fwrite ( lcentre[i][j], 1, FILTRATION[i].i_start, glf );
		  fwrite ( li_centre[i][j], 1, FILTRATION[i].i_start, glf );
	   }
    }
    
    /* operation matrices */
    for ( i = 2; i < lift_limit; i++ ) {
	   scut = i<<1;
	   if ( scut > MAX_ID )
		  scut = MAX_ID;
	   dquad = FILTRATION[scut].i_start - FILTRATION[i].i_start;
	   dquad *= dquad;
	   for ( j = 0; j < FILTRATION[i].i_start; j++ ) {
		  fwrite ( al_matrix[i][j], 1, dquad, glf );
		  fwrite ( ar_matrix[i][j], 1, dquad, glf );
	   }
    }
    
    fclose ( glf );
}

void pvm_read_global_data (void)
{
    int i, j, scut, g_gens, dquad;
    char name[80];
    char *pvm_root;
    char *pvm_arch;
    FILE *glf;

    g_gens = group_desc->defs ? GMINGEN : GNUMGEN;

    pvm_root = getenv ( "PVM_ROOT" );
    pvm_arch = getenv ( "PVM_ARCH" );
    sprintf ( name, "%s/bin/%s/GLOBAL_DATA", pvm_root, pvm_arch );
    
    glf = fopen ( name, "rb" );
    
    /* several global variables */
    fread ( &lift_limit, sizeof ( int ), 1, glf );
    fread ( &start_from_beginning, sizeof ( int ), 1, glf );
    fread ( &lookahead, sizeof ( int ), 1, glf );

    /* multiplication table */
    group_ring->mul_table = ALLOCATE ( GCARD *sizeof ( int* ) );
    for ( i = 0; i < GCARD; i++ ) {
	   group_ring->mul_table[i] = ALLOCATE ( GCARD * sizeof ( int ) );
	   fread ( group_ring->mul_table[i], sizeof ( int ), GCARD, glf );
    }

    /* information about automorphism group */
    dgroup_auts = ALLOCATE ( sizeof ( HOM ) );
    fread ( &dgroup_auts->auts, sizeof ( int ), 1, glf );
    fread ( &dgroup_auts->inn_log, sizeof ( int ), 1, glf );
    fread ( &dgroup_auts->out_log, sizeof ( int ), 1, glf );
    dgroup_auts->g = group_desc;
    dgroup_auts->aut_gens = ARRAY ( group_desc->exp_p_class+1, VEC* );
    dgroup_auts->aut_gens_dim = ARRAY ( group_desc->exp_p_class+1, int );
    dgroup_auts->out_gens_dim = ARRAY ( group_desc->exp_p_class+1, int );
    fread ( &dgroup_auts->aut_gens_dim[1], sizeof ( int ), 1, glf );
    dgroup_auts->out_gens_dim[1] = dgroup_auts->aut_gens_dim[1];
    for ( i = 0; i < dgroup_auts->aut_gens_dim[1]; i++ ) {
	   dgroup_auts->aut_gens[1][i] = ALLOCATE ( g_gens * GNUMGEN );
	   fread ( dgroup_auts->aut_gens[1][i], 1, g_gens * GNUMGEN, glf );
    }

    /* information about stabilizing automorphisms */
    dgroup_auts->stabs = ARRAY ( MAX_ID+1, int* );
    for ( i = 2; i <= MAX_ID; i++ ) {
	   dgroup_auts->stabs[i] = ARRAY ( dgroup_auts->aut_gens_dim[1]+1, int );
	   fread ( dgroup_auts->stabs[i], sizeof ( int ), dgroup_auts->aut_gens_dim[1]+1, glf );
    }

    /* centralizer data */
    lcentre = ARRAY ( MAX_ID+1, VEC* );
    li_centre = ARRAY ( MAX_ID+1, VEC* );
    lc_dim = ARRAY ( MAX_ID+1, int );
    fread ( lc_dim, sizeof ( int ), MAX_ID+1, glf );
    for ( i = 3; i <=MAX_ID; i++ ) {
	   lcentre[i] = ARRAY ( lc_dim[i], VEC );
	   li_centre[i] = ARRAY ( lc_dim[i], VEC );
	   for ( j = 0; j < lc_dim[i]; j++ ) {
		  lcentre[i][j] = ALLOCATE ( FILTRATION[i].i_start );
		  li_centre[i][j] = ALLOCATE ( FILTRATION[i].i_start );
		  fread ( lcentre[i][j], 1, FILTRATION[i].i_start, glf );
		  fread ( li_centre[i][j], 1, FILTRATION[i].i_start, glf );
	   }
    }
    
    /* operation matrices */
    al_matrix = ARRAY ( MAX_ID+1, VEC* );
    ar_matrix = ARRAY ( MAX_ID+1, VEC* );
    al_matrix[0] = al_matrix[1] = ar_matrix[0] = ar_matrix[1] = NULL;
    for ( i = 2; i < lift_limit; i++ ) {
	   scut = i<<1;
	   if ( scut > MAX_ID )
		  scut = MAX_ID;
	   dquad = FILTRATION[scut].i_start - FILTRATION[i].i_start;
	   dquad *= dquad;
	   al_matrix[i] = ARRAY ( FILTRATION[i].i_start, VEC );
	   ar_matrix[i] = ARRAY ( FILTRATION[i].i_start, VEC );
	   for ( j = 0; j < FILTRATION[i].i_start; j++ ) {
		  al_matrix[i][j] = ALLOCATE ( dquad );
		  ar_matrix[i][j] = ALLOCATE ( dquad );
		  fread ( al_matrix[i][j], 1, dquad, glf );
		  fread ( ar_matrix[i][j], 1, dquad, glf );
	   }
    }
    fclose ( glf );
}

void pvm_send_global_data ( int dest )
{
    int i, j, g_gens, scut, dquad;

    pvm_initsend ( 0 );

    g_gens = group_desc->defs ? GMINGEN : GNUMGEN;

    /* several global variables */
    pvm_pkint ( &lift_limit, 1, 1 );
    pvm_pkint ( &start_from_beginning, 1, 1 );
    pvm_pkint ( &lookahead, 1, 1 );

    /* multiplication table */
    for ( i = 0; i < GCARD; i++ )
	   pvm_pkint ( group_ring->mul_table[i], GCARD, 1 );

    /* information about automorphism group */
    pvm_pkint ( &dgroup_auts->auts, 1, 1 );
    pvm_pkint ( &dgroup_auts->inn_log, 1, 1 );
    pvm_pkint ( &dgroup_auts->out_log, 1, 1 );
    pvm_pkint ( &dgroup_auts->aut_gens_dim[1], 1, 1 );
    for ( i = 0; i < dgroup_auts->aut_gens_dim[1]; i++ )
	   pvm_pkbyte ( dgroup_auts->aut_gens[1][i], g_gens * GNUMGEN, 1 );

    /* information about stabilizing automorphisms */
    for ( i = 2; i <= MAX_ID; i++ )
	   pvm_pkint ( dgroup_auts->stabs[i], dgroup_auts->aut_gens_dim[1]+1, 1 );

    /* centralizer data */
    pvm_pkint ( lc_dim, MAX_ID+1, 1 );
    for ( i = 3; i <=MAX_ID; i++ ) {
	   for ( j = 0; j < lc_dim[i]; j++ ) {
		  pvm_pkbyte ( lcentre[i][j], FILTRATION[i].i_start, 1 );
		  pvm_pkbyte ( li_centre[i][j], FILTRATION[i].i_start, 1 );
	   }
    }
    
    /* operation matrices */
    for ( i = 2; i < lift_limit; i++ ) {
	   scut = i<<1;
	   if ( scut > MAX_ID )
		  scut = MAX_ID;
	   dquad = FILTRATION[scut].i_start - FILTRATION[i].i_start;
	   dquad *= dquad;
	   for ( j = 0; j < FILTRATION[i].i_start; j++ ) {
		  pvm_pkbyte ( al_matrix[i][j], dquad, 1 );
		  pvm_pkbyte ( ar_matrix[i][j], dquad, 1 );
	   }
    }
    pvm_send ( dest, SPVM_GDATA );
}    

void pvm_receive_global_data (void)
{
    int i, j, g_gens, scut, dquad;

    g_gens = group_desc->defs ? GMINGEN : GNUMGEN;

    /* several global variables */
    pvm_upkint ( &lift_limit, 1, 1 );
    pvm_upkint ( &start_from_beginning, 1, 1 );
    pvm_upkint ( &lookahead, 1, 1 );

    /* multiplication table */
    group_ring->mul_table = ALLOCATE ( GCARD *sizeof ( int* ) );
    for ( i = 0; i < GCARD; i++ ) {
	   group_ring->mul_table[i] = ALLOCATE ( GCARD * sizeof ( int ) );
	   pvm_upkint ( group_ring->mul_table[i], GCARD, 1 );
    }

    
    /* information about automorphism group */
    dgroup_auts = ALLOCATE ( sizeof ( HOM ) );
    pvm_upkint ( &dgroup_auts->auts, 1, 1 );
    pvm_upkint ( &dgroup_auts->inn_log, 1, 1 );
    pvm_upkint ( &dgroup_auts->out_log, 1, 1 );
    dgroup_auts->g = group_desc;
    dgroup_auts->aut_gens = ARRAY ( group_desc->exp_p_class+1, VEC* );
    dgroup_auts->aut_gens_dim = ARRAY ( group_desc->exp_p_class+1, int );
    dgroup_auts->out_gens_dim = ARRAY ( group_desc->exp_p_class+1, int );
    pvm_upkint ( &dgroup_auts->aut_gens_dim[1], 1, 1 );
    dgroup_auts->out_gens_dim[1] = dgroup_auts->aut_gens_dim[1];
    dgroup_auts->aut_gens[1] = ARRAY ( dgroup_auts->aut_gens_dim[1], VEC );
    for ( i = 0; i < dgroup_auts->aut_gens_dim[1]; i++ ) {
	   dgroup_auts->aut_gens[1][i] = ALLOCATE ( g_gens * GNUMGEN );
	   pvm_upkbyte ( dgroup_auts->aut_gens[1][i], g_gens * GNUMGEN, 1 );
    }

    /* information about stabilizing automorphisms */
    dgroup_auts->stabs = ARRAY ( MAX_ID+1, int* );
    for ( i = 2; i <= MAX_ID; i++ ) {
	   dgroup_auts->stabs[i] = ARRAY ( dgroup_auts->aut_gens_dim[1]+1, int );
	   pvm_upkint ( dgroup_auts->stabs[i], dgroup_auts->aut_gens_dim[1]+1, 1 );
    }

    /* centralizer data */
    lcentre = ARRAY ( MAX_ID+1, VEC* );
    li_centre = ARRAY ( MAX_ID+1, VEC* );
    lc_dim = ARRAY ( MAX_ID+1, int );
    pvm_upkint ( lc_dim, MAX_ID+1, 1 );
    for ( i = 3; i <=MAX_ID; i++ ) {
	   lcentre[i] = ARRAY ( lc_dim[i], VEC );
	   li_centre[i] = ARRAY ( lc_dim[i], VEC );
	   for ( j = 0; j < lc_dim[i]; j++ ) {
		  lcentre[i][j] = ALLOCATE ( FILTRATION[i].i_start );
		  li_centre[i][j] = ALLOCATE ( FILTRATION[i].i_start );
		  pvm_upkbyte ( lcentre[i][j], FILTRATION[i].i_start, 1 );
		  pvm_upkbyte ( li_centre[i][j], FILTRATION[i].i_start, 1 );
	   }
    }
    
    /* operation matrices */
    al_matrix = ARRAY ( MAX_ID+1, VEC* );
    ar_matrix = ARRAY ( MAX_ID+1, VEC* );
    al_matrix[0] = al_matrix[1] = ar_matrix[0] = ar_matrix[1] = NULL;
    for ( i = 2; i < lift_limit; i++ ) {
	   scut = i<<1;
	   if ( scut > MAX_ID )
		  scut = MAX_ID;
	   dquad = FILTRATION[scut].i_start - FILTRATION[i].i_start;
	   dquad *= dquad;
	   al_matrix[i] = ARRAY ( FILTRATION[i].i_start, VEC );
	   ar_matrix[i] = ARRAY ( FILTRATION[i].i_start, VEC );
	   for ( j = 0; j < FILTRATION[i].i_start; j++ ) {
		  al_matrix[i][j] = ALLOCATE ( dquad );
		  ar_matrix[i][j] = ALLOCATE ( dquad );
		  pvm_upkbyte ( al_matrix[i][j], dquad, 1 );
		  pvm_upkbyte ( ar_matrix[i][j], dquad, 1 );
	   }
    }
}    

/* lift modulo conjugation, pvm version */

void patch_count ( int hlen, int startv, VEC v )
{
    for ( ; hlen--; ) {
	   v[hlen] = startv % GPRIME;
	   startv /= GPRIME;
    }
}

void pvm_do_control ( BHEADER *bdesc, VEC block )
{
	VEC ind_vec, indhead;
	int h1_dim, j, lift;
	int k, nrho;
	BHEADER out_bdesc;
	
	part_start = bdesc->scut;
	cut = part_start<<1;
	if ( cut > MAX_ID )
		cut = MAX_ID;
	new_cut = part_start + 1;

	pvm_set_files ( part_start, new_cut );
	start = rho_dim = FILTRATION[part_start].i_start;
	fend	= FILTRATION[cut].i_start;
	dim = fend - start;
	dquad = dim * dim;
	nrho = bdesc->nrho;
	h1_dim = bdesc->h1dim;

	out_bdesc.start = h_out.old_start = start;
	out_bdesc.end = h_out.old_end = FILTRATION[new_cut].i_start;
	out_bdesc.dim = h_out.old_dim = h_out.old_end - h_out.old_start;
	out_bdesc.nrho = 0;
	out_bdesc.scut = new_cut;
	out_bdesc.h1dim = 0;
	out_bdesc.tail_len = 0;
	out_bdesc.count_init = 0;

	new_xdim = NUMGEN * h_out.old_dim;
	
	fprintf ( slavelog, "part_start = %d \n", part_start );
	fprintf ( slavelog, "cut	   = %d \n", cut );
	fprintf ( slavelog, "new_cut	   = %d \n", new_cut );
	fprintf ( slavelog, "start	   = %d \n", start );
	fprintf ( slavelog, "fend	   = %d \n", fend );
	fprintf ( slavelog, "rho_dim    = %d \n", rho_dim );
	fprintf ( slavelog, "dimension  = %d \n", dim );

	get_centralizer ( new_cut );
	
	x_dim = dim * NUMGEN;
	y_dim = dim * NUMREL;
	absolut = CALLOCATE ( y_dim );
	inhom = CALLOCATE ( x_dim );

	lif_rho = bad_rho = 0;

	/* read file header, write file header of new file */
	h_in.old_dim = bdesc->dim;
	h_in.old_start = bdesc->start;
	h_in.old_end = bdesc->end;
	
	old_xdim = h_in.old_dim * NUMGEN;
	out_f = pvm_put_header ( pvm_out_n, &out_bdesc );
		
	/* get storage for old rhos and transformation matrices */
	for ( j = NUMGEN; j--; ) {
		org_rho[j] = ALLOCATE ( fend );
		old_rho[j] = ALLOCATE ( fend );
	}

	get_all_op_mats ( part_start );
	h1_mod = ALLOCATE ( old_xdim );
	param_dim = red_param = 0;
	all_liftable = TRUE;		

	for ( k = nrho; k--; ) {
		PUSH_STACK();
		if ( verbose )
			printf ( "current block : %d \n\n", k );
		fprintf ( slavelog, "current block : %d \n", k );
		pvm_get_rho ( org_rho, h1, k, fend, bdesc, block );
		ind_vec = CALLOCATE ( h1_dim );
		patch_count ( h1_dim - bdesc->tail_len, bdesc->count_init, ind_vec );
		indhead = ind_vec + ( h1_dim - bdesc->tail_len );
		fprintf ( slavelog, "head of counter (corresponding to %d): ", bdesc->count_init );
		for ( j = 0; j < h1_dim - bdesc->tail_len; j++ )
		    fprintf ( slavelog, "%2d", ind_vec[j] );
		fprintf ( slavelog, "\n" );

		do  {
			for ( j = NUMGEN; j--; ) 
				copy_vector ( org_rho[j], old_rho[j], fend );
			mod_with_h1 ( ind_vec, h1_dim ); 
			lift = try_to_lift ( old_rho );
			if ( lift )
				lif_rho++;
			else
				bad_rho++;
		} while ( inc_count ( indhead, bdesc->tail_len ) );
		POP_STACK();
	}

	out_bdesc.nrho = lif_rho;
	out_bdesc.h1dim = out_bdesc.tail_len = red_param;
	rewind ( out_f );
	fwrite ( &out_bdesc, sizeof ( BHEADER ), 1, out_f );
	fclose ( out_f );

	fprintf ( slavelog, "to FG/I^%2d liftable rho's  : %d \n", new_cut, lif_rho );
	fprintf ( slavelog, "not liftable rho's	        : %d \n", bad_rho );
/*	printf ( "sum of old rho's	        : %d \n\n", n_rho[part_start] ); */
	if ( proto != NULL ) {
		fprintf ( proto, "   to FG/I^%2d liftable rho's : %d \n", new_cut, lif_rho );
		fprintf ( proto, "   not liftable rho's	   : %d \n", bad_rho );
/*		fprintf ( proto, "   sum of old rho's	         : %d \n", n_rho[part_start] ); */
		fprintf ( proto, "   dimension of Z^1(FH,I^%d/I^%d) : %d\n",
			part_start, cut, param_dim );
		fprintf ( proto, "   dimension of H^1(FH,I^%d/I^%d) : %d\n\n",
			part_start, part_start+1, red_param );
	}
	if ( (param_dim == dim * NUMGEN) && (all_liftable == TRUE ) ) {
		puts ( "completely liftable !!!!!" );
		if ( proto != NULL )
			fputs ( "completely liftable !!!!!\n\n", proto );
	}
}



void pvm_set_files ( int from, int to )
{
    char *pvm_root;
    char *pvm_arch;
    
    pvm_root = getenv ( "PVM_ROOT" );
    pvm_arch = getenv ( "PVM_ARCH" );
    sprintf ( pvm_in_n, "%s/bin/%s/ID_%s_%04d_%d", pvm_root, pvm_arch,
		    hostname, from, job_num );
    sprintf ( pvm_out_n, "%s/bin/%s/ID_%s_%04d_%d", pvm_root, pvm_arch,
		    hostname, to, job_num );
}

char *pvm_swap_file ( char *name, int section, int j_id, int part, int subpart )
{
    char *pvm_root;
    char *pvm_arch;
    
    pvm_root = getenv ( "PVM_ROOT" );
    pvm_arch = getenv ( "PVM_ARCH" );
    sprintf ( name, "%s/bin/%s/SW_MASTER_%04d_%05d_%d_%d", pvm_root, pvm_arch,
		     section, j_id, part, subpart );
    return ( name );   	
}

int get_block_size ( BHEADER *bdesc )
{
	return ( bdesc->nrho * NUMGEN * ( bdesc->end + bdesc->h1dim * bdesc->dim ) );
}

int get_item_size ( BHEADER *bdesc )
{
	return ( NUMGEN * ( bdesc->end + bdesc->h1dim * bdesc->dim ) );
}

void pvm_save_block ( char *fname, BHEADER *bdesc, VEC block )
{
	FILE *out_f;
	int blength;
	
	if ( !(out_f = fopen ( fname, "wb" )) ) {
		perror ( "ERROR - couldn't open RHO file for output" );
		return;
	}
	
	fwrite ( bdesc, sizeof ( BHEADER ), 1, out_f );
	blength = get_block_size ( bdesc );
	fwrite ( block, blength, 1, out_f );
	fclose ( out_f );
}

VEC pvm_read_block ( char *fname, BHEADER **bdesc )
{
	FILE *in_f;
	int blength;
	VEC block;
	BHEADER *bd;
	
	if ( !(in_f = fopen ( fname, "rb" )) ) {
	    printf ( "ERROR: host %s file %s\n", hostname, fname );
	    perror ( "ERROR - couldn't open RHO file for input" );
	    return ( NULL );
	}

	bd = ALLOCATE ( sizeof ( BHEADER ) );
	*bdesc = bd;
	fread ( bd, sizeof ( BHEADER ), 1, in_f );
	blength = get_block_size ( bd );
	block = ALLOCATE ( blength );
	fread ( block, blength, 1, in_f );
	fclose ( in_f );
	return ( block );
}
	
void pvm_send_block ( int dest, char *group, int index, int j_id, BHEADER *bdesc, VEC block )
{
	int blength = get_block_size ( bdesc );
	
	pvm_initsend ( 0 );
	pvm_pkint ( &index, 1, 1);
	pvm_pkint ( &j_id, 1, 1 );
	pvm_pkint ( &bdesc->nrho, 1, 1 );
	pvm_pkint ( &bdesc->scut, 1, 1 );
	pvm_pkint ( &bdesc->start, 1, 1 );
	pvm_pkint ( &bdesc->end, 1, 1 );
	pvm_pkint ( &bdesc->dim, 1, 1 );
	pvm_pkint ( &bdesc->h1dim, 1, 1 );
	pvm_pkint ( &bdesc->tail_len, 1, 1 );
	pvm_pkint ( &bdesc->count_init, 1, 1 );
	if ( bdesc->nrho != 0 )
		pvm_pkbyte ( block, blength, 1 );
	if ( group == NULL && dest != -1 )
	    pvm_send ( dest, SPVM_JOB );
	if ( group != NULL )
	    pvm_bcast ( group, SPVM_JOB );
}

VEC pvm_receive_block ( int *index, int *j_id, BHEADER **bdesc )
{
	int blength;
	VEC block;
	BHEADER *bd;
	
	bd = ALLOCATE ( sizeof ( BHEADER ) );
	*bdesc = bd;
	pvm_upkint ( index, 1, 1 );
	pvm_upkint ( j_id, 1, 1 );
	pvm_upkint ( &bd->nrho, 1, 1 );
	pvm_upkint ( &bd->scut, 1, 1 );
	pvm_upkint ( &bd->start, 1, 1 );
	pvm_upkint ( &bd->end, 1, 1 );
	pvm_upkint ( &bd->dim, 1, 1 );
	pvm_upkint ( &bd->h1dim, 1, 1 );
	pvm_upkint ( &bd->tail_len, 1, 1 );
	pvm_upkint ( &bd->count_init, 1, 1 );
	if ( bd->nrho == 0 )
		return ( NULL );
	blength = get_block_size ( bd );
	block = ALLOCATE ( blength );
	pvm_upkbyte ( block, blength, 1 );
	return ( block );
}

VEC *pvm_split_block ( int parts, int **lnrho, BHEADER *bdesc, VEC block )
{
	VEC *bl = ARRAY ( parts + 1, VEC );
	int offset;
	int i;
	int itemlen = get_item_size ( bdesc );
	int partlen, new_nrho;
	
	*lnrho = ARRAY ( parts + 1, int );
	new_nrho = bdesc->nrho / parts;
	partlen = new_nrho * itemlen;
	
	for ( i = 0, offset = 0; i < parts; i++, offset+=partlen ) {
	    (*lnrho)[i] = new_nrho;
	    bl[i] = block + offset;
	}
	if ( ((*lnrho)[parts] = bdesc->nrho % parts) != 0 )
	    bl[parts] = block + offset;
	else
	    bl[parts] = NULL;
	return ( bl );
}

void pvm_get_rho ( VEC rho[], VEC h1[], int n, int fend, BHEADER *bdesc, VEC block )
{
	int partlen = get_item_size ( bdesc );
	int i;
	VEC v;
	
	v = block + n * partlen;
	
	for ( i = NUMGEN; i--; )	{
		copy_vector ( v, rho[i], bdesc->end );
		zero_vector ( rho[i]+bdesc->end, fend - bdesc->end );
		v += bdesc->end;
	}
	for ( i = bdesc->h1dim; i--; ) {
		 h1[i] = v;
		 v += bdesc->dim * NUMGEN;
	}
}

void pvm_put_rho ( VEC rho[], VEC h1[], int h1dim, IHEADER *inf_header, FILE *out_f )
{
	register int i;
	register o_xdim = inf_header->old_dim * NUMGEN;
	
	for ( i = NUMGEN; i--; )
		fwrite ( rho[i], inf_header->old_end, 1, out_f );
	for ( i = h1dim; i--; )
		fwrite ( h1[i], o_xdim, 1, out_f );
	
}

FILE *pvm_put_header ( char *f_name, BHEADER *bdesc )
{
	FILE *out_f;

	out_f = fopen ( f_name, "wb" );

	if ( out_f )
		fwrite ( bdesc, sizeof ( BHEADER ), 1, out_f );
	else
		perror ( "ERROR - couldn't open RHO file for writing" );
	return ( out_f );
}

void pvm_show_homomorphisms ( GRPDSC *h, BHEADER *bdesc, VEC block, char *file_n )
{
	FILE *rho_f;
	VEC v;
	int j;
	GRPDSC *old_p_group;
	int k, rho;
	int n = bdesc->scut;
	int h1_dim;
	
	old_p_group = h_desc;
	set_h_group ( h );

	if ( file_n == NULL )
		rho_f = stdout;
	else {
		file_n = add_path ( "PROTO", file_n );
		rho_f = fopen ( file_n, "w" );
	}

	if ( n > 1 && n < MAX_ID+2 ) {

		fprintf ( rho_f, "\nList of homomorphisms into I^%1d :\n", n );

		fprintf ( rho_f, "length of rho	    : %1d \n", bdesc->end );
		fprintf ( rho_f, "dimension of H1	    : %d \n", bdesc->h1dim );
		fprintf ( rho_f, "start of modification : %d \n", bdesc->start );
		old_xdim = bdesc->dim * NUMGEN;

		v = block;		
		rho = 0;
		fprintf ( rho_f, "number of blocks = %d \n", bdesc->nrho );
		for ( k = bdesc->nrho; k--; ) {
			fprintf ( rho_f, "\n\nrho nr. %d : \n", ++rho );
			for ( j = NUMGEN; j--; ) {
				fprintf ( rho_f, "gen.%1d : ", j );
			     group_write ( v, n, rho_f );
				v += bdesc->end;
			}				
			fprintf ( rho_f, "\nBasis for H1 : \n" );
			h1_dim = bdesc->h1dim;
			while ( h1_dim-- ) {
				for ( j = 0; j < old_xdim; j++ )
					fprintf ( rho_f, "%1d", *(v+j) );
				fprintf ( rho_f, "\n" );
				v += old_xdim;
			}
		}
		if ( rho_f != stdout )
			fclose ( rho_f );
	}
	set_h_group ( old_p_group );
}

/* queue handling routines */

static LISTP job_queue;
static LISTP host_queue;

void init_queue ( LISTP *q )
{
	q->first = q->last = NULL;
}

int is_empty_queue ( LISTP *q )
{
	return ( q->first == NULL && q->last == NULL );
}

int size_queue ( LISTP *q )
{
	int n = 0;
	DYNLIST p;
	
	for ( p = q->first; p != NULL; p = p->next )
		n++;
	return ( n );
}
 
void dump_job_queue (void)
{
    DYNLIST p;
    int i;

    printf ( "jobs currently in queue: " );
    for ( p = job_queue.first,i = 0; p != NULL; p = p->next,i++ );
/*	   printf ( "job no. %2d : %s\n", i, (char *)p->value.gv ); */
    printf ( "%d\n", i );
}

void dump_host_queue (void)
{
    DYNLIST p;
    int i;

    printf ( "hosts currently in queue:\n" );
    for ( p = host_queue.first,i = 0; p != NULL; p = p->next,i++ )
	   printf ( "host no. %2d : %s\n", i, gid2hname ( p->value.intv ) );
}

int get_next_host (void)
{
	int gid;
	DYNLIST p;
	
	if ( host_queue.first == NULL )
		return ( -1 );
	p = host_queue.first;
	gid = p->value.intv;
	if ( host_queue.first == host_queue.last )
		host_queue.first = host_queue.last = NULL;
	else 
		host_queue.first = host_queue.first->next;
	free ( p );
	return ( gid );
}

void put_host_to_queue ( int gid )
{
	DYNLIST nitem;
	
	nitem = malloc ( sizeof ( dynlistitem ) );
	nitem->value.intv = gid;
	nitem->next = NULL;
	if ( host_queue.last == NULL )
		host_queue.last = host_queue.first = nitem;
	else {
		host_queue.last->next = nitem;
		host_queue.last = nitem;
	}
}

void cancel_jobs ( int dtid )
{
    DYNLIST p, q;

    while ( (host_queue.first != NULL) && 
		  (Hosts[host_queue.first->value.intv].dtid == dtid) )
	   get_next_host();

    if ( host_queue.first == NULL )
	   return;

    for ( p = host_queue.first; p->next != NULL; p = p->next ) {
	   if ( Hosts[p->next->value.intv].dtid == dtid ) {
		  q = p->next;
		  p->next = q->next;
		  if ( host_queue.last == q )
			 host_queue.last = p;
		  free ( q );
		  Hosts[p->next->value.intv].dtid = -1;
	   }
    }
}
    
char *get_next_job (void)
{
	char *name;
	DYNLIST p;
	
	if ( job_queue.first == NULL )
		return ( NULL );
	p = job_queue.first;
	name = p->value.gv;
	if ( job_queue.first == job_queue.last )
		job_queue.first = job_queue.last = NULL;
	else
	    job_queue.first = job_queue.first->next;
	free ( p );
	return ( name );
}
	
void put_job_to_queue ( char *name )
{
	DYNLIST nitem;
	
	nitem = malloc ( sizeof ( dynlistitem ) );
	nitem->value.gv = malloc ( strlen ( name ) + 1 );
	strcpy ( (char *)nitem->value.gv, name );
	nitem->next = NULL;
	if ( job_queue.last == NULL )
		job_queue.last = job_queue.first = nitem;
	else {
		job_queue.last->next = nitem;
		job_queue.last = nitem;
	}
}

/* job table routines */


static JTE *job_table = NULL;
static int jt_length = 0;
static int n_active_jobs = 0;

void init_job_table ( int len )
{
	int i;
	
	job_table = ARRAY ( len, JTE );
	jt_length = len;
	for ( i = 0; i < len; i++ ) {
		job_table[i].job_id = job_table[i].tid = job_table[i].dtid = -1;
		job_table[i].j_name = NULL;
	}
}

int schedule_job ( int gid, char *name )
{
    int i, tid;
    static int job_counter = 1;
    
    if ( (tid = pvm_gettid ( "sisyphos", gid )) < 0 ) {
	   printf ( "ERROR: no group member with gid %d !!!\n", gid );
	   return ( -1 );
    }
    for ( i = 0; i < jt_length; i++ )
	   if ( job_table[i].job_id == -1 ) break;
    job_table[i].job_id = ++job_counter;
    job_table[i].tid = tid;
    job_table[i].dtid = pvm_tidtohost ( tid );
    job_table[i].j_name = malloc ( strlen ( name ) + 1 );
    strcpy ( job_table[i].j_name, name );
    n_active_jobs++;
    return ( i );
}

void remove_job ( int index, int j_id )
{
	if ( job_table[index].job_id == j_id ) {
	    job_table[index].job_id = job_table[index].tid = 
		   job_table[index].dtid = -1;
	    free ( job_table[index].j_name );
	    n_active_jobs--;
	}
	else
	    fprintf ( stderr, "Error : job id does not match\n" );
}

void dump_job_table (void)
{
    int i;

    printf ( "job table: %d active jobs\n", n_active_jobs );
    for ( i = 0; i < jt_length; i++ )
	   if ( job_table[i].job_id != -1 )
		  printf ( "%2d: job id: %d, host: %d (%s), job: %s\n",
				 i, job_table[i].job_id, job_table[i].dtid,
				 tid2hname ( job_table[i].tid ), job_table[i].j_name );
}

void requeue_jobs ( int dtid )
{
    int i;
    
    for ( i = 0; i < jt_length; i++ ) {
	   if ( job_table[i].dtid == dtid ) {
		  put_job_to_queue ( job_table[i].j_name );
		  printf ( ">>>> requeued job %s\n", job_table[i].j_name );
		  free ( job_table[i].j_name );
		  job_table[i].job_id = job_table[i].tid = job_table[i].dtid = -1;
		  n_active_jobs--;
	   }
    }
}

int split_heuristic ( BHEADER *bdesc, int *head_len )
{
	int i;
	int modnum, parts;
	
	for ( i = bdesc->h1dim, modnum = 1; i--; ) modnum *= GPRIME;
	
	if ( bdesc->h1dim > 10 ) {
	    i = bdesc->h1dim - 10;
	    *head_len =  i > 7 ? 7 : i;
	}
	else
	    *head_len = 0;
		   
	if ( modnum > SPLITSIZE )
		return ( bdesc->nrho );
	
	parts = (bdesc->nrho * modnum ) / SPLITSIZE;
	return ( parts > 1 ? parts : 1 ); 
}

void pvm_do2 (void)
{
	BHEADER out_bdesc;


	/* handle case I^2 */

	pvm_set_files ( 2, 2 );
	dim = FILTRATION[1].i_dim;
	x_dim = dim;
	y_dim = NUMGEN;
	
	out_bdesc.nrho = 0;
	out_bdesc.scut = 2;
	out_bdesc.dim = 0;
	out_bdesc.start = dim + 1;
	out_bdesc.end = dim + 1;
	out_bdesc.h1dim = out_bdesc.tail_len = out_bdesc.count_init = 0;
	
	out_f = pvm_put_header ( pvm_out_n, &out_bdesc );
	out_bdesc.nrho = test_mod2 ( FALSE );
	rewind ( out_f );
	fwrite ( &out_bdesc, sizeof ( BHEADER ), 1, out_f );
	fclose ( out_f );

	if ( proto != NULL ) 
		fprintf ( proto, "to FG/I^2 liftable rho's : %ld \n\n", n_rho[2] );
	printf ( "to FG/I^2 liftable rho's : %d \n", out_bdesc.nrho );
}

void pvm_lift_control ( GRPDSC *h, int first, int last, int lookahead )
{
	int i, index, j_id, parts;
	GRPDSC *old_p_group;
	int old_cut = cut;
	BHEADER *bdesc;
	VEC block;
	int *lnrho;
	VEC *bls;
	int slave;
	char name[80];
	char *sw_name;

	old_p_group = h_desc;
	set_h_group ( h );

	part_start = first;

	if ( me == 0 ) {
		init_job_table ( MAXNPROC );
		init_queue ( &job_queue );
		init_queue ( &host_queue );
		ltree_info = ARRAY ( MAX_ID+1, LTI );
		for ( i = 0; i <= MAX_ID; i++ )
		    ltree_info[i].blocks = ltree_info[i].jobs = ltree_info[i].h1dim = 0;
		PUSH_STACK();
		job_num = 0;
		if ( start_from_beginning ) {
		    pvm_do2();
		    block = pvm_read_block ( pvm_out_n, &bdesc );
		    remove ( pvm_out_n );
		}
		else
		    block = pvm_read_block ( "/u/pvm3/bin/LINUX/START_BLOCK", &bdesc );
		parts = bdesc->nrho >= nproc-1 ? nproc-1 : bdesc->nrho;
		ltree_info[bdesc->scut].blocks = bdesc->nrho;
		ltree_info[bdesc->scut].jobs = 1;
		ltree_info[bdesc->scut].h1dim = bdesc->h1dim;
		bls = pvm_split_block ( parts, &lnrho, bdesc, block );
		for ( i = 0; i < parts; i++ ) {
			bdesc->nrho = lnrho[i];
			index = schedule_job ( i+1, "INITIAL_JOB" );
			slave = pvm_gettid ( "sisyphos", i+1 );
			j_id = job_table[index].job_id;
			pvm_send_block ( slave, NULL, index, j_id, bdesc, bls[i] );
		}
		printf ( "master has created %d initial jobs\n", nproc-1 );
		if ( lnrho[parts] != 0 ) {
			bdesc->nrho = lnrho[parts];
			sw_name = pvm_swap_file ( name, bdesc->scut, 1, 1, 0 );
			pvm_save_block ( sw_name, bdesc, bls[nproc-1] );
			put_job_to_queue ( sw_name );
			printf ( "master has swapped job %s containing %d items\n",
				    sw_name, bdesc->nrho );
		}
		for ( i = parts; i < nproc-1; i++ )
		    put_host_to_queue ( i );
		POP_STACK();
	}
	pvm_barrier ( "sisyphos", nproc );
	if ( me == 0 ) {
		master_work();
		printf ( "\nSummary:\n" );
		for ( i = 2; i <= MAX_ID; i++ ) 
		    printf ( "   I^%1d: %d blocks, %d jobs, dim(H1) %d\n", i,
				   ltree_info[i].blocks, ltree_info[i].jobs, ltree_info[i].h1dim );
	}
	else
		slave_work();			

	cut = old_cut;
	set_h_group ( old_p_group );
}

void slave_work (void)
{
    int master = pvm_gettid ( "sisyphos", 0 );
    int bufid, nbytes, mstag, tid;
    int index;
    BHEADER *bd;
    VEC block;
    char protname[80], errname[80];
    char *pvm_root;
    char *pvm_arch;
    
    pvm_root = getenv ( "PVM_ROOT" );
    pvm_arch = getenv ( "PVM_ARCH" );
    sprintf ( protname, "%s/bin/%s/LOG_%s", pvm_root, pvm_arch, hostname );
    sprintf ( errname, "%s/bin/%s/ERROR_%s", pvm_root, pvm_arch, hostname );
    printf ( "host %s entering slave loop\n", hostname );
    slavelog = fopen ( protname, "w" );
    /* freopen ( errname, "w", stderr ); */
    setbuf ( slavelog, NULL );
    /* setbuf ( stderr, NULL ); */
    do {
	   bufid = pvm_recv ( master, -1 );
	   pvm_bufinfo ( bufid, &nbytes, &mstag, &tid );
	   
	   switch ( mstag ) {
	   case SPVM_JOB:
		  PUSH_STACK();
		  block = pvm_receive_block ( &index, &job_num, &bd );
		  fprintf ( slavelog, "host %s accepted job no. %i\n", hostname, job_num );
		  pvm_do_control ( bd, block );
		  block = pvm_read_block ( pvm_out_n, &bd );	
		  pvm_send_block ( master, NULL, index, job_num,
					    bd, block );
		  remove ( pvm_out_n );
		  POP_STACK();
		  break;
	   case SPVM_GDATA:
		  fprintf ( slavelog, "host %s is going to receive global data\n", hostname );
		  use_permanent_stack();
		  pvm_receive_global_data();
		  cgroup_mul = tc_group_mul;
		  use_temporary_stack();
		  fprintf ( slavelog, "host %s received global data\n", hostname );
		  pvm_initsend ( 0 );
		  pvm_pkint ( &dgroup_auts->aut_gens_dim[1], 1, 1 );
		  pvm_send ( master, SPVM_READY );
		  break;
	   case SPVM_FINISH:
		  fprintf ( slavelog, "host %s got FINISH message\n", hostname );
		  memory_usage();
		  break;
	   default:
		  fprintf ( slavelog, "host %s got unknown message %d\n", hostname, mstag );
		  break;
	   }
    } while ( mstag != SPVM_FINISH );
    fclose ( slavelog );
}

static int dtids[MAXNPROC];

void master_work (void)
{
	int slave;
	int bufid, nbytes, mstag, gid, parts, i, j;
	int index, j_id, dtid;
	int nh, na, subparts;
	int *tids;
	int nhosts;
	int *ntids;
	char *fname;
	BHEADER *bd;
	VEC block;
	VEC *bls;
	int *lnrho;
	char name[80];
	char *sw_name;
	struct pvmhostinfo *hostp;
	char **args;
	char pcgn[6], gn[6], sfrom[6], slimit[6];

	
	/* spawn new jobs if there are hosts in the waiting queue
	   as long as either the host or job queue gets empty */
	   
	printf ( "master %s entering master loop\n", hostname );

	slavelog = stdout;

	/* we want to be notified if a new host enters the virtual machine */
	if ( pvm_notify ( PvmHostAdd, SPVM_NEWHOST, 1, NULL ) < 0 )
	    printf ( "notify failed!!!\n" );

	/* we want to be notified if a host leaves the virtual machine */
	pvm_config ( &nh, &na, &hostp );
	for ( i = 0; i < nh; i++ )
	    dtids[i] = hostp[i].hi_tid;
	if ( pvm_notify ( PvmHostDelete, SPVM_FAILHOST, nh, dtids ) < 0 )
	    printf ( "notify failed!!!\n" );

	do {
	    printf ( "\nBEGIN OF LOOP\n" );
	    dump_job_queue();
	    dump_host_queue();
	    dump_job_table();
	    while ( !is_empty_queue ( &host_queue ) && 
			  !is_empty_queue ( &job_queue ) ) {
		   PUSH_STACK();
		   gid = get_next_host();
		   slave = pvm_gettid ( "sisyphos", gid );
		   fname = get_next_job();
		   if ( (index = schedule_job ( gid, fname )) != -1 ) {
			  block = pvm_read_block ( fname, &bd );
			  j_id = job_table[index].job_id;
			  pvm_send_block ( slave, NULL, index, j_id, bd, block );
		   }
		   free ( fname );
		   POP_STACK();
	    }
	    bufid = pvm_recv ( -1, -1 );
	    pvm_bufinfo ( bufid, &nbytes, &mstag, &slave );
	    
	    switch ( mstag ) {
	    case SPVM_JOB:
		   printf ( ">>> master received block from %s, ",
				  tid2hname ( slave ) );
		   PUSH_STACK();
		   block = pvm_receive_block ( &index, &j_id, &bd );
		   ltree_info[bd->scut].blocks += bd->nrho;
		   if ( bd->h1dim > 0 )
			  ltree_info[bd->scut].h1dim = bd->h1dim;
		   ++ltree_info[bd->scut].jobs;
		   remove_job ( index, j_id );
		   put_host_to_queue ( pvm_getinst ( "sisyphos", slave ) );
		   parts = split_heuristic ( bd, &i );
		   subparts = ppot ( i );
		   bls = pvm_split_block ( parts, &lnrho, bd, block );
		   printf ( "splitted into %d parts and %d subparts\n", parts, subparts );
		   bd->tail_len = bd->h1dim - i;
		   for ( i = 0; i <= parts; i++ ) {
			  if ( lnrho[i] != 0 ) {
				 bd->nrho = lnrho[i];
				 for ( j = 0; j < subparts; j++ ) {
					bd->count_init = j;
					sw_name = pvm_swap_file ( name, bd->scut, j_id, i, j );
					printf ( "swap name: %s\n", sw_name );
					pvm_save_block ( sw_name, bd, bls[i] );
					if ( bd->scut < lift_limit ) 
					    put_job_to_queue ( sw_name );
					else
					    pvm_show_homomorphisms ( h_desc, bd, bls[i], NULL );
				 }
			  }
		   }	
		   POP_STACK();
		   break;
	    case SPVM_NEWHOST:
		   PUSH_STACK();
		   pvm_upkint ( &nhosts, 1, 1 );
		   ntids = ARRAY ( nhosts, int );
		   pvm_upkint ( ntids, nhosts, 1 );
		   for ( i = 0; i < nhosts; i++ )
			  printf ( ">>> host with dtid no. %d entered virtual machine\n",
					 ntids[i] );
		   pvm_notify ( PvmHostAdd, SPVM_NEWHOST, 1, NULL );
		   pvm_config ( &nh, &na, &hostp );
		   sprintf ( gn, "%d", group_num );
		   tids = ARRAY ( 1, int );
		   args = ARRAY ( 8, char* );
		   args[0] = pcgroup_lib;
		   args[1] = group_lib;
		   sprintf ( pcgn, "%d", pcgroup_num );
		   args[2] = pcgn;
		   sprintf ( gn, "%d", group_num );
		   args[3] = gn;
		   sprintf ( sfrom, "%d", lift_start );
		   args[4] = sfrom;
		   sprintf ( slimit, "%d", lift_limit );
		   args[5] = slimit;
		   args[6] = "0";
		   args[7] = NULL;
		   for ( i = 0; i < nhosts; i++ ) {
			  for ( j = nh; j--; ) {
				 if ( hostp[j].hi_tid == ntids[i] ) {
					if ( pvm_spawn ( "spvm", args, PvmTaskHost, 
							  hostp[j].hi_name, 1, tids ) != 1 )
					    printf ( "ERROR: could not spawn task on host %s\n", hostp[j].hi_name );
				 }
			  }
		   }
		   POP_STACK();
		   break;
	    case SPVM_REGISTER:
		   /* receive gid of new process */
		   pvm_upkint ( &gid, 1, 1 );
		   pvm_upkstr ( name );
		   /* corresponding tid */
		   slave = pvm_gettid ( "sisyphos", gid );
		   Hosts[Nhosts].name = ALLOCATE ( strlen ( name ) + 1 );
		   strcpy ( Hosts[Nhosts].name, name );
		   Hosts[Nhosts].dtid = pvm_tidtohost ( slave );
		   Gids[gid] = Nhosts;
		   Nhosts++;
		   Gsize++;
		   printf ( ">>> host %s with gid %d and tid %d entered group\n",
				  name, gid, slave );
		   pvm_send_global_data ( slave );
		   break;
	    case SPVM_READY:
		   pvm_upkint ( &na, 1, 1 );
		   gid = pvm_getinst ( "sisyphos", slave );
		   if ( na == dgroup_auts->aut_gens_dim[1] ) {
			  put_host_to_queue ( gid );
			  printf ( ">>> host %s with gid %d and tid %d is ready for work\n", gid2hname ( gid ), gid, slave );
		   }
		   else
			  printf ( "got garbled data from host %s\n", gid2hname ( gid ) );
		   break;
	    case SPVM_FAILHOST:
		   pvm_upkint ( &dtid, 1, 1 );
		   for ( i = 0; i < Nhosts; i++ )
			  if ( Hosts[i].dtid == dtid ) {
				 printf ( ">>> host %s with dtid %d left group\n",
						Hosts[i].name, dtid );
				 break;
			  }
		   if ( i == Nhosts )
			  printf ( "ERROR: dtid %d does not match any host!!!, received %d bytes\n", dtid, nbytes );
		   cancel_jobs ( dtid );
		   requeue_jobs ( dtid );
		   pvm_config ( &Nhosts, &na, &hostp );
		   printf ( "---- new configuration ----\n" );
		   for ( i = 0; i < Nhosts; i++ ) {
			  Hosts[i].name = ALLOCATE ( strlen ( hostp[i].hi_name ) + 1 );
			  strcpy ( Hosts[i].name, hostp[i].hi_name  );
			  Hosts[i].dtid = hostp[i].hi_tid;
			  printf ( "    no. %d, name %s, dtid %d\n",
					 i, Hosts[i].name, Hosts[i].dtid );
		   }
		   Gsize =  pvm_gsize ( "sisyphos" );
		   /* recompute gid <-> host mapping */
		   for ( i = 0; i < MAXNPROC; i++ ) {
			  Gids[i] = -1;
			  if ( (slave = pvm_gettid ( "sisyphos", i ) ) > 0 ) {
				 dtid = pvm_tidtohost ( slave );
				 for ( j = 0; j < Nhosts; j++ )
					if ( Hosts[j].dtid == dtid )
					    Gids[i] = j;
			  }
		   }
		   for ( i = 0; i < Nhosts; i++ )
			  dtids[i] = hostp[i].hi_tid;
		   if ( pvm_notify ( PvmHostDelete, SPVM_FAILHOST, Nhosts, dtids ) < 0 )
			  printf ( "notify failed!!!\n" );
		   break;
	    default:
		   sw_name = tid2hname ( slave );
		   printf ( "master %s got unknown message %d from host %s consisting of %d bytes\n", 
				  hostname, mstag, sw_name, nbytes );
		   /* pvm_upkstr ( name );
		   printf ( "message string: %s\n", name ); */
		   break;
	    }
	    printf ( "END OF LOOP\n" );
	} while ( n_active_jobs != 0 || !is_empty_queue ( &job_queue ) );
	pvm_initsend ( 0 );
	pvm_bcast ( "sisyphos", SPVM_FINISH );
}

void dowork( int me, int nproc )
{
    int dest;
    int i, j, dtid, na;
    int **table;
    struct pvmhostinfo *hostp;
    
    dest = pvm_gettid ( "sisyphos", 0 );
    gethostname ( hostname, 80 );

    /* check if this host has been added later */
    if ( nproc < 1 ) {
	   pvm_initsend ( PvmDataDefault );
	   pvm_pkint ( &me, 1, 1 );
	   pvm_pkstr ( hostname );
	   pvm_send ( dest, SPVM_REGISTER );
	   return;
    }

    /* construct multiplication table */
    use_permanent_stack();
    
    if ( me == 0 ) {
	   pvm_initsend ( 0 );
	   pvm_pkint ( &lift_limit, 1, 1 );
	   pvm_pkint ( &start_from_beginning, 1, 1 );
	   pvm_pkint ( &lookahead, 1, 1 );
	   pvm_bcast ( "sisyphos", 9 );
    }
    else {
	   pvm_recv ( dest, 9 );
	   pvm_upkint ( &lift_limit, 1, 1);
	   pvm_upkint ( &start_from_beginning, 1, 1);
	   pvm_upkint ( &lookahead, 1, 1);
    }
    pvm_barrier ( "sisyphos", nproc );
    if ( me == 0 ) {
	   group_ring->mul_table = table = multiplication_table();
	   pvm_initsend ( 0 );
	   for ( i = 0; i < GCARD; i++ )
		  pvm_pkint ( table[i], GCARD, 1 );
	   pvm_bcast ( "sisyphos", 10 );
    }
    else {
	   table = group_ring->mul_table = ALLOCATE ( GCARD *sizeof ( int* ) );
	   pvm_recv ( dest, 10 );
	   for ( i = 0; i < GCARD; i++ ) {
		  table[i] = ALLOCATE ( GCARD * sizeof ( int ) );
		  pvm_upkint ( table[i], GCARD, 1 );
	   } 
    }
    
    pvm_barrier ( "sisyphos", nproc );
    printf ( "past barrier\n" );
    cgroup_mul = tc_group_mul;
    
    pvm_get_all_op_mats();
    pvm_get_centralizer();
    printf ( "computing automorphisms\n" );
    pvm_get_automorphisms();
    pvm_barrier ( "sisyphos", nproc );
    use_temporary_stack();
    
    if( me == 0 ) { 
	   pvm_config ( &Nhosts, &na, &hostp );
	   Hosts = ARRAY ( MAXNPROC, HINFO );
	   for ( i = 0; i < Nhosts; i++ ) {
		  Hosts[i].name = ALLOCATE ( strlen ( hostp[i].hi_name ) + 1 );
		  strcpy ( Hosts[i].name, hostp[i].hi_name  );
		  Hosts[i].dtid = hostp[i].hi_tid;
	   }
	   Gsize = pvm_gsize ( "sisyphos" );
	   Gids = ARRAY ( MAXNPROC, int );
	   for ( i = 0; i < Gsize; i++ ) {
		  dtid = pvm_tidtohost ( pvm_gettid ( "sisyphos", i ) );
		  for ( j = 0; j < Nhosts; j++ )
			 if ( Hosts[j].dtid == dtid )
				Gids[i] = j;
	   }
	   for ( i = Gsize; i < MAXNPROC; i++ )
		  Gids[i] = -1;
	   printf ( "initial setup of virtual machine:\n" );
	   for ( i = 0; i < Gsize; i++ ) 
		  printf ( "-- gid %02d, index %02d, dtid %010d, tid %010d, host %s\n",
				 i, Gids[i], Hosts[Gids[i]].dtid, pvm_gettid ( "sisyphos", i ),
				 Hosts[Gids[i]].name );
	   
    }
}

void do_pvm ( GRPDSC *h, int from, int to, int lahead, int smallgrpring, int npr )
{
    int mytid = -1;                  /* my task id */
    int i;
    char ntstring[10];
    GRPDSC *old_p_group;
    char **args;
    char pcgn[6], gn[6], sfrom[6], slimit[6];
    FILE *log_all = NULL;

    /* Join a group and if I am the first instance */
    /* i.e. me=0 spawn more copies of myself       */

    old_p_group = h_desc;
    set_h_group ( h );
    lift_start = from;
    lift_limit = to > MAX_ID ? MAX_ID : to;
    start_from_beginning = (from <= 2);
    lookahead = lahead;

    if ( smallgrpring ) {
	   group_mul = sn_group_mul;
	   group_exp = sngroup_exp;
	   small_grpring ( NULL );
    }
	
    if ( elim_central_involutions )
	   get_central_involutions ( NGEN_VEC, GMINGEN, MAX_ID );

    me = pvm_joingroup( "sisyphos" );
    printf ( "me = %d mytid = %d\n", me, mytid );

    nproc = npr;
    tids = ARRAY ( npr, int );
    
    /* enroll in pvm */
    mytid = pvm_mytid();
    /* pvm_setopt ( PvmOutputTid, mytid );
    pvm_setopt ( PvmOutputCode, 998 ); */

    if( me == 0 ) {
	   /* catch the output of all spawned tasks */
	   log_all = fopen ( "LOG_TASKS", "w" );
	   /* setbuf ( log_all, NULL ); */
	   pvm_catchout ( log_all );
	   sprintf ( ntstring, "%d", nproc );
	   args = ARRAY ( 8, char* );
	   args[0] = pcgroup_lib;
	   args[1] = group_lib;
	   sprintf ( pcgn, "%d", pcgroup_num );
	   args[2] = pcgn;
	   sprintf ( gn, "%d", group_num );
	   args[3] = gn;
	   sprintf ( sfrom, "%d", lift_start );
	   args[4] = sfrom;
	   sprintf ( slimit, "%d", lift_limit );
	   args[5] = slimit;
	   args[6] = ntstring;
	   args[7] = NULL;
	   printf ( "%d tasks spawned\n", 
			  pvm_spawn("spvm", args, 0, "", nproc-1, &tids[1]));
	   for ( i = 1; i < nproc; i++ )
		  printf ( "tid[%1d] = %d\n", i, tids[i] );

    }

    /* Wait for everyone to startup before proceeding. */
    if ( npr > 0 ) {
	   pvm_barrier( "sisyphos", nproc );
	   printf ( "all jobs started\n" );
	   dowork( me, nproc );
	   pvm_lift_control ( h_desc, 2, 2, 0 );
    }
    else {
	   dowork ( me, nproc ); 
	   slave_work();
    }
    
    /* program finished leave group */
    pvm_lvgroup( "sisyphos" );
    pvm_exit();
    if ( me == 0 )
	   fclose ( log_all );

    if ( smallgrpring ) {
	   group_mul = n_group_mul;
	   group_exp = ngroup_exp;
    }

    set_h_group ( old_p_group );
}


