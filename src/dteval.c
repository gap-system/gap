#include       "system.h"
#include       "gasman.h"
#include       "objects.h"
#include       "scanner.h"
#include       "bool.h"
#include       "calls.h"
#include       "gap.h"
#include       "gvars.h"
#include       "plist.h"
#include       "lists.h"
#include       "listfunc.h"
#include       "precord.h"
#include       "records.h"
#include       "integer.h"
#include       "dt.h"
#include       "objcftl.h"

#define   CELM(list, pos)      (  INT_INTOBJ( ELM_PLIST(list, pos) ) )

static int             evlist, evlistvec;

extern Obj             ShallowCopyPlist( Obj  list );
extern Obj             CollectPolycyc (
                                        Obj pcp,
                                        Obj list,
                                        Obj word );

void       MultGen(
                    Obj     xk,
                    UInt    gen,
                    Obj     power,
                    Obj     pseudoreps    )
{
    UInt  i, j, len, len2;
    Obj   copy, sum, sum1, sum2, prod, ord, Evaluation(), help;

    if ( IS_INTOBJ(power)  &&  INT_INTOBJ(power) == 0 )
        return;
    sum = SumInt(ELM_PLIST(xk, gen),  power);
    if ( IS_INTOBJ( ELM_PLIST(pseudoreps, gen) ) )
    {
        SET_ELM_PLIST(xk, gen, sum);
        CHANGED_BAG(xk);
        return;
    }
    copy = ShallowCopyPlist(xk);
    SET_ELM_PLIST(xk, gen, sum);
    CHANGED_BAG(xk);     
    sum = ElmPRec( ELM_PLIST(pseudoreps, gen), evlist );
    sum1 = ElmPRec( ELM_PLIST(pseudoreps, gen), evlistvec);
    len = LEN_PLIST(sum);
    for ( i=1;
          i <= len;
          i++ )
    {
        ord = Evaluation( ELM_PLIST( sum, i), copy, power  );
        if ( !IS_INTOBJ(ord)  ||  INT_INTOBJ(ord) != 0 )
        {
            help = ELM_PLIST(sum1, i);
            len2 = LEN_PLIST(help);
            for ( j=1; 
                  j < len2;
                  j+=2    )
            {
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



Obj     Evaluation(
                    Obj     vec,
                    Obj     xk,
                    Obj     power      )
{
    UInt i, len;
    Obj  prod, help;

    if ( IS_INTOBJ(power)  &&  INT_INTOBJ(power) > 0  &&  
         power < ELM_PLIST(vec, 6)     )
        return INTOBJ_INT(0);
    prod = binomial(power, ELM_PLIST(vec, 6) );
    len = LEN_PLIST(vec);
    for (i=7; i < len; i+=2)
    {
        help = ELM_PLIST(xk, CELM(vec, i) );
        if ( IS_INTOBJ( help )                       &&
             ( INT_INTOBJ(help) == 0                 ||
               ( INT_INTOBJ(help) > 0  &&  help < ELM_PLIST(vec, i+1) )  ) )
            return INTOBJ_INT(0);
        prod = ProdInt( prod, binomial( help, ELM_PLIST(vec, i+1) ) );
    }
    return prod;
}


void        Multbound(
                  Obj    xk,
                  Obj    y,
                  Int    anf,
                  Int    end,
                  Obj    pseudoreps  )
{
    int     i;
    void    MultGen();

    for (i=anf; i < end; i+=2)
        MultGen(xk, CELM( y, i), ELM_PLIST( y, i+1) , pseudoreps);
}



Obj       Multiplybound(
                     Obj      x,
                     Obj      y,       
                     Int      anf,
                     Int      end,
                     Obj      pseudoreps  )
{
    UInt   i, j, k, len, help;
    Obj    xk, res, sum;
    void   Multbound();

    if ( LEN_PLIST( x ) == 0 )
        return y;
    if ( anf > end )
        return x;
    if ( IS_INTOBJ( ELM_PLIST(pseudoreps, CELM(y, anf) ) )   &&
         CELM(pseudoreps, CELM(y, anf) ) == 0                          )
    {
        res = NEW_PLIST( T_PLIST, 2*LEN_PLIST( pseudoreps ) );
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
    len = LEN_PLIST(pseudoreps);
    help = LEN_PLIST(x);
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
    Multbound(xk, y, anf, end, pseudoreps);
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



Obj      FuncMultiply(
                       Obj      self,
                       Obj      x,
                       Obj      y,
                       Obj      pseudoreps      )
{
    Obj    Multiplybound();

    return Multiplybound(x, y, 1, LEN_PLIST(y), pseudoreps);
}



Obj      Power(
                Obj         x,
                Obj         n,
                Obj         pseudoreps     )
{
    Obj     res, Solution(), Multiplybound(), m, y;
    UInt    i,len;


    if ( IS_INTOBJ( ELM_PLIST( pseudoreps, CELM(x, 1) ) )   &&
         CELM( pseudoreps, CELM(x, 1) ) == 0                     )
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
    if (  TNUM_OBJ(n) == T_INTNEG  ||  INT_INTOBJ(n) < 0  ) 
    {
        y = NEW_PLIST( T_PLIST, 0);
        SET_LEN_PLIST(y, 0);
        return  Power( Solution(x, y, pseudoreps), 
                       ProdInt(INTOBJ_INT(-1), n),   pseudoreps  );    
    }
    res = NEW_PLIST(T_PLIST, 2);
    SET_LEN_PLIST(res, 0);
    if ( IS_INTOBJ(n)  &&  INT_INTOBJ(n) == 0  )
        return res;
    while( LtInt(INTOBJ_INT(0), n) )
    {
        len = LEN_PLIST(x);
        if ( ModInt(n, INTOBJ_INT(2) ) == INTOBJ_INT(1)  )
            res = Multiplybound(res, x, 1, len, pseudoreps);
        if ( LtInt(INTOBJ_INT(1), n) )
            x = Multiplybound(x, x, 1, len, pseudoreps);
        n = QuoInt(n, INTOBJ_INT(2) );
    }
    return res;
}



Obj        FuncPower(
                      Obj     self,
                      Obj     x,
                      Obj     n,
                      Obj     pseudoreps     )
{
    Obj      Power();

    return Power(x, n, pseudoreps);
}


   

Obj      Solution( Obj       x,
                   Obj       y,
                   Obj       pseudoreps  )

{
    Obj    xk, res, m;
    UInt   i,j,k, len1, len2;
    void   MultGen();

    if ( LEN_PLIST(x) == 0)
        return y;
    if ( IS_INTOBJ( ELM_PLIST( pseudoreps, CELM(x, 1) )  )  &&
         CELM( pseudoreps, CELM(x, 1) ) == 0                &&
         IS_INTOBJ( ELM_PLIST( pseudoreps, CELM(y, 1) )  )  &&
         CELM( pseudoreps, CELM(y, 1) ) == 0                     )
    {
        res = NEW_PLIST( T_PLIST, 2*LEN_PLIST( pseudoreps ) );
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
                m = ProdInt( INTOBJ_INT(-1), ELM_PLIST(x, j+1) );
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
                m = ProdInt( INTOBJ_INT(-1), ELM_PLIST( x, j+1 ) );
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
    xk = NEW_PLIST( T_PLIST, LEN_PLIST(pseudoreps) );
    SET_LEN_PLIST(xk, LEN_PLIST(pseudoreps) );
    j = 1;
    for (i=1; i <= LEN_PLIST(pseudoreps); i++)
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
                MultGen(xk, i, m, pseudoreps);
                j+=2;
            }
            k+=2;
        }
        else if ( !IS_INTOBJ( ELM_PLIST(xk, i) )  ||  CELM( xk, i ) != 0 )
        {
            m = ProdInt( INTOBJ_INT(-1), ELM_PLIST(xk, i) );
            SET_ELM_PLIST( res, j, INTOBJ_INT(i) );
            SET_ELM_PLIST( res, j+1, m );
            CHANGED_BAG(res);
            MultGen(xk, i, m, pseudoreps);
            j+=2;
        }
    }
    SET_LEN_PLIST(res, j-1);
    SHRINK_PLIST(res, j-1);
    return res;
}



Obj       Commutator( Obj     x,
                      Obj     y,
                      Obj     pseudoreps  )
{
    Obj    res, Solution(), Multiplybound(), help;

    res = Multiplybound(x, y, 1, LEN_PLIST(y), pseudoreps);
    help = Multiplybound(y, x, 1, LEN_PLIST(x), pseudoreps);
    res = Solution(help, res, pseudoreps);
    return res;
}



Obj       Conjugate( Obj     x,
                     Obj     y,
                     Obj     pseudoreps  )
{
    Obj    res, Solution(), Multiplybound();

    res = Multiplybound(x, y, 1, LEN_PLIST(y), pseudoreps);
    res = Solution(y, res, pseudoreps);
    return res;
}



Obj      CommutatorredL( Obj    x,
                         Obj    y,
                         Obj    pcp  )
{
    Obj    orders, Commutator(), mod, c, res;
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



Obj       ConjugateredL( Obj    x,
                         Obj    y,
                         Obj    pcp  )
{
    Obj    orders, Conjugate(), mod, c, res;
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




Obj       FuncDTCommutatorL( Obj      self,
                             Obj      x,
                             Obj      y,
                             Obj      pcp  )
{
    Obj   res, CommutatorredL();
    void  ReduceWordL();

    res = CommutatorredL(x, y, pcp);
    ReduceWordL(res, pcp);
    return res;
}



Obj       FuncDTConjugateL( Obj      self,
                            Obj      x,
                            Obj      y,
                            Obj      pcp  )
{
    Obj   res, ConjugateredL();
    void  ReduceWordL();

    if  ( LEN_PLIST(y) == 0 )
        return x;
    res = ConjugateredL(x, y, pcp);
    ReduceWordL(res, pcp);
    return res;
}



Obj       FuncDTQuotientL( Obj      self,
                           Obj      x,
                           Obj      y,
                           Obj      pcp )
{
    Obj     SolutionredL(), MultiplyboundredL(), help, res;
    void    ReduceWordL();

    if  ( LEN_PLIST(y) == 0 )
        return x;
    help = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST(help, 0);
    res = SolutionredL(y, help, pcp);
    res = MultiplyboundredL(x, res, 1, LEN_PLIST(res), pcp);
    ReduceWordL(res, pcp);
    return(res);
}



Obj      MultiplyboundredL( Obj     x,
                            Obj     y,
                            UInt    anf,
                            UInt    end,
                            Obj     pcp )
{
    Obj   Multiplybound(), orders, res, mod, c;
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



Obj      PowerredL( Obj       x,
                    Obj       n,
                    Obj       pcp  )
{
    Obj   Power(),  orders, res, mod, c;
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



Obj      SolutionredL( Obj       x,
                       Obj       y,
                       Obj       pcp  )
{
    Obj   Solution(),  orders, res, mod, c;
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



void     ReduceWordL( Obj      x,
                      Obj      pcp )   
{
    Obj       PowerredL(), MultiplyboundredL(), powers, exponent;
    Obj       deepthoughtpols, help, potenz, quo, mod, prel;
    UInt      i,j,flag, len, gen, lenexp, lenpow;
    void      compress();

    powers = ELM_PLIST(pcp, PC_POWERS);
    exponent = ELM_PLIST(pcp, PC_EXPONENTS);
    deepthoughtpols = ELM_PLIST(pcp, PC_DEEP_THOUGHT_POLS);
    len = **deepthoughtpols;
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
                mod = ModInt( quo, potenz );
                SET_ELM_PLIST(x, i+1, mod);
                CHANGED_BAG(x);
                if ( gen <= lenpow            &&
                     (prel = ELM_PLIST( powers, gen) )  != 0  )
                {
                    if ( ( IS_INTOBJ(quo) && INT_INTOBJ(quo) >= INT_INTOBJ(potenz) )   ||
                         TNUM_OBJ(quo) == T_INTPOS    )
                    {
                        help = PowerredL( prel,
                                          QuoInt(quo, potenz),
                                          pcp    );
                        help = MultiplyboundredL( help, x, i+2, flag, pcp);
                    }
                    else
                    {
                        quo = INT_INTOBJ(mod) == 0? QuoInt(quo,potenz):SumInt(QuoInt(quo, potenz),INTOBJ_INT(-1));
                        help = PowerredL( prel, 
                                          quo, 
                                          pcp );
                        help = MultiplyboundredL( help, x, i+2, flag, pcp);
                    }
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
    compress(x);
}



Obj      FuncDTmultiplyL( Obj      self,
                          Obj      x,
                          Obj      y,
                          Obj      pcp    )
{
    Obj    MultiplyboundredL(), res;
    void   ReduceWordL();

    if  ( LEN_PLIST(x) == 0 )
        return y;
    if  ( LEN_PLIST(y) == 0 )
        return x;
    res = MultiplyboundredL(x, y, 1, LEN_PLIST(y), pcp);
    ReduceWordL(res, pcp);
    return res;
}



Obj      FuncDTPowerL( Obj       self,
                       Obj       x,
                       Obj       n,
                       Obj       pcp  )
{
    Obj    PowerredL(), res;
    void   ReduceWordL();

    res = PowerredL(x, n, pcp);
    ReduceWordL(res, pcp);
    return res;
}



Obj     FuncDTSolutionL( Obj     self,
                         Obj     x,
                         Obj     y,
                         Obj     pcp )
{
    Obj     SolutionredL(), res;
    void    ReduceWordL();

    if  ( LEN_PLIST(x) == 0 )
        return y;
    res = SolutionredL(x, y, pcp);
    ReduceWordL(res, pcp);
    return res;
}




Obj     FuncWernerProduct( Obj      self,
                           Obj      lword,
                           Obj      rword,
                           Obj      pcp  )
{
    Obj   res, xk;
    UInt  help, len, i, j;

    help = CELM(pcp, 1);
    xk = NEW_PLIST( T_PLIST, help );
    SET_LEN_PLIST(xk, help );
    len = LEN_PLIST(lword);
    j = 1;
    for (i=1; i <= help; i++)
    {
        if ( j >= len  ||  i < CELM(lword, j) )
            SET_ELM_PLIST(xk, i, INTOBJ_INT(0) );
        else
        {
            SET_ELM_PLIST(xk, i, ELM_PLIST(lword, j+1) );
            j+=2;
        }
    }
    CollectPolycyc(pcp, xk, rword);
    res = NEW_PLIST(T_PLIST, 2*help);
    j = 0;
    for (i=1; i <= help; i++)
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


void     compress( Obj        list )
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


Obj      Funccompress( Obj         self, 
                       Obj         list  )
{
    compress(list);
    return  (Obj)0;
}


void     InitDTEvaluation(void)
{

    evlist = RNamName("evlist");
    evlistvec = RNamName("evlistvec");
    
    InitHandlerFunc( Funccompress, "dteval: compress");
    AssGVar( GVarName("Compress"), NewFunctionC("Compress", 1L,
             "list", Funccompress)  );

    InitHandlerFunc( FuncMultiply, "dteval: multiply");
    AssGVar( GVarName("Multiply"), NewFunctionC("Multiply", 3L, 
             "lword, rword, representatives", FuncMultiply)      );

    InitHandlerFunc( FuncPower, "dteval: power");
    AssGVar( GVarName("Power"), NewFunctionC("Power", 3L,
             "word, exponent, representatives", FuncPower)         );

    InitHandlerFunc( FuncDTmultiplyL, "dteval: DTMultiply");
    AssGVar( GVarName("DTMultiply"), NewFunctionC("DTMultiply", 3L,
             "lword, rword, rewritingsystem", FuncDTmultiplyL)    );

    InitHandlerFunc( FuncDTPowerL, "dteval: DTPowerL");
    AssGVar( GVarName("DTPower"), NewFunctionC("DTPower", 3L,
             "word, exponent, rewritingsytem", FuncDTPowerL)  );

    InitHandlerFunc( FuncDTSolutionL, "dteval: DTSolutionL");
    AssGVar( GVarName("DTSolution"), NewFunctionC("DTSolution", 3L,
             "lword, rword, rewritingsystem", FuncDTSolutionL)   );

    InitHandlerFunc( FuncDTCommutatorL, "dteval: DTCommutatorL");
    AssGVar( GVarName("DTCommutator"), NewFunctionC("DTCommutator", 3L,
             "lword, rword, rewritingsystem", FuncDTCommutatorL)    );

    InitHandlerFunc( FuncDTQuotientL, "dteval: DTQuotientL");
    AssGVar( GVarName("DTQuotient"), NewFunctionC("DTQuotient", 3L,
             "lword, rword, rewritingsystem", FuncDTQuotientL)   );

    InitHandlerFunc( FuncDTConjugateL, "dteval: DTConjugateL");
    AssGVar( GVarName("DTConjugate"), NewFunctionC("DTConjugate", 3L,
             "lword, rword, rewritingsystem", FuncDTConjugateL)   );

    InitHandlerFunc( FuncWernerProduct, "dteval: Werner Product");
    AssGVar( GVarName("WernerProduct"), NewFunctionC("WernerProduct", 3L,
             "lword, rword, rewritingsystem", FuncWernerProduct)   );
}

