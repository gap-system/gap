/****************************************************************************
**
**    pres.h                          NQ                       Werner Nickel
**
**    Copyright 1992                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
*/

#include <stdio.h>

#ifndef USH_DEF
#define USH_DEF
typedef unsigned short usgshort;
#endif


/*
**    This type declaration allows at most 2^15-1 generators.
*/
#define GEN_DEFINED
typedef	short gen;

/*
**    The following data structure will represent a node in an expression
**    tree. The component type can indicate 3 basic objects : numbers,
**    generators and binary operators. There are currently 5 binary
**    operations.
*/
struct _node {
        int     type;
        union {
                int     n;                          /* stores numbers */
                gen     g;                          /* stores generators */
                struct { struct _node *l, *r; } op; /* stores bin ops */
        } cont;
};

typedef struct _node node;

/*
**    The following macros are used as first argument to the function
**    SetEvalFunction().
*/
#define TNUM   1
#define TGEN   2

#define TMULT  3
#define TPOW   4
#define TCONJ  5
#define TCOMM  6
#define TREL   7
#define TDRELL 8
#define TDRELR 9
#define TLAST  10

extern void	PrintGen();
extern void	PrintPresentation();
extern void	GetPresentation();
extern node	*Word();

extern char     *GenName();
extern int      NumberOfGens();
extern int      NumberOfRels();
extern node	*FirstRelation();
extern node	*NextRelation();
extern node     *CurrentRelation();
extern node	*NthRelation();

extern void	*Allocate();
extern void	*ReAllocate();
extern void	Free();

extern void	SetEvalFunc();
extern void	**EvalRelations();
extern void	*EvalNode();
extern void	FreeNode();
extern void	PrintNode();
