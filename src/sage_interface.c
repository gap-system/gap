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
#include <src/gapstate.h>
#include <src/gap.h>
#include <src/gasman.h>
#include <src/scanner.h>
#include <src/read.h>
#include <src/compiled.h>
#include <src/objset.h>
#include <src/funcs.h>
#include <src/calls.h>
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

// This is a list of GAP objects that the library user wants to retain
Obj libgap_GCPins;

void libgap_GC_pin(Obj obj);
void libgap_GC_unpin(Obj obj);

/*************************************************************************/
/*** Initialize / Finalize ***********************************************/
/*************************************************************************/

/*************************************************************************/
/*** Global Initialization ***********************************************/
/*************************************************************************/

void libgap_initialize(int argc, char** argv, char** environ)
{
    /* Init interpreter state */
    InitMainGAPState();
    libgap_mark_stack_bottom();
    InitializeGap(&argc, argv, environ);
    SetJumpToCatchFunc(libgap_call_error_handler);

    /*
     * Pinned objects
     */
    InitGlobalBag(&libgap_GCPins, "src/sage_interface.c:75");
    libgap_GCPins = NewObjSet();
}


void libgap_finalize()
{ FinishBags(); }


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
  while (STATE(Symbol) != S_EOF)
    GetSymbol();
  stdin_buffer = NULL;

  stdout_bufsize = 0;
  stdout_pos = 0;
  free(stdout_buffer);
  stdout_buffer = NULL;

  stderr_pos = 0;
  ClearError();
}

Obj libgap_eval_string(char *cmd, char *out, size_t outl, char *err, size_t errl)
{
  libgap_start_interaction(cmd);
  libgap_enter();
  ReadEvalCommand(STATE(BottomLVars), 0);
  // Note that this prevents
  // any result of eval string from
  // being garbage collected, unless
  // its unpinned
  libgap_GC_pin(STATE(ReadEvalResult));

  libgap_append_stdout('\0');
  strncpy(out, stdout_buffer, outl);
  libgap_append_stderr('\0');
  strncpy(err, stderr_buffer, errl);

  libgap_exit();
  libgap_finish_interaction();

  return STATE(ReadEvalResult);
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

/*
 * API
 *
 * These are the beginnings of an API for the GAP-as-a-library
 */
UInt8 libgap_TNumObj(Obj obj)      { return TNUM_OBJ(obj); }

/* We should really be able to extract/transfer BigInts as
   GMP integers */
Obj libgap_IntObj_Int(UInt8 val) { return INTOBJ_INT(val); }
UInt8 libgap_Int_IntObj(Obj obj)   { return INT_INTOBJ(obj); }

UInt8 libgap_Length_StringObj(Obj str) { return GET_LEN_STRING(str); };
/* Slightly dodgy, we could provide a function that copies the string
 * to a buffer */
char *libgap_String_StringObj(Obj str) { return CSTR_STRING(str); };
Obj libgap_StringObj_String(const char *str, size_t len)
{
    Obj res;
    C_NEW_STRING(res, len, str);
    return res;
}

/* Mhm. what should the API be here? */
Obj libgap_NewPermutation()
{  }

/* Records */
Obj libgap_NewPRec(UInt cap)
{ return NEW_PREC(cap); }

/* Lists */
Obj libgap_NewPList(UInt cap)
{
    Obj list;

    list = NEW_PLIST( T_PLIST, cap); 
    SET_LEN_PLIST(list, 0);

    return list;
}

UInt libgap_GrowPList(Obj list, UInt cap)
{ GROW_PLIST(list,  cap); }

void libgap_ShrinkPList(Obj list, UInt cap)
{ return SHRINK_PLIST(list, cap); }

void libgap_SetLenPList(Obj list, UInt len)
{ return SET_LEN_PLIST(list, len); }

void libgap_SetElmPList(Obj list, UInt pos, Obj val)
{ SET_ELM_PLIST(list,pos,val); }

Obj libgap_ElmPList(Obj list, UInt pos)
{ return ELM_PLIST(list, pos); }

Obj libgap_ValGVar(const char *name)
{
    UInt varnum = GVarName(name);
    return VAL_GVAR(varnum);
}

/* Executing Functions */
/* It's probably enough to have "CallFuncList" in the API, though
   we might want to circumvent the "overhead" of that in places? */
Obj DoExecFunc0args(Obj func);
Obj DoExecFunc1args(Obj func, Obj arg1);
Obj libgap_DoExecFunc0args(Obj func)
{ return DoExecFunc0args(func); }

Obj libgap_DoExecFunc1args(Obj func, Obj arg1)
{ return DoExecFunc1args(func, arg1); }

Obj DoOperation0Args(Obj func);
Obj DoOperation1Args(Obj func, Obj arg1);
Obj libgap_DoOperation0args(Obj func)
{ return DoOperation0Args(func); }

Obj libgap_DoOperation1args(Obj func, Obj arg1)
{ return DoOperation1Args(func, arg1); }

Obj libgap_CallFuncList(Obj func, Obj list)
{ return CallFuncList(func, list); }

void libgap_GC_pin(Obj obj)
{ AddObjSet(libgap_GCPins, obj); }

void libgap_GC_unpin(Obj obj)
{ RemoveObjSet(libgap_GCPins, obj); }

UInt libgap_CollectBags(UInt size, UInt full)
{ return CollectBags(size, full); }

Obj libgap_EvalString(char *cmd, char *out, size_t outl, char *err, size_t errl)
{
    libgap_start_interaction(cmd);
    libgap_enter();
    ReadEvalCommand(STATE(BottomLVars), 0);
    // Note that this prevents
    // any result of eval string from
    // being garbage collected, unless
    // its unpinned
    libgap_GC_pin(STATE(ReadEvalResult));

    libgap_append_stdout('\0');
    strncpy(out, stdout_buffer, outl);
    libgap_append_stderr('\0');
    strncpy(err, stderr_buffer, errl);

    libgap_exit();
    libgap_finish_interaction();

    return STATE(ReadEvalResult);
}


