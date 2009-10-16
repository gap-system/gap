
/*  A Bison parser, made from sisgram.y with Bison version GNU Bison version 1.22
  */

#define YYBISON 1  /* Identify Bison output.  */

#define	NUMBER	258
#define	NGEN	259
#define	CGEN	260
#define	GRGEN	261
#define	QUIT	262
#define	MOD	263
#define	IDEAL	264
#define	DEFGRP	265
#define	DEFPCGRP	266
#define	DEFAGGRP	267
#define	STRING	268
#define	IDENTIFIER	269
#define	NUM	270
#define	RELS	271
#define	SEQ	272
#define	MATRIX	273
#define	GEN	274
#define	ID	275
#define	READAUTGRP	276
#define	READGRP	277
#define	READPCGRP	278
#define	READAGGRP	279
#define	MINIMAL	280
#define	ACTUAL	281
#define	GENS	282
#define	WEIGHTS	283
#define	BATCH	284
#define	COMMUT	285
#define	UMINUS	286


#include "config.h"
#include <ctype.h>
#include "aglobals.h"
#include "fdecla.h"
#include "pc.h"
#include  "graut.h"
#include	"aggroup.h"
#include	"grpring.h"
#include	"hgroup.h"
#include	"symtab.h"
#include	"aut.h"
#include	"parsesup.h"
#include	"storage.h"
#include	"error.h"
#include	"solve.h"

#define TAMOUNT 100000L

#ifdef SUN3
#include <strings.h>
#else
#include <string.h>
#endif

#ifndef ANSI
extern void exit();
#else
#ifndef SUN3
#include <stdlib.h>
#endif
#endif

#ifdef HAVE_LIBGPVM3
#define DO_PVM(h,f,t,l,s,n)  do_pvm(h,f,t,l,s,n)
#else
#define DO_PVM(h,f,t,l,s,n)  /* empty */
#endif 

typedef unsigned long ULONG;
#ifndef __GNUC__
#define alloca malloc
#endif
#define IS_VALID( expr )		((expr) != 0)

void show_logo				_(( void ));
void set_paths				_(( void ));
static int find_gen 		_(( char *name ));
HOM *aut_read                 _(( char file_n[], PCGRPDESC *g_desc ));
int getopt				_(( int argc, char *const *argv, 
						    const char *optstring ));
VEC mult_comm				_(( VEC u1, VEC u2, int mod_id ));
void init_mem_stats			_(( void ));
void init_act_table			_(( void ));
void memory_usage			_(( void ));
int yyparse 				_(( void ));
int yyerror				_(( char *s ));
int yylex					_(( void ));
void do_pvm	 	    		_(( GRPDSC *h, int from, int to, int lahead, 
						    int smallgrpring, int npr ));
void initialize_readline      _(( void ));
int do_check_args             _(( FUNCDSC *func, LISTP *args, int chk_retval ));

extern int cut, fend, bperelem;
extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern int prime;
extern GRPDSC *h_desc;
extern char *optarg;
extern char root_path[256];
extern int pcgroup_num, group_num;
extern char prompt1[], prompt2[];
extern int use_prompt1;

/* algorithm flags */				/* default values */	
extern int aut_pres_all;				/* FALSE */
#define MAXFLAGS 					10
extern int use_filtration;			/* TRUE */
extern int use_max_elab_sections;		/* FALSE */
extern int only_normal_auts;			/* FALSE */
extern int use_fail_list;			/* TRUE */
extern int with_inner;				/* FALSE */
extern OPTION display_basis;			/* NONE */
extern OPTION aut_pres_style;			/* NONE */
extern int flags[];

char *mem_bottom;
char out_n[32];
char in_n[32];
char proto_n[32];
char *proto_p;
FILE *out_f, *in_f;
FILE *proto = NULL;
int verbose = FALSE;
int p_abort = FALSE;
int banner = TRUE;
int quiet = FALSE;
int use_pvm = FALSE;
DSTYLE displaystyle = SISYPHOS;
char *boolean_prefix;
char *boolean_postfix;
long amount;
long tamount;
FILE *out_hdl;
int mon_per_line;
int read_group_el = FALSE;
char pvm_in_n[80];
char pvm_out_n[80];
char pcgroup_lib[256];
char group_lib[256];
int pcgroup_num, group_num;

static DYNLIST p;
static symbol *yysym;
static GENVAL *yyhval;
static FUNCDSC *yyfunc;
static size_t node_size = sizeof ( rel_node );
static GRPDSC *g_desc;
static int i;
static int use_proto = FALSE;
int rt;


typedef union {
	int ival;
	GENVAL *gval;
	} YYSTYPE;

#ifndef YYLTYPE
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;

#define YYLTYPE yyltype
#endif

#include <stdio.h>

#ifndef __cplusplus
#ifndef __STDC__
#define const
#endif
#endif



#define	YYFINAL		222
#define	YYFLAG		-32768
#define	YYNTBASE	46

#define YYTRANSLATE(x) ((unsigned)(x) <= 286 ? yytranslate[x] : 78)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,    45,     2,     2,     2,    40,
    41,    33,    31,    43,    32,    38,    34,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,    39,     2,
    44,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
    37,     2,    42,    36,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
    16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    30,    35
};

#if YYDEBUG != 0
static const short yyprhs[] = {     0,
     0,     1,     5,     9,    10,    12,    14,    19,    24,    26,
    33,    35,    39,    43,    44,    46,    48,    52,    56,    57,
    59,    62,    67,    68,    71,    76,    78,    82,    85,    90,
    92,    96,    99,   102,   103,   106,   108,   110,   114,   118,
   123,   129,   131,   132,   134,   135,   140,   147,   148,   153,
   154,   159,   163,   168,   172,   176,   180,   184,   187,   191,
   197,   204,   210,   212,   214,   216,   218,   220,   222,   227,
   229,   233,   238,   239,   250,   251,   265,   272,   274,   275,
   286,   287,   301,   308,   309,   317,   318,   329,   336,   337
};

