#include        "system.h"              /* system dependent part           */

const char * Revision_vecgf2_c =
   "@(#)$Id$";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */
#include        "finfield.h"            /* finite fields and ff elements   */

#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "range.h"               /* ranges                          */
#include        "blister.h"             /* boolean lists                   */
#include        "string.h"              /* strings                         */

#define INCLUDE_DECLARATION_PART
#include        "vecgf2.h"              /* GF2 vectors                     */
#undef  INCLUDE_DECLARATION_PART

#include        "saveload.h"            /* saving and loading              */
#include        "integer.h"             /* (long) integers                 */
#include        "vec8bit.h"             /* vectors over bigger small fields*/
#include        <assert.h>

/****************************************************************************
**
*F * * * * * * * * * * * imported library variables * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of a GF2 vector object
*/
Obj TYPE_LIST_GF2VEC;


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_LOCKED. . . .  type of a mutable GF2 vector object
**                                          with locked representation
*/
Obj TYPE_LIST_GF2VEC_LOCKED;


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_IMM  . . . . . .  type of an immutable GF2 vector object
*/
Obj TYPE_LIST_GF2VEC_IMM;

/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_IMM_LOCKED. . . .  type of an immutable GF2 vector object
**                                          with locked representation
*/
Obj TYPE_LIST_GF2VEC_IMM_LOCKED;


/****************************************************************************
**
*V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . . . type of a GF2 matrix object
*/
Obj TYPE_LIST_GF2MAT;


/****************************************************************************
**
*V  TYPE_LIST_GF2MAT_IMM  . . . . . .  type of an immutable GF2 matrix object
*/
Obj TYPE_LIST_GF2MAT_IMM;


/****************************************************************************
**
*V  IsGF2VectorRep  . . . . . . . . . . . . . . . . . . . . . . . . .  filter
*/
Obj IsGF2VectorRep;


/****************************************************************************
**
*V  GF2One  . . . . . . . . . . . . . . . . . . . . . . . . . . .  one of GF2
*/
Obj GF2One;


/****************************************************************************
**
*V  GF2Zero . . . . . . . . . . . . . . . . . . . . . . . . . . . zero of GF2
*/
Obj GF2Zero;


/****************************************************************************
**
*F * * * * * * * * * * * * arithmetic operations  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  AddCoeffsGF2VecGF2Vec( <sum>, <vec> ) . . . . . . . .  add <vec> to <sum>
**
**  `AddCoeffsGF2VecGF2Vec' adds  the   entries of <vec>  to <sum>.    If the
**  length  are not equal the  missing entries are  assumed  to be zero.  The
**  position of the rightmost Z(2) is returned.
*/

UInt RightMostOneGF2Vec (
    Obj                 vec )
{
    UInt                len;

    len = LEN_GF2VEC(vec);
    while ( 0 < len ) {
        if ( BLOCK_ELM_GF2VEC(vec,len) == 0 )
	    len = BIPEB*((len-1)/BIPEB);
        else if ( BLOCK_ELM_GF2VEC(vec,len) & MASK_POS_GF2VEC(len) )
            break;
	else
	  len--;
    }
    return len;
}


Obj AddCoeffsGF2VecGF2Vec (
    Obj                 sum,
    Obj                 vec )
{
    UInt *              ptS;
    UInt *              ptV;
    UInt *              end;
    UInt                len;

    /* get the length                                                      */
    len = LEN_GF2VEC(vec);

    /* grow <sum> is necessary                                             */
    if ( LEN_GF2VEC(sum) < len ) {
        ResizeBag( sum, SIZE_PLEN_GF2VEC(len) );
        SET_LEN_GF2VEC( sum, len );
    }

    /* add <vec> to <sum>                                                  */
    ptS = BLOCKS_GF2VEC(sum);
    ptV = BLOCKS_GF2VEC(vec);
    end = ptS + ((len+BIPEB-1)/BIPEB);
    while ( ptS < end ) {
        *ptS++ ^= *ptV++;
    }
    return INTOBJ_INT(RightMostOneGF2Vec(sum));
}


/****************************************************************************
**
*F  AddPartialGF2VecGF2Vec( <sum>, <vl>, <vr>, <n> )  . . . . . . partial sum
**
**  'AddPartialGF2VecGF2Vec' adds the entries  of <vl> and <vr> starting from
**  that block which is corresponding to the entry with number <n> and stores
**  the result in <sum>.
**
**  Note: The other entries are set to be zero. So use a higher value for <n>
**        only for vectors, which both have leading zero-entries. 
**
**  You  can use  the parameter  <n> for  example for  an  gauss-algorithm on 
**  gf2-matrices  can be  improved,  because when  using the gauss-algorithm,
**  you  know that  the leading entries of two vectors to be  added are equal
**  zero. If <n> = 1 all entries are added. 
**
**  Note that the caller has to ensure, that <sum> is a gf2-vector with the 
**  correct size.
*/
Obj AddPartialGF2VecGF2Vec (
    Obj                 sum,
    Obj                 vl,
    Obj                 vr,
    UInt                n )
{
    UInt *              ptL;            /* bit field of <vl>               */
    UInt *              ptR;            /* bit field of <vr>               */
    UInt *              ptS;            /* bit field of <sum>              */
    UInt *              end;            /* end marker                      */
    UInt                len;            /* length of the list              */
    UInt                offset;         /* number of block to start adding */
    UInt                x;
    

    /* both operands lie in the same field                                 */
    len = LEN_GF2VEC(vl);
    if ( len != LEN_GF2VEC(vr) ) {
        ErrorQuit( "Vector +: vectors must have the same length",
                   0L, 0L );
        return 0;
    }


    /* calculate the offset for adding                                     */
    if ( n == 1 ) {  
        ptL = BLOCKS_GF2VEC(vl);
        ptR = BLOCKS_GF2VEC(vr);
        ptS = BLOCKS_GF2VEC(sum);
        end = ptS + ((len+BIPEB-1)/BIPEB);
    } else {
        offset = ( n - 1 ) / BIPEB;
        ptL = BLOCKS_GF2VEC(vl) + offset ;
        ptR = BLOCKS_GF2VEC(vr) + offset ;
        ptS = BLOCKS_GF2VEC(sum) + offset ;
        end = ptS + ((len+BIPEB-1)/BIPEB) - offset;
    }
    
    /* loop over the entries and add                                       */
    if (vl == sum)
      while ( ptS < end )
	{
	  if ((x = *ptR)!= 0)
	    *ptS = *ptL ^ x;
	  ptL++; ptS++; ptR++;
	}
    else if (vr == sum)
      while ( ptS < end )
	{
	  if ((x = *ptL) != 0)
	    *ptS = *ptR ^ x;
	  ptL++; ptS++; ptR++;
	}
    else
      while (ptS < end )
	*ptS++ = *ptL++ ^ *ptR++;

    /* return the result                                                   */
    return sum;
}


/****************************************************************************
**
*F  ProdGF2VecGF2Vec( <vl>, <vr> )  . . . . . . .  product of two GF2 vectors
**
**  'ProdVecGF2VecGF2' returns  the product of  the two GF2 vectors <vl> and
**  <vr>.   The product is  the folded sum of   the corresponding entries of
**  <vl> and <vr>.
**
**  'ProdVecGF2VecGF2' is an improved  version of the general multiplication,
**  which  does not  call 'PROD'  but uses bit  operations instead.   It will
**  always return either 'GF2One' or 'GF2Zero'.
*/
#ifdef SYS_IS_64_BIT

#define PARITY_BLOCK(m) \
  do { m = m ^ (m>>32); \
       m = m ^ (m>>16); \
       m = m ^ (m>>8);  \
       m = m ^ (m>>4);  \
       m = m ^ (m>>2);  \
       m = m ^ (m>>1);  \
  } while(0)

#else

#define PARITY_BLOCK(m) \
  do { m = m ^ (m>>16); \
       m = m ^ (m>>8);  \
       m = m ^ (m>>4);  \
       m = m ^ (m>>2);  \
       m = m ^ (m>>1);  \
  } while(0)

#endif

Obj ProdGF2VecGF2Vec ( vl, vr )
    Obj                 vl;
    Obj                 vr;
{
    UInt *              ptL;            /* bit field of <vl>               */
    UInt *              ptR;            /* bit field of <vr>               */
    UInt                len;            /* length of the list              */
    UInt                nrb;            /* number of blocks in blist       */
    UInt                m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                i;              /* loop variable                   */

    /* both operands lie in the same field                                 */
    len = LEN_GF2VEC(vl);
    if ( len != LEN_GF2VEC(vr) ) {
      ErrorQuit(
        "Vector *: <right> must have the same length as <left> (%d not %d)",
        len, (Int)LEN_GF2VEC(vr) );
      return 0;
    }

    /* loop over the entries and multiply                                  */
    ptL = BLOCKS_GF2VEC(vl);
    ptR = BLOCKS_GF2VEC(vr);
    nrb = NUMBER_BLOCKS_GF2VEC(vl);
    n   = 0;
    for ( i = 1;  i <= nrb;  i++ ) {
        m = (*ptL++) & (*ptR++);
        PARITY_BLOCK(m);
        n ^= m;
    }

    /* return the result                                                   */
    return (n & 1) ? GF2One : GF2Zero;
}


/****************************************************************************
**
*F  ProdGF2VecGF2Mat( <vl>, <vr> )  . .  product of GF2 vector and GF2 matrix
**
**  'ProdGF2VecGF2Mat'  returns the product  of the  GF2 vector <vl>  and the
**  GF2 matrix  <vr>.   The product is   the sum of  the  rows of <vr>,  each
**  multiplied by the corresponding entry of <vl>.  Note that the  caller has
**  to ensure, that <vl> is a gf2-vector and <vr> is a gf2-matrix.
*/
Obj ProdGF2VecGF2Mat ( vl, vr )
    Obj                 vl;
    Obj                 vr;
{
    UInt                len;            /* length of the list              */
    UInt                stop;
    UInt                col;            /* length of the rows              */
    UInt                i;              /* loop variables                  */
    Obj                 prod;           /* product, result                 */
    UInt *              start;
    UInt *              end;
    UInt *              ptL;
    UInt                mask;
    
    /* both operands lie in the same field                                 */
    len = LEN_GF2VEC(vl);
    if ( len != LEN_GF2MAT(vr) ) {
      ErrorQuit(
        "Vector *: <right> must have the same length as <left> (%d not %d)",
        len, (Int)LEN_GF2MAT(vr) );
      return 0;
    }

    /* make the result vector                                              */
    col = LEN_GF2VEC( ELM_GF2MAT( vr, 1 ) );
    NEW_GF2VEC( prod, (IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr)) ? 
		TYPE_LIST_GF2VEC : TYPE_LIST_GF2VEC_IMM, col );
    SET_LEN_GF2VEC( prod, col );
    
    /* get the start and end block                                         */
    start = BLOCKS_GF2VEC(prod);
    ptL   = BLOCKS_GF2VEC(vl);
    end   = start + (col+BIPEB-1)/BIPEB;

    /* loop over the vector                                                */
    for ( i = 1;  i <= len;  ptL++ )  {

        /* if the whole block is zero, get the next entry                  */
        if (*ptL == 0) {
            i += BIPEB;
            continue;
        }
        
        /* run through the block                                           */
        stop = i + BIPEB - 1;
        if ( len < stop )
            stop = len;
        for ( mask = 1;  i <= stop;  i++, mask <<= 1 ) {

            /* if there is entry add the row to the result                 */
            if ( (*ptL & mask) != 0 ) {
                UInt * ptPP = start;
                UInt * ptRR = BLOCKS_GF2VEC(ELM_GF2MAT(vr,i));
                while ( ptPP < end ) 
                    *ptPP++ ^= *ptRR++;
            }
        }
    }

    /* return the result                                                   */
    return prod;
}


/****************************************************************************
**
*F  ProdGF2MatGF2Vec( <ml>, <vr> )  . .  product of GF2 matrix and GF2 vector
**
**  'ProdGF2MatGF2Vec'  returns the product  of the  GF2 matrix <ml>  and the
**  GF2 vector  <vr>.   The ith entry of the
**  product is the inner product of  the  ith row of <ml> with <vr>.
**  Note that the  caller has
**  to ensure, that <ml> is a GF2 matrix and <vr> is a GF2 vector.
*/
Obj ProdGF2MatGF2Vec ( ml, vr )
    Obj                 ml;
    Obj                 vr;
{
    UInt                len;            /* length of the vector            */
    UInt                ln2;            /* length of the matrix            */
    UInt *              ptL;            /* bit field of <ml>[j]            */
    UInt *              ptR;            /* bit field of <vr>               */
    UInt                nrb;            /* number of blocks in blist       */
    UInt                m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                i;              /* loop variable                   */
    UInt                j;              /* loop variable                   */
    Obj                 prod;           /* result                          */
    
    /* both operands lie in the same field                                 */
    len = LEN_GF2VEC(vr);
    ln2 = LEN_GF2MAT(ml);
    if ( 0 == ln2 ) {
        return CopyObj(ml,0);
    }
    if ( len != LEN_GF2VEC(ELM_GF2MAT(ml,1)) ) {
     ErrorQuit(
      "Vector *: <left>[1] must have the same length as <right> (%d not %d)",
      len, (Int)LEN_GF2VEC(ELM_GF2MAT(vr,1)) );
     return 0;
    }

    /* make the result vector                                              */
    NEW_GF2VEC( prod, (IS_MUTABLE_OBJ(ELM_GF2MAT(ml,1)) || IS_MUTABLE_OBJ(vr)) ? 
		TYPE_LIST_GF2VEC :TYPE_LIST_GF2VEC_IMM, ln2 );
    SET_LEN_GF2VEC( prod, ln2 );

    /* loop over the entries and multiply                                  */
    nrb = NUMBER_BLOCKS_GF2VEC(vr);
    for ( j = 1;  j <= ln2;  j++ ) {
        ptL = BLOCKS_GF2VEC(ELM_GF2MAT(ml,j));
        ptR = BLOCKS_GF2VEC(vr);
        n   = 0;
        for ( i = 1;  i <= nrb;  i++ ) {
            m = (*ptL++) & (*ptR++);
            PARITY_BLOCK(m);
            n ^= m;
        }
        if ( n & 1 )
            BLOCK_ELM_GF2VEC(prod,j) |= MASK_POS_GF2VEC(j);
    }

    /* return the result                                                   */
    return prod;
}

/****************************************************************************
**
*F  ProdGF2MatGF2Mat( <ml>, <mr> )  . .  product of GF2 matrix and GF2 matrix
**
**  'ProdGF2MatGF2Mat'  returns the product  of the  GF2 matrix <vl>  and the
**  GF2 matrix  <mr>.  This simply calls ProdGF2VecGF2Mat once on each row.
*/

static Obj IsLockedRepresentationVector;

