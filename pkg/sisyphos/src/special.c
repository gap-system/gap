/* mostly used for debug and test routines */

/* 	$Id: special.c,v 1.2 2000/10/31 12:01:48 gap Exp $	 */
/* 	$Log: special.c,v $
/* 	Revision 1.2  2000/10/31 12:01:48  gap
/* 	changed the line
/* 	
/* 	    FILE *pres_file = stdout;
/* 	
/* 	to
/* 	
/* 	    FILE *pres_file;
/* 	
/* 	(Only `show_pres' seems to be called from outside,
/* 	and this function initializes `pres_file'.)
/* 	Afterwards the package copiles nicely.
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/07/03 11:35:24  pluto
 * 	Changed output routines to support p-groups with p > 2.
 *
 * 	Revision 3.0  1995/06/23 09:54:16  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Output routines for GAP format are now more flexible.
 *
 * Revision 1.2  1995/01/05  17:18:01  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: special.c,v 1.2 2000/10/31 12:01:48 gap Exp $";
#endif /* lint */

# include	"aglobals.h"
# include	"storage.h"
# include	"pc.h"
# include	"fdecla.h"
# include	"grpring.h"
# include	<stdlib.h>

void get_pc_pres 			_(( void ));
VEC mult_comm 				_(( VEC u1, VEC u2, int mod_id ));
symbol *find_symbol 		_(( char *symname ));
void init_gl2				_(( int dim ));
void test_ag				_(( void ));
VEC gr_invers 				_(( VEC elem, int mod_id ));
void gr_decompose             _(( VEC elem, int mod_id, char *gname ));
void show_pres 			_(( int mod_id, char *name, int def_gens, char *file_n ));
int psi 					_(( int n, int m, int k ));
VEC *triv_mod 				_(( int dim, int numgen ));
void two_coboundaries 		_(( PCGRPDESC *g_desc, VEC g_op[], int dim ));
VEC gr_factor_set             _(( void ));

extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern int cut, end, prime;
extern int small_groupring;
extern VEC svec;

VEC *generators;
int *startg;
FILE *pres_file;
DSTYLE presentation_type;

int is_new ( VEC vector, int s, int e )
{
	int i;
	VEC help;
	int res = TRUE;
	
	PUSH_STACK();
	help = ALLOCATE ( GCARD );
	for ( i = s; i < e; i++ ) {
		copy_vector ( vector, help, GCARD );
		SUBB_VECTOR ( generators[i], help, GCARD );
		if ( (res = !iszero ( help, GCARD ) ) == FALSE )
			break;
	}
	POP_STACK();
	return ( res );
}

void get_pc_pres (void)
{
	int i, j;
	int bg, class;
	VEC help;
	char *old_top;
	
	generators = ARRAY ( 6000, VEC );
	startg = ARRAY ( cut, int );
	startg[0] = 0;
	generators[0] = CALLOCATE ( GCARD );
	generators[0][0] = generators[0][3] = 1;
	generators[1] = CALLOCATE ( GCARD );
	generators[1][0] = generators[1][2] = 1;
	generators[2] = CALLOCATE ( GCARD );
	generators[2][0] = generators[2][1] = 1;
	generators[3] = CALLOCATE ( GCARD );
	generators[3][0] = generators[3][6] = 1;
	generators[4] = CALLOCATE ( GCARD );
	generators[4][0] = generators[4][7] = 1;
	generators[5] = CALLOCATE ( GCARD );
	generators[5][0] = generators[5][8] = 1;
	generators[6] = CALLOCATE ( GCARD );
	generators[6][0] = generators[6][15] = 1;
	n_group_write ( generators[0], cut );
	n_group_write ( generators[1], cut );
	n_group_write ( generators[2], cut );
	n_group_write ( generators[3], cut );
	n_group_write ( generators[4], cut );
	n_group_write ( generators[5], cut );
	n_group_write ( generators[6], cut );
	startg[1] = bg = 7;
	
	for ( class = 1; class < 4; class++ ) {
		printf ( "\nclass %d:\n", class );
		for ( i = startg[class-1]; i < startg[class]; i++ ) {
			for ( j = 0; j < i; j++ ) {
				old_top = GET_TOP();
				help = mult_comm ( generators[i], generators[j], cut );
				if ( (!iszero ( help+1, GCARD-1 )) && is_new ( help, startg[class], bg )  ) {
					generators[bg++] = help;
					old_top = GET_TOP();
				}
				else
					SET_TOP ( old_top );
			}
		}
		startg[class+1] = bg;
		for ( i = startg[class]; i < startg[class+1]; i++ )
			n_group_write ( generators[i], cut );
	}
}

