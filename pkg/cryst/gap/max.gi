#############################################################################
##
#A  max.gi                    Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Routines for the determination of maximal subgroups of CrystGroups
##

#############################################################################
##
#F  DepthVector( vec ) . . . . . . . . . . . . . . . . . . . . depth of vetor
##
#DepthVector := function( vec )
#    local i;
#    for i in [1..Length(vec)] do
#        if not vec[i] = 0 * vec[i] then
#            return i;
#        fi;
#    od;
#    return Length(vec) + 1;
#end;

#############################################################################
##
#F  CoefficientsMod( base, v ) . . . . . . . coefficients of v in factorspace
##
CoefficientsMod := function( base, v )

    local head, i, zero, coeff, w, j, h;

    if not IsBound( base.fullbase ) then
        base.fullbase := Concatenation( base.subspace, base.factorspace );
    fi;
    if not IsBound( base.depth ) then
        head := [];
        for i in [1..Length( base.fullbase )] do
            #head[i] := DepthVector( base.fullbase[i] );
            head[i] := PositionNonZero( base.fullbase[i] );
        od;
        base.depth := head;
    fi;

    zero  := base.fullbase[1] * Zero( base.field );
    coeff := ShallowCopy( zero );
    w     := v;
    while w <> zero do
        #j := DepthVector( w );
        j := PositionNonZero( w );
        h := Position( base.depth, j );
        coeff[h] := coeff[h] + w[j];
        w := w - w[j] * base.fullbase[h];
    od;
    return coeff{[Length(base.subspace)+1..Length(base.fullbase)]};
end;


#############################################################################
##
#F  InducedMatrix( base, mat ) . . . . . . . .  induced action of mat on base
##
InducedMatrix := function( base, mat )
    local ind, n, l, b, v, s;
    ind := [];
    n := Length(base.fullbase);
    l := Length(base.subspace); 
    for b in base.factorspace do
        v := b * mat;
        s := SolutionMat( base.fullbase, v );
        Add( ind, s{[l+1..n]} );
    od;
    return ind;
end;


#############################################################################
##
#F  TriangularizeMatVector  . . . . . . . . . . compute triangularized matrix
##
## This function computes the upper triangular form of the integer
## matrix M via elementary row operations and performs the same
## operations on the (column) vector b.
##
## The function works in place.
##
TriangularizeMatVector := function( M, b )
    local   zero,  c,  r,  i,  t;
    
    zero := M[1][1] * 0;
    
    c := 1; r := 1;
    while c <= Length(M[1]) and r <= Length(M) do
        i := r; while i <= Length(M) and M[i][c] = zero do i := i+1; od;

        if i <= Length(M) then
            t := b[r]; b[r] := b[i]; b[i] := t;
            t := M[r]; M[r] := M[i]; M[i] := t;

            b[r] := b[r] / M[r][c];
            M[r] := M[r] / M[r][c]; 

            for i in [1..r-1] do 
                b[i] := b[i] - b[r] * M[i][c];
                M[i] := ShallowCopy( M[i] );
                AddCoeffs( M[i], M[r], -M[i][c] );
            od;
            for i in [r+1..Length(M)] do
                b[i] := b[i] - b[r] * M[i][c];
                M[i] := ShallowCopy( M[i] );
                AddCoeffs( M[i], M[r], -M[i][c] );
            od;
            r := r+1;    
        fi;
        c := c+1;
    od;
    
    for i in Reversed( [r..Length(M)] ) do
        Unbind( M[i] );
    od;
end;


#############################################################################
##
#F  SolutionInhomEquations  . . .  solve an inhomogeneous system of equations
##
## This function computes the set of solutions of the equation
##
##                           X * M = b.
##
SolutionInhomEquations := function( M, b )
    local   zero,  one,  i,  c,  d,  r,  heads,  S,  v;
    
    zero := M[1][1] * 0;
    one  := M[1][1] ^ 0;
    
    M := MutableTransposedMat( M ); 
    d := Length(M[1]);
    b := ShallowCopy( b );
    
    TriangularizeMatVector( M, b );
    for i in [Length(M)+1..Length(b)] do
        if b[i] <> zero then return false; fi;
    od;

    # determine the null space
    c := 1; r := 1; heads := []; S := [];
    while r <= Length(M) and c <= d do
        
        while c <= d and M[r][c] = zero do 
            v := ShallowCopy( zero * [1..d] );
            v{heads} := M{[1..r-1]}[c];  v[c] := -one;
            Add( S, v );
            c := c+1;
        od;
        
        if c <= d then
            Add( heads, c ); c := c+1; r := r+1;
        fi;
    od;
    while c <= d do
        v := ShallowCopy( zero * [1..d] );
        v{heads} := M{[1..r-1]}[c];  v[c] := -one;
        Add( S, v );
        c := c+1;
    od;
    
    # one particular solution
    v := ShallowCopy( zero * [1..d] );
    v{heads} := b{[1..Length(M)]};
    if Length(S) > 0 then TriangulizeMat( S ); fi;
    return rec( basis := S, translation := v );
