#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Heiko Theißen, Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#M  SymplecticGroupCons( <IsMatrixGroup>, <d>, <q> )
##
InstallMethod( SymplecticGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsPosInt,
      IsPosInt ],
    function( filter, d, q )
    local   g,  f,  z,  o,  mat1,  mat2,  i,  size,  qi,  c;

    # the dimension must be even
    if d mod 2 = 1  then
        Error( "the dimension <d> must be even" );
    fi;
    f := GF(q);
    z := PrimitiveRoot( f );
    o := One( f );

    # if the dimension is two it is a special linear group
    if d = 2 then
        g := SL( 2, q );

    else

        # Sp(4,2)
        if d = 4 and q = 2  then
            mat1 := [ [1,0,1,1], [1,0,0,1], [0,1,0,1], [1,1,1,1] ] * o;
            mat2 := [ [0,0,1,0], [1,0,0,0], [0,0,0,1], [0,1,0,0] ] * o;

        # Sp(d,q)
        else
            mat1 := IdentityMat( d, f );
            mat2 := NullMat( d, d, f );
            for i  in [ 2 .. d/2 ]      do mat2[i,i-1]:= o;  od;
            for i  in [ d/2+1 .. d-1 ]  do mat2[i,i+1]:= o;  od;

            if q mod 2 = 1  then
                mat1[  1,    1] := z;
                mat1[  d,    d] := z^-1;
                mat2[  1,    1] := o;
                mat2[  1,d/2+1] := o;
                mat2[d-1,  d/2] := o;
                mat2[  d,  d/2] := -o;

            elif q <> 2  then
                mat1[    1,    1] := z;
                mat1[  d/2,  d/2] := z;
                mat1[d/2+1,d/2+1] := z^-1;
                mat1[    d,    d] := z^-1;
                mat2[    1,d/2-1] := o;
                mat2[    1,  d/2] := o;
                mat2[    1,d/2+1] := o;
                mat2[d/2+1,  d/2] := o;
                mat2[    d,  d/2] := o;

            else
                mat1[    1,  d/2] := o;
                mat1[    1,    d] := o;
                mat1[d/2+1,    d] := o;
                mat2[    1,d/2+1] := o;
                mat2[    d,  d/2] := o;
            fi;
        fi;

        mat1:=ImmutableMatrix(f,mat1,true);
        mat2:=ImmutableMatrix(f,mat2,true);
        # avoid to call 'Group' because this would check invertibility ...
        g := GroupWithGenerators( [ mat1, mat2 ] );
        SetName( g, Concatenation("Sp(",String(d),",",String(q),")") );
        SetDimensionOfMatrixGroup( g, d );
        SetFieldOfMatrixGroup( g, f );

        # add the size
        size := 1;
        qi   := 1;
        for i in [ 1 .. d/2 ] do
            qi   := qi * q^2;
            size := size * (qi-1);
        od;
        SetSize( g, q^((d/2)^2) * size );
    fi;

    # construct the form
    c := NullMat( d, d, f );
    for i  in [ 1 .. d/2 ]  do
        c[i,d-i+1] := o;
        c[d/2+i,d/2-i+1] := -o;
    od;
    SetInvariantBilinearForm( g,
        rec( matrix:= ImmutableMatrix( f, c, true ) ) );
    SetIsFullSubgroupGLorSLRespectingBilinearForm(g,true);
    SetIsSubgroupSL(g,true);

    # and return
    return g;
    end );

InstallMethod( SymplecticGroupCons,
    "matrix group for dimension and finite field",
    [ IsMatrixGroup and IsFinite,
      IsPosInt,
      IsField and IsFinite ],
function(filt,n,f)
  return SymplecticGroupCons(filt,n,Size(f));
end);



#############################################################################
##
#M  GeneralUnitaryGroupCons( <IsMatrixGroup>, <n>, <q> )
##
InstallMethod( GeneralUnitaryGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsPosInt,
      IsPosInt ],
    function( filter, n, q )
     local g, i, e, f, z, o, mat1, mat2, gens, size, qi, eps, c;

     f:= GF( q^2 );
     z:= PrimitiveRoot( f );
     o:= One( f );

     # Construct the generators.

     if n > 1 then
       mat1:= IdentityMat( n, f );
       mat2:= NullMat( n, n, f );
     fi;

     if   n = 1 then
       mat1:= [ [ z ^ (q-1) ] ];

     elif n = 2 then

       # We use the isomorphism of 'SU(2,q)' and 'SL(2,q)':
       # 'e' is mapped to '-e' under the Frobenius mapping.
       e:= Z(q^2) - Z(q^2)^q;
       if q = 2 then
         mat1[1,1]:= z;
         mat1[2,2]:= z;
         mat1[1,2]:= z;
         mat2[1,2]:= o;
         mat2[2,1]:= o;
       else
         mat1[1,1]:= z;
         mat1[2,2]:= z^-q;
         mat2[1,1]:= -o;
         mat2[1,2]:= e;
         mat2[2,1]:= -e^-1;
       fi;

     elif n mod 2 = 0 then
       if q mod 2 = 1 then e:= z^( (q+1)/2 ); else e:= o; fi;
       mat1[1,1]:= z;
       mat1[n,n]:= z^-q;
       for i in [ 2 .. n/2 ]     do mat2[ i, i-1 ]:= o; od;
       for i in [ n/2+1 .. n-1 ] do mat2[ i, i+1 ]:= o; od;
       mat2[ 1, 1 ]:= o;
       mat2[1,n/2+1]:= e;
       mat2[n-1,n/2]:= e^-1;
       mat2[n, n/2 ]:= -e^-1;
     else
       mat1[(n-1)/2,(n-1)/2]:= z;
       mat1[(n-1)/2+2,(n-1)/2+2]:= z^-q;
       for i in [ 1 .. (n-1)/2-1 ] do mat2[ i, i+1 ]:= o; od;
       for i in [ (n-1)/2+3 .. n ] do mat2[ i, i-1 ]:= o; od;
       mat2[(n-1)/2,  1  ]:=  -(1+z^q/z)^-1;
       mat2[(n-1)/2,(n-1)/2+1]:= -o;
       mat2[(n-1)/2,  n  ]:=  o;
       mat2[(n-1)/2+1,  1  ]:= -o;
       mat2[(n-1)/2+1,(n-1)/2+1]:= -o;
       mat2[(n-1)/2+2,  1  ]:=  o;
     fi;

     mat1:=ImmutableMatrix(f,mat1,true);
     if n = 1 then
       gens := [ mat1 ];
     else
       mat2:=ImmutableMatrix(f,mat2,true);
       gens := [ mat1, mat2 ];
     fi;

     # Avoid to call 'Group' because this would check invertibility ...
     g:= GroupWithGenerators( gens );
     SetName( g, Concatenation("GU(",String(n),",",String(q),")") );
     SetDimensionOfMatrixGroup( g, n );
     SetFieldOfMatrixGroup( g, f );

     # Add the size.
     size := q+1;
     qi   := q;
     eps  := 1;
     for i in [ 2 .. n ] do
       qi   := qi * q;
       eps  := -eps;
       size := size * (qi+eps);
     od;
     SetSize( g, q^(n*(n-1)/2) * size );

     # construct the form
     c := Reversed( One( g ) );
     SetInvariantSesquilinearForm( g,
         rec( matrix:= ImmutableMatrix( f, c, true ) ) );
     SetIsFullSubgroupGLorSLRespectingSesquilinearForm(g,true);

     # Return the group.
     return g;
    end );


