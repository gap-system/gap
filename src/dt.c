/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements the part of the deep thought package which deals
**  with computing the deep thought polynomials.
**
**  Deep Thought deals with trees.  A tree <tree> is a concatenation of 
**  several nodes where each node is a 5-tuple of immediate integers.  If
**  <tree> is an atom it contains only one node,  thus it is itself a
**  5-tuple. If <tree> is not an atom we obtain its list representation by
**
**  <tree>  :=  topnode(<tree>) concat left(<tree>) concat right(<tree>) .
**
**  Let us denote the i-th node of <tree> by (<tree>, i)  and the tree rooted 
**  at (<tree>, i) by tree(<tree>, i).  Let <a> be tree(<tree>, i)
**  The first entry of (<tree>, i) is pos(a),
**  and the second entry is num(a). The third entry of (<tree>, i) gives a 
**  mark.(<tree>, i)[3] = 1  means that (<tree>, i) is marked,  
**  (<tree>, i)[3] = 0 means that (<tree>, i) is not marked. The fourth entry
**  of (<tree>, i) contains the number of knodes of tree(<tree>, i).  The
**  fifth entry of (<tree>, i) finally contains a boundary for 
**  pos( tree(<tree>, i) ).  (<tree>, i)[5] <= 0 means that 
**  pos( tree(<tree>, i) ) is unbounded.  If tree(<tree>, i) is an atom we
**  already know that pos( tree(<tree>, i) ) is unbound.  Thus we then can
**  use the fifth component of (<tree>, i) to store the side.  In this case
**  (<tree>, i)[5] = -1 means  that tree(<tree>, i) is an atom from the
**  right hand word, and (<tree>, i)[5] = -2 means that tree(<tree>, i) is
**  an atom from the left hand word.
**
**  A second important data structure deep thought deals with is a deep
**  thought monomial. A deep thought monomial g_<tree> is a product of
**  binomial coefficients with a coefficient c. Deep thought monomials
**  are represented in this implementation by formula
**  vectors,  which are lists of integers.  The first entry of a formula
**  vector is 0,  to distinguish formula vectors from trees.  The second
**  entry is the coefficient c,  and the third and fourth entries are
**  num( left(tree) ) and num( right(tree) ).  The remaining part of the
**  formula vector is a concatenation of pairs of integers.  A pair (i, j)
**  with i > 0 represents binomial(x_i, j).  A pair (0, j) represents
**  binomial(y_gen, j) when word*gen^power is calculated.
**
**  Finally deep thought has to deal with pseudorepresentatives. A
**  pseudorepresentative <a> is stored in list of length 4. The first entry
**  stores left( <a> ),  the second entry contains right( <a> ),  the third
**  entry contains num( <a> ) and the last entry finally gives a boundary
**  for pos( <b> ) for all trees <b> which are represented by <a>.
*/

#include "dt.h"

#include "calls.h"
#include "error.h"
#include "gvars.h"
#include "integer.h"
#include "modules.h"
#include "plist.h"

static void UnmarkTree(Obj z);
static UInt Mark(Obj tree, Obj reftree, Int indexx);
static Int  AlmostEqual(Obj tree1, Int index1, Obj tree2, Int index2);
static Int  Equal(Obj tree1, Int index1, Obj tree2, Int index2);
static Obj  Mark2(Obj tree, Int index1, Obj reftree, Int index2);
static UInt FindTree(Obj tree, Int indexx);
static Obj  MakeFormulaVector(Obj tree, Obj pr);
static Int  Leftof(Obj tree1, Int index1, Obj tree2, Int index2);
static Int  Leftof2(Obj tree1, Int index1, Obj tree2, Int index2);
static Int  Earlier(Obj tree1, Int index1, Obj tree2, Int index2);
static void FindNewReps(Obj tree, Obj reps, Obj pr, Obj max);
static void FindSubs(Obj tree,
                     Int x,
                     Obj list1,
                     Obj list2,
                     Obj a,
                     Obj b,
                     Int al,
                     Int ar,
                     Int bl,
                     Int br,
                     Obj reps,
                     Obj pr,
                     Obj max);
static void SetSubs(Obj list, Obj a, Obj tree);
static void UnmarkAEClass(Obj tree, Obj list);

#ifdef TEST_TREE
static void TestTree(Obj tree);
static Obj  Part(Obj list, Int pos1, Int pos2);
#endif


/****************************************************************************
**
*F  DT_POS(tree, index) . . . . . . . . . . . . . position of (<tree>, index)
**
**  'DT_POS' returns pos(<a>) where <a> is the subtree of <tree> rooted at
**  (<tree>, index).  <index> has to be a positive integer less or equal than
**  the number of nodes of <tree>.
*/
#define  DT_POS(tree, index) \
              (ELM_PLIST(tree, (index-1)*5 + 1 ) ) 


/***************************************************************************
**
*F  SET_DT_POS(tree, index, obj) . . . assign the position of(<tree>, index)
**
**  'SET_DT_POS sets pos(<a>) to the object <obj>, where <a> is the subtree
**  of <tree>,  rooted at (<tree>, index).  <index> has to be a positive
**  integer less or equal to the number of nodes of <tree>
*/
#define  SET_DT_POS(tree, index, obj) \
              SET_ELM_PLIST(tree, (index-1)*5 + 1, obj) 


/***************************************************************************
**
*F  DT_GEN(tree, index) . . . . . . . . . . . . . generator of (<tree>, index)
**
**  'DT_GEN' returns num(<a>) where <a> is the subtree of <tree> rooted at
**  (<tree>, index).  <index> has to be a positive integer less or equal than
**  the number of nodes of <tree>.
*/
#define  DT_GEN(tree, index) \
              (ELM_PLIST(tree, (index-1)*5 + 2) )


/**************************************************************************
**
*F  DT_IS_MARKED(tree, index) . . . . . . tests if (<tree>, index) is marked
**
**  'DT_IS_MARKED' returns 1 (as C integer) if (<tree>, index) is marked, and
**  0 otherwise.  <index> has to be a positive integer less or equal to the
**  number of nodes of <tree>.
*/
#define  DT_IS_MARKED(tree, index)  \
             (INT_INTOBJ (ELM_PLIST(tree, (index-1)*5 + 3) ) )


/**************************************************************************
**
*F  DT_MARK(tree, index) . . . . . . . . . . . . . . . . . . . . mark a node
**
**  'DT_MARK' marks the node (<tree>, index). <index> has to be a positive
**  integer less or equal to the number of nodes of <tree>.
*/
#define  DT_MARK(tree, index) \
              SET_ELM_PLIST(tree, (index-1)*5 + 3, INTOBJ_INT(1) ) 


/**************************************************************************
**
*F  DT_UNMARK(tree, index) . . . . . . . . . . . remove the mark from a node
**
**  'DT_UNMARK' removes the mark from the node (<tree>, index). <index> has 
**  has to be a positive integer less or equal to the number of nodes of
**  <tree>.
*/
#define  DT_UNMARK(tree, index) \
              SET_ELM_PLIST(tree, (index-1)*5 + 3, INTOBJ_INT(0) ) 


/****************************************************************************
**
*F  DT_RIGHT(tree, index) . . . .determine the right subnode of (<tree>, index)
*F  DT_LEFT(tree, index) . . . . determine the left subnode of (<tree>, index)
**
**  'DT_RIGHT' returns the right subnode of (<tree>, index).  That means if
**  DT_RIGHT(tree, index) = index2,  then (<tree>, index2) is the right
**  subnode of (<tree>, index).
**
**  'DT_LEFT' returns the left subnode of (<tree>, index).  That means if
**  DT_LEFT(tree, index) = index2,  then (<tree>, index2) is the left
**  subnode of (<tree>, index).
**
**  Before calling 'DT_RIGHT' or 'DT_LEFT' it should be ensured,  that 
**  (<tree>, index) is not an atom.  <index> has to be a positive integer
**  less or equal to the number of nodes of <tree>.
*/
#define  DT_RIGHT(tree, index) \
              ( INT_INTOBJ(ELM_PLIST(tree, index*5 + 4) ) + index + 1)
#define  DT_LEFT(tree, index) \
              ( index + 1 )


/****************************************************************************
**
*F  DT_SIDE(tree, index) . . . . . . . determine the side of (<tree>, index)
*V  RIGHT. . . . . . . . . . . . . . . integer describing "right"
*V  LEFT . . . . . . . . . . . . . . . integer describing "left"
**
**  'DT_SIDE' returns 'LEFT' if (<tree>, index) is an atom from the Left-hand
**  word,  and 'RIGHT'  if (<tree>, index) is an atom of the Right-hand word.
**  Otherwise 'DT_SIDE' returns an integer bigger than 1.  <index> has to be
**  a positive integer less or equal to the number of nodes of <tree>.
*/
#define  RIGHT                  -1
#define  LEFT                   -2
#define  DT_SIDE(tree, index) \
              (INT_INTOBJ( ELM_PLIST(tree, (index-1)*5 + 5 ) )  )


/****************************************************************************
**
*F  DT_LENGTH(tree, index) . . . . . . . . number of nodes of (<tree>, index)
**
**  'DT_LENGTH' returns the number of nodes of (<tree>, index).  <index> has
**  to be a positive integer less or equal to the number of nodes of <tree>.
*/
#define  DT_LENGTH(tree, index) \
              ( INT_INTOBJ(ELM_PLIST(tree, (index-1)*5 + 4) )  )


