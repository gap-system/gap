#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Willem de Graaf, and Craig A. Struble.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for modules over Lie algebras.
##


###########################################################################
##
#R  IsZeroCochainRep( <c> )
##
DeclareRepresentation( "IsZeroCochainRep", IsPackedElementDefaultRep, [1] );

##############################################################################
##
#M  Cochain( <V>, <s>, <list> )
##
##
InstallMethod( Cochain,
        "for a module over a Lie algebra, an integer and an object",
        true, [ IsAlgebraModule, IsInt, IsObject ], 0,
        function( V, s, obj )

    local fam,type;

         if IsLeftAlgebraModuleElementCollection( V ) then
             if IsRightAlgebraModuleElementCollection( V ) then
                Error("cochains are note defined for bi-modules");
             else
                 if not IsLieAlgebra( LeftActingAlgebra( V ) ) then
                     TryNextMethod();
                 fi;
             fi;
         else
             if not IsLieAlgebra( RightActingAlgebra( V ) ) then
                 TryNextMethod();
             fi;
         fi;

    # Every s-cochain has the same type, so we store the types in the
    # module. The family of an s-cochain knows about its order (s), and
    # about the underlying module. 0 is not a position in a list, so we store
    # the type of the 0-cochains elsewhere.

         if not IsBound( V!.cochainTypes ) then
            V!.cochainTypes:= [ ];
         fi;
         if s = 0 then
           if not IsBound( V!.zeroCochainType ) then
             fam:= NewFamily( "CochainFamily", IsCochain );
             fam!.order:= s;
             fam!.module:= V;
             type:= NewType( fam, IsZeroCochainRep );
             V!.zeroCochainType:= type;
           else
             type:= V!.zeroCochainType;
           fi;
           return Objectify( type, [ obj ] );
         fi;

         if not IsBound( V!.cochainTypes[s] ) then
            fam:= NewFamily( "CochainFamily", IsCochain );
            fam!.order:= s;
            fam!.module:= V;
            type:= NewType( fam, IsPackedElementDefaultRep );
            V!.cochainTypes[s]:= type;
         else
            type:= V!.cochainTypes[s];
         fi;
         return Objectify( type, [ Immutable( obj ) ] );

end );

##############################################################################
##
#M  ExtRepOfObj( <coch> ) . . . . . . . . . . . . . . . for a cochain
##
InstallMethod( ExtRepOfObj,
        "for a cochain",
        true, [ IsCochain and IsPackedElementDefaultRep ], 0,
        c -> c![1] );


##############################################################################
##
#M  PrintObj( <coch> ) . . . . . . . . . . . . . . . for cochains
##
##
InstallMethod( PrintObj,
       "for a cochain",
       true, [ IsCochain ], 0,
       function( c )

          Print("<",FamilyObj(c)!.order,"-cochain>");
end );


##############################################################################
##
#M  CochainSpace( <V>, <s> ) . . . . . . . for a module over a Lie algebra and
##                                         an integer
##
##
InstallMethod( CochainSpace,
     "for a module over a Lie algebra and an integer",
     true, [ IsAlgebraModule, IS_INT ], 0,
     function( V, s )

       local L,r,n,F,tups,bas,k,t,l;

       L:= ActingAlgebra( V );
       if not IsLieAlgebra( L ) then
         Error("<V> must be a module over a Lie algebra");
       fi;

       r:= Dimension( V );
       F:= LeftActingDomain( L );

       if r = 0 then
         if s = 0 then
           return VectorSpace( F, [], Cochain( V, 0, Zero(V) ), "basis" );
         else
           return VectorSpace( F, [], Cochain( V, s, [] ), "basis" );
         fi;
       fi;

       if s = 0 then
         bas:= List( BasisVectors( Basis( V ) ), x -> Cochain( V, s, x ) );
         return VectorSpace( F, bas, "basis" );
       fi;

       n:= Dimension( L );
       tups:= Combinations( [1..n], s );

    #Every tuple gives rise to `r' basis vectors.

       bas:= [ ];
       for k in [1..r] do
         for t in tups do
           l:= List( [1..r], x -> [] );
           Add( l[k], [ t, One( F ) ] );
           Add( bas, l );
         od;
       od;

       bas:= List( bas, x -> Cochain( V, s, x ) );
       FamilyObj( bas[1] )!.tuples:= tups;
       return VectorSpace( F, bas, "basis" );
end );



##############################################################################
##
#M  \+( <c1>, <c2> ) . . . . . . . . . . . . . . . . . . . for two cochains
#M  AdditiveInverseOp( <c> ) . . . . .  . . . . . . . . . . . . . . . . for a cochain
#M  \*( <scal>, <c> ) . . . . . . . . . . . . . . for a scalar and a cochain
#M  \*( <c>, <scal> ) . . . . . . . . . . . . . . for a chain and a scalar
#M  \<( <c1>, <c2> ) . . . . . . . . . . . . . . . . . . . for two cochains
#M  \=( <c1>, <c2> ) . . . . . . . . . . . . . . . . . . . for two cochains
#M  ZeroOp( <c> ) . . . . . . . . . . . . . . . . . . . .  for a cochain
##
InstallMethod( \+,
    "for two cochains",
    IsIdenticalObj, [ IsCochain and IsPackedElementDefaultRep,
            IsCochain and IsPackedElementDefaultRep ], 0,
    function( c1, c2 )

      local l1,l2,r,l,k,list,i;

      l1:= c1![1]; l2:= c2![1];
      r:= Length( l1 );

  # We `merge the two lists'.

      l:= [ ];
      for k in [1..r] do
        if l1[k] = [] then
          l[k]:= l2[k];
        elif l2[k] = [ ] then
          l[k]:= l1[k];
        else
          list:= List( l1[k], ShallowCopy );
          Append( list, List( l2[k], ShallowCopy ) );
          SortBy( list, t -> t[1] );
          i:= 1;
          while i < Length( list ) do  # take equal things together.
            if list[i][1] = list[i+1][1] then
               list[i][2]:= list[i][2]+list[i+1][2];
               Remove( list, i+1 );
            else
               i:= i+1;
            fi;
          od;
          list:= Filtered( list, x -> x[2]<>0*x[2] );
          l[k]:= list;
        fi;
      od;
      return Objectify( TypeObj( c1 ), [ Immutable( l ) ] );

end );

InstallMethod( \+,
    "for two 0-cochains",
    IsIdenticalObj, [ IsCochain and IsZeroCochainRep,
            IsCochain and IsZeroCochainRep ], 0,
    function( c1, c2 )

      return Objectify( TypeObj( c1 ), [ c1![1] + c2![1] ] );
end );

InstallMethod( AdditiveInverseOp,
     "for a cochain",
     true, [ IsCochain and IsPackedElementDefaultRep ], 0,
     function( c )

       local l,lc,k,i;

       l:= [ ];
       lc:= c![1];
       for k in [1..Length(lc)] do
         l[k]:= List( lc[k], ShallowCopy );
         for i in [1..Length(l[k])] do
           l[k][i][2]:= -l[k][i][2];
         od;
       od;
       return Objectify( TypeObj( c ), [ Immutable( l ) ] );
end );

InstallMethod( AdditiveInverseOp,
     "for a 0-cochain",
     true, [ IsCochain and IsZeroCochainRep ], 0,
     function( c )

      return Objectify( TypeObj( c ), [ -c![1] ] );
end );



InstallMethod( \*,
     "for scalar and cochain",
     true, [ IsScalar, IsCochain and IsPackedElementDefaultRep ], 0,
     function( scal, c )

       local l,lc,k,i;

       l:= [ ];
       lc:= c![1];
       for k in [1..Length(lc)] do
         l[k]:= List( lc[k], ShallowCopy );
         for i in [1..Length(l[k])] do
           l[k][i][2]:= scal*l[k][i][2];
         od;
       od;
       return Objectify( TypeObj( c ), [ Immutable( l ) ] );

end );

InstallMethod( \*,
     "for scalar and cochain",
     true, [ IsScalar and IsZero, IsCochain and IsPackedElementDefaultRep ], 0,
     function( scal, c )

       return Zero( c );
end );

InstallMethod( \*,
     "for scalar and 0-cochain",
     true, [ IsScalar, IsCochain and IsZeroCochainRep ], 0,
     function( scal, c )

       return Objectify( TypeObj( c ), [ scal*c![1] ] );
end );

InstallMethod( \*,
     "for cochain and scalar",
     true, [ IsCochain and IsPackedElementDefaultRep, IsScalar ], 0,
     function( c, scal )

       local l,lc,k,i;

       l:= [ ];
       lc:= c![1];
       for k in [1..Length(lc)] do
         l[k]:= List( lc[k], ShallowCopy );
         for i in [1..Length(l[k])] do
           l[k][i][2]:= scal*l[k][i][2];
         od;
       od;
       return Objectify( TypeObj( c ), [ Immutable( l ) ] );

end );

InstallMethod( \*,
     "for cochain and scalar",
     true, [ IsCochain and IsPackedElementDefaultRep, IsScalar and IsZero ], 0,
     function( c, scal )

       return Zero( c );
end );

InstallMethod( \*,
     "for 0-cochain and scalar",
     true, [ IsCochain and IsZeroCochainRep, IsScalar ], 0,
     function( c, scal )

        return Objectify( TypeObj( c ), [ scal*c![1] ] );
end );

InstallMethod( \<,
     "for two cochains",
     true, [ IsCochain and IsPackedElementDefaultRep,
             IsCochain and IsPackedElementDefaultRep ],0,
     function( c1, c2 )
        return c1![1]<c2![1];
end );

InstallMethod( \=,
     "for two cochains",
     true, [ IsCochain and IsPackedElementDefaultRep,
             IsCochain and IsPackedElementDefaultRep ],0,
     function( c1, c2 )
        return c1![1]=c2![1];
end );

InstallMethod( ZeroOp,
     "for a cochain",
     true, [ IsCochain and IsPackedElementDefaultRep ], 0,
     function( c )

        local list;

        list:= List( c![1], x -> [] );
        return Objectify( TypeObj( c ), [ Immutable( list ) ] );
end );

InstallMethod( ZeroOp,
     "for a 0-cochain",
     true, [ IsCochain and IsZeroCochainRep ], 0,
     function( c )

       return Objectify( TypeObj( c ), [ Zero( c![1] ) ] );
end );

#############################################################################
##
#M  NiceFreeLeftModuleInfo( <C> ) . . . . . . . . . for a module of cochains
#M  NiceVector ( <C>, <c> ) . . . . .for a module of cochains and a cochain
#M  UglyVector( <C>, <v> ) . . . . . for a module of cochains and a row vector
##
InstallHandlingByNiceBasis( "IsCochainsSpace", rec(
    detect := function( R, gens, V, zero )
      return IsCochainCollection( V );
      end,

    NiceFreeLeftModuleInfo := function( C )

        local G,tups,g,l,k,i;

  # We collect together the tuples occurring in the generators of `C'
  # and store them in `C'. If the dimension of `C' is small with respect
  # to the number of possible tuples, then this leads to smaller nice
  # vectors.

        if ElementsFamily( FamilyObj( C ) )!.order = 0 then
          return true;
        fi;

        G:= GeneratorsOfLeftModule( C );
        tups:= [ ];
        for g in G do
          l:= g![1];
          for k in [1..Length(l)] do
            for i in [1..Length(l[k])] do
              AddSet( tups, l[k][i][1] );
            od;
          od;
        od;
        return tups;
      end,

    NiceVector := function( C, c )
      local tt,l,v,k,i,p;

      if IsZeroCochainRep( c ) then
        return Coefficients( Basis( FamilyObj( c )!.module ), c![1] );
      elif not IsPackedElementDefaultRep( c ) then
        TryNextMethod();
      fi;
      tt:= NiceFreeLeftModuleInfo( C );
      l:= c![1];

   # Every tuple gives rise to dim V entries in the nice Vector
   # (where V is the Lie algebra module).

      v:= ListWithIdenticalEntries( Length(l)*Length(tt),
                                     Zero( LeftActingDomain( C ) ) );
      if v = [ ] then v:= [  Zero( LeftActingDomain( C ) ) ]; fi;

      for k in [1..Length(l)] do
        for i in [1..Length(l[k])] do
          p:= Position( tt, l[k][i][1] );
          if p = fail then return fail; fi;
          v[(k-1)*Length(tt)+p]:= l[k][i][2];
        od;
      od;
      return v;
      end,

    UglyVector := function( C, vec )
      local l,tt,k,j,i,fam;

  # We do the inverse of `NiceVector'.

      fam:= ElementsFamily( FamilyObj( C ) );
      if fam!.order = 0 then

        return Objectify( fam!.module!.zeroCochainType, [
                 LinearCombination( Basis( fam!.module ), vec ) ]  );
      fi;

      l:= [ ];
      tt:= NiceFreeLeftModuleInfo( C );
      k:= 1;
      j:=0;
      while j <> Length( vec ) do
        l[k]:= [ ];
        for i in [j+1..j+Length(tt)] do
          if vec[i] <> 0*vec[i] then
            Add( l[k], [ tt[i-j], vec[i] ] );
          fi;
        od;
        k:= k+1;
        j:= j+ Length(tt);
      od;

      return Objectify( fam!.module!.cochainTypes[ fam!.order ],
                       [ Immutable(l) ] );
      end ) );


##############################################################################
##
#F   ValueCochain( <c>, <y1>, ... ,<ys> )
##
##
InstallGlobalFunction( ValueCochain,
       function( arg )

         local c,ys,V,L,cfs,le,k,cfs1,i,j,cf,val,vs,ind,
               sign, # sign of a permutation.
               p,ec;

     # We also allow for lists as argument of the function.
     # Such a list must then consist of the listed arguments.

         if IsList( arg[1] ) then arg:= arg[1]; fi;

         c:= arg[1];
         if not IsCochain( c ) then
           Error( "first arggument must be a cochain" );
         fi;

         if FamilyObj( c )!.order = 0 then
           return c![1];
         fi;

         ys:= arg{[2..Length(arg)]};
         if Length( ys ) <> FamilyObj( c )!.order then
           Error( "number of arguments is not equal to the order of <c>" );
         fi;

         V:= FamilyObj( c )!.module;
         L:= ActingAlgebra( V );
         cfs:= [ List( ys, x -> Coefficients( Basis(L), x ) ) ];
         le:= Length( ys );
         k:= 1;

   # We expand the list of coefficients to a list of elements of the form
   #
   #         [ [2/3,2], [7,1], [1/3,3] ]
   #
   # meaning that there we have to evaluate 2/3*7*1/3*c( x_2, x_1, x_3 ).

         while k <= le do

           cfs1:= [ ];
           for i in [1..Length(cfs)] do
             for j in [1..Length(cfs[i][k])]  do
               if cfs[i][k][j] <> 0*cfs[i][k][j] then
                  cf:= ShallowCopy( cfs[i] );
                  cf[k] := [ cf[k][j], j ];
                  Add( cfs1, cf );
               fi;
             od;
           od;
           cfs:= cfs1;
           k:= k+1;
         od;

   # We loop over the expanded list, and add the values that we get.

         ec:= c![1];
         val:= Zero( V );
         vs:= BasisVectors( Basis( V ) );
         for i in [1..Length( cfs )] do
           cf:= Product( List( cfs[i], x -> x[1] ) );
           ind:= List( cfs[i], x -> x[2] );
           sign:= SignPerm( Sortex( ind ) );
           for k in [1..Length(ec)] do
             p:= PositionProperty( ec[k], x -> x[1] = ind );
             if p <> fail then
               val:= val +  ec[k][p][2]*sign*cf*vs[k];
             fi;
           od;
         od;

         return val;

end );


#############################################################################
##
#V  LieCoboundaryOperator
##
##  Takes an s-cochain, and returns an (s+1)-cochain.
##
InstallGlobalFunction( LieCoboundaryOperator,

     function( c )

       local s,V,L,bL,n,fam,tups,type,list,t,val,cfs,k,q,r,elts,z,inp,sn,F;

       s:= FamilyObj( c )!.order;
       V:= FamilyObj( c )!.module;
       L:= ActingAlgebra( V );
       bL := BasisVectors( Basis( L ) );
       n:= Dimension( L );
       F:= LeftActingDomain( V );

   # We get the type of the (s+1)-cochains, and store the tuples we need
   # in the family (so that in the next call of `LieCoboundaryOperator' we
   # do not need to recompute them).

       if IsBound( V!.cochainTypes[s+1] ) then
          fam:= FamilyType( V!.cochainTypes[s+1] );
          if IsBound( fam!.tuples ) then
            tups:= fam!.tuples;
          else
            tups:= Combinations( [1..n], s+1 );
            fam!.tuples:= tups;
          fi;
       else
          tups:= Combinations( [1..n], s+1 );
          fam:= NewFamily( "CochainFamily", IsCochain );
          fam!.order:= s+1;
          fam!.module:= V;
          fam!.tuples:= tups;
          type:= NewType( fam, IsPackedElementDefaultRep );
          V!.cochainTypes[s+1]:= type;
       fi;

       list:= List( [1..Dimension(V)], x -> [] );
       for t in tups do

   # We calculate \delta(c)(x_{i_1},...,x_{i_s+1}) (where \delta denotes
   # the coboundary operator). We use the definition of \delta as given in
   # Jacobson, Lie Algebras, Dover 1979, p. 94. There he writes about right
   # modules. We cater for left and right modules; for left modules we have
   # to add a - when acting.

         val:= Zero( V );
         sn:= (-1)^s;
         for q in [1..s+1] do
           elts:= bL{t};
           z:= elts[q];
           Remove( elts, q );
           inp:= [c]; Append( inp, elts );
           if IsLeftAlgebraModuleElementCollection( V ) then
             val:= val - sn*( z^ValueCochain( inp ) );
           else
             val:= val + sn*( ValueCochain( inp )^z );
           fi;
           sn:= -sn;

           for r in [q+1..s+1] do
             elts:= bL{t};
             z:= elts[q]*elts[r];
             Unbind( elts[q] ); Unbind( elts[r] );
             elts:= Compacted( elts );
             inp:= [ c ]; Append( inp, elts ); Add( inp, z );
             val:= val+(-1)^(q+r)*ValueCochain( inp );
           od;
         od;

         cfs:= Coefficients( Basis(V), val );
         for k in [1..Length(cfs)] do
           if cfs[k] <> 0*cfs[k] then
             Add( list[k], [ t, cfs[k] ] );
           fi;
         od;

       od;

       return Cochain( V, s+1, list );

end );