#############################################################################
##
#M  SpecialUnitaryGroupCons( <IsMatrixGroup>, <n>, <q> )
##
InstallMethod( SpecialUnitaryGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsPosInt,
      IsPosInt ],
    function( filter, n, q )
     local g, i, e, f, z, o, mat1, mat2, gens, size, qi, eps, c;

     f:= GF( q^2 );
     z:= PrimitiveRoot( f );
     o:= One( f );

     # Construct the generators.
     if n = 3 and q = 2 then

       mat1:= [ [o,z,z], [0,o,z^2], [0,0,o] ] * o;
       mat2:= [ [z,o,o], [o,o, 0 ], [o,0,0] ] * o;

     else

       mat1:= IdentityMat( n, f );
       mat2:= NullMat( n, n, f );

       if   n = 2 then

         # We use the isomorphism of 'SU(2,q)' and 'SL(2,q)':
         # 'e' is mapped to '-e' under the Frobenius mapping.
         e:= Z(q^2) - Z(q^2)^q;
         if q <= 3 then
           mat1[1,2]:= e;
           mat2[1,2]:= e;
           mat2[2,1]:= -e^-1;
         else
           mat1[1,1]:= z^(q+1);
           mat1[2,2]:= z^(-q-1);
           mat2[1,1]:= -o;
           mat2[1,2]:= e;
           mat2[2,1]:= -e^-1;
         fi;

       elif n mod 2 = 0 then

         mat1[1,1]:= z;
         mat1[n,n]:= z^-q;
         mat1[2,2]:= z^-1;
         mat1[ n-1, n-1 ]:= z^q;

         if q mod 2 = 1 then e:= z^( (q+1)/2 ); else e:= o; fi;
         for i in [ 2 .. n/2 ]     do mat2[ i, i-1 ]:= o; od;
         for i in [ n/2+1 .. n-1 ] do mat2[ i, i+1 ]:= o; od;
         mat2[ 1, 1 ]:= o;
         mat2[1,n/2+1]:= e;
         mat2[n-1,n/2]:= e^-1;
         mat2[n, n/2 ]:= -e^-1;

       elif n <> 1 then

         mat1[ (n-1)/2  , (n-1)/2  ]:= z;
         mat1[ (n-1)/2+1, (n-1)/2+1 ]:= z^q/z;
         mat1[ (n-1)/2+2, (n-1)/2+2 ]:= z^-q;

         for i in [ 1 .. (n-1)/2-1 ] do mat2[ i, i+1 ]:= o; od;
         for i in [ (n-1)/2+3 .. n ] do mat2[ i, i-1 ]:= o; od;
         mat2[(n-1)/2,    1    ]:=  -(1+z^q/z)^-1;
         mat2[(n-1)/2,(n-1)/2+1]:= -o;
         mat2[(n-1)/2,    n    ]:=  o;
         mat2[(n-1)/2+1,   1   ]:= -o;
         mat2[(n-1)/2+1,(n-1)/2+1]:= -o;
         mat2[(n-1)/2+2,  1  ]:=  o;
       fi;

     fi;

     mat1:=ImmutableMatrix(f,mat1,true);
     if n = 1 then
       gens := [ mat1 ];
     else
       mat2:=ImmutableMatrix(f,mat2,true);
       gens := [ mat1, mat2 ];
     fi;

     # Avoid to call 'Group' because this would check invertibility ...
     g:= GroupWithGenerators( gens );
     SetName( g, Concatenation("SU(",String(n),",",String(q),")") );
     SetDimensionOfMatrixGroup( g, n );
     SetFieldOfMatrixGroup( g, f );

     # Add the size.
     size := 1;
     qi   := q;
     eps  := 1;
     for i in [ 2 .. n ] do
       qi   := qi * q;
       eps  := -eps;
       size := size * (qi+eps);
     od;
     SetSize( g, q^(n*(n-1)/2) * size );

     # construct the form
     c := Reversed( One( g ) );
     SetInvariantSesquilinearForm( g,
         rec( matrix:= ImmutableMatrix( f, c, true ) ) );
     SetIsFullSubgroupGLorSLRespectingSesquilinearForm(g,true);
     SetIsSubgroupSL(g,true);

     # Return the group.
     return g;
    end );


#############################################################################
##
#M  SetInvariantQuadraticFormFromMatrix( <g>, <mat> )
##
##  Set the invariant quadratic form of <g>  to the matrix <mat>, and also
##  set the bilinear form to the value required by the documentation, i.e.,
#   to <mat> + <mat>^T.
##
BindGlobal( "SetInvariantQuadraticFormFromMatrix", function( g, mat )
    SetInvariantQuadraticForm( g, rec( matrix:= mat ) );
    SetInvariantBilinearForm( g, rec( matrix:= mat+TransposedMat(mat) ) );
end );


#############################################################################
##
#F  Oplus45() . . . . . . . . . . . . . . . . . . . . . . . . . . . . O+_4(5)
##
BindGlobal( "Oplus45", function()
    local   f,  tau2,  tau,  phi,  delta,  eichler,  g;

    f  := GF(5);

    # construct TAU2: tau(x1-x2)
    tau2 := NullMat( 4, 4, f );
    tau2[1,1] := One( f );
    tau2[2,2] := One( f );
    tau2[3,4] := One( f );
    tau2[4,3] := One( f );

    # construct TAU: tau(x1+x2)
    tau := NullMat( 4, 4, f );
    tau[1,1] := One( f );
    tau[2,2] := One( f );
    tau[3,4] := -One( f );
    tau[4,3] := -One( f );

    # construct PHI: phi(2)
    phi := IdentityMat( 4, f );
    phi[1,1] := 2*One( f );
    phi[2,2] := 3*One( f );

    # construct DELTA: u <-> v
    delta := IdentityMat( 4, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct eichler transformation
    eichler := [[1,0,0,0],[-1,1,-1,0],[2,0,1,0],[0,0,0,1]]*One( f );

    # construct the group without calling 'Group'
    g := [ phi*tau2, tau*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, 4 );
    SetFieldOfMatrixGroup( g, f );

    # set the size
    SetSize( g, 28800 );

    # construct the forms
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
        [[0,1,0,0],[0,0,0,0],[0,0,1,0],[0,0,0,1]] * One( f ), true ) );

    # and return
    return g;
end );


#############################################################################
##
#F  Opm3( <s>, <d> )  . . . . . . . . . . . . . . . . . . . . . .  O+-_<d>(3)
##
##  <q> must be 3, <d> at least 6,  beta is 2
##
BindGlobal( "Opm3", function( s, d )
    local   f,  theta,  i,  theta2,  phi,  eichler,  g,  delta;

    f  := GF(3);

    # construct DELTA: u <-> v, x -> x
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct THETA: x2 -> ... -> xk -> x2
    theta := NullMat( d, d, f );
    theta[1,1] := One( f );
    theta[2,2] := One( f );
    theta[3,3] := One( f );
    for i  in [ 4 .. d-1 ]  do
        theta[i,i+1] := One( f );
    od;
    theta[d,4] := One( f );

    # construct THETA2: x2 -> x1 -> x3 -> x2
    theta2 := IdentityMat( d, f );
    theta2{[3..5]}{[3..5]} := [[0,1,1],[-1,-1,1],[1,-1,1]]*One( f );

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( d, f );
    phi[1,1] := 2*One( f );
    phi[2,2] := (2*One( f ))^-1;

    # construct the eichler transformation
    eichler := IdentityMat( d, f );
    eichler[2,1] := -One( f );
    eichler[2,4] := -One( f );
    eichler[4,1] := 2*One( f );

    # construct the group without calling 'Group'
    g := [ phi*theta2, theta*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # construct the forms
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[0,0]]*One( f );
    delta[3,3] := One( f )*2;
    delta := ImmutableMatrix( f, delta, true );
    SetInvariantQuadraticFormFromMatrix( g, delta );

    # set the size
    delta  := 1;
    theta  := 1;
    theta2 := 3^2;
    for i  in [ 1 .. d/2-1 ]  do
        theta := theta * theta2;
        delta := delta * (theta-1);
    od;
    SetSize( g, 2*3^(d/2*(d/2-1))*(3^(d/2)-s)*delta );

    return g;
end );


#############################################################################
##
#F  OpmSmall( <s>, <d>, <q> ) . . . . . . . . . . . . . . . . .  O+-_<d>(<q>)
##
##  <q> must be 3 or 5, <d> at least 6,  beta is 1
##
BindGlobal( "OpmSmall", function( s, d, q )
    local   f,  theta,  i,  theta2,  phi,  eichler,  g,  delta;

    f  := GF(q);

    # construct DELTA: u <-> v, x -> x
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct THETA: x2 -> ... -> xk -> x2
    theta := NullMat( d, d, f );
    theta[1,1] := One( f );
    theta[2,2] := One( f );
    theta[3,3] := One( f );
    for i  in [ 4 .. d-1 ]  do
        theta[i,i+1] := One( f );
    od;
    theta[d,4] := One( f );

    # construct THETA2: x2 -> x1 -> x3 -> x2
    theta2 := IdentityMat( d, f );
    theta2{[3..5]}{[3..5]} := [[0,0,1],[1,0,0],[0,1,0]]*One( f );

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( d, f );
    phi[1,1] := 2*One( f );
    phi[2,2] := (2*One( f ))^-1;

    # construct the eichler transformation
    eichler := IdentityMat( d, f );
    eichler[2,1] := -One( f );
    eichler[2,4] := -One( f );
    eichler[4,1] := 2*One( f );

    # construct the group without calling 'Group'
    g := [ phi*theta2, theta*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # construct the forms
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[0,0]]*One( f );
    delta[3,3] := One( f );
    delta := ImmutableMatrix( f, delta, true );
    SetInvariantQuadraticFormFromMatrix( g, delta );

    # set the size
    delta  := 1;
    theta  := 1;
    theta2 := q^2;
    for i  in [ 1 .. d/2-1 ]  do
        theta := theta * theta2;
        delta := delta * (theta-1);
    od;
    SetSize( g, 2*q^(d/2*(d/2-1))*(q^(d/2)-s)*delta );

    return g;
end );