/***************************************************************************
**
*F  DT_MAX(tree, index) . . . . . . . . . . . . . . . . boundary of a node
**
**  'DT_MAX(tree, index)' returns a boundary for 'DT_POS(tree, index)'.
**  'DT_MAX(tree, index) = 0 ' means that 'DT_POS(tree, index)' is unbound.
**  <index> has to be a positive integer less or equal to the number of nodes
**  of tree.
*/
#define  DT_MAX(tree, index) \
              (ELM_PLIST(tree, (index-1)*5 + 5 ) )


/****************************************************************************
**
*F  CELM(list, pos) . . . . . . . . . . element of a plain list as C integer
**
**  'CELM' returns the <pos>-th element of the plain list <list>.  <pos> has
**  to be a positive integer less or equal to the physical length of <list>.
**  Before calling 'CELM' it should be ensured that the <pos>-th entry of
**  <list> is an immediate integer object.
*/
#define  CELM(list, pos)         ( INT_INTOBJ(ELM_PLIST(list, pos) ) )


/****************************************************************************
**
*V  Dt_add
**
**  Dt_add is used to store the library function dt_add.
*/

static Obj Dt_add;

/****************************************************************************
**
*F  UnmarkTree( <tree> ) . . . . . . . remove the marks of all nodes of <tree>
**
**  'UnmarkTree' removes all marks of all nodes of the tree <tree>.
*/
static void UnmarkTree(Obj tree)
{
    UInt     i, len; /*  loop variable                     */

    len = DT_LENGTH(tree, 1);
    for (i=1; i <= len; i++ )
        DT_UNMARK(tree, i);
}


/****************************************************************************
**
*F  FuncUnmarkTree(<self>, <tree>) . . remove the marks of all nodes of <tree>
**
**  'FuncUnmarkTree' implements the internal function 'UnmarkTree'.
**
**  'UnmarkTree( <tree> )'
**
**  'UnmarkTree' removes all marks of all nodes of the tree <tree>.
*/
static Obj FuncUnmarkTree(Obj self, Obj tree)
{
    UnmarkTree(tree);
    return  0;
}


/*****************************************************************************
**
*F  Mark(<tree>, <reftree>, <index>) . . . . . . . . find all nodes of <tree> 
**                                                   which are almost equal
**                                                   to (<reftree>, index)
**
**  'Mark' determines all nodes of the tree <tree>, rooting subtrees almost
**  equal to the tree rooted at (<reftree>, index).  'Mark' marks these nodes
**  and returns the number of different nodes among these nodes.  Since it
**  is assumed that the set {pos(a) | a almost equal to (<reftree>, index) }
**  is equal to {1,...,n} for a positive integer n,  'Mark' actually returns
**  the Maximum of {pos(a) | a almost equal to (<reftree>, index)}.
*/
static UInt Mark(Obj tree, Obj reftree, Int indexx)
{
    UInt  i, /*  loop variable                    */
          m, /*  integer to return                */
          len;
    Obj   refgen;

    m = 0;
    i = 1;
    len = DT_LENGTH(tree, 1);
    refgen = DT_GEN(reftree, indexx);
    while ( i <= len )
    {
        /*  skip all nodes (<tree>, i) with 
        **  num(<tree>, i) > num(<reftree>, indexx)     */
        while( i < len && 
               DT_GEN(tree, i)  >  refgen )
            i++;
        if ( AlmostEqual(tree, i, reftree, indexx) )
        {
            DT_MARK(tree, i);
            if ( m < INT_INTOBJ( DT_POS(tree, i) )  )
                m = INT_INTOBJ( DT_POS(tree, i) );
        }
        /*  Since num(a) < num(b) holds for all subtrees <a> of an arbitrary
        **  tree <b> we can now skip the whole tree rooted at (<tree>, i).
        **  If (<tree>, i) is the left subnode of another node we can even
        **  skip the tree rooted at that node,  because of 
        **  num( right(a) )  <  num( left(a) ) for all trees <a>.
        **  Note that (<tree>, i) is the left subnode of another node,  if and
        **  only if the previous node (<tree>, i-1) is not an atom. in this
        **  case (<tree>, i) is the left subnode of (<tree>, i-1).          */
        if ( DT_LENGTH(tree, i-1) == 1 )
            /*   skip the tree rooted at (<tree>, i).                    */
            i = i + DT_LENGTH(tree, i);
        else
            /*   skip the tree rooted at (<tree>, i-1)                   */
            i = i - 1 + DT_LENGTH(tree, i-1);
    }
    return m;
}


/****************************************************************************
**
*F  AmostEqual(<tree1>,<index1>,<tree2>,<index2>) . . test of almost equality
**
**  'AlmostEqual' tests if tree(<tree1>, index1) is almost equal to
**  tree(<tree2>, index2).  'AlmostEqual' returns 1
**  if these trees are almost equal,  and 0 otherwise.  <index1> has to be
**  a positive integer less or equal to the number of nodes of <tree1>,
**  and <index2> has to be a positive integer less or equal to the number of
**  nodes of <tree2>.
*/
static Int AlmostEqual(Obj tree1, Int index1, Obj tree2, Int index2)
{
    UInt   k, schranke; /*   loop variable                                             */
    /*  First the two top nodes of tree(<tree1>, index1) and
    **  tree(<tree2>, index2) (that are (<tree1>, index1) and 
    **  (<tree2, index2) ) are compared by testing the equality of the 2-nd,
    **  5-th and 6-th entries the nodes.                                    */
    if ( DT_GEN(tree1, index1) != DT_GEN(tree2, index2) )
        return  0;
    if ( DT_SIDE(tree1, index1) != DT_SIDE(tree2, index2)  )
        return  0;
    if ( DT_LENGTH(tree1, index1) != DT_LENGTH(tree2, index2)  )
        return  0;
    /*  For the comparison of the remaining nodes of tree(<tree1>, index1)
    **  and tree(<tree2>, index2) it is also necessary to compare the first
    **  entries of the nodes.  Note that we know at this point,  that 
    **  tree(<tree1>, index1) and tree(<tree2>, index2) have the same number
    **  of nodes                                                             */
    schranke = index1 + DT_LENGTH(tree1, index1);
    for (k = index1 + 1;  k < schranke;  k++ )
    {
        if ( DT_GEN(tree1, k) != DT_GEN(tree2, k + index2 - index1 ) )
            return  0;
        if ( DT_POS(tree1, k) != DT_POS(tree2, k + index2 - index1 ) )
            return  0;
        if ( DT_SIDE(tree1, k)    !=
             DT_SIDE(tree2, k + index2 - index1)  )
            return  0;
        if ( DT_LENGTH(tree1, k) != DT_LENGTH(tree2, k + index2 - index1) )
            return  0;
    }
    return  1;
}


/*****************************************************************************
**
*F  Equal(<tree1>,<index1>,<tree2>,<index2>) . . . . . . . . test of equality
**
**  'Equal' tests if tree(<tree1>, index1) is equal to
**  tree(<tree2>, index2).  'Equal' returns 1
**  if these trees are  equal,  and 0 otherwise.  <index1> has to be
**  a positive integer less or equal to the number of nodes of <tree1>,
**  and <index2> has to be a positive integer less or equal to the number of
**  nodes of <tree2>.
*/
static Int Equal(Obj tree1, Int index1, Obj tree2, Int index2)
{
    UInt   k, schranke; /*  loop variable                                   */

    /*  Each node of tree(<tree1>, index1) is compared to the corresponding
    **  node of tree(<tree2>, index2) by testing the equality of the 1-st,
    **  2-nd,  5-th and 6-th nodes.                                          */
    schranke = index1 + DT_LENGTH(tree1, index1);
    for (k=index1; k < schranke;  k++)
    {
        if ( DT_GEN(tree1, k) != DT_GEN(tree2, k + index2 - index1 ) )
            return  0;
        if ( DT_POS(tree1, k) != DT_POS(tree2, k + index2 - index1 ) )
            return  0;
        if ( DT_SIDE(tree1, k)   !=
             DT_SIDE(tree2, k + index2 - index1)   )
            return  0;
        if ( DT_LENGTH(tree1, k) != DT_LENGTH(tree2, k + index2 - index1) )
            return  0;
    }
    return  1;
}