##############################################################################
##
#M  Coboundaries( <V>, <s> ) . . . . . . . . . for alg module and integer
##
##
InstallMethod( Coboundaries,
    "for module over a Lie algebra and an integer",
    true, [ IsAlgebraModule, IS_INT ], 0,
    function( V, s )

      local Csm1,gens;

   # if s=0, then the space is zero.

      if s = 0 then
          return VectorSpace( LeftActingDomain(V),
                         [ ], Cochain( V, 0, Zero(V) ), "basis" );
      fi;

   # The s-coboundaries are the images of the (s-1)-cochains under
   # the coboundary operator.

      Csm1:= CochainSpace( V, s-1 );
      gens:= List( GeneratorsOfLeftModule( Csm1 ), x ->
                                       LieCoboundaryOperator(x) );
      if Length(gens) = 0 then
          return VectorSpace( LeftActingDomain(V),
                         [ ], Cochain( V, s, [] ), "basis" );
      fi;
      return VectorSpace( LeftActingDomain(V), gens );

end );


InstallMethod( Cocycles,
    "for module over a Lie algebra and an integer",
    true, [ IsAlgebraModule, IS_INT ], 0,
    function( V, s )

      local Cs,gens,Bsp1,B,eqmat,sol;

  # The set of s-cocycles is the kernel of the coboundary operator,
  # when restricted to the space of s-cochains.

      Cs:= CochainSpace( V, s );
      if IsTrivial(Cs) then return Cs; fi;
      gens:= List( GeneratorsOfLeftModule( Cs ), x ->
                                       LieCoboundaryOperator(x) );

      Bsp1:= VectorSpace( LeftActingDomain(V), gens );
      B:= Basis( Bsp1 );

      if Dimension( Bsp1 ) > 0 then
          eqmat:= List( gens, x -> Coefficients( B, x ) );
          sol:= NullspaceMat( eqmat );
          sol:= List( sol, x -> LinearCombination(
                        GeneratorsOfLeftModule(Cs),x));
          return Subspace( Cs, sol, "basis" );
      else
          # in this case the every cochain is a cocycle.
          return Cs;
      fi;


end );

############################################################################
##
#M  WeylGroup( <R> ) . . . . . . . . . . . . . . . . . . . for a root system
##
InstallMethod( WeylGroup,
        "for a root system",
        true, [ IsRootSystem ], 0,
        function( R )

          local   C,  refl,  rank,  i,  m,  G,  RM,  j;

          C:= CartanMatrix( R );

      # We calculate a list of simple reflections that generate the
      # Weyl group. The reflections are given by the matrices of their
      # action on the fundamental weights. Let r_i denote the i-th
      # simple reflection, and \lambda_i the i-th fundamental weight.
      # Then r_i(\lambda_j) = \lambda_j -\delta_{ij} \alpha_i, where
      # \alpha_i is the i-th simple root. Furthermore, in the basis of
      # fundamental weights the coefficients of the simple root \alpha_i
      # are the i-th row of the Cartan matrix C. So the matrix of the
      # i-th reflection is the identity matrix, with C[i] subtracted
      # from the i-th row. So the action of a reflection with matrix m
      # on a weight \mu = [ n_1,.., n_l] (list of integers) is given by
      # \mu*m.

          refl:= [ ];
          rank:= Length( C);
          for i in [1..rank] do
              m:= IdentityMat( rank, rank );
              m[i]:=m[i]-C[i];
              Add( refl, m );
          od;
          G:= Group( refl );
          SetIsWeylGroup( G, true );
          RM:=[];
          for i in [1..rank] do
              RM[i]:= [ ];
              for j in [1..rank ] do
                  if C[i][j] <> 0 then
                      Add( RM[i], [j,C[i][j]] );
                  fi;
              od;
          od;
          SetSparseCartanMatrix( G, RM );
          SetRootSystem( G, R );
          return G;
end );

#############################################################################
##
#M  ApplySimpleReflection( <SC>, <i>, <w> )
##
##
InstallMethod( ApplySimpleReflection,
   "for a sparse Cartan matrix, index and weight",
   true, [ IsList, IS_INT, IsList ], 0,

function( SC, i, w )

          local   p, ni;

          ni:= w[i];
          if ni = 0 then return; fi;
          for p in SC[i] do
              w[p[1]]:= w[p[1]]-ni*p[2];
          od;

end );

############################################################################
##
#M  LongestWeylWordPerm( <W> ) . . . . . . . . . . . . . . . for a Weyl group
##
##
InstallMethod(LongestWeylWordPerm,
              "for Weyl group",
              true, [ IsWeylGroup ], 0,
          function( W )

          local   M,  rho,  p;

          M:= SparseCartanMatrix( W );

     # rho will be the Weyl vector (in the basis of fundamental weights).

          rho:= List( [1..Length(M)], x -> -x );
          p:= 1;

          while p <> fail do
              ApplySimpleReflection( M, p, rho );
              p:= PositionProperty( rho, x -> x < 0 );
          od;

          return PermList( List( [1..Length(M)], x -> Position( rho, x ) ) );

end );

#############################################################################
##
#M  ConjugateDominantWeight( <W>, <w> )
##
##
InstallMethod( ConjugateDominantWeight,
              "for Weyl group and weight",
              true, [ IsWeylGroup, IsList ], 0,
              function( W, wt )

          local   ww,  M,  p;

          ww:= ShallowCopy( wt );
          M:= SparseCartanMatrix( W );
          p:= PositionProperty( ww, x -> x < 0 );

      # We apply simple reflections until `ww' is dominant.

          while p <> fail do
              ApplySimpleReflection( M, p, ww );
              p:= PositionProperty( ww, x -> x < 0 );
          od;
          return ww;

end);

###########################################################################
##
#M  ConjugateDominantWeightWithWord( <W>, <wt> )
##
##
InstallMethod( ConjugateDominantWeightWithWord,
              "for Weyl group and weight",
              true, [ IsWeylGroup, IsList ], 0,
              function( W, wt )

          local   ww,  M,  p, word;

          ww:= ShallowCopy( wt );
          word:= [ ];
          M:= SparseCartanMatrix( W );
          p:= PositionProperty( ww, x -> x < 0 );
          while p <> fail do
              ApplySimpleReflection( M, p, ww );
              Add( word, p );
              p:= PositionProperty( ww, x -> x < 0 );
          od;
          return [ ww, word ];
end);


#############################################################################
##
#M  WeylOrbitIterator( <w>, <wt> )
##
##  stack is a stack of weights, i.e., a list of elts of the form [ w, ind ]
##  the last elt of this list [w1,i1] is such that the i1-th refl app to
##  w1 gives currentweight. The second to last elt [w2,i2] is such that the
##  i2-th refl app to w2 gives w1 etc.
##
##  the status indicates whether or not to compute a successor
##     status=1 means output current weight w, next one will be g_0(w)
##     status=2 means output g_0(w), where w=current weight, next one will
##              be the successor of w
##     status=3 means output current weight w, next one will be succ(w)
##
##  midLen is the middle length, to where we have to compute
##  permuteMidLen is true if we have to map the weights of length
##  midLen with the longest Weyl element...
##

############################################################################
##
#M  IsDoneIterator( <it> ) . . . . . . . . . . . . for Weyl orbit iterator
##
BindGlobal( "IsDoneIterator_WeylOrbit", it -> it!.isDone );


############################################################################
##
#M  NextIterator( <it> ) . . . . . . . . . . . . for a Weyl orbit iterator
##
##  The algorithm is due to D. M. Snow (`Weyl group orbits',
##  ACM Trans. Math. Software, 16, 1990, 94--108).
##
BindGlobal( "NextIterator_WeylOrbit", function( it )
    local   output,  mu,  rank,  len,  stack,  bound,  foundsucc,
            pos,  i,  nu,  a;

    if it!.isDone then Error("the iterator is exhausted"); fi;

    if it!.status = 1 then
        it!.status:= 2;
        mu:= it!.currentWeight;
        if mu = 0*mu then
            it!.isDone:= true;
        fi;
        return mu;
    fi;

    if it!.status = 2 then
        output:= -Permuted( it!.currentWeight, it!.perm );
    else
        output:= ShallowCopy( it!.currentWeight );
    fi;

    #calculate the successor of curweight

    mu:= ShallowCopy(it!.currentWeight);
    rank:= Length( mu );
    len:= it!.curLen;
    stack:= it!.stack;
    bound:= 1;
    foundsucc:= false;
    while not foundsucc do

        pos:= fail;
        if len <> it!.midLen then
            for i in [bound..rank] do
                if mu[i]>0 then
                    nu:= ShallowCopy(mu);
                    ApplySimpleReflection( it!.RMat, i, nu );
                    if ForAll( nu{[i+1..rank]}, x -> x >= 0 ) then
                        pos:= i; break;
                    fi;
                fi;
            od;
        fi;

        if pos <> fail then
            Add( stack, [ mu, pos ] );
            foundsucc:= true;
        else

            if mu = it!.root then

                # we cannot find a successor of the root: we are done

                it!.isDone:= true;
                nu:= [];
                foundsucc:= true;
            else
                a:= stack[Length(stack)];
                mu:= a[1]; bound:= a[2]+1;
                len:= len-1;
                Remove( stack, Length(stack) );
            fi;

        fi;

    od;

    it!.stack:= stack;
    it!.curLen:= len+1;
    it!.currentWeight:= nu;
    if len+1 = it!.midLen and not it!.permuteMidLen then
        it!.status:= 3;
    else
        it!.status:= 1;
    fi;

    return output;

end );

InstallMethod( WeylOrbitIterator,
        "for weights of a W-orbit",
        [ IsWeylGroup, IsList ],

        function( W, wt )

    local   mu,  perm,  nu,  len,  i;

    # The iterator starts at the dominant weight of the orbit.

    mu:= ConjugateDominantWeight( W, wt );

    # We calculate the maximum length occurring in an orbit (the length of
    # an element of the orbit being defined as the minimum number of
    # simple reflections that have to be applied in order to get from the
    # dominant weight to the particular orbit element). This will determine
    # whether we also have to apply the longest Weyl element to the elements
    # of "middle" length.

    perm:= LongestWeylWordPerm(W);
    nu:= -Permuted( mu, perm );
    len:= 0;
    while nu <> mu do
        i:= PositionProperty( nu, x -> x < 0 );
        ApplySimpleReflection( SparseCartanMatrix(W), i, nu );
        len:= len+1;
    od;

    return IteratorByFunctions( rec(
               IsDoneIterator := IsDoneIterator_WeylOrbit,
               NextIterator   := NextIterator_WeylOrbit,
#T no `ShallowCopy'!
               ShallowCopy:= function( iter )
                      return rec( root:= ShallowCopy( iter!.root ),
                        currentWeight:= ShallowCopy( iter!.currentWeight ),
                        stack:= ShallowCopy( iter!.stack ),
                        RMat:= iter!.RMat,
                        perm:= iter!.perm,
                        status:= iter!.status,
                        permuteMidLen:=  iter!.permuteMidLen,
                        midLen:=  iter!.midLen,
                        curLen:= iter!.curLen,
                        maxlen:= iter!.maxlen,
                        noPosR:= iter!.noPosR,
                        isDone:= iter!.isDone );
                     end,
                        root:= mu,
                        currentWeight:= mu,
                        stack:= [ ],
                        RMat:= SparseCartanMatrix(W),
                        perm:= perm,
                        status:= 1,
                        permuteMidLen:=  IsOddInt( len ),
                        midLen:=  EuclideanQuotient( len, 2 ),
                        curLen:= 0,
                        maxlen:= len,
                        noPosR:= Length( PositiveRoots(
                                RootSystem(W) ) ),
                        isDone:= false ) );
end );


#############################################################################
##
#M  PositiveRootsAsWeights( <R> )
##
InstallMethod( PositiveRootsAsWeights,
    "for a root system",
    true, [ IsRootSystem ], 0,
    function( R )

      local posR,V,lcombs;

      posR:= PositiveRoots( R );
      V:= VectorSpace( Rationals, SimpleSystem( R ) );
      lcombs:= List( posR, r ->
                       Coefficients( Basis( V, SimpleSystem(R) ), r ) );
      return List( lcombs, c -> LinearCombination( CartanMatrix(R), c ) );

end );

#############################################################################
##
#M  DominantWeights( <R>, <maxw> )
##
InstallMethod( DominantWeights,
    "for a root system and a dominant weight",
    true, [ IsRootSystem, IsList ], 0,
    function( R, maxw )

    local n,posR,V,lcombs,dom,ww,newdom,mu,a,levels,heights,pos;

   # First we calculate the list of positive roots, represented in the
   # basis of fundamental weights. `heights' will be the list of heights
   # of the positive roots.

   posR:= PositiveRoots( R );
   V:= VectorSpace( Rationals, SimpleSystem( R ) );
   lcombs:= List( posR, r -> Coefficients( Basis( V, SimpleSystem(R) ), r ) );
   posR:= List( lcombs, c -> LinearCombination( CartanMatrix(R), c ) );

   heights:= List( lcombs, Sum );

   # Now `dom' will be the list of dominant weights; `levels' will be a list
   # (in bijection with `dom') of the levels of the weights in `dom'.

   dom:= [ maxw ];
   levels:= [ 0 ];

   ww:= [ maxw ];

   # `ww' is the list of weights found in the last round. We subtract the
   # positive roots from the elements of `ww'; algorithm as in
   # R. V. Moody and J. Patera, "Fast recursion formula for weight
   # multiplicities", Bull. Amer. math. Soc., 7:237--242.

   while ww <> [] do

     newdom:= [ ];
     for mu in ww do
       for a in posR do
         if ForAll( mu-a, x -> x >= 0 ) and not (mu-a in dom) then
           Add( newdom, mu - a );
           Add( dom, mu-a );
           pos:= Position( mu, dom );
           Add( levels, levels[Position(dom,mu)]+heights[Position(posR,a)] );
         fi;
       od;
     od;
     ww:= newdom;

   od;

   return [dom,levels];

end );

#############################################################################
##
#M  BilinearFormMat( <R> ) . . . . . . . . . . . . . . for a root system
##                                                     from a Lie algebra
##
##
InstallMethod( BilinearFormMat,
    "for a root system from a Lie algebra",
    true, [ IsRootSystemFromLieAlgebra ] , 0,
    function( R )

     local C, B, roots, i, j;

     C:= CartanMatrix( R );
     B:= NullMat( Length(C), Length(C) );
     roots:= ShallowCopy( PositiveRoots( R ) );
     Append( roots, NegativeRoots( R ) );

     # First we calculate the lengths of the roots. For that we use
     # the following. We have that $\kappa( h_i, h_i ) = \sum_{r\in R}
     # r(h_i)^2$, where $\kappa$ is the Killing form, and the $h_i$
     # are the canonical Cartan generators. Furthermore,
     # $(\alpha_i, \alpha_i) = 4/\kappa(h_i,h_i)$. We note that the roots
     # of R are represented on the basis of the $h_i$, so the $i$-th
     # element of a root $r$, is the value $r(h_i)$.

     for i in [1..Length(C)] do
       B[i][i]:= 4/Sum( List( roots, r -> r[i]^2 ) );
     od;

     # Now we calculate the other entries of the matrix of the bilinear
     # form.

     for i in [1..Length(C)] do
       for j in [i+1..Length(C)] do
         if C[i][j] <> 0 then
           B[i][j]:= C[i][j]*B[j][j]/2;
           B[j][i]:= B[i][j];
         fi;
       od;
     od;

     return B;

end );

