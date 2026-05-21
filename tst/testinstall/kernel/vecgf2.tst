#
# Tests for functions defined in src/vecgf2.c
#
gap> START_TEST("kernel/vecgf2.tst");
gap> z := 0*Z(2);;
gap> o := Z(2)^0;;
gap> V2 := function(list)
> local v;
>   v := ShallowCopy(list);
>   CONV_GF2VEC(v);
>   return v;
> end;;
gap> M2 := function(rows)
> local m, i;
>   m := List(rows, ShallowCopy);
>   for i in [1 .. Length(m)] do
>     CONV_GF2VEC(m[i]);
>   od;
>   CONV_GF2MAT(m);
>   return m;
> end;;
gap> Mx02 := n -> M2(List([1 .. n], i -> []));;
gap> Veclis2 := function(rows)
> local f, fdi, fdip, veclis, row, mults, j, mult;
>   f := AsSSortedList(GF(2));
>   fdi := [];
>   for j in [2 .. Length(f)] do
>     fdi[j - 1] := f[j] - f[j - 1];
>   od;
>   Add(fdi, -Last(f));
>   fdip := List(fdi, x -> Position(fdi, x));
>   veclis := [];
>   for row in rows do
>     mults := [];
>     mults[Length(fdi) + 1] := false;
>     for j in [1 .. Length(fdi)] do
>       if fdip[j] < j then
>         mult := mults[fdip[j]];
>       else
>         mult := fdi[j] * row;
>       fi;
>       mults[j] := mult;
>     od;
>     Add(veclis, mults);
>   od;
>   return veclis;
> end;;
gap> empty := V2([]);;
gap> one := V2([o]);;
gap> oneZero := V2([z]);;

#
# CONV_GF2VEC
#
gap> v := [];; CONV_GF2VEC(v); v;
<a GF2 vector of length 0>

# bad arguments
gap> CONV_GF2VEC(fail);
Error, CONV_GF2VEC: <list> must be a small list (not the value 'fail')

#
# COPY_GF2VEC
#
gap> v := COPY_GF2VEC([]);
<a GF2 vector of length 0>

# bad arguments
gap> COPY_GF2VEC(fail);
Error, COPY_GF2VEC: argument must be a list of GF2 elements

#
# PLAIN_GF2VEC
#
gap> v := V2([]);; PLAIN_GF2VEC(v);; IsPlistRep(v) and Length(v) = 0;
true

# bad arguments
gap> PLAIN_GF2VEC(fail);
Error, PLAIN_GF2VEC: <list> must be a GF2 vector (not the value 'fail')

#
# PLAIN_GF2MAT
#
gap> m := Mx02(2);; PLAIN_GF2MAT(m);; IsPlistRep(m) and m = [[], []];
true

# bad arguments
gap> PLAIN_GF2MAT(fail);
Error, PLAIN_GF2MAT: <list> must be a GF2 matrix (not the value 'fail')

#
# EQ_GF2VEC_GF2VEC
#
gap> EQ_GF2VEC_GF2VEC(empty, empty);
true
gap> EQ_GF2VEC_GF2VEC(empty, one);
false

# bad arguments
gap> EQ_GF2VEC_GF2VEC(fail, empty);
Error, EQ_GF2VEC_GF2VEC: <vl> must be a GF2 vector (not the value 'fail')
gap> EQ_GF2VEC_GF2VEC(empty, fail);
Error, EQ_GF2VEC_GF2VEC: <vr> must be a GF2 vector (not the value 'fail')

#
# LT_GF2VEC_GF2VEC
#
gap> LT_GF2VEC_GF2VEC(oneZero, one);
true
gap> LT_GF2VEC_GF2VEC(one, oneZero);
false

# bad arguments
gap> LT_GF2VEC_GF2VEC(fail, one);
Error, LT_GF2VEC_GF2VEC: <vl> must be a GF2 vector (not the value 'fail')
gap> LT_GF2VEC_GF2VEC(oneZero, fail);
Error, LT_GF2VEC_GF2VEC: <vr> must be a GF2 vector (not the value 'fail')

#
# EQ_GF2MAT_GF2MAT
#
gap> EQ_GF2MAT_GF2MAT(Mx02(2), Mx02(2));
true
gap> EQ_GF2MAT_GF2MAT(Mx02(1), Mx02(2));
false

# bad arguments
gap> EQ_GF2MAT_GF2MAT(fail, Mx02(2));
Error, EQ_GF2MAT_GF2MAT: <ml> must be a GF2 matrix (not the value 'fail')
gap> EQ_GF2MAT_GF2MAT(Mx02(2), fail);
Error, EQ_GF2MAT_GF2MAT: <mr> must be a GF2 matrix (not the value 'fail')

#
# LT_GF2MAT_GF2MAT
#
gap> LT_GF2MAT_GF2MAT(Mx02(1), Mx02(2));
true
gap> LT_GF2MAT_GF2MAT(Mx02(2), Mx02(1));
false

# bad arguments
gap> LT_GF2MAT_GF2MAT(fail, Mx02(2));
Error, LT_GF2MAT_GF2MAT: <ml> must be a GF2 matrix (not the value 'fail')
gap> LT_GF2MAT_GF2MAT(Mx02(1), fail);
Error, LT_GF2MAT_GF2MAT: <mr> must be a GF2 matrix (not the value 'fail')