/****************************************************************************
**
*F  Mark2(<tree>,<index1>,<reftree>,<index2>) . . find all subtrees of
**                                                tree(<tree>, index1) which
**                                                are almost equal to
**                                                tree(<reftree>, index2)
**
**  'Mark2' determines all subtrees of tree(<tree>, index1) that are almost
**  equal to tree(<reftree>, index2).  'Mark2' marks the top nodes of these
**  trees and returns a list of lists <list> such that <list>[i]
**  for each subtree <a> of <tree> which is  almost equal to
**  tree(<reftree>, index2) and for which pos(<a>) = i holds contains an
**  integer describing the position of the top node of <a> in <tree>.
**  For example <list>[i] = [j, k] means that tree(<tree>, j) and
**  tree(<tree>, k) are almost equal to tree(<reftree>, index2) and
**  that pos(tree(<tree>, j) = pos(tree(<tree>, k) = i holds.
**
**  <index1> has to be a positive integer less or equal to the number of nodes
**  of <tree>,  and <index2> has to be a positive integer less or equal to
**  the number of nodes of <reftree>.
*/
static Obj Mark2(Obj tree, Int index1, Obj reftree, Int index2)
{
    UInt    i, /*  loop variable                                          */
            len;
    Obj     new, 
            list, /*  list to return                                      */
            refgen;

    /*  initialize <list>                                                 */
    list = NEW_PLIST(T_PLIST, 0);
    i = index1;
    len = index1 + DT_LENGTH(tree, index1) - 1;
    refgen = DT_GEN(reftree, index2);
    while( i <= len )
    {
        /*  skip all nodes (<tree>, i) with 
        **  num(<tree>, i) > num(<reftree>, index)     */
        while( i < len     &&
               DT_GEN(tree, i) > refgen   )
            i++;
        if ( AlmostEqual(tree, i, reftree, index2) )
        {
            DT_MARK(tree, i);
            /*  if <list> is too small grow it appropriately               */
            if ( LEN_PLIST(list) < INT_INTOBJ( DT_POS(tree, i) )  )
            {
                GROW_PLIST(list, INT_INTOBJ( DT_POS(tree, i) ) );
                SET_LEN_PLIST(list, INT_INTOBJ( DT_POS(tree, i) )  );
            }
            /*  if <list> has no entry at position pos(tree(<tree>, i))
            **  create a new list <new>,  assign it to list at position
            **  pos(tree(<tree>, i)),  and add i to <new>                  */
            if ( ELM_PLIST(list, INT_INTOBJ( DT_POS(tree, i) )  )  ==  0)
            {
                new = NewPlistFromArgs(INTOBJ_INT(i));
                SET_ELM_PLIST(list, INT_INTOBJ( DT_POS(tree, i) ),  new);
                /*  tell gasman that list has changed                      */
                CHANGED_BAG(list);
            }
            /*  add i to <list>[ pos(tree(<tree>, i)) ]                    */ 
            else
            {
                new = ELM_PLIST(list, INT_INTOBJ( DT_POS(tree, i) )  );
                PushPlist(new, INTOBJ_INT(i) );
            }
        }
        /*  Since num(a) < num(b) holds for all subtrees <a> of an arbitrary
        **  tree <b> we can now skip the whole tree rooted at (<tree>, i).
        **  If (<tree>, i) is the left subnode of another node we can even
        **  skip the tree rooted at that node,  because of 
        **  num( right(a) )  <  num( left(a) ) for all trees <a>.
        **  Note that (<tree>, i) is the left subnode of another node,  if and
        **  only if the previous node (<tree>, i-1) is not an atom. In this
        **  case (<tree>, i) is the left subnode of (<tree>, i-1).          */
        if ( DT_LENGTH(tree, i-1) == 1 )
            /*  skip tree(<tree>, i)                                        */
            i = i + DT_LENGTH(tree, i);
        else
            /*  skip tree(<tree>, i-1)                                      */
            i = i - 1 + DT_LENGTH(tree, i-1);
    }
    return  list;
}


/*****************************************************************************
**
*F  FindTree(<tree>, <index>)
**
**  'FindTree' looks for a subtree <a> of tree(<tree>, index) such that 
**  the top node of
**  <a> is not marked but all the other nodes of <a> are marked.  It is
**  assumed that if the top node of a subtree <b> of tree(<tree>, index) 
**  is marked,  all
**  nodes of <b> are marked.  Hence it suffices to look for a subtree <a>
**  of <tree> such that the top node of <a> is unmarked and the left and the
**  right node of <a> are marked.  'FindTree' returns an integer <i> such 
**  that tree(<tree> ,i) has the properties mentioned above.  If such a tree
**  does not exist 'Findtree' returns 0 (as C integer).  Note that this holds
**  if and only if tree(<tree>, index) is marked.
*/
static UInt FindTree(Obj tree, Int indexx)
{
    UInt   i; /*     loop variable                                    */

    /*  return 0 if (<tree>, indexx) is marked                           */
    if ( DT_IS_MARKED(tree, indexx) )
        return  0;
    i = indexx;
    /*  loop over all nodes of tree(<tree>, indexx) to find a tree with the
    **  properties described above.                                       */
    while( i < indexx + DT_LENGTH(tree, indexx)  )
    {
        /*  skip all nodes that are unmarked and rooting non-atoms        */
        while( !( DT_IS_MARKED(tree, i) )  &&  DT_LENGTH(tree, i) > 1  )
            i++;
        /*  if (<tree>, i) is unmarked we now know that tree(<tree>, i) is
        **  an atom and we can return i.  Note that an unmarked atom has the
        **  desired properties.                                             */
        if ( !( DT_IS_MARKED(tree, i) )  )
            return  i;
        /*  go to the previous node                                          */
        i--;
        /*  If the right node of tree(<tree>, i) is marked return i.
        **  Else go to the right node of tree(<tree>, i).                    */
        if  ( DT_IS_MARKED(tree, DT_RIGHT(tree, i) )  )
            return   i;
        i = DT_RIGHT(tree, i);
    }
    return 0;
}


/****************************************************************************
**
*F  MakeFormulaVector(<tree>, <pr>) . . . . . . . . . compute the polynomial 
**                                                    g_<tree> for <tree>
**
**  'MakeFormulaVector' returns the polynomial g_<tree> for a tree <tree>
**  and a pc-presentation <pr> of a nilpotent group.  This polynomial g_<tree>
**  is a product of binomial coefficients with a coefficient c ( see the
**  header of this file ).
**
**  For the calculation of the coefficient c the top node of <tree> is ignored
**  because it can happen that trees are equal except for the top node.
**  Hence it suffices to compute the formula vector for one of these trees.
**  Then we get the "correct" coefficient for the polynomial for each <tree'>
**  of those trees by multiplying the coefficient given by the formula vector
**  with c_( num(left(<tree'>)),  num(right(<tree'>));  num(<tree'>) ).  This
**  is also the reason for storing num(left(<tree>)) and num(right(<tree>))
**  in the formula vector.
**
**  'MakeFormulaVector' only returns correct results if all nodes of <tree>
**  are unmarked.
*/
static Obj MakeFormulaVector(Obj tree, Obj pr)
{
    UInt  i, /*    denominator of a binomial coefficient              */
          j, /*    loop variable                                      */
          u; /*    node index                                         */
    Obj   rel, /*  stores relations of <pr>                           */
          vec, /*  stores formula vector to return                    */
          prod,/*  stores the product of two integers                 */
          gen;

    /*  initialize <vec> and set the first four elements              */
    vec = NewPlistFromArgs(INTOBJ_INT(0), INTOBJ_INT(1),
                           DT_GEN(tree, DT_LEFT(tree, 1)),
                           DT_GEN(tree, DT_RIGHT(tree, 1)));
    /*  loop over all almost equal classes of subtrees of <tree> except for
    **  <tree> itself.                                                    */
    u = FindTree(tree, 1);
    while( u > 1 )
    {
        /*  mark all subtrees of <tree> almost equal to tree(<tree>, u) and
        **  get the number of different trees in this almost equal class    */
        i = Mark(tree, tree, u);
        /*  if tree(<tree>, u) is an atom from the Right-hand word append
        **  [ 0, i ] to <vec>                                               */
        if  ( DT_SIDE(tree, u) == RIGHT )
        {
            GROW_PLIST(vec, LEN_PLIST(vec)+2);
            SET_LEN_PLIST(vec, LEN_PLIST(vec)+2);
            SET_ELM_PLIST(vec, LEN_PLIST(vec)-1, INTOBJ_INT(0) );
            SET_ELM_PLIST(vec, LEN_PLIST(vec), INTOBJ_INT(i) );
        }
        /*  if tree(<tree>, u) is an atom from the Left-hand word append
        **  [ num(tree(<tree>, u)), i ] to <vec>                            */
        else if  ( DT_SIDE(tree, u) == LEFT)
        {
            GROW_PLIST(vec, LEN_PLIST(vec)+2);
            SET_LEN_PLIST(vec, LEN_PLIST(vec)+2);
            SET_ELM_PLIST(vec, LEN_PLIST(vec)-1, DT_GEN(tree, u) );
            SET_ELM_PLIST(vec, LEN_PLIST(vec), INTOBJ_INT(i) );
        }
        /*  if tree(<tree>, u) is not an atom multiply 
        **  <vec>[2] with binomial(d, i) where
        **  d = c_(num(left(<tree>,u)), num(right(<tree>,u)); num(<tree>,u)) */
        else
        {
            j = 3;
            rel = ELM_PLIST( ELM_PLIST(pr, INT_INTOBJ( DT_GEN(tree, 
                                                        DT_LEFT(tree, u) ) ) ),
                             INT_INTOBJ( DT_GEN(tree, DT_RIGHT(tree, u) ) )  );
            gen = DT_GEN(tree, u);
            while ( 1  )
            {
                if ( ELM_PLIST(rel, j) == gen  )
                {
                    prod = ProdInt(ELM_PLIST(vec, 2),
                                   BinomialInt(ELM_PLIST(rel, j+1), 
                                            INTOBJ_INT(i)        )        );
                    SET_ELM_PLIST(vec,  2, prod);
                    /*  tell gasman that vec has changed                     */
                    CHANGED_BAG(vec);
                    break;
                }
                j+=2;
            }
        }
        u = FindTree(tree, 1);
    }
    return vec;
}