#############################################################################
##
#M  DominantCharacter( <R>, <maxw> )
#M  DominantCharacter( <L>, <maxw> )
##
InstallMethod( DominantCharacter,
    "for a root system and a highest weight",
    true, [ IsRootSystem, IsList ], 0,
   function( R, maxw )

   local ww, rank, fundweights, rhs, bilin, i, j, rts, dones, mults,
         lam_rho, clam, WR, refl, grps, orbs, k, mu, zeros, p, O, W, reps,
         sum, a, done_summing, sum1, nu, nu1, mu_rho, gens;

   ww:= DominantWeights( R, maxw );
   rank:= Length( CartanMatrix( R ) );

   # `fundweights' will be a list of the fundamental weights, calculated
   # on the basis of simple roots. `bilin' will be the matrix of the
   # bilinear form of `R', relative to the fundamental weights.
   # We have that $(\lambda_i,\lambda_j) = \zeta_{ji} (\alpha_i,\alpha_i)/2$,
   # where $\zeta_{ji}$ is the $i$-th coefficient in the expression for
   # $\lambda_j$ as a linear combination of simple roots.

   fundweights:= [ ];
   for i in [1..rank] do
     rhs:= ListWithIdenticalEntries( rank, 0 );
     rhs[i]:= 1;
     Add( fundweights, SolutionMat( CartanMatrix(R), rhs ) );
   od;

   bilin:= NullMat( rank, rank );
   for i in [1..rank] do
     for j in [i..rank] do
       bilin[i][j]:= fundweights[j][i]*BilinearFormMat( R )[i][i]/2;
       bilin[j][i]:= bilin[i][j];
     od;
   od;

   # We sort the dominant weights according to level.

   SortParallel( ww[2], ww[1] );

   rts:= ShallowCopy( PositiveRootsAsWeights( R ) );
   Append( rts, -rts );

   # `dones' will be a list of the dominant weights for which we have
   # calculated the multiplicity. `mults' will be a list containing the
   # corresponding multiplicities. `lam_rho' is the weight `maxw+rho',
   # where `rho' is the Weyl vector.

   dones:= [ maxw ];
   mults:= [ 1 ];

   lam_rho:= maxw+List([1..rank], x -> 1 );
   clam:= lam_rho*(bilin*lam_rho);

   WR:= WeylGroup( R );
   refl:= GeneratorsOfGroup( WR );

   # `grps' is a list containing the index lists for the stabilizers of the
   # different weights (i.e., such a stabilizer is generated by the
   # simple reflections corresponding to the indices). `orbs' is a list
   # of orbits of these groups (acting on the roots).

   grps:= [ ]; orbs:= [ ];

   for k in [2..Length(ww[1])] do

       mu:= ww[1][k];

       # We calculate the multiplicity of `mu'. The algorithm is as
       # described in
       # R. V. Moody and J. Patera, "Fast recursion formula for weight
       # multiplicities", Bull. Amer. math. Soc., 7:237--242.
       # First we calculate the orbits of the stabilizer of `mu' (with the
       # additional element -1), acting on the roots.

       zeros:= Filtered([1..rank], x -> mu[x]=0 );
       p:= Position( grps, zeros );
       if p <> fail then
           O:= orbs[p];
       else

           gens:= refl{zeros};
           Add( gens, -IdentityMat(rank) );
           W:= Group( gens );
           O:= Orbits( W, rts );
           Add( grps, zeros );
           Add( orbs, O );
       fi;

       # For each representative of the orbits we calculate the sum occurring
       # in Freudenthal's formula (and multiply by the size of the orbit).

       reps:= List( O, o -> Intersection( o, PositiveRootsAsWeights(R) )[1] );
       sum:= 0;
       for i in [1..Length(reps)] do
           a:= reps[i];
           j:= 1; done_summing:= false;
           sum1:= 0;
           while not done_summing do
               nu:= mu+j*a;
               nu1:= ConjugateDominantWeight( WR, nu );
               if not nu1 in ww[1] then
                   done_summing:= true;
               else

                   p:= Position( dones, nu1 );
                   sum1:= sum1 + mults[p]*(nu*(bilin*a));
                   j:= j+1;
               fi;
           od;
           sum:= sum + Length(O[i])*sum1;
       od;

       mu_rho:= mu+List([1..rank],x->1);

       sum:= sum/( clam - mu_rho*(bilin*mu_rho) );
       Add( dones, mu );
       Add( mults, sum );

   od;

   return [ dones, mults ];

end );

InstallOtherMethod( DominantCharacter,
    "for a semisimple Lie algebra and a highest weight",
    true, [ IsLieAlgebra, IsList ], 0,
   function( L, maxw )
       return DominantCharacter( RootSystem(L), maxw );
end );


###############################################################################
##
#M  DecomposeTensorProduct( <L>, <w1>, <w2> )
##
##
InstallMethod( DecomposeTensorProduct,
     "for a semisimple Lie algebra and two dominant weights",
     true, [ IsLieAlgebra, IsList, IsList ], 0,
    function( L, w1, w2 )

    #W decompose the tensor product of the two irreps of L with hwts
    #w1,w2 respectively. We use Klymik's formula.

    local   R,  W,  ch1,  wts,  mlts,  rho,  i,  it,  ww,  mu,  nu,
            mult,  p;

    R:= RootSystem( L );
    W:= WeylGroup( R );
    ch1:= DominantCharacter( L, w1 );
    wts:= [ ]; mlts:= [ ];
    rho:= ListWithIdenticalEntries( Length( CartanMatrix( R ) ), 1 );

    for i in [1..Length(ch1[1])] do

       # We loop through all weights of the irrep with highest weight <w1>.
       # We get these by taking the orbits of the dominant ones under the
       # Weyl group.

        it:= WeylOrbitIterator( W, ch1[1][i] );
        while not IsDoneIterator( it ) do

            ww:= NextIterator( it ); #+w2+rho;
            ww:= ww+w2+rho;
            mu:= ConjugateDominantWeightWithWord( W, ww );

            if not ( 0 in mu[1] ) then

              # The stabilizer of `ww' is trivial; so `ww' contributes to the
              # formula. `nu' will be the highest weight of the direct
              # summand gotten from `ww'.

                nu:= mu[1]-rho;
                mult:= ch1[2][i]*( (-1)^Length(mu[2]) );
                p:= PositionSorted( wts, nu );
                if not IsBound( wts[p] ) or wts[p] <> nu then
                    Add( wts, nu, p );
                    Add( mlts, mult, p );
                else
                    mlts[p]:= mlts[p]+mult;
                    if mlts[p] = 0 then
                        Remove( mlts, p );
                        Remove( wts, p );
                    fi;

                fi;
            fi;
        od;
    od;
    return [ wts, mlts ];

end );

###############################################################################
##
#M  DimensionOfHighestWeightModule( <L>, <w> )
##
##
InstallMethod( DimensionOfHighestWeightModule,
        "for a semisimple Lie algebra",
        true, [ IsLieAlgebra, IsList ], 0,
        function( L, w )

    local   R,  l,  B,  M,  p,  r,  cf,  den,  num,  i;

    R:= RootSystem( L );
    l:= Length( CartanMatrix( R ) );
    B:= Basis( VectorSpace( Rationals, SimpleSystem(R) ), SimpleSystem(R) );
    M:= BilinearFormMat( R );
    p:= 1;
    for r in PositiveRoots( R ) do
        cf:= Coefficients( B, r );
        den:= 0;
        num:= 0;
        for i in [1..l] do
            num:= num + cf[i]*(w[i]+1)*M[i][i];
            den:= den + cf[i]*M[i][i];
        od;
        p:= p*(num/den);
    od;

    return p;

end );




############################################################################
##
#M  ObjByExtRep( <fam>, <list> )
#M  ExtRepOfObj( <obj> )
##
InstallMethod( ObjByExtRep,
   "for family of UEALattice elements, and list",
   true, [ IsUEALatticeElementFamily, IsList ], 0,
   function( fam, list )
#+
    return Objectify( fam!.packedUEALatticeElementDefaultType,
                    [ Immutable(list) ] );
end );

InstallMethod( ExtRepOfObj,
   "for an UEALattice element",
   true, [ IsUEALatticeElement ], 0,
   function( obj )
#+
   return obj![1];

end );

###########################################################################
##
#M  PrintObj( <m> ) . . . . . . . . . . . . . . . . for an UEALattice element
##
InstallMethod( PrintObj,
        "for UEALattice element",
        true, [IsUEALatticeElement and IsPackedElementDefaultRep], 0,
        function( x )

    local   lst,  k, i, n;

    # This function prints a UEALattice element; see notes above.

    lst:= x![1];
    n:= FamilyObj( x )!.noPosRoots;
    if lst=[] then
        Print("0");
    else
        for k in [1,3..Length(lst)-1] do
            if lst[k+1] > 0 and k>1 then
                Print("+" );
            fi;
            if lst[k+1] <> lst[k+1]^0 then
                Print( lst[k+1],"*");
            fi;
            if lst[k] = [] then
                Print("1");
            else

                for i in [1,3..Length(lst[k])-1] do
                    if lst[k][i] <=n then
                        Print("y",lst[k][i]);
                        if lst[k][i+1]>1 then
                            Print("^(",lst[k][i+1],")");
                        fi;
                    elif lst[k][i] <= 2*n then
                        Print("x",lst[k][i]-n);
                        if lst[k][i+1]>1 then
                            Print("^(",lst[k][i+1],")");
                        fi;
                    else
                        Print("( h",lst[k][i],"/",lst[k][i+1]," )");
                    fi;
                    if i <> Length(lst[k])-1 then
                        Print("*");
                    fi;
                od;
            fi;

        od;

    fi;

end );

#############################################################################
##
#M  OneOp( <m> ) . . . . . . . . . . . . . . . . for a UEALattice element
#M  ZeroOp( <m> ) . . . . . . . . . . . . . . .  for a UEALattice element
#M  \<( <m1>, <m2> ) . . . . . . . . . . . . . . for two UEALattice elements
#M  \=( <m1>, <m2> ) . . . . . . . . . . . . . . for two UEALattice elements
#M  \+( <m1>, <m2> ) . . . . . . . . . . . . . . for two UEALattice elements
#M  \AdditiveInverseOp( <m> )     . . . . . . . . . . . . . . for a UEALattice element
##
##
InstallMethod( OneOp,
        "for UEALattice element",
        true, [ IsUEALatticeElement and IsPackedElementDefaultRep ], 0,
        function( x )

    return ObjByExtRep( FamilyObj( x ), [ [], 1 ] );

end );

InstallMethod( ZeroOp,
        "for UEALattice element",
        true, [ IsUEALatticeElement and IsPackedElementDefaultRep ], 0,
        function( x )

    return ObjByExtRep( FamilyObj( x ), [ ] );

end );


InstallMethod( \<,
                "for two UEALattice elements",
        IsIdenticalObj, [ IsUEALatticeElement and IsPackedElementDefaultRep,
                IsUEALatticeElement and IsPackedElementDefaultRep ], 0,
        function( x, y )
    return x![1]< y![1];
end );

InstallMethod( \=,
                "for two UEALattice elements",
        IsIdenticalObj, [ IsUEALatticeElement and IsPackedElementDefaultRep,
                IsUEALatticeElement and IsPackedElementDefaultRep ], 0,
        function( x, y )


    return x![1] = y![1];
end );


InstallMethod( \+,
        "for two UEALattice elements",
        true, [ IsUEALatticeElement and IsPackedElementDefaultRep,
                IsUEALatticeElement and IsPackedElementDefaultRep], 0,
        function( x, y )

    return ObjByExtRep( FamilyObj(x), ZippedSum( x![1], y![1], 0, [\<,\+] ) );
end );



InstallMethod( AdditiveInverseOp,
        "for UEALattice element",
        true, [ IsUEALatticeElement and IsPackedElementDefaultRep ], 0,
        function( x )

    local   ex,  i;

    ex:= ShallowCopy(x![1]);
    for i in [2,4..Length(ex)] do
        ex[i]:= -ex[i];
    od;
    return ObjByExtRep( FamilyObj(x), ex );
end );

#############################################################################
##
#M  \*( <scal>, <m> ) . . . . . . . . .for a scalar and a UEALattice element
#M  \*( <m>, <scal> ) . . . . . . . . .for a scalar and a UEALattice element
##
InstallMethod( \*,
        "for scalar and UEALattice element",
        true, [ IsScalar, IsUEALatticeElement and
                IsPackedElementDefaultRep ], 0,
        function( scal, x )

    local   ex,  i;

    ex:= ShallowCopy( x![1] );
    for i in [2,4..Length(ex)] do
        ex[i]:= scal*ex[i];
    od;
    return ObjByExtRep( FamilyObj(x), ex );
end);

InstallMethod( \*,
        "for UEALattice element and scalar",
        true, [ IsUEALatticeElement and IsPackedElementDefaultRep,
                IsScalar ], 0,
        function( x, scal )

    local   ex,  i;

    ex:= ShallowCopy( x![1] );
    for i in [2,4..Length(ex)] do
        ex[i]:= scal*ex[i];
    od;
    return ObjByExtRep( FamilyObj(x), ex );
end);


