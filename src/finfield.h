/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the  functions  to compute  with elements  from  small
**  finite fields.
**
**  Finite fields  are an  important   domain in computational   group theory
**  because the classical matrix groups are defined over those finite fields.
**  In GAP we  support  small  finite  fields  with  up  to  65536  elements,
**  larger fields can be realized  as polynomial domains over smaller fields.
**
**  Elements in small finite fields are  represented  as  immediate  objects.
**
**      +----------------+-------------+---+
**      |     <value>    |   <field>   |010|
**      +----------------+-------------+---+
**
**  The least significant 3 bits of such an immediate object are always  010,
**  flagging the object as an object of a small finite field.
**
**  The next 13 bits represent the small finite field where the element lies.
**  They are simply an index into a global table of small finite fields.
**
**  The most significant 16 bits represent the value of the element.
**
**  If the  value is 0,  then the element is the  zero from the finite field.
**  Otherwise the integer is the logarithm of this  element with respect to a
**  fixed generator of the multiplicative group of the finite field plus one.
**  In the following descriptions we denote this generator always with $z$, it
**  is an element of order $o-1$, where $o$ is the order of the finite field.
**  Thus 1 corresponds to $z^{1-1} = z^0 = 1$, i.e., the  one from the field.
**  Likewise 2 corresponds to $z^{2-1} = z^1 = z$, i.e., the root itself.
**
**  This representation  makes multiplication very easy,  we only have to add
**  the values and subtract 1 , because  $z^{a-1} * z^{b-1} = z^{(a+b-1)-1}$.
**  Addition is reduced to * by the formula $z^a +  z^b = z^b * (z^{a-b}+1)$.
**  This makes it necessary to know the successor $z^a + 1$ of every value.
**
**  The  finite field  bag contains  the  successor for  every nonzero value,
**  i.e., 'SUCC_FF(<ff>)[<a>]' is  the successor of  the element <a>, i.e, it
**  is the  logarithm  of $z^{a-1} +   1$.  This list  is  usually called the
**  Zech-Logarithm  table.  The zeroth  entry in the  finite field bag is the
**  order of the finite field minus one.
*/

#ifndef GAP_FINFIELD_H
#define GAP_FINFIELD_H

#include "common.h"
#include "ffdata.h"
#include "objects.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#endif


/****************************************************************************
**
*T  FF  . . . . . . . . . . . . . . . . . . . . . type of small finite fields
**
**  'FF' is the type used to represent small finite fields.
**
**  Small finite fields are represented by an  index  into  a  global  table.
**
**  Since there are  only  6542 (prime) + 93 (nonprime)  small finite fields,
**  the index fits into a 'UInt2' (actually into 13 bits).
*/
typedef UInt2       FF;


/****************************************************************************
**
*F  CHAR_FF(<ff>) . . . . . . . . . . .  characteristic of small finite field
**
**  'CHAR_FF' returns the characteristic of the small finite field <ff>.
**
**  Note that  'CHAR_FF' is a macro,  so do not call  it  with arguments that
**  have side effects.
*/
#define CHAR_FF(ff)             (CharFF[ff])


/****************************************************************************
**
*F  DEGR_FF(<ff>) . . . . . . . . . . . . . . .  degree of small finite field
**
**  'DEGR_FF' returns the degree of the small finite field <ff>.
**
**  Note that 'DEGR_FF' is  a macro, so do   not call it with  arguments that
**  have side effects.
*/
#define DEGR_FF(ff)             (DegrFF[ff])


/****************************************************************************
**
*F  SIZE_FF(<ff>) . . . . . . . . . . . . . . . .  size of small finite field
**
**  'SIZE_FF' returns the size of the small finite field <ff>.
**
**  Note that 'SIZE_FF' is a macro, so do not call  it  with  arguments  that
**  have side effects.
*/
#define SIZE_FF(ff)             (SizeFF[ff])


