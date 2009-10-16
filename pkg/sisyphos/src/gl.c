/********************************************************************/
/*  Module        : General linear                                  */
/*                                                                  */
/*  Description :                                                   */
/*     Each subsequent call to get_gl_element returnes a new        */
/*     element of GL(dim,F) in the array 'vector'. As long as there */
/*     are new elements, 'TRUE' is returned, otherwise 'FALSE'.     */
/*                                                                  */
/********************************************************************/

/* 	$Id: gl.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: gl.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:41:18  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Added function 'do_dimino'.
 *
 * Revision 1.6  1995/01/05  17:08:13  pluto
 * Changed header to new style.
 *
 * Revision 1.5  1995/01/03  14:45:22  pluto
 * Second correction to liftings_mod2.
 *
 * Revision 1.4  1995/01/03  14:37:39  pluto
 * Corrected liftings_mod2.
 *	 */

#ifndef lint
static char vcid[] = "$Id: gl.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include	"aglobals.h"
#include	"fdecla.h"
#include	"pc.h"
#include	"storage.h"
#include	"solve.h"

extern int dim, dquad, prime;
extern PCGRPDESC *group_desc;
extern int test_new_version;
VEC mat;

VEC *rlist;
int blocks;
VEC *mautgens;
int n_mautgens;

/* algorithm flags */
int use_fail_list = TRUE;

#define Zmat()		CALLOCATE ( dquad )
#define MAXGL		30000

VEC Idmat 				_(( void ));
int isIdmat				_(( VEC m ));
void find_least 			_(( void ));
int is_in_elements 			_(( VEC m, VEC l[], int max_l ));
void gen_gl				_(( void ));
void add_to_index_table 		_(( VEC mat, int ind ));
int is_in_list 			_(( VEC m, VEC l[] ));
unsigned int hash_index 		_(( VEC mat ));
int get_list_index 			_(( VEC m, VEC l[] ));
int get1_gl_element 		_(( void ));
int get2_gl_element 		_(( void ));
void add1_to_list 			_(( void ));
void add1_to_fail_list 		_(( int mark ));
void add2_to_list 			_(( void ));
void add2_to_fail_list 		_(( int mark ));

int (*get_gl_element)		_(( void ));
void (*add_to_list)			_(( void ));
void (*add_to_fail_list)		_(( int mark ));

typedef struct {
	int li;
	int re;
	int liftable;
} GLDESC;

typedef struct index_entry {
	int index;
	struct index_entry *next;
} IENTRY;

typedef IENTRY *PI;

int initialized = FALSE;

static GLDESC *gl_info;
static int level;
static VEC *vec_list;
static VEC *ind_vec;
static VEC *indp_vec;
static VEC id;
static VEC *sgl;			/* generators of Gl */
static VEC s[100];			/* generators of liftable subgroup of Gl */
static VEC *e;				/* elements of Gl */
static VEC le[MAXGL];		/* elements of liftable subgroup of Gl */
static PI  ht[1024];		/* hash table for indices */
static int hbytes = 1;		/* number of bytes use in hash function */
/*
static VEC f[300000];
static int f_index = 0;
*/
static VEC cm[30000];		/* maximal order of cyclic subgroup of Gl */
static int t = 0; 			/* number of generators of liftable subgroup of Gl */
static int order = 0;		/* order of subgroup of liftable elements of Gl */
static long order_of_gl = 0;	/* order of Gl */
static int current_el = 0;	/* index of element of gl that is currently checked */
static int num_gl_generators = 2; /* number of generators of Gl */
static int fdim;			/* rank of GL */
static int use_gl_info = TRUE;
static VEC *vector;

int gcd ( int a, int b )
{
	int x;
	
	while ( (x = a % b) != 0 ) {
		a = b;
		b = x;
	}
	return b;
}

long gl_order ( int dim )
{
	long o = 1;
	int p = 1;
	int i;
	
	for ( i = 1; i <= dim; i++ ) {
		o *= p;
		p *= prime;
		o *= (p-1);
	}
	return ( o );
}

