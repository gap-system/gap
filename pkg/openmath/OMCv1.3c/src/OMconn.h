/* public header for OMconn.c */
#ifndef __OMconn_h__
#define __OMconn_h__

#include "OM.h"

typedef struct OMconnStruct *OMconn;


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/*
 */
extern OMconn OMmakeConn(int timeout);

extern OMdev OMconnIn(OMconn conn);

extern OMdev OMconnOut(OMconn conn);

extern OMstatus OMconnClose(OMconn conn);

extern OMstatus OMbindUnix(OMconn conn, char *file);

extern OMstatus OMconnUnix(OMconn conn, char *socketpath);

extern OMstatus OMconnTCP(OMconn conn, char *machine, int port);

extern OMstatus OMbindTCP(OMconn conn, int port);

extern OMstatus OMlaunchEnv(OMconn conn, char *machine, char *cmd, char *env);

extern OMstatus OMlaunch(OMconn conn, char *machine, char *cmd);

extern OMstatus OMserveClient(OMconn conn);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */

#endif /* __OMconn_h__ */


/*
 */
OMconn OMmakeConn(int timeout);

OMdev OMconnIn(OMconn conn);

OMdev OMconnOut(OMconn conn);

OMstatus OMconnClose(OMconn conn);

OMstatus OMbindUnix(OMconn conn, char *file);

OMstatus OMconnUnix(OMconn conn, char *socketpath);

OMstatus OMconnTCP(OMconn conn, char *machine, int port);

OMstatus OMbindTCP(OMconn conn, int port);

OMstatus OMlaunchEnv(OMconn conn, char *machine, char *cmd, char *env);

OMstatus OMlaunch(OMconn conn, char *machine, char *cmd);

OMstatus OMserveClient(OMconn conn);
