/****************************************************************************
**
*W  vector.h                    GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions  that mainly  operate  on vectors  whose
**  elements are integers, rationals, or elements from cyclotomic fields.  As
**  vectors are special lists many things are done in the list package.
**
**  A *vector* is a list that has no holes,  and whose elements all come from
**  a common field.  For the full definition of vectors see chapter "Vectors"
**  in  the {\GAP} manual.   Read also about "More   about Vectors" about the
**  vector flag and the compact representation of vectors over finite fields.
**
**  A list that  is known to   be a vector is  represented  by a bag of  type
**  'T_VECTOR',  which has exactely the  same  representation as bags of type
**  'T_PLIST'.  As a matter of fact the functions  in this file do not really
**  know  how this  representation  looks, they  use  the macros 'NEW_PLIST',
**  'GROW_PLIST',      'SHRINK_PLIST',      'SET_LEN_PLIST',     'LEN_PLIST',
**  'SET_ELM_PLIST', and 'ELM_PLIST' exported by the plain list package.
**
**  Note  that  a list  represented by  a bag of   type 'T_PLIST', 'T_SET' or
**  'T_RANGE' might still be a vector over the rationals  or cyclotomics.  It
**  is just that the kernel does not known this.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_vector_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupVector() . . . . . . . . . . . . . . . initialize the vector package
*/
extern void SetupVector ( void );


/****************************************************************************
**
*F  InitVector()  . . . . . . . . . . . . . . . initialize the vector package
**
**  'InitVector' initializes the vector package.
*/
extern void InitVector ( void );


/****************************************************************************
**
*F  CheckVector() . . . . . .  check the initialisation of the vector package
*/
extern void CheckVector ( void );


/****************************************************************************
**

*E  vector.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
