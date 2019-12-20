/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the part of the deep thought package which uses the
**  deep thought polynomials to multiply in nilpotent groups.
**
**  The deep thought polynomials are stored in the list <dtpols> where
**  <dtpols>[i] contains the polynomials f_{i1},...,f_{in}.
**  <dtpols>[i] is a record consisting of the components <evlist> and
**  <evlistvec>. <evlist> is a list of all deep thought monomials occurring
**  in the polynomials f_{i1},...,f_{in}. <evlistvec>is a list of vectors
**  describing the coefficients of the corresponding deep thought monomials
**  in the polynomials f_{i1},..,f_{in}. For example when a pair [j,k]
**  occurs in <dtpols>[i].<evlistvec>[l]  then the deep thought monomial
**  <dtpols>[i].<evlist>[l] occurs in f_{ij} with the coefficient k.
**  If the polynomials f_{i1},..,f_{in} are trivial i.e. f_{ii} = x_i + y_i
**  and f_{ij} = x_j (j<>i),  then <dtpols>[i] is either 1 or 0. <dtpols>[i]
**  is 0 if also the polynomials f_{m1},...,f_{mn} for (m > i) are trivial .
*/

#include "dteval.h"

#include "dt.h"
#include "integer.h"
#include "modules.h"
#include "objcftl.h"
#include "plist.h"
#include "precord.h"
#include "records.h"

#ifdef HPCGAP
#include "hpc/guards.h"
#endif

#define   CELM(list, pos)      (  INT_INTOBJ( ELM_PLIST(list, pos) ) )

static int             evlist, evlistvec;


/****************************************************************************
**
*F  MultGen( <xk>, <gen>, <power>, <dtpols> )
**
**  MultGen multiplies the word given by the exponent vector <xk> with
**  g_<gen>^<power> by evaluating the deep thought polynomials. The result
**  is an ordered word and stored in <xk>.
*/

/* See below: */
static Obj Evaluation(Obj vec, Obj xk, Obj power);

static void MultGen(Obj xk, UInt gen, Obj power, Obj dtpols)
{
    UInt  i, j, len, len2;
    Obj   copy, sum, sum1, sum2, prod, ord, help;

    if ( power == INTOBJ_INT(0) )
        return;
    sum = SumInt(ELM_PLIST(xk, gen),  power);
    if ( IS_INTOBJ( ELM_PLIST(dtpols, gen) ) )
    {
        /* if f_{<gen>1},...,f_{<gen>n} are trivial we only have to add
        ** <power> to <xk>[ <gen> ].                                     */
        SET_ELM_PLIST(xk, gen, sum);
        CHANGED_BAG(xk);
        return;
    }
    copy = ShallowCopyPlist(xk);
    /* first add <power> to <xk>[ gen> ].                                */
    SET_ELM_PLIST(xk, gen, sum);
    CHANGED_BAG(xk);     
    sum = ElmPRec( ELM_PLIST(dtpols, gen), evlist );
    sum1 = ElmPRec( ELM_PLIST(dtpols, gen), evlistvec);
    len = LEN_PLIST(sum);
    for ( i=1;
          i <= len;
          i++ )
    {
        /* evaluate the deep thought monomial <sum>[<i>],        */
        ord = Evaluation( ELM_PLIST( sum, i), copy, power  );
        if ( ord != INTOBJ_INT(0) )
        {
            help = ELM_PLIST(sum1, i);
            len2 = LEN_PLIST(help);
            for ( j=1; 
                  j < len2;
                  j+=2    )
            {
                /* and add the result multiplied by the right coefficient
                ** to <xk>[ <help>[j] ].                                    */
                prod = ProdInt( ord, ELM_PLIST(  help, j+1 ) );
                sum2 = SumInt(ELM_PLIST( xk, CELM( help,j ) ),
                              prod);
                SET_ELM_PLIST(xk, CELM( help, j ),  
                              sum2 );
                CHANGED_BAG(xk);
            }
        }
    }
}