#############################################################################
##
#F  CollectUEALatticeElement( <noPosR>, <BH>, <f>, <vars>, <Rvecs>, <RT>,
##                                                          <posR>, <lst> )
##
InstallGlobalFunction( CollectUEALatticeElement,

    function( noPosR, BH, f, vars, Rvecs, RT, posR, lst )

    local   i, j, k, l, p, q, r, s,   # loop variables
            todo,                # list of monomials that still need treatment
            dones,               # list of monomials that don't
            collocc,             # `true' is a collection has occurred
            mon, mon1,           # monomials,
            cf, c1, c2, c3, c4,  # coefficients
            temp,                # for temporary storing
            start, tail,         # beginning and end of a monomial
            h,                   # Cartan element
            rr,                  # list of monomials with coefficients
            type,                # type of a pseudo root system of rank 2
            i1, j1, m, n,        # integers
            a, b,                # roots
            p1, p2, p3, p4,      # positions
            st1,
            has_h,
            mons,
            pol,
            ww,
            mm,
            min,
            WriteAsLCOfBinoms;   # local function.


     WriteAsLCOfBinoms:= function( vars, pol )

        # This function writes the polynomial `pol' in the variables `vars'
        # as a linear combination of polynomials of the form
        # (x_1\choose m_1).....(x_t\choose m_t). (`pol' must tae integral
        # values when evaluated at integral points.)

         local   d,  ind,  e,  fam,  fac,  k,  p,  q,  bin,  cc,  res,
                 mon, dfac;

         if IsConstantRationalFunction( pol ) or vars = [] then
             return [ [], pol ];
         fi;
         d:=  DegreeIndeterminate(pol,vars[1]);
         if d = 0 then
            # The variable `vars[1]' does not occur in `pol', so we can
            # recurse with one variable less.
             return WriteAsLCOfBinoms( vars{[2..Length(vars)]}, pol );
         fi;

         ind:= IndeterminateNumberOfLaurentPolynomial( vars[1] );
         e:= ShallowCopy( ExtRepPolynomialRatFun( pol ) );
         fam:= FamilyObj( pol );

         # `fac' will be contain the monomials of degree `d' in the variable
         # `vars[1]'.
         fac:= [ ];
         for k in [1,3..Length(e)-1] do

             if e[k]<>[] and e[k][1] = ind and e[k][2] = d then
                 Add( fac, e[k] ); Unbind( e[k] );
                 Add( fac, e[k+1] ); Unbind( e[k+1] );
             fi;
         od;
         e:= Compacted( e );
         # `e' now contains the rest of the polynomial.

         p:= PolynomialByExtRepNC( fam, fac )/(vars[1]^d);
         q:= PolynomialByExtRepNC( fam, e );

         # So now we have `pol = vars[1]^d*p+q', where `p' does not contain
         # `vars[1]' and `q' has lower degree in `vars[1]'. We can also
         # write this as (writing x = vars[1])
         #
         #            (x)            (x)
         #    pol = d!(d)p + q - { d!(d) - x^d }p
         #
         # `bin' will be d!* x\choose d.

         bin:= Product( List( [0..d-1], x -> vars[1] - x ) );
         q:= q - (bin-vars[1]^d)*p;
         cc:= WriteAsLCOfBinoms( vars{[2..Length(vars)]}, p );

         # No wwe prepend d!*(x\choose d) to cc.
         dfac := Factorial( d );
         res:=[ ];
         for k in [1,3..Length(cc)-1] do
             mon:=[ vars[1], d ];
             Append( mon, cc[k] );
             Add( res, mon ); Add( res, dfac*cc[k+1] );
         od;
         Append( res, WriteAsLCOfBinoms( vars, q ) );
         for k in [2,4..Length(res)] do
             if res[k] = 0*res[k] then
                 Unbind( res[k-1] ); Unbind( res[k] );
             fi;
         od;

         return Compacted( res );
     end;


    # We collect the UEALattice element represented by the data in `lst'.
    # `lst' represents a UEALattice element in the usual way, except that
    # a Cartan element is now not represented by an index, but by a list
    # of two elements: the element of the Cartan subalgebra, and an integer
    # (meaning `h-k', if the list is [h,k]). The ordering
    # is as follows: first come the `negative' root vectors (in the
    # same order as the roots), then the Cartan elements, and then the
    # `positive' root vectors.

    todo:= ShallowCopy( lst );
    dones:= [ ];

    while todo <> [] do

     # `collocc' will be `true' once a collection has occurred.

        collocc:= false;
        mon:= ShallowCopy(todo[1]);

     # We collect `mon'.

        i:= 1;
        while i <= Length( mon ) - 3 do

            # Collect `mon[i]' and `mon[i+1]'.
            if IsList( mon[i] ) and IsList( mon[i+2] ) then

                # They are both Cartan elements; so we do nothing.
                i:= i+2;
            elif IsList( mon[i] ) and not IsList( mon[i+2] ) then

                #`mon[i]' is a Cartan element, but `mon[i+2]' is not.
                if mon[i+2] > noPosR then

                    # They are in the right order; so we do nothing.
                    i:= i+2;
                else

                    # They are not in the right order, so we swap.
                    # `cf' is the coefficient in [ h, x ] = cf*x,
                    # where h is the Cartan element, x an element from the
                    # root space corresponding to `mon[i+2]'. When swapping
                    # the second element of the list representing the Cartan
                    # element changes.
                    cf:= Coefficients( BH, mon[i][1] )*posR[mon[i+2]];
                    temp:= mon[i];
                    temp[2]:= temp[2] +mon[i+3]*cf;
                    mon[i]:= mon[i+2];
                    mon[i+2]:= temp;

                    # Swap the coefficients.
                    temp:= mon[i+1];
                    mon[i+1]:= mon[i+3];
                    mon[i+3]:= temp;
                    todo[1]:= mon;
                    i:= 1;

                fi;
            elif not IsList( mon[i] ) and IsList( mon[i+2] ) then

                # Here `mon[i]' is no Cartan element, but `mon[i+2]' is. We
                # do the same as above.
                if mon[i] <= noPosR then
                    i:= i+2;
                else
                    cf:= Coefficients( BH, mon[i+2][1] )*posR[mon[i]];
                    temp:= mon[i+2];
                    temp[2]:= temp[2] - mon[i+1]*cf;
                    mon[i+2]:= mon[i];
                    mon[i]:= temp;
                    temp:= mon[i+1];
                    mon[i+1]:= mon[i+3];
                    mon[i+3]:= temp;
                    todo[1]:= mon;
                    i:= 1;
                fi;
            elif mon[i] = mon[i+2] then

                # They are the same; so we take them together. This costs
                # a binomial factor.
                mon[i+1]:= mon[i+1]+mon[i+3];
                todo[2]:= todo[2]*Binomial(mon[i+1],mon[i+3]);

                Remove( mon, i+2 );
                Remove( mon, i+2 );
                todo[1]:= mon;
            elif mon[i] < mon[i+2] then

                # They are in the right order; we do nothing.
                i:=i+2;
            else

                # We swap them. There are two cases: the two roots are
                # each others negatives, or not. In the first case we
                # get extra Cartan elements. In both cases the result of
                # swapping the two elements will be contained in `rr'.
                # To every element of `rr' we then have to prepend
                # `start' and to append `tail'.

                cf:= todo[2];
                Unbind( todo[1] ); Unbind( todo[2] );
                start:= mon{[1..i-1]};
                tail:= mon{[i+4..Length(mon)]};
                if posR[mon[i]] = -posR[mon[i+2]] then
                    i1:= mon[i]; j1:= mon[i+2];
                    m:= mon[i+1]; n:= mon[i+3];
                    h:= Rvecs[i1]*Rvecs[j1];
                    min:= Minimum( m, n );
                    rr:= [ ];
                    for k in [0..min] do
                      mon1:= [ ];
                      if n-k>0 then
                        Append( mon1, [ j1, n-k ] );
                      fi;
                      if k > 0 then
                        Append( mon1, [ [ h, -n-m+2*k ], k ] );
                      fi;
                      if m-k > 0 then
                        Append( mon1, [ i1, m-k ] );
                      fi;
                      Add( rr, mon1 ); Add( rr, 1 );
                    od;

                else

                # In the second case we have to swap two powers of root
                # vectors. According to the form of the root string
                # we distinguish a few cases. In each case we have a
                # different formula for the result.

                    i1:= mon[i]; j1:= mon[i+2];
                    m:= mon[i+1]; n:= mon[i+3];
                    a:= posR[j1]; b:= posR[i1];
                    if a+b in posR then
                       if a+2*b in posR then
                          if a+3*b in posR then
                             type:= "G2+";
                          else
                             if 2*a+b in posR then
                                type:= "G2~";
                             else
                                type := "B2+";
                             fi;
                          fi;
                       elif 2*a+b in posR then
                            if 3*a+b in posR then
                               type:= "G2-";
                            else
                               type:= "B2-";
                            fi;
                       else
                            type:= "A2";
                       fi;
                    else
                       type:= "A1A1";
                    fi;

                    rr:= [ ];
                    if type = "A1A1" then

                       # The elements simply commute.
                       rr:= [ [ j1, n, i1, m ], 1 ];
                    elif type = "A2" then

                       c1:= -RT[j1][i1];
                       c2:= 1;
                       p1:= Position( posR, a+b );
                       for k in [0..Minimum(m,n)] do
                          mon1:= [ ];
                          if n-k > 0 then
                             Append( mon1, [ j1, n-k ] );
                          fi;
                          if m-k > 0 then
                             Append( mon1, [ i1, m-k] );
                          fi;
                          if k>0 then
                             Append( mon1, [ p1, k ] );
                          fi;
                          Add( rr, mon1 );
                          Add( rr, c2 );
                          c2:= c2*c1;
                       od;

                    elif type = "B2+" then

                       c1:= -RT[j1][i1];
                       p1:= Position( posR, a+b );
                       p2:= Position( posR, a+2*b );
                       c2:= -c1*RT[i1][p1]/2;
                       min:= Minimum( m,n );
                       for k in [0..min] do
                          for l in [0..min] do
                             if n-k-l >= 0 and m-k-2*l >= 0 then
                                mon1:= [ ];
                                if n-k-l > 0 then
                                   Append( mon1, [ j1, n-k-l ] );
                                fi;
                                if m-k-2*l > 0 then
                                   Append( mon1, [ i1, m-k-2*l ] );
                                fi;
                                if k > 0 then
                                   Append( mon1, [ p1, k ] );
                                fi;
                                if l > 0 then
                                   Append( mon1, [ p2, l ] );
                                fi;
                                Add( rr, mon1 );
                                Add( rr, c1^k*c2^l );
                             fi;
                          od;
                       od;

                    elif type = "B2-" then

                       c1:= -RT[j1][i1];
                       p1:= Position( posR, a+b );
                       p2:= Position( posR, 2*a+b );
                       c2:= -c1*RT[j1][p1]/2;
                       min:= Minimum( m,n );
                       for k in [0..min] do
                          for l in [0..min] do
                             if n-k-2*l >= 0 and m-k-l >= 0 then
                                mon1:= [ ];
                                if n-k-2*l > 0 then
                                   Append( mon1, [ j1, n-k-2*l ] );
                                fi;
                                if m-k-l > 0 then
                                   Append( mon1, [ i1, m-k-l ] );
                                fi;
                                if k > 0 then
                                   Append( mon1, [ p1, k ] );
                                fi;
                                if l > 0 then
                                   Append( mon1, [ p2, l ] );
                                fi;
                                Add( rr, mon1 );
                                Add( rr, c1^k*c2^l );
                             fi;
                          od;
                       od;

                    elif type = "G2+" then

                       p1:= Position( posR, a+b );
                       p2:= Position( posR, a+2*b );
                       p3:= Position( posR, a+3*b );
                       p4:= Position( posR, 2*a+3*b );
                       c1:= RT[j1][i1];
                       c2:= RT[i1][p1];
                       c3:= RT[p1][p2];
                       c4:= RT[i1][p2]/2;
                       min:= Minimum(m,n);
                       for p in [0..min] do
                          for q in [0..min] do
                             for r in [0..min] do
                                for s in [0..min] do
                                   if n-p-q-r-2*s>=0 and
                                          m-p-2*q-3*r-3*s >=0  then
                                      mon1:= [ ];
                                      if n-p-q-r-2*s > 0 then
                                         Append( mon1, [ j1, n-p-q-r-2*s ] );
                                      fi;
                                      if m-p-2*q-3*r-3*s > 0 then
                                         Append( mon1, [i1,m-p-2*q-3*r-3*s]);
                                      fi;
                                      if p > 0 then
                                         Append( mon1, [ p1, p ] );
                                      fi;
                                      if q > 0 then
                                         Append( mon1, [ p2, q ] );
                                      fi;
                                      if r > 0 then
                                         Append( mon1, [ p3, r ] );
                                      fi;
                                      if s > 0 then
                                         Append( mon1, [ p4, s ] );
                                      fi;
                                      Add( rr, mon1 );
                                      Add( rr, (-1)^(p+r)*(1/3)^(s+r)*(1/2)^q*
                                        c1^(p+q+r+2*s)*c2^(q+r+s)*c3^s*c4^r );
                                   fi;
                                od;
                             od;
                          od;
                       od;
                    elif type = "G2-" then

                       p1:= Position( posR, a+b );
                       p2:= Position( posR, 2*a+b );
                       p3:= Position( posR, 3*a+b );
                       p4:= Position( posR, 3*a+2*b );
                       c1:= RT[j1][i1];
                       c2:= RT[j1][p1]/2;
                       c3:= RT[j1][p2]/3;
                       c4:= (c1*RT[p1][p2]+c3*RT[i1][p3])/2;
                       min:= Minimum(m,n);
                       for p in [0..min] do
                          for q in [0..min] do
                             for r in [0..min] do
                                for s in [0..min] do
                                   if n-p-2*q-3*r-3*s>=0 and
                                                m-p-q-r-2*s >=0 then
                                      mon1:= [ ];
                                      if n-p-2*q-3*r-3*s > 0 then
                                         Append( mon1,[j1, n-p-2*q-3*r-3*s]);
                                      fi;
                                      if m-p-q-r-2*s > 0 then
                                         Append( mon1, [ i1, m-p-q-r-2*s ] );
                                      fi;
                                      if p > 0 then
                                         Append( mon1, [ p1, p ] );
                                      fi;
                                      if q > 0 then
                                         Append( mon1, [ p2, q ] );
                                      fi;
                                      if r > 0 then
                                         Append( mon1, [ p3, r ] );
                                      fi;
                                      if s > 0 then
                                         Append( mon1, [ p4, s ] );
                                      fi;
                                      Add( rr, mon1 );
                                      Add( rr, (-1)^(p+r)*
                                        c1^(p+q+r+s)*c2^(q+r+s)*c3^r*c4^s );
                                   fi;
                                od;
                             od;
                          od;
                       od;
                    elif type = "G2~" then

                       p1:= Position( posR, a+b );
                       p2:= Position( posR, 2*a+b );
                       p3:= Position( posR, a+2*b );
                       c1:= RT[j1][i1];
                       c2:= RT[j1][p1]/2;
                       c3:= RT[i1][p1]/2;
                       min:= Minimum(m,n);
                       for p in [0..min] do
                          for q in [0..min] do
                             for r in [0..min] do
                                if n-p-2*q-r>=0 and m-p-q-2*r >=0 then
                                   mon1:= [ ];
                                   if n-p-2*q-r > 0 then
                                      Append( mon1, [ j1, n-p-2*q-r ] );
                                   fi;
                                   if m-p-q-2*r > 0 then
                                      Append( mon1, [ i1, m-p-q-2*r ] );
                                   fi;
                                   if p > 0 then
                                      Append( mon1, [ p1, p ] );
                                   fi;
                                   if q > 0 then
                                      Append( mon1, [ p2, q ] );
                                   fi;
                                   if r > 0 then
                                      Append( mon1, [ p3, r ] );
                                   fi;
                                   Add( rr, mon1 );
                                   Add( rr, (-1)^(p)*c1^(p+q+r)*c2^q*c3^r);
                                fi;
                             od;
                          od;
                       od;
                    fi;
                fi;  # End of the piece that swapped two elements, and
                     # produced `rr', which we now insert.

                for j in [1,3..Length(rr)-1] do
                    st1:= List( start, ShallowCopy );
                    Append( st1, rr[j] );
                    Append( st1, List( tail, ShallowCopy ) );
                    p:= Position( todo, st1 );
                    if p = fail then
                        Add( todo, st1 );
                        Add( todo, rr[j+1]*cf );
                    else
                        todo[p+1]:= todo[p+1] + rr[j+1]*cf;
                        if todo[p+1] = 0 then
                            Unbind( todo[p+1] ); Unbind( todo[p] );
                        fi;
                    fi;
                od;
                todo:= Compacted( todo );
                collocc:= true;

               # We performed one collection step, and we break from
               # the loop over i (and thus starting the next collection step).
                break;
            fi;
        od;

        if not collocc then

            # No collection has occurred, so `todo[1]' is in normal form.
            # First we check whether the monomial has any Cartan elements.
            # (Those are represented by lists, instead of integers).

            has_h:= false;
            for i in [1,3..Length(todo[1])-1] do
                if IsList(todo[1][i]) then has_h:= true; break; fi;
            od;

            if not has_h then

              # No Cartan elements; we do not have to transform the monomial.
                mons:= [ todo[1], todo[2] ];
            else

              # Here we do have Cartan elements; those occur as pieces of the
              # monomial in the form [ .... [ h, k ], m ,....] which
              # represents (h-k) \choose m. We have to rewrite those as
              # linear combinations of pure binomials ( of the form
              # h\choose m). We recall that `f' is the map from the
              # Cartan subalgebra into the polynomial ring generated by `vars'.
              # We first transform the Cartan elements into a polynomial,
              # write that polynomial as a linear combination of pure
              # binomials, and transform the result back again.

                start:= todo[1]{[1..i-1]};
                j:= i;
                pol:= vars[1]^0;

                while j <= Length( todo[1] ) and IsList( todo[1][j] ) do
                    q:= Image( f, todo[1][j][1] ) + todo[1][j][2];
                    s:= todo[1][j+1];
                    pol:= pol*
                          Product( List( [0..s-1], x -> q - x ) )/Factorial(s);
                    j:= j+2;
                od;

              # Now we processed the Cartan elements, we still may have a tail.

                if j <= Length( todo[1] ) then
                    tail:= todo[1]{[j..Length(todo[1])]};
                else
                    tail:= [ ];
                fi;

                mons:= [ ];
                ww:= WriteAsLCOfBinoms( vars, pol );

                # Prepend the start, append the tail...

                for k in [1,3..Length(ww)-1] do
                    for l in [1,3..Length(ww[k])-1] do
                        ww[k][l]:= 2*noPosR+Position( vars, ww[k][l] );
                    od;
                    mm:= ShallowCopy( start );
                    Append( mm, ww[k] ); Append( mm, tail );
                    Add( mons, mm );
                    cf:= ww[k+1]*todo[2];
                    if IsRationalFunction( cf ) then
                        cf:= ExtRepPolynomialRatFun( cf )[2];
                    fi;
                    Add( mons, cf );

                od;
            fi;

            # Now insert the monomials (that are in normal form) into
            # the list `dones'.
            for i in [1,3..Length(mons)-1] do

                p:= Position( dones, mons[i] );
                if p = fail then
                    Add( dones, mons[i] );
                    Add( dones, mons[i+1]  );
                else
                    dones[p+1]:= dones[p+1]+mons[i+1];
                    if dones[p+1] = 0 then
                        Remove( dones, p );
                        Remove( dones, p );
                    fi;
                fi;
            od;

            Remove( todo, 1 );
            Remove( todo, 1 );

        fi;
    od;

    return dones;
end );

#############################################################################
##
#M  \*( <x>, <y> ) . . . . . . . . . . . . . . for two UEALattice elements
##
##
InstallMethod( \*,
        "for two UEALattice elements",
        IsIdenticalObj, [ IsUEALatticeElement and IsPackedElementDefaultRep,
                IsUEALatticeElement and IsPackedElementDefaultRep ], 0,
        function( x, y )

    local   fam,  ex,  ey,  lst,  i,  j,  m,  mons,  cfs,
            len, L, n, R, H;

    fam:= FamilyObj( x );
    ex:= x![1]; ey:= y![1];
    L:= fam!.lieAlgebra;
    R:= RootSystem( L );

    # We append every monomial of `y' to every monomial of `x'.
    # We encode the Cartan elements as lists.

    n:= fam!.noPosRoots;
    lst:= [ ];
    for i in [1,3..Length(ex)-1] do
        for j in [1,3..Length(ey)-1] do
            m:= ShallowCopy( ex[i] );
            Append( m, ey[j] );
            Add( lst, m );
            Add( lst, ex[i+1]*ey[j+1] );
        od;
    od;
    for i in [1,3..Length(lst)-1] do
        for j in [1,3..Length(lst[i])-1] do
            if lst[i][j] > 2*n then
                lst[i][j]:= [ CanonicalGenerators( R )[3][ lst[i][j]-2*n ],
                                                                         0 ];
            fi;
        od;
    od;

    lst:= CollectUEALatticeElement( n, fam!.basH, fam!.cartMap, fam!.cartVars,
                  fam!.rootVecs, fam!.rootTable, fam!.roots, lst );
    mons:= [ ]; cfs:= [ ];
    for i in [1,3..Length(lst)-1] do
        Add( mons, lst[i] ); Add( cfs, lst[i+1] );
    od;

    # Sort everything, wrap it up and return.

    SortParallel( mons, cfs );

    lst:= [ ];
    len:= 0;
    for i in [1..Length( mons )] do
        if len > 0 and lst[len-1] = mons[i] then
            lst[len]:= lst[len]+cfs[i];
            if lst[len] = 0*lst[len] then
                Remove( lst, len-1 );
                Remove( lst, len-1 );
                len:= len-2;
            fi;

        else
            Add( lst, mons[i] ); Add( lst, cfs[i] );
            len:= len+2;
        fi;
    od;
    return ObjByExtRep( FamilyObj(x), lst );
end );

############################################################################
##
##
##
##  The next few functions are implementations for vector search tables.
##  The ideas
##  used in this implementation are from Macaulay 2 by Dan Grayson and
##  Mike Stillman.
##

#############################################################################
##
#R  IsVectorSearchTableDefaultRep     Representation of vector search tables.
##
DeclareRepresentation( "IsVectorSearchTableDefaultRep",
    IsVectorSearchTable and IsComponentObjectRep and IsAttributeStoringRep,
    [ "top" ]);            # the top node of the search data structure

## Create a new vector search tree node
BindGlobal( "VSTNode", function(var, exp, nxt)
    return rec( var := var,
                exp := exp,
                nxt := nxt,
                isHeader := false,
                header := 0,
                right := 0,
                left := 0 );
end );