int primitive_element ( int p )
{
	register int i, j, k;
	
	if ( p == 2 )
		return ( 1 );
	
	for ( i = 2; i < p-1; i++ ) {
		j = i;
		k = 1;
		while ( j != 1 ) {
			j *= i;
			j %= p;
			k++;
		}
		if ( k == p-1 )
			break;
	}
	return ( i );
}

VEC *gl_generators ( int n, int p )
{
	VEC *g;
	int i, mp;

	if ( n == 1 ) {
		num_gl_generators = 1;
		g = ARRAY ( 1, VEC );
		g[0] = CALLOCATE ( 1 );
		if ( p == 2 )
			g[0][0] = 1;
		else
			g[0][0] = primitive_element ( p );
	}
	else {
		num_gl_generators = 2;
		g = ARRAY ( 2, VEC );
		g[0] = CALLOCATE ( n*n );
		g[1] = CALLOCATE ( n*n );
	
		mp = p-1;
		for ( i = 1; i < n; i++ ) {
			g[1][i*n+i] = 1;
			g[0][i*n+i-1] = mp;
		}
		g[0][n-1] = 1;
	
		if ( p == 2 )
			g[1][0] = g[1][1] = 1;
		else {
			g[1][0] = primitive_element ( p );
			g[0][0] = mp;
		}
	}
	
	return ( g );
}

void init_gl1 ( int dim )
{
	int i;
	
	if ( !initialized ) {
		hbytes = dquad / sizeof ( int );
		for ( i = 0; i < 1024; i++ )
			ht[i] = NULL;
		mat = ALLOCATE ( dquad );

		/* reserve space for element list */
		e = ARRAY ( order_of_gl, VEC );
		gl_info = ARRAY ( order_of_gl, GLDESC );
	
		sgl = gl_generators ( dim, prime );
		gen_gl();
		initialized = TRUE;
	}

	order = current_el = t = 0;
	for ( i = 0; i < order_of_gl; i++ )
		gl_info[i].liftable = -1;
}

void init_gl2 ( int dim )
{
	int list_len, i;
	
/*	if ( !initialized ) { */
		t = 0;
		order = 0;
/*		printf ( "order ( gl ) : %d\n", order_of_gl ); */
		mat = ALLOCATE ( dquad );
		list_len = (dim*(dim+1))>>1;
		vec_list = (VEC *)CALLOCATE ( sizeof ( VEC ) * list_len );
		vector = (VEC *)CALLOCATE ( sizeof ( VEC ) * dim );
		ind_vec = (VEC *)CALLOCATE ( sizeof ( VEC ) * dim );
		indp_vec = (VEC *)CALLOCATE ( sizeof ( VEC ) * dim );
		
		/* initialize identity matrix and initial part of vec_list */
		id = (VEC)CALLOCATE ( dim*dim );
		for ( i=dim; i--; ) {
			vector[i] = ALLOCATE ( dim );
			id[i*dim+i] = 1;
			vec_list[i] = ALLOCATE ( dim );
			copy_vector ( id+i*dim, vec_list[i], dim );
		}
		
		for ( i = dim; i < list_len; i++ )
			vec_list[i] = ALLOCATE ( dim );
			
		/* initialize ind_vec */
		for ( i=dim; i--; ) {
			ind_vec[i] = CALLOCATE ( dim-i );
			indp_vec[i] = CALLOCATE ( i+1 );
			indp_vec[i][i] = -1;
		}			
		level = 0;
/*		initialized = TRUE;
	}	*/

}

void init_gl ( int dim )
{
	fdim = dim;
	order_of_gl = gl_order ( dim );
	if ( order_of_gl <= MAXGL ) {
/*		fprintf ( stderr, "#D SISYPHOS: precompute GL\n" ); */
		init_gl1 ( dim );
		get_gl_element = get1_gl_element;
		add_to_list = add1_to_list;
		add_to_fail_list = add1_to_fail_list;
		use_gl_info = TRUE;
	}
	else {
/*		fprintf ( stderr, "#D SISYPHOS: no precomputation of GL\n" ); */
		init_gl2 ( dim );
		get_gl_element = get2_gl_element;
		add_to_list = add2_to_list;
		add_to_fail_list = add2_to_fail_list;
		use_gl_info = FALSE;
	}
}

