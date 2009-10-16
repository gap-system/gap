/* public header for OMdevFile.c */
#ifndef __OMdevFile_h__
#define __OMdevFile_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* OMmakeIOFile
 *   Create a low level IO object from a FILE*.
 *   (May be used on stdin for instance.)
 * fd: FILE* to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOFile(FILE * f);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */





#endif /* __OMdevFile_h__ */
