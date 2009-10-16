InstallMethod( SolvableLieAlgebra,  "for a field and a list", true,
   [ IsField, IsList ], 0, 

function( F, data )

   local d, no, a, b, S, L;

   if not Length( data ) >= 2 then 
      Error("<data> has to have length at least two"); 
   fi;
   if not IsPosInt( data[1] ) then
      Error("the first element of <data> has to be a positive integer");
   else
      d:= data[1];
      if not d in [1,2,3,4] then
         Error("the dimension has to be 1,2,3, or 4");
      fi;
   fi;
   no:= data[2];
   if d=1 then
       if no > 1 then
           Error( "the second element of <data> has to be <= 1" );
       fi;
   elif d=2 then
      if no > 2 then
         Error("the second element of <data> has to be <= 2");
      fi;
   elif d=3 then
      if no > 4 then
         Error("the second element of <data> has to be <= 4");
      fi;
   else
      if not no in [1..14] then
         Error("the second element of <data> has to be <= 14");
      fi;
    fi;
   if Length( data ) >=3 then
      a:= data[3];
   fi;
   if Length( data ) >= 4 then
      b:= data[4];
   fi;
   
   if d = 1 then
       S:= EmptySCTable( 1, Zero(F), "antisymmetric" );
       L := LieAlgebraByStructureConstants( F, S );
       L!.arg := data;
       return L;
   elif d = 2 then
      if no=1 then
         S:= EmptySCTable( 2, Zero(F), "antisymmetric" );
         L := LieAlgebraByStructureConstants( F, S );
         L!.arg := data;
         return L;
      else
         S:= EmptySCTable( 2, Zero(F), "antisymmetric" );
         SetEntrySCTable( S, 2, 1, [One(F),1] );
         L := LieAlgebraByStructureConstants( F, S );
         L!.arg := data;
         return L;
      fi;
   elif d=3 then
      if no=1 then
         S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
         L := LieAlgebraByStructureConstants( F, S );
         L!.arg := data;
         return L;
      elif no=2 then
         S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
         SetEntrySCTable( S, 3, 1, [One(F),1] );
         SetEntrySCTable( S, 3, 2, [One(F),2] );
         L := LieAlgebraByStructureConstants( F, S );
         L!.arg := data;
         return L;
      elif no=3 then
         S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
         SetEntrySCTable( S, 3, 1, [One(F),2] );
         SetEntrySCTable( S, 3, 2, [a,1,One(F),2] );
         L := LieAlgebraByStructureConstants( F, S );     
         L!.arg := data;
         return L;
      else
         S:= EmptySCTable( 3, Zero(F), "antisymmetric" );
         SetEntrySCTable( S, 3, 1, [One(F),2] );
         SetEntrySCTable( S, 3, 2, [a,1] );
         L := LieAlgebraByStructureConstants( F, S );
         L!.arg := data;
         return L;
      fi;
   else
      if no=1 then
         S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
         L := LieAlgebraByStructureConstants( F, S );
         L!.arg := data;
         return L;
      elif no=2 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),1] );
           SetEntrySCTable( S, 4, 2, [One(F),2] );
           SetEntrySCTable( S, 4, 3, [One(F),3] );
           L := LieAlgebraByStructureConstants( F, S );   
           L!.arg := data;
           return L;
      elif no=3 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),1] );
           SetEntrySCTable( S, 4, 2, [One(F),3] );
           SetEntrySCTable( S, 4, 3, [-a,2,a+One(F),3] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no = 4 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 2, [One(F),3] );
           SetEntrySCTable( S, 4, 3, [One(F),3] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no = 5 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 2, [One(F),3] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no = 6 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),2] );
           SetEntrySCTable( S, 4, 2, [One(F),3] );
           SetEntrySCTable( S, 4, 3, [a,1,b,2,One(F),3] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no = 7 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),2] );
           SetEntrySCTable( S, 4, 2, [One(F),3] );
           SetEntrySCTable( S, 4, 3, [a,1,b,2] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no=8 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 1, 2, [One(F),2] );
           SetEntrySCTable( S, 3, 4, [One(F),4] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no=9 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),1,a,2] );
           SetEntrySCTable( S, 4, 2, [One(F),1] );
           SetEntrySCTable( S, 3, 1, [One(F),1] );
           SetEntrySCTable( S, 3, 2, [One(F),2] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no=10 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),2] );
           SetEntrySCTable( S, 4, 2, [a,1] );
           SetEntrySCTable( S, 3, 1, [One(F),1] );
           SetEntrySCTable( S, 3, 2, [One(F),2] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no=11 then
           if Characteristic(F) <> 2 then
              Error( "The characteristic of F has to be 2 for L4_11");
           fi;

           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),1] );
           SetEntrySCTable( S, 4, 2, [b,2] );
           SetEntrySCTable( S, 4, 3, [One(F)+b,3] );
           SetEntrySCTable( S, 3, 1, [One(F),2] );
           SetEntrySCTable( S, 3, 2, [a,1] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no=12 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),1] );
           SetEntrySCTable( S, 4, 2, [2*One(F),2] );
           SetEntrySCTable( S, 4, 3, [One(F),3] );
           SetEntrySCTable( S, 3, 1, [One(F),2] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      elif no=13 then
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [One(F),1,a,3] );
           SetEntrySCTable( S, 4, 2, [One(F),2] );
           SetEntrySCTable( S, 4, 3, [One(F),1] );
           SetEntrySCTable( S, 3, 1, [One(F),2] );
           L := LieAlgebraByStructureConstants( F, S );   
           L!.arg := data;
           return L;
      else
           S:= EmptySCTable( 4, Zero(F), "antisymmetric" );
           SetEntrySCTable( S, 4, 1, [a,3] );
           SetEntrySCTable( S, 4, 3, [One(F),1] );
           SetEntrySCTable( S, 3, 1, [One(F),2] );
           L := LieAlgebraByStructureConstants( F, S );
           L!.arg := data;
           return L;
      fi;
   fi;

end );

InstallMethod( NilpotentLieAlgebra,  "for a field and a list", true,
   [ IsField, IsList ], 0, 

function( F, data )

   local L, d, no, a, ff, arg,
         N1_1, N2_1, N3_1, N3_2, N4_1, N4_2, N4_3, 
         N6_1, N6_2, N6_3, N6_4, N6_5, N6_6, N6_7, N6_8, N6_9, N6_10,
         N6_11, N6_12, N6_13, N6_14, N6_15, N6_16, N6_17, N6_18, N6_19, 
	 N6_20, N6_21, N6_22, N6_23, N6_24, N6_25, N6_26,N5_1, N5_2, N5_3, 
	 N5_4, N5_5, N5_6, N5_7, N5_8, N5_9;

N1_1 := function( F )
    local T;
    T := EmptySCTable( 1, Zero(F), "antisymmetric" );
    return LieAlgebraByStructureConstants( F, T );
end;

N2_1 := function( F )
    local T;
    T := EmptySCTable( 2, Zero(F), "antisymmetric" );
    return LieAlgebraByStructureConstants( F, T );
end;

N3_1 := function( F )
    local T;
    T := EmptySCTable( 3, Zero(F), "antisymmetric" );
    return LieAlgebraByStructureConstants( F, T );
end;

N3_2 := function( F )
    local T;
    T := EmptySCTable( 3, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    return LieAlgebraByStructureConstants( F, T );
end;

N4_1 := function( F )
    local T;
    T := EmptySCTable( 4, Zero(F), "antisymmetric" );
    return LieAlgebraByStructureConstants( F, T );
end;

N4_2 := function( F )
    local T;
    T := EmptySCTable( 4, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,4] );
    return LieAlgebraByStructureConstants( F, T );
end;

N4_3 := function( F )
    local T;
    T := EmptySCTable( 4, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [1,4] );
    return LieAlgebraByStructureConstants( F, T );
end;

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

   if not Length( data ) >= 2 then 
      Error("<data> has to have length at least two"); 
   fi;
   if not IsPosInt( data[1] ) then
      Error("the first element of <data> has to be a positive integer");
   else
      d:= data[1];
      if not d in [1,2,3,4,5,6] then
         Error("the dimension has to be an integer from 1 to 6");
      fi;
   fi;
   no:= data[2];
   if d=1 then
       if no > 1 then
           Error( "the second element of <data> has to be <= 1" );
       fi;
   elif d=2 then
       if no > 1 then
           Error( "the second element of <data> has to be <= 1" );
       fi;
   elif d=3 then
       if no > 2 then
           Error( "the second element of <data> has to be <= 2" );
       fi;
   elif d=4 then
       if no > 3 then
           Error( "the second element of <data> has to be <= 3" );
       fi;
   elif d=5 then
       if no > 9 then
           Error("the second element of <data> has to be <= 9");
       fi;
   else
       if no > 26  then
           Error("the second element of <data> has to be <= 26");
       fi;
   fi;

   if Length( data ) >= 3 then a:= data[3]; fi;
   
   if d = 1 then
       ff := [N1_1];
       L := CallFuncList( ff[no], [ F ] );
       L!.arg := data;
       return L;
   elif d = 2 then
       ff := [N2_1];
       L := CallFuncList( ff[no], [ F ] );
       L!.arg := data;
       return L;
   elif d = 3 then
       ff := [N3_1,N3_2];
       L := CallFuncList( ff[no], [ F ] );
       L!.arg := data;
       return L;
  elif d = 4 then
       ff := [N4_1,N4_2,N4_3];
       L := CallFuncList( ff[no], [ F ] );
       L!.arg := data;
       return L;
   elif d = 5 then
      ff:= [ N5_1, N5_2, N5_3, N5_4, N5_5, N5_6, N5_7, N5_8, N5_9 ];
      L := CallFuncList( ff[no], [ F ] );
      L!.arg := data;
      return L;
  else
      ff:= [ N6_1, N6_2, N6_3, N6_4, N6_5, N6_6, N6_7, N6_8, N6_9, N6_10,
             N6_11, N6_12, N6_13, N6_14, N6_15, N6_16, N6_17, N6_18, N6_19,
             N6_20, N6_21, N6_22, N6_23, N6_24, N6_25, N6_26 ];
      if no in [19,21,22,24] then
         arg:= [F,a];
      else
         arg:= [F];
      fi;
      L := CallFuncList( ff[no], arg );
      L!.arg := data;
      return L;
   fi;
         
end );

#W  function StringPrint is from the GAPDoc package...
#W  (the normal String does not work for finite fields).


isomN:= function( L, x1, x2, x3, x4 )

      # Here the xi satisfy the commutation relations of N;
      # we produce the isomorphism with M_0^13...

      local F, y1, y2, y3, y4, name, K, f;

      F:= LeftActingDomain( L );

      if Characteristic(F) <> 3 then
         y1:= x1+x2;
         y2:= 3*x1-(3/2*One(F))*x2;
         y3:= x1+x2-x3+2*x4;
         y4:= x3;
      else
         y1:= x2;
         y2:= x1+x2;
         y3:= x1-x2+x3+x4;
         y4:= x1-x2+x3;
      fi;
      name:= "L4_13( ";
      Append( name, LieAlgDBField2String( F ) );
      Append( name, ", " );
      Append( name, String( Zero(F) ) );
      Append( name, " )" );
      K:= SolvableLieAlgebra( F, [4,13, Zero(F)] );
      f:= AlgebraHomomorphismByImages(K,L,Basis(K),[y1,y2,y3,y4]);
      return rec( name:= [ name, [ Zero(F) ] ], isom:= f );

end;