/****************************************************************************
**
*F  SUCC_FF(<ff>) . . . . . . . . . . . successor table of small finite field
**
**  'SUCC_FF' returns a pointer to the successor table of  the  small  finite
**  field <ff>.
**
**  Note that 'SUCC_FF' is a macro, so do not call  it  with  arguments  that
**  side effects.
*/
#ifdef HPCGAP
#define SUCC_FF(ff)             ((const FFV*)(1+CONST_ADDR_OBJ( ATOMIC_ELM_PLIST( SuccFF, ff ) )))
#else
#define SUCC_FF(ff)             ((const FFV*)(1+CONST_ADDR_OBJ( ELM_PLIST( SuccFF, ff ) )))
#endif

extern  Obj             SuccFF;


/****************************************************************************
**
*T  FFV . . . . . . . . type of the values of elements of small finite fields
**
**  'FFV'  is the  type used  to represent  the values  of elements  of small
**  finite fields.
**
**  Values of  elements  of  small  finite  fields  are  represented  by  the
**  logarithm of the element with respect to the root plus one.
**
**  Since small finite fields contain at most 65536 elements,  the value fits
**  into a 'UInt2'.
**
**  It may be possible to change this to 'UInt4' to allow small finite fields
**  with more than  65536 elements.  The macros  and have been coded  in
**  such a  way that they work  without problems.  The exception is 'POW_FFV'
**  which  will only work if  the product of integers  of type 'FFV' does not
**  cause an overflow.  And of course the successor table stored for a finite
**  field will become quite large for fields with more than 65536 elements.
*/
typedef UInt2           FFV;

GAP_STATIC_ASSERT(sizeof(UInt) >= 2 * sizeof(FFV),
                  "Overflow possibility in POW_FFV");

/****************************************************************************
**
*F  PROD_FFV(<a>,<b>,<f>) . . . . . . . . . . . product of finite field value
**
**  'PROD_FFV' returns the product of the two finite field values <a> and <b>
**  from the finite field pointed to by the pointer <f>.
**
**  Note that 'PROD_FFV' may only be used if the  operands are represented in
**  the  same finite field.  If you  want to multiply  two elements where one
**  lies in a subfield of the other use 'ProdFFEFFE'.
**
**  If one of the values is 0 the product is 0.
**  If $a+b <= o$ we have $a * b ~ z^{a-1} * z^{b-1} = z^{(a+b-1)-1} ~ a+b-1$
**  otherwise   we   have $a * b ~ z^{(a+b-2)-(o-1)} = z^{(a+b-o)-1} ~ a+b-o$
*/
EXPORT_INLINE FFV PROD_FFV(FFV a, FFV b, const FFV * f)
{
    GAP_ASSERT(a <= f[0]);
    GAP_ASSERT(b <= f[0]);
    if (a == 0 || b == 0)
        return 0;
    FFV q1 = f[0];
    FFV a1 = a - 1;
    FFV b1 = q1 - b;
    if (a1 <= b1)
        return a1 + b;
    else
        return a1 - b1;
}


/****************************************************************************
**
*F  SUM_FFV(<a>,<b>,<f>)  . . . . . . . . . . . .  sum of finite field values
**
**  'SUM_FFV' returns the sum of the two finite field values <a> and <b> from
**  the finite field pointed to by the pointer <f>.
**
**  Note that 'SUM_FFV' may only  be used if  the operands are represented in
**  the same finite field.  If you want to add two elements where one lies in
**  a subfield of the other use 'SumFFEFFE'.
**
**  If either operand is 0, the sum is just the other operand.
**  If $a <= b$ we have
**  $a + b ~ z^{a-1}+z^{b-1} = z^{a-1} * (z^{(b-1)-(a-1)}+1) ~ a * f[b-a+1]$,
**  otherwise we have
**  $a + b ~ z^{b-1}+z^{a-1} = z^{b-1} * (z^{(a-1)-(b-1)}+1) ~ b * f[a-b+1]$.
*/
EXPORT_INLINE FFV SUM_FFV(FFV a, FFV b, const FFV * f)
{
    GAP_ASSERT(a <= f[0]);
    GAP_ASSERT(b <= f[0]);
    if (a == 0)
        return b;
    if (b == 0)
        return a;
    if (b > a) {
        FFV t = a;
        a = b;
        b = t;
    }
    return PROD_FFV(b, f[a - b + 1], f);
}


