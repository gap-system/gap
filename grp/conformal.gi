
# auxiliary function analogous to `DescribesInvariantBilinearForm`
BindGlobal( "DescribesInvariantBilinearFormUpToScalars",
    obj -> IsMatrixOrMatrixObj( obj ) or
           ( IsBoundGlobal( "IsBilinearForm" ) and
             ValueGlobal( "IsBilinearForm" )( obj ) ) or
           ( IsGroup( obj ) and HasInvariantBilinearForm( obj ) ) or
           ( IsGroup( obj ) and HasInvariantBilinearFormUpToScalars( obj ) ) );


#############################################################################
##
#F  ConformalSymplecticGroup( [<filt>, ]<d>, <q>[, <form>] ) conf. sympl. gp.
#F  ConformalSymplecticGroup( [<filt>, ]<d>, <R>[, <form>] ) conf. sympl. gp.
#F  ConformalSymplecticGroup( [<filt>, ]<form> )   conformal symplectic group
#F  CSp( [<filt>, ]<d>, <q>[, <form>] )            conformal symplectic group
#F  CSp( [<filt>, ]<d>, <R>[, <form>] )            conformal symplectic group
#F  CSp( [<filt>, ]<form> )                        conformal symplectic group
##
InstallGlobalFunction( ConformalSymplecticGroup, function ( arg )
  local filt, form;

  if IsFilter( First( arg ) ) then
    filt:= Remove( arg, 1 );
  else
    filt:= IsMatrixGroup;
  fi;
  if DescribesInvariantBilinearFormUpToScalars( Last( arg ) ) then
    # interpret this argument (matrix or form or group with stored form)
    # as "up to scalars"
    form:= Remove( arg );
    if Length( arg ) = 0 then
      # ( [<filt>, ]<form> )
      return ConformalSymplecticGroupCons( filt, form );
    elif Length( arg ) = 2 and IsPosInt( arg[1] )
                           and ( IsRing( arg[2] ) or IsPosInt( arg[2] ) ) then
      # ( [<filt>, ]<d>, <R>, <form> ) or ( [<filt>, ]<d>, <q>, <form> )
      return ConformalSymplecticGroupCons( filt, arg[1], arg[2], form );
    fi;
  elif Length( arg ) = 2 and IsPosInt( arg[1] )
                         and ( IsRing( arg[2] ) or IsPosInt( arg[2] ) ) then
    # ( [<filt>, ]<d>, <R> ) or ( [<filt>, ]<d>, <q> )
    return ConformalSymplecticGroupCons( filt, arg[1], arg[2] );
  fi;
  Error( "usage: ConformalSymplecticGroup( [<filt>, ]<d>, <R>[, <form>] )\n",
         "or ConformalSymplecticGroup( [<filt>, ]<d>, <q>[, <form>] )\n",
         "or ConformalSymplecticGroup( [<filt>, ]<form> )" );
end );


#############################################################################
##
#M  ConformalSymplecticGroupCons( <IsMatrixGroup>, <d>, <F> )
##
InstallMethod( ConformalSymplecticGroupCons,
  "matrix group for dimension and finite field",
  [ IsMatrixGroup and IsFinite,
    IsPosInt,
    IsField and IsFinite ],
  function( filter, d, F )
  local q, o, filt, g, c, data, mat1, mat2, mat3, z, i, size, qi;

  # the dimension must be even
  if d mod 2 = 1 then
    Error( "the dimension <d> must be even" );
  fi;
  q:= Size( F );
  o:= One( F );

  # Decide about the internal representation of group generators.
  filt:= ValueOption( "ConstructingFilter" );
  if filt = fail then
    filt:= IsPlistRep;
  fi;

  if d = 2 then
    # the group is a general linear group
    g:= GL( 2, F );

    c:= ZeroMatrix( filt, F, 2, 2 );
    c[1,2]:= o;
    c[2,1]:= -o;
  else
    data:= GeneratorsAndFormOfSymplecticGroupOverFiniteField( filt,
               F, d, q );
    c:= data[2];
    mat1:= data[1][1];
    mat2:= data[1][2];

    mat3:= IdentityMatrix( filt, F, d );
    z:= PrimitiveRoot( F );
    for i in [ 1 .. d/2 ] do
      mat3[i, i]:= z;
    od;
    mat3:= ImmutableMatrix( F, mat3, true );

    # avoid to call 'Group' because this would check invertibility ...
    g:= GroupWithGenerators( [ mat1, mat2, mat3 ] );
    SetName( g, Concatenation( "CSp(", String(d), ",", String(q), ")" ) );
    SetDimensionOfMatrixGroup( g, d );

    # 'mat1' contains a primitive root of 'F'.
    SetFieldOfMatrixGroup( g, F );

    # add the size
    size := 1;
    qi   := 1;
    for i in [ 1 .. d/2 ] do
      qi   := qi * q^2;
      size := size * (qi-1);
    od;
    SetSize( g, q^((d/2)^2) * size * (q-1) );
  fi;

  # set the form
  SetInvariantBilinearFormUpToScalars( g,
      rec( matrix:= ImmutableMatrix( F, c, true ), baseDomain:= F ) );
  SetIsFullSubgroupGLRespectingBilinearFormUpToScalars( g, true );

  # and return
  return g;
end );


