/****************************************************************************
**
*W  objcftl.c                      GAP source                   Werner Nickel
**
**  Objects Collected From The Left.
**  This file contains a collector from the left for polycyclic
**  presentations.
**
**  This code (in particular the function "CollectPolycyc") is used exclusively by
**  the polycyclic package. So in an ideal world, we'd turn it into a kernel      
**  extensions that is shipped with polycyclic. However, doing so could lead to a 
**  significant number of people not being able to use polycyclic (as they would   
**  not know how to compile a kernel extension). And polycyclic is a very central 
**  package upon which tons of other packages depend... so for now, we leave this 
**  code here.                                                                    
*/
#include <src/system.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */
#include <src/gvars.h>                  /* global variables */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/gap.h>                    /* error handling, initialisation */
#include <src/bool.h>                   /* booleans */
#include <src/integer.h>                /* integers */
#include <src/ariths.h>                 /* fast integers */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */

#include <src/dt.h>                     /* deep thought */

#include <src/objcftl.h>                /* from the left collect */

#include <src/hpc/guards.h>


#define IS_INT_ZERO( n )  ((n) == INTOBJ_INT(0))

#define GET_COMMUTE( g )  INT_INTOBJ(ELM_PLIST(commute,(g))) 

#define GET_EXPONENT( g ) ( ((g) <= LEN_PLIST(exp)) ? \
                            ELM_PLIST( exp, (g) ) : (Obj)0 )
#define GET_POWER( g )    ( ((g) <= LEN_PLIST(pow)) ? \
                            ELM_PLIST( pow, (g) ) : (Obj)0 )
#define GET_IPOWER( g )   ( ((g) <= LEN_PLIST(ipow)) ? \
                            ELM_PLIST( ipow, (g) ) : (Obj)0 )

#define GET_CONJ( h, g ) ( (h <= LEN_PLIST( conj ) && \
                            g <= LEN_PLIST(ELM_PLIST( conj, h ))) ? \
                           ELM_PLIST( ELM_PLIST( conj, h ), g ) : (Obj)0 )

#define GET_ICONJ( h, g ) ( (h <= LEN_PLIST( iconj ) && \
                             g <= LEN_PLIST(ELM_PLIST( iconj, h ))) ? \
                            ELM_PLIST( ELM_PLIST( iconj, h ), g ) : (Obj)0 )

#define PUSH_STACK( word, exp ) {  \
  st++; \
  SET_ELM_PLIST( wst,  st, word ); \
  SET_ELM_PLIST( west, st, exp );  \
  SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) ); \
  SET_ELM_PLIST( est,  st, ELM_PLIST( word, 2 ) ); \
  CHANGED_BAG( wst ); CHANGED_BAG( west ); CHANGED_BAG( est ); }

                                
void AddIn( Obj list, Obj w, Obj e ) {

  Int    g,  i;
  Obj    r,  s,  t;

  for( i = 1; i < LEN_PLIST(w); i += 2 ) {
      g = INT_INTOBJ( ELM_PLIST( w, i ) );

      s = ELM_PLIST( w, i+1 );
      C_PROD_FIA( t, s, e );      /*   t = s * e   */

      r = ELM_PLIST( list, g );
      C_SUM_FIA( s, t, r );       /*   s = r + s * e   */

      SET_ELM_PLIST( list, g, s );  CHANGED_BAG( list );
  }

}

