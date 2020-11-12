/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  WARNING: This file should NOT be directly included. It is designed
**  to instantiate a generic balanced tree type based on #defines that
**  have to be set before including the file, and the file can be included
**  repeatedly with different parameters.
**
**  The balanced tree being used is a scapegoat tree. Scapegoat trees have
**  amortized logarithmic insertion and deletion time and logarithmic lookup
**  time. While insertion and deletion only have amortized logarithmic time
**  complexity, that is offset by the much simpler implementation compared
**  to AVL trees or red black trees, as complicated rotations are avoided.
**
**  @inproceedings{10.5555/313559.313676,
**    author = {Galperin, Igal and Rivest, Ronald L.},
**    title = {Scapegoat Trees},
**    year = {1993},
**    isbn = {0898713137},
**    publisher = {Society for Industrial and Applied Mathematics},
**    address = {USA},
**    booktitle = {Proceedings of the Fourth Annual ACM-SIAM Symposium on
**      Discrete Algorithms},
**    pages = {165–174},
**    numpages = {10},
**    location = {Austin, Texas, USA},
**    series = {SODA '93}
**  }
*/

// Parameters:
//
// #define ELEM_TYPE type of elements
// #define COMPARE comparison function for elements
// #define ALLOC allocation function (optional)
// #define DEALLOC deallocation function (optional)

#define Tree JOIN(ELEM_TYPE, Tree)
#define Node JOIN(ELEM_TYPE, Node)

#define FN(sym) JOIN(Tree, sym)

#define JOIN(s1, s2) JOIN2(s1, s2)
#define JOIN2(s1, s2) s1##s2

#ifndef ALLOC
#define ALLOC(T, n) ((T *)malloc(sizeof(T) * (n)))
#endif

#ifndef DEALLOC
#define DEALLOC(p) (free(p))
#endif

#ifndef BALANCED_TREE_INIT    // non-generic part shared by all versions
#define BALANCED_TREE_INIT

// Scapegoat trees are height-balanced trees. With respect to a
// parameter alpha, with 0.5 < alpha < 1, a binary tree is
// height-balanced, if
//
//   height(tree) <= log_{1/alpha}(size(tree))
//
// where size(tree) is the number of nodes that a tree contains. The
// closer alpha is to 0.5, the closer a height-balanced tree is to a
// balanced tree. With alpha = 1, a linked list would be
// height-balanced. However, the smaller alpha is, the more time will be
// wasted on rebalancing operations.
//
// A binary tree is called weight-balanced iff for any subtree `tree`,
//
//   size(left) <= alpha * size(tree) and
//   size(right) <= alpha * size(tree)
//
// where `left` and `right` are the left and right subtrees of `tree`.
//
// Any weight-balanced tree is also height-balanced, but not all
// height-balanced trees are also weight-balanced. However, by
// contraposition, any tree that is not height-balanced cannot be
// weight-balanced, either.
//
// Furthermore, for any tree that is not height-balanced, any node at
// maximum depth will have an ancestor that is not weight-balanced.
// Thus, if we violate the height balance property through the insertion
// of a new node, we can simply check that node's ancestors to look for
// a node that is not weight-balanced and rebalance the subtree rooted
// at that node.
//
// Rebalancing operations have time complexity linear in the number of
// nodes affected, but their amortized cost is O(log n) per node for a
// tree with n nodes, as most insertions either do not require
// rebalancing or only the rebalancing of a small number of nodes.
//
// Overall, this ensures that height(tree) = O(log(size(tree)) and that
// insertion, deletion, and lookup operations can be done in amortized
// O(log(size(tree)) time. While individual insertion or deletion
// operations (though not lookup operations) can take O(size(tree))
// time, the amortized time complexity remains logarithmic.
//
// See [Galperin and Rivest 1993] for further details and proofs of the
// above claims.

// The value of MaxTreeDepth assumes that alpha <= 1/sqrt(2). Larger
// values of alpha do not lead to well-balanced trees.
enum { MaxTreeDepth = 2 * (sizeof(UInt) * 8) };

static int min_nodes_for_height_init = 0;
// For scapegoat trees with balance factor alpha:
// min_nodes_for_height: d -> (1/alpha) ^ d
//
// This array contains the minimum number of nodes that
// a binary tree of a given height can contain while still
// being height-balanced. Any tree with fewer nodes is too
// sparse to be height balanced.
static Int min_nodes_for_height[MaxTreeDepth];

// alpha = ALPHA_NUM / ALPHA_DENOM
// We use integers to allow for more efficient arithmetic.
enum {
  ALPHA_DENOM = 3,
  ALPHA_NUM = 2,
};

static inline void InitBalancedTrees(void)
{
    if (!min_nodes_for_height_init) {
        min_nodes_for_height_init = 1;
        double w = 1.0;
        for (int d = 0; d < MaxTreeDepth; d++) {
            w *= (double)ALPHA_DENOM;
            w /= (double)ALPHA_NUM;
            min_nodes_for_height[d] = (Int)w;
        }
    }
}

#endif    // BALANCED_TREE_INIT

typedef struct Node {
    struct Node *left, *right;
    ELEM_TYPE    item;
} Node;

typedef struct {
    Int    nodes, maxnodes;
    Node * root;
} Tree;

static inline void FN(DeleteNodes)(Node * node)
{
    if (node != NULL) {
        FN(DeleteNodes)(node->left);
        FN(DeleteNodes)(node->right);
        DEALLOC(node);
    }
}

static inline Node * FN(Linearize)(Node * subtree, Node * list)
{
    // Linearize subtree; returns `subtree` in list form with right
    // pointers connecting them and `list` appended to the right.
    if (subtree == NULL)
        return list;
    subtree->right = FN(Linearize)(subtree->right, list);
    return FN(Linearize)(subtree->left, subtree);
}

static inline Node * FN(Treeify)(Node * list, Int n)
{
    // Turn a linked list into a tree.
    //
    // Returns a pointer to the n+1'st node. The left pointer of that
    // node points to the subtree we constructed, the right pointer of
    // that node points to a linked list of the remaining elements.
    if (n == 0) {
        list->left = NULL;
        return list;
    }
    n--;
    Int n2 = n >> 1;
    Int n1 = n - n2;
    // Create left subtree and root of result.
    Node * root = FN(Treeify)(list, n1);
    // root->left contains the left subtree.
    // root->right contains nodes not yet treeified.

    // Create right subtree.
    Node * tail = FN(Treeify)(root->right, n2);
    // tail->left contains the right subtree.
    // tail points to any nodes not yet treeified.
    root->right = tail->left;
    tail->left = root;
    return tail;
}

// A subtree is rebalanced by first turning it into a linked list
// (linked through the `right` pointer) and then turning the linked list
// into a balanced tree in a second step. Both operations occur in place
// and do not require additional memory, other than O(height(subtree))
// stack space for recursion, which again is bounded by O(log(nodes)).

static inline void FN(Rebalance)(Node ** nodeaddr, Int size)
{
    Node * subtree = *nodeaddr;
    Node   pseudoroot;
    pseudoroot.left = pseudoroot.right = NULL;
    Node * linearized = FN(Linearize)(subtree, &pseudoroot);
    *nodeaddr = FN(Treeify)(linearized, size)->left;
}

static inline Int FN(CountAux)(Node * node)
{
    if (node == NULL)
        return 0;
    else
        return 1 + FN(CountAux)(node->left) + FN(CountAux)(node->right);
}

static inline Int FN(Count)(Tree * tree)
{
    return FN(CountAux)(tree->root);
}

static inline ELEM_TYPE * FN(FindAux)(Node * node, ELEM_TYPE item)
{
    if (node == NULL)
        return NULL;
    int c = COMPARE(item, node->item);
    if (c < 0)
        return FN(FindAux)(node->left, item);
    else if (c > 0)
        return FN(FindAux)(node->right, item);
    else
        return &node->item;
}

// Insertion works by first doing a normal binary tree insertion, then
// checking if the tree is no longer height-balanced, which is done by
// comparing the height of the tree to log(nodes, 1/alpha). The tree no
// longer being height balanced, this implies it is no longer
// weight-balanced (see above), so we go up the tree to look for an
// ancestor that is not weight-balanced and rebalance the tree at that
// point.

static inline Int
    FN(InsertAux)(Tree * tree, Node ** nodeaddr, ELEM_TYPE item, int d)
{
    // This function returns 0 if no further rebalancing is needed and
    // the number of nodes in the subtree rooted at `*nodeaddr` if
    // the subtree is not height-balanced.
    Node * node = *nodeaddr;
    if (node == NULL) {
        // actual insertion
        *nodeaddr = node = ALLOC(Node, 1);
        node->left = NULL;
        node->right = NULL;
        node->item = item;
        tree->nodes++;
        // calculate: (1/alpha) ^ d > _nodes
        // equivalent to: d > log(_nodes, 1/alpha)
        // i.e.: has the tree become unbalanced?
        return min_nodes_for_height[d] > tree->nodes;
    }
    int c = COMPARE(item, node->item);
    Int lsize, rsize;
    // insert and calculate sizes of subtrees
    if (c < 0) {
        lsize = FN(InsertAux)(tree, &node->left, item, d + 1);
        if (lsize == 0)    // balanced?
            return 0;
        rsize = FN(CountAux)(node->right);
    }
    else if (c > 0) {
        rsize = FN(InsertAux)(tree, &node->right, item, d + 1);
        if (rsize == 0)    // balanced?
            return 0;
        lsize = FN(CountAux)(node->left);
    }
    else {
        node->item = item;    // overwrite, no rebalancing necessary.
        return 0;
    }
    Int size = lsize + rsize + 1;
    // The following condition checks
    //
    //   lsize <= alpha * size && rsize <= alpha * size
    //
    // while avoiding potentially expensive operations.
    if (ALPHA_DENOM * lsize <= ALPHA_NUM * size &&
        ALPHA_DENOM * rsize <= ALPHA_NUM * size) {
        // try further up the tree if the current subtree is balanced
        return size;
    }
    // subtree is not weight-balanced, so rebalance it.
    FN(Rebalance)(nodeaddr, size);
    return 0;
}


// Deletion of nodes checks if the size of the tree becomes smaller
// than alpha * max_nodes, where max_nodes is the maximum number of
// nodes that the tree has had prior to the last deletion. This
// ensures that the tree remains loosely height-balanced, i.e.
// height <= log(nodes, 1/alpha) + 1. (Note the + 1, which is
// different from the normal height balance property.)

static inline void FN(RemoveNode)(Tree * tree, Node ** nodeaddr)
{
    Node * node = *nodeaddr;
    Node * del = node;
    if (node->left != NULL) {
        if (node->right != NULL) {
            // copy from & delete in order successor
            Node ** succ = &node->right;
            while ((*succ)->left != NULL)
                succ = &(*succ)->left;
            node->item = (*succ)->item;
            FN(RemoveNode)(tree, succ);
            return;
        }
        else {
            *nodeaddr = node->left;
        }
    }
    else {
        *nodeaddr = node->right;
    }
    DEALLOC(del);
    tree->nodes--;
    if (ALPHA_DENOM * tree->nodes <= ALPHA_NUM * tree->maxnodes) {
        if (tree->root)
            FN(Rebalance)(&tree->root, tree->nodes);
        tree->maxnodes = tree->nodes;
    }
}

static inline void
    FN(RemoveAux)(Tree * tree, Node ** nodeaddr, ELEM_TYPE item)
{
    Node * node = *nodeaddr;
    if (!node)
        return;
    int c = COMPARE(item, node->item);
    if (c < 0)
        FN(RemoveAux)(tree, &node->left, item);
    else if (c > 0)
        FN(RemoveAux)(tree, &node->right, item);
    else {
        FN(RemoveNode)(tree, nodeaddr);
    }
}

static inline Tree * FN(Make)(void)
{
    Tree * tree = ALLOC(Tree, 1);
    tree->nodes = tree->maxnodes = 0;
    tree->root = NULL;
    InitBalancedTrees();
    return tree;
}

static inline void FN(Delete)(Tree * tree)
{
    FN(DeleteNodes)(tree->root);
    DEALLOC(tree);
}


static inline void FN(Insert)(Tree * tree, ELEM_TYPE item)
{
    Int rebalance = FN(InsertAux)(tree, &tree->root, item, 0);
    // GAP_ASSERT(rebalance == 0);
    //
    // Note: under normal circumstances, rebalance should never be
    // non-zero, as one of the properties of a scapegoat tree is that
    // inserting a node that is not height-balanced implies that there
    // it has an ancestor that is not weight-balanced.
    //
    // This is a safeguard against errors where the min_nodes_for_height
    // array contains values that are too large. While this is not
    // possible with the current settings, different alpha values or
    // changes in the implementation may cause such an effect. For
    // example, this case can be triggered by simply increasing all
    // entries in min_nodes_for_height by 1.
    //
    // The rebalance operation is still not necessary for
    // correctness, but prevents performance regressions by avoiding
    // unnecessary O(nodes) operations.
    if (rebalance > 0) {
        FN(Rebalance)(&tree->root, rebalance);
    }
    if (tree->nodes > tree->maxnodes)
        tree->maxnodes = tree->nodes;
}

static inline ELEM_TYPE * FN(Find)(Tree * tree, ELEM_TYPE item)
{
    return FN(FindAux)(tree->root, item);
}

static inline void FN(Remove)(Tree * tree, ELEM_TYPE item)
{
    FN(RemoveAux)(tree, &tree->root, item);
}

static inline void FN(Clear)(Tree * tree)
{
    FN(DeleteNodes)(tree->root);
    tree->root = NULL;
    tree->nodes = tree->maxnodes = 0;
}

static inline Int FN(DepthAux)(Node * node)
{
    if (node == NULL)
        return 0;
    Int m1 = FN(DepthAux)(node->left);
    Int m2 = FN(DepthAux)(node->right);
    return (m1 < m2 ? m2 : m1) + 1;
}

static inline Int FN(Depth)(Tree * tree)
{
    return FN(DepthAux)(tree->root);
}

#undef Tree
#undef Node

#undef FN

#undef JOIN
#undef JOIN2

#undef ELEM_TYPE
#undef COMPARE
#undef ALLOC
#undef DEALLOC