void print_lis (void)
{
	VEC help;
	int i;
	
	help = ALLOCATE ( GCARD );
	help[0] = 1;
	for ( i = 1; i < GCARD; i++ ) {
		zero_vector ( help+1, GCARD-1 );
		help[i] = 1;
		printf ( "no. %2d ", i );
		n_group_write ( help, cut );
	}
}

VEC *liste;

VEC compare_res ( VEC res, VEC index, int mod_id )
{
	int i;
	VEC help, prod, help2;
	int end = FILTRATION[mod_id].i_start;
	
	PUSH_STACK();
	zero_vector ( index, end );
	prod = CALLOCATE ( end );
	prod[0] = 1;
	help = ALLOCATE ( end );
	
	do {
		copy_vector ( res, help, end );
		SUBB_VECTOR  ( prod, help, end );
		if ( !iszero ( help, end ) ) {
			for ( i = 1; i < end; i++ ) {
				if ( help[i] != 0 ) {
					break;
				}
			}
			index[i] = ADD ( index[i], 1 );
			PUSH_STACK();
			help2 = GROUP_MUL ( prod, liste[i], mod_id );
			copy_vector ( help2, prod, end );
			POP_STACK();
		}
	} while ( !iszero ( help, end ) );
	POP_STACK();
	return ( index );
}

void output_prae ( int len, int start, int unitgrp, int mod_id, char *name )
{
	int i;
	char gs[5];
	int isfirst;
	
	if ( presentation_type == GAP ) {
		if ( unitgrp ) {
			for ( i = start; i < len; i++ ) {
			    if ( !small_groupring || (svec[i] != 0) ) {
				   sprintf ( gs, "g%1d", i );
				   fprintf ( pres_file, "#I %4s <-> ", gs );
				   group_write ( liste[i], mod_id, pres_file );
			    }
			}
			fprintf ( pres_file, "#I\n" );
		}
		for ( i = start; i < len; i++ )
		    if ( !small_groupring || (svec[i] != 0) )
			   fprintf ( pres_file, "g%1d := AbstractGenerator ( \"g%1d\" );;\n", i, i );
		fprintf ( pres_file, "%s := AgGroupFpGroup ( rec (\n", name );
		fprintf ( pres_file, "     generators := [" );
		isfirst = TRUE;
		for ( i = start; i < len; i++ )
		    if ( !small_groupring || (svec[i] != 0) )
			   if ( isfirst ) {
				  fprintf ( pres_file, "g%1d", i );
				  isfirst = FALSE;
			   }
			   else
				  fprintf ( pres_file, ",g%1d", i );
		fprintf ( pres_file, "],\n     relators := [\n" );
	}
}

void output_post ( int len, int start, int def_gens, char *name )
{
    int i;

    if ( presentation_type == GAP )
	   fprintf ( pres_file, "] ) );\n" );
    if ( def_gens )
	   for ( i = start; i < len; i++ )
		  fprintf ( pres_file, "g%1d := %s.%1d;;\n", i, name, i );
}
		
void output_relation ( VEC index, int e1, int e2, int is_pow, int len,
				   int start )
{
	int k, first;
	char val;
	
	if ( is_pow ) {
	    if ( e1 > start )
		   fprintf ( pres_file, ",\n" );
	    fprintf ( pres_file, "g%1d^%1d", e1, GPRIME );
	    if ( !iszero ( index+start, len-start) ) {
		   if ( presentation_type == GAP )
			  fprintf ( pres_file, "/(" );
		   else 
			  fprintf ( pres_file, "=" );
		   first = TRUE;
		   for ( k = 0; k < len; k++ ) {
			  if ( (val=index[k]) != 0 ) {
				 if ( first ) {
					fprintf ( pres_file, "g%1d", k );
					  first = FALSE;
				 }
				 else
					fprintf ( pres_file, "*g%1d", k );
				 if ( val != 1 )
					fprintf ( pres_file, "^%1d", val );
			    }
		   }
		   if ( presentation_type == GAP )
			  fprintf ( pres_file, ")" );
	    }
	}
	else {
	    if ( iszero ( index+start, len-start ) )
		   /* nothing to do */
		   return;
	    
		if ( presentation_type == GAP )
		    fprintf ( pres_file, ",\nComm(g%1d,g%1d)/(", e1, e2 );
		else
		    fprintf ( pres_file, "[g%1d,g%1d]=", e1, e2 );
	    first = TRUE;
	    for ( k = 0; k < len; k++ ) {
		   if ( (val=index[k]) != 0 ) {
			  if ( first ) {
				 fprintf ( pres_file, "g%1d", k );
				 first = FALSE;
			  }
			  else
				 fprintf ( pres_file, "*g%1d", k );
			  if ( val != 1 )
				 fprintf ( pres_file, "^%1d", val );
		   }
	    }
	    if ( presentation_type == GAP )
		   fprintf ( pres_file, ")" );
	}		
}

