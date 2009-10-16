/****************************************************************************
**
*W  macintr.c                  GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  routines which periodically interrupt GAP  to do cooperative multitasking
**  and checks for user interrupts
*/
#if !TARGET_API_MAC_CARBON
#include <timer.h>
#endif

#include        "system.h"              /* system dependent part           */

#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "bool.h"                /* booleans                        */

#include        "code.h"                /* coder                           */
#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */

#include        "intrprtr.h"            /* interpreter                     */

#include        "ariths.h"              /* basic arithmetic                */

#include        "stats.h"               /* statements                      */

#include "macdefs.h"
#include "macte.h"
#include "macedit.h"
#include "macdocs.h"
#include "maccon.h"
#include "macpaths.h"
#include "macintr.h"

/* the callback function for the timer does not have access to GAP's global
   variables, so we have to pass it the relevant addresses */
   
struct intrDataStruct {
	TMTask intrTask;
	UInt (** realExecStatFuncs) ( Stat stat );	
	UInt (** execStatFuncs) ( Stat stat );
	Boolean TimerAnswered;
	} intrData;

extern UInt (* RealExecStatFuncs[256]) ( Stat stat );

extern UInt RealExecStatCopied;

UInt (* RealExecStatFuncsCopies[256]) ( Stat stat );


UInt TestForIntrStat (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    /* change the entries in 'ExecStatFuncs' back to the original          */
    if ( RealExecStatCopied ) {
        for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
            if (RealExecStatFuncsCopies[i] != RealExecStatFuncs[i]) {
            	SyExit (2);
            }
            ExecStatFuncs[i] = RealExecStatFuncs[i];
        }
    }

    /* and now for something completely different                          */
    SET_BRK_CURR_STAT( stat );

    if ( SyStorOverrun == -1 ) {
       SyStorOverrun = 0; /* reset */
       ErrorReturnVoid(
        "exceeded the permitted memory (`-o' command line option)",
	    0L, 0L, "you can return to continue with twice the previous value" );
    } 
    else     if ( SyStorOverrun == -2 ) {
       SyStorOverrun = 0; /* reset */
       ErrorReturnVoid(
        "almost exceeded the available memory. Use the Finder to allocate more memory and restart GAP.)",
	    0L, 0L, "you can return to continue (proceed with care)" );
    } 
    else {
	    SyStopTime = SyTime();
        ProcessEvent ();
	    SyStartTime += SyTime() - SyStopTime;
	    if ( SyIsInterrupted ) {
		    SyIsInterrupted = 0;
			FlushLog ();   /* discard pending input */
	      	ErrorReturnVoid( "user interrupt", 0L, 0L, "you can return" );
    	  	syIsIntrTime = TickCount() + syIsIntrFreq;
    	}
	}
	
    /* install next interrupt                              */
	ReactivateIntr ();

    /* continue at the interrupted statement                               */
    return EXEC_STAT( stat );
}


#if TARGET_OS_MAC && TARGET_CPU_68K && !TARGET_RT_MAC_CFM
#pragma parameter AnswerTimerIntr(__A1)
#endif

pascal void AnswerTimerIntr ( TMTaskPtr task )
{
    UInt                i;              /* loop variable                   */
		
	((struct intrDataStruct*)task)->TimerAnswered = true;
	
    /* change the entries in the table 'ExecStatFuncs' to 'ExecIntrStat'   */
    for ( i = 0;
          i < T_SEQ_STAT;
          i++ ) {
        (((struct intrDataStruct*)task)->execStatFuncs)[i] = TestForIntrStat;
    }
    for ( i = T_RETURN_VOID;
          i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]);
          i++ ) {
        (((struct intrDataStruct*)task)->execStatFuncs)[i] = TestForIntrStat;
    }
}


void InterruptExecStat ( void )
{
    UInt                i;              /* loop variable                   */

    /* change the entries in the table 'ExecStatFuncs' to 'ExecIntrStat'   */
    for ( i = 0;
          i < T_SEQ_STAT;
          i++ ) {
        ExecStatFuncs[i] = TestForIntrStat;
    }
    for ( i = T_RETURN_VOID;
          i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]);
          i++ ) {
        ExecStatFuncs[i] = TestForIntrStat;
    }
}

void ReactivateIntr (void)
{
	if (intrData.TimerAnswered) {
		intrData.TimerAnswered = false;
		PrimeTime ((QElemPtr)&intrData.intrTask, 16*syIsIntrFreq);
	}
}

/* ActivateIntr is called from InitializeGAP when ExecStatFuncs has been set up */
void ActivateIntr (void)
{
    long i;
    
    for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
        RealExecStatFuncs[i] = ExecStatFuncs[i];
        RealExecStatFuncsCopies[i] = ExecStatFuncs[i];
    }
    RealExecStatCopied = 1;
 	
 	intrData.intrTask.tmAddr = NewTimerProc (AnswerTimerIntr);
 	intrData.intrTask.tmCount = 0;
 	intrData.realExecStatFuncs = RealExecStatFuncs;
 	intrData.execStatFuncs = ExecStatFuncs;

	InsTime ((QElemPtr)&intrData.intrTask);
	intrData.TimerAnswered = true;
	ReactivateIntr ();
}	