isomM9:= function( L, x1, x2, x3, x4, a )

      # The xi satisfy the commutation rules of M9a; we return 
      # the isomorphism with either N, M8 or M9a

      local F, T, pol, facs, dd, id, f, name, K, c, exp, prim, ef, b, q, i;

      F:= LeftActingDomain( L );

      if Characteristic(F) <> 2 and a = (-1/4)*One(F) then

         return isomN( L, x1, x2, x3, x4 );

      fi;

      T:= Indeterminate( F);
      pol:= T^2-T-a;
      facs:= Factors( pol );

      if Length( facs ) = 2 then
         #direct sum...
         dd:= DirectSumDecomposition( L );
         id:= LieAlgebraIdentification( dd[1] );
         f:= id.isomorphism;
         x1:= Image( f, Basis( Source(f) )[2] );
         x2:= Image( f, Basis( Source(f) )[1] );
         id:= LieAlgebraIdentification( dd[2] );
         f:= id.isomorphism;
         x3:= Image( f, Basis( Source(f) )[2] );
         x4:= Image( f, Basis( Source(f) )[1] );
         name:= "L4_8( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,8] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
         return rec( name:= [ name, [] ], isom:= f );     
      else

         if HasIsFinite(F) and IsFinite(F) then
            # for M9 we let b be the smallest power of the primitive root
            # such that T^2-T-b has no roots in F
            q:= Size( F );
            prim:= PrimitiveRoot( F );
            for i in [1..q-1] do
                if Length(Factors( T^2-T-prim^i ) ) = 1 then
                   b:= prim^i;
                   break;
                fi;
            od;
            
            if Characteristic(F) > 2 then
               c:= (b+One(F)/4)/(a+One(F)/4);
               exp:= LogFFE( c, PrimitiveRoot(F) );
               c:= PrimitiveRoot(F)^(exp/2);
               x1:= c*x1+((One(F)-c)/2)*x2;
               x4:= ((One(F)-c)/2)*x3+c*x4;
            else
               facs:= Factors( T^2+T+a+b );
               ef:= ExtRepPolynomialRatFun( facs[1] );
               if Length( ef[1] ) = 0 then
                  c:= -ef[2];
               else
                  c:= Zero( F );
               fi;
               x1:= x1+c*x2;
               x4:= c*x3+x4;
            fi;
         else
            b:= a;
         fi;
         name:= "L4_9( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, ", " );
         Append( name, String( b ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,9, b] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
         return rec( name:= [ name, [ b ] ], isom:= f );
      fi;

end;

isomM10:= function( L, x1, x2, x3, x4, a )

      # the xi satisfy the commutation rels of M10(a)

      local f, b, y1, y2, y3, y4, name, K, F;

      F:= LeftActingDomain( L );
      if HasIsFinite(F) and IsFinite(F) then
         f:= Inverse( FrobeniusAutomorphism(F) );
         b:= Image( f, a );
         y1:= x1;
         y2:= b*x1+x2;
         y3:= x3;
         y4:= b*x3+x4;
         name:= "L4_13( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, ", " );
         Append( name, String( Zero(F) ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,13, Zero(F)] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                       [y1,y2,y1+y2+y4,y1+y2+y3]);
         return rec( name:= [ name, [Zero(F)] ], isom:= f );
      else
         name:= "L4_10( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, ", " );
         Append( name, String( a ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,10, a] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
         return rec( name:= [ name, [a] ], isom:= f );
      fi;
end;

isomM11:= function( L, x1, x2, x3, x4, a, b )

      local name, K, f, gam, eps, del, y1, y2, y3, y4, F;

      F:= LeftActingDomain(L);
                  
      if b = Zero(F) then
         name:= "L4_11( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, ", " );
         Append( name, String( a ) );
         Append( name, ", " );
         Append( name, String( b ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,11,a, b] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
         return rec( name:= [ name, [a,b] ], isom:= f );
      elif HasIsFinite(F) and IsFinite(F) then
         f:= Inverse( FrobeniusAutomorphism(F) );
         gam:= Image( f, b/(a*(b^2+One(F))) );
         eps:= Image( f, 1/a );
         del:= 1/(1+b);
         y1:= a*gam*x1+b*del*x2;
         y2:= a*eps*b*del*x1+a*gam*eps*x2;
         y3:= eps*x3;
         y4:= gam*x3+del*x4;
         name:= "L4_11( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, ", " );
         Append( name, String( One(F) ) );
         Append( name, ", " );
         Append( name, String( Zero(F) ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,11, One(F), Zero(F)] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),[y1,y2,y3,y4]);
         return rec( name:= [ name, [One(F),Zero(F)] ],isom:= f);
      else 
         name:= "L4_11( ";
         Append( name, LieAlgDBField2String( F ) );
         Append( name, ", " );
         Append( name, String( a ) );
         Append( name, ", " );
         Append( name, String( b ) );
         Append( name, " )" );
         K:= SolvableLieAlgebra( F, [4,11, a, b] );
         f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
         return rec( name:= [ name, [a,b] ], isom:= f );
      fi;     
end;

solv_type:= function( L )

     local n, F, sp, k, BL, b, x1, x2, x3, x4, c1, c2, K, f, name, par, 
           id, num, c3, c4, mat, is_diag, i, j, facs, ev, s, t, sol, 
           sevec, tevec, cfs, u, v, w, found, y1, y2, y3, y4,  u1, u3, 
           v1, v3, a, D, adM, adK, dd, bK, b_adK, ef, ev1, ev2, mp, q, C, 
           R, exp;

     n:= Dimension( L );
     F:= LeftActingDomain( L );
     sp:= LieDerivedSubalgebra( L );

     k:= 1;
     BL:= Basis( L );
     while Dimension( sp ) < n-1 do
         if not BL[k] in sp then
            b:= ShallowCopy( BasisVectors( Basis(sp) ) );
            Add( b, BL[k] );
            sp:= Subspace( L, b );
         fi;
         k:= k+1;
     od;

     b:= Basis( sp );

     if n = 2 then

        x1:= b[1];
        for k in [1,2] do
            if not BL[k] in sp then
               x2:= BL[k];
               break;
            fi;
        od;
        
        if x1*x2 = Zero(L) then
           name:= "L2_1( ";
           Append( name, LieAlgDBField2String( F ) );
           Append( name, " )" );
           K:= SolvableLieAlgebra( F, [2,1] );
           f:= AlgebraHomomorphismByImages( K, L, Basis(K), Basis(L) );
           return rec( name:= [ name, [] ], isom:= f );
        fi;

        c1:= Coefficients( b, x2*x1 );
        x2:= x2/c1[1];
        name:= "L2_2( ";
        Append( name, LieAlgDBField2String( F ) );
        Append( name, " )" );
        K:= SolvableLieAlgebra( F, [2,2] );
        f:= AlgebraHomomorphismByImages( K, L, Basis(K), [x1,x2] );
        return rec( name:= [ name, [] ], isom:= f );

     elif n = 3 then

        x1:= b[1]; x2:= b[2];
        if x1*x2 <> Zero(L) then
           # Here [L,L] has dimension 1, and its centralizer
           # has dimension 2, and it contains [L,L].
           sp:= LieCentralizer( L, LieDerivedSubalgebra(L) );
           b:= Basis( sp );
           x1:= Basis(sp)[1];
           x2:= Basis(sp)[2];
        fi;

        for k in [1..3] do
            if not BL[k] in sp then
               x3:= BL[k];
               break;
            fi;
        od;

        if x1*x3 = Zero(L) and x2*x3 = Zero(L) then
           # Abelian!
           name:= "L3_1( ";
           Append( name, LieAlgDBField2String( F ) );
           Append( name, " )" );
           K:= SolvableLieAlgebra( F, [3,1] );
           f:= AlgebraHomomorphismByImages( K, L, Basis(K), Basis(L) );
           return rec( name:= [ name, [] ], isom:= f );
        fi;

        c1:= Coefficients( b, x3*x1 );
        c2:= Coefficients( b, x3*x2 );

        if c1[1] = c2[2] and c1[2] = Zero(F) and c2[1] = Zero(F) then
           x3:= x3/c1[1];
           name:= "L3_2( ";
           Append( name, LieAlgDBField2String( F ) );
           Append( name, " )" );
           K:= SolvableLieAlgebra( F, [3,2] );
           f:= AlgebraHomomorphismByImages( K, L, Basis(K), [x1,x2,x3] );
           return rec( name:= [ name, [] ], isom:= f );
        fi;

        if c1[2] = Zero(F) then
           # i.e., x1 is an eigenvector of ad x3, not good.
           if c2[1] = Zero(F) then
              # x2 is an eigenvector as well, so x1+x2 cannot be
              # (by previous case)...
              x1:= x1+x2;
           else
              x1:=  x2;
           fi;
        fi;

        x2:= x3*x1;
        b:= Basis( Subspace( L, [x1,x2] ), [x1,x2] );
        c2:= Coefficients( b, x3*x2 );

        if c2[2] <> Zero(F) then
           x2:= x2/c2[2];
           x3:= x3/c2[2];
           par:= c2[1]/(c2[2]^2);
           name:= "L3_3( ";
           Append( name, LieAlgDBField2String( F ) );
           Append( name, ", " );
           Append( name, String( par ) );
           Append( name, " )" );
           K:= SolvableLieAlgebra( F, [3,3,par] );
           f:= AlgebraHomomorphismByImages( K, L, Basis(K), [x1,x2,x3] );
           return rec( name:= [ name, [par] ], isom:= f );
        fi;

        par:= c2[1];
        if HasIsFinite(F) and IsFinite(F) and not par in [Zero(F),One(F)] then
           if Characteristic(F) = 2 then
              f:= Inverse( FrobeniusAutomorphism( F ) );
              a:= Image( f, par );
              x2:= a*x2;
              x3:= a*x3;
              par:= a^2*par;
           else
              exp:= LogFFE( 1/par, PrimitiveRoot(F) );
              if IsEvenInt( exp ) then 
                 a:= PrimitiveRoot(F)^(exp/2);
                 x2:= a*x2;
                 x3:= a*x3;
                 par:= a^2*par;
              else
                 exp:= LogFFE( PrimitiveRoot(F)/par, PrimitiveRoot(F) );
                 a:= PrimitiveRoot(F)^(exp/2);
                 x2:= a*x2;
                 x3:= a*x3;
                 par:= a^2*par;
              fi;
           fi;
        fi;
        name:= "L3_4( ";
        Append( name, LieAlgDBField2String( F ) );
        Append( name, ", " );
        Append( name, String( par ) );
        Append( name, " )" );
        K:= SolvableLieAlgebra( F, [3,4,par] );
        f:= AlgebraHomomorphismByImages( K, L, Basis(K), [x1,x2,x3] );
        return rec( name:= [ name, [par] ], isom:= f );

     elif n = 4 then
        x1:= b[1]; x2:= b[2]; x3:= b[3];
        for k in [1..4] do
            if not BL[k] in sp then
               x4:= BL[k];
               break;
            fi;
        od;
        K:= Subalgebra(  L, [x1,x2,x3] );
        adM:= List( Basis(K), x -> AdjointMatrix(Basis(K),x ) );
        adK:= MutableBasis( F, [ 0*adM[1] ] );
        bK:= [ ];
        b_adK:= [ ];
        for i in [1..Length(adM)] do
            if not IsContainedInSpan( adK, adM[i] ) then
               CloseMutableBasis( adK, adM[i] );
               Add( bK, Basis(K)[i] );
               Add( b_adK, adM[i] );
            fi;
        od;

        
        adK:= VectorSpace( F, b_adK, 0*adM[1] );

        mat:= List( Basis(K), x -> Coefficients( Basis(K), x4*x ) );
        mat:= TransposedMat( mat );
        if mat in adK then
           c1:= Coefficients( Basis( adK, b_adK ), mat );
           if c1 = [ ] then # L is abelian
              name:= "L4_1( ";
              Append( name, LieAlgDBField2String( F ) );
              Append( name, " )" );
              K:= SolvableLieAlgebra( F, [4,1] );
              f:= AlgebraHomomorphismByImages( K, L, Basis(K), Basis(L) );
              return rec( name:= [ name, [] ], isom:= f );
           else  
              x3:= x4 - LinearCombination( c1, bK );
              id:= LieAlgebraIdentification( K );
              x4:= Image( id.isomorphism, Basis( Source( id.isomorphism ) )[3] );
              x1:= Image( id.isomorphism, Basis( Source( id.isomorphism ) )[1] );
              x2:= Image( id.isomorphism, Basis( Source( id.isomorphism ) )[2] );
              K:= Subalgebra(  L, [x1,x2,x3] );
           fi;
        fi;

        id:= LieAlgebraIdentification( K );
        x1:= Image( id.isomorphism, Basis( Source( id.isomorphism ) )[1] );
        x2:= Image( id.isomorphism, Basis( Source( id.isomorphism ) )[2] );
        x3:= Image( id.isomorphism, Basis( Source( id.isomorphism ) )[3] );
        b:= Basis( K, [x1,x2,x3] );
        c1:= Coefficients( b, x4*x1 );
        c2:= Coefficients( b, x4*x2 );
        c3:= Coefficients( b, x4*x3 );
        mat:= [ c1, c2, c3 ];
        num:= id.name[4];

        if num = '1' then

           # K is abelian

           R:= PolynomialRing( F, 1 );
           mat:= TransposedMat( mat );
           mp:= MinimalPolynomial( F, mat );
           is_diag:= true;
           for i in [1..3] do
               if not is_diag then break; fi;
               for j in [1..3] do
                   if not is_diag then break; fi;
                   if i <> j and mat[i][j] <> Zero(F) then 
                      is_diag:= false;
                   fi;
               od;
           od;
 
           if Degree(mp) = 1 then
              if c1[1] = Zero(F) then           
                 name:= "L4_1( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,1] );
                 f:= AlgebraHomomorphismByImages( K, L, Basis(K), Basis(L) );
                 return rec( name:= [ name, [] ], isom:= f );                 
              else
                 x4:= x4/c1[1];
                 name:= "L4_2( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,2] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
                 return rec( name:= [ name, [] ], isom:= f );
              fi;
           fi;

           if Degree(mp) = 2 then

              # compute rational canonical form; rather clumsy algorithm
              # which however works for the 3x3 case. 

              facs:= Factors( R, mp );
              ev:= [ ];
              for f in facs do
                  ef:= ExtRepPolynomialRatFun( f );
                  if Length( ef[1] ) = 0 then
                     Add( ev, -ef[2] );
                  else
                     Add( ev, Zero( F ) );
                  fi;
              od; 

              if ev[1] <> ev[2] then

                 sol:= NullspaceMat( TransposedMat(mat) -
                                                ev[1]*IdentityMat( 3, F ) );
                 ev1:= List( sol, x -> LinearCombination( x, [x1,x2,x3] ) );
                 sol:= NullspaceMat( TransposedMat(mat) -
                                                ev[2]*IdentityMat( 3, F ) );
                 ev2:= List( sol, x -> LinearCombination( x, [x1,x2,x3] ) );
                 if Length( ev1 ) = 2 then
                    x1:= ev1[1];
                    x2:= ev1[2] + ev2[1];
                    x3:= x4*x2;
                    s:= ev[1]; t:= ev[2];
                 else
                    x1:= ev2[1];
                    x2:= ev2[2] + ev1[1];
                    x3:= x4*x2;
                    s:= ev[2]; t:= ev[1];
                 fi;
              else
                 s:= ev[1]; t:= s;
                 sol:= NullspaceMat( TransposedMat(mat) -
                                                ev[1]*IdentityMat( 3, F ) );
                 ev1:= List( sol, x -> LinearCombination( x, [x1,x2,x3] ) );
                 sp:= Subspace( L, ev1 );
                 if not x1 in sp then
                    x2:= x1;
                 elif not x3 in sp then
                    x2:= x3;
                 fi;
                 x3:= x4*x2;
                 sp:= Subspace( L, [x2,x3] );
                 if not ev1[1] in sp then
                    x1:= ev1[1];
                 else
                    x1:= ev1[2];
                 fi; 
              fi;

              if s <> Zero(F) then
                 x3:= x3/s;
                 x4:= x4/s;
                 name:= "L4_3( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, ", " );
                 Append( name, String( t/s ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,3,t/s] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                      [x1,x2,x3,x4]);
                 return rec( name:= [ name, [t/s] ], isom:= f );
              elif t <> Zero(F) then
                 x3:= x3/t;
                 x4:= x4/t;
                 name:= "L4_4( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,4] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                     [x1,x2,x3,x4]);
                 return rec( name:= [ name, [] ], isom:= f );
              else
                 name:= "L4_5( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,5] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                      [x1,x2,x3,x4]);
                 return rec( name:= [ name, [] ], isom:= f );
              fi;
           fi;      

           # look for a cyclic vector...
           # we take a random element, maybe better algorithm needed...
           if IsFinite(F) then
              cfs:= List( [1..10], x -> PrimitiveRoot(F)^x );
           else
              cfs:= List( [1..10], x -> x*One(F) );
           fi;
           Add( cfs, Zero(F) );
           found:= false;
           while not found do
               u:= Random(cfs)*x1+Random(cfs)*x2+Random(cfs)*x3;
               v:= x4*u;
               w:= x4*v;
               sp:= Subspace( L, [u,v,w] );
               if Dimension(sp) = 3 then found:= true; fi;
           od;
           x1:= u; x2:= v; x3:= w;
           b:= Basis( sp, [x1,x2,x3] );
           c1:= Coefficients( b, x4*x3 );
           if c1[3] <> Zero(F) then
              x2:= x2/c1[3];
              x3:= x3/(c1[3]^2);
              x4:= x4/c1[3];
              name:= "L4_6( ";
              Append( name, LieAlgDBField2String( F ) );
              Append( name, ", " );
              Append( name, String( c1[1]/(c1[3]^3) ) );
              Append( name, ", ");
              Append( name, String( c1[2]/(c1[3]^2) ) );
              Append( name, " )" );
              K:= SolvableLieAlgebra( F, [4,6, c1[1]/(c1[3]^3), c1[2]/(c1[3]^2) ] );
              f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
              return rec( name:= [ name, [c1[1]/(c1[3]^3), c1[2]/(c1[3]^2)] ], 
                          isom:= f );
           else
              if c1[1] <> Zero(F) and c1[2] <> Zero(F) then
                 s:= c1[2]/c1[1];
                 x2:= x2*s;
                 x3:= x3*s^2;
                 x4:= x4*s;
                 t:= s^2*c1[2];
                 name:= "L4_7( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, ", " );
                 Append( name, String( t ) );
                 Append( name, ", ");
                 Append( name, String( t ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,7, t, t] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
                 return rec( name:= [ name, [t,t] ], isom:= f );
              else

                 if HasIsFinite(F) and IsFinite(F) then
                    q:= Size(F);
                    if c1[1] <> Zero(F) then
                       par:= c1[1];
                       a:= PrimitiveRoot(F);
                       if q mod 6 = 1 or q mod 6 = 4 then
                          exp:= LogFFE( par, a );
                          b:= One(F);
                          if exp mod 3 <> 0 then
                             exp:= LogFFE( par/a, a );
                             b:= a;
                             if exp mod 3 <> 0 then
                                exp:= LogFFE( par/(a^2), a );
                                b:= a^2;
                             fi; 
                          fi;
                          a:= a^(exp/3);
                       else
                          exp:= LogFFE( par, a );
                          if exp mod 3 = 1 then
                             for b in F do
                                 if b^3 = a then
                                    a:= a^((exp-1)/3)*b;
                                    break;
                                 fi;
                             od;
                          elif exp mod 3 = 2 then
                            for b in F do
                                 if b^3 = a^2 then
                                    a:= a^((exp-2)/3)*b;
                                    break;
                                 fi;
                             od;
                          else
                             a:= a^(exp/3);
                          fi;
                          b:= One(F);
                       fi;
                       c1:= [ b, Zero(F) ]; 
                    elif c1[2] <> Zero(F) then     
                       par:= c1[2];
                       a:= PrimitiveRoot(F);
                       if IsEvenInt( q ) then
                          exp:= LogFFE( par, a );
                          if exp mod 2 = 1 then
                             a:= a^((exp-1)/2)*a^(q/2);
                          else
                             a:= a^(exp/2);
                          fi;
                          b:= One(F);
                       else
                          exp:= LogFFE( par, a );
                          b:= One(F);
                          if not IsEvenInt( exp ) then
                             exp:= LogFFE( par/a, a );
                             b:= a;
                          fi;
                          a:= a^(exp/2);
                       fi;
                       c1:= [ Zero(F), b ]; 
                    else
                       a:= One(F);
                    fi;
                    x2:= x2/a;
                    x3:= x3/(a^2);
                    x4:= x4/a;
                 fi;
                 name:= "L4_7( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, ", " );
                 Append( name, String( c1[1] ) );
                 Append( name, ", ");
                 Append( name, String( c1[2] ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,7, c1[1], c1[2] ] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),[x1,x2,x3,x4]);
                 return rec( name:= [ name, [c1[1],c1[2]] ], isom:= f );
              fi;
           fi;
        elif num = '2' then

           D:= TransposedMat( mat );
           x4:= x4+D[1][3]*x1+D[2][3]*x2-D[2][2]*x3;
           mat:= List( [x1,x2,x3], x -> Coefficients( b, x4*x ) );
           D:= TransposedMat( mat );
           
           if D[1][1] <> Zero(F) then
              x4:= x4/D[1][1];
              D:= D/D[1][1];
              w:= D[1][2];
              v:= D[2][1];

              if w <> Zero(F) then
                 x1:= w*x1;
                 v:= v*w;

                 return isomM9( L, x1, x2, x3, x4, v );

              else
                 #direct sum...
                 dd:= DirectSumDecomposition( L );
                 id:= LieAlgebraIdentification( dd[1] );
                 f:= id.isomorphism;
                 x1:= Image( f, Basis( Source(f) )[2] );
                 x2:= Image( f, Basis( Source(f) )[1] );
                 id:= LieAlgebraIdentification( dd[2] );
                 f:= id.isomorphismorphism;
                 x3:= Image( f, Basis( Source(f) )[2] );
                 x4:= Image( f, Basis( Source(f) )[1] );
                 name:= "L4_8( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,8] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                         [x1,x2,x3,x4]);
                 return rec( name:= [ name, [] ], isom:= f );
              fi;
           else
           
              if D[2][1] <> Zero(F) then
                 x4:= x4/D[2][1];
                 a:= D[1][2]/D[2][1];
                 if Characteristic(F) <> 2 then
                    a:= a - (1/4)*One(F);
                    return isomM9( L, x1/(4*One(F))+x2/(2*One(F)), 
                                      x1/(2*One(F)), x3, x3/(2*One(F))+x4, a );
                 else
                    return isomM10( L, x1, x2, x3, x4, a );
                 fi;
              else
                 if D[1][2] <> Zero(F) then
                    x4:= x4/D[1][2];
                    if Characteristic(F) <> 2 then
                       y1:= (x1+x2)/(2*One(F));
                       y2:= x2;
                       y3:= x3;
                       y4:= (x3+x4)/(2*One(F));
                       return isomN( L, y1, y2, y3, y4 );
                    else
                      name:= "L4_10( ";
                      Append( name, LieAlgDBField2String( F ) );
                      Append( name, ", " );
                      Append( name, String( Zero(F) ) );
                      Append( name, " )" );
                      K:= SolvableLieAlgebra( F, [4,10, Zero(F) ] );
                      f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                           [x2,x1,x3,x4]);
                      return rec( name:= [ name, [Zero(F)] ], isom:= f );
                    fi;
                 fi;
              fi;
           fi;            
        elif num = '3' then

           D:= TransposedMat( mat );
           a:= id.parameters[1];
           if a <> Zero(F) then
              x4:= x4-(D[1][3]/a-D[2][3])*x1+D[1][3]/a*x2-D[2][1]*x3;
              x4:= x4/D[1][1];
              return isomM9( L, x2, x1, x4, x3, a );
           else

              x4:= x4+D[2][3]*x1-D[2][1]*x3;
              mat:= List( [x1,x2,x3], x -> Coefficients( b, x4*x ) );
              D:= TransposedMat( mat );
              if D[1][3] = Zero(F) then
                 x4:= x4/D[1][1];
                 return isomM9( L, x2, x1, x4, x3, a );
              elif D[1][1] = Zero(F) then
                 x4:= x4/D[1][3];
                 name:= "L4_6( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, ", " );
                 Append( name, String( Zero(F) ) );
                 Append( name, ", ");
                 Append( name, String( Zero(F) ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,6, Zero(F), Zero(F)] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                      [-x4,x1,x2,x3]);
                 return rec( name:= [ name, [Zero(F),Zero(F)] ], isom:= f );
              else
                 x4:= x4/D[1][1];
                 x3:= -D[1][3]/D[1][1]*x1+x3;
                 return isomM9( L, x2, x1, x4, x3, a );
              fi;
           fi;
        else # i.e., num = '4'...

           D:= TransposedMat( mat );
           a:= id.parameters[1];
           if a <> Zero(F) and Characteristic(F) <> 2 then
              x4:= x4+D[2][3]*x1+D[1][3]/a*x2-D[2][1]*x3;
              x4:= x4/D[1][1];
              return isomM9( L, x1/(4*One(F))+x2/(2*One(F)), x1/(2*One(F)), 
                                x4, x3+x4/(2*One(F)), a-(1/4*One(F)) );
           elif a <> Zero(F) and Characteristic(F) = 2 then

              x4:= x4+D[2][3]*x1+D[1][3]/a*x2-D[2][1]*x3;
              if D[3][3] = Zero(F) then
                 x4:= x4/D[1][1];
                 return isomM10( L, x1, x2, x4, x3, a );
              elif D[1][1] <> Zero(F) then
                 x4:= x4/D[1][1];
                 b:= One(F) + D[3][3]/D[1][1];
                 return isomM11( L, x1, x2, x3, x4, a, b );
              else
                 if a <> One(F) then
                    x4:= x4/D[3][3];
                    y1:= (a*x1+x2)/(a+One(F));
                    y2:= a*(x1+x2)/(a+One(F));
                    y3:= x3;
                    y4:= x3+(a+1)*x4;
                    return isomM11( L, y1, y2, y3, y4, a, a );
                 else
                    return isomM11( L, x2, x1, x3, x4, One(F), Zero(F) );
                 fi;
              fi;
           else       
              x4:= x4+D[2][3]*x1-D[2][1]*x3;
              if D[1][3]=Zero(F) and D[3][1]=Zero(F) and D[1][1]=D[3][3] then
                 x4:= x4/D[1][1];
                 name:= "L4_12( ";
                 Append( name, LieAlgDBField2String( F ) );
                 Append( name, " )" );
                 K:= SolvableLieAlgebra( F, [4,12] );
                 f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                      [x1,x2,x3,x4]);
                 return rec( name:= [ name, [] ], isom:= f );
              else

                 if D[3][3] <> Zero(F) then
                    u1:= D[1][1];
                    u3:= D[3][1];
                    v1:= D[1][3];
                    v3:= D[3][3];
                    if v1 <> Zero(F) then
                       x1:= x1+(v3/v1)*x3;
                    elif u3 <> Zero(F) then
                       x3:= -(v3/u3)*x1+x3;
                    elif u1 = Zero(F) then
                       y1:= x1;
                       x1:= x3;
                       x2:= -x2;
                       x3:= y1;
                    else
                       y1:= x1;
                       x1:= x1/(One(F) - v3/u1)-x3;
                       x3:= -(v3/u1)*y1/(One(F) - v3/u1)+x3;  
                    fi;
                    K:= Subalgebra(  L, [x1,x2,x3] );
                    b:= Basis( K, [x1,x2,x3] );
                    c1:= Coefficients( b, x4*x1 );
                    c2:= Coefficients( b, x4*x2 );
                    c3:= Coefficients( b, x4*x3 );
                    mat:= [ c1, c2, c3 ];
                    D:= TransposedMat( mat );
                 fi; # now D[3][3] is zero...

                 u1:= D[1][1]; u3:= D[3][1]; v1:= D[1][3];
                 if u1 <> Zero(F) and v1 <> Zero(F) then
                    x4:= x4/u1;
                    x1:= (1/u1)*x1;
                    x2:= (1/(u1*v1))*x2;
                    x3:= (1/v1)*x3;
                    a:= (v1/u1)*(u3/u1);

                    name:= "L4_13( ";
                    Append( name, LieAlgDBField2String( F ) );
                    Append( name, ", " );
                    Append( name, String( a ) );
                    Append( name, " )" );
                    K:= SolvableLieAlgebra( F, [4,13, a] );
                    f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                        [x1,x2,x3,x4]);
                    return rec( name:= [ name, [a] ], isom:= f );
                 elif u1 <> Zero(F) and v1 = Zero(F) then
                    if u3 <> Zero(F) then
                       x4:= x4/u1;
                       x1:= (1/u3)*x1;
                       x2:= (1/(u1*u3))*x2;
                       x3:= (1/u1)*x3;
                       y1:= x1;
                       x1:= x1+x3;
                       x2:= -x2;
                       x3:= y1;
                    else
                       x4:= x4/u1;
                       x3:= x1+x3;
                    fi;
     
                    name:= "L4_13( ";
                    Append( name, LieAlgDBField2String( F ) );
                    Append( name, ", " );
                    Append( name, String( Zero(F) ) );
                    Append( name, " )" );
                    K:= SolvableLieAlgebra( F, [4,13, Zero(F)] );
                    f:= AlgebraHomomorphismByImages(K,L,Basis(K),
                                                        [x1,x2,x3,x4]);
                    return rec( name:= [ name, [Zero(F)] ], isom:= f );
                 elif u1 = Zero(F) and v1 <> Zero(F) then
                    x4:= x4/v1;
                    par:= u3/v1;
                    if HasIsFinite(F) and IsFinite(F) and 
                                         not par in [Zero(F),One(F)] then
                       if Characteristic(F) = 2 then
                          f:= Inverse( FrobeniusAutomorphism( F ) );
                          a:= Image( f, 1/par );
                       else
                          exp:= LogFFE( 1/par, PrimitiveRoot(F) );
                          if IsEvenInt( exp ) then 
                             a:= PrimitiveRoot(F)^(exp/2);
                          else
                             exp:= LogFFE( PrimitiveRoot(F)/par, 
                                                    PrimitiveRoot(F) );
                             a:= PrimitiveRoot(F)^(exp/2);
                          fi;
                       fi;
                    
                       x1:= a*x1;
                       x2:= a*x2;
                       x4:= a*x4; 
                       par:= a^2*par;
                    fi;
                    if par = Zero(F) then

                       name:= "L4_7( ";
                       Append( name, LieAlgDBField2String( F ) );
                       Append( name, ", " );
                       Append( name, String( Zero(F) ) );
                       Append( name, ", " );
                       Append( name, String( Zero(F) ) );
                       Append( name, " )" );
                       K:= SolvableLieAlgebra( F, [4,7, Zero(F), Zero(F)] );
                       f:= AlgebraHomomorphismByImages( K, L, Basis(K), 
                                                              [-x4,x1,x2,x3]);
                       return rec( name:= [ name, [Zero(F),Zero(F)] ], 
                                                               isom:= f );
                    else

                       
                       name:= "L4_14( ";
                       Append( name, LieAlgDBField2String( F ) );
                       Append( name, ", " );
                       Append( name, String( par ) );
                       Append( name, " )" );
                       K:= SolvableLieAlgebra( F, [4,14, par] );
                       f:= AlgebraHomomorphismByImages( K, L, Basis(K), 
                                                              [x1,x2,x3,x4] );
                       return rec( name:= [ name, [par] ], isom:= f );
                    fi;
                 else

                    x4:= x4/u3;
                    y1:= x3;
                    y2:= -x2;
                    y3:= x1;
                    y4:= x4;
                    name:= "L4_7( ";
                    Append( name, LieAlgDBField2String( F ) );
                    Append( name, ", " );
                    Append( name, String( Zero(F) ) );
                    Append( name, ", " );
                    Append( name, String( Zero(F) ) );
                    Append( name, " )" );
                    K:= SolvableLieAlgebra( F, [4, 7, Zero(F), Zero(F)] );
                    f:= AlgebraHomomorphismByImages( K, L, Basis(K), 
                                                            [-y4,y1,y2,y3] );
                    return rec( name:= [ name, [Zero(F),Zero(F)] ], isom:= f );
                 fi;
              fi;
           fi;
        fi;
     else
       Error( "dim > 4 not yet implemented" );
     fi;
        