static const short yyrhs[] = {    -1,
    46,    47,    39,     0,    46,     1,    39,     0,     0,    66,
     0,    14,     0,    14,    40,    51,    41,     0,    29,    40,
    13,    41,     0,     7,     0,    18,    40,    37,    49,    42,
    41,     0,    50,     0,    49,    43,    50,     0,    37,    51,
    42,     0,     0,    52,     0,    70,     0,    52,    43,    70,
     0,    37,    54,    42,     0,     0,    55,     0,    65,     3,
     0,    55,    43,    65,     3,     0,     0,    25,    43,     0,
    27,    40,    58,    41,     0,    19,     0,    58,    43,    19,
     0,    58,     1,     0,    16,    40,    60,    41,     0,    61,
     0,    60,    43,    61,     0,    60,     1,     0,    64,    62,
     0,     0,    44,    63,     0,    64,     0,    20,     0,    40,
    64,    41,     0,    64,    33,    64,     0,    64,    36,    65,
    15,     0,    37,    64,    43,    64,    42,     0,    19,     0,
     0,    32,     0,     0,    14,    44,    67,    70,     0,    14,
    37,    70,    42,    44,    70,     0,     0,     5,    44,    68,
    70,     0,     0,     4,    44,    69,    70,     0,    40,    70,
    41,     0,    14,    40,    51,    41,     0,    70,    31,    70,
     0,    70,    32,    70,     0,    70,    33,    70,     0,    70,
    34,    70,     0,    32,    70,     0,    70,    36,    70,     0,
    37,    70,    43,    70,    42,     0,    30,    40,    70,    43,
    70,    41,     0,    70,     8,     9,    36,    70,     0,    14,
     0,     4,     0,     5,     0,     6,     0,     3,     0,    13,
     0,    17,    40,    51,    41,     0,    48,     0,    70,    38,
    70,     0,    70,    37,    70,    42,     0,     0,    10,    71,
    40,    56,     3,    43,    57,    43,    59,    41,     0,     0,
    22,    40,     3,    43,    13,    41,    72,    56,     3,    43,
    57,    43,    59,     0,    22,    40,     3,    43,    13,    45,
     0,    26,     0,     0,    11,    73,    40,     3,    43,    57,
    43,    59,    77,    41,     0,     0,    23,    40,     3,    43,
    13,    41,    74,     3,    43,    57,    43,    59,    77,     0,
    23,    40,     3,    43,    13,    45,     0,     0,    12,    75,
    40,    57,    43,    59,    41,     0,     0,    24,    40,     3,
    43,    13,    41,    76,    57,    43,    59,     0,    21,    40,
    70,    43,    13,    41,     0,     0,    28,    40,    53,    41,
     0
};

#endif

#if YYDEBUG != 0
static const short yyrline[] = { 0,
   209,   210,   214,   217,   218,   219,   230,   246,   247,   251,
   254,   265,   278,   281,   284,   287,   298,   311,   314,   317,
   320,   326,   335,   338,   342,   353,   358,   364,   367,   376,
   381,   387,   390,   398,   401,   404,   406,   410,   412,   419,
   426,   433,   444,   446,   450,   451,   466,   486,   487,   489,
   490,   493,   497,   515,   520,   525,   530,   535,   540,   545,
   550,   560,   569,   579,   584,   588,   592,   595,   598,   600,
   602,   619,   642,   645,   648,   651,   654,   656,   663,   665,
   676,   678,   688,   693,   695,   701,   703,   712,   726,   728
};

static const char * const yytname[] = {   "$","error","$illegal.","NUMBER","NGEN",
"CGEN","GRGEN","QUIT","MOD","IDEAL","DEFGRP","DEFPCGRP","DEFAGGRP","STRING",
"IDENTIFIER","NUM","RELS","SEQ","MATRIX","GEN","ID","READAUTGRP","READGRP","READPCGRP",
"READAGGRP","MINIMAL","ACTUAL","GENS","WEIGHTS","BATCH","COMMUT","'+'","'-'",
"'*'","'/'","UMINUS","'^'","'['","'.'","';'","'('","')'","']'","','","'='","'$'",
"cmdlist","stat","matrix","rowlist","row","exprlist","exprlistp","numlist","litems",
"litemsp","min","gendecl","gens","reldecl","rels","rel","rside","rword","lword",
"sign","assign","@1","@2","@3","expr","@4","@5","@6","@7","@8","@9","wdecl",
""
};
#endif

static const short yyr1[] = {     0,
    46,    46,    46,    47,    47,    47,    47,    47,    47,    48,
    49,    49,    50,    51,    51,    52,    52,    53,    54,    54,
    55,    55,    56,    56,    57,    58,    58,    58,    59,    60,
    60,    60,    61,    62,    62,    63,    63,    64,    64,    64,
    64,    64,    65,    65,    67,    66,    66,    68,    66,    69,
    66,    70,    70,    70,    70,    70,    70,    70,    70,    70,
    70,    70,    70,    70,    70,    70,    70,    70,    70,    70,
    70,    70,    71,    70,    72,    70,    70,    70,    73,    70,
    74,    70,    70,    75,    70,    76,    70,    70,    77,    77
};

static const short yyr2[] = {     0,
     0,     3,     3,     0,     1,     1,     4,     4,     1,     6,
     1,     3,     3,     0,     1,     1,     3,     3,     0,     1,
     2,     4,     0,     2,     4,     1,     3,     2,     4,     1,
     3,     2,     2,     0,     2,     1,     1,     3,     3,     4,
     5,     1,     0,     1,     0,     4,     6,     0,     4,     0,
     4,     3,     4,     3,     3,     3,     3,     2,     3,     5,
     6,     5,     1,     1,     1,     1,     1,     1,     4,     1,
     3,     4,     0,    10,     0,    13,     6,     1,     0,    10,
     0,    13,     6,     0,     7,     0,    10,     6,     0,     4
};

static const short yydefact[] = {     1,
     0,     0,     0,     0,     9,     6,     0,     0,     5,     3,
    50,    48,     0,    14,    45,     0,     2,     0,     0,    67,
    64,    65,    66,    73,    79,    84,    68,    63,     0,     0,
     0,     0,     0,     0,    78,     0,     0,     0,     0,    70,
     0,     0,    15,    16,     0,     0,    51,    49,     0,     0,
     0,    14,    14,     0,     0,     0,     0,     0,     0,    58,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     7,     0,    46,     8,    23,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,    52,     0,    54,
    55,    56,    57,    59,     0,    71,     0,    17,     0,     0,
     0,     0,     0,    53,    69,    14,     0,    11,     0,     0,
     0,     0,     0,     0,     0,    72,    47,    24,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
    60,    62,     0,     0,    26,     0,     0,     0,    13,    10,
    12,    88,    75,    77,    81,    83,    86,    61,     0,     0,
    28,    25,     0,     0,    85,    23,     0,     0,     0,    89,
    27,    42,     0,     0,     0,    30,    34,     0,     0,     0,
     0,     0,     0,     0,     0,    32,    29,     0,     0,    43,
     0,    33,     0,     0,     0,    74,     0,    80,     0,    38,
    31,    39,    44,     0,    37,    35,    36,     0,     0,    87,
    19,     0,     0,    40,     0,     0,     0,    20,     0,    90,
    41,     0,    89,    18,    43,    21,    76,    82,     0,    22,
     0,     0
};

static const short yydefgoto[] = {     1,
     8,    40,   107,   108,    42,    43,   202,   207,   208,   100,
   103,   136,   138,   165,   166,   182,   196,   167,   194,     9,
    45,    19,    18,    44,    49,   156,    50,   157,    51,   158,
   173
};