/****************************************************************************
**
*F  Evaluation( <vec>, <xk>, <power>)
**
**  Evaluation evaluates the deep thought monomial <vec> at the entries in
**  <xk> and at <power>.
*/

static Obj Evaluation(Obj vec, Obj xk, Obj power)
{
    UInt i, len;
    Obj  prod, help;

    if ( IS_POS_INTOBJ(power) &&  
         power < ELM_PLIST(vec, 6)     )
        return INTOBJ_INT(0);
    prod = BinomialInt(power, ELM_PLIST(vec, 6) );
    len = LEN_PLIST(vec);
    for (i=7; i < len; i+=2)
    {
        help = ELM_PLIST(xk, CELM(vec, i) );
        if ( IS_INTOBJ( help )                       &&
             ( INT_INTOBJ(help) == 0                 ||
               ( INT_INTOBJ(help) > 0  &&  help < ELM_PLIST(vec, i+1) )  ) )
            return INTOBJ_INT(0);
        prod = ProdInt( prod, BinomialInt(help, ELM_PLIST(vec, i+1) ) );
    }
    return prod;
}



/****************************************************************************
**
*F  Multbound( <xk>, <y>, <anf>, <end>, <dtpols> )
**
**  Multbound multiplies the word given by the exponent vector <xk> with
**  <y>{ [<anf>..<end>] } by evaluating the deep thought polynomials <dtpols>
**  The result is an ordered word and is stored in <xk>.
*/

static void Multbound(Obj xk, Obj y, Int anf, Int end, Obj dtpols)
{
    int     i;

    for (i=anf; i < end; i+=2)
        MultGen(xk, CELM( y, i), ELM_PLIST( y, i+1) , dtpols);
}



/****************************************************************************
**
*F  Multiplybound( <x>, <y>, <anf>, <end>, <dtpols> )
**
**  Multiplybound returns the product of the word <x> with the word
**  <y>{ [<anf>..<end>] } by evaluating the deep thought polynomials <dtpols>.
**  The result is an ordered word.
*/

static Obj Multiplybound(Obj x, Obj y, Int anf, Int end, Obj dtpols)
{
    UInt   i, j, k, len, help;
    Obj    xk, res, sum;

    if ( LEN_PLIST( x ) == 0 )
        return y;
    if ( anf > end )
        return x;
    /* first deal with the case that <y>{ [<anf>..<end>] } lies in the center
    ** of the group defined by <dtpols>                                    */
    if ( IS_INTOBJ( ELM_PLIST(dtpols, CELM(y, anf) ) )   &&
         CELM(dtpols, CELM(y, anf) ) == 0                          )
    {
        res = NEW_PLIST( T_PLIST, 2*LEN_PLIST( dtpols ) );
        len = LEN_PLIST(x);
        j = 1;
        k = anf;
        i = 1;
        while ( j<len && k<end )
        {
            if ( ELM_PLIST(x, j) == ELM_PLIST(y, k) )
            {
                sum = SumInt( ELM_PLIST(x, j+1), ELM_PLIST(y, k+1) );
                SET_ELM_PLIST(res, i, ELM_PLIST(x, j) );
                SET_ELM_PLIST(res, i+1, sum );
                j+=2;
                k+=2;
            }
            else if ( ELM_PLIST(x, j) < ELM_PLIST(y, k) )
            {
                SET_ELM_PLIST(res, i, ELM_PLIST(x, j) );
                SET_ELM_PLIST(res, i+1, ELM_PLIST(x, j+1) );
                j+=2;
            }
            else
            {
                SET_ELM_PLIST(res, i, ELM_PLIST(y, k) );
                SET_ELM_PLIST(res, i+1, ELM_PLIST(y, k+1) );
                k+=2;
            }
            CHANGED_BAG(res);
            i+=2;
        }
        if ( j>=len )
            while ( k<end )
            {
                SET_ELM_PLIST(res, i, ELM_PLIST(y, k) );
                SET_ELM_PLIST(res, i+1, ELM_PLIST(y, k+1 ) );
                CHANGED_BAG(res);
                k+=2;
                i+=2;
            }
        else
            while ( j<len )
            {
                SET_ELM_PLIST(res, i, ELM_PLIST(x, j) );
                SET_ELM_PLIST(res, i+1, ELM_PLIST(x, j+1) );
                CHANGED_BAG(res);
                j+=2;
                i+=2;
            }
        SET_LEN_PLIST(res, i-1);
        SHRINK_PLIST(res, i-1);
        return res;
    }
    len = LEN_PLIST(dtpols);
    help = LEN_PLIST(x);
    /* convert <x> into a exponent vector                             */
    xk = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST(xk, len );
    j = 1;
    for (i=1; i <= len; i++)
    {
        if ( j >= help  ||  i < CELM(x, j) )
            SET_ELM_PLIST(xk, i, INTOBJ_INT(0) );
        else
        {
            SET_ELM_PLIST(xk, i, ELM_PLIST(x, j+1) );
            j+=2;
        }
    }
    /* let Multbound do the work                                       */
    Multbound(xk, y, anf, end, dtpols);
    /* finally convert the result back into a word                     */
    res = NEW_PLIST(T_PLIST, 2*len);
    j = 0;
    for (i=1; i <= len; i++)
    {
        if ( !( IS_INTOBJ( ELM_PLIST(xk, i) )  &&  CELM(xk, i) == 0 ) )
        {
            j+=2;
            SET_ELM_PLIST(res, j-1, INTOBJ_INT(i) );
            SET_ELM_PLIST(res, j, ELM_PLIST(xk, i) );
        }
    }
    SET_LEN_PLIST(res, j);
    SHRINK_PLIST(res, j);
    return res;
}



