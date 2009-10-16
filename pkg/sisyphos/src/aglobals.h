/********************************************************************/
/*                                                                  */
/*  Module        : Global definitions                              */
/*                                                                  */
/*  Description :                                                   */
/*     Global definitions for SISYPHOS project.                     */
/*                                                                  */
/********************************************************************/

/* 	$Id: aglobals.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: aglobals.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 09:34:22  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:24:48  pluto
 * Initial version under RCS control.
 *	 */

#include <stdio.h>
#include <string.h>

#ifndef TRUE
#define FALSE		0
#define TRUE		!FALSE
#endif
#define MAXGEN 	20
#define MAXGRAD	100
#define MAXREL 	250			/* should be at least MAXGEN+MAXGEN*(MAXGEN-1)/2 */
#define MAXCARD	1048576L		/* prime^MAXGEN */
#define RELX		50
#define RELY		100
#define H1MAX		250
#define AMOUNT 	8000000L
#define NIL		0
#define MAXAUT 	1048576
#define MAXLIE		100

#ifdef ANSI
#define _( params ) params
#else
#define _( params ) ()
#endif

#define ARRAY(n,t)		(*gallocate)( (n) * sizeof ( t ) )

#define copy_vector( src, dst, dim) memcpy((void *)(dst),(void *)(src),(dim))
#ifndef LASER
#define zero_vector(vector, dim) memset((void *)(vector),0,(dim))
#else
#define zero_vector(vector, dim) bzero((vector),(dim))
#endif
#define ALIGN4( amount ) (amount)+4-((amount) & 3)

typedef char *VEC;
typedef char PCGEN;
typedef PCGEN *PCELEM;

#define NAME_MAX 32
#define MAXSYM 127
#define MAXTYPES 19
#define MAXOPERANDS 7

typedef enum {STANDARD_BASIS,IMAGES,PERMUTATIONS,BINARYP,CYCLES,NONE} OPTION;
typedef enum {GAP,SISYPHOS,CAYLEY} DSTYLE;
typedef enum {NOTYPE,INT,GROUP,PCGROUP,AGGROUP,GROUPRING,GRELEMENT,
		    VECTORSPACE,DLIST,HOMREC,GRHOMREC,SGRHOMREC,GROUPEL,
		    MULTIP,OPTIONAL,NSTRING,SHOMREC,GMODREC,COHOMOLREC} TYPE;

typedef struct symtabentry {
	char name[NAME_MAX+1];
	TYPE type;
	int value1;
	int value2;
	void *object;
	void *etype;
	int level;
} symbol;

typedef struct {
    void *pval;
    TYPE exptype;
} GENVAL;

typedef struct {
	int g;
	int e;
} ge_pair;

typedef union {
	int gen;
	ge_pair *pair_vec;
} vtype;

typedef struct {
	vtype type;
	int len;
	int exp;
} cstack_item;

typedef struct {
	 int i_start;
	 int i_end;
	 int i_dim;
} FILT;

typedef struct {
	int is_power;
	int el1;
	int el2;
} GENDEF;

typedef struct grpdsc {
	int prime;
	int num_gen;
	int num_rel;
	int is_minimal;
     char group_name[50];
	char **gen;
	int with_rel;
	int with_n_rho;
	int relx;
	int rely;
	int o_max_id;
	struct r_node **rel_list;
	struct pcgrpdesc *pc_pres;
	struct homom *isog;
} GRPDSC;

typedef struct pcgrpdesc {
     int prime;
     int num_gen;
     int group_card;
     int max_id;
     int min_gen;
	int defs;
     char group_name[50];
     int *g_max;
     int *g_ideal;
     int *image;
     int *pimage;
     char **gen;
     PCELEM *nom;
	int *c_len;
	int *p_len;
	ge_pair **c_list;
	ge_pair **p_list;
	struct r_node **def_list;
	int *pc_weight;
	FILT *exp_p_lcs;
	int exp_p_class;
	struct homom *autg;
} PCGRPDESC;

