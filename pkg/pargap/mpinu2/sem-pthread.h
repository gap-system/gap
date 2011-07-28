 /**********************************************************************
  * TOP-C (Task Oriented Parallel C)                                   *
  * Copyright (c) 2000 Gene Cooperman <gene@ccs.neu.edu>               *
  *                    and Victor Grinberg <victor@ccs.neu.edu>        *
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

/* Would like to declare:  static inline, but not all C compilers accept it */

typedef struct {
  volatile int val;
  pthread_mutex_t mutex;
  pthread_cond_t cond;
 } sem_t;

static
int sem_init( sem_t *sem, int ignore, unsigned int val ) {
  sem->val = val;
  pthread_mutex_init(&sem->mutex, NULL);
  pthread_cond_init(&sem->cond, NULL);
  return 0;
}

static
int sem_wait( sem_t *sem ) {
  pthread_mutex_lock( &sem->mutex );
  (sem->val)--;
  while (sem->val < 0)
    pthread_cond_wait(&sem->cond, &sem->mutex);
  pthread_mutex_unlock( &sem->mutex );
  return 0;
}

static
int sem_post( sem_t *sem ) {
  int do_signal = 0;
  pthread_mutex_lock( &sem->mutex );
  (sem->val)++;
  if (sem->val >= 0) do_signal = 1;
  pthread_mutex_unlock( &sem->mutex );
  if (do_signal) pthread_cond_signal(&sem->cond);
  return 0;
}
