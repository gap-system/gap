/* LibGAP - a shared library version of the GAP kernel
 * Copyright (C) 2013 Volker Braun <vbraun.name@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. 
 */


#include <src/sage_interface.h>
#include <src/sage_interface_internal.h>
#include <src/system.h>
#include <src/gap.h>
#include <src/gasman.h>
#include <src/scanner.h>
#include <src/read.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

/* Pointers to input/output buffers. libGAP users must not access these buffers directly!
 */

#define BUFFER_STEP 16*1024

static char* stdin_buffer = NULL;

static char* stdout_buffer = NULL;
static size_t stdout_bufsize = 0;
static size_t stdout_pos = 0;


/* stderr is captured in a static buffer to make it easier to pass it around in the error handler */

#define STDERR_BUFSIZE 4096

static char stderr_buffer[STDERR_BUFSIZE];
static size_t stderr_pos = 0;

int libgap_in_enter_exit_block = 0; /* false */

/*************************************************************************/
/*** Initialize / Finalize ***********************************************/
/*************************************************************************/

/*************************************************************************/
/*** Global Initialization ***********************************************/
/*************************************************************************/

void libgap_initialize(int argc, char** argv)
{
    /* Init interpreter state */
    InitMainGlobalState();
    libgap_mark_stack_bottom();
    InitializeGap(&argc, argv, environ);
    SetJumpToCatchFunc(libgap_call_error_handler);
}


void libgap_finalize()
{
  FinishBags();
}


/*************************************************************************/
/*** Garbage collector callback ******************************************/
/*************************************************************************/

static libgap_gasman_callback_ptr gasman_callback = NULL;

void libgap_set_gasman_callback(libgap_gasman_callback_ptr callback)
{
    SetExtraMarkFuncBags(callback);
}


/*************************************************************************/
/*** Input/Output interaction ********************************************/
/*************************************************************************/

void libgap_start_interaction(char* inputline)
{
  assert(stdin_buffer == NULL);
  stdin_buffer = inputline;
  
  stdout_bufsize = BUFFER_STEP;
  stdout_buffer = (char*)malloc(stdout_bufsize);
  stdout_pos = 0;
  
  stderr_pos = 0;
}

char* libgap_get_output() 
{
  libgap_append_stdout('\0');
  return stdout_buffer;
}

char* libgap_get_error() 
{
  libgap_append_stderr('\0');
  return strdup(stderr_buffer);
}

void libgap_finish_interaction()
{
  while (TLS(Symbol) != S_EOF)
    GetSymbol();
  stdin_buffer = NULL;

  stdout_bufsize = 0;
  stdout_pos = 0;
  free(stdout_buffer);
  stdout_buffer = NULL;
  
  stderr_pos = 0;
  ClearError();
}

void libgap_eval(char *cmd, char *result, size_t rlen, char *err, size_t elen)
{
  libgap_start_interaction(cmd);

  libgap_enter();
  ReadEvalCommand(TLS(BottomLVars), 0);
  ViewObjHandler(TLS(ReadEvalResult));
  strncpy(result, libgap_get_output(), rlen);
  strncpy(err, libgap_get_error(), elen);

  libgap_exit();
  libgap_finish_interaction();
}



/*************************************************************************/
/*** Let GAP access the buffers ******************************************/
/*************************************************************************/

static libgap_error_func_ptr error_func = NULL;

void libgap_set_error_handler(libgap_error_func_ptr callback)
{
  error_func = callback;
}


void libgap_call_error_handler()
{
  if (error_func == NULL) {
    printf("An error occurred, but libGAP has no handler set.\n");
    printf("Error message: %s\n", libgap_get_error());
    return;
  }
  libgap_append_stderr('\0');
  stderr_pos = 0;
  ClearError();
  (*error_func) (stderr_buffer);
}



/*************************************************************************/
/*** Let GAP access the buffers ******************************************/
/*************************************************************************/

char* libgap_get_input(char* line, int length)
{
  // TODO: copy in length chunks
  if (stdin_buffer == NULL) {
    return NULL;
  }
  assert(strlen(stdin_buffer) < length);
  strcpy(line, stdin_buffer);
  stdin_buffer = NULL;
  return line;
}

void libgap_append_stdout(char ch)
{
  if (stdout_buffer == NULL)
    return;
  if (stdout_pos == stdout_bufsize) {
    char* old_stdout_buffer = stdout_buffer;
    size_t old_stdout_bufsize = stdout_bufsize;
    stdout_bufsize += BUFFER_STEP;
    stdout_buffer = (char*)malloc(stdout_bufsize);
    memcpy(stdout_buffer, old_stdout_buffer, old_stdout_bufsize);
    free(old_stdout_buffer);
  }    
  stdout_buffer[stdout_pos++] = ch;
}


void libgap_append_stderr(char ch)
{
  stderr_buffer[stderr_pos++] = ch;
  if (stderr_pos == STDERR_BUFSIZE) 
    stderr_pos--;
}


void libgap_set_error(char* msg)
{
  stderr_pos = 0;
  int i;
  for (i=0; i<strlen(msg); i++)
    libgap_append_stderr(msg[i]);
}