Obj ProdGF2MatGF2Mat( Obj ml, Obj mr )
{
  Obj prod;
  UInt i;
  UInt len;
  Obj row;
  len = LEN_GF2MAT(ml);
  prod = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT(len));
  SET_LEN_GF2MAT(prod,len);
  TYPE_POSOBJ(prod) = (IS_MUTABLE_OBJ(ml) || IS_MUTABLE_OBJ(mr)) ? TYPE_LIST_GF2MAT : TYPE_LIST_GF2MAT_IMM;
  for (i = 1; i <= len; i++)
    {
      row = ProdGF2VecGF2Mat(ELM_GF2MAT(ml,i),mr);

      /* Since I'm going to put this vector into a matrix, I must lock its
	 representation, so that it doesn't get rewritten over GF(2^k) */
      TYPE_DATOBJ(row) = TYPE_LIST_GF2VEC_IMM_LOCKED;
      SET_ELM_GF2MAT(prod,i,row);
      CHANGED_BAG(prod);
    }
  return prod;
}


/****************************************************************************
**
*F  FuncProdGF2VecAnyMat( <self>, <v>, <m>) . . . method to handle vector*plain list
**                                    of GF2Vectors reasonably efficiently
**
*/
Obj FuncProdGF2VecAnyMat ( Obj self, Obj vec, Obj mat )
{
  Obj res;
  UInt len;
  UInt len1;
  Obj row1;
  UInt i;
  UInt block;
  
  len = LEN_GF2VEC(vec);
  if (LEN_PLIST(mat) != len)
    {
      mat = ErrorReturnObj("<vec> * <mat>: vector and matrix must have same length", 0L, 0L,
			   "you can replace matrix <mat> via 'return <mat>;'");
      return PROD(vec,mat);
    }

  /* Get the first row, to establish the size of the result */
  row1 = ELM_PLIST(mat,1);  
  if (! IS_GF2VEC_REP(row1))
    return TRY_NEXT_METHOD;
  len1 = LEN_GF2VEC(row1);

  /* create the result space */
  NEW_GF2VEC( res,
	      (IS_MUTABLE_OBJ(vec) || IS_MUTABLE_OBJ(mat)) ? TYPE_LIST_GF2VEC : TYPE_LIST_GF2VEC_IMM,
	      len1);
  SET_LEN_GF2VEC(res,len1);

  /* Finally, we start work */
  for (i = 1; i <= len; i++)
    {
      if (i % BIPEB == 1)
	block = BLOCK_ELM_GF2VEC(vec,i);
      if (block & MASK_POS_GF2VEC(i))
     	{
	  row1 = ELM_PLIST(mat,i);  
	  if (! IS_GF2VEC_REP(row1))
	    return TRY_NEXT_METHOD;
	  AddPartialGF2VecGF2Vec(res, res, row1, 1);
	}
    }
  return res;

}

/****************************************************************************
**
*F  InversePlistGF2VecsDesstructive( <list> )
**
**  This is intended to form the core of a method for InverseOp.
**  by this point it should be checked that list is a plain list of GF2 vectors
**  of equal lengths. 
*/
Obj InversePlistGF2VecsDesstructive( Obj list )
{
    UInt                len;            /* dimension                       */
    Obj                 inv;            /* result                          */
    Obj                 row;            /* row vector                      */
    Obj                 old;            /* row from <mat>                  */
    Obj                 tmp;            /* temporary                       */
    UInt *              ptQ;            /* data block of <row>             */
    UInt *              ptP;            /* data block of source row        */
    UInt *              end;            /* end marker                      */
    UInt *              end2;           /* end marker                      */
    UInt                i;              /* loop variable                   */
    UInt                k;              /* loop variable                   */

    len = LEN_PLIST(list);
    
    /* create the identity matrix                                          */
    tmp = NEW_PLIST( T_PLIST, len );
    for ( i = len;  0 < i;  i-- ) {
      NEW_GF2VEC( row, TYPE_LIST_GF2VEC, len );
      SET_LEN_GF2VEC( row, len );
      BLOCK_ELM_GF2VEC(row,i) |= MASK_POS_GF2VEC(i);
      SET_ELM_PLIST( tmp, i, row );
      CHANGED_BAG(tmp);
    }
    SET_LEN_PLIST(tmp, len);
    inv = tmp;

    /* now start with ( id | mat ) towards ( inv | id )                    */
    for ( k = 1;  k <= len;  k++ ) {

        /* find a nonzero entry in column <k>                              */
        for ( i = k;  i <= len;  i++ ) {
            row = ELM_PLIST( list, i );
            if ( BLOCK_ELM_GF2VEC(row,k) & MASK_POS_GF2VEC(k) )
                break;
        }
        if ( i > len )  {
            return Fail;
        }
        if ( i != k )  {
            row = ELM_PLIST( list, i );
            SET_ELM_PLIST( list, i, ELM_PLIST( list, k ) );
            SET_ELM_PLIST( list, k, row );
            row = ELM_PLIST( inv, i );
            SET_ELM_PLIST( inv, i, ELM_PLIST( inv, k ) );
            SET_ELM_PLIST( inv, k, row );
        }
        
        /* clear entries                                                   */
        old = ELM_PLIST( list, k );
        end = BLOCKS_GF2VEC(old) + ((len+BIPEB-1)/BIPEB);
        for ( i = 1;  i <= len;  i++ ) {
            if ( i == k )
                continue;
            row = ELM_PLIST( list, i );
            if ( BLOCK_ELM_GF2VEC(row,k) & MASK_POS_GF2VEC(k) ) {

                /* clear <mat>                                             */
                ptQ = &(BLOCK_ELM_GF2VEC(row,k));
                ptP = &(BLOCK_ELM_GF2VEC(old,k));
                while ( ptP < end ) {
                    *ptQ++ ^= *ptP++;
                }

                /* modify <inv>                                            */
                row  = ELM_PLIST( inv, i );
                ptQ  = BLOCKS_GF2VEC(row);
                row  = ELM_PLIST( inv, k );
                ptP  = BLOCKS_GF2VEC(row);
                end2 = ptP + ((len+BIPEB-1)/BIPEB);
                while ( ptP < end2 ) {
                    *ptQ++ ^= *ptP++;
                }
            }
        }
    }
    return inv;
}
    


/****************************************************************************
**
*F  InverseGF2Mat( <mat> )  . . . . . . . . . . . . . . inverse of GF2 matrix
*/

Obj InverseGF2Mat (
    Obj                 mat )
{
    UInt                len;            /* dimension                       */
    Obj                 inv;            /* result                          */
    Obj                 row;            /* row vector                      */
    Obj                 tmp;            /* temporary                       */
    UInt                i;              /* loop variable                   */
    Obj                 old;            /* row from <mat>                  */
    UInt *              ptQ;            /* data block of <row>             */
    UInt *              ptP;            /* data block of source row        */
    UInt *              end;            /* end marker                      */

    /* make a structural copy of <mat> as list of GF2 vectors              */
    len = LEN_GF2MAT(mat);

    /* special routes for very small matrices */
    if ( len == 0 ) {
        return CopyObj(mat,1);
    }
    if (len == 1 ) {
      row = ELM_GF2MAT(mat,1);
      if (BLOCKS_GF2VEC(row)[0] & 1)
	{
	  return CopyObj(mat, 1);
	}
      else
	return Fail;
    }
    
    tmp = NEW_PLIST( T_PLIST, len );
    for ( i = len;  0 < i;  i-- ) {
        old = ELM_GF2MAT( mat, i );
        NEW_GF2VEC( row, TYPE_LIST_GF2VEC_IMM, len );
        SET_LEN_GF2VEC( row, len );
        ptQ = BLOCKS_GF2VEC(old);
        ptP = BLOCKS_GF2VEC(row);
        end = ptP + ((len+BIPEB-1)/BIPEB);
        while ( ptP < end )
            *ptP++ = *ptQ++;
        SET_ELM_PLIST( tmp, i, row );
        CHANGED_BAG(tmp);
    }
    SET_LEN_PLIST(tmp,len);
    inv = InversePlistGF2VecsDesstructive( tmp );
    if (inv == Fail)
      return inv;
    
    /* convert list <inv> into a matrix                                    */
    ResizeBag( inv, SIZE_PLEN_GF2MAT(len) );
    for ( i = len;  0 < i;  i-- ) {
      row = ELM_PLIST(inv,i);
      SET_TYPE_POSOBJ(row, TYPE_LIST_GF2VEC_IMM_LOCKED);
      SET_ELM_GF2MAT( inv, i, row );
    }
    SET_LEN_GF2MAT( inv, len );
    RetypeBag( inv, T_POSOBJ );
    TYPE_POSOBJ( inv ) = TYPE_LIST_GF2MAT;
    return inv;
}

/****************************************************************************
**
*F  ShallowCopyVecGF2( <vec> )
**
*/

Obj ShallowCopyVecGF2( Obj vec )
{
  Obj copy;
  UInt len;
  UInt *ptrS;
  UInt *ptrD;
  UInt *endS;
  len = LEN_GF2VEC(vec);
  NEW_GF2VEC( copy, TYPE_LIST_GF2VEC, len);
  SET_LEN_GF2VEC(copy,len);
  ptrS = BLOCKS_GF2VEC(vec);
  ptrD = BLOCKS_GF2VEC(copy);
  endS = ptrS + NUMBER_BLOCKS_GF2VEC(vec);
  while (ptrS < endS)
    *ptrD++ = *ptrS++;
  return copy;
}

/****************************************************************************
**
*F  SemiEchelonPlistGF2Vecs( <mat>, <transformations-needed> )
**
**  The matrix needs to have mutable rows, so it can't be a GF2Mat
**  This function DOES NOT CHECK that the rows are all GF2 vectors
**
**  Does not copy the matrix, may destroy it, may include some
**  of the rows among the returned vectors
*/

static inline void AddGF2VecToGF2Vec(
  UInt *	ptS,
  UInt *	ptV,
  UInt		len)
{
  UInt * end;
  end = ptS + ((len+BIPEB-1)/BIPEB);
  while ( ptS < end ) {
    *ptS++ ^= *ptV++;
  }
}


static UInt RNheads = 0, RNvectors = 0, RNcoeffs = 0, RNrelns = 0;


Obj SemiEchelonListGF2Vecs( Obj mat, UInt TransformationsNeeded )
{
  UInt nrows, ncols;
  UInt i,j,h;
  UInt block;
  Obj heads,vectors, coeffs, relns;
  UInt nvecs, nrels;
  Obj coeffrow;
  Obj row;
  UInt *rowp, *coeffrowp;
  Obj res;
  nrows = LEN_PLIST(mat);
  ncols = LEN_GF2VEC(ELM_PLIST(mat,1));
  heads = NEW_PLIST(T_PLIST_CYC, ncols);
  SET_LEN_PLIST(heads, ncols);
  vectors = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
  SET_LEN_PLIST(vectors, 0);
  nvecs = 0;
  if (TransformationsNeeded)
    {
      coeffs = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
      SET_LEN_PLIST(coeffs, 0);
      relns  = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
      SET_LEN_PLIST(relns, 0);
      nrels = 0;
    }
  for (i = 1; i <= ncols; i++)
    SET_ELM_PLIST(heads, i, INTOBJ_INT(0));
  for (i = 1; i <= nrows; i++)
    {
      row = ELM_PLIST(mat, i);
      if (TransformationsNeeded)
	{
	  NEW_GF2VEC(coeffrow, TYPE_LIST_GF2VEC, nrows);
	  SET_LEN_GF2VEC(coeffrow, nrows);
	  BLOCK_ELM_GF2VEC( coeffrow, i) |= MASK_POS_GF2VEC(i);
	}
      
      /* No garbage collection risk from here */
      rowp = BLOCKS_GF2VEC(row);
      if (TransformationsNeeded)
	coeffrowp = BLOCKS_GF2VEC(coeffrow);
      for (j = 1; j <= ncols; j++)
	{
	  h = INT_INTOBJ(ELM_PLIST(heads, j));
	  if (h != 0)
	    {
	      if (rowp[(j-1)/BIPEB] & MASK_POS_GF2VEC(j))
		{
		  AddGF2VecToGF2Vec(rowp, BLOCKS_GF2VEC(ELM_PLIST(vectors,h)),ncols);
		  if (TransformationsNeeded)
		    AddGF2VecToGF2Vec(coeffrowp, BLOCKS_GF2VEC(ELM_PLIST(coeffs,h)),nrows);
		}
	    }
	}
      j = 1;
      while (j <= ncols && !*rowp)
	{
	  j += BIPEB;
	  rowp++;
	}
      while ( j <= ncols && !(*rowp & MASK_POS_GF2VEC(j)))
	j++;

      /* garbage collection OK again after here */
      if (j <= ncols)
	{
	  SET_ELM_PLIST(vectors, ++nvecs, row);
	  SET_LEN_PLIST(vectors, nvecs);
	  SET_ELM_PLIST( heads, j, INTOBJ_INT(nvecs));
	  if (TransformationsNeeded)
	    {
	      SET_ELM_PLIST(coeffs, nvecs, coeffrow);
	      SET_LEN_PLIST(coeffs, nvecs);
	    }
	}
      else if (TransformationsNeeded)
	{
	  SET_ELM_PLIST(relns, ++nrels, coeffrow);
	  SET_LEN_PLIST(relns, nrels);
	}
    }
  if (RNheads == 0)
    {
      RNheads = RNamName("heads");
      RNvectors = RNamName("vectors");
    }
  res = NEW_PREC( TransformationsNeeded ? 4 : 2);
  SET_RNAM_PREC( res, 1, RNheads);
  SET_ELM_PREC(  res, 1, heads);
  SET_RNAM_PREC( res, 2, RNvectors);
  SET_ELM_PREC(  res, 2, vectors);
  if (LEN_PLIST(vectors) == 0)
    RetypeBag(vectors, T_PLIST_EMPTY);
  if (TransformationsNeeded)
    {
      if (RNcoeffs == 0)
	{
	  RNcoeffs = RNamName("coeffs");
	  RNrelns = RNamName("relations");
	}
      SET_RNAM_PREC( res, 3, RNcoeffs);
      SET_ELM_PREC ( res, 3, coeffs);
      if (LEN_PLIST(coeffs) == 0)
	RetypeBag(coeffs, T_PLIST_EMPTY);
      SET_RNAM_PREC( res, 4, RNrelns);
      SET_ELM_PREC ( res, 4, relns);
      if (LEN_PLIST(relns) == 0)
	RetypeBag(relns, T_PLIST_EMPTY);
    }
  return res;
}

/****************************************************************************
**
*F  UInt TriangulizeListGF2Vecs( <mat>, <clearup> ) -- returns the rank
**
*/

UInt TriangulizeListGF2Vecs( Obj mat, UInt clearup)
{
  UInt nrows;
  UInt ncols;
  UInt workcol;
  UInt workrow;
  UInt rank;
  Obj row, row2;
  UInt *rowp, *row2p;
  UInt block;
  UInt mask;
  UInt j;
  nrows = LEN_PLIST( mat );
  ncols = LEN_GF2VEC( ELM_PLIST(mat, 1));
  rank = 0;

  /* Nothing here can cause a garbage collection */
  
  for (workcol = 1; workcol <= ncols; workcol++)
    {
      block = (workcol-1)/BIPEB;
      mask = MASK_POS_GF2VEC(workcol);
      for (workrow = rank+1; workrow <= nrows &&
	     !(BLOCKS_GF2VEC(ELM_PLIST(mat, workrow))[block] & mask); workrow ++)
	;
      if (workrow <= nrows)
	{
	  rank++;
	  row = ELM_PLIST(mat, workrow);
	  if (workrow != rank)
	    {
	      SET_ELM_PLIST(mat, workrow, ELM_PLIST(mat, rank));
	      SET_ELM_PLIST(mat, rank, row);
	    }
	  rowp = BLOCKS_GF2VEC(row);
	  if (clearup)
	    for (j = 1; j < rank; j ++)
	      {
		row2 = ELM_PLIST(mat, j);
		row2p = BLOCKS_GF2VEC(row2);
		if (row2p[block] & mask)
		  AddGF2VecToGF2Vec(row2p,rowp, ncols);
	      }
	  for (j = workrow+1; j <= nrows; j++)
	    {
	      row2 = ELM_PLIST(mat, j);
	      row2p = BLOCKS_GF2VEC(row2);
	      if (row2p[block] & mask)
		AddGF2VecToGF2Vec(row2p,rowp, ncols);
	    }
	  
	}
      
    }
  return rank;
}