typedef struct aggrpdesc {
     int num_gen;
     int group_card;
     int min_gen;
     char group_name[50];
     int *powers;
     char **gen;
     PCELEM *nom;
	int *c_len;
	int *p_len;
	ge_pair **c_list;
	ge_pair **p_list;
	ge_pair **conjugates;
	GENDEF *def_list;
	int *avec;
	FILT *elab_series;
	int elab_length;
	struct homom *autg;
} AGGRPDESC;

typedef struct homom {
	struct grpdsc *h;
	struct pcgrpdesc *g;
	int auts;
	int class1_generators;
	int inn_log;
	int out_log;
	int only_normal_auts;
	int with_inner;
	int *aut_gens_dim;
	int *out_gens_dim;
	VEC **aut_gens;
	VEC epimorphism;
	int elements;
	int **stabs;
} HOM;

typedef struct {
	int nr;
	int pot;
} RELDESC;

typedef enum {MULT,EXP,COMM,GGEN,EQ} ops;

typedef struct r_node {
	ops nodetype;
	int value;
	struct r_node *left;
	struct r_node *right;
} rel_node;

typedef rel_node *node; 

typedef struct {
	int **mul_table;
	VEC **jenn_table;
	FILT *filtration;
	PCELEM *c_monom;
	VEC *n_monom;
	VEC *ngen_vec;
	int *el_num;
	PCGRPDESC *g;
} GRPRING;

typedef struct {
	int old_end;
	int old_dim;
	int old_start;
} IHEADER;

enum basis_flags {UNDEF,LOWER,UPPER};

typedef struct {
	int total_dim;
	int dimension;
	enum basis_flags b_flag;
	VEC basis;
} SPACE;

/* data types for multi-type dynamic lists */

typedef union {
	int intv;
	node nodev;
	void *gv;
} listv;

typedef struct dynlist {
    listv value;
    TYPE type;
    struct dynlist *next;
} dynlistitem;

typedef dynlistitem *DYNLIST;

typedef struct {
	DYNLIST first;
	DYNLIST last;
} LISTP;

#define ADD (*add)
#define MUL (*mul)
#define ADD_VECTOR (*add_vector)
#define SUBA_VECTOR (*suba_vector)
#define SUBB_VECTOR (*subb_vector)
#define SMUL_VECTOR (*smul_vector)
#define ADD_MULT (*add_mult)
#define MATRIX_MUL (*matrix_mul)
#define GROUP_MUL (*group_mul)
#define GROUP_EXP (*group_exp)
#define C_GROUP_MUL (*cgroup_mul)

/*
#define ADD_VECTOR(vec1, vec2, dim) { register int d = (dim); \
                                      while ( d  ) { \
							   	  d--; \
							       (vec1)[d] ^= (vec2)[d]; \
							   } }
*/

/* function prototypes */

long test_mod2 			_(( int sublift ));
VEC obstruct				_(( node p, VEC args[] ));
int check_next_obs			_(( VEC args[] ));
int inc_count				_(( VEC coeff, int last ));
int nr					_(( VEC vector ));
PCELEM monom_mul			_(( PCELEM i, PCELEM j ));
/* PCGEN get_el 				_(( register PCELEM el, register int n ));
void set_el 				_(( register PCELEM el, register int n, register PCGEN v )); */
PCELEM g_invers 			_(( register PCELEM el ));
int g_order 				_(( register PCELEM el ));
PCELEM g_expo 				_(( register PCELEM el, register int power ));
VEC c_group_mul			_(( VEC vec1, VEC vec2 ));
VEC tc_group_mul			_(( VEC vec1, VEC vec2 ));
VEC cgroup_exp 			_(( VEC vector, int power ));
VEC n_group_mul			_(( VEC vec1, VEC vec2, int cut ));
VEC t_group_mul			_(( VEC vec1, VEC vec2, int cut ));
VEC ngroup_exp				_(( VEC vector, int power, int cut ));
VEC tgroup_exp				_(( VEC vector, int power, int cut ));
char *add_path 			_(( char *env_var, char *filename ));
VEC re_order				_(( VEC vector ));
VEC do_conv				_(( int num ));
int get_gen_num			_(( char c, PCGRPDESC *g_desc ));
int get_com 				_(( char **pointer, int *cno, PCGRPDESC *g_desc ));
int get_word 				_(( char **pointer, PCELEM el, PCGRPDESC *g_desc  ));
void translation			_(( void ));
int do_aut				_(( char file_n[], int inner ));
void read_in				_(( PCGRPDESC *g_desk ));
void write_desc			_(( void ));
void read_desc 			_(( void ));


