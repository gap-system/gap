/********************************************************************/
/*                                                                  */
/*  Module        : Obstruction/Lifting                             */
/*                                                                  */
/*  Description :                                                   */
/*     With this module the obstructions for lifting a homomorphism */
/*     can be computed.                                             */
/*                                                                  */
/********************************************************************/

/* 	$Id: obslif.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: obslif.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 09:37:50  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Minor bugfix in 'try_to_lift'.
 *
 * Revision 1.3  1995/02/16  19:48:24  pluto
 * Added "use_static_matrix" to direct call of GAUSS_ELIMINATE.
 *
 * Revision 1.2  1995/01/05  17:05:57  pluto
 * Changed header to new style.
 *
 * Revision 1.1  1995/01/05  13:02:16  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: obslif.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include <ctype.h>
#include	"pc.h"
#include	"hgroup.h"
#include	"grpring.h"
#include	"storage.h"
#include	"aut.h"
#include	"solve.h"

void apply_aut 		_(( int ind, long nrho, int disp ));
void save_set			_(( void ));
void restore_set		_(( void ));
int handle_central_involutions   _(( int ydim ));

extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern GRPRING *group_ring;
extern int dim, dquad, start, fend, cut;
extern IHEADER h_out;
extern int new_xdim, new_cut;
extern FILE *out_f;
extern int s_int;
extern int param_dim, red_param, all_liftable;
extern int verbose;
extern int elim_grp_aut;
extern int elim_central_involutions;
extern int prime;
extern HOM *dgroup_auts;
extern VEC *rlist;
extern int blocks;
extern int use_pvm;

static int sy_dim, sx_dim;
static VEC sabsolut, sinhom;
static VEC liste[MAXGEN];

void save_set (void)
{
	sy_dim = y_dim;
	sx_dim = x_dim;
	sabsolut = absolut;
	sinhom = inhom;
}

void restore_set (void)
{
	y_dim = sy_dim;
	x_dim = sx_dim;
	absolut = sabsolut;
	inhom = sinhom;
}

void apply_aut ( int ind, long nrho, int disp )
{
	int i, j, k;
	int equal;
	int autord = dgroup_auts->aut_gens_dim[1];
	VEC image[MAXGEN], test[MAXGEN];
	int curr;
	
	for ( j = NUMGEN; j--; )
		test[j] = ALLOCATE ( fend );

	for ( i = 0; i < autord; i += disp ) {
		PUSH_STACK();
		for ( j = NUMGEN; j--; ) {
			image[j] = n_apply ( i, liste[j]+ind*fend, 2 );
/*			n_group_write ( image[j], 2 ); */
		}
		for ( k = ind+1; k < nrho; k++ ) {
			curr = k*fend;
			equal = TRUE;
			for ( j = NUMGEN; j--; ) {
				if ( !(equal &= !memcmp ( liste[j]+curr, image[j], fend ) ) )
					break;
			}
			if ( equal ) {
				liste[0][curr] = 0;
				break;
			}
		}
		POP_STACK();
	}
}
				