static const short yypact[] = {-32768,
    76,    -4,    -8,     5,-32768,    22,     8,    31,-32768,-32768,
-32768,-32768,   106,   106,-32768,    59,-32768,   106,   106,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,    33,    42,    45,
    54,    64,    66,    68,-32768,    81,   106,   106,   106,-32768,
   133,    34,    52,   218,   106,    62,   218,   218,    82,    86,
    95,   106,   106,   102,   106,   139,   141,   144,   106,   140,
    55,   191,   143,   106,   106,   106,   106,   106,   106,   106,
   129,-32768,   106,   218,-32768,   149,   177,   152,   142,   145,
   148,   117,   138,   146,   147,   125,   106,-32768,   151,   -17,
   -17,   140,   140,   140,   164,-32768,   106,   218,   150,   179,
   160,   154,   161,-32768,-32768,   106,   -33,-32768,   175,   178,
   192,   202,   106,   176,   106,-32768,   218,-32768,   173,   152,
   198,   204,   188,   180,   148,   190,   -23,    56,   197,   203,
-32768,   140,   152,   199,-32768,     2,   193,   205,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   200,   204,
-32768,-32768,   226,     4,-32768,   149,   189,   152,   204,   219,
-32768,-32768,     4,     4,    26,-32768,    63,   216,   210,   214,
   207,   220,   217,    35,   104,-32768,-32768,     4,     4,   227,
    94,-32768,   221,   152,   204,-32768,   224,-32768,     4,-32768,
-32768,   229,-32768,   247,-32768,-32768,    14,   152,   223,-32768,
     1,   222,    -2,-32768,   225,   204,   228,   230,   264,-32768,
-32768,   204,   219,-32768,   227,-32768,-32768,-32768,   266,-32768,
   271,-32768
};

static const short yypgoto[] = {-32768,
-32768,-32768,-32768,   153,   -45,-32768,-32768,-32768,-32768,   116,
  -119,-32768,  -148,-32768,    96,-32768,-32768,  -151,  -186,-32768,
-32768,-32768,-32768,   -13,-32768,-32768,-32768,-32768,-32768,-32768,
    67
};


#define	YYLAST		280


static const short yytable[] = {    41,
   134,   160,   151,   -43,    47,    48,    79,    80,   124,   125,
   171,   174,   175,   149,   209,    66,    67,   143,    68,    69,
    70,   144,   162,    60,    61,    62,   176,   192,   219,   197,
   179,    74,   193,   180,    10,    11,   200,   203,   170,   211,
   163,    82,   152,   164,   153,    86,   179,    16,    12,   180,
    90,    91,    92,    93,    94,    95,    96,   213,    13,    98,
   123,    14,    63,   217,   199,    15,   177,   179,   178,    17,
   180,    46,    52,   114,    72,   221,     2,   189,   205,     3,
     4,    53,     5,   117,    54,    64,    65,    66,    67,     6,
    68,    69,    70,    55,    73,   179,   145,    87,   180,   130,
   146,   132,    75,    56,     7,    57,   181,    58,    20,    21,
    22,    23,   162,   195,    -4,    24,    25,    26,    27,    28,
    59,    76,    29,    30,    63,    77,    31,    32,    33,    34,
   163,    35,    63,   164,    78,    36,   179,    37,    81,   180,
    63,    83,    38,    84,   190,    39,    85,    64,    65,    66,
    67,    89,    68,    69,    70,    64,    65,    66,    67,   109,
    68,    69,    70,    64,    65,    66,    67,   113,    68,    69,
    70,    63,    97,    99,    71,    68,    69,    70,   102,   101,
   110,   119,   104,    63,   106,   105,   115,   126,   111,   112,
   127,   169,   118,   121,    64,    65,    66,    67,    63,    68,
    69,    70,   120,   122,   128,   116,    64,    65,    66,    67,
    63,    68,    69,    70,   129,   133,   135,   131,   183,   137,
   140,    64,    65,    66,    67,    63,    68,    69,    70,   139,
   142,    88,   154,    64,    65,    66,    67,   147,    68,    69,
    70,   150,   159,   148,   161,   155,   172,   186,    64,    65,
    66,    67,   184,    68,    69,    70,   185,   188,   193,   187,
   201,   204,   210,   198,   180,   206,   216,   212,   220,   214,
   222,   168,   215,   191,     0,     0,     0,   141,     0,   218
};

static const short yycheck[] = {    13,
   120,   150,     1,     3,    18,    19,    52,    53,    42,    43,
   159,   163,   164,   133,   201,    33,    34,    41,    36,    37,
    38,    45,    19,    37,    38,    39,     1,   179,   215,   181,
    33,    45,    32,    36,    39,    44,   185,   189,   158,    42,
    37,    55,    41,    40,    43,    59,    33,    40,    44,    36,
    64,    65,    66,    67,    68,    69,    70,   206,    37,    73,
   106,    40,     8,   212,   184,    44,    41,    33,    43,    39,
    36,    13,    40,    87,    41,     0,     1,    43,   198,     4,
     5,    40,     7,    97,    40,    31,    32,    33,    34,    14,
    36,    37,    38,    40,    43,    33,    41,    43,    36,   113,
    45,   115,    41,    40,    29,    40,    44,    40,     3,     4,
     5,     6,    19,    20,    39,    10,    11,    12,    13,    14,
    40,    40,    17,    18,     8,    40,    21,    22,    23,    24,
    37,    26,     8,    40,    40,    30,    33,    32,    37,    36,
     8,     3,    37,     3,    41,    40,     3,    31,    32,    33,
    34,     9,    36,    37,    38,    31,    32,    33,    34,    43,
    36,    37,    38,    31,    32,    33,    34,    43,    36,    37,
    38,     8,    44,    25,    42,    36,    37,    38,    27,     3,
    43,     3,    41,     8,    37,    41,    36,    13,    43,    43,
    13,     3,    43,    40,    31,    32,    33,    34,     8,    36,
    37,    38,    43,    43,    13,    42,    31,    32,    33,    34,
     8,    36,    37,    38,    13,    43,    19,    42,     3,    16,
    41,    31,    32,    33,    34,     8,    36,    37,    38,    42,
    41,    41,    40,    31,    32,    33,    34,    41,    36,    37,
    38,    43,    43,    41,    19,    41,    28,    41,    31,    32,
    33,    34,    43,    36,    37,    38,    43,    41,    32,    40,
    37,    15,    41,    43,    36,    43,     3,    43,     3,    42,
     0,   156,    43,   178,    -1,    -1,    -1,   125,    -1,   213
};
/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */


/* Skeleton output parser for bison,
   Copyright (C) 1984, 1989, 1990 Bob Corbett and Richard Stallman

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 1, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */


#ifndef alloca
#ifdef __GNUC__
#define alloca __builtin_alloca
#else /* not GNU C.  */
#if (!defined (__STDC__) && defined (sparc)) || defined (__sparc__) || defined (__sparc) || defined (__sgi)
#include <alloca.h>
#else /* not sparc */
#if defined (MSDOS) && !defined (__TURBOC__)
#include <malloc.h>
#else /* not MSDOS, or __TURBOC__ */
#if defined(_AIX)
#include <malloc.h>
 #pragma alloca
#else /* not MSDOS, __TURBOC__, or _AIX */
#ifdef __hpux
#ifdef __cplusplus
extern "C" {
void *alloca (unsigned int);
};
#else /* not __cplusplus */
void *alloca ();
#endif /* not __cplusplus */
#endif /* __hpux */
#endif /* not _AIX */
#endif /* not MSDOS, or __TURBOC__ */
#endif /* not sparc.  */
#endif /* not GNU C.  */
#endif /* alloca not defined.  */

