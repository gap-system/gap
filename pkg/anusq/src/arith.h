/****************************************************************************
**
**    eapquot.h                       SQ                   Alice C. Niemeyer
**
**    Copyright 1993                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
**
**
**
*/

extern ExtensionElement * NumberExtensionElement();
extern uint LengthGroupWord();
extern uint LengthVector();
extern uint LengthRingWord();
extern GroupWord InverseGroupWord();
extern RingWord InverseRingWord();
extern Vector InverseVector();
extern GroupWord MultiplyGroupWordLocal();
extern ExtensionElement *MultiplyExtensionElementLocal();
extern ExtensionElement *MultiplyExtensionElement();
extern ExtensionElement *PowerExtensionElementLocal();
extern ExtensionElement *PowerExtensionElement();
extern ExtensionElement *ConjugateExtensionElement();
extern ExtensionElement *CommutatorExtensionElement();
extern int  LeftHandSide();
extern void RightHandSide();
extern ExtensionElement *RelationExtensionElement();
extern ExtensionElement	*DefiningRelationExtensionElement();
extern void	InitExtensionElement(); 