#############################################################################
##
#M  ConformalSymplecticGroupCons( <IsMatrixGroup>, <d>, <q> )
##
InstallMethod( ConformalSymplecticGroupCons,
  "matrix group for dimension and finite field size",
  [ IsMatrixGroup and IsFinite,
    IsPosInt,
    IsPosInt ],
  { filt, n, q } -> ConformalSymplecticGroupCons( filt, n, GF(q) ) );


#############################################################################
##
##  Support `IsPermGroup` as first argument in `ConformalSymplecticGroup`.
##
PermConstructor( ConformalSymplecticGroupCons,
  [ IsPermGroup, IsInt, IsObject ],
  IsMatrixGroup and IsFinite );


#############################################################################
##
#F  ConformalOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q>[, <form>] )
#F  ConformalOrthogonalGroup( [<filt>, ]<form> )
##
BindGlobal( "DescribesInvariantQuadraticFormUpToScalars",
    obj -> IsMatrixOrMatrixObj( obj ) or
           ( IsBoundGlobal( "IsQuadraticForm" ) and
             ValueGlobal( "IsQuadraticForm" )( obj ) ) or
           ( IsGroup( obj ) and HasInvariantQuadraticForm( obj ) ) or
           ( IsGroup( obj ) and HasInvariantQuadraticFormUpToScalars( obj ) ) );

InstallGlobalFunction( ConformalOrthogonalGroup, function ( arg )
  local filt, form;

  if IsFilter( First( arg ) ) then
    filt:= Remove( arg, 1 );
  else
    filt:= IsMatrixGroup;
  fi;
  if DescribesInvariantQuadraticFormUpToScalars( Last( arg ) ) then
    form:= Remove( arg );
    if Length( arg ) = 0 then
      # ( [<filt>, ]<form> )
      return ConformalOrthogonalGroupCons( filt, form );
    elif Length( arg ) = 2 and IsPosInt( arg[1] )
                           and ( IsPosInt( arg[2] ) or IsRing( arg[2] ) ) then
      # ( [<filt>, ]<d>, <q>, <form> ) or ( [<filt>, ]<d>, <R>, <form> )
      return ConformalOrthogonalGroupCons( filt, 0, arg[1], arg[2], form );
    elif Length( arg ) = 3 and IsInt( arg[1] ) and IsPosInt( arg[2] )
                           and ( IsPosInt( arg[3] ) or IsRing( arg[3] ) ) then
      # ( [<filt>, ]<e>, <d>, <q>, <form> ) or ( [<filt>, ]<e>, <d>, <R>, <form> )
      return ConformalOrthogonalGroupCons( filt, arg[1], arg[2], arg[3], form );
    fi;
  elif Length( arg ) = 2 and IsPosInt( arg[1] )
                         and ( IsPosInt( arg[2] ) or IsRing( arg[2] ) ) then
    # ( [<filt>, ]<d>, <q> ) or ( [<filt>, ]<d>, <R> )
    return ConformalOrthogonalGroupCons( filt, 0, arg[1], arg[2] );
  elif Length( arg ) = 3 and IsInt( arg[1] ) and IsPosInt( arg[2] )
                         and ( IsPosInt( arg[3] ) or IsRing( arg[3] ) ) then
    # ( [<filt>, ]<e>, <d>, <q> ) or ( [<filt>, ]<e>, <d>, <R> )
    return ConformalOrthogonalGroupCons( filt, arg[1], arg[2], arg[3] );
  fi;
  Error( "usage: ConformalOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q>[, <form>] )\n",
         "or ConformalOrthogonalGroup( [<filt>, ]<form> )" );
end );


