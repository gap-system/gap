


/* private counterpart for OMbase64.h */
#ifndef __OMbaseP_h__
#define __OMbaseP_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* reverse conversion. */
extern int OMIsB64Char(char c);

/*
 */
extern int OMto64(unsigned char *data, int len, char *buffer);

/*
 */
extern OMstatus OMfrom64(char *data, int len, unsigned char *buffer, int *bufLen);

/*
 */
extern void OMto16(char *data, int len, char *buffer);

/*
 */
extern OMstatus OMfrom16(char *data, int len, char *buffer);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#include "OMbase.h"


#endif /* __OMbaseP_h__ */


/*
 */
int OMto64(unsigned char *data, int len, char *buffer);

/*
 */
OMstatus OMfrom64(char *data, int len, unsigned char *buffer, int *bufLen);

/*
 */
void OMto16(char *data, int len, char *buffer);

/*
 */
OMstatus OMfrom16(char *data, int len, char *buffer);