/* storage */

void *get_memblock			_(( long amount ));
void *tget_memblock 		_(( long amount ));
void *allocate 			_(( long nbytes ));
void *tallocate			_(( long nbytes ));
void *callocate			_(( long nbytes ));
void *tcallocate			_(( long nbytes ));
void *get_top				_(( void ));
void *tget_top 			_(( void ));
void set_top				_(( void *newtop ));
void tset_top				_(( void *newtop ));
void push_stack			_(( void ));
void pop_stack 			_(( void ));
void clear_t				_(( void ));
void free_memblock			_(( void *pointer ));
void tfree_memblock 		_(( void *pointer ));
void show_info 			_(( long *mem_bottom, long *mem_top,
				  			long *mem_maxtop, long *mem_free ));

/* arithmetik */

void swap_arith			_(( int p ));
char f2_add				_(( char v1, char v2 ));
char f2_mul				_(( char v1, char v2 ));
char f3_add				_(( char v1, char v2 ));
char f3_mul				_(( char v1, char v2 ));
char fp_add				_(( char v1, char v2 ));
char fp_mul				_(( char v1, char v2 ));
char fp_inv				_(( register char v1 ));
void add2_vector			_(( VEC vector1, VEC vector2, register int dim ));
void suba2_vector			_(( VEC vector1, VEC vector2, register int dim ));
void subb2_vector			_(( VEC vector1, VEC vector2, register int dim ));
void smul2_vector			_(( char value, VEC vector, register int dim ));
void add2_mult 			_(( char value, VEC vector1, VEC vector2, register int dim ));
void add3_vector			_(( VEC vector1, VEC vector2, register int dim ));
void suba3_vector			_(( VEC vector1, VEC vector2, register int dim ));
void subb3_vector			_(( VEC vector1, VEC vector2, register int dim ));
void smul3_vector			_(( char value, VEC vector, register int dim ));
void add3_mult 			_(( char value, VEC vector1, VEC vector2, register int dim ));
void addp_vector			_(( VEC vector1, VEC vector2, register int dim ));
void subap_vector			_(( VEC vector1, VEC vector2, register int dim ));
void subbp_vector			_(( VEC vector1, VEC vector2, register int dim ));
void smulp_vector			_(( char value, VEC vector, register int dim ));
void sub_mult				_(( char value, VEC vector1, VEC vector2, register int dim ));
void addp_mult 			_(( char value, VEC vector1, VEC vector2, register int dim ));
/* void copy_vector			_(( VEC src, VEC dst, register int dim )); */
/* void zero_vector			_(( VEC vector, register int dim )); */
void write_vector			_(( VEC vector, int dim ));
int read_vector			_(( VEC vector ));

VEC matrix2_mul			_(( VEC mat1, VEC mat2 ));
VEC matrixp_mul			_(( VEC mat1, VEC mat2 ));
VEC matrix_exp 			_(( VEC mat, int power ));

/* group setting */

void ana_rel				_(( char **pointer, GRPDSC *g_desc ));
void group_set 			_(( void ));

/* H1 matrix */

void calc_matrix			_(( VEC rho, VEC l_mat, VEC r_mat ));
VEC do_exp_rel 			_(( int gen_nr, int power ));
void get_rho_mat			_(( VEC rho, VEC *r_mat, int left ));
void get_op_mat			_(( RELDESC l_rel[], RELDESC r_rel[] ));
void transform 			_(( void ));
void z1_mat				_(( VEC rho[], char **M, VEC Abs ));
void b1_mat				_(( void ));

void write_rho 			_(( int n, char file_n[], long count ));
void read_gr_file			_(( char file_n[] ));
void write_gr_file			_(( char file_n[] ));
void show_rel				_(( GRPDSC *g_desc ));
void show_list 			_(( void ));
void show_grpring 			_(( GRPRING *gr ));
void show_pcgrpdesc 		_(( PCGRPDESC *g ));
void set_main_group 		_(( PCGRPDESC *g_desc ));
void set_domain			_(( GRPRING *gr_desc, int modulo ));
void show_grpdsc 			_(( GRPDSC *h_group ));
void set_h_group 			_(( GRPDSC *h_group ));
int **multiplication_table 	_(( void ));
VEC **jennings_table 		_(( int cut ));
void cut_file				_(( void ));
void alter_nrho			_(( void ));
void help 				_(( void ));

