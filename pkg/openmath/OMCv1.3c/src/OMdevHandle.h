/* public header for OMdevHandle.c */
#ifndef __OMdevHandle_h__
#define __OMdevHandle_h__

#ifdef WIN32
/* OMmakeIOHandle
 *   Create a low level IO object from a widows handle.
 * handle: windows handle to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOHandle(HANDLE handle);
extern void OMfreeIOHandle(OMIOStruct * io);
#endif

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */



/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#endif /* __OMdevHandle_h__ */
