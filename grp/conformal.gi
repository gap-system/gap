
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