## Insert the node p to the left of node q in the doubly linked list
BindGlobal( "VSTInsertToLeft", function(q, p)
    p.header := q.header;
    p.left := q.left;
    p.right := q;
    q.left.right := p;
    q.left := p;
end );

#############################################################################
##
#O  Insert( <T>, <key>, <data> )
##
##  inserts the object <data> into table <T> with key <key>. The key <key>
##  must be an integer list. Assumes that the identity element is not
##  ever inserted.
##
InstallMethod( Insert,
    "for a vector search table in default representation",
    [ IsVectorSearchTableDefaultRep, IsHomogeneousList, IsObject ],
    function( T, key, data )
        local p,               # Position in the search data structure
              q,               # Position in the search data structure
              i,               # Index into the key
              update,          # The index should be updated
              nxt,             # The next node to follow in the search
              iVar,            # The variable index being inserted
              iExp,            # The exponent being inserted
              iNode,           # The new VST node to insert
              cKey,            # A compressed version of the key
              pState,          # Where new header nodes should be inserted
              headerNode,      # New node to insert for new level
              zeroNode;        # New node to insert for new level

        p := T!.top;
        nxt := 0;
        pState := 0; # 0 means top node, 1 means nxt node.

        # Build a compressed key
        cKey := [];
        for i in [1..Length(key)] do
            if key[i] <> 0 then
                Append(cKey, [i,key[i]]);
            fi;
        od;

        Info(InfoSearchTable, 1, "Compressed key: ", cKey);

        i := Length(cKey)-1;
        while i >= 1 do
            iVar := cKey[i];
            if p = 0 then
                ## Create a new header node for a new variable level
                Info(InfoSearchTable, 1, "Creating new header.");
                if pState = 0 then
                    T!.top := VSTNode(iVar, 0, nxt);
                    p := T!.top;
                else
                    q.nxt := VSTNode(iVar, 0, nxt);
                    p := q.nxt;
                fi;
                p.isHeader := true;
                p.header := p;
                p.left := p;
                p.right := p;
            elif p.var < iVar then
                ## A higher indexed variable has a non-zero component.
                ## Create a new level in the data structure, storing
                ## the current level under the exponent 0 for the new
                ## non-zero component.
                Info(InfoSearchTable, 1, "Creating new layer.");
                headerNode := VSTNode(iVar, 0, nxt);
                zeroNode := VSTNode(iVar, 0, p);
                headerNode.isHeader := true;
                headerNode.left := zeroNode;
                headerNode.right := zeroNode;
                p.nxt := zeroNode;
                zeroNode.right := headerNode;
                zeroNode.left := headerNode;
                zeroNode.header := headerNode;
                headerNode.header := headerNode;
                p := headerNode;
                if pState = 0 then
                    T!.top := p;
                else
                    q.nxt := p;
                fi;
            fi;

            # Need to add a zero layer to the current variable.
            if p.var > iVar then
                iVar := p.var;
                iExp := 0;
                update := false;
            else
                iExp := cKey[i+1];
                update := true;
            fi;

            # Insert into the doubly linked list in the current level
            q := p.right;
            while (not q.isHeader) and (q.exp < iExp) do
                q := q.right;
            od;
            if q.exp <> iExp then
                Info(InfoSearchTable, 1, "Inserting: ", iVar, " ", iExp);
                iNode := VSTNode(iVar, iExp, 0);
                VSTInsertToLeft(q, iNode);
                if i <> 1 or not update then
                    q := iNode;
                else
                    iNode.data := data;
                    return true;
                fi;
            fi;
            nxt := q;
            p := q.nxt;
            pState := 1;
            if update then
                i := i - 2;
            fi;
        od;
        return false;    # already in the table
    end );


#############################################################################
##
#O  Search( <T>, <key> )
##
##  searches the vector search table <T> for a key that divides <key>.
##  If an appropriate key <div> is found, the data stored with <div> is
##  returned. Otherwise, `fail' is returned.
##
InstallMethod( Search,
    "for vector search tables in default representation",
    [ IsVectorSearchTableDefaultRep, IsHomogeneousList ],
    function( T, key )
        local p;    # point into the search data structure

        # Handle empty tables.
        if T!.top = 0 then
            return fail;
        fi;

        p := T!.top;
        while true do
            p := p.right;
            if p.isHeader then
                # Checked all of the elements on the current level, move on.
                p := p.nxt;
                if p = 0 then
                    return fail;
                fi;
            elif p.exp > key[p.var] then
                # Remaining elements are too large, move on.
                p := p.header.nxt;
                if p = 0 then
                    return fail;
                fi;
            elif IsBound(p.data) then
                # Found an element.
                return p.data;
            else
                # Still making progress. Continue the search.
                p := p.nxt;
            fi;
        od;
    end );

#############################################################################
##
#F VectorSearchTable( )
#F VectorSearchTable( <keys>, <data> )
##
## construct an empty search table or a search table containing <data>
## keyed by <keys>. The list <keys> must contain integer lists which are
## interpreted as exponents for variables.
##
## The lists <keys> and <data> must be the same length as well.
##
InstallGlobalFunction( VectorSearchTable,
    function( arg )
        local fam, T, i;

        if Length(arg) <> 0 and Length(arg) <> 2 then
            Error("Usage: VectorSearchTable() or VectorSearchTable( keys, data )");
        fi;
        if Length(arg) = 2 and Length(arg[1]) <> Length(arg[2]) then
            Error("Must provide the same number of keys and data.");
        fi;

        fam := NewFamily("VectorSearchTableFam", IsVectorSearchTable);
        T := Objectify( NewType(fam,
                                IsVectorSearchTableDefaultRep and IsMutable),
                        rec( top := 0) );

        if Length(arg) = 2 then
            for i in [1..Length(arg[1])] do
                Insert(T, arg[1][i], arg[2][i]);
            od;
        fi;

        return T;
    end );


#############################################################################
##
#M ViewObj( <T> )
##
## Prints out simply that this is a vector search table.
##
InstallMethod( ViewObj,
    "for vector search tables",
    [IsVectorSearchTable],
    function( T )
        Print("<vector search table>");
    end );


#############################################################################
##
#M Display( <T> )
##
## Display the contents of <T> in a tree like output.
##
InstallMethod(Display,
    "for vector search tables in default representation",
    [IsVectorSearchTableDefaultRep],
    function(T)
        local DisplayNode,
              DisplayTree;

        DisplayNode := function(n, indent)
            local i;
            for i in [1..indent] do
                Print(" ");
            od;
            Print(n.var, " ", n.exp);
            if IsBound(n.data) then
                Print("  (", n.data, ")");
            fi;
            Print("\n");
        end;

        DisplayTree := function(n, indent)
            local q;

            DisplayNode(n, indent);
            q := n.right;
            while not q.isHeader do
                DisplayNode(q, indent);
                if not IsBound(q.data) then
                    DisplayTree(q.nxt, indent+2);
                fi;
                q := q.right;
            od;
        end;

        if T!.top <> 0 then
            DisplayTree(T!.top, 0);
        fi;
    end );



############################################################################
##
#M  LatticeGeneratorsInUEA( <L> )
##
##
InstallMethod( LatticeGeneratorsInUEA,
        "for semsimple Lie algebra",
        true, [ IsLieAlgebra ], 0,
        function( L )

    local   R,  n,  roots,  fam,  gens,  i, Rvecs, bL, H, vars, P, m, F, j, k,
            B; # Chevalley basis.

    # For every root and every canonical Cartan element, there is a generator.
    # In the family we install a lot of data that is needed in the collection
    # algorithm.

    F:= LeftActingDomain( L );
    if Characteristic( F ) <> 0 then
        Error( "the characteristic of the ground field must be zero.");
    fi;

    R:= RootSystem( L );
    B:= ChevalleyBasis( L );
    n:= Length(PositiveRoots(R));
    roots:= ShallowCopy( NegativeRoots( R ) );
    Append( roots, PositiveRoots( R ) );
    Rvecs:= ShallowCopy( B[2] );
    Append( Rvecs, B[1] );

    fam:= NewFamily( "UEALatticeEltFam", IsUEALatticeElement );
    fam!.packedUEALatticeElementDefaultType:=
                            NewType( fam, IsPackedElementDefaultRep );
    fam!.roots:= roots;
    fam!.rootVecs:= Rvecs;


    # We calculate a matrix `m' such that `m[i][j]' is the coefficient
    # `a' in the expression `y_{\alpha_i}*y_{\alpha_j} =
    # a*y_{\alpha_i+\alpha_j}'.

    m:= NullMat( 2*n, 2*n );
    for i in [1..2*n] do
        for j in [i+1..2*n] do
            k:= Position( roots, roots[i]+roots[j] );
            if k <> fail then
                m[i][j]:= Coefficients( Basis( VectorSpace( F, [ Rvecs[k] ]),
                                      [ Rvecs[k] ] ), Rvecs[i]*Rvecs[j])[1];
                m[j][i]:= -m[i][j];
            fi;
        od;
    od;
    fam!.rootTable:= m;

    fam!.noPosRoots:= n;
    fam!.lieAlgebra:= L;

    # We construct a linear map from H into a polynomial ring such that
    # every canonical Cartan element is mapped onto a variable.

    H:= VectorSpace( LeftActingDomain(L), B[3], "basis" );

    fam!.basH:= Basis( H, B[3] );
    P:= PolynomialRing( LeftActingDomain(L), Dimension( H ));
    vars:= IndeterminatesOfPolynomialRing( P );
    fam!.cartMap:= LeftModuleHomomorphismByImages( H, P,
                           BasisVectors(fam!.basH), vars );
    fam!.cartVars:= vars;

    bL:= ShallowCopy( Rvecs ); Append( bL, CanonicalGenerators(R)[3] );
    fam!.canBasL:= Basis( VectorSpace( LeftActingDomain(L), bL ), bL );

    # Finally construct the generators.

    gens:= [ ];
    for i in [1..n] do
        gens[i]:= ObjByExtRep( fam, [ [ i, 1 ], 1 ] );
        gens[i+n]:= ObjByExtRep( fam, [ [ i+n, 1 ], 1 ] );
    od;
    for i in [1..Length( CartanMatrix(R) )] do
        Add( gens,  ObjByExtRep( fam, [ [ 2*n+i, 1 ], 1 ] ) );
    od;
    return gens;

end );

#############################################################################
##
#M  LeadingUEALatticeMonomial( <novar>, <f> )
##
##
InstallMethod( LeadingUEALatticeMonomial,
        "for an integer and a UEALattice element",
        true, [ IsInt, IsUEALatticeElement ], 0,

        function ( novar, p )

    local e,max,cf,m,n,j,k,o,pos,deg,ind, degn;

    # Degree lexicographical ordering...

    e:= p![1];
    max:= e[1];
    ind:= 1;
    cf:= e[2];
    m:= ListWithIdenticalEntries( novar, 0 );
    for k in [1,3..Length(max)-1] do
        m[max[k]]:= max[k+1];
    od;
    deg:= Sum(m);
    for k in [3,5..Length(e)-1] do

        degn:= Sum( List( [ 2, 4 .. Length(e[k]) ], jj -> e[k][jj] ) );
        if degn >= deg then
            n:= ListWithIdenticalEntries( novar, 0 );
            for j in [1,3..Length(e[k])-1] do
                n[e[k][j]]:= e[k][j+1];
            od;
            if degn > deg then
                max:= e[k]; cf:= e[k+1]; deg:= degn;
                ind := k;
                m:= n;
            else
                o:= n-m;
                pos:= PositionProperty( o, x -> x <> 0 );
                if o[pos] < 0 then
                    max:= e[k];
                    ind := k;
                    cf:= e[k+1];
                    deg:= degn; m:= n;
                fi;
            fi;
        fi;

    od;

    return [max, m, cf, ind];
end );

#############################################################################
##
#F  LeftReduceUEALatticeElement( <novar>, <G>, <lms>, <lmtab>, <p> )
##
##  Here `G' is a list of UEALatticeElements, `lms' is a list of
##  indices where the leading monomials of elements of `G' can be found
##  (in their extrep), `lmtab' is a search table for `G', `p' is the
##  elements to be reduced modulo `G'.
##
##
InstallGlobalFunction( LeftReduceUEALatticeElement,
        function( novar, G, lms, lmtab, p )

    local   fam,  reduced,  rem,  res,  m1,  k,  g,  diff,  cme,  mon,
            cflmg,  j,  fac,  fac1,  cf,  lm;

    # We left-reduce the UEALattice element `p' modulo the elements in `G'.
    # Here `lms' is a list of leading monomial-indices; if the index `k'
    # occurs somewhere in `lms', then g![1][k] is the leading monomial
    # of `g', where `g' is the corresponding element of `G'. `novar'
    # is the number of variables.

    fam:= FamilyObj( p );
    reduced:= false;
    rem:= p;
    res:= 0*p;

    while rem <> 0*rem do

        m1:= LeadingUEALatticeMonomial( novar, rem );
        k:= 1;
        reduced:= false;

        k:= Search( lmtab, m1[2] );
        if k <> fail then

            g:= G[k];
            diff:= ShallowCopy( m1[2] );
            cme:= g![1];
            mon:= cme[ lms[k] ];
            cflmg:= cme[ lms[k]+1 ];
            for j in [1,3..Length(mon)-1] do
                diff[mon[j]]:= diff[mon[j]] - mon[j+1];
            od;

            fac:= [ ];
            for j in [1..novar] do
                if diff[j] <> 0 then
                    Add( fac, j ); Add( fac, diff[j] );
                fi;
            od;
            fac1:= ObjByExtRep( fam, [ fac, 1 ] )*g;
            cf:= LeadingUEALatticeMonomial( novar, fac1 )[3];
            rem:= rem - (m1[3]/cf)*fac1;
            reduced:= true;


        else
            lm:= ObjByExtRep( fam, [ m1[1], m1[3] ] );
            res:= res + lm;
            rem:= rem-lm;
        fi;


    od;

    return res;

end );


############################################################################
##
#M  ObjByExtRep( <fam>, <list> ) . . . . . . for a WeightRepFamily and a list
#M  ExtRepOfObj( <wte> ) . . . . . . . . . . for a weight rep element
##
InstallMethod( ObjByExtRep,
        "for a family of weight rep elements and a list",
        true, [ IsWeightRepElementFamily, IsList] , 0,
        function( fam, list )

    return Objectify( fam!.weightRepElementDefaultType,
                   [ Immutable( list ) ] );
end );

InstallMethod( ExtRepOfObj,
        "for weight rep element",
        true,
        [ IsWeightRepElement and IsPackedElementDefaultRep ], 0,
        function( v )
    return v![1];

end );


#############################################################################
##
#M   PrintObj( <v> ) . . . . . . . . . . . . .  for a weight rep element
##
InstallMethod( PrintObj,
        "for weight rep element",
        true,
        [ IsWeightRepElement and IsPackedElementDefaultRep ], 0,
        function( v )

    local e,k;

    e:= v![1];
    if e = [] then
        Print( "0*v0" );
    else
        for k in [1,3..Length(e)-1] do
            if e[k+1]>0 and k>1 then
                Print("+" );
            fi;
            Print( e[k+1]*e[k][2], "*v0" );
        od;
    fi;

end );


#############################################################################
##
#M  \+( <u>, <v> ) . . . . . . . . . . . . . . for two weight rep elements
#M  AdditiveInverseOp( <u> ) . . . . . . . . . . . .  . . . for a weight rep element
#M  \*( <scal>, <u> ) . . . . . . . . . . . .for a scalar and a weight rep elt
#M  \*( <u>, <scal> ) . . . . . . . . . . . .for a wewight rep elt and a scalar
#M  ZeroOp( <u> ) . . . . . . . . . . . . .  for a weight rep element
#M  \=( <u>, <v> ) . . . . . . . . . . . . . for two weight rep elements
#M  \<( <u>, <v> ) . . . . . . . . . . . . . for two weight rep elements
##
InstallMethod(\+,
        "for weight rep elements",
        IsIdenticalObj,
        [ IsWeightRepElement and IsPackedElementDefaultRep,
          IsWeightRepElement and IsPackedElementDefaultRep], 0,
        function( u, v )
    local lu,lv,k,p,cf, vecs, lu0;

    lu:= ShallowCopy( u![1] );
    vecs:= lu{ [ 1, 3 ..Length(lu)-1 ] };
    lv:= v![1];
    for k in [1,3..Length(lv)-1] do

        # See whether in `lu' there is a vector with the same number as
        # `lv[k]'. If not, then insert...

#        p := PositionSorted(vecs, [lv[k]]);
        p:= PositionSorted( vecs, lv[k], function( a, b ) return a[1] < b[1];
                                                                end );
        if p > Length( vecs ) or vecs[p][1] <> lv[k][1] then
            Add(vecs, lv[k],p);
            lu0:= lu{[1..2*p-2]};
            Add( lu0, lv[k] );
            Add( lu0, lv[k+1] );
            Append( lu0, lu{[2*p-1..Length(lu)]} );
            lu:= lu0;
        else
            cf:= lu[2*p]+lv[k+1];
            if cf = 0*cf then
                Remove( lu, 2*p-1 );
                Remove( lu, 2*p-1 );
                Remove( vecs, p );
            else
                lu[2*p]:= cf;
            fi;
        fi;
    od;

    return ObjByExtRep( FamilyObj( u ), lu );

end );

InstallMethod( AdditiveInverseOp,
        "for a weight rep element",
        true,
        [ IsWeightRepElement and IsPackedElementDefaultRep ], 0,
        function( u )

    local lu,k;

    lu:= ShallowCopy( u![1] );
    for k in [2,4..Length(lu)] do
        lu[k]:= -lu[k];
    od;
    return ObjByExtRep( FamilyObj( u ), lu );

end );


