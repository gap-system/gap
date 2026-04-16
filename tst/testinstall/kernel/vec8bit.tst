#
# Tests for functions defined in src/vec8bit.c
#
gap> START_TEST("kernel/vec8bit.tst");
gap> q := 5;;
gap> z := 0*Z(q);;
gap> o := Z(q)^0;;
gap> t := Z(q);;
gap> V8 := function(list)
> local v;
>   v := ShallowCopy(list);
>   CONV_VEC8BIT(v, q);
>   return v;
> end;;
gap> M8 := function(rows)
> local m, i;
>   m := List(rows, ShallowCopy);
>   for i in [1 .. Length(m)] do
>     CONV_VEC8BIT(m[i], q);
>   od;
>   CONV_MAT8BIT(m, q);
>   return m;
> end;;
gap> IM8 := function(rows)
> local m;
>   m := M8(rows);
>   MakeImmutable(m);
>   return m;
> end;;
gap> ZeroRowMat8 := function()
> local m;
>   m := [];
>   CONV_MAT8BIT(m, q);
>   return m;
> end;;
gap> Mx08 := n -> M8(List([1 .. n], i -> []));;
gap> Veclis8 := function(rows)
> local f, fdi, fdip, veclis, row, mults, j, mult;
>   f := AsSSortedList(GF(q));
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
gap> empty := V8([]);;
gap> one := V8([o]);;
gap> oneZero := V8([z]);;
gap> pair := V8([o, t]);;
gap> pair2 := V8([t, o]);;
gap> f5 := AsSSortedList(GF(q));;

#
# CONV_VEC8BIT
#
gap> v := [];; CONV_VEC8BIT(v, q); v;
< mutable compressed vector length 0 over GF(5) >

# bad arguments
gap> CONV_VEC8BIT(fail, q);
Error, CONV_VEC8BIT: <list> must be a small list (not the value 'fail')
gap> CONV_VEC8BIT(v, fail);
Error, CONV_VEC8BIT: <q> must be a positive small integer (not the value 'fail\
')

#
# COPY_VEC8BIT
#
gap> v := [];; w := COPY_VEC8BIT(v, q); v;
< mutable compressed vector length 0 over GF(5) >
[  ]

# bad arguments
gap> COPY_VEC8BIT(fail, q);
Error, COPY_VEC8BIT: <list> must be a small list (not the value 'fail')
gap> COPY_VEC8BIT(v, fail);
Error, COPY_VEC8BIT: <q> must be a positive small integer (not the value 'fail\
')

#
# PLAIN_VEC8BIT
#
gap> v := V8([]);; PLAIN_VEC8BIT(v);; IsPlistRep(v); Length(v);
true
0

# bad arguments
gap> PLAIN_VEC8BIT(fail);
Error, PLAIN_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fa\
il')

#
# LEN_VEC8BIT
#
gap> LEN_VEC8BIT(empty);
0
gap> LEN_VEC8BIT(pair);
2

# bad arguments
gap> LEN_VEC8BIT(fail);
Error, LEN_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fail\
')

#
# ELM0_VEC8BIT
#
gap> ELM0_VEC8BIT(empty, 1);
fail
gap> ELM0_VEC8BIT(one, 1);
Z(5)^0

# bad arguments
gap> ELM0_VEC8BIT(fail, 1);
Error, ELM0_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fai\
l')
gap> ELM0_VEC8BIT(empty, fail);
Error, ELM0_VEC8BIT: <pos> must be a positive small integer (not the value 'fa\
il')

#
# ELM_VEC8BIT
#
gap> ELM_VEC8BIT(one, 1);
Z(5)^0

# bad arguments
gap> ELM_VEC8BIT(fail, 1);
Error, ELM_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fail\
')
gap> ELM_VEC8BIT(one, fail);
Error, ELM_VEC8BIT: <pos> must be a positive small integer (not the value 'fai\
l')

#
# ELMS_VEC8BIT
#
gap> ELMS_VEC8BIT(empty, []) = empty;
true
gap> ELMS_VEC8BIT(pair, [2]); # = V8([t]));
[ Z(5) ]

# bad arguments
gap> ELMS_VEC8BIT(fail, []);
Error, ELMS_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fai\
l')
gap> ELMS_VEC8BIT(empty, fail);
Error, ELMS_VEC8BIT: <poss> must be a plain list (not the value 'fail')

#
# ELMS_VEC8BIT_RANGE
#
gap> ELMS_VEC8BIT_RANGE(one, [1 .. 1]);
[ Z(5)^0 ]
gap> ELMS_VEC8BIT_RANGE(pair, [1 .. 2]) = pair;
true

# bad arguments
gap> ELMS_VEC8BIT_RANGE(fail, [1 .. 1]);
Error, ELMS_VEC8BIT_RANGE: <list> must belong to Is8BitVectorRep (not the valu\
e 'fail')
gap> ELMS_VEC8BIT_RANGE(one, fail);
Error, ELMS_VEC8BIT_RANGE: Range includes indices which are too high or too lo\
w

#
# ASS_VEC8BIT
#
gap> v := V8([]);; ASS_VEC8BIT(v, 1, z);; v = V8([z]);
true
gap> v := [Z(23), Z(23)];; ConvertToVectorRep(v);; ASS_VEC8BIT(v, 1, Z(23^5));;
gap> Is8BitVectorRep(v);
false
gap> v;
[ z, Z(23) ]

# bad arguments
gap> v := V8([z, z]);;
gap> ASS_VEC8BIT(fail, 1, z);
Error, ASS_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fail\
')
gap> ASS_VEC8BIT(v, fail, z);
Error, ASS_VEC8BIT: <pos> must be a positive small integer (not the value 'fai\
l')
gap> ASS_VEC8BIT(v, 1, fail);;
gap> IsPlistRep(v);
true
gap> v;
[ fail, 0*Z(5) ]

#
# UNB_VEC8BIT
#
gap> v := V8([o]);; UNB_VEC8BIT(v, 1);; v = empty;
true

