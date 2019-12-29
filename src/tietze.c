/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions for computing with finite presentations.
*/

#include "tietze.h"

#include "bool.h"
#include "error.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "stats.h"
#include "stringobj.h"


/****************************************************************************
**
*V  TZ_SOMETHING  . . . . . . defining some constants for the Tietze routines
*/
#define TZ_NUMGENS               1
#define TZ_NUMRELS               2
#define TZ_TOTAL                 3
// #define TZ_GENERATORS            4
#define TZ_INVERSES              5
#define TZ_RELATORS              6
#define TZ_LENGTHS               7
#define TZ_FLAGS                 8
// #define TZ_FREEGENS              9
#define TZ_LENGTHTIETZE         21


/****************************************************************************
**
*F  CheckTietzeStack( <tietze>, <ptTietze> )
*/
static void CheckTietzeStack(Obj tietze, Obj ** ptTietze)
{
    /*  check the Tietze stack                                             */
    RequirePlainList(0, tietze);
    if ( LEN_PLIST(tietze) != TZ_LENGTHTIETZE ) {
        ErrorQuit( "<tietze> must have length %d (not %d)",
                   (Int)TZ_LENGTHTIETZE, (Int)LEN_PLIST(tietze) );
    }
    *ptTietze = ADDR_OBJ(tietze);
}


/****************************************************************************
**
*F  CheckTietzeRelators( <ptTietze>, <rels>, <ptRels>, <numrels> )
*/
static void
CheckTietzeRelators(Obj * ptTietze, Obj * rels, Obj ** ptRels, Int * numrels)
{
    *rels    = ptTietze[TZ_RELATORS];
    *numrels = INT_INTOBJ(ptTietze[TZ_NUMRELS]);
    if ( *rels == 0 || ! IS_PLIST(*rels) || LEN_PLIST(*rels) != *numrels ) {
        ErrorQuit("invalid Tietze relators list", 0, 0);
    }
    *ptRels = ADDR_OBJ(*rels);
}


/****************************************************************************
**
*F  CheckTietzeInverses( <ptTietze>, <invs>, <ptInvs>, <numgens> )
*/
static void
CheckTietzeInverses(Obj * ptTietze, Obj * invs, Obj ** ptInvs, Int * numgens)
{
    /* get and check the Tietze inverses list                              */
    *invs    = ptTietze[TZ_INVERSES];
    *numgens = INT_INTOBJ(ptTietze[TZ_NUMGENS]);
    if ( *invs==0 || !IS_PLIST(*invs) || LEN_PLIST(*invs)!=2*(*numgens)+1 ) {
        ErrorQuit("invalid Tietze inverses list", 0, 0);
    }
    *ptInvs = ADDR_OBJ(*invs) + (*numgens+1);
}


/****************************************************************************
**
*F  CheckTietzeLengths( <ptTietze>, <numrels>, <lens>, <ptLens> )
*/
static void
CheckTietzeLengths(Obj * ptTietze, Int numrels, Obj * lens, Obj ** ptLens)
{
    /*  Get and check the Tietze lengths list                              */
    *lens = ptTietze[TZ_LENGTHS];
    if ( *lens == 0 || ! IS_PLIST(*lens) || LEN_PLIST(*lens) != numrels ) {
        ErrorQuit("invalid Tietze lengths list", 0, 0);
    }
    *ptLens = ADDR_OBJ(*lens);
}


/****************************************************************************
**
*F  CheckTietzeFlags( <ptTietze>, <numrels>, <flags>, <ptFlags> )
*/
static void
CheckTietzeFlags(Obj * ptTietze, Int numrels, Obj * flags, Obj ** ptFlags)
{
    /* get and check the Tietze flags list                                 */
    *flags = ptTietze[TZ_FLAGS];
    if ( *flags==0 || ! IS_PLIST(*flags) || LEN_PLIST(*flags)!=numrels ) {
        ErrorQuit("invalid Tietze flags list", 0, 0);
    }
    *ptFlags = ADDR_OBJ(*flags);
}


/****************************************************************************
**
*F  CheckTietzeRelLengths( <ptTietze>, <ptRels>, <ptLens>, <nrels>, <total> )
*/
static void CheckTietzeRelLengths(
    Obj * ptTietze, Obj * ptRels, Obj * ptLens, Int numrels, Int * total)
{
    Int                i;

    /* Check list <lens> to contain the relator lengths                 */
    *total = 0;
    for ( i = 1;  i <= numrels;  i++ ) {
        if ( ptRels[i] == 0
          || ! IS_PLIST(ptRels[i])
          || INT_INTOBJ(ptLens[i]) != LEN_PLIST(ptRels[i]) )
        {
            ErrorQuit("inconsistent Tietze lengths list", 0, 0);
        }
        *total += INT_INTOBJ(ptLens[i]);
    }
    if ( *total != INT_INTOBJ(ptTietze[TZ_TOTAL]) ) {
        ErrorQuit("inconsistent total length", 0, 0);
    }
}


/****************************************************************************
**
*F  FuncTzSortC( <self>, <stack> )  . . . . . . . sort the relators by length
*/
static Obj FuncTzSortC(Obj self, Obj tietze)
{
    Obj *               ptTietze;       /* pointer to the Tietze stack     */
    Obj                 rels;           /* relators list                   */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 lens;           /* lengths list                    */
    Obj *               ptLens;         /* pointer to this list            */
    Obj                 flags;          /* handle of the flags list        */
    Obj *               ptFlags;        /* pointer to this list            */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 i, h, k;        /* loop variables                  */
    Obj                 rel, len, flag; /* list entries                    */
    Int                 total;

    /* check the Tietze stack                                              */
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );

    /* get and check the Tietze lengths list                               */
    CheckTietzeLengths( ptTietze, numrels, &lens, &ptLens );

    /* get and check the Tietze flags list                                 */
    CheckTietzeFlags( ptTietze, numrels, &flags, &ptFlags );

    /* check list <lens> to contain the relator lengths                    */
    CheckTietzeRelLengths( ptTietze, ptRels, ptLens, numrels, &total );

    /* sort the list                                                       */
    h = 1;
    while ( 9 * h + 4 < numrels )
        h = 3 * h + 1;
    while ( 0 < h ) {
        for ( i = h + 1; i <= numrels; i++ ) {
            rel = ptRels[i];  len = ptLens[i];  flag = ptFlags[i];
            k = i;
            if ( INT_INTOBJ(len) ) {
                while ( h < k
                  && ( !INT_INTOBJ(ptLens[k-h])
                     || len < ptLens[k-h]
                     || (len == ptLens[k-h] && flag > ptFlags[k-h])))
                {
                    ptRels[k] = ptRels[k-h];
                    ptLens[k] = ptLens[k-h];
                    ptFlags[k] = ptFlags[k-h];
                    k = k - h;
                }
            }
            ptRels[k] = rel;  ptLens[k] = len;  ptFlags[k] = flag;
        }
        h = h / 3;
    }
    for ( i = numrels;  i > 0;  i-- ) {
        if ( INT_INTOBJ(ptLens[i]) )
            break;
    }
    if ( i < numrels ) {
        SET_LEN_PLIST( rels,  i );  SHRINK_PLIST( rels,  i );
        SET_LEN_PLIST( lens,  i );  SHRINK_PLIST( lens,  i );
        SET_LEN_PLIST( flags, i );  SHRINK_PLIST( flags, i );
        SET_ELM_PLIST( tietze, TZ_NUMRELS, INTOBJ_INT(i) );
        CHANGED_BAG(tietze);
    }

    return 0;
}