/****************************************************************************
**

*F * * * * * * * * * * * *  conversion functions  * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  PlainGF2Vec( <list> ) . . .  . convert a GF2 vector into an ordinary list
**
**  'PlainGF2Vec' converts the GF2 vector <list> to a plain list.
*/
static Obj IsLockedRepresentationVector;


void PlainGF2Vec (
    Obj                 list )
{
    Int                 len;            /* length of <list>                */
    UInt                i;              /* loop variable                   */
    Obj                 first;          /* first entry                     */


    /* check for representation lock */
    if (True == DoFilter( IsLockedRepresentationVector, list))
      ErrorQuit("Cannot convert a locked GF2 vector into a plain list", 0, 0);
    
    /* resize the list and retype it, in this order                        */
    len = LEN_GF2VEC(list);
    RetypeBag( list, IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE );
    GROW_PLIST( list, (UInt)len );
    SET_LEN_PLIST( list, len );

    /* keep the first entry because setting the second destroys the first  */
    first = ELM_GF2VEC(list,1);

    /* wipe out the first entry of the GF2 vector (which becomes the       */
    /* entry of the plain list, in case the list has length 1.             */
    if (len == 1)
      SET_ELM_PLIST( list, 2, 0 );
    
    /* replace the bits by 'GF2One' or 'GF2Zero' as the case may be        */
    /* this must of course be done from the end of the list backwards      */
    for ( i = len;  1 < i;  i-- )
        SET_ELM_PLIST( list, i, ELM_GF2VEC( list, i ) );
    SET_ELM_PLIST( list, 1, first );

    CHANGED_BAG(list);
}


/****************************************************************************
**
*F  PlainGF2Mat( <list> ) . . .  . convert a GF2 matrix into an ordinary list
**
**  'PlainGF2Mat' converts the GF2 matrix <list> to a plain list.
*/
void PlainGF2Mat (
    Obj                 list )
{
    Int                 len;            /* length of <list>                */
    UInt                i;              /* loop variable                   */

    /* resize the list and retype it, in this order                        */
    len = LEN_GF2MAT(list);
    RetypeBag( list, IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE );
    SET_LEN_PLIST( list, len );

    /* shift the entries to the left                                       */
    for ( i = 1;  i <= len;  i++ ) {
        SET_ELM_PLIST( list, i, ELM_GF2MAT( list, i ) );
    }
    SHRINK_PLIST( list, len );
    CHANGED_BAG(list);
}


/****************************************************************************
**
*F  ConvGF2Vec( <list> )  . . . . .  convert a list into a GF2 vector objects
*/
void ConvGF2Vec (
    Obj                 list )
{
    Int                 len;            /* logical length of the vector    */
    Int                 i;              /* loop variable                   */
    UInt                block;          /* one block of the boolean list   */
    UInt                bit;            /* one bit of a block              */
        
    /* already in the correct representation                               */
    if ( IS_GF2VEC_REP(list) ) {
        return;
    }

    /* Otherwise make it a plain list so that we will know where it keeps
       its data -- could do much better in the case of GF(2^n) ectors that actually
       lie over GF(2) */

    if (IS_VEC8BIT_REP(list))
      PlainVec8Bit(list);
    else
      PLAIN_LIST( list );
    
    /* change its representation                                           */
    len   = LEN_PLIST(list);

    /* We may have to resize the bag now because a length 1
       plain list is shorter than a length 1 VECGF2 */
    if (SIZE_PLEN_GF2VEC(len) > SIZE_OBJ(list))
      ResizeBag( list, SIZE_PLEN_GF2VEC(len) );

    /* now do the work */
    block = 0;
    bit   = 1;
    for ( i = 1;  i <= len;  i++ ) {
        if ( VAL_FFE( ELM_PLIST( list, i ) ) )
            block |= bit;
        bit = bit << 1;
        if ( bit == 0 || i == len ) {
            BLOCK_ELM_GF2VEC(list,i) = block;
            block = 0;
            bit   = 1;
        }
    }

    /* retype and resize bag                                               */
    ResizeBag( list, SIZE_PLEN_GF2VEC(len) );
    SET_LEN_GF2VEC( list, len );
    if ( HAS_FILT_LIST( list, FN_IS_MUTABLE ) )
        TYPE_DATOBJ( list ) = TYPE_LIST_GF2VEC;
    else
        TYPE_DATOBJ( list ) = TYPE_LIST_GF2VEC_IMM;
    RetypeBag( list, T_DATOBJ );
}


/****************************************************************************
**
*F  FuncCONV_GF2VEC( <self>, <list> ) . . . . . convert into a GF2 vector rep
*/
Obj FuncCONV_GF2VEC (
    Obj                 self,
    Obj                 list )
{
    /* check whether <list> is a GF2 vector                               */
    ConvGF2Vec(list);

    /* return nothing                                                      */
    return 0;
}

/****************************************************************************
**
*F FuncCONV_GF2MAT (<self>, <list> ) . . . convert into a GF2 matrix rep
**
** We know from the library level that <list> is a list of 
** compressed GF2 vectors
**  
*/
Obj FuncCONV_GF2MAT( Obj self, Obj list)
{
  UInt len, i;
  Obj tmp;
  UInt mut;
  len = LEN_LIST(list);
  if (len == 0)
    return (Obj)0;
  
  PLAIN_LIST(list);
  GROW_PLIST(list, len+1);
  for (i = len; i > 0 ; i--)
    {
      tmp = ELM_PLIST(list, i);
      TYPE_DATOBJ(tmp) = IS_MUTABLE_OBJ(tmp) ? TYPE_LIST_GF2VEC_LOCKED: TYPE_LIST_GF2VEC_IMM_LOCKED;
      SET_ELM_PLIST(list, i+1, tmp);
    }
  SET_ELM_PLIST(list,1,INTOBJ_INT(len));
  mut = IS_MUTABLE_OBJ(list);
  RetypeBag(list, T_POSOBJ);
  SET_TYPE_POSOBJ(list, mut ? TYPE_LIST_GF2MAT : TYPE_LIST_GF2MAT_IMM);
  return (Obj) 0;
}


/****************************************************************************
**
*F  FuncPLAIN_GF2VEC( <self>, <list> ) . . .  convert back into ordinary list
*/
Obj FuncPLAIN_GF2VEC (
    Obj                 self,
    Obj                 list )
{
    /* check whether <list> is a GF2 vector                                */
    while ( ! IS_GF2VEC_REP(list) ) {
        list = ErrorReturnObj(
            "PLAIN_GF2VEC: <list> must be a GF2 vector (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }
    PlainGF2Vec(list);

    /* return nothing                                                      */
    return 0;
}




/****************************************************************************
**
*F  revertbits -- utility function to reverse bit orders
*/


/*   A list of flip values for bytes (i.e. ..xyz -> zyx..) */

static const UInt1 revertlist [] ={
 0, 128, 64, 192, 32, 160, 96, 224, 16, 144, 80, 208, 48, 176, 112, 240, 8, 
  136, 72, 200, 40, 168, 104, 232, 24, 152, 88, 216, 56, 184, 120, 248, 4, 
  132, 68, 196, 36, 164, 100, 228, 20, 148, 84, 212, 52, 180, 116, 244, 12, 
  140, 76, 204, 44, 172, 108, 236, 28, 156, 92, 220, 60, 188, 124, 252, 2, 
  130, 66, 194, 34, 162, 98, 226, 18, 146, 82, 210, 50, 178, 114, 242, 10, 
  138, 74, 202, 42, 170, 106, 234, 26, 154, 90, 218, 58, 186, 122, 250, 6, 
  134, 70, 198, 38, 166, 102, 230, 22, 150, 86, 214, 54, 182, 118, 246, 14, 
  142, 78, 206, 46, 174, 110, 238, 30, 158, 94, 222, 62, 190, 126, 254, 1, 
  129, 65, 193, 33, 161, 97, 225, 17, 145, 81, 209, 49, 177, 113, 241, 9, 
  137, 73, 201, 41, 169, 105, 233, 25, 153, 89, 217, 57, 185, 121, 249, 5, 
  133, 69, 197, 37, 165, 101, 229, 21, 149, 85, 213, 53, 181, 117, 245, 13, 
  141, 77, 205, 45, 173, 109, 237, 29, 157, 93, 221, 61, 189, 125, 253, 3, 
  131, 67, 195, 35, 163, 99, 227, 19, 147, 83, 211, 51, 179, 115, 243, 11, 
  139, 75, 203, 43, 171, 107, 235, 27, 155, 91, 219, 59, 187, 123, 251, 7, 
  135, 71, 199, 39, 167, 103, 231, 23, 151, 87, 215, 55, 183, 119, 247, 15, 
  143, 79, 207, 47, 175, 111, 239, 31, 159, 95, 223, 63, 191, 127, 255
};

/* Takes an UInt a on n bits and returns the Uint obtained by reverting the
 * bits */
UInt revertbits(UInt a, Int n)
{
  UInt b,c;
  Int i;
  b=0;
  while (n>8) {
    c=a&0xff; /* last byte */
    a = a>>8;
    b = b<<8;
    b += (UInt) revertlist[(UInt1)c]; /* add flipped */
    n -=8;
  }
  /* cope with the last n bits */
  a &= 0xff;
  b= b<<n;
  c=(UInt) revertlist[(UInt1)a];
  c = c>> (8-n);
  b+=c;
  return b;
}

/****************************************************************************
**
*F  Cmp_GF2Vecs( <vl>, <vr> )   compare GF2 vectors -- internal
**                                    returns -1, 0 or 1
*/
Int Cmp_GF2VEC_GF2VEC (
    Obj                 vl,
    Obj                 vr )
{
    UInt                i;              /* loop variable                   */
    UInt *              bl;             /* block of <vl>                   */
    UInt *              br;             /* block of <vr>                   */
    UInt                len,lenl,lenr;  /* length of the list              */
    UInt a,b,nb;

    /* get and check the length                                            */
    lenl = LEN_GF2VEC(vl);
    lenr = LEN_GF2VEC(vr);
    nb=NUMBER_BLOCKS_GF2VEC(vl);
    a=NUMBER_BLOCKS_GF2VEC(vr);
    if (a<nb) {
      nb = a;
    }

    /* check all blocks                                                    */
    bl = BLOCKS_GF2VEC(vl);
    br = BLOCKS_GF2VEC(vr);
    for ( i = nb;  1 < i;  i--, bl++, br++ ) {
	/* comparison is numeric of the reverted lists*/
      if (*bl != *br)
	{
	  a=revertbits(*bl,BIPEB);
	  b=revertbits(*br,BIPEB);
	  if ( a < b )
            return -1;
	  else return 1;
	}
    }
    

    /* The last block remains */
    len=lenl;
    if (len>lenr) {
      len=lenr;
    }

    /* is there still a full block in common? */
    len = len % BIPEB;
    if (len == 0) {
      a=revertbits(*bl,BIPEB);
      b=revertbits(*br,BIPEB);
    }
    else {
      a=revertbits(*bl,len);
      b=revertbits(*br,len);
    }

    if (a<b)
      return -1;
    if (a>b)
      return 1;
    
    /* blocks still the same --left length must be smaller to be true */
    if (lenr>lenl)
      return -1;
    if (lenl > lenr)
      return 1;
    
    return 0;

}


/****************************************************************************
**
*F  FuncEQ_GF2VEC_GF2VEC( <self>, <vl>, <vr> )   test equality of GF2 vectors
*/
Obj FuncEQ_GF2VEC_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
  /* we can do this case MUCH faster if we just want equality */
  if (LEN_GF2VEC(vl)  != LEN_GF2VEC(vr))
    return False;
  return (Cmp_GF2VEC_GF2VEC(vl,vr) == 0) ? True : False;
}


/****************************************************************************
**
*F  FuncLEN_GF2VEC( <self>, <list> )  . . . . . . . .  length of a GF2 vector
*/
Obj FuncLEN_GF2VEC (
    Obj                 self,
    Obj                 list )
{
    return INTOBJ_INT(LEN_GF2VEC(list));
}


/****************************************************************************
**

*F  FuncELM0_GF2VEC( <self>, <list>, <pos> )  . select an elm of a GF2 vector
**
**  'ELM0_GF2VEC'  returns the element at the  position  <pos> of the boolean
**  list <list>, or `Fail' if <list> has no assigned  object at <pos>.  It is
**  the  responsibility of  the caller to   ensure  that <pos> is  a positive
**  integer.
*/
Obj FuncELM0_GF2VEC (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;

    p = INT_INTOBJ(pos);
    if ( LEN_GF2VEC(list) < p ) {
        return Fail;
    }
    else {
        return ELM_GF2VEC( list, p );
    }
}


/****************************************************************************
**
*F  FuncELM_GF2VEC( <self>, <list>, <pos> ) . . select an elm of a GF2 vector
**
**  'ELM_GF2VEC' returns the element at the position <pos>  of the GF2 vector
**  <list>.   An  error  is signalled  if  <pos>  is  not bound.    It is the
**  responsibility of the caller to ensure that <pos> is a positive integer.
*/
Obj FuncELM_GF2VEC (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;

    p = INT_INTOBJ(pos);
    if ( LEN_GF2VEC(list) < p ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            p, 0L, "you can 'return;' after assigning a value" );
        return ELM_LIST( list, p );
    }
    else {
        return ELM_GF2VEC( list, p );
    }
}