#############################################################################
##
#F  OpmOdd( <s>, <d>, <q> ) . . . . . . . . . . . . . . . . . . O<s>_<d>(<q>)
##
BindGlobal( "OpmOdd", function( s, d, q )
    local   f,  w,  beta,  epsilon,  eb1,  tau,  theta,  i,  phi,
            delta,  eichler,  g;

    # <d> must be at least 4
    if d mod 2 = 1  then
        Error( "<d> must be even" );
    fi;
    if d < 4  then
        Error( "<d> must be at least 4" );
    fi;

    # beta is either 1 or a generator of the field
    f := GF(q);
    w := LogFFE( -1*2^(d-2)*One( f ), PrimitiveRoot( f ) ) mod 2 = 0;
    beta := One( f );
    if s = +1 and (d*(q-1)/4) mod 2 = 0  then
        if not w  then
            beta := PrimitiveRoot( f );
        fi;
    elif s = +1 and (d*(q-1)/4) mod 2 = 1  then
        if w  then
            beta := PrimitiveRoot( f );
        fi;
    elif s = -1 and (d*(q-1)/4) mod 2 = 1  then
        if not w  then
            beta := PrimitiveRoot( f );
        fi;
    elif s = -1 and (d*(q-1)/4) mod 2 = 0  then
        if w  then
            beta := PrimitiveRoot( f );
        fi;
    else
        Error( "<s> must be -1 or +1" );
    fi;

    # special cases
    if q = 3 and d = 4 and s = +1  then
        g := GroupWithGenerators( [
                    [[1,0,0,0],[0,1,2,1],[2,0,2,0],[1,0,0,1]]*One( f ),
                    [[0,2,2,2],[0,1,1,2],[1,0,2,0],[1,2,2,0]]*One( f ) ] );
        SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
          [[0,1,0,0],[0,0,0,0],[0,0,2,0],[0,0,0,1]]*One( f ), true ) );
        SetSize( g, 1152 );
        return g;
    elif q = 3 and d = 4 and s = -1  then
        g := GroupWithGenerators( [
                    [[0,2,0,0],[2,1,0,1],[0,2,0,1],[0,0,1,0]]*One( f ),
                    [[2,0,0,0],[1,2,0,2],[1,0,0,1],[0,0,1,0]]*One( f ) ] );
        SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
          [[0,1,0,0],[0,0,0,0],[0,0,1,0],[0,0,0,1]]*One( f ), true ) );
        SetSize( g, 1440 );
        return g;
    elif q = 5 and d = 4 and s = +1  then
        return Oplus45();
    elif ( q = 3 or q = 5 ) and 4 < d and beta = One( f )  then
        return OpmSmall( s, d, q );
    elif q = 3 and 4 < d and beta <> One( f )  then
        return Opm3( s, d );
    fi;

    # find an epsilon such that (epsilon^2*beta)^2 <> 1
    if beta = PrimitiveRoot( f )  then
        epsilon := One( f );
    else
        epsilon := PrimitiveRoot( f );
    fi;

    # construct the reflection TAU_epsilon*x1+x2
    eb1 := epsilon^2*beta+1;
    tau := IdentityMat( d, f );
    tau[3,3] := 1-2*beta*epsilon^2/eb1;
    tau[3,4] := -2*beta*epsilon/eb1;
    tau[4,3] := -2*epsilon/eb1;
    tau[4,4] := 1-2/eb1;

    # construct THETA
    theta := NullMat( d, d, f );
    theta[1,1] := One( f );
    theta[2,2] := One( f );
    theta[3,3] := One( f );
    for i  in [ 4 .. d-1 ]  do
        theta[i,i+1] := One( f );
    od;
    theta[d,4] := -One( f );

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( d, f );
    phi[1,1] := PrimitiveRoot( f );
    phi[2,2] := PrimitiveRoot( f )^-1;

    # construct DELTA: u <-> v, x -> x
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct the eichler transformation
    eichler := IdentityMat( d, f );
    eichler[2,1] := -One( f );
    eichler[2,4] := -One( f );
    eichler[4,1] := 2*One( f );

    # construct the group without calling 'Group'
    g := [ phi, theta*tau*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # construct the forms
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[0,0]]*One( f );
    delta[3,3] := beta;
    delta := ImmutableMatrix( f, delta, true );
    SetInvariantQuadraticFormFromMatrix( g, delta );

    # set the size
    delta := 1;
    theta := 1;
    tau   := q^2;
    for i  in [ 1 .. d/2-1 ]  do
        theta := theta * tau;
        delta := delta * (theta-1);
    od;
    SetSize( g, 2*q^(d/2*(d/2-1))*(q^(d/2)-s)*delta );

    return g;
end );


#############################################################################
##
#F  Oplus2( <q> ) . . . . . . . . . . . . . . . . . . . . . . . . . O+_2(<q>)
##
BindGlobal( "Oplus2", function( q )
    local   z,  f,  m1,  m2,  g;

    # a field generator
    z := Z(q);
    f := GF(q);

    # a matrix of order q-1
    m1 := [ [ z, 0*z ], [ 0*z, z^-1 ] ];

    # a matrix of order 2
    m2 := [ [ 0, 1 ], [ 1, 0 ] ] * z^0;

    m1:= ImmutableMatrix( f, m1, true );
    m2:= ImmutableMatrix( f, m2, true );
    # construct the group, set the order, and return
    g := GroupWithGenerators( [ m1, m2 ] );
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
        [ [ 0, 1 ], [ 0, 0 ] ] * z^0, true ) );
    SetSize( g, 2*(q-1) );
    return g;
end );


#############################################################################
##
#F  Oplus4Even( <q> ) . . . . . . . . . . . . . . . . . . . . . . . O+_4(<q>)
##
BindGlobal( "Oplus4Even", function( q )
    local   f,  rho,  delta,  phi,  eichler,  g;

    # <q> must be even
    if q mod 2 = 1  then
        Error( "<q> must be even" );
    fi;
    f := GF(q);

    # construct RHO: x1 <-> y1
    rho := IdentityMat( 4, f );
    rho{[3,4]}{[3,4]} := [[0,1],[1,0]] * One( f );

    # construct DELTA: u <-> v
    delta := IdentityMat( 4, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( 4, f );
    phi[1,1] := PrimitiveRoot( f );
    phi[2,2] := PrimitiveRoot( f )^-1;

    # construct eichler transformation
    eichler := [[1,0,0,0],[0,1,-1,0],[0,0,1,0],[1,0,0,1]] * One( f );

    # construct the group without calling 'Group'
    g := [ phi*rho, rho*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, 4 );
    SetFieldOfMatrixGroup( g, f );

    # set the size
    SetSize( g, 2*q^2*(q^2-1)^2 );

    # construct the forms
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
      [[0,1,0,0],[0,0,0,0],[0,0,0,1],[0,0,0,0]] * One( f ), true ) );

    # and return
    return g;
end );


#############################################################################
##
#F  OplusEven( <d>, <q> ) . . . . . . . . . . . . . . . . . . . . O+_<d>(<q>)
##
BindGlobal( "OplusEven", function( d, q )
    local   f,  k,  phi,  delta,  theta,  i,  delta2,  eichler,
            rho,  g;

    # <d> and <q> must be even
    if d mod 2 = 1  then
        Error( "<d> must be even" );
    fi;
    if d < 6  then
        Error( "<d> must be at least 6" );
    fi;
    if q mod 2 = 1  then
        Error( "<q> must be even" );
    fi;
    f := GF(q);

    # V = H | H_1 | ... | H_k
    k := (d-2) / 2;

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( d, f );
    phi[1,1] := PrimitiveRoot( f );
    phi[2,2] := PrimitiveRoot( f )^-1;

    # construct DELTA: u <-> v, x -> x
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct THETA: x_2 -> x_3 -> .. -> x_k -> y_2 -> .. -> y_k -> x_2
    theta := NullMat( d, d, f );
    for i  in [ 1 .. 4 ]  do
        theta[i,i] := One( f );
    od;
    for i  in [ 2 .. k-1 ]  do
        theta[1+2*i,3+2*i] := One( f );
        theta[2+2*i,4+2*i] := One( f );
    od;
    theta[1+2*k,6] := One( f );
    theta[2+2*k,5] := One( f );

    # (k even) construct DELTA2: x_i <-> y_i, 1 <= i <= k-1
    if k mod 2 = 0  then
        delta2 := NullMat( d, d, f );
        delta2{[1,2]}{[1,2]} := [[1,0],[0,1]] * One( f );
        for i  in [ 1 .. k ]  do
            delta2[1+2*i,2+2*i] := One( f );
            delta2[2+2*i,1+2*i] := One( f );
        od;

    # (k odd) construct DELTA2: x_1 <-> y_1, x_i <-> x_i+1, y_i <-> y_i+1
    else
        delta2 := NullMat( d, d, f );
        delta2{[1,2]}{[1,2]} := [[1,0],[0,1]] * One( f );
        delta2{[3,4]}{[3,4]} := [[0,1],[1,0]] * One( f );
        for i  in [ 2, 4 .. k-1 ]  do
            delta2[1+2*i,3+2*i] := One( f );
            delta2[3+2*i,1+2*i] := One( f );
            delta2[2+2*i,4+2*i] := One( f );
            delta2[4+2*i,2+2*i] := One( f );
        od;
    fi;

    # construct eichler transformation
    eichler := IdentityMat( d, f );
    eichler[4,6] := One( f );
    eichler[5,3] := -One( f );

    # construct RHO = THETA * EICHLER
    rho := theta*eichler;

    # construct second eichler transformation
    eichler := IdentityMat( d, f );
    eichler[2,5] := -One( f );
    eichler[6,1] := One( f );

    # there seems to be something wrong in I/E for p=2
    if k mod 2 = 0  then
        if q = 2  then
            g := [ phi*delta2, rho, eichler, delta ];
        else
            g := [ phi*delta2, rho*eichler*delta, delta ];
        fi;
    elif q = 2  then
        g := [ phi*delta2, rho*eichler*delta, rho*delta ];
    else
        g := [ phi*delta2, rho*eichler*delta ];
    fi;

    # construct the group without calling 'Group'
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # construct the forms
    delta := NullMat( d, d, f );
    for i  in [ 1 .. d/2 ]  do
        delta[2*i-1,2*i] := One( f );
    od;
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f, delta, true ) );

    # set the size
    delta := 1;
    theta := 1;
    rho   := q^2;
    for i  in [ 1 .. d/2-1 ]  do
        theta := theta * rho;
        delta := delta * (theta-1);
    od;
    SetSize( g, 2*q^(d/2*(d/2-1))*(q^(d/2)-1)*delta );

    return g;
