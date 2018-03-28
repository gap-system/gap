/****************************************************************************
**
*W  finfield.h                  GAP source                      Werner Nickel
**                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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

#include <src/ffdata.h>
#include <src/system.h>

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
#define SUCC_FF(ff)             ((const FFV*)(1+CONST_ADDR_OBJ( ELM_PLIST( SuccFF, ff ) )))

extern  Obj             SuccFF;


/****************************************************************************
**
*F  TYPE_FF(<ff>) . . . . . . . . . . . . . . .  type of a small finite field
**
**  'TYPE_FF' returns the type of elements of the small finite field <ff>.
**  'TYPE_FF0' returns the type of the zero of <ff>
**
**  Note that  'TYPE_FF' is a macro, so  do not call  it  with arguments that
**  have side effects.
*/
#define TYPE_FF(ff)             (ELM_PLIST( TypeFF, ff ))
#define TYPE_FF0(ff)             (ELM_PLIST( TypeFF0, ff ))

extern  Obj             TypeFF;
extern  Obj             TypeFF0;

extern  Obj             TYPE_FFE;
extern  Obj             TYPE_FFE0;


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
**  with more than than  65536 elements.  The macros  and have been coded  in
**  such a  way that they work  without problems.  The exception is 'POW_FFV'
**  which  will only work if  the product of integers  of type 'FFV' does not
**  cause an overflow.  And of course the successor table stored for a finite
**  field will become quite large for fields with more than 65536 elements.
*/
typedef UInt2           FFV;


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
**  Use  'SUM_FFV' only with arguments  that are variables or array elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and because it  is a complex macro  so most C  compilers will be upset by
**  complex arguments.  Especially do not use 'SUM_FFV(a,NEG_FFV(b,f),f)'.
**
**  If either operand is 0, the sum is just the other operand.
**  If $a <= b$ we have
**  $a + b ~ z^{a-1}+z^{b-1} = z^{a-1} * (z^{(b-1)-(a-1)}+1) ~ a * f[b-a+1]$,
**  otherwise we have
**  $a + b ~ z^{b-1}+z^{a-1} = z^{b-1} * (z^{(a-1)-(b-1)}+1) ~ b * f[a-b+1]$.
*/
#define SUM2_FFV(a,b,f) PROD_FFV( a, (f)[(b)-(a)+1], f )
#define SUM1_FFV(a,b,f) ( (a)<=(b) ? SUM2_FFV(a,b,f) : SUM2_FFV(b,a,f) )
#define SUM_FFV(a,b,f)  ( (a)==0 || (b)==0 ? (a)+(b) : SUM1_FFV(a,b,f) )


/****************************************************************************
**
*F  NEG_FFV(<a>,<f>)  . . . . . . . . . . . .  negative of finite field value
**
**  'NEG_FFV' returns  the negative of the   finite field value  <a> from the
**  finite field pointed to by the pointer <f>.
**
**  Use  'NEG_FFV' only with arguments  that are variables or array elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and because it is  a complex macro so most  C compilers will be upset  by
**  complex arguments.  Especially do not use 'NEG_FFV(PROD_FFV(a,b,f),f)'.
**
**  If the characteristic is 2, every element is its  own  additive  inverse.
**  Otherwise note that $z^{o-1} = 1 = -1^2$ so $z^{(o-1)/2} = 1^{1/2} = -1$.
**  If $a <= (o-1)/2$ we have
**  $-a ~ -1 * z^{a-1} = z^{(o-1)/2} * z^{a-1} = z^{a+(o-1)/2-1} ~ a+(o-1)/2$
**  otherwise we have
**  $-a ~ -1 * z^{a-1} = z^{a+(o-1)/2-1} = z^{a+(o-1)/2-1-(o-1)} ~ a-(o-1)/2$
*/
#define NEG2_FFV(a,f)   ( (a)<=*(f)/2 ? (a)+*(f)/2 : (a)-*(f)/2 )
#define NEG1_FFV(a,f)   ( *(f)%2==1 ? (a) : NEG2_FFV(a,f) )
#define NEG_FFV(a,f)    ( (a)==0 ? 0 : NEG1_FFV(a,f) )


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
**  Use 'PROD_FFV' only with arguments that are  variables or array elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and  because it is  a complex macro so most  C compilers will be upset by
**  complex arguments.  Especially do not use 'NEG_FFV(PROD_FFV(a,b,f),f)'.
**
**  If one of the values is 0 the product is 0.
**  If $a+b <= o$ we have $a * b ~ z^{a-1} * z^{b-1} = z^{(a+b-1)-1} ~ a+b-1$
**  otherwise   we   have $a * b ~ z^{(a+b-2)-(o-1)} = z^{(a+b-o)-1} ~ a+b-o$
*/
#define PROD1_FFV(a,b,f) ( (a)-1<=*(f)-(b) ? (a)-1+(b) : (a)-1-(*(f)-(b)) )
#define PROD_FFV(a,b,f) ( (a)==0 || (b)==0 ? 0 : PROD1_FFV(a,b,f) )


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
**  Use 'QUO_FFV' only with arguments  that are variables or array  elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and  because it is  a complex macro so most  C compilers will be upset by
**  complex arguments.  Especially do not use 'NEG_FFV(PROD_FFV(a,b,f),f)'.
**
**  A division by 0 is an error,  and dividing 0 by a nonzero value gives  0.
**  If $0 <= a-b$ we have  $a / b ~ z^{a-1} / z^{b-1} = z^{a-b+1-1} ~ a-b+1$,
**  otherwise   we   have  $a / b ~ z^{a-b+1-1}  =  z^{a-b+(o-1)}   ~ a-b+o$.
*/
#define QUO1_FFV(a,b,f) ( (b)<=(a) ? (a)-(b)+1 : *(f)-(b)+1+(a) )
#define QUO_FFV(a,b,f)  ( (a)==0 ? 0 : QUO1_FFV(a,b,f) )


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
**  Note  that 'POW_FFV' is a macro,  so do not call  it  with arguments that
**  have side effects.
**
**  If the finite field element is 0 the power is also 0, otherwise  we  have
**  $a^n ~ (z^{a-1})^n = z^{(a-1)*n} = z^{(a-1)*n % (o-1)} ~ (a-1)*n % (o-1)$
**
**  In the first macro one needs to be careful to convert a and n to UInt4.
**  Before performing the multiplication, ANSI-C will only convert to Int
**  since UInt2 fits into Int.
*/
#define POW1_FFV(a,n,f) ( (((UInt4)(a)-1) * (UInt4)(n)) % (UInt4)*(f) + 1 )
#define POW_FFV(a,n,f)  ( (n)==0 ? 1 : ( (a)==0 ? 0 : POW1_FFV(a,n,f) ) )