/****************************************************************************
**
*F  FuncELMS_GF2VEC( <self>, <list>, <poss> ) . . . sublist from a GF2 vector
**
**  'ELMS_GF2VEC' returns a new list containing  the elements at the position
**  given in    the   list  <poss> from  the   vector   <list>.   It  is  the
**  responsibility of the caller to ensure that <poss>  is dense and contains
**  only positive integers.  An error is signalled if an element of <poss> is
**  larger than the length of <list>.
*/
Obj FuncELMS_GF2VEC (
    Obj                 self,
    Obj                 list,
    Obj                 poss )
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    UInt *              ptrD;           /* pointer destination             */
    UInt *              ptrS;           /* pointer source                  */
    Int                 lenPoss;        /* length of positions             */
    Int                 pos;            /* position as integer             */
    Int                 cut;            /* cut point in a <BIPEB> block    */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */

    /* get the length of <list>                                            */
    lenList = LEN_GF2VEC(list);

    /* general code for arbritrary lists, which are ranges                 */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST(poss);

        /* make the result vector                                          */
        NEW_GF2VEC( elms, TYPE_LIST_GF2VEC, lenPoss );
        SET_LEN_GF2VEC( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1;  i <= lenPoss;  i++ ) {

            /* get next position                                           */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorQuit( "List Elements: <list>[%d] must have a value",
                           pos, 0L );
                return 0;
            }

            /* assign the element into <elms>                              */
            if ( ELM_GF2VEC( list, pos ) == GF2One ) {
                BLOCK_ELM_GF2VEC(elms,i) |= MASK_POS_GF2VEC(i);
            }
        }

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE(poss);
        pos = GET_LOW_RANGE(poss);
        inc = GET_INC_RANGE(poss);

        /* check that no <position> is larger than <lenList>               */
        if ( lenList < pos ) {
            ErrorQuit( "List Elements: <list>[%d] must have a value",
                       pos, 0L );
            return 0;
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorQuit( "List Elements: <list>[%d] must have a value",
                       pos + (lenPoss-1) * inc, 0L );
            return 0;
        }

        /* make the result vector                                          */
        NEW_GF2VEC( elms, TYPE_LIST_GF2VEC, lenPoss );
        SET_LEN_GF2VEC( elms, lenPoss );

        /* special code for ranges with increment of one and perfect fit   */
        cut = (pos-1) % BIPEB;
        if ( inc == 1 && cut == 0 ) {
            ptrS = BLOCKS_GF2VEC(list) + ((pos-1)/BIPEB);
            ptrD = BLOCKS_GF2VEC(elms);
            for ( i = (lenPoss+BIPEB-1)/BIPEB;  0 < i;  i-- )
                *ptrD++ = *ptrS++;
        }

        /* special code for ranges with increment of one                   */
        else if ( inc == 1 ) {
            ptrS = BLOCKS_GF2VEC(list) + ((pos-1)/BIPEB);
            ptrD = BLOCKS_GF2VEC(elms);
            for ( i = lenPoss;  BIPEB <= i;  ptrD++, ptrS++, i -= BIPEB ) {
                *ptrD = (ptrS[0] >> cut) | (ptrS[1] << (BIPEB-cut));
            }
            if ( 0 < i )
                *ptrD = *ptrS >> cut;
	    if (BIPEB - cut < i)
	      *ptrD |= ptrS[1] << (BIPEB-cut);
        }

        /* loop over the entries of <positions> and select                 */
        else {
            for ( i = 1;  i <= lenPoss;  i++, pos += inc ) {
                if ( ELM_GF2VEC(list,pos) == GF2One ) {
                    BLOCK_ELM_GF2VEC(elms,i) |= MASK_POS_GF2VEC(i);
                }
            }
        }
    }

    /* return the result                                                   */
    return elms;
}


/****************************************************************************
**
*F  FuncASS_GF2VEC( <self>, <list>, <pos>, <elm> ) set an elm of a GF2 vector
**
**  'ASS_GF2VEC' assigns the element  <elm> at the position  <pos> to the GF2
**  vector <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive,
**  and that <elm> is not 0.
*/

static Obj ConvertToVectorRep;	/* BH: changed to static */

Obj FuncASS_GF2VEC (
    Obj                 self,
    Obj                 list,
    Obj                 pos,
    Obj                 elm )
{
    UInt                p;

    /* check that <list> is mutable                                        */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        ErrorReturnVoid(
            "Lists Assignment: <list> must be a mutable list",
            0L, 0L,
            "you can 'return;' and ignore the assignment" );
        return 0;
    }

    /* get the position                                                    */
    p = INT_INTOBJ(pos);

    /* if <elm> is Z(2) or 0*Z(2) and the position is OK, keep rep         */
    if ( p <= LEN_GF2VEC(list)+1 ) {
        if ( LEN_GF2VEC(list)+1 == p ) {
	  if (DoFilter(IsLockedRepresentationVector, list) == True)
	    ErrorQuit("Assignment forbidden beyond the end of locked GF2 vector", 0, 0);
	  ResizeBag( list, SIZE_PLEN_GF2VEC(p) );
	  SET_LEN_GF2VEC( list, p );
        }
        if ( EQ(GF2One,elm) ) {
            BLOCK_ELM_GF2VEC(list,p) |= MASK_POS_GF2VEC(p);
        }
        else if ( EQ(GF2Zero,elm) ) {
            BLOCK_ELM_GF2VEC(list,p) &= ~MASK_POS_GF2VEC(p);
        }
	else if (IS_FFE(elm) && CHAR_FF(FLD_FFE(elm)) == 2 && DEGR_FF(FLD_FFE(elm)) <= 8)
	  {
	    /*	    Pr("Rewriting GF2 vector over larger field",0,0); */
	    RewriteGF2Vec(list, SIZE_FF(FLD_FFE(elm)));
	    FuncASS_VEC8BIT(self, list, pos, elm);
	  }
        else
	  {
	    /* 	    Pr("arbitrary assignment (GF2)",0,0); */
	    PlainGF2Vec(list);
	    ASS_LIST( list, p, elm );
	  }
    }
    else {
      /*       Pr("arbitrary assignment 2 (GF2)",0,0); */
        PlainGF2Vec(list);
        ASS_LIST( list, p, elm );
    }
    return 0;
}

/****************************************************************************
**
*F  FuncPLAIN_GF2MAT( <self>, <list> ) . . .  convert back into ordinary list
*/
Obj FuncPLAIN_GF2MAT (
    Obj                 self,
    Obj                 list )
{
    PlainGF2Mat(list);

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F  FuncASS_GF2MAT( <self>, <list>, <pos>, <elm> ) set an elm of a GF2 matrix
**
**  'ASS_GF2MAT' assigns the element  <elm> at the position  <pos> to the GF2
**  matrix <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive,
**  and that <elm> is not 0.
*/
Obj FuncASS_GF2MAT (
    Obj                 self,
    Obj                 list,
    Obj                 pos,
    Obj                 elm )
{
    UInt                p;

    /* check that <list> is mutable                                        */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        ErrorReturnVoid(
            "Lists Assignment: <list> must be a mutable list",
            0L, 0L,
            "you can 'return;' and ignore the assignment" );
        return 0;
    }

    /* get the position                                                    */
    p = INT_INTOBJ(pos);

    /* if <elm> is a GF2 vector and the length is OK, keep the rep         */
    if ( ! IS_GF2VEC_REP(elm) || IS_MUTABLE_OBJ(elm) ) {
        PlainGF2Mat(list);
        ASS_LIST( list, p, elm );
    }
    else if ( p == 1 && 1 >= LEN_GF2MAT(list) ) {
        ResizeBag( list, SIZE_PLEN_GF2MAT(p) );
	TYPE_DATOBJ(elm) = TYPE_LIST_GF2VEC_IMM_LOCKED;
        SET_ELM_GF2MAT( list, p, elm );
	CHANGED_BAG(list);
    }
    else if ( p > LEN_GF2MAT(list)+1 ) {
        PlainGF2Mat(list);
        ASS_LIST( list, p, elm );
    }
    else if ( LEN_GF2VEC(elm) == LEN_GF2VEC(ELM_GF2MAT(list,1)) ) {
        if ( LEN_GF2MAT(list)+1 == p ) {
            ResizeBag( list, SIZE_PLEN_GF2MAT(p) );
            SET_LEN_GF2MAT( list, p );
        }
	TYPE_DATOBJ(elm) = TYPE_LIST_GF2VEC_IMM_LOCKED;
        SET_ELM_GF2MAT( list, p, elm );
        CHANGED_BAG(list);
    }
    else {
        PlainGF2Mat(list);
        ASS_LIST( list, p, elm );
    }
    return 0;
}


/****************************************************************************
**

*F  FuncUNB_GF2VEC( <self>, <list>, <pos> ) . unbind position of a GF2 vector
**
**  'UNB_GF2VEC' unbind  the element at  the position  <pos> in  a GF2 vector
**  <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive.
*/
Obj FuncUNB_GF2VEC (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;

    /* check that <list> is mutable                                        */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        ErrorReturnVoid(
            "Unbind: <list> must be a mutable list",
            0L, 0L,
            "you can 'return;' and ignore the operation" );
        return 0;
    }

    if (DoFilter(IsLockedRepresentationVector, list) == True)
    {
      ErrorReturnVoid( "Unbind forbidden on locked GF2 vector",
		          0L, 0L,
            "you can 'return;' and ignore the operation" );
        return 0;
    }

    /* get the position                                                    */
    p = INT_INTOBJ(pos);

    /* if we unbind the last position keep the representation              */
    if ( LEN_GF2VEC(list) < p ) {
        ;
    }
    else if ( LEN_GF2VEC(list) == p ) {
        ResizeBag( list, SIZE_PLEN_GF2VEC(p-1) );
        SET_LEN_GF2VEC( list, p-1 );
    }
    else {
        PlainGF2Vec(list);
        UNB_LIST( list, p );
    }
    return 0;
}


/****************************************************************************
**
*F  FuncUNB_GF2MAT( <self>, <list>, <pos> ) . unbind position of a GF2 matrix
**
**  'UNB_GF2VEC' unbind  the element at  the position  <pos> in  a GF2 matrix
**  <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive.
*/
Obj FuncUNB_GF2MAT (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;

    /* check that <list> is mutable                                        */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        ErrorReturnVoid(
            "Lists Assignment: <list> must be a mutable list",
            0L, 0L,
            "you can 'return;' and ignore the assignment" );
        return 0;
    }

    /* get the position                                                    */
    p = INT_INTOBJ(pos);

    /* if we unbind the last position keep the representation              */
    if ( LEN_GF2MAT(list) < p ) {
        ;
    }
    else if ( LEN_GF2VEC(list) == p ) {
        ResizeBag( list, SIZE_PLEN_GF2MAT(p-1) );
        SET_LEN_GF2MAT( list, p-1 );
    }
    else {
        PlainGF2Vec(list);
        UNB_LIST( list, p );
    }
    return 0;
}


/****************************************************************************
**

*F * * * * * * * * * * * * arithmetic operations  * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncZERO_GF2VEC( <self>, <mat> )  . . . . . . . . . . . . zero GF2 vector
**
**  return the zero vector over GF2 of the same length as <mat>.
*/
Obj FuncZERO_GF2VEC (
    Obj                 self,
    Obj                 mat )
{
    Obj                 zero;
    UInt                len;

    /* create a new GF2 vector                                             */
    len = LEN_GF2VEC(mat);
    NEW_GF2VEC( zero, TYPE_LIST_GF2VEC, len );
    SET_LEN_GF2VEC( zero, len );
    return zero;
}

/****************************************************************************
**
*F  FuncZERO_GF2VEC_2( <self>, <len>) . . . . . . . . . zero GF2 vector
**
**  return the zero vector over GF2 of length <len>
*/
Obj FuncZERO_GF2VEC_2 (
    Obj                 self,
    Obj                 len )
{
    Obj                 zero;

    /* create a new GF2 vector                                             */
    NEW_GF2VEC( zero, TYPE_LIST_GF2VEC, INT_INTOBJ(len) );
    SET_LEN_GF2VEC( zero, INT_INTOBJ(len) );
    return zero;
}


/****************************************************************************
**
*F  FuncINV_GF2MAT( <self>, <mat> ) . . . . . . . . . . .  inverse GF2 matrix
**
** This might now be redundant, a library method using
**  INVERSE_PLIST_GF2VECS_DESTRUCTIVE
** might do just as good a job
*/
Obj FuncINV_GF2MAT (
    Obj                 self,
    Obj                 mat )
{
    UInt                len;

    len = LEN_GF2MAT(mat);
    if ( len != 0 ) {
        if ( len != LEN_GF2VEC(ELM_GF2MAT(mat,1)) ) {
            mat = ErrorReturnObj( "<matrix> must be square", 0, 0,
                                  "you can replace <matrix> via 'return <matrix>;'" );
            return FuncINV_GF2MAT(self,mat);
        }
    }
    return InverseGF2Mat(mat);
}

/****************************************************************************
**
*F  FuncINV_PLIST_GF2VECS_DESTRUCTIVE( <self>, <list> ) . . .invert possible GF2 matrix
*/
Obj FuncINV_PLIST_GF2VECS_DESTRUCTIVE( Obj self, Obj list )
{
  UInt len,i;
  Obj row;
  len = LEN_PLIST(list);
  for (i = 1; i <= len; i++)
    {
      row = ELM_PLIST(list,i);
      if (!IS_GF2VEC_REP(row) || LEN_GF2VEC(row) != len)
	return TRY_NEXT_METHOD;
    }
  if ( len == 0 ) {
    return CopyObj(list,1);
  }
  if (len == 1 ) {
    row = ELM_PLIST(list,1);
    if (BLOCKS_GF2VEC(row)[0] & 1)
      {
	return CopyObj(list, 1);
	}
    else
      return Fail;
  }
  return InversePlistGF2VecsDesstructive(list);
  
}


/****************************************************************************
**
*F  FuncSUM_GF2VEC_GF2VEC( <self>, <vl>, <vr> ) . . . . .  sum of GF2 vectors
**
**  'FuncSUM_GF2VEC_GF2VEC' returns the sum  of the two gf2-vectors <vl>  and
**  <vr>.  The sum is a new gf2-vector, where each element is  the sum of the
**  corresponding entries of <vl>  and <vr>.  The  major work is done  in the
**  routine   'AddPartialGF2VecGF2Vec'     which     is         called   from
**  'FuncSUM_GF2VEC_GF2VEC'.
**
**  'FuncSUM_GF2VEC_GF2VEC'  is  an improved  version of 'SumListList', which
**  does not call 'SUM' but uses bit operations instead.
*/
Obj FuncSUM_GF2VEC_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
    Obj                 sum;            /* sum, result                     */
    UInt                len;            /* length of the list              */

    /* get and check the length                                            */
    len = LEN_GF2VEC(vl);
    if ( len != LEN_GF2VEC(vr) ) {
      vr = ErrorReturnObj(
        "Vector +: <right> must have the same length as <left> (%d not %d)",
        len, (Int)LEN_GF2VEC(vr),
        "you can replace GF2 vector <right> via 'return <right>;'" );
      return SUM( vl, vr );
    }

    /* construct the result vector                                         */
    NEW_GF2VEC( sum, (IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr)) ? 
		TYPE_LIST_GF2VEC :TYPE_LIST_GF2VEC_IMM, len );
    SET_LEN_GF2VEC( sum, len );

    /* and add the two argument vectors                                    */
    AddPartialGF2VecGF2Vec ( sum, vl, vr, 1 );
    return sum;
}

/****************************************************************************
**
*F  FuncMULT_ROW_VECTOR_GF2VECS_2( <self>, <vl>, <mul> )
**                                      . . . . .  sum of GF2 vectors
**
*/
Obj FuncMULT_ROW_VECTOR_GF2VECS_2 (
    Obj                 self,
    Obj                 vl,
    Obj                 mul )
{
    UInt                len;            /* length of the list              */
    if (EQ(mul,GF2One))
      return (Obj) 0;
    else if (EQ(mul,GF2Zero))
      {
	AddCoeffsGF2VecGF2Vec(vl,vl);
	return (Obj) 0;
      }
    else
      return TRY_NEXT_METHOD;
}


/****************************************************************************
**
*F  FuncPROD_GF2VEC_GF2VEC( <self>, <vl>, <vr> )  . .  product of GF2 vectors
**
**  'FuncPROD_GF2VEC_GF2VEC' returns the product of  the two GF2 vectors <vl>
**  and <vr>.  The product is either `GF2One' or `GF2Zero'.
*/
Obj FuncPROD_GF2VEC_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
    return ProdGF2VecGF2Vec( vl, vr );
}