end;


#############################################################################
##
#F  SolutionHomEquations  . . . . . . solve a homogeneous system of equations
##
## This function computes the set of solutions of the equation
##
##                           X * M = 0.
##
SolutionHomEquations := function( M )
    return SolutionInhomEquations( M, Zero(Field(M[1][1]))*[1..Length(M[1])]);
end;


#############################################################################
##
#F  MatJacobianMatrix( G, mats )
##
MatJacobianMatrix := function( G, mats )
    local   gens, rels,
            J,  D,      # the result,  the one `column' of J
            imats,      # list of inverted matrices
            d,          # dimension of matrices
            j,  k,  l,  # loop variables
            r,          # run through the relators
            h, p;       # generator in r,  its position in G.generators
    
    
    gens := GeneratorsOfGroup( FreeGroupOfFpGroup( G ) );
    rels := RelatorsOfFpGroup( G );
    if Length(gens) = 0 then return []; fi;

    d := Length( mats[1] );
    imats := List( mats, m->m^-1 );
    
    J := List( [1..d*Length(gens)], k->[] );
    for j in [1..Length(rels)] do
        r := rels[j];
        D := NullMat( d*Length(gens), d );
    
        for k in [1..Length(r)] do
            h := Subword( r,k,k );
            p := Position( gens, h );
            if not IsBool( p ) then
                D := D * mats[p];
                for l in [1..d] do
                    D[(p-1)*d+l][l] := D[(p-1)*d+l][l] + 1;
                od;
            else
                p := Position( gens, h^-1 );
                for l in [1..d] do
                    D[(p-1)*d+l][l] := D[(p-1)*d+l][l] - 1;
                od;
                D := D * imats[p];
            fi;

            J{[1..Length(gens)*d]}{[(j-1)*d+1..j*d]} := D;
        od;
    od;
    return J;
end;


#############################################################################
##
#F  OneCoboundariesSG( <G>, <mats> )  . . . . . . . . . . . . . . B^1( G, M )
##
OneCoboundariesSG := function( G, mats )
    local   d,  I,  S,  i;
    
    d := Length( mats[1] );
    I := IdentityMat( d );
    
    if Length(mats) <> Length( GeneratorsOfGroup(G) ) then
        return Error( "As many matrices as generators expected" );
    fi;
    
    S := List( [1..d], i->[] );
    for i in [1..Length(mats)] do
        S{[1..d]}{[(i-1)*d+1..i*d]} := mats[i] - I;
    od;

    TriangulizeMat( S );

    return S;
end;


#############################################################################
##
#F  OneCocyclesVector( <G>, <mats>, <b> ) . . . . . . . . . . . . . . . . . . 
##
OneCocyclesVector := function( G, mats, b )
    local   J,  L;
    
    J := MatJacobianMatrix( G, mats );
    
    ##
    ##  b needs to be inverted for the following reason (I don't know how to
    ##  say this better without setting up a lot of notation.
    ##  
    ##  b was  computed by  CocycleInfo() by evaluating  the relators  of the
    ##  group.  In solving the system X * J = b we need to find all tuples of
    ##  elements  with the following  property: If  we modify  the generating
    ##  sequence with  such a tuple by  multiplying from the  rigth, then the
    ##  relators on the modified generators have to evaluate to the identity.
    ##  For example,  if we have the  relation [g2,g1] =  m, then [g2*y,g1*x]
    ##  should be  1.  Therefore, x  and y should  be chosen such  that after
    ##  collection  we have [g2,g1]  m^-1 =  m m^-1  = 1.   Hence we  need to
    ##  invert b.

    b := -Concatenation( b );

    L := SolutionInhomEquations( J, b );

    return L;
end;