InstallMethod(\*,
        "for weight rep element and a scalar",
        true,
        [ IsWeightRepElement and IsPackedElementDefaultRep, IsRingElement ], 0,
        function( u, scal )
    local lu,k;

    if IsZero( scal ) then return ZeroOp( u ); fi;

    lu:= ShallowCopy( u![1] );
    for k in [2,4..Length(lu)] do
        lu[k]:= scal*lu[k];
    od;
    return ObjByExtRep( FamilyObj( u ), lu );

end );

InstallMethod(\*,
        "for weight rep element and a scalar",
        true,
        [ IsRingElement, IsWeightRepElement and IsPackedElementDefaultRep ], 0,
        function( scal, u  )
    local lu,k;

    if IsZero( scal ) then return ZeroOp( u ); fi;

    lu:= ShallowCopy( u![1] );
    for k in [2,4..Length(lu)] do
        lu[k]:= scal*lu[k];
    od;
    return ObjByExtRep( FamilyObj( u ), lu );

end );

InstallMethod(ZeroOp,
        "for weight rep element",
        true,
        [ IsWeightRepElement and IsPackedElementDefaultRep ], 0,
        function( u )

    return ObjByExtRep( FamilyObj( u ), [ ] );

end );

InstallMethod(\=,
        "for two weight rep elements",
        IsIdenticalObj,
        [ IsWeightRepElement and IsPackedElementDefaultRep,
          IsWeightRepElement and IsPackedElementDefaultRep], 0,
        function( u, v )

    local   lu,  lv,  le,  i;

    lu:= u![1];
    lv:= v![1];
    le:= Length( lu );
    if Length( lv ) <> le then return false; fi;
    for i in [1,3..le-1] do
        if lu[i][1] <> lv[i][1] then return false; fi;
        if lu[i+1] <> lv[i+1] then return false; fi;
    od;
    return true;

end );

InstallMethod(\<,
        "for two weight rep elements",
        IsIdenticalObj,
        [ IsWeightRepElement and IsPackedElementDefaultRep,
          IsWeightRepElement and IsPackedElementDefaultRep], 0,
        function( u, v ) return u![1] < v![1];
end );


#############################################################################
##
#M  \^( <x>, <u> ) . . . . . for a Lie algebra element and a weight rep elt.
##
InstallOtherMethod(\^,
        "for a Lie algebra element and a weight rep element",
        true,
        [ IsRingElement, IsWeightRepElement and IsPackedElementDefaultRep], 0,
        function( x, u )

    local   fam,  G,  L,  wvecs,  j,  hwv,  hw,  g,  elt,  lu,  m,  k,
            n,  em,  er,  i,  len,  cf,  mon,  pos,  f,  mons,  cfts,
            p,  im;

    fam:= FamilyObj( u );
    G:= fam!.grobnerBasis;
    L:= fam!.algebra;
    if not x in L then Error( "acting element must be in Lie algebra" ); fi;


    wvecs:= fam!.weightVectors;
    for j in [1..Length(wvecs)] do
        if wvecs[j]![1][1][1] = 1 then
            hwv:= wvecs[j];
            break;
        fi;
    od;
    hw:= hwv![1][1][3];

    g:= LatticeGeneratorsInUEA( L );

    # `elt' will be the acting element `x' written as UEALattice element.
    elt:= LinearCombination( g, Coefficients( FamilyObj(g[1])!.canBasL, x ) );

    # `m' will be the UEALattice element corresponding to `x^u'.
    lu:= u![1];
    m:= Zero( g[1] );

    for k in [1,3..Length(lu)-1] do
        m:= m + lu[k+1]*elt*lu[k][2];
    od;

    n:= Length( PositiveRoots( RootSystem( L ) ) );

    # Now `m' is a linear combination of monomials of the form
    # `yhx', where `x' is a product of positive root vectors,
    # `h' is a product of Cartan elements, and `y' is a product of negative
    # root vectors. We know that `x' maps the highest weight vector to
    # zero. So only those monomials will give a contribution that do not
    # contain the x-part. Furthermore, `h' acts on the highest weight
    # vector as multiplication by a scalar. For all monomials that do
    # not contain the x-part, we replace the h-part by the appropriate scalar,
    # and we left-reduce the rest modulo `G'.

    em:= m![1];
    er:= [ ];
    for i in [1,3..Length(em)-1] do
        len:= Length(em[i])-1;
        if em[i][len] > n then

            if em[i][len] > 2*n then

                # The monomial ends with the h-part. We calculate the scalar.
                j:= len;
                while j-2 >= 1 and em[i][j-2] > 2*n do j:= j-2; od;
                cf:= em[i+1];
                for k in [j,j+2..len] do
                    cf:= cf*Binomial( hw[ em[i][k]-2*n ], em[i][k+1] );
                od;
                if cf <> 0*cf then
                    mon:= em[i]{[1..j-1]};
                    pos:= Position( er, mon );
                    if pos = fail then
                        Add( er, mon ); Add( er, cf );
                    else
                        er[pos+1]:= er[pos+1]+cf;
                        if er[pos+1] = 0*er[pos+1] then
                            Remove( er, pos );
                            Remove( er, pos );
                        fi;
                    fi;
                fi;
            fi;

        else
            mon:= em[i]; cf:= em[i+1];
            pos:= Position( er, mon );
            if pos = fail then
                Add( er, mon ); Add( er, cf );
            else
                er[pos+1]:= er[pos+1]+cf;
                if er[pos+1] = 0*er[pos+1] then
                    Remove( er, pos );
                    Remove( er, pos );
                fi;
            fi;
        fi;

    od;
    f:= ObjByExtRep( FamilyObj( m ), er );
    m:= LeftReduceUEALatticeElement( n, G[1], G[2], G[3], f );

    # Write `m' as a weight rep element again...
    mons:= [ ];
    cfts:= [ ];
    em:= m![1];

    for k in [1,3..Length(em)-1] do
        p:= PositionProperty( wvecs, x -> x![1][1][2]![1][1] = em[k] );
        Add( mons, ShallowCopy( wvecs[p]![1][1] ) );
        Add( cfts, em[k+1] );
    od;

    SortParallel( mons, cfts, function( a, b ) return a[1] < b[1]; end );
    im:= [ ];
    for k in [1..Length(mons)] do
        Add( im, mons[k] );
        Add( im, cfts[k] );
    od;
    return ObjByExtRep( FamilyObj( hwv ), im );

end );