#############################################################################
##
#M  ConformalOrthogonalGroupCons( <IsMatrixGroup>, <e>, <d>, <q> )
##
##  CO is generated by GO and one similarity whose multiplier generates the
##  group of all multipliers, which consists of all nonzero field elements
##  for even <d> and of their squares for odd <d>.
##  A scalar matrix suffices unless <d> is even and <q> is odd.
##  In that case, the form of GO is an orthogonal sum of binary forms on
##  consecutive pairs of coordinates, and we combine similarities of these
##  binary forms with the same multiplier.
##
InstallMethod( ConformalOrthogonalGroupCons,
  "matrix group for <e>, dimension, and finite field size",
  [ IsMatrixGroup and IsFinite,
    IsInt,
    IsPosInt,
    IsPosInt ],
  function( filter, e, d, q )
  local G, F, o, z, Q, binary, delta, i, g, sign, form;

  G:= GeneralOrthogonalGroupCons( filter, e, d, q );
  F:= GF(q);
  o:= One( F );
  z:= PrimitiveRoot( F );
  Q:= InvariantQuadraticForm( G ).matrix;

  # Return a matrix M with f(v M) = z f(v) for the nonsingular binary
  # quadratic form f(x,y) = a x^2 + b x y + c y^2 over F, for odd q,
  # where a = c = 0 or a <> 0, as for the forms of GO.
  # If a <> 0 then f = a N for the norm form N(x,y) = x^2 + p x y + s y^2
  # of the algebra F[t]/(t^2 - p t + s), and M describes the
  # multiplication with an element c0 + e0 t of norm z.
  binary:= function( a, b, c )
    local p, s, e0, r, c0;

    if IsZero( a ) and IsZero( c ) then
      return [ [ z, 0*z ], [ 0*z, o ] ];
    fi;
    Assert( 1, not IsZero( a ) );

    # Since z is not a square, a solution has e0 <> 0.
    p:= b / a;
    s:= c / a;
    e0:= o;
    repeat
      r:= RootFFE( F, ( p^2 - 4*s ) * e0^2 + 4*z, 2 );
      if r = fail then
        e0:= e0 * z;
      fi;
    until r <> fail;
    c0:= ( r - p * e0 ) / ( 2*o );
    return [ [ c0, e0 ], [ -s * e0, c0 + p * e0 ] ];
  end;

  if IsOddInt( d ) then
    # multiplier z^2
    delta:= z * IdentityMat( d, F );
  elif IsEvenInt( q ) then
    # multiplier z
    delta:= z^(q/2) * IdentityMat( d, F );
  else
    delta:= NullMat( d, d, F );
    for i in [ 1, 3 .. d-1 ] do
      Assert( 1, ForAll( [ i+2 .. d ],
                         j -> IsZero( Q[i,j] ) and IsZero( Q[j,i] ) and
                              IsZero( Q[i+1,j] ) and IsZero( Q[j,i+1] ) ) );
      delta{ [ i, i+1 ] }{ [ i, i+1 ] }:=
          binary( Q[i,i], Q[i,i+1] + Q[i+1,i], Q[i+1,i+1] );
    od;
  fi;
  delta:= ImmutableMatrix( F, delta, true );

  # avoid to call 'Group' because this would check invertibility ...
  g:= GroupWithGenerators( Concatenation( GeneratorsOfGroup( G ),
                                          [ delta ] ) );
  if e = 1 then
    sign:= "+";
  else
    sign:= "";
  fi;
  SetName( g, Concatenation( "CO(", sign, String( e ), ",", String( d ), ",",
                             String( q ), ")" ) );
  SetDimensionOfMatrixGroup( g, d );

  # 'g' contains the scalar matrices.
  SetFieldOfMatrixGroup( g, F );

  if IsOddInt( d ) then
    SetSize( g, Size( G ) * ( q-1 ) / GcdInt( 2, q-1 ) );
  else
    SetSize( g, Size( G ) * ( q-1 ) );
  fi;

  # set the forms
  form:= InvariantQuadraticForm( G );
  SetInvariantQuadraticFormUpToScalars( g,
      rec( matrix:= form.matrix, baseDomain:= F ) );
  SetIsFullSubgroupGLRespectingQuadraticFormUpToScalars( g, true );
  form:= InvariantBilinearForm( G );
  SetInvariantBilinearFormUpToScalars( g,
      rec( matrix:= form.matrix, baseDomain:= F ) );
  if IsOddInt( q ) then
    SetIsFullSubgroupGLRespectingBilinearFormUpToScalars( g, true );
  fi;

  return g;
end );