/**************************************************************************
**
*F  FuncMakeFormulaVector(<self>,<tree>,<pr>) . . . . . compute the formula 
**                                                      vector for <tree>
**
**  'FuncMakeFormulaVector' implements the internal function
**  'MakeFormulaVector(<tree>, <pr>)'.
**
**  'MakeFormulaVector(<tree>, <pr>)'
**
**  'MakeFormulaVector' returns the formula vector for the tree <tree> and
**  the pc-presentation <pr>.
*/
static Obj FuncMakeFormulaVector(Obj self, Obj tree, Obj pr)
{
    if  (LEN_PLIST(tree) == 5)
        ErrorMayQuit("<tree> has to be a non-atom", 0, 0);
    return  MakeFormulaVector(tree, pr);
}


/****************************************************************************
**
*F  Leftof(<tree1>,<index1>,<tree2>,<index2>) . . . . test if one tree is left
**                                                    of another tree
**
**  'Leftof' returns 1 if tree(<tree1>, index1) is left of tree(<tree2>,index2)
**  in the word being collected at the first instance,  that 
**  tree(<tree1>, index1) and tree(<tree2>, index2) both occur. It is assumed
**  that tree(<tree1>, index1) is not equal to tree(<tree2>, index2). 
*/
static Int Leftof(Obj tree1, Int index1, Obj tree2, Int index2)
{
    if  ( DT_LENGTH(tree1, index1) ==  1  &&  DT_LENGTH(tree2, index2) == 1 ) {
        if (DT_SIDE(tree1, index1) == LEFT && DT_SIDE(tree2, index2) == RIGHT)
            return  1;
        else if  (DT_SIDE(tree1, index1) == RIGHT  &&
                  DT_SIDE(tree2, index2) == LEFT         )
            return  0;
        else if (DT_GEN(tree1, index1) == DT_GEN(tree2, index2)  )
            return ( DT_POS(tree1, index1) < DT_POS(tree2, index2) );
        else
            return ( DT_GEN(tree1, index1) < DT_GEN(tree2, index2) );
    }
    if  ( DT_LENGTH(tree1, index1) > 1                         &&  
          DT_LENGTH(tree2, index2) > 1                         &&
          Equal( tree1, DT_RIGHT(tree1, index1) , 
                 tree2, DT_RIGHT(tree2, index2)    )                    )
    {
        if  ( Equal( tree1, DT_LEFT(tree1, index1),
                     tree2, DT_LEFT(tree2, index2)  )     ) {
            if  ( DT_GEN(tree1, index1) == DT_GEN(tree2, index2)  )
                return   ( DT_POS(tree1, index1) < DT_POS(tree2, index2) );
            else
                return   ( DT_GEN(tree1, index1) < DT_GEN(tree2, index2) );
        }
    }
    if( Earlier(tree1, index1, tree2, index2)  )
        return  !Leftof2( tree2, index2, tree1, index1);
    else
        return  Leftof2( tree1, index1, tree2, index2);
}
     
  
/*****************************************************************************
**
*F  Leftof2(<tree1>,<index1>,<tree2>,<index2>) . . . . . test if one tree is
**                                                       left of another tree
**
**  'Leftof2' returns 1 if tree(<tree1>, index1) is left of 
**  tree(<tree2>,index2)in the word being collected at the first instance,  
**  that tree(<tree1>, index1) and tree(<tree2>, index2) both occur.  It is
**  assumed that tree(<tree2>, index2) occurs earlier than 
**  tree(<tree1>,index1).  Furthermore it is assumed that if both
**  tree(<tree1>, index1) and tree(<tree2>, index2) are non-atoms,  then their
**  right trees and their left trees are not equal. 
*/
static Int Leftof2(Obj tree1, Int index1, Obj tree2, Int index2)
{
    if  ( DT_GEN(tree2, index2) < DT_GEN(tree1, DT_RIGHT(tree1, index1) )  )
        return  0;
    else if  (Equal(tree1, DT_RIGHT(tree1, index1), tree2, index2 )  )
        return  0;
    else if  (DT_GEN(tree2, index2) == DT_GEN(tree1, DT_RIGHT(tree1, index1)) )
        return  Leftof(tree1, DT_RIGHT(tree1, index1), tree2, index2 );
    else if  (Equal(tree1, DT_LEFT(tree1, index1), tree2, index2) )
        return  0;
    else
        return  Leftof(tree1, DT_LEFT(tree1, index1), tree2, index2);
}


/****************************************************************************
**
*F  Earlier(<tree1>,<index1>,<tree2>,<index2>) . . . test if one tree occurs
**                                                   earlier than another
**
**  'Earlier' returns 1 if tree(<tree1>, index1) occurs strictly earlier than
**  tree(<tree2>, index2).  It is assumed that at least one of these trees
**  is a non-atom. Furthermore it is assumed that if both of these trees are
**  non-atoms,  right(tree(<tree1>, index1) ) does not equal
**  right(tree(<tree2>, index2) ) or left(tree(<tree1>, index1) ) does not
**  equal left(tree(<tree2>, index2) ). 
*/
static Int Earlier(Obj tree1, Int index1, Obj tree2, Int index2)
{
    if  ( DT_LENGTH(tree1, index1) == 1 )
        return  1;
    if  ( DT_LENGTH(tree2, index2) == 1 )
        return  0;
    if ( Equal(tree1, DT_RIGHT(tree1, index1), 
               tree2, DT_RIGHT(tree2, index2)  ) )
        return Leftof(tree1, DT_LEFT(tree2, index2),
                      tree2, DT_LEFT(tree1, index1)  );
    if  ( DT_GEN(tree1, DT_RIGHT(tree1, index1) )  ==
          DT_GEN(tree2, DT_RIGHT(tree2, index2) )            )
        return  Leftof( tree1, DT_RIGHT(tree1, index1) ,
                        tree2, DT_RIGHT(tree2, index2)      );
    return  (DT_GEN(tree1, DT_RIGHT(tree1, index1) )   <
             DT_GEN(tree2, DT_RIGHT(tree2, index2) )      );
}


/****************************************************************************
**
**  GetPols( <list>, <pr>, <pols> )
**
**  GetPols computes all representatives which are represented by the
**  pseudorepresentative <list>,  converts them all into the corresponding
**  deep thought monomial and stores all these monomials in the list <pols>.
*/

/* See below: */
static void GetReps(Obj list, Obj reps);
static void FindNewReps2(Obj tree, Obj reps, Obj pr);

static void GetPols(Obj list, Obj pr, Obj pols)
{
    Obj    lreps,
           rreps,
           tree,
           tree1;
    UInt   i,j,k,l, lenr, lenl, len;

    lreps = NEW_PLIST(T_PLIST, 2);
    rreps = NEW_PLIST(T_PLIST, 2);
    /*  get the representatives that are represented by <list>[1] and those
    **  which are represented by <list>[2].                                 */
    GetReps( ELM_PLIST(list, 1), lreps );
    GetReps( ELM_PLIST(list, 2), rreps );
    lenr = LEN_PLIST(rreps);
    lenl = LEN_PLIST(lreps);
    for  (i=1; i<=lenl; i++)
        for  (j=1; j<=lenr; j++)
            {
                /* now get all representatives, which can be constructed from
                ** <lreps>[<i>] and <rreps>[<j>] and add the corresponding
                ** deep thought monomials to <pols>                         */
                k = LEN_PLIST( ELM_PLIST(lreps, i) )
                  + LEN_PLIST( ELM_PLIST(rreps, j) ) + 5;/* m"ogliche Inkom-*/
                tree = NEW_PLIST(T_PLIST, k);            /* patibilit"at nach*/
                SET_LEN_PLIST(tree, k);        /*"Anderung der Datenstruktur */
                SET_ELM_PLIST(tree, 1, INTOBJ_INT(1) );
                SET_ELM_PLIST(tree, 2, ELM_PLIST( list, 3) );
                SET_ELM_PLIST(tree, 3, INTOBJ_INT(0) );
                SET_ELM_PLIST(tree, 4, INTOBJ_INT((int)(k/5)) );
                SET_ELM_PLIST(tree, 5, INTOBJ_INT(0) );
                tree1 = ELM_PLIST(lreps, i);
                len = LEN_PLIST( tree1 );
                for  (l=1; l<=len; l++)
                    SET_ELM_PLIST(tree, l+5, ELM_PLIST(tree1, l) );
                k = LEN_PLIST(tree1) + 5;
                tree1 = ELM_PLIST(rreps, j);
                len = LEN_PLIST( tree1 );
                for  (l=1; l<=len; l++)
                    SET_ELM_PLIST(tree, l+k, ELM_PLIST(tree1, l) );
                UnmarkTree(tree);
                FindNewReps2(tree, pols, pr);
            }
}



/****************************************************************************
**
*F  FuncGetPols( <self>, <list>, <pr>, <pols> )
**
**  FuncGetPols implements the internal function GetPols.
*/

static Obj FuncGetPols(Obj self, Obj list, Obj pr, Obj pols)
{
    if  (LEN_PLIST(list) != 4)
        ErrorMayQuit("<list> must be a generalised representative not a tree",
                     0, 0);
    GetPols(list, pr, pols);
    return (Obj) 0;
}