#############################################################################
##
#F  BasisOfWeightRepSpace( <V>, <vecs> )
##                           for space of weight rep elements
##                           and a list of elements thereof
##
BindGlobal( "BasisOfWeightRepSpace",
    function( V, vectors )
    local B;

    B:= Objectify( NewType( FamilyObj( V ),
                            IsFiniteBasisDefault and
                            IsBasisOfWeightRepElementSpace and
                            IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, vectors );

    return B;

end );

BindGlobal( "TriangulizeWeightRepElementList", function( ww )

    # Here `ww' is a list weight rep elements. We triangulize this list
    # of vectors. `basechange' with be a list describing the elements
    # of the new list `ww' in terms of the elements that were input to
    # the function. `heads' is a list of indices, describing where
    # the first non-zero weight vector in an element of `ww' occurs.

    local   basechange,  heads,  k,  head,  i,  cf,  b,  b1,  pos;

    ww:= Filtered( ww, x -> not IsZero(x) );
    basechange:= List( [1..Length(ww)], x -> [ [ x, 1 ] ] );
    SortParallel( ww, basechange,
            function( u, v ) return u![1][1][1] < v![1][1][1]; end );
    heads:= [ ];
    k:= 1;
    while k <= Length( ww ) do
        if IsZero( ww[k] ) then
            Remove( ww, k );
            Remove( basechange, k );
        else
            cf:= ww[k]![1][2];
            ww[k]:= ww[k]/cf;
            for i in [1..Length(basechange[k])] do
                basechange[k][i][2]:= basechange[k][i][2]/cf;
            od;

            head:= ww[k]![1][1][1];
            Add( heads, head );
            for i in [k+1..Length(ww)] do
                if ww[i]![1][1][1] = head then
                    cf:= ww[i]![1][2];
                    ww[i]:= ww[i] - cf*ww[k];
                    for b in basechange[k] do
                        b1:= [ b[1], -cf*b[2] ];
                        pos := PositionSorted( basechange[i], [b1[1]]);
                        if Length( basechange[i] ) < pos or
                           basechange[i][pos][1] <> b1[1] then
                            Add(basechange[i], b1, pos);
                        else
                            basechange[i][pos][2]:= basechange[i][pos][2]+
                                                              b1[2];
                        fi;
                    od;
                fi;
            od;
            k:= k+1;
        fi;
        # sort the lists again...
        # get rid of the zeros first (if any)...

        for i in [1..Length(ww)] do
            if IsZero( ww[i] ) then
                Unbind( ww[i] );
                Unbind( basechange[i] );
            fi;
        od;
        ww:= Compacted( ww );
        basechange:= Compacted( basechange );

        SortParallel( ww, basechange,
                function( u, v )
                        return u![1][1][1] < v![1][1][1]; end );

    od;
    return rec( echelonbas:= ww, heads:= heads, basechange:= basechange );
end );

##############################################################################
##
#M  Basis( <V>, <vecs> )
#M  BasisNC( <V>, <vecs> )
##
##  The basis of the space of weight rep elements <V> consisting of the
##  vectors in <vecs>.
##  In the NC version it is not checked whether the elements of <vecs> lie
##  in <V>.
##
##  In both cases the list of vectors <vecs> is triangulized, and the data
##  produced by this is stored in the basis.
InstallMethod( Basis,
    "for a space of weight rep elements and a list of weight rep elements",
    IsIdenticalObj,
    [ IsFreeLeftModule and IsWeightRepElementCollection,
      IsWeightRepElementCollection and IsList ], 0,
    function( V, vectors )

      local B, info;

      if not ForAll( vectors, x -> x in V ) then return fail; fi;

      info:= TriangulizeWeightRepElementList( ShallowCopy( vectors ) );
      if Length( info.echelonbas ) <> Length( vectors ) then return fail; fi;
      B:= BasisOfWeightRepSpace( V, vectors );
      B!.echelonBasis:= info.echelonbas;
      B!.heads:= info.heads;
      B!.baseChange:= info.basechange;
      return B;
end );

InstallMethod( BasisNC,
    "for a space of weight rep elements and a list of weight rep elements",
    IsIdenticalObj,
    [ IsFreeLeftModule and IsWeightRepElementCollection,
      IsWeightRepElementCollection and IsList ], 0,
    function( V, vectors )

      local B, info;

      info:= TriangulizeWeightRepElementList( ShallowCopy( vectors ) );
      if Length( info.echelonbas ) <> Length( vectors ) then return fail; fi;
      B:= BasisOfWeightRepSpace( V, vectors );
      B!.echelonBasis:= info.echelonbas;
      B!.heads:= info.heads;
      B!.baseChange:= info.basechange;
      return B;
end );

#############################################################################
##
#M  Basis( <V> )  . . . . . . . . . . . .  for a space of weight rep elements
##
InstallMethod( Basis,
    "for a space of weight rep elements",
    true, [ IsFreeLeftModule and IsWeightRepElementCollection ], 0,
    function( V )

    local B, info;

    info:= TriangulizeWeightRepElementList( ShallowCopy(
                                  GeneratorsOfLeftModule( V ) ) );
    B:= BasisOfWeightRepSpace( V, info.echelonbas );
    B!.echelonBasis:= info.echelonbas;
    B!.heads:= info.heads;
    B!.baseChange:= List( [1..Length(info.echelonbas)], x -> [[ x, 1 ]] );
    return B;

end );


##############################################################################
##
#M  Coefficients( <B>, <v> ). . . . . . for basis of a space of weight rep
##                                      elements and vector
##
InstallMethod( Coefficients,
    "for basis of weight rep elements, and algebra module element",
    true, [ IsBasisOfWeightRepElementSpace,
            IsWeightRepElement and IsPackedElementDefaultRep ], 0,
    function( B, v )

    local   w,  cf,  i,  b, c;

    # We use the echelon basis that comes with <B>. See the comments
    # in `lierep.gd'.

    w:= v;
    cf:= List( BasisVectors( B ), x -> FamilyObj(v)!.zeroCoeff );
    for i in [1..Length(B!.heads)] do
        if IsZero( w ) then return cf; fi;
        if w![1][1][1] < B!.heads[i] then
            return fail;
        elif w![1][1][1] = B!.heads[i] then
            c:= w![1][2];
            w:= w - c*B!.echelonBasis[i];
            for b in B!.baseChange[i] do
                cf[b[1]]:= cf[b[1]] + b[2]*c;
            od;
        fi;
    od;

    if not IsZero( w ) then return fail; fi;
    return cf;

end );




##############################################################################
##
#M  HighestWeightModule( <L>, <hw> ) for a Lie algebra and a dominant weight.
##
InstallMethod( HighestWeightModule,
        "for a Lie algebra and a list of non-negative integers",
        true, [ IsLieAlgebra, IsList ], 0,

  function( L, hw )

    local   NormalizedLeftReduction,  ggg,  famU,  R,  n,  posR,  V,
            lcombs,  fundB,  novar,  rank,  char,  orbs,  k,  it,
            orb,  www,  levels,  weights,  wd,  levwd,  i,  w,  j,
            w1,  lev,  lents,  maxlev,  cfs,  G,  Glms,  paths,  GB,
            lms,  lmtab,  curlev,  ccc,  mons,  pos,  m,  em,  z,
            pos1,  Glmsk,  Gk,  isdone,  mmm,  lm,  prelcm,  l,
            multiplicity,  sps,  sortmn,  we_had_enough,  le,  f,
            m1a,  g,  m2a,  lcm,  pp,  w2,  e1,  e2,  fac1,  fac2,
            comp,  vec,  ecomp,  vecs,  cfsc,  ec,  wvecs,  no,  fam,
            B,  delmod,  delB, lexord, longmon;


    lexord:= function( novar, m1, m2 )

        # m1, m2 are two monomials in extrep, deg lex order...

        local   d1,  d2,  n1,  k,  n2,  o,  pos;

        d1:= Sum(m1{[2,4..Length(m1)]});
        d2:= Sum(m2{[2,4..Length(m2)]});
        if d1<>d2 then
            return d1<d2;
        fi;

        n1:= ListWithIdenticalEntries( novar, 0 );
        for k in [1,3..Length(m1)-1] do
            n1[m1[k]]:= m1[k+1];
        od;
        n2:= ListWithIdenticalEntries( novar, 0 );
        for k in [1,3..Length(m2)-1] do
            n2[m2[k]]:= m2[k+1];
        od;

        o:= n2-n1;
        pos:= PositionProperty( o, x -> x <> 0 );
        if pos = fail then
            return false;
        fi;
        return o[pos] < 0;
    end;


    NormalizedLeftReduction:= function( novar, G, lms, lmtab, p )

        local   res,  cf;

        # We reduce `p' modulo `G' and make the coefficients integral, and
        # divide by their greatest common divisor.

        res:= LeftReduceUEALatticeElement( novar, G, lms, lmtab, p );
        if res <> 0*res then
            cf:= res![1]{[2,4..Length(res![1])]};
            res:= (Lcm(List(cf,DenominatorRat))/
                                 Gcd(List(cf,NumeratorRat)))*res;
        fi;
        return res;

    end;


    if PositionProperty( hw, x -> x<0 ) <> fail then
        Error( "the weight <hw> must be dominant" );
    fi;

    ggg:=  LatticeGeneratorsInUEA( L );
    famU:= FamilyObj( ggg[1] );

    R:= RootSystem( L );
    n:= Length(PositiveRoots( R ));
    posR:= PositiveRoots( R );
    V:= VectorSpace( Rationals, SimpleSystem( R ) );
    lcombs:= List( posR, r -> Coefficients( Basis( V, SimpleSystem(R)),r));
    posR:= List( lcombs, c -> LinearCombination( CartanMatrix(R), c ) );

    fundB:= Basis( VectorSpace( Rationals, CartanMatrix( R ) ),
                 CartanMatrix( R ) );

    novar:= n;
    rank:= Dimension(L) - 2*n;

    # `orbs' will be a list of lists of the form [ mult, wts ], where
    # `wts' is a list of weights, and `mult' is theit multiplicity.

    char:= DominantCharacter( L, hw );
    orbs:= [ ];

    for k in [1..Length( char[1] )] do
        it:= WeylOrbitIterator( WeylGroup( R ), char[1][k] );
        orb:= [ ];
        while not IsDoneIterator( it ) do
            Add( orb, NextIterator( it ) );
        od;
        Add( orbs, [ char[2][k], orb ] );
    od;


    # `levels' will be a list of lists, and `levels[k]' is the list of
    # weights of level `k-1'.
    # `weights' will be the list of all weights, sorted according to level.
    # `wd' will be the list of the weights of the extended weight diagram,
    # also sorted according to level.
    # `levwd' will be the list of the levels of the elements of `wd'.

    www:= [ ];
    for k in orbs do Append( www, k[2] ); od;
    levels:= [ [ hw ] ];
    weights:= [ ];
    k:=1;
    wd:= [ hw ];
    levwd:= [ 0 ];

    while k <= Length( levels ) do
        for i in [1..Length(levels[k])] do
            w:= levels[k][i];
            for j in [1..Length(posR)] do
                w1:= w - posR[j];
                lev:= k + Sum(lcombs[j]);
                if w1 in www then
                    if IsBound( levels[lev] ) then
                        if not w1 in levels[lev] then
                            Add( levels[lev], w1 );
                        fi;

                    else
                        levels[lev]:= [ w1 ];
                    fi;
                fi;
                if not w1 in wd then
                    Add( wd, w1 );
                    Add( levwd, lev );
                fi;

            od;
        od;
        k:= k+1;
    od;
    SortParallel( levwd, wd );
    for k in levels do
        Append( weights, k );
    od;

    # `lents' is a list of the lengths of the elements of `levels'; this is
    # used to calculate the position of an element of the list `weights'
    # efficiently.

    lents:= List(levels, Length );
    maxlev:= Length(levels);

    # `cfs' will be a list of coefficient-lists. The k-th element of `cfs'
    # are the coefficients $k_i$ in the expression `wd[k] = hw - \sum_i k_i
    # \alpha_i', where the \alpha_i are the fundamental roots.

    cfs:= List( wd, x -> Coefficients( fundB, hw - x ) );

    # `G' will be the Groebner basis, where the elements are grouped
    # in lists; for every weight of the extended diagram `wd' there is
    # a list. `Glms' is the list of leading monomials of the elements of `G'.
    # The leading monomials in this list are represented by indices j such that
    # f![1][j] is the leading monomial of f.
    # `paths' is the list of normal monomials of each weight in `weights'.
    # `GB' is the Groebner basis, now as a flat list, `lms' are the
    # corresponding leading monomials.
    # `lmtab' will be the search table of leading monomials of `G'.
    #

    G:= [ [ ] ];
    Glms:= [ [ ] ];

    paths:= [ [ ggg[1]^0 ] ];
    GB:= [ ];
    lms:= [ ];
    lmtab:= VectorSearchTable( );

    k:= 2;
    while k <= Length(wd) do

        # We take all weights of level equal to the level of `wd[k]'
        # together, and construct the corresponding parts of the Groebner
        # basis simultaneously.

        w:= [ ]; curlev:= levwd[k];
        ccc:= [ ];
        while k <= Length(wd) and levwd[k] = curlev do
            Add( w, wd[k] );
            Add( ccc, cfs[k] );
            k:= k+1;
        od;

        # `mons' will be a list of sets of monomials of the UAE.
        # They are candidates for the normal monomials of the weights in `w'.

        mons:= [ ];
        for j in [1..Length(w)] do
            mons[j]:= [ ];
            for i in [1..Length(posR)] do

                # We construct all weights of lower levels (that already have
                # been taken care of), connected to the weight `w'.

                w1:= w[j] + posR[i];
                lev:= curlev-Sum(lcombs[i]);

                if lev>0 and lev <= maxlev then
                    pos:= Position( levels[lev], w1 );
                else
                    pos:= fail;
                fi;

                if pos <> fail then # `w1' is a weight of the representation.

                    # `pos' will be the position of `w1' in the list `weights'.

                    pos:= pos + Sum( lents{[1..lev-1]} );
                    for m in paths[pos] do

                        # fit y_i in m (commutatively)
                        em:= ShallowCopy(m![1][1]);

                        z:= em{[1,3..Length(em)-1]};

                      # We search for the position in `z' where to insert y_i.

                        pos1:= PositionSorted( z, i );
                        if pos1 > Length( z ) or z[pos1] <> i then
                            # There is no y_i in `m', so insert it.
                            Add(em, i, 2*pos1-1);
                            Add(em, 1, 2*pos1);
                        else
                            # We increase the exponent of y_i by 1.
                            em[2*pos1]:= em[2*pos1]+1;
                        fi;

                        AddSet( mons[j], ObjByExtRep( famU, [ em, 1 ] ) );
                    od;
                fi;
            od;
        od;

        # `Gk' will contain the part of the Groebner basis corresponding
        # to the weights in `w'. `Glmsk' are the corresponding leading
        # monomials. The list `isdone' keeps track of the positions
        # with a complete part of the GB. `mmm' are the corresponding
        # normal monomials.

        Glmsk:= [ ];
        Gk:= [ ];
        isdone:= [ ];
        mmm:= [ ];

        for j in [1..Length(w)] do

            for i in [1..Length(mons[j])] do

                lm:= mons[j][i]![1][1];
                longmon:= ListWithIdenticalEntries( n, 0 );
                for l in [1,3..Length(lm)-1] do
                    longmon[lm[l]]:= lm[l+1];
                od;
                if Search( lmtab, longmon ) <> fail then

                    # This means that `longmon' reduces modulo `G',
                    # so we get rid of it.
                    Unbind( mons[j][i] );
                fi;
            od;
            mons[j]:= Compacted( mons[j] );

            Glmsk[j]:= [ ];
            Gk[ j ]:= [ ];
            if curlev > maxlev or not w[j] in levels[ curlev ] then

            # `w[j]' is not a weight of the representation; this means that
            # there are no normal monomials of weight `w[j]'. Hence we can
            # add all candidates in `mons' to the Groebner basis.


                Gk[j]:= mons[j];
                Glmsk[j]:= List( Gk[j], x -> 1 );

                # Normal monomials; empty in this case.
                mmm[j]:= [ ];
                isdone[j]:= true;
            fi;
        od;

        for j in [1..Length(w)] do
            if not IsBound( isdone[j] ) then isdone[j]:= false; fi;
        od;

        # For all remaining weights we know the dimension
        # of the corresponding weight space, and we calculate Groebner
        # basis elements of weight `w' until we can reduce all monomials
        # except a number equal to this dimension.
        # `mmm' will contain the lists of normal monomials, from which we
        # erase elements if they are reducible.

        pos:= List( w, ww -> PositionProperty( orbs, x -> ww in x[2] ) );
        multiplicity:= List( pos, function( j )
                                     if j <> fail then
                                         return orbs[j][1];
                                     fi;
                                     return 0;
                                 end );

        # Let `a', `b' be two monomials of the same weight; then `a' can only
        # be a factor of `b' if we have `a=b'. So reduction within a
        # weight component is the same as linear algebra. We use the
        # mutable bases in `sps' to perform the linear algebra.

        sps:= [ ];
        sortmn:= [ ];
        for j in [1..Length(w)] do
            if not isdone[j] then
                mmm[j]:= mons[j];
                if Length( mmm[j] ) = multiplicity[j] then
                    isdone[j]:= true;
                else

                    sps[j]:= MutableBasis( Rationals, [],
                                     [1..Length(mmm[j])]*0 );
                    sortmn[j]:= List( mmm[j], x -> ExtRepOfObj(x)[1] );
                    Sort( sortmn[j], function(x,y) return
                             lexord( novar, y, x ); end );

                fi;
            fi;
        od;


        we_had_enough:= ForAll( isdone, x -> x );
        le:= Length(GB);

        for i in [1..le] do
            if we_had_enough then break; fi;
            f:= GB[i];

            # `prelcm' will be the leading monomial of `f', represented as
            # a list of length `n', if prelcm[i] = k, then the leading
            # monomial contains a factor y_i^k.
            m1a:= f![1][lms[i]];
            prelcm:= ListWithIdenticalEntries( n, 0 );
            for l in [1,3..Length(m1a)-1] do
                prelcm[m1a[l]]:= m1a[l+1];
            od;

            for j in [le,le-1..i] do

                if we_had_enough then break; fi;
                g:= GB[j];
                # `lcm' will be the least common multiple of the LM of `f'
                # and the LM of `g', represented as a list of length n.
                m2a:= g![1][lms[j]];
                lcm:= ShallowCopy( prelcm );
                for l in [1,3..Length(m2a)-1] do
                    lcm[m2a[l]]:= Maximum(lcm[m2a[l]],m2a[l+1]);
                od;

                # We check whether `lcm' is of the correct
                # weight; only in that case we form the S-element.
                pp:= Position( ccc, LinearCombination( lcm, lcombs ) );

                if pp <> fail and not isdone[pp] then

                    # w1*f-w2*g will be the S-element of `f' and `g'.
                    w1:= lcm-prelcm;
                    w2:= lcm;
                    for l in [1,3..Length(m2a)-1] do
                        w2[m2a[l]]:= w2[m2a[l]]-m2a[l+1];
                    od;

                    # We make `w1' and `w2' into UEALattice elements,
                    # `fac1' and `fac2' respectively.
                    e1:= []; e2:= [];
                    for l in [1..n] do
                        if w1[l] <> 0 then
                            Add( e1, l ); Add( e1, w1[l] );
                        fi;
                        if w2[l] <> 0 then
                            Add( e2, l ); Add( e2, w2[l] );
                        fi;
                    od;
                    fac1:= ObjByExtRep( famU, [ e1, 1 ] )*f;
                    fac2:= ObjByExtRep( famU, [ e2, 1 ] )*g;

                    # `comp' will be the S-element of `f' and `g'.
                    # We reduce it modulo the elements we already have,
                    # and if it does not reduce to 0 we add it, and remove
                    # its leading monomial from the list of normal
                    # monomials.

                    comp:= LeadingUEALatticeMonomial(novar,fac2)[3]*fac1 -
                           LeadingUEALatticeMonomial(novar,fac1)[3]*fac2;
                    comp:= NormalizedLeftReduction( novar, GB, lms, lmtab,
                                   comp );
                    if comp <> 0*comp then

                        vec:= ListWithIdenticalEntries( Length( sortmn[pp] ),
                                      0 );
                        ecomp:= comp![1];
                        for l in [1,3..Length(ecomp)-1] do
                            vec[ Position( sortmn[pp], ecomp[l] )]:=
                              ecomp[l+1];
                        od;

                        CloseMutableBasis( sps[pp], vec );

                        isdone[pp]:=  multiplicity[pp] = Length( mmm[pp] )-
                                      Length( BasisVectors( sps[pp] ) );
                        if isdone[pp] then
                            we_had_enough:= ForAll( isdone, x -> x );
                        fi;
                    fi;
                fi;   # done processing this S-element.

            od;   # loop over j
        od;     # loop over i

        for j in [1..Length(w)] do

            if multiplicity[j] > 0 then

                # We add the elements that we get from the mutable bases to
                # the Groebner basis. We have to use the order of monomials
                # that is used by GAP to multiply, i.e., not the deglex order.
                # (Otherwise everything messes up.)

                if IsBound( sps[j] ) then

                    vecs:= BaseMat( BasisVectors( sps[j] ) );

                else
                    vecs:= [ ];
                fi;

                for l in [1..Length(vecs)] do
                    ecomp:= [ ];
                    cfsc:= [ ];
                    for i in [1..Length(vecs[l])] do
                        if vecs[l][i] <> 0*vecs[l][i] then

                            Add( ecomp, sortmn[j][i] );
                            Add( cfsc, vecs[l][i] );
                        fi;

                    od;
                    SortParallel( ecomp, cfsc );
                    ec:= [ ];
                    for i in [1..Length(ecomp)] do
                        Add( ec, ecomp[i] );
                        Add( ec, cfsc[i] );
                    od;

                    Add( Gk[j], ObjByExtRep( famU, ec ) );
                od;

                Glmsk[j]:= List( Gk[j], x -> LeadingUEALatticeMonomial(
                                  novar, x )[ 4 ] );

                le:= Length(GB);
                Append( GB, Gk[j] );
                Append( lms, Glmsk[j] );

                # Update the search table....

                for i in [1..Length(Gk[j])] do
                    lm:= Gk[j][i]![1][ Glmsk[j][i] ];
                    longmon:= ListWithIdenticalEntries( n, 0 );
                    for l in [1,3..Length(lm)-1] do
                        longmon[lm[l]]:= lm[l+1];
                    od;
                    Insert( lmtab, longmon, le+i );
                od;

                # Get rid of the monomials that reduce....

                for i in [1..Length(mmm[j])] do
                    lm:= mmm[j][i]![1][1];
                    longmon:= ListWithIdenticalEntries( n, 0 );
                    for l in [1,3..Length(lm)-1] do
                        longmon[lm[l]]:= lm[l+1];
                    od;
                    if Search( lmtab, longmon ) <> fail then
                        Unbind( mmm[j][i] );
                    fi;
                od;
                mmm[j]:= Compacted( mmm[j] );
                paths[Position(weights,w[j])]:= mmm[j];
            else

                # In this case the weight s not a weight of the representation;
                # we only update the Groebner basis, and the search table.

                le:= Length(GB);
                Append( GB, Gk[j] );
                Append( lms, Glmsk[j] );

                for i in [1..Length(Gk[j])] do
                    lm:= Gk[j][i]![1][ Glmsk[j][i] ];
                    longmon:= ListWithIdenticalEntries( n, 0 );
                    for l in [1,3..Length(lm)-1] do
                        longmon[lm[l]]:= lm[l+1];
                    od;
                    Insert( lmtab, longmon, le+i );
                od;
            fi;



        od;
        Append( G, Gk );

    od; #loop over k, we now looped through the entire extended weight diagram.


# We construct the module spanned by the normal monomials....

    wvecs:= [ ];
    no:= 0;
    fam:= NewFamily( "WeightRepElementsFamily", IsWeightRepElement );
    fam!.weightRepElementDefaultType:= NewType( fam,
                                               IsPackedElementDefaultRep );

    for k in [1..Length(weights)] do
        mmm:= paths[k];
        for m in mmm do
            no:= no+1;
            Add( wvecs, ObjByExtRep( fam , [ [ no, m, weights[k] ], 1 ] ) );
        od;
    od;

    fam!.grobnerBasis:= [ GB, lms, lmtab ];
    fam!.algebra:= L;
    fam!.hwModule:= V;
    fam!.weightVectors:= wvecs;
    fam!.dimension:= Length( wvecs );
    fam!.zeroCoeff:= Zero( LeftActingDomain( L ) );
    V:= LeftAlgebraModuleByGenerators( L, \^, wvecs );
    SetGeneratorsOfLeftModule( V, GeneratorsOfAlgebraModule( V ) );

    B:= Objectify( NewType( FamilyObj( V ),
                            IsFiniteBasisDefault and
                            IsBasisOfAlgebraModuleElementSpace and
                            IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, GeneratorsOfLeftModule( V ) );
    delmod:= VectorSpace( LeftActingDomain(V), wvecs);
    delB:= BasisOfWeightRepSpace( delmod, wvecs );
    delB!.echelonBasis:= wvecs;
    delB!.heads:= List( [1..Length(wvecs)], x -> x );
    delB!.baseChange:= List( [1..Length(wvecs)], x -> [[ x, 1 ]] );
    B!.delegateBasis:= delB;
    SetBasis( V, B );
    SetDimension( V, Length( wvecs ) );
    return V;

end );




InstallGlobalFunction( ExtendRepresentation,

        function( L, newelts, I, mats )

# This function extends the representation of the subalgebra 'I' of 'L'
# (given by 'mats') to the subalgebra generated by 'I' and 'newelts'.
# The representation space is a subspace of U(I)^*. The
# functions appearing in the process are represented in the way described
# in the comments to  'EvaluateFunction'.


    local   EvalMat,  HasZeroOrbit,  EvaluateFunction,
            IsLieAlgebraRepresentation,  TupToMon,  infostring,  F,
            e,  bb,  Alg,  T,  aa,  eqs,  rhs,  j,  k,  eqno,  i,
            cij,  pos,  sol,  exrep,  n,  Q,  U,  g,  newelts1,
            asbas,  sp,  wds,  deg,  ready,  le,  w,  m,  w1,  fcts,
            cc,  cf,  inds,  mons,  tup,  mons1,  ff,  vecs,  f,  vec,
            l,  ii,  finished,  Bsp,  bI,  M,  vv,  pd1,  newwds1,
            newwds;

    EvalMat:=function( p, mats )

    # Here 'p' is an element of the universal enveloping algebra of the Lie
    # algebra. So 'p' is a non-commutative polynomial in the basis elements.
    # This function substitutes the i-th element of the list of matrices
    # 'mats' for the i-th basis element of the Lie algebra. This means
    # that 'p' is evaluated on the matrices 'mats'.

        local M,i,r,ind,exp;

        M:= 0*mats[1];
        r:= ExtRepOfObj( p )[2];
        i:= 1;
        while i <= Length( r ) do
          ind:= r[i]{[0..Length(r[i])/2-1]*2+1};
          exp:= r[i]{[1..Length(r[i])/2]*2};
          M:=M + mats[1]^0*
           r[i+1]*Product( List( [1..Length(ind)], x -> mats[ind[x]]^exp[x] ) );
          i:= i+2;
        od;
        return M;
    end;

    HasZeroOrbit:=function(w,L,mats,elts)

    # Here 'w' is an element of the universal enveloping algebra of a subalgebra
    # of 'L'. The elements of 'elts' map this subalgebra into itself
    # (where the action is given by elts[i]\cdot x = elts[i]*x - x*elts[i],
    # where x is an element of the subalgebra). This function calculates
    # the orbit of 'w' under the action of the elements 'elts' and checks
    # whether \rho( orbit ) = 0 where \rho is the representation of the
    # subalgebra afforded by 'mats'. If this is the case then
    # the element 'w' need not be considered in the function 'ExtendRep'.
    # Here 'M' is a basis of the subspace of the universal enveloping algebra
    # consisting of all elements of degree <= Degree(w).

        local   F,  A,  mons,  orb,  vv,  V,  i,  orb1,  j,  c,  c1,  val,
                r,  mons1,  k,  pos,  bb;

       F:= LeftActingDomain( L );

       A:=EvalMat( w, mats );
       if A <> Zero(F)*A then return false; fi;

       mons:= [ ExtRepOfObj( w )[2][1] ];
       orb:=[ w ];

    # Every element is a vector in the space spanned by 'M'. So 'V' will be the
    # space of vectors.

       vv:= [ One( F ) ];
       V:= MutableBasis( F, [ vv ] );
       i:= 1;

       while i <= Length( elts ) do

    # We apply the element 'elts[i]' to all elements of 'orb' (the orbit
    # calculated so far).

         orb1:= [ ];
         j:= 1;
         c:= orb[j];

         while j <= Length( orb ) do

           c1:= elts[i]*c-c*elts[i];
           val:= EvalMat( c1, mats );

           if val <> Zero( F ) * val then return false; fi;
           vv:= ListWithIdenticalEntries( Length(mons), Zero( F ) );
           r:= ExtRepOfObj( c1 )[2];
           mons1:= [ ];
           for k in [1,3..Length(r)-1] do
               pos:= Position( mons, r[k] );
               if pos = fail then
                   Add( mons, r[k] );
                   Add( mons1, r[k] );
                   Add( vv, r[k+1] );
               else
                   vv[pos]:= r[k+1];
               fi;
           od;

           if mons1 <> [] then
               bb:= List( BasisVectors( V ), ShallowCopy );
               for k in bb do
                   Append( k, ListWithIdenticalEntries( Length(mons1), Zero(F) ) );
               od;
               V:= MutableBasis( F, bb );
           fi;

           if IsContainedInSpan( V, vv ) then

    # We take the next element of 'orb'.

             j:= j+1;
             if j <= Length( orb ) then c:= orb[j]; fi;

           else

    # We apply 'elt[i]' again.

             c:= c1;
             Add( orb1, c );
             CloseMutableBasis( V, vv );

           fi;

         od;
         Append( orb, orb1 );
         i:= i+1;

       od;

    # We calculated the whole orbit and all elements were represented as 0.

       return true;

    end;

    EvaluateFunction:=function(L,a,f,elts,mats)

    # 'f' is a functional on the universal enveloping algebra. This function
    # evaluates 'f' on the element 'a'. 'elts' is
    # a list of elements for which the representation is extended. The
    # function 'f' is "made" from an elementary function \theta(v_i,v_j^*)
    # by successive application of elements from 'elts'. 'f' has the
    # following representation: 'f= [ [i,j], [k_1,k_2,...,k_m] ]' which
    # means that
    #
    #    f=elts[m]^{k_m}*...*elts[1]^{k_1}*\theta(v_i,v_j^*).
    #
    # This implies that
    #
    #    f(a)=v_j^*(\rho( elts[1]^{k_1}*...*elts[m]^{k_m}*a )*v_i),
    #
    # where the representation \rho is given by the matrices 'mats'.

        local m,p,i,j,k,s,t;

        m:= Length( elts );
        p:= a;

        for i in [1..m] do
          k:= m-i+1;
          for j in [1..f[2][k]] do
            p:= elts[k]*p-p*elts[k];
          od;
        od;

        s:= EvalMat( p, mats )[f[1][2]][f[1][1]];
        return s * ( (-1)^ Sum(f[2]) );
    end;

    IsLieAlgebraRepresentation:= function( L, mm )

    # Check whether the representation afforded by 'mm' is a Lie algebra
    # representation.

       local T,i,j,s,cij,M;

       T:= StructureConstantsTable( Basis( L ) );
       for i in [1..Dimension(L)] do
         for j in [i+1..Dimension(L)] do
           cij:= T[i][j];
           M:= mm[i]*mm[j]-mm[j]*mm[i];
           for s in [1..Length(cij[1])] do
             M:= M - cij[2][s]*mm[cij[1][s]];
           od;
           if M <> 0*M then return false; fi;
         od;
       od;
       return true;
    end;

    TupToMon:= function( t )

        local   ind,  mon,  len,  i;

        ind:= 0;
        mon:= [ ];
        len:=0;
        for i in [1..Length(t)] do
            if t[i] = ind then
                mon[len]:= mon[len]+1;
            else
                ind:= t[i];
                Add( mon, ind );
                Add( mon, 1 );
                len:= len+2;
            fi;
        od;
        return mon;
    end;



    infostring:= "Entering the extension function; a representation of a ";
    Append( infostring, String( Dimension( I ) ) );
    Append( infostring, "-dimensional ideal is extended to a " );
    Append( infostring, String( Length(newelts)+Dimension(I) ) );
    Append( infostring, "-dimensional Lie algebra." );
    Info( InfoAlgebra, 1, infostring );

    F:= LeftActingDomain( L );
    e:= One( F );
    bb:= ShallowCopy( BasisVectors( Basis( I ) ) );
    Append( bb, newelts );
    Alg:= Subalgebra( L, bb, "basis" );

    if Length( newelts ) = 1 then

# We check whether there is an element 'y' in 'I' such that
# 'newelts[1]-y' commutes with all elements of 'I'. In that case we
# can easily extend the representation.

      T:= StructureConstantsTable( Basis( I ) );
      aa:= List( [1..Dimension(I)], i ->
                Coefficients(Basis(I),newelts[1]*BasisVectors(Basis(I))[i])
              );
      eqs:= NullMat(Dimension(I)^2+Dimension(I),Dimension(I),F);
      rhs:= List([1..Dimension(I)^2+Dimension(I)],i->Zero(F));

      for j in [1..Dimension(I)] do

        for k in [1..Dimension(I)] do

          eqno:= k + (j-1)*Dimension( I );
          for i in [1..Dimension(I)] do
            cij:= T[i][j];
            pos:= Position( cij[1], k );
            if pos <> fail then
              eqs[eqno][i]:= cij[2][pos];
            fi;
            rhs[eqno]:= aa[j][k];
          od;

        od;

      od;

      for k in [1..Dimension(I)] do
        for i in [1..Dimension(I)] do
          eqs[Dimension(I)^2+k][i]:= aa[i][k];
        od;
      od;

      sol:= SolutionMat( TransposedMat( eqs ), rhs );

      if sol <> fail then
        exrep:= [ ];
        n:= Length( mats[1] );

        for i in [1..Length(mats)] do
          Q:= List( mats[i], ShallowCopy );
          for j in [1..n] do
            Add( Q[j], Zero( F ) );
          od;
          Add(Q, List( [1..n+1], x -> Zero( F ) ) );
          Add(exrep,Q);
        od;

        Q:=LinearCombination( mats, sol );
        Q:=List( Q, x -> ShallowCopy( x ) );
        for j in [1..n] do
          Add( Q[j], Zero(F) );
        od;
        Add( Q, List( [1..n+1], x -> Zero( F ) ) );
        Q[1][n+1]:= e;
        Add( exrep, Q );
        return exrep;
      fi;

    fi;

# In the other case we compute the space spanned by C_{\rho}. We also
# determine an initial set of monomials relative to which we describe the
# functions.

    U:= UniversalEnvelopingAlgebra( L );
    g:= GeneratorsOfAlgebraWithOne( U );
    newelts1:= List( newelts, x -> g[Position(BasisVectors(Basis(L)),x)] );

    asbas:=[ IdentityMat( Length( mats[1] ), F ) ];
    Append( asbas, mats );
    sp:= MutableBasis( F, asbas );
    wds:= [ [] ];
    for i in [1..Length(mats)] do
      Add( wds, [i] );
    od;
    deg:=0;
    ready:=false;
    while not ready do
      deg:=deg+1;
      i:=1;
      while Length( wds[i] ) < deg do
        i:=i+1;
      od;
      le:= Length( wds );
      ready:= true;
      while i<= le do
        w:= ShallowCopy( wds[i] );

        for j in [ w[ Length(w) ]..Length( mats )] do
            m:= asbas[i]*mats[j];
            if not IsContainedInSpan( sp, m ) then
                ready:= false;
                Add( asbas, m );
                w1:= ShallowCopy(w);
                Add( w1, j );
                Add( wds, w1 );
                CloseMutableBasis( sp, m );
            fi;
        od;

        i:= i+1;
      od;
    od;

    fcts:= [ ]; cc:=[ ];
    sp:= MutableBasis( F, [ List(asbas,m->Zero( F )) ] );

    for i in [1..Length(mats[1])] do
      for j in [1..Length(mats[1])] do

          cf:= List( asbas, m -> m[j][i] );

        if not IsContainedInSpan( sp, cf ) then
          Add( fcts, cf );
          Add( cc, [i,j] );
          CloseMutableBasis( sp, cf );
        fi;
      od;
    od;

# 'mons' will be a list of all monomials in 'U' up to degree 'deg'
# 'mons1' will be the subset of 'mons' consisting of all monomials
# that have a nonzero orbit.

    inds:=[ 1.. Dimension( I ) ];
    mons:=[ One( U ) ];
    for i in [1..deg] do
      tup:= UnorderedTuples( inds, i );
      Append( mons, List( tup, t -> ObjByExtRep(
                                   ElementsFamily( FamilyObj(U) ),
                         [ Zero(F), [ TupToMon(t), One(F) ] ] ) ) );
    od;

    mons1:= Filtered( mons, m ->
               not HasZeroOrbit(m,L,mats,newelts1 ) );


# 'ff' will be a basis of the subspace of U(I)^* and 'vecs' will contain
# the vectorial representation of the elements of 'ff' relative to the
# monomials in 'mons1'.

    ff:=[]; vecs:=[];
    for i in [1..Length(cc)] do
      f:= [ cc[i], List( newelts, x -> Zero( F ) ) ];
      vec:= List( mons1, a -> EvaluateFunction(L,a,f,newelts1,mats) );
      Add( ff, f ); Add( vecs, ShallowCopy( vec ) );
    od;

    while true do

      # We determine the space generated by C_{\rho} (under the action of the
      # elements from 'newelts').

      k:= 1;
      m:= Length( newelts );
      sp:= VectorSpace( F, vecs );
      while k <= Length(ff) do
        for l in [1..m] do
          ii:= m-l+1;
          f:=[ ShallowCopy( ff[k][1] ), ShallowCopy( ff[k][2] ) ];
          finished:= false;
          while not finished do
            f[2][ii]:= f[2][ii]+1;

            vec:= List( mons1, a -> EvaluateFunction(L,a,f,newelts1,mats) );
            if vec in sp then
              finished:= true;
            else
              Add( ff, [ ShallowCopy(f[1]), ShallowCopy(f[2]) ] );
              Add( vecs, ShallowCopy( vec ) );
              sp:= VectorSpace( F, vecs );
            fi;
          od;
        od;
        k:= k+1;
      od;

      TriangulizeMat( vecs );
      mons1:= mons1{ List( vecs, x -> PositionProperty( x, y -> y <> 0 ) ) };
      vecs:= [ ];
      for f in ff do
          vec:= List( mons1, a -> EvaluateFunction(L,a,f,newelts1,mats) );
          Add( vecs, vec );
      od;
      sp:= VectorSpace( F, vecs );
      Bsp:= Basis( sp, vecs );

      infostring:= "The dimension of the representation space is ";
      Append( infostring, String( Length(ff) ) );
      Info( InfoAlgebra, 1, infostring );

      # We calculate the action of 'I' on the new space.

      bI:= BasisVectors( Basis( I ) );
      exrep:= [ ];

      for i in [1..Length( bI )] do
        ii:= Position( BasisVectors( Basis( L ) ) , bI[i] );
        M:= [ ];
        for j in [1..Length(ff)] do
          vv:= [ ];
          for m in mons1 do
            pd1:= m*g[ii];
            Add( vv, EvaluateFunction(L,pd1,ff[j],newelts1,mats) );
          od;

          Add( M, Coefficients( Bsp, vv ) );
        od;

        Add( exrep, TransposedMat( M ) );

      od;

      # We calculate the action of the new elements...

      for i in [1..Length(newelts ) ] do
        M:= [ ];
        ii:= Position( BasisVectors( Basis( L ) ), newelts[ i ] );
        for j in [1..Length(ff)] do
          vv:= [ ];
          for m in mons1 do
            pd1:= m*g[ii]-g[ii]*m;
            Add( vv, EvaluateFunction(L,pd1,ff[j],newelts1,mats) );
          od;

          Add( M, Coefficients( Bsp, vv ) );
        od;

        Add( exrep, TransposedMat( M ) );
      od;

      # If the representation we get is a Lie algebra representation, then we are
      # happy, if not then we increase the degree.

      if not IsLieAlgebraRepresentation( Alg, exrep ) then
        newwds1:= [ ];
        while Length( newwds1 ) = 0 do
          deg:= deg+1;
          tup:= UnorderedTuples( inds, deg );

          newwds:= List( tup, t -> ObjByExtRep( ElementsFamily( FamilyObj(U) ),
                           [ Zero(F), [ TupToMon(t), One(F) ] ] ) );
          Append( mons, newwds );

          newwds1:= Filtered( newwds, w ->
                        not HasZeroOrbit(w,L,mats,newelts1));
        od;

        for i in [1..Length(vecs)] do
          Append( vecs[i], List( newwds1, w
                         -> EvaluateFunction(L,w,ff[i],newelts1,mats) ) );
        od;

        Append( mons1, newwds1 );

      else
        return exrep;
      fi;

    od;

end );

InstallMethod( FaithfulModule,
        "for a Lie algebra",
        true, [ IsLieAlgebra ], 0,

       function(L)

# In this function we construct a tower of subalgebras with good properties
# and then a representation of the first element is successively extended
# to the whole of 'L'.

    local   ZL,  F,  N,  R,  lowser,  bb,  vv,  bas,  sp,  i,  d,  b,
            j,  ll,  ww,  mats,  S,  L1,  basK,  K,  x,  adm,  dirsm,
            Q,  k,  l,  mats1,  cf,  m,  f;

# If the centre of 'L' is 0, then the adjoint representation is faithful.

    ZL:= LieCentre( L );
    if Dimension( ZL ) = 0 then
      return AdjointModule( L );
    fi;

    F:= LeftActingDomain( L );
    N:= LieNilRadical( L );
    R:= LieSolvableRadical( L );
    lowser:= LieLowerCentralSeries( N );
    bb:= ShallowCopy(BasisVectors(Basis(lowser[Length(lowser)-1])));
    vv:= [ ];
    bas:= ShallowCopy( bb );
    sp:= VectorSpace( F, bb );
    for i in [1..Length(lowser)-1] do
      d:= Length( lowser ) - i;
      b:= BasisVectors( Basis( lowser[d] ) );
      for j in [1..Length(b)] do
        if not b[j] in sp then
          Add( bas, b[j] );
          Add( vv, b[j] );
          sp:= VectorSpace( F, bas );
        fi;
      od;
    od;

    b:= BasisVectors( Basis( R ) );
    for j in [1..Length(b)] do
      if not b[j] in sp then
        Add( bas, b[j] );
        Add( vv, b[j] );
        sp:= VectorSpace( F, bas );
      fi;
    od;

    ll:= LeviMalcevDecomposition( L );
    ww:= BasisVectors( Basis( ll[1] ) );

    mats:=List( [1..Length(bb)], x ->
                NullMat(Length(bb)+1,Length(bb)+1,F));
    for i in [1..Length(mats)] do
      mats[i][1][i+1]:= One( F );
    od;

    bas:= ShallowCopy( bb );
    Append( bas, vv );
    Append( bas, ww );

    S:= StructureConstantsTable( Basis( L, bas ) );
    L1:= LieAlgebraByStructureConstants( F, S );
    basK:= List( [1..Length(bb)], x -> BasisVectors( Basis( L1 ) )[x] );
    K:= Subalgebra( L1, basK, "basis" );

    for i in [1..Length(vv)] do
      x:= BasisVectors( Basis( L1 ) )[ Length(bb)+i ];
      mats:= ExtendRepresentation( L1, [x], K, mats );
      Add( basK, x );
      K:= Subalgebra( L1, basK, "basis" );
    od;

    if ww<>[] then

# We extend once more and if the resulting representation is not
# faithful, then we take the direct sum with the adjoint representation.

      mats:=ExtendRepresentation(L1,List([1..Length(ww)],i->
                   BasisVectors(Basis(L1))[Length(bas)-Length(ww)+i]),K,mats);

      if not Dimension(VectorSpace(F,mats))=Dimension(L) then

        adm:= List( BasisVectors( Basis( L1 ) ), x ->
                        AdjointMatrix( Basis( L1 ), x ) );
        d:= Length( mats[1] );
        dirsm:= [ ];
        for i in [1..Dimension(L1)] do
          Q:= NullMat( d+Dimension(L1), d+Dimension(L1), F );
          for k in [1..d] do
            for l in [1..d] do
              Q[k][l]:= mats[i][k][l];
            od;
          od;
          for k in [1..Dimension(L)] do
            for l in [1..Dimension(L)] do
              Q[d+k][d+l]:= adm[i][k][l];
            od;
          od;
          Add( dirsm, Q );
        od;
        mats:= dirsm;

      fi;

    fi;

    mats1:= [ ];
    for i in [1..Dimension(L)] do
      cf:= Coefficients( Basis( L, bas ), BasisVectors( Basis( L ) )[i] );
      m:= cf[1]*mats[1];
      for j in [2..Length(cf)] do
        m:= m + cf[j]*mats[j];
      od;
      Add( mats1, m );
    od;

    K:= LieAlgebra( F, mats1, "basis" );
    f:= AlgebraHomomorphismByImagesNC( L, K, BasisVectors( Basis( L ) ),
                List( mats1, LieObject ) );

    return LeftModuleByHomomorphismToMatAlg( L, f );

end );