/****************************************************************************
**
*F  FLD_FFE(<ffe>)  . . . . . . . field of an element of a small finite field
**
**  'FLD_FFE' returns the small finite field over which the element  <ffe> is
**  represented.
**
**  Note that 'FLD_FFE' is a macro, so do not call  it  with  arguments  that
**  have side effects.
*/
#define FLD_FFE(ffe)            ((FF)((((UInt)(ffe)) & 0xFFFF) >> 3))


/****************************************************************************
**
*F  VAL_FFE(<ffe>)  . . . . . . . value of an element of a small finite field
**
**  'VAL_FFE' returns the value of the element <ffe> of a small finite field.
**  Thus,  if <ffe> is $0_F$, it returns 0;  if <ffe> is $1_F$, it returns 1;
**  and otherwise if <ffe> is $z^i$, it returns $i+1$.
**
**  Note that 'VAL_FFE' is a macro, so do not call  it  with  arguments  that
**  have side effects.
*/
#define VAL_FFE(ffe)            ((FFV)(((UInt)(ffe)) >> 16))


/****************************************************************************
**
*F  NEW_FFE(<fld>,<val>)  . . . .  make a new element of a small finite field
**
**  'NEW_FFE' returns a new element  <ffe>  of the  small finite  field <fld>
**  with the value <val>.
**
**  Note that 'NEW_FFE' is a macro, so do not  call  it  with  arguments that
**  have side effects.
*/
#define NEW_FFE(fld,val)        ((Obj)(((UInt)(val) << 16) + \
                                ((UInt)(fld) << 3) + (UInt)0x02))


/****************************************************************************
**
*F  FiniteField(<p>,<d>)  . . . make the small finite field with <q> elements
**
**  'FiniteField' returns the small finite field with <p>^<d> elements.
*/
extern  FF              FiniteField (
            UInt                p,
            UInt                d );


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
extern  FF              CommonFF (
            FF                  f1,
            UInt                d1,
            FF                  f2,
            UInt                d2 );


/****************************************************************************
**
*F  CharFFE(<ffe>)  . . . . . . . . .  characteristic of a small finite field
**
**  'CharFFE' returns the characteristic of the small finite field  in  which
**  the element <ffe> lies.
*/
extern  UInt            CharFFE (
            Obj                 ffe );


/****************************************************************************
**
*F  DegreeFFE(<ffe>)  . . . . . . . . . . . .  degree of a small finite field
**
**  'DegreeFFE' returns the degree of the smallest finite field in which  the
**  element <ffe> lies.
*/
extern  UInt            DegreeFFE (
            Obj                 ffe );


/****************************************************************************
**
*F  TypeFFE(<ffe>)  . . . . . . . . . . type of element of small finite field
**
**  'TypeFFE' returns the type of the element <ffe> of a small finite field.
**
**  'TypeFFE' is the function in 'TypeObjFuncs' for  elements in small finite
**  fields.
*/
extern  Obj             TypeFFE (
            Obj                 ffe );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoFinfield()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFinfield ( void );


#endif // GAP_FINFIELD_H