/****************************************************************************
**
*F  Power( <x>, <n>, <dtpols> )
**
**  Power returns the <n>-th power of the word <x> as ordered word by
**  evaluating the deep thought polynomials <dtpols>.
*/

/* See below: */
static Obj Solution(Obj x, Obj y, Obj dtpols);

static Obj Power(Obj x, Obj n, Obj dtpols)
{
    Obj     res, m, y;
    UInt    i,len;

    if ( LEN_PLIST(x) == 0 )
        return x;
    /* first deal with the case that <x> lies in the centre of the group
    ** defined by <dtpols>                                              */
    if ( IS_INTOBJ( ELM_PLIST( dtpols, CELM(x, 1) ) )   &&
         CELM( dtpols, CELM(x, 1) ) == 0                     )
    {
        len = LEN_PLIST(x);
        res = NEW_PLIST( T_PLIST, len );
        SET_LEN_PLIST(res, len );
        for (i=2;i<=len;i+=2)
        {
            m = ProdInt( ELM_PLIST(x, i), n );
            SET_ELM_PLIST(res, i, m );
            SET_ELM_PLIST(res, i-1, ELM_PLIST(x, i-1) );
            CHANGED_BAG( res );
        }
        return res;
    }
    /* if <n> is a negative integer compute ( <x>^-1 )^(-<n>)           */
    if ( IS_NEG_INT(n) )
    {
        y = NEW_PLIST( T_PLIST, 0);
        return  Power( Solution(x, y, dtpols), AInvInt(n), dtpols );
    }
    res = NEW_PLIST(T_PLIST, 2);
    if ( n == INTOBJ_INT(0) )
        return res;
    /* now use the russian peasant rule to get the result               */
    while( LtInt(INTOBJ_INT(0), n) )
    {
        len = LEN_PLIST(x);
        if ( ModInt(n, INTOBJ_INT(2) ) == INTOBJ_INT(1)  )
            res = Multiplybound(res, x, 1, len, dtpols);
        if ( LtInt(INTOBJ_INT(1), n) )
            x = Multiplybound(x, x, 1, len, dtpols);
        n = QuoInt(n, INTOBJ_INT(2) );
    }
    return res;
}



/****************************************************************************
**
*F  Solution( <x>, <y>, <dtpols> )
**
**  Solution returns a solution for the equation <x>*a = <y> by evaluating
**  the deep thought polynomials <dtpols>. The result is an ordered word.
*/

static Obj Solution(Obj x, Obj y, Obj dtpols)

