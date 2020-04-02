/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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

#include "objcftl.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "integer.h"
#include "modules.h"
#include "plist.h"


static ModuleStateOffset CFTLStateOffset = -1;

struct CFTLModuleState {
    Obj WORD_STACK;
    Obj WORD_EXPONENT_STACK;
    Obj SYLLABLE_STACK;
    Obj EXPONENT_STACK;
};

extern inline struct CFTLModuleState *CFTLState(void)
{
    return (struct CFTLModuleState *)StateSlotsAtOffset(CFTLStateOffset);
}

static inline Obj IncInt(Obj x)
{
    if (IS_INTOBJ(x) && x != INTOBJ_MAX) {
        return (Obj)((Int)x + (Int)4);
    }
    return SumInt(x, INTOBJ_INT(1));
}

static inline Obj DecInt(Obj x)
{
    if (IS_INTOBJ(x) && x != INTOBJ_MIN) {
        return (Obj)((Int)x - (Int)4);
    }
    return DiffInt(x, INTOBJ_INT(1));
}

static inline Obj FastAInvInt(Obj x)
{
    if (IS_INTOBJ(x) && x != INTOBJ_MIN)
        return INTOBJ_INT(-INT_INTOBJ(x));
    return AInvInt(x);
}

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
  GROW_PLIST( wst,  st ); \
  GROW_PLIST( west, st ); \
  GROW_PLIST( sst,  st ); \
  GROW_PLIST( est,  st ); \
  SET_ELM_PLIST( wst,  st, word ); \
  SET_ELM_PLIST( west, st, exp );  \
  SET_ELM_PLIST( sst,  st, INTOBJ_INT(1) ); \
  SET_ELM_PLIST( est,  st, ELM_PLIST( word, 2 ) ); \
  CHANGED_BAG( wst ); CHANGED_BAG( west ); CHANGED_BAG( est ); }

                                