#
# LEN_GF2VEC
#
gap> LEN_GF2VEC(empty);
0
gap> LEN_GF2VEC(V2([o, z]));
2

# bad arguments
gap> LEN_GF2VEC(fail);
Error, LEN_GF2VEC: <list> must be a GF2 vector (not the value 'fail')

#
# ELM0_GF2VEC
#
gap> ELM0_GF2VEC(empty, 1);
fail
gap> ELM0_GF2VEC(one, 1);
Z(2)^0

# bad arguments
gap> ELM0_GF2VEC(fail, 1);
Error, ELM0_GF2VEC: <list> must be a GF2 vector (not the value 'fail')
gap> ELM0_GF2VEC(empty, fail);
Error, ELM0_GF2VEC: <pos> must be a small integer (not the value 'fail')

#
# ELM_GF2VEC
#
gap> ELM_GF2VEC(one, 1);
Z(2)^0

# bad arguments
gap> ELM_GF2VEC(fail, 1);
Error, ELM_GF2VEC: <list> must be a GF2 vector (not the value 'fail')
gap> ELM_GF2VEC(one, fail);
Error, ELM_GF2VEC: <pos> must be a small integer (not the value 'fail')

#
# ELMS_GF2VEC
#
gap> ELMS_GF2VEC(empty, []) = empty;
true
gap> ELMS_GF2VEC(V2([o, z]), [1]);
<a GF2 vector of length 1>

# bad arguments
gap> ELMS_GF2VEC(fail, []);
Error, ELMS_GF2VEC: <list> must be a GF2 vector (not the value 'fail')
gap> ELMS_GF2VEC(empty, fail);
Error, Length: <list> must be a list (not the value 'fail')

#
# ASS_GF2VEC
#
gap> v := V2([]);; ASS_GF2VEC(v, 1, z);; v = oneZero;
true

# bad arguments
gap> ASS_GF2VEC(fail, 1, z);
Error, ASS_GF2VEC: <list> must be a GF2 vector (not the value 'fail')
gap> ASS_GF2VEC(v, fail, z);
Error, ASS_GF2VEC: <pos> must be a small integer (not the value 'fail')
gap> ASS_GF2VEC(v, 1, fail);

#
# ELM_GF2MAT
#
gap> ELM_GF2MAT(Mx02(2), 1);
<a GF2 vector of length 0>

# bad arguments
gap> ELM_GF2MAT(fail, 1);
Error, ELM_GF2MAT: <mat> must be a GF2 matrix (not the value 'fail')
gap> ELM_GF2MAT(Mx02(2), fail);
Error, ELM_GF2MAT: <row> must be a small integer (not the value 'fail')

#
# ASS_GF2MAT
#
gap> m := M2([[]]);; ASS_GF2MAT(m, 2, empty);; m = Mx02(2);
true

# bad arguments
gap> ASS_GF2MAT(fail, 2, empty);
Error, ASS_GF2MAT: <list> must be a GF2 matrix (not the value 'fail')
gap> ASS_GF2MAT(m, fail, empty);
Error, ASS_GF2MAT: <pos> must be a small integer (not the value 'fail')
gap> ASS_GF2MAT(m, 2, fail);

#
# SWAP_ROWS_GF2MAT
#
gap> m := M2([[o], [z]]);; SWAP_ROWS_GF2MAT(m, 1, 2);; m = M2([[z], [o]]);
true

# bad arguments
gap> SWAP_ROWS_GF2MAT(fail, 1, 2);
Error, SWAP_ROWS_GF2MAT: <mat> must be a GF2 matrix (not the value 'fail')
gap> SWAP_ROWS_GF2MAT(m, fail, 2);
Error, SWAP_ROWS_GF2MAT: <row1> must be a small integer (not the value 'fail')
gap> SWAP_ROWS_GF2MAT(m, 1, fail);
Error, SWAP_ROWS_GF2MAT: <row2> must be a small integer (not the value 'fail')

#
# SWAP_COLS_GF2MAT
#
gap> m := M2([[o, z]]);; SWAP_COLS_GF2MAT(m, 1, 2);; m = M2([[z, o]]);
true

# bad arguments
gap> SWAP_COLS_GF2MAT(fail, 1, 2);
Error, SWAP_COLS_GF2MAT: <mat> must be a GF2 matrix (not the value 'fail')
gap> SWAP_COLS_GF2MAT(m, fail, 2);
Error, SWAP_COLS_GF2MAT: <col1> must be a small integer (not the value 'fail')
gap> SWAP_COLS_GF2MAT(m, 1, fail);
Error, SWAP_COLS_GF2MAT: <col2> must be a small integer (not the value 'fail')

#
# UNB_GF2VEC
#
gap> v := V2([o]);; UNB_GF2VEC(v, 1);; v = empty;
true

# bad arguments
gap> UNB_GF2VEC(fail, 1);
Error, UNB_GF2VEC: <list> must be a GF2 vector (not the value 'fail')
gap> UNB_GF2VEC(v, fail);
Error, UNB_GF2VEC: <pos> must be a small integer (not the value 'fail')

