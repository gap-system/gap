#############################################################################
##
#A  zass.gi                   Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Routines for the determination of space groups for a given a point group
##

#############################################################################
##
#F  NullBlockMat( <d>, <d1>, <d2> ). . . . . . d1xd2-matrix of d-NullMatrices
##
NullBlockMat := function( d, d1, d2 )
   # return d1 x d2 matrix, whose entries are d x d NullMatrices
   return List( [1..d1], i -> List( [1..d2], j -> NullMat( d, d ) ) );
end;

#############################################################################
##
#F  FlattenedBlockMat( < BlockMat > ). . . . . . . . . flattened block matrix
##
FlattenedBlockMat := function( mat )
   # flatten a matrix whose entries are matrices to a normal matrix
   local m;
   m := mat;
   m := List( [1..Length(m[1])], 
              j -> Concatenation( List([1..Length(m)], i -> m[i][j] ) ) );
   m := TransposedMat( Concatenation( List( [1..Length(m)], 
                                      i -> TransposedMat(m[i]) ) ) );
   return m;
end;

#############################################################################
##
#F  MakeSpaceGroup( <d>, <Pgens>, <transl>, <transp> )  construct space group
##
MakeSpaceGroup := function( d, Pgens, transl, transp )
   # construct space group from point group and translation vector
   local Sgens, i, m, S;

   # first the non-translational generators
   Sgens := List( [1..Length( Pgens )], i -> 
                  AugmentedMatrix( Pgens[i], transl{[(i-1)*d+1..i*d]} ) );

   # the pure translation generators
   for i in [1..d] do
      m := IdentityMat( d+1 );
      m[d+1][i] := 1;
      Add( Sgens, m );
   od;

   # make the space group and return it
   if transp then
      Sgens := List( Sgens, TransposedMat );
      S := AffineCrystGroupOnLeftNC( Sgens, IdentityMat(d+1) );
   else
      S := AffineCrystGroupOnRightNC( Sgens, IdentityMat(d+1) );
   fi;
   AddTranslationBasis( S, IdentityMat( d ) );
   return S;

end;

#############################################################################
##
#F  GroupExtEquations( <d>, <gens>, <rels> ) . equations for group extensions
##
GroupExtEquations := function( d, gens, rels )
   # construct equations which determine the non-primitive translations
   local mat, i, j, k, r, r0, max, prod;

   mat := NullBlockMat( d, Length(gens), Length(rels) );
   for i in [1..Length(rels)] do

      # interface to GAP-3 format
      r0 := rels[i]; r := [];
      for k in [1..Length(r0)/2] do
          max := r0[2*k];
          if max > 0 then
              for j in [1..max] do 
                  Add( r, r0[2*k-1] );
              od;
          else
              for j in [1..-max] do 
                  Add( r, -r0[2*k-1] );
              od;
          fi;
      od; 

      prod := IdentityMat(d);
      for j in Reversed([1..Length(r)]) do
         if r[j]>0 then
            mat[ r[j] ][i] := mat[ r[j] ][i]+prod;
            prod := gens[ r[j] ]*prod;
         else
            prod := gens[-r[j] ]^-1*prod;
            mat[-r[j] ][i] := mat[-r[j] ][i]-prod;
         fi;
      od;

   od;
   return FlattenedBlockMat( mat );
end;


#############################################################################
##
#F  StandardTranslation( <trans>, <nullspace> ) . .reduce to std. translation
##
StandardTranslation := function( L, NN )
   # reduce non-primitive translations to "standard" form
   local N, j, k;

   # first apply "continuous" translations
   for N in NN[1] do
      j := PositionProperty( N, x -> x=1 );
      L := L-L[j]*N;
   od;
   L := List( L, FractionModOne );

   # and then "discrete" translations
   for N in NN[2] do
      j := PositionProperty( N, x -> x<>0 );
      k := Int( L[j] / N[j] );
      if k > 0 then
         L := List( L-k*N, FractionModOne );
      fi;
   od;

   return L;

end;


#############################################################################
##
#F  SolveHomEquationsModZ( <mat> ) . . . . . . . . . . .  solve x*mat=0 mod Z
##
SolveHomEquationsModZ := function( M )

    local Q, L, N, N2;

    Q := IdentityMat( Length(M) );
    
    # first diagonalize M
    M := TransposedMat(M);
    M := RowEchelonForm( M );
    while not IsDiagonalMat(M) do
        M := TransposedMat(M);
        M := RowEchelonFormT(M,Q);
        if not IsDiagonalMat(M) then
            M := TransposedMat(M);
            M := RowEchelonForm(M);
        fi;
    od;

    # and then determine the solutions of x*M=0 mod Z
    if Length(M)>0 then
        L := List( [1..Length(M)], i -> [ 0 .. M[i][i]-1 ] / M[i][i] );
        L := List( Cartesian( L ), l -> l * Q{[1..Length(M)]} );
    else
        L := NullMat( 1, Length(Q) );
    fi;

    # we later need the space in which one can freely shift
    # non-primitive translations; first the translations which 
    # can be applied with rational coefficients

    if Length(M)<Length(Q) then
        N := Q{[Length(M)+1..Length(Q)]};
        TriangulizeMat( N );
    else
        N := [];
    fi; 

    # and now those which allow only integral coefficients
    if N<>[] then
       N2 := List( N, n -> List( n, FractionModOne ) );
       N2 := ReducedLatticeBasis( N2 );
       N2 := List( N2, n -> List( n, FractionModOne ) );
       N2 := Filtered( N2, n -> n<>0*N[1] );
    else
       N2 := [];
    fi;

    # reduce non-primitive translations to standard form
    L := Set( List( L, x -> StandardTranslation( x, [ N, N2 ] ) ) );

    return [ L, [ N, N2 ] ];