# bad arguments
gap> UNB_VEC8BIT(fail, 1);
Error, UNB_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fail\
')
gap> UNB_VEC8BIT(v, fail);
Error, UNB_VEC8BIT: <pos> must be a positive small integer (not the value 'fai\
l')

#
# Q_VEC8BIT
#
gap> Q_VEC8BIT(empty);
5

# bad arguments
gap> Q_VEC8BIT(fail);
Error, Q_VEC8BIT: <list> must belong to Is8BitVectorRep (not the value 'fail')

#
# SHALLOWCOPY_VEC8BIT
#
gap> v := SHALLOWCOPY_VEC8BIT(empty);; v = empty and not IsIdenticalObj(v, empty);
true

# bad arguments
gap> SHALLOWCOPY_VEC8BIT(fail);
Error, SHALLOWCOPY_VEC8BIT: <list> must belong to Is8BitVectorRep (not the val\
ue 'fail')

#
# SUM_VEC8BIT_VEC8BIT
#
gap> SUM_VEC8BIT_VEC8BIT(empty, empty);
< mutable compressed vector length 0 over GF(5) >
gap> SUM_VEC8BIT_VEC8BIT(one, oneZero);
[ Z(5)^0 ]

# bad arguments
gap> SUM_VEC8BIT_VEC8BIT(fail, empty);
Error, SUM_VEC8BIT_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the value\
 'fail')
gap> SUM_VEC8BIT_VEC8BIT(empty, fail);
Error, SUM_VEC8BIT_VEC8BIT: <vr> must belong to Is8BitVectorRep (not the value\
 'fail')

#
# DIFF_VEC8BIT_VEC8BIT
#
gap> DIFF_VEC8BIT_VEC8BIT(empty, empty);
< mutable compressed vector length 0 over GF(5) >
gap> DIFF_VEC8BIT_VEC8BIT(one, oneZero);
[ Z(5)^0 ]

# bad arguments
gap> DIFF_VEC8BIT_VEC8BIT(fail, empty);
Error, DIFF_VEC8BIT_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the valu\
e 'fail')
gap> DIFF_VEC8BIT_VEC8BIT(empty, fail);
Error, DIFF_VEC8BIT_VEC8BIT: <vr> must belong to Is8BitVectorRep (not the valu\
e 'fail')

#
# PROD_VEC8BIT_FFE
#
gap> PROD_VEC8BIT_FFE(empty, o);
< mutable compressed vector length 0 over GF(5) >
gap> PROD_VEC8BIT_FFE(one, z);
[ 0*Z(5) ]

# bad arguments
gap> PROD_VEC8BIT_FFE(fail, o);
Error, PROD_VEC8BIT_FFE: <vec> must belong to Is8BitVectorRep (not the value '\
fail')
gap> PROD_VEC8BIT_FFE(empty, fail);
Error, PROD_VEC8BIT_FFE: <ffe> must be a finite field element (not the value '\
fail')

#
# PROD_FFE_VEC8BIT
#
gap> PROD_FFE_VEC8BIT(o, empty);
< mutable compressed vector length 0 over GF(5) >
gap> PROD_FFE_VEC8BIT(z, one);
[ 0*Z(5) ]

# bad arguments
gap> PROD_FFE_VEC8BIT(fail, empty);
Error, PROD_FFE_VEC8BIT: <ffe> must be a finite field element (not the value '\
fail')
gap> PROD_FFE_VEC8BIT(o, fail);
Error, PROD_FFE_VEC8BIT: <vec> must belong to Is8BitVectorRep (not the value '\
fail')

#
# AINV_VEC8BIT_MUTABLE
#
gap> AINV_VEC8BIT_MUTABLE(empty);
< mutable compressed vector length 0 over GF(5) >
gap> AINV_VEC8BIT_MUTABLE(oneZero);
[ 0*Z(5) ]

# bad arguments
gap> AINV_VEC8BIT_MUTABLE(fail);
Error, AINV_VEC8BIT_MUTABLE: <vec> must belong to Is8BitVectorRep (not the val\
ue 'fail')

#
# AINV_VEC8BIT_IMMUTABLE
#
gap> AINV_VEC8BIT_IMMUTABLE(empty);
< immutable compressed vector length 0 over GF(5) >
gap> AINV_VEC8BIT_IMMUTABLE(oneZero);
[ 0*Z(5) ]

# bad arguments
gap> AINV_VEC8BIT_IMMUTABLE(fail);
Error, AINV_VEC8BIT_IMMUTABLE: <vec> must belong to Is8BitVectorRep (not the v\
alue 'fail')

#
# AINV_VEC8BIT_SAME_MUTABILITY
#
gap> AINV_VEC8BIT_SAME_MUTABILITY(empty);
< mutable compressed vector length 0 over GF(5) >
gap> AINV_VEC8BIT_SAME_MUTABILITY(oneZero);
[ 0*Z(5) ]

# bad arguments
gap> AINV_VEC8BIT_SAME_MUTABILITY(fail);
Error, AINV_VEC8BIT_SAME_MUTABILITY: <vec> must belong to Is8BitVectorRep (not\
 the value 'fail')

#
# ZERO_VEC8BIT
#
gap> ZERO_VEC8BIT(empty);
< mutable compressed vector length 0 over GF(5) >
gap> ZERO_VEC8BIT(pair);
[ 0*Z(5), 0*Z(5) ]

# bad arguments
gap> ZERO_VEC8BIT(fail);
Error, ZERO_VEC8BIT: <vec> must belong to Is8BitVectorRep (not the value 'fail\
')

#
# ZERO_VEC8BIT_2
#
gap> ZERO_VEC8BIT_2(q, 0);
< mutable compressed vector length 0 over GF(5) >
gap> ZERO_VEC8BIT_2(q, 2);
[ 0*Z(5), 0*Z(5) ]

# bad arguments
gap> ZERO_VEC8BIT_2(fail, 0);
Error, ZERO_VEC8BIT_2: <q> must be a positive small integer (not the value 'fa\
il')
gap> ZERO_VEC8BIT_2(q, fail);
Error, ZERO_VEC8BIT_2: <len> must be a non-negative small integer (not the val\
ue 'fail')