#
# UNB_GF2MAT
#
gap> m := M2([[]]);; UNB_GF2MAT(m, 1);; m = [];
true

# bad arguments
gap> UNB_GF2MAT(fail, 1);
Error, UNB_GF2MAT: <list> must be a GF2 matrix (not the value 'fail')
gap> UNB_GF2MAT(m, fail);
Error, UNB_GF2MAT: <pos> must be a small integer (not the value 'fail')

#
# ZERO_GF2VEC
#
gap> ZERO_GF2VEC(empty);
<a GF2 vector of length 0>
gap> ZERO_GF2VEC(V2([o, z]));
<a GF2 vector of length 2>

# bad arguments
gap> ZERO_GF2VEC(fail);
Error, ZERO_GF2VEC: <mat> must be a GF2 vector (not the value 'fail')

#
# ZERO_GF2VEC_2
#
gap> ZERO_GF2VEC_2(0);
<a GF2 vector of length 0>
gap> ZERO_GF2VEC_2(2);
<a GF2 vector of length 2>

# bad arguments
gap> ZERO_GF2VEC_2(fail);
Error, ZERO_GF2VEC_2: <len> must be a non-negative small integer (not the valu\
e 'fail')

#
# INV_GF2MAT_MUTABLE
#
gap> INV_GF2MAT_MUTABLE(M2([[o]])) = M2([[o]]);
true

# bad arguments
gap> INV_GF2MAT_MUTABLE(fail);
Error, INV_GF2MAT_MUTABLE: <mat> must be a GF2 matrix (not the value 'fail')

#
# INV_GF2MAT_SAME_MUTABILITY
#
gap> INV_GF2MAT_SAME_MUTABILITY(M2([[o]])) = M2([[o]]);
true

# bad arguments
gap> INV_GF2MAT_SAME_MUTABILITY(fail);
Error, INV_GF2MAT_SAME_MUTABILITY: <mat> must be a GF2 matrix (not the value '\
fail')

#
# INV_GF2MAT_IMMUTABLE
#
gap> INV_GF2MAT_IMMUTABLE(Immutable(M2([[o]]))) = Immutable(M2([[o]]));
true

# bad arguments
gap> INV_GF2MAT_IMMUTABLE(fail);
Error, INV_GF2MAT_IMMUTABLE: <mat> must be a GF2 matrix (not the value 'fail')

#
# INV_PLIST_GF2VECS_DESTRUCTIVE
#
gap> m := [one];; INV_PLIST_GF2VECS_DESTRUCTIVE(m) = [one] and m = [one];
true

# bad arguments
gap> INV_PLIST_GF2VECS_DESTRUCTIVE(fail);
Error, INV_PLIST_GF2VECS_DESTRUCTIVE: <list> must be a plain list (not the val\
ue 'fail')

#
# SUM_GF2VEC_GF2VEC
#
gap> SUM_GF2VEC_GF2VEC(empty, empty);
<a GF2 vector of length 0>
gap> SUM_GF2VEC_GF2VEC(one, one);
<a GF2 vector of length 1>

# bad arguments
gap> SUM_GF2VEC_GF2VEC(fail, empty);
Error, SUM_GF2VEC_GF2VEC: <vl> must be a GF2 vector (not the value 'fail')
gap> SUM_GF2VEC_GF2VEC(empty, fail);
Error, SUM_GF2VEC_GF2VEC: <vr> must be a GF2 vector (not the value 'fail')

#
# PROD_GF2VEC_GF2VEC
#
gap> PROD_GF2VEC_GF2VEC(one, one);
Z(2)^0

# bad arguments
gap> PROD_GF2VEC_GF2VEC(fail, one);
Error, PROD_GF2VEC_GF2VEC: <vl> must be a GF2 vector (not the value 'fail')
gap> PROD_GF2VEC_GF2VEC(one, fail);
Error, PROD_GF2VEC_GF2VEC: <vr> must be a GF2 vector (not the value 'fail')

#
# PROD_GF2VEC_GF2MAT
#
gap> PROD_GF2VEC_GF2MAT(empty, Mx02(2));
<a GF2 vector of length 0>

# bad arguments
gap> PROD_GF2VEC_GF2MAT(fail, Mx02(2));
Error, PROD_GF2VEC_GF2MAT: <vl> must be a GF2 vector (not the value 'fail')
gap> PROD_GF2VEC_GF2MAT(empty, fail);
Error, PROD_GF2VEC_GF2MAT: <vr> must be a GF2 matrix (not the value 'fail')

#
# PROD_GF2MAT_GF2VEC
#
gap> PROD_GF2MAT_GF2VEC(Mx02(2), empty);
<a GF2 vector of length 2>

# bad arguments
gap> PROD_GF2MAT_GF2VEC(fail, empty);
Error, PROD_GF2MAT_GF2VEC: <vl> must be a GF2 matrix (not the value 'fail')
gap> PROD_GF2MAT_GF2VEC(Mx02(2), fail);
Error, PROD_GF2MAT_GF2VEC: <vr> must be a GF2 vector (not the value 'fail')