{
    Obj    xk, res, m;
    UInt   i,j,k, len1, len2;

    if ( LEN_PLIST(x) == 0)
        return y;
    /* first deal with the case that <x> and <y> lie in the centre of the
    ** group defined by <dtpols>.                                       */
    if ( IS_INTOBJ( ELM_PLIST( dtpols, CELM(x, 1) )  )  &&
         CELM( dtpols, CELM(x, 1) ) == 0                &&
         (  LEN_PLIST(y) == 0                              ||
            (  IS_INTOBJ( ELM_PLIST( dtpols, CELM(y, 1) )  )  &&
               CELM( dtpols, CELM(y, 1) ) == 0                    )  )   )
    {
        res = NEW_PLIST( T_PLIST, 2*LEN_PLIST( dtpols ) );
        i = 1;
        j = 1;
        k = 1;
        len1 = LEN_PLIST(x);
        len2 = LEN_PLIST(y);
        while ( j < len1 && k < len2 )
        {
            if ( ELM_PLIST(x, j) == ELM_PLIST(y, k) )
            {
                m = DiffInt( ELM_PLIST(y, k+1), ELM_PLIST(x, j+1) );
                SET_ELM_PLIST( res, i, ELM_PLIST(x, j) );
                SET_ELM_PLIST( res, i+1, m );
                CHANGED_BAG( res );
                i+=2; j+=2; k+=2;
            }
            else if ( CELM(x, j) < CELM(y, k) )
            {
                m = AInvInt( ELM_PLIST(x, j+1) );
                SET_ELM_PLIST( res, i, ELM_PLIST(x, j) );
                SET_ELM_PLIST( res, i+1, m );
                CHANGED_BAG( res );
                i+=2; j+=2;
            }
            else
            {
                SET_ELM_PLIST( res, i, ELM_PLIST(y, k) );
                SET_ELM_PLIST( res, i+1, ELM_PLIST(y, k+1) );
                CHANGED_BAG( res );
                i+=2; k+=2;
            }
        }
        if ( j < len1 )
            while( j < len1 )
            {
                m = AInvInt( ELM_PLIST( x, j+1 ) );
                SET_ELM_PLIST( res, i, ELM_PLIST(x, j) );
                SET_ELM_PLIST( res, i+1, m );
                CHANGED_BAG( res );
                i+=2; j+=2;
            }
        else
            while( k < len2 )
            {
                SET_ELM_PLIST( res, i ,ELM_PLIST(y, k) );
                SET_ELM_PLIST( res, i+1, ELM_PLIST(y, k+1) );
                CHANGED_BAG( res );
                i+=2; k+=2;
            }
        SET_LEN_PLIST( res, i-1 );
        SHRINK_PLIST( res, i-1);
        return res;
    }
    /* convert <x> into an exponent vector                           */
    xk = NEW_PLIST( T_PLIST, LEN_PLIST(dtpols) );
    SET_LEN_PLIST(xk, LEN_PLIST(dtpols) );
    j = 1;
    for (i=1; i <= LEN_PLIST(dtpols); i++)
    {
        if ( j >= LEN_PLIST(x)  ||  i < CELM(x, j) )
            SET_ELM_PLIST(xk, i, INTOBJ_INT(0) );
        else
        {
            SET_ELM_PLIST(xk, i, ELM_PLIST(x, j+1) );
            j+=2;
        }
    }
    res = NEW_PLIST( T_PLIST, 2*LEN_PLIST( xk ) );
    j = 1;
    k = 1;
    len1 = LEN_PLIST(xk);
    len2 = LEN_PLIST(y);
    for (i=1; i <= len1; i++)
    {
        if ( k < len2   &&   i == CELM(y, k)  )
        {
            if  ( !EqInt( ELM_PLIST(xk, i), ELM_PLIST(y, k+1) )  )
            {
                m = DiffInt( ELM_PLIST(y, k+1), ELM_PLIST(xk, i) );
                SET_ELM_PLIST(res, j, INTOBJ_INT(i) );
                SET_ELM_PLIST(res, j+1, m);
                CHANGED_BAG(res);
                MultGen(xk, i, m, dtpols);
                j+=2;
            }
            k+=2;
        }
        else if ( !IS_INTOBJ( ELM_PLIST(xk, i) )  ||  CELM( xk, i ) != 0 )
        {
            m = AInvInt( ELM_PLIST(xk, i) );
            SET_ELM_PLIST( res, j, INTOBJ_INT(i) );
            SET_ELM_PLIST( res, j+1, m );
            CHANGED_BAG(res);
            MultGen(xk, i, m, dtpols);
            j+=2;
        }
    }
    SET_LEN_PLIST(res, j-1);
    SHRINK_PLIST(res, j-1);
    return res;
}