#############################################################################
##
#F  OneCocyclesSG( <G>, <mats> )  . . . . . . . . . . . . . . . . Z^1( G, M )
##
OneCocyclesSG := function( G, mats )
    local   J,  L;
    
    J := MatJacobianMatrix( G, mats );
    L := SolutionHomEquations( J ).basis;
        
    return L;
end;


#############################################################################
##
#F  OneCohomology( <G>, <mats> )  . . . . . . . . . . . . . . . . H^1( G, M )
##
OneCohomologySG := function( G, mats )
    
    return rec( cocycles     := OneCocyclesSG( G, mats ),
                coboundaries := OneCoboundariesSG( G, mats ) );
    
end;


#############################################################################
##
#F  ListOneCohomology( <H> ) . . . . . . . . . . . . . . . . . . . . list H^1
##
##    Run through the triangularized basis of Z and find those head
##    entries which do not occur in the basis of B.  For each such
##    vector in the basis of Z we need to run through the coefficients
##    0..p-1. 
##
ListOneCohomology := function( H )
    local   Z,  B,  C,  zero,  coeffs,  h,  j,  i;
    
    Z := H.cocycles;
    B := H.coboundaries;
    if Length(Z) = 0 then return B; fi;
    
    C := AsSSortedList( Field( Z[1][1] ) );
    zero := Z[1][1]*0;
    
    coeffs := [];
    h := 1; j := 1;
    for i in [1..Length(Z)] do
        while Z[i][h] = zero do h := h+1; od;
        if j > Length(B) or B[j][h] = zero then
            coeffs[i] := C;
        else
            coeffs[i] := [ zero ];  j := j+1;
        fi;
    od;

    return List( Cartesian( coeffs ), t->t*Z );
end;


#############################################################################
##
#F  ComplementsSG . . . . . . . . . . . . compute complements up to conjugacy
##
ComplementsSG := function( G, mats, b )
    local   Z,  B,  C,  d,  n;
    
    if Length(GeneratorsOfGroup(G)) = 0 then return [ [] ]; fi;
    
    Z := OneCocyclesVector( G, mats, b );
    if Z = false then return []; fi;
    
    B := OneCoboundariesSG( G, mats );
    
    C := ListOneCohomology( 
                 rec( cocycles := Z.basis,
                      coboundaries := B ) );
    
    C := List( C, c->c + Z.translation );
    
    d := Length( mats[1] );
    n := Length(GeneratorsOfGroup(G));
    
    return List( C, c->List( [0..n-1], x->c{ [1..d] + x*d } ) );
end;


#############################################################################
##
#F  MaximalSubgroupRepsTG( < S > ) . .translationengleiche maximal subgroups
##
## This function computes conjugacy class representatives of the maximal 
## subgroups of $S$ which contain $T$. Note that this function may be
## slow, if $S$ is not solvable.
##
MaximalSubgroupRepsTG := function( S )

    local  d, P, N, T, Sgens, A, max, ind, l, i, gens, g, exp, h, j, 
           trans, sub; 

    d := DimensionOfMatrixGroup( S ) - 1;
    P := PointGroup( S );
    N := NiceObject( P );

    # catch a trivial case
    if Size( N ) = 1 then
        return [];
    fi;

    # compute the translation generators
    T     := TranslationBasis( S );
    trans := List( T, x -> IdentityMat( d+1 ) );
    for i in [1..Length(T)] do
        trans[i][d+1]{[1..d]} := T[i];
    od;

    # first the solvable case
    if IsSolvableGroup( N ) then

        A     := GroupByPcgs( Pcgs( N ) );
        Sgens := List( AsList( Pcgs( N ) ),
                       x -> ImagesRepresentative( NiceToCryst( P ), x ) );

        # compute maximal subgroups in ag group
        max := ShallowCopy( MaximalSubgroupClassReps( A ) );

        # compute preimages in space group and construct subgroups
        for i in [1..Length(max)] do

            gens := [];
            for g in GeneratorsOfGroup( max[i] ) do
                exp := ExponentsOfPcElement( Pcgs( A ), g );
                h := IdentityMat( d+1 );
                for j in [1..Length(exp)] do
                    h := h * Sgens[j]^exp[j];
                od;
                Add( gens, h );
            od;

            Append( gens, trans );
            sub := SubgroupNC( S, gens );
            AddTranslationBasis( sub, T );
            SetIndexInParent( sub, IndexInParent( max[i] ) );
            max[i] := sub;

        od;
        return max;

    fi;

    # now the non-solvable case
    max := List( ConjugacyClassesMaximalSubgroups( N ), Representative );
    ind := List( max, x -> Index( N, x ) );

    # go back to S, and construct the subgroups
    for i in [1..Length(max)] do 

        gens := List( GeneratorsOfGroup( max[i] ), 
                x -> ImagesRepresentative( NiceToCryst( P ), x ) );
        Append( gens, trans );
        sub  := SubgroupNC( S, gens ); 
        AddTranslationBasis( sub, T );
        SetIndexInParent( sub, ind[i] );
        max[i] := sub;

    od;
    return max;