/****************************************************************************
**
*F  FuncTzRenumberGens( <self>, <stack> ) . .  renumber the Tietze generators
*/
static Obj FuncTzRenumberGens(Obj self, Obj tietze)
{
    Obj *               ptTietze;       /* pointer to this stack           */
    Obj                 rels;           /* handle of the relators list     */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 invs;           /* handle of the inverses list     */
    Obj *               ptInvs;         /* pointer to this list            */
    Obj *               ptRel;          /* pointer to the ith relator      */
    Int                 numgens;        /* number of Tietze generators     */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 old;            /* generator or inverse            */
    Int                 leng;           /* relator length                  */
    Int                 i, j;           /* loop variables                  */

    /* check the Tietze stack                                              */
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );

    /* get and check the Tietze inverses list                              */
    CheckTietzeInverses( ptTietze, &invs, &ptInvs, &numgens );

    /*  Loop over all relators and replace the occurring generators        */
    for ( i = 1;  i <= numrels;  i++ ) {
        ptRel = ADDR_OBJ( ptRels[i] );
        leng  = LEN_PLIST( ptRels[i] );

        /* run through the relator and replace the occurring generators    */
        for ( j = 1;  j <= leng;  j++ ) {
            old = INT_INTOBJ( ptRel[j] );
            if ( old < -numgens || numgens < old || old == 0 ) {
                ErrorQuit( "gen no. %d in rel no. %d out of range", j,i );
            }
            ptRel[j] = ptInvs[-old];
        }
    }

    return 0;
}


/****************************************************************************
**
*F  FuncTzReplaceGens( <self>, <stack> )  replace Tietze generators by others
*/
static Obj FuncTzReplaceGens(Obj self, Obj tietze)
{
    Obj *               ptTietze;       /* pointer to this stack           */
    Obj                 rels;           /* handle of the relators list     */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 lens;           /* handle of the lengths list      */
    Obj *               ptLens;         /* pointer to this list            */
    Obj                 flags;          /* handle of the flags list        */
    Obj *               ptFlags;        /* pointer to this list            */
    Obj                 invs;           /* handle of the inverses list     */
    Obj *               ptInvs;         /* pointer to this list            */
    Obj                 rel;            /* handle of a relator             */
    Obj *               ptRel;          /* pointer to this relator         */
    Obj *               pt1;            /* pointer to a relator            */
    Obj *               pt2;            /* pointer to a relator            */
    Int                 numgens;        /* number of Tietze generators     */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 total;          /* total length of relators        */
    Int                 old, new;       /* generators or inverses          */
    Int                 leng, reduced;  /* relator lengths                 */
    Int                 altered;        /* flag                            */
    Int                 i, j;           /* loop variables                  */

    /* check the Tietze stack                                              */
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );

    /* get and check the Tietze lengths list                               */
    CheckTietzeLengths( ptTietze, numrels, &lens, &ptLens );

    /* check list <lens> to contain the relator lengths                    */
    CheckTietzeRelLengths( ptTietze, ptRels, ptLens, numrels, &total );

    /* get and check the Tietze flags list                                 */
    CheckTietzeFlags( ptTietze, numrels, &flags, &ptFlags );

    /* get and check the Tietze inverses list                              */
    CheckTietzeInverses( ptTietze, &invs, &ptInvs, &numgens );

    /* loop over all relators                                              */
    for ( i = 1; i <= numrels; i++ ) {
        rel = ptRels[i];
        pt2 = ptRel = ADDR_OBJ( rel );
        leng = INT_INTOBJ( ptLens[i] );
        altered = 0;

        /* don't change a square relator defining a valid involution       */
        if (ptFlags[i] == INTOBJ_INT(3) && leng == 2 &&
            ptRel[1] == ptInvs[-INT_INTOBJ(ptRel[1])] ) {
            continue;  /*  loop over i  */
        }

        /* run through the relator and replace the occurring generators    */
        for ( j = 1; j <= leng; j++ ) {

            old = INT_INTOBJ( ptRel[j] );
            if ( old < -numgens || numgens < old || old == 0 ) {
                ErrorQuit( "gen no. %d in rel no. %d out of range",
                           (Int)j, (Int)i );
            }

            new = INT_INTOBJ( ptInvs[-old] );
            if ( ! new ) {
                altered = 1;
                continue;  /*  loop over j  */
            }

            if ( pt2 > ptRel && *pt2 == ptInvs[new] ) {
                altered = 1;
                --pt2;
            }
            else {
                if ( new != old )  { altered = 1; }
                *++pt2 = INTOBJ_INT( new );
            }
        }

        if ( ! altered )  {
            continue; /*  loop over i  */
        }

        /* now cyclically reduce the relator                               */
        pt1 = ++ptRel;
        while ( pt1 < pt2 && *pt1 == ptInvs[INT_INTOBJ(*pt2)] ) {
            ++pt1;  --pt2;
        }
        if ( ptRel < pt1 ) {
            while ( pt1 <= pt2 )  { *ptRel++ = *pt1++; }
            pt2 = --ptRel;
        }

        /* resize the resulting relator, if necessary                      */
        ptRel = ADDR_OBJ( rel );
        reduced = pt2 - ptRel;
        if ( reduced < leng ) {
            SET_LEN_PLIST( rel, reduced );
            ptLens[i] = INTOBJ_INT( reduced );
            total = total - leng + reduced;
            SHRINK_PLIST( rel, reduced );
            CHANGED_BAG(rels);
            ptRels  = ADDR_OBJ( rels );
            ptLens  = ADDR_OBJ( lens );
            ptFlags = ADDR_OBJ( flags );
            ptInvs  = ADDR_OBJ( invs ) + (numgens + 1);
        }

        /*  Redefine the corresponding search flag                         */
        ADDR_OBJ( flags )[i] = INTOBJ_INT( 1 );
    }
    ptTietze = ADDR_OBJ( tietze );
    ptTietze[TZ_TOTAL] = INTOBJ_INT( total );

    return 0;
}