/****************************************************************************
**
*F  Commutator( <x>, <y>, <dtpols> )
**
**  Commutator returns the commutator of the word <x> and <y> by evaluating
**  the deep thought polynomials <dtpols>.
*/

static Obj Commutator(Obj x, Obj y, Obj dtpols)
{
    Obj    res, help;

    res = Multiplybound(x, y, 1, LEN_PLIST(y), dtpols);
    help = Multiplybound(y, x, 1, LEN_PLIST(x), dtpols);
    res = Solution(help, res, dtpols);
    return res;
}



/****************************************************************************
**
*F  Conjugate( <x>, <y>, <dtpols> )
**
**  Conjugate returns <x>^<y> for the words <x> and <y> by evaluating the
**  deep thought polynomials <dtpols>. The result is an ordered word.
*/

static Obj Conjugate(Obj x, Obj y, Obj dtpols)
{
    Obj    res;

    res = Multiplybound(x, y, 1, LEN_PLIST(y), dtpols);
    res = Solution(y, res, dtpols);
    return res;
}



/****************************************************************************
**
*F  Multiplyboundred( <x>, <y>, <anf>, <end>, <pcp> )
**
**  Multiplyboundred returns the product of the words <x> and <y>. The result
**  is an ordered word with the additional property that all word exponents
**  are reduced modulo the corresponding generator orders given by the
**  deep thought rewriting system <pcp>..
*/

static Obj Multiplyboundred(Obj x, Obj y, UInt anf, UInt end, Obj pcp)
{
    Obj   orders, res, mod, c;
    UInt  i, len, len2, help;

    orders = ELM_PLIST(pcp, PC_ORDERS);
    res = Multiplybound(x,y,anf, end, ELM_PLIST( pcp, PC_DEEP_THOUGHT_POLS) );
    len = LEN_PLIST(res);
    len2 = LEN_PLIST(orders);
    for (i=2; i<=len; i+=2)
        if ( (help=CELM(res, i-1)) <= len2        &&
             ( c=ELM_PLIST( orders, help )) != 0 )
        {
            mod = ModInt( ELM_PLIST(res, i), c );
            SET_ELM_PLIST( res, i, mod);
            CHANGED_BAG(res);
        }
    return res;
}



/****************************************************************************
**
*F  Powerred( <x>, <n>, <pcp>
**
**  Powerred returns the <n>-th power of the word <x>. The result is an
**  ordered word with the additional property that all word exponents are
**  reduced modulo the generator orders given by the deep thought rewriting
**  system <pcp>.
*/

static Obj Powerred(Obj x, Obj n, Obj pcp)
{
    Obj   orders, res, mod, c;
    UInt  i, len, len2,help;

    orders = ELM_PLIST(pcp, PC_ORDERS);
    res = Power(x, n, ELM_PLIST( pcp, PC_DEEP_THOUGHT_POLS) );
    len = LEN_PLIST(res);
    len2 = LEN_PLIST(orders);
    for (i=2; i<=len; i+=2)
        if ( (help=CELM(res, i-1)) <= len2         &&
             ( c=ELM_PLIST( orders, help )) != 0 )
        {
            mod = ModInt( ELM_PLIST(res, i), c );
            SET_ELM_PLIST( res, i, mod);
            CHANGED_BAG(res);
        }
    return res;
}



