/****************************************************************************
**
*W  costab.c                    GAP source                       Frank Celler
*W                                                           & Volkmar Felsch
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of for coset tables.
*/
char * Revision_costab_c =
   "@(#)$Id$";


#include        "system.h"              /* Ints, UInts, SyIsIntr           */
#include        "scanner.h"             /* Pr                              */
#include        "gasman.h"              /* Retype                          */

#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "gvars.h"               /* AssGVar, GVarName               */
#include        "gap.h"                 /* Error                           */

#include        "calls.h"               /* NAMI_FUNC, ENVI_FUNC            */

#include        "bool.h"                /* True, False                     */
#include        "lists.h"               /* lists                           */

#include        "plist.h"               /* plain lists                     */

#define INCLUDE_DECLARATION_PART
#include        "costab.h"              /* declaration part                */
#undef  INCLUDE_DECLARATION_PART


/****************************************************************************
**

*V  declaration of static variables
*/
static Obj      objRel;                 /* handle of a relator             */
static Obj      objNums;                 /* handle of parallel numbers list */
static Obj      objTable;               /* handle of the coset table       */
#if 0
static Obj      hdTabl2;          /* handle of coset factor table    */
#endif
static Obj      objNext;                /*                                 */
static Obj      objPrev;                /*                                 */
#if 0
static Obj      hdFact;           /*                                 */
static Obj      hdTree;           /* handle of subgroup gens tree    */
static Obj      hdTree1;          /* handle of first tree component  */
static Obj      hdTree2;          /* handle of second tree component */

static Obj      hdExponent;       /* handle of subgroup order        */
static Obj      hdWordValue;      /* handle of word value            */

static Int           treeType;         /* tree type                       */
static Int           treeWordLength;   /* maximal tree word length        */
#endif
static Int      firstDef;               /*                                 */
static Int      lastDef;                /*                                 */
static Int      firstFree;              /*                                 */
static Int      lastFree;               /*                                 */

static Int      nrdel;                  /*                                 */

static Int      dedfst;                 /* position of first deduction     */
static Int      dedlst;                 /* position of last deduction      */
static Int      dedgen [40960];         /* deduction list keeping gens     */
static Int      dedcos [40960];         /* deduction list keeping cosets   */
static Int      dedSize = 40960;        /* size of deduction list buffers  */
static Int      dedprint;               /* print flag for warning          */

#if 0
static Int           wordList [1024];  /* coset rep word buffer           */
static Int           wordSize = 1023;  /* maximal no. of coset rep words  */
#endif


/****************************************************************************
**

*F  FuncApplyRel( <self>, <app>, <rel> )   apply a relator to a coset in a TC
**
**  'FuncApplyRel' implements the internal function 'ApplyRel'.
**
**  'ApplyRel( <app>, <rel> )'
**
**  'ApplyRel'  applies the relator  <rel>  to the  application  list  <app>.
**
**  ... more about ApplyRel ...
*/
Obj FuncApplyRel (
    Obj			self,
    Obj                 app,            /* handle of the application list  */
    Obj                 rel )           /* handle of the relator           */
{
    
    Int                 lp;             /* left pointer into relator       */
    Int                 lc;             /* left coset to apply to          */
    Int                 rp;             /* right pointer into relator      */
    Int                 rc;             /* right coset to apply to         */
    Int                 tc;             /* temporary coset                 */

    /* check the application list                                          */
    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    while ( ! IS_PLIST(app) ) {
	app = ErrorReturnObj(
            "<app> must be a plain list (not a %s)",
	    (Int)(InfoBags[TYPE_OBJ(app)].name), 0L,
	    "you can return a list for <app>" );
    }
    if ( LEN_PLIST(app) != 4 ) {
	ErrorQuit( "<app> must be a list of length 4 not %d",
		   (Int) LEN_PLIST(app), 0L );
    }

    /* get the four entries                                                */
    lp = INT_INTOBJ( ELM_PLIST( app, 1 ) );
    lc = INT_INTOBJ( ELM_PLIST( app, 2 ) );
    rp = INT_INTOBJ( ELM_PLIST( app, 3 ) );
    rc = INT_INTOBJ( ELM_PLIST( app, 4 ) );

    /* get and check the relator (well, only a little bit)                 */
    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    while ( ! IS_PLIST(rel) ) {
	rel = ErrorReturnObj(
            "<rel> must be a plain list (not a %s)",
	    (Int)(InfoBags[TYPE_OBJ(rel)].name), 0L,
	    "you can return a list for <rel>" );
    }

    /* fix right pointer if requested                                      */
    if ( rp == -1 )
	rp = lp + INT_INTOBJ( ELM_PLIST( rel, 1 ) );

    /* scan as long as possible from the right to the left                 */
    while ( lp < rp
         && 0 < (tc = INT_INTOBJ(ELM_PLIST(ELM_PLIST(rel,rp),rc))) )
    {
        rc = tc;  rp = rp - 2;
    }

    /* scan as long as possible from the left to the right                 */
    while ( lp < rp
         && 0 < (tc = INT_INTOBJ(ELM_PLIST(ELM_PLIST(rel,lp),lc))) )
    {
        lc = tc;  lp = lp + 2;
    }

    /* copy the information back into the application list                 */
    SET_ELM_PLIST( app, 1, INTOBJ_INT( lp ) );
    SET_ELM_PLIST( app, 2, INTOBJ_INT( lc ) );
    SET_ELM_PLIST( app, 3, INTOBJ_INT( rp ) );
    SET_ELM_PLIST( app, 4, INTOBJ_INT( rc ) );
    CHANGED_BAG(app);

    /* return 'true' if a coincidence or deduction was found               */
    if ( lp == rp+1
	 && INT_INTOBJ(ELM_PLIST(ELM_PLIST(rel,lp),lc)) != rc )
    {
        return True;
    }
    else
        return False;
}