/****************************************************************************
**
*F  FuncTzSubstituteGen( <self>, <stack>, <gennum>, <word> )
*/
static Obj FuncTzSubstituteGen(Obj self, Obj tietze, Obj gennum, Obj word)
{
    Obj *               ptTietze;       /* pointer to this stack           */
    Obj                 rels;           /* handle of the relators list     */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 lens;           /* handle of the lengths list      */
    Obj *               ptLens;         /* pointer to this list            */
    Obj                 flags;          /* handle of the flags list        */
    Obj *               ptFlags;        /* pointer to this list            */
    Obj                 invs;           /* handle of the inverses list     */
    Obj *               ptInvs;         /* pointer to this list            */
    Obj *               ptWrd;          /* pointer to this word            */
    Obj                 iwrd;           /* handle of the inverse word      */
    Obj *               ptIwrd;         /* pointer to this word            */
    Obj                 new;            /* handle of a modified relator    */
    Obj *               ptNew;          /* pointer to this relator         */
    Obj                 rel;            /* handle of a relator             */
    Obj *               ptRel;          /* pointer to this relator         */
    Obj *               pt1;            /* pointer to a relator            */
    Obj *               pt2;            /* pointer to a relator            */
    Obj *               pt3;            /* pointer to a relator            */
    Int                 numgens;        /* number of Tietze generators     */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 total;          /* total length of relators        */
    Int                 given;          /* given generator and inverse     */
    Int                 gen, ginv;      /* given generator and inverse     */
    Int                 next;           /* generator or inverse            */
    Int                 leng, newleng;  /* relator lengths                 */
    Int                 wleng;          /* length of the replacing word    */
    Int                 occ;            /* number of occurrences           */
    Int                 i, j;           /* loop variables                  */
    Int                 alen,len;       /* number of changed relators */
    Obj                 Idx;
    Obj *               ptIdx;          /* List of changed relators */

    /* check the Tietze stack                                              */
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );

    /* get and check the Tietze lengths list                               */
    CheckTietzeLengths( ptTietze, numrels, &lens, &ptLens );

    /* get and check the Tietze flags list                                 */
    CheckTietzeFlags( ptTietze, numrels, &flags, &ptFlags );

    /* get and check the Tietze inverses list                              */
    CheckTietzeInverses( ptTietze, &invs, &ptInvs, &numgens );

    /* check the second argument (generator number)                        */
    if ( ! IS_INTOBJ(gennum) ) {
        ErrorQuit("<gennum> must be an integer", 0, 0);
    }
    given = INT_INTOBJ(gennum);
    gen   = ( given > 0 ) ? given : -given;
    if ( gen <= 0 || numgens < gen ) {
        ErrorQuit("generator number %d out of range", (Int)gen, 0);
    }
    ginv = INT_INTOBJ(ptInvs[gen]);

    /* check the third argument (replacing word)                           */
    if ( ! IS_PLIST(word) ) {
        ErrorQuit("invalid replacing word", 0, 0);
    }
    ptWrd = ADDR_OBJ(word);
    wleng = LEN_PLIST(word);
    for ( i = 1;  i <= wleng;  i++ ) {
        next = INT_INTOBJ( ptWrd[i] );
        if ( next < -numgens || next == 0 || next > numgens ) {
            ErrorQuit("entry [%d] of <Tietze word> out of range", (Int)i, 0);
        }
    }

    /* check list <lens> to contain the relator lengths                    */
    CheckTietzeRelLengths( ptTietze, ptRels, ptLens, numrels, &total );

    /* list of changed relator indices */
    len=0;
    alen=20;
    Idx=NEW_PLIST( T_PLIST, alen );
    SET_LEN_PLIST(Idx,alen);

    /* allocate a bag for the inverse of the replacing word                */
    iwrd   = NEW_PLIST( T_PLIST, wleng );
    ptRels = ADDR_OBJ( rels );
    ptLens = ADDR_OBJ( lens );
    ptInvs = ADDR_OBJ( invs ) + (numgens + 1);
    ptWrd  = ADDR_OBJ( word );
    ptIwrd = ADDR_OBJ( iwrd );
    ptIdx  = ADDR_OBJ( Idx );

    /* invert the replacing word                                           */
    SET_LEN_PLIST( iwrd, wleng );
    pt1 = ptWrd;
    pt2 = ptIwrd + wleng;
    while ( pt2 > ptIwrd ) {
        *pt2-- = ptInvs[INT_INTOBJ(*++pt1)];
    }
    if ( given < 0 ) {
        new = word;  word = iwrd;  iwrd = new;
        ptWrd = ADDR_OBJ(word);  ptIwrd = ADDR_OBJ(iwrd);
    }

    /* loop over all relators                                              */
    for ( i = 1;  i <= numrels;  i++ ) {
        /* We assume that ptRels, ptLens and ptIdx are valid at the 
           beginning of this loop (and not rendered invalid by a 
           garbage collection)! */
        rel = ptRels[i];
        ptRel = ADDR_OBJ(rel);
        leng = INT_INTOBJ(ptLens[i]);
        if ( leng == 0 )  { 
            continue;
        }

        /* run through the relator and count the occurrences of gen        */
        occ = 0;
        for ( j = 1;  j <= leng;  j++ ) {
            next = INT_INTOBJ( ptRel[j] );
            if ( next < -numgens || numgens < next ) {
                ErrorQuit( "gen no. %d in rel no. %d out of range",
                           (Int)j, (Int)i );
            }
            if (next == gen || next == ginv )
                ++occ;
        }
        if ( occ == 0 )  {
            continue;
        }

        /* mark that the relator changed */
        if (len>=alen) {
          alen+=100; /* more relators changed */
          GROW_PLIST(Idx,alen);
          SET_LEN_PLIST(Idx,alen);
          ptIdx=ADDR_OBJ(Idx);
        }
        len+=1;
        ptIdx[len]=INTOBJ_INT(i);
        CHANGED_BAG(Idx);

        /* allocate a bag for the modified Tietze relator                  */
        new = NEW_PLIST( T_PLIST, leng + occ * (wleng - 1) );
        /* Now renew saved pointers into bags: */
        pt2 = ptNew = ADDR_OBJ( new );
        ptIdx  = ADDR_OBJ( Idx );
        ptLens = ADDR_OBJ( lens );
        ptInvs = ADDR_OBJ( invs ) + (numgens + 1);
        ptWrd  = ADDR_OBJ( word );
        ptIwrd = ADDR_OBJ( iwrd );
        ptRel  = ADDR_OBJ( rel );

        /* now run again through the relator and modify it                 */
        for ( j = 1;  j <= leng;  j++ ) {
            next = INT_INTOBJ( ptRel[j] );
            if ( next == gen || next == -gen ) {
                pt1 = ( next > 0 ) ? ptWrd : ptIwrd;
                pt3 = pt1 + wleng;
                while ( pt1 < pt3 ) {
                    ++pt1;
                    if ( pt2 > ptNew && *pt2 == ptInvs[INT_INTOBJ(*pt1)] )
                        --pt2;
                    else
                        *++pt2 = *pt1;
                }
            }
            else {
                if ( pt2 > ptNew && *pt2 == ptInvs[next] )
                    --pt2;
                else
                    *++pt2 = INTOBJ_INT( next );
            }
        }

        /*  now cyclically reduce the relator                              */
        pt1 = ++ptNew;
        while ( pt1 < pt2 && *pt1 == ptInvs[INT_INTOBJ(*pt2)] ) {
            ++pt1;  --pt2;
        }
        if ( ptNew < pt1 ) {
            while ( pt1 <= pt2 )   *ptNew++ = *pt1++;
            pt2 = --ptNew;
        }

        /*  resize and save the resulting relator                          */
        ptNew = ADDR_OBJ( new );
        newleng = pt2 - ptNew;
        SET_LEN_PLIST( new, newleng );
        ptLens[i] = INTOBJ_INT( newleng );
        total = total - leng + newleng;
        SHRINK_PLIST( new, newleng );
        ptRels = ADDR_OBJ( rels );
        ptLens = ADDR_OBJ( lens );
        ptIdx  = ADDR_OBJ( Idx );
        ptRels[i] = new;
        ADDR_OBJ( flags )[i] = INTOBJ_INT( 1 );
        CHANGED_BAG(rels);
    }

    SHRINK_PLIST(Idx,len);
    SET_LEN_PLIST(Idx,len);
    CHANGED_BAG(Idx);

    ptTietze = ADDR_OBJ( tietze );
    ptTietze[TZ_TOTAL] = INTOBJ_INT( total );

    return Idx;
}