end;


#############################################################################
##
#F  CollectEquivExtensions( <trans>, <nullspace>, <norm>, <grp> ) . . . . . .
#F  . . . . collect extensions equivalent by conjugation with elems from norm
##
CollectEquivExtensions := function( ll, nn, norm, grp )

   # check for conjugacy with generators of the normalizer of grp in GL(n,Z)

   local cent, d, gens, sgens, res, orb, x, y, c, n, i, j, sg, h, m;

   norm := Set( Filtered( norm, x -> not x in grp ) );
   cent := Filtered( norm, 
             x -> ForAll( GeneratorsOfGroup( grp ), g -> x*g=g*x ) );
   SubtractSet( norm, cent );

   d     := DimensionOfMatrixGroup( grp );
   gens  := GeneratorsOfGroup( grp );
   sgens := List( gens, g -> AugmentedMatrix( g, List( [1..d], x -> 0 ) ) );

   res := [ ];
   while ll<>[] do
      orb := [ ll[1] ]; 
      for x in orb do

         # first the generators which are in the centralizer
         for c in cent do
            y := List([1..Length(gens)], i -> x{ [(i-1)*d+1..i*d] }*c );
            y := StandardTranslation( Concatenation(y), nn );
            if not y in orb then 
               Add( orb, y ); 
            fi;
         od;

         # then the remaining ones; this is more complicated
         for n in norm do
            for i in [1..Length(gens)] do
               for j in [1..d] do
                  sgens[i][d+1][j]:=x[(i-1)*d+j];
               od;
            od;
            sg := Group( sgens, IdentityMat( d+1 ) );
            SetIsFinite( sg, false );
            h :=GroupHomomorphismByImagesNC( sg, grp, sgens, gens );
            y :=[];
            for i in [1..Length(gens)] do
               m := PreImagesRepresentative( h, n*gens[i]*n^-1 );
               Append( y, m[d+1]{[1..d]}*n );
            od;
            y := StandardTranslation( y, nn );
            if not y in orb then
               Add( orb, y ); 
            fi;
         od;

      od;
      Add( res, orb );
      SubtractSet( ll, orb );
   od;

   return res;

end;


#############################################################################
##
#F  ZassFunc( <grp>, <norm>, <orbsflag>, <transpose> ) . Zassenhaus algorithm
##
ZassFunc := function( grp, norm, orbsflag, transpose )

   local d, S, N, F, Fam, rels, gens, mat, ext, lst, res;

   d := DimensionOfMatrixGroup( grp );
   if transpose then
      grp  := TransposedMatrixGroup( grp );
      norm := List( norm, TransposedMat );
   fi;

   if not IsIntegerMatrixGroup( grp ) then
      Error( "the point group must be an integer matrix group" );
   fi;

   if not IsFinite( grp ) then
      Error("the point group must be finite" );
   fi;

   # catch the trivial case
   if IsTrivial( grp ) then
      S := MakeSpaceGroup( d, [], [], transpose );
      if orbsflag then
         return [[S]];
      else
         return [ S ];
      fi;
   fi;

   # first get group relators for grp
   N := NiceObject( grp );
   F := Image( IsomorphismFpGroupByGenerators( N, GeneratorsOfGroup( N ) ) );
   rels := List( RelatorsOfFpGroup( F ), ExtRepOfObj );
   gens := GeneratorsOfGroup( grp );

   # construct equations which determine the non-primitive translations
   # an alternative would be
   # mat := MatJacobianMatrix( F, gens );
   mat := GroupExtEquations( d, gens, rels );

   # now solve them modulo integers
   ext := SolveHomEquationsModZ( mat );
   
   # collect group extensions which are equivalent as space groups
   lst := CollectEquivExtensions( ext[1], ext[2], norm, grp );

   # make the space groups
   if orbsflag then 
      res := List( lst, x -> List( x, 
                   y -> MakeSpaceGroup( d, gens, y, transpose ) ) );
   else
      res := List( lst, x -> MakeSpaceGroup( d, gens, x[1], transpose ) );
   fi;

   return res;

end;


#############################################################################
##
#M  SpaceGroupsByPointGroupOnRight( <grp> [, <norm> [, <orbsflag> ] ] )
##
InstallMethod( SpaceGroupsByPointGroupOnRight, true,
   [ IsCyclotomicMatrixGroup ], 0,
function( grp )
   return ZassFunc( grp, [], false, false );
end );