/****************************************************************************
**
*F  GetReps( <list>, <reps> )
**
**  GetReps computes all representatives which are represented by the
**  pseudorepresentative <list> and adds them to the list <reps>.
*/

/* See below: */
static void FindNewReps1(Obj tree, Obj reps);

static void GetReps(Obj list, Obj reps)
{
    Obj    lreps,
           rreps,
           tree,
           tree1;
    UInt   i,j,k,l, lenr, lenl, len;;

    if  ( LEN_PLIST(list) != 4 )
    {
        SET_ELM_PLIST(reps, 1, list);
        SET_LEN_PLIST(reps, 1);
        return;
    }
    lreps = NEW_PLIST(T_PLIST, 2);
    rreps = NEW_PLIST(T_PLIST, 2);
    /* now get all representatives which are represented by <list>[1] and
    ** all representatives which are represented by <list>[2].           */
    GetReps( ELM_PLIST(list, 1), lreps );
    GetReps( ELM_PLIST(list, 2), rreps );
    lenl = LEN_PLIST( lreps );
    lenr = LEN_PLIST( rreps );
    for  (i=1; i<=lenl; i++)
        for  (j=1; j<=lenr; j++)
        {
            /* compute all representatives which can be constructed from
            ** <lreps>[<i>] and <rreps>[<j>] and add them to <reps>.   */
            k = LEN_PLIST( ELM_PLIST(lreps, i) )
                + LEN_PLIST( ELM_PLIST(rreps, j) ) + 5;/* m"ogliche Inkom-*/
            tree = NEW_PLIST(T_PLIST, k);            /* patibilit"at nach*/
            SET_LEN_PLIST(tree, k);        /*"Anderung der Datenstruktur */
            SET_ELM_PLIST(tree, 1, INTOBJ_INT(1) );
            SET_ELM_PLIST(tree, 2, ELM_PLIST( list, 3) );
            SET_ELM_PLIST(tree, 3, INTOBJ_INT(0) );
            SET_ELM_PLIST(tree, 4, INTOBJ_INT((int)(k/5)) );
            if ( IS_INTOBJ( ELM_PLIST(list, 4) ) &&
                   CELM(list, 4) < 100 && CELM(list, 4) > 0 )
                SET_ELM_PLIST(tree, 5, ELM_PLIST(list, 4) );
            else
                SET_ELM_PLIST(tree, 5, INTOBJ_INT(0) );
            tree1 = ELM_PLIST(lreps, i);
            len = LEN_PLIST( tree1 );
            for  (l=1; l<=len; l++)
                SET_ELM_PLIST(tree, l+5, ELM_PLIST(tree1, l) );
            k = LEN_PLIST(tree1) + 5;
            tree1 = ELM_PLIST(rreps, j);
            len = LEN_PLIST( tree1 );
            for  (l=1; l<=len; l++)
                SET_ELM_PLIST(tree, l+k, ELM_PLIST(tree1, l) );
            UnmarkTree(tree);
            FindNewReps1(tree, reps);
        }
}


/**************************************************************************
**
*F  FindNewReps(<tree>,<reps>,<pr>,<max>) . . construct new representatives
**
**  'FindNewReps' constructs all trees <tree'> with the following properties.
**  1) left(<tree'>) is equivalent to left(<tree>).
**     right(<tree'>) is equivalent to right(<tree>).
**     num(<tree'>) = num(<tree>)
**  2) <tree'> is the least tree in its equivalence class.
**  3) for each marked node of (<tree>, i) of <tree> tree(<tree>, i) is equal
**     to tree(<tree'>, i).
**  There are three versions of FindNewReps. FindNewReps1 adds all found
**  trees to the list <reps>.  This version is called by GetReps.
**  FindNewReps2 computes for each found tree the corresponding deep thought
**  monomial adds these deep thought monomials to <reps>.  This version
**  is called from GetPols.
**  The third version FindNewReps finally assumes that <reps> is the list of 
**  pseudorepresentatives. This Version adds all found trees to <reps> and
**  additionally all trees, that fulfill 1), 2) and 3) except for
**  num(<tree'>) = num(<tree>).  This version is called from the library
**  function calrepsn.
**  It is assumed that both left(<tree>) and right(<tree>) are the least
**  elements in their equivalence class.
*/

/* See below: */
static void FindSubs1(Obj tree,
                      Int x,
                      Obj list1,
                      Obj list2,
                      Obj a,
                      Obj b,
                      Int al,
                      Int ar,
                      Int bl,
                      Int br,
                      Obj reps);

static void FindNewReps1(Obj tree, Obj reps)
{
    Obj   y,           /*  stores a copy of <tree>                       */
          lsubs,       /*  stores pos(<subtree>) for all subtrees of
                       **  left(<tree>) in a given almost equal class    */

          rsubs,       /*  stores pos(<subtree>) for all subtrees of
                       **  right(<tree>) in the same almost equal class  */

          llist,       /*  stores all elements of an almost equal class
                       **  of subtrees of left(<tree>)                   */

          rlist;       /*  stores all elements of the same almost equal
                       **  class of subtrees of right(<tree>)            */
    Int   a,           /*  stores a subtree of right((<tree>)            */
          n,           /*  Length of lsubs                               */
          m,           /*  Length of rsubs                               */
          i;           /*  loop variable                                 */

    /*  get a subtree of right(<tree>) which is unmarked but whose 
    **  subtrees are all marked                                          */
    a = FindTree(tree, DT_RIGHT(tree, 1) );
    /*  If we do not find such a tree we at the bottom of the recursion.
    **  If leftof(left(<tree>),  right(<tree>) ) holds we add all <tree>
    **  to <reps>.                                                       */
    if  ( a == 0 )
    {
        if ( Leftof(tree, DT_LEFT(tree, 1), tree, DT_RIGHT(tree, 1) )  )
        {
            y = ShallowCopyPlist(tree);
            AssPlist(reps, LEN_PLIST(reps) + 1, y);
        }
        return;
    }
    /*  get all subtrees of left(<tree>) which are almost equal to
    **  tree(<tree>, a) and mark them                                  */
    llist = Mark2(tree, DT_LEFT(tree, 1), tree, a);
    /*  get all subtrees of right(<tree>) which are almost equal to
    **  tree(<tree>, a) and mark them                                  */
    rlist = Mark2(tree, DT_RIGHT(tree, 1), tree, a);
    n = LEN_PLIST(llist);
    m = LEN_PLIST(rlist);
    /*  if no subtrees of left(<tree>) almost equal to
    **  tree(<tree>, a) have been found there is no possibility
    **  to change the pos-argument in the trees stored in llist and
    **  rlist,  so call FindNewReps without changing any pos-arguments.
    */
    if  ( n == 0 )
    {
        FindNewReps1(tree, reps);
        /*  unmark all top nodes of the trees stored in rlist          */
        UnmarkAEClass(tree, rlist);
        return;
    }
    /*  store all pos-arguments that occur in the trees of llist.
    **  Note that the set of the pos-arguments in llist actually
    **  equals {1,...,n}.                                              */
    lsubs = NEW_PLIST( T_PLIST, n );
    SET_LEN_PLIST(lsubs, n);
    for (i=1; i<=n; i++)
        SET_ELM_PLIST(lsubs, i, INTOBJ_INT(i) );
    /*  store all pos-arguments that occur in the trees of rlist.
    **  Note that the set of the pos-arguments in rlist actually
    **  equals {1,...,m}.                                              */
    rsubs = NEW_PLIST( T_PLIST, m );
    SET_LEN_PLIST(rsubs, m);
    for (i=1; i<=m; i++)
        SET_ELM_PLIST(rsubs, i, INTOBJ_INT(i) );
    /*  find all possibilities for lsubs and rsubs such that
    **  lsubs[1] < lsubs[2] <...<lsubs[n],
    **  rsubs[1] < rsubs[2] <...<rsubs[n],
    **  and set(lsubs concat rsubs) equals {1,...,k} for a positiv
    **  integer k.  For each found lsubs and rsubs 'FindSubs' changes
    **  pos-arguments of the subtrees in llist and rlist accordingly
    **  and  then calls 'FindNewReps' with the changed tree <tree>.
    */
    FindSubs1(tree, a, llist, rlist, lsubs, rsubs, 1, n, 1, m, reps);
    /*  Unmark the subtrees of <tree> in llist and rlist and reset
    **  pos-arguments to the original state.                            */
    UnmarkAEClass(tree, rlist);
    UnmarkAEClass(tree, llist);
}

/* See below: */
static void FindSubs2(Obj tree,
                      Int x,
                      Obj list1,
                      Obj list2,
                      Obj a,
                      Obj b,
                      Int al,
                      Int ar,
                      Int bl,
                      Int br,
                      Obj reps,
                      Obj pr);

