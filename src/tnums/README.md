# TNum implementations

Files in this directory contain implementation of most of the
intrinsic GAP types.

* blister.{c,h}
  * `T_BLIST`
  * `T_BLIST_NSORT`
  * `T_BLIST_SSORT`

* bool.{c,h}
  * `T_BOOL`

* cyclotom.{c,h}
  * `T_CYC`

* ffdata.{c,h}, finfield.{c,h}
  * `T_FFE`

* gmpints.{c,h}, intobj.h
  * `T_INT`
  * `T_INTPOS`
  * `T_INTNEG`

* macfloat.{c,h}
  * `T_MACFLOAT`

* objset.{c,h}
  * `T_OBJSET`
  * `T_OBJMAP`

* permutat.{c,h}
  * `T_PERM2`
  * `T_PERM4`

* plist.{c,h}
  * `T_PLIST` and its many variants

* pperm.{c,h}
  * `T_PPERM2`
  * `T_PPERM4`

* precord.{c,h}
  * `T_PREC`

* range.{c,h}:
  * `T_RANGE_NSORT`
  * `T_RANGE_SSORT`

* rational.{c,h}
  * `T_RAT`

* stringobj.{c,h}
  * `T_CHAR`
  * `T_STRING`
  * `T_STRING_NSORT`
  * `T_STRING_SSORT`

* trans.{c,h}
  * `T_TRANS2`
  * `T_TRANS4`

* weakptr.{c.h}:
  * `T_WPOBJ`     weak pointer objects


## TNums implemented elsewhere

The implementation of several TNums are outside of this directory
for various reasons.

* parts of the interpreter:
  * `T_FUNCTION`  calls.c,  funcs.c
  * `T_BODY`      code.c
  * `T_FLAGS`     opers.c
  * `T_LVARS`     vars.c
  * `T_HVARS`     vars.c

* external types: objects.c
  * `T_COMOBJ`
  * `T_POSOBJ`
  * `T_DATOBJ`
    
* atomic objects: hpc/aobjects.c
  * `T_APOSOBJ`
  * `T_ACOMOBJ`

* shared TNUMs: hpc/threadapi.c
  * `T_THREAD`    
  * `T_MONITOR`
  * `T_REGION`
  * `T_SEMAPHORE`
  * `T_CHANNEL`
  * `T_BARRIER`
  * `T_SYNCVAR`

* atomic lists and records, thread local records: hpc/aobjects.c
  * `T_FIXALIST`      
  * `T_ALIST`
  * `T_AREC`
  * `T_AREC_INNER`
  * `T_TLREC`
  * `T_TLREC_INNER`