end );


#############################################################################
##
#F  Ominus2( <q> )  . . . . . . . . . . . . . . . . . . . . . . . . O-_2(<q>)
##
BindGlobal( "Ominus2", function( q )
    local z, f, one, R, x, t, n, e, bc, m2, m1, g;

    # construct the root
    z := Z(q);

    # find $x^2+x+t$ that is irreducible over GF(`q')
    f:= GF( q );
    one:= One( z );
    R:= PolynomialRing( f );
    x:= Indeterminate( f );
    t:= z^First( [ 0 .. q-2 ], u -> Length( Factors( R, x^2+x+z^u ) ) = 1 );

    # get roots in GF(q^2)
    n := List( Factors( PolynomialRing( GF( q^2 ) ), x^2+x+t ),
               x -> - CoefficientsOfLaurentPolynomial( x )[1][1] );
    e := 4*t-1;

    # construct base change
    bc := [ [ n[1]/e, 1/e ], [ n[2], one ] ];

    # matrix of order 2
    m2 := [ [ -1, 0 ], [ -1, 1 ] ] * one;

    # matrix of order q+1 (this will lie in $GF(q)^{d \times d}$)
    z  := Z(q^2)^(q-1);
    m1 := bc^-1 * [[z,0*z],[0*z,z^-1]] * bc;
    if IsCoeffsModConwayPolRep( z ) then
      # Write all relevant field elements explicitly over GF(q).
      m1[1,1]:= FFECONWAY.WriteOverSmallestField( m1[1,1] );
      m1[1,2]:= FFECONWAY.WriteOverSmallestField( m1[1,2] );
      m1[2,1]:= FFECONWAY.WriteOverSmallestField( m1[2,1] );
      m1[2,2]:= FFECONWAY.WriteOverSmallestField( m1[2,2] );
    fi;

    # and return the group
    m1:=ImmutableMatrix(GF(q),m1,true);
    m2:=ImmutableMatrix(GF(q),m2,true);
    g := GroupWithGenerators( [ m1, m2 ] );
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
      [ [ 1, 1 ], [ 0, t ] ] * one, true ) );
    SetSize( g, 2*(q+1) );

    return g;
end );


#############################################################################
##
#F  Ominus4Even( <q> )  . . . . . . . . . . . . . . . . . . . . . . O-_4(<q>)
##
BindGlobal( "Ominus4Even", function( q )
    local f, rho, delta, phi, R, x, t, eichler, g;

    # <q> must be even
    if q mod 2 = 1  then
        Error( "<q> must be even" );
    fi;
    f := GF(q);

    # construct RHO: x1 <-> y1
    rho := IdentityMat( 4, f );
    rho{[3,4]}{[3,4]} := [[0,1],[1,0]] * One( f );

    # construct DELTA: u <-> v
    delta := IdentityMat( 4, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( 4, f );
    phi[1,1] := PrimitiveRoot( f );
    phi[2,2] := PrimitiveRoot( f )^-1;

    # find x^2+x+t that is irreducible over <f>
    R:= PolynomialRing( f, 1 );
    x:= Indeterminate( f );
    t:= First( [ 0 .. q-2 ],
               u -> Length( Factors( R, x^2+x+PrimitiveRoot( f )^u ) ) = 1 );

    # compute square root of <t>
    t := t/2 mod (q-1);
    t := PrimitiveRoot( f )^t;

    # construct eichler transformation
    eichler := [[1,0,0,0],[-t,1,-1,0],[0,0,1,0],[1,0,0,1]] * One( f );

    # construct the group without calling 'Group'
    g := [ phi*rho, rho*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, 4 );
    SetFieldOfMatrixGroup( g, f );

    # set the size
    SetSize( g, 2*q^2*(q^2+1)*(q^2-1) );

    # construct the forms
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f,
      [[0,1,0,0],[0,0,0,0],[0,0,t,1],[0,0,0,t]] * One( f ), true ) );

    # and return
    return g;
end );


#############################################################################
##
#F  OminusEven( <d>, <q> )  . . . . . . . . . . . . . . . . . . . O-_<d>(<q>)
##
BindGlobal( "OminusEven", function( d, q )
    local f, k, phi, delta, theta, i, delta2, eichler, rho, g, t, R, x;

    # <d> and <q> must be odd
    if d mod 2 = 1  then
        Error( "<d> must be even" );
    elif d < 6  then
        Error( "<d> must be at least 6" );
    elif q mod 2 = 1  then
        Error( "<q> must be even" );
    fi;
    f := GF(q);

    # V = H | H_1 | ... | H_k
    k := (d-2) / 2;

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( d, f );
    phi[1,1] := PrimitiveRoot( f );
    phi[2,2] := PrimitiveRoot( f )^-1;

    # construct DELTA: u <-> v, x -> x
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct THETA: x_2 -> x_3 -> .. -> x_k -> y_2 -> .. -> y_k -> x_2
    theta := NullMat( d, d, f );
    for i  in [ 1 .. 4 ]  do
        theta[i,i] := One( f );
    od;
    for i  in [ 2 .. k-1 ]  do
        theta[1+2*i,3+2*i] := One( f );
        theta[2+2*i,4+2*i] := One( f );
    od;
    theta[1+2*k,6] := One( f );
    theta[2+2*k,5] := One( f );

    # (k even) construct DELTA2: x_i <-> y_i, 1 <= i <= k-1
    if k mod 2 = 0  then
        delta2 := NullMat( d, d, f );
        delta2{[1,2]}{[1,2]} := [[1,0],[0,1]] * One( f );
        for i  in [ 1 .. k ]  do
            delta2[1+2*i,2+2*i] := One( f );
            delta2[2+2*i,1+2*i] := One( f );
        od;

    # (k odd) construct DELTA2: x_1 <-> y_1, x_i <-> x_i+1, y_i <-> y_i+1
    else
        delta2 := NullMat( d, d, f );
        delta2{[1,2]}{[1,2]} := [[1,0],[0,1]] * One( f );
        delta2{[3,4]}{[3,4]} := [[0,1],[1,0]] * One( f );
        for i  in [ 2, 4 .. k-1 ]  do
            delta2[1+2*i,3+2*i] := One( f );
            delta2[3+2*i,1+2*i] := One( f );
            delta2[2+2*i,4+2*i] := One( f );
            delta2[4+2*i,2+2*i] := One( f );
        od;
    fi;

    # find x^2+x+t that is irreducible over GF(`q')
    R:= PolynomialRing( f );
    x:= Indeterminate( f );
    t:= First( [ 0 .. q-2 ],
               u -> Length( Factors( R, x^2+x+PrimitiveRoot( f )^u ) ) = 1 );

    # compute square root of <t>
    t := t/2 mod (q-1);
    t := PrimitiveRoot( f )^t;

    # construct Eichler transformation
    eichler := IdentityMat( d, f );
    eichler[4,6] := One( f );
    eichler[5,3] := -One( f );
    eichler[5,6] := -t;

    # construct RHO = THETA * EICHLER
    rho := theta*eichler;

    # construct second eichler transformation
    eichler := IdentityMat( d, f );
    eichler[2,5] := -One( f );
    eichler[6,1] := One( f );

    # there seems to be something wrong in I/E for p=2
    if k mod 2 = 0  then
        if q = 2  then
            g := [ phi*delta2, rho, eichler, delta ];
        else
            g := [ phi*delta2, rho*eichler*delta, delta ];
        fi;
    elif q = 2  then
        g := [ phi*delta2, rho*eichler*delta, rho*delta ];
    else
        g := [ phi*delta2, rho*eichler*delta ];
    fi;

    # construct the group without calling 'Group'
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # construct the forms
    delta := NullMat( d, d, f );
    for i  in [ 1 .. d/2 ]  do
        delta[2*i-1,2*i] := One( f );
    od;
    delta[3,3] := t;
    delta[4,4] := t;
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f, delta, true ) );

    # set the size
    delta := 1;
    theta := 1;
    rho   := q^2;
    for i  in [ 1 .. d/2-1 ]  do
        theta := theta * rho;
        delta := delta * (theta-1);
    od;
    SetSize( g, 2*q^(d/2*(d/2-1))*(q^(d/2)+1)*delta );

    return g;