long otest_mod2 ( int sublift )
{
	VEC dummy;
	int i, j;
	int curr = 0;
	int num2 = 0;
	int dum_dim;
	long rho_cnt = 0;
	long rem_rho = 0;
	VEC obs;
	VEC help[MAXGEN];
	int all, p;
	int ok = TRUE;
	int isom = TRUE;
	int sub_dim;
	
	if ( sublift )
		sub_dim = NUMGEN;
	else
		sub_dim = dim;
		
	PUSH_STACK();
	cut = 2;
	start = FILTRATION[1].i_start;
	fend   = FILTRATION[2].i_start;

	/* compute order of GL(min_gen,F_p) */
	all = p = 1;
	for ( i = (dim-sub_dim); i--; )
		p *= prime;
	for ( i = 0; i < sub_dim; i++ ) {
		p *= prime;
		all *= ( p - 1 );
	}
	i = sub_dim * ( sub_dim - 1 ) >> 1;
	for ( ;i--; ) all *= prime;
	printf ( "order of GL(%d,F%1d) : %d\n", dim, prime, all );
	
	/* reserve space for homomorphisms */
	for ( i = NUMGEN; i--; )
		liste[i] = ALLOCATE ( all*fend );
	
	PUSH_STACK();
	dum_dim = y_dim * dim;
	dummy = CALLOCATE ( dum_dim );
	dummy[dum_dim-1] = -1;
	absolut = CALLOCATE ( y_dim );
	for ( i = NUMGEN; i--; ) {
		help[i] = ALLOCATE ( fend );
		help[i][0] = 1;
	}
	while ( inc_count ( dummy, dum_dim ) ) {
/*		write_vector ( dummy, dum_dim ); */
		for ( i = NUMGEN; i--; ) {
			copy_vector ( dummy+i*dim, matrix[i], dim );
			copy_vector ( dummy+i*dim, help[i]+1, dim );
		}
		if ( GAUSS_ELIMINATE() == sub_dim || !isom ) {
			if ( !h_desc->is_minimal )
			for ( i = NUMREL; i--; ) {
				obs = obstruct ( RELATION[i], help );
				ok = iszero ( obs+1, fend-1 );
				if ( !ok )
					break;
			}
			if ( ok ) {
				for ( i = NUMGEN; i--; )
					copy_vector ( help[i], liste[i]+rho_cnt*fend, fend );
				rho_cnt++;
			}
		}
	}
	printf ( "rho_cnt = %ld\n", rho_cnt );
	POP_STACK();
	
	/* apply group automorphisms */
	for ( i = 0; i < rho_cnt; i++ ) {
		if ( liste[0][curr] != 0 ) {
			rem_rho++;
			fwrite ( &num2, sizeof ( int ), 1, out_f );
			for ( j = NUMGEN; j--; )
				fwrite ( liste[j]+curr, fend, 1, out_f );
			if ( elim_grp_aut )
				apply_aut ( i, rho_cnt, 1 );
		}
		curr += fend;
	}
	POP_STACK();
	return ( rem_rho );
}

long stest_mod2 ( int sublift )
{
	VEC dummy;
	int i, j;
	int curr = 0;
	int num2 = 0;
	int dum_dim;
	long rho_cnt = 0;
	long rem_rho = 0;
	VEC obs;
	VEC help[MAXGEN];
	int all, p;
	int ok = TRUE;
	int isom = TRUE;
	int sub_dim;
	int class1order = 0;
	
	if ( sublift )
		sub_dim = NUMGEN;
	else
		sub_dim = dim;
		
	PUSH_STACK();
	cut = 2;
	start = FILTRATION[1].i_start;
	fend   = FILTRATION[2].i_start;

	/* compute order of GL(min_gen,F_p) */
	all = p = 1;
	for ( i = (dim-sub_dim); i--; )
		p *= prime;
	for ( i = 0; i < sub_dim; i++ ) {
		p *= prime;
		all *= ( p - 1 );
	}
	i = sub_dim * ( sub_dim - 1 ) >> 1;
	for ( ;i--; ) all *= prime;
	printf ( "order of GL(%d,F%1d) : %d\n", dim, prime, all );
	
	/* reserve space for homomorphisms */
	for ( i = NUMGEN; i--; )
		liste[i] = ALLOCATE ( all*fend );
	
	PUSH_STACK();
	dum_dim = y_dim * dim;
	dummy = CALLOCATE ( dum_dim );
	dummy[dum_dim-1] = -1;
	absolut = CALLOCATE ( y_dim );
	for ( i = NUMGEN; i--; ) {
		help[i] = ALLOCATE ( fend );
		help[i][0] = 1;
	}
	use_static_matrix();
	while ( inc_count ( dummy, dum_dim ) ) {
		for ( i = NUMGEN; i--; ) {
			copy_vector ( dummy+i*dim, matrix[i], dim );
			copy_vector ( dummy+i*dim, help[i]+1, dim );
		}
		if ( GAUSS_ELIMINATE() == sub_dim || !isom ) {
			if ( !h_desc->is_minimal )
			for ( i = NUMREL; i--; ) {
				obs = obstruct ( RELATION[i], help );
				ok = iszero ( obs+1, fend-1 );
				if ( !ok )
					break;
			}
			if ( ok ) {
				for ( i = NUMGEN; i--; )
					copy_vector ( help[i], liste[i]+rho_cnt*fend, fend );
				rho_cnt++;
			}
		}
	}
	printf ( "rho_cnt = %ld\n", rho_cnt );
	POP_STACK();
	
	if ( elim_grp_aut )
		class1order = dgroup_auts->aut_gens_dim[1] / dgroup_auts->aut_gens_dim[2];

	/* apply group automorphisms */
	for ( i = 0; i < rho_cnt; i++ ) {
		if ( liste[0][curr] != 0 ) {
			rem_rho++;
			if ( !use_pvm )
				fwrite ( &num2, sizeof ( int ), 1, out_f );
			for ( j = NUMGEN; j--; )
				fwrite ( liste[j]+curr, fend, 1, out_f );
			if ( elim_grp_aut && (class1order > 1)  )
				apply_aut ( i, rho_cnt, dgroup_auts->aut_gens_dim[2] );
		}
		curr += fend;
	}
	POP_STACK();
	return ( rem_rho );
}