/****************************************************************************
**
*F  NEG_FFV(<a>,<f>)  . . . . . . . . . . . .  negative of finite field value
**
**  'NEG_FFV' returns  the negative of the   finite field value  <a> from the
**  finite field pointed to by the pointer <f>.
**
**  If the characteristic is 2, every element is its  own  additive  inverse.
**  Otherwise note that $z^{o-1} = 1 = -1^2$ so $z^{(o-1)/2} = 1^{1/2} = -1$.
**  If $a <= (o-1)/2$ we have
**  $-a ~ -1 * z^{a-1} = z^{(o-1)/2} * z^{a-1} = z^{a+(o-1)/2-1} ~ a+(o-1)/2$
**  otherwise we have
**  $-a ~ -1 * z^{a-1} = z^{a+(o-1)/2-1} = z^{a+(o-1)/2-1-(o-1)} ~ a-(o-1)/2$
*/
EXPORT_INLINE FFV NEG_FFV(FFV a, const FFV * f)
{
    GAP_ASSERT(a <= f[0]);
    UInt q1 = f[0];
    if (a == 0)
        return 0;
    if (q1 % 2)
        return a;
    if (a <= q1 / 2)
        return a + q1 / 2;
    else
        return a - q1 / 2;
}


/****************************************************************************
**
*F  QUO_FFV(<a>,<b>,<f>)  . . . . . . . . . . quotient of finite field values
**
**  'QUO_FFV' returns the quotient of the two finite field values <a> and <b>
**  from the finite field pointed to by the pointer <f>.
**
**  Note that 'QUO_FFV' may  only be used  if the operands are represented in
**  the same finite field.  If you want to divide two elements where one lies
**  in a subfield of the other use 'QuoFFEFFE'.
**
**  A division by 0 is an error,  and dividing 0 by a nonzero value gives  0.
**  If $0 <= a-b$ we have  $a / b ~ z^{a-1} / z^{b-1} = z^{a-b+1-1} ~ a-b+1$,
**  otherwise   we   have  $a / b ~ z^{a-b+1-1}  =  z^{a-b+(o-1)}   ~ a-b+o$.
*/
EXPORT_INLINE FFV QUO_FFV(FFV a, FFV b, const FFV * f)
{
    GAP_ASSERT(a <= f[0]);
    GAP_ASSERT(b <= f[0]);
    if (a == 0)
        return 0;
    if (b <= a)
        return a - b + 1;
    else
        return a + (f[0] - b) + 1;
}


/****************************************************************************
**
*F  POW_FFV(<a>,<n>,<f>)  . . . . . . . . . . . power of a finite field value
**
**  'POW_FFV' returns the <n>th power of the finite  field value <a> from the
**  the finite field pointed to by the pointer <f>.
**
**  Note that 'POW_FFV' may only be used  if the right  operand is an integer
**  in the range $0..order(f)-1$.
**
**  Finally 'POW_FFV' may only be used if the  product of two integers of the
**  size of 'FFV'   does  not cause an  overflow,   i.e.  only if  'FFV'   is
**  'unsigned short'.
**
**  If the finite field element is 0 the power is also 0, otherwise  we  have
**  $a^n ~ (z^{a-1})^n = z^{(a-1)*n} = z^{(a-1)*n % (o-1)} ~ (a-1)*n % (o-1)$
*/
EXPORT_INLINE FFV POW_FFV(FFV a, UInt n, const FFV * f)
{
    GAP_ASSERT(a <= f[0]);
    GAP_ASSERT(n <= f[0]);
    if (!n)
        return 1;
    if (!a)
        return 0;

    // Use UInt to avoid overflow in the multiplication
    UInt a1 = a - 1;
    return ((a1 * n) % f[0]) + 1;
}