InstallOtherMethod( SpaceGroupsByPointGroupOnRight, IsIdenticalObj,
   [ IsCyclotomicMatrixGroup, IsList ], 0,
function( grp, norm )
   return ZassFunc( grp, norm, false, false );
end );

InstallOtherMethod( SpaceGroupsByPointGroupOnRight,
   function(a,b,c) return IsIdenticalObj(a,b); end,
   [ IsCyclotomicMatrixGroup, IsList, IsBool ], 0,
function( grp, norm, orbsflag )
   return ZassFunc( grp, norm, orbsflag, false );
end );


#############################################################################
##
#M  SpaceGroupsByPointGroupOnLeft( <grp> [, <norm>, [ <orbsflag> ] ] )
##
InstallMethod( SpaceGroupsByPointGroupOnLeft, true,
   [ IsCyclotomicMatrixGroup ], 0,
function( grp )
   return ZassFunc( grp, [], false, true );
end );

InstallOtherMethod( SpaceGroupsByPointGroupOnLeft, IsIdenticalObj,
   [ IsCyclotomicMatrixGroup, IsList ], 0,
function( grp, norm )
   return ZassFunc( grp, norm, false, true );
end );

InstallOtherMethod( SpaceGroupsByPointGroupOnLeft,
   function(a,b,c) return IsIdenticalObj(a,b); end,
   [ IsCyclotomicMatrixGroup, IsList, IsBool ], 0,
function( grp, norm, orbsflag )
   return ZassFunc( grp, norm, orbsflag, true );
end );


#############################################################################
##
#M  SpaceGroupsByPointGroup( <grp> [, <norm> [, <orbsflag> ] ] )
##
InstallMethod( SpaceGroupsByPointGroup, true,
   [ IsCyclotomicMatrixGroup ], 0,
function( grp )
   return ZassFunc( grp, [], false, CrystGroupDefaultAction=LeftAction );
end );

InstallOtherMethod( SpaceGroupsByPointGroup, IsIdenticalObj,
   [ IsCyclotomicMatrixGroup, IsList ], 0,
function( grp, norm )
   return ZassFunc( grp, norm, false, CrystGroupDefaultAction=LeftAction );
end );

InstallOtherMethod( SpaceGroupsByPointGroup,
   function(a,b,c) return IsIdenticalObj(a,b); end,
   [ IsCyclotomicMatrixGroup, IsList, IsBool ], 0,
function( grp, norm, orbsflag )
   return ZassFunc( grp, norm, orbsflag, CrystGroupDefaultAction=LeftAction );
end );


#############################################################################
##
#M  SpaceGroupTypesByPointGroupOnRight( <grp> [, <orbsflag>] )
##
InstallMethod( SpaceGroupTypesByPointGroupOnRight, true,
   [ IsCyclotomicMatrixGroup ], 0,
function( grp )
   local norm;
   norm := GeneratorsOfGroup( NormalizerInGLnZ( grp ) );
   return ZassFunc( grp, norm, false, false );
end );

InstallOtherMethod( SpaceGroupTypesByPointGroupOnRight, true,
   [ IsCyclotomicMatrixGroup, IsBool ], 0,
function( grp, orbsflag )
   local norm;
   norm := GeneratorsOfGroup( NormalizerInGLnZ( grp ) );
   return ZassFunc( grp, norm, orbsflag, false );
end );


#############################################################################
##
#M  SpaceGroupTypesByPointGroupOnLeft( <grp> [, <orbsflag> ] )
##
InstallMethod( SpaceGroupTypesByPointGroupOnLeft, true,
   [ IsCyclotomicMatrixGroup ], 0,
function( grp )
   local norm;
   norm := GeneratorsOfGroup( NormalizerInGLnZ( grp ) );
   return ZassFunc( grp, norm, false, true );
end );

InstallOtherMethod( SpaceGroupTypesByPointGroupOnLeft, true,
   [ IsCyclotomicMatrixGroup, IsBool ], 0,
function( grp, orbsflag )
   local norm;
   norm := GeneratorsOfGroup( NormalizerInGLnZ( grp ) );
   return ZassFunc( grp, norm, orbsflag, true );
end );


#############################################################################
##
#M  SpaceGroupTypesByPointGroup( <grp> [, <orbsflag> ] )
##
InstallMethod( SpaceGroupTypesByPointGroup, true,
   [ IsCyclotomicMatrixGroup ], 0,
function( grp )
   local norm;
   norm := GeneratorsOfGroup( NormalizerInGLnZ( grp ) );
   return ZassFunc( grp, norm, false, CrystGroupDefaultAction=LeftAction );
end );

InstallOtherMethod( SpaceGroupTypesByPointGroup, true,
   [ IsCyclotomicMatrixGroup, IsBool ], 0,
function( grp, orbsflag )
   local norm;
   norm := GeneratorsOfGroup( NormalizerInGLnZ( grp ) );
   return ZassFunc( grp, norm, orbsflag, CrystGroupDefaultAction=LeftAction );
end );