static void
FindNewReps2(Obj tree, Obj reps, Obj pr /*  pc-presentation for a
                                         **  nilpotent group <G> */
)
{
    Obj   lsubs,       /*  stores pos(<subtree>) for all subtrees of
                       **  left(<tree>) in a given almost equal class    */

          rsubs,       /*  stores pos(<subtree>) for all subtrees of
                       **  right(<tree>) in the same almost equal class  */

          llist,       /*  stores all elements of an almost equal class
                       **  of subtrees of left(<tree>)                   */

          rlist;       /*  stores all elements of the same almost equal
                       **  class of subtrees of right(<tree>)            */
    Int   a,           /*  stores a subtree of right((<tree>)            */
          n,           /*  Length of lsubs                               */
          m,           /*  Length of rsubs                               */
          i;           /*  loop variable                                 */

    /*  get a subtree of right(<tree>) which is unmarked but whose 
    **  subtrees are all marked                                          */
    a = FindTree(tree, DT_RIGHT(tree, 1) );
    /*  If we do not find such a tree we at the bottom of the recursion.
    **  If leftof(left(<tree>),  right(<tree>) ) holds we convert <tree>
    **  into the corresponding deep thought monomial and add that to
    **  <reps>.                                                          */
    if  ( a == 0 )
    {
        if ( Leftof(tree, DT_LEFT(tree, 1), tree, DT_RIGHT(tree, 1) )  )
        {
                /*  get the formula vector of tree and add it to
                **  reps[ rel[1] ].                                */  
            UnmarkTree(tree);
            tree = MakeFormulaVector( tree, pr);
            CALL_3ARGS(Dt_add, tree, reps, pr);
        }
        return;
    }
    /*  get all subtrees of left(<tree>) which are almost equal to
    **  tree(<tree>, a) and mark them                                  */
    llist = Mark2(tree, DT_LEFT(tree, 1), tree, a);
    /*  get all subtrees of right(<tree>) which are almost equal to
    **  tree(<tree>, a) and mark them                                  */
    rlist = Mark2(tree, DT_RIGHT(tree, 1), tree, a);
    n = LEN_PLIST(llist);
    m = LEN_PLIST(rlist);
    /*  if no subtrees of left(<tree>) almost equal to
    **  tree(<tree>, a) have been found there is no possibility
    **  to change the pos-argument in the trees stored in llist and
    **  rlist,  so call FindNewReps without changing any pos-arguments.
    */
    if  ( n == 0 )
    {
        FindNewReps2(tree, reps, pr);
        /*  unmark all top nodes of the trees stored in rlist          */
        UnmarkAEClass(tree, rlist);
        return;
    }
    /*  store all pos-arguments that occur in the trees of llist.
    **  Note that the set of the pos-arguments in llist actually
    **  equals {1,...,n}.                                              */
    lsubs = NEW_PLIST( T_PLIST, n );
    SET_LEN_PLIST(lsubs, n);
    for (i=1; i<=n; i++)
        SET_ELM_PLIST(lsubs, i, INTOBJ_INT(i) );
    /*  store all pos-arguments that occur in the trees of rlist.
    **  Note that the set of the pos-arguments in rlist actually
    **  equals {1,...,m}.                                              */
    rsubs = NEW_PLIST( T_PLIST, m );
    SET_LEN_PLIST(rsubs, m);
    for (i=1; i<=m; i++)
        SET_ELM_PLIST(rsubs, i, INTOBJ_INT(i) );
    /*  find all possibilities for lsubs and rsubs such that
    **  lsubs[1] < lsubs[2] <...<lsubs[n],
    **  rsubs[1] < rsubs[2] <...<rsubs[n],
    **  and set(lsubs concat rsubs) equals {1,...,k} for a positiv
    **  integer k.  For each found lsubs and rsubs 'FindSubs' changes
    **  pos-arguments of the subtrees in llist and rlist accordingly
    **  and  then calls 'FindNewReps' with the changed tree <tree>.
    */
    FindSubs2(tree, a, llist, rlist, lsubs, rsubs, 1, n, 1, m, reps, pr);
    /*  Unmark the subtrees of <tree> in llist and rlist and reset
    **  pos-arguments to the original state.                            */
    UnmarkAEClass(tree, rlist);
    UnmarkAEClass(tree, llist);
}


static void FindNewReps(Obj tree,
                        Obj reps,
                        Obj pr, /*  pc-presentation for a
                                **  nilpotent group <G>                 */

                        Obj max /*  every generator <g_i> of <G> with
                                **  i > max lies in the center of <G>   */
)
{
    Obj   y,           /*  stores a copy of <tree>                       */
          lsubs,       /*  stores pos(<subtree>) for all subtrees of
                       **  left(<tree>) in a given almost equal class    */

          rsubs,       /*  stores pos(<subtree>) for all subtrees of
                       **  right(<tree>) in the same almost equal class  */

          llist,       /*  stores all elements of an almost equal class
                       **  of subtrees of left(<tree>)                   */

          rlist,       /*  stores all elements of the same almost equal
                       **  class of subtrees of right(<tree>)            */
          list1,       /*  stores a sublist of <reps>                    */
          rel;         /*  stores a commutator relation from <pr>        */
    Int   a;           /*  stores a subtree of right((<tree>)            */
    UInt  n,           /*  Length of lsubs                               */
          m,           /*  Length of rsubs                               */
          i, lenrel;   /*  loop variable                                 */

    /*  get a subtree of right(<tree>) which is unmarked but whose 
    **  subtrees are all marked                                          */
    a = FindTree(tree, DT_RIGHT(tree, 1) );
    /*  If we do not find such a tree we at the bottom of the recursion.
    **  If leftof(left(<tree>),  right(<tree>) ) holds we add all trees
    **  <tree'> with left(<tree'>) = left(<tree>), 
    **  right(<tree'>) = right(<tree>) to <reps>,  and <tree'> is the
    **  least element in its equivalence calss.  Note that for such a 
    **  tree we have pos(<tree'>) = 1 and num(<tree'>) = j where j is a
    **  positive integer for which
    **  c_( num(left(<tree>),  num(right(<tree>)), j ) does not equal
    **  0.  These integers are contained in the list
    **  pr[ num(left(<tree>)) ][ num(right(<tree>)) ].             */
    if  ( a == 0 )
    {
        if ( Leftof(tree, DT_LEFT(tree, 1), tree, DT_RIGHT(tree, 1) )  )
        {
            /*  get  pr[ num(left(<tree>)) ][ num(right(<tree>)) ]      */
            rel = ELM_PLIST( ELM_PLIST(pr, INT_INTOBJ( DT_GEN(tree, 
                                                         DT_LEFT(tree, 1)))) ,
                             INT_INTOBJ( DT_GEN(tree, DT_RIGHT(tree, 1) ) )  );
            if  ( ELM_PLIST(rel, 3) > max )
            {
              UnmarkTree(tree);
              tree = MakeFormulaVector(tree, pr);
              list1 = ELM_PLIST(reps, CELM(rel, 3) );
              PushPlist(list1, tree);
            }
            else
            {
                y = ShallowCopyPlist(tree);
                lenrel = LEN_PLIST(rel);
                for  (  i=3;  
                        i < lenrel  &&
                        ELM_PLIST(rel, i) <= max;  
                        i+=2                                        )
                {
                    list1 = ELM_PLIST(reps, CELM(rel, i)  );
                    PushPlist(list1, y);
                }
            }
        }
        return;
    }
    /*  get all subtrees of left(<tree>) which are almost equal to
    **  tree(<tree>, a) and mark them                                  */
    llist = Mark2(tree, DT_LEFT(tree, 1), tree, a);
    /*  get all subtrees of right(<tree>) which are almost equal to
    **  tree(<tree>, a) and mark them                                  */
    rlist = Mark2(tree, DT_RIGHT(tree, 1), tree, a);
    n = LEN_PLIST(llist);
    m = LEN_PLIST(rlist);
    /*  if no subtrees of left(<tree>) almost equal to
    **  tree(<tree>, a) have been found there is no possibility
    **  to change the pos-argument in the trees stored in llist and
    **  rlist,  so call FindNewReps without changing any pos-arguments.
    */
    if  ( n == 0 )
    {
        FindNewReps(tree, reps, pr, max);
        /*  unmark all top nodes of the trees stored in rlist          */
        UnmarkAEClass(tree, rlist);
        return;
    }
    /*  store all pos-arguments that occur in the trees of llist.
    **  Note that the set of the pos-arguments in llist actually
    **  equals {1,...,n}.                                              */
    lsubs = NEW_PLIST( T_PLIST, n );
    SET_LEN_PLIST(lsubs, n);
    for (i=1; i<=n; i++)
        SET_ELM_PLIST(lsubs, i, INTOBJ_INT(i) );
    /*  store all pos-arguments that occur in the trees of rlist.
    **  Note that the set of the pos-arguments in rlist actually
    **  equals {1,...,m}.                                              */
    rsubs = NEW_PLIST( T_PLIST, m );
    SET_LEN_PLIST(rsubs, m);
    for (i=1; i<=m; i++)
        SET_ELM_PLIST(rsubs, i, INTOBJ_INT(i) );
    /*  find all possibilities for lsubs and rsubs such that
    **  lsubs[1] < lsubs[2] <...<lsubs[n],
    **  rsubs[1] < rsubs[2] <...<rsubs[n],
    **  and set(lsubs concat rsubs) equals {1,...,k} for a positiv
    **  integer k.  For each found lsubs and rsubs 'FindSubs' changes
    **  pos-arguments of the subtrees in llist and rlist accordingly
    **  and  then calls 'FindNewReps' with the changed tree <tree>.
    */
    FindSubs(tree, a, llist, rlist, lsubs, rsubs, 1, n, 1, m, reps, pr, max);
    /*  Unmark the subtrees of <tree> in llist and rlist and reset
    **  pos-arguments to the original state.                            */
    UnmarkAEClass(tree, rlist);
    UnmarkAEClass(tree, llist);
}