end;

#========================================================================

liealg_hom:= function( K, L, p, i )

     return AlgebraHomomorphismByImagesNC( K, L, p, i );

end;

class_dim_le4:= function( L )

    # finds an isomorphism of the nilpotent Lie algebra L of dim <= 4,
    # to a "normal form".

    local F, C, C1, D, i, x, y, z, u, T, V, K, A, cc, b, a;

    F:= LeftActingDomain(L);
    if Dimension(L) = 3 then
       if IsLieAbelian( L ) then
          return rec( type:= [3,1], f:= liealg_hom( L, L, Basis(L), Basis(L) ) );
       else
          C:= LieCentre(L);
          for i in [1..3] do
              if not Basis(L)[i] in C then 
                 x:= Basis(L)[i]; break;
              fi;
          od;

          C:= Subalgebra( L, [x,Basis(C)[1]] );
          for i in [1..3] do
              if not Basis(L)[i] in C then 
                 y:= Basis(L)[i]; break;
              fi;
          od;

          T:= EmptySCTable( 3, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          K:= LieAlgebraByStructureConstants( F, T );
          return rec( type:= [3,2], f:= liealg_hom( L, K, [x,y,x*y], Basis(K) ) );
       fi; 
    elif Dimension(L) = 4 then
       if IsLieAbelian(L) then
          return rec( type:= [4,1], f:= liealg_hom( L, L, Basis(L), Basis(L) ) );
       else
          C:= LieCentre(L);
          if Dimension(C) = 2 then
             for i in [1..4] do
                 if not Basis(L)[i] in C then 
                    x:= Basis(L)[i]; break;
                 fi;
             od;

             C1:= Subalgebra( L, [ Basis(C)[1], Basis(C)[2], x ] );
             for i in [1..4] do
                 if not Basis(L)[i] in C1 then 
                    y:= Basis(L)[i]; break;
                 fi;
             od;

             A:= Subalgebra( L, [ x*y ]);
             if Basis(C)[1] in A then
                u:= Basis(C)[2];
             else
                u:= Basis(C)[1];
             fi;

             T:= EmptySCTable( 4, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,3] );
             K:= LieAlgebraByStructureConstants( F, T );
             return rec( type:= [4,2], f:= liealg_hom( L, K, [x,y,x*y,u], Basis(K) ) );

          elif Dimension(C) = 1 then

             D:= LieDerivedSubalgebra( L );
             b:= ShallowCopy( Basis(D) );
             cc:= [ ];
             for i in [1..4] do
                 x:= Basis(L)[i];
                 if not x in D then 
                    Add( cc, x );
                    Add( b, x );
                    D:= Subalgebra( L, b ); 
                 fi;
             od;

             z:= cc[1]*cc[2];
             if cc[1]*z <> Zero(L) then
                x:= cc[1]; y:= cc[2];
             else 
                x:= cc[2]; y:= cc[1];
             fi;

             z:= x*y; u:= x*z;

             # we have to change y to make sure that [x,y]=z, and
             # [y,u]=0.
             V:= Basis( Subalgebra( L, [u] ), [u] );
             a:= Coefficients( V, y*z )[1];
             y:= -a*x+y;

             T:= EmptySCTable( 4, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,3] );
             SetEntrySCTable( T, 1, 3, [1,4] );
             K:= LieAlgebraByStructureConstants( F, T );
             return rec( type:= [4,3], f:= liealg_hom( L, K, [x,y,z,u], Basis(K) ) );

          fi;
       fi;
    fi;

end;