void show_gl_elts (void)
{
	int i;
	
	printf ( "order of group      : %d\n", order );
	
	printf ( "\nelementss:\n" );
	for ( i = 0; i < order; i++ ) {
		show_mat ( e[i] );
		printf ( "li: %d, re: %d, liftable: %d\n", gl_info[i].li, gl_info[i].re, gl_info[i].liftable );
	}
}


void gen_gl (void)
{
	int i,j,t;
	int prev_order, rep_pos;
	int order = 0;
	VEC g;
	int li, re;
	int p1 = 0;
	int p2 = 0;
	
	for ( t = 0; t < num_gl_generators; t++ ) {

		if ( t == 0 ) {
	
			/* generating set is empty */
			order = 1;
			e[0] = Idmat();
			add_to_index_table ( e[0], 0 );
			gl_info[0].li = gl_info[0].re = 0;
			g = sgl[t];
			p1 = 1;
			li = 0;
			while ( !isIdmat ( g ) ) {
				if ( g == sgl[t] ) {
					e[order] = Zmat();
					copy_vector ( g, e[order], dquad );
					add_to_index_table ( e[order], order );
					gl_info[order].li = li++;
					gl_info[order].re = p1;
				}
				else {
					e[order] = g;
					add_to_index_table ( e[order], order );
					gl_info[order].li = li++;
					gl_info[order].re = p1;
				}
				order++;
				g = MATRIX_MUL ( g, sgl[t] );
			}
			p2 = order;
		}
		else {
			/* generating set contains already t elements */
	
				prev_order = order;
				
				/* add coset of sgl[t] */
				e[order] = Zmat();
				copy_vector ( sgl[t], e[order], dquad );
				add_to_index_table ( e[order], order );
				gl_info[order].li = 0;
				gl_info[order].re = p2;
			
				order++;
				for ( j = 1; j < prev_order; j++ ) {
					e[order] = MATRIX_MUL ( e[j], sgl[t] );
					add_to_index_table ( e[order], order );
					gl_info[order].li = j;
					gl_info[order++].re = p2;
				}
				rep_pos = li = prev_order;
				do {
					for ( i = 0; i < num_gl_generators; i++ ) {
						g = MATRIX_MUL ( e[rep_pos], sgl[i] );
						if ( !is_in_list ( g, e ) ) {
							
							/* add coset */
							gl_info[order].li = li;
							gl_info[order].re = i == 0 ? p1 : p2;
							re = order;
							e[order] = g;
							add_to_index_table ( e[order], order );
							order++;
							for ( j = 1; j < prev_order; j++ ) {
								e[order] = MATRIX_MUL ( e[j], g );
								add_to_index_table ( e[order], order );
								gl_info[order].li = j;
								gl_info[order++].re = re;
							}
						}
					}
				
					/* position of next representative */
					rep_pos += prev_order;
				} while ( rep_pos < order );
/*				printf ( "order: %d\n", order );  */
		}
	}
}

