/****************************************************************************
**
**    relations.h
*/

#ifndef RELATIONS_H
#define RELATIONS_H

#include "genexp.h"
#include "presentation.h" /* for struct node */

extern int EvalSingleRelation(node *r);
extern void EvalAllRelations(void);
extern void InitEpim(void);
extern int ExtendEpim(void);
extern int ElimAllEpim(int n, expvec *M, gen *renumber);
extern void ElimEpim(void);
extern void PrintEpim(void);
extern word Epimorphism(gen g);


#endif
