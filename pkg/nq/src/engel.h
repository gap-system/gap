/****************************************************************************
**
**    engel.h                         NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#define NONE 0
#define ENGEL 1
#define LEFT 2
#define RIGHT 3
#define LEFTRIGHT 4

extern int SemigroupOnly;
extern int SemigroupFirst;
extern int CheckFewInstances;
extern int ReverseOrder;

extern word EngelCommutator();

extern void EvalEngel();
extern void InitEngel();