/* This is the parser code that is written into each bison parser
  when the %semantic_parser declaration is not specified in the grammar.
  It was written by Richard Stallman by simplifying the hairy parser
  used when %semantic_parser is specified.  */

/* Note: there must be only one dollar sign in this file.
   It is replaced by the list of actions, each action
   as one case of the switch.  */

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYACCEPT	return(0)
#define YYABORT 	return(1)
#define YYERROR		goto yyerrlab1
/* Like YYERROR except do call yyerror.
   This remains here temporarily to ease the
   transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */
#define YYFAIL		goto yyerrlab
#define YYRECOVERING()  (!!yyerrstatus)
#define YYBACKUP(token, value) \
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    { yychar = (token), yylval = (value);			\
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { yyerror ("syntax error: cannot back up"); YYERROR; }	\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

#ifndef YYPURE
#define YYLEX		yylex()
#endif

#ifdef YYPURE
#ifdef YYLSP_NEEDED
#define YYLEX		yylex(&yylval, &yylloc)
#else
#define YYLEX		yylex(&yylval)
#endif
#endif

/* If nonreentrant, generate the variables here */

#ifndef YYPURE

int	yychar;			/*  the lookahead symbol		*/
YYSTYPE	yylval;			/*  the semantic value of the		*/
				/*  lookahead symbol			*/

#ifdef YYLSP_NEEDED
YYLTYPE yylloc;			/*  location data for the lookahead	*/
				/*  symbol				*/
#endif

int yynerrs;			/*  number of parse errors so far       */
#endif  /* not YYPURE */

#if YYDEBUG != 0
int yydebug;			/*  nonzero means print parse trace	*/
/* Since this is uninitialized, it does not stop multiple parsers
   from coexisting.  */
#endif

/*  YYINITDEPTH indicates the initial size of the parser's stacks	*/

#ifndef	YYINITDEPTH
#define YYINITDEPTH 200
#endif

/*  YYMAXDEPTH is the maximum size the stacks can grow to
    (effective only if the built-in stack extension method is used).  */

#if YYMAXDEPTH == 0
#undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 10000
#endif

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
int yyparse (void);
#endif

#if __GNUC__ > 1		/* GNU C and GNU C++ define this.  */
#define __yy_bcopy(FROM,TO,COUNT)	__builtin_memcpy(TO,FROM,COUNT)
#else				/* not GNU C or C++ */
#ifndef __cplusplus

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_bcopy (from, to, count)
     char *from;
     char *to;
     int count;
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#else /* __cplusplus */

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_bcopy (char *from, char *to, int count)
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#endif
#endif


int
yyparse()
{
  register int yystate;
  register int yyn;
  register short *yyssp;
  register YYSTYPE *yyvsp;
  int yyerrstatus;	/*  number of tokens to shift before error messages enabled */
  int yychar1 = 0;		/*  lookahead token as an internal (translated) token number */

  short	yyssa[YYINITDEPTH];	/*  the state stack			*/
  YYSTYPE yyvsa[YYINITDEPTH];	/*  the semantic value stack		*/

  short *yyss = yyssa;		/*  refer to the stacks thru separate pointers */
  YYSTYPE *yyvs = yyvsa;	/*  to allow yyoverflow to reallocate them elsewhere */

#ifdef YYLSP_NEEDED
  YYLTYPE yylsa[YYINITDEPTH];	/*  the location stack			*/
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
#define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  int yystacksize = YYINITDEPTH;

#ifdef YYPURE
  int yychar;
  YYSTYPE yylval;
  int yynerrs;
#ifdef YYLSP_NEEDED
  YYLTYPE yylloc;
#endif
#endif

  YYSTYPE yyval;		/*  the variable used to return		*/
				/*  semantic values from the action	*/
				/*  routines				*/

  int yylen;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Starting parse\n");
#endif

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;
#ifdef YYLSP_NEEDED
  yylsp = yyls;
#endif

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
yynewstate:

  *++yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Give user a chance to reallocate the stack */
      /* Use copies of these so that the &'s don't force the real ones into memory. */
      YYSTYPE *yyvs1 = yyvs;
      short *yyss1 = yyss;
#ifdef YYLSP_NEEDED
      YYLTYPE *yyls1 = yyls;
#endif

      /* Get the current used size of the three stacks, in elements.  */
      int size = yyssp - yyss + 1;

#ifdef yyoverflow
      /* Each stack pointer address is followed by the size of
	 the data in use in that stack, in bytes.  */
#ifdef YYLSP_NEEDED
      /* This used to be a conditional around just the two extra args,
	 but that might be undefined if yyoverflow is a macro.  */
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yyls1, size * sizeof (*yylsp),
		 &yystacksize);
#else
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yystacksize);
#endif

      yyss = yyss1; yyvs = yyvs1;
#ifdef YYLSP_NEEDED
      yyls = yyls1;
#endif
#else /* no yyoverflow */
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	{
	  yyerror("parser stack overflow");
	  return 2;
	}
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;
      yyss = (short *) alloca (yystacksize * sizeof (*yyssp));
      __yy_bcopy ((char *)yyss1, (char *)yyss, size * sizeof (*yyssp));
      yyvs = (YYSTYPE *) alloca (yystacksize * sizeof (*yyvsp));
      __yy_bcopy ((char *)yyvs1, (char *)yyvs, size * sizeof (*yyvsp));
#ifdef YYLSP_NEEDED
      yyls = (YYLTYPE *) alloca (yystacksize * sizeof (*yylsp));
      __yy_bcopy ((char *)yyls1, (char *)yyls, size * sizeof (*yylsp));
#endif
#endif /* no yyoverflow */

      yyssp = yyss + size - 1;
      yyvsp = yyvs + size - 1;
#ifdef YYLSP_NEEDED
      yylsp = yyls + size - 1;
#endif

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Stack size increased to %d\n", yystacksize);
#endif

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Entering state %d\n", yystate);
#endif

  goto yybackup;
 yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Reading a token: ");