/****************************************************************************
**
*F  Solutionred( <x>, <y>, <pcp> )
**
**  Solutionred returns the solution of the equation <x>*a = <y>.  The result
**  is an ordered word with the additional property that all word exponents
**  are reduced modulo the generator orders given by the deep thought
**  rewriting system <pcp>.
*/

static Obj Solutionred(Obj x, Obj y, Obj pcp)
{
    Obj   orders, res, mod, c;
    UInt  i, len, len2, help;

    orders = ELM_PLIST(pcp, PC_ORDERS);
    res = Solution(x, y, ELM_PLIST( pcp, PC_DEEP_THOUGHT_POLS) );
    len = LEN_PLIST(res);
    len2 = LEN_PLIST(orders);
    for (i=2; i<=len; i+=2)
        if ( (help=CELM(res, i-1)) <= len2       &&
             ( c=ELM_PLIST( orders, help )) != 0 )
        {
            mod = ModInt( ELM_PLIST(res, i), c );
            SET_ELM_PLIST( res, i, mod);
            CHANGED_BAG(res);
        }
    return res;
}



/****************************************************************************
**
**  Commutatorred( <x>, <y>, <pcp> )
**
**  Commutatorred returns the commutator of the words <x> and <y>. The result
**  is an ordered word with the additional property that all word exponents
**  are reduced modulo the corresponding generator orders given by the deep
**  thought rewriting system <pcp>.
*/

static Obj Commutatorred(Obj x, Obj y, Obj pcp)
{
    Obj    orders, mod, c, res;
    UInt   i, len, len2, help;

    orders = ELM_PLIST(pcp, PC_ORDERS);
    res = Commutator(x, y, ELM_PLIST( pcp, PC_DEEP_THOUGHT_POLS) );
    len = LEN_PLIST(res);
    len2 = LEN_PLIST(orders);
    for (i=2; i<=len; i+=2)
        if ( (help=CELM(res, i-1)) <= len2         &&
             ( c=ELM_PLIST( orders, help )) != 0 )
        {
            mod = ModInt( ELM_PLIST(res, i), c );
            SET_ELM_PLIST( res, i, mod);
            CHANGED_BAG(res);
        }
    return res;
}



/****************************************************************************
**
*F  Conjugate( <x>, <y>, <pcp> )
**
**  Conjugate returns <x>^<y> for the words <x> and <y>. The result is an
**  ordered word with the additional property that all word exponents are
**  reduced modulo the corresponding generator orders given by the deep
**  thought rewriting system <pcp>.
*/

static Obj Conjugatered(Obj x, Obj y, Obj pcp)
{
    Obj    orders, mod, c, res;
    UInt   i, len, len2, help;

    orders = ELM_PLIST(pcp, PC_ORDERS);
    res = Conjugate(x, y, ELM_PLIST( pcp, PC_DEEP_THOUGHT_POLS) );
    len = LEN_PLIST(res);
    len2 = LEN_PLIST(orders);
    for (i=2; i<=len; i+=2)
        if ( (help=CELM(res, i-1)) <= len2         &&
             ( c=ELM_PLIST( orders, help )) != 0 )
        {
            mod = ModInt( ELM_PLIST(res, i), c );
            SET_ELM_PLIST( res, i, mod);
            CHANGED_BAG(res);
        }
    return res;
}



/****************************************************************************
**
**  compress( <list> )
**
**  compress removes pairs (n,0) from the list of GAP integers <list>.
*/

static void compress(Obj list)
{    
    UInt    i, skip, len;
    
    skip = 0;
    i = 2;
    len = LEN_PLIST( list );
    while  ( i <= len )
    {
        while ( i<=len  &&  CELM(list, i) == 0)
        {
            skip+=2;
            i+=2;
        }
        if ( i <= len )
        {
            SET_ELM_PLIST(list, i-skip, ELM_PLIST(list, i) );
            SET_ELM_PLIST(list, i-1-skip, ELM_PLIST( list, i-1 ) );
        }
        i+=2;
    }
    SET_LEN_PLIST( list, len-skip );
    CHANGED_BAG( list );
    SHRINK_PLIST( list, len-skip );
}



