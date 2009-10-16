/****************************************************************************
**
**    veinter.h                       SQ                   Alice C. Niemeyer
**
**    Copyright 1993                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
**
**
**  Headerfile for the vector enumerator interface.
**
*/

extern  void    PrintModuleHead      ( /* <FpVeIn> */ );
extern  void    PrintTrivial         ( /* <FpVeIn> */ );
extern  void    PrintModuleEnd       ( /* <FpVeIn> */ );
extern  int   * GetGroupWord         ( /* <FpVeOut> */ );
extern  void    CallModuleEnumerator ( /* <FileName> */ );
extern  void    ReadMat              ( /*  <mat>, <newdim>, <FpVeOut> */ );