/****************************************************************************
**
*F  FuncPROD_GF2VEC_GF2MAT( <self>, <vl>, <vr> ) product of GF2 vector/matrix
**
**  'FuncPROD_GF2VEC_GF2MAT' returns  the product of the GF2 vectors <vl> and
**  the GF2 matrix <vr>.
**
**  The  product is  again a  GF2 vector.  It  is  the  responsibility of the
**  caller to ensure that <vl> is a  GF2 vector, <vr>  a GF2 matrix.
*/
Obj FuncPROD_GF2VEC_GF2MAT (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
    return ProdGF2VecGF2Mat( vl, vr );
}

/****************************************************************************
**
*F  FuncPROD_GF2MAT_GF2MAT( <self>, <ml>, <mr> ) product of GF2 vector/matrix
**
**  'FuncPROD_GF2MAT_GF2MAT' returns  the product of the GF2 matricess <ml> and
**  <mr>.
**
**  The  product is  again a  GF2 matrix.  It  is  the  responsibility of the
**  caller to ensure that <ml> and <mr> are  GF2 matrices
*/
Obj FuncPROD_GF2MAT_GF2MAT (
    Obj                 self,
    Obj                 ml,
    Obj                 mr )
{
    return ProdGF2MatGF2Mat( ml, mr );
}


/****************************************************************************
**
*F  FuncPROD_GF2MAT_GF2VEC( <self>, <vl>, <vr> ) product of GF2 matrix/vector
**
**  'FuncPROD_GF2VEC_GF2MAT' returns  the product of the GF2 matrix  <vl> and
**  the GF2 vector <vr>.
**
**  The  product is  again a  GF2 vector.  It  is  the  responsibility of the
**  caller to ensure that <vr> is a  GF2 vector, <vl>  a GF2 matrix.
*/
Obj FuncPROD_GF2MAT_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
    return ProdGF2MatGF2Vec( vl, vr );
}


/****************************************************************************
**
*F  FuncADDCOEFFS_GF2VEC_GF2VEC_MULT( <self>, <vl>, <vr>, <mul> ) GF2 vectors
*/
Obj FuncADDCOEFFS_GF2VEC_GF2VEC_MULT (
    Obj                 self,
    Obj                 vl,
    Obj                 vr,
    Obj                 mul )
{
    /* do nothing if <mul> is zero                                         */
    if ( EQ(mul,GF2Zero) ) {
        return INTOBJ_INT( RightMostOneGF2Vec(vl) );
    }

    /* add if <mul> is one                                                 */
    if ( EQ(mul,GF2One) ) {
        return AddCoeffsGF2VecGF2Vec( vl, vr );
    }

    /* try next method                                                     */
    return TRY_NEXT_METHOD;
}

/****************************************************************************
**
*F  FuncADDCOEFFS_GF2VEC_GF2VEC_MULT( <self>, <vl>, <vr>, <mul>, <from>, <to> )
**  GF2 vectors
*/
Obj FuncADDCOEFFS_GF2VEC_GF2VEC_MULT_LIMS (
    Obj                 self,
    Obj                 vl,
    Obj                 vr,
    Obj                 mul )
{
    /* do nothing if <mul> is zero                                         */
    if ( EQ(mul,GF2Zero) ) {
        return INTOBJ_INT( RightMostOneGF2Vec(vl) );
    }

    /* add if <mul> is one                                                 */
    if ( EQ(mul,GF2One) ) {
        return AddCoeffsGF2VecGF2Vec( vl, vr );
    }

    /* try next method                                                     */
    return TRY_NEXT_METHOD;
}


/****************************************************************************
**
*F  FuncADDCOEFFS_GF2VEC_GF2VEC( <self>, <vl>, <vr> ) . . . . . . GF2 vectors
*/
Obj FuncADDCOEFFS_GF2VEC_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
    return AddCoeffsGF2VecGF2Vec( vl, vr );
}


/****************************************************************************
**
*F  FuncSHRINKCOEFFS_GF2VEC( <self>, <vec> )  . . . . . remove trailing zeros
*/
Obj FuncSHRINKCOEFFS_GF2VEC (
    Obj                 self,
    Obj                 vec )
{
    UInt                len;
    UInt                nbb;
    UInt                onbb;
    UInt *              ptr;
    UInt		off;

    /* get length and number of blocks                                     */
    len = LEN_GF2VEC(vec);
    if ( len == 0 ) {
        return INTOBJ_INT(0);
    }

    nbb = ( len + BIPEB - 1 ) / BIPEB;
    onbb = nbb; 
    ptr = BLOCKS_GF2VEC(vec) + (nbb-1);
    
    /* number of insignificant bit positions in last word */
    off = BIPEB - ((len-1)%BIPEB+1); 
    
    /* mask out the last bits */
#ifdef SYS_IS_64_BIT
    *ptr &= 0xffffffffffffffff >> off;
#else
    *ptr &= 0xffffffff >> off;
#endif

    /* find last non-trivial block */
    while ( 0 < nbb && ! *ptr ) {
        nbb--;
        ptr--;
    }
    /* did the block number change? */
    if (nbb < onbb) {
      len = nbb * BIPEB;
    }

    /* find position inside this block                   */
    /* we are guaranteed not to cross a block boundary ! */
    while ( 0 < len && ! ( *ptr & MASK_POS_GF2VEC(len) ) ) {
        len--;
    }
    ResizeBag( vec, SIZE_PLEN_GF2VEC(len) );
    SET_LEN_GF2VEC( vec, len );
    return INTOBJ_INT(len);
}

/****************************************************************************
**
*F  FuncPOSITION_NONZERO_GF2VEC( <self>, <vec>, <zero>) ..find first non-zero
**
**  The pointless zero argument is because this is a method for PositionNot
**  It is *not* used in the code and can be replaced by a dummy argument.
*/
Obj FuncPOSITION_NONZERO_GF2VEC(
    Obj                 self,
    Obj                 vec,
    Obj                 zero)
{
    UInt                len;
    UInt                nbb;
    UInt                nb;
    UInt *              ptr;
    UInt                pos;

    /* get length and number of blocks                                     */
    len = LEN_GF2VEC(vec);
    if ( len == 0 ) {
      return INTOBJ_INT(len+1);
    }

    /* find first non-trivial block                                         */
    nbb = 0;
    ptr = BLOCKS_GF2VEC(vec);
    nb = NUMBER_BLOCKS_GF2VEC(vec);
    while ( nbb < nb && ! *ptr ) {
        nbb++;
        ptr++;
    }

    /* find position inside this block                                     */
    pos = nbb * BIPEB + 1;
    while ( pos <= len && ! ( *ptr & MASK_POS_GF2VEC(pos) ) ) {
        pos++;
    }
    /* as the code is intended to run over, trailing 1's are innocent */
    if (pos <= len)
      return INTOBJ_INT(pos);
    else
      return INTOBJ_INT(len+1);
}


/****************************************************************************
**
*F  FuncAPPEND_VECGF2( <self>, <vecl>, <vecr> )
**
*/

Obj FuncAPPEND_VECGF2( Obj self, Obj vecl, Obj vecr )
{
  UInt lenl, lenr;
  UInt *ptrl;
  UInt *ptrr;
  UInt offl, nextr,off2;		/* 0 based */

  lenl = LEN_GF2VEC(vecl);
  lenr = LEN_GF2VEC(vecr);
  if (True == DoFilter(IsLockedRepresentationVector, vecl) && lenr > 0)
    {
      ErrorReturnVoid("Append to locked compressed vector is forbidden", 0, 0,
		      "You can `return;' to ignore the operation");
      return 0;
    }
  ResizeBag(vecl, SIZE_PLEN_GF2VEC(lenl+lenr));
  ptrl = BLOCKS_GF2VEC(vecl) + (lenl-1)/BIPEB;
  ptrr = BLOCKS_GF2VEC(vecr);
  offl = (lenl-1) % BIPEB + 1; /* number of significant bits in the last word */
  off2 = BIPEB - offl;         /* number of insignificant bits in the last word */
  nextr = 0;

  /* mask out the last bits */
#ifdef SYS_IS_64_BIT
  *ptrl &= 0xffffffffffffffff >> off2;
#else
  *ptrl &= 0xffffffff >> off2;
#endif

  if (offl == BIPEB)
    {
      while (nextr < lenr)
	{
	  *++ptrl = *ptrr++;
	  nextr += BIPEB;
	}
    }
  else
    while (nextr < lenr)
      {
	*ptrl |= (*ptrr) << offl;
	ptrl++;
	nextr += off2;
	if (nextr >= lenr -1)
	  break;
	*ptrl = (*ptrr) >> off2;
	ptrr++;
	nextr += offl;
      }
  
  SET_LEN_GF2VEC(vecl,lenl+lenr);
  return (Obj) 0;
}


/****************************************************************************
**
*F  FuncSHALLOWCOPY_VECGF2( <self>, <vec> )
**
*/

Obj FuncSHALLOWCOPY_VECGF2( Obj self, Obj vec)
{
  return ShallowCopyVecGF2(vec);
}

/****************************************************************************
**
*F  FuncSUM_GF2MAT_GF2MAT( <self>, <matl>, <matr> )
**
*/


Obj FuncSUM_GF2MAT_GF2MAT( Obj self, Obj matl, Obj matr)
{
  UInt ll,lr, wl,wr;
  Obj sum;
  Obj vr, sv;
  UInt i;
  ll = LEN_GF2MAT(matl);
  lr = LEN_GF2MAT(matr);
  if (ll != lr)
    ErrorQuit("Matrix +: <right> must have the same length as <left>", 0L, 0L);
  wl = LEN_GF2VEC(ELM_GF2MAT(matl, 1));
  wr = LEN_GF2VEC(ELM_GF2MAT(matr, 1));
  if (wl != wr)
    ErrorQuit("Matrix +: <left> and <right> must have the same number of columns", 0L, 0L);
  sum = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT( ll ));
  TYPE_POSOBJ(sum) = (IS_MUTABLE_OBJ(matl) || IS_MUTABLE_OBJ(matr)) ?
    TYPE_LIST_GF2MAT : TYPE_LIST_GF2MAT_IMM;
  SET_LEN_GF2MAT(sum, ll);
  for (i = 1; i <= ll; i++)
    {
      sv = ShallowCopyVecGF2( ELM_GF2MAT( matl, i));
      vr = ELM_GF2MAT( matr, i);
      AddGF2VecToGF2Vec(BLOCKS_GF2VEC(sv), BLOCKS_GF2VEC(vr), wl);
      TYPE_DATOBJ(sv) = TYPE_LIST_GF2VEC_IMM_LOCKED;
      SET_ELM_GF2MAT( sum, i, sv);
      CHANGED_BAG(sum);
    }
  return sum;
}


/****************************************************************************
**
*F  FuncNUMBER_VECGF2( <self>, <vect> )
**
*/



Obj FuncNUMBER_VECGF2( Obj self, Obj vec )
{
  UInt len,nd,i,nonz;
  UInt head,a;
  UInt off,off2;		/* 0 based */
  Obj zahl;  /* the long number */
  UInt *num;
  UInt *vp;
  len = LEN_GF2VEC(vec);
  num = BLOCKS_GF2VEC(vec) + (len-1)/BIPEB;
  off = (len -1) % BIPEB + 1; /* number of significant bits in last word */
  off2 = BIPEB - off;         /* number of insignificant bits in last word */

  /* mask out the last bits */
#ifdef SYS_IS_64_BIT
  *num &= 0xffffffffffffffff >> off2;
#else
  *num &= 0xffffffff >> off2;
#endif

  if (len <=NR_SMALL_INT_BITS) 
    /* it still fits into a small integer */
    return INTOBJ_INT(revertbits(*num,len));
  else {
    /* we might have to build a long integer */

    /* the number of words we need. A word is two digits */
    nd = ((len-1)/NR_DIGIT_BITS/2)+1;

    zahl = NewBag( T_INTPOS, (((nd+1)>>1)<<1)*sizeof(UInt) );
    /* +1)>>1)<<1: round up to next even number*/

    /* garbage collection might lose pointer */
    num = BLOCKS_GF2VEC(vec) + (len-1)/BIPEB;

    vp = (UInt *)ADDR_OBJ(zahl); /* the place we write to */
    nonz=0; /* last non-zero position */ 
    i=1;

    if (off!=BIPEB) {
      head = revertbits(*num,off); /* the last 'off' bits, reverted */
      while (i<nd) {
	/* next word */
	num--;
	*vp = head; /* the bits left from last word */
	a = revertbits(*num,BIPEB); /* the full word reverted */
	head = a>>off2; /* next head: trailing `off' bits */
	a =a << off; /* the rest of the word */
	*vp |=a;
#ifdef WORDS_BIGENDIAN
	*vp = (*vp >> NR_DIGIT_BITS) | (*vp << NR_DIGIT_BITS);
#endif
	if (*vp != 0) {nonz=i;} 
	vp++;
	i++;
      }
      *vp = head; /* last head bits */
#ifdef WORDS_BIGENDIAN
      *vp = (*vp >> NR_DIGIT_BITS) | (*vp << NR_DIGIT_BITS);
#endif
      vp++;
      if (head !=0) {
	nonz=i; 
      }
    }
    else {
      while (i<=nd) {
        *vp=revertbits(*num--,BIPEB);
	if (*vp != 0) {nonz=i;} 
#ifdef WORDS_BIGENDIAN
      *vp = (*vp >> NR_DIGIT_BITS) | (*vp << NR_DIGIT_BITS);
#endif
	vp++;
	i++;
      }
    }


    i=nd%2; 
    if (i==1) { 
      *vp=0; /* erase the trailing two digits if existing */
      nd++; /* point to the last position */
    }

    if ((nonz<=1)) {
      /* there were only entries in the first word. Can we make it a small
       * int? */
      num = (UInt*)ADDR_OBJ(zahl);
      head = *num;
#ifdef WORDS_BIGENDIAN
      head = (head >> NR_DIGIT_BITS) | (head << NR_DIGIT_BITS);
#endif
      if (0==(head & (((UInt)15L)<<NR_SMALL_INT_BITS))) {
	return INTOBJ_INT(head);
      }
    }

    /* if there are mult. of 2 words of zero entries we have to remove them */
    if ((nd>2) && ((nd-1)>nonz)) {
      /* get the length */
      while ((nd>2) && ((nd-1)>nonz)) {
	nd -= 2;
      } 
      ResizeBag(zahl,nd*sizeof(UInt)); 

    }

    return zahl;
  }

}


/****************************************************************************
**
*F  FuncLT_GF2VEC_GF2VEC( <self>, <vl>, <vr> )   compare GF2 vectors
*/
Obj FuncLT_GF2VEC_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
  return (Cmp_GF2VEC_GF2VEC(vl,vr) < 0) ? True : False;
}

/****************************************************************************
**
*F  Cmp_GF2MAT_GF2MAT( <ml>, <mr> )   compare GF2 matrices
*/

