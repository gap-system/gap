/****************************************************************************
**
*A  vsystem.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: vsystem.c,v 1.8 2011/12/02 16:28:40 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* when the standard C command "system" executes, it forks -- 
   thereby increasing significantly the size of the job; 

   this procedure is a Unix-specific version of the command 
   which does not fork; in most respects, it is similar to vfork; 

   the code was originally written by Werner Nickel for SPARC;
   it was later modified for NeXT machine by Frank Celler */

#include "config.h"

#ifdef HAVE_WORKING_VFORK

#include <unistd.h>
#include <signal.h>
#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

int vsystem(char *string)
{
   int             status;
   int             pid;
   void            (*f1)();
   void            (*f2)();

   if( (pid = vfork()) == 0 )
   {
      execl( "/bin/sh", "sh", "-c", string, (char*) 0 );
      _exit( 0x7f );
   }
   else if ( pid == -1 )
      return -1;
   else
   {
      f1 = signal( SIGINT,  SIG_IGN );
      f2 = signal( SIGQUIT, SIG_IGN );
#ifdef HAVE_WAITPID
      pid = waitpid( pid, &status, 0 );
#elif defined(HAVE_WAIT4)
      pid = wait4( pid, &status, 0, 0 );
#else
#     error At least one of waitpid or wait4 must be available
#endif
      signal( SIGQUIT, f2 );
      signal( SIGINT, f1 );
      if( pid != -1 )
         return WEXITSTATUS(status);
      else
         return -1;
   }
}

#endif
