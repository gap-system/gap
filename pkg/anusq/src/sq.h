/****************************************************************************
**
**    eapquot.h                       SQ                   Alice C. Niemeyer
**
**    Copyright 1993                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
**
**
**  Header file for the Soluble Quotient Algorithm.
**
*/

#include <stdio.h>

extern FILE * FN, * GAPFP;
/*
** Debug Variable
*/
int Debug;

/* 
**  The elements of the augmented group consist of 2 parts. One is the
**  element of the factor group and one is the element of the module.
**  This is exhibited by the way they are stored.
*/

#ifndef __sys_types_h
#ifndef  _SYS_TYPES_H
typedef unsigned int   uint;
#endif
#endif
#ifndef USH_DEF
#define USH_DEF
typedef unsigned short usgshort;
#endif
typedef short  tgen;
typedef int    texp;

/*
#define ISBOUNDGG(g)((g->gen  == (tgen) 0 && g->exp == (texp) 0)     ? 0 : 1 )
#define ISBOUNDMG(m)((m->gen  == (tgen) 0 && m->exp == (RingWord) 0) ? 0 : 1 )
#define ISBOUNDRE(r)((r->mult == 0        && r->ring == NULL       ) ? 0 : 1 )
#define ISBOUNDEE(e)((e.group == NULL     && e.vector == (Vector) 0) ? 0 : 1 )
*/
#define ISBOUNDGG(g)(((g)->gen  == (tgen) 0 )     ? 0 : 1 )
#define ISBOUNDMG(m)(((m)->gen  == (tgen) 0 ) ? 0 : 1 )
#define ISBOUNDRE(r)(((r)->mult == 0 && (r)->ring == NULL ) ? 0 : 1 )
#define ISBOUNDEE(e)(((e).group == NULL     ) ? 0 : 1 )

#define ISONEGG(g)(((g)->gen  == 1 && g->exp == 0 ) ? 1 : 0 )
#define ISONEMG(g)(((g)->gen  == 1 && g->exp == 0 ) ? 1 : 0 )
#define ISONERE(r)(((r)->mult==1&&ISONEGG((r)->ring)&&!ISBOUNDRE((r)+1))?1:0)
#define ISONEEE(e)((ISONEGG((e)->group) && ISONEMG((e)->vector)) ? 1 : 0 )

#define PLENGTH(j)((P->Lseries[(j)][0]))
#define PDIM(j)((P->Lseries[P->Lfactor][(j)]))

#define MAX(i,j) (((i) <= (j)) ? (j) : (i))
#define MIN(i,j) (((i) <= (j)) ? (i) : (j))

/*
** The generators of the group are stored as a struct with two components.
** The first component is the number of the element and the second
** component is the exponent. 
*/
typedef struct _GroupGenerator {
             tgen              gen;
             texp              exp;
} GroupGenerator;

/*
** Other group elements are stored as words in the generators which
** is an array of GroupGenerator.
*/
typedef GroupGenerator *GroupWord;

typedef struct RingElement {
	     int        mult;
	     GroupWord  ring;
} * RingWord;


/*
** Module generators are also described by a structure. The structure 
** describing module generators has two components. The first one is
** the number of the generator. The second component is the 
** element of the group ring operating on the generator.
*/
typedef struct _ModuleGenerator {
        usgshort      gen;           /* generator number  */
	RingWord      exp;  /* the group elements acting */
} ModuleGenerator;


typedef ModuleGenerator *Vector;

/*
** Now we can define the elements of the extension.
*/
typedef struct _ExtensionElement {
             GroupWord        group;
	     Vector           vector;
} ExtensionElement;

/*
** And finally the presentation.
*/

typedef struct _Presentation {
             char             *name;
             uint             Nr_Generators;
             uint             Nr_Orig;
             uint             prime;
             uint             factor;
             uint            **Lseries;
             uint             Lfactor;
             uint             Nr_firstmgen;
      	     int              *exponents;
             ExtensionElement **relations;
	     uint             Nr_GroupGenerators;
             int             **definedby;
	     uint             trivial;
             ExtensionElement *Epimorphism;
             uint             *defepi;
	     uint             *Commute;
} Presentation;

Presentation *P;
extern Presentation * InitPresentation();

extern Vector    IdVec;
extern GroupWord IdGrp;

typedef int *ExpVec;
extern GroupWord STACK;