skew_symm_NF:= function( V, f )

    # here V is a vector space, and f : VxV -> F a skew-symmetric
    # bilinear function; we compute a basis of V such that f has standard form.
    # Here f is just given as a GAP function.

    local b, dim, found, i, j, c, W, bU, u, v, bb, done, x, w;  
    b:= Basis(V);
    dim:= Dimension(V);
    found:= false;
    for i in [1..dim] do
        if found then break; fi;
        for j in [i+1..dim] do
            c:= f(b[i],b[j]);
            if not IsZero(c) then
               u:= [b[i]]; v:= [b[j]/c];
               found:= true; break;
            fi;
        od;
    od;

    done:= false;
    while not done do
          # consider the linear map T: V --> V defined by
          # T(w) = \sum_i f(w,v[i])u[i] - f(w,u[i])v[i],
          # then T is projection onto the space spanned by the elts in u,v.
          # set U = (1-T)V; then T is zero on U, and V is the direct 
          # sum of U and the space spanned by u,v. We compute U.
          W:= MutableBasis( LeftActingDomain(V), [], Zero(V) );
          for x in b do
              w:= x-Sum( List( [1..Length(u)], k -> f(x,v[k])*u[k]-f(x,u[k])*v[k] ) );
              if not IsContainedInSpan( W, w ) then
                 CloseMutableBasis( W, w );
              fi;
          od;
          bU:= BasisVectors(W);
 
          found:= false;
          for i in [1..Length(bU)] do
              if found then break; fi;
              for j in [i+1..Length(bU)] do
                  c:= f(bU[i],bU[j]);
                  if not IsZero(c) then
                     Add( u, bU[i] ); Add( v, bU[j]/c );
                     found:= true; break;
                  fi;
              od;
          od;
          if not found then
             done:= true;
             bb:= [ ];
             for i in [1..Length(u)] do
                 Add( bb, u[i] );          
                 Add( bb, v[i] );          
             od;
             Append( bb, bU );
          elif 2*Length(u) = dim then
             done:= true;
             bb:= [ ];
             for i in [1..Length(u)] do
                 Add( bb, u[i] );          
                 Add( bb, v[i] );          
             od;
          fi;
    od;

    return bb;

end;


class_dim_5:= function( K )

    local F, C, D, ind, i, bL, bsp, L, W, t, T, d, N, imgs, p, s, coc1, coc2, tau, M, coc21, coc22,
          bM, cz, cx, type, a, b, c, m, mat, cf, c1, c2, x, mt, sp, y, r;

    if IsLieAbelian(K) then 
       return rec( type:= [5,1], f:= liealg_hom( K, K, Basis(K), Basis(K) ) );
    fi;

    F:= LeftActingDomain( K );

    # see if there is an abelian component (necessarily of dim 1)
    C:= LieCentre( K );
    D:= LieDerivedSubalgebra(K);
    ind:= 0;
    for i in [1..Dimension(C)] do
        if not Basis(C)[i] in D then
           ind:= i;
           break;
        fi;
    od;

    if ind > 0 then

       bL:= ShallowCopy( Basis(D) );
       bsp:= ShallowCopy( bL );
       Add( bsp, Basis(C)[ind] );
       sp:= MutableBasis( F, bsp );
       for i in [1..Dimension(K)] do
           if not IsContainedInSpan( sp, Basis(K)[i] ) then
              Add( bL, Basis(K)[i] );
              CloseMutableBasis( sp, Basis(K)[i] );
           fi;
       od;
       # now K = bL \oplus C[ind].

       L:= Subalgebra( K, bL );
       bL:= ShallowCopy( Basis(L) );
       Add( bL,  Basis(C)[ind] );
       W:= Basis( K, bL );

       # so now bL is a basis of K, the first n-1 elements form 
       # a basis of an ideal, the last element of an abelian ideal.
       # We have an isomorphism of K to the direct sum of L with a
       # 1-dim ideal; write x\in K on the basis bL. 

       r:= class_dim_le4( L ); type:= r.type; tau:= r.f; 
       T:= ShallowCopy( StructureConstantsTable( Basis( Range( tau ) ) ) );
       d:= Dimension( Range( tau ) );
       for i in [1..d] do
           T[i]:= ShallowCopy( T[i] );
           Add( T[i], [ [], [] ] );
       od;
       T[d+3]:= T[d+2]; T[d+2]:= T[d+1];
       T[d+1]:= List( [1..d+1], x -> [ [], [] ] );

       N:= LieAlgebraByStructureConstants( F, T );

       imgs:= [ ];
       for x in Basis(K) do
           cx:= Coefficients( W, x );
           y:= Image( tau, LinearCombination( Basis(L), cx{[1..Length(cx)-1]} ) );
           y:= ShallowCopy( Coefficients( Basis( Range(tau) ), y ) );
           Add( y, cx[ Length(cx) ]  );
           Add( imgs, LinearCombination( Basis(N), y ) );
       od;

       return rec( type:= [5,type[2]], f:= liealg_hom( K, N, Basis(K), imgs ) );

    fi;

    # if there are no central components, then we look at the 
    # cocycle we get by dividing by the centre, and so on.

    C:= LieCentre(K);
    p:= NaturalHomomorphismByIdeal( K, C );
    L:= Range(p);
    s:= function( v ) return PreImagesRepresentative( p, v ); end;
    coc1:= function( u, v ) return s(u)*s(v)-s(u*v); end;  

    r:= class_dim_le4( L ); type:= r.type; tau:= r.f;
    M:= Range( tau );
    coc2:= function( u, v ) return coc1( PreImage(tau,u), PreImage(tau,v) ); end;
    # i.e., the cocycle for M
    # now we need to map coc2 to normal form, according to the type of M 

    if type = [4,1] then
    
       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
        
       bM:= Basis( M, skew_symm_NF( M, coc21 ) );
       T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,5] );
       SetEntrySCTable( T, 3, 4, [1,5] );
       N:= LieAlgebraByStructureConstants( F, T );

       imgs:= [ ];
       for x in Basis(K) do
           # the coordinate of the central part of x:
           # this will be the coordinate of the central part of the 
           # image of x. 
           cz:= Coefficients( Basis(C), x-s(Image(p,x)) )[1];       
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image(p,x) ) ) );    
           Add( cx, cz );
           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;

       return rec( type:= [5,4], f:= liealg_hom( K, N, Basis(K), imgs ) );

    elif type = [4,2] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );
       a:= coc21( bM[1], bM[3] );
       b:= coc21( bM[1], bM[4] );
       c:= coc21( bM[2], bM[3] );
       d:= coc21( bM[2], bM[4] );

       mat:= IdentityMat( 4, F ); 

       if IsZero( a ) then
          # c is non zero
          m:= IdentityMat( 4, F );
          m[2][1]:= 1;
          mat:= m;
          a:= c; b:= b+d; 
       fi;

       m:= IdentityMat( 4, F );
       m[1][1]:= 1/a;
       m[1][2]:= -c;
       m[2][2]:= a;
       m[4][4]:= 1/(a*d-b*c);
       m[3][4]:= -m[4][4]*b/a;
       mat:= mat*m;
      
       mat:= TransposedMat( mat );
       bM:= Basis( M, List( mat, x -> LinearCombination( Basis(M), x ) ) );
       T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,3] );
       SetEntrySCTable( T, 1, 3, [1,5] );
       SetEntrySCTable( T, 2, 4, [1,5] );
       N:= LieAlgebraByStructureConstants( F, T );

       imgs:= [ ];
       for x in Basis(K) do
           cz:= Coefficients( Basis(C), x-s(Image(p,x)) )[1];
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
           Add( cx, cz );

           # effectively subtract a coboundary (i.e., apply one further
           # isomorphism): 
           # Here we have (in the normal form Lie algebra)
           # [x1,x2]=x3. Hence c(x1,x2)=1, rest 0 is a coboundary.
           # The isomorphism corresponding to the subtraction of c
           # from the cocycle, subtracts coc21( x1, x2 )*x5 from
           # the element. (Rather vague comment...).
           cf:= coc21( bM[1], bM[2] );
           cx[5]:= cx[5] - cf*cx[3];

           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;

       return rec( type:= [5,5], f:= liealg_hom( K, N, Basis(K), imgs ) );           

    elif type = [4,3] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= Basis(M);
       a:= coc21( bM[1], bM[4] );
       b:= coc21( bM[2], bM[3] );

       if not IsZero(b) then

          T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,5] );
          SetEntrySCTable( T, 2, 3, [1,5] );
          N:= LieAlgebraByStructureConstants( F, T );
          
          imgs:= [ ];
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s( Image(p,x) ) )[1];           
              cx:= ShallowCopy( Coefficients( Basis(M), Image( tau, Image( p, x ) ) ) );
              cf:= a/b;
              cx[1]:= cx[1]*cf; cx[2]:= cx[2]*cf; cx[3]:= cx[3]*cf^2; cx[4]:= cx[4]*cf^3;
              Add( cx, cf^4*cz/a );
              
              # take care of the coboundary...
              c1:= coc21( cf^-1*Basis(M)[1],cf^-1*Basis(M)[2] );
              cx[5]:= cx[5] - c1*(cf^4/a)*cx[3];

              c1:= coc21( cf^-1*Basis(M)[1],cf^-2*Basis(M)[3] );
              cx[5]:= cx[5] - c1*(cf^4/a)*cx[4];

              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [5,6], f:= liealg_hom( K, N, Basis(K), imgs ) );

       else

          T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,5] );
          N:= LieAlgebraByStructureConstants( F, T );
          
          imgs:= [ ];
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s( Image( p, x ) ) )[1];           
              cx:= ShallowCopy( Coefficients( Basis(M), Image( tau, Image(p,x) ) ) );
              Add( cx, cz/a );
              
              # take care of the coboundary...
              cf:= coc21( Basis(M)[1], Basis(M)[2] );
              cx[5]:= cx[5] - cf/a*cx[3];

              cf:= coc21( Basis(M)[1], Basis(M)[3] );
              cx[5]:= cx[5] - cf/a*cx[4];

              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [5,7], f:= liealg_hom( K, N, Basis(K), imgs ) );

       fi;

    elif type = [ 3, 1 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       coc22:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[2]; end;

       bM:= skew_symm_NF( M, coc21 );

       b:= coc22( bM[1], bM[3] ); c:= coc22(bM[2],bM[3]);
       if IsZero(b) then
          # change the basis bM so that it becomes nonzero.
          bM[1]:= bM[1]+bM[2];
          b:= coc22(bM[1],bM[3]); c:= coc22(bM[2],bM[3]);
       fi;

       # change the basis so that c becomes zero... 
       bM[2]:= bM[2]-c/b*bM[1];
 
       bM:= Basis( M, bM );
       a:= coc22(bM[1],bM[2]);
       b:= coc22(bM[1],bM[3]);

       T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,4] );
       SetEntrySCTable( T, 1, 3, [1,5] );
       N:= LieAlgebraByStructureConstants( F, T );

       imgs:= [ ];
       for x in Basis(K) do
           # the coordinate of the central part of x:
           cz:= Coefficients( Basis(C), x-s( Image( p, x ) ) );           
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );

           # account for the base change in the centre:
           cz[2]:= -cz[1]*a/b+cz[2]/b;
           Append( cx, cz );
           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;

       return rec( type:= [5,8], f:= liealg_hom( K, N, Basis(K), imgs ) );

    elif type = [ 3, 2 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       coc22:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[2]; end;
       bM:= Basis(M);
       m:= [[coc21(bM[1],bM[3]),coc21(bM[2],bM[3])],
            [coc22(bM[1],bM[3]),coc22(bM[2],bM[3])] ];

       m:= m^-1;
       mt:= TransposedMat(m);

       T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,3] );
       SetEntrySCTable( T, 1, 3, [1,4] );
       SetEntrySCTable( T, 2, 3, [1,5] );
       N:= LieAlgebraByStructureConstants( F, T );

       c1:= mt[1][1]*coc21(bM[1],bM[2])+mt[2][1]*coc22(bM[1],bM[2]);
       c2:= mt[1][2]*coc21(bM[1],bM[2])+mt[2][2]*coc22(bM[1],bM[2]);
          
       imgs:= [ ];
       for x in Basis(K) do
           cz:= Coefficients( Basis(C), x-s( Image( p, x ) ) );           
           cx:= ShallowCopy( Coefficients( Basis(M), Image( tau, Image( p, x ) ) ) );
           Append( cx, cz*mt );
              
           # take care of the coboundary...
           cx[4]:= cx[4] - c1*cx[3];
           cx[5]:= cx[5] - c2*cx[3];
           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;
       return rec( type:= [5,9], f:= liealg_hom( K, N, Basis(K), imgs ) );


    fi;


end;


comp_mat:= function( x, y, det )

    local a,b,c,d;

    if IsZero(y) then
       c:= 0; a:= 1/x; d:= x*det;b:= 0;
    else
       a:= -y*det; c:= -y*det; d:= x*det; b:= (1+x*y*det)/y;
    fi;
    return [[a,b],[c,d]];

end;