Obj CollectPolycyc (
    Obj pcp,
    Obj list,
    Obj word )
{
    Int    ngens   = INT_INTOBJ( ADDR_OBJ(pcp)[ PC_NUMBER_OF_GENERATORS ] );
    Obj    commute = ADDR_OBJ(pcp)[ PC_COMMUTE ];

    Obj    gens    = ADDR_OBJ(pcp)[ PC_GENERATORS ];
    Obj    igens   = ADDR_OBJ(pcp)[ PC_INVERSES ];

    Obj    pow     = ADDR_OBJ(pcp)[ PC_POWERS ];
    Obj    ipow    = ADDR_OBJ(pcp)[ PC_INVERSEPOWERS ];
    Obj    exp     = ADDR_OBJ(pcp)[ PC_EXPONENTS ];

    Obj    wst  = ADDR_OBJ(pcp)[ PC_WORD_STACK ];
    Obj    west = ADDR_OBJ(pcp)[ PC_WORD_EXPONENT_STACK ];
    Obj    sst  = ADDR_OBJ(pcp)[ PC_SYLLABLE_STACK ];
    Obj    est  = ADDR_OBJ(pcp)[ PC_EXPONENT_STACK ];

    Obj    conj=0, iconj=0;   /*QQ initialize to please compiler */

    Int    st, bottom = INT_INTOBJ( ADDR_OBJ(pcp)[ PC_STACK_POINTER ] );

    Int    g, syl, h, hh;

    Obj    e, ee, ge, mge, we, s, t;
    Obj    w, x = (Obj)0, y = (Obj)0;


    if( LEN_PLIST(word) == 0 ) return (Obj)0;

    if( LEN_PLIST(list) < ngens ) {
        ErrorQuit( "vector too short", 0L, 0L );
        return (Obj)0;
    }
    if( LEN_PLIST(word) % 2 != 0 ) {
        ErrorQuit( "Length of word odd", 0L, 0L );
        return (Obj)0;
    }

    st = bottom;
    PUSH_STACK( word, INTOBJ_INT(1) );

    while( st > bottom ) {

      w   = ELM_PLIST( wst, st );
      syl = INT_INTOBJ( ELM_PLIST( sst, st ) );
      g   = INT_INTOBJ( ELM_PLIST( w, syl )  );

      if( st > bottom+1 && syl==1 && g == GET_COMMUTE(g) ) {
        /* Collect word^exponent in one go. */

        e = ELM_PLIST( west, st );

        /* Add in. */
        AddIn( list, w, e );

        /* Reduce. */
        for( h = g; h <= ngens; h++ ) {
          s = ELM_PLIST( list, h );
          if( IS_INT_ZERO( s ) ) continue;

          y = (Obj)0;
          if( (e = GET_EXPONENT( h )) != (Obj)0 ) {
              if( !LtInt( s, e ) ) {
                  t = ModInt( s, e );
                  SET_ELM_PLIST( list, h, t ); CHANGED_BAG( list );
                  if( (y = GET_POWER( h )) ) e = QuoInt( s, e );
              }
              else if( LtInt( s, INTOBJ_INT(0) ) ) {
                  t = ModInt( s, e );
                  SET_ELM_PLIST( list, h, t ); CHANGED_BAG( list );
              
                  if( (y = GET_IPOWER( h )) ) {
                      e = QuoInt( s, e );
                      if( !IS_INT_ZERO( t ) ) e = DiffInt( e, INTOBJ_INT(1) );
                      e = ProdInt( e, INTOBJ_INT(-1) );
                  }
              }
          }
          if( y != (Obj)0 ) AddIn( list, y, e );

        }

        st--;

      }
      else {
        if( g == GET_COMMUTE( g ) ) {
          s = ELM_PLIST( list, g ); 
          t = ELM_PLIST( est, st ); 
          C_SUM_FIA( ge, s, t );
          SET_ELM_PLIST( est, st, INTOBJ_INT(0) );
        }
        else {
          /* Assume that the top of the exponent stack is non-zero. */
          e = ELM_PLIST( est, st );
          
          if( LtInt( INTOBJ_INT(0), e ) ) {
            C_DIFF_FIA( ee, e, INTOBJ_INT(1) );  e = ee;
            SET_ELM_PLIST( est, st, e );
            conj  = ADDR_OBJ(pcp)[PC_CONJUGATES];
            iconj = ADDR_OBJ(pcp)[PC_INVERSECONJUGATES];
            
            C_SUM_FIA( ge, ELM_PLIST( list, g ), INTOBJ_INT(1) );
          }
          else {
            C_SUM_FIA( ee, e, INTOBJ_INT(1) );  e = ee;
            SET_ELM_PLIST( est, st, e );
            conj  = ADDR_OBJ(pcp)[PC_CONJUGATESINVERSE];
            iconj = ADDR_OBJ(pcp)[PC_INVERSECONJUGATESINVERSE];
            
            C_DIFF_FIA( ge, ELM_PLIST( list, g ), INTOBJ_INT(1) );
          }
        }
        SET_ELM_PLIST( list, g, ge );  CHANGED_BAG( list );


        /* Reduce the exponent.  We delay putting the power onto the 
           stack until all the conjugates are on the stack.  The power is
           stored in  y, its exponent in ge.  */
        y = (Obj)0;
        if( (e = GET_EXPONENT( g )) ) {
            if( !LtInt( ge, e ) ) {
                mge = ModInt( ge, e );
                SET_ELM_PLIST( list, g, mge ); CHANGED_BAG( list );
            
                if( (y = GET_POWER( g )) ) ge = QuoInt( ge, e );
            }
            else if( LtInt( ge, INTOBJ_INT(0) ) ) {
                mge = ModInt( ge, e );
                SET_ELM_PLIST( list, g, mge ); CHANGED_BAG( list );
            
                if( (y = GET_IPOWER( g )) ) {
                    ge = QuoInt( ge, e );
                    if( !IS_INT_ZERO( mge ) ) 
                        ge = DiffInt( ge, INTOBJ_INT(1) );
                    ge = ProdInt( ge, INTOBJ_INT(-1) );
                }
            }
        }
        
        hh = h = GET_COMMUTE( g );
        
        /* Find the place where we start to collect. */
        for( ; h > g; h-- ) {
            e = ELM_PLIST( list, h );
            if( !IS_INT_ZERO(e) ) {
            
                if( LtInt( INTOBJ_INT(0), e ) ) {
                    if( GET_CONJ( h, g ) ) break;
                }
                else {
                    if( GET_ICONJ( h, g ) ) break;
                }
            }
        }

        /* Put those onto the stack, if necessary. */
        if( h > g || y != (Obj)0 ) 
          for( ; hh > h; hh-- ) {
            e = ELM_PLIST( list, hh );
            if( !IS_INT_ZERO(e) ) {
              SET_ELM_PLIST( list, hh, INTOBJ_INT(0) );
              
              if( LtInt( INTOBJ_INT(0), e ) ) {
                  x = ELM_PLIST(  gens, hh );
              }
              else {
                  x = ELM_PLIST( igens, hh );
                  C_PROD_FIA( ee, e, INTOBJ_INT(-1) );  e = ee;
              }
              
              PUSH_STACK( x, e );
            }
          }
        
        
        for( ; h > g; h-- ) {
          e = ELM_PLIST( list, h );
          if( !IS_INT_ZERO(e) ) {
            SET_ELM_PLIST( list, h, INTOBJ_INT(0) );
            
            x = (Obj)0;
            if( LtInt( INTOBJ_INT(0), e ) ) x = GET_CONJ( h, g );
            else                            x = GET_ICONJ( h, g );
            
            if( x == (Obj)0 )  {
              if( LtInt( INTOBJ_INT(0), e ) ) x = ELM_PLIST(  gens, h );
              else                            x = ELM_PLIST( igens, h );
            
            }
            if( LtInt( e, INTOBJ_INT(0) ) ) {
              C_PROD_FIA( ee, e, INTOBJ_INT(-1) );  e = ee;
            }
            PUSH_STACK( x, e );
          }
        }
        
        if( y != (Obj)0 ) PUSH_STACK( y, ge );
      }

      while( st > bottom && IS_INT_ZERO( ELM_PLIST( est, st ) ) ) {
        w   = ELM_PLIST( wst, st );
        syl = INT_INTOBJ( ELM_PLIST( sst, st ) ) + 2;
        if( syl > LEN_PLIST( w ) ) {
          we = DiffInt( ELM_PLIST( west, st ), INTOBJ_INT(1) );
          if( EqInt( we, INTOBJ_INT(0) ) ) { st--; }
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

    ADDR_OBJ(pcp)[ PC_STACK_POINTER ] = INTOBJ_INT( bottom );
    return (Obj)0;
}

Obj FuncCollectPolycyclic (
    Obj self,
    Obj pcp,
    Obj list,
    Obj word )
{
  CollectPolycyc( pcp, list, word );
  return (Obj)0;
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

    GVAR_FUNC(CollectPolycyclic, 3, "pcp, list, word"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* Keep track of variables containing library functions called in this */
    /* module.                                                             */

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
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
    ExportAsConstantGVar(PC_NUMBER_OF_GENERATORS);
    ExportAsConstantGVar(PC_GENERATORS);
    ExportAsConstantGVar(PC_INVERSES);
    ExportAsConstantGVar(PC_COMMUTE);
    ExportAsConstantGVar(PC_POWERS);
    ExportAsConstantGVar(PC_INVERSEPOWERS);
    ExportAsConstantGVar(PC_EXPONENTS);
    ExportAsConstantGVar(PC_CONJUGATES);
    ExportAsConstantGVar(PC_INVERSECONJUGATES);
    ExportAsConstantGVar(PC_CONJUGATESINVERSE);
    ExportAsConstantGVar(PC_INVERSECONJUGATESINVERSE);
    ExportAsConstantGVar(PC_DEEP_THOUGHT_POLS);
    ExportAsConstantGVar(PC_DEEP_THOUGHT_BOUND);
    ExportAsConstantGVar(PC_ORDERS);
    ExportAsConstantGVar(PC_WORD_STACK);
    ExportAsConstantGVar(PC_STACK_SIZE);
    ExportAsConstantGVar(PC_WORD_EXPONENT_STACK);
    ExportAsConstantGVar(PC_SYLLABLE_STACK);
    ExportAsConstantGVar(PC_EXPONENT_STACK);
    ExportAsConstantGVar(PC_STACK_POINTER);
    ExportAsConstantGVar(PC_DEFAULT_TYPE);

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoPcc() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objcftl",                          /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoPcc ( void )
{
    return &module;
}