/****************************************************************************
**
*F  FuncDTCompress( <self>, <list> )
**
**  FuncDTCompress implements the internal function DTCompress.
*/

static Obj FuncDTCompress(Obj self, Obj list)
{
    compress(list);
    return  (Obj)0;
}



/****************************************************************************
**
*F  ReduceWord( <x>, <pcp> )
**
**  ReduceWord reduces the ordered word <x> with respect to the deep thought
**  rewriting system <pcp> i.e after applying ReduceWord <x> is an ordered
**  word with exponents less than the corresponding relative orders given
**  by <pcp>.
*/

static void ReduceWord(Obj x, Obj pcp)
{
    Obj       powers, exponent;
    Obj       deepthoughtpols, help, potenz, quo, mod, prel;
    UInt      i,j,flag, len, gen, lenexp, lenpow;

    powers = ELM_PLIST(pcp, PC_POWERS);
    exponent = ELM_PLIST(pcp, PC_EXPONENTS);
    deepthoughtpols = ELM_PLIST(pcp, PC_DEEP_THOUGHT_POLS);
    len = LEN_PLIST(deepthoughtpols);
    lenexp = LEN_PLIST(exponent);
    lenpow = LEN_PLIST(powers);
    GROW_PLIST(x, 2*len );
    flag = LEN_PLIST(x);
    for (i=1; i<flag; i+=2)
    {
        if ( (gen = CELM(x, i) ) <= lenexp              &&
             (potenz = ELM_PLIST(exponent, gen) ) != 0                    )
        {
            quo = ELM_PLIST(x, i+1);
            if  ( !IS_INTOBJ(quo) || INT_INTOBJ(quo) >= INT_INTOBJ(potenz) || 
                  INT_INTOBJ(quo)<0 )
            {
                /* reduce the exponent of the generator <gen>            */
                mod = ModInt( quo, potenz );
                SET_ELM_PLIST(x, i+1, mod);
                CHANGED_BAG(x);
                if ( gen <= lenpow            &&
                     (prel = ELM_PLIST( powers, gen) )  != 0  )
                {
                    if ( ( IS_INTOBJ(quo) && INT_INTOBJ(quo) >= INT_INTOBJ(potenz) )   ||
                         INT_INTOBJ(mod) == 0 ||
                         TNUM_OBJ(quo) == T_INTPOS    )
                    {
                        quo = QuoInt(quo, potenz);
                    }
                    else
                    {
                        quo = QuoInt(quo, potenz);
                        quo = SumInt(quo, INTOBJ_INT(-1));
                    }
                    help = Powerred(prel, quo, pcp);
                    help = Multiplyboundred(help, x, i+2, flag, pcp);
                    len = LEN_PLIST(help);
                    for (j=1; j<=len; j++)
                        SET_ELM_PLIST(x, j+i+1, ELM_PLIST(help, j) );
                    CHANGED_BAG(x);
                    flag = i+len+1;
                    /*SET_LEN_PLIST(x, flag);*/
                }
            }
        }
    }
    SET_LEN_PLIST(x, flag);
    SHRINK_PLIST(x, flag);
    /* remove all syllables with exponent 0 from <x>.                  */
    compress(x);
}



/****************************************************************************
**
*F  FuncDTMultiply( <self>, <x>, <y>, <pcp> )
**
**  FuncDTMultiply implements the internal function
**
*F  DTMultiply( <x>, <y>, <pcp> ).
**
**  DTMultiply returns the product of <x> and <y>. The result is reduced
**  with respect to the deep thought rewriting system <pcp>.
*/

static Obj FuncDTMultiply(Obj self, Obj x, Obj y, Obj pcp)
{
    Obj res;

    if  ( LEN_PLIST(x) == 0 )
        return y;
    if  ( LEN_PLIST(y) == 0 )
        return x;
    res = Multiplyboundred(x, y, 1, LEN_PLIST(y), pcp);
    ReduceWord(res, pcp);
    return res;
}