/****************************************************************************
**
*F  FuncTzOccurrences( <self>, <args> ) . .  occurrences of Tietze generators
*/
static Obj FuncTzOccurrences(Obj self, Obj args)
{
    Obj                 tietze;         /* handle of the Tietze stack      */
    Obj *               ptTietze;       /* pointer to the Tietze stack     */
    Obj                 rels;           /* handle of the relators list     */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 res;            /* handle of the result            */
    Obj                 cnts;           /* list of the counts              */
    Obj *               ptCnts;         /* pointer to the counts list      */
    Obj                 mins;           /* list of minimal occurrence list  */
    Obj *               ptMins;         /* pointer to the minimals list    */
    Obj                 lens;           /* list of lengths of those        */
    Obj *               ptLens;         /* pointer to the lengths list     */
    Obj                 rel;            /* handle of a relator             */
    Obj *               ptRel;          /* pointer to this relator         */
    Obj                 aux;            /* auxiliary list                  */
    Int  *              ptAux;          /* pointer to the lengths list     */
    Int                 numgens;        /* number of Tietze generators     */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 leng;           /* length of a relator             */
    Int                 num, next;      /* generators or inverses          */
    Int                 i, k;           /* loop variables                  */
    Int                 c;              /* count of one generator          */
    Int                 nr;             /* number of occurrences           */
    Int                 nr1;            /* nr of occurrences in one word   */
    Int                 nrm;            /* minimal value of 'nr1'          */
    Int                 min;            /* word that has this minimum      */

    /* get and check arguments                                             */
    if ( ! IS_SMALL_LIST(args) || 2 < LEN_LIST(args) || LEN_LIST(args) < 1 ) {
        ErrorQuit( "usage: TzOccurrences( <Tietze stack>[, <gen no.> ] )",
                   0, 0);
    }

    /* check the first argument (Tietze stack)                             */
    tietze = ELM_LIST( args, 1 );
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );
    numgens = INT_INTOBJ(ptTietze[TZ_NUMGENS]);

    /* get and check the given generator number                            */
    if ( LEN_LIST(args) == 2 ) {
        num = INT_INTOBJ( ELM_LIST(args,2) );
        if ( num <= 0 || numgens < num ) {
            ErrorQuit("given generator number out of range", 0, 0);
        }
        numgens = 1;
    }
    else {
        num = numgens;
    }

    /* allocate the result lists                                           */
    cnts = NEW_PLIST( T_PLIST, numgens );
    SET_LEN_PLIST( cnts, numgens );
    for ( k = 1;  k <= numgens;  k++ )
        ADDR_OBJ(cnts)[k] = INTOBJ_INT(0);

    mins = NEW_PLIST( T_PLIST, numgens );

    lens = NEW_PLIST( T_PLIST, numgens );
    
    res = NEW_PLIST( T_PLIST, 3 );
    SET_LEN_PLIST( res, 3 );
    ADDR_OBJ(res)[1] = cnts;
    ADDR_OBJ(res)[2] = mins;
    ADDR_OBJ(res)[3] = lens;
    CHANGED_BAG(res);

    /* allocate an auxiliary list                                          */
    ptAux = 0;
    if ( numgens > 1 ) {
        aux   = NEW_STRING( (numgens+1)*sizeof(Int) );
        ptAux = (Int*)ADDR_OBJ(aux);
        ptAux[0] = numgens;
        for ( k = 1;  k <= numgens;  k++ )
            ptAux[k] = 0;

    }

    /* now we can safely grab pointers                                     */
    ptRels = ADDR_OBJ(rels);
    ptCnts = ADDR_OBJ(cnts);
    ptLens = ADDR_OBJ(lens);
    ptMins = ADDR_OBJ(mins);

    /* handle special case of single generator in generator list           */
    if ( numgens == 1 ) {

        /* initialize the counters                                         */
        nr = 0;  nrm = 0;  min = 0;

        /* loop over all relators                                          */
        for ( i = 1;  i <= numrels;  i++ ) {
            rel = ptRels[i];
            if ( rel == 0 || ! IS_PLIST(rel) ) {
                ErrorQuit("invalid entry [%d] in Tietze relators list",
                          (Int)i, 0);
            }
            ptRel = ADDR_OBJ(rel);
            leng  = LEN_PLIST(rel);

            /* loop over the letters of the relator                        */
            nr1 = 0;
            for ( k = 1;  k <= leng;  k++ ) {
                next = INT_INTOBJ( ptRel[k] );
                if ( next == num || next == -num )  {
                    nr1++;
                }
            }

            /* check whether the number of occurrences of num is less than */
            /* in the preceding relators                                   */
            nr += nr1;
            if ( nrm == 0
              || (0 < nr1 && nr1 < nrm)
              || (nr1 == nrm && LEN_PLIST(rel) < LEN_PLIST(ptRels[min])) )
            {
                nrm = nr1;  min = i;
            }
        }

        /* put the information into the result bags                        */
        ptCnts[1] = INTOBJ_INT( nr );
        if ( nr != 0 ) {
            ptCnts[1] = INTOBJ_INT( nr );
            SET_LEN_PLIST( lens, 1 );
            SET_ELM_PLIST( lens, 1, INTOBJ_INT(nrm) );
            SET_LEN_PLIST( mins, 1 );
            SET_ELM_PLIST( mins, 1, INTOBJ_INT(min) );
        }
    }

    /* handle general case of all Tietze generators                        */
    else {

        /* loop over all relators                                          */
        for ( i = 1;  i <= numrels;  i++ ) {
            rel = ptRels[i];
            if ( rel == 0 || ! IS_PLIST(rel) ) {
                ErrorQuit("invalid entry [%d] in Tietze relators list",
                          (Int)i, 0);
            }
            ptRel = ADDR_OBJ(rel);
            leng  = LEN_PLIST(rel);

            /* loop over the letters of the relator                        */
            for ( k = 1;  k <= leng;  k++ ) {
                next = INT_INTOBJ( ptRel[k] );
                if ( next < 0 ) next = -next;
                if ( next == 0 || numgens < next ) {
                    ErrorQuit( "invalid entry [%d][%d] in Tietze rels list",
                               (Int)i, (Int)k );
                }
                (ptAux[next])++;
            }

            /* loop over the generators, collecting the counts             */
            for ( k = 1;  k <= numgens;  k++ ) {
                c = ptAux[k];
                if ( !c )
                    continue;
                ptAux[k] = 0;
                if ( ! SUM_INTOBJS( ptCnts[k], ptCnts[k], INTOBJ_INT(c) ) ) {
                    ErrorQuit("integer overflow", 0, 0);
                }
                if ( 0 < c ) {
                    if ( ptLens[k] == 0 || c < INT_INTOBJ(ptLens[k])
                      || (c == INT_INTOBJ(ptLens[k]) 
                       && LEN_PLIST(rel) 
                          < LEN_PLIST(ptRels[INT_INTOBJ(ptMins[k])])) )
                    {
                        ptLens[k] = INTOBJ_INT(c);
                        ptMins[k] = INTOBJ_INT(i);
                    }
                }
            }
        }

        /* find the correct length of the minimals and lengths lists       */
        k = numgens;
        while ( ptMins[k] == 0 )
            k--;
        SET_LEN_PLIST( mins, k );
        SET_LEN_PLIST( lens, k );
    }

    return res;
}