#
# EQ_VEC8BIT_VEC8BIT
#
gap> EQ_VEC8BIT_VEC8BIT(empty, empty);
true
gap> EQ_VEC8BIT_VEC8BIT(empty, one);
false

# bad arguments
gap> EQ_VEC8BIT_VEC8BIT(fail, empty);
Error, EQ_VEC8BIT_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the value \
'fail')
gap> EQ_VEC8BIT_VEC8BIT(empty, fail);
Error, EQ_VEC8BIT_VEC8BIT: <vr> must belong to Is8BitVectorRep (not the value \
'fail')

#
# LT_VEC8BIT_VEC8BIT
#
gap> LT_VEC8BIT_VEC8BIT(empty, one);
true
gap> LT_VEC8BIT_VEC8BIT(one, empty);
false

# bad arguments
gap> LT_VEC8BIT_VEC8BIT(fail, one);
Error, LT_VEC8BIT_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the value \
'fail')
gap> LT_VEC8BIT_VEC8BIT(empty, fail);
Error, LT_VEC8BIT_VEC8BIT: <vr> must belong to Is8BitVectorRep (not the value \
'fail')

#
# PROD_VEC8BIT_VEC8BIT
#
gap> PROD_VEC8BIT_VEC8BIT(empty, empty);
0*Z(5)
gap> PROD_VEC8BIT_VEC8BIT(one, one);
Z(5)^0

# bad arguments
gap> PROD_VEC8BIT_VEC8BIT(fail, empty);
Error, PROD_VEC8BIT_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the valu\
e 'fail')
gap> PROD_VEC8BIT_VEC8BIT(empty, fail);
Error, PROD_VEC8BIT_VEC8BIT: <vr> must belong to Is8BitVectorRep (not the valu\
e 'fail')

#
# DISTANCE_VEC8BIT_VEC8BIT
#
gap> DISTANCE_VEC8BIT_VEC8BIT(empty, empty);
0
gap> DISTANCE_VEC8BIT_VEC8BIT(one, oneZero);
1

# bad arguments
gap> DISTANCE_VEC8BIT_VEC8BIT(fail, empty);
Error, DISTANCE_VEC8BIT_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the \
value 'fail')
gap> DISTANCE_VEC8BIT_VEC8BIT(empty, fail);
Error, DISTANCE_VEC8BIT_VEC8BIT: <vr> must belong to Is8BitVectorRep (not the \
value 'fail')

#
# ADD_ROWVECTOR_VEC8BITS_5
#
gap> v := V8([o, z]);; ADD_ROWVECTOR_VEC8BITS_5(v, V8([z, o]), o, 2, 2);; v = V8([o, o]);
true