#endif
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Now at end of input.\n");
#endif
    }
  else
    {
      yychar1 = YYTRANSLATE(yychar);

#if YYDEBUG != 0
      if (yydebug)
	{
	  fprintf (stderr, "Next token is %d (%s", yychar, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise meaning
	     of a token, for further debugging info.  */
#ifdef YYPRINT
	  YYPRINT (stderr, yychar, yylval);
#endif
	  fprintf (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting token %d (%s), ", yychar, yytname[yychar1]);
#endif

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  goto yynewstate;

/* Do the default action for the current state.  */
yydefault:

  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
yyreduce:
  yylen = yyr2[yyn];
  if (yylen > 0)
    yyval = yyvsp[1-yylen]; /* implement default value of the action */

#if YYDEBUG != 0
  if (yydebug)
    {
      int i;

      fprintf (stderr, "Reducing via rule %d (line %d), ",
	       yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (i = yyprhs[yyn]; yyrhs[i] > 0; i++)
	fprintf (stderr, "%s ", yytname[yyrhs[i]]);
      fprintf (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif


  switch (yyn) {

case 2:
{ proc_error();
                 use_prompt1 = TRUE;
			  aut_pres_style = NONE; ;
    break;}
case 3:
{  yyerrok; ;
    break;}
case 6:
{ if ( (yysym = find_symbol ( yyvsp[0].gval->pval ) ) != NULL ) {
                    if ( yysym->type == NOTYPE ) {
				   yyfunc = (FUNCDSC *)yysym->object;
				   if ( do_check_args ( yyfunc, NULL, FALSE ) != -1 )
				       yyfunc->wrapper_func ( NULL );
				 }
			   }
			  else
				 set_error ( NO_SUCH_PROC );
			;
    break;}
case 7:
{ 
			    if ( (yysym = find_symbol ( yyvsp[-3].gval->pval ) ) != NULL ) {
				   if ( yysym->type == NOTYPE )
					  if ( IS_VALID ( yyvsp[-1].gval ) ) {
						 yyfunc = (FUNCDSC *)yysym->object;
						 if ( do_check_args ( yyfunc, (LISTP *)yyvsp[-1].gval->pval,
										  FALSE ) != -1 )
							yyfunc->wrapper_func ( (LISTP *)yyvsp[-1].gval->pval );
					  }
					  else
						 set_error ( UNDEFINED_EXPRESSION );
			    }
			    else
				   set_error ( NO_SUCH_PROC );
			;
    break;}
case 9:
{ YYACCEPT; ;
    break;}
case 10:
{ yyval.gval = yyvsp[-2].gval;;
    break;}
case 11:
{ if ( IS_VALID ( yyvsp[0].gval ) ) { 
	          yyval.gval = galloc ( DLIST );
			((LISTP *)yyval.gval->pval)->first = ((LISTP *)yyval.gval->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->first->value.gv = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->first->type = yyvsp[0].gval->exptype;
			((LISTP *)yyval.gval->pval)->first->next = NULL; 
	          }
			else 
                  yyval.gval = NULL;
               ;
    break;}
case 12:
{ if ( IS_VALID ( yyvsp[0].gval ) ) {
               yyval.gval = yyvsp[-2].gval;
			((LISTP *)yyval.gval->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->last = ((LISTP *)yyval.gval->pval)->last->next;
			((LISTP *)yyval.gval->pval)->last->value.gv = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->last->type = yyvsp[0].gval->exptype;
			((LISTP *)yyval.gval->pval)->last->next = NULL;
			}
               else
			   yyval.gval = yyvsp[-2].gval;
               ;
    break;}
case 13:
{ yyval.gval = yyvsp[-1].gval; ;
    break;}
case 14:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = NULL; ;
    break;}
case 15:
{ yyval.gval = yyvsp[0].gval; ;
    break;}
case 16:
{ if ( IS_VALID ( yyvsp[0].gval ) ) { 
	          yyval.gval = galloc ( DLIST );
			((LISTP *)yyval.gval->pval)->first = ((LISTP *)yyval.gval->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->first->value.gv = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->first->type = yyvsp[0].gval->exptype;
			((LISTP *)yyval.gval->pval)->first->next = NULL; 
	          }
			else 
                  yyval.gval = NULL;
               ;
    break;}
case 17:
{ if ( IS_VALID ( yyvsp[0].gval ) ) {
               yyval.gval = yyvsp[-2].gval;
			((LISTP *)yyval.gval->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->last = ((LISTP *)yyval.gval->pval)->last->next;
			((LISTP *)yyval.gval->pval)->last->value.gv = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->last->type = yyvsp[0].gval->exptype;
			((LISTP *)yyval.gval->pval)->last->next = NULL;
			}
               else
			   yyval.gval = yyvsp[-2].gval;
               ;
    break;}
case 18:
{ yyval.gval = yyvsp[-1].gval;;
    break;}
case 19:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = NULL; ;
    break;}
case 20:
{ yyval.gval = yyvsp[0].gval; ;
    break;}
case 21:
{ yyval.gval = galloc ( DLIST );
			((LISTP *)yyval.gval->pval)->first = ((LISTP *)yyval.gval->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->first->value.intv = yyvsp[-1].ival*yyvsp[0].ival;
			((LISTP *)yyval.gval->pval)->first->type = INT;
			((LISTP *)yyval.gval->pval)->first->next = NULL; ;
    break;}
case 22:
{ yyval.gval = yyvsp[-3].gval;
			((LISTP *)yyval.gval->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->last = ((LISTP *)yyval.gval->pval)->last->next;
			((LISTP *)yyval.gval->pval)->last->value.intv = yyvsp[-1].ival*yyvsp[0].ival;
			((LISTP *)yyval.gval->pval)->last->type = INT;
			((LISTP *)yyval.gval->pval)->last->next = NULL; ;
    break;}
case 23:
{ yyval.ival = 0;
			g_desc->is_minimal = FALSE; ;
    break;}
case 24:
{ yyval.ival = 1;
			g_desc->is_minimal = TRUE; ;
    break;}
case 25:
{ i = 0;
			for ( p = ((LISTP *)yyvsp[-1].gval->pval)->first; p != NULL; p = p->next ) i++;
			g_desc->num_gen = i;
			g_desc->gen = ALLOCATE ( i * sizeof ( char * ) );
			i = 0;
			for ( p = ((LISTP *)yyvsp[-1].gval->pval)->first; p != NULL; p = p->next ) {
				g_desc->gen[i] = ALLOCATE ( strlen ( (char *)p->value.gv )+1 );
				strcpy ( g_desc->gen[i++], (char *)p->value.gv );
			} ;
    break;}
case 26:
{ yyval.gval = galloc ( DLIST );
			((LISTP *)yyval.gval->pval)->first = ((LISTP *)yyval.gval->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->first->value.gv = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->first->next = NULL; ;
    break;}
case 27:
{ yyval.gval = yyvsp[-2].gval;
			((LISTP *)yyval.gval->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->last = ((LISTP *)yyval.gval->pval)->last->next;
			((LISTP *)yyval.gval->pval)->last->value.gv = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->last->next = NULL; ;
    break;}
case 28:
{ yyclearin; ;
    break;}
case 29:
{ i = 0;
			for ( p = ((LISTP *)yyvsp[-1].gval->pval)->first; p != NULL; p = p->next ) i++;
			g_desc->num_rel = i;
			g_desc->rel_list = (node *)ALLOCATE ( i * sizeof ( node ) );
			i = 0;
			for ( p = ((LISTP *)yyvsp[-1].gval->pval)->first; p != NULL; p = p->next )
				g_desc->rel_list[i++] = p->value.nodev; ;
    break;}
case 30:
{ yyval.gval = galloc ( DLIST );
			((LISTP *)yyval.gval->pval)->first = ((LISTP *)yyval.gval->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->first->value.nodev = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->first->next = NULL; ;
    break;}
case 31:
{ yyval.gval = yyvsp[-2].gval;
			((LISTP *)yyval.gval->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)yyval.gval->pval)->last = ((LISTP *)yyval.gval->pval)->last->next;
			((LISTP *)yyval.gval->pval)->last->value.nodev = yyvsp[0].gval->pval;
			((LISTP *)yyval.gval->pval)->last->next = NULL; ;
    break;}
case 32:
{ yyclearin; ;
    break;}
case 33:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = ALLOCATE ( node_size );
			  ((node)yyval.gval->pval)->nodetype = EQ;
			  ((node)yyval.gval->pval)->value = 0;
			  ((node)yyval.gval->pval)->left = yyvsp[-1].gval->pval;
			  ((node)yyval.gval->pval)->right = yyvsp[0].gval->pval; ;
    break;}
case 34:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = NULL; ;
    break;}
case 35:
{ yyval.gval = yyvsp[0].gval; ;
    break;}
case 36:
{ yyval.gval = yyvsp[0].gval; ;
    break;}
case 37:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = NULL; ;
    break;}
case 38:
{ yyval.gval = yyvsp[-1].gval; ;
    break;}
case 39:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = ALLOCATE ( node_size );
			  ((node)yyval.gval->pval)->nodetype = MULT;
			  ((node)yyval.gval->pval)->value = 0;
			  ((node)yyval.gval->pval)->left = yyvsp[-2].gval->pval;
			  ((node)yyval.gval->pval)->right = yyvsp[0].gval->pval; ;
    break;}
case 40:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = ALLOCATE ( node_size );
			  ((node)yyval.gval->pval)->nodetype = EXP;
			  ((node)yyval.gval->pval)->value = yyvsp[-1].ival*yyvsp[0].ival;
			  ((node)yyval.gval->pval)->left = yyvsp[-3].gval->pval;
			  ((node)yyval.gval->pval)->right = NULL; ;
    break;}
case 41:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = ALLOCATE ( node_size );
			  ((node)yyval.gval->pval)->nodetype = COMM;
			  ((node)yyval.gval->pval)->value = 0;
			  ((node)yyval.gval->pval)->left = yyvsp[-3].gval->pval;
			  ((node)yyval.gval->pval)->right = yyvsp[-1].gval->pval; ;
    break;}
case 42:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = ALLOCATE ( node_size );
			  ((node)yyval.gval->pval)->nodetype = GGEN;
			  if ( (((node)yyval.gval->pval)->value = find_gen ( yyvsp[0].gval->pval )) == -1 ) {
			  	set_error ( INVALID_GENERATOR );
			  }
			  ((node)yyval.gval->pval)->left = NULL;
			  ((node)yyval.gval->pval)->right = NULL;
			;
    break;}
case 43:
{ yyval.ival = 1; ;
    break;}
case 44:
{ yyval.ival = -1; ;
    break;}
case 45:
{ tpush_stack(); ;
    break;}
case 46:
{ if ( IS_VALID ( yyvsp[0].gval ) && ( error_no == NO_ERROR ) ) {
				if ( (yysym = find_symbol ( yyvsp[-3].gval->pval ) ) == NULL ) {
					yysym = new_symbol ( yyvsp[-3].gval->pval, 0 );
					yysym = add_symbol ( yysym );
				}
				yysym->type = yyvsp[0].gval->exptype;
				assign_symbol ( (void **)&yysym->object, yyvsp[0].gval );
				if ( yysym->type == GROUP )
				    strncpy ( ((GRPDSC *)yysym->object)->group_name,
						    yysym->name, NAME_MAX+1 );
				if ( yysym->type == PCGROUP )
				    strncpy ( ((PCGRPDESC *)yysym->object)->group_name,
						    yysym->name, NAME_MAX+1 );
				tpop_stack();
			} ;
    break;}
case 47:
{ if ( (yysym = find_symbol ( yyvsp[-5].gval->pval ) ) == NULL ) {
				 set_error ( UNDEF_IDENTIFIER );
			  }
			  else {
				 if ( yysym->type == DLIST )
					if ( (IS_VALID ( yyvsp[-3].gval )) && (IS_VALID ( yyvsp[0].gval )) )
					    if ( yyvsp[-3].gval->exptype == INT ) {
						   insert_list_item ( (LISTP *)yysym->object,
								*(int *)yyvsp[-3].gval->pval-1, yyvsp[0].gval ); 
					    }
					    else
						   set_error ( IS_NOT_TYPE_INT );
					else
					    set_error ( UNDEFINED_EXPRESSION );
				 else
					set_error ( IS_NOT_TYPE_DLIST );

			  }
			;
    break;}
case 48:
{ tpush_stack(); ;
    break;}
case 49:
{ set_error ( GEN_MAY_NOT_BE_REASSIGNED );
			  tpop_stack(); ;
    break;}
case 50:
{ tpush_stack(); ;
    break;}
case 51:
{ set_error ( GEN_MAY_NOT_BE_REASSIGNED );
			  tpop_stack(); ;
    break;}
case 52:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->exptype = yyvsp[-1].gval->exptype;
			  yyval.gval->pval = yyvsp[-1].gval->pval; ;
    break;}
case 53:
{ yyval.gval = NULL;
			  if ( (yysym = find_symbol ( yyvsp[-3].gval->pval ) ) != NULL ) {
                    if ( yysym->type == NOTYPE ) {
				    yyfunc = (FUNCDSC *)yysym->object;
				    if ( (rt = do_check_args ( yyfunc, 
						  (LISTP *)yyvsp[-1].gval->pval, TRUE )) != -1 ) {
                           yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
				       yyval.gval->pval = yyfunc->wrapper_func ( (LISTP *)yyvsp[-1].gval->pval );
					  yyval.gval->exptype = rt;
				    }
			     }
				else
				    set_error ( NO_SUCH_PROC );
			  }
			  else 
				 set_error ( NO_SUCH_PROC );
	          ;
    break;}
case 54:
{ if ( (IS_VALID ( yyvsp[-2].gval )) && (IS_VALID ( yyvsp[0].gval )) )
				yyval.gval = do_op ( yyvsp[-2].gval, yyvsp[0].gval, O_ADD );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 55:
{ if ( (IS_VALID ( yyvsp[-2].gval )) && (IS_VALID ( yyvsp[0].gval )) )
				yyval.gval = do_op ( yyvsp[-2].gval, yyvsp[0].gval, O_SUB );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 56:
{ if ( (IS_VALID ( yyvsp[-2].gval )) && (IS_VALID ( yyvsp[0].gval )) )
				yyval.gval = do_op ( yyvsp[-2].gval, yyvsp[0].gval, O_MUL );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 57:
{ if ( (IS_VALID ( yyvsp[-2].gval )) && (IS_VALID ( yyvsp[0].gval )) )
				yyval.gval = do_op ( yyvsp[-2].gval, yyvsp[0].gval, O_DIV );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 58:
{ if ( IS_VALID ( yyvsp[0].gval ) )
				yyval.gval = do_op ( yyvsp[0].gval, NULL, O_UMI );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 59:
{ if ( (IS_VALID ( yyvsp[-2].gval )) && (IS_VALID ( yyvsp[0].gval )) )
				yyval.gval = do_op ( yyvsp[-2].gval, yyvsp[0].gval, O_EXP );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 60:
{ if ( (IS_VALID ( yyvsp[-3].gval )) && (IS_VALID ( yyvsp[-1].gval )) )
				yyval.gval = do_op ( yyvsp[-3].gval, yyvsp[-1].gval, O_LIE );
			  else
			  	yyval.gval = NULL; ;
    break;}
case 61:
{ if ( (IS_VALID ( yyvsp[-3].gval )) && (IS_VALID ( yyvsp[-1].gval )) )
				if ( (yyvsp[-3].gval->exptype == GRELEMENT) && (yyvsp[-3].gval->exptype == GRELEMENT) ) {
					yyval.gval = galloc ( GRELEMENT );
					yyval.gval->pval = mult_comm ( (VEC)yyvsp[-3].gval->pval, (VEC)yyvsp[-1].gval->pval, cut );
					if ( yyval.gval->pval == NULL )
						yyval.gval = NULL;
				}
			  else
			  	yyval.gval = NULL; ;
    break;}
case 62:
{ yyval.gval = NULL;
			if ( (IS_VALID ( yyvsp[-4].gval )) && (yyvsp[-4].gval->exptype == GRELEMENT) )
			    if ( (IS_VALID ( yyvsp[0].gval )) && (yyvsp[0].gval->exptype == INT) ) {
				   yyval.gval = galloc ( GRELEMENT );
				   copy_vector ( yyvsp[-4].gval->pval, yyval.gval->pval, 
							  FILTRATION[*(int *)yyvsp[0].gval->pval].i_start );
			    }
			;
    break;}
case 63:
{ yyval.gval = NULL; 
			if ( (yysym = find_symbol ( yyvsp[0].gval->pval ) ) != NULL ) {
				yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
				yyval.gval->exptype = yysym->type;
				yyval.gval->pval = yysym->object;
			} 
			else
			    set_error ( UNDEF_IDENTIFIER );
			;
    break;}
case 64:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->exptype = GRELEMENT;
			  yyval.gval->pval = NGEN_VEC[yyvsp[0].ival];
			;
    break;}
case 65:
{ yyval.gval = galloc ( GRELEMENT );
			  copy_vector ( NGEN_VEC[yyvsp[0].ival], (char *)yyval.gval->pval, fend );
			  ((VEC)yyval.gval->pval)[0] = 1; ;
    break;}
case 66:
{ yyval.gval = galloc ( GROUPEL );
			  copy_vector ( group_desc->nom[yyvsp[0].ival], (PCELEM)yyval.gval->pval, bperelem );
			;
    break;}
case 67:
{ yyval.gval = galloc ( INT );
			  *((int *)yyval.gval->pval) = yyvsp[0].ival; ;
    break;}
case 68:
{ yyval.gval = galloc ( NSTRING );
			  yyval.gval->pval = yyvsp[0].gval->pval; ;
    break;}
case 69:
{ yyval.gval = yyvsp[-1].gval; ;
    break;}
case 70:
{ yyval.gval = yyvsp[0].gval; ;
    break;}
case 71:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
                 yyval.gval->pval = NULL;
	            if ( IS_VALID ( yyvsp[-2].gval ) )
                    if ( IS_VALID ( yyvsp[0].gval ) )
                       if ( yyvsp[0].gval->exptype == INT ) {
	                     yyval.gval->pval = get_record_field ( yyvsp[-2].gval, *(int *)yyvsp[0].gval->pval-1,
                                                        &rt );
			           yyval.gval->exptype = rt;
                       }
                       else
                          set_error ( IS_NOT_TYPE_INT );
                    else
                       set_error ( UNDEFINED_EXPRESSION );
                 else
                    set_error ( UNDEFINED_EXPRESSION );
               ;
    break;}
case 72:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			  yyval.gval->pval = NULL;
                 if ( IS_VALID ( yyvsp[-3].gval ) )
                    if ( yyvsp[-3].gval->exptype == DLIST )
				   if ( IS_VALID ( yyvsp[-1].gval ) )
				      if ( yyvsp[-1].gval->exptype == INT ) {
					    yyval.gval->pval = get_list_item ( (LISTP *)yyvsp[-3].gval->pval, 
                                          *(int *)yyvsp[-1].gval->pval-1, &rt ); 
					    yyval.gval->exptype = rt;
                          }
				      else
				         set_error ( IS_NOT_TYPE_INT );
                        else
                           set_error ( UNDEFINED_EXPRESSION );
                     else
                        set_error ( IS_NOT_TYPE_DLIST );
                  else
                     set_error ( UNDEFINED_EXPRESSION );
                ;
    break;}
case 73:
{ yyhval = galloc ( GROUP ); 
			g_desc = (GRPDSC *)yyhval->pval ;
    break;}
case 74:
{ g_desc->prime = yyvsp[-5].ival;
			  yyval.gval = yyhval; ;
    break;}
case 75:
{ yyhval = galloc ( GROUP ); 
			  g_desc = (GRPDSC *)yyhval->pval ;
    break;}
case 76:
{ g_desc->prime = yyvsp[-4].ival;
			  yyval.gval = yyhval; ;
    break;}
case 77:
{ yyval.gval = NULL; ;
    break;}
case 78:
{ yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			yyval.gval->exptype = GROUP;
			yyval.gval->pval = h_desc; ;
    break;}
case 79:
{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); ;
    break;}
case 80:
{ g_desc->prime = yyvsp[-6].ival;
			yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			yyval.gval->exptype = PCGROUP;
			yyval.gval->pval = grp_to_pcgrp ( g_desc );
			if ( yyvsp[-1].gval != NULL ) {
				i = 0;
				for ( p = ((LISTP *)yyvsp[-1].gval->pval)->first; p != NULL; p = p->next )
				((PCGRPDESC *)yyval.gval->pval)->g_ideal[i++] = p->value.intv;
			}
			;
    break;}
case 81:
{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); ;
    break;}
case 82:
{ g_desc->prime = yyvsp[-5].ival;
			yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			yyval.gval->exptype = PCGROUP;
			yyval.gval->pval = grp_to_pcgrp ( g_desc );
			if ( yyvsp[0].gval != NULL ) {
				i = 0;
				for ( p = ((LISTP *)yyvsp[0].gval->pval)->first; p != NULL; p = p->next )
				((PCGRPDESC *)yyval.gval->pval)->g_ideal[i++] = p->value.intv;
			} ;
    break;}
case 83:
{ yyval.gval = NULL; ;
    break;}
case 84:
{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); ;
    break;}
case 85:
{ 
			yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			yyval.gval->exptype = AGGROUP;
			yyval.gval->pval = grp_to_aggrp ( g_desc );
			;
    break;}
case 86:
{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); ;
    break;}
case 87:
{
			yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
			yyval.gval->exptype = AGGROUP;
			yyval.gval->pval = grp_to_aggrp ( g_desc );
			;
    break;}
case 88:
{ if ( (IS_VALID ( yyvsp[-3].gval )) && (IS_VALID ( yyvsp[-1].gval )) )
				if ( yyvsp[-3].gval->exptype == PCGROUP ) {
					yyval.gval = ALLOCATE ( sizeof ( GENVAL ) );
					yyval.gval->exptype = HOMREC;
					yyval.gval->pval = aut_read ( (char *)yyvsp[-1].gval->pval, (PCGRPDESC *)yyvsp[-3].gval->pval );
			  	}
			  	else
			  		set_error ( IS_NOT_TYPE_PCGROUP );
			  else
			  	set_error ( UNDEFINED_EXPRESSION );
			;
    break;}
case 89:
{ yyval.gval = NULL; ;
    break;}
case 90:
{ yyval.gval = yyvsp[-1].gval; ;
    break;}
}
   /* the action file gets copied in in place of this dollarsign */


  yyvsp -= yylen;
  yyssp -= yylen;
#ifdef YYLSP_NEEDED
  yylsp -= yylen;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;

#ifdef YYLSP_NEEDED
  yylsp++;
  if (yylen == 0)
    {
      yylsp->first_line = yylloc.first_line;
      yylsp->first_column = yylloc.first_column;
      yylsp->last_line = (yylsp-1)->last_line;
      yylsp->last_column = (yylsp-1)->last_column;
      yylsp->text = 0;
    }
  else
    {
      yylsp->last_line = (yylsp+yylen-1)->last_line;
      yylsp->last_column = (yylsp+yylen-1)->last_column;
    }
#endif

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;

yyerrlab:   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
      ++yynerrs;

#ifdef YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  int size = 0;
	  char *msg;
	  int x, count;

	  count = 0;
	  /* Start X at -yyn if nec to avoid negative indexes in yycheck.  */
	  for (x = (yyn < 0 ? -yyn : 0);
	       x < (sizeof(yytname) / sizeof(char *)); x++)
	    if (yycheck[x + yyn] == x)
	      size += strlen(yytname[x]) + 15, count++;
	  msg = (char *) malloc(size + 15);
	  if (msg != 0)
	    {
	      strcpy(msg, "parse error");

	      if (count < 5)
		{
		  count = 0;
		  for (x = (yyn < 0 ? -yyn : 0);
		       x < (sizeof(yytname) / sizeof(char *)); x++)
		    if (yycheck[x + yyn] == x)
		      {
			strcat(msg, count == 0 ? ", expecting `" : " or `");
			strcat(msg, yytname[x]);
			strcat(msg, "'");
			count++;
		      }
		}
	      yyerror(msg);
	      free(msg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exceeded");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror("parse error");
    }

  goto yyerrlab1;
yyerrlab1:   /* here on error raised explicitly by an action */

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Discarding token %d (%s).\n", yychar, yytname[yychar1]);
#endif

      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;

yyerrdefault:  /* current state does not do anything special for the error token. */

#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */
  yyn = yydefact[yystate];  /* If its default is to accept any token, ok.  Otherwise pop it.*/
  if (yyn) goto yydefault;
#endif

yyerrpop:   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#ifdef YYLSP_NEEDED
  yylsp--;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "Error: state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

yyerrhandle:

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting error token, ");
#endif

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  yystate = yyn;
  goto yynewstate;
}


int yyerror ( s )
char *s;
{
	if ( (strcmp ( s, "parse error")) == 0 ) {
		set_error ( SYNTAX_ERROR );
		proc_error();
	}
	else
		fprintf ( stderr, "Unexpected error: %s\n", s );
	return 0;
}

static int find_gen ( char *name )
{
	int i;
	
	for ( i = 0; i < g_desc->num_gen; i++ )
		if ( !strcmp ( g_desc->gen[i], name ) )
			return ( i );
	return ( -1 );
}

void sys_init ( void )
{
	/* get dynamic storage */
	if ( ( mem_bottom = get_memblock ( amount ) ) == NULL ) {
		puts ( "amount not available !!!!!" );
		exit(-1);
	}

	if ( ( mem_bottom = tget_memblock ( tamount ) ) == NULL ) {
		puts ( "temporary amount not available !!!!!" );
		exit(-1);
	}

	init_mem_stats();
	/* set output to stdout */
	out_hdl = stdout;

	/* init dispatcher */
	use_permanent_stack();
	init_act_table();
	use_temporary_stack();
	
	/* set initial value for prime and setup arithmetic for GF(2) */
	prime = 2;
	swap_arith ( 2 );
	
	/* initialize matrix */
	init_matrix();
	
	/* initialize paths */
	set_paths();
	
	/* initialize algorithm flags */
	flags[0] = use_filtration;
	flags[1] = use_max_elab_sections;
	flags[2] = only_normal_auts;
	flags[3] = use_fail_list;
	flags[4] = with_inner;

	/* initialize group ring multiplication routines */
	group_mul = n_group_mul;
	cgroup_mul = c_group_mul;
	group_exp = ngroup_exp;
	
	mon_per_line = 16;
	if ( banner ) {
		show_logo();
		show_settings();
	}

	if ( use_proto ) {
		proto_p = add_path ( "PROTO", proto_n );
		if ( (proto = fopen ( proto_p, "w" ) ) == 0 )
			printf ( "ERROR : couldn't open logfile !!!\n" );
	}
}

int main ( int argc, char *argv[] )
{
	int c;
	
#ifdef YYDEBUG
	yydebug = 1;
#endif

	amount  = 100000L;
	tamount = 300000L;
	root_path[0] = '\0';
	strcpy ( proto_n, "LOGFILE0.dat" );
	strcpy ( in_n, "ideal000.lif" );
	strcpy ( out_n, "ideal000.lif" );
	while ( (c = getopt ( argc, argv, "m:t:l:p:d:s:e:f:u:w:bq" )) != -1 )
		switch ( c ) {
		case 'm':
		    amount = atol ( optarg );
		    break;
		case 't':
		    tamount = atol ( optarg );
		    break;
		case 'l':
		    strcpy ( root_path, optarg );
		    break;
		case 'p':
		    strcpy ( proto_n, optarg );
		    use_proto = TRUE;
		    break;
		case 'd':
		    strcpy ( in_n, optarg );
		    strcpy ( out_n, optarg );
		    break;
		case 's':
		    if ( strcmp ( "gap", optarg ) == 0 ) {
			   displaystyle = GAP;					
			   strcpy ( prompt1, "# " );
			   strcpy ( prompt2, "# " );
		    }
		    break;
		case 'e':
		    strcpy ( pcgroup_lib, optarg );
		    break;
		case 'f':
		    strcpy ( group_lib, optarg );
		    break;
		case 'u':
		    pcgroup_num = atoi ( optarg );
		    break;
		case 'w':
		    group_num = atoi ( optarg );
		    break;
		case 'b':
		    banner = FALSE;
		    break;
		case 'q':
		    quiet = TRUE;
		    break;
		case '?':
		    exit (-1);
		    break;
		}
	
	init_memory_stack();
	sys_init();
	init_sym_tab();

#ifdef HAVE_LIBREADLINE
	initialize_readline();
#endif

	yyparse();
	if ( !quiet && (displaystyle != GAP) )
		memory_usage();
	return 0;
}


