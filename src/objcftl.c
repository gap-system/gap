/****************************************************************************
**
*A  pcc.c                       GAP source                   Werner Nickel
**
**
**  This file contains a collector from thye left for polycyclic
**  presentations.
*/

#include "system.h"
#include "scanner.h"
#include "gasman.h"
#include "objects.h"
#include "plist.h"
#include "gvars.h"
#include "calls.h"
#include "records.h"
#include "precord.h"
#include "gap.h"
#include "bool.h"
#include "integer.h"

#include "dt.h"
#include "objcftl.h"



static UInt DebugPcc;
static void DbPr( char *str, long arg1, long arg2 ) {
    if( VAL_GVAR( DebugPcc ) == True )
        Pr( str, arg1, arg2 );
}

static void DbPrintObj( Obj v ) {
    if( VAL_GVAR( DebugPcc ) == True )
        PrintObj( v );
}

static Obj PowerAutomorphism;

Obj CollectPolycyc (
    Obj pcp,
    Obj list,
    Obj word )
{
    Int    ngens   = INT_INTOBJ( ADDR_OBJ(pcp)[ PC_NUMBER_OF_GENERATORS ] );
    Obj    commute = ADDR_OBJ(pcp)[ PC_COMMUTE ];

    Obj    pow     = ADDR_OBJ(pcp)[ PC_POWERS ];
    Obj    ipow    = ADDR_OBJ(pcp)[ PC_INVERSEPOWERS ];
    Obj    exp     = ADDR_OBJ(pcp)[ PC_EXPONENTS ];

    Obj    dtpols  = ADDR_OBJ(pcp)[ PC_DEEP_THOUGHT_POLS ];
    Int    dtbound = INT_INTOBJ( ADDR_OBJ(pcp)[ PC_DEEP_THOUGHT_BOUND ] );

    Obj    wst  = ADDR_OBJ(pcp)[ PC_WORD_STACK ];
    Obj    west = ADDR_OBJ(pcp)[ PC_WORD_EXPONENT_STACK ];
    Obj    sst  = ADDR_OBJ(pcp)[ PC_SYLLABLE_STACK ];
    Obj    est =  ADDR_OBJ(pcp)[ PC_EXPONENT_STACK ];

    Obj    conj, iconj, powers;

    Int    st, bottom = INT_INTOBJ( ADDR_OBJ(pcp)[ PC_STACK_POINTER ] );

    Int    g, syl, h;

    Obj    e, ge, mge, we;
    Obj    w, x = (Obj)0;

    extern Obj BinaryPower();

    if( LEN_PLIST(list) < ngens ) {
      ErrorQuit( "vector too short", 0L, 0L );
      return (Obj)0;
    }

    st = bottom + 1;
    SET_ELM_PLIST( wst,  st, word );
    SET_ELM_PLIST( west, st, INTOBJ_INT(1) );
    SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) );
    SET_ELM_PLIST( est,  st, ELM_PLIST( word, 2 ) ); 

    DbPr( "Entering collector at %d\n", (long)st, 0L );
    DbPrintObj( word ); DbPr( "\n", 0L, 0L );
    DbPrintObj( list ); DbPr( "\n", 0L, 0L );
    
    while( st > bottom ) {

      w   = ELM_PLIST( wst, st );
      syl = INT_INTOBJ( ELM_PLIST( sst, st ) );
      g   = INT_INTOBJ( ELM_PLIST( w, syl )  );

      DbPr( "Collecting generator %d\n", (long)g, 0L );
      /*
      ** Look at g and choose one of three collection methods:
      **   a) commute
      **      1) (x1 x2 ... xn)^e can be rewritten as x1^e x2^e ... xn^e if
      **         x1 == Commute[ x1 ].
      **      2) xi^e can be collected in one step if xi == Commute[ xi ].
      **   b) Deep Thought
      **   c) collection from the left
      */
      if( syl == 1 ) {
        /* Do something about the word exponent. */
        we = ELM_PLIST( west, st );
        if( !IS_INTOBJ(we) || INT_INTOBJ(we) > 1 ) {
          if( g == INT_INTOBJ( ELM_PLIST(commute, g) ) ) {
            x = NEW_PLIST( T_PLIST, LEN_PLIST(w) );
            SET_LEN_PLIST( x, LEN_PLIST(w) );
            for( syl = 1; syl <= LEN_PLIST(w); syl += 2 ) {
              SET_ELM_PLIST( x, syl,   ELM_PLIST( w, syl ) );
              e = ProdInt( ELM_PLIST( w, syl+1 ), we );
              SET_ELM_PLIST( x, syl+1, e );
              CHANGED_BAG(x);
            }
            we = INTOBJ_INT(1);
          }
          else if( g >= dtbound ) {
            x = Power( w, we, dtpols );
            we = INTOBJ_INT(1);
          }
          else {
            /* Here we need the treatment of huge exponents via the Russian
            ** peasant method. */
            if( !IS_INTOBJ(we) || we != INTOBJ_INT(1) ) {
              ADDR_OBJ(pcp)[ PC_STACK_POINTER ] = INTOBJ_INT( st );
              x = BinaryPower( pcp, w, we );
              we = INTOBJ_INT(1);
            }
          }
          SET_ELM_PLIST( wst,  st, x );
          SET_ELM_PLIST( west, st, we );
          SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) );
          SET_ELM_PLIST( est,  st, ELM_PLIST( x, 2 ));
          CHANGED_BAG( wst ); CHANGED_BAG( west );

          /* Reset w, syl and g. */
          w   = ELM_PLIST( wst, st );
          syl = INT_INTOBJ( ELM_PLIST( sst, st ) );
          g   = INT_INTOBJ( ELM_PLIST( w, syl )  );
        }
      }

      if( g == INT_INTOBJ( ELM_PLIST(commute, g) ) ) {
        e = SumInt( ELM_PLIST( list, g ), ELM_PLIST( est, st ) );
        SET_ELM_PLIST( list, g, e );
        SET_ELM_PLIST( est, st, INTOBJ_INT(0) );
        CHANGED_BAG( list );
      }
      else if( g >= dtbound ) {
        DbPr( "Using Deep thought\n", 0L, 0L );
        MultGen( list, g, ELM_PLIST( est, st ), dtpols );
        SET_ELM_PLIST( est, st, INTOBJ_INT(0) );
        /*
        ** Put the result onto the stack because exponents may have to be
        ** reduced.
        */
        x = NEW_PLIST( T_PLIST, 2*ngens );
        for( syl = 1, h = g+1; h <= ngens; h++ )
          if( ELM_PLIST( list, h ) != INTOBJ_INT(0) ) {
            SET_ELM_PLIST( x, syl,   INTOBJ_INT(h) );
            SET_ELM_PLIST( x, syl+1, ELM_PLIST(list,h) );
            syl += 2;
            SET_ELM_PLIST( list, h, INTOBJ_INT(0) );
          }
        if( syl > 1 ) {
          SET_LEN_PLIST( x, syl-1 );
          SHRINK_PLIST(  x, syl-1 );
          CHANGED_BAG(x);
          st++;
          SET_ELM_PLIST( wst,  st, x );
          SET_ELM_PLIST( west, st, INTOBJ_INT(1) );
          SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) );
          SET_ELM_PLIST( est,  st, ELM_PLIST( x, 2 ));
          CHANGED_BAG( wst ); CHANGED_BAG( est );
        }
      }
      else {
        /* Assume that the top of the exponent stack is non-zero. */
        e = ELM_PLIST( est, st );
        SET_ELM_PLIST( est, st, INTOBJ_INT(0) );

        DbPr( "Calling PowerAutomorphism with %d ", (long)g, 0L );
        DbPrintObj( e ); DbPr( "\n", 0L, 0L );
        ADDR_OBJ(pcp)[ PC_STACK_POINTER ] = INTOBJ_INT( st );
        powers = CALL_3ARGS( PowerAutomorphism, pcp, INTOBJ_INT(g), e );
        conj   = ELM_PLIST( powers, 1 );
        iconj  = ELM_PLIST( powers, 2 );

        e = SumInt( ELM_PLIST( list, g ), e );
        SET_ELM_PLIST( list, g, e );  CHANGED_BAG( list );
        
        for( h = INT_INTOBJ(ELM_PLIST( commute, g )); h > g; h-- ) {
          e = ELM_PLIST( list, h );
          if( !IS_INTOBJ(e) || INT_INTOBJ(e) != 0 ) {
            SET_ELM_PLIST( list, h, INTOBJ_INT(0) );
            if( LtInt( INTOBJ_INT(0), e ) ) {
              x = ELM_PLIST( conj, h );
            }
            else if( LtInt( e, INTOBJ_INT(0) ) ) {
              e = ProdInt( e, INTOBJ_INT(-1) );
              x = ELM_PLIST( iconj, h );
            }
            st++; 
            SET_ELM_PLIST( wst,  st, x );
            SET_ELM_PLIST( west, st, e );
            SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) );
            SET_ELM_PLIST( est,  st, ELM_PLIST( x, 2 ) );
            CHANGED_BAG( west ); CHANGED_BAG( est ); 
          }
        }
      }

      /* Reduce the exponent. */
      if( g <= LEN_PLIST(exp) && (e = ELM_PLIST( exp, g )) != (Obj)0 ) {
        ge = ELM_PLIST( list, g );
        x = (Obj)0;
        if( !LtInt( ge, e ) ) {
          mge = ModInt( ge, e );
          SET_ELM_PLIST( list, g, mge );
          CHANGED_BAG( list );
          if( g <= LEN_PLIST( pow ) && (x = ELM_PLIST( pow, g )) != (Obj)0 )
            ge = QuoInt( ge, e );
        }
        else if( LtInt( ge, INTOBJ_INT(0) ) ) {
          mge = ModInt( ge, e );
          SET_ELM_PLIST( list, g, mge );
          CHANGED_BAG( list )
          if( g <= LEN_PLIST(ipow) && (x = ELM_PLIST( ipow, g )) != (Obj)0 ) {
            ge = QuoInt( ge, e );
            if( !EqInt( mge, INTOBJ_INT(0) ) ) ge = DiffInt( ge,INTOBJ_INT(1) );
            ge = ProdInt( ge, INTOBJ_INT(-1) );
          }
        }
        
        if( x != (Obj)0 ) {
            st++;
            SET_ELM_PLIST( wst,  st, x );
            SET_ELM_PLIST( west, st, ge );
            SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) );
            SET_ELM_PLIST( est,  st, ELM_PLIST( x, 2 ) );
            CHANGED_BAG( west ); CHANGED_BAG( est );
        }
      }

      while( st > bottom && EqInt( ELM_PLIST( est, st ), INTOBJ_INT(0) ) ) {
        DbPr( "Exponent stack shows zero\n", 0L, 0L );
        w   = ELM_PLIST( wst, st );
        DbPrintObj( list ); DbPr( "\n", 0L, 0L );
        DbPrintObj( w ); DbPr( "\n", 0L, 0L );
        syl = INT_INTOBJ( ELM_PLIST( sst, st ) ) + 2;
        DbPr( "Syllable: %d\n", (long)syl, 0L );
        if( syl > LEN_PLIST( w ) ) {
          DbPr( "Syllable exceeded word length\n", 0L, 0L );
          we = DiffInt( ELM_PLIST( west, st ), INTOBJ_INT(1) );
          if( EqInt( we, INTOBJ_INT(0) ) ) {
            DbPr( "Word exponent stack shows zero\n", 0L, 0L );
            st--;
          }
          else {
            SET_ELM_PLIST( west, st, we );
            SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) );
            SET_ELM_PLIST( est,  st, ELM_PLIST( w, 2 ) );
            CHANGED_BAG( west ); CHANGED_BAG( est );
          }
        }
        else {
          SET_ELM_PLIST( sst, st, INTOBJ_INT(syl) );
          SET_ELM_PLIST( est, st, ELM_PLIST( w, syl+1 ));
          CHANGED_BAG( est );
        }
      }
    }
    DbPr( "\n", 0L, 0L );

    ADDR_OBJ(pcp)[ PC_STACK_POINTER ] = INTOBJ_INT( bottom );
    DbPr( "Exiting collector at %d\n", (long)st, 0L );

    return (Obj)0;
}