# bad arguments
gap> ADD_ROWVECTOR_VEC8BITS_5(fail, V8([z, o]), o, 2, 2);
Error, ADD_ROWVECTOR_VEC8BITS_5: <vl> must belong to Is8BitVectorRep (not the \
value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_5(v, fail, o, 2, 2);
Error, ADD_ROWVECTOR_VEC8BITS_5: <vr> must belong to Is8BitVectorRep (not the \
value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_5(v, V8([z, o]), fail, 2, 2);
Error, ADD_ROWVECTOR_VEC8BITS_5: <mul> must be a finite field element (not the\
 value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_5(v, V8([z, o]), o, fail, 2);
Error, ADD_ROWVECTOR_VEC8BITS_5: <from> must be a positive small integer (not \
the value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_5(v, V8([z, o]), o, 2, fail);
Error, ADD_ROWVECTOR_VEC8BITS_5: <to> must be a positive small integer (not th\
e value 'fail')

#
# ADD_ROWVECTOR_VEC8BITS_3
#
gap> v := V8([]);; ADD_ROWVECTOR_VEC8BITS_3(v, empty, o);; v = empty;
true

# bad arguments
gap> ADD_ROWVECTOR_VEC8BITS_3(fail, empty, o);
Error, ADD_ROWVECTOR_VEC8BITS_3: <vl> must belong to Is8BitVectorRep (not the \
value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_3(v, fail, o);
Error, ADD_ROWVECTOR_VEC8BITS_3: <vr> must belong to Is8BitVectorRep (not the \
value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_3(v, empty, fail);
Error, ADD_ROWVECTOR_VEC8BITS_3: <mul> must be a finite field element (not the\
 value 'fail')

#
# ADD_ROWVECTOR_VEC8BITS_2
#
gap> v := V8([]);; ADD_ROWVECTOR_VEC8BITS_2(v, empty);; v = empty;
true

# bad arguments
gap> ADD_ROWVECTOR_VEC8BITS_2(fail, empty);
Error, ADD_ROWVECTOR_VEC8BITS_2: <vl> must belong to Is8BitVectorRep (not the \
value 'fail')
gap> ADD_ROWVECTOR_VEC8BITS_2(v, fail);
Error, ADD_ROWVECTOR_VEC8BITS_2: <vr> must belong to Is8BitVectorRep (not the \
value 'fail')

#
# MULT_VECTOR_VEC8BITS
#
gap> v := V8([]);; MULT_VECTOR_VEC8BITS(v, o);; v = empty;
true

# bad arguments
gap> MULT_VECTOR_VEC8BITS(fail, o);
Error, MULT_VECTOR_VEC8BITS: <vec> must belong to Is8BitVectorRep (not the val\
ue 'fail')
gap> MULT_VECTOR_VEC8BITS(v, fail);
Error, MULT_VECTOR_VEC8BITS: <mul> must be a finite field element (not the val\
ue 'fail')

#
# POSITION_NONZERO_VEC8BIT
#
gap> POSITION_NONZERO_VEC8BIT(empty, z);
1
gap> POSITION_NONZERO_VEC8BIT(one, z);
1

# bad arguments
gap> POSITION_NONZERO_VEC8BIT(fail, z);
Error, POSITION_NONZERO_VEC8BIT: <list> must belong to Is8BitVectorRep (not th\
e value 'fail')
gap> POSITION_NONZERO_VEC8BIT(empty, fail);
1

#
# POSITION_NONZERO_VEC8BIT3
#
gap> POSITION_NONZERO_VEC8BIT3(empty, z, 1);
1
gap> POSITION_NONZERO_VEC8BIT3(V8([z, o]), z, 2);
3

# bad arguments
gap> POSITION_NONZERO_VEC8BIT3(fail, z, 1);
Error, POSITION_NONZERO_VEC8BIT3: <list> must belong to Is8BitVectorRep (not t\
he value 'fail')
gap> POSITION_NONZERO_VEC8BIT3(empty, fail, 1);
1
gap> POSITION_NONZERO_VEC8BIT3(empty, z, fail);
Error, POSITION_NONZERO_VEC8BIT3: <from> must be a non-negative small integer \
(not the value 'fail')

#
# APPEND_VEC8BIT
#
gap> v := V8([]);; APPEND_VEC8BIT(v, one);; v = one;
true

# bad arguments
gap> APPEND_VEC8BIT(fail, one);
Error, APPEND_VEC8BIT: <vecl> must belong to Is8BitVectorRep (not the value 'f\
ail')
gap> APPEND_VEC8BIT(v, fail);
Error, APPEND_VEC8BIT: <vecr> must belong to Is8BitVectorRep (not the value 'f\
ail')

#
# NUMBER_VEC8BIT
#
gap> NUMBER_VEC8BIT(empty);
1
gap> NUMBER_VEC8BIT(one);
1

# bad arguments
gap> NUMBER_VEC8BIT(fail);
Error, NUMBER_VEC8BIT: <vec> must belong to Is8BitVectorRep (not the value 'fa\
il')

#
# PROD_VEC8BIT_MATRIX
#
gap> PROD_VEC8BIT_MATRIX(one, [fail]);
"TRY_NEXT_METHOD"
gap> PROD_VEC8BIT_MATRIX(one, [one]);
[ Z(5)^0 ]

# bad arguments
gap> PROD_VEC8BIT_MATRIX(fail, [fail]);
Error, PROD_VEC8BIT_MATRIX: <vec> must belong to Is8BitVectorRep (not the valu\
e 'fail')
gap> PROD_VEC8BIT_MATRIX(one, fail);
Error, PROD_VEC8BIT_MATRIX: <mat> must be a plain list (not the value 'fail')

#
# CONV_MAT8BIT
#
gap> m := [V8([]), V8([])];; CONV_MAT8BIT(m, q);; EQ_MAT8BIT_MAT8BIT(m, Mx08(2));
true

# bad arguments
gap> CONV_MAT8BIT(fail, q);
Error, CONV_MAT8BIT: <list> must be a plain list (not the value 'fail')
gap> CONV_MAT8BIT(m, fail);
Error, CONV_MAT8BIT: <list> must be a plain list (not a positional object)

#
# PLAIN_MAT8BIT
#
gap> m := Mx08(2);; PLAIN_MAT8BIT(m);; IsPlistRep(m) and m = [[], []];
true

# bad arguments
gap> PLAIN_MAT8BIT(fail);
Error, PLAIN_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value 'fai\
l')

#
# PROD_VEC8BIT_MAT8BIT
#
gap> PROD_VEC8BIT_MAT8BIT(empty, ZeroRowMat8());
Error, PROD_VEC8BIT_MAT8BIT: compressed 8bit matrices with empty rows are not \
supported
gap> PROD_VEC8BIT_MAT8BIT(empty, Mx08(2));
< mutable compressed vector length 0 over GF(5) >

# bad arguments
gap> PROD_VEC8BIT_MAT8BIT(fail, ZeroRowMat8());
Error, PROD_VEC8BIT_MAT8BIT: <vec> must belong to Is8BitVectorRep (not the val\
ue 'fail')
gap> PROD_VEC8BIT_MAT8BIT(empty, fail);
Error, PROD_VEC8BIT_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the val\
ue 'fail')

#
# PROD_MAT8BIT_VEC8BIT
#
gap> PROD_MAT8BIT_VEC8BIT(ZeroRowMat8(), empty);
Error, PROD_MAT8BIT_VEC8BIT: compressed 8bit matrices with empty rows are not \
supported
gap> PROD_MAT8BIT_VEC8BIT(Mx08(2), empty);
[ 0*Z(5), 0*Z(5) ]

# bad arguments
gap> PROD_MAT8BIT_VEC8BIT(fail, empty);
Error, PROD_MAT8BIT_VEC8BIT: <mat> must belong to Is8BitMatrixRep (not the val\
ue 'fail')
gap> PROD_MAT8BIT_VEC8BIT(ZeroRowMat8(), fail);
Error, PROD_MAT8BIT_VEC8BIT: <vec> must belong to Is8BitVectorRep (not the val\
ue 'fail')

#
# PROD_MAT8BIT_MAT8BIT
#
gap> PROD_MAT8BIT_MAT8BIT(ZeroRowMat8(), ZeroRowMat8());
Error, PROD_MAT8BIT_MAT8BIT: compressed 8bit matrices with empty rows are not \
supported
gap> PROD_MAT8BIT_MAT8BIT(M8([[o], [z]]), Mx08(1)) = Mx08(2);
true

# bad arguments
gap> PROD_MAT8BIT_MAT8BIT(fail, ZeroRowMat8());
Error, PROD_MAT8BIT_MAT8BIT: <matl> must belong to Is8BitMatrixRep (not the va\
lue 'fail')
gap> PROD_MAT8BIT_MAT8BIT(ZeroRowMat8(), fail);
Error, PROD_MAT8BIT_MAT8BIT: <matr> must belong to Is8BitMatrixRep (not the va\
lue 'fail')

#
# INV_MAT8BIT_MUTABLE
#
gap> INV_MAT8BIT_MUTABLE(ZeroRowMat8());
Error, INV_MAT8BIT_MUTABLE: compressed 8bit matrices with empty rows are not s\
upported
gap> INV_MAT8BIT_MUTABLE(M8([[o]])) = M8([[o]]);
true

# bad arguments
gap> INV_MAT8BIT_MUTABLE(fail);
Error, INV_MAT8BIT_MUTABLE: <mat> must belong to Is8BitMatrixRep (not the valu\
e 'fail')

#
# INV_MAT8BIT_SAME_MUTABILITY
#
gap> INV_MAT8BIT_SAME_MUTABILITY(ZeroRowMat8());
Error, INV_MAT8BIT_SAME_MUTABILITY: compressed 8bit matrices with empty rows a\
re not supported
gap> INV_MAT8BIT_SAME_MUTABILITY(M8([[o]])) = M8([[o]]);
true

# bad arguments
gap> INV_MAT8BIT_SAME_MUTABILITY(fail);
Error, INV_MAT8BIT_SAME_MUTABILITY: <mat> must belong to Is8BitMatrixRep (not \
the value 'fail')

#
# INV_MAT8BIT_IMMUTABLE
#
gap> INV_MAT8BIT_IMMUTABLE(ZeroRowMat8());
Error, INV_MAT8BIT_IMMUTABLE: compressed 8bit matrices with empty rows are not\
 supported
gap> INV_MAT8BIT_IMMUTABLE(IM8([[o]])) = IM8([[o]]);
true

# bad arguments
gap> INV_MAT8BIT_IMMUTABLE(fail);
Error, INV_MAT8BIT_IMMUTABLE: <mat> must belong to Is8BitMatrixRep (not the va\
lue 'fail')

#
# ASS_MAT8BIT
#
gap> ASS_MAT8BIT(ZeroRowMat8(), 1, empty);
Error, ASS_MAT8BIT: compressed 8bit matrices with empty rows are not supported
gap> m := Mx08(1);; ASS_MAT8BIT(m, 2, empty);; m = Mx08(2);
true

# bad arguments
gap> ASS_MAT8BIT(fail, 1, empty);
Error, ASS_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value 'fail'\
)
gap> ASS_MAT8BIT(ZeroRowMat8(), fail, empty);
Error, ASS_MAT8BIT: compressed 8bit matrices with empty rows are not supported
gap> ASS_MAT8BIT(ZeroRowMat8(), 1, fail);
Error, ASS_MAT8BIT: compressed 8bit matrices with empty rows are not supported

#
# ELM_MAT8BIT
#
gap> ELM_MAT8BIT(Mx08(2), 1);
< mutable compressed vector length 0 over GF(5) >

# bad arguments
gap> ELM_MAT8BIT(fail, 1);
Error, ELM_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value 'fail'\
)
gap> ELM_MAT8BIT(Mx08(2), fail);
Error, ELM_MAT8BIT: <pos> must be a positive small integer (not the value 'fai\
l')

#
# SWAP_ROWS_MAT8BIT
#
gap> m := Mx08(2);; SWAP_ROWS_MAT8BIT(m, 1, 2);; m = Mx08(2);
true

# bad arguments
gap> SWAP_ROWS_MAT8BIT(fail, 1, 2);
Error, SWAP_ROWS_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value \
'fail')
gap> SWAP_ROWS_MAT8BIT(m, fail, 2);
Error, SWAP_ROWS_MAT8BIT: <row1> must be a small integer (not the value 'fail'\
)
gap> SWAP_ROWS_MAT8BIT(m, 1, fail);
Error, SWAP_ROWS_MAT8BIT: <row2> must be a small integer (not the value 'fail'\
)

#
# SWAP_COLS_MAT8BIT
#
gap> m := ZeroRowMat8();; SWAP_COLS_MAT8BIT(m, 1, 1);; EQ_MAT8BIT_MAT8BIT(m, ZeroRowMat8());
true

# bad arguments
gap> SWAP_COLS_MAT8BIT(fail, 1, 1);
Error, SWAP_COLS_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value \
'fail')
gap> SWAP_COLS_MAT8BIT(m, fail, 1);
Error, SWAP_COLS_MAT8BIT: <col1> must be a small integer (not the value 'fail'\
)
gap> SWAP_COLS_MAT8BIT(m, 1, fail);
Error, SWAP_COLS_MAT8BIT: <col2> must be a small integer (not the value 'fail'\
)