#
# PROD_GF2MAT_GF2MAT
#
gap> PROD_GF2MAT_GF2MAT(M2([[o], [z]]), Mx02(1)) = Mx02(2);
true

# bad arguments
gap> PROD_GF2MAT_GF2MAT(fail, Mx02(1));
Error, PROD_GF2MAT_GF2MAT: <ml> must be a GF2 matrix (not the value 'fail')
gap> PROD_GF2MAT_GF2MAT(M2([[o], [z]]), fail);
Error, PROD_GF2MAT_GF2MAT: <mr> must be a GF2 matrix (not the value 'fail')

#
# PROD_GF2MAT_GF2MAT_SIMPLE
#
gap> PROD_GF2MAT_GF2MAT_SIMPLE(M2([[o], [z]]), Mx02(1)) = Mx02(2);
true

# bad arguments
gap> PROD_GF2MAT_GF2MAT_SIMPLE(fail, Mx02(1));
Error, PROD_GF2MAT_GF2MAT_SIMPLE: <ml> must be a GF2 matrix (not the value 'fa\
il')
gap> PROD_GF2MAT_GF2MAT_SIMPLE(M2([[o], [z]]), fail);
Error, PROD_GF2MAT_GF2MAT_SIMPLE: <mr> must be a GF2 matrix (not the value 'fa\
il')

#
# PROD_GF2MAT_GF2MAT_ADVANCED
#
gap> PROD_GF2MAT_GF2MAT_ADVANCED(M2([[o]]), M2([[o]]), 1, 1) = M2([[o]]);
true

# bad arguments
gap> PROD_GF2MAT_GF2MAT_ADVANCED(fail, M2([[o]]), 1, 1);
Error, PROD_GF2MAT_GF2MAT_ADVANCED: <ml> must be a GF2 matrix (not the value '\
fail')
gap> PROD_GF2MAT_GF2MAT_ADVANCED(M2([[o]]), fail, 1, 1);
Error, PROD_GF2MAT_GF2MAT_ADVANCED: <mr> must be a GF2 matrix (not the value '\
fail')
gap> PROD_GF2MAT_GF2MAT_ADVANCED(M2([[o]]), M2([[o]]), fail, 1);
Error, PROD_GF2MAT_GF2MAT_ADVANCED: <greaselevel> must be a small integer (not\
 the value 'fail')
gap> PROD_GF2MAT_GF2MAT_ADVANCED(M2([[o]]), M2([[o]]), 1, fail);
Error, PROD_GF2MAT_GF2MAT_ADVANCED: <blocksize> must be a small integer (not t\
he value 'fail')

#
# ADDCOEFFS_GF2VEC_GF2VEC_MULT
#
gap> v := V2([]);; ADDCOEFFS_GF2VEC_GF2VEC_MULT(v, empty, z);
0
gap> v;
<a GF2 vector of length 0>

# bad arguments
gap> ADDCOEFFS_GF2VEC_GF2VEC_MULT(fail, empty, z);
Error, ADDCOEFFS_GF2VEC_GF2VEC_MULT: <vl> must be a GF2 vector (not the value \
'fail')
gap> ADDCOEFFS_GF2VEC_GF2VEC_MULT(v, fail, z);
Error, ADDCOEFFS_GF2VEC_GF2VEC_MULT: <vr> must be a GF2 vector (not the value \
'fail')
gap> ADDCOEFFS_GF2VEC_GF2VEC_MULT(v, empty, fail);
Error, ADDCOEFFS_GF2VEC_GF2VEC_MULT: <mul> must be a finite field element (not\
 the value 'fail')

#
# ADDCOEFFS_GF2VEC_GF2VEC
#
gap> v := V2([]);; ADDCOEFFS_GF2VEC_GF2VEC(v, empty);
0
gap> v;
<a GF2 vector of length 0>

# bad arguments
gap> ADDCOEFFS_GF2VEC_GF2VEC(fail, empty);
Error, ADDCOEFFS_GF2VEC_GF2VEC: <vl> must be a GF2 vector (not the value 'fail\
')
gap> ADDCOEFFS_GF2VEC_GF2VEC(v, fail);
Error, ADDCOEFFS_GF2VEC_GF2VEC: <vr> must be a GF2 vector (not the value 'fail\
')

#
# SHRINKCOEFFS_GF2VEC
#
gap> v := V2([o, z]);; SHRINKCOEFFS_GF2VEC(v);
1
gap> v;
<a GF2 vector of length 1>

# bad arguments
gap> SHRINKCOEFFS_GF2VEC(fail);
Error, SHRINKCOEFFS_GF2VEC: <vec> must be a GF2 vector (not the value 'fail')

#
# POSITION_NONZERO_GF2VEC
#
gap> POSITION_NONZERO_GF2VEC(empty, z);
1
gap> POSITION_NONZERO_GF2VEC(one, z);
1

# bad arguments
gap> POSITION_NONZERO_GF2VEC(fail, z);
Error, POSITION_NONZERO_GF2VEC: <vec> must be a GF2 vector (not the value 'fai\
l')
gap> POSITION_NONZERO_GF2VEC(empty, fail);
1

