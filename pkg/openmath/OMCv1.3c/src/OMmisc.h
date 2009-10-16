
/* public header for OMmisc.c */
#ifndef __OMmisc_h__
#define __OMmisc_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* OMstatusToString
 *   Convert a status to a human readable string that explain its meaning
 * status: status to explain
 * return: corresponding string
 */
extern char *OMstatusToString(OMstatus status);

/* OMtokenTypeToString
 *   Convert a tokenType to a human readable string
 * ttype: type to convert
 * return: corresponding string
 */
extern char *OMtokenTypeToString(OMtokenType ttype);

/* OMsetVerbosityLevel
 *   When using API some infos may be loged.
 *   This set the required verbosity level.
 * level: level of verbosity.
 *        0 means nothing is nether printed
 *        1 everything is printed (default)
 *        2,... less verbose
 * return: last verbosity level
 */
extern int OMsetVerbosityLevel(int level);

/* OMsetVerbosityOutput
 *   When using API some infos may be loged.
 *   This set the destination for logs.
 * logFile: where to output logs (default is stderr)
 * return: last output
 */
extern FILE *OMsetVerbosityOutput(FILE * logFile);

/* OMlibDynamicInfo
 *   Gather some informations about lib that can't be statically determined.
 *   Complete them with some relevant static infornation too.
 * return: a newly allocated string
 */
extern char *OMlibDynamicInfo(void);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */





#endif /* __OMmisc_h__ */