/****************************************************************************
**
*F  FLD_FFE(<ffe>)  . . . . . . . field of an element of a small finite field
**
**  'FLD_FFE' returns the small finite field over which the element  <ffe> is
**  represented.
**
*/
EXPORT_INLINE FF FLD_FFE(Obj ffe)
{
    GAP_ASSERT(IS_FFE(ffe));
    return (FF)((((UInt)(ffe)) & 0xFFFF) >> 3);
}


/****************************************************************************
**
*F  VAL_FFE(<ffe>)  . . . . . . . value of an element of a small finite field
**
**  'VAL_FFE' returns the value of the element <ffe> of a small finite field.
**  Thus,  if <ffe> is $0_F$, it returns 0;  if <ffe> is $1_F$, it returns 1;
**  and otherwise if <ffe> is $z^i$, it returns $i+1$.
**
*/
EXPORT_INLINE FFV VAL_FFE(Obj ffe)
{
    GAP_ASSERT(IS_FFE(ffe));
    return (FFV)(((UInt)(ffe)) >> 16);
}


/****************************************************************************
**
*F  NEW_FFE(<fld>,<val>)  . . . .  make a new element of a small finite field
**
**  'NEW_FFE' returns a new element  <ffe>  of the  small finite  field <fld>
**  with the value <val>.
**
*/
EXPORT_INLINE Obj NEW_FFE(FF fld, FFV val)
{
    GAP_ASSERT(val < SIZE_FF(fld));
    return (Obj)(((UInt)(val) << 16) + ((UInt)(fld) << 3) + (UInt)0x02);
}


/****************************************************************************
**
*F  FiniteField(<p>,<d>) .  make the small finite field with <p>^<d> elements
*F  FiniteFieldBySize(<q>) . .  make the small finite field with <q> elements
**
**  'FiniteField' returns the small finite field with <p>^<d> elements.
**  'FiniteFieldBySize' returns the small finite field with <q> elements.
*/
FF FiniteField(UInt p, UInt d);
FF FiniteFieldBySize(UInt q);


/****************************************************************************
**
*F  CommonFF(<f1>,<d1>,<f2>,<d2>) . . . . . . . . . . . . find a common field
**
**  'CommonFF' returns  a small finite field  that can represent  elements of
**  degree <d1> from the small finite field <f1> and  elements of degree <d2>
**  from the small finite field <f2>.  Note that this is not guaranteed to be
**  the smallest such field.  If  <f1> and <f2> have different characteristic
**  or the smallest common field, is too large, 'CommonFF' returns 0.
*/
FF CommonFF(FF f1, UInt d1, FF f2, UInt d2);


/****************************************************************************
**
*F  CharFFE(<ffe>)  . . . . . . . . .  characteristic of a small finite field
**
**  'CharFFE' returns the characteristic of the small finite field  in  which
**  the element <ffe> lies.
*/
UInt CharFFE(Obj ffe);


/****************************************************************************
**
*F  DegreeFFE(<ffe>)  . . . . . . . . . . . .  degree of a small finite field
**
**  'DegreeFFE' returns the degree of the smallest finite field in which  the
**  element <ffe> lies.
*/
UInt DegreeFFE(Obj ffe);


/****************************************************************************
**
*F  TypeFFE(<ffe>)  . . . . . . . . . . type of element of small finite field
**
**  'TypeFFE' returns the type of the element <ffe> of a small finite field.
**
**  'TypeFFE' is the function in 'TypeObjFuncs' for  elements in small finite
**  fields.
*/
Obj TypeFFE(Obj ffe);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoFinfield()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFinfield ( void );


#endif // GAP_FINFIELD_H
