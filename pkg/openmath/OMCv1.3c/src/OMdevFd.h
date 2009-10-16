/* public header for OMdevFd.c */
#ifndef __OMdevFd_h__
#define __OMdevFd_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* OMmakeIOFd
 *   Create a low level IO object from a file descriptor.
 *   (May be used on socket for instance.)
 * fd: file descriptor to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOFd(int fd);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */





#endif /* __OMdevFd_h__ */