/****************************************************************************
**
*F  FuncTzOccurrencesPairs( <self>, <args> )  . . . . .  occurrences of pairs
*/
static Obj FuncTzOccurrencesPairs(Obj self, Obj args)
{
    Obj                 tietze;         /* handle of the Tietze stack      */
    Obj *               ptTietze;       /* pointer to the Tietze stack     */
    Obj                 rels;           /* handle of the relators list     */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 invs;           /* handle of the inverses list     */
    Obj *               ptInvs;         /* pointer to this list            */
    Obj                 res;            /* handle of the resulting list    */
    Obj *               ptRes;          /* pointer to this list            */
    Obj                 rel;            /* handle of a relator             */
    Obj *               ptRel;          /* pointer to this relator         */
    Obj                 numObj;         /* handle of generator number      */
    Obj                 invObj;         /* handle of inverse gen number    */
    Int                 num, i, ii;     /* generator numbers               */
    Int                 numgens;        /* number of Tietze generators     */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 length;         /* length of the current relator   */
    Int                 j1, j2, r;      /* loop variables                  */

    /* get and check arguments                                             */
    if ( ! IS_SMALL_LIST(args) || 3 < LEN_LIST(args) || LEN_LIST(args) < 2 ) {
        ErrorQuit(
          "usage: TzOccurrencesPairs( <Tietze stack>, <gen>[, <list>] )",
          0, 0);
    }

    /* check the first argument (Tietze stack)                             */
    tietze = ELM_LIST( args, 1 );
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );

    /* get and check the Tietze inverses list                              */
    CheckTietzeInverses( ptTietze, &invs, &ptInvs, &numgens );

    /* get and check the Tietze generator number                           */
    numObj = ELM_LIST( args, 2 );
    if ( ! IS_INTOBJ(numObj) ) {
        ErrorQuit("<gen> must be a Tietze generator number", 0, 0);
    }
    num = INT_INTOBJ(numObj);
    if ( num <= 0 || num > numgens ) {
        ErrorQuit("given generator number is out of range", 0, 0);
    }

    /*  Get and check the list for the results, if specified               */
    if ( LEN_PLIST(args) == 2 ) {
        res = NEW_PLIST( T_PLIST, 4*numgens );
        SET_LEN_PLIST( res, 4*numgens );
    }
    else {
        res = ELM_LIST( args, 3 );
        if ( res == 0 || ! IS_PLIST(res) || LEN_PLIST(res) != 4*numgens ) {
            ErrorQuit( "<list> must be a list of length %d",
                       (Int)4*numgens, 0);
        }
    }

    /*  return, if num = numgens                                           */
    if ( num == numgens )  {
        return res;
    }

    /*  get pointers to the involved lists                                 */
    ptRels = ADDR_OBJ( rels );
    ptInvs = ADDR_OBJ( invs ) + (numgens + 1);
    ptRes  = ADDR_OBJ( res );

    /* get the handle of the inverse of the given generator                */
    invObj = ptInvs[num];

    /* ptRes[i]           counts the occurrences of gen * gen[i]           */
    /* ptRes[numgens+i]   counts the occurrences of gen * gen[i]^-1        */
    /* ptRes[2*numgens+i] counts the occurrences of gen^-1 * gen[i]        */
    /* ptRes[3*numgens+i] counts the occurrences of gen^-1 * gen[i]^-1     */

    /* initialize the counters                                             */
    for ( i = 1; i <= 4 * numgens; i++ ) {
        ptRes[i] = INTOBJ_INT(0);
    }

    /* loop over the relators                                       */
    for ( r = 1; r <= numrels; r++ ) {
        rel = ptRels[r];
        if ( rel == 0 || ! IS_PLIST(rel) ) {
            ErrorQuit("invalid Tietze relator [%d]", (Int)r, 0);
        }
        ptRel = ADDR_OBJ(rel) + 1;

        /* skip the current relator if its length is less than 2           */
        length = LEN_PLIST( rel );
        if ( length < 2 )  {
            continue;
        }

        /* loop over the current relator and investigate the pairs         */
        /* ( ptRel[j1], ptRel[j2] )                                        */
        j1 = length - 1;
        for ( j2 = 0;  j2 < length;  j1 = j2, j2++ ) {

            /* count any "forward" pair  gen * gen[i],  gen * gen[i]^-1,   */
            /* gen^-1 * gen[i],  or  gen^-1 * gen[i]^-1  ( with num < i )  */
            if ( ptRel[j1] == numObj || ptRel[j1] == invObj ) {
                i = INT_INTOBJ( ptRel[j2] );
                if ( -num <= i && i <= num )  {
                    continue;
                }
                if ( i < -numgens || numgens < i ) {
                    ErrorQuit( "invalid entry %d in Tietze relator [%d]",
                               (Int)i, (Int)r );
                }
                if ( i < 0 )
                    i = numgens - i;
                if ( ptRel[j1] != numObj )
                    i = i + 2 * numgens;
                if ( ! SUM_INTOBJS( ptRes[i], ptRes[i], INTOBJ_INT(1) ) ) {
                    ErrorQuit("integer overflow", 0, 0);
                }
            }

            /* count any "backward" pair  gen[i]^-1 * gen^-1,              */
            /* gen[i] * gen^-1,  gen[i]^-1 * gen,  or  gen[i] * gen        */
            /* ( with num < i )  which is not covered by a forward pair    */
            else if ( ptRel[j2] == numObj || ptRel[j2] == invObj ) {
                i = INT_INTOBJ( ptRel[j1] );
                if ( -num <= i && i <= num )  {
                    continue;
                }
                if ( i < - numgens || numgens < i ) {
                    ErrorQuit( "invalid entry %d in Tietze relator [%d]",
                               (Int)i, (Int)r );
                }
                ii = INT_INTOBJ( ptInvs[i] );
                if ( !( (numObj == invObj
                        && ptRel[(j2+1)%length] == INTOBJ_INT(ii))
                     || (i == ii
                        && ptInvs[INT_INTOBJ(ptRel[(j1+length-1)%length])] 
                           == ptRel[j2]) ) )
                {
                    if ( ii < 0 )
                        ii = numgens - ii;
                    if ( ptRel[j2] != invObj )
                        ii = ii + 2 * numgens;
                    if ( !SUM_INTOBJS(ptRes[ii],ptRes[ii],INTOBJ_INT(1)) ) {
                        ErrorQuit("integer overflow", 0, 0);
                    }
                }
            }
        }
    }

    return res;
}


