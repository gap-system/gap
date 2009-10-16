/* private counterpart for OMmisc.h */
#ifndef __OMmiscP_h__
#define __OMmiscP_h__

#define OMdoubleLE2BE(_D) OMdoubleLEBESwitch(_D)
#define OMdoubleBE2LE(_D) OMdoubleLEBESwitch(_D)


/* Definitions for byte order, according to significance of bytes, from low
 * addresses to high addresses.  The value is what you get by putting '4'
 * in the most significant byte, '3' in the second most significant byte,
 * '2' in the second least significant byte, and '1' in the least
 * significant byte.  
 * #define __LITTLE_ENDIAN 1234
 * #define __BIG_ENDIAN    4321
 * #define __PDP_ENDIAN    3412
 */

/* some OM functions need to know if architecure is little or big endian
 * we intentionaly forgot PDP weird byte ordering
 */
extern int OMlittleEndianMode;


/* The IEEE double precision floating point standard representation requires a 64 bit word, which may be represented
 * as numbered from 0 to 63, left to right. The first bit is the sign bit, S, the next eleven bits are the exponent bits, 'E',
 * and the final 52 bits are the fraction 'F':
 * 
 * S EEEEEEEEEEE FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
 * 0 1        11 12                                                63
 * The value V represented by the word may be determined as follows:
 * 
 * If E=2047 and F is nonzero, then V=NaN ("Not a number") 
 * If E=2047 and F is zero and S is 1, then V=-Infinity 
 * If E=2047 and F is zero and S is 0, then V=Infinity 
 * If 0&ltE&lt2047 then V=(-1)**S * 2 ** (E-1023) * (1.F) where "1.F" is intended to represent the binary
 * number created by prefixing F with an implicit leading 1 and a binary point. 
 * If E=0 and F is nonzero, then V=(-1)**S * 2 ** (-1022) * (0.F) These are "unnormalized" values. 
 * If E=0 and F is zero and S is 1, then V=-0 
 * If E=0 and F is zero and S is 0, then V=0 
 * 
 * Reference:
 * 
 * ANSIIEEE Standard 754-1985,
 * Standard for Binary Floating Point Arithmetic
 */

/* This is the IEEE 754 double-precision format in Big Endian */
typedef union OMieee754DoubleBigEndian {
  double d;
  struct {
    unsigned int negative:1;
    unsigned int exponent:11;
    unsigned int mantissa0:20;
    unsigned int mantissa1:32;
  } ieee;
} OMieee754DoubleBigEndian;

/* This is the IEEE 754 double-precision format in Little Endian */
typedef union OMieee754DoubleLittleEndian {
  double d;
  struct {
    unsigned int mantissa1:32;
    unsigned int mantissa0:20;
    unsigned int exponent:11;
    unsigned int negative:1;
  } ieee;
} OMieee754DoubleLittleEndian;


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* dbgStopHere
 *   Convenience func. To stop under debugger put a break on it
 */
extern int dbgStopHere(void);

/*
 */
extern void OMreturnToDebugger(int val);

/* OMfatal
 *   Print a message to OMerrorLog
 *   (see OMsetVerbosityLevel and OMsetVerbosityOutput
 *   then call OMfatalFunc (if not NULL) with status
 *   (if compiled in OM_DEBUG mode, try to return to debuger).
 *   and finaly exit 
 * status: used as exit status
 * format,...: arguments passed to printf for OMerrorLog output
 * return: void
 */
extern void OMfatalInternal(OMstatus status, char *format,...);

/* OMprintf
 *   Print a message on current verbose file (OMverboseLog)
 *   depending on current verbosity level (OMverbosity)
 * status: >0 print if status >= current verbosity level
 *          0 always print
 * format,...: arguments passed to printf if print enabled
 * return: void
 */
extern void OMprintf(int level, char *format,...);

/* OMmalloc
 *   Like std malloc but checks for allocation errors
 * size: size of chunck to allocate (in bytes)
 * return: pointer to allocated chunk
 */