int get_next_gl_element ( int dim )
{
	int i, offset, pdim, cdim;
	int do_inc;
	char val;
	
	offset = (level*((dim<<1)-level+1))>>1;
	zero_vector ( vector[level], dim );
	do_inc = TRUE;
	if ( level > 0 ) {
		pdim = level;
		if ( inc_count ( indp_vec[level-1], pdim ) ) {
			
			/* add current space to basis element of complement */
			for ( i = pdim; i--; )
				if ( (val = indp_vec[level-1][i]) != 0 )
					ADD_MULT ( val, vector[i], vector[level], dim );
			do_inc = iszero ( ind_vec[level], dim - level );
		}
		else {
			
			/* already done for complete space */
			zero_vector ( indp_vec[level-1], pdim );
			do_inc = TRUE;
		}
	}
	
	if ( do_inc ) {
		if ( !inc_count ( ind_vec[level], dim - level ) ) {
			if ( level == 0 )
				
				/* we are done */
				return ( FALSE );
			else {
			
				/* go up one level */
				level--;
				return ( get_next_gl_element ( dim ) );
			}
		
		}
	}
		
	/* construct vector */
	for ( i = dim - level; i--; )
		if ( (val = ind_vec[level][i]) != 0 )
			ADD_MULT ( val, vec_list[offset+i], vector[level], dim );
			
	if ( level == dim-1 )
		return ( TRUE );
	else {
		
		/* compute complement of constructed subspace */
		for ( i = 0; i <= level; i++ )
			copy_vector ( vector[i], matrix[i], dim );

		for ( i = 0; i < dim; i++ )
			copy_vector ( id+i*dim, matrix[i+level+1], dim );
			
		PUSH_STACK();
		cdim = complement ( level+1, dim, dim+level+1 );
		for ( i = cdim; i--; )
			copy_vector ( fsolution[i], vec_list[offset+dim-level+i], dim );
		POP_STACK();
		zero_vector ( ind_vec[level+1], dim - level - 1 );
		zero_vector ( indp_vec[level], level+1 );
		indp_vec[level][level] = -1;
					
		/* go down one level */
		level++;
		return ( get_next_gl_element ( dim ) );
	}
}

VEC Idmat (void)
{
	VEC r = CALLOCATE ( dquad );
	int i;
	
	for ( i = 0; i < dim; i++ )
		r[i*dim+i] = 1;
		
	return ( r );
}

int isIdmat ( VEC m )
{
	VEC help;
	int isid;

	PUSH_STACK();
	help = Idmat();
	isid = memcmp ( help, m, dquad );
	POP_STACK();
	return ( !isid );
}

int is_in_elements ( VEC m, VEC l[], int max_l )
{
	int isin = FALSE;
	int i;
	
	PUSH_STACK();
	for ( i = 0; i < max_l; i++ ) {
		isin = !memcmp ( l[i], m, dquad );
		if ( isin )
			break;
	}
	POP_STACK();
	return ( isin );
}


int dimino ( VEC m )
{
	int i, j;
	int prev_order, rep_pos;
	VEC g, h;
	
	if ( t == 0 ) {

		/* generating set is empty */
		order = 1;
		le[0] = Idmat();
		s[0] = Zmat();
		copy_vector ( m, s[0], dquad );
		t = 1;
		g = m;
		while ( !isIdmat ( g ) ) {
			if ( g == m ) {
				le[order] = Zmat();
				copy_vector ( g, le[order], dquad );
			}
			else {
				le[order] = g;
				if ( use_gl_info )
					gl_info[get_list_index (g, e)].liftable = TRUE;		
			}
			order++;
			g = MATRIX_MUL ( g, m );
		}
		return ( TRUE );
	}
	else {
		/* generating set contains already t elements */

		if ( !is_in_elements ( m, le, order ) ) {
			/* not redundant */
			
			prev_order = order;
			
			/* take m as a new generator */
			s[t] = Zmat();
			copy_vector ( m, s[t], dquad );
			t++;
			
			/* add coset of m */
			le[order] = Zmat();
			copy_vector ( m, le[order], dquad );
			order++;
			for ( j = 1; j < prev_order; j++ ) {
				g = MATRIX_MUL ( le[j], m );
				le[order++] = g;
				if ( use_gl_info )
					gl_info[get_list_index(g, e)].liftable = TRUE;
			}
			rep_pos = prev_order;
			do {
				for ( i = 0; i < t; i++ ) {
					g = MATRIX_MUL ( le[rep_pos], s[i] );
					if ( !is_in_elements ( g, le, order ) ) {
						/* add coset */
						
						le[order++] = g;
						for ( j = 1; j < prev_order; j++ ) {
							h = MATRIX_MUL ( le[j], g );
							le[order++] = h;
							if ( use_gl_info )
								gl_info[get_list_index (h, e)].liftable = TRUE;
						}
					}
				}
			
				/* position of next representative */
				rep_pos += prev_order;
			} while ( rep_pos < order );
			return ( TRUE );
		}
		else
			return ( FALSE );
	}
}