Obj FuncCollectPolycyc (
    Obj self,
    Obj pcp,
    Obj list,
    Obj word )
{
  CollectPolycyc( pcp, list, word );
  return (Obj)0;
}

Obj BinaryPower( Obj pcp, Obj w, Obj e ) {

    Int    ngens   = INT_INTOBJ( ADDR_OBJ(pcp)[ PC_NUMBER_OF_GENERATORS ] );
    Int    g, syl;

    Obj    ev, f, result;
    
    DbPr( "Running BinaryPower with ", 0L, 0L );
    DbPrintObj( w ); DbPr( " and ", 0L, 0L );
    DbPrintObj( e ); DbPr( ".\n", 0L, 0L );
    
    /* copy w into a list of length 2*ngens. */
    f = NEW_PLIST( T_PLIST, 2*ngens );
    for( syl = 1; syl <= LEN_PLIST(w); syl++ )
      SET_ELM_PLIST( f, syl, ELM_PLIST( w, syl ) );
    SET_LEN_PLIST( f, syl-1 ); CHANGED_BAG(f);
    w = f;

    /* convert w into an exponent vector. */
    ev = NEW_PLIST( T_PLIST, ngens ); SET_LEN_PLIST( ev, ngens );
    for( g = 1; g <= ngens; g++ )
      ELM_PLIST( ev, g ) = INTOBJ_INT(0);
    for( syl = 1; syl <= LEN_PLIST(w); syl += 2 ) {
      g = INT_INTOBJ( ELM_PLIST( w, syl ) );
      SET_ELM_PLIST( ev, g, ELM_PLIST( w, syl+1 ) );
    }
    CHANGED_BAG(ev);

    /* allocate space for the result. */
    result = NEW_PLIST( T_PLIST, ngens ); SET_LEN_PLIST( result, ngens );
    for( g = 1; g <= ngens; g++ )
      ELM_PLIST( result, g ) = INTOBJ_INT(0);
    
    while( !IS_INTOBJ(e) || e != INTOBJ_INT(0) ) {
      if( ModInt( e, INTOBJ_INT(2) ) == INTOBJ_INT(1) )
        CollectPolycyc( pcp, result, w ); 

      e = QuoInt( e, INTOBJ_INT(2) );
      if( !IS_INTOBJ(e) || e != INTOBJ_INT(0) ) {
        CollectPolycyc( pcp, ev, w );
        /* copy ev back into w. */
        for( syl = g = 1; g <= ngens; g++ ) {
          f = ELM_PLIST( ev, g );
          if( !IS_INTOBJ(f) || f != INTOBJ_INT(0) ) {
            ELM_PLIST( w, syl++ ) = INTOBJ_INT(g);
            ELM_PLIST( w, syl++ ) = f;
          }
        }
        SET_LEN_PLIST( w, syl-1 ); CHANGED_BAG(w);
      }
    }

    /* convert result into a word, use w for that. */
    for( syl = g = 1; g <= ngens; g++ ) {
      f = ELM_PLIST( result, g );
      if( !IS_INTOBJ( f ) || f != INTOBJ_INT(0) ) {
        ELM_PLIST( w, syl++ ) = INTOBJ_INT(g);
        ELM_PLIST( w, syl++ ) = f;
      }
    }
    SET_LEN_PLIST( w, syl-1 ); CHANGED_BAG(w);

    DbPr( "Returning from BinaryPower with ", 0L, 0L );
    DbPrintObj( w ); DbPr( "\n", 0L, 0L );
    
    return w;
}