class_dim_6:= function( K )

    local F, C, D, ind, i, bL, bsp, sp, W, r, T, d, N, imgs, x, cx, g, p, L, 
          s, coc1, coc2, coc21, coc22, coc23, type, tau, M, bM, a, b, c, m, 
          v1, v2, e, f, c1, c2, c3, c4, a21, tt, cz1, cx1, s13, s24, s14, 
          t, u, v, cf, y, cz, a42, store, q, cc, f1, f2, f3, f4, f5, cf1; 

    if IsCommutative(K) then 
       return rec( type:= [6,1], f:= liealg_hom( K, K, Basis(K), Basis(K) ) );
    fi;

    F:= LeftActingDomain( K );

    # see if there is an abelian component (necessarily of dim 1)
    C:= LieCentre( K );
    D:= LieDerivedSubalgebra(K);
    ind:= 0;
    for i in [1..Dimension(C)] do
        if not Basis(C)[i] in D then
           ind:= i;
           break;
        fi;
    od;

    if ind > 0 then

       bL:= ShallowCopy( Basis(D) );
       bsp:= ShallowCopy( bL );
       Add( bsp, Basis(C)[ind] );
       sp:= MutableBasis( F, bsp );
       for i in [1..Dimension(K)] do
           if not IsContainedInSpan( sp, Basis(K)[i] ) then
              Add( bL, Basis(K)[i] );
              CloseMutableBasis( sp, Basis(K)[i] );
           fi;
       od;
       # now K = bL \oplus C[ind].

       L:= Subalgebra( K, bL );
       bL:= ShallowCopy( Basis(L) );
       Add( bL,  Basis(C)[ind] );
       W:= Basis( K, bL );

       # so now bL is a basis of K, the first n-1 elements form 
       # a basis of an ideal, the last element of an abelian ideal.
       # We have an isomorphism of K to the direct sum of L with a
       # 1-dim ideal; write x\in K on the basis bL. 

       r:= class_dim_5( L ); type:= r.type; tau:= r.f; 
       T:= ShallowCopy( StructureConstantsTable( Basis( Range( tau ) ) ) );
       d:= Dimension( Range( tau ) );
       for i in [1..d] do
           T[i]:= ShallowCopy( T[i] );
           Add( T[i], [ [], [] ] );
       od;
       T[d+3]:= T[d+2]; T[d+2]:= T[d+1];
       T[d+1]:= List( [1..d+1], x -> [ [], [] ] );

       N:= LieAlgebraByStructureConstants( F, T );

       imgs:= [ ];
       for x in Basis(K) do
           cx:= Coefficients( W, x );
           y:= Image( tau, LinearCombination( Basis(L), cx{[1..Length(cx)-1]} ) );
           y:= ShallowCopy( Coefficients( Basis( Range(tau) ), y ) );
           Add( y, cx[ Length(cx) ]  );
           Add( imgs, LinearCombination( Basis(N), y ) );
       od;

       return rec( type:= [6,type[2]], f:= liealg_hom( K, N, Basis(K), imgs ) );

    fi;


    # if there are no central components, then we look at the 
    # cocycle we get by dividing by the centre, and so on.

    C:= LieCentre(K);
    p:= NaturalHomomorphismByIdeal( K, C );
    L:= Range(p);
    s:= function( v ) return PreImagesRepresentative( p, v ); end;
    coc1:= function( u, v ) return s(u)*s(v)-s(u*v); end;  

    if Dimension(L) <= 4 then
       r:= class_dim_le4( L );
    else
       r:= class_dim_5( L );
    fi;
    type:= r.type; tau:= r.f;
    M:= Range( tau );
    coc2:= function( u, v ) return coc1( PreImage(tau,u), PreImage(tau,v) ); end;
    # i.e., the cocycle for M
    # now we need to map coc2 to normal form, according to the type of M 

    if type = [ 5, 2 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;

       bM:= ShallowCopy( BasisVectors( Basis( (M) ) ) );

       # we change the basis bM so that the cocycle is in "normal form":

       a:= coc21(bM[1],bM[3]); d:= coc21(bM[2],bM[3]);
 
       m:= comp_mat( a, d, One(F) );
       v1:= m[1][1]*bM[1]+m[1][2]*bM[2];
       v2:= m[2][1]*bM[1]+m[2][2]*bM[2];
       bM[1]:= v1; bM[2]:= v2;

       b:= coc21(bM[1],bM[4]); c:= coc21(bM[1],bM[5]);
       bM[4]:= bM[4]-b*bM[3];
       bM[5]:= bM[5]-c*bM[3];

       e:= coc21(bM[2],bM[4]); f:= coc21(bM[2],bM[5]); 
       g:= coc21(bM[4],bM[5]);

       if not (IsZero(e) and IsZero(f)) then
          m:= comp_mat( e, f, 1/g );
          v1:= m[1][1]*bM[4]+m[1][2]*bM[5];
          v2:= m[2][1]*bM[4]+m[2][2]*bM[5];
          bM[4]:= v1; bM[5]:= v2;

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,6] );
          SetEntrySCTable( T, 4, 5, [1,6] );
          N:= LieAlgebraByStructureConstants( F, T );

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          bM:= Basis( M, bM );
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s( Image( p, x ) ) );  
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3];

              # isomorphism to M_2 (see paper):
              cx[5]:= cx[5]-cx[2];
              Add( imgs, LinearCombination( Basis(N), cx )  );
          od;
          return rec( type:= [6,10], f:= liealg_hom( K, N, Basis(K), imgs ) );

       else

          bM[4]:= bM[4]/g;
          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,6] );
          SetEntrySCTable( T, 4, 5, [1,6] );
          N:= LieAlgebraByStructureConstants( F, T );
          
          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          bM:= Basis( M, bM );
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );

              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3];
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:=[6,10], f:= liealg_hom( K, N, Basis(K), imgs ) );

       fi;
    elif type = [5,3] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;

       bM:= ShallowCopy( BasisVectors( Basis(M) ) );

       # we change the basis bM so that the cocycle is in "normal form":

       a:= coc21(bM[1],bM[4]);

       bM[2]:= bM[2]/a; bM[3]:= bM[3]/a; bM[4]:= bM[4]/a;
       b:= coc21(bM[1],bM[5]); d:= coc21(bM[2],bM[5]);
       bM[1]:= bM[1]-b/d*bM[2];
       bM[5]:= bM[5]/d;

       c:= coc21( bM[2],bM[3] );
       if not IsZero(c) then

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,6] );
          SetEntrySCTable( T, 2, 3, [1,6] );
          SetEntrySCTable( T, 2, 5, [1,6] );
          N:= LieAlgebraByStructureConstants( F, T );

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          bM:= Basis( M, bM );
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3]-c2*cx[4];

              # make c equal to 1...
              cx[1]:= cx[1]/c; cx[2]:= cx[2]/c; cx[3]:= cx[3]/c^2;
              cx[4]:= cx[4]/c^3; cx[5]:= cx[5]/c^3; cx[6]:= cx[6]/c^4;
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [6,11], f:= liealg_hom( K, N, Basis(K), imgs ) );

       else

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,6] );
          SetEntrySCTable( T, 2, 5, [1,6] );
          N:= LieAlgebraByStructureConstants( F, T );

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          bM:= Basis(M,bM);
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3]-c2*cx[4];
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [6,12], f:= liealg_hom( K, N, Basis(K), imgs ) );

       fi;

    elif type = [5,5] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );;

       # we change the basis bM so that the cocycle is in "normal form":

       b:= coc21(bM[1],bM[5]);
       bM[2]:= bM[2]/b; bM[3]:= bM[3]/b; bM[5]:= bM[5]/b;
       a:= coc21(bM[1],bM[4]); c:= coc21(bM[2],bM[3]);
       bM[1]:= bM[1]-a*bM[3]; bM[2]:= bM[2]+c*bM[4];

       imgs:= [ ];
       c1:= coc21(bM[1],bM[2]);
       c2:= coc21(bM[1],bM[3]);
       d:= coc21(bM[2],bM[4])-c2;

       T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,3] );
       SetEntrySCTable( T, 1, 3, [1,5] );
       SetEntrySCTable( T, 2, 4, [1,5] );
       SetEntrySCTable( T, 1, 5, [1,6] );
       SetEntrySCTable( T, 3, 4, [1,6] );
       N:= LieAlgebraByStructureConstants( F, T );
       bM:= Basis(M,bM);
       for x in Basis(K) do
           cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
           Append( cx, cz );
              
           # take care of the coboundary...
           cx[6]:= cx[6] - c1*cx[3]-c2*cx[5];
           
           if not IsZero(d) then
              # map it to 1:
              cx[1]:= cx[1]/d; cx[3]:= cx[3]/d; cx[4]:= cx[4]/d^2;
              cx[5]:= cx[5]/d^2; cx[6]:= cx[6]/d^3; 
              # make isom with the Lie alg where d=0:
              cx[5]:= cx[5]+(cx[2]+cx[3])/2;
              cx[4]:= cx[4]+cx[1]/2;
              cx[3]:= cx[3]+cx[2];
           fi;
           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;
       return rec( type:= [6,13], f:= liealg_hom( K, N, Basis(K), imgs ) );
       
    elif type = [ 5, 6 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );

       # we change the basis bM so that the cocycle is in "normal form":

       a:= coc21(bM[1],bM[5]); 
       b:= coc21(bM[2],bM[3])-coc21(bM[1],bM[4]); 
       c:= coc21(bM[2],bM[5]);

       if not IsZero(c) then
          a21:= -a/c; a42:= -(a^2/c^2+b/c)/2;
          bM[1]:= bM[1]+a21*bM[2];
          bM[2]:= bM[2]+a42*bM[4];
          bM[3]:= bM[3]+a42*bM[5];
          bM[4]:= bM[4]+a21*bM[5];
          c:= coc21(bM[2],bM[5]);

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          c3:= coc21(bM[1],bM[4]);

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,5] );
          SetEntrySCTable( T, 2, 3, [1,5] );
          SetEntrySCTable( T, 2, 5, [1,6] );
          SetEntrySCTable( T, 3, 4, [-1,6] );
          N:= LieAlgebraByStructureConstants( F, T );
          bM:= Basis( M, bM );
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3]-c2*cx[4]-c3*cx[5];
           
              # make c=1;
              cx[6]:= cx[6]/c;
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [6,14], f:= liealg_hom( K, N, Basis(K), imgs ) );
       else

          a21:= b/(2*a); 
          bM[1]:= bM[1]+a21*bM[2];
          bM[4]:= bM[4]+a21*bM[5];

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          c3:= coc21(bM[1],bM[4]);

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,5] );
          SetEntrySCTable( T, 2, 3, [1,5] );
          SetEntrySCTable( T, 1, 5, [1,6] );
          SetEntrySCTable( T, 2, 4, [1,6] );
          N:= LieAlgebraByStructureConstants( F, T );
          bM:= Basis( M, bM );
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3]-c2*cx[4]-c3*cx[5];

              # make a=1:
              cx[6]:= cx[6]/a;
           
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [6,15], f:= liealg_hom( K, N, Basis(K), imgs ) );
       fi;

    elif type = [ 5, 7 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );

       # we change the basis bM so that the cocycle is in "normal form":

       a:= coc21(bM[1],bM[5]); 
       b:= coc21(bM[2],bM[3]);
       c:= coc21(bM[2],bM[5]);

       if not IsZero(c) then
          a21:= -a/c; a42:= -(b/c)/2;
          bM[1]:= bM[1]+a21*bM[2];
          bM[2]:= bM[2]+a42*bM[4];
          bM[3]:= bM[3]+a42*bM[5];

          c:= coc21(bM[2],bM[5]);

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          c3:= coc21(bM[1],bM[4]);

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,3] );
          SetEntrySCTable( T, 1, 3, [1,4] );
          SetEntrySCTable( T, 1, 4, [1,5] );
          SetEntrySCTable( T, 2, 5, [1,6] );
          SetEntrySCTable( T, 3, 4, [-1,6] );
          N:= LieAlgebraByStructureConstants( F, T );
          bM:= Basis( M, bM );
          for x in Basis(K) do
              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );
              
              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3]-c2*cx[4]-c3*cx[5];
           
              # make c=1;
              cx[6]:= cx[6]/c;
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [6,16], f:= liealg_hom( K, N, Basis(K), imgs ) );
       else

          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          c3:= coc21(bM[1],bM[4]);

          if not IsZero(b) then 

             T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,3] );
             SetEntrySCTable( T, 1, 3, [1,4] );
             SetEntrySCTable( T, 1, 4, [1,5] );
             SetEntrySCTable( T, 1, 5, [1,6] );
             SetEntrySCTable( T, 2, 3, [1,6] );
             N:= LieAlgebraByStructureConstants( F, T );
             tt:= [ 6, 17 ];
          else

             T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,3] );
             SetEntrySCTable( T, 1, 3, [1,4] );
             SetEntrySCTable( T, 1, 4, [1,5] );
             SetEntrySCTable( T, 1, 5, [1,6] );
             N:= LieAlgebraByStructureConstants( F, T );
             tt:= [ 6, 18 ];
          fi;

          bM:= Basis( M, bM );
          b:= b/a; #(we will divide by a, also changing b)

          for x in Basis(K) do

              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );

              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[3]-c2*cx[4]-c3*cx[5];

              # make a=1:
              cx[6]:= cx[6]/a;
 
              if not IsZero(b) then
                 # make it 1:
                 cx[1]:= cx[1]/b; cx[2]:= cx[2]/b^2; cx[3]:= cx[3]/b^3;
                 cx[4]:= cx[4]/b^4; cx[5]:= cx[5]/b^5; cx[6]:= cx[6]/b^6;
              fi;
            
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= tt, f:= liealg_hom( K, N, Basis(K), imgs ) );
       fi;       

    elif type = [ 5, 8 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );

       # we change the basis bM so that the cocycle is in "normal form":

       d:= coc21(bM[2],bM[4]); 
       e:= coc21(bM[2],bM[5]);
       f:= coc21(bM[3],bM[5]);
       if not IsZero(f) then
          bM[2]:= bM[2]-e/f*bM[3];
          bM[4]:= bM[4]-e/f*bM[5];
       elif not IsZero(d) then
          bM[3]:= bM[3]-e/d*bM[2];
          bM[5]:= bM[5]-e/d*bM[4];
       else
          v:= bM[2];
          bM[2]:= bM[2]-bM[3];
          bM[3]:= bM[3]+v;
          v:= bM[4];
          bM[4]:= bM[4]-bM[5];
          bM[5]:= v+bM[5];
       fi;

       d:= coc21(bM[2],bM[4]);
       if not IsZero(d) then

          # make d=1:
          bM[1]:= bM[1]/d; bM[4]:= bM[4]/d; bM[5]:= bM[5]/d;
          # and a=c=0
          a:= coc21(bM[1],bM[4]);
          c:= coc21(bM[2],bM[3]);
          bM[1]:= bM[1]-a*bM[2];
          bM[3]:= bM[3]-c*bM[4];

          b:= coc21(bM[1],bM[5]);

          if IsZero(b) then
             f:= coc21(bM[3],bM[5]);
             T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,4] );
             SetEntrySCTable( T, 1, 3, [1,5] );
             SetEntrySCTable( T, 2, 4, [1,6] );
             SetEntrySCTable( T, 3, 5, [f,6] );
             N:= LieAlgebraByStructureConstants( F, T );

             bM:= Basis( M, bM );

             imgs:= [ ];
             c1:= coc21(bM[1],bM[2]);
             c2:= coc21(bM[1],bM[3]);
             for x in Basis(K) do

                 cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
                 cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                 Append( cx, cz );

                 # take care of the coboundary...
                 cx[6]:= cx[6] - c1*cx[4]-c2*cx[5];

                 Add( imgs, LinearCombination( Basis(N), cx ) );
             od;
             return rec( type:= [ 6, 19, f ], f:= liealg_hom( K, N, Basis(K), imgs ) );

          else # i.e., b <> 0

             bM[3]:= bM[3]/b;
             bM[5]:= bM[5]/b;
             f:= coc21(bM[3],bM[5]);

             if not IsZero(f) then

                T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                SetEntrySCTable( T, 1, 2, [1,4] );
                SetEntrySCTable( T, 1, 3, [1,5] );
                SetEntrySCTable( T, 2, 4, [1,6] );
                SetEntrySCTable( T, 3, 5, [f,6] );
                N:= LieAlgebraByStructureConstants( F, T );
                bM:= Basis( M, bM );
                imgs:= [ ];
                c1:= coc21(bM[1],bM[2]);
                c2:= coc21(bM[1],bM[3]);

                for x in Basis(K) do

                    cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
                    cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                    Append( cx, cz );

                    cx[3]:= cx[3] + cx[1]/f;

                    # take care of the coboundary...
                    cx[6]:= cx[6] - c1*cx[4]-c2*cx[5];

                    Add( imgs, LinearCombination( Basis(N), cx ) );
                od;
                return rec( type:= [ 6, 19, f ], f:= liealg_hom( K, N, Basis(K), imgs ) );
             else # i.e., f=0
                             
                T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                SetEntrySCTable( T, 1, 2, [1,4] );
                SetEntrySCTable( T, 1, 3, [1,5] );
                SetEntrySCTable( T, 1, 5, [1,6] );
                SetEntrySCTable( T, 2, 4, [1,6] );
                N:= LieAlgebraByStructureConstants( F, T );
 
                bM:= Basis( M, bM );

                imgs:= [ ];
                c1:= coc21(bM[1],bM[2]);
                c2:= coc21(bM[1],bM[3]);
                for x in Basis(K) do

                    cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
                    cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                    Append( cx, cz );

                    # take care of the coboundary...
                    cx[6]:= cx[6] - c1*cx[4]-c2*cx[5];

                    Add( imgs, LinearCombination( Basis(N), cx ) );
                od;
                return rec( type:= [ 6, 20 ], f:= liealg_hom( K, N, Basis(K), imgs ) );
             fi;
          fi;
       else # i.e., d=0

          # make f=1:
          bM[1]:= bM[1]/f; bM[4]:= bM[4]/f; bM[5]:= bM[5]/f;
          # and c=0, a=1
          a:= coc21(bM[1],bM[4]);
          c:= coc21(bM[2],bM[3]);
          bM[2]:= bM[2]+c*bM[5];
          bM[2]:= bM[2]/a; bM[4]:= bM[4]/a;

          b:= coc21(bM[1],bM[5]);        

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,4] );
          SetEntrySCTable( T, 1, 3, [1,5] );
          SetEntrySCTable( T, 1, 5, [1,6] );
          SetEntrySCTable( T, 2, 4, [1,6] );
          N:= LieAlgebraByStructureConstants( F, T );

          bM:= Basis( M, bM );
          imgs:= [ ];
          c1:= coc21(bM[1],bM[2]);
          c2:= coc21(bM[1],bM[3]);
          for x in Basis(K) do

              cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz );

              # take care of the coboundary...
              cx[6]:= cx[6] - c1*cx[4]-c2*cx[5];

              if not IsZero(b) then
                 cx[2]:= cx[2]/b^2; cx[3]:= cx[3]/b; cx[4]:= cx[4]/b^2;
                 cx[5]:= cx[5]/b; cx[6]:= cx[6]/b^2;
                 cx[3]:= cx[3]+cx[1];
              fi;
              cx1:= ShallowCopy( cx );
              cx1[2]:= cx[3]; cx1[3]:= cx[2];
              cx1[4]:= cx[5]; cx1[5]:= cx[4];

              Add( imgs, LinearCombination( Basis(N), cx1 ) );
          od;
          return rec( type:= [ 6, 20 ], f:= liealg_hom( K, N, Basis(K), imgs ) );

       fi;

    elif type = [ 5, 9 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );

       # we change the basis bM so that the cocycle is in "normal form":

       a:= coc21(bM[1],bM[4]); 
       b:= coc21(bM[1],bM[5]);
       c:= coc21(bM[2],bM[5]);
       if not IsZero(c) then
          bM[1]:= bM[1]-b/c*bM[2];
          bM[4]:= bM[4]-b/c*bM[5];
       elif not IsZero(a) then
          bM[2]:= bM[2]-b/a*bM[1];
          bM[5]:= bM[5]-b/a*bM[4];
       else
          v:= bM[1];
          bM[1]:= bM[1]-bM[2];
          bM[2]:= v+bM[2];
          bM[3]:= 2*bM[3];
          v:= bM[4];
          bM[4]:= 2*(bM[4]-bM[5]);
          bM[5]:= 2*(v+bM[5]);
       fi;

       a:= coc21(bM[1],bM[4]);
       c:= coc21(bM[2],bM[5]);

       T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,3] );
       SetEntrySCTable( T, 1, 3, [1,4] );
       SetEntrySCTable( T, 2, 3, [1,5] );
       SetEntrySCTable( T, 1, 4, [1,6] );
       SetEntrySCTable( T, 2, 5, [c/a,6] );
       N:= LieAlgebraByStructureConstants( F, T );
       bM:= Basis( M, bM );
       imgs:= [ ];
       c1:= coc21(bM[1],bM[2]);
       c2:= coc21(bM[1],bM[3]);
       c3:= coc21(bM[2],bM[3]);
       for x in Basis(K) do

           cz:= Coefficients( Basis(C), x-s(Image(p,x)) );           
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
           Append( cx, cz );

           # take care of the coboundary...
           cx[6]:= cx[6] - c1*cx[3]-c2*cx[4]-c3*cx[5];

           cx[6]:= cx[6]/a;
           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;
       return rec( type:= [ 6, 21, c/a ], f:= liealg_hom( K, N, Basis(K), imgs ));

    elif type = [ 4, 1 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;
       coc22:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[2]; end;

       bM:= skew_symm_NF( M, coc21 );

       if IsZero( coc21(bM[3],bM[4]) ) then
          # find a linear combination of coc21, coc22 that is nondegenerate:
          y:= coc22(bM[1],bM[2]); a:= coc22(bM[1],bM[3]);
          b:= coc22(bM[1],bM[4]); c:= coc22(bM[2],bM[3]);
          d:= coc22(bM[2],bM[4]); e:= coc22(bM[3],bM[4]);
          if IsZero( a*d-b*c ) then
             x:= 1-y;
          else
             x:= -y;
          fi;

          if IsZero(x) then
             store:= coc21;
             coc21:= coc22;
             # so now coc21 has become coc22, need to make coc22 equal to
             # the old coc21 (otherwise no longer independent).
             coc22:= store;
             r:= 1; t:= 0;
          else
             f1:= coc21;
             coc21:= function(u,v) return x*f1(u,v)+coc22(u,v); end;
             r:= 0; t:= 1;
          fi;
          bM:= skew_symm_NF( M, coc21 );

          u:= x; v:= 1;
          # i.e., we have made a base change in the centre, corresponding 
          # to theta_1 --> u*theta_1 + v*\theta_2
          #    theta_2 --> r*theta_1 + t*\theta_2
       else
          u:= 1; v:= 0;
          r:= 0; t:= 1;
       fi;

       y:= coc22(bM[1],bM[2]);
       if not IsZero(y) then
          f2:= coc22;
          coc22:= function(u,v) return -y*coc21(u,v)+f2(u,v); end;
          r:= -u*y+r; t:= -v*y+t;
          # a new base change...
       fi;

       a:= coc22(bM[1],bM[3]);
       if IsZero(a) then
          # try to make it 0:
          b:= coc22(bM[1],bM[4]);
          c:= coc22(bM[2],bM[3]);
          d:= coc22(bM[2],bM[4]);
          if not IsZero(b) then
             bM[3]:= bM[3]+bM[4];
             a:= coc22(bM[1],bM[3]);
          elif not IsZero(c) then
             bM[1]:= bM[1]+bM[2];
             a:= coc22(bM[1],bM[3]);
          elif not IsZero(d) then
             bM[1]:= bM[1]+bM[2];
             bM[3]:= bM[3]+bM[4];
             a:= coc22(bM[1],bM[3]);
          fi;
       fi;

       if not IsZero(a) then
          # make it 1:
          bM[1]:= bM[1]/a; bM[4]:= bM[4]/a;

          # make b,c -> 0
          b:= coc22(bM[1],bM[4]); c:= coc22(bM[2],bM[3]);
          bM[2]:= bM[2]-c*bM[1]; bM[4]:= bM[4]-b*bM[3];

          e:= coc22(bM[3],bM[4]);
          if not IsZero(e) then
             # make it 1:
             bM[2]:= bM[2]/e; bM[4]:= bM[4]/e;

             a:= coc22(bM[2],bM[4]);

             if not IsZero(a) and not IsZero( a+1/4 ) then
                b:= a+1/4;
             elif IsZero(a) then
                b:= 1;
             elif IsZero( a+1/4 ) then
                b:= 0;
             fi;
          else
             b:= coc22(bM[2],bM[4]);
          fi;

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,5] );
          SetEntrySCTable( T, 1, 3, [1,6] );
          SetEntrySCTable( T, 2, 4, [b,6] );
          SetEntrySCTable( T, 3, 4, [1,5] );
          N:= LieAlgebraByStructureConstants( F, T );
          bM:= Basis( M, bM );
          imgs:= [ ];

          q:= coc21(bM[1],bM[2]); # we have to change that back to 1...
          for x in Basis(K) do

              cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );

              cz1:= ShallowCopy( cz );
              cz1[1]:= u/q*cz[1]+v/q*cz[2];
              cz1[2]:= r*cz[1]+t*cz[2];

              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz1 );

              if not IsZero(e) then
                 # make another isomorphism...
                 cx1:= ShallowCopy( cx );
                 if not IsZero(a) and not IsZero(a+1/4) then
                    cx1[1]:= (1/(4*a)+1)*cx[1]; 
                    cx1[2]:= cx[3];
                    cx1[3]:= a*cx[2]+cx[3]/2;
                    cx1[4]:= cx[4]+1/(2*a)*cx[1];
                    cx1[5]:= -cx[5]/2+cx[6];
                    cx1[6]:= (a+1/4)*cx[5];
                 elif IsZero(a) then
                    cx1[1]:= cx[4];
                    cx1[2]:= -cx[2]/4;
                    cx1[3]:= cx[2]/4-cx[3]/2;
                    cx1[4]:= 2*cx[1]-cx[4];
                    cx1[5]:= -cx[5]/2+cx[6];
                    cx1[6]:= cx[5]/2;   
                 elif IsZero(a+1/4) then
                    cx1[1]:= -2*cx[1]+cx[4];
                    cx1[2]:= cx[2]/2-2*cx[3];
                    cx1[3]:= cx[2]/2-cx[3];
                    cx1[4]:= -4*cx[1]+cx[4];
                    cx1[6]:= -cx[5]+2*cx[6];
                 fi;
                 cx:= ShallowCopy( cx1 );
              fi;
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [ 6, 22, b ], f:= liealg_hom( K, N, Basis(K), imgs ) );

       else # i.e, a=0, which means that b=c=d=0.

          # make e=1:
          e:= coc22(bM[3],bM[4]);
          f2:= coc22;          
          coc22:= function(u,v) return f2(u,v)/e; end;
          r:= r/e; t:= t/e;

          # subtract coc22 from coc21:
          f1:= coc21;
          coc21:= function(u,v) return f1(u,v)-coc22(u,v); end;
          u:= u-r; v:= v-t;

          T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
          SetEntrySCTable( T, 1, 2, [1,5] );
          SetEntrySCTable( T, 1, 3, [1,6] );
          SetEntrySCTable( T, 2, 4, [1,6] );
          SetEntrySCTable( T, 3, 4, [1,5] );
          N:= LieAlgebraByStructureConstants( F, T );
          bM:= Basis( M, bM );
          imgs:= [ ];

          for x in Basis(K) do

              cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );

              cz1:= ShallowCopy( cz );
              cz1[1]:= u*cz[1]+v*cz[2];
              cz1[2]:= r*cz[1]+t*cz[2];

              cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
              Append( cx, cz1 );

              # isom 
              cx1:= ShallowCopy( cx );
              cx1[1]:= cx[1]-cx[4];
              cx1[2]:= cx[2]/4-cx[3]/4;
              cx1[3]:= cx[2]/4+cx[3]/4;
              cx1[4]:= -cx[1]-cx[4];
              cx1[5]:= cx[5]/2-cx[6]/2;
              cx1[6]:= cx[5]/2+cx[6]/2;   
              cx:= ShallowCopy( cx1 );
              Add( imgs, LinearCombination( Basis(N), cx ) );
          od;
          return rec( type:= [ 6, 22, One(F) ], f:= liealg_hom( K, N, Basis(K), imgs ) );

       fi;   

    elif type = [ 4, 2 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;

       coc22:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[2]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );

       # coc21 can be moved to one of three normal forms
       a:= coc21( bM[1],bM[3] );
       b:= coc21( bM[1],bM[4] );
       c:= coc21( bM[2],bM[3] );
       d:= coc21( bM[2],bM[4] );

       if IsZero(a) and not IsZero(c) then # make a not zero
          bM[1]:= bM[1]+bM[2];
          a:= coc21( bM[1],bM[3] );
          b:= coc21( bM[1],bM[4] );
       fi;

       if not IsZero(a) then

          bM[1]:= bM[1]/a;
          bM[2]:= bM[2]*a;
          c:= coc21(bM[2],bM[3]);
          bM[2]:= bM[2]-c*bM[1];

          b:= coc21( bM[1],bM[4] );
          d:= coc21( bM[2],bM[4] );

          if not IsZero(d) then
             bM[4]:= bM[4]/d-b/d*bM[3];
          else
             bM[4]:= bM[4]-b*bM[3];
          fi;
       else  # here also c=0.
          m:= comp_mat( b, d, One(F) );
          store:= bM[1];
          bM[1]:= m[1][1]*bM[1]+m[1][2]*bM[2];
          bM[2]:= m[2][1]*store+m[2][2]*bM[2];
       fi;

       s13:= coc21( bM[1],bM[3] );
       s24:= coc21( bM[2],bM[4] );
       s14:= coc21( bM[1],bM[4] );

       r:= 1; t:= 0; 
       u:= 0; v:= 1;

       if not IsZero( s13 ) then

          if not IsZero( s24 ) then

             a:= coc22(bM[1],bM[3]);
             u:= -a; v:= 1;
             f1:= coc22;
             f5:= coc21;
             coc22:= function(u,v) return -a*f5(u,v)+f1(u,v); end;   
             b:= coc22( bM[1],bM[4] );  
             c:= coc22( bM[2],bM[3] );
             d:= coc22( bM[2],bM[4] );

             if IsZero(c) then

                if not IsZero(d) then

                   bM[3]:= bM[3]/d;
                   bM[2]:= bM[2]/d;
                   bM[1]:= bM[1]-b*bM[2];
                   bM[4]:= bM[4]+b*bM[3];

                   cf:= 1/coc21( bM[1],bM[3] );
                   f2:= coc21;
                   coc21:= function(u,v) return cf*f2(u,v); end;
                   r:= r*cf; t:= t*cf;
                   cf1:= 1/coc22(bM[2],bM[4]);
                   f3:= coc22;
                   coc22:= function(u,v) return cf1*f3(u,v); end;
                   u:= u*cf1; v:= v*cf1;
                   f4:= coc21;

                   coc21:= function(u,v) 
                        return f4(u,v)-coc22(u,v); 
                   end;
                   r:= r-u; t:= t-v;
                   c1:= coc21(bM[1],bM[2]);
                   c2:= coc22(bM[1],bM[2]);

                   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                   SetEntrySCTable( T, 1, 2, [1,4] );
                   SetEntrySCTable( T, 1, 3, [1,5] );
                   SetEntrySCTable( T, 2, 4, [1,6] );
                   N:= LieAlgebraByStructureConstants( F, T );
                   bM:= Basis( M, bM );
                   imgs:= [ ];

                   for x in Basis(K) do

                       cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                       cz1:= ShallowCopy( cz );
                       cz1[1]:= r*cz[1]+t*cz[2];
                       cz1[2]:= u*cz[1]+v*cz[2];
                       cx:= ShallowCopy( Coefficients( bM, Image( tau, Image(p,x) ) ) );
                       Append( cx, cz1 );

                       # subtract the cocycle
                       cx[5]:= cx[5]-c1*cx[3];
                       cx[6]:= cx[6]-c2*cx[3];

                       # isom 
                       cx1:= ShallowCopy(cx);
                       cx1[1]:= cx[2];
                       cx1[2]:= cx[1];
                       cx1[3]:= cx[4];
                       cx1[4]:= -cx[3];
                       cx1[5]:= cx[6];
                       cx1[6]:= -cx[5];
                       Add( imgs, LinearCombination( Basis(N), cx1 ) );
                   od;
                   return rec( type:= [ 6, 19, Zero(F) ], f:= liealg_hom(K,N,Basis(K),imgs) );
                else # d=0


                   cf:= 1/coc21(bM[1],bM[3]);
                   f2:= coc21;
                   coc21:= function(u,v) return cf*f2(u,v); end;
                   r:= r*cf; t:= t*cf;
                   cf1:= 1/coc22(bM[1],bM[4]);
                   f3:= coc22;
                   coc22:= function(u,v) return cf1*f3(u,v); end;
                   u:= u*cf1; v:= v*cf1;

                   c1:= coc21(bM[1],bM[2]);
                   c2:= coc22(bM[1],bM[2]);

                   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                   SetEntrySCTable( T, 1, 2, [1,3] );
                   SetEntrySCTable( T, 1, 3, [1,5] );
                   SetEntrySCTable( T, 1, 4, [1,6] );
                   SetEntrySCTable( T, 2, 4, [1,5] );
                   N:= LieAlgebraByStructureConstants( F, T );
                   bM:= Basis( M, bM );
                   imgs:= [ ];

                   for x in Basis(K) do

                       cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                       cz1:= ShallowCopy(cz);
                       cz1[1]:= r*cz[1]+t*cz[2];
                       cz1[2]:= u*cz[1]+v*cz[2];
                       cx:= ShallowCopy( Coefficients( bM, Image(tau,Image(p,x))));
                       Append( cx, cz1 );

                       # subtract the cocycle
                       cx[5]:= cx[5]-c1*cx[3];
                       cx[6]:= cx[6]-c2*cx[3];

                       Add( imgs, LinearCombination( Basis(N), cx ) );
                   od;
                   return rec( type:= [ 6, 23 ], f:= liealg_hom(K,N,Basis(K),imgs) );
                fi; 
             else # i.e., c not 0

                if not IsZero(d) then
                   bM[1]:= (2*c/d)*bM[1]+bM[2];
                   bM[2]:= d/(2*c)*bM[2];
                   bM[4]:= (2*c/d)^2*bM[4]-(2*c/d)*bM[3];
 
                   cf:= 1/coc21(bM[1],bM[3]);
                   f2:= coc21;
                   coc21:= function(u,v) return cf*f2(u,v); end;
                   r:= r*cf; t:= t*cf;

                   cf1:= coc22(bM[2],bM[3]);
                   f3:= coc22;
                   coc22:= function(u,v) return (f3(u,v)-c*coc21(u,v))/cf1; end;
                   u:= (u-c*r)/cf1; v:= (v-c*t)/cf1;
                   b:= coc22(bM[1],bM[4]);
                else
                   bM[1]:= bM[1]/c; bM[3]:= bM[3]/c; bM[4]:= bM[4]/(c^2);
                   cf:= 1/coc21(bM[1],bM[3]);
                   f2:= coc21;
                   coc21:= function(u,v) return cf*f2(u,v); end;
                   r:= r*cf; t:= t*cf;
                   b:= coc22(bM[1],bM[4]);
                fi;

                c1:= coc21(bM[1],bM[2]);
                c2:= coc22(bM[1],bM[2]);
                T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                SetEntrySCTable( T, 1, 2, [1,3] );
                SetEntrySCTable( T, 1, 3, [1,5] );
                SetEntrySCTable( T, 1, 4, [b,6] );
                SetEntrySCTable( T, 2, 3, [1,6] );
                SetEntrySCTable( T, 2, 4, [1,5] );
                N:= LieAlgebraByStructureConstants( F, T );
                bM:= Basis( M, bM );
                imgs:= [ ];

                for x in Basis(K) do

                    cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                    cz1:= ShallowCopy( cz );
                    cz1[1]:= r*cz[1]+t*cz[2];
                    cz1[2]:= u*cz[1]+v*cz[2];
                    cx:= ShallowCopy( Coefficients( bM, Image(tau,Image(p,x)))); 
                    Append( cx, cz1 );

                    # subtract the cocycle
                    cx[5]:= cx[5]-c1*cx[3];
                    cx[6]:= cx[6]-c2*cx[3];

                    Add( imgs, LinearCombination( Basis(N), cx ) );
                od;
                return rec( type:= [ 6, 24, b ], f:= liealg_hom(K,N,Basis(K),imgs) );
             fi;
          else # theta_1 = Delta_13

             b:= coc22( bM[1],bM[4] );  
             d:= coc22( bM[2],bM[4] );

             if not IsZero(d) then
                bM[1]:= bM[1]-(b/d)*bM[2];
                bM[4]:= bM[4]/d;

                c:= coc22( bM[2],bM[3] );
                if not IsZero(c) then
                   bM[1]:= bM[1]/c;
                   bM[3]:= bM[3]/c;

                   # normalise coc21
                   cf:= 1/coc21(bM[1],bM[3]);
                   f1:= coc21;
                   coc21:= function(u,v) return cf*f1(u,v); end;
                   r:= r*cf; t:= t*cf;

                   #make a = 0 by subtracting...
                   a:= coc22(bM[1],bM[3]);
                   u:= u-a*r; v:= v-a*t; 
                   f2:= coc22;
                   coc22:= function(u,v) return -a*coc21(u,v)+f2(u,v); end;
                   c1:= coc21(bM[1],bM[2]);
                   c2:= coc22(bM[1],bM[2]);
                   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                   SetEntrySCTable( T, 1, 2, [1,3] );
                   SetEntrySCTable( T, 1, 3, [1,5] );
                   SetEntrySCTable( T, 1, 4, [1,6] );
                   SetEntrySCTable( T, 2, 3, [1,6] );
                   SetEntrySCTable( T, 2, 4, [1,5] );
                   N:= LieAlgebraByStructureConstants( F, T );
                   bM:= Basis( M, bM );
                   imgs:= [ ];

                   for x in Basis(K) do

                       cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                       cz1:= ShallowCopy(cz);
                       cz1[1]:= r*cz[1]+t*cz[2];
                       cz1[2]:= u*cz[1]+v*cz[2];
                       cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                       Append( cx, cz1 );

                       # subtract the cocycle
                       cx[5]:= cx[5]-c1*cx[3];
                       cx[6]:= cx[6]-c2*cx[3];

                       #isom...
                       cx1:= ShallowCopy(cx);
                       cx1[1]:= cx[1]+cx[2];
                       cx1[2]:= -cx[1] +cx[2];
                       cx1[3]:= 2*cx[3]+cx[4];
                       cx1[4]:= cx[4];
                       cx1[5]:= 2*cx[5]+2*cx[6];
                       cx1[6]:= -2*cx[5]+2*cx[6];

                       Add( imgs, LinearCombination( Basis(N), cx1 ) );
                   od;
                   return rec( type:= [ 6, 24, One(F) ], f:= liealg_hom(K,N,Basis(K),imgs) );
                else # c=0

                   # normalise coc21
                   cf:= 1/coc21(bM[1],bM[3]);
                   f1:= coc21;
                   coc21:= function(u,v) return cf*f1(u,v); end; 
                   r:= r*cf; t:= t*cf;

                   #make a = 0 by subtracting...
                   a:= coc22(bM[1],bM[3]);
                   u:= u-a*r; v:= v-a*t;
                   f2:= coc22;
                   coc22:= function(u,v) return -a*coc21(u,v)+f2(u,v); end;

                   c1:= coc21(bM[1],bM[2]);
                   c2:= coc22(bM[1],bM[2]);
                   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                   SetEntrySCTable( T, 1, 2, [1,4] );
                   SetEntrySCTable( T, 1, 3, [1,5] );
                   SetEntrySCTable( T, 2, 4, [1,6] );
                   N:= LieAlgebraByStructureConstants( F, T );
                   bM:= Basis( M, bM );
                   imgs:= [ ];

                   for x in Basis(K) do

                       cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                       cz1:= ShallowCopy( cz );
                       cz1[1]:= r*cz[1]+t*cz[2];
                       cz1[2]:= u*cz[1]+v*cz[2];
                       cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                       Append( cx, cz1 );

                       # subtract the cocycle
                       cx[5]:= cx[5]-c1*cx[3];
                       cx[6]:= cx[6]-c2*cx[3];

                       #isom...
                       cx1:= ShallowCopy(cx);
                       cx1[1]:= cx[2];
                       cx1[2]:= cx[1];
                       cx1[3]:= cx[4];
                       cx1[4]:= -cx[3];
                       cx1[5]:= cx[6];
                       cx1[6]:= -cx[5];
                       Add( imgs, LinearCombination( Basis(N), cx1 ) );
                   od;
                   return rec( type:= [ 6, 19, Zero(F) ], f:= liealg_hom(K,N,Basis(K),imgs) );

                fi;

             else # d=0

                bM[4]:= bM[4]/b; # now b=1
                c:= coc22(bM[2],bM[3]);
                if not IsZero(c) then
                   bM[1]:= bM[1]/c; bM[3]:= bM[3]/c; bM[4]:= c*bM[4];
                   # normalise coc21
                   cf:= 1/coc21(bM[1],bM[3]);
                   f1:= coc21;
                   coc21:= function(u,v) return cf*f1(u,v); end;
                   r:= r*cf; t:= t*cf;

                   #make a = 0 by subtracting...
                   a:= coc22(bM[1],bM[3]);
                   u:= u-a*r; v:= v-a*t;
                   f2:= coc22;
                   coc22:= function(u,v) return -a*coc21(u,v)+f2(u,v); end;  

                   c1:= coc21(bM[1],bM[2]);
                   c2:= coc22(bM[1],bM[2]);
                   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                   SetEntrySCTable( T, 1, 2, [1,3] );
                   SetEntrySCTable( T, 1, 3, [1,5] );
                   SetEntrySCTable( T, 2, 3, [1,6] );
                   SetEntrySCTable( T, 2, 4, [1,5] );
                   N:= LieAlgebraByStructureConstants( F, T );
                   bM:= Basis( M, bM );
                   imgs:= [ ];

                   for x in Basis(K) do

                       cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                       cz1:= ShallowCopy( cz );
                       cz1[1]:= r*cz[1]+t*cz[2];
                       cz1[2]:= u*cz[1]+v*cz[2];
                       cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                       Append( cx, cz1 );

                       # subtract the cocycle
                       cx[5]:= cx[5]-c1*cx[3];
                       cx[6]:= cx[6]-c2*cx[3];

                       #isom...
                       cx1:= ShallowCopy( cx );
                       cx1[1]:= -cx[2];
                       cx1[2]:= -cx[1];
                       cx1[3]:= -cx[3];
                       cx1[4]:= -cx[4];
                       cx1[5]:= cx[6];
                       cx1[6]:= cx[5];

                       Add( imgs, LinearCombination( Basis(N), cx1 ) );
                   od;
                   return rec( type:= [ 6, 24, Zero(F) ], f:= liealg_hom(K,N,Basis(K),imgs) );

                else # c=0
                   # normalise coc21
                   cf:= 1/coc21(bM[1],bM[3]);
                   f1:= coc21;
                   coc21:= function(u,v) return cf*f1(u,v); end;
                   r:= r*cf; t:= t*cf;

                   #make a = 0 by subtracting...
                   a:= coc22(bM[1],bM[3]);
                   u:= u-a*r; v:= v-a*t; 
                   f2:= coc22;
                   coc22:= function(u,v) return -a*coc21(u,v)+f2(u,v); end;
                   c1:= coc21(bM[1],bM[2]);
                   c2:= coc22(bM[1],bM[2]);
                   T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                   SetEntrySCTable( T, 1, 2, [1,3] );
                   SetEntrySCTable( T, 1, 3, [1,5] );
                   SetEntrySCTable( T, 1, 4, [1,6] );
                   N:= LieAlgebraByStructureConstants( F, T );
                   bM:= Basis( M, bM );
                   imgs:= [ ];

                   for x in Basis(K) do

                       cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                       cz1:= ShallowCopy(cz);
                       cz1[1]:= r*cz[1]+t*cz[2];
                       cz1[2]:= u*cz[1]+v*cz[2];
                       cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                       Append( cx, cz1 );

                       # subtract the cocycle
                       cx[5]:= cx[5]-c1*cx[3];
                       cx[6]:= cx[6]-c2*cx[3];

                       Add( imgs, LinearCombination( Basis(N), cx ) );
                   od;
                   return rec( type:= [ 6, 25 ], f:= liealg_hom(K,N,Basis(K),imgs) );

                fi;
             fi;
          fi;

       else # i.e., theta_1 = Delta_14

          c:= coc22(bM[2],bM[3]);
          if not IsZero(c) then

             bM[1]:= bM[1]/c; bM[3]:= bM[3]/c;

             a:= coc22(bM[1],bM[3]);
             d:= coc22(bM[2],bM[4]);
             bM[1]:= bM[1]-a*bM[2];
             bM[4]:= bM[4]-d*bM[3];

             # normalise coc21
             cf:= 1/coc21(bM[1],bM[4]);
             f1:= coc21;
             coc21:= function(u,v) return cf*f1(u,v); end;
             r:= r*cf; t:= t*cf;

             #make b = 0 by subtracting...
             b:= coc22(bM[1],bM[4]);
             u:= u-b*r; v:= v-b*t;
             f2:= coc22;
             coc22:= function(u,v) return -b*coc21(u,v)+f2(u,v); end;
             c1:= coc21(bM[1],bM[2]);
             c2:= coc22(bM[1],bM[2]);
             T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,4] );
             SetEntrySCTable( T, 1, 3, [1,5] );
             SetEntrySCTable( T, 2, 4, [1,6] );
             N:= LieAlgebraByStructureConstants( F, T );
             bM:= Basis( M, bM );
             imgs:= [ ];

             for x in Basis(K) do

                 cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                 cz1:= cz;
                 cz1[1]:= r*cz[1]+t*cz[2];
                 cz1[2]:= u*cz[1]+v*cz[2];
                 cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                 Append( cx, cz1 );

                 # subtract the cocycle
                 cx[5]:= cx[5]-c1*cx[3];
                 cx[6]:= cx[6]-c2*cx[3];

                 #isom...
                 cx1:= ShallowCopy(cx);
                 cx1[2]:= -cx[2];
                 cx1[3]:= -cx[4];
                 cx1[4]:= -cx[3];
                 cx1[5]:= -cx[5];
                 Add( imgs, LinearCombination( Basis(N), cx1 ) );
             od;
             return rec( type:= [ 6, 19, Zero(F) ], f:= liealg_hom(K,N,Basis(K),imgs) );
          else #c=0

             a:= coc22(bM[1],bM[3]);
             bM[2]:= bM[2]/a; bM[3]:= bM[3]/a;
             d:= coc22(bM[2],bM[4]);
             if not IsZero(d) then
                bM[4]:= bM[4]/d;
             fi;

             # normalise coc21
             cf:= 1/coc21(bM[1],bM[4]);
             f1:= coc21;
             coc21:= function(u,v) return cf*f1(u,v); end;
             r:= r*cf; t:= t*cf;

             #make b = 0 by subtracting...
             b:= coc22(bM[1],bM[4]);
             u:= u-b*r; v:= v-b*t;
             f2:= coc22;
             coc22:= function(u,v) return -b*coc21(u,v)+f2(u,v); end;

             c1:= coc21(bM[1],bM[2]);
             c2:= coc22(bM[1],bM[2]);
             T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
             SetEntrySCTable( T, 1, 2, [1,3] );
             SetEntrySCTable( T, 1, 3, [1,5] );
             SetEntrySCTable( T, 1, 4, [1,6] );

             if not IsZero(d) then
                SetEntrySCTable( T, 2, 4, [1,5] );
             fi; 
             N:= LieAlgebraByStructureConstants( F, T );
             bM:= Basis( M, bM );
             imgs:= [ ];

             for x in Basis(K) do

                 cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
                 cz1:= ShallowCopy(cz);
                 cz1[1]:= r*cz[1]+t*cz[2];
                 cz1[2]:= u*cz[1]+v*cz[2];
                 cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
                 Append( cx, cz1 );

                 # subtract the cocycle
                 cx[5]:= cx[5]-c1*cx[3];
                 cx[6]:= cx[6]-c2*cx[3];

                 #isom...
                 cx1:= ShallowCopy(cx);
                 cx1[5]:= cx[6];
                 cx1[6]:= cx[5];
                 Add( imgs, LinearCombination( Basis(N), cx1 ) );
             od;
             if not IsZero(d) then
                return rec( type:= [ 6, 23 ], f:= liealg_hom(K,N,Basis(K),imgs ));
             else
                return rec( type:= [ 6, 25 ], f:= liealg_hom(K,N,Basis(K),imgs ) );
             fi;
          fi;
       fi;
   
    elif type = [ 4, 3 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;

       coc22:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[2]; end;
       bM:= ShallowCopy( BasisVectors( Basis(M) ) );
       a:= coc21( bM[1],bM[4] );
       b:= coc21( bM[2],bM[3] );
       c:= coc22( bM[1],bM[4] );
       d:= coc22( bM[2],bM[3] );
       m:= [[a,b],[c,d]]^-1;

       r:= m[1][1]; t:= m[1][2];
       u:= m[2][1]; v:= m[2][2];

       cc:= coc21;
       f1:= coc22;
       coc21:= function(u,v) return r*cc(u,v)+t*f1(u,v); end;
       coc22:= function(x,y) return u*cc(x,y)+v*f1(x,y); end;

       c1:= coc21(bM[1],bM[2]);
       c2:= coc22(bM[1],bM[2]);
       c3:= coc21(bM[1],bM[3]);
       c4:= coc22(bM[1],bM[3]);
       T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,3] );
       SetEntrySCTable( T, 1, 3, [1,4] );
       SetEntrySCTable( T, 1, 4, [1,6] );
       SetEntrySCTable( T, 2, 3, [1,5] );
       N:= LieAlgebraByStructureConstants( F, T );
       bM:= Basis( M, bM );
       imgs:= [ ];

       for x in Basis(K) do

           cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
           cz1:= ShallowCopy(cz);
           cz1[1]:= r*cz[1]+t*cz[2];
           cz1[2]:= u*cz[1]+v*cz[2];
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
           Append( cx, cz1 );

           # subtract the cocycle
           cx[5]:= cx[5]-c1*cx[3]-c3*cx[4];
           cx[6]:= cx[6]-c2*cx[3]-c4*cx[4];

           #isom...
           cx1:= ShallowCopy(cx);
           cx1[5]:= cx[6];
           cx1[6]:= cx[5];
           Add( imgs, LinearCombination( Basis(N), cx1 ) );
       od;
       return rec( type:= [ 6, 21, Zero(F) ], f:= liealg_hom(K,N,Basis(K),imgs ));

    elif type = [ 3, 1 ] then

       coc21:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[1]; end;

       coc22:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[2]; end;
       coc23:= function( u, v ) return Coefficients( Basis(C), coc2(u,v) )[3]; end;

       bM:= Basis(M);
       m:= [ [], [], [] ];
       m[1][1]:= coc21( bM[1],bM[2] );
       m[1][2]:= coc21( bM[1],bM[3] );
       m[1][3]:= coc21( bM[2],bM[3] );
       m[2][1]:= coc22( bM[1],bM[2] );
       m[2][2]:= coc22( bM[1],bM[3] );
       m[2][3]:= coc22( bM[2],bM[3] );
       m[3][1]:= coc23( bM[1],bM[2] );
       m[3][2]:= coc23( bM[1],bM[3] );
       m[3][3]:= coc23( bM[2],bM[3] );

       m:= m^-1;
       T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
       SetEntrySCTable( T, 1, 2, [1,4] );
       SetEntrySCTable( T, 1, 3, [1,5] );
       SetEntrySCTable( T, 2, 3, [1,6] );
       N:= LieAlgebraByStructureConstants( F, T );
       imgs:= [ ];

       for x in Basis(K) do

           cz:= Coefficients( Basis(C), x-s( Image(p,x) ) );
           cz:= cz*TransposedMat(m);
           cx:= ShallowCopy( Coefficients( bM, Image( tau, Image( p, x ) ) ) );
           Append( cx, cz );
           Add( imgs, LinearCombination( Basis(N), cx ) );
       od;
       return rec( type:= [ 6, 26  ], f:= liealg_hom(K,N,Basis(K),imgs) );

    fi;