#############################################################################
##
#M  ConformalOrthogonalGroupCons( <IsMatrixGroup>, <e>, <d>, <F> )
##
InstallMethod( ConformalOrthogonalGroupCons,
  "matrix group for <e>, dimension, and finite field",
  [ IsMatrixGroup and IsFinite,
    IsInt,
    IsPosInt,
    IsField and IsFinite ],
  { filt, e, d, F } -> ConformalOrthogonalGroupCons( filt, e, d, Size( F ) ) );


#############################################################################
##
#F  ConformalUnitaryGroup( [<filt>, ]<d>, <q>[, <form>] )
#F  ConformalUnitaryGroup( [<filt>, ]<form> )
##
BindGlobal( "DescribesInvariantHermitianFormUpToScalars",
    obj -> IsMatrixOrMatrixObj( obj ) or
           ( IsBoundGlobal( "IsHermitianForm" ) and
             ValueGlobal( "IsHermitianForm" )( obj ) ) or
           ( IsGroup( obj ) and HasInvariantSesquilinearForm( obj ) ) or
           ( IsGroup( obj ) and
             HasInvariantSesquilinearFormUpToScalars( obj ) ) );

InstallGlobalFunction( ConformalUnitaryGroup, function ( arg )
  local filt, form;

  if IsFilter( First( arg ) ) then
    filt:= Remove( arg, 1 );
  else
    filt:= IsMatrixGroup;
  fi;
  if DescribesInvariantHermitianFormUpToScalars( Last( arg ) ) then
    form:= Remove( arg );
    if Length( arg ) = 0 then
      # ( [<filt>, ]<form> )
      return ConformalUnitaryGroupCons( filt, form );
    elif Length( arg ) = 2 and IsPosInt( arg[1] ) and IsPosInt( arg[2] ) then
      # ( [<filt>, ]<d>, <q>, <form> )
      return ConformalUnitaryGroupCons( filt, arg[1], arg[2], form );
    fi;
  elif Length( arg ) = 2 and IsPosInt( arg[1] ) and IsPosInt( arg[2] ) then
    # ( [<filt>, ]<d>, <q> )
    return ConformalUnitaryGroupCons( filt, arg[1], arg[2] );
  fi;
  Error( "usage: ConformalUnitaryGroup( [<filt>, ]<d>, <q>[, <form>] )\n",
         "or ConformalUnitaryGroup( [<filt>, ]<form> )" );
end );


#############################################################################
##
#M  ConformalUnitaryGroupCons( <IsMatrixGroup>, <d>, <q> )
##
##  Each multiplier lies in GF(q) and is the norm of a scalar,
##  so CU is generated by GU and the scalar matrices.
##
InstallMethod( ConformalUnitaryGroupCons,
  "matrix group for dimension and finite field size",
  [ IsMatrixGroup and IsFinite,
    IsPosInt,
    IsPosInt ],
  function( filter, d, q )
  local G, F, z, g, form;

  G:= GeneralUnitaryGroupCons( filter, d, q );
  F:= GF( q^2 );
  z:= PrimitiveRoot( F );

  # avoid to call 'Group' because this would check invertibility ...
  g:= GroupWithGenerators( Concatenation( GeneratorsOfGroup( G ),
      [ ImmutableMatrix( F, z * IdentityMat( d, F ), true ) ] ) );
  SetName( g, Concatenation( "CU(", String( d ), ",", String( q ), ")" ) );
  SetDimensionOfMatrixGroup( g, d );

  # 'g' contains the scalar matrices.
  SetFieldOfMatrixGroup( g, F );

  SetSize( g, Size( G ) * ( q-1 ) );

  # set the form
  form:= InvariantSesquilinearForm( G );
  SetInvariantSesquilinearFormUpToScalars( g,
      rec( matrix:= form.matrix, baseDomain:= F ) );
  SetIsFullSubgroupGLRespectingSesquilinearFormUpToScalars( g, true );

  return g;
end );


#############################################################################
##
##  Support `IsPermGroup` as first argument in `ConformalOrthogonalGroup`
##  and `ConformalUnitaryGroup`.
##
PermConstructor( ConformalOrthogonalGroupCons,
  [ IsPermGroup, IsInt, IsInt, IsObject ],
  IsMatrixGroup and IsFinite );

PermConstructor( ConformalUnitaryGroupCons,
  [ IsPermGroup, IsInt, IsObject ],
  IsMatrixGroup and IsFinite );