/****************************************************************************
**
*F  FuncTzSearchC( <self>, <args> ) . find subword matches in Tietze relators
*/
static Obj FuncTzSearchC(Obj self, Obj args)
{
    Obj                 tietze;         /* handle of the Tietze stack      */
    Obj *               ptTietze;       /* pointer to this stack           */
    Obj                 rels;           /* handle of the relators list     */
    Obj *               ptRels;         /* pointer to this list            */
    Obj                 lens;           /* handle of the lengths list      */
    Obj *               ptLens;         /* pointer to this list            */
    Obj                 invs;           /* handle of the inverses list     */
    Obj *               ptInvs;         /* pointer to this list            */
    Obj                 flags;          /* handle of the flags list        */
    Obj *               ptFlags;        /* pointer to this list            */
    Obj                 word;           /* handle of the given relator     */
    Obj                 lo;             /* handle of current list relator  */
    Obj                 wo;             /* handle of a relator             */
    Obj                 tmp;            /* handle of the second argument   */
    Obj                 equ;            /* handle of the fifth argument    */
    UInt1               keys1[8192];    /* hash table of key values        */
    UInt1               keys2[8192];    /* hash table of key values        */
    UInt1               keys3[8192];    /* hash table of key values        */
    UInt                inv;            /* inverse for key computation     */
    UInt                key;            /* key value of subword            */
    Int                 numgens;        /* number of Tietze generators     */
    Int                 numrels;        /* number of Tietze relators       */
    Int                 total;          /* total length of relators        */
    Obj *               ptr;            /* pointer to a relator            */
    Obj *               v;              /* pointers into relators          */
    Obj *               w;              /* pointers into relators          */
    Obj *               ptx;            /* pointers into relators          */
    Obj *               pty;            /* pointers into relators          */
    Int                 i1, j1;         /* loop variables                  */
    Int                 i2, j2;         /* loop variables                  */
    Int                 i3, j3;         /* loop variables                  */
    Int                 len1;           /* relator length                  */
    Int                 lmin, lmax;     /* bound for relator lengths       */
    Int                 pos1, pos2;     /* position of the given relator   */
    Int                 xmax;           /* position of the given relator   */
    Int                 newflag, flag1; /* Tietze relator flags            */
    Int                 xflag, yflag;   /* Tietze relator flags            */
    Int                 xlen, xlen1;    /* length of the given relator     */
    Int                 mlen;           /* length of the wanted match      */
    Int                 ylen, ylen1;    /* length of the current relator   */
    Int                 newlen;         /* length of a new relator         */
    Int                 n, m;           /* subword lengths                 */
    Int                 count;          /* number of altered relators      */
    Int                 i, j, jj, x, y; /* loop variables                  */
    Int                 lasty;          /* flag                            */
    Int                 altered;        /* flag                            */
    Int                 equal;          /* flag                            */

    /* get and check arguments                                             */
    if ( ! IS_SMALL_LIST(args) || 4 < LEN_LIST(args) || LEN_LIST(args) < 3 ) {
        ErrorQuit(
            "usage: TzSearchC( <Tietze stack>, <pos1>, <pos2>[, <equal>] )",
            0, 0);
    }

    /* check the first argument (Tietze stack)                             */
    tietze = ELM_LIST( args, 1 );
    CheckTietzeStack( tietze, &ptTietze );

    /* get and check the Tietze relators list                              */
    CheckTietzeRelators( ptTietze, &rels, &ptRels, &numrels );

    /* get and check the Tietze lengths list                               */
    CheckTietzeLengths( ptTietze, numrels, &lens, &ptLens );

    /* get and check the Tietze flags list                                 */
    CheckTietzeFlags( ptTietze, numrels, &flags, &ptFlags );

    /* check list <lens> to contain the relator lengths                    */
    CheckTietzeRelLengths( ptTietze, ptRels, ptLens, numrels, &total );

    /* get and check the Tietze inverses list                              */
    CheckTietzeInverses( ptTietze, &invs, &ptInvs, &numgens );

    /* check the second argument                                           */
    tmp = ELM_LIST( args, 2 );
    if ( ! IS_INTOBJ(tmp) ) {
        ErrorQuit("<pos1> must be a positive int", 0, 0);
    }
    pos1 = INT_INTOBJ(tmp);
    if ( pos1 > numrels ) {
        ErrorQuit("<pos1> out of range: %d", (Int)pos1, 0);
    }

    /* check the third argument                                            */
    tmp = ELM_LIST( args, 3 );
    if ( ! IS_INTOBJ(tmp) ) {
        ErrorQuit("<pos2> must be a positive int", 0, 0);
    }
    pos2 = INT_INTOBJ(tmp);
    if ( pos2 > numrels ) {
        ErrorQuit("<pos2> out of range: %d", (Int)pos2, 0);
    }

    /* check the fourth argument                                           */
    if ( LEN_LIST(args) == 3 ) {
        equ = False;
    }
    else {
        equ = ELM_LIST( args, 4 );
        if ( equ != False && equ != True ) {
            ErrorQuit("<equal> must be false or true", 0, 0);
        }
    }
    equal = ( equ == True );

    /* Skip relators of inconvenient lengths or with inconvenient flags,   */
    /*  and return if the remaining range is empty                         */
    while ( pos1 <= pos2
        && (INT_INTOBJ( ptLens[pos1] ) < 2
         || INT_INTOBJ( ptFlags[pos1] ) > 1
         || (equal && ( INT_INTOBJ( ptLens[pos1] ) < 4
                     || INT_INTOBJ( ptLens[pos1] ) % 2 == 1 ) ) ) )
    {
        pos1++;
    }
    if ( pos1 > pos2 || pos1 == numrels ) {
        return INTOBJ_INT(0);
    }

    /* get the range of compatible relator lengths                         */
    len1 = INT_INTOBJ( ptLens[pos1] );
    lmin = len1 - ( len1 % 2 );
    lmax = ( equal ) ? lmin : lmin + 1;

    /* initialize some variables                                           */
    newflag = ( equal ) ? 1 : 2;
    count = 0;
    lasty = 0;
    xmax = pos1 - 1;
    flag1 = INT_INTOBJ( ptFlags[pos1] );

    /* Compute the length of the wanted match and the corresponding        */
    /*  inverse factor                                                     */
    mlen = equal ? ( lmin + 1 ) / 2 : lmin / 2 + 1;
    inv = 1;
    for ( i = 1; i <= mlen; i++ )
       inv = 109109 * inv;

    /* initialize the hash table                                           */
    for ( i = 0; i < 2048; i++ )
       ((UInt4 *)keys1)[i] = ((UInt4 *)keys2)[i] = ((UInt4 *)keys3)[i] = 0;

    /* loop over the Tietze relators, starting at position pos1            */
    for ( y = pos1;  y < numrels;  ) {
       word  = ptRels[y];
       ylen  = INT_INTOBJ( ptLens[y] );
       yflag = INT_INTOBJ( ptFlags[y] );
       if ( y <= pos2 && lmin <= ylen && ylen <= lmax && yflag <= 1 ) {

          /* add the key values of the current relator to the hash table   */
          ptr = ADDR_OBJ(word);

          key = 0;

          for ( i = 0, w = ptr+1;  i < mlen;  i++, w++ )
             key = 109109 * key + ((UInt)*w >> 2);

          for ( i = 0, v = ptr+1, w = v+mlen; i < ylen; i++, v++, w++ ) {
             keys1[ key & 8191 ] = 1;
             keys2[ (key >> 11) & 8191 ] |= (1 << ((key >> 8) & 7));
             keys3[ (key >> 19) & 8191 ] |= (1 << ((key >> 16) & 7));
             if ( i == ylen-mlen )
                 w = ptr+1;
             key = 109109 * key - inv * ((UInt)*v >> 2) + ((UInt)*w >> 2);
          }

          key = 0;

          for ( i = 0, w = ptr+ylen; i < mlen; i++, w-- ) {
             key = 109109 * key + ((UInt) ptInvs[INT_INTOBJ(*w)] >> 2);
          }

          for ( i = 0, v = ptr+ylen, w = v-mlen; i < ylen; i++, v--, w-- ) {
             keys1[ key & 8191 ] = 1;
             keys2[ (key >> 11) & 8191 ] |= (1 << ((key >> 8) & 7));
             keys3[ (key >> 19) & 8191 ] |= (1 << ((key >> 16) & 7));
             if ( i == ylen-mlen )
                 w = ptr+ylen;
             key = 109109 * key
                 - inv * ((UInt) ptInvs[INT_INTOBJ(*v)] >> 2)
                 + ( (UInt) ptInvs[INT_INTOBJ(*w)] >> 2 );
          }
          if ( len1 > ylen )
              len1 = ylen;
          if ( flag1 < yflag )
              flag1 = yflag;
          xmax = y;
       }

       /* move to next relator                                             */
       y++;

       /* initialize some variables                                        */
       lo      = ptRels[y];
       ylen    = INT_INTOBJ( ptLens[y] );
       yflag   = INT_INTOBJ( ptFlags[y] );
       ylen1   = ylen - 1;
       altered = 0;

       /* Loop to the next relator, if the current relator is too short    */
       if ( y > lasty
         && (ylen < len1 || yflag > 1 || (!equal && !(yflag + flag1)) ) )
       {
          continue;  /*  loop over y */
       }
       lasty = y;

       /* Compute the key values of the current relator                    */
       ptr = ADDR_OBJ(lo);

       key = 0;

       for ( j = 0, w = ptr+1; j < mlen; j++, w++ )
          key = 109109 * key + ( (UInt)*w >> 2 );

       for ( j = 0; j < ylen; j++ ) {

          /* check for key match in the tables                             */
          if ( keys1[ key & 8191 ]
             && (keys2[ (key >> 11) & 8191 ] & (1 << ((key >> 8) & 7)))
             && (keys3[ (key >> 19) & 8191 ] & (1 << ((key >> 16) & 7))) ){

             /* loop over the (relevant) given relators                    */
             for ( x = pos1; x <= xmax; x++ ) {

                wo    = ptRels[x];
                xlen  = INT_INTOBJ( ptLens[x] );
                xflag = INT_INTOBJ( ptFlags[x] );
                if ( xlen < len1 || xlen > lmax || xlen > ylen
                  || xflag > 1 || (!equal && !( xflag + yflag )) )
                {
                   continue;  /*  loop over x */
                }

                xlen1 = xlen - 1;
                ptx = ADDR_OBJ(wo) + 1;
                pty = ADDR_OBJ(lo) + 1;

                /* loop over all possible positions in the given relator   */
                for ( i = 0; i < xlen; i++ ) {

                   /* search forward for a match of length at least mlen   */
                   i2 = i;  j2 = j;
                   for ( n = 0; n < xlen; n++,
                      i2 = (i2 == xlen1) ? 0 : i2 + 1,
                      j2 = (j2 == ylen1) ? 0 : j2 + 1 ) {
                      if ( ptx[i2] != pty[j2] )
                          break;  /* loop over n */
                   }
                   if ( n < mlen )  continue;  /*  loop over i             */

                   /* search backward to find the whole match              */
                   i1 = (i == 0) ? xlen1 : i - 1;
                   j1 = (j == 0) ? ylen1 : j - 1;
                   for ( ; n < xlen; n++,
                      i1 = (i1 == 0) ? xlen1 : i1 - 1,
                      j1 = (j1 == 0) ? ylen1 : j1 - 1 )
                   {
                      if ( ptx[i1] != pty[j1] )
                          break;  /* loop over n */
                   }

                   /* replace a matching substring of equal length         */
                   if ( n == xlen - n ) {
                      j2 = j;
                      for ( m = 0; m < n; m++,
                         i1 = (i1 == 0) ? xlen1 : i1 - 1,
                         j2 = (j2 == ylen1) ? 0 : j2 + 1 )
                      {
                         pty[j2] = ptInvs[INT_INTOBJ(ptx[i1])];
                      }

                      /* Now replace all exact occurrences of this string  */
                      /*  in the current word (not relator)                */
                      i3 = (i + n) % xlen;

                      for ( jj = 0; jj <= ylen - n; jj++ ) {
                         i2 = i;  j2 = jj;
                         for ( m = 0; m < n; m++,
                            i2 = (i2 == xlen1) ? 0 : i2 + 1,
                            j2 = (j2 == ylen1) ? 0 : j2 + 1 ) {
                            if ( ptx[i2] != pty[j2] )
                                break;  /* loop over m */
                         }
                         if ( m < n )
                             continue;  /* loop over jj */

                         i1 = (i == 0) ? xlen1 : i - 1;
                         if ( ptx[i1] == pty[(jj + ylen1) % ylen] ||
                            ptx[i3] == pty[(jj + n) % ylen] )
                         {
                            continue;  /* loop over jj */
                         }

                         j2 = jj;
                         for ( m = 0; m < n; m++,
                            i1 = (i1 == 0) ? xlen1 : i1 - 1,
                            j2 = (j2 == ylen1) ? 0 : j2 + 1 ) {
                            pty[j2] = ptInvs[INT_INTOBJ(ptx[i1])];
                         }

                         jj = -1;
                      }

                      ptFlags[y] = INTOBJ_INT( newflag );
                      altered = 1;
                      ++count;
                      break;  /* loop over i */
                   }

                   m = ylen - n;  n = xlen - n;

                   /* find all canceling factors                           */
                   if ( n == 0 ) {
                      for ( ; 1 < m; m -= 2,
                         j1 = (j1 == 0) ? ylen1 : j1 - 1,
                         j2 = (j2 == ylen1) ? 0 : j2 + 1 )
                      {
                         if ( pty[j1] != ptInvs[INT_INTOBJ(pty[j2])] )
                            break;  /*  loop over m                        */
                      }
                   }

                   /* create the modified relator and save it              */
                   newlen = m + n;
                   if ( j2 > 0 ) {
                      if ( j2 <= j1 )  {
                          jj = 0;  j3 = j1;  j1 = m - 1;
                      }
                      else  {
                          jj = j1 + n + 1;  j3 = ylen - 1;
                      }
                      for ( ; j2 <= j3; ) {
                         pty[jj++] = pty[j2++];
                      }
                   }
                   for ( ; n > 0; n--, i1 = (i1 == 0) ? xlen1 : i1 - 1 ) {
                      pty[++j1] = ptInvs[INT_INTOBJ(ptx[i1])];
                   }
                   SET_LEN_PLIST( lo, newlen );
                   ptLens[y] = INTOBJ_INT(newlen);
                   total = total - ylen + newlen;
                   ptFlags[y] = INTOBJ_INT(newflag);

                   /* reduce the bag size                                  */
                   SHRINK_PLIST( lo, newlen );
                   CHANGED_BAG(rels);
                   ptRels  = ADDR_OBJ( rels );
                   ptLens  = ADDR_OBJ( lens );
                   ptFlags = ADDR_OBJ( flags);
                   ptInvs  = ADDR_OBJ( invs ) + (numgens + 1);

                   altered = 1;
                   ++count;
                   --y;
                   break;  /* loop over i */
                }

                if ( altered )
                    break;  /* loop over x */

                /* now try the inverse of the given relator                */
                for ( i = 0;  i < xlen;  i++ ) {

                   /* search forward for a match of length at least mlen   */
                   i2 = xlen1 - i;  j2 = j;
                   for ( n = 0; n < xlen; n++,
                      i2 = (i2 == 0) ? xlen1 : i2 - 1,
                      j2 = (j2 == ylen1) ? 0 : j2 + 1 )
                   {
                      if ( ptInvs[INT_INTOBJ(ptx[i2])] != pty[j2] )
                         break;  /* loop over n */
                   }
                   if ( n < mlen )
                       continue;  /* loop over i */

                   /* search backward to find the whole match              */
                   i1 = (i == 0) ? 0 : xlen - i;
                   j1 = (j == 0) ? ylen1 : j - 1;
                   for ( ; n < xlen; n++,
                      i1 = (i1 == xlen1) ? 0 : i1 + 1,
                      j1 = (j1 == 0) ? ylen1 : j1 - 1 )
                   {
                      if ( ptInvs[INT_INTOBJ(ptx[i1])] != pty[j1] )
                         break;  /* loop over n */
                   }

                   /* replace a matching substring of equal length         */
                   if ( n == xlen - n ) {
                      j2 = j;
                      for ( m = 0; m < n; m++,
                         i1 = (i1 == xlen1) ? 0 : i1 + 1,
                         j2 = (j2 == ylen1) ? 0 : j2 + 1 )
                      {
                         pty[j2] = ptx[i1];
                      }

                      ptFlags[y] = INTOBJ_INT( newflag );
                      altered = 1;
                      ++count;
                      break;  /* loop over i */
                   }

                   m = ylen - n;  n = xlen - n;

                   /* Find all canceling factors                           */
                   if ( n == 0 ) {
                      for ( ; 1 < m; m -= 2,
                         j1 = (j1 == 0) ? ylen1 : j1 - 1,
                         j2 = (j2 == ylen1) ? 0 : j2 + 1 )
                      {
                         if ( pty[j1] != ptInvs[INT_INTOBJ(pty[j2])] )
                            break;  /* loop over m */
                      }
                   }

                   /* create the modified relator and save it              */
                   newlen = m + n;
                   if ( j2 > 0 )  {
                      if ( j2 <= j1 )  {
                          jj = 0;  j3 = j1;  j1 = m - 1;
                      }
                      else  {
                          jj = j1 + n + 1;  j3 = ylen - 1;
                      }
                      for ( ;  j2 <= j3;  ) {
                         pty[jj++] = pty[j2++];
                      }
                   }
                   for ( ;  n > 0;  n--, i1 = (i1 == xlen1) ? 0 : i1 + 1 ) {
                      pty[++j1] = ptx[i1];
                   }
                   SET_LEN_PLIST( lo, newlen );
                   ptLens[y] = INTOBJ_INT(newlen);
                   total = total - ylen + newlen;
                   ptFlags[y] = INTOBJ_INT(newflag);

                   /* reduce the bag size                                  */
                   SHRINK_PLIST( lo, newlen );
                   CHANGED_BAG(rels);
                   ptRels  = ADDR_OBJ( rels );
                   ptLens  = ADDR_OBJ( lens );
                   ptFlags = ADDR_OBJ( flags);
                   ptInvs  = ADDR_OBJ( invs ) + numgens + 1;

                   altered = 1;
                   ++count;
                   --y;
                   break;  /* loop over i */
                }

                if ( altered )
                    break;  /* loop over x */
             }
          }

          if ( altered )
              break;  /* loop over j */

          v = ptr + ( 1 + j ); 
          w = ptr + ( 1 + ( j + mlen ) % ylen );
          key = 109109 * key - inv * ( (UInt)*v >> 2 )
              + ( (UInt)*w >> 2 );
       }
    }

    ADDR_OBJ( tietze )[TZ_TOTAL] = INTOBJ_INT(total);

    /* return the number of altered relators                               */
    return INTOBJ_INT( count );
}