long test_mod2 ( int sublift )
{
	int i;
	int num2 = 0;

	if ( sublift || (h_desc->num_gen != GMINGEN) )
	    return ( stest_mod2 ( sublift ) );

	for ( i = 0; i < blocks; i++ ) {
	    if ( !use_pvm )
		   fwrite ( &num2, sizeof ( int ), 1, out_f );
	    fwrite ( rlist[i], FILTRATION[2].i_start, NUMGEN, out_f );
	}
	return ( blocks );
}

void f_save_rho ( int h1_dim, VEC rho_lif[] )
{
	int i;
	
	if ( !use_pvm )
		fwrite ( &h1_dim, s_int, 1, out_f );
	for ( i = NUMGEN; i--; ) 
		fwrite ( rho_lif[i], h_out.old_end, 1, out_f );
	for ( i = h1_dim; i--; )
		fwrite ( fsolution[i], new_xdim, 1, out_f );
}

int check_next_obs ( VEC args[] )
{
	VEC relobs;
	int i,j;
	char nonzero;
	
	PUSH_STACK();
	for ( i = NUMREL; i--; ) {
		relobs = obstruct ( RELATION[i], args );
		nonzero = 0;
		for ( j = start; j < fend; j++ )
			nonzero |= relobs[j];
		if ( nonzero ) {
			POP_STACK();
			return ( FALSE );
		}
	}
	POP_STACK();
	return ( TRUE );
}

int try_to_lift ( VEC args[] )
{
	int offset, rank, h1_dim, z1_dim;
	register int i, j;
	int grp_aut, ss_gens;
	int lift = FALSE;
	VEC save_z1[H1MAX];

	PUSH_STACK();
	z1_mat ( args, matrix, absolut );
	
	/* compute lifting and Z^1 if possible */
	rank = solve_equations ( x_dim, y_dim );
	
	/* modify rho[i] with special solution */
	if ( rank != -1 ) {
		if ( verbose )
			puts ( ">>>>>>>> liftable <<<<<<<<" );
		offset = x_dim;
		for ( i = NUMGEN; i--; ) {
			offset -= dim;
			copy_vector ( inhom+offset, args[i]+start, dim );
		}
	
		/* get dimension of H^1 and save information about lifted rho */
		z1_dim = param_dim = x_dim - rank;
		if ( verbose )
			printf ( "dimension of Z1 : %d \n", z1_dim );

		/* save Z1 */
		offset = 0;
		for ( i = x_dim; i--; ) {
			if ( fsolution[i] ) {
				save_z1[offset] = ALLOCATE ( new_xdim );
				for ( j = 0; j < NUMGEN; j++ )
					copy_vector ( fsolution[i]+j*dim, 
						save_z1[offset]+j*h_out.old_dim, h_out.old_dim );
				offset++;
			}
		}

		/* get factor out group automorphisms */
		save_set();
		i = ss_gens = grp_aut = handle_conj ( args );
		if ( elim_grp_aut )
		    i = ss_gens = grp_aut = handle_grp_aut ( args, grp_aut );
		if ( elim_central_involutions )
		    i = ss_gens = handle_central_involutions ( i );
		for ( j = z1_dim; j--; )
			copy_vector ( save_z1[j], matrix[(long)i++], new_xdim );
		h1_dim = red_param = complement ( ss_gens, new_xdim, ss_gens+z1_dim );
		restore_set();
		if ( verbose )
			printf ( "dimension of H1 : %d \n", h1_dim );
		f_save_rho ( h1_dim, args );
		lift = TRUE;
	}
	else {
		if ( verbose )
			puts ( "######## not liftable ########" );
		all_liftable = FALSE;
	}
	POP_STACK();
	return ( lift );
}
                 
/* end of module obstruction lifting */