#
# SUM_MAT8BIT_MAT8BIT
#
gap> SUM_MAT8BIT_MAT8BIT(ZeroRowMat8(), ZeroRowMat8());
Error, SUM_MAT8BIT_MAT8BIT: compressed 8bit matrices with empty rows are not s\
upported
gap> SUM_MAT8BIT_MAT8BIT(Mx08(2), Mx08(2)) = Mx08(2);
true

# bad arguments
gap> SUM_MAT8BIT_MAT8BIT(fail, ZeroRowMat8());
Error, SUM_MAT8BIT_MAT8BIT: <ml> must belong to Is8BitMatrixRep (not the value\
 'fail')
gap> SUM_MAT8BIT_MAT8BIT(ZeroRowMat8(), fail);
Error, SUM_MAT8BIT_MAT8BIT: <mr> must belong to Is8BitMatrixRep (not the value\
 'fail')

#
# DIFF_MAT8BIT_MAT8BIT
#
gap> DIFF_MAT8BIT_MAT8BIT(ZeroRowMat8(), ZeroRowMat8());
Error, DIFF_MAT8BIT_MAT8BIT: compressed 8bit matrices with empty rows are not \
supported
gap> DIFF_MAT8BIT_MAT8BIT(Mx08(2), Mx08(2)) = Mx08(2);
true

# bad arguments
gap> DIFF_MAT8BIT_MAT8BIT(fail, ZeroRowMat8());
Error, DIFF_MAT8BIT_MAT8BIT: <ml> must belong to Is8BitMatrixRep (not the valu\
e 'fail')
gap> DIFF_MAT8BIT_MAT8BIT(ZeroRowMat8(), fail);
Error, DIFF_MAT8BIT_MAT8BIT: <mr> must belong to Is8BitMatrixRep (not the valu\
e 'fail')

#
# ADD_COEFFS_VEC8BIT_3
#
gap> v := V8([]);; ADD_COEFFS_VEC8BIT_3(v, empty, o);
0
gap> v;
< mutable compressed vector length 0 over GF(5) >

