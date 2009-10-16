#include "mpi.h"
#include "mpiimpl.h"

int MPINU_set_and_exec_cmds(hostname, port, argc, argv, outfile)
int argc;
char *hostname, *port, *argv[], *outfile;
{
  char cmd[256], args[256];
  char *rsh_cmd;
  int i, fd;
  pid_t pid;
  FILE *rsh_script;

  rsh_script = fopen(outfile, "w");
  fprintf(rsh_script, "#!/bin/sh\n");
  if ( (rsh_cmd = getenv("RSH")) == NULL ) rsh_cmd = "rsh";
  if ( getenv("CALLBACK_HOST") != NULL ) hostname = getenv("CALLBACK_HOST");

  args[0] = '\0';
  for (i=1; i < argc; i++) sprintf(args+strlen(args), "%s ", argv[i]);
  for(i=1; i < PG_ARRAY_SIZE && MPINU_pg_array[i].processor != NULL; i++)
  {
    /* If localhost, avoid overhead and portability issues of local loop */
    if ( 0 == strcmp("localhost",  MPINU_pg_array[i].processor) )
      sprintf(cmd, "cd; exec %s %s %s %s -p4amslave",
	      MPINU_pg_array[i].process, args, hostname, port);
    /* Assumes user shell on remote processor accepts "exec" */
    else sprintf(cmd, "exec %s %s exec %s %s %s %s -p4amslave", rsh_cmd,
		 MPINU_pg_array[i].processor, MPINU_pg_array[i].process,
		 args, hostname, port);
    fprintf(rsh_script, "(%s) &\n", cmd);
    fflush(rsh_script);
#ifdef DEBUG
    printf("cmd:  %s\n",cmd);
#endif
    CALL_CHK( pid = fork, () );
    if (pid == (pid_t)0) {  /* if child process */

      fclose(rsh_script);
      /* Could have used "rsh -n" to redirect stdin, but position of "-n"
         in "rsh" varies according to different dialects. */
#ifndef STDIN_FILENO
#define STDIN_FILENO 0 /* Should be standard in most dialects -- just in case */
#endif
      close(STDIN_FILENO);
      CALL_CHK( fd = open, ("/dev/null", O_RDONLY) );
      if ( fd != STDIN_FILENO ) { /* fd should be stdin, but check to be safe */
        CALL_CHK( dup2, (fd, STDIN_FILENO) );
        close( fd );
      }
      
#if 0
      /* Some problem for this on alpha, when stdin used (as in GCL) ?? */
      /* Also, system is preferred, because one can add
	">debug1.out" to procgroup file for slave output, for example. */
      execlp(rsh_cmd, MPINU_pg_array[i].processor, "exec",
	     MPINU_pg_array[i].process, hostname, port, "-p4amslave");
#else
      system(cmd);
#endif
      exit(0); /* child exits after slave finishes */
    }
    cmd[0] = '\0';
  }
  fclose(rsh_script);
  return i - 1; /* return number of slaves */
}