end );


#############################################################################
##
#F  OzeroOdd( <d>, <q>, <b> ) . . . . . . . . . . . . . . . . . . O0_<d>(<q>)
##
##  'OzeroOdd'  construct  the orthogonal   group in  odd dimension  and  odd
##  characteristic. The discriminant of the quadratic form is -(2<b>)^(<d>-2)
##
BindGlobal( "OzeroOdd", function( d, q, b )
    local   phi,  delta,  rho,  i,  eichler,  g,  s,  f,  q2,  q2i;

    # <d> and <q> must be odd
    if d mod 2 = 0  then
        Error( "<d> must be odd" );
    elif q mod 2 = 0  then
        Error( "<q> must be odd" );
    fi;

    f := GF(q);
    if d = 1 then
      # The group has order two.
      s:= ImmutableMatrix( f, [ [ One( f ) ] ], true );
      g:= GroupWithGenerators( [ -s ] );
      SetDimensionOfMatrixGroup( g, d );
      SetFieldOfMatrixGroup( g, f );
      SetSize( g, 2 );
      SetInvariantQuadraticFormFromMatrix( g, s );
      return g;
    fi;

    # construct PHI: u -> au, v -> a^-1v, x -> x
    phi := IdentityMat( d, f );
    phi[1,1] := PrimitiveRoot( f );
    phi[2,2] := PrimitiveRoot( f )^-1;

    # construct DELTA: u <-> v, x -> x
    delta := IdentityMat( d, f );
    delta{[1,2]}{[1,2]} := [[0,1],[1,0]]*One( f );

    # construct RHO: u -> u, v -> v, x_i -> x_i+1
    rho := NullMat( d, d, f );
    rho[1,1] := One( f );
    rho[2,2] := One( f );
    for i  in [ 3 .. d-1 ]  do
        rho[i,i+1] := One( f );
    od;
    rho[d,3] := One( f );

    # construct eichler transformation
    eichler := IdentityMat( d, f );
    eichler{[1..3]}{[1..3]} := [[1,0,0],[-b,1,-1],[2*b,0,1]] * One( f );

    # construct the group without calling 'Group'
    g := [ phi, rho*eichler*delta ];
    g:=List(g,i->ImmutableMatrix(f,i,true));
    g := GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # and set its size
    s   := 1;
    q2  := q^2;
    q2i := 1;
    for i  in [ 1 .. (d-1)/2 ]  do
        q2i := q2 * q2i;
        s   := s  * (q2i-1);
    od;
    SetSize( g, 2 * q^((d-1)^2/4) * s );

    # construct the forms
    s := b * IdentityMat( d, f );
    s{[1,2]}{[1,2]} := [[0,1],[0,0]]*One( f );
    SetInvariantQuadraticFormFromMatrix( g, ImmutableMatrix( f, s, true ) );

    # and return
    return g;
end );


#############################################################################
##
#F  OzeroEven( <d>, <q> ) . . . . . . . . . . . . . . . . . . . . O0_<d>(<q>)
##
##  'OzeroEven' constructs the orthogonal group in odd dimension and even
##  characteristic.
##  The generators are constructed via the isomorphism with the symplectic
##  group in dimension $<d>-1$ over the field with <q> elements.
##
##  Removing the first row and the first column from the matrices defines the
##  isomorphism to the symplectic group.
##  This group is *not* equal to the symplectic group constructed with the
##  function `Sp',
##  since the bilinear form of the orthogonal group is the one used in the
##  book of Carter and not the one used for `Sp'.
##  (Note that our matrices are transposed, relative to the ones given by
##  Carter, because the group shall act on a *row* space.)
##
##  The generators of the orthogonal groups can be computed as those matrices
##  that project onto the generators of the symplectic group and satisfy the
##  quadratic form
##  $f(x) = x_0^2 + x_1 x_{-1} + x_2 x_{-2} + \cdots + x_l x_{-l}$.
##  This condition results in a quadratic equation system that can be
##  interpreted as a linear equation system because taking square roots is
##  one-to-one in characteristic $2$.
##
BindGlobal( "OzeroEven", function( d, q )
    local f, z, o, n, mat1, mat2, i, g, size, qi, s;

    # <d> must be odd, <q> must be even
    if d mod 2 = 0 then
      Error( "<d> must be odd" );
    elif q mod 2 = 1 then
      Error( "<q> must be even" );
    fi;
    f:= GF(q);
    z:= PrimitiveRoot( f );
    o:= One( f );
    n:= Zero( f );

    if d = 1 then

      # The group is trivial.
      s:= ImmutableMatrix( f, [ [ o ] ], true );
      g:= GroupWithGenerators( [], s  );
      SetDimensionOfMatrixGroup( g, d );
      SetFieldOfMatrixGroup( g, f );
      SetSize( g, 1 );
      SetInvariantQuadraticFormFromMatrix( g, s );
      return g;

    elif d = 3 then

      # The isomorphic symplectic group is $SL(2,<q>)$.
      if q = 2 then
        mat1:= ImmutableMatrix( f, [ [o,n,n], [o,o,o], [n,n,o] ],true );
        mat2:= ImmutableMatrix( f, [ [o,n,n], [n,n,o], [n,o,n] ],true );
      else
        mat1:= ImmutableMatrix( f, [ [o,n,n], [n,z,n], [n,n,z^-1] ],true );
        mat2:= ImmutableMatrix( f, [ [o,n,n], [o,o,o], [n,o,n] ],true );
      fi;

    elif d = 5 and q = 2  then

      # The isomorphic symplectic group is $Sp(4,2)$.
      mat1:= ImmutableMatrix( f, [ [o,n,n,n,n], [o,n,o,n,o], [o,n,o,o,o],
                                   [n,o,n,n,o], [n,o,o,o,o] ],true );
      mat2:= ImmutableMatrix( f, [ [o,n,n,n,n], [n,n,o,n,n], [n,n,n,o,n],
                                   [n,n,n,n,o], [n,o,n,n,n] ],true );

    else

      mat1:= IdentityMat( d, f );
      mat2:= NullMat( d, d, f );
      mat2[1,1]:= o;
      mat2[d,2]:= o;
      for i in [ 2 .. d-1 ] do
        mat2[i,i+1]:= o;
      od;

      if q = 2 then
        mat1[(d+1)/2,      1]:= o;
        mat1[(d+1)/2,      2]:= o;
        mat1[(d+1)/2,      d]:= o;
        mat1[(d+3)/2,      d]:= o;
      else
        mat1[      2,      2]:= z;
        mat1[(d+1)/2,(d+1)/2]:= z;
        mat1[(d+3)/2,(d+3)/2]:= z^-1;
        mat1[      d,      d]:= z^-1;
        mat2[(d+1)/2,      1]:= o;
        mat2[(d+1)/2,      2]:= o;
        mat2[(d+1)/2,      3]:= o;
        mat2[(d+3)/2,      2]:= o;
      fi;

    fi;

    mat1:= ImmutableMatrix( f, mat1,true );
    mat2:= ImmutableMatrix( f, mat2,true );

    # avoid to call 'Group' because this would check invertibility ...
    g:= GroupWithGenerators( [ mat1, mat2 ] );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );
    SetIsSubgroupSL( g, true );

    # add the size
    size := 1;
    qi   := 1;
    for i in [ 1 .. (d-1)/2 ] do
      qi   := qi * q^2;
      size := size * (qi-1);
    od;
    SetSize( g, q^(((d-1)/2)^2) * size );

    # construct the forms
    s := NullMat( d, d, f );
    s[1,1]:= o;
    for i in [ 2 .. (d+1)/2 ] do
      s[(d-1)/2+i,i]:= o;
    od;
    s:= ImmutableMatrix( f, s, true );
    SetInvariantQuadraticFormFromMatrix( g, s );

    # and return
    return g;
end );