/***************************************************************************
**
*F  FuncFindNewReps(<self>,<args>) . . . . . . construct new representatives
**
**  'FuncFindNewReps' implements the internal function 'FindNewReps'.
*/

static Obj FuncFindNewReps(Obj self, Obj tree, Obj reps, Obj pr, Obj max)
{

#ifdef TEST_TREE
    /*  test if <tree> is really a tree                                    */
    TestTree(tree);
#endif
    if (LEN_PLIST(tree) < 15)
        ErrorMayQuit("<tree> must be a tree not a plain list", 0, 0);
    FindNewReps(tree, reps, pr, max);   
    return  0;
}


/***************************************************************************
**
*F  TestTree(<obj>) . . . . . . . . . . . . . . . . . . . . . . test a tree
**
**  'TestTree' tests if <tree> is a tree. If <tree> is not a tree 'TestTree'
**  signals an error.
*/
#ifdef TEST_TREE
static void  TestTree(
               Obj     tree)
{
    if ( TNUM_OBJ(tree) != T_PLIST || LEN_PLIST(tree) % 7 != 0)
        ErrorMayQuit(
            "<tree> must be a plain list,  whose length is a multiple of 7",
            0, 0);
    if ( DT_LENGTH(tree, 1) != LEN_PLIST(tree)/7 )
        ErrorMayQuit("<tree> must be a tree, not a plain list", 0, 0);
    if ( DT_SIDE(tree, 1) >= DT_LENGTH(tree, 1) )
        ErrorMayQuit("<tree> must be a tree, not a plain list", 0, 0);
    if ( DT_LENGTH(tree, 1) == 1)
    {
        if ( DT_SIDE(tree, 1) != LEFT && DT_SIDE(tree, 1) != RIGHT )
            ErrorMayQuit("<tree> must be a tree, not a plain list", 0, 0);
        return;
    }
    if ( DT_SIDE(tree, 1) <= 1 )
        ErrorMayQuit("<tree> must be a tree, not a plain list", 0, 0);
    if (DT_LENGTH(tree, 1) !=
          DT_LENGTH(tree, DT_LEFT(tree, 1)) + 
          DT_LENGTH(tree, DT_RIGHT(tree, 1)) +  
          1                                           )
        ErrorMayQuit("<tree> must be a tree, not a plain list", 0, 0);
    if ( DT_SIDE(tree, 1) != DT_LENGTH(tree, DT_LEFT(tree, 1) ) + 1 )
        ErrorMayQuit("<tree> must be a tree, not a plain list", 0, 0);
    TestTree( Part(tree, (DT_LEFT(tree, 1) - 1)*7, 
                         (DT_RIGHT(tree, 1) - 1)*7                    )    );
    TestTree( Part(tree, (DT_RIGHT(tree, 1) - 1)*7,  LEN_PLIST(tree) ) );
}
#endif


/****************************************************************************
**
*F  Part(<list>, <pos1>, <pos2>)  . . . . . . . . . . . return a part of list
**
**  'Part' returns <list>{ [<pos1>+1 .. <pos2>] }.
*/
#ifdef TEST_TREE
static Obj    Part(
             Obj      list,
             Int      pos1,
             Int      pos2  )
{
    Int      i, length;
    Obj      part;

    length = pos2 - pos1;
    part = NEW_PLIST(T_PLIST, length);
    SET_LEN_PLIST(part, length);
    for (i=1; i <= length; i++)
    {
        SET_ELM_PLIST(part, i, ELM_PLIST(list, pos1+i) );
    }
    return part;
}
#endif


/***************************************************************************
**
*F  FindSubs(<tree>,<x>,<list1>,<list2>,<a>,<b>,<al>,<ar>,<bl>,<br>,<reps>,
**           <pr>,<max>  ) . . . . . . . . . find possible pos-arguments for 
**                                           the trees in <list1> and <list2>
**
**  'FindSubs' finds all possibilities for a and b such that
**  1) a[1] < a[2] <..< a[ ar ]
**     b[1] < b[2] <..< b[ br ]
**  2) set( a concat b ) = {1,..,k} for a positiv integer k.
**  3) a[1],...,a[ al-1 ] and b[1],..,b[ bl-1 ] remain unchanged.
**  For each found possibility 'FindSubs' sets the pos-arguments in the
**  trees of <list1> and <list2> according to the entries of <a> and
**  <b>.  Then it calls 'FindNewReps' with the changed tree <tree> as
v**  argument.
**
**  It is assumed that the conditions 1) and 2) hold for a{ [1..al-1] } and
**  b{ [1..bl-1] }.  
**
**  There are three versions of FindSubs according to the three versions of
**  FindNewReps.  FindSubs1 is called from FindNewReps1 and calls
**  FindNewReps1.  FindSubs2 is called from FindNewReps2 and calls 
**  FindNewReps2.  FindSubs is called from FindNewReps and calls FindNewReps.
*/

static void FindSubs1(Obj tree,
                      Int x,     /*  subtree of <tree>                     */
                      Obj list1, /*  list containing all subtrees of
                                 **  left(<tree>) almost equal to
                                 **  tree(<tree>, x)                       */

                      Obj list2, /*  list containing all subtrees of
                                 **  right(<tree>) almost equal to
                                 **  tree(<tree>, x)                       */

                      Obj a, /*  list to change,  containing the
                             **  pos-arguments of the trees in list1   */

                      Obj b, /*  list to change,  containing tthe
                             **  pos-arguments of the trees in list2   */
                      Int al,
                      Int ar,
                      Int bl,
                      Int br,
                      Obj reps /*  list of representatives for all trees */
)
{
   Int    i;  /*  loop variable                                             */

   /*  if <al> > <ar> or <bl> > <br> nothing remains to change.             */
   if (  al > ar  ||  bl > br  )
   {
       /*  Set the pos-arguments of the trees in <list1> and <list2>
       **  according to the entries of <a> and <b>.                         */
       SetSubs( list1, a, tree);
       SetSubs( list2, b, tree);
       FindNewReps1(tree, reps);
       return;
   }
   /*  If a[ ar] is bigger or equal to the boundary of pos(tree(<tree>, x)
   **  the execution of the statements in the body of this if-statement
   **  would have the consequence that some subtrees of <tree> in <list1>
   **  would get a pos-argument bigger than the boundary of
   **  pos(tree<tree>, x).  But since the trees in <list1> are almost
   **  equal to tree(<tree>, x) they have all the same boundary for their
   **  pos-argument as tree(<tree>, x).  So these statements are only
   **  executed when <a>[ar] is less than the boundary of 
   **  pos(tree(<tree>, x).
   */
   if ( INT_INTOBJ( DT_MAX(tree, x) ) <= 0  ||  
        ELM_PLIST(a, ar) < DT_MAX(tree, x)   )
   {
       for (i=al; i<=ar; i++)
           SET_ELM_PLIST(a, i, INTOBJ_INT( CELM(a,i) + 1 ) );
       FindSubs1(tree, x, list1, list2, a, b, al, ar, bl+1, br, reps);
       for  (i=al; i<=ar; i++)
           SET_ELM_PLIST(a, i, INTOBJ_INT( CELM(a, i) - 1  ) );
   }
   FindSubs1(tree, x, list1, list2, a, b, al+1, ar, bl+1, br, reps);
   /*  If b[ br] is bigger or equal to the boundary of pos(tree(<tree>, x)
   **  the execution of the statements in the body of this if-statement
   **  would have the consequence that some subtrees of <tree> in <list2>
   **  would get a pos-argument bigger than the boundary of
   **  pos(tree<tree>, x).  But since the trees in <list2> are almost
   **  equal to tree(<tree>, x) they have all the same boundary for their
   **  pos-argument as tree(<tree>, x).  So these statements are only
   **  executed when <b>[br] is less than the boundary of 
   **  pos(tree(<tree>, x).
   */
   if ( INT_INTOBJ( DT_MAX(tree, x) ) <= 0  ||
        ELM_PLIST(b, br) < DT_MAX(tree, x)        )
   {
       for  (i=bl; i<=br; i++)
           SET_ELM_PLIST(b, i, INTOBJ_INT( CELM(b, i) + 1  ) );
       FindSubs1(tree, x, list1, list2, a, b, al+1, ar, bl, br, reps);
       for  (i=bl; i<=br; i++)
           SET_ELM_PLIST(b, i, INTOBJ_INT( CELM(b, i) - 1 ) );
   }
}