end; 


#############################################################################
##
#F  CocycleInfo( <S> ) . . . . . . . . . . .information about extension type
##
CocycleInfo := function( S )
    local P, iso, F, d, gens, mats, coc, rel, new;

    P   := PointGroup( S );
    iso := IsomorphismFpGroup( P );
    F   := Image( iso );
    d   := DimensionOfMatrixGroup( S ) - 1;

    gens := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );
    mats := iso!.preimagesInAffineCrystGroup;

    coc := [];
    for rel in RelatorsOfFpGroup( F ) do
        new := MappedWord( rel, gens, mats );
        Add( coc, new[d+1]{[1..d]} );
    od;

    return coc;
end;


#############################################################################
##
#M  CocVecs( <S> ) . . Cocycles of extension of point group with translations
##
InstallMethod( CocVecs, true, [ IsAffineCrystGroupOnRight ], 0,
function( S )
    return ReducedLatticeBasis( CocycleInfo( S ) );
end );

InstallMethod( CocVecs, true, [ IsAffineCrystGroupOnLeft ], 0,
function( S )
    return CocVecs( TransposedMatrixGroup( S ) );
end );


#############################################################################
##
#F  SimpleGenerators( d, gens ) . . . . . . . . . . . simplify the generators 
##
SimpleGenerators := function( d, gens )

    local I, new, g, trans, t, m;

    I     := IdentityMat( d );
    new   := [];
    trans := [];
    for g in gens do
        if g{[1..d]}{[1..d]} = I then
            Add( trans, g[d+1]{[1..d]} );
        else
            Add( new, g );
        fi;
    od;
    trans := ReducedLatticeBasis( trans );

    # add the new translation generators
    for t in trans do
        m := IdentityMat( d+1 );
        m[d+1]{[1..d]} := t;
        Add( new, m );
    od;
    return [ new, trans ];

end; 