void show_pres ( int mod_id, char *name, int def_gens, char *file_n )
{
	int i, j;
	VEC res, index;
	int end;
	
	if ( mod_id > cut )
		mod_id = cut;
	if ( file_n == NULL )
		pres_file = stdout;
	else {
		pres_file = fopen ( file_n, "w" );
	}

	if ( mod_id < 2 ) {
		fprintf ( pres_file, "%s := CyclicGroup ( AgWords, 1 );\n", name );
		if ( pres_file != stdout )
			fclose ( pres_file );
		return;
	}

	end = FILTRATION[mod_id].i_start;
	PUSH_STACK();
	presentation_type = GAP;

	liste = ARRAY ( end, VEC );
	for ( i = 0; i < end; i++ ) {
		liste[i] = CALLOCATE ( end );
		liste[i][0] = liste[i][i] = 1;
	}

	output_prae ( end, 1, TRUE, mod_id, name );

	index = ALLOCATE ( end );
	for ( i = 1; i < end; i++ ) {
	    if ( !small_groupring || (svec[i] != 0 ) ) {
		   PUSH_STACK();
		   res = GROUP_EXP ( liste[i], GPRIME, mod_id );
		   output_relation ( compare_res ( res, index, mod_id ), i, 0, 
						 TRUE, end, 1 );
		   POP_STACK();
	    }
	}

	for ( i = 2; i < end; i++ ) {
		for ( j = 1; j < i; j++ ) {
		    if ( !small_groupring || ((svec[i] != 0 ) && (svec[j] != 0)) ) {
			   PUSH_STACK();
			   res = mult_comm ( liste[i], liste[j], mod_id );
			   if ( !iszero ( res+1, end-1) ) {
				  output_relation ( compare_res ( res, index, mod_id ), i,
								j, FALSE, end, 1 );
			   }
			   POP_STACK();
		    }
		}
	}
	output_post ( end, 1, def_gens, name );
	if ( pres_file != stdout )
		fclose ( pres_file );
	POP_STACK();
}

PCELEM rand_word (void)
{
	PCELEM w;
	int j, e;
	
	w = IDENTITY;
	for ( j = 0; j < GNUMGEN; j++ ) {
		e = rand() % prime;
		w[j] = e;
	}
	return ( w );
}
	
void do_colltest (void)
{
	int generators;
	int i, olde, newe;
	int number_of_tests;
	PCELEM z1, z2;
	PCELEM *xlist, *ylist;
	int *neww, *oldw;
	symbol *s;
	
	printf ( "number of tests : " );
	scanf ( "%d", &number_of_tests );
	
	s = find_symbol ( "g" );
	set_main_group ( (PCGRPDESC *)s->object );
	generators  = group_desc->num_gen;

	xlist = ARRAY ( number_of_tests, PCELEM );
	ylist = ARRAY ( number_of_tests, PCELEM );
	neww = ARRAY ( generators, int );
	for ( i = 0; i < generators; i++ )
		neww[i] = 1;
	
	oldw = group_desc->pc_weight;
	for ( i = 0; i < number_of_tests; i++ ) {
		xlist[i] = rand_word();
		ylist[i] = rand_word();
	}
	newe = generators;
	olde = group_desc->exp_p_class;
	
	for ( i = 0; i < number_of_tests; i++ ) {
		PUSH_STACK();
		z1 = monom_mul ( xlist[i], ylist[i] );
		group_desc->pc_weight = neww;
		group_desc->exp_p_class = newe;
		z2 = monom_mul ( xlist[i], ylist[i] );
		group_desc->pc_weight = oldw;
		group_desc->exp_p_class = olde;
		SUBB_VECTOR ( z1, z2, generators );
		if ( !iszero ( z2, generators ) )
			fprintf ( stderr, "not identical !!!!\n" );
		POP_STACK();
	}
}

void check_conjugacy_classes ( int n )
{
	SPACE *cent;
	int i, j, mdim, e;
	VEC *vlist;

	PUSH_STACK();
	vlist = ARRAY ( 1, VEC );
	vlist[0] = ALLOCATE ( GCARD );
	mdim = 0;

	for ( i = 0; i < n; i++ ) {
		PUSH_STACK();
		
		for ( j = 0; j < GCARD; j++ ) {
			e = rand() % prime;
			vlist[0][j] = e;
		}
		cent = e_centralizer ( vlist, 1, MAX_ID );
		/* printf ( "dim(cent): %d\n", cent->dimension ); */
		if ( (cent->dimension < GCARD) && ( cent->dimension > mdim ) ) 
			mdim = cent->dimension;
		POP_STACK();
	}
	printf ( "maximum: %d\n", GCARD-mdim );
}		

	
int get_next_section ( int start )
{
	int elab = TRUE;
	int i = start;
	int c, j;
	
	while ( elab && i > 0 ) {
		for ( j = i+1; j <= start; j++ ) {
			c = CN(j,i);
			if ( group_desc->c_list[c] != NULL && 
				group_desc->c_list[c][0].g <= start ) {
				elab = FALSE;
				break;
			}
		}
		if ( group_desc->p_list[i] != NULL && 
			group_desc->p_list[i][0].g <= start )
			elab = FALSE;
		i--;
	}
	return ( i );
}