# bad arguments
gap> ADD_COEFFS_VEC8BIT_3(fail, empty, o);
Error, ADD_COEFFS_VEC8BIT_3: <vec1> must belong to Is8BitVectorRep (not the va\
lue 'fail')
gap> ADD_COEFFS_VEC8BIT_3(v, fail, o);
Error, ADD_COEFFS_VEC8BIT_3: <vec2> must belong to Is8BitVectorRep (not the va\
lue 'fail')
gap> ADD_COEFFS_VEC8BIT_3(v, empty, fail);
0

#
# ADD_COEFFS_VEC8BIT_2
#
gap> v := V8([]);; ADD_COEFFS_VEC8BIT_2(v, empty);
0
gap> v;
< mutable compressed vector length 0 over GF(5) >

# bad arguments
gap> ADD_COEFFS_VEC8BIT_2(fail, empty);
Error, ADD_COEFFS_VEC8BIT_2: <vec1> must belong to Is8BitVectorRep (not the va\
lue 'fail')
gap> ADD_COEFFS_VEC8BIT_2(v, fail);
Error, ADD_COEFFS_VEC8BIT_2: <vec2> must belong to Is8BitVectorRep (not the va\
lue 'fail')

#
# SHIFT_VEC8BIT_LEFT
#
gap> v := V8([]);; SHIFT_VEC8BIT_LEFT(v, 3);; v = empty;
true

# bad arguments
gap> SHIFT_VEC8BIT_LEFT(fail, 3);
Error, SHIFT_VEC8BIT_LEFT: <vec> must belong to Is8BitVectorRep (not the value\
 'fail')
gap> SHIFT_VEC8BIT_LEFT(v, fail);
Error, SHIFT_VEC8BIT_LEFT: <amount> must be a non-negative small integer (not \
the value 'fail')

#
# SHIFT_VEC8BIT_RIGHT
#
gap> v := V8([]);; SHIFT_VEC8BIT_RIGHT(v, 3, z);; v = V8([z, z, z]);
true

# bad arguments
gap> SHIFT_VEC8BIT_RIGHT(fail, 3, z);
Error, SHIFT_VEC8BIT_RIGHT: <vec> must belong to Is8BitVectorRep (not the valu\
e 'fail')
gap> SHIFT_VEC8BIT_RIGHT(v, fail, z);
Error, SHIFT_VEC8BIT_RIGHT: <amount> must be a non-negative small integer (not\
 the value 'fail')
gap> SHIFT_VEC8BIT_RIGHT(v, 3, fail);
Error, SHIFT_VEC8BIT_RIGHT: <zero> must be a finite field element (not the val\
ue 'fail')

#
# RESIZE_VEC8BIT
#
gap> v := V8([]);; RESIZE_VEC8BIT(v, 2);; v = V8([z, z]);
true

# bad arguments
gap> RESIZE_VEC8BIT(fail, 2);
Error, RESIZE_VEC8BIT: <vec> must belong to Is8BitVectorRep (not the value 'fa\
il')
gap> RESIZE_VEC8BIT(v, fail);
Error, RESIZE_VEC8BIT: <newsize> must be a non-negative small integer (not the\
 value 'fail')

#
# RIGHTMOST_NONZERO_VEC8BIT
#
gap> RIGHTMOST_NONZERO_VEC8BIT(empty);
0
gap> RIGHTMOST_NONZERO_VEC8BIT(V8([z, o]));
2

# bad arguments
gap> RIGHTMOST_NONZERO_VEC8BIT(fail);
Error, RIGHTMOST_NONZERO_VEC8BIT: <vec> must belong to Is8BitVectorRep (not th\
e value 'fail')

#
# PROD_COEFFS_VEC8BIT
#
gap> PROD_COEFFS_VEC8BIT(empty, 0, empty, 0);
< mutable compressed vector length 0 over GF(5) >
gap> PROD_COEFFS_VEC8BIT(one, 1, one, 1);
[ Z(5)^0 ]

# bad arguments
gap> PROD_COEFFS_VEC8BIT(fail, 0, empty, 0);
"TRY_NEXT_METHOD"
gap> PROD_COEFFS_VEC8BIT(empty, fail, empty, 0);
Error, PROD_COEFFS_VEC8BIT: <ll> must be a non-negative small integer (not the\
 value 'fail')
gap> PROD_COEFFS_VEC8BIT(empty, 0, fail, 0);
Error, Cannot convert a vector compressed over GF(17) to small field GF(5)
gap> PROD_COEFFS_VEC8BIT(empty, 0, empty, fail);
Error, PROD_COEFFS_VEC8BIT: <lr> must be a non-negative small integer (not the\
 value 'fail')

#
# REDUCE_COEFFS_VEC8BIT
#
gap> s := MAKE_SHIFTED_COEFFS_VEC8BIT(V8([o]), 1);;
gap> v := V8([o]);; REDUCE_COEFFS_VEC8BIT(v, 1, s);
0
gap> v;
< mutable compressed vector length 0 over GF(5) >

# bad arguments
gap> REDUCE_COEFFS_VEC8BIT(fail, 1, s);
Error, REDUCE_COEFFS_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the val\
ue 'fail')
gap> REDUCE_COEFFS_VEC8BIT(v, fail, s);
Error, REDUCE_COEFFS_VEC8BIT: <ll> must be a non-negative small integer (not t\
he value 'fail')
gap> REDUCE_COEFFS_VEC8BIT(v, 1, fail);
fail

#
# QUOTREM_COEFFS_VEC8BIT
#
gap> s := MAKE_SHIFTED_COEFFS_VEC8BIT(V8([o]), 1);;
gap> QUOTREM_COEFFS_VEC8BIT(empty, 0, s);
[ < mutable compressed vector length 0 over GF(5) >, 
  < mutable compressed vector length 0 over GF(5) > ]