#############################################################################
##
#F  MaximalSubgroupRepsKG( < G >, <ps> ) . .klassengleiche maximal subgroups
##
## This function computes represenatives of the conjugacy classes of maximal
## subgroups of $G$ which have $p$-power index for some $p$ in the list $ps$
## and do not contain $T$. 
## In the case that $G$ is solvable it is more efficient to use the function
## 'MaximalSubgroupSG' and filter the corresponding maximal subgroups.
##
MaximalSubgroupRepsKG := function( G, primes )

    local P, iso, pres, coc, rep, d, n, maximals, p, field, 
          repp, cocp, mods, sub, F, hom, cocin, repin, comp, c, modu,
          modgens, powers, vec, elm, basis, cocpre, gens, i, j, h,
          base, primeslist, Ggens, T, trans;

    # check argument
    if IsInt( primes ) then
        primeslist := [primes];
    else
        primeslist := primes;
    fi;

    T := TranslationBasis( G );
    n := Length( T );

    # extract the point group
    P     := PointGroup( G );
    iso   := IsomorphismFpGroup( P );
    Ggens := iso!.preimagesInAffineCrystGroup;
    if not IsStandardAffineCrystGroup( G ) then
        Ggens  := List ( Ggens, x -> G!.lconj * x * G!.rconj );
    fi;

    pres  := Image( iso );
    rep   := List( Ggens, x -> x{[1..n]}{[1..n]} );
    coc   := CocycleInfo( G ) * T^-1;
    d     := DimensionOfMatrixGroup( G ) - 1;
    trans := List( T, x -> IdentityMat( d+1 ) );
    for i in [1..n] do
        trans[i][d+1][i] := 1;
    od; 

    # view them as matrices over GF(p)
    maximals := [];
    for p in primeslist do
        field := GF(p);
        repp  := List( rep, x -> x * One( field ) );
        cocp  := List( coc, x -> x * One( field ) );
        modu  := GModuleByMats( repp, d, field );
        mods  := MTX.BasesMaximalSubmodules( modu );
        powers:= List( trans, x -> x^p );

        # compute induced operation on T/maxmod and induced cocycle
        for sub in mods do

            # compute group of translations of maximal subgroup
            modgens := [];
            for vec in sub do
                elm := One( G );
                for j in [1..Length( vec )] do
                    elm := elm * trans[j]^IntFFE(vec[j]);
                od;
                Add( modgens, elm );
            od;
            Append( modgens, powers );

            # compute quotient space
            base  := BaseSteinitzVectors( IdentityMat( n, field ), sub );
            TriangulizeMat(base.factorspace);
            base.field := field;
            cocin := List( cocp, x -> CoefficientsMod( base, x ) );
            repin := List( repp, x -> InducedMatrix( base, x ) );

            # use complement routine
            comp := ComplementsSG( pres, repin, cocin );

            # compute generators of G corresponding to complements
            for i in [1..Length( comp )] do
                cocpre := List( comp[i], x -> x * base.factorspace );
                gens := [];
                for j in [1..Length( cocpre )] do
                    elm := Ggens[j];
                    for h in [1..Length( cocpre[j] )] do
                        elm := elm*trans[h]^IntFFE(cocpre[j][h]);
                    od;
                    Add( gens, elm );     
                od;
        
                # append generators of group of translations 
                Append( gens, modgens );

                # conjugate generators if necessary
                if not IsStandardAffineCrystGroup( G ) then
                    for j in [1..Length(gens)] do
                        gens[j] := G!.rconj * gens[j] * G!.lconj;
                    od;
                fi;

                # construct subgroup and append index
                gens := SimpleGenerators( d, gens );
                comp[i] := SubgroupNC( G, gens[1] );
                AddTranslationBasis( comp[i], gens[2] );
                SetIndexInParent( comp[i], p^(n - Length( sub ) ) );
            od;
            Append( maximals, comp );
        od;
    od;
    return maximals;
end;


#############################################################################
##
#F  MaximalSubgroupRepsSG( <G>, <p> ) . . .maximal subgroups of solvable <G>
##
## This function computes representatives of the conjugacy classes of the 
## maximal subgroups of $p$-power index in $G$ in the case that $G$ is 
## solvable.
##
MaximalSubgroupRepsSG := function( G, p )

    local iso, F, Fgens, Frels, Ffree, Ggens, T, n, d, t, gens, A, kernel, 
          i, imgs, max, M, g, exp, h, j, pcgs, first, weights;

    if not IsSolvableGroup( G ) then
        Error("G must be solvable \n");
    fi;

    iso   := IsomorphismFpGroup( PointGroup( G ) );
    Ggens := iso!.preimagesInAffineCrystGroup;
    if not IsStandardAffineCrystGroup( G ) then
        Ggens  := List ( Ggens, x -> G!.lconj * x * G!.rconj );
    fi;

    F     := Image( IsomorphismFpGroup( G ) );
    Frels := RelatorsOfFpGroup( F );
    Ffree := FreeGroupOfFpGroup( F );
    Fgens := GeneratorsOfGroup( Ffree );

    T := TranslationBasis( G );
    n := Length( Ggens );
    d := DimensionOfMatrixGroup( G ) - 1;
    t := Length( T );

    gens := List( [n+1..n+t], x -> Fgens[x]^p );
    F := Ffree / Concatenation( Frels, gens );
    A := PcGroupFpGroup( F );

    # compute maximal subgroups of S
    pcgs := SpecialPcgs(A);
    first := LGFirst( pcgs );
    weights := LGWeights( pcgs );
    max := [];
    for i in [1..Length(first)-1] do
        if weights[first[i]][2] = 1 and weights[first[i]][3] = p then
            Append(max,ShallowCopy(MaximalSubgroupClassesRepsLayer(pcgs,i)));
        fi;
    od;

    # compute generators of kernel G -> A and preimages
    kernel := List( [1..t], x -> IdentityMat( d+1 ) );
    for i in [1..t] do
        kernel[i][d+1][i] := 1;
    od;
    imgs := Concatenation( Ggens, List( kernel, m -> MutableMatrix( m ) ) ); 
    for i in [1..t] do
        kernel[i][d+1][i] := p;
    od;
    
    # compute corresponding subgroups in G
    for i in [1..Length(max)] do

        M := max[i];
        gens := [];
        for g in GeneratorsOfGroup( M ) do
            exp := ExponentsOfPcElement( Pcgs(A), g );
            h := Product( List( [1..Length(exp)], x -> imgs[x]^exp[x] ) );
            Add( gens, h );
        od;
        Append( gens, kernel );

        if not IsStandardAffineCrystGroup( G ) then
            for j in [1..Length(gens)] do
                gens[j] := G!.rconj * gens[j] * G!.lconj;
            od;
        fi;
        gens := SimpleGenerators( d, gens );
        M := SubgroupNC( G, gens[1] );
        AddTranslationBasis( M, gens[2] );

        SetIndexInParent( M, Index( A, max[i] ) );
        max[i] := M;

    od;
    return max;