int do_dimino ( VEC m[], int l_m, int d )
/* Generate the subgroup of GL(d,p) generated by the <d>x<d> matrices
   <m>. <l_m> is the length of the list <m>. The order of the subgroup
   is returned.
   */ 
{
    int i;

    dim = d;
    dquad = d * d;
    order = t = 0;

    for ( i = 0; i < l_m; i++ )
	   dimino ( m[i] );
    return ( order );
}

void show_gen_set (void)
{
	int i;
	
	printf ( "number of generators: %d\n", t );
	printf ( "order of group      : %d\n", order );
	
	printf ( "\ngenerators:\n" );
	for ( i = 0; i < t; i++ ) {
		show_mat ( s[i] );
		printf ( "\n" );
	}
}

int gl_subgroup_order (void)
{
	return ( order );
}

int gl_subg_generators (void)
{
	return ( t );
}

/* static long cnt = 0L; */

int get2_gl_element (void)
{
	int i, j;
	int isinlist = FALSE;
	
	if ( order == order_of_gl )
		return ( FALSE );
	do {
		if ( get_next_gl_element ( fdim ) ) {
			for ( i = 0; i < fdim; i++ ) {
				for ( j = 0; j < fdim; j++ ) {
					mat[i*fdim+j]  = vector[i][fdim-1-j];
				}
			}
			isinlist = is_in_elements ( mat, le, order );
			/* if ( !isinlist && use_fail_list ) {
				find_least();
				isinlist = is_in_elements ( mat, f, f_index );
			} */
		}
		else
			return ( FALSE );
	} while ( isinlist );
/*	if ( cnt++ % 1000 == 0 )
		fprintf ( stderr, "#D SISYPHOS: checking element no. %ld\n", cnt ); */
	return ( TRUE );
}


int get1_gl_element (void)
{
	int value;
	int have_one;
	
	have_one = FALSE;
	while ( current_el < order_of_gl && !have_one ) {
		value = gl_info[ gl_info[current_el].li].liftable + gl_info[gl_info[current_el].re].liftable;
		if ( gl_info[current_el].liftable != -1 )
			current_el++;
		else if (  value == 1 )
			gl_info[current_el++].liftable = FALSE;
		else if ( value == 2 )
			gl_info[current_el++].liftable = TRUE;
		else if ( is_in_elements ( e[current_el], le, order ) )
			gl_info[current_el++].liftable = TRUE;
		else
			have_one =TRUE;
	}
	
	if ( !have_one )
		return ( FALSE );
		
	copy_vector ( e[current_el], mat, dquad );
	return ( TRUE );
}

void mark_nl (void)
{
	VEC h;
	int i, m_order;
	PI p;
	unsigned int hv = 0;
	int isin;
	
	PUSH_STACK();
	cm[0] = h = mat;
	i = 1;
	while ( !isIdmat ( h ) ) {
		h = MATRIX_MUL ( h, mat );
		cm[i++] = h;
	}
	m_order = i;
	
	for ( i = 1; i < m_order-1; i++ ) {
		if ( gcd ( i+1, m_order ) == 1 )
			hv = hash_index ( cm[i] );
			for ( p = ht[hv]; p != NULL; p = p->next ) {
				isin = !memcmp ( e[p->index], cm[i], dquad );
				if ( isin ) {
					gl_info[p->index].liftable = FALSE;
					break;
				}
			}
	}
	POP_STACK();
}

void add1_to_list (void)
{
	gl_info[current_el].liftable = TRUE;
	dimino ( mat );
}

void add1_to_fail_list ( int mark )
{
	gl_info[current_el].liftable = FALSE;
	if ( mark )
		mark_nl();
}

void add2_to_list (void)
{
	dimino ( mat );
}

void add2_to_fail_list ( int mark )
{
	mark = mark;
}