#
# POSITION_NONZERO_GF2VEC3
#
gap> POSITION_NONZERO_GF2VEC3(empty, z, 1);
1
gap> POSITION_NONZERO_GF2VEC3(V2([z, o]), z, 2);
3

# bad arguments
gap> POSITION_NONZERO_GF2VEC3(fail, z, 1);
Error, POSITION_NONZERO_GF2VEC3: <vec> must be a GF2 vector (not the value 'fa\
il')
gap> POSITION_NONZERO_GF2VEC3(empty, fail, 1);
1
gap> POSITION_NONZERO_GF2VEC3(empty, z, fail);
Error, POSITION_NONZERO_GF2VEC3: <from> must be a non-negative small integer (\
not the value 'fail')

#
# MULT_VECTOR_GF2VECS_2
#
gap> v := V2([o]);; MULT_VECTOR_GF2VECS_2(v, o);; v = one;
true

# bad arguments
gap> MULT_VECTOR_GF2VECS_2(fail, o);
Error, MULT_VECTOR_GF2VECS_2: <vl> must be a GF2 vector (not the value 'fail')
gap> MULT_VECTOR_GF2VECS_2(v, fail);
Error, MULT_VECTOR_GF2VECS_2: <mul> must be a finite field element (not the va\
lue 'fail')

#
# APPEND_GF2VEC
#
gap> v := V2([]);; APPEND_GF2VEC(v, one);; v = one;
true

# bad arguments
gap> APPEND_GF2VEC(fail, one);
Error, APPEND_GF2VEC: <vecl> must be a GF2 vector (not the value 'fail')
gap> APPEND_GF2VEC(v, fail);
Error, APPEND_GF2VEC: <vecr> must be a GF2 vector (not the value 'fail')

#
# SHALLOWCOPY_GF2VEC
#
gap> v := SHALLOWCOPY_GF2VEC(empty);; v = empty and not IsIdenticalObj(v, empty);
true

# bad arguments
gap> SHALLOWCOPY_GF2VEC(fail);
Error, SHALLOWCOPY_GF2VEC: <vec> must be a GF2 vector (not the value 'fail')

#
# NUMBER_GF2VEC
#
gap> NUMBER_GF2VEC(empty);
1
gap> NUMBER_GF2VEC(one);
1

# bad arguments
gap> NUMBER_GF2VEC(fail);
Error, NUMBER_GF2VEC: <vec> must be a GF2 vector (not the value 'fail')

#
# TRANSPOSED_GF2MAT
#
gap> TRANSPOSED_GF2MAT(Mx02(2));
Error, row index 1 exceeds 0, the number of rows

# bad arguments
gap> TRANSPOSED_GF2MAT(fail);
Error, TRANSPOSED_GF2MAT: <mat> must be a GF2 matrix (not the value 'fail')

#
# DIST_GF2VEC_GF2VEC
#
gap> DIST_GF2VEC_GF2VEC(empty, empty);
0
gap> DIST_GF2VEC_GF2VEC(one, one);
0

# bad arguments
gap> DIST_GF2VEC_GF2VEC(fail, empty);
Error, DIST_GF2VEC_GF2VEC: <vl> must be a GF2 vector (not the value 'fail')
gap> DIST_GF2VEC_GF2VEC(empty, fail);
Error, DIST_GF2VEC_GF2VEC: <vr> must be a GF2 vector (not the value 'fail')

#
# DIST_VEC_CLOS_VEC
#
gap> d := [0, 0];; DIST_VEC_CLOS_VEC(Veclis2([one]), oneZero, d);; d;
[ 1, 1 ]

# bad arguments
gap> DIST_VEC_CLOS_VEC(fail, oneZero, d);
Error, DIST_VEC_CLOS_VEC: <veclis> must be a plain list (not the value 'fail')
gap> DIST_VEC_CLOS_VEC(Veclis2([one]), fail, d);
Error, DIST_VEC_CLOS_VEC: <vec> must be a GF2 vector (not the value 'fail')
gap> DIST_VEC_CLOS_VEC(Veclis2([one]), oneZero, fail);
Error, DIST_VEC_CLOS_VEC: <d> must be a plain list (not the value 'fail')

#
# SUM_GF2MAT_GF2MAT
#
gap> SUM_GF2MAT_GF2MAT(Mx02(2), Mx02(2)) = Mx02(2);
true

# bad arguments
gap> SUM_GF2MAT_GF2MAT(fail, Mx02(2));
Error, SUM_GF2MAT_GF2MAT: <matl> must be a GF2 matrix (not the value 'fail')
gap> SUM_GF2MAT_GF2MAT(Mx02(2), fail);
Error, SUM_GF2MAT_GF2MAT: <matr> must be a GF2 matrix (not the value 'fail')

#
# A_CLOS_VEC
#
gap> A_CLOS_VEC(Veclis2([one]), one, 0, 0);
<a GF2 vector of length 1>

