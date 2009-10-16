/****************************************************************************
**
**    pcarith.h                       SQ                   Alice C. Niemeyer
**
**    Copyright 1992                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
**
**  This module contains the arithmetic functions for computing with
**  Extension Elements.
**
*/

extern RingWord          SubRingWord();
extern Vector           AddVector();
extern ExtensionElement *MappedEE();
extern ExtensionElement *MultiplyEELocal();
extern ExtensionElement *MultiplyEE();
extern ExtensionElement *MapHomGW();
extern ExtensionElement *InverseEE();
extern ExtensionElement *PowerEE();
extern ExtensionElement *PowerEELocal();
extern ExtensionElement *ConjugateEE();
extern ExtensionElement *CommutatorEE();
extern ExtensionElement *RelationEE();
extern void             InitCollectExtensionElement();
extern void             Commute();