/*
void find_least ( void )
{
	VEC h;
	int i, minw, m_order;
	
	PUSH_STACK();
	cm[0] = h = mat;
	i = 1;
	while ( !isIdmat ( h ) ) {
		h = MATRIX_MUL ( h, mat );
		cm[i++] = h;
	}
	m_order = i;
	
	printf ( "m_order: %d\n", m_order );
	minw = 0;
	for ( i = 1; i < m_order-1; i++ ) {
		if ( gcd ( i+1, m_order ) == 1 )
			if ( memcmp ( cm[minw], cm[i], dquad ) > 0 )
				minw = i;
	}
	copy_vector ( cm[minw], mat, dquad );
	POP_STACK();
}
*/

/*
unsigned int hash_index ( VEC mat )
{
	register unsigned int ul;
	
	ul = hbytes == 1 ? mat[0] : *((unsigned int *)mat);
	return ( ul  & (1 << 10) - 1 );
}
*/

unsigned int hash_index ( VEC mat )
{
	register unsigned int ul = 0;
	register int i;
	register unsigned int *p;
	
	if ( dim == 1 )
		return ( mat[0] );
	for ( i = 0,p=(unsigned int *)mat; i < hbytes; i++,p++ )
		ul = (ul << 1) + *p;
	return ( ul  & ((1 << 10) - 1) );
}
	
void add_to_index_table ( VEC mat, int ind )
{
	unsigned int hv;
	PI entry;
	
	hv = hash_index ( mat );
	entry = ALLOCATE ( sizeof ( IENTRY ) );
	entry->index = ind;
	entry->next = ht[hv];
	ht[hv] = entry;
}

int is_in_list ( VEC m, VEC l[] )
{
	int isin = FALSE;
	PI p;
	unsigned int hv;

	hv = hash_index ( m );
	
	for ( p = ht[hv]; p != NULL; p = p->next ) {
		isin = !memcmp ( l[p->index], m, dquad );
		if ( isin )
			break;
	}
	return ( isin );
}

int get_list_index ( VEC m, VEC l[] )
{
	int isin = FALSE;
	PI p;
	unsigned int hv;

	hv = hash_index ( m );
	
	for ( p = ht[hv]; p != NULL; p = p->next ) {
		isin = !memcmp ( l[p->index], m, dquad );
		if ( isin )
			break;
	}
	return ( p->index );
}

void liftings_mod2 ( VEC autgens[], int n_autgens, int n, int p )
{
    VEC *glgens;
    int i, j, k, o, offset, subgrp_order;

    dim = n;
    dquad = dim * dim;
    glgens = gl_generators ( n, p );
    order = t = 0;
    
    n_mautgens = n_autgens;
    mautgens = ARRAY ( n_autgens, VEC );
    for ( i = 0; i < n_autgens; i++ ) {
	   mautgens[i] = ALLOCATE ( dquad );
	   for ( j = 0; j < n; j++ )
		  for ( k = 0; k < n; k++ )
			 mautgens[i][(n-1-k)*n+n-1-j] = autgens[i][j*GNUMGEN+k];
    }

    /* generate subgroup of GL, induced by automorphism group */
    for ( i = 0; i < n_autgens; i++ )
	   dimino ( mautgens[i] );
    
    if ( n_autgens == 0 )
	   /* automorphism group operates trivial on Frattini quotient */
	   subgrp_order = 1;
    else
	   subgrp_order = order;
    
    /* compute complete GL by adding generators */
    for ( i = 0; i < (n == 1 ? 1 : 2); i++ )
	   dimino ( glgens[i] );
    /* save representatives in list */
    blocks = order / subgrp_order;
    rlist = ARRAY ( blocks, VEC );
    n = test_new_version ? dim : dim+1;
    offset = test_new_version ? 0 : 1;
    for ( i = 0,o = 0; i < blocks; i++,o += subgrp_order ) {
	   rlist[i] = ALLOCATE ( n*dim );
	   for ( j = 0; j < dim; j++ ) {
		  if ( !test_new_version )
			 rlist[i][j*n] = 1;
		  for ( k = 0; k < dim; k++ )
			 rlist[i][k*n+j+offset] = le[o][j*dim+k];
	   }
    }
}
			  
/* end of module gl */


