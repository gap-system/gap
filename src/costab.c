/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of for coset tables.
*/

#include "costab.h"

#include "bool.h"
#include "error.h"
#include "gvars.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"


/****************************************************************************
**
*V  declaration of static variables
*/
static Obj      objRel;                 /* handle of a relator             */
static Obj      objNums;                /* handle of parallel numbers list */
static Obj      objTable;               /* handle of the coset table       */
static Obj      objTable2;              /* handle of coset factor table    */
static Obj      objNext;                /*                                 */
static Obj      objPrev;                /*                                 */
static Obj      objFactor;              /*                                 */
static Obj      objTree;                /* handle of subgroup gens tree    */

static Obj      objTree1;               /* first tree component            */
static Obj      objTree2;               /* second tree component           */

static Obj      objExponent;            /* handle of subgroup order        */
static Obj      objWordValue;           /* handle of word value            */

static Int      treeType;               /* tree type                       */
static Int      treeWordLength;         /* maximal tree word length        */
static Int      firstDef;               /*                                 */
static Int      lastDef;                /*                                 */
static Int      firstFree;              /*                                 */
static Int      lastFree;               /*                                 */

static Int      minGaps;                /* switch for marking mingaps      */
static Int      nrdel;                  /*                                 */

static Int      dedfst;                 /* position of first deduction     */
static Int      dedlst;                 /* position of last deduction      */
static Int      dedgen [40960];         /* deduction list keeping gens     */
static Int      dedcos [40960];         /* deduction list keeping cosets   */
static Int      dedSize = 40960;        /* size of deduction list buffers  */
static Int      dedprint;               /* print flag for warning          */

static Int      wordList [1024];        /* coset rep word buffer           */
static Int      wordSize = 1023;        /* maximal no. of coset rep words  */

