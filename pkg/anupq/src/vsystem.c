/****************************************************************************
**
*A  vsystem.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: vsystem.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* when the standard C command "system" executes, it forks -- 
   thereby increasing significantly the size of the job; 

   this procedure is a Unix-specific version of the command 
   which does not fork; in most respects, it is similar to vfork; 

   the choice of system or vsystem is determined by the
   defined status of the identifiers SPARC or NeXT; 
  
   the SPARC procedure was written by Werner Nickel;
   it was later modified for NeXT machine by Frank Celler */

#if defined (SPARC)

#include <signal.h>
#include <sys/wait.h>

vsystem ( string )
char    *string;
{
   int     status, pid;
   void    (*f1)(), (*f2)();

   if( (pid = vfork()) == 0 ) {
      execl( "/bin/sh", "sh", "-c", string, (char*)0 );
      _exit( 0x7f );
   }
   else if( pid == -1 ) return -1;
   else {
      f1 = signal( SIGINT, SIG_IGN );
      f2 = signal( SIGQUIT, SIG_IGN );
      pid = waitpid( pid, &status, 0 );
      signal( SIGQUIT, f2 );
      signal( SIGINT, f1 );
      if( pid != -1 ) return status;
      else            return -1;
   }
}

#else
#if defined(NeXT)

#include <signal.h>
#include <sys/wait.h>

vsystem ( string )
    char          * string;
{
   union wait      status;
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
      pid = wait4( pid, &status, 0, 0 );
      signal( SIGQUIT, f2 );
      signal( SIGINT,  f1 );
      if( pid != -1 )
	 return status.w_status;
      else
	 return -1;
   }
}

#else
#if defined(__386BSD__)

#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>

vsystem ( string )
    char          * string;
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
      pid = wait4( pid, &status, 0, 0 );
      signal( SIGQUIT, f2 );
      signal( SIGINT,  f1 );
      if( pid != -1 )
	 return WEXITSTATUS(status);
      else
	 return -1;
   }
}

#endif
#endif
#endif
