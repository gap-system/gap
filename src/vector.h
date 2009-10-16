/****************************************************************************
**
*W  vector.h                    GAP source                   Martin Schoenert
**
*H  @(#)$Id: vector.h,v 4.6 2002/04/15 10:04:03 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
const char * Revision_vector_h =
   "@(#)$Id: vector.h,v 4.6 2002/04/15 10:04:03 sal Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoVector()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoVector ( void );


/****************************************************************************
**

*E  vector.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
