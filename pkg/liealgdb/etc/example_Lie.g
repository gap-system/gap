LieAlgDataBase.example_Lie := rec(

  information := rec(
      title := "example",
      description := "some examples to explain the proposed format",
      authors_of_classification := [ "folklore" ],
      references := [ "Gong's thesis" ],
      authors_of_conversion := [ "Costantini, Marco" ] ),

  common_data := rec(
      method := AlgebraByStructureConstants,
      symmetry := "antisymmetric",
      properties_and_attributes := [ 
[ IsLieAlgebra, true ], 
[ IsLieSolvable, true ] 
] ),


5 := [

rec(
name:="N5,1",
non_zero_products:=[
[1,2,[1,3]],
[1,3,[1,4]],
[1,4,[1,5]],
[2,3,[1,5]],
]),

rec(
name:="N5,2,1",
non_zero_products:=[
[1,2,[1,3]],
[1,3,[1,4]],
[1,4,[1,5]],
[2,3,[1,5]],
]),

rec(
name:="N5,2,2",
non_zero_products:=[
[1,2,[1,4]],
[1,4,[1,5]],
[2,3,[1,5]],
]),

rec(
name:="N5,2,3",
non_zero_products:=[
[1,2,[1,3]],
[1,3,[1,4]],
[2,3,[1,5]],
]),

rec(
name:="N5,3,1",
non_zero_products:=[
[1,2,[1,5]],
[3,4,[1,5]],
]),

rec(
name:="N5,3,2",
non_zero_products:=[
[1,2,[1,4]],
[1,3,[1,5]],
])

],



7 := [


rec(
name:="147E",
description:="this is an one parameter family",
non_zero_products:=[
[1,2,[1,4]],
[1,3,[-1,6]],
[1,5,[-1,7]],
[2,3,[1,5]],
[2,6,["LADB_p[1]",7]],
[3,4,["LADB_1 - LADB_p[1]",7]],
]),

rec(
name:="147F",
description:="this Lie algebra exists for char = 3 only",
is_the_field_valid := F -> Characteristic( F ) = 3,
non_zero_products:=[
[1,2,[1,4]],
[1,3,[-1,6]],
[1,5,[1,7]],
[1,6,[1,7]],
[2,3,[1,5]],
[2,4,[1,7]],
[2,6,[1,7]],
[3,4,[1,7]],
])

]

);