#############################################################################
##
#M  GeneralOrthogonalGroupCons( <e>, <d>, <q> ) . . . . . . .  GO<e>_<d>(<q>)
##
InstallMethod( GeneralOrthogonalGroupCons,
    "matrix group for <e>, dimension, and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsInt,
      IsPosInt,
      IsPosInt ],
    function( filter, e, d, q )
    local   g,  i;

    # <e> must be -1, 0, +1
    if e <> -1 and e <> 0 and e <> +1  then
        Error( "sign <e> must be -1, 0, +1" );
    fi;

    # if <e> = 0  then <d> must be odd
    if e = 0 and d mod 2 = 0  then
        Error( "sign <e> = 0 but dimension <d> is even" );

    # if <e> <> 0  then <d> must be even
    elif e <> 0 and d mod 2 = 1  then
        Error( "sign <e> <> 0 but dimension <d> is odd" );
    fi;

    # construct the various orthogonal groups
    if   e = 0 and q mod 2 <> 0  then
        g := OzeroOdd( d, q, 1 );
    elif e = 0  then
        g := OzeroEven( d, q );

    # O+(2,q) = D_{2(q-1)}
    elif e = +1 and d = 2  then
        g := Oplus2(q);

    # if <d> = 4 and <q> even use 'Oplus4Even'
    elif e = +1 and d = 4 and q mod 2 = 0  then
        g := Oplus4Even(q);

    # if <q> is even use 'OplusEven'
    elif e = +1 and q mod 2 = 0  then
        g := OplusEven( d, q );

    # if <q> is odd use 'OpmOdd'
    elif e = +1 and q mod 2 = 1  then
        g := OpmOdd( +1, d, q );

    # O-(2,q) = D_{2(q+1)}
    elif e = -1 and d = 2  then
         g := Ominus2(q);

    # if <d> = 4 and <q> even use 'Ominus4Even'
    elif e = -1 and d = 4 and q mod 2 = 0  then
        g := Ominus4Even(q);

    # if <q> is even use 'OminusEven'
    elif e = -1 and q mod 2 = 0  then
        g := OminusEven( d, q );

    # if <q> is odd use 'OpmOdd'
    elif e = -1 and q mod 2 = 1  then
        g := OpmOdd( -1, d, q );
    fi;

    # set name
    if e = +1  then i := "+";  else i := "";  fi;
    SetName( g, Concatenation( "GO(", i, String(e), ",", String(d), ",",
                                   String(q), ")" ) );

    SetIsFullSubgroupGLorSLRespectingQuadraticForm( g, true );
    if q mod 2 = 1 then
      SetIsFullSubgroupGLorSLRespectingBilinearForm( g, true );
#T in which cases does characteristic 2 imply `false'?
    fi;

    # and return
    return g;
end );

InstallMethod( GeneralOrthogonalGroupCons,
    "matrix group for dimension and finite field",
    [ IsMatrixGroup and IsFinite,
      IsInt,
      IsPosInt,
      IsField and IsFinite ],
function(filt,sign,n,f)
  return GeneralOrthogonalGroupCons(filt,sign,n,Size(f));
end);


#############################################################################
##
#M  SpecialOrthogonalGroupCons( <e>, <d>, <q> ) . . . . . . .  GO<e>_<d>(<q>)
##
##  SO has index $1$ in GO if the characteristic is even
##  and index $2$ if the characteristic is odd.
##
##  In the latter case, the generators of GO are $a$ and $b$.
##  When GO is constructed with `OzeroOdd', `Oplus2', and `Ominus2' then by
##  construction $a$ has determinant $1$, and $b$ has determinant $-1$.
##  The group $\langle a, b^{-1} a b, b^2 \rangle$ is therefore equal to SO.
##  (Note that it is clearly contained in SO, and each word in terms of $a$
##  and $b$ can be written as a word in terms of the three generators above
##  or $b$ times such a word.)
##  So the case `OpmOdd' is left, which deals with three exceptions
##  $(s,d,q) \in \{ (1,4,3), (-1,4,3), (1,4,5) \}$, two series for small $q$
##  (via `OpmSmall' and `Opm3'), and the generic remainder;
##  exactly in the two of the three exceptional cases where $s = 1$ holds,
##  the determinant of the first generator is $-1$; in these cases, the
##  determinant of the second generator is $1$, so we get the generating set
##  $\{ a^2, a^{-1} b a, b \}$.
##
InstallMethod( SpecialOrthogonalGroupCons,
    "matrix group for <e>, dimension, and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsInt,
      IsPosInt,
      IsPosInt ],
    function( filter, e, d, q )
    local G, gens, U, i;

    G:= GeneralOrthogonalGroupCons( filter, e, d, q );
    if q mod 2 = 1 then

      # Deal with the special cases.
      gens:= GeneratorsOfGroup( G );
      if e = 1 and d = 4 and q in [ 3, 5 ] then
        gens:= Reversed( gens );
      fi;

      # Construct the group.
      if d = 1 then
        U:= GroupWithGenerators( [], One( G ) );
      else
        Assert( 1, Length( gens ) = 2 and IsOne( DeterminantMat( gens[1] ) ) );
        U:= GroupWithGenerators( [ gens[1], gens[1]^gens[2], gens[2]^2 ] );
      fi;

      # Set the group order.
      SetSize( U, Size( G ) / 2 );

      # Set the name.
      if e = +1  then i := "+";  else i := "";  fi;
      SetName( U, Concatenation( "SO(", i, String(e), ",", String(d), ",",
                                     String(q), ")" ) );

      # Set the invariant quadratic form and the symmetric bilinear form.
      SetInvariantBilinearForm( U, InvariantBilinearForm( G ) );
      SetInvariantQuadraticForm( U, InvariantQuadraticForm( G ) );
      SetIsFullSubgroupGLorSLRespectingQuadraticForm( U, true );
      SetIsFullSubgroupGLorSLRespectingBilinearForm( U, true );
      G:= U;

    fi;
    return G;
    end );

InstallMethod( SpecialOrthogonalGroupCons,
    "matrix group for dimension and finite field",
    [ IsMatrixGroup and IsFinite,
      IsInt,
      IsPosInt,
      IsField and IsFinite ],
function(filt,sign,n,f)
  return SpecialOrthogonalGroupCons(filt,sign,n,Size(f));
end);


#############################################################################
##
#F  OmegaZero( <d>, <q> ) . . . . . . . . . . . . . . . . \Omega^0_{<d>}(<q>)
##
BindGlobal( "OmegaZero", function( d, q )
    local f, o, m, mo, n, i, x, g, xi, h, s, q2, q2i;

    # <d> must be odd
    if d mod 2 = 0 then
      Error( "<d> must be odd" );
    elif d = 1 then
      # The group is trivial.
      return SO( d, q );
    elif q mod 2 = 0 then
      # For even q, the generators claimed in [RylandsTalor98] are wrong:
      # For (d,q) = (5,2), the matrices generate only S4(2)' not S4(2).
      # In the other cases, the matrices would have to be transposed
      # in order to respect a form as required;
      # thus they describe a group of the right isomorphism type
      # but not an orthogonal group.
      # We return the isomorphic group SO(d,q) in these cases;
      # note that this is the definition of Omega(d,q) for odd d and even q
      # in the ATLAS of Finite Groups [CCN85, p. xi].
      return SO( d, q );
    fi;
    f:= GF(q);
    o:= One( f );
    m:= ( d-1 ) / 2;

    if 3 < d then
      # Omega(0,d,q) for d=2m+1, m >= 2, Section 4.5
      if d mod 4 = 3 then
        mo:= -o;  # (-1)^m
      else
        mo:= o;
      fi;

      n:= NullMat( d, d, f );
      n[m+2, 1]:= mo;
      n[  m, d]:= mo;
      n[m+1, m+1]:= -o;
      for i in [ 1 .. m-1 ] do
        n[i,i+1]:= o;
        n[ d+1-i, d-i ]:= o;
      od;

      # $x = x_{\alpha_1}(1)$
      x:= IdentityMat( d, f );
      x[m, m+1 ]:= 2*o;
      x[ m+1, m+2 ]:= -o;
      x[m, m+2 ]:= -o;

      if q <= 3 then
        # the matrices $x$ and $n$
        g:= [ x, n ];
      else
        # the matrices $h$ and $x n$
        xi:= Z(q);
        h:= IdentityMat( d, f );
        h[1,1]:= xi;
        h[m,m]:= xi;
        h[ m+2, m+2 ]:= xi^-1;
        h[d,d]:= xi^-1;
        g:= [ h, x*n ];
      fi;

    else
      # Omega(0,3,q), Section 4.6
      if q <= 3 then
        # the matrices $x$ and $n$
        g:= [ [[1,0,0],[1,1,0],[-1,-2,1]],
              [[0,0,-1],[0,-1,0],[-1,0,0]] ] * o;
      else
        # the matrices $n x$ and $h$
        xi:= Z(q);
        g:= [ [[1,2,-1],[-1,-1,0],[-1,0,0]],
              [[xi^-2,0,0],[0,1,0],[0,0,xi^2]] ] * o;
      fi;
    fi;

    # construct the group without calling 'Group'
    g:= List( g, i -> ImmutableMatrix( f, i, true ) );
    g:= GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # and set its size
    s  := 1;
    q2 := q^2;
    q2i:= 1;
    for i in [ 1 .. m ] do
      q2i:= q2 * q2i;
      s  := s * (q2i-1);
    od;
    if q mod 2 = 1 then
      s:= s/2;
    fi;
    SetSize( g, q^(m^2) * s );

    # construct the forms
    x:= NullMat( d, d, f );
    for i in [ 1 .. m ] do
      x[i,d-i+1] := o;
    od;
    x[m+1,m+1] := (Characteristic(f)+1)/4*o;
    SetInvariantQuadraticFormFromMatrix(g, ImmutableMatrix( f, x, true ) );

    # and return
    return g;
    end );


