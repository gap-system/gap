/****************************************************************************
**
**    collect.h                       PC                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

extern  int     UseCombiCollector;
extern  int     UseSimpleCollector;

extern  int     SimpleCollect(expvec lhs, word rhs, expo e);
extern  int     CombiCollect(expvec lhs, word rhs, expo e);
extern  int     Collect(expvec lhs, word rhs, expo e);

extern  word    Solve(word u, word v);
extern  word    Invert(word u);
extern  word    Multiply(word u, word v);
extern  word    Exponentiate(word u, int n);
extern  word    Commutator(word u, word v);