/****************************************************************************
**
*F  CompressDeductionList() . . . .  removes unused items from deduction list
**
**  'CompressDeductionList'  tries to find and delete  deduction list entries
**  which are not used any more.
**
**  'dedgen',  'dedcos',  'dedfst',  'dedlst',  'dedSize' and 'objTable'  are
**  assumed to be known as static variables.
*/
void CompressDeductionList ()
{
    Obj               * ptTable;          /* pointer to the coset table    */
    Int			i;
    Int                 j;

    /* check if the situation is as assumed                                */
    if ( dedlst != dedSize ) {
        ErrorQuit( "invalid call of CompressDeductionList", 0L, 0L );
    }

    /* run through the lists and compress them                             */
    ptTable = ADDR_OBJ( objTable );
    j = 0;
    for ( i = dedfst; i < dedlst; i++ ) {
        if ( INT_INTOBJ(ELM_PLIST(ptTable[dedgen[i]],dedcos[i])) != 0
          && j < i )
        {
            dedgen[j] = dedgen[i];
            dedcos[j] = dedcos[i];
            j++;
        }
    }

    /* update the pointers                                                 */
    dedfst = 1;
    dedlst = j;

    /* check if we have at least one free position                         */
    if ( dedlst == dedSize ) {
        if ( dedprint == 0 ) {
            Pr( "#I  WARNING: deductions being discarded\n", 0L, 0L );
            dedprint = 1;
        }
        dedlst--;
    }
}


