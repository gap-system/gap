 /**********************************************************************
  * MPINU				                               *
  * Copyright (c) 2004-2005 Gene Cooperman <gene@ccs.neu.edu>          *
  *                                                                    *
  * This library is free software; you can redistribute it and/or      *
  * modify it under the terms of the GNU Lesser General Public         *
  * License as published by the Free Software Foundation; either       *
  * version 2.1 of the License, or (at your option) any later version. *
  *                                                                    *
  * This library is distributed in the hope that it will be useful,    *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of     *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU   *
  * Lesser General Public License for more details.                    *
  *                                                                    *
  * You should have received a copy of the GNU Lesser General Public   *
  * License along with this library (see file COPYING); if not, write  *
  * to the Free Software Foundation, Inc., 59 Temple Place, Suite      *
  * 330, Boston, MA 02111-1307 USA, or contact Gene Cooperman          *
  * <gene@ccs.neu.edu>.                                                *
  **********************************************************************/

#include "mpi.h"
#include "mpiimpl.h"

#define NUM_SLAVES_TO_CREATE_AT_ONCE 5

static char *global_ssh_cmd, *global_hostname;

static void alarm_handler(int sig) {
  fprintf(stderr, "*** MPINU:  Slave %s didn't reply to `%s'.\n",
          global_hostname, global_ssh_cmd);
  fflush(stderr);
  exit(1);
}

static void exec_system_with_interrupt( char *command ) {
  char *argv[4], probe_string[MPI_MAX_PROCESSOR_NAME+100];

  if ( 0 != strcmp("localhost", global_hostname) ) {
    signal( SIGALRM, alarm_handler );
    alarm(15);
    sprintf( probe_string, "exec %s %s pwd \">\" /dev/null",
	     global_ssh_cmd, global_hostname );
    assert( system( probe_string ) == 0 );
    alarm(0);
  }

  argv[0] = "sh";
  argv[1] = "-c";
  argv[2] = command;
  argv[3] = NULL;
  /* It works to call alarm() here, if desired. */
  execv("/bin/sh", argv);
  exit(127);
}

int MPINU_set_and_exec_cmds(hostname, port, argc, argv, outfile)
int argc;
char *hostname, *port, *argv[], *outfile;
{
  char cmd[256], args[256];
  char *ssh_cmd;
  int i, fd;
  pid_t pid;
  FILE *ssh_script;

  ssh_script = fopen(outfile, "w");
  fprintf(ssh_script, "#!/bin/sh\n");
  if ( (ssh_cmd = getenv("SSH")) == NULL ) ssh_cmd = "ssh";
  if ( getenv("CALLBACK_HOST") != NULL ) hostname = getenv("CALLBACK_HOST");

  args[0] = '\0';
  for (i=1; i < argc; i++) sprintf(args+strlen(args), "%s ", argv[i]);
  for(i=1; i < PG_ARRAY_SIZE && MPINU_pg_array[i].processor != NULL; i++)
  {
    /* If localhost, avoid overhead and portability issues of local loop */
    /* Strictly speaking, should be sprintf(cmd, "cd; exec ...");
       but then: localhost 1 - >slave.out   creates slave.out in home dir. */
    if ( 0 == strcmp("localhost", MPINU_pg_array[i].processor) )
      sprintf(cmd, "exec %s %s %s %s -p4amslave",
	      MPINU_pg_array[i].process, args, hostname, port);
    /* Assumes user shell on remote processor accepts "exec" */
    else sprintf(cmd, "exec %s %s exec %s %s %s %s -p4amslave", ssh_cmd,
		 MPINU_pg_array[i].processor, MPINU_pg_array[i].process,
		 args, hostname, port);
    fprintf(ssh_script, "%s &\n", cmd);
    if ( i % NUM_SLAVES_TO_CREATE_AT_ONCE == 0 )
      fprintf(ssh_script, "sleep(1)\n", cmd);
    fflush(ssh_script);
#ifdef DEBUG
    printf("cmd:  %s\n",cmd);
#endif
    CALL_CHK( pid = fork, () );
    if (pid == (pid_t)0) {  /* if child process */

      fclose(ssh_script);
      /* Could have used "ssh -n" to redirect stdin, but position of "-n"
         in "ssh" varies according to different dialects. */
#ifndef STDIN_FILENO
#define STDIN_FILENO 0 /* Should be standard in most dialects -- just in case */
#endif
      close(STDIN_FILENO);
      CALL_CHK( fd = open, ("/dev/null", O_RDONLY) );
      if ( fd != STDIN_FILENO ) { /* fd should be stdin, but check to be safe */
        CALL_CHK( dup2, (fd, STDIN_FILENO) );
        close( fd );
      }

      global_ssh_cmd = ssh_cmd; /* used by exec_system_with_interrupt() */
      global_hostname = MPINU_pg_array[i].processor;
      exec_system_with_interrupt(cmd);
      exit(127); /* child shouldn't reach here */
    }
    if ( i % NUM_SLAVES_TO_CREATE_AT_ONCE == 0 )
      sleep(1);
    cmd[0] = '\0';
  }
  fclose(ssh_script);
  if ( i >= PG_ARRAY_SIZE )
    printf("MPINU: WARNING: more slaves than PG_ARRAY_SIZE(%d); not using all\n",
           PG_ARRAY_SIZE);
  return i - 1; /* return number of slaves */
}