int max_elab_section ( int start )
{
	int i;
	int e_end = GNUMGEN-1;
	int c, j;
	
	for ( i = start; i <= e_end; i++ ) {
		for ( j = i+1; j <= e_end; j++ ) {
			c = CN(j,i);
			if ( group_desc->c_list[c] != NULL && 
				group_desc->c_list[c][0].g <= e_end ) {
				e_end = group_desc->c_list[c][0].g - 1;
			}
		}
		if ( group_desc->p_list[i] != NULL && 
			group_desc->p_list[i][0].g <= e_end )
				e_end = group_desc->p_list[i][0].g - 1;
	}
	return ( e_end );
}

int get_section ( int ind )
{
	int i = EXP_P_CLASS;
	
	while ( EXP_P_LCS[i].i_start > (ind+1) ) i--;
	return ( i );
}

void show_elab_inf (void)
{
	int i, j, c;
	symbol *s;
	
	s = find_symbol ( "g" );
	set_main_group ( (PCGRPDESC *)s->object );

	for ( i = EXP_P_CLASS; i >= 1; i-- ) {
		j = max_elab_section ( EXP_P_LCS[i].i_start );
		c = get_section ( j );
		printf ( "section: %d, start: %d, end: %d, class: %d, cend: %d\n",
			i, EXP_P_LCS[i].i_start, j, c,
			EXP_P_LCS[c].i_end );
	}
}

void gr_decompose ( VEC elem, int mod_id, char *gname )
{
	int len = FILTRATION[mod_id].i_start;
	int last, first, expo;
	VEC help, rest;
	
	PUSH_STACK();
	rest = ALLOCATE ( len );
	help = CALLOCATE ( len );
	copy_vector ( elem, rest, len );
	
	last = 1;
	first = TRUE;
	while ( !iszero ( rest+1, len-1 ) ) {
		while ( rest[last] == 0 ) last++;
		if ( !first )
		    printf ( "*" );
		else
		    first = FALSE;
		if ( gname != NULL )
		    printf ( "%s.%1d", gname, last );
		else
		    printf ( "g%1d", last );
		zero_vector ( help, len );
		help[0] = help[last] = 1;
		expo = prime - rest[last];
		rest = GROUP_MUL ( GROUP_EXP ( help, expo, mod_id ), rest, mod_id );
		expo = prime - expo;
		if ( expo > 1 )
			printf ( "^%1d", expo );
	}
	printf ( "\n" );
	POP_STACK();
}

int psi ( int n, int m, int k )
{
	int pow = 1;
	int len, i, mod_id, start, end, dim;
	int ker_dim = 0;
	VEC index, help, res;
	
	for ( i = 1; i <= k; i++ ) pow *= prime;
	mod_id = n*pow + m;
	if ( mod_id > cut ) mod_id = cut;
	len = FILTRATION[mod_id].i_start;
	start = FILTRATION[n].i_start;
	end = FILTRATION[n+m].i_start;
	dim = end - start;
	
	PUSH_STACK();
	index = CALLOCATE ( dim );

	help = CALLOCATE ( len );
	
	do { 
		copy_vector ( index, help+start, dim );
		res = GROUP_EXP ( help, pow, mod_id );
		if ( iszero ( res, len ) )
			ker_dim++;	
	} while ( inc_count ( index, dim ) );
	
	POP_STACK();
	
	return ( ker_dim );
}

void fspecial ( int no )
{
	int n, p, m, k;
	
	switch ( no ) {
		case 1:
			get_pc_pres();
			break;
		case 2:
			print_lis();
			break;
		case 4:
			do_colltest();
			break;
		case 5:
			printf ( "n = " );
			scanf ( "%d", &n );
			printf ( "p = " );
			scanf ( "%d", &p );
			swap_arith ( p );
			init_gl2 ( n );
			break;
		case 6:
			show_elab_inf();
			break;
		case 7:
			printf ( "n = " );
			scanf ( "%d", &n );
			check_conjugacy_classes  ( n );
			break;
		case 8:
			printf ( "n = " );
			scanf ( "%d", &n );
			printf ( "m = " );
			scanf ( "%d", &m );
			printf ( "k = " );
			scanf ( "%d", &k );
			psi ( n, m, k );
			break;
		case 9:
			gr_factor_set();
			break;
		default:
			printf ( "unknown special function\n" );
			break;
	}
}
	