static void FindSubs2(Obj tree,
                      Int x,     /*  subtree of <tree>                     */
                      Obj list1, /*  list containing all subtrees of
                                 **  left(<tree>) almost equal to
                                 **  tree(<tree>, x)                       */

                      Obj list2, /*  list containing all subtrees of
                                 **  right(<tree>) almost equal to
                                 **  tree(<tree>, x)                       */

                      Obj a, /*  list to change,  containing the
                             **  pos-arguments of the trees in list1   */

                      Obj b, /*  list to change,  containing the
                             **  pos-arguments of the trees in list2   */
                      Int al,
                      Int ar,
                      Int bl,
                      Int br,
                      Obj reps, /*  list of representatives for all trees */
                      Obj pr    /*  pc-presentation                       */
)
{
   Int    i;  /*  loop variable                                             */

   /*  if <al> > <ar> or <bl> > <br> nothing remains to change.             */
   if (  al > ar  ||  bl > br  )
   {
       /*  Set the pos-arguments of the trees in <list1> and <list2>
       **  according to the entries of <a> and <b>.                         */
       SetSubs( list1, a, tree);
       SetSubs( list2, b, tree);
       FindNewReps2(tree, reps, pr);
       return;
   }
   /*  If a[ ar] is bigger or equal to the boundary of pos(tree(<tree>, x)
   **  the execution of the statements in the body of this if-statement
   **  would have the consequence that some subtrees of <tree> in <list1>
   **  would get a pos-argument bigger than the boundary of
   **  pos(tree<tree>, x).  But since the trees in <list1> are almost
   **  equal to tree(<tree>, x) they have all the same boundary for their
   **  pos-argument as tree(<tree>, x).  So these statements are only
   **  executed when <a>[ar] is less than the boundary of 
   **  pos(tree(<tree>, x).
   */
   if ( INT_INTOBJ( DT_MAX(tree, x) ) <= 0  ||  
        ELM_PLIST(a, ar) < DT_MAX(tree, x)   )
   {
       for (i=al; i<=ar; i++)
           SET_ELM_PLIST(a, i, INTOBJ_INT( CELM(a,i) + 1 ) );
       FindSubs2(tree, x, list1, list2, a, b, al, ar, bl+1, br, reps, pr);
       for  (i=al; i<=ar; i++)
           SET_ELM_PLIST(a, i, INTOBJ_INT( CELM(a, i) - 1  ) );
   }
   FindSubs2(tree, x, list1, list2, a, b, al+1, ar, bl+1, br, reps, pr);
   /*  If b[ br] is bigger or equal to the boundary of pos(tree(<tree>, x)
   **  the execution of the statements in the body of this if-statement
   **  would have the consequence that some subtrees of <tree> in <list2>
   **  would get a pos-argument bigger than the boundary of
   **  pos(tree<tree>, x).  But since the trees in <list2> are almost
   **  equal to tree(<tree>, x) they have all the same boundary for their
   **  pos-argument as tree(<tree>, x).  So these statements are only
   **  executed when <b>[br] is less than the boundary of 
   **  pos(tree(<tree>, x).
   */
   if ( INT_INTOBJ( DT_MAX(tree, x) ) <= 0  ||
        ELM_PLIST(b, br) < DT_MAX(tree, x)        )
   {
       for  (i=bl; i<=br; i++)
           SET_ELM_PLIST(b, i, INTOBJ_INT( CELM(b, i) + 1  ) );
       FindSubs2(tree, x, list1, list2, a, b, al+1, ar, bl, br, reps, pr);
       for  (i=bl; i<=br; i++)
           SET_ELM_PLIST(b, i, INTOBJ_INT( CELM(b, i) - 1 ) );
   }
}


static void FindSubs(Obj tree,
                     Int x,     /*  subtree of <tree>                     */
                     Obj list1, /*  list containing all subtrees of
                                **  left(<tree>) almost equal to
                                **  tree(<tree>, x)                       */

                     Obj list2, /*  list containing all subtrees of
                                **  right(<tree>) almost equal to
                                **  tree(<tree>, x)                       */

                     Obj a, /*  list to change,  containing the
                            **  pos-arguments of the trees in list1   */

                     Obj b, /*  list to change,  containing the
                            **  pos-arguments of the trees in list2   */
                     Int al,
                     Int ar,
                     Int bl,
                     Int br,
                     Obj reps, /*  list of representatives for all trees */
                     Obj pr,   /*  pc-presentation                       */
                     Obj max   /*  needed to call 'FindNewReps'          */
)
{
   Int    i;  /*  loop variable                                             */

   /*  if <al> > <ar> or <bl> > <br> nothing remains to change.             */
   if (  al > ar  ||  bl > br  )
   {
       /*  Set the pos-arguments of the trees in <list1> and <list2>
       **  according to the entries of <a> and <b>.                         */
       SetSubs( list1, a, tree);
       SetSubs( list2, b, tree);
       FindNewReps(tree, reps, pr, max);
       return;
   }
   /*  If a[ ar] is bigger or equal to the boundary of pos(tree(<tree>, x)
   **  the execution of the statements in the body of this if-statement
   **  would have the consequence that some subtrees of <tree> in <list1>
   **  would get a pos-argument bigger than the boundary of
   **  pos(tree<tree>, x).  But since the trees in <list1> are almost
   **  equal to tree(<tree>, x) they have all the same boundary for their
   **  pos-argument as tree(<tree>, x).  So these statements are only
   **  executed when <a>[ar] is less than the boundary of 
   **  pos(tree(<tree>, x).
   */
   if ( INT_INTOBJ( DT_MAX(tree, x) ) <= 0  ||  
        ELM_PLIST(a, ar) < DT_MAX(tree, x)   )
   {
       for (i=al; i<=ar; i++)
           SET_ELM_PLIST(a, i, INTOBJ_INT( CELM(a,i) + 1 ) );
       FindSubs(tree, x, list1, list2, a, b, al, ar, bl+1, br, reps, pr, max);
       for  (i=al; i<=ar; i++)
           SET_ELM_PLIST(a, i, INTOBJ_INT( CELM(a, i) - 1  ) );
   }
   FindSubs(tree, x, list1, list2, a, b, al+1, ar, bl+1, br, reps, pr, max);
   /*  If b[ br] is bigger or equal to the boundary of pos(tree(<tree>, x)
   **  the execution of the statements in the body of this if-statement
   **  would have the consequence that some subtrees of <tree> in <list2>
   **  would get a pos-argument bigger than the boundary of
   **  pos(tree<tree>, x).  But since the trees in <list2> are almost
   **  equal to tree(<tree>, x) they have all the same boundary for their
   **  pos-argument as tree(<tree>, x).  So these statements are only
   **  executed when <b>[br] is less than the boundary of 
   **  pos(tree(<tree>, x).
   */
   if ( INT_INTOBJ( DT_MAX(tree, x) ) <= 0  ||
        ELM_PLIST(b, br) < DT_MAX(tree, x)        )
   {
       for  (i=bl; i<=br; i++)
           SET_ELM_PLIST(b, i, INTOBJ_INT( CELM(b, i) + 1  ) );
       FindSubs(tree, x, list1, list2, a, b, al+1, ar, bl, br, reps, pr, max);
       for  (i=bl; i<=br; i++)
           SET_ELM_PLIST(b, i, INTOBJ_INT( CELM(b, i) - 1 ) );
   }
}


/****************************************************************************
**
*F  SetSubs(<list>, <a>, <tree>) . . . . . . . . . . .. .  set pos-arguments
** 
**  'SetSubs' sets the pos-arguments of the subtrees of <tree>,  contained
**  in <list> according to the entries in the list <a>.
*/
static void SetSubs(Obj list, Obj a, Obj tree)
{
    UInt   i,j;  /*  loop variables                                         */
    UInt   len, len2;
    
    len = LEN_PLIST(list);
    for  (i=1; i <= len; i++)
    {
        len2 = LEN_PLIST( ELM_PLIST(list, i) );
        for  (j=1;  j <= len2;  j++)
            SET_DT_POS(tree, CELM( ELM_PLIST(list, i), j), ELM_PLIST(a, i) );
    }
}


/****************************************************************************
**
*F  UnmarkAEClass(<tree>, <list>) . . . . . . . . . . . . reset pos-arguments
**
**  'UnmarkAEClass' resets the pos arguments of the subtrees of <tree>,
**  contained in <list> to the original state.  Furthermore it unmarks the
**  top node of each of those trees.
*/

static void UnmarkAEClass(Obj tree, Obj list)
{
    UInt  i,j, len, len2;

    len = LEN_PLIST(list);
    for  (i=1; i <= len; i++)
    {
        len2 = LEN_PLIST( ELM_PLIST(list, i) );
        for (j=1;  j <= len2;  j++)
        {
            DT_UNMARK(tree, CELM( ELM_PLIST(list, i), j)  );
            SET_DT_POS(tree, CELM( ELM_PLIST(list, i), j), INTOBJ_INT(i) );
        }
    }
}


/****************************************************************************
**
*F  FuncDT_evaluation( <self>, <vector> )
**
**  FuncDT_evaluation implements the internal function
**
**  DT_evaluation( <vector> ).
**
**  DT_evaluation returns a positive integer which is used to sort the deep
**  monomials.  DT_evaluation is called from the library function dt_add.
*/

static Obj FuncDT_evaluation(Obj self, Obj vector)
{
    UInt   res,i;

    res = CELM(vector, 6)*CELM(vector, 6);
    for  (i=7; i < LEN_PLIST(vector); i+=2)
        res += CELM(vector, i)*CELM(vector, i+1)*CELM(vector, i+1);
    return INTOBJ_INT(res);
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

    GVAR_FUNC_2ARGS(MakeFormulaVector, tree, presentation),
    GVAR_FUNC_4ARGS(
        FindNewReps, tree, representatives, presentation, maximum),
    GVAR_FUNC_1ARGS(UnmarkTree, tree),
    GVAR_FUNC_3ARGS(GetPols, list, presentation, polynomial),
    GVAR_FUNC_1ARGS(DT_evaluation, vector),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    InitFopyGVar( "Dt_add" , &Dt_add );

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
*F  InitInfoDeepThought() . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "dt",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoDeepThought ( void )
{
    return &module;
}
