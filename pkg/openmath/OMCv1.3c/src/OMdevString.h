/* public header for OMdevString.c */
#ifndef __OMdevString_h__
#define __OMdevString_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* OMmakeIOString
 *   Create a low level IO object from a string (NUL terminator is not needed).
 *   (May be used for copy/paste for instance.)
 * s: pointer to string to use into the OpenMath IO object.
 *    - In case of input device the string must be NUL terminated.
 *    - In case of output device string may be reallocated
 *      to fit size of outcoming objects.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOString(char **s);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */





#endif /* __OMdevString_h__ */
