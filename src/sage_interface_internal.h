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


#ifndef LIBGAP_INTERNAL__H
#define LIBGAP_INTERNAL__H

/* Allow environment access to OSX dylib, see http://trac.sagemath.org/14038 */
#ifdef __APPLE__
#include <crt_externs.h>
#define environ (*_NSGetEnviron())
#else
extern char** environ;
#endif /* __APPLE__ */


/* libGAP functions that are used in the modified GAP kernel, not part
 * of the libGAP api */

/* GAP uses this function to call the gasman callback */
void libgap_call_gasman_callback();

/* For GAP to access the buffers */
char* libgap_get_input(char* line, int length);
char* libgap_get_error();
void libgap_append_stdout(char ch);
void libgap_append_stderr(char ch);
void libgap_set_error(char* msg);

#endif /* LIBGAP_INTERNAL__H */