#############################################################################
##
#F  OmegaPlus( <d>, <q> ) . . . . . . . . . . . . . . . . \Omega^+_{<d>}(<q>)
##
BindGlobal( "OmegaPlus", function( d, q )
    local f, o, m, xi, g, a, mo, n, i, x1, x2, x, h, s, q2, q2i;

    # <d> must be even
    if d mod 2 = 1 then
      Error( "<d> must be even" );
    fi;
    f:= GF(q);
    o:= One( f );
    m:= d / 2;
    xi:= Z(q);

    if m = 1 then
      # Omega(+1,2,q), Section 4.4
      g:= [ [[xi^2,0],[0,xi^-2]] ] * o;
    elif m = 2 then
      # Omega(+1,4,q), Section 4.3
      xi:= Z(q^2)^(q-1);
      a:= xi + xi^-1;
      g:= [ [[0,-1,0,-1],[1,a,-1,a],[0,0,0,1],[0,0,-1,a]],
            [[0,0,1,-1],[0,0,0,-1],[-1,-1,a,-a],[0,1,0,a]] ] * o;
    else
      # Omega(+1,d,q) for d=2m, Sections 4.1 and 4.2
      if d mod 4 = 2 then
        mo:= -o;  # (-1)^m
      else
        mo:= o;
      fi;

      n:= NullMat( d, d, f );
      n[ m+2,1]:= mo;
      n[ m-1,d]:= mo;
      n[m, m+1 ]:= o;
      n[ m+1,m]:= o;
      for i in [ 1 .. m-2 ] do
        n[i, i+1 ]:= o;
        n[ d+1-i, d-i ]:= o;
      od;

      if m mod 2 = 0 then
        x1:= IdentityMat( d, f );
        if q = 2 then
          x1[ m-1, m+1 ]:= -o;
          x1[m, m+2 ]:= o;
        else
          x1[ m+2, m]:= o;
          x1[ m+1, m-1 ]:= -o;
        fi;
        x2:= IdentityMat( d, f );
        x2[ m-2, m-1 ]:= o;
        x2[ m+2, m+3 ]:= -o;
        x:= x1 * x2;
      else
        x:= IdentityMat( d, f );
        x[ m-1, m+1 ]:= -o;
        x[m, m+2 ]:= o;
      fi;

      if ( m mod 2 = 0 and q = 2 ) or ( m mod 2 = 1 and q <= 3 ) then
        # the matrices $x$ and $n$
        g:= [ x, n ];
      else
        # the matrices $h$ and $x n$
        h:= IdentityMat( d, f );
        h[ m-1, m-1 ]:= xi;
        h[ m+2, m+2 ]:= xi^-1;
        if m mod 2 = 0 then
          h[ m, m ]:= xi^-1;
          h[ m+1, m+1 ]:= xi;
        else
          h[ m, m ]:= xi;
          h[ m+1, m+1 ]:= xi^-1;
        fi;
        g:= [ h, x*n ];
      fi;
    fi;

    # construct the group without calling 'Group'
    g:= List( g, i -> ImmutableMatrix( f, i, true ) );
    g:= GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # and set its size
    s  := 1;
    q2 := q^2;
    q2i:= 1;
    for i in [ 1 .. m-1 ] do
      q2i:= q2 * q2i;
      s  := s * (q2i-1);
    od;
    if q mod 2 = 1 then
      s:= s/2;
    fi;
    SetSize( g, q^(m*(m-1)) * (q^m-1) * s );

    # construct the forms
    x:= NullMat( d, d, f );
    for i in [ 1 .. m ] do
      x[i,d-i+1] := o;
    od;
    x:= ImmutableMatrix( f, x, true );
    SetInvariantQuadraticFormFromMatrix( g, x );

    # and return
    return g;
    end );


#############################################################################
##
#F  OmegaMinus( <d>, <q> )  . . . . . . . . . . . . . . . \Omega^-_{<d>}(<q>)
##
BindGlobal( "OmegaMinus", function( d, q )
    local f, o, m, xi, mo, nu, nubar, nutrace, nuinvtrace, nunorm, h, x, n,
          i, g, s, q2, q2i;

    # <d> must be even
    if d mod 2 = 1 then
      Error( "<d> must be even" );
    elif d = 2 then
      # The construction in the Rylands/Taylor paper does not apply
      # to the case d = 2.
      # The group 'Ominus2( q ) = GO(-1,2,q)' is a dihedral group
      # of order 2*(q+1).
      g:= Ominus2( q );
      h:= GeneratorsOfGroup( g )[1];
      Assert( 1, Order( h ) = q+1 );
      if IsEvenInt( q ) then
        # For even q, 'GO(-1,2,q)' is equal to 'SO(-1,2,q)',
        # and 'Omega(-1,2,q)' is its unique subgroup of index two.
        s:= GroupWithGenerators( [ h ] );
      else
        # For odd q, the group 'SO(-1,2,q)' is cyclic of order q+1,
        # and 'Omega(-1,2,q)' is its unique subgroup of index two.
        s:= GroupWithGenerators( [ h^2 ] );
      fi;
      SetInvariantBilinearForm( s, InvariantBilinearForm( g ) );
      SetInvariantQuadraticForm( s, InvariantQuadraticForm( g ) );
      return s;
    fi;
    f:= GF(q);
    o:= One( f );
    m:= d / 2 - 1;
    xi:= Z(q);

    if d mod 4 = 2 then
      mo:= -o;  # (-1)^(m-1)
    else
      mo:= o;
    fi;

    nu:= Z(q^2);
    nubar:= nu^q;
    nutrace:= nu + nubar;
    nuinvtrace:= nu^-1 + nubar^-1;
    nunorm:= nu * nubar;
    if IsCoeffsModConwayPolRep( nu ) then
      # Write all relevant field elements explicitly over GF(q).
      nutrace:= FFECONWAY.WriteOverSmallestField( nutrace );
      nuinvtrace:= FFECONWAY.WriteOverSmallestField( nuinvtrace );
      nunorm:= FFECONWAY.WriteOverSmallestField( nunorm );
    fi;

    h:= IdentityMat( d, f );
    h[m,m]:= nunorm;
    h[ m+3, m+3 ]:= nunorm^-1;
    h{ [ m+1 .. m+2 ] }{ [ m+1 .. m+2 ] }:= [
        [-1, nuinvtrace],
        [-nutrace, nutrace * nuinvtrace - o]] * o;
    x:= IdentityMat( d, f );
    x{ [ m .. m+3 ] }{ [ m .. m+3 ] }:= [[1,1,0,1],[0,1,0,2],
                                         [0,0,1,nutrace],
                                         [0,0,0,1]] * o;

    n:= NullMat( d, d, f );
    n[ m+3,1]:= mo;
    n[ m,d]:= mo;
    n[ m+1, m+1 ]:= -o;
    n[ m+2, m+1 ]:= -nutrace;
    n[ m+2, m+2 ]:= o;
    for i in [ 1 .. m-1 ] do
      n[i, i+1 ]:= o;
      n[ d+1-i, d-i ]:= o;
    od;

    g:= [ h, x*n ];

    # construct the group without calling 'Group'
    g:= List( g, i -> ImmutableMatrix( f, i, true ) );
    g:= GroupWithGenerators( g );
    SetDimensionOfMatrixGroup( g, d );
    SetFieldOfMatrixGroup( g, f );

    # and set its size
    m:= d/2;
    s  := 1;
    q2 := q^2;
    q2i:= 1;
    for i in [ 1 .. m-1 ] do
      q2i:= q2 * q2i;
      s  := s * (q2i-1);
    od;
    if q mod 2 = 1 then
      s:= s/2;
    fi;
    SetSize( g, q^(m*(m-1)) * (q^m+1) * s );

    # construct the forms
    x:= NullMat( d, d, f );
    for i in [ 1 .. m-1 ] do
      x[i,d-i+1] := o;
    od;
    x[m,d-m+1] := -nutrace;
    x[m,d-m] := -o;
    x[m+1,d-m+1] := -xi;
    x:= ImmutableMatrix( f, x, true );
    SetInvariantQuadraticFormFromMatrix( g, x );

    # and return
    return g;
    end );