Obj FunBinaryPower( Obj self, Obj pcp, Obj w, Obj e ) {

  return BinaryPower( pcp, w, e );
}

void InitPcc ( void ) {

    AssGVar( GVarName( "DTBound" ), INTOBJ_INT(1) );

    DebugPcc = GVarName( "DebugPcc" );
    AssGVar( DebugPcc, False );

    AssGVar( GVarName( "PC_NUMBER_OF_GENERATORS" ),
            INTOBJ_INT( PC_NUMBER_OF_GENERATORS ) );
    AssGVar( GVarName( "PC_GENERATORS" ),
            INTOBJ_INT( PC_GENERATORS ) );
    AssGVar( GVarName( "PC_INVERSES" ),
            INTOBJ_INT( PC_INVERSES ) );
    AssGVar( GVarName( "PC_COMMUTE" ),
            INTOBJ_INT( PC_COMMUTE ) );
    AssGVar( GVarName( "PC_POWERS" ),
            INTOBJ_INT( PC_POWERS ) );
    AssGVar( GVarName( "PC_INVERSEPOWERS" ),
            INTOBJ_INT( PC_INVERSEPOWERS ) );
    AssGVar( GVarName( "PC_EXPONENTS" ),
            INTOBJ_INT( PC_EXPONENTS ) );
    AssGVar( GVarName( "PC_CONJUGATES" ),
            INTOBJ_INT( PC_CONJUGATES ) );
    AssGVar( GVarName( "PC_INVERSECONJUGATES" ),
            INTOBJ_INT( PC_INVERSECONJUGATES ) );
    AssGVar( GVarName( "PC_CONJUGATESINVERSE" ),
            INTOBJ_INT( PC_CONJUGATESINVERSE ) );
    AssGVar( GVarName( "PC_INVERSECONJUGATESINVERSE" ),
            INTOBJ_INT( PC_INVERSECONJUGATESINVERSE ) );
    AssGVar( GVarName( "PC_DEEP_THOUGHT_POLS" ),
            INTOBJ_INT( PC_DEEP_THOUGHT_POLS ) );
    AssGVar( GVarName( "PC_DEEP_THOUGHT_BOUND" ),
            INTOBJ_INT( PC_DEEP_THOUGHT_BOUND ) );
    AssGVar( GVarName( "PC_ORDERS" ), INTOBJ_INT( PC_ORDERS ) );
    AssGVar( GVarName( "PC_WORD_STACK" ),
            INTOBJ_INT( PC_WORD_STACK ) );
    AssGVar( GVarName( "PC_STACK_SIZE" ),
            INTOBJ_INT( PC_STACK_SIZE ) );
    AssGVar( GVarName( "PC_WORD_EXPONENT_STACK" ),
            INTOBJ_INT( PC_WORD_EXPONENT_STACK ) );
    AssGVar( GVarName( "PC_SYLLABLE_STACK" ),
            INTOBJ_INT( PC_SYLLABLE_STACK ) );
    AssGVar( GVarName( "PC_EXPONENT_STACK" ),
            INTOBJ_INT( PC_EXPONENT_STACK ) );
    AssGVar( GVarName( "PC_STACK_POINTER" ),
            INTOBJ_INT( PC_STACK_POINTER ) );
    AssGVar( GVarName( "PC_DEFAULT_KIND" ), INTOBJ_INT( PC_DEFAULT_KIND ) );

    /* Install internal functions. */
    AssGVar( GVarName( "CollectPolycyclic" ), 
        NewFunctionC( "CollectPolycyclic", 3L, 
                    "pcp, list, word", FuncCollectPolycyc ) );
    AssGVar( GVarName( "BinaryPower" ), 
        NewFunctionC( "BinaryPower", 3L, 
                    "pcp, word, exponent", FunBinaryPower ) );

    /* Keep track of variables containing library functions called in this
    ** module. */
    InitFopyGVar( GVarName("PowerAutomorphism"), &PowerAutomorphism );

}
