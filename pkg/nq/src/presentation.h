/****************************************************************************
**
**    presentation.h           Presentation                    Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#ifndef PRESENTATION_H
#define PRESENTATION_H

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "mem.h"
#include "genexp.h"
#include "pc.h"	/* for Class */

/*
**    The following are used as first argument to the function
**    SetEvalFunction().
*/
typedef enum {
	TNUM,
	TGEN,

	TMULT,
	TPOW,
	TCONJ,
	TCOMM,
	TREL,
	TDRELL,
	TDRELR,
	TENGEL,
	TLAST
} EvalType;

typedef word (*EvalFunc)(word a, void *b);

/*
**    The following data structure will represent a node in an expression
**    tree. The component type can indicate 3 basic objects : numbers,
**    generators and binary operators. There are currently 5 binary
**    operations.  There is now place to also hold a ternary operation: Engel
**    commutators.
*/
struct _node {
	EvalType type;
	union {
		int     n;                 /* stores numbers      */
		gen     g;                 /* stores generators   */
		struct {
			struct _node *l, *r;   /* stores bin ops      */
			struct _node *e;       /* and Engel relations */
		} op;
	} cont;
};

typedef struct _node node;


extern void     PrintGen(gen g);
extern void     PrintPresentation(FILE *fp);
extern void     Presentation(FILE *fp, const char *filename);
extern node     *ReadWord(void);

extern const char *GenName(gen g);
extern int      NumberOfAbstractGens(void);
extern int      NumberOfIdenticalGens(void);
extern int      NumberOfGens(void);
extern int      NumberOfRels(void);
extern node     *FirstRelation(void);
extern node     *NextRelation(void);
extern node     *CurrentRelation(void);
extern node     *NthRelation(int n);

extern void     SetEvalFunc(EvalType type, EvalFunc function);
extern void     **EvalRelations(void);
extern void     *EvalNode(node *n);
extern void     FreeNode(node *n);
extern void     PrintNode(node *n);
extern void     InitPrint(FILE *);

extern int      NrIdenticalGensNode;
extern gen      *IdenticalGenNumberNode;
extern int      NumberOfIdenticalGensNode(node *n);

#endif