/* clean out global Obj-type variables  to avoid hogging memory*/
static void CleanOut( void )
{
  objRel = (Obj) 0;
  objNums = (Obj) 0;
  objTable = (Obj) 0;
  objTable2 = (Obj) 0;
  objNext = (Obj) 0;
  objPrev = (Obj) 0;
  objFactor = (Obj) 0;
  objTree = (Obj) 0;
  objTree1 = (Obj) 0;
  objTree2 = (Obj) 0;
  objExponent = (Obj) 0;
  objWordValue = (Obj) 0;
}

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
static Obj FuncApplyRel(Obj self,
                        Obj app, /* handle of the application list  */
                        Obj rel) /* handle of the relator           */
{
    
    Int                 lp;             /* left pointer into relator       */
    Int                 lc;             /* left coset to apply to          */
    Int                 rp;             /* right pointer into relator      */
    Int                 rc;             /* right coset to apply to         */
    Int                 tc;             /* temporary coset                 */

    /* check the application list                                          */
    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    RequirePlainList(0, app);
    if ( LEN_PLIST(app) != 4 ) {
        ErrorQuit("<app> must be a list of length 4 not %d",
                  (Int)LEN_PLIST(app), 0);
    }

    /* get the four entries                                                */
    lp = INT_INTOBJ( ELM_PLIST( app, 1 ) );
    lc = INT_INTOBJ( ELM_PLIST( app, 2 ) );
    rp = INT_INTOBJ( ELM_PLIST( app, 3 ) );
    rc = INT_INTOBJ( ELM_PLIST( app, 4 ) );

    /* get and check the relator (well, only a little bit)                 */
    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    RequirePlainList(0, rel);

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
static void CompressDeductionList ( void )
{
    Obj               * ptTable;          /* pointer to the coset table    */
    Int                 i;
    Int                 j;

    /* check if the situation is as assumed                                */
    if ( dedlst != dedSize ) {
        ErrorQuit("invalid call of CompressDeductionList", 0, 0);
    }

    /* run through the lists and compress them                             */
    ptTable = BASE_PTR_PLIST(objTable) - 1;
    j = 0;
    for ( i = dedfst; i < dedlst; i++ ) {
        if ( INT_INTOBJ(ELM_PLIST(ptTable[dedgen[i]],dedcos[i])) > 0
          && j < i )
        {
            dedgen[j] = dedgen[i];
            dedcos[j] = dedcos[i];
            j++;
        }
    }

    /* update the pointers                                                 */
    dedfst = 0;
    dedlst = j;

    /* check if we have at least one free position                         */
    if ( dedlst == dedSize ) {
        if ( dedprint == 0 ) {
            Pr("#I  WARNING: deductions being discarded\n", 0, 0);
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
static void HandleCoinc (
    Int                 cos1,
    Int                 cos2 )
{
    Obj *               ptTable;          /* pointer to the coset table    */
    Obj *               ptNext;
    Obj *               ptPrev;
    Int                 c1;
    Int                 c2;
    Int                 c3;
    Int                 i;
    Int                 firstCoinc;
    Int                 lastCoinc;
    Obj *               gen;
    Obj *               inv;

    /* is this test necessary?                                             */
    if ( cos1 == cos2 )  return;

    /* get some pointers                                                   */
    ptTable = BASE_PTR_PLIST(objTable) - 1;
    ptNext = BASE_PTR_PLIST(objNext) - 1;
    ptPrev = BASE_PTR_PLIST(objPrev) - 1;

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
            gen = BASE_PTR_PLIST(ptTable[i]) - 1;
            /* inv = ADDR_OBJ(ptTable[ ((i-1)^1)+1 ] ); */
            inv = BASE_PTR_PLIST(ptTable[i + 2 * (i % 2) - 1]) - 1;

            /* replace <cos2> by <cos1> in the column of <gen>^-1          */
            c2 = INT_INTOBJ( gen[cos2] );
            if ( c2 > 0 ) {
                c1 = INT_INTOBJ( gen[cos1] );

                /* if the other entry is empty copy it                     */
                if ( c1 <= 0 )  {
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
                    if ( gen[cos1] <= INTOBJ_INT( 0 ) ) {
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

            /* save minimal gap flags                                      */
            else if ( minGaps != 0 && c2 == -1 ) {
                if ( gen[cos1] <= INTOBJ_INT( 0 ) ) {
                    gen[cos1] = INTOBJ_INT( -1 );
                }
                gen[cos2] = INTOBJ_INT( 0 );
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
static Obj FuncMakeConsequences(Obj self, Obj list)
{
    Obj                 hdSubs;         /*                                 */
    Obj                 objRels;        /*                                 */
    Obj *               ptRel;          /* pointer to the relator bag      */
    Obj *               ptNums;         /* pointer to this list            */
    Int                 lp;             /* left pointer into relator       */
    Int                 lc;             /* left coset to apply to          */
    Int                 rp;             /* right pointer into relator      */
    Int                 rc;             /* right coset to apply to         */
    Int                 tc;             /* temporary coset                 */
    Int                 i;              /* loop variable                   */
    Obj                 hdTmp;          /* temporary variable              */

    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    RequirePlainList(0, list);

    objTable  = ELM_PLIST( list, 1 );
    objNext   = ELM_PLIST( list, 2 );
    objPrev   = ELM_PLIST( list, 3 );

    firstFree = INT_INTOBJ( ELM_PLIST( list, 6 ) );
    lastFree  = INT_INTOBJ( ELM_PLIST( list, 7 ) );
    firstDef  = INT_INTOBJ( ELM_PLIST( list, 8 ) );
    lastDef   = INT_INTOBJ( ELM_PLIST( list, 9 ) );
    minGaps   = INT_INTOBJ( ELM_PLIST( list, 12 ) );

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
        if ( INT_INTOBJ(hdTmp) <= 0 ) {
            dedfst++;
            continue;
        }

        /* while there are still subgroup generators apply them            */
        hdSubs = ELM_PLIST( list, 5 );
        for ( i = LEN_LIST( hdSubs ); 1 <= i; i-- ) {
          if ( ELM_PLIST( hdSubs, i ) != 0 ) {
            objNums = ELM_PLIST( ELM_PLIST( hdSubs, i ), 1 );
            ptNums = BASE_PTR_PLIST(objNums) - 1;
            objRel  = ELM_PLIST( ELM_PLIST( hdSubs, i ), 2 );
            ptRel = BASE_PTR_PLIST(objRel) - 1;

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
            if ( lp == rp + 1 ) {
              if ( INT_INTOBJ(ELM_PLIST(ptRel[lp],lc)) != rc ) {
                if ( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ) > 0 ) {
                    HandleCoinc( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ), rc );
                }
                else if ( INT_INTOBJ( ELM_PLIST(ptRel[rp],rc) ) > 0 ) {
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

              /* remove the completed subgroup generator                   */
              SET_ELM_PLIST( hdSubs, i, 0 );
              if ( i == LEN_PLIST(hdSubs) ) {
                  while ( 0 < i  && ELM_PLIST(hdSubs,i) == 0 )
                      --i;
                  SET_LEN_PLIST( hdSubs, i );
                  i++;
              }
            }

            /* if a minimal gap has been found, set a flag                 */
            else if ( minGaps != 0 && lp == rp - 1 ) {
                SET_ELM_PLIST( ptRel[lp], lc, INTOBJ_INT( -1 ) );
                SET_ELM_PLIST( ptRel[rp], rc, INTOBJ_INT( -1 ) );
            }
          }
        }

        /* apply all relators that start with this generator               */
        objRels = ELM_PLIST( ELM_PLIST( list, 4 ), dedgen[dedfst] );
        for ( i = 1; i <= LEN_LIST( objRels ); i++ ) {
            objNums = ELM_PLIST( ELM_PLIST(objRels,i), 1 );
            ptNums = BASE_PTR_PLIST(objNums) - 1;
            objRel  = ELM_PLIST( ELM_PLIST(objRels,i), 2 );
            ptRel = BASE_PTR_PLIST(objRel) - 1;

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
                if ( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ) > 0 ) {
                    HandleCoinc( INT_INTOBJ( ELM_PLIST(ptRel[lp],lc) ), rc );
                }
                else if ( INT_INTOBJ( ELM_PLIST(ptRel[rp],rc) ) > 0 ) {
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

            /* if a minimal gap has been found, set a flag                 */
            else if ( minGaps != 0 && lp == rp - 1 ) {
                SET_ELM_PLIST( ptRel[lp], lc, INTOBJ_INT( -1 ) );
                SET_ELM_PLIST( ptRel[rp], rc, INTOBJ_INT( -1 ) );
            }
        }

        dedfst++;
    }

    SET_ELM_PLIST( list, 6, INTOBJ_INT( firstFree ) );
    SET_ELM_PLIST( list, 7, INTOBJ_INT( lastFree  ) );
    SET_ELM_PLIST( list, 8, INTOBJ_INT( firstDef  ) );
    SET_ELM_PLIST( list, 9, INTOBJ_INT( lastDef   ) );

    /* clean out  */
    CleanOut();

    return INTOBJ_INT( nrdel );
}


/****************************************************************************
**
*F  FuncMakeConsequencesPres( <self>, <list> )  . . . . . . find consequences
**
**  This  is a  special version  of  `FuncMakeConsequences'  for the subgroup
**  presentation routines.
*/
static Obj FuncMakeConsequencesPres(Obj self, Obj list)
{
    Obj                 objDefs1;       /* handle of defs list part 1      */
    Obj                 objDefs2;       /* handle of defs list part 2      */
    Obj                 objRels;        /*                                 */
    Obj *               ptRel;          /* pointer to the relator bag      */
    Obj *               ptNums;         /* pointer to this list            */
    Int                 ndefs;          /* number of defs done so far      */
    Int                 undefined;      /* maximal of undefined entreis    */
    Int                 apply;          /* num of next def to be applied   */
    Int                 ndefsMax;       /* maximal number of definitons    */
    Int                 coset;          /* coset involved in current def   */
    Int                 gen;            /* gen involved in current def     */
    Int                 lp;             /* left pointer into relator       */
    Int                 lc;             /* left coset to apply to          */
    Int                 rp;             /* right pointer into relator      */
    Int                 rc;             /* right coset to apply to         */
    Int                 tc;             /* temporary coset                 */
    Int                 i;              /* loop variable                   */

    /*T 1996/12/03 fceller this should be replaced by 'PlistConv'          */
    RequirePlainList(0, list);

    objTable  = ELM_PLIST( list, 1 );
    objDefs1  = ELM_PLIST( list, 2 );
    objDefs2  = ELM_PLIST( list, 3 );

    undefined = INT_INTOBJ( ELM_PLIST( list, 4 ) );
    ndefs     = INT_INTOBJ( ELM_PLIST( list, 5 ) );

    /* check the definitions lists                                         */
    if ( ! ( IS_PLIST(objDefs1) && IS_PLIST(objDefs2) &&
        LEN_PLIST(objDefs1) == LEN_PLIST(objDefs2) ) ) {
        ErrorQuit("inconsistent definitions lists", 0, 0);
    }
    ndefsMax = LEN_PLIST(objDefs1);
    apply = 1;

    /* while the deduction queue is not worked off                         */
    while ( apply <= ndefs ) {

        /* apply all relators that start with this generator               */
        coset = INT_INTOBJ( ELM_PLIST( objDefs1, apply ) );
        gen = INT_INTOBJ( ELM_PLIST( objDefs2, apply ) );
        objRels = ELM_PLIST( ELM_PLIST( list, 6 ), gen );
        for ( i = 1; i <= LEN_LIST( objRels ); i++ ) {
            objNums = ELM_PLIST( ELM_PLIST(objRels,i), 1 );
            ptNums = BASE_PTR_PLIST(objNums) - 1;
            objRel  = ELM_PLIST( ELM_PLIST(objRels,i), 2 );
            ptRel = BASE_PTR_PLIST(objRel) - 1;

            lp = INT_INTOBJ( ELM_PLIST( ELM_PLIST(objRels,i), 3 ) );
            lc = coset;
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

            /* if a deduction has been found, handle it     */
            if ( lp == rp+1 && INT_INTOBJ(ELM_PLIST(ptRel[rp],rc)) <= 0 ) {
                SET_ELM_PLIST( ptRel[lp], lc, INTOBJ_INT( rc ) );
                undefined--;
                if ( INT_INTOBJ(ELM_PLIST(ptRel[rp],rc)) <= 0 ) {
                    SET_ELM_PLIST( ptRel[rp], rc, INTOBJ_INT( lc ) );
                    undefined--;
                }
                ndefs++;
                if ( ndefs > ndefsMax ) {
                    ErrorQuit("inconsistent definitions lists", 0, 0);
                }
                SET_ELM_PLIST( objDefs1, ndefs, INTOBJ_INT( lc ) );
                SET_ELM_PLIST( objDefs2, ndefs, ptNums[lp] );
                if ( undefined == 0 ) {
                    return INTOBJ_INT( 0 );
                }
            }
        }

        apply++;
    }

    /* clean out  */
    CleanOut();

    return INTOBJ_INT( undefined );
}


/****************************************************************************
**
*F  FuncStandardizeTableC(<self>,<table>,<stan>)  . . . . . .  standardize CT
**
**  This is the kernel routine for standardizing a coset table.  It is called
**  by the  GAP routine  'StandardizeTable'.  The user  should  not  call the
**  kernel routine but only the GAP routine.
**
**  If  <stan> = 1  the table  is standardized  using  the  (old)  semilenlex
**  standard.
**  If  not  <stan> = 1  the table  is standardized  using the  (new)  lenlex
**  standard (this is the default).
*/
static Obj FuncStandardizeTableC(Obj self, Obj table, Obj stan)
{
    Obj *               ptTable;        /* pointer to table                */
    UInt                nrgen;          /* number of rows of the table / 2 */
    Obj *               g;              /* one generator list from table   */
    Obj *               h;              /* generator list                  */
    Obj *               i;              /*  and inverse                    */
    UInt                acos;           /* actual coset                    */
    UInt                lcos;           /* last seen coset                 */
    UInt                mcos;           /*                                 */
    UInt                c1, c2;         /* coset temporaries               */
    Obj                 tmp;            /* temporary for swap              */
    UInt                j, k, nloop;    /* loop variables                  */

    RequirePlainList(0, table);

    /* get the arguments                                                   */
    objTable = table;
    ptTable = BASE_PTR_PLIST(objTable) - 1;
    nrgen    = LEN_PLIST(objTable) / 2;
    for ( j = 1;  j <= nrgen*2;  j++ ) {
        if ( ! IS_PLIST(ptTable[j]) ) {
            ErrorQuit(
                "<table>[%d] must be a plain list (not a %s)",
                (Int)j,
                (Int)TNAM_OBJ(ptTable[j]) );
        }
    }
    if (stan == INTOBJ_INT(1)) {
       /* use semilenlex standard                                          */
       nloop = nrgen;
    }
    else {
       /* use lenlex standard                                              */
       nloop = nrgen*2;
    }

    /* run over all cosets                                                 */
    acos = 1;
    lcos = 1;
    while ( acos <= lcos ) {

        /* scan through all columns of acos                                */
        for ( j = 1;  j <= nloop;  j++ ) {
            k = ( nloop == nrgen ) ? 2*j - 1 : j;
            g = BASE_PTR_PLIST(ptTable[k]) - 1;

            /* if we haven't seen this coset yet                           */
            if ( lcos+1 < INT_INTOBJ( g[acos] ) ) {

                /* swap rows lcos and g[acos]                              */
                lcos = lcos + 1;
                mcos = INT_INTOBJ( g[acos] );
                for ( k = 1;  k <= nrgen;  k++ ) {
                    h = BASE_PTR_PLIST(ptTable[2 * k - 1]) - 1;
                    i = BASE_PTR_PLIST(ptTable[2 * k]) - 1;
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
    }

    /* clean out  */
    CleanOut();

    return 0;
}


/****************************************************************************
**
*F  InitializeCosetFactorWord() . . . . . . .  initialize a coset factor word
**
**  'InitializeCosetFactorWord'  initializes  a word  in  which  a new  coset
**  factor is to be built up.
**
**  'wordList', 'treeType', 'objTree2', and  'treeWordLength' are assumed  to
**  be known as static variables.
*/
static void InitializeCosetFactorWord ( void )
{
    Obj *               ptWord;         /* pointer to the word             */
    Int                 i;              /* integer variable                */

    /* handle the one generator MTC case                                   */
    if ( treeType == 1 ) {
        objWordValue = INTOBJ_INT(0);
    }

    /* handle the abelianized case                                         */
    else if ( treeType == 0 ) {
        ptWord = BASE_PTR_PLIST(objTree2) - 1;
        for ( i = 1;  i <= treeWordLength;  i++ ) {
            ptWord[i] = INTOBJ_INT(0);
        }
    }

    /* handle the general case                                             */
    else {
        wordList[0] = 0;
    }
}


/****************************************************************************
**
*F  TreeEntryC()  . . . . . . . . . . . . returns a tree entry for a rep word
**
**  'TreeEntryC'  determines a tree entry  which represents the word given in
**  'wordList', if it finds any, or it defines a  new proper tree entry,  and
**  then returns it.
**
**  Warning:  It is assumed,  but not checked,  that the given word is freely
**  reduced  and that it does  not contain zeros,  and that the  tree type is
**  either 0 or 2.
**
**  'wordList'  is assumed to be known as static variable.
**
*/
static Int TreeEntryC ( void )
{
    Obj *               ptTree1;        /* ptr to first tree component     */
    Obj *               ptTree2;        /* ptr to second tree component    */
    Obj *               ptWord;         /* ptr to given word               */
    Obj *               ptFac;          /* ptr to old word                 */
    Obj *               ptNew;          /* ptr to new word                 */
    Obj                 objNew;         /* handle of new word              */
    Int                 treesize;       /* tree size                       */
    Int                 numgens;        /* tree length                     */
    Int                 leng;           /* word length                     */
    Int                 sign;           /* sign flag                       */
    Int                 i, k;           /* integer variables               */
    Int                 gen;            /* generator value                 */
    Int                 u, u1, u2;      /* generator values                */
    Int                 v, v1, v2;      /* generator values                */
    Int                 t1, t2;         /* generator values                */
    Int                 uabs, vabs;     /* generator values                */

    /*  Get the tree components                                            */
    ptTree1 = BASE_PTR_PLIST(objTree1) - 1;
    ptTree2 = BASE_PTR_PLIST(objTree2) - 1;
    treesize = LEN_PLIST(objTree1);
    numgens  = INT_INTOBJ( ELM_PLIST( objTree, 3 ) );

    /* handle the abelianized case                                         */
    if ( treeType == 0 )
    {
        ptWord = BASE_PTR_PLIST(objTree2) - 1;
        for ( leng = treeWordLength;  leng >= 1;  leng-- ) {
            if ( ptWord[leng] != INTOBJ_INT(0) )  {
                break;
            }
        }
        if ( leng == 0 )  {
            return 0;
        }
        for ( k = 1; k <= leng; k++ ) {
            if ( ptWord[k] != INTOBJ_INT(0) )  { 
                break;
            }
        }
        sign = 1;
        if ( INT_INTOBJ( ptWord[k] ) < 0 ) {

            /* invert the word                                             */
            sign = - 1;
            for ( i = k; i <= leng; i++ ) {
                ptWord[i] = INTOBJ_INT( - INT_INTOBJ( ptWord[i] ) );
            }
        }
        for ( k = 1; k <= numgens; k++ ) {
            ptFac = BASE_PTR_PLIST(ptTree1[k]) - 1;
            if ( LEN_PLIST(ptTree1[k]) == leng ) {
                for ( i = 1;  i <= leng;  i++ ) {
                    if ( ptFac[i] != ptWord[i] )  {
                        break;
                    }
                }
                if ( i > leng )  {
                    return sign * k;
                }
            }
        }

        /* extend the tree                                                 */
        numgens++;
        if ( treesize < numgens ) {
            treesize = 2 * treesize;
            GROW_PLIST( objTree1, treesize );
            CHANGED_BAG(objTree);
        }
        objNew = NEW_PLIST( T_PLIST, leng );
        SET_LEN_PLIST( objNew, leng );

        SET_ELM_PLIST( objTree, 3, INTOBJ_INT(numgens) );

        SET_LEN_PLIST( objTree1, treesize );
        SET_ELM_PLIST( objTree1, numgens, objNew );
        CHANGED_BAG(objTree1);

        /* copy the word to the new bag                                    */
        ptWord = BASE_PTR_PLIST(objTree2) - 1;
        ptNew = BASE_PTR_PLIST(objNew) - 1;
        while ( leng > 0 ) {
            ptNew[leng] = ptWord[leng];
            leng--;
        }

        return sign * numgens;
    }

    /* handle the general case                                             */

    /*  Get the length of the word                                         */
    leng = wordList[0];

    gen = ( leng == 0 ) ? 0 : wordList[1];
    u2  = 0; /* just to shut up gcc */
    for ( i = 2;  i <= leng;  i++ ) {
        u = gen;
        v = wordList[i];
        while ( i ) {

            /*  First handle the trivial cases                             */
            if ( u == 0 || v == 0 || ( u + v ) == 0 ) {
                gen = u + v;
                break;
            }

            /*  Cancel out factors, if possible                            */
            u1 = INT_INTOBJ( ptTree1[ (u > 0) ? u : -u ] );
            if ( u1 != 0 ) {
                if ( u > 0 ) {
                    u2 = INT_INTOBJ( ptTree2[u] );
                }
                else {
                    u2 = - u1;
                    u1 = - INT_INTOBJ( ptTree2[-u] );
                }
                if ( u2 == -v ) {
                    gen = u1;
                    break;
                }
            }
            v1 = INT_INTOBJ( ptTree1[ (v > 0) ? v : -v ] );
            if ( v1 != 0 ) {
                if ( v > 0 ) {
                    v2 = INT_INTOBJ( ptTree2[v] );
                }
                else {
                    v2 = - v1;
                    v1 = - INT_INTOBJ( ptTree2[-v] );
                }
                if ( v1 == -u ) {
                    gen = v2;
                    break;
                }
                if ( u1 != 0 && v1 == - u2 ) {
                    u = u1;
                    v = v2;
                    continue;
                }
            }

            /*  Check if there is already a tree entry [u,v] or [-v,-u]    */
            if ( u < -v ) {
                t1 = u;
                t2 = v;
            }
            else {
                t1 = -v;
                t2 = -u;
            }
            uabs = ( u > 0 ) ? u : -u;
            vabs = ( v > 0 ) ? v : -v;
            k = ( uabs > vabs ) ? uabs : vabs;
            for ( k++; k <= numgens; k++ ) {
                if ( INT_INTOBJ(ptTree1[k]) == t1 &&
                     INT_INTOBJ(ptTree2[k]) == t2 )
                {
                    break;
                }
            }

            /*  Extend the tree, if necessary                              */
            if ( k > numgens ) {
                numgens++;
                if ( treesize < numgens ) {
                    treesize = 2 * treesize;
                    GROW_PLIST( objTree1, treesize );
                    GROW_PLIST( objTree2, treesize );
                    ptTree1 = BASE_PTR_PLIST(objTree1) - 1;
                    ptTree2 = BASE_PTR_PLIST(objTree2) - 1;
                    SET_LEN_PLIST( objTree1, treesize );
                    SET_LEN_PLIST( objTree2, treesize );
                    CHANGED_BAG(objTree);
                }
                ptTree1[numgens] = INTOBJ_INT( t1 );
                ptTree2[numgens] = INTOBJ_INT( t2 );
                SET_ELM_PLIST( objTree, 3, INTOBJ_INT(numgens) );
            }
            gen = ( u > - v ) ? -k : k;
            break;
        }
    }

    return gen;
}


/****************************************************************************
**
*F  AddCosetFactor2( <factor> ) . add a factor to a coset representative word
**
**  'AddCosetFactor2'  adds  a  factor  to a  coset  representative word  and
**  extends the tree appropriately, if necessary.
**
**  'treeType', 'wordList', and 'wordSize'  are assumed to be known as static
**  variables, and 'treeType' is assumed to be either 0 or 2,
**
**  Warning: 'factor' is not checked for being zero.
**
**  it returns 0 if everything worked, and 1 if a problem arose.
*/
static Int AddCosetFactor2 (
    Int                factor )
{
    Obj *               ptFac;          /* pointer to the factor           */
    Obj *               ptWord;         /* pointer to the word             */
    Int                 leng;           /* length of the factor            */
    Obj                 sum;            /* intermediate result             */
    Int                 i;              /* integer variable                */
    Obj                 tmp;

    /* handle the abelianized case                                         */
    if ( treeType == 0 ) {
        ptWord = BASE_PTR_PLIST(objTree2) - 1;
        if ( factor > 0 ) {
            tmp   = ELM_PLIST( objTree1, factor );
            ptFac = BASE_PTR_PLIST(tmp) - 1;
            leng  = LEN_PLIST(tmp);
            for ( i = 1;  i <= leng;  i++ ) {
                if ( ! SUM_INTOBJS( sum, ptWord[i], ptFac[i] ) ) {
                    return 1;
                    /* used to be unrecoverable error message: 
                    ErrorQuit(
                        "exponent too large, Modified Todd-Coxeter aborted",
                        0, 0); */
                }
                ptWord[i] = sum;
            }
        }
        else
        {
            tmp   = ELM_PLIST( objTree1, -factor );
            ptFac = BASE_PTR_PLIST(tmp) - 1;
            leng  = LEN_PLIST(tmp);
            for ( i = 1;  i <= leng;  i++ ) {
                if ( ! DIFF_INTOBJS( sum, ptWord[i], ptFac[i] ) ) {
                    return 1;
                    /* used to be unrecoverable error message: 
                    ErrorQuit(
                        "exponent too large, Modified Todd-Coxeter aborted",
                        0, 0); */
                }
                ptWord[i] = sum;
            }
        }
    }

    /* handle the general case                                             */
    else if ( wordList[0] == 0 ) {
        wordList[++wordList[0]] = factor;
    }
    else if ( wordList[wordList[0]] == -factor ) {
        --wordList[0];
    }
    else if ( wordList[0] < wordSize ) {
        wordList[++wordList[0]] = factor;
    }
    else {
        wordList[0] = ( wordList[1] = TreeEntryC( ) == 0 ) ? 0 : 1;
        if (AddCosetFactor2(factor)==1) {
          return 1;
        }
    }
    return 0;
}


/****************************************************************************
**
*F  FuncApplyRel2( <self>, <app>, <rel>, <nums> ) . . . . . . apply a relator
**
**  'FuncApplyRel2' implements the internal function 'ApplyRel2'.
**
**  'ApplyRel2( <app>, <rel>, <nums> )'
**
**  'ApplyRel2'  applies  the relator  <rel>  to a  coset representative  and
**  returns the corresponding factors in "word"
**
**  ...more about ApplyRel2...
**
**  function returns `true` if everything worked, and `false` if there was a
**  problem (e.g. exponents).
*/
static Obj FuncApplyRel2(Obj self, Obj app, Obj rel, Obj nums)
{
    Obj *               ptApp;          /* pointer to that list            */
    Obj                 word;           /* handle of resulting word        */
    Obj *               ptWord;         /* pointer to this word            */
    Obj *               ptTree;         /* pointer to the tree             */
    Obj *               ptTree2;        /* ptr to second tree component    */
    Obj *               ptRel;          /* pointer to the relator bag      */
    Obj *               ptNums;         /* pointer to this list            */
    Obj *               ptTabl2;        /* pointer to coset factor table   */
    Obj                 objRep;         /* handle of temporary factor      */
    Int                 lp;             /* left pointer into relator       */
    Int                 lc;             /* left coset to apply to          */
    Int                 rp;             /* right pointer into relator      */
    Int                 rc;             /* right coset to apply to         */
    Int                 rep;            /* temporary factor                */
    Int                 tc;             /* temporary coset                 */
    Int                 bound;          /* maximal number of steps         */
    Int                 last;           /* proper word length              */
    Int                 size;           /* size of the word bag            */
    Int                 i;              /* loop variables                  */
    Int                 tmp;

    /* get and check the application list                                  */
    RequirePlainList(0, app);
    if ( LEN_PLIST(app) != 9 ) {
        ErrorQuit("<app> must be a list of length 9 not %d",
                  (Int)LEN_PLIST(app), 0);
    }
    ptApp = BASE_PTR_PLIST(app) - 1;

    /* get the components of the proper application list                   */
    lp = INT_INTOBJ( ptApp[1] );
    lc = INT_INTOBJ( ptApp[2] );
    rp = INT_INTOBJ( ptApp[3] );
    rc = INT_INTOBJ( ptApp[4] );

    /* get and check the relator (well, only a little bit)                 */
    objRel = rel;
    RequirePlainList(0, rel);

    /* fix right pointer if requested                                      */
    if ( rp == -1 )
        rp = lp + INT_INTOBJ( ELM_PLIST(objRel,1) );

    /* get and check the numbers list parallel to the relator              */
    objNums = nums;
    RequirePlainList(0, nums);

    /* get and check the corresponding factors list                        */
    objTable2 = ptApp[6];
    RequirePlainList(0, objTable2);

    /* get the tree type                                                   */
    treeType = INT_INTOBJ( ptApp[5] );

    /* handle the one generator MTC case                                   */
    if ( treeType == 1 ) {

        /* initialize the resulting exponent by zero                       */
        objExponent = INTOBJ_INT( 0 );

        /* scan as long as possible from the left to the right             */
        while ( lp < rp + 2 &&
                0 < (tc = INT_INTOBJ(ELM_PLIST(ELM_PLIST(objRel,lp),lc))) )
        {
            tmp = INT_INTOBJ( ELM_PLIST(objNums,lp) );
            objRep = ELM_PLIST( objTable2, tmp );
            objRep = ELM_PLIST( objRep, lc );
            objExponent = DiffInt( objExponent, objRep );
            lc = tc;
            lp = lp + 2;
        }

        /* scan as long as possible from the right to the left             */
        while ( lp < rp + 2 &&
                0 < (tc = INT_INTOBJ(ELM_PLIST(ELM_PLIST(objRel,rp),rc))) )
        {
            tmp = INT_INTOBJ( ELM_PLIST(objNums,rp) );
            objRep = ELM_PLIST( objTable2, tmp );
            objRep = ELM_PLIST( objRep, rc );
            objExponent = SumInt( objExponent, objRep );
            rc = tc;
            rp = rp - 2;
        }

        /* The functions DiffInt or SumInt may have caused a garbage       */
        /* collections. So restore the pointer.                            */

        /* save the resulting exponent                                     */
        SET_ELM_PLIST( app, 9, objExponent );
    }

    else {

        /* get and check the corresponding word                            */
        word = ptApp[7];
        RequirePlainList(0, word);

        /* handle the abelianized case                                     */
        if ( treeType == 0 ) {
            objTree  = ptApp[8];
            objTree1 = ELM_PLIST( objTree, 1 );
            objTree2 = ELM_PLIST( objTree, 2 );
            ptTree = BASE_PTR_PLIST(objTree) - 1;
            treeWordLength = INT_INTOBJ( ptTree[4] );
            if ( LEN_PLIST(objTree2) != treeWordLength ) {
                ErrorQuit("ApplyRel2: illegal word length", 0, 0);
            }

            /* initialize the coset representative word                    */
            InitializeCosetFactorWord();

            /* scan as long as possible from the left to the right         */
            while ( lp < rp + 2 &&
                    0 < (tc=INT_INTOBJ(ELM_PLIST(ELM_PLIST(objRel,lp),lc))) )
            {
                tmp    = INT_INTOBJ( ELM_PLIST(objNums,lp) );
                objRep = ELM_PLIST(objTable2,tmp);
                objRep = ELM_PLIST(objRep,lc);
                rep    = INT_INTOBJ(objRep);
                if ( rep != 0 ) {
                    if (AddCosetFactor2(-rep)==1) {;
                        return False;
                    }
                }
                lc = tc;
                lp = lp + 2;
            }

            /* scan as long as possible from the right to the left         */
            while ( lp < rp + 2 &&
                    0 < (tc=INT_INTOBJ(ELM_PLIST(ELM_PLIST(objRel,rp),rc))) )
            {
                tmp    = INT_INTOBJ( ELM_PLIST(objNums,rp) );
                objRep = ELM_PLIST(objTable2,tmp);
                objRep = ELM_PLIST(objRep,rc);
                rep    = INT_INTOBJ(objRep);
                if ( rep != 0 ) {
                    if (AddCosetFactor2(rep)==1) {
                        return False;
                    }
                }
                rc = tc;
                rp = rp - 2;
            }

            /* initialize some local variables                             */
            ptWord = BASE_PTR_PLIST(word) - 1;
            ptTree2 = BASE_PTR_PLIST(objTree2) - 1;

            /* copy the result to its destination, if necessary            */
            if ( ptWord != ptTree2 ) {
                if ( LEN_PLIST(word) != treeWordLength ) {
                    ErrorQuit("illegal word length", 0, 0);
                }
                for ( i = 1;  i <= treeWordLength;  i++ ) {
                    ptWord[i] = ptTree2[i];
                }
                SET_LEN_PLIST( word, LEN_PLIST(objTree2) );
            }
        }

        /* handle the general case                                         */
        else {

            /* extend the word size, if necessary                          */
            bound = ( rp - lp + 3 ) / 2;
            size  = SIZE_OBJ(word)/sizeof(Obj) - 1;
            if ( size < bound ) {
                size = ( bound > 2 * size ) ? bound : 2 * size;
                GROW_PLIST( word, size );
                CHANGED_BAG(app);
            }

            /* initialize some local variables                             */
            ptRel = BASE_PTR_PLIST(objRel) - 1;
            ptNums = BASE_PTR_PLIST(objNums) - 1;
            ptTabl2 = BASE_PTR_PLIST(objTable2) - 1;
            ptWord = BASE_PTR_PLIST(word) - 1;
            last    = 0;

            /* scan as long as possible from the left to the right         */
            while ( lp < rp + 2
                  && 0 < (tc = INT_INTOBJ(ELM_PLIST(ptRel[lp],lc))) )
            {
                objRep = ELM_PLIST( ptTabl2[INT_INTOBJ(ptNums[lp])], lc );
                rep    = INT_INTOBJ(objRep);
                if ( rep != 0 ) {
                    if ( last > 0 && INT_INTOBJ(ptWord[last]) == rep ) {
                        last--;
                    }
                    else {
                        ptWord[++last] = INTOBJ_INT(-rep);
                    }
                }
                lc = tc;
                lp = lp + 2;
            }

            /* revert the ordering of the word constructed so far          */
            if ( last > 0 ) {
                last++;
                for ( i = last / 2;  i > 0;  i-- ) {
                    objRep = ptWord[i];
                    ptWord[i] = ptWord[last-i];
                    ptWord[last-i] = objRep;
                }
                last--;
            }

            /* scan as long as possible from the right to the left         */
            while ( lp < rp + 2
                 && 0 < (tc = INT_INTOBJ(ELM_PLIST(ptRel[rp],rc))) )
            {
                objRep = ELM_PLIST( ptTabl2[INT_INTOBJ(ptNums[rp])], rc );
                rep    = INT_INTOBJ(objRep);
                if ( rep != 0 ) {
                    if ( last > 0 && INT_INTOBJ(ptWord[last]) == -rep ) {
                        last--;
                    }
                    else {
                        ptWord[++last] = INTOBJ_INT(rep);
                    }
                }
                rc = tc;
                rp = rp - 2;
            }

            /* save the word length                                        */
            SET_LEN_PLIST( word, last );
        }
    }

    /* copy the information back into the application list                 */
    SET_ELM_PLIST( app, 1, INTOBJ_INT( lp ) );
    SET_ELM_PLIST( app, 2, INTOBJ_INT( lc ) );
    SET_ELM_PLIST( app, 3, INTOBJ_INT( rp ) );
    SET_ELM_PLIST( app, 4, INTOBJ_INT( rc ) );

    /* return true                                                      */
    return True;
}


/****************************************************************************
**
*F  FuncCopyRel( <self>, <rel> )   . . . . . . . . . . . .  copy of a relator
**
**  'FuncCopyRel' returns a copy  of the given RRS  relator such that the bag
**  of the copy does not exceed the minimal required size.
*/
static Obj FuncCopyRel(Obj self, Obj rel) /* the given relator */
{
    Obj *               ptRel;          /* pointer to the given relator    */
    Obj                 copy;           /* the copy                        */
    Obj *               ptCopy;         /* pointer to the copy             */
    Int                 leng;           /* length of the given word        */

    RequirePlainList(0, rel);
    leng = LEN_PLIST(rel);

    /*  Allocate a bag for the copy                                        */
    copy   = NEW_PLIST( T_PLIST, leng );
    SET_LEN_PLIST( copy, leng );
    ptRel = BASE_PTR_PLIST(rel);
    ptCopy = BASE_PTR_PLIST(copy);

    /*  Copy the relator to the new bag                                    */
    while ( leng > 0 ) {
        *ptCopy++ = *ptRel++; 
        leng--;
    }

    /*  Return the copy                                                    */
    return copy;
}


/****************************************************************************
**
*F  FuncMakeCanonical( <self>, <rel> ) . . . . . . . make a relator canonical
**
**  'FuncMakeCanonical' is a subroutine  of the Reduced Reidemeister-Schreier
**  routines.  It replaces the given relator by its canonical representative.
**  It does not return anything.
*/
static Obj FuncMakeCanonical(Obj self, Obj rel) /* the given relator */
{
    Obj *               ptRel;          /* pointer to the relator          */
    Obj                 obj1,  obj2;    /* handles 0f relator entries      */
    Int                 leng, leng1;    /* length of the relator           */
    Int                 max, min, next; /* relator entries                 */
    Int                 i, j, k, l;     /* integer variables               */
    Int                 ii, jj, kk;     /* integer variables               */

    RequirePlainList(0, rel);
    leng  = LEN_PLIST(rel);
    if (leng == 0) {
        return 0;
    }
    ptRel = BASE_PTR_PLIST(rel);
    leng1 = leng - 1;

    /*  cyclically reduce the relator, if necessary                        */
    i = 0;
    while ( i<leng1 && INT_INTOBJ(ptRel[i]) == -INT_INTOBJ(ptRel[leng1]) ) {
        i++;
        leng1--;
    }
    if ( i > 0 ) {
        for ( j = i;  j <= leng1;  j++ ) {
            ptRel[j-i] = ptRel[j];
        }
        leng1 = leng1 - i;
        leng  = leng1 + 1;
        SET_LEN_PLIST( rel, leng );
    }

    /*  Loop over the relator and find the maximal postitve and negative   */
    /*  entries                                                            */
    max = min = INT_INTOBJ(ptRel[0]);
    i = 0;  j = 0;
    for ( k = 1;  k < leng;  k++ ) {
        next = INT_INTOBJ( ptRel[k] );
        if ( next > max ) {
            max = next; 
            i = k;
        }
        else if ( next <= min ) {
            min = next;
            j = k;
        }
    }

    /*  Find the lexicographically last cyclic permutation of the relator  */
    if ( max < -min ) {
        i = leng;
    }
    else {
        for ( k = i + 1;  k < leng;  k++ ) {
            for ( ii = i, kk = k, l = 0;
                  l < leng;
                  ii = (ii + 1) % leng, kk = (kk + 1) % leng, l++ )
            {
                if ( INT_INTOBJ(ptRel[kk]) < INT_INTOBJ(ptRel[ii]) ) {
                    break;
                }
                else if ( INT_INTOBJ(ptRel[kk]) > INT_INTOBJ(ptRel[ii]) ) {
                    i = k; 
                    break;
                }
            }
            if ( l == leng ) {
                break;
            }
        }
    }

    /*  Find the lexicographically last cyclic permutation of its inverse  */
    if ( -max < min ) {
        j = leng;
    }
    else {
        for ( k = j - 1;  k >= 0;  k-- ) {
            for ( jj = j, kk = k, l = 0;
                  l < leng;
                  jj = (jj + leng1) % leng, kk = (kk + leng1) % leng, l++ )
            {
                if ( INT_INTOBJ(ptRel[kk]) > INT_INTOBJ(ptRel[jj]) ) {
                    break;
                }
                else if ( INT_INTOBJ(ptRel[kk]) < INT_INTOBJ(ptRel[jj]) ) {
                    j = k;
                    break;
                }
            }
            if ( l == leng ) {
                break;
            }
        }
    }

    /*  Compare the two words and find the lexicographically last one      */
    if ( -min == max ) {
        for ( ii = i, jj = j, l = 0;
              l < leng;
              ii = (ii + 1) % leng, jj = (jj + leng1) % leng, l++ )
        {
            if ( - INT_INTOBJ(ptRel[jj]) < INT_INTOBJ(ptRel[ii]) ) {
                break;
            }
            else if ( - INT_INTOBJ(ptRel[jj]) > INT_INTOBJ(ptRel[ii]) ) {
                i = leng; 
                break;
            }
        }
    }

    /*  Invert the given relator, if necessary                             */
    if ( i == leng ) {
        for ( k = 0;  k < leng / 2;  k++ ) {
            next = INT_INTOBJ( ptRel[k] );
            ptRel[k] = INTOBJ_INT( - INT_INTOBJ( ptRel[leng1-k] ) );
            ptRel[leng1-k] = INTOBJ_INT( - next );
        }
        if ( leng % 2 ) {
            ptRel[leng1/2] = INTOBJ_INT( - INT_INTOBJ( ptRel[leng1/2] ) );
        }
        i = leng1 - j;
    }

    /*  Now replace the given relator by the resulting word                */
    if ( i > 0 ) {
        k = INT_INTOBJ( GcdInt( INTOBJ_INT(i), INTOBJ_INT(leng) ) );
        l = leng / k;
        leng1 = leng - i;
        for ( j = 0; j < k; j++ ) {
            jj = (j + i) % leng;
            obj1 = ptRel[jj];
            for ( ii = 0; ii < l; ii++ ) {
                jj = (jj + leng1) % leng;
                obj2 = ptRel[jj];  ptRel[jj] = obj1;  obj1 = obj2;
            }
        }
    }

    return 0;
}


/****************************************************************************
**
*F  FuncTreeEntry( <self>, <tree>, <word> )  .  tree entry for the given word
**
**  'FuncTreeEntry' determines  a tree entry  which represents the given word
**  in the  current generators, if  it finds any, or it  defines a new proper
**  tree entry, and then returns it.
*/
static Obj FuncTreeEntry(Obj self, Obj tree, Obj word)
{
    Obj *               ptTree1;        /* pointer to that component       */
    Obj *               ptTree2;        /* pointer to that component       */
    Obj *               ptWord;         /* pointer to that word            */
    Obj                 new;            /* handle of new word              */
    Obj *               ptNew;          /* pointer to new word             */
    Obj *               ptFac;          /* pointer to old word             */
    Int                 treesize;       /* tree size                       */
    Int                 numgens;        /* tree length                     */
    Int                 leng;           /* word length                     */
    Int                 sign;           /* integer variable                */
    Int                 i, j, k;        /* integer variables               */
    Int                 gen;            /* generator value                 */
    Int                 u, u1, u2;      /* generator values                */
    Int                 v, v1, v2;      /* generator values                */
    Int                 t1, t2;         /* generator values                */
    Int                 uabs, vabs;     /* generator values                */

    /*  Get and check the first argument (tree)                            */
    objTree = tree;
    if ( ! IS_PLIST(tree) || LEN_PLIST(tree) < 5 ) {
        ErrorQuit("invalid <tree>", 0, 0);
    }

    /*  Get and check the tree components                                  */
    objTree1 = ELM_PLIST(objTree,1);
    if ( ! IS_PLIST(objTree1) ) {
        ErrorQuit("invalid <tree>[1]", 0, 0);
    }
    objTree2 = ELM_PLIST(objTree,2);
    if ( ! IS_PLIST(objTree2) ) {
        ErrorQuit("invalid <tree>[2]", 0, 0);
    }
    ptTree1 = BASE_PTR_PLIST(objTree1) - 1;
    ptTree2 = BASE_PTR_PLIST(objTree2) - 1;
    treesize = LEN_PLIST(objTree1);
    numgens  = INT_INTOBJ( ELM_PLIST( objTree, 3 ) );
    treeWordLength = INT_INTOBJ( ELM_PLIST( objTree, 4 ) );
    treeType = INT_INTOBJ( ELM_PLIST( objTree, 5 ) );

    /*  Get the second argument (word)                                     */
    if ( ! IS_PLIST(word) ) {
        ErrorQuit("invalid <word>", 0, 0);
    }

    /* handle the abelianized case                                         */
    ptWord = BASE_PTR_PLIST(word) - 1;
    if ( treeType == 0 ) {
        if ( LEN_PLIST(word) != treeWordLength ) {
            ErrorQuit("inconsistent <word> length", 0, 0);
        }
        ptWord = BASE_PTR_PLIST(objTree2) - 1;
        for ( leng = treeWordLength;  leng >= 1;  leng-- ) {
            if ( ptWord[leng] != INTOBJ_INT(0) ) {
                break;
            }
        }
        if ( leng == 0 ) {
            return INTOBJ_INT( 0 );
        }

        for ( k = 1; k <= leng; k++ ) {
            if ( ptWord[k] != INTOBJ_INT(0) ) {
                break;
            }
        }
        sign = 1;

        /* invert the word                                                 */
        if ( INT_INTOBJ(ptWord[k]) < 0 ) {
            sign = -1;
            for ( i = k; i <= leng; i++ ) {
                ptWord[i] = INTOBJ_INT( - INT_INTOBJ( ptWord[i] ) );
            }
        }

        for ( k = 1;  k <= numgens;  k++ ) {
            ptFac = BASE_PTR_PLIST(ptTree1[k]) - 1;
            if ( LEN_PLIST(ptTree1[k]) == leng ) {
                for ( i = 1;  i <= leng;  i++ ) {
                    if ( ptFac[i] != ptWord[i] ) {
                        break;
                    }
                }
                if ( i > leng ) {
                    return INTOBJ_INT( sign * k );
                }
            }
        }

        /* extend the tree                                                 */
        numgens++;
        if ( treesize < numgens ) {
            treesize = 2 * treesize;
            GROW_PLIST( objTree1, treesize );
            SET_LEN_PLIST( objTree1, treesize );
            CHANGED_BAG(objTree);
        }
        new = NEW_PLIST( T_PLIST, leng );
        SET_LEN_PLIST( new, leng );

        SET_ELM_PLIST( objTree, 3, INTOBJ_INT(numgens) );
        SET_ELM_PLIST( objTree1, numgens, new );
        CHANGED_BAG(objTree1);

        /* copy the word to the new bag                                    */
        ptWord = BASE_PTR_PLIST(objTree2) - 1;
        ptNew = BASE_PTR_PLIST(new) - 1;
        while ( leng > 0 ) {
            ptNew[leng] = ptWord[leng];
            leng--;
        }

        return INTOBJ_INT( sign * numgens );
    }

    /* handle the general case                                             */
    if ( LEN_PLIST(objTree1) != LEN_PLIST(objTree2) ) {
        ErrorQuit("inconsistent <tree> components", 0, 0);
    }

    for ( i = 1;  i <= numgens;  i++ ) {
        if ( INT_INTOBJ(ptTree1[i]) <= -i || INT_INTOBJ(ptTree1[i]) >= i
          || INT_INTOBJ(ptTree2[i]) <= -i || INT_INTOBJ(ptTree2[i]) >= i )
        {
            ErrorQuit("invalid <tree> components", 0, 0);
        }
    }

    /*  Freely reduce the given word                                       */
    leng = LEN_PLIST(word);
    for ( j = 0, i = 1;  i <= leng;  i++ ) {
        gen = INT_INTOBJ(ptWord[i]);
        if ( gen == 0 ) {
            continue;
        }
        if ( gen > numgens || gen < -numgens ) {
            ErrorQuit("invalid <word> entry [%d]", i, 0);
        }
        if ( j > 0 && gen == - INT_INTOBJ(ptWord[j]) ) {
            j--;
        }
        else {
            ptWord[++j] = ptWord[i];
        }
    }
    for ( i = j + 1;  i <= leng;  i++ ) {
        ptWord[i] = INTOBJ_INT( 0 );
    }
    leng = j;

    gen = ( leng == 0 ) ? 0 : INT_INTOBJ( ptWord[1] );
    u2 = 0; /* just to shut up gcc */
    for ( i = 2;  i <= leng;  i++ ) {
        u = gen;
        v = INT_INTOBJ( ELM_PLIST(word,i) );
        while ( i ) {

            /*  First handle the trivial cases                             */
            if ( u == 0 || v == 0 || ( u + v ) == 0 ) {
                gen = u + v;
                break;
            }

            /*  Cancel out factors, if possible                            */
            u1 = INT_INTOBJ( ptTree1[ (u > 0) ? u : -u ] );
            if ( u1 != 0 ) {
                if ( u > 0 ) {
                    u2 = INT_INTOBJ( ptTree2[u] );
                }
                else {
                    u2 = - u1;
                    u1 = - INT_INTOBJ( ptTree2[-u] );
                }
                if ( u2 == -v ) {
                    gen = u1;
                    break;
                }
            }
            v1 = INT_INTOBJ( ptTree1[ (v > 0) ? v : -v ] );
            if ( v1 != 0 ) {
                if ( v > 0 ) {
                    v2 = INT_INTOBJ( ptTree2[v] );
                }
                else {
                    v2 = - v1;
                    v1 = - INT_INTOBJ( ptTree2[-v] );
                }
                if ( v1 == -u ) {
                    gen = v2;
                    break;
                }
                if ( u1 != 0 && v1 == - u2 ) {
                    u = u1;
                    v = v2;
                    continue;
                }
            }

            /*  Check if there is already a tree entry [u,v] or [-v,-u]    */
            if ( u < -v ) {
                t1 = u; 
                t2 = v;
            }
            else {
                t1 = -v; 
                t2 = -u;
            }
            uabs = ( u > 0 ) ? u : -u;
            vabs = ( v > 0 ) ? v : -v;
            k = ( uabs > vabs ) ? uabs : vabs;
            for ( k++;  k <= numgens;  k++ ) {
                if ( INT_INTOBJ(ptTree1[k]) == t1 &&
                     INT_INTOBJ(ptTree2[k]) == t2 )
                {
                    break;
                }
            }

            /*  Extend the tree, if necessary                              */
            if ( k > numgens ) {
                numgens++;
                if ( treesize < numgens ) {
                    treesize = 2 * treesize;
                    GROW_PLIST( objTree1, treesize );
                    GROW_PLIST( objTree2, treesize );
                    SET_LEN_PLIST( objTree1, treesize );
                    SET_LEN_PLIST( objTree2, treesize );
                    ptTree1 = BASE_PTR_PLIST(objTree1) - 1;
                    ptTree2 = BASE_PTR_PLIST(objTree2) - 1;
                    CHANGED_BAG(objTree);
                }
                ptTree1[numgens] = INTOBJ_INT( t1 );
                ptTree2[numgens] = INTOBJ_INT( t2 );
                SET_ELM_PLIST( objTree, 3, INTOBJ_INT( numgens ) );
            }
            gen = ( u > - v ) ? -k : k;
            break;
        }
    }

    return INTOBJ_INT( gen );
}


/****************************************************************************
**
*F  FuncStandardizeTable2C(<self>,<table>,<table2>,<stan>)  . standardize ACT
**
**  This is the kernel routine for standardizing an augmented coset table. It
**  is called by the  GAP routine  'StandardizeTable2'.  The user should  not
**  call the kernel routine but only the GAP routine.
**
**  If  <stan> = 1  the table  is standardized  using  the  (old)  semilenlex
**  standard.
**  If  not  <stan> = 1  the table  is standardized  using the  (new)  lenlex
**  standard (this is the default).
*/
static Obj FuncStandardizeTable2C(Obj self, Obj table, Obj table2, Obj stan)
{
    Obj *               ptTable;        /* pointer to table                */
    Obj *               ptTabl2;        /* pointer to coset factor table   */
    UInt                nrgen;          /* number of rows of the table / 2 */
    Obj *               g;              /* one generator list from table   */
    Obj *               h;              /* generator list                  */
    Obj *               i;              /*  and inverse                    */
    Obj *               h2;             /* corresponding factor lists      */
    Obj *               i2;             /*  and inverse                    */
    UInt                acos;           /* actual coset                    */
    UInt                lcos;           /* last seen coset                 */
    UInt                mcos;           /*                                 */
    UInt                c1, c2;         /* coset temporaries               */
    Obj                 tmp;            /* temporary for swap              */
    UInt                j, k, nloop;    /* loop variables                  */

    RequirePlainList(0, table);
    RequirePlainList(0, table2);

    /* get the arguments                                                   */
    objTable = table;
    ptTable = BASE_PTR_PLIST(objTable) - 1;
    nrgen   = LEN_PLIST(objTable) / 2;
    for ( j = 1;  j <= nrgen*2;  j++ ) {
        if ( ! IS_PLIST(ptTable[j]) ) {
            ErrorQuit(
                "<table>[%d] must be a plain list (not a %s)",
                (Int)j,
                (Int)TNAM_OBJ(ptTable[j]) );
        }
    }
    objTable2 = table2;
    ptTabl2 = BASE_PTR_PLIST(objTable2) - 1;
    if (stan == INTOBJ_INT(1)) {
       /* use semilenlex standard                                          */
       nloop = nrgen;
    }
    else {
       /* use lenlex standard                                              */
       nloop = nrgen*2;
    }

    /* run over all cosets                                                 */
    acos = 1;
    lcos = 1;
    while ( acos <= lcos ) {

        /* scan through all columns of acos                                */
        for ( j = 1;  j <= nloop;  j++ ) {
            k = ( nloop == nrgen ) ? 2*j - 1 : j;
            g = BASE_PTR_PLIST(ptTable[k]) - 1;

            /* if we haven't seen this coset yet                           */
            if ( lcos+1 < INT_INTOBJ( g[acos] ) ) {

                /* swap rows lcos and g[acos]                              */
                lcos = lcos + 1;
                mcos = INT_INTOBJ( g[acos] );
                for ( k = 1;  k <= nrgen;  k++ ) {
                    h = BASE_PTR_PLIST(ptTable[2 * k - 1]) - 1;
                    i = BASE_PTR_PLIST(ptTable[2 * k]) - 1;
                    h2 = BASE_PTR_PLIST(ptTabl2[2 * k - 1]) - 1;
                    i2 = BASE_PTR_PLIST(ptTabl2[2 * k]) - 1;
                    c1 = INT_INTOBJ( h[lcos] );
                    c2 = INT_INTOBJ( h[mcos] );
                    if ( c1 != 0 )  i[c1] = INTOBJ_INT( mcos );
                    if ( c2 != 0 )  i[c2] = INTOBJ_INT( lcos );
                    tmp     = h[lcos];
                    h[lcos] = h[mcos];
                    h[mcos] = tmp;
                    tmp      = h2[lcos];
                    h2[lcos] = h2[mcos];
                    h2[mcos] = tmp;
                    if ( i != h ) {
                        c1 = INT_INTOBJ( i[lcos] );
                        c2 = INT_INTOBJ( i[mcos] );
                        if ( c1 != 0 )  h[c1] = INTOBJ_INT( mcos );
                        if ( c2 != 0 )  h[c2] = INTOBJ_INT( lcos );
                        tmp     = i[lcos];
                        i[lcos] = i[mcos];
                        i[mcos] = tmp;
                        tmp      = i2[lcos];
                        i2[lcos] = i2[mcos];
                        i2[mcos] = tmp;
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

    /* shrink the tables                                                   */
    for ( j = 1; j <= nrgen; j++ ) {
        SET_LEN_PLIST( ptTable[2*j-1], lcos );
        SET_LEN_PLIST( ptTable[2*j  ], lcos );
        SET_LEN_PLIST( ptTabl2[2*j-1], lcos );
        SET_LEN_PLIST( ptTabl2[2*j  ], lcos );
    }

    return 0;
}


/****************************************************************************
**
*F  FuncAddAbelianRelator( <hdCall> ) . . . . . . internal 'AddAbelianRelator'
**
**  'FuncAddAbelianRelator' implements 'AddAbelianRelator(<rels>,<number>)'
*/
static Obj FuncAddAbelianRelator(Obj self,
                                 Obj rels, /* relators list */
                                 Obj number)
{
    Obj *               ptRels;         /* pointer to relators list        */
    Obj *               pt1;            /* pointer to a relator            */
    Obj *               pt2;            /* pointer to another relator      */
    Obj                 tmp;
    Int                 numcols;        /* list length of the rel vectors  */
    Int                 numrows;        /* number of relators              */
    Int                 i, j;           /* loop variables                  */

    RequirePlainList(0, rels);
    ptRels = BASE_PTR_PLIST(rels) - 1;

    /* get the length of the given relators list                           */
    numrows = GetPositiveSmallInt("AddAbelianRelator", number);
    if ( numrows < 1 || LEN_PLIST(rels) < numrows ) {
        ErrorQuit("inconsistent relator number", 0, 0);
    }
    tmp = ELM_PLIST( rels, numrows );
    if ( tmp == 0 ) {
        ErrorQuit("inconsistent relator number", 0, 0);
    }
    pt2 = BASE_PTR_PLIST(tmp) - 1;

    /* get the length of the exponent vectors (the number of generators)   */
    numcols = LEN_PLIST(tmp);

    /* remove the last relator if it has length zero                       */
    for ( i = 1;  i <= numcols;  i++ ) {
        if ( INT_INTOBJ(pt2[i]) ) {
            break;
        }
    }
    if ( i > numcols ) {
        return INTOBJ_INT(numrows-1);
    }

    /* invert the relator if its first non-zero exponent is negative       */
    if ( INT_INTOBJ(pt2[i]) < 0 ) {
        for ( j = i;  j <= numcols;  j++ ) {
            pt2[j] = INTOBJ_INT( -INT_INTOBJ( pt2[j] ) );
        }
    }

    /* if the last relator occurs twice, remove one of its occurrences     */
    for ( i = 1;  i < numrows;  i++ ) {
        pt1 = BASE_PTR_PLIST(ptRels[i]) - 1;
        for ( j = 1;  j <= numcols;  j++ ) {
            if ( pt1[j] != pt2[j] ) {
                break;
            }
        }
        if ( j > numcols ) {
            break;
        }
    }
    if ( i < numrows ) {
        for ( i = 1;  i <= numcols;  i++ ) {
            pt2[i] = INTOBJ_INT(0);
        }
        numrows = numrows - 1;
    }

    return INTOBJ_INT( numrows );
}

/* new type functions that use different data structures */

static UInt ret1, ret2;

static UInt RelatorScan(Obj t, UInt di, Obj r)
{
    UInt  m,i,p,a,j;
    UInt  pa=0,pb=0;
    const UInt * rp;
    rp=(const UInt*)CONST_ADDR_OBJ(r);
    m=rp[1]; /* length is in position 1 */
    i=2;
    p=di;
    while ((p!=0) && (i<=(m+1))){
      a=rp[i];
      pa=p;
      p=INT_INTOBJ(ELM_PLIST(ELM_PLIST(t,a),p));
      if (p!=0) i++;
    }

    if (i>(m+1)) {
      if (p==di) 
        return 1;
      else
        return 0;
    }

    /*  backwards scan */
    j=m+1;
    p=di;
    while ((p!=0) && (j>=i)) {
      /* a=INT_INTOBJ(ELM_PLIST(invtab,INT_INTOBJ(ELM_PLIST(r,j))));*/

      a=rp[j];
      if ((a%2)==1)
        a++;
      else
        a--;
      pb=p;
      p=INT_INTOBJ(ELM_PLIST(ELM_PLIST(t,a),p));
      if (p!=0) j--;
    }

    if (j<i) {
      if (p==pa) 
        return 1;
      else
        return 0;
    }
    else {
      if (j==i) {
        a=rp[i];
        if ((a%2)==0) {
          p=a-1;
          ret1=pb;
          ret2=p;
        }
        else {
          p=a+1;
          ret1=pa;
          ret2=a;
        }
        SET_ELM_PLIST(ELM_PLIST(t,a),pa,INTOBJ_INT(pb));
        SET_ELM_PLIST(ELM_PLIST(t,p),pb,INTOBJ_INT(pa));

        return 2;
      }
      else
        return 1;
    }

}

/* data object type for the mangled relators */
static Obj TYPE_LOWINDEX_DATA;

/****************************************************************************
**
*F  FuncLOWINDEX_COSET_SCAN( <t>,<r>,<s1>,<s2>)
**
*/
static Obj FuncLOWINDEX_COSET_SCAN(Obj self,
                                   Obj t,  /* table */
                                   Obj r,  /* relators */
                                   Obj s1, /* stack */
                                   Obj s2) /* stack */
{
  UInt ok,i,j,d,e,x,y,l,sd;
  Obj  rx;
  UInt * s1a;
  UInt * s2a;

  ok=1;
  j=1;
  /* we convert stack entries to c-integers to avoid conversion */
  sd=LEN_PLIST(s1);
  s1a=(UInt*)ADDR_OBJ(s1);
  s2a=(UInt*)ADDR_OBJ(s2);
  s1a[1]=INT_INTOBJ((Obj)s1a[1]);
  s2a[1]=INT_INTOBJ((Obj)s2a[1]);
  while ((ok==1) && (j>0)) {
    d=s1a[j];
    x=s2a[j];
    j--;
    rx=ELM_PLIST(r,x);
    l=LEN_PLIST(rx);
    i=1;
    while ((ok==1)&&(i<=l)) {
      ok=RelatorScan(t,d,ELM_PLIST(rx,i));
      if (ok==2) {
        j++;
        if (j>sd) {
          sd=2*sd;
          GROW_PLIST(s1,sd);
          SET_LEN_PLIST(s1,sd);
          CHANGED_BAG(s1);
          GROW_PLIST(s2,sd);
          SET_LEN_PLIST(s2,sd);
          CHANGED_BAG(s2);
          s1a=(UInt*)ADDR_OBJ(s1);
          s2a=(UInt*)ADDR_OBJ(s2);
        }
        s1a[j]=ret1;
        s2a[j]=ret2;
        ok=1;
      }
      i++;
    }

    e=INT_INTOBJ(ELM_PLIST(ELM_PLIST(t,x),d));
    y=x+1;
    rx=ELM_PLIST(r,y);
    i=1;
    while ((ok==1)&&(i<=l)) {
      ok=RelatorScan(t,e,ELM_PLIST(rx,i));
      if (ok==2) {
        j++;
        if (j>sd) {
          sd=2*sd;
          GROW_PLIST(s1,sd);
          GROW_PLIST(s2,sd);
          s1a=(UInt*)ADDR_OBJ(s1);
          s2a=(UInt*)ADDR_OBJ(s2);
        }
        s1a[j]=ret1;
        s2a[j]=ret2;
        ok=1;
      }
      i++;
    }
  }
  /* clean up the mess we made */
  for (i=1;i<=sd;i++) {
    s1a[i]=(Int)INTOBJ_INT(0);
    s2a[i]=(Int)INTOBJ_INT(0);
  }
  if (ok==1)
    return True;
  else
    return False;
}

/****************************************************************************
**
*F  FuncLOWINDEX_IS_FIRST( <t>,<n>,<mu>,<nu>)
**
*/
static Obj FuncLOWINDEX_IS_FIRST(Obj self,
                                 Obj t,    /* table */
                                 Obj nobj, /* relators */
                                 Obj muo,  /* stack */
                                 Obj nuo)  /* stack */
{
  UInt l,ok,b,g,ga,de,a,n,mm;
  UInt * mu;
  UInt * nu;

  mm=LEN_PLIST(t)-1;
  n=INT_INTOBJ(nobj);
  mu=(UInt*)ADDR_OBJ(muo);
  nu=(UInt*)ADDR_OBJ(nuo);
  for (b=1;b<=n;nu[b++]=0);
  l=0;
  for (a=2;a<=n;a++) {
    for (b=1;b<=l;nu[mu[b++]]=0);
    mu[1]=a;
    nu[a]=1;
    l=1;
    ok=1;
    b=1;
    while ((ok==1) && (b<=n)) {
      g=1;
      while ((ok==1)&&(g<=mm)) {
        ga=INT_INTOBJ(ELM_PLIST(ELM_PLIST(t,g),b));
        de=INT_INTOBJ(ELM_PLIST(ELM_PLIST(t,g),mu[b]));
        if ((ga==0)||(de==0)) 
          ok=0;
        else {
          if (nu[de]==0) {
            l++;
            mu[l]=de;
            nu[de]=l;
          }
          if (nu[de]<ga) 
            return False;
          else {
            if (nu[de]>ga) {
              ok=0;
            }
          }
        }
        g=g+2;
      }
      b=b+1;
    }
  }
  return True;
}

/****************************************************************************
**
*F  FuncLOWINDEX_PREPARE_RELS( <rels> )
**
*/
static Obj FuncLOWINDEX_PREPARE_RELS(Obj self, Obj r) /* rels */
{
   UInt i,j,k,l;
   Obj ri, rel;
   UInt * rp;

   for (i=1;i<=LEN_PLIST(r);i++) {
    ri=ELM_PLIST(r,i);
    for (j=1;j<=LEN_PLIST(ri);j++) {
      rel=ELM_PLIST(ri,j); /* single relator */
      l=LEN_PLIST(rel);
      rp=(UInt*)ADDR_OBJ(rel);
      for (k=1;k<=l;k++) 
        rp[k]=INT_INTOBJ((Obj)rp[k]); /* convert relator entries to C-integers */
      /* change type */
      RetypeBag(rel,T_DATOBJ);
      SET_TYPE_DATOBJ(rel, TYPE_LOWINDEX_DATA);
    }
   }
   return (Obj) 0;
}

/****************************************************************************
**
*F  FuncTC_QUICK_SCAN( <c>,<o>,<alpha>,<w>)
**
*/
static Obj FuncTC_QUICK_SCAN(Obj self,
                             Obj c,      /* table */
                             Obj o,      /* offset */
                             Obj a,      /* alpha */
                             Obj w,      /* word */
                             Obj result) /* result list */
{
  Int f,b,ff,bb,r,i,j,alpha,offset;

  alpha=INT_INTOBJ(a);
  offset=INT_INTOBJ(o);

  f=alpha;i=1;
  r=LEN_PLIST(w);

  /*  # forward scan */
  /*  while i<=r and c[w[i]+offset][f]<>0 do */
  while ((i<=r) && 
    ((ff=INT_INTOBJ(ELM_PLIST(ELM_PLIST(c,INT_INTOBJ(ELM_PLIST(w,i))+offset),f)))
        !=0) ) {
    /*    f:=c[w[i]+offset][f];  Use extra variable so old f remains if
     *    i-condition triggered */
    f=ff;
    i++;  
  }

  if (i>r) {
    if (f!=alpha) {
      SET_ELM_PLIST(result,1,INTOBJ_INT(i));
      SET_ELM_PLIST(result,2,INTOBJ_INT(f));
      return True;
    }
    return False;
  }

/*  #backward scan */
  b=alpha; j=r;
  /*  while j>=i and c[-w[j]+offset][b]<>0 do */
  while ((j>=i) && 
    ((bb=INT_INTOBJ(ELM_PLIST(ELM_PLIST(c,-INT_INTOBJ(ELM_PLIST(w,j))+offset),b)))
      !=0) ) {

  /*    b:=c[-w[j]+offset][b];  implicitly done*/
    b=bb;
    j--;
   }
  if (j<=i) {
    SET_ELM_PLIST(result,1,INTOBJ_INT(i));
    SET_ELM_PLIST(result,2,INTOBJ_INT(f));
    SET_ELM_PLIST(result,3,INTOBJ_INT(j));
    SET_ELM_PLIST(result,4,INTOBJ_INT(b));
    return True;
  }
  return False;
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

    GVAR_FUNC_2ARGS(ApplyRel, app, relator),
    GVAR_FUNC_1ARGS(MakeConsequences, list),
    GVAR_FUNC_1ARGS(MakeConsequencesPres, list),
    GVAR_FUNC_2ARGS(StandardizeTableC, table, standard),
    GVAR_FUNC_3ARGS(ApplyRel2, app, relators, nums),
    GVAR_FUNC_1ARGS(CopyRel, relator),
    GVAR_FUNC_1ARGS(MakeCanonical, relator),
    GVAR_FUNC_2ARGS(TreeEntry, relator, word),
    GVAR_FUNC_3ARGS(StandardizeTable2C, table, table, standard),
    GVAR_FUNC_2ARGS(AddAbelianRelator, rels, number),
    GVAR_FUNC_4ARGS(LOWINDEX_COSET_SCAN, table, relators, stack1, stack2),
    GVAR_FUNC_4ARGS(LOWINDEX_IS_FIRST, table, n, mu, nu),
    GVAR_FUNC_1ARGS(LOWINDEX_PREPARE_RELS, rels),
    GVAR_FUNC_5ARGS(TC_QUICK_SCAN, table, offset, alpha, word, result),
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

    // import type object
    InitCopyGVar("TYPE_LOWINDEX_DATA", &TYPE_LOWINDEX_DATA);

    /* static variables                                                    */
    InitGlobalBag( &objRel      , "src/costab.c:objRel"       );
    InitGlobalBag( &objNums     , "src/costab.c:objNums"      );
    InitGlobalBag( &objFactor   , "src/costab.c:objFactor"    );
    InitGlobalBag( &objTable    , "src/costab.c:objTable"     );
    InitGlobalBag( &objTable2   , "src/costab.c:objTable2"    );
    InitGlobalBag( &objNext     , "src/costab.c:objNext"      );
    InitGlobalBag( &objPrev     , "src/costab.c:objPrev"      );
    InitGlobalBag( &objTree     , "src/costab.c:objTree"      );
    InitGlobalBag( &objTree1    , "src/costab.c:objTree1"     );
    InitGlobalBag( &objTree2    , "src/costab.c:objTree2"     );
    InitGlobalBag( &objWordValue, "src/costab.c:objWordValue" );
    InitGlobalBag( &objExponent , "src/costab.c:objExponent"  );

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

    return 0;
}


/****************************************************************************
**
*F  InitInfoCosetTable()  . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "costab",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoCosetTable ( void )
{
    return &module;
}