Int Cmp_GF2MAT_GF2MAT( Obj ml, Obj mr)
{
  UInt l1, l2,l, i;
  Int c;
  l1 = INT_INTOBJ(ELM_PLIST(ml,1));
  l2 = INT_INTOBJ(ELM_PLIST(mr,1));
  l = (l1 < l2) ? l1 : l2;
  for (i = 2; i <= l+1; i++)
    {
      c = Cmp_GF2VEC_GF2VEC(ELM_PLIST(ml,i), ELM_PLIST(mr,i));
      if (c != 0)
	return c;
    }
  if (l1 < l2)
    return -1;
  if (l1 > l2)
    return 1;
  return 0;
  
}

/****************************************************************************
**
*F  FuncEQ_GF2MAT_GF2MAT( <ml>, <mr> )   compare GF2 matrices
*/

Obj FuncEQ_GF2MAT_GF2MAT( Obj self, Obj ml, Obj mr)
{
  if (ELM_PLIST(ml,1) != ELM_PLIST(mr,1))
    return False;
  return (0 == Cmp_GF2MAT_GF2MAT(ml,mr)) ? True : False;
}

/****************************************************************************
**
*F  FuncLT_GF2MAT_GF2MAT( <ml>, <mr> )   compare GF2 matrices
*/

Obj FuncLT_GF2MAT_GF2MAT( Obj self, Obj ml, Obj mr)
{
  return (Cmp_GF2MAT_GF2MAT(ml,mr) < 0) ? True : False;
}

/****************************************************************************
**
*F  DistGF2Vecs( <ptL>, <ptR>, <len> )
**
**  computes the GF2-vector distance of two blocks in memory, pointed to by
**  ptL and ptR for a GF(2) vector of <len> entries.
**  
*/
UInt DistGF2Vecs(UInt* ptL,UInt* ptR,UInt len)
{
  UInt 			sum,m;
  UInt *                end;            /* end marker                      */

  /*T this  function will not work if the vectors have more than 2^28
   * entries */

  end = ptL + ((len+BIPEB-1)/BIPEB);
  sum=0;
  /* loop over the entries */
  while ( ptL < end ) {
    m = *ptL++ ^ *ptR++; /* xor of bits, nr bits therein is difference */
    COUNT_TRUES_BLOCK(m);
    sum += m;
  }
  return sum;
}

/****************************************************************************
**
*F  FuncDIST_GF2VEC_GF2VEC( <self>, <vl>, <vr> )
**
**  'FuncDIST_GF2VEC_GF2VEC' returns the number of position in which two
**  gf2-vectors <vl>  and  <vr> differ.                            
*/
Obj FuncDIST_GF2VEC_GF2VEC (
    Obj                 self,
    Obj                 vl,
    Obj                 vr )
{
  UInt                  len;            /* length of the list              */
  UInt                  off;            /* bit offset at the end to clean out */
  UInt *                ptL;            /* bit field of <vl>               */
  UInt *                ptR;            /* bit field of <vr>               */
  UInt *                end;            /* pointer used to zero out end bit */
  /* get and check the length                                            */
  len = LEN_GF2VEC(vl);

  if ( len != LEN_GF2VEC(vr) ) {
    ErrorQuit(
      "DIST_GF2VEC_GF2VEC: vectors must have the same length",0L,0L);
    return 0;
  }

  /* calculate the offsets */
  ptL = BLOCKS_GF2VEC(vl);
  ptR = BLOCKS_GF2VEC(vr);

/* mask out the last bits */
  off = (len -1) % BIPEB + 1; /* number of significant bits in last word */
  off = BIPEB - off;          /* number of insignificant bits in last word */
  end = ptL + ((len-1)/BIPEB);
#ifdef SYS_IS_64_BIT
  *end &= 0xffffffffffffffff >> off;
#else
  *end &= 0xffffffff >> off;
#endif
  end = ptR + ((len-1)/BIPEB);
#ifdef SYS_IS_64_BIT
  *end &= 0xffffffffffffffff >> off;
#else
  *end &= 0xffffffff >> off;
#endif

  return INTOBJ_INT(DistGF2Vecs(ptL,ptR,len));
}


void DistVecClosVec(
  Obj		veclis, /* pointers to matrix vectors and their multiples */
  Obj 	        ovec,    /* vector we compute distance to */
  Obj		d,	/* distances list */
  Obj  	        osum,	/* position of the sum vector */
  UInt		pos,	/* recursion depth */
  UInt		l,	/* length of basis */
  UInt		len )	/* length of the involved vectors */
{
  UInt 		i;
  UInt		di;
  Obj		cnt;
  Obj		vp;
  UInt *        vec;
  UInt *        sum;
  Obj           one;
  Obj           tmp;

  vec = BLOCKS_GF2VEC(ovec);
  sum = BLOCKS_GF2VEC(osum);
  vp = ELM_PLIST(veclis,pos);
  one = INTOBJ_INT(1);
  
  for (i=0;i<=1;i++) {
    if (pos < l)
      {
	DistVecClosVec(veclis,ovec,d,osum,pos+1,l,len);
      }
    else
      {
	di=DistGF2Vecs(sum,vec,len);

	cnt=ELM_PLIST(d,di+1);
	if (IS_INTOBJ(cnt) && SUM_INTOBJS(tmp, cnt, one))
	  {
	    cnt = tmp;
	    SET_ELM_PLIST(d,di+1,cnt);
	  }
	else
	  {
	    cnt=SumInt(cnt,one);
	    vec = BLOCKS_GF2VEC(ovec);
	    sum = BLOCKS_GF2VEC(osum);
	    SET_ELM_PLIST(d,di+1,cnt);
	    CHANGED_BAG(d);
	  }
      }
    AddGF2VecToGF2Vec(sum,BLOCKS_GF2VEC(ELM_PLIST(vp,i+1)),len);
  }
}

Obj FuncDistVecClosVec(
  Obj		self,
  Obj		veclis, /* pointers to matrix vectors and their multiples */
  Obj		vec,    /* vector we compute distance to */
  Obj		d )	/* distances list */

{
  Obj		sum; /* sum vector */
  UInt 		len;

  len = LEN_GF2VEC(vec);

  /* get space for sum vector */
  NEW_GF2VEC( sum, TYPE_LIST_GF2VEC, len );
  SET_LEN_GF2VEC( sum, len );

  /* do the recursive work */
  DistVecClosVec(veclis,vec,d,sum,1,LEN_PLIST(veclis),len);

  return (Obj) 0;
}

UInt AClosVec(
  Obj		veclis, /* pointers to matrix vectors and their multiples */
  Obj 	        ovec,    /* vector we compute distance to */
  Obj  	        osum,	/* position of the sum vector */
  UInt		pos,	/* recursion depth */
  UInt		l,	/* length of basis */
  UInt		len,	/* length of the involved vectors */
  UInt		cnt,	/* numbr of vectors used */
  UInt		stop,	/* stop value */
  UInt		bd,	/* best distance so far */
  Obj		obv)	/* best vector so far */
{
  UInt 		i;
  UInt		di;
  Obj		vp;
  UInt *        vec;
  UInt *        sum;
  UInt *        bv;
  UInt *        end;
  UInt *w;
  Obj           tmp;


  /* maybe we don't add this basis vector -- if this leaves us enough possibilitiies */
  if ( pos+cnt<l ) {
      bd = AClosVec(veclis,ovec,osum,pos+1,l,len,cnt,stop,bd,obv);
      if (bd<=stop) {
        return bd;
      }
  }


  /* Otherwise we do */
  
  vec = BLOCKS_GF2VEC(ovec);
  sum = BLOCKS_GF2VEC(osum);
  vp = ELM_PLIST(veclis,pos);
  w = BLOCKS_GF2VEC(ELM_PLIST(vp,1));
  AddGF2VecToGF2Vec(sum,w,len);

  
  if (cnt == 0) /* this is a candidate */
    {
      di=DistGF2Vecs(sum,vec,len);
      if (di<bd) {
	
	/* store new result */
	bd=di;
	bv = BLOCKS_GF2VEC(obv);
	end = bv+((len+BIPEB-1)/BIPEB);
	while (bv<=end) 
	  *bv++=*sum++;
	sum = BLOCKS_GF2VEC(osum);
      }
    }
  else /* need to add in some more */
    {
      bd=AClosVec(veclis,ovec,osum,pos+1,l,len,cnt-1,stop,bd,obv);
      if (bd<=stop) {
	return bd;
      }
    }
    
  /* reset component  */
  AddGF2VecToGF2Vec(sum,w,len);

  return bd;
}

Obj FuncAClosVec(
  Obj		self,
  Obj		veclis, /* pointers to matrix vectors and their multiples */
  Obj		vec,    /* vector we compute distance to */
  Obj		cnt,	/* distances list */
  Obj		stop)	/* distances list */

{
  Obj		sum; /* sum vector */
  Obj		best; /* best vector */
  UInt 		len;

  len = LEN_GF2VEC(vec);

  /* get space for sum vector and zero out */
  NEW_GF2VEC( sum, TYPE_LIST_GF2VEC, len );
  SET_LEN_GF2VEC( sum, len );

  NEW_GF2VEC( best, TYPE_LIST_GF2VEC, len );
  SET_LEN_GF2VEC( best, len );


  /* do the recursive work */
  AClosVec(veclis,vec,sum,1, LEN_PLIST(veclis),len,
    INT_INTOBJ(cnt),INT_INTOBJ(stop),len+1, /* maximal value +1 */
    best);

  return best;
}

/****************************************************************************
**
*F FuncCOSET_LEADERS_INNER_GF2( <self>, <veclis>, <weight>, <tofind>, <leaders> )
**
** Search for new coset leaders of weight <weight>
*/

UInt CosetLeadersInnerGF2( Obj veclis,
			   Obj v,
			   Obj w,
			   UInt weight,
			   UInt pos,
			   Obj leaders,
			   UInt tofind )
{
  UInt found = 0;
  UInt len = LEN_GF2VEC(v);
  UInt lenw = LEN_GF2VEC(w);
  UInt sy;
  UInt u0;
  Obj vc;
  UInt i,j;
    
  /* we know that the length of w does not exceed BIPEB -4 here
     (or there would not be room in a PLIST for all the coset leaders)
    we use this to do a lot of GF2 vector operations for w "in-place"

    Even more in this direction could be done, but this no longer
  the rate-determining step for any feasible application*/
  
  if (weight == 1)
    {
      for (i = pos; i <= len; i++)
	{
	  u0 = BLOCKS_GF2VEC(ELM_PLIST(ELM_PLIST(veclis, i),1))[0];
	  BLOCKS_GF2VEC(w)[0] ^= u0;
	  BLOCK_ELM_GF2VEC(v, i) |= MASK_POS_GF2VEC(i);

	  sy = revertbits(BLOCKS_GF2VEC(w)[0], lenw);
	  if ((Obj) 0 == ELM_PLIST(leaders,sy+1))
	    {
	      NEW_GF2VEC(vc, TYPE_LIST_GF2VEC_IMM, len);
	      SET_LEN_GF2VEC(vc, len);
	      for (j = 0; j < NUMBER_BLOCKS_GF2VEC(v); j++)
		BLOCKS_GF2VEC(vc)[j] = BLOCKS_GF2VEC(v)[j];
	      SET_ELM_PLIST(leaders,sy+1,vc);
	      CHANGED_BAG(leaders);
	      if (++found == tofind)
		return found;
	    }
	  BLOCKS_GF2VEC(w)[0] ^= u0;
	  BLOCK_ELM_GF2VEC(v, i) &= ~MASK_POS_GF2VEC(i);
	}
    }
  else
    {
      if (pos + weight <= len)
	{
	  found += CosetLeadersInnerGF2(veclis, v, w, weight, pos+1, leaders, tofind);
	  if (found == tofind)
	    return found;
	}
      u0 = BLOCKS_GF2VEC(ELM_PLIST(ELM_PLIST(veclis, pos),1))[0];
      BLOCKS_GF2VEC(w)[0] ^= u0;
      BLOCK_ELM_GF2VEC(v, pos) |= MASK_POS_GF2VEC(pos);
      found += CosetLeadersInnerGF2(veclis, v, w, weight -1, pos + 1, leaders, tofind - found);
      if (found == tofind)
	return found;
      BLOCKS_GF2VEC(w)[0] ^= u0;
      BLOCK_ELM_GF2VEC(v, pos) &= ~MASK_POS_GF2VEC(pos);
    }
  return found;
}




Obj FuncCOSET_LEADERS_INNER_GF2( Obj self, Obj veclis, Obj weight, Obj tofind, Obj leaders)
{
  Obj v,w;
  UInt lenv, lenw;
  lenv = LEN_PLIST(veclis);
  NEW_GF2VEC(v, TYPE_LIST_GF2VEC, lenv);
  SET_LEN_GF2VEC(v, lenv);
  lenw = LEN_GF2VEC(ELM_PLIST(ELM_PLIST(veclis,1),1));
  NEW_GF2VEC(w, TYPE_LIST_GF2VEC,lenw );
  SET_LEN_GF2VEC(w,lenw);
  if (lenw > BIPEB-4)
    ErrorQuit("COSET_LEADERS_INNER_GF2: too many cosets to return the leaders in a plain list",0,0);
  return INTOBJ_INT(CosetLeadersInnerGF2( veclis, v, w, INT_INTOBJ(weight), 1, leaders, INT_INTOBJ(tofind)));
}

/****************************************************************************
**
*F  Polynomial Arithmetic Support
*/


/****************************************************************************
**
*F  FuncRIGHTMOST_NONZERO_GF2VEC (<self>, <vec> )
**
*/

Obj FuncRIGHTMOST_NONZERO_GF2VEC( Obj self, Obj vec )
{
  return INTOBJ_INT(RightMostOneGF2Vec(vec));
}

/****************************************************************************
**
*F  ResizeGF2Vec( <vec>, <newlen>, <clean> )
**
*/

void ResizeGF2Vec( Obj vec, UInt newlen )
{
  UInt len;
  UInt *ptr;
  UInt *nptr;
  UInt off;
  len = LEN_GF2VEC(vec);
  if (len == newlen)
    return;
  if (True == DoFilter(IsLockedRepresentationVector, vec))
    {
      ErrorReturnVoid("Resize of locked compressed vector is forbidden", 0, 0,
		      "You can `return;' to ignore the operation");
      return;
    }

  
  if (newlen == 0)
    {
      RetypeBag(vec, T_PLIST_EMPTY);
      SET_LEN_PLIST(vec, 0);
      SHRINK_PLIST(vec, 0);
      return;
    }
  if (newlen > len)
    {
      ResizeBag(vec,SIZE_PLEN_GF2VEC(newlen));

      /* now clean remainder of last block */
      if (len == 0)
	ptr = BLOCKS_GF2VEC(vec);
      else
	{
	  ptr = BLOCKS_GF2VEC(vec) + (len -1)/BIPEB;
	  off = BIPEB - ((len -1)% BIPEB + 1); /* number of insignificant bits in last word */
#ifdef SYS_IS_64_BIT
	  *ptr &= 0xffffffffffffffff >> off;
#else
	  *ptr &= 0xffffffff >> off;
#endif
	  ptr++;
	}
      
      /* and clean new blocks -- shouldn't need to do this, but
	 it's very cheap */
      nptr = BLOCKS_GF2VEC(vec) + (newlen -1)/BIPEB;
      while (ptr <= nptr)
	*ptr++ = 0;
      SET_LEN_GF2VEC(vec, newlen);
      return;
    }
  else
    {
      /* clean remainder of new last block */
      ptr = BLOCKS_GF2VEC(vec) + (newlen -1)/BIPEB;
      off = BIPEB - ((newlen-1) % BIPEB + 1);
#ifdef SYS_IS_64_BIT
      *ptr &= 0xffffffffffffffff >> off;
#else
      *ptr &= 0xffffffff >> off;
#endif
      SET_LEN_GF2VEC(vec, newlen);
      ResizeBag(vec, SIZE_PLEN_GF2VEC(newlen));
      return;
    }
}