static void AddIn(Obj list, Obj w, Obj e)
{

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

static Obj CollectPolycyc(Obj pcp, Obj list, Obj word)
{
    Int    ngens   = INT_INTOBJ( CONST_ADDR_OBJ(pcp)[ PC_NUMBER_OF_GENERATORS ] );
    Obj    commute = CONST_ADDR_OBJ(pcp)[ PC_COMMUTE ];

    Obj    gens    = CONST_ADDR_OBJ(pcp)[ PC_GENERATORS ];
    Obj    igens   = CONST_ADDR_OBJ(pcp)[ PC_INVERSES ];

    Obj    pow     = CONST_ADDR_OBJ(pcp)[ PC_POWERS ];
    Obj    ipow    = CONST_ADDR_OBJ(pcp)[ PC_INVERSEPOWERS ];
    Obj    exp     = CONST_ADDR_OBJ(pcp)[ PC_EXPONENTS ];

    Obj    wst  = CFTLState()->WORD_STACK;
    Obj    west = CFTLState()->WORD_EXPONENT_STACK;
    Obj    sst  = CFTLState()->SYLLABLE_STACK;
    Obj    est  = CFTLState()->EXPONENT_STACK;

    Obj    conj=0, iconj=0;   /*QQ initialize to please compiler */

    Int    st;

    Int    g, syl, h, hh;

    Obj    e, ee, ge, mge, we, s, t;
    Obj    w, x = (Obj)0, y = (Obj)0;


    if( LEN_PLIST(word) == 0 ) return (Obj)0;

    if( LEN_PLIST(list) < ngens ) {
        ErrorQuit("vector too short", 0, 0);
    }
    if( LEN_PLIST(word) % 2 != 0 ) {
        ErrorQuit("Length of word odd", 0, 0);
    }

    st = 0;
    PUSH_STACK( word, INTOBJ_INT(1) );

    while( st > 0 ) {

      w   = ELM_PLIST( wst, st );
      syl = INT_INTOBJ( ELM_PLIST( sst, st ) );
      g   = INT_INTOBJ( ELM_PLIST( w, syl )  );

      if( st > 1 && syl==1 && g == GET_COMMUTE(g) ) {
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
              else if( IS_NEG_INT( s ) ) {
                  t = ModInt( s, e );
                  SET_ELM_PLIST( list, h, t ); CHANGED_BAG( list );
              
                  if( (y = GET_IPOWER( h )) ) {
                      e = QuoInt( s, e );
                      if( !IS_INT_ZERO( t ) ) e = DecInt( e );
                      e = AInvInt(e);
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
          
          if( IS_POS_INT( e ) ) {
            e = DecInt( e );
            SET_ELM_PLIST( est, st, e ); CHANGED_BAG( est );
            conj  = CONST_ADDR_OBJ(pcp)[PC_CONJUGATES];
            iconj = CONST_ADDR_OBJ(pcp)[PC_INVERSECONJUGATES];
            
            ge = IncInt( ELM_PLIST( list, g ) );
          }
          else {
            C_SUM_FIA( ee, e, INTOBJ_INT(1) );  e = ee;
            SET_ELM_PLIST( est, st, e ); CHANGED_BAG( est );
            conj  = CONST_ADDR_OBJ(pcp)[PC_CONJUGATESINVERSE];
            iconj = CONST_ADDR_OBJ(pcp)[PC_INVERSECONJUGATESINVERSE];
            
            ge = DecInt( ELM_PLIST( list, g ) );
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
            else if( IS_NEG_INT( ge ) ) {
                mge = ModInt( ge, e );
                SET_ELM_PLIST( list, g, mge ); CHANGED_BAG( list );
            
                if( (y = GET_IPOWER( g )) ) {
                    ge = QuoInt( ge, e );
                    if( !IS_INT_ZERO( mge ) ) 
                        ge = DecInt( ge );
                    ge = AInvInt(ge);
                }
            }
        }
        
        hh = h = GET_COMMUTE( g );
        
        /* Find the place where we start to collect. */
        for( ; h > g; h-- ) {
            e = ELM_PLIST( list, h );
            if( !IS_INT_ZERO(e) ) {
            
                if( IS_POS_INT( e ) ) {
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
              
              if( IS_POS_INT( e ) ) {
                  x = ELM_PLIST(  gens, hh );
              }
              else {
                  x = ELM_PLIST( igens, hh );
                  e = FastAInvInt(e);
              }
              
              PUSH_STACK( x, e );
            }
          }
        
        
        for( ; h > g; h-- ) {
          e = ELM_PLIST( list, h );
          if( !IS_INT_ZERO(e) ) {
            SET_ELM_PLIST( list, h, INTOBJ_INT(0) );
            
            x = IS_POS_INT( e ) ? GET_CONJ( h, g ) : GET_ICONJ( h, g );
            
            if( x == (Obj)0 )  {
              x = IS_POS_INT( e ) ? ELM_PLIST( gens, h ) : ELM_PLIST( igens, h );
            }
            if( IS_NEG_INT( e ) ) {
              e = FastAInvInt(e);
            }
            PUSH_STACK( x, e );
          }
        }
        
        if( y != (Obj)0 ) PUSH_STACK( y, ge );
      }

      while( st > 0 && IS_INT_ZERO( ELM_PLIST( est, st ) ) ) {
        w   = ELM_PLIST( wst, st );
        syl = INT_INTOBJ( ELM_PLIST( sst, st ) ) + 2;
        if( syl > LEN_PLIST( w ) ) {
          we = DecInt( ELM_PLIST( west, st ) );
          if( we == INTOBJ_INT(0) ) { st--; }
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

    return (Obj)0;
}

static Obj FuncCollectPolycyclic(Obj self, Obj pcp, Obj list, Obj word)
{
  CollectPolycyc( pcp, list, word );
  return (Obj)0;
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

    GVAR_FUNC_3ARGS(CollectPolycyclic, pcp, list, word),
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

    // signal to polycyclic that 'CollectPolycyclic' does not use resp.
    // require stacks inside the collector objects
    AssConstantGVar(GVarName("NO_STACKS_INSIDE_COLLECTORS"), True);

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}

static Int InitModuleState(void)
{
    InitGlobalBag( &CFTLState()->WORD_STACK, "WORD_STACK" );
    InitGlobalBag( &CFTLState()->WORD_EXPONENT_STACK, "WORD_EXPONENT_STACK" );
    InitGlobalBag( &CFTLState()->SYLLABLE_STACK, "SYLLABLE_STACK" );
    InitGlobalBag( &CFTLState()->EXPONENT_STACK, "EXPONENT_STACK" );

    CFTLState()->WORD_STACK = NEW_PLIST( T_PLIST, 4096 );
    CFTLState()->WORD_EXPONENT_STACK = NEW_PLIST( T_PLIST, 4096 );
    CFTLState()->SYLLABLE_STACK = NEW_PLIST( T_PLIST, 4096 );
    CFTLState()->EXPONENT_STACK = NEW_PLIST( T_PLIST, 4096 );

    return 0;
}

/****************************************************************************
**
*F  InitInfoPcc() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "objcftl",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(struct CFTLModuleState),
    .moduleStateOffsetPtr = &CFTLStateOffset,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoPcc ( void )
{
    return &module;
}
