/*
 * Small program to test data structures used by the Julia GC integration.
 */

#include <libgap-api.h>
#include <stdio.h>

static int int_cmp(int a, int b)
{
    return a - b;
}

#define ELEM_TYPE int
#define COMPARE int_cmp

#include "baltree.h"

void ShowTree(intTree * btree)
{
    printf("Tree state: %ld nodes, %ld depth.\n", (long)intTreeCount(btree),
           (long)intTreeDepth(btree));
}

void TestScapegoatTrees(void)
{
    const Int N = 1024 * 1024;
    intTree * btree = intTreeMake();
    printf("# Testing balanced trees.\n");
    for (int i = 0; i < N; i++) {
        intTreeInsert(btree, i);
    }
    ShowTree(btree);
    Int errors = 0;
    for (int i = 0; i < N; i++) {
        if (!intTreeFind(btree, i))
            errors++;
    }
    printf("Missing nodes: %ld\n", (long)errors);
    printf("# Removing half of all nodes.\n");
    for (int i = 1; i < N; i += 2) {
        intTreeRemove(btree, i);
    }
    ShowTree(btree);
    errors = 0;
    for (int i = 0; i < N; i += 2) {
        if (!intTreeFind(btree, i))
            errors++;
        if (intTreeFind(btree, i + 1))
            errors++;
    }
    printf("Missing/wrong nodes: %ld\n", (long)errors);
    printf("# Removing all but one node.\n");
    for (int i = 1; i < N; i++) {
        intTreeRemove(btree, i);
    }
    ShowTree(btree);
    intTreeClear(btree);
    printf("# Creating tree from out of order insertions.\n");
    for (int i = 0, j = 0; i < N; i++, j = (5 * j + 1) & (N - 1)) {
        intTreeInsert(btree, j);
    }
    ShowTree(btree);
    errors = 0;
    for (int i = 0; i < N; i++) {
        if (!intTreeFind(btree, i))
            errors++;
    }
    printf("Missing nodes: %ld\n", (long)errors);
    printf("# Deleting half nodes out of order.\n");
    for (int i = 0, j = 0; i < N; i++, j = (j + 7) & (N - 1)) {
        if (i == N / 2) {
            ShowTree(btree);
            printf("# Deleting other nodes out of order.\n");
        }
        intTreeRemove(btree, i);
    }
    ShowTree(btree);
    intTreeDelete(btree);
    printf("# Balanced tree tests finished.\n");
}

#define ELEM_TYPE int
#define COMPARE int_cmp

#include "dynarray.h"

void ShowArray(intArray * arr)
{
    Int sum = 0;
    for (Int i = 0; i < intArrayLen(arr); i++) {
        sum += arr->items[i];
    }
    printf("Array state: length = %ld, sum = %ld\n", (long)intArrayLen(arr),
           (long)sum);
}


static void TestDynArrays(void)
{
    const Int N = 50000;
    printf("# Testing dynamic arrays.\n");
    intArray * arr = intArrayMake(1);
    for (Int i = 0; i < N; i++) {
        intArrayAdd(arr, N - i);
    }
    ShowArray(arr);
    Int errors = 0;
    for (Int i = 0; i < N; i++) {
        if (intArrayGet(arr, i) != N - i)
            errors++;
    }
    printf("Wrong entries: %ld\n", (long)errors);
    printf("# Sorting array.\n");
    intArraySort(arr);
    errors = 0;
    for (Int i = 0; i < N; i++) {
        if (intArrayGet(arr, i) != i + 1)
            errors++;
    }
    printf("Wrong entries: %ld\n", (long)errors);
    printf("# Splitting and duplicating array.\n");
    intArraySetLen(arr, N / 2);
    for (Int i = 0; i < N / 2; i++) {
        intArrayAdd(arr, arr->items[i]);
    }
    ShowArray(arr);
    printf("# Cloning array.\n");
    intArray * arr2 = intArrayClone(arr);
    errors = 0;
    for (Int i = 0; i < N / 2; i++) {
        if (intArrayGet(arr2, i) != i + 1)
            errors++;
        if (intArrayGet(arr2, i + N / 2) != i + 1)
            errors++;
    }
    printf("Wrong entries: %ld\n", (long)errors);
    ShowArray(arr2);
    intArrayDelete(arr);
    intArrayDelete(arr2);
    printf("# Dynamic array tests finished.\n");
}

int main(int argc, char ** argv)
{
    TestScapegoatTrees();
    TestDynArrays();
    return 0;
}