# bad arguments
gap> A_CLOS_VEC(fail, one, 0, 0);
Error, A_CLOS_VEC: <veclis> must be a plain list (not the value 'fail')
gap> A_CLOS_VEC(Veclis2([one]), fail, 0, 0);
Error, A_CLOS_VEC: <vec> must be a GF2 vector (not the value 'fail')
gap> A_CLOS_VEC(Veclis2([one]), one, fail, 0);
Error, A_CLOS_VEC: <cnt> must be a non-negative small integer (not the value '\
fail')
gap> A_CLOS_VEC(Veclis2([one]), one, 0, fail);
Error, A_CLOS_VEC: <stop> must be a non-negative small integer (not the value \
'fail')

#
# A_CLOS_VEC_COORDS
#
gap> A_CLOS_VEC_COORDS(Veclis2([one]), one, 0, 0);
[ <a GF2 vector of length 1>, [ 1 ] ]

# bad arguments
gap> A_CLOS_VEC_COORDS(fail, one, 0, 0);
Error, A_CLOS_VEC_COORDS: <veclis> must be a plain list (not the value 'fail')
gap> A_CLOS_VEC_COORDS(Veclis2([one]), fail, 0, 0);
Error, A_CLOS_VEC_COORDS: <vec> must be a GF2 vector (not the value 'fail')
gap> A_CLOS_VEC_COORDS(Veclis2([one]), one, fail, 0);
Error, A_CLOS_VEC_COORDS: <cnt> must be a non-negative small integer (not the \
value 'fail')
gap> A_CLOS_VEC_COORDS(Veclis2([one]), one, 0, fail);
Error, A_CLOS_VEC_COORDS: <stop> must be a non-negative small integer (not the\
 value 'fail')

#
# COSET_LEADERS_INNER_GF2
#
gap> leaders := [Immutable(oneZero)];; leaders[3] := false;;
gap> COSET_LEADERS_INNER_GF2(Veclis2([one]), 1, 1, leaders);
1
gap> leaders[2];
<an immutable GF2 vector of length 1>

# bad arguments
gap> COSET_LEADERS_INNER_GF2(fail, 1, 1, leaders);
Error, COSET_LEADERS_INNER_GF2: <veclis> must be a plain list (not the value '\
fail')
gap> COSET_LEADERS_INNER_GF2(Veclis2([one]), fail, 1, leaders);
Error, COSET_LEADERS_INNER_GF2: <weight> must be a small integer (not the valu\
e 'fail')
gap> COSET_LEADERS_INNER_GF2(Veclis2([one]), 1, fail, leaders);
Error, COSET_LEADERS_INNER_GF2: <tofind> must be a small integer (not the valu\
e 'fail')
gap> COSET_LEADERS_INNER_GF2(Veclis2([one]), 1, 1, fail);
Error, COSET_LEADERS_INNER_GF2: <leaders> must be a plain list (not the value \
'fail')

#
# CONV_GF2MAT
#
gap> m := [V2([]), V2([])];; CONV_GF2MAT(m);; m = Mx02(2);
true

# bad arguments
gap> CONV_GF2MAT(fail);
Error, CONV_GF2MAT: <list> must be a small list (not the value 'fail')

#
# PROD_GF2VEC_ANYMAT
#
gap> PROD_GF2VEC_ANYMAT(one, [fail]);
"TRY_NEXT_METHOD"
gap> PROD_GF2VEC_ANYMAT(one, [one]);
<a GF2 vector of length 1>

# bad arguments
gap> PROD_GF2VEC_ANYMAT(fail, [fail]);
Error, PROD_GF2VEC_ANYMAT: <vec> must be a GF2 vector (not the value 'fail')
gap> PROD_GF2VEC_ANYMAT(one, fail);
Error, PROD_GF2VEC_ANYMAT: <mat> must be a plain list (not the value 'fail')

#
# RIGHTMOST_NONZERO_GF2VEC
#
gap> RIGHTMOST_NONZERO_GF2VEC(empty);
0
gap> RIGHTMOST_NONZERO_GF2VEC(V2([z, o]));
2

# bad arguments
gap> RIGHTMOST_NONZERO_GF2VEC(fail);
Error, RIGHTMOST_NONZERO_GF2VEC: <vec> must be a GF2 vector (not the value 'fa\
il')

#
# RESIZE_GF2VEC
#
gap> v := V2([]);; RESIZE_GF2VEC(v, 2);; v = V2([z, z]);
true

# bad arguments
gap> RESIZE_GF2VEC(fail, 2);
Error, RESIZE_GF2VEC: <vec> must be a GF2 vector (not the value 'fail')
gap> RESIZE_GF2VEC(v, fail);
Error, RESIZE_GF2VEC: <newlen> must be a non-negative small integer (not the v\
alue 'fail')

#
# SHIFT_LEFT_GF2VEC
#
gap> v := V2([]);; SHIFT_LEFT_GF2VEC(v, 3);; v = empty;
true

# bad arguments
gap> SHIFT_LEFT_GF2VEC(fail, 3);
Error, SHIFT_LEFT_GF2VEC: <vec> must be a GF2 vector (not the value 'fail')
gap> SHIFT_LEFT_GF2VEC(v, fail);
Error, SHIFT_LEFT_GF2VEC: <amount> must be a non-negative small integer (not t\
he value 'fail')

#
# SHIFT_RIGHT_GF2VEC
#
gap> v := V2([]);; SHIFT_RIGHT_GF2VEC(v, 3, z);; v = V2([z, z, z]);
true

