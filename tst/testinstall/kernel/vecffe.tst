#
# Tests for functions defined in src/vecffe.c
#
gap> START_TEST("kernel/vecffe.tst");

#
# ADD_ROWVECTOR_VECFFES_3
#
gap> ADD_ROWVECTOR_VECFFES_3(fail, fail, fail);
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_3(fail, fail, 0*Z(2));
gap> ADD_ROWVECTOR_VECFFES_3([1], fail, Z(2));
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_3(fail, [1], Z(2));
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_3([1], [1], Z(2));
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_3([Z(3)], [Z(3), Z(3)], Z(3));
Error, AddRowVector: <dst> must have the same length as <src> (lengths are 1 a\
nd 2)
gap> ADD_ROWVECTOR_VECFFES_3([Z(3)], [Z(2)], Z(3));
Error, AddRowVector: vectors have different fields
gap> ADD_ROWVECTOR_VECFFES_3([Z(3)], [Z(9)], Z(3));
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_3([Z(3)], [Z(3)], Z(2));
Error, AddRowVector: <multiplier> has different field
gap> v:=[Z(3)];; ADD_ROWVECTOR_VECFFES_3(v, v, Z(3)^0);
gap> v;
[ Z(3)^0 ]
gap> v:=[Z(9)];; ADD_ROWVECTOR_VECFFES_3(v, v, Z(3)^0);
gap> v;
[ Z(3^2)^5 ]

#
# MULT_VECTOR_VECFFES
#
gap> MULT_VECTOR_VECFFES(fail, fail);
"TRY_NEXT_METHOD"
gap> MULT_VECTOR_VECFFES(fail, 0);
"TRY_NEXT_METHOD"
gap> MULT_VECTOR_VECFFES(fail, 0*Z(2));
"TRY_NEXT_METHOD"
gap> MULT_VECTOR_VECFFES([1], 0*Z(2));
"TRY_NEXT_METHOD"
gap> MULT_VECTOR_VECFFES([Z(3)], 0*Z(2));
Error, MultVector: <multiplier> has different field
gap> v:=[Z(3)];; MULT_VECTOR_VECFFES(v, Z(3));
gap> v;
[ Z(3)^0 ]
gap> v:=[Z(9)];; MULT_VECTOR_VECFFES(v, Z(3));
gap> v;
[ Z(3^2)^5 ]
gap> v:=[Z(9)];; MULT_VECTOR_VECFFES(v, 0*Z(3));
gap> v;
[ 0*Z(3) ]

#
# ADD_ROWVECTOR_VECFFES_2
#
gap> ADD_ROWVECTOR_VECFFES_2(fail, fail);
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_2(fail, fail);
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_2([1], fail);
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_2(fail, [1]);
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_2([1], [1]);
"TRY_NEXT_METHOD"
gap> ADD_ROWVECTOR_VECFFES_2([Z(3)], [Z(3), Z(3)]);
Error, AddRowVector: <dst> must have the same length as <src> (lengths are 1 a\
nd 2)
gap> ADD_ROWVECTOR_VECFFES_2([Z(3)], [Z(2)]);
Error, AddRowVector: vectors have different fields
gap> ADD_ROWVECTOR_VECFFES_2([Z(3)], [Z(9)]);
"TRY_NEXT_METHOD"
gap> v:=[Z(3)];; ADD_ROWVECTOR_VECFFES_2(v, v);
gap> v;
[ Z(3)^0 ]

#
# IS_VECFFE
#
gap> IS_VECFFE(fail);
false
gap> IS_VECFFE([]);
false
gap> IS_VECFFE([1]);
false
gap> IS_VECFFE([Z(2), Z(3)]);
false
gap> IS_VECFFE([Z(2), Z(4)]);
false
gap> IS_VECFFE([Z(3)]);
true

#
# COMMON_FIELD_VECFFE
#
gap> COMMON_FIELD_VECFFE(fail);
fail
gap> COMMON_FIELD_VECFFE([Z(3)]);
3
gap> COMMON_FIELD_VECFFE([Z(4), Z(4)^2]);
4
gap> COMMON_FIELD_VECFFE([Z(4), Z(8)]);
fail

#
# SMALLEST_FIELD_VECFFE
#
gap> SMALLEST_FIELD_VECFFE(fail);
fail
gap> SMALLEST_FIELD_VECFFE([]);
fail
gap> SMALLEST_FIELD_VECFFE([1]);
fail
gap> SMALLEST_FIELD_VECFFE([Z(2)]);
2
gap> SMALLEST_FIELD_VECFFE([Z(2), Z(3)]);
fail
gap> SMALLEST_FIELD_VECFFE([Z(2), Z(4)]);
4
gap> SMALLEST_FIELD_VECFFE([Z(8), Z(4)]);
64

#
gap> STOP_TEST("kernel/vecffe.tst", 1);
