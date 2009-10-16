/****************************************************************************
**
*W  mp_float.h                    GAP source                Laurent Bartholdi
**
*H  @(#)$Id: mp_float.h,v 1.1 2008/06/14 15:45:40 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file declares the functions for the floating point package
*/
#ifdef BANNER_MP_FLOAT_H
static const char *Revision_mp_float_h =
   "@(#)$Id: mp_float.h,v 1.1 2008/06/14 15:45:40 gap Exp $";
#endif

#define mpz_MPZ(obj) ((__mpz_struct *) ADDR_OBJ(obj))
Obj MPZ_LONGINT (Obj obj);
Obj INT_mpz(mpz_ptr z);

#define TEST_IS_INTOBJ(mp_name,obj)					\
  while (!IS_INTOBJ(obj))						\
    obj = ErrorReturnObj(mp_name ": expected a small integer, not a %s", \
			 (Int)(InfoBags[TNUM_OBJ(obj)].name),0,		\
			 "You can return an integer to continue");

/****************************************************************
 * mpfr
 ****************************************************************/
#ifdef WITH_MPFR
#include <mpfr.h>

/****************************************************************
 * mpfr's are stored as follows:
 * +-----------+----------------------------------+-------------+
 * | TYPE_MPFR |           __mpfr_struct          | mp_limb_t[] |
 * |           | precision exponent sign mantissa |             |
 * +-----------+----------------------------------+-------------+
 *                                          \_______^
 ****************************************************************/
#define MPFR_OBJ(obj) ((mpfr_ptr) (ADDR_OBJ(obj)+1))
inline Obj NEW_MPFR (mp_prec_t prec);
inline mpfr_ptr GET_MPFR(Obj obj);

int PRINT_MPFR(char *s, mp_exp_t *exp, int digits, mpfr_ptr f, mpfr_rnd_t rnd);

int InitMPFRKernel (void);
int InitMPFRLibrary (void);
#endif

/****************************************************************
 * mpfi
 ****************************************************************/
#ifdef WITH_MPFI
#include <mpfi.h>

/****************************************************************
 * mpfi's are stored as follows:
 * +-----------+-----------------------------------------+---------------------+
 * | TYPE_MPFI |             __mpfi_struct               |    __mp_limb_t[]    |
 * |           | __mpfr_struct left         right        | limbl ... limbr ... |
 * |           | prec exp sign mant   prec exp sign mant |                     |
 * +-----------+-----------------------------------------+---------------------+
 *                               \____________________\____^         ^
 *                                                     \____________/
 * it is assumed that the left and right mpfr's are allocated with the
 * same precision
 ****************************************************************/
#define MPFI_OBJ(obj) ((mpfi_ptr) (ADDR_OBJ(obj)+1))

int InitMPFIKernel (void);
int InitMPFILibrary (void);
#endif

/****************************************************************
 * mpc
 ****************************************************************/
#ifdef WITH_MPC
#include <mpc.h>

int InitMPCKernel (void);
int InitMPCLibrary (void);
#endif

/****************************************************************
 * mpd
 ****************************************************************/
#ifdef WITH_MPD
int InitMPDKernel (void);
int InitMPDLibrary (void);
#endif

/****************************************************************************
**
*E  mp_float.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