# bad arguments
gap> QUOTREM_COEFFS_VEC8BIT(fail, 0, s);
Error, QUOTREM_COEFFS_VEC8BIT: <vl> must belong to Is8BitVectorRep (not the va\
lue 'fail')
gap> QUOTREM_COEFFS_VEC8BIT(empty, fail, s);
Error, QUOTREM_COEFFS_VEC8BIT: <ll> must be a non-negative small integer (not \
the value 'fail')
gap> QUOTREM_COEFFS_VEC8BIT(empty, 0, fail);
Error, QUOTREM_COEFFS_VEC8BIT: <vrshifted> must be a plain list (not the value\
 'fail')

#
# MAKE_SHIFTED_COEFFS_VEC8BIT
#
gap> s := MAKE_SHIFTED_COEFFS_VEC8BIT(V8([o]), 1);; s[4];
1
gap> s[5];
Z(5)^0

# bad arguments
gap> MAKE_SHIFTED_COEFFS_VEC8BIT(fail, 1);
Error, MAKE_SHIFTED_COEFFS_VEC8BIT: <vr> must belong to Is8BitVectorRep (not t\
he value 'fail')
gap> MAKE_SHIFTED_COEFFS_VEC8BIT(V8([o]), fail);
Error, MAKE_SHIFTED_COEFFS_VEC8BIT: <lr> must be a non-negative small integer \
(not the value 'fail')

#
# DISTANCE_DISTRIB_VEC8BITS
#
gap> d := [0, 0];; DISTANCE_DISTRIB_VEC8BITS(Veclis8([one]), oneZero, d);; d;
[ 1, 4 ]

# bad arguments
gap> DISTANCE_DISTRIB_VEC8BITS(fail, oneZero, d);
Error, DISTANCE_DISTRIB_VEC8BITS: <veclis> must be a plain list (not the value\
 'fail')
gap> DISTANCE_DISTRIB_VEC8BITS(Veclis8([one]), fail, d);
Error, DISTANCE_DISTRIB_VEC8BITS: <vec> must belong to Is8BitVectorRep (not th\
e value 'fail')
gap> DISTANCE_DISTRIB_VEC8BITS(Veclis8([one]), oneZero, fail);
Error, DISTANCE_DISTRIB_VEC8BITS: <d> must be a plain list (not the value 'fai\
l')

#
# A_CLOSEST_VEC8BIT
#
gap> A_CLOSEST_VEC8BIT(Veclis8([one]), one, 0, 0);
[ Z(5)^0 ]

# bad arguments
gap> A_CLOSEST_VEC8BIT(fail, one, 0, 0);
Error, A_CLOSEST_VEC8BIT: <veclis> must be a plain list (not the value 'fail')
gap> A_CLOSEST_VEC8BIT(Veclis8([one]), fail, 0, 0);
Error, A_CLOSEST_VEC8BIT: <vec> must belong to Is8BitVectorRep (not the value \
'fail')
gap> A_CLOSEST_VEC8BIT(Veclis8([one]), one, fail, 0);
Error, A_CLOSEST_VEC8BIT: <cnt> must be a non-negative small integer (not the \
value 'fail')
gap> A_CLOSEST_VEC8BIT(Veclis8([one]), one, 0, fail);
Error, A_CLOSEST_VEC8BIT: <stop> must be a non-negative small integer (not the\
 value 'fail')

#
# A_CLOSEST_VEC8BIT_COORDS
#
gap> A_CLOSEST_VEC8BIT_COORDS(Veclis8([one]), one, 0, 0);
[ [ Z(5)^0 ], [ 1 ] ]

# bad arguments
gap> A_CLOSEST_VEC8BIT_COORDS(fail, one, 0, 0);
Error, A_CLOSEST_VEC8BIT_COORDS: <veclis> must be a plain list (not the value \
'fail')
gap> A_CLOSEST_VEC8BIT_COORDS(Veclis8([one]), fail, 0, 0);
Error, A_CLOSEST_VEC8BIT_COORDS: <vec> must belong to Is8BitVectorRep (not the\
 value 'fail')
gap> A_CLOSEST_VEC8BIT_COORDS(Veclis8([one]), one, fail, 0);
Error, A_CLOSEST_VEC8BIT_COORDS: <cnt> must be a non-negative small integer (n\
ot the value 'fail')
gap> A_CLOSEST_VEC8BIT_COORDS(Veclis8([one]), one, 0, fail);
Error, A_CLOSEST_VEC8BIT_COORDS: <stop> must be a non-negative small integer (\
not the value 'fail')

#
# COSET_LEADERS_INNER_8BITS
#
gap> leaders := [Immutable(oneZero)];; leaders[6] := false;;
gap> COSET_LEADERS_INNER_8BITS(Veclis8([one]), 1, 1, leaders, f5);
4
gap> leaders[2];
[ Z(5)^0 ]

# bad arguments
gap> COSET_LEADERS_INNER_8BITS(fail, 1, 1, leaders, f5);
Error, COSET_LEADERS_INNER_8BITS: <veclis> must be a plain list (not the value\
 'fail')
gap> COSET_LEADERS_INNER_8BITS(Veclis8([one]), fail, 1, leaders, f5);
Error, COSET_LEADERS_INNER_8BITS: <weight> must be a small integer (not the va\
lue 'fail')
gap> COSET_LEADERS_INNER_8BITS(Veclis8([one]), 1, fail, leaders, f5);
Error, COSET_LEADERS_INNER_8BITS: <tofind> must be a small integer (not the va\
lue 'fail')
gap> COSET_LEADERS_INNER_8BITS(Veclis8([one]), 1, 1, fail, f5);
Error, COSET_LEADERS_INNER_8BITS: <leaders> must be a plain list (not the valu\
e 'fail')
gap> COSET_LEADERS_INNER_8BITS(Veclis8([one]), 1, 1, leaders, fail);
Error, COSET_LEADERS_INNER_8BITS: <felts> must be a plain list (not the value \
'fail')

#
# SEMIECHELON_LIST_VEC8BITS
#
gap> s := SEMIECHELON_LIST_VEC8BITS([one]);; s.heads = [1] and s.vectors = [one];
true

# bad arguments
gap> SEMIECHELON_LIST_VEC8BITS(fail);
Error, SEMIECHELON_LIST_VEC8BITS: <mat> must be a plain list (not the value 'f\
ail')