end;

#############################################################################
##
#M  MaximalSubgroupClassReps( S, flags )
##
InstallOtherMethod( MaximalSubgroupClassReps,
    "for AffineCrystGroupOnRight", 
    true, [ IsAffineCrystGroupOnRight, IsRecord ], 0,
function( S, flags )

    local reps, new, M, i;

    if IsBound( flags.primes ) then 
        if not IsList( flags.primes ) or
           not ForAll( flags.primes, IsPrimeInt ) then
            Error("flags.primes must be a list of primes");                   
        fi;
    fi; 

    # the lattice-equal case
    if IsBound( flags.latticeequal ) and flags.latticeequal=true then
        if IsBound( flags.classequal ) and flags.classequal=true then
            Error("both classequal and latticeequal is impossible!");
        fi;
        reps := MaximalSubgroupRepsTG( S );
        if IsBound( flags.primes ) then
            new  := [];
            for M in reps do
                i := Index( S, M );
                if IsPrimePowerInt( i ) and
                   FactorsInt(i)[1] in flags.primes then
                    Add( new, M );
                fi;
            od;
            return new;
        fi;
        return reps;
    fi;

    # the class-equal case
    if IsBound( flags.classequal ) and flags.classequal=true then
        if not IsBound( flags.primes ) then
            Error("flags.primes must be bound");
        fi;
        return MaximalSubgroupRepsKG( S, flags.primes );
    fi;

    # the p-index case
    if IsBound( flags.primes ) then
        if IsSolvableGroup( S ) then
            return Concatenation( List( flags.primes, 
                   x -> MaximalSubgroupRepsSG( S, x ) ) );
        else
            reps := MaximalSubgroupRepsTG( S );
            new  := [];
            for M in reps do
                i := Index( S, M );
                if IsPrimePowerInt( i ) and
                   FactorsInt(i)[1] in flags.primes then
                    Add( new, M );
                fi;
            od;
            Append( new, MaximalSubgroupRepsKG( S, flags.primes ) );
            return new;
        fi;
    fi;
    Error("inconsistent input - check manual");
end );

InstallOtherMethod( MaximalSubgroupClassReps,
    "for AffineCrystGroupOnLeft", 
    true, [ IsAffineCrystGroupOnLeft, IsRecord ], 0,
function( S, flags )
    local G, reps, lst, max, gen, new;
    G := TransposedMatrixGroup( S );
    reps := MaximalSubgroupClassReps( G, flags );
    lst := [];
    for max in reps do
        gen := List( GeneratorsOfGroup( max ), TransposedMat );
        new := SubgroupNC( S, gen ); 
        if HasTranslationBasis( max ) then
            AddTranslationBasis( new, TranslationBasis( max ) );
        fi;
        if HasIndexInParent( max ) then
            SetIndexInParent( new, IndexInParent( max ) );
        fi;
        Add( lst, new );
    od;
    return lst;
end );

#############################################################################
##
#M  ConjugacyClassesMaximalSubgroups( S, flags )
##
InstallOtherMethod( ConjugacyClassesMaximalSubgroups, "forAffineCrystGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight, IsRecord ], 0,
function( S, flags )
    local reps, cls, M, c;
    reps := MaximalSubgroupClassReps( S, flags );
    cls := [];
    for M in reps do
        c := ConjugacyClassSubgroups( S, M );
        if not IsNormal( S, M ) then
            SetSize( c, IndexInParent( M ) );
        else
            SetSize( c, 1 );
        fi;
        Add( cls, c );
    od;
    return cls; 
end );