/****************************************************************************
**
*F  FuncRESIZE_GF2VEC( <self>, <vec>, <newlen> )
**
*/

Obj FuncRESIZE_GF2VEC( Obj self, Obj vec, Obj newlen)
{
  Int newlen1;
  if (!IS_MUTABLE_OBJ(vec))
    {
      ErrorReturnVoid("RESIZE_GF2VEC: the vector must be mutable", 0, 0,
		      "you may 'return;' to skip the operation");
      return (Obj)0;
    }
  newlen1 = INT_INTOBJ(newlen);
  while (newlen1 < 0)
    {
      newlen = ErrorReturnObj("RESIZE_GF2VEC: the new size must be a non-negative integer, not %d", newlen1, 0,
			      "you may replace the new size <ns> via 'return <ns>;'");
      newlen1 = INT_INTOBJ(newlen);
    }
  ResizeGF2Vec(vec, newlen1);
  return (Obj)0;
}


/****************************************************************************
**
*F  ShiftLeftGF2Vec( <vec>, <amount> )
**
*/

void ShiftLeftGF2Vec( Obj vec, UInt amount )
{
  UInt len;
  UInt *ptr1, *ptr2;
  UInt i;
  UInt block;
  UInt off;
  if (amount == 0)
    return;
  len = LEN_GF2VEC(vec);
  if (amount >= len)
    {
      ResizeGF2Vec(vec, 0);
      return;
    }
  if (amount % BIPEB == 0)
    {
      ptr1 = BLOCKS_GF2VEC(vec);
      ptr2 = ptr1 + amount/BIPEB;
      for (i = 0; i < (len - amount + BIPEB - 1)/BIPEB; i++)
	*ptr1++ = *ptr2++;
    }
  else
    {
      ptr1 = BLOCKS_GF2VEC(vec);
      ptr2 = ptr1 + amount/BIPEB;
      off = amount % BIPEB;
      for (i = 0; i < (len - amount + BIPEB - 1)/BIPEB; i++)
	{
	  block = (*ptr2++) >> off;
	  block |= (*ptr2) << (BIPEB - off);
	  *ptr1++ = block;
	}
    }
  ResizeGF2Vec(vec, len-amount);
  return;
}

/****************************************************************************
**
*F  FuncSHIFT_LEFT_GF2VEC(<self>, <vec>, <amount> )
**
*/

Obj FuncSHIFT_LEFT_GF2VEC( Obj self, Obj vec, Obj amount)
{
  Int amount1;
  if (!IS_MUTABLE_OBJ(vec))
    {
      ErrorReturnVoid("SHIFT_LEFT_GF2VEC: the vector must be mutable", 0, 0,
		      "you may 'return;' to skip the operation");
      return (Obj)0;
    }
  amount1 = INT_INTOBJ(amount);
  while (amount1 < 0)
    {
      amount = ErrorReturnObj("SHIFT_LEFT_GF2VEC: <amount> must be a non-negative integer, not %d", amount1, 0,
			      "you may replace <amount> via 'return <amount>;'");
      amount1 = INT_INTOBJ(amount);
    }
  ShiftLeftGF2Vec(vec, amount1);
  return (Obj)0;
}

/****************************************************************************
**
*F  ShiftRightGF2Vec( <vec>, <amount> )
**
*/

void ShiftRightGF2Vec( Obj vec, UInt amount )
{
  UInt len;
  UInt *ptr1, *ptr2, *ptr0;
  UInt i;
  UInt block;
  UInt off;
  if (amount == 0)
    return;
  len = LEN_GF2VEC(vec);
  ResizeGF2Vec(vec, len+amount);
  if (amount % BIPEB == 0)
    {
      /* move the blocks */
      ptr1 = BLOCKS_GF2VEC(vec) + (len - 1 + amount)/BIPEB;
      ptr2 = ptr1 - amount/BIPEB;
      for (i = 0; i < (len + BIPEB - 1)/BIPEB; i++)
	*ptr1-- = *ptr2--;

      /* and fill with zeroes */
      ptr2 = BLOCKS_GF2VEC(vec);
      while (ptr1 >= ptr2)
	*ptr1-- = 0;
    }
  else
    {
      ptr1 = BLOCKS_GF2VEC(vec) + (len -1 + amount)/BIPEB;
      ptr2 = ptr1 - amount/BIPEB; /* this can sometimes be the block AFTER the old last block,
				     but this must be OK */
      off = amount % BIPEB;
      ptr0 = BLOCKS_GF2VEC(vec);
      while (1)
	{
	  block = (*ptr2--) << off;
	  if (ptr2 < ptr0)
	    break;
	  block |= (*ptr2) >> (BIPEB - off);
	  *ptr1-- = block;
	}
      *ptr1-- = block;
      while (ptr1 >= ptr0)
	*ptr1-- = 0;
    }
  return;
}

/****************************************************************************
**
*F  FuncSHIFT_RIGHT_GF2VEC(<self>, <vec>, <amount> )
**
*/

Obj FuncSHIFT_RIGHT_GF2VEC( Obj self, Obj vec, Obj amount)
{
  Int amount1;
  if (!IS_MUTABLE_OBJ(vec))
    {
      ErrorReturnVoid("SHIFT_RIGHT_GF2VEC: the vector must be mutable", 0, 0,
		      "you may 'return;' to skip the operation");
      return (Obj)0;
    }
  amount1 = INT_INTOBJ(amount);
  while (amount1 < 0)
    {
      amount = ErrorReturnObj("SHIFT_RIGHT_GF2VEC: <amount> must be a non-negative integer, not %d", amount1, 0,
			      "you may replace <amount> via 'return <amount>;'");
      amount1 = INT_INTOBJ(amount);
    }
  ShiftRightGF2Vec(vec, amount1);
  return (Obj)0;
}

/* ReduceCoeffs */

/****************************************************************************
**
*F  AddShiftedVecGF2VecGF2( <vec1>, <vec2>, <len2>, <off> )
**
*/

void AddShiftedVecGF2VecGF2( Obj vec1, Obj vec2, UInt len2, UInt off )
{
  UInt *ptr1, *ptr2;
  UInt i;
  UInt block;
  UInt shift1, shift2;
  if (off % BIPEB == 0)
    {
      ptr1 = BLOCKS_GF2VEC(vec1) + off/BIPEB;
      ptr2 = BLOCKS_GF2VEC(vec2);
      for (i = 0; i < (len2 - 1)/BIPEB; i++)
	*ptr1++ ^= *ptr2++;
      block = *ptr2;
#ifdef SYS_IS_64_BIT
      block &= (0xFFFFFFFFFFFFFFFF >> (BIPEB - (len2-1) % BIPEB -1));
#else
      block &= (0xFFFFFFFF >> (BIPEB - (len2-1) % BIPEB-1));
#endif
      *ptr1 ^= block;
    }
  else
    {
      ptr1 = BLOCKS_GF2VEC(vec1) + off/BIPEB;
      ptr2 = BLOCKS_GF2VEC(vec2);
      shift1 = off %BIPEB;
      shift2 = BIPEB - off%BIPEB;
      for (i = 0; i < len2/BIPEB; i++)
	{
	  *ptr1++ ^= *ptr2 << shift1;
	  *ptr1   ^= *ptr2++ >> shift2;
	}

      if (len2 % BIPEB)
	{
	  block = *ptr2;
#ifdef SYS_IS_64_BIT
	  block &= 0xFFFFFFFFFFFFFFFF >> (BIPEB - (len2-1) % BIPEB-1);
#else
	  block &= 0xFFFFFFFF >> (BIPEB - (len2-1) % BIPEB-1);
#endif
	  *ptr1++ ^= block << shift1;
	  if (len2 % BIPEB + off % BIPEB > BIPEB)
	    {
	      assert(ptr1 < BLOCKS_GF2VEC(vec1) + (LEN_GF2VEC(vec1) + BIPEB -1)/BIPEB);
	      *ptr1 ^= block >> shift2;
	    }
	}
    }
}

/****************************************************************************
**
*F FuncADD_GF2VEC_GF2VEC_SHIFTED( <self>, <vec1>, <vec2>, <len2>, <off> )
**
*/

Obj FuncADD_GF2VEC_GF2VEC_SHIFTED( Obj self, Obj vec1, Obj vec2, Obj len2, Obj off)
{
  Int off1, len2a;
  off1 = INT_INTOBJ(off);
  while (off1 < 0)
    {
      off = ErrorReturnObj("ADD_GF2VEC_GF2VEC_SHIFTED: <offset> must be a non-negative integer",
			   0,0,
                           "you can replace <offset> via 'return <offset>;'");
      off1 = INT_INTOBJ(off);
    }
  len2a = INT_INTOBJ(len2);
  while (len2a < 0 && len2a <= LEN_GF2VEC(vec2)) 
    {
      len2 = ErrorReturnObj("ADD_GF2VEC_GF2VEC_SHIFTED: <len2> must be a non-negative integer\nand less than the actual length of the vector",
			   0,0,"you can replace <len2> via 'return <len2>;'");
      len2a = INT_INTOBJ(len2);
    }
  if (len2a + off1 > LEN_GF2VEC(vec1))
    ResizeGF2Vec(vec1, len2a+ off1);
  AddShiftedVecGF2VecGF2( vec1, vec2, len2a, off1);
  return (Obj) 0;
}

/****************************************************************************
**
*F  ProductCoeffsGF2Vec( <vec1>, <len1>, <vec2>, <len2> )
**
*/

Obj ProductCoeffsGF2Vec( Obj vec1, UInt len1, Obj vec2, UInt len2)
{
  Obj prod;
  UInt i,e;
  UInt *ptr;
  UInt block;
  NEW_GF2VEC(prod, TYPE_LIST_GF2VEC, len1 + len2 -1);
  SET_LEN_GF2VEC(prod, len1+len2 -1);

  /* better to do the longer loop on the inside */
  if (len2 < len1)
    {
      UInt tmp;
      Obj tmpv;
      tmp = len1;
      len1 = len2;
      len2 = tmp;
      tmpv = vec1;
      vec1 = vec2;
      vec2 = tmpv;
    }

  ptr = BLOCKS_GF2VEC(vec1);
  e = BIPEB;
  for (i = 0; i < len1; i++)
    {
      if (e == BIPEB)
	{
	  block = *ptr++;
	  e = 0;
	}
      if (block & ((UInt)1 << e++))
	AddShiftedVecGF2VecGF2( prod, vec2, len2, i);
    }
  return prod;
}

/****************************************************************************
**
*F  FuncPROD_COEFFS_GF2VEC( <self>, <vec1>, <len1>, <vec2>, <len2> )
**
*/

Obj FuncPROD_COEFFS_GF2VEC( Obj self, Obj vec1, Obj len1, Obj vec2, Obj len2 )
{
  UInt len1a, len2a;
  Obj prod;
  UInt last;
  len2a = INT_INTOBJ(len2);
  while ( len2a > LEN_GF2VEC(vec2)) 
    {
      len2 = ErrorReturnObj("PROD_COEFFS_GF2VEC: <len2> must not be more than the actual\nlength of the vector",
			   0,0,
                           "you can replace integer <len2> via 'return <len2>;'");
      len2a = INT_INTOBJ(len2);
    }
  len1a = INT_INTOBJ(len1);
  while (len1a > LEN_GF2VEC(vec1)) 
    {
      len1 = ErrorReturnObj("PROD_COEFFS_GF2VEC: <len1> must be not more than the actual\nlength of the vector",
			   0,0,
                           "you can replace integer <len1> via 'return <len1>;'");
      len1a = INT_INTOBJ(len1);
    }
  prod = ProductCoeffsGF2Vec( vec1, len1a, vec2, len2a );
  last = RightMostOneGF2Vec(prod);
  if (last < LEN_GF2VEC(prod))
    ResizeGF2Vec(prod, last);
  return prod;
}

/****************************************************************************
**
*F  ReduceCoeffsGF2Vec(<vec1>, <vec2>, <len2> )
**
*/

void ReduceCoeffsGF2Vec( Obj vec1, Obj vec2, UInt len2 )
{
  UInt len1 = LEN_GF2VEC(vec1);
  UInt i,e;
  UInt *ptr;
  if (len2 > len1)
    return;
  i = len1 -1;
  e = (i % BIPEB);
  ptr = BLOCKS_GF2VEC(vec1) + (i/BIPEB);
  while (i+ 1 >= len2)
    {
      if (*ptr & ((UInt)1 << e))
	AddShiftedVecGF2VecGF2(vec1, vec2, len2, i - len2 + 1);
      assert(!(*ptr & ((UInt)1<<e)));
      if (e == 0)
	{
	  e = BIPEB -1;
	  ptr--;
	}
      else
	e--;
      i--;
    }
 return;
}

/****************************************************************************
**
*F  FuncREDUCE_COEFFS_GF2VEC( <self>, <vec1>, <len1>, <vec2>, <len2> )
**
*/
Obj FuncREDUCE_COEFFS_GF2VEC( Obj self, Obj vec1, Obj len1, Obj vec2, Obj len2)
{
  UInt last;
  UInt len2a;
  while (INT_INTOBJ(len1) < 0 || INT_INTOBJ(len1) > LEN_GF2VEC(vec1))
    {
      len1 = ErrorReturnObj("ReduceCoeffs: given length <len1> of left argt (%d)\nis longer than the argt (%d)",
			  INT_INTOBJ(len1), LEN_GF2VEC(vec1), 
                          "you can replace integer <len1> via 'return <len1>;'");
    }
  len2a = INT_INTOBJ(len2);
  while (/* len2a < 0 ||*/  len2a > LEN_GF2VEC(vec2))
    {
      len2 = ErrorReturnObj("ReduceCoeffs: given length <len2> of right argt (%d)\nis longer than the argt (%d)",
			  len2a, LEN_GF2VEC(vec2), 
                          "you can replace integer <len2> via 'return <len2>;'");
      len2a = INT_INTOBJ(len2);
    }
  ResizeGF2Vec(vec1, INT_INTOBJ(len1));
  
  while ( 0 < len2a ) {
    if ( BLOCK_ELM_GF2VEC(vec2,len2a) == 0 )
      len2a = BIPEB*((len2a-1)/BIPEB);
    else if ( BLOCK_ELM_GF2VEC(vec2,len2a) & MASK_POS_GF2VEC(len2a) )
      break;
    else
      len2a--;
  }

  if (len2a == 0)
    {
      ErrorReturnVoid("ReduceCoeffs: second argument must not be zero", 0, 0,
		      "you may 'return;' to skip the reduction");
      return 0;
    }
  
  ReduceCoeffsGF2Vec( vec1, vec2, len2a);
  last = RightMostOneGF2Vec(vec1);
  ResizeGF2Vec(vec1, last);
  return INTOBJ_INT(last);
}


