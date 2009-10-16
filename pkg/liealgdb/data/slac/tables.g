#####################################dim2#################################

L2_1:= function( F )

     local S;

     S:= EmptySCTable( 2, Zero(F), "antisymmetric" );
     return LieAlgebraByStructureConstants( F, S );

end;

L2_2:= function( F )

     local S;

     S:= EmptySCTable( 2, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 2, 1, [One(F),1] );
     return LieAlgebraByStructureConstants( F, S );

end;


#####################################dim3#################################

# Abelian Lie algebra L^1:
L3_1:= function( F )

     local S;

     S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
     return LieAlgebraByStructureConstants( F, S );

end;

# L^2:
L3_2:= function( F )

     local S;

     S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 3, 1, [One(F),1] );
     SetEntrySCTable( S, 3, 2, [One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;

# L^3_a:
L3_3:= function( F, a )

     local S;

     S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 3, 1, [One(F),2] );
     SetEntrySCTable( S, 3, 2, [a,1,One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;

# L^4_a:
L3_4:= function( F, a )

     local S;

     S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 3, 1, [One(F),2] );
     SetEntrySCTable( S, 3, 2, [a,1] );
     return LieAlgebraByStructureConstants( F, S );

end;

################################ dim 4 ##################################

L4_1:= function( F )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_2:= function( F )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),1] );
     SetEntrySCTable( S, 4, 2, [One(F),2] );
     SetEntrySCTable( S, 4, 3, [One(F),3] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_3:= function( F, a )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),1] );
     SetEntrySCTable( S, 4, 2, [One(F),3] );
     SetEntrySCTable( S, 4, 3, [-a,2,a+One(F),3] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_4:= function( F )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 2, [One(F),3] );
     SetEntrySCTable( S, 4, 3, [One(F),3] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_5:= function( F )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 2, [One(F),3] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_6:= function( F, a, b )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),2] );
     SetEntrySCTable( S, 4, 2, [One(F),3] );
     SetEntrySCTable( S, 4, 3, [a,1,b,2,One(F),3] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_7:= function( F, a, b )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),2] );
     SetEntrySCTable( S, 4, 2, [One(F),3] );
     SetEntrySCTable( S, 4, 3, [a,1,b,2] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_8:= function( F )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 1, 2, [One(F),2] );
     SetEntrySCTable( S, 3, 4, [One(F),4] );
     return LieAlgebraByStructureConstants( F, S );

end;


L4_9:= function( F, a  )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),1,a,2] );
     SetEntrySCTable( S, 4, 2, [One(F),1] );
     SetEntrySCTable( S, 3, 1, [One(F),1] );
     SetEntrySCTable( S, 3, 2, [One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_10:= function( F, a  )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),2] );
     SetEntrySCTable( S, 4, 2, [a,1] );
     SetEntrySCTable( S, 3, 1, [One(F),1] );
     SetEntrySCTable( S, 3, 2, [One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;

L4_11:= function( F, a, b  )

     local S;

     if Characteristic(F) <> 2 then
        Error( "The characteristic of F has to b e2 for L4_11");
     fi;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),1] );
     SetEntrySCTable( S, 4, 2, [b,2] );
     SetEntrySCTable( S, 4, 3, [One(F)+b,3] );
     SetEntrySCTable( S, 3, 1, [One(F),2] );
     SetEntrySCTable( S, 3, 2, [a,1] );
     return LieAlgebraByStructureConstants( F, S );

end;


L4_12:= function( F )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),1] );
     SetEntrySCTable( S, 4, 2, [2*One(F),2] );
     SetEntrySCTable( S, 4, 3, [One(F),3] );
     SetEntrySCTable( S, 3, 1, [One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;


L4_13:= function( F, a )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [One(F),1,a,3] );
     SetEntrySCTable( S, 4, 2, [One(F),2] );
     SetEntrySCTable( S, 4, 3, [One(F),1] );
     SetEntrySCTable( S, 3, 1, [One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;


L4_14:= function( F, a )

     local S;

     S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
     SetEntrySCTable( S, 4, 1, [a,3] );
     SetEntrySCTable( S, 4, 3, [One(F),1] );
     SetEntrySCTable( S, 3, 1, [One(F),2] );
     return LieAlgebraByStructureConstants( F, S );

end;

# Nilpotent Lie algebras:
#====================================dim5===================================

N5_1:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_2:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_3:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_4:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,5] );
   SetEntrySCTable( T, 3, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_5:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 2, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_6:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_7:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_8:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,4] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N5_9:= function( F )

   local T;
   T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

#=================================== dim6===============================

N6_1:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_2:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_3:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_4:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,5] );
   SetEntrySCTable( T, 3, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_5:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 2, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_6:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_7:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_8:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,4] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_9:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_10:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,6] );
   SetEntrySCTable( T, 4, 5, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_11:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,6] );
   SetEntrySCTable( T, 2, 3, [1,6] );
   SetEntrySCTable( T, 2, 5, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_12:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,6] );
   SetEntrySCTable( T, 2, 5, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_13:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 2, 4, [1,5] );
   SetEntrySCTable( T, 1, 5, [1,6] );
   SetEntrySCTable( T, 3, 4, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_14:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   SetEntrySCTable( T, 2, 5, [1,6] );
   SetEntrySCTable( T, 3, 4, [-1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_15:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   SetEntrySCTable( T, 1, 5, [1,6] );
   SetEntrySCTable( T, 2, 4, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_16:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 2, 5, [1,6] );
   SetEntrySCTable( T, 3, 4, [-1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_17:= function( F )


   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 1, 5, [1,6] );
   SetEntrySCTable( T, 2, 3, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_18:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 1, 4, [1,5] );
   SetEntrySCTable( T, 1, 5, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_19:= function( F, a )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,4] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 2, 4, [1,6] );
   SetEntrySCTable( T, 3, 5, [a,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_20:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,4] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 1, 5, [1,6] );
   SetEntrySCTable( T, 2, 4, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_21:= function( F, a )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,4] );
   SetEntrySCTable( T, 2, 3, [1,5] );
   SetEntrySCTable( T, 1, 4, [1,6] );
   SetEntrySCTable( T, 2, 5, [a,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_22:= function( F, a )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,5] );
   SetEntrySCTable( T, 1, 3, [1,6] );
   SetEntrySCTable( T, 2, 4, [a,6] );
   SetEntrySCTable( T, 3, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_23:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 1, 4, [1,6] );
   SetEntrySCTable( T, 2, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_24:= function( F, a )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 1, 4, [a,6] );
   SetEntrySCTable( T, 2, 3, [1,6] );
   SetEntrySCTable( T, 2, 4, [1,5] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_25:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,3] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 1, 4, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;

N6_26:= function( F )

   local T;
   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
   SetEntrySCTable( T, 1, 2, [1,4] );
   SetEntrySCTable( T, 1, 3, [1,5] );
   SetEntrySCTable( T, 2, 3, [1,6] );
   return LieAlgebraByStructureConstants( F, T );

end;
