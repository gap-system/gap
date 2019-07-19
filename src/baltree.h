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

enum { MaxTreeDepth = 2 * (sizeof(UInt) * 8) };

static int height_to_size_init = 0;
// For scapegoat trees with balance factor alpha:
// height_to_size: d -> (1/alpha) ^ d
static Int height_to_size[MaxTreeDepth];

// alpha = alpha_lo / alpha_hi
static const Int alpha_hi = 3;
static const Int alpha_lo = 2;

static inline void InitBalancedTrees(void)
{
    if (!height_to_size_init) {
        height_to_size_init = 1;
        double w = 1.0;
        for (int d = 0; d < MaxTreeDepth; d++) {
            w *= (double)alpha_hi;
            w /= (double)alpha_lo;
            height_to_size[d] = (Int)w;
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

// Linearize subtree starting at node
static inline Node ** FN(Linearize)(Node ** buf, Node * node)
{
    if (node->left)
        buf = FN(Linearize)(buf, node->left);
    *buf++ = node;
    if (node->right)
        buf = FN(Linearize)(buf, node->right);
    return buf;
}

static inline Node * FN(Treeify)(Node ** buf, Int size)
{
    Int mid;
    switch (size) {
    case 0:
        return NULL;
    case 1:
        buf[0]->left = NULL;
        buf[0]->right = NULL;
        return buf[0];
    default:
        mid = size >> 1;
        buf[mid]->left = FN(Treeify)(buf, mid);
        buf[mid]->right = FN(Treeify)(buf + mid + 1, size - mid - 1);
        return buf[mid];
    }
}

static inline void FN(Rebalance)(Node ** nodeaddr, Int size)
{
    const Int N = 1024;
    Node *    node = *nodeaddr;
    Node *    local[N];
    Node **   buf = size <= N ? local : ALLOC(Node *, size);
    FN(Linearize)(buf, node);
    *nodeaddr = FN(Treeify)(buf, size);
    if (buf != local)
        DEALLOC(buf);
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

static inline Int FN(InsertAux)(Tree * tree, Node ** nodeaddr, ELEM_TYPE item, int d)
{
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
        return height_to_size[d] > tree->nodes;
    }
    int c = COMPARE(item, node->item);
    Int lsize, rsize;
    // insert and calculate sizes of subtrees
    if (c < 0) {
        lsize = FN(InsertAux)(tree, &node->left, item, d + 1);
        if (lsize == 0)
            return 0;
        rsize = FN(CountAux)(node->right);
    }
    else if (c > 0) {
        rsize = FN(InsertAux)(tree, &node->right, item, d + 1);
        if (rsize == 0)
            return 0;
        lsize = FN(CountAux)(node->left);
    }
    else {
        node->item = item;
        return 0;
    }
    Int size = lsize + rsize + 1;
    // lsize <= alpha * size && rsize <= alpha * size
    if (alpha_hi * lsize <= alpha_lo * size &&
        alpha_hi * rsize <= alpha_lo * size) {
        // try further up if not unbalanced
        return size;
    }
    // rebalance node
    FN(Rebalance)(nodeaddr, size);
    return 0;
}

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
    if (alpha_hi * tree->nodes <= alpha_lo * tree->maxnodes) {
        if (tree->root)
            FN(Rebalance)(&tree->root, tree->nodes);
        tree->maxnodes = tree->nodes;
    }
}

static inline void FN(RemoveAux)(Tree * tree, Node ** nodeaddr, ELEM_TYPE item)
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
    FN(InsertAux)(tree, &tree->root, item, 0);
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
