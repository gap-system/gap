#include       "system.h"
#include       "scanner.h"
#include       "gasman.h"
#include       "objects.h"
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

#define   CELM(list, pos)      (  INT_INTOBJ( ELM_PLIST(list, pos) ) )

static int             evlist, evlistvec, Orders, DeepThoughtPols, Powers;
static int             Exponent;
Obj                    komprimiere;

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
    UInt  i, j;
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
    for ( i=1;
          i <= LEN_PLIST( sum );
          i++ )
    {
	ord = Evaluation( ELM_PLIST( sum, i), copy, power  );
        if ( !IS_INTOBJ(ord)  ||  INT_INTOBJ(ord) != 0 )
	{
	    help = ELM_PLIST(sum1, i);
	    for ( j=1; 
                  j < LEN_PLIST( help );
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
    int  i;
    Obj  prod, help;

    if ( IS_INTOBJ(power)  &&  INT_INTOBJ(power) > 0  &&  
         power < ELM_PLIST(vec, 6)     )
        return INTOBJ_INT(0);
    prod = binomial(power, ELM_PLIST(vec, 6) );
    for (i=7; i < LEN_PLIST(vec); i+=2)
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


void        Mult(
                  Obj    xk,
                  Obj    y,
                  Obj    pseudoreps  )
{
    int     i, help3;
    void    MultGen();

    help3 = LEN_PLIST(y);
    for (i=1; i < help3; i+=2)
        MultGen(xk, CELM( y, i), ELM_PLIST( y, i+1) , pseudoreps);
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




Obj       Multiply(
		     Obj      x,
		     Obj      y,       
                     Obj      pseudoreps  )
{
    UInt   i, j, help, len;
    Obj    xk, res;
    void   Mult();

    if ( LEN_PLIST( x ) == 0 )
        return y;
    if ( LEN_PLIST( y ) == 0 )
        return x;
    help = LEN_PLIST(pseudoreps);
    len = LEN_PLIST(x);
    xk = NEW_PLIST( T_PLIST, help );
    SET_LEN_PLIST(xk, help );
    j = 1;
    for (i=1; i <= help; i++)
    {
        if ( j >= len  ||  i < CELM(x, j) )
	    SET_ELM_PLIST(xk, i, INTOBJ_INT(0) );
	else
	{
	    SET_ELM_PLIST(xk, i, ELM_PLIST(x, j+1) );
	    j+=2;
	}
    }
    Mult(xk, y, pseudoreps);
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
    Obj    Multiply();

    return Multiply(x, y, pseudoreps);
}



Obj      FuncMultiplybound(
		       Obj      self,
		       Obj      x,
		       Obj      y,
                       Obj      anf,
                       Obj      end,
		       Obj      pseudoreps      )
{
    Obj    Multiplybound();

    return Multiplybound(x, y, INT_INTOBJ(anf), INT_INTOBJ(end), pseudoreps);
}




Obj      Power(
                Obj         x,
	        Obj         n,
	        Obj         pseudoreps     )
{
    Obj     res, Solution(), m, y;
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
    if (  TYPE_OBJ(n) == T_INTNEG  ||  INT_INTOBJ(n) < 0  ) 
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
        if ( ModInt(n, INTOBJ_INT(2) ) == INTOBJ_INT(1)  )
	    res = Multiply(res, x, pseudoreps);
	if ( LtInt(INTOBJ_INT(1), n) )
	    x = Multiply(x, x, pseudoreps);
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
    Obj    res, Solution(), Multiply(), help;

    res = Multiply(x, y, pseudoreps);
    help = Multiply(y, x, pseudoreps);
    res = Solution(help, res, pseudoreps);
    return res;
}


Obj       Conjugate( Obj     x,
		     Obj     y,
		     Obj     pseudoreps  )
{
    Obj    res, Solution(), Multiply();

    res = Multiply(x, y, pseudoreps);
    res = Solution(y, res, pseudoreps);
    return res;
}



Obj      Commutatorred( Obj    x,
			Obj    y,
			Obj    pcp  )
{
    Obj    orders, Commutator(), mod, c, res;
    UInt   i, len;

    orders = ElmPRec(pcp, Orders);
    res = Commutator(x, y, ElmPRec( pcp, DeepThoughtPols) );
    len = LEN_PLIST(res);
    for (i=2; i<=len; i+=2)
        if ( CELM(res, i-1) <= LEN_PLIST(orders)         &&
             ( c=ELM_PLIST( orders, CELM( res, i-1 ) )) != 0 )
	{
	    mod = ModInt( ELM_PLIST(res, i), c );
	    SET_ELM_PLIST( res, i, mod);
	    CHANGED_BAG(res);
	}
    return res;
}


Obj      Conjugatered( Obj    x,
			Obj    y,
			Obj    pcp  )
{
    Obj    orders, Conjugate(), mod, c, res;
    UInt   i, len;

    orders = ElmPRec(pcp, Orders);
    res = Conjugate(x, y, ElmPRec( pcp, DeepThoughtPols) );
    len = LEN_PLIST(res);
    for (i=2; i<=len; i+=2)
        if ( CELM(res, i-1) <= LEN_PLIST(orders)         &&
             ( c=ELM_PLIST( orders, CELM( res, i-1 ) )) != 0 )
	{
	    mod = ModInt( ELM_PLIST(res, i), c );
	    SET_ELM_PLIST( res, i, mod);
	    CHANGED_BAG(res);
	}
    return res;
}



Obj       FuncDTCommutator( Obj      self,
                            Obj      x,
		   	    Obj      y,
			    Obj      pcp  )
{
    Obj   res, Commutatorred();
    void  ReduceWord();

    res = Commutatorred(x, y, pcp);
    ReduceWord(res, pcp);
    return res;
}


Obj       FuncDTConjugate( Obj      self,
                           Obj      x,
		   	   Obj      y,
			   Obj      pcp  )
{
    Obj   res, Conjugatered();
    void  ReduceWord();

    if  ( LEN_PLIST(y) == 0 )
        return x;
    res = Conjugatered(x, y, pcp);
    ReduceWord(res, pcp);
    return res;
}





Obj       FuncDTQuotient( Obj      self,
			  Obj      x,
		          Obj      y,
		          Obj      pcp )
{
    Obj     Solutionred(), Multiplyboundred(), help, res;
    void    ReduceWord();

    if  ( LEN_PLIST(y) == 0 )
        return x;
    help = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST(help, 0);
    res = Solutionred(y, help, pcp);
    res = Multiplyboundred(x, res, 1, LEN_PLIST(res), pcp);
    ReduceWord(res, pcp);
    return(res);
}




Obj      Multiplyboundred( Obj     x,
                           Obj     y,
			   UInt    anf,
                           UInt    end,
                           Obj     pcp )
{
    Obj   Multiplybound(), orders, res, mod, c;
    UInt  i, len;

    orders = ElmPRec(pcp, Orders);
    res = Multiplybound(x, y, anf, end, ElmPRec( pcp, DeepThoughtPols) );
    len = LEN_PLIST(res);
    for (i=2; i<=len; i+=2)
        if ( CELM(res, i-1) <= LEN_PLIST(orders)        &&
             ( c=ELM_PLIST( orders, CELM( res, i-1 ) )) != 0 )
	{
	    mod = ModInt( ELM_PLIST(res, i), c );
	    SET_ELM_PLIST( res, i, mod);
	    CHANGED_BAG(res);
	}
    return res;
}





Obj      Powerred( Obj       x,
                   Obj       n,
                   Obj       pcp  )
{
    Obj   Power(),  orders, res, mod, c;
    UInt  i, len;

    orders = ElmPRec(pcp, Orders);
    res = Power(x, n, ElmPRec( pcp, DeepThoughtPols) );
    len = LEN_PLIST(res);
    for (i=2; i<=len; i+=2)
        if ( CELM(res, i-1) <= LEN_PLIST(orders)         &&
             ( c=ELM_PLIST( orders, CELM( res, i-1 ) )) != 0 )
	{
	    mod = ModInt( ELM_PLIST(res, i), c );
	    SET_ELM_PLIST( res, i, mod);
	    CHANGED_BAG(res);
	}
    return res;
}


Obj      Solutionred( Obj       x,
                      Obj       y,
                      Obj       pcp  )
{
    Obj   Solution(),  orders, res, mod, c;
    UInt  i, len;

    orders = ElmPRec(pcp, Orders);
    res = Solution(x, y, ElmPRec( pcp, DeepThoughtPols) );
    len = LEN_PLIST(res);
    for (i=2; i<=len; i+=2)
        if ( CELM(res, i-1) <= LEN_PLIST(orders)       &&
             ( c=ELM_PLIST( orders, CELM( res, i-1 ) )) != 0 )
	{
	    mod = ModInt( ELM_PLIST(res, i), c );
	    SET_ELM_PLIST( res, i, mod);
	    CHANGED_BAG(res);
	}
    return res;
}





void     ReduceWord( Obj      x,
                     Obj      pcp )   
{
    Obj       Powerred(), Multiplyboundred(), powers, exponent;
    Obj       deepthoughtpols, help, potenz, quo, mod, prel;
    UInt      i,j,flag, len, gen;

    powers = ElmPRec(pcp, Powers);
    exponent = ElmPRec(pcp, Exponent);
    deepthoughtpols = ElmPRec(pcp, DeepThoughtPols);
    len = **deepthoughtpols;
    GROW_PLIST(x, 2*len );
    flag = LEN_PLIST(x);
    for (i=1; i<flag; i+=2)
    {
        if ( (gen = CELM(x, i) ) <= LEN_PLIST(exponent)              &&
             (potenz = ELM_PLIST(exponent, gen) ) != 0                    )
	{
	    quo = ELM_PLIST(x, i+1);
	    if  ( !IS_INTOBJ(quo) || INT_INTOBJ(quo) >= INT_INTOBJ(potenz) || 
                  INT_INTOBJ(quo)<0 )
	    {
	        mod = ModInt( quo, potenz );
	        SET_ELM_PLIST(x, i+1, mod);
	        CHANGED_BAG(x);
		if ( gen <= LEN_PLIST(powers)            &&
                     (prel = ELM_PLIST( powers, gen) )  != 0  )
		{
		    if ( ( IS_INTOBJ(quo) && INT_INTOBJ(quo) >= INT_INTOBJ(potenz) )   ||
		         TYPE_OBJ(quo) == T_INTPOS    )
		    {
		        help = Powerred( prel,
			   	         QuoInt(quo, potenz),
				         pcp    );
		        help = Multiplyboundred( help, x, i+2, flag, pcp);
		    }
		    else
		    {
		        quo = INT_INTOBJ(mod) == 0? QuoInt(quo,potenz):SumInt(QuoInt(quo, potenz),INTOBJ_INT(-1));
		        help = Powerred( prel, 
                                         quo, 
                                         pcp );
		        help = Multiplyboundred( help, x, i+2, flag, pcp);
		    }
		    len = LEN_PLIST(help);
		    for (j=1; j<=len; j++)
		        SET_ELM_PLIST(x, j+i+1, ELM_PLIST(help, j) );
		    CHANGED_BAG(x);
		    flag = i+len+1;
		    SET_LEN_PLIST(x, flag);
		}
	    }
	}
    }
    SET_LEN_PLIST(x, flag);
    SHRINK_PLIST(x, flag);
    CALL_1ARGS( komprimiere, x);
}


Obj     FuncReduceWord( Obj      self,
			Obj      x,
			Obj      pcp     )
{
    void      ReduceWord();

    ReduceWord(x, pcp);
    return  0;
}
				     

Obj      FuncDTmultiply( Obj      self,
			 Obj      x,
			 Obj      y,
			 Obj      pcp    )
{
    Obj    Multiplyboundred(), res;
    void   ReduceWord();

    if  ( LEN_PLIST(x) == 0 )
        return y;
    if  ( LEN_PLIST(y) == 0 )
        return x;
    res = Multiplyboundred(x, y, 1, LEN_PLIST(y), pcp);
    ReduceWord(res, pcp);
    return res;
}


Obj      FuncDTPower( Obj       self,
		      Obj       x,
		      Obj       n,
		      Obj       pcp  )
{
    Obj    Powerred(), res;
    void   ReduceWord();

    res = Powerred(x, n, pcp);
    ReduceWord(res, pcp);
    return res;
}


Obj      FuncDTSolution( Obj     self,
		         Obj     x,
			 Obj     y,
		         Obj     pcp )
{
    Obj     Solutionred(), res;
    void    ReduceWord();

    if  ( LEN_PLIST(x) == 0 )
        return y;
    res = Solutionred(x, y, pcp);
    ReduceWord(res, pcp);
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

	

void     InitDTEvaluation(void)
{

    evlist = RNamName("evlist");
    evlistvec = RNamName("evlistvec");
    Orders = RNamName("Orders");
    DeepThoughtPols = RNamName("DeepThoughtPols");
    Powers = RNamName("Power");
    Exponent = RNamName("Exponent");
    AssGVar( GVarName("Multiply"), NewFunctionC("Multiply", 3L, 
             "lword, rword, representatives", FuncMultiply)      );
    AssGVar( GVarName("Pover"), NewFunctionC("Pover", 3L,
             "word, exponent, representatives", FuncPower)         );
    AssGVar( GVarName("Multiplybound"), NewFunctionC("Multiplybound", 5L,
             "lword, rword, beginning, end, representatives", 
              FuncMultiplybound)       );
    AssGVar( GVarName("ReduceWordC"), NewFunctionC("ReduceWordC", 2L,
	     "word, rewritingsystem", FuncReduceWord )      );
    AssGVar( GVarName("DTMultiply"), NewFunctionC("DTMultiply", 3L,
             "lword, rword, rewritingsystem", FuncDTmultiply)    );
    AssGVar( GVarName("DTPower"), NewFunctionC("DTPower", 3L,
             "word, exponent, rewritingsytem", FuncDTPower)  );
    AssGVar( GVarName("DTSolution"), NewFunctionC("DTSolution", 3L,
             "lword, rword, rewritingsystem", FuncDTSolution)   );
    AssGVar( GVarName("DTCommutator"), NewFunctionC("DTCommutator", 3L,
             "lword, rword, rewritingsystem", FuncDTCommutator)    );
    AssGVar( GVarName("DTQuotient"), NewFunctionC("DTQuotient", 3L,
             "lword, rword, rewritingsystem", FuncDTQuotient)   );
    AssGVar( GVarName("DTConjugate"), NewFunctionC("DTConjugate", 3L,
             "lword, rword, rewritingsystem", FuncDTConjugate)   );
    AssGVar( GVarName("WernerProduct"), NewFunctionC("WernerProduct", 3L,
             "lword, rword, rewritingsystem", FuncWernerProduct)   );
    InitFopyGVar(GVarName("komprimiere"), &komprimiere);
}