/****************************************************************************
**
*F  HandleCoinc( <cos1>, <cos2> ) . . . . . . . . handle coincidences in a TC
**
**  'HandleCoinc'  is a subroutine of 'FuncMakeConsequences'  and handles the
**  coincidence  cos2 = cos1.
*/
void HandleCoinc (
    UInt       		cos1,
    UInt		cos2 )
{
    Obj *               ptTable;        /* pointer to the coset table    */
    Obj *               ptNext;
    Obj *               ptPrev;
    UInt                c1;
    UInt                c2;
    UInt                c3;
    UInt                i;
    UInt                firstCoinc;
    UInt                lastCoinc;
    Obj *               gen;
    Obj *               inv;

    /* is this test necessary?                                             */
    if ( cos1 == cos2 )  return;

    /* get some pointers                                                   */
    ptTable = ADDR_OBJ( objTable );
    ptNext  = ADDR_OBJ( objNext );
    ptPrev  = ADDR_OBJ( objPrev );

    /* take the smaller one as new representative                          */
    if ( cos2 < cos1 ) { c3 = cos1;  cos1 = cos2;  cos2 = c3;  }

    /* if we are removing an important coset update it                     */
    if ( cos2 == lastDef )
        lastDef  = INT_INTOBJ( ptPrev[lastDef ] );
    if ( cos2 == firstDef )
        firstDef = INT_INTOBJ( ptPrev[firstDef] );

    /* remove <cos2> from the coset list                                   */
    ptNext[INT_INTOBJ(ptPrev[cos2])] = ptNext[cos2];
    if ( ptNext[cos2] != INTOBJ_INT( 0 ) )
        ptPrev[INT_INTOBJ(ptNext[cos2])] = ptPrev[cos2];

    /* put the first coincidence into the list of coincidences             */
    firstCoinc        = cos2;
    lastCoinc         = cos2;
    ptNext[lastCoinc] = INTOBJ_INT( 0 );

    /* <cos1> is the representative of <cos2> and its own representative   */
    ptPrev[cos2] = INTOBJ_INT( cos1 );

    /* while there are coincidences to handle                              */
    while ( firstCoinc != 0 ) {

        /* replace <firstCoinc> by its representative in the table         */
        cos1 = INT_INTOBJ( ptPrev[firstCoinc] );  cos2 = firstCoinc;
        for ( i = 1; i <= LEN_PLIST(objTable); i++ ) {
            gen = ADDR_OBJ(ptTable[i]);
            /* inv = ADDR_OBJ(ptTable[ ((i-1)^1)+1 ] ); */
            inv = ADDR_OBJ( ptTable[ i + 2*(i % 2) - 1 ] );

            /* replace <cos2> by <cos1> in the column of <gen>^-1          */
            c2 = INT_INTOBJ( gen[cos2] );
            if ( c2 != 0 ) {
                c1 = INT_INTOBJ( gen[cos1] );

                /* if the other entry is empty copy it                     */
                if ( c1 == 0 )  {
                    gen[cos1] = INTOBJ_INT( c2 );
                    gen[cos2] = INTOBJ_INT( 0 );
                    inv[c2]   = INTOBJ_INT( cos1 );
                    if ( dedlst == dedSize )
			CompressDeductionList( );
                    dedgen[dedlst] = i;
                    dedcos[dedlst] = cos1;
                    dedlst++;
                }

                /* otherwise check for a coincidence                       */
                else {
                    inv[c2]   = INTOBJ_INT( 0 );
                    gen[cos2] = INTOBJ_INT( 0 );
                    if ( gen[cos1] == INTOBJ_INT( 0 ) ) {
                        gen[cos1] = INTOBJ_INT( cos1 );
                        if ( dedlst == dedSize )
			    CompressDeductionList( );
                        dedgen[dedlst] = i;
                        dedcos[dedlst] = cos1;
                        dedlst++;
                    }

                    /* find the representative of <c1>                     */
                    while ( c1 != 1
                        && INT_INTOBJ(ptNext[INT_INTOBJ(ptPrev[c1])]) != c1 )
		    {
                        c1 = INT_INTOBJ(ptPrev[c1]);
                    }

                    /* find the representative of <c2>                     */
                    while ( c2 != 1
                        && INT_INTOBJ(ptNext[INT_INTOBJ(ptPrev[c2])]) != c2 )
		    {
                        c2 = INT_INTOBJ(ptPrev[c2]);
                    }

                    /* if the representatives differ we got a coincindence */
                    if ( c1 != c2 ) {

                        /* take the smaller one as new representative      */
                        if ( c2 < c1 ) { c3 = c1;  c1 = c2;  c2 = c3; }

                        /* if we are removing an important coset update it */
                        if ( c2 == lastDef  )
                            lastDef  = INT_INTOBJ(ptPrev[lastDef ]);
                        if ( c2 == firstDef )
                            firstDef = INT_INTOBJ(ptPrev[firstDef]);

                        /* remove <c2> from the coset list                 */
                        ptNext[INT_INTOBJ(ptPrev[c2])] = ptNext[c2];
                        if ( ptNext[c2] != INTOBJ_INT( 0 ) )
                            ptPrev[INT_INTOBJ(ptNext[c2])] = ptPrev[c2];

                        /* append <c2> to the coincidence list             */
                        ptNext[lastCoinc] = INTOBJ_INT( c2 );
                        lastCoinc         = c2;
                        ptNext[lastCoinc] = INTOBJ_INT( 0 );

                        /* <c1> is the rep of <c2> and its own rep.        */
                        ptPrev[c2] = INTOBJ_INT( c1 );

                    }

                }

            }

        }

        /* move the replaced coset to the free list                        */
        if ( firstFree == 0 ) {
            firstFree      = firstCoinc;
            lastFree       = firstCoinc;
        }
        else {
            ptNext[lastFree] = INTOBJ_INT( firstCoinc );
            lastFree         = firstCoinc;
        }
        firstCoinc = INT_INTOBJ( ptNext[firstCoinc] );
        ptNext[lastFree] = INTOBJ_INT( 0 );

        nrdel++;

    }
}