/****************************************************************************
**
*F  FuncDTPower( <self>, <x>, <n>, <pcp> )
**
**  FuncDTPower implements the internal function
**
*F  DTPower( <x>, <n>, <pcp> ).
**
**  DTPower returns the <n>-th power of the word <x>. The result is reduced
**  with respect to the deep thought rewriting system <pcp>.
*/

static Obj FuncDTPower(Obj self, Obj x, Obj n, Obj pcp)
{
    Obj    res;

    res = Powerred(x, n, pcp);
    ReduceWord(res, pcp);
    return res;
}



/****************************************************************************
**
*F  FuncDTSolution( <self>, <x>, <y>, <pcp> )
**
**  FuncDTSolution implements the internal function
**
*F  DTSolution( <x>, <y>, <pcp> ).
**
**  DTSolution returns the solution of the equation <x>*a = <y>. The result
**  is reduced with respect to the deep thought rewriting system <pcp>.
*/

static Obj FuncDTSolution(Obj self, Obj x, Obj y, Obj pcp)
{
    Obj     res;

    if  ( LEN_PLIST(x) == 0 )
        return y;
    res = Solutionred(x, y, pcp);
    ReduceWord(res, pcp);
    return res;
}



/****************************************************************************
**
*F  FuncDTCommutator( <self>, <x>, <y>. <pcp> )
**
**  FuncDTCommutator implements the internal function
**
*F  DTCommutator( <x>, <y>, <pcp> )
**
**  DTCommutator returns the commutator of the words <x> and <y>.  The result
**  is reduced with respect to the deep thought rewriting system <pcp>.
*/

static Obj FuncDTCommutator(Obj self, Obj x, Obj y, Obj pcp)
{
    Obj   res;

    res = Commutatorred(x, y, pcp);
    ReduceWord(res, pcp);
    return res;
}



/****************************************************************************
**
*F  FuncConjugate( <self>, <x>, <y>, <pcp> )
**
**  FuncConjugate implements the internal function
**
*F  Conjugate( <x>, <y>, <pcp> ).
**
**  Conjugate returns <x>^<y> for the words <x> and <y>.  The result is
**  reduced with respect to the deep thought rewriting system <pcp>.
*/

static Obj FuncDTConjugate(Obj self, Obj x, Obj y, Obj pcp)
{
    Obj   res;

    if  ( LEN_PLIST(y) == 0 )
        return x;
    res = Conjugatered(x, y, pcp);
    ReduceWord(res, pcp);
    return res;
}



/****************************************************************************
**
*F  FuncDTQuotient( <self>, <x>, <y>, <pcp> )
**
**  FuncDTQuotient implements the internal function
**
*F  DTQuotient( <x>, <y>, <pcp> ).
**
*F  DTQuotient returns the <x>/<y> for the words <x> and <y>. The result is
**  reduced with respect to the deep thought rewriting system <pcp>.
*/

static Obj FuncDTQuotient(Obj self, Obj x, Obj y, Obj pcp)
{
    Obj     help, res;

    if  ( LEN_PLIST(y) == 0 )
        return x;
    help = NEW_PLIST( T_PLIST, 0 );
    res = Solutionred(y, help, pcp);
    res = Multiplyboundred(x, res, 1, LEN_PLIST(res), pcp);
    ReduceWord(res, pcp);
    return(res);
}



/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(DTCompress, list),
    GVAR_FUNC_3ARGS(DTMultiply, lword, rword, rws),
    GVAR_FUNC_3ARGS(DTPower, word, exponent, rws),
    GVAR_FUNC_3ARGS(DTSolution, lword, rword, rws),
    GVAR_FUNC_3ARGS(DTCommutator, lword, rword, rws),
    GVAR_FUNC_3ARGS(DTQuotient, lword, rword, rws),
    GVAR_FUNC_3ARGS(DTConjugate, lword, rword, rws),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    evlist    = RNamName("evlist");
    evlistvec = RNamName("evlistvec");

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

    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoDTEvaluation()  . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "dteval",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore
};

StructInitInfo * InitInfoDTEvaluation ( void )
{
    return &module;
}