end;


nilp_type:= function( L )

    local r, t, a, g, exp, c, K, imgs, pp, s, f, F, name;

    if (Characteristic(LeftActingDomain(L))=2) or (not Dimension(L) in [5,6]) or (not IsLieNilpotent(L)) then 
       Error("This function is only implemented for nilpotent Lie algebras of dim 5,6 over fields of char not 2");
    fi; 

    if Dimension(L) = 5 then
       r:= class_dim_5( L );
    else
       r:= class_dim_6( L );
       F:= LeftActingDomain( L );
       if IsFinite(F) then
          t:= r.type;
          if t[2] in [ 19, 21, 22, 24 ] then
             # normalise the parameter
             a:= t[3];
             g:= PrimitiveRoot( F );
             if not a in [Zero(F),One(F),g] then
                exp:= LogFFE( a, g );
                if IsEvenInt(exp) then
                   c:= g^-(exp/2);
                   pp:= One(F);
                else
                   c:= g^(-(exp-1)/2);
                   pp:= g;
                fi;
                # now we make an isomorphism that multiplies the parameter by c^2:
                f:= r.f;
                if t[2] = 19 then
                   K:= NilpotentLieAlgebra( F, [6,19, pp] );
                   imgs:= ShallowCopy( BasisVectors( Basis(K) ) );
                   imgs[3]:= imgs[3]*c;
                   imgs[5]:= imgs[5]*c;
                elif t[2] = 21 then
                   K:= NilpotentLieAlgebra( F, [6,21, pp] );
                   imgs:= ShallowCopy( BasisVectors( Basis(K) ) );
                   imgs[2]:= imgs[2]/c; 
                   imgs[3]:= imgs[3]/c;
                   imgs[4]:= imgs[4]/c;
                   imgs[5]:= imgs[5]/c^2;
                   imgs[6]:= imgs[6]/c;
                elif t[2] = 22 then
                   K:= NilpotentLieAlgebra( F, [6,22, pp] );
                   imgs:= ShallowCopy( BasisVectors( Basis(K) ) );
                   imgs[1]:= imgs[1]*c;
                   imgs[3]:= imgs[3]*c;
                   imgs[5]:= imgs[5]*c;
                   imgs[6]:= imgs[6]*c^2;
                elif t[2] = 24 then
                   K:= NilpotentLieAlgebra( F, [6,24, pp] );
                   imgs:= ShallowCopy( BasisVectors( Basis(K) ) );
                   imgs[1]:= imgs[1]/c; 
                   imgs[3]:= imgs[3]/c;
                   imgs[4]:= imgs[4]/c^2;
                   imgs[5]:= imgs[5]/c^2;
                   imgs[6]:= imgs[6]/c;
                fi; 
                s:= liealg_hom( Range(f), K, Basis(Range(f)), imgs );
                imgs:= List( Basis(L), x -> Image( s, Image( f, x ) ) );
                r:= rec( type:= [6,t[2],pp], f:= liealg_hom(L,K,Basis(L),imgs) );
             fi;
          fi;
       fi;
    fi;

    name:= "N";
    Append( name, String(r.type[1]) );
    Append( name, "_" );
    Append( name, String( r.type[2] ) );
    Append( name, "( ");
    Append( name, LieAlgDBField2String( F ) );
    if Length(r.type) = 3 then
       Append( name, ", " );
       Append( name, String( r.type[3] ) );
       pp:= [r.type[3]];
    else
       pp:= [ ];
    fi;
    Append( name, " )" );
    return rec( name:= [ name, pp ], isom:= r.f );    

