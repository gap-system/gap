#ifndef _GAP__GLOBAL_H
#define _GAP_GLOBAL_H

/* This file contains global #includes for faster compilation */

#include <pthread.h>
#ifndef WARD_ENABLED
/* This file contains some constructs Ward can't parse yet. */
#include <atomic_ops.h>
#endif

#endif /* _GAP_GLOBAL_H */