#############################################################################
##
#M  OmegaCons( <filter>, <e>, <d>, <q> )  . . . . . . . . .  orthogonal group
##
InstallMethod( OmegaCons,
    "matrix group for <e>, dimension, and finite field size",
    [ IsMatrixGroup and IsFinite,
      IsInt,
      IsPosInt,
      IsPosInt ],
    function( filter, e, d, q )
    local g, i;

    # if <e> = 0  then <d> must be odd
    if e = 0 and d mod 2 = 0  then
        Error( "sign <e> = 0 but dimension <d> is even" );

    # if <e> <> 0  then <d> must be even
    elif e <> 0 and d mod 2 = 1  then
        Error( "sign <e> <> 0 but dimension <d> is odd" );
    fi;

    # construct the various orthogonal groups
    if   e = 0 then
      g:= OmegaZero( d, q );
    elif e = 1 then
      g:= OmegaPlus( d, q );
    elif e = -1 then
      g:= OmegaMinus( d, q );
    else
      Error( "sign <e> must be -1, 0, +1" );
    fi;

    # set name
    if e = +1  then i := "+";  else i := "";  fi;
    SetName( g, Concatenation( "Omega(", i, String(e), ",", String(d), ",",
                               String(q), ")" ) );

    # and return
    return g;
end );


#############################################################################
##
#M  Omega( [<filt>, ][<e>, ]<d>, <q> )
##
InstallMethod( Omega,
    [ IsPosInt, IsPosInt ],
    function( d, q )
    return OmegaCons( IsMatrixGroup, 0, d, q );
    end );

InstallMethod( Omega,
    [ IsInt, IsPosInt, IsPosInt ],
    function( e, d, q )
    return OmegaCons( IsMatrixGroup, e, d, q );
    end );

InstallMethod( Omega,
    [ IsFunction, IsPosInt, IsPosInt ],
    function( filt, d, q )
    return OmegaCons( filt, 0, d, q );
    end );

InstallMethod( Omega,
    [ IsFunction, IsInt, IsPosInt, IsPosInt ],
    OmegaCons );


#############################################################################
##
#M  Omega( [<filt>, ][<e>, ]<d>, <F_q> )
##
InstallMethod( Omega,
    [ IsPosInt, IsField and IsFinite ],
    { d, R } -> OmegaCons( IsMatrixGroup, 0, d, Size( R ) ) );

InstallMethod( Omega,
    [ IsInt, IsPosInt, IsField and IsFinite ],
    { e, d, R } -> OmegaCons( IsMatrixGroup, e, d, Size( R ) ) );

InstallMethod( Omega,
    [ IsFunction, IsPosInt, IsField and IsFinite ],
    { filt, d, R } -> OmegaCons( filt, 0, d, Size( R ) ) );

InstallMethod( Omega,
    [ IsFunction, IsInt, IsPosInt, IsField and IsFinite ],
    { filt, e, d, R } -> OmegaCons( filt, e, d, Size( R ) ) );


#############################################################################
##
#F  WallForm( <form>, <m> ) . . .  compute Wall form of <m> wrt <form>
##
##  Return the Wall form of <m>, where <m> is a matrix which is orthogonal
##  with respect to the bilinear form <form>, also given as a matrix.
##  For the definition of Wall forms, see [Tay92, page 163].
BindGlobal( "WallForm", function( form, m )
    local id,  w,  b,  p,  i,  x,  j, d, rank;

    id := One( m );

    # compute a base for Image(id-m) which is a subset of the rows of (id - m)
    # We also store the index of the rows (corresponding to w) in p
    w := id - m;
    b := [];
    p := [];
    rank := 0;
    for i in [ 1 .. Length(w) ]  do
        # add a new row and see if that increases the rank
        Add( b, w[i] );
        if RankMat(b) > rank then
            Add( p, i );
            rank := rank + 1;
        else
            Remove( b ); # rank was not increased, so remove the added row again
        fi;
    od;

    # compute the form
    d := Length(b);
    x := NullMat(d,d,DefaultFieldOfMatrix(m));
    for i  in [ 1 .. d ]  do
        for j  in [ 1 .. d ]  do
            x[i,j] := form[p[i]] * b[j];
        od;
    od;

    # and return
    return rec( base := b, pos := p, form := x );

end );


#############################################################################
##
#F  IsSquareFFE( fld, e) . . . . . . . Tests whether <e> is a square in <fld>
##
## For an finite field element <e> of <fld> this function returns
## true if <e> is a square element in <fld> and otherwise false.
BindGlobal( "IsSquareFFE", function( fld, e )
    local char, q;

    if IsZero(e) then
        return true;
    else
        char := Characteristic(fld);
        # If the characteristic of fld is equal to 2, we know that every element is a
        # square. Hence, we can return true.
        if char = 2 then
            return true;
        fi;
        q := Size(fld);

        # If the characteristic of fld is not 2, we know that there are exactly
        # (q+1)/2 elements which are a square (Huppert LA, Theorem 2.5.4). Now observe
        # that for a square element e we have that e^((q-1)/2) = 1. And, thus, the
        # polynomial X^((q-1)/2) - 1 has already (q-1)/2 different roots (every square
        # except 0). Hence, for a non-square element e' we have that (e')^((q-1)/2) <> 1
        # which proves the line below.
        return IsOne(e^((q-1)/2));
    fi;

end );


#############################################################################
##
#F  SpinorNorm( <form>, <fld>, <m> ) . . . . . compute the spinor norm of <m>
##
##
## For a matrix <m> over the finite field <fld> of odd characteristic which
## is orthogonal with respect to the bilinear form <form>, also given as a
## matrix, this function returns One(fld) if the discriminant of the
## Wall form of <m> is (F^*)^2 and otherwise -1 * One(fld).
## For the definition of Wall forms, see [Tay92, page 163].
BindGlobal( "SpinorNorm", function( form, fld, m )
    local one;

    if Characteristic(fld) = 2 then
        Error("The characteristic of <fld> needs to be odd.");
    fi;

    one := OneOfBaseDomain(m);
    if IsOne(m) then return one; fi;

    if IsSquareFFE(fld, DeterminantMat( WallForm(form,m).form )) then
        return one;
    else
        return -1 * one;
    fi;
end );



#############################################################################
##
#F  WreathProductOfMatrixGroup( <M>, <P> )  . . . . . . . . .  wreath product
##
BindGlobal( "WreathProductOfMatrixGroup", function( M, P )
    local   m,  d,  f,  id,  gens,  b,  ran,  raN,  mat,  gen,  G;

    m := DimensionOfMatrixGroup( M );
    d := LargestMovedPoint( P );
    f := DefaultFieldOfMatrixGroup( M );
    id := IdentityMat( m * d, f );
    gens := [  ];
    for b  in [ 1 .. d ]  do
        ran := ( b - 1 ) * m + [ 1 .. m ];
        for mat  in GeneratorsOfGroup( M )  do
            gen := IdentityMat( m * d, f );
            gen{ ran }{ ran } := mat;
            Add( gens, gen );
        od;
    od;
    for gen  in GeneratorsOfGroup( P )  do
        mat := IdentityMat( m * d, f );
        for b  in [ 1 .. d ]  do
            ran := ( b - 1 ) * m + [ 1 .. m ];
            raN := ( b^gen - 1 ) * m + [ 1 .. m ];
            mat{ ran } := id{ raN };
        od;
        Add( gens, mat );
    od;
    G := GroupWithGenerators( gens );
    if HasName( M )  and  HasName( P )  then
        SetName( G, Concatenation( Name( M ), " wr ", Name( P ) ) );
    fi;
    return G;
end );


# Permutation constructors by using `IsomorphismPermGroup'
PermConstructor(GeneralLinearGroupCons,[IsPermGroup,IsInt,IsObject],
  IsMatrixGroup and IsFinite);
PermConstructor(GeneralOrthogonalGroupCons,[IsPermGroup,IsInt,IsInt,IsObject],
  IsMatrixGroup and IsFinite);
PermConstructor(GeneralUnitaryGroupCons,[IsPermGroup,IsInt,IsObject],
  IsMatrixGroup and IsFinite);

PermConstructor(SpecialLinearGroupCons,[IsPermGroup,IsInt,IsObject],
  IsMatrixGroup and IsFinite);
PermConstructor(SpecialOrthogonalGroupCons,[IsPermGroup,IsInt,IsInt,IsObject],
  IsMatrixGroup and IsFinite);
PermConstructor(SpecialUnitaryGroupCons,[IsPermGroup,IsInt,IsObject],
  IsMatrixGroup and IsFinite);

PermConstructor(SymplecticGroupCons,[IsPermGroup,IsInt,IsObject],
  IsMatrixGroup and IsFinite);

PermConstructor(OmegaCons,[IsPermGroup,IsInt,IsInt,IsObject],
  IsMatrixGroup and IsFinite);