/****************************************************************************
**
*F  FuncMakeConsequences( <self>, <list> )  find consqs of a coset definition
*/
Obj FuncMakeConsequences (
    Obj			self,
    Obj                 list )
{
    Obj                 hdSubs;         /*                                 */
    Obj                 objRels;         /*                                 */
    Obj *               ptRel;        /* pointer to the relator bag      */
    Obj *               ptNums;       /* pointer to this list            */
    long                lp;             /* left pointer into relator       */
    long                lc;             /* left coset to apply to          */
    long                rp;             /* right pointer into relator      */
    long                rc;             /* right coset to apply to         */
    long                tc;             /* temporary coset                 */
    long                i;              /* loop variable                   */
    Obj                 hdTmp;          /* temporary variable              */

    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    while ( ! IS_PLIST(list) ) {
	list = ErrorReturnObj(
            "<list> must be a plain list (not a %s)",
	    (Int)(InfoBags[TYPE_OBJ(list)].name), 0L,
	    "you can return a list for <list>" );
    }

    objTable  = ELM_PLIST( list, 1 );
    objNext   = ELM_PLIST( list, 2 );
    objPrev   = ELM_PLIST( list, 3 );

    firstFree = INT_INTOBJ( ELM_PLIST( list, 6 ) );
    lastFree  = INT_INTOBJ( ELM_PLIST( list, 7 ) );
    firstDef  = INT_INTOBJ( ELM_PLIST( list, 8 ) );
    lastDef   = INT_INTOBJ( ELM_PLIST( list, 9 ) );

    nrdel     = 0;

    /* initialize the deduction queue                                      */
    dedprint = 0;
    dedfst = 0;
    dedlst = 1;
    dedgen[ 0 ] = INT_INTOBJ( ELM_PLIST( list, 10 ) );
    dedcos[ 0 ] = INT_INTOBJ( ELM_PLIST( list, 11 ) );

    /* while the deduction queue is not empty                              */
    while ( dedfst < dedlst ) {

        /* skip the deduction, if it got irrelevant by a coincidence       */
        hdTmp = ELM_PLIST( objTable, dedgen[dedfst] );
        hdTmp = ELM_PLIST( hdTmp, dedcos[dedfst] );
        if ( INT_INTOBJ(hdTmp) == 0 ) {
            dedfst++;
            continue;
        }

        /* while there are still subgroup generators apply them            */
        hdSubs = ELM_PLIST( list, 5 );
        for ( i = LEN_LIST( hdSubs ); 1 <= i; i-- ) {
          if ( ELM_PLIST( hdSubs, i ) != 0 ) {
            objNums = ELM_PLIST( ELM_PLIST( hdSubs, i ), 1 );
            ptNums  = ADDR_OBJ( objNums );
            objRel  = ELM_PLIST( ELM_PLIST( hdSubs, i ), 2 );
            ptRel   = ADDR_OBJ( objRel );

            lp = 2;
            lc = 1;
            rp = LEN_LIST( objRel ) - 1;
            rc = 1;

            /* scan as long as possible from the right to the left         */
            while ( lp<rp && 0 < (tc=INT_INTOBJ(ELM_PLIST(ptRel[rp],rc))) ) {
                rc = tc;  rp = rp - 2;
            }

            /* scan as long as possible from the left to the right         */
            while ( lp<rp && 0 < (tc=INT_INTOBJ(ELM_PLIST(ptRel[lp],lc))) ) {
                lc = tc;  lp = lp + 2;
            }

            /* if a coincidence or deduction has been found, handle it     */
            if ( lp == rp+1 && INT_INTOBJ(ELM_PLIST(ptRel[lp],lc)) != rc ) {
	      if ( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ) != 0 ) {
		  HandleCoinc( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ), rc );
	      }
	      else if ( INT_INTOBJ( ELM_PLIST(ptRel[rp],rc) ) != 0 ) {
		  HandleCoinc( INT_INTOBJ( ELM_PLIST(ptRel[rp],rc) ), lc );
	      }
	      else {
		  SET_ELM_PLIST( ptRel[lp], lc, INTOBJ_INT( rc ) );
		  SET_ELM_PLIST( ptRel[rp], rc, INTOBJ_INT( lc ) );
		  if ( dedlst == dedSize )
		      CompressDeductionList();
		  dedgen[ dedlst ] = INT_INTOBJ( ptNums[lp] );
		  dedcos[ dedlst ] = lc;
		  dedlst++;
	      }

	      /* remove the completed subgroup generator                 */
	      SET_ELM_PLIST( hdSubs, i, 0 );
	      if ( i == LEN_PLIST(hdSubs) ) {
		  while ( 0 < i  && ELM_PLIST(hdSubs,i) == 0 )
		      --i;
		  SET_LEN_PLIST( hdSubs, i );
	      }
            }
          }
        }

        /* apply all relators that start with this generator               */
        objRels = ELM_PLIST( ELM_PLIST( list, 4 ), dedgen[dedfst] );
        for ( i = 1; i <= LEN_LIST( objRels ); i++ ) {
            objNums = ELM_PLIST( ELM_PLIST(objRels,i), 1 );
            ptNums  = ADDR_OBJ( objNums );
            objRel  = ELM_PLIST( ELM_PLIST(objRels,i), 2 );
            ptRel   = ADDR_OBJ( objRel );

            lp = INT_INTOBJ( ELM_PLIST( ELM_PLIST(objRels,i), 3 ) );
            lc = dedcos[ dedfst ];
            rp = lp + INT_INTOBJ( ptRel[1] );
            rc = lc;

            /* scan as long as possible from the right to the left         */
            while ( lp<rp && 0 < (tc=INT_INTOBJ(ELM_PLIST(ptRel[rp],rc))) ) {
                rc = tc;  rp = rp - 2;
            }

            /* scan as long as possible from the left to the right         */
            while ( lp<rp && 0 < (tc=INT_INTOBJ(ELM_PLIST(ptRel[lp],lc))) ) {
                lc = tc;  lp = lp + 2;
            }

            /* if a coincidence or deduction has been found, handle it     */
            if ( lp == rp+1 && INT_INTOBJ(ELM_PLIST(ptRel[lp],lc)) != rc ) {
                if ( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ) != 0 ) {
                    HandleCoinc( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ), rc );
                }
                else if ( INT_INTOBJ( ELM_PLIST(ptRel[rp],rc) ) != 0 ) {
                    HandleCoinc( INT_INTOBJ( ELM_PLIST(ptRel[rp],rc) ), lc );
                }
                else {
                    SET_ELM_PLIST( ptRel[lp], lc, INTOBJ_INT( rc ) );
                    SET_ELM_PLIST( ptRel[rp], rc, INTOBJ_INT( lc ) );
                    if ( dedlst == dedSize )
			CompressDeductionList();
                    dedgen[ dedlst ] = INT_INTOBJ( ptNums[lp] );
                    dedcos[ dedlst ] = lc;
                    dedlst++;
                }

            }

        }

        dedfst++;
    }

    SET_ELM_PLIST( list, 6, INTOBJ_INT( firstFree ) );
    SET_ELM_PLIST( list, 7, INTOBJ_INT( lastFree  ) );
    SET_ELM_PLIST( list, 8, INTOBJ_INT( firstDef  ) );
    SET_ELM_PLIST( list, 9, INTOBJ_INT( lastDef   ) );
    CHANGED_BAG(list);

    return INTOBJ_INT( nrdel );
}