# bad arguments
gap> SHIFT_RIGHT_GF2VEC(fail, 3, z);
Error, SHIFT_RIGHT_GF2VEC: <vec> must be a GF2 vector (not the value 'fail')
gap> SHIFT_RIGHT_GF2VEC(v, fail, z);
Error, SHIFT_RIGHT_GF2VEC: <amount> must be a non-negative small integer (not \
the value 'fail')
gap> SHIFT_RIGHT_GF2VEC(v, 3, fail);
Error, SHIFT_RIGHT_GF2VEC: <zero> must be a finite field element (not the valu\
e 'fail')

#
# ADD_GF2VEC_GF2VEC_SHIFTED
#
gap> v := V2([]);; ADD_GF2VEC_GF2VEC_SHIFTED(v, one, 0, 1);; v = oneZero;
true

# bad arguments
gap> ADD_GF2VEC_GF2VEC_SHIFTED(fail, one, 0, 1);
Error, ADD_GF2VEC_GF2VEC_SHIFTED: <vec1> must be a GF2 vector (not the value '\
fail')
gap> ADD_GF2VEC_GF2VEC_SHIFTED(v, fail, 0, 1);
Error, ADD_GF2VEC_GF2VEC_SHIFTED: <vec2> must be a GF2 vector (not the value '\
fail')
gap> ADD_GF2VEC_GF2VEC_SHIFTED(v, one, fail, 1);
Error, ADD_GF2VEC_GF2VEC_SHIFTED: <len2> must be a non-negative small integer \
(not the value 'fail')
gap> ADD_GF2VEC_GF2VEC_SHIFTED(v, one, 0, fail);
Error, ADD_GF2VEC_GF2VEC_SHIFTED: <off> must be a non-negative small integer (\
not the value 'fail')

#
# PROD_COEFFS_GF2VEC
#
gap> PROD_COEFFS_GF2VEC(empty, 0, empty, 0);
<a GF2 vector of length 0>
gap> PROD_COEFFS_GF2VEC(one, 1, one, 1);
<a GF2 vector of length 1>

# bad arguments
gap> PROD_COEFFS_GF2VEC(fail, 0, empty, 0);
<a GF2 vector of length 0>
gap> PROD_COEFFS_GF2VEC(empty, fail, empty, 0);
Error, PROD_COEFFS_GF2VEC: <len1> must be a non-negative small integer (not th\
e value 'fail')
gap> PROD_COEFFS_GF2VEC(empty, 0, fail, 0);
<a GF2 vector of length 0>
gap> PROD_COEFFS_GF2VEC(empty, 0, empty, fail);
Error, PROD_COEFFS_GF2VEC: <len2> must be a non-negative small integer (not th\
e value 'fail')

#
# REDUCE_COEFFS_GF2VEC
#
gap> v := V2([o]);; w := V2([o, z]);;
gap> REDUCE_COEFFS_GF2VEC(v, 1, w, 1);
0
gap> v;
<a GF2 vector of length 0>

# bad arguments
gap> REDUCE_COEFFS_GF2VEC(fail, 1, w, 1);
Error, REDUCE_COEFFS_GF2VEC: <vec1> must be a GF2 vector (not the value 'fail'\
)
gap> REDUCE_COEFFS_GF2VEC(v, fail, w, 1);
Error, REDUCE_COEFFS_GF2VEC: <len1> must be a non-negative small integer (not \
the value 'fail')
gap> REDUCE_COEFFS_GF2VEC(v, 1, fail, 1);
Error, REDUCE_COEFFS_GF2VEC: <vec2> must be a GF2 vector (not the value 'fail'\
)
gap> REDUCE_COEFFS_GF2VEC(v, 1, w, fail);
Error, REDUCE_COEFFS_GF2VEC: <len2> must be a non-negative small integer (not \
the value 'fail')

#
# QUOTREM_COEFFS_GF2VEC
#
gap> QUOTREM_COEFFS_GF2VEC(empty, 0, w, 1);
[ <a GF2 vector of length 0>, <a GF2 vector of length 0> ]

# bad arguments
gap> QUOTREM_COEFFS_GF2VEC(fail, 0, w, 1);
Error, QUOTREM_COEFFS_GF2VEC: <vec1> must be a GF2 vector (not the value 'fail\
')
gap> QUOTREM_COEFFS_GF2VEC(empty, fail, w, 1);
Error, QUOTREM_COEFFS_GF2VEC: <len1> must be a non-negative small integer (not\
 the value 'fail')
gap> QUOTREM_COEFFS_GF2VEC(empty, 0, fail, 1);
Error, QUOTREM_COEFFS_GF2VEC: <vec2> must be a GF2 vector (not the value 'fail\
')
gap> QUOTREM_COEFFS_GF2VEC(empty, 0, w, fail);
Error, QUOTREM_COEFFS_GF2VEC: <len2> must be a non-negative small integer (not\
 the value 'fail')

#
# SEMIECHELON_LIST_GF2VECS
#
gap> s := SEMIECHELON_LIST_GF2VECS([one]);; s.heads = [1] and s.vectors = [one];
true