/* rewriting using tz form relators */

static Obj FuncREDUCE_LETREP_WORDS_REW_SYS(Obj self, Obj tzrules, Obj a_w)
{
 UInt n,lt,i,k,p,j,lrul,eq,rlen,newlen,a;
 Obj w,nw,rul;
 Obj * wa;
 Obj * nwa;
 
 w=a_w;

 /* n := Length( w ); */
 n=LEN_PLIST(w);
 
 /* lt := Length( tzrules ); */
 lt=LEN_PLIST(tzrules);
 
 /* i := 1; */
 i=1;
 
 /* while i in [ 1 .. n ] od */
 while (i<=n) {
   TakeInterrupt();
  
  /* k := 1; */
  k=1;
  
  /* while k in [ 1 .. lt ] od */
  while (k<=lt) {
    
    /* rul := tzrules[k][1]; */
    rul = ELM_PLIST(tzrules,k);
    rul = ELM_PLIST(rul,1);
    lrul = LEN_PLIST(rul);
   
   /* if Length( tzrules[k][1] ) <= i then */
   if (lrul<=i) {
    
    /* eq := true; */
    eq=1;

    /* p := i; */
    p=i;
    
    /* j := Length( rul ); */
    j=lrul;
    
    /* while eq and j > 0 od */
    while ((eq==1) && (j>0) ) {
     
     /* eq := w[p] = rul[j]; */
     eq=((ELM_LIST(w,p)==ELM_LIST(rul,j))?1:0);
     
     /* p := p - 1; */
     p--;
     
     /* j := j - 1; */
     j--;
     
    }
    /* od */
    
    /* if eq then */
    if (eq==1) {
     
     /* make the new plist */

     rlen=LEN_PLIST(ELM_PLIST(ELM_PLIST(tzrules,k),2));
     newlen = n-lrul+rlen;

     if (newlen==0) {
       nw=NewEmptyPlist();
     }
     else {
        /* make space for the new word */
        nw = NEW_PLIST(TNUM_OBJ(w),newlen);

       /* addresses */
       wa=ADDR_OBJ(w);
       nwa=ADDR_OBJ(nw);
       wa++;
       nwa++;

       /* for a in [ 1 .. p ] do */
       /* Add( nw, w[a] ); */
       for (a=1; a<=p;a++) {
         *nwa++=*wa++;
       }
       /* od */

       /* rul := tzrules[k][2]; */
       rul = ELM_PLIST(tzrules,k);
       rul = ELM_PLIST(rul,2);
       wa=ADDR_OBJ(rul);
       wa++;

       /* for a in [ 1 .. Length( rul ) ] do */
       /* Add( nw, rul[a] ); */
       for (a=1;a<=rlen;a++) {
         *nwa++=*wa++;
       }
       /* od */

       /* for a in [ i + 1 .. n ] do */
       /* there must be a better way for giving this address ... */
       wa=(Obj*) &(ADDR_OBJ(w)[i+1]);
       /* Add( nw, w[a] ); */
       for (a=i+1;a<=n;a++) {
         *nwa++=*wa++;
       }
       /* od */

     }

     /* w := nw; */
     SET_LEN_PLIST(nw,newlen);
     w = nw;
     
     /* i := i - Length( tzrules[k][1] ); */
     i=i-lrul;
     
     /* n := Length( w ); */
     n=newlen;
     
     /* k := lt; */
     k = lt;
     
    }
    /* fi */
    
   }
   /* fi */
   
   /* k := k + 1; */
   k++;
   
  }
  /* od */
  
  /* i := i + 1; */
  i++;
  
 }
 /* od */
 
 /* return w; */
 return w;
 
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

    GVAR_FUNC_1ARGS(TzSortC, tietze),
    GVAR_FUNC_1ARGS(TzRenumberGens, tietze),
    GVAR_FUNC_1ARGS(TzReplaceGens, tietze),
    GVAR_FUNC_3ARGS(TzSubstituteGen, tietze, gennum, word),
    GVAR_FUNC(TzOccurrences, -1, "args"),
    GVAR_FUNC(TzOccurrencesPairs, -1, "args"),
    GVAR_FUNC(TzSearchC, -1, "args"),
    GVAR_FUNC_2ARGS(REDUCE_LETREP_WORDS_REW_SYS, tzwords, word),
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
*F  InitInfoTietze()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "tietze",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoTietze ( void )
{
    return &module;
}