#
# SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS
#
gap> s := SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS([one]);; s.heads = [1] and s.vectors = [one] and s.coeffs = [one];
true

# bad arguments
gap> SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS(fail);
Error, SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS: <mat> must be a plain list (\
not the value 'fail')

#
# TRIANGULIZE_LIST_VEC8BITS
#
gap> m := [one];; TRIANGULIZE_LIST_VEC8BITS(m);; m = [one];
true

# bad arguments
gap> TRIANGULIZE_LIST_VEC8BITS(fail);
Error, TRIANGULIZE_LIST_VEC8BITS: <mat> must be a plain list (not the value 'f\
ail')

#
# RANK_LIST_VEC8BITS
#
gap> RANK_LIST_VEC8BITS([one]);
1

# bad arguments
gap> RANK_LIST_VEC8BITS(fail);
Error, RANK_LIST_VEC8BITS: <mat> must be a plain list (not the value 'fail')

#
# DETERMINANT_LIST_VEC8BITS
#
gap> DETERMINANT_LIST_VEC8BITS([one]);
Z(5)^0

# bad arguments
gap> DETERMINANT_LIST_VEC8BITS(fail);
Error, DETERMINANT_LIST_VEC8BITS: <mat> must be a plain list (not the value 'f\
ail')

#
# EQ_MAT8BIT_MAT8BIT
#
gap> EQ_MAT8BIT_MAT8BIT(Mx08(2), Mx08(2)) and EQ_MAT8BIT_MAT8BIT(ZeroRowMat8(), ZeroRowMat8());
true

# bad arguments
gap> EQ_MAT8BIT_MAT8BIT(fail, Mx08(2));
Error, EQ_MAT8BIT_MAT8BIT: <ml> must belong to Is8BitMatrixRep (not the value \
'fail')
gap> EQ_MAT8BIT_MAT8BIT(Mx08(2), fail);
Error, EQ_MAT8BIT_MAT8BIT: <mr> must belong to Is8BitMatrixRep (not the value \
'fail')

#
# LT_MAT8BIT_MAT8BIT
#
gap> LT_MAT8BIT_MAT8BIT(ZeroRowMat8(), Mx08(1)) and not LT_MAT8BIT_MAT8BIT(Mx08(1), ZeroRowMat8());
true

# bad arguments
gap> LT_MAT8BIT_MAT8BIT(fail, Mx08(1));
Error, LT_MAT8BIT_MAT8BIT: <ml> must belong to Is8BitMatrixRep (not the value \
'fail')
gap> LT_MAT8BIT_MAT8BIT(ZeroRowMat8(), fail);
Error, LT_MAT8BIT_MAT8BIT: <mr> must belong to Is8BitMatrixRep (not the value \
'fail')

#
# TRANSPOSED_MAT8BIT
#
gap> TRANSPOSED_MAT8BIT(ZeroRowMat8());
Error, TRANSPOSED_MAT8BIT: compressed 8bit matrices with empty rows are not su\
pported
gap> EQ_MAT8BIT_MAT8BIT(TRANSPOSED_MAT8BIT(Mx08(2)), ZeroRowMat8());
true

# bad arguments
gap> TRANSPOSED_MAT8BIT(fail);
Error, TRANSPOSED_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value\
 'fail')

#
# KRONECKERPRODUCT_MAT8BIT_MAT8BIT
#
gap> KRONECKERPRODUCT_MAT8BIT_MAT8BIT(ZeroRowMat8(), ZeroRowMat8());
Error, KRONECKERPRODUCT_MAT8BIT_MAT8BIT: compressed 8bit matrices with empty r\
ows are not supported
gap> KRONECKERPRODUCT_MAT8BIT_MAT8BIT(Mx08(2), M8([[o]])) = Mx08(2);
true

# bad arguments
gap> KRONECKERPRODUCT_MAT8BIT_MAT8BIT(fail, ZeroRowMat8());
Error, KRONECKERPRODUCT_MAT8BIT_MAT8BIT: <matl> must belong to Is8BitMatrixRep\
 (not the value 'fail')
gap> KRONECKERPRODUCT_MAT8BIT_MAT8BIT(ZeroRowMat8(), fail);
Error, KRONECKERPRODUCT_MAT8BIT_MAT8BIT: <matr> must belong to Is8BitMatrixRep\
 (not the value 'fail')

#
# MAT_ELM_MAT8BIT
#
gap> MAT_ELM_MAT8BIT(M8([[o]]), 1, 1);
Z(5)^0

# bad arguments
gap> MAT_ELM_MAT8BIT(fail, 1, 1);
Error, MAT_ELM_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the value 'f\
ail')
gap> MAT_ELM_MAT8BIT(M8([[o]]), fail, 1);
Error, MAT_ELM_MAT8BIT: <row> must be a positive small integer (not the value \
'fail')
gap> MAT_ELM_MAT8BIT(M8([[o]]), 1, fail);
Error, MAT_ELM_MAT8BIT: <col> must be a positive small integer (not the value \
'fail')

#
# SET_MAT_ELM_MAT8BIT
#
gap> m := M8([[z]]);; SET_MAT_ELM_MAT8BIT(m, 1, 1, o);; m = M8([[o]]);
true

# bad arguments
gap> SET_MAT_ELM_MAT8BIT(fail, 1, 1, o);
Error, SET_MAT_ELM_MAT8BIT: <mat> must belong to Is8BitMatrixRep (not the valu\
e 'fail')
gap> SET_MAT_ELM_MAT8BIT(m, fail, 1, o);
Error, SET_MAT_ELM_MAT8BIT: <row> must be a positive small integer (not the va\
lue 'fail')
gap> SET_MAT_ELM_MAT8BIT(m, 1, fail, o);
Error, SET_MAT_ELM_MAT8BIT: <col> must be a positive small integer (not the va\
lue 'fail')
gap> SET_MAT_ELM_MAT8BIT(m, 1, 1, fail);
Error, Attempt to convert locked compressed vector to plain list

#
gap> STOP_TEST("kernel/vec8bit.tst");
