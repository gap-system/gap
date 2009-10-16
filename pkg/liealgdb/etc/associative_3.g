LieAlgDataBase.associative_3 := rec(

  information := rec(
      title := "small associative",
      description := "associative and unitary algebras up to dimension 3 over real field",
      authors_of_classification := [ "folklore" ],
      references := [ "http://www.mathsoft.com/mathsoft_resources/unsolved_problems/2190a.asp" ],
      authors_of_conversion := [ "Costantini, Marco" ] ),

  common_data := rec(
      method := AlgebraByStructureConstants,
      properties_and_attributes := [ [ IsAssociative, true ] ] ),

  1 := [

      rec( description := "R", non_zero_products := [ [ 1, 1, [ 1, 1 ] ] ] )

       ],

  2 := [

      rec( description := "R x R", non_zero_products := [ [ 1, 1, [ 1, 1 ] ], [ 2, 2, [ 1, 2 ] ] ] ),
      rec( description := "C", symmetry := "symmetric",
          non_zero_products := [ [ 1, 1, [ -1, 2 ] ], [ 1, 2, [ 1, 1 ] ], [ 2, 2, [ 1, 2 ] ] ] ),
      rec( description := "R[X]/(X^2)",  symmetry := "symmetric",
          non_zero_products := [[ 1, 1, [ 1, 1 ] ], [ 1, 2, [ 1, 2 ] ] ] )

       ],

  3 := [

      rec( description := "R x R x R",
          non_zero_products := [ [ 1, 1, [ 1, 1 ] ], [ 2, 2, [ 1, 2 ] ], [ 3, 3, [ 1, 3 ] ] ] ),
      rec( description := "C x R", symmetry := "symmetric",
          non_zero_products := [ [ 1, 1, [ -1, 2 ] ], [ 1, 2, [ 1, 1 ] ], [ 2, 2, [ 1, 2 ] ],
          [ 3, 3, [ 1, 3 ] ] ] ),
      rec( description := "R[X]/(X^2) x R",  symmetry := "symmetric",
          non_zero_products := [ [ 1, 1, [ 1, 1 ] ], [ 1, 2, [ 1, 2 ] ], [ 3, 3, [ 1, 3 ] ] ] ),
      rec( description := "R[X]/(X^3)",  symmetry := "symmetric",
          non_zero_products := [ [ 1, 1, [ 1, 1 ] ], [ 1, 2, [ 1, 2 ] ], [ 1, 3, [ 1, 3 ] ],
          [ 2, 2, [ 1, 3 ] ] ] ),
      rec( description := "R[X, Y]/(X^2, XY, Y^2)",  symmetry := "symmetric",
          non_zero_products := [ [ 1, 1, [ 1, 1 ] ], [ 1, 2, [ 1, 2 ] ], [ 1, 3, [ 1, 3 ] ] ] ),
      rec( description := "T",
          non_zero_products := [ [ 1, 1, [ 1, 1 ] ], [ 1, 2, [ 1, 2 ] ], [ 2, 3, [ 1, 2 ] ],
          [ 3, 3, [ 1, 3 ] ] ] )

       ]

);