extern void *OMmallocInternal(int size);

extern void *OMmallocWarn(int size, char *format,...);

/* OMrealloc
 *   Like std realloc but checks for allocation error
 * old: pointer to old memory chunck (or NULL for a simple alloc)
 * size: size of (new) chunck to reallocate (in bytes)
 * return: pointer to reallocated chunk
 */
extern void *OMreallocInternal(void *old, int size);

/* OMreallocWarn
 *   Like std realloc but checks for allocation error
 * old: pointer to old memory chunck (or NULL for a simple alloc)
 * size: size of (new) chunck to reallocate (in bytes)
 * format,...: arguments passed to printf if print enabled
 *
 * return: pointer to reallocated chunk
 */
extern void *OMreallocWarn(void *old, int size, char *format,...);

/* OMfree
 *   Like std free but checks for NULL pointers
 * p: pointer to free
 * return: void
 */
extern void OMfreeInternal(void *p);

/* OMdup
 *   Duplicates a memory chunck.
 * p: pointer to memory chunck.
 * len: size of memory chunck.
 * return: the newly allocated copy of p.
 */
extern void *OMdup(void *p, int len);

extern void OMinitFd(void);

extern void OMinitMathCst(void);

extern int OMlittleEndianess(void);

extern double OMdoubleLEBESwitch(double toConvert);

/*
 * Convert memory chunck into a string reflecting its bit pattern
 */
extern char *OMbitString(char *p, int l);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */

#include "OMmisc.h"

#ifndef __GNUC__
#ifndef __FUNCTION__
#define __FUNCTION__ "-unknown-"
#endif
#endif

#ifndef __STRING
#ifdef __STDC__
#define __STRING(S) #S
#else
#define __STRING(S) "S"
#endif
#endif


#if OM_DEBUG
#define OMassert(Test) if(!(Test)) {OMfatalInternal(OMfailed,"%s:%d %s() assertion failed. (%s)\n",__FILE__,__LINE__,__FUNCTION__,__STRING(Test)); OMreturnToDebugger(1);};
#else /* OM_DEBUG */
#define OMassert(Test)
#endif /* OM_DEBUG */


/* use this one to put in empty func bodies... this may avoid some nasty bugs ;)
 */
#define OMNYI {OMfatalInternal(OMnotImplemented,"%s:%d %s() Not yet implemented. \n",__FILE__,__LINE__,__FUNCTION__); OMreturnToDebugger(1);};

#define OMIE {OMfatalInternal(OMfailed,"%s:%d %s() Internal error?\n",__FILE__,__LINE__,__FUNCTION__); OMreturnToDebugger(1);};


#ifndef Min
#define Min(A,B) (((A)>(B))?(B):(A))
#endif
#ifndef Max
#define Max(A,B) (((A)<(B))?(B):(A))
#endif
#ifndef Abs
#define Abs(A)   (((A)>=0)?(A):-(A))
#endif
#ifndef Bound
#define Bound(MIN,MAX,V) (Max((MIN),Min((MAX),(V))))
#endif

/* uh it seems to be a swap. isn't it? ;) 
 * eg: OMswap(a,b,int) or OMswap(v1,v2,vectorType) */
#define OMswap(A,B,Type)         {Type _tmp; _tmp=(A);(A)=(B);(B)=_tmp;}

/* more compact notation 
 * eg: pv=OMnew(vector*) is equal to pv=(vector*)malloc(sizeof(vector*)) */
#define OMnew(Type) ((Type*) OMmallocInternal(sizeof(Type)))


#define OMcheckStatus(FctCall) \
{\
   OMstatus _status;\
   if((_status = (FctCall))){\
     return _status;\
   }\
}


/* warnings are emitted at this verbosity level */
#define OMwarnLevel 1

#define EQSTRING(S1, S2) (strcmp((S1), (S2)) == 0)
#define ZERO(x) memset((char *) &x, 0, sizeof (x))


#endif /* __OMmiscP_h__ */
