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

#define BUF_LEN 256

/* parse_buf must be as large as procgroup file length; avoids using malloc */
static char parse_buf[PROCGROUP_LEN];

int MPINU_parse( p4pg_file )
char *p4pg_file;
{
  FILE *fin;
  char *t0;
  char *c;
  char *buf = parse_buf;
  int index = 1;

#ifdef DEBUG
printf("parsing %s\n", p4pg_file);fflush(stdout);
#endif
  MPINU_pg_array[0].processor = "local";
  MPINU_pg_array[0].num_threads = "0";
  MPINU_pg_array[0].process = ""; /* Could use strcat of all argv[i] ?? */
  if ( (fin = fopen(p4pg_file, "r")) )
  { /* CHECK IF:  PROCGROUP_LEN > length of "procgroup" file */
    /* # in col 0 is comment*/
    while(fgets(buf, BUF_LEN, fin))
    { if ( buf[0] == '#' ) continue; /* # means comment */
      if ( buf[0] == '\n' ) continue; /* skip null lines */

      t0 = strtok(buf, " \t");
      if ( !strcmp(t0, "local") )
        continue;
      else
      {
	MPINU_pg_array[index].processor = t0;
	if ( (t0 = strtok(NULL, " \t")) == NULL ) {
	  printf("MPINU_parse: strtok: token not found\n");
	  exit(1);
	}
	MPINU_pg_array[index].num_threads = t0;
	if ( (t0 = strtok(NULL, "\n")) == NULL ) {
	  printf("MPINU_parse: strtok: token not found\n");
	  exit(1);
	}
	for ( c = MPINU_pg_array[index].num_threads;
	      *c != '\0'; c++ )
	  if ( ! isdigit(*c) ) {
	    printf("MPINU_parse: procgroup: num threads must be integer:");
	    printf(" (use 1, if not sure)\n");
	    exit(1);
	  }
	MPINU_pg_array[index].process = t0;
	buf = strchr(t0, '\0') + 1;
#if 0
        strcpy(MPINU_pg_array[index].processor, t0);
        t1 = strtok(NULL, " \t");
        if (t1) strcpy(MPINU_pg_array[index].num_threads, t1);
        t2 = strtok(NULL, "\n");
        if (t2) strcpy(MPINU_pg_array[index].process, t2);
#endif
#ifdef DEBUG
        printf("MPINU_pg_array[%d].process: %s\n",
	       index, MPINU_pg_array[index].process);
#endif
      }    
      index++;
    }
  }
#if 0
#ifdef __alpha
  /* ulimit(4,0) is file descriptors on Sun, DEC requires getrlimit */
#else
  if ( ulimit(4, 0) < index + 3 ) {
    CALL_CHK(ulimit, (4,0)); /* see if ulimit(4, 0) == -1 */
    printf("MPINU_parse:  Not enough file descriptors (%d) for all processes.\n",
	    ulimit(4,0) );
    exit(1);
  }
#endif
#endif
  fclose( fin );
  return 0;
}