end;

InstallMethod( LieAlgebraIdentification, "for a Lie algebra",
    true,
    [ IsLieAlgebra ], 0,

    function( L )

    local n, r;

    n:= Dimension(L);
    if n in [2,3,4] then
       if not IsLieSolvable(L) then Error("<L> has to be a solvable Lie algebra"); fi;
       r:= solv_type(L);
    elif n in [5,6] then
       if not IsLieNilpotent(L) then Error("<L> has to be a nilpotent Lie algebra"); fi;
       r:= nilp_type(L);
    else
       Error("the dimension has to satisfy 2<= dim <= 6");
    fi;
    return rec( name:= r.name[1], parameters:= r.name[2], isomorphism:= r.isom );

end );


InstallMethod( AllSolvableLieAlgebras, 
        "for a finite field and a positive integer",
        true,
        [ IsField and IsFinite, IsPosInt ], 0,
        
        function( F, dim )
    
    local  parlist, R, fam;
    
    if not IsFinite(F) then Error("F has to be a finite field"); fi;
    if not dim in [1,2,3,4] then Error("solvable Lie algebras of this dimension are not included"); fi;
    
    
    
    if dim = 1 then
        parlist := [[1,1]];
    elif dim = 2 then
        parlist:= [[2,1],[2,2]];
    elif dim = 3 then
        parlist := EnumeratorByFunctions( NewFamily( IsList ),
                           rec( 
                                ElementNumber := function( e, x )
            local aa;
            
            aa:= [ Zero(F), One(F) ];
            if Characteristic( F ) > 2 then
                Add( aa, PrimitiveRoot(F) );
            fi;
                      
            if x in [1,2] then
                return [3,x];
            elif x in [3..Size( F )+2] then
                return [3,3,Enumerator( F )[x-2]];
            elif Characteristic( F ) = 2 and x in [Size( F )+3..Size( F )+4]
              then return [3,4,aa[x-Size(F)-2]];
          elif Characteristic( F ) <> 2 and x in [Size( F )+3..Size( F )+5]
            then  return [3,4,aa[x-Size(F)-2]];
          fi;
      end,
        NumberElement := function( e, x )
          local list1, list2;
          
          list1 := [[3,1],[3,2]];
          list2 := [[3,4,Zero(F)],[3,4,One(F)]];
          if Characteristic( F ) > 2 then
              Add( list2, [3,4,PrimitiveRoot(F)]);
          fi;
          
          if x in list1 then
              return Position( list1, x );
          elif x{[1,2]} = [3,3] then
              return Position( Enumerator( F ), x[3] ) + 2;
          elif x in list2 then
              return Position( list2, x ) + Size( F )+2;
          fi;
      end,
        
        Length := function( e )
          if Characteristic( F ) = 2 then
              return Size( F )+4;
          else
              return Size( F )+5;
          fi;
      end ));
          
  elif dim = 4 then
      parlist := EnumeratorByFunctions( NewFamily( IsList ),
                         rec( 
                              ElementNumber := function( e, x )
          local a, T, i, ff, q, l1, l2, l3, l4, l5;
          
          q:= Size( F ); a := PrimitiveRoot( F );
          
          l1 := [[4,7, Zero(F), One(F)],[4,7, Zero(F), a],[4,14,One(F)],
                 [4,14,a],[4,7,a^0, Zero(F)],[4,7, a, Zero(F)],
                 [4,7, a^2, Zero(F)]];
          l2 := [[4,7, Zero(F), One(F)],[4,11, One(F), Zero(F) ],
                 [4,14, One(F)],[4,7, One(F), Zero(F)]];
          l3 := [[4,7, Zero(F), One(F)],[4,7, Zero(F), a],[4,14,One(F)],
                 [4,14,a],[4,7, One(F), Zero(F)]];
          l4 := [[4,7, Zero(F), One(F)],[4,11, One(F), Zero(F) ],
                 [4,14, One(F)],[4,7, a^0, Zero(F)],
                 [4,7, a, Zero(F)],[4,7, a^2, Zero(F)]];
          l5 := [[4,7, Zero(F), One(F)],[4,7, Zero(F), a],[4,14,One(F)],
                 [4,14,a],[4,7, One(F), Zero(F)]];
          
          if x in [1,2] then
              return [4,x];
          elif x in [3..Size( F )+2] then
              return [4,3,Enumerator( F )[x-2]];
          elif x in [Size( F )+3..Size( F )+4] then
              return [4,x-Size(F)+1];
          elif x in [Size(F)+5..Size(F)^2+Size(F)+4] then
              return [4,6,
                      Enumerator( F )[Int((x-Size( F )-5)/Size( F ))+1],
                      Enumerator( F )[((x-Size(F)-5) mod Size( F ))+1]];
          elif x in [Size(F)^2+Size(F)+5..Size(F)^2+2*Size(F)+4] then
              return [4,7,Enumerator( F )[x-(Size(F)^2+Size(F)+4)],
                      Enumerator( F )[x-(Size(F)^2+Size(F)+4)]];
          elif x = Size(F)^2+2*Size(F)+5 then
              return [4,8];
          elif x = Size(F)^2+2*Size(F)+6 then
              a:= PrimitiveRoot( F );
              T:= Indeterminate(F);
              for i in [1..q-1] do
                  ff:= Factors( T^2-T-a^i );
                  if Length(ff) = 1 then
                      return [4,9,a^i];
                      break;
                  fi;
              od;
          elif x = Size(F)^2+2*Size(F)+7 then
              return [4,12];
          elif x in [Size(F)^2+2*Size(F)+8..Size(F)^2+3*Size(F)+7] then
              return [4,13,Enumerator( F )[x-(Size(F)^2+2*Size(F)+7)]];
          elif q mod 6 = 1 and
            x in [Size(F)^2+3*Size(F)+8..Size(F)^2+3*Size(F)+14] then
              return l1[x-(Size(F)^2+3*Size(F)+7)];
          elif q mod 6 = 2 and
            x in [Size(F)^2+3*Size(F)+8..Size(F)^2+3*Size(F)+11] then
              return l2[x-(Size(F)^2+3*Size(F)+7)];
          elif q mod 6 = 3 and 
            x in [Size(F)^2+3*Size(F)+8..Size(F)^2+3*Size(F)+12] then
              return l3[x-(Size(F)^2+3*Size(F)+7)];
          elif q mod 6 = 4 and
            x in [Size(F)^2+3*Size(F)+8..Size(F)^2+3*Size(F)+13] then
              return l4[x-(Size(F)^2+3*Size(F)+7)];
          elif q mod 6 = 5 and
            x in [Size(F)^2+3*Size(F)+8..Size(F)^2+3*Size(F)+12] then
              return l5[x-(Size(F)^2+3*Size(F)+7)];
          fi;
      end,
        NumberElement := function( e, x )
          local q, a, l1, l2, l3, l4, l5;
          q:= Size( F ); a := PrimitiveRoot( F );
          
          l1 := [[4,7, Zero(F), One(F)],[4,7, Zero(F), a],[4,14,One(F)],
                 [4,14,a],[4,7,a^0, Zero(F)],[4,7, a, Zero(F)],
                 [4,7, a^2, Zero(F)]];
          l2 := [[4,7, Zero(F), One(F)],[4,11, One(F), Zero(F) ],
                 [4,14, One(F)],[4,7, One(F), Zero(F)]];
          l3 := [[4,7, Zero(F), One(F)],[4,7, Zero(F), a],[4,14,One(F)],
                 [4,14,a],[4,7, One(F), Zero(F)]];
          l4 := [[4,7, Zero(F), One(F)],[4,11, One(F), Zero(F) ],
                 [4,14, One(F)],[4,7, a^0, Zero(F)],
                 [4,7, a, Zero(F)],[4,7, a^2, Zero(F)]];
          l5 := [[4,7, Zero(F), One(F)],[4,7, Zero(F), a],[4,14,One(F)],
                 [4,14,a],[4,7, One(F), Zero(F)]];
          
          if x[2] in [1,2] then
              return x[2];
          elif x[2] = 3 then
              return Position( Enumerator( F ), x[3] )+2;
          elif x[2] in [4,5] then
              return Size( F )+x[2]-1;
          elif x[2] = 6 then
              return Size( F )+4+(Position( Enumerator( F ), x[3])-1)*
                     Size( F )+Position( Enumerator( F ), x[4] );
          elif x[2] = 7 and x[3]=x[4] then
              return Size(F)^2+Size(F)+4+Position( Enumerator( F ), x[3] );
          elif x[2] = 8 then
              return Size(F)^2+2*Size(F)+5;
          elif x[2] = 9 then
              return Size(F)^2+2*Size(F)+6;
          elif x[2] = 12 then
              return Size(F)^2+2*Size(F)+7;
          elif x[2] = 13 then
              return Size(F)^2+2*Size(F)+7+
                     Position( Enumerator( F ), x[3] );
          elif q mod 6 = 1 and x in l1 then
              return Size(F)^2+3*Size(F)+7+Position( l1, x );
          elif q mod 6 = 2 and x in l2 then
              return Size(F)^2+3*Size(F)+7+Position( l2, x );
          elif q mod 6 = 3 and x in l3 then
              return Size(F)^2+3*Size(F)+7+Position( l3, x );
          elif q mod 6 = 4 and x in l4 then
              return Size(F)^2+3*Size(F)+7+Position( l4, x );
          elif q mod 6 = 5 and x in l5 then
              return Size(F)^2+3*Size(F)+7+Position( l5, x );
          fi;
      end,
        Length := function( e )
          local q;
          
          q := Size( F );
          if q mod 6 = 1 then
              return q^2+3*q+14;
          elif q mod 6 = 2 then
              return q^2+3*q+11;
          elif q mod 6 = 3 then
              return q^2+3*q+12;
          elif q mod 6 = 4 then
              return q^2+3*q+13;
          elif q mod 6 = 5 then
              return q^2+3*q+12;
          fi;
      end ));
  else
      Error( "not yet implemented" );
  fi;
  R := rec( field := F,
            dim := dim,
            type := "Solvable",
            parlist := parlist );
  fam := NewFamily( IsLieAlgDBCollection_Solvable );
  R := Objectify( NewType( fam, IsLieAlgDBCollection_Solvable ), R );
  
  return R;
end );
  
InstallMethod(  Enumerator,
        "method for LieAlgDBCollections",
        [ IsLieAlgDBCollection_Solvable ],
        function( R )
    
    return EnumeratorByFunctions( NewFamily( 
                   CategoryCollections( IsLieAlgebra )), 
                   rec( 
                        ElementNumber := function( e, n )
        local par;
        par := R!.parlist[n];      
        
        return SolvableLieAlgebra( R!.field, par );
    end, 
      NumberElement := function( e, x )
        return Position( R!.parlist, x!.arg );
    end,
      Length := function( x ) return Length( R!.parlist ); end ));
  end );


 