/****************************************************************************
**
*F  FuncStandardizeTable( <self>, <list> )  . . . . standardize a coset table
*/
Obj FuncStandardizeTable (
    Obj			self,
    Obj                 list )
{
    Obj *               ptTable;        /* pointer to table                */
    UInt                nrgen;          /* number of rows of the table / 2 */
    Obj *               g;              /* one generator list from table   */
    Obj *               h;              /* generator list and inverse      */
    Obj *               i;
    UInt                acos;           /* actual coset                    */
    UInt                lcos;           /* last seen coset                 */
    UInt                mcos;           /*                                 */
    UInt                c1, c2;         /* coset temporaries               */
    Obj                 tmp;            /* temporary for swap              */
    UInt                j, k;           /* loop variables                  */

    /* get the arguments                                                   */
    objTable = list;
    while ( ! IS_PLIST(objTable) ) {
	objTable = ErrorReturnObj(
            "<objTable> must be a plain list (not a %s)",
	    (Int)(InfoBags[TYPE_OBJ(objTable)].name), 0L,
	    "you can return a list for <objTable>" );
    }
    ptTable  = ADDR_OBJ(objTable);
    nrgen    = LEN_PLIST(objTable) / 2;
    for ( j = 1;  j <= nrgen*2;  j++ ) {
	if ( ! IS_PLIST(ptTable[j]) ) {
	    ErrorQuit( "<objTable>[%d] must be a plain list (not a %s)",
		       (Int)j,
		       (Int)(InfoBags[TYPE_OBJ(ptTable[j])].name) );
	}
    }

    /* run over all cosets                                                 */
    acos = 1;
    lcos = 1;
    while ( acos <= lcos ) {

        /* scan through all rows of acos                                   */
        for ( j = 1;  j <= nrgen;  j++ ) {
            g = ADDR_OBJ( ptTable[2*j-1] );

            /* if we haven't seen this coset yet                           */
            if ( lcos+1 < INT_INTOBJ( g[acos] ) ) {

                /* swap columns lcos and g[acos]                           */
                lcos = lcos + 1;
                mcos = INT_INTOBJ( g[acos] );
                for ( k = 1;  k <= nrgen;  k++ ) {
                    h = ADDR_OBJ( ptTable[2*k-1] );
                    i = ADDR_OBJ( ptTable[2*k] );
                    c1 = INT_INTOBJ( h[lcos] );
                    c2 = INT_INTOBJ( h[mcos] );
                    if ( c1 != 0 )  i[c1] = INTOBJ_INT( mcos );
                    if ( c2 != 0 )  i[c2] = INTOBJ_INT( lcos );
                    tmp     = h[lcos];
                    h[lcos] = h[mcos];
                    h[mcos] = tmp;
                    if ( i != h ) {
                        c1 = INT_INTOBJ( i[lcos] );
                        c2 = INT_INTOBJ( i[mcos] );
                        if ( c1 != 0 )  h[c1] = INTOBJ_INT( mcos );
                        if ( c2 != 0 )  h[c2] = INTOBJ_INT( lcos );
                        tmp     = i[lcos];
                        i[lcos] = i[mcos];
                        i[mcos] = tmp;
                    }
                }

            }

            /* if this is already the next only bump lcos                  */
            else if ( lcos < INT_INTOBJ( g[acos] ) ) {
                lcos = lcos + 1;
            }

        }

        acos = acos + 1;
    }

    /* shrink the table                                                    */
    for ( j = 1; j <= nrgen; j++ ) {
	SET_LEN_PLIST( ptTable[2*j-1], lcos );
	SET_LEN_PLIST( ptTable[2*j  ], lcos );
	CHANGED_BAG(ptTable[2*j-1]);
	CHANGED_BAG(ptTable[2*j  ]);
    }
    CHANGED_BAG(objTable);

    /* return void                                                         */
    return 0;
}


/****************************************************************************
**

*F  InitCosetTable()
*/
void InitCosetTable ( void )
{

    /* functions for coset tables                                          */
    AssGVar( GVarName( "ApplyRel" ),
         NewFunctionC( "ApplyRel", 2L, "app, rel",
                    FuncApplyRel ) );

    AssGVar( GVarName( "MakeConsequences" ),
         NewFunctionC( "MakeConsequences", 1L, "list",
                    FuncMakeConsequences ) );

    AssGVar( GVarName( "StandardizeTable" ),
         NewFunctionC( "StandardizeTable", 1L, "table",
                    FuncStandardizeTable ) );

}


/****************************************************************************
**

*E  costab.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