/****************************************************************************
**
*F  FuncSEMIECHELON_LIST_GF2VECS( <self>, <mat> )
**
**  Method for SemiEchelonMat for plain lists of GF2 vectors
**
** Method selection can guarantee us a plain list of characteristic 2 vectors 
*/

Obj FuncSEMIECHELON_LIST_GF2VECS( Obj self, Obj mat )
{
  UInt i,len;
  Obj row;
  /* check argts */
  len = LEN_PLIST(mat);
  if (!len)
    return TRY_NEXT_METHOD;
  for (i = 1; i <= len; i++)
    {
      row = ELM_PLIST(mat, i);
      if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(ELM_PLIST(mat,i)))
	{
	  return TRY_NEXT_METHOD;
	}
    }
  return SemiEchelonListGF2Vecs( mat, 0);
}

/****************************************************************************
**
*F  FuncSEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS( <self>, <mat> )
**
**  Method for SemiEchelonMatTransformations for plain lists of GF2 vectors
**
** Method selection can guarantee us a plain list of characteristic 2 vectors 
*/

Obj FuncSEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS( Obj self, Obj mat )
{
  UInt i,len;
  Obj row;
  /* check argts */
  len = LEN_PLIST(mat);
  if (!len)
    return TRY_NEXT_METHOD;
  for (i = 1; i <= len; i++)
    {
      row = ELM_PLIST(mat, i);
      if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(ELM_PLIST(mat,i)))
	{
	  return TRY_NEXT_METHOD;
	}
    }
  return SemiEchelonListGF2Vecs( mat, 1);
}

/****************************************************************************
**
*F  FuncTRIANGULIZE_LIST_GF2VECS( <self>, <mat> )
**
*/

Obj FuncTRIANGULIZE_LIST_GF2VECS( Obj self, Obj mat)
{
  UInt i,len;
  Obj row;
  /* check argts */
  len = LEN_PLIST(mat);
  if (!len)
    return TRY_NEXT_METHOD;
  for (i = 1; i <= len; i++)
    {
      row = ELM_PLIST(mat, i);
      if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(ELM_PLIST(mat,i)))
	{
	  return TRY_NEXT_METHOD;
	}
    }
  TriangulizeListGF2Vecs( mat, 1 );
  return (Obj) 0;
}

/****************************************************************************
**
*F  FuncRANK_LIST_GF2VECS( <self>, <mat> )
**
*/

Obj FuncRANK_LIST_GF2VECS( Obj self, Obj mat)
{
  UInt i,len;
  Obj row;
  /* check argts */
  len = LEN_PLIST(mat);
  if (!len)
    return TRY_NEXT_METHOD;
  for (i = 1; i <= len; i++)
    {
      row = ELM_PLIST(mat, i);
      if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(ELM_PLIST(mat,i)))
	{
	  return TRY_NEXT_METHOD;
	}
    }
  return INTOBJ_INT(TriangulizeListGF2Vecs( mat , 0));
}

/****************************************************************************
**
*F  FuncDETERMINANT_LIST_GF2VECS( <self>, <mat> )
**
*/

Obj FuncDETERMINANT_LIST_GF2VECS( Obj self, Obj mat)
{
  UInt i,len;
  Obj row;
  /* check argts */
  len = LEN_PLIST(mat);
  if (!len)
    return TRY_NEXT_METHOD;
  for (i = 1; i <= len; i++)
    {
      row = ELM_PLIST(mat, i);
      if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(ELM_PLIST(mat,i)))
	{
	  return TRY_NEXT_METHOD;
	}
    }
  return (len == TriangulizeListGF2Vecs( mat , 0)) ? GF2One : GF2Zero;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "CONV_GF2VEC", 1, "list",
      FuncCONV_GF2VEC, "src/vecgf2.c:CONV_GF2VEC" },

    { "PLAIN_GF2VEC", 1, "gf2vec",
      FuncPLAIN_GF2VEC, "src/vecgf2.c:PLAIN_GF2VEC" },

    { "PLAIN_GF2MAT", 1, "gf2mat",
      FuncPLAIN_GF2MAT, "src/vecgf2.c:PLAIN_GF2MAT" },

    { "EQ_GF2VEC_GF2VEC", 2, "gf2vec, gf2vec",
      FuncEQ_GF2VEC_GF2VEC, "src/vecgf2.c:EQ_GF2VEC_GF2VEC" },

    { "LT_GF2VEC_GF2VEC", 2, "gf2vec, gf2vec",
      FuncLT_GF2VEC_GF2VEC, "src/vecgf2.c:LT_GF2VEC_GF2VEC" },

    { "EQ_GF2MAT_GF2MAT", 2, "gf2mat, gf2mat",
      FuncEQ_GF2MAT_GF2MAT, "src/vecgf2.c:EQ_GF2MAT_GF2MAT" },

    { "LT_GF2MAT_GF2MAT", 2, "gf2mat, gf2mat",
      FuncLT_GF2MAT_GF2MAT, "src/vecgf2.c:LT_GF2MAT_GF2MAT" },

    { "LEN_GF2VEC", 1, "gf2vec",
      FuncLEN_GF2VEC, "src/vecgf2.c:LEN_GF2VEC" },

    { "ELM0_GF2VEC", 2, "gf2vec, pos",
      FuncELM0_GF2VEC, "src/vecgf2.c:ELM0_GF2VEC" },

    { "ELM_GF2VEC", 2, "gf2vec, pos",
      FuncELM_GF2VEC, "src/vecgf2.c:ELM_GF2VEC" },

    { "ELMS_GF2VEC", 2, "gf2vec, poss",
      FuncELMS_GF2VEC, "src/vecgf2.c:ELMS_GF2VEC" },

    { "ASS_GF2VEC", 3, "gf2vec, pos, elm",
      FuncASS_GF2VEC, "src/vecgf2.c:ASS_GF2VEC" },

    { "ASS_GF2MAT", 3, "gf2mat, pos, elm",
      FuncASS_GF2MAT, "src/vecgf2.c:ASS_GF2MAT" },

    { "UNB_GF2VEC", 2, "gf2vec, pos",
      FuncUNB_GF2VEC, "src/vecgf2.c:UNB_GF2VEC" },

    { "UNB_GF2MAT", 2, "gf2mat, pos",
      FuncUNB_GF2MAT, "src/vecgf2.c:UNB_GF2MAT" },

    { "ZERO_GF2VEC", 1, "gf2vec",
      FuncZERO_GF2VEC, "src/vecgf2.c:ZERO_GF2VEC" },

    { "ZERO_GF2VEC_2", 1, "len",
      FuncZERO_GF2VEC_2, "src/vecgf2.c:ZERO_GF2VEC_2" },

    { "INV_GF2MAT", 1, "gf2mat",
      FuncINV_GF2MAT, "src/vecgf2.c:INV_GF2MAT" },

    { "INV_PLIST_GF2VECS_DESTRUCTIVE", 1, "list",
      FuncINV_PLIST_GF2VECS_DESTRUCTIVE, "src/vecgf2.c:INV_PLIST_GF2VECS_DESTRUCTIVE" },

    { "SUM_GF2VEC_GF2VEC", 2, "gf2vec, gf2vec",
      FuncSUM_GF2VEC_GF2VEC, "src/vecgf2.c:SUM_GF2VEC_GF2VEC" },

    { "PROD_GF2VEC_GF2VEC", 2, "gf2vec, gf2vec",
      FuncPROD_GF2VEC_GF2VEC, "src/vecgf2.c:PROD_GF2VEC_GF2VEC" },

    { "PROD_GF2VEC_GF2MAT", 2, "gf2vec, gf2mat",
      FuncPROD_GF2VEC_GF2MAT, "src/vecgf2.c:PROD_GF2VEC_GF2MAT" },

    { "PROD_GF2MAT_GF2VEC", 2, "gf2mat, gf2vec",
      FuncPROD_GF2MAT_GF2VEC, "src/vecgf2.c:PROD_GF2MAT_GF2VEC" },

    { "PROD_GF2MAT_GF2MAT", 2, "gf2matl, gf2matr",
      FuncPROD_GF2MAT_GF2MAT, "src/vecgf2.c:PROD_GF2MAT_GF2MAT" },

    { "ADDCOEFFS_GF2VEC_GF2VEC_MULT", 3, "gf2vec, gf2vec, mul",
      FuncADDCOEFFS_GF2VEC_GF2VEC_MULT, "src/vecgf2.c:ADDCOEFFS_GF2VEC_GF2VEC_MULT" },

    { "ADDCOEFFS_GF2VEC_GF2VEC", 2, "gf2vec, gf2vec",
      FuncADDCOEFFS_GF2VEC_GF2VEC, "src/vecgf2.c:ADDCOEFFS_GF2VEC_GF2VEC" },

    { "SHRINKCOEFFS_GF2VEC", 1, "gf2vec",
      FuncSHRINKCOEFFS_GF2VEC, "src/vecgf2.c:SHRINKCOEFFS_GF2VEC" },

    { "POSITION_NONZERO_GF2VEC", 2, "gf2vec, zero",
      FuncPOSITION_NONZERO_GF2VEC, "src/vecgf2.c:POSITION_NONZERO_GF2VEC" },

    { "MULT_ROW_VECTOR_GF2VECS_2", 2, "gf2vecl, mul",
      FuncMULT_ROW_VECTOR_GF2VECS_2, "src/vecgf2.c:MULT_ROW_VECTOR_GF2VECS_2" },

    { "APPEND_GF2VEC", 2, "gf2vecl, gf2vecr",
      FuncAPPEND_VECGF2, "src/vecgf2.c:APPEND_GF2VEC" },

    { "SHALLOWCOPY_GF2VEC", 1, "gf2vec",
      FuncSHALLOWCOPY_VECGF2, "src/vecgf2.c:SHALLOWCOPY_GF2VEC" },

    { "NUMBER_GF2VEC", 1, "gf2vec",
      FuncNUMBER_VECGF2, "src/vecgf2.c:NUMBER_GF2VEC" },

    { "DIST_GF2VEC_GF2VEC", 2, "gf2vec, gf2vec",
      FuncDIST_GF2VEC_GF2VEC, "src/vecgf2.c:DIST_GF2VEC_GF2VEC" },

    { "DIST_VEC_CLOS_VEC", 3, "list, gf2vec, list",
      FuncDistVecClosVec, "src/vecgf2.c:DIST_VEC_CLOS_VEC" },

    { "SUM_GF2MAT_GF2MAT", 2, "matl, matr",
      FuncSUM_GF2MAT_GF2MAT, "src/vecgf2.c:SUM_GF2MAT_GF2MAT" },

    { "A_CLOS_VEC", 4, "list, gf2vec, int, int",
      FuncAClosVec, "src/vecgf2.c:A_CLOS_VEC" },

    { "COSET_LEADERS_INNER_GF2", 4, "veclis, weight, tofind, leaders",
      FuncCOSET_LEADERS_INNER_GF2, "src/vecgf2.c:COSET_LEADERS_INNER_GF2" },

    { "CONV_GF2MAT", 1, "list",
      FuncCONV_GF2MAT, "src/vecgf2.c:CONV_GF2MAT" },

    { "PROD_GF2VEC_ANYMAT", 2, "vec, mat",
      FuncProdGF2VecAnyMat, "sec/vecgf2.c:PROD_GF2VEC_ANYMAT" },
    
    { "RIGHTMOST_NONZERO_GF2VEC", 1, "vec",
      FuncRIGHTMOST_NONZERO_GF2VEC, "sec/vecgf2.c:RIGHTMOST_NONZERO_GF2VEC" },
    
    { "RESIZE_GF2VEC", 2, "vec, newlen",
      FuncRESIZE_GF2VEC, "sec/vecgf2.c:RESIZE_GF2VEC" },
    
    { "SHIFT_LEFT_GF2VEC", 2, "vec, amount",
      FuncSHIFT_LEFT_GF2VEC, "sec/vecgf2.c:SHIFT_LEFT_GF2VEC" },
    
    { "SHIFT_RIGHT_GF2VEC", 3, "vec, amount, zero",
      FuncSHIFT_RIGHT_GF2VEC, "sec/vecgf2.c:SHIFT_RIGHT_GF2VEC" },

    { "ADD_GF2VEC_GF2VEC_SHIFTED", 4, "vec1, vec2,len2, off",
      FuncADD_GF2VEC_GF2VEC_SHIFTED, "sec/vecgf2.c:ADD_GF2VEC_GF2VEC_SHIFTED" },
    
    { "PROD_COEFFS_GF2VEC", 4, "vec1, len1, vec2,len2",
      FuncPROD_COEFFS_GF2VEC, "sec/vecgf2.c:PROD_COEFFS_GF2VEC" },

    { "REDUCE_COEFFS_GF2VEC", 4, "vec1, len1, vec2,len2",
      FuncREDUCE_COEFFS_GF2VEC, "sec/vecgf2.c:REDUCE_COEFFS_GF2VEC" },

    { "SEMIECHELON_LIST_GF2VECS", 1, "mat",
      FuncSEMIECHELON_LIST_GF2VECS, "sec/vecgf2.c:SEMIECHELON_LIST_GF2VECS" },

    { "SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS", 1, "mat",
      FuncSEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS, "sec/vecgf2.c:SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS" },

    { "TRIANGULIZE_LIST_GF2VECS", 1, "mat",
      FuncTRIANGULIZE_LIST_GF2VECS, "sec/vecgf2.c:TRIANGULIZE_LIST_GF2VECS" },

    { "DETERMINANT_LIST_GF2VECS", 1, "mat",
      FuncDETERMINANT_LIST_GF2VECS, "sec/vecgf2.c:DETERMINANT_LIST_GF2VECS" },

    { "RANK_LIST_GF2VECS", 1, "mat",
      FuncRANK_LIST_GF2VECS, "sec/vecgf2.c:RANK_LIST_GF2VECS" },
    
    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* import kind functions                                               */
    ImportGVarFromLibrary( "TYPE_LIST_GF2VEC",     &TYPE_LIST_GF2VEC     );
    ImportGVarFromLibrary( "TYPE_LIST_GF2VEC_IMM", &TYPE_LIST_GF2VEC_IMM );
    ImportGVarFromLibrary( "TYPE_LIST_GF2VEC_IMM_LOCKED", &TYPE_LIST_GF2VEC_IMM_LOCKED );
    ImportGVarFromLibrary( "TYPE_LIST_GF2VEC_LOCKED", &TYPE_LIST_GF2VEC_LOCKED );
    ImportFuncFromLibrary( "IsGF2VectorRep",       &IsGF2VectorRep       );
    ImportGVarFromLibrary( "TYPE_LIST_GF2MAT",     &TYPE_LIST_GF2MAT     );
    ImportGVarFromLibrary( "TYPE_LIST_GF2MAT_IMM", &TYPE_LIST_GF2MAT_IMM );

    /* initialize one and zero of GF2                                      */
    ImportGVarFromLibrary( "GF2One",  &GF2One  );
    ImportGVarFromLibrary( "GF2Zero", &GF2Zero );

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    InitFopyGVar("ConvertToVectorRep", &ConvertToVectorRep);
    InitFopyGVar("IsLockedRepresentationVector", &IsLockedRepresentationVector);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoGF2Vec()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "vecgf2",                           /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoGF2Vec ( void )
{
    module.revision_c = Revision_vecgf2_c;
    module.revision_h = Revision_vecgf2_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  vecgf2.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