# bad arguments
gap> SEMIECHELON_LIST_GF2VECS(fail);
Error, SEMIECHELON_LIST_GF2VECS: <mat> must be a plain list (not the value 'fa\
il')

#
# SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS
#
gap> s := SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS([one]);;
gap> s.heads;
[ 1 ]
gap> s.vectors = [one];
true
gap> s.coeffs = [one];
true

# bad arguments
gap> SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS(fail);
Error, SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS: <mat> must be a plain list (n\
ot the value 'fail')

#
# TRIANGULIZE_LIST_GF2VECS
#
gap> m := [one];; TRIANGULIZE_LIST_GF2VECS(m);; m = [one];
true

# bad arguments
gap> TRIANGULIZE_LIST_GF2VECS(fail);
Error, TRIANGULIZE_LIST_GF2VECS: <mat> must be a plain list (not the value 'fa\
il')

#
# DETERMINANT_LIST_GF2VECS
#
gap> DETERMINANT_LIST_GF2VECS([one]);
Z(2)^0

# bad arguments
gap> DETERMINANT_LIST_GF2VECS(fail);
Error, DETERMINANT_LIST_GF2VECS: <mat> must be a plain list (not the value 'fa\
il')

#
# RANK_LIST_GF2VECS
#
gap> RANK_LIST_GF2VECS([one]);
1

# bad arguments
gap> RANK_LIST_GF2VECS(fail);
Error, RANK_LIST_GF2VECS: <mat> must be a plain list (not the value 'fail')

#
# KRONECKERPRODUCT_GF2MAT_GF2MAT
#
gap> KRONECKERPRODUCT_GF2MAT_GF2MAT(Mx02(2), M2([[o]])) = Mx02(2);
true

# bad arguments
gap> KRONECKERPRODUCT_GF2MAT_GF2MAT(fail, M2([[o]]));
Error, KRONECKERPRODUCT_GF2MAT_GF2MAT: <matl> must be a GF2 matrix (not the va\
lue 'fail')
gap> KRONECKERPRODUCT_GF2MAT_GF2MAT(Mx02(2), fail);
Error, KRONECKERPRODUCT_GF2MAT_GF2MAT: <matr> must be a GF2 matrix (not the va\
lue 'fail')

#
# COPY_SECTION_GF2VECS
#
gap> src := V2([o, o]);; dst := V2([z, z, z]);; COPY_SECTION_GF2VECS(src, dst, 1, 2, 2);; dst = V2([z, o, o]);
true

# bad arguments
gap> COPY_SECTION_GF2VECS(fail, dst, 1, 2, 2);
Error, COPY_SECTION_GF2VECS: <src> must be a GF2 vector (not the value 'fail')
gap> COPY_SECTION_GF2VECS(src, fail, 1, 2, 2);
Error, COPY_SECTION_GF2VECS: <dest> must be a GF2 vector (not the value 'fail'\
)
gap> COPY_SECTION_GF2VECS(src, dst, fail, 2, 2);
Error, COPY_SECTION_GF2VECS: <from> must be a positive small integer (not the \
value 'fail')
gap> COPY_SECTION_GF2VECS(src, dst, 1, fail, 2);
Error, COPY_SECTION_GF2VECS: <to> must be a positive small integer (not the va\
lue 'fail')
gap> COPY_SECTION_GF2VECS(src, dst, 1, 2, fail);
Error, COPY_SECTION_GF2VECS: <howmany> must be a small integer (not the value \
'fail')

#
# MAT_ELM_GF2MAT
#
gap> MAT_ELM_GF2MAT(M2([[o]]), 1, 1);
Z(2)^0

# bad arguments
gap> MAT_ELM_GF2MAT(fail, 1, 1);
Error, MAT_ELM_GF2MAT: <mat> must be a GF2 matrix (not the value 'fail')
gap> MAT_ELM_GF2MAT(M2([[o]]), fail, 1);
Error, MAT_ELM_GF2MAT: <row> must be a positive small integer (not the value '\
fail')
gap> MAT_ELM_GF2MAT(M2([[o]]), 1, fail);
Error, MAT_ELM_GF2MAT: <col> must be a positive small integer (not the value '\
fail')

#
# SET_MAT_ELM_GF2MAT
#
gap> m := M2([[z]]);; SET_MAT_ELM_GF2MAT(m, 1, 1, o);; m = M2([[o]]);
true

# bad arguments
gap> SET_MAT_ELM_GF2MAT(fail, 1, 1, o);
Error, SET_MAT_ELM_GF2MAT: <mat> must be a GF2 matrix (not the value 'fail')
gap> SET_MAT_ELM_GF2MAT(m, fail, 1, o);
Error, SET_MAT_ELM_GF2MAT: <row> must be a positive small integer (not the val\
ue 'fail')
gap> SET_MAT_ELM_GF2MAT(m, 1, fail, o);
Error, SET_MAT_ELM_GF2MAT: <col> must be a positive small integer (not the val\
ue 'fail')
gap> SET_MAT_ELM_GF2MAT(m, 1, 1, fail);
Error, SET_MAT_ELM_GF2MAT: assigned element must be a GF(2) element (not the v\
alue 'fail')

#
gap> STOP_TEST("kernel/vecgf2.tst");