void centralizer			_(( VEC args[], int mod_id, int argn ));
SPACE *e_centralizer 		_(( VEC args[], int n_args, int mod_id ));
int handle_conj			_(( VEC args[] ));
void show_settings			_(( void ));
VEC c_n_trans				_(( VEC c_vec, int mod_id ));
VEC n_c_trans				_(( VEC n_vec, int mod_id ));
int get_rho				_(( VEC rho[], VEC h1[], int end, IHEADER *inf_header, FILE *in_f ));
FILE *get_header			_(( char *f_name, IHEADER *inf_header ));
void put_rho				_(( VEC rho[], VEC h1[], int h1dim, IHEADER *inf_header, FILE *out_f ));
FILE *put_header			_(( char *f_name, IHEADER *inf_header ));
void show_grad 			_(( void ));
void conv_sun_atari 		_(( void ));
void conv_atari_sun 		_(( void ));
void extract_rho			_(( void ));
void set_files 			_(( int from, int to ));
int get_old_rho			_(( void ));
int iszero				_(( VEC vector, int len ));

/* lifting */

void mod_with_h1			_(( VEC index, int len ));
long fetch_nrho			_(( int mod_id ));
void do_control			_(( int sublift ));
void lift_control			_(( GRPDSC *h, int first, int last, int lookahead, int sublift, int smallgrpring ));
void lift2_control			_(( int first, int last ));
void lift_one_step			_(( void ));
void cut_first_id			_(( int ideal ));
void verify				_(( GRPDSC *h, int ideal ));
void show_mat				_(( VEC mat ));
void do_rel				_(( int relat, VEC args[], int cut ));
void f_save_rho			_(( int h1_dim, VEC rho_lif[] ));
int try_to_lift			_(( VEC args[] ));

void c_monom_write			_(( PCELEM elem ));
void fc_monom_write 		_(( PCELEM elem, FILE *handle ));
void cgroup_write			_(( VEC vector ));
void n_monom_write			_(( int nr ));
void n_group_write			_(( VEC vector, int cut ));
void monom_write			_(( int nr, FILE *handle ));
void group_write			_(( VEC vector, int cut, FILE *handle ));
void group_ring_def_from_file	_(( int grflag, char *dsc_file_name ));
PCGRPDESC *grp_to_pcgrp  	_(( GRPDSC *g_desc ));
GRPDSC *conv_rel			_(( PCGRPDESC *g_desc ));

/* vector space */

void show_space			_(( SPACE *v_space ));
SPACE *meet_space			_(( SPACE *v1, SPACE *v2 ));
SPACE *join_space			_(( SPACE *v1, SPACE *v2 ));
SPACE *compl_space			_(( SPACE *v_space ));
SPACE *left_ideal			_(( SPACE *v_space ));
void s_compress 			_(( void ));
SPACE *ideal_closure 		_(( SPACE *v_space, int side_flag ));
SPACE *annihilator 			_(( int side, SPACE *v_space ));
SPACE *pot_space 			_(( SPACE *v1, int power ));
SPACE *principal_ideal 		_(( VEC v, int cut, int side_flag ));

/* lie algebra */

int get_I_power			_(( int dimension ));
SPACE *s_lie_prod			_(( SPACE *v1, SPACE *v2 ));
SPACE *conv_I_space 		_(( int I_power, int modI_power ));
void get_lie_series			_(( void ));
void get_lie_ideal			_(( void ));

/* debug */

void tdebug				_(( void ));
void dmatrix				_(( VEC vec, int d ));

/* special */

char *stpblk				_(( char *p ));

int get_order				_(( VEC vec, int cut ));
void regular_rep			_(( VEC vector, int cut ));
void special				_(( void ));
int get_classes 			_(( void ));
void sort_classes 			_(( void ));
void show_classes 			_(( void ));


/* end of header globals new */
