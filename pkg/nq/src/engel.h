/****************************************************************************
**
**    engel.h                         NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


extern int SemigroupOnly;
extern int SemigroupFirst;
extern int CheckFewInstances;
extern int ReverseOrder;

extern word EngelCommutator(word v, word w, int engel);

extern void EvalEngel(void);
extern void InitEngel(int l, int r, int v, int e, int n);
