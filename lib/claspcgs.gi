#############################################################################
##
#W  claspcgs.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
##  This file contains functions that  deal with conjugacy topics in solvable
##  groups using affine  methods.   These  topics includes   calculating  the
##  (rational)   conjugacy classes and centralizers   in solvable groups. The
##  functions   rely only on   the existence of pcgs,  not  on the particular
##  representation of the groups.
##
Revision.claspcgs_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  SubspaceVectorSpaceGroup( <N>, <p>, <gens> )  . complement and projection
##
##  This function creates a record  containing information about a complement
##  in <N> to the span of <gens>.
##
SubspaceVectorSpaceGroup := function( N, p, gens )
    local   zero,  one,  r,  ran,  n,  nan,  cg,  pos,  Q,  i,  j,  v;
    
    one := One( GF( p ) );  zero := 0 * one;
    r := Length( N );       ran := [ 1 .. r ];
    n := Length( gens );    nan := [ 1 .. n ];
    Q := [  ];
    if n <> 0  and  IsMultiplicativeElementWithInverse( gens[ 1 ] )  then
        Q := List( gens, gen -> ExponentsOfPcElement( N, gen ) ) * one;
    else
        Q := ShallowCopy( gens );
    fi;
    
    cg := rec( matrix         := [  ],
               needed         := [  ],
               baseComplement := ShallowCopy( ran ),
               projection     := DeepCopy( IdentityMat( r, one ) ),
               commutator     := 0,
               centralizer    := 0,
               dimensionN     := r,
               dimensionC     := n );
    if n = 0  or  r = 0  then
        cg.inverse := NullMapMatrix;
        return cg;
    fi;
    
    for i  in nan  do
        cg.matrix[ i ] := Concatenation( Q[ i ], zero * nan );
        cg.matrix[ i ][ r + i ] := one;
    od;
    TriangulizeMat( cg.matrix );
    pos := 1;
    for v  in cg.matrix  do
        while v[ pos ] = zero  do
            pos := pos + 1;
        od;
        RemoveSet( cg.baseComplement, pos );
        if pos <= r  then  cg.commutator  := cg.commutator  + 1;
                     else  cg.centralizer := cg.centralizer + 1;  fi;
    od;

    # Find a right pseudo inverse for <Q>.
    Append( Q, cg.projection );
    Q := MutableTransposedMat( Q );
    TriangulizeMat( Q );
    Q := TransposedMat( Q );
    i := 1;
    j := 1;
    while i <= Length( N )  do
        while j <= Length( gens ) and Q[ j ][ i ] = zero  do
            j := j + 1;
        od;
        if j <= Length( gens ) and Q[ j ][ i ] <> zero  then
            cg.needed[ i ] := j;
        else

            # If <Q> does  not  have full rank, terminate when the bottom row
            # is reached.
            i := Length( N );

        fi;
        i := i + 1; 
    od;
    
    if IsEmpty( cg.needed )  then
        cg.inverse := NullMapMatrix;
    else
        cg.inverse := Q{ Length( gens ) + ran }
                       { [ 1 .. Length( cg.needed ) ] };
    fi;
    if IsEmpty( cg.baseComplement )  then
        cg.projection := NullMapMatrix;
    else

        # Find a base change matrix for the projection onto the complement.
        for i  in [ 1 .. cg.commutator ]  do
            cg.projection[ i ][ i ] := zero;
        od;
        Q := [  ];
        for i  in [ 1 .. cg.commutator ]  do
            Q[ i ] := cg.matrix[ i ]{ ran };
        od;
        for i  in [ cg.commutator + 1 .. r ]  do
            Q[ i ] := ShallowCopy( 0 * cg.projection[ 1 ] );
            Q[ i ][ cg.baseComplement[ i-r+Length(cg.baseComplement) ] ]
              := one;
        od;
        cg.projection := cg.projection ^ Q;
        cg.projection := cg.projection{ ran }{ cg.baseComplement };
        
    fi;
    
    return cg;
end;

#############################################################################
##
#F  CentralStepConjugatingElement( ... )  . . . . . . . . . . . . . . . local
##
##  This function returns an element of <G> conjugating <hk1> to <hk2>^<l>.
##
CentralStepConjugatingElement := function( N, h, k1, k2, l, cN )
    local   v,  conj;
    
    v := ExponentsOfPcElement( N, h ^ -l * h ^ cN * k1 * k2 ^ -l );
    conj := WordVector( N!.CmodK{ N!.subspace.needed },
                    OneOfPcgs( N ), v * N!.subspace.inverse );
    conj := LeftQuotient( conj, cN );
    return conj;
end;

#############################################################################
##
#F  KernelHcommaC( <N>, <h>, <C> )  . . . . . . . . . . . . . . . . . . local
##
##  Given a homomorphism C -> N, c |-> [h,c],  this function determines (a) a
##  vector space decomposition N =  [h,C] + K with  projection onto K and (b)
##  the  ``kernel'' S <  C which plays   the role of  C_G(h)  in lemma 3.1 of
##  [Mecky, Neub\"user, Bull. Aust. Math. Soc. 40].
##
KernelHcommaC := function( N, h, C )
    local   i,  tmp,  v;
    
    N!.subspace := SubspaceVectorSpaceGroup( N, RelativeOrders( N )[ 1 ],
                           List( C, c -> Comm( h, c ) ) );
    tmp := [  ];
    for i  in [ N!.subspace.commutator + 1 .. 
                N!.subspace.commutator + N!.subspace.centralizer ]  do
        v := N!.subspace.matrix[ i ];
        tmp[ i - N!.subspace.commutator ] := PcElementByExponents( C,
                 v{ [ N!.subspace.dimensionN + 1 ..
                      N!.subspace.dimensionN + N!.subspace.dimensionC ] } );
    od;
    return tmp;
end;

#############################################################################
##
#F  GroupByPrimeResidues( <gens>, <oh> )  . . . . . . . . . . . . . . . local
##
GroupByPrimeResidues := function( gens, oh )
    local   perms,  gen;
    
    perms := [  ];
    for gen  in gens  do
        if gen mod oh <> 1  then
            Add( perms, PermResidueClass( gen, oh ) );
        fi;
    od;
    return SubgroupNC( PrimeResidueClassGroup( oh ), perms );
end;

#############################################################################
##
#F  OrderModK( <h>, <mK> )  . . . . . . . . . .  order modulo normal subgroup
##
OrderModK := function( h, mK )
    local   ord,  d,  o;
    
    ord := 1;
    d := DepthOfPcElement( mK, h );
    while d <= Length( mK )  do
        o := RelativeOrders( mK )[ d ];
        h := h ^ o;
        ord := ord * o;
        d := DepthOfPcElement( mK, h, d + 1 );
    od;
    return ord;
end;
    
#############################################################################
##
#F  CentralStepRatClPGroup( <G>, <N>, <mK>, <mL>, <cl> )  . . . . . . . local
##
CentralStepRatClPGroup := function( G, N, mK, mL, cl )
    local  h,           # preimage of `Representative( <cl> )' under <hom>
           candexps,    # list of exponent vectors for <h> mod <candidates>
           classes,     # the resulting list of classes
           ohN,  oh,    # order of <h> in `Range(<hom>)' resp. `Source(<hom>)'
           p,           # exponent of <N>
           K,           # a complement to $[h,C]$ in <N>
           Gal,  gal,   # Galois group for element in `Source(<hom>)'
           preimage,    # preimage of $Gal(hN)$ in $Z_oh^*$
           operator,    # generator of <preimage> acting by conjugation
           reps, conj,  #\ representatives, conjugating elements,
           exps, lens,  #/ exponents and orbit lengths in orbit algorithm
           pos, here,   # first point in current orbit, which candidates?
           trans,       # transversal for the current orbit
           Q,  v,       # subspace to be projected onto, projection vectors
           k,           # orbit representative in <N>
           gens,  oprs, # generators and operators for new Galois group
           type,        # the type of the Galois group as subgroup of Z_2^r^*
           i, j, l, c,  # loop variables
           C,  cyc,  xset,  opr,  orb;
    
    p   := RelativeOrders( N )[ 1 ];
    h   := Representative( cl );
    ohN := OrderModK( h, mK );
    oh  := OrderModK( h, mL );
    Gal := PrimeResidueClassGroup( oh );
    
    classes := [  ];
    if oh = 1  then

        # Special case: <h> is trivial.
        gal := GroupByPrimeResidues( [  ], p );
        gal!.type := 3;
        gal!.operators := [  ];
        
        if IsBound( cl!.candidates )  then
            for c  in cl!.candidates  do
                l := LeadingExponentOfPcElement( N, c );
                if l = fail  then
                    l := 1;
                    c := RationalClass( G, c );
                    SetGaloisGroup( c, TrivialSubgroup( Gal ) );
                    GaloisGroup( c )!.type := 3;
                    GaloisGroup( c )!.operators := [  ];
                else
                    c := RationalClass( G, c ^ ( 1 / l mod p ) );
                    SetGaloisGroup( c, gal );
                fi;
                SetStabilizerOfExternalSet( c, G );
                c!.operator := OneOfPcgs( N );
                c!.exponent := l;
                Add( classes, c );
            od;
        else
            c := RationalClass( G, One( G ) );
            SetStabilizerOfExternalSet( c, G );
            SetGaloisGroup( c, TrivialSubgroup( Gal ) );
            GaloisGroup( c )!.type := 3;
            GaloisGroup( c )!.operators := [  ];
            Add( classes, c );
            for v  in ProjectiveSpace( GF( p ) ^ Length( N ) )  do
                c := RationalClass( G, PcElementByExponents( N, v ) );
                SetStabilizerOfExternalSet( c, G );
                SetGaloisGroup( c, gal );
                Add( classes, c );
            od;
        fi;

    else
        if IsBound( cl!.kernel )  then
            N := cl!.kernel;
        else
            N!.CmodK := Pcgs( StabilizerOfExternalSet( cl ) ) mod
                        DenominatorOfModuloPcgs( N );
            N!.CmodL := ExtendedPcgs( DenominatorOfModuloPcgs( N ),
                                KernelHcommaC( N, h, N!.CmodK ) );
        fi;
        if IsBound( cl!.candidates )  then
            cl!.candidates := List( cl!.candidates, c ->
                LeftQuotient( h, c ) );
            candexps := List( cl!.candidates, c ->
                ExponentsOfPcElement( N, c ) ) * N!.subspace.projection;
        fi;
    
        # If <p> = 2, use a projection operation.
        if p = 2  then
            
            # Construct the preimage of $Gal(hN)$ in $Z_oh^*$.
            if ohN <= 2  then
                preimage := GroupByPrimeResidues( [ -1, 5 ], oh );
                preimage!.type := 1;
                preimage!.operators := List( GeneratorsOfGroup( preimage ),
                                            i -> One( G ) );
            else
                if   GaloisGroup( cl )!.type = 1  then
                    preimage := [ -1, 5^(ohN/(2*Size(GaloisGroup( cl )))) ];
                elif GaloisGroup( cl )!.type = 2  then
                    preimage := [  -( 5^(ohN/(4*Size(GaloisGroup( cl ))))) ];
                else
                    preimage := [     5^(ohN/(4*Size(GaloisGroup( cl )))) ];
                fi;
                preimage := GroupByPrimeResidues( preimage, oh );
                preimage!.type := GaloisGroup( cl )!.type;
                if Length( GeneratorsOfGroup( preimage ) ) =
                   Length( GeneratorsOfGroup( GaloisGroup( cl ) ) )  then
                    preimage!.operators := GaloisGroup( cl )!.operators;
                else
                    preimage!.operators := Concatenation
                      ( GaloisGroup( cl )!.operators, [ One( G ) ] );
                fi;
            fi;
            
            # Construct the image of the homomorphism <preimage> -> <K>.
            Q := [  ];
            for i  in [ 1 .. Length( GeneratorsOfGroup( preimage ) ) ]  do
                Add( Q, ExponentsOfPcElement( N, LeftQuotient( h ^
                        ( 1 ^ GeneratorsOfGroup( preimage )[ i ] ),
                        h ^ preimage!.operators[ i ] ) ) );
            od;
            Q := Q * N!.subspace.projection;
            K := InducedPcgsByPcSequenceNC( N,
                         N{ N!.subspace.baseComplement } );
            K!.subspace := SubspaceVectorSpaceGroup( K, p, Q );
            
            # Project the factors in <N> onto a complement to <Q>.
            if IsBound( cl!.candidates )  then
                v := List( candexps, ShallowCopy );
                reps := v * K!.subspace.projection;
                exps := [  ];
                conj := [  ];
                if not IsEmpty( K!.subspace.baseComplement )  then
                    v{[1..Length(v)]}{K!.subspace.baseComplement} :=
                      v{[1..Length(v)]}{K!.subspace.baseComplement} + reps;
                fi;
                v := v * K!.subspace.inverse;
                for i  in [ 1 .. Length( reps ) ]  do
                    reps[ i ] := PcElementByExponents
                        ( K, K{ K!.subspace.baseComplement }, reps[ i ] );
                    exps[ i ] := WordVector( GeneratorsOfGroup( preimage )
                        { K!.subspace.needed }, One( preimage ), v[ i ] );
                    conj[ i ] := WordVector( preimage!.operators
                        { K!.subspace.needed }, One( G ), v[ i ] );
                od;
            
            # In the  construction case,  the complement  to <Q>  is a set of
            # representatives.
            else
                reps := EnumeratorByPcgs( K, K!.subspace.baseComplement );
            fi;
            
            # The kernel of the homomorphism into  <K> is the Galois group of
            # <h>.
            if IsTrivial( preimage )  then  # pre = < 1 >
                gens := GeneratorsOfGroup( preimage );
                oprs := preimage!.operators;
                type := preimage!.type;
            else
                if Q[ 1 ] = Zero( Q[ 1 ] )  then  i := 1;
                                            else  i := 2;  fi;
                if Length( GeneratorsOfGroup( preimage ) ) = 1  then
                    gens := [ GeneratorsOfGroup( preimage )[ 1 ] ^ i ];
                    oprs := [ preimage!.operators          [ 1 ] ^ i ];
                    if   preimage!.type = 1  then  type := 2 * i - 1; # <-1>
                    elif preimage!.type = 2  then  type := i + 1;
                                             else  type := 3;          fi;
                else
                    if Q[ 2 ] = Zero( Q[ 2 ] )  then  j := 1;
                                                else  j := 2;  fi;
                    if i = 1  then
                        gens := [ GeneratorsOfGroup( preimage )[ 1 ],
                                  GeneratorsOfGroup( preimage )[ 2 ] ^ j ];
                        oprs := [ preimage!.operators          [ 1 ],
                                  preimage!.operators          [ 2 ] ^ j ];
                        type := 1;
                    elif j = 2  and  Q[ 1 ] = Q[ 2 ]  then
                        gens := [ GeneratorsOfGroup( preimage )[ 1 ] *
                                  GeneratorsOfGroup( preimage )[ 2 ] ];
                        oprs := [ preimage!.operators          [ 1 ] *
                                  preimage!.operators          [ 2 ] ]; 
                        type := 2;
                    else
                        gens := [ GeneratorsOfGroup( preimage )[ 2 ] ^ j ];
                        oprs := [ preimage!.operators          [ 2 ] ^ j ];
                        type := 3;
                    fi;
                fi;
            fi;
            
        # If <p> <> 2, use an affine operation of a cyclic group generated by
        # <preimage>.
        else
            K := EnumeratorByPcgs( N, N!.subspace.baseComplement );
            preimage := PermResidueClass( PrimitiveRootMod( oh ), oh ) ^
                        IndexInParent( GaloisGroup( cl ) );
            if IsTrivial( GaloisGroup( cl ) )  then
                operator := One( G );
            else
                operator := GaloisGroup( cl )!.operators[ 1 ];
            fi;
            v := PcElementByExponents( N, N{ N!.subspace.baseComplement },
                 ExponentsOfPcElement( N, LeftQuotient( h ^ ( 1 ^ preimage ),
                         h ^ operator ) ) * N!.subspace.projection );
            cyc := GroupByGenerators( [ preimage ] );  Pcgs( cyc );
            opr := function( k, l )
                return ( v * k ) ^ ( 1 / 1 ^ l mod p );
            end;
            xset := ExternalSet( cyc, K, opr );
            
            reps := [  ];
            exps := [  ];
            if IsBound( cl!.candidates )  then
                conj := [  ];
                for c  in candexps  do
                    orb := ExternalOrbit( xset, PcElementByExponents( N,
                                   N{ N!.subspace.baseComplement }, c ) );
                    Add( reps, CanonicalRepresentativeOfExternalSet( orb ) );
                    i := Size( cyc ) / Order( OperatorOfExternalSet( orb ) );
                    Add( exps, preimage ^ i );
                    Add( conj, operator ^ i );
                od;
            else
                for orb  in ExternalOrbits( xset )  do
                    Add( reps, CanonicalRepresentativeOfExternalSet( orb ) );
                    Add( exps, preimage ^ Size( orb ) );
                od;
            fi;
            
        fi;
            
        # If <reps> is a set of  representatives of the orbits then <h><reps>
        # is a set of representatives of the rational classes in <hN>.
        for l  in [ 1 .. Length( reps ) ]  do
            k := reps[ l ];
            
            # Construct  the   Galois  group and find   conjugating  elements
            # corresponding to its generator(s).
            if p <> 2  then
                gens := [ exps[ l ] ];
                oprs := [ operator ^ ( 1 ^ exps[ l ] ) ];
            fi;
            gal := SubgroupNC( Gal, gens );
            if p = 2  then
                gal!.type := type;
            fi;
            gal!.operators := [  ];
            for i  in [ 1 .. Length( GeneratorsOfGroup( gal ) ) ]  do
                Add( gal!.operators, CentralStepConjugatingElement
                     ( N, h, k, k, 1 ^ GeneratorsOfGroup( gal )[ i ],
                       oprs[ i ] ) );
            od;
            
            c := RationalClass( G, h * k );
            C := SubgroupNC( G, N!.CmodL );
            SetPcgs( C, N!.CmodL );
            SetStabilizerOfExternalSet( c, C );
            SetGaloisGroup( c, gal );
            if IsBound( cl!.candidates )  then
                
                # cl!.candidates[l] ^ c!.operator =
                # Representative(c) ^ c!.exponent
                c!.exponent := 1 ^ exps[ l ];
                c!.operator := CentralStepConjugatingElement
                    ( N, h, cl!.candidates[ l ], k, c!.exponent, conj[ l ] );
                
                if IsBound( cl!.kernel )  then
                    c!.kernel := N;
                fi;
            fi;
            Add( classes, c );
        od;
        
    fi;
    return classes;
end;

#############################################################################
##
#F  CentralStepClEANS( <H>, <U>, <N>, <cl> )  . . . . . . . . . . . . . local
##
CentralStepClEANS := function( H, U, N, cl )
    local  classes,    # classes to be constructed, the result
           field,      # field over which <N> is a vector space
           h,          # preimage `Representative( cl )' under <hom>
           C,  gens,   # preimage `Centralizer( cl )' under <hom>
           exp,  w,    # coefficient vectors for projection along $[h,N]$
           c;          # loop variable
    
    field := GF( RelativeOrders( N )[ 1 ] );
    h := Representative( cl );
    N!.CmodK := Pcgs( StabilizerOfExternalSet( cl ) ) mod
                DenominatorOfModuloPcgs( N!.capH );
    N!.CmodL := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
                        KernelHcommaC( N, h, N!.CmodK ) );
    C := SubgroupNC( H, N!.CmodL );
    SetPcgs( C, N!.CmodL );
    
    classes := [  ];
    if IsBound( cl!.candidates )  then
        gens := N!.CmodK{ N!.subspace.needed };
        if IsIdentical( FamilyObj( U ), FamilyObj( cl!.candidates ) )  then
            for c  in cl!.candidates  do
                exp := ExponentsOfPcElement( N, LeftQuotient( h, c ) )
                       * One( field );
                w := exp * N!.subspace.projection;
                exp{ N!.subspace.baseComplement } :=
                  w - exp{ N!.subspace.baseComplement };
                c := ConjugacyClass( U, h * PcElementByExponents
                             ( N, N{ N!.subspace.baseComplement }, w ) );
                SetStabilizerOfExternalSet( c, C );
                c!.operator := WordVector( gens,
                                       One( StabilizerOfExternalSet( cl ) ),
                                       exp * N!.subspace.inverse );
                Add( classes, c );
            od;
        else
            c := ConjugacyClass( U, cl!.candidates );
            SetStabilizerOfExternalSet( c, C );
            c!.operator := One( H );
            Add( classes, c );
        fi;
        
    else
        gens := N{ N!.subspace.baseComplement };
        for w  in field ^ Length( gens )  do
            c := ConjugacyClass( U, h * PcElementByExponents( N, gens, w ) );
            SetStabilizerOfExternalSet( c, C );
            Add( classes, c );
        od;
    fi;
    return classes;
end;

#############################################################################
##
#F  CorrectConjugacyClass( <orb>, <H>, <U>, <h>, <n>, <N>, <cNh> )   cf. MN89
##
CorrectConjugacyClass := function( orb, H, U, h, n, N, cNh )
    local   cl,  stab,  comm,  s,  C;
    
    stab := ShallowCopy( Pcgs( StabilizerOfExternalSet( orb ) ) );
    comm := [  ];
    for s  in [ 1 .. Length( stab ) ]  do
        comm[ s ] := ExponentsOfPcElement( N,
            Comm( n, stab[ s ] ) * Comm( h, stab[ s ] ) );
    od;
    comm := comm * N!.subspace.inverse;
    for s  in [ 1 .. Length( comm ) ]  do
        stab[ s ] := stab[ s ] / PcElementByExponents
          ( N!.capH, N!.capH{ N!.subspace.needed }, comm[ s ] );
    od;
    cl := ConjugacyClass( U, h * n );
    stab := ExtendedPcgs( cNh, stab );
    C := SubgroupNC( H, stab );
    SetPcgs( C, stab );
    SetStabilizerOfExternalSet( cl, C );
    return cl;
end;

#############################################################################
##
#F  GeneralStepClEANS( <H>, <U>, <N>, <cl> )  . . . . . . . . . . . . . local
##
GeneralStepClEANS := function( H, U, N, cl )
    local  classes,    # classes to be constructed, the result
           field,      # field over which <N> is a vector space
           h,          # preimage `Representative( cl )' under <hom>
           cNh,        # centralizer of <h> in <N>
           C,  gens,   # preimage `Centralizer( cl )' under <hom>
           r,          # dimension of <N>
           ran,        # constant range `[ 1 .. r ]'
           aff,        # <N> as affine space
           xset,       # affine operation of <C> on <aff>
           imgs,  M,   # generating matrices for affine operation
           orbs,  orb, # orbits of affine operation
           Rep,        # representative function to use for <orb>
           n,  k,      # cf. Mecky--Neub\"user paper
           cls,rep,pos,# set of classes with canonical representatives
           c,  ca,  i; # loop variables
           
    C := StabilizerOfExternalSet( cl );
    field := GF( RelativeOrders( N )[ 1 ] );
    h := Representative( cl );
    
    # Determine the subspace $[h,N]$ and calculate the centralizer of <h>.
    cNh := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
                   KernelHcommaC( N, h, N!.capH ) );
    r := Length( N!.subspace.baseComplement );
    ran := [ 1 .. r ];
    
    # Construct matrices for the affine operation on $N/[h,N]$.
    aff := AffineSpace( field ^ r );
    gens := Pcgs( C );
    imgs := [  ];
    for c  in gens  do
        if c in GroupOfPcgs( NumeratorOfModuloPcgs( N ) )  then
            M := IdentityMat( r + 1, field );
        else
            M := [  ];
            for i  in [ 1 .. r ]  do
                M[ i ] := Concatenation( ExponentsOfPcElement( N,
                     N[ N!.subspace.baseComplement[ i ] ] ^ c )
                     * N!.subspace.projection, [ Zero( field ) ] );
            od;
            M[ r + 1 ] := Concatenation( ExponentsOfPcElement
                                  ( N, Comm( h, c ) ) * N!.subspace.projection,
                                  [ One( field ) ] );
        fi;
        Add( imgs, M );
    od;
    xset := ExternalSet( C, aff, gens, imgs );

    classes := [  ];
    if IsBound( cl!.candidates )  then
        if IsIdentical( FamilyObj( U ), FamilyObj( cl!.candidates ) )  then
            Rep := CanonicalRepresentativeOfExternalSet;
        else
            cl!.candidates := [ cl!.candidates ];
            Rep := Representative;
        fi;
        cls := [  ];
        for ca  in cl!.candidates  do
            n := ExponentsOfPcElement( N, LeftQuotient( h, ca ) ) *
                 One( field );
            k := n * N!.subspace.projection;
            orb := ExternalOrbit( xset, Concatenation( k, [ One( field ) ] ) );
            rep := PcElementByExponents( N, N{ N!.subspace.baseComplement },
                      Rep( orb ){ ran } );
            pos := Position( cls, rep );
            if pos = fail  then
                Add( cls, rep );
                c := CorrectConjugacyClass( orb, H, U, h, rep, N, cNh );
            else
                c := ConjugacyClass( U, h * rep );
                SetStabilizerOfExternalSet( c,
                        StabilizerOfExternalSet( classes[ pos ] ) );
            fi;
            n := ShallowCopy( -n );
            n{ N!.subspace.baseComplement } :=
              k + n{ N!.subspace.baseComplement };
            c!.operator := PcElementByExponents( N, N{ N!.subspace.needed },
                                   n * N!.subspace.inverse );
            if IsIdentical( Rep, CanonicalRepresentativeOfExternalSet )  then
                c!.operator := c!.operator * OperatorOfExternalSet( orb );
                k := PcElementByExponents( N, N{ N!.subspace.needed },
                     ExponentsOfPcElement( N, LeftQuotient
                             ( Representative( c ), ca ^ c!.operator ) ) *
                             N!.subspace.inverse );
                c!.operator := c!.operator / k;
                SetStabilizerOfExternalSet( c, ConjugateSubgroup
                        ( StabilizerOfExternalSet( c ),
                          OperatorOfExternalSet( orb ) * k ) );
            fi;
            Add( classes, c );
        od;
        
    else
        orbs := ExternalOrbits( xset );
        for orb  in orbs  do
            rep := PcElementByExponents( N, N{ N!.subspace.baseComplement },
                       CanonicalRepresentativeOfExternalSet( orb ){ ran } );
            c := CorrectConjugacyClass( orb, H, U, h, rep, N, cNh );
            Add( classes, c );
        od;
    fi;
    return classes;
end;
    
#############################################################################
##
#F  ClassesSolvableGroup( <H>, <U>, <limit>, <mode>, <cands> )  cool function
##
ClassesSolvableGroup := function( arg )
    local  G,  home,    # the supergroup (of <H> and <U>), the home pcgs
           U,           # group in which to find the <H>-classes
           H,  Hp,      # group operating on <U>, a pcgs for <H>
           limit,       # limit on order of representatives
           mode,        # LSB: ratCl | power | test :MSB
           candidates,  # candidates to be replaced by their canonical reps.
           eas, step,   # elementary abelian series in <G> through <U>
           K,    L,     # members of <eas>
           Kp,mK,Lp,mL, # induced and modulo pcgs's
           KcapH,LcapH, # pcgs's of intersections with <H>
           N,   cent,   # elementary abelian factor, for affine action
           cls, newcls, # classes in range/source of homomorphism
           tra, exp,    # transversal and exponents for candidates
           team,        # team of candidates with same image under homomorphism
           blist,pos,q, # these control grouping of <cls> into <team>s
           p,           # prime dividing $|G|$
           ord,         # order of a rational class modulo <modL>
           new, power,  # auxiliary variables for determination of power tree
           cl,  c,  i;  # loop variables
    
    # Get the arguments.
    H     := arg[ 1 ];
    U     := arg[ 2 ];
    limit := arg[ 3 ];
    mode  := arg[ 4 ];
    if limit = true  then
        limit := rec( order := infinity,
                       size := 0 );
    fi;
    if H = U  then  G := H;
              else  G := ClosureGroup( H, U );  fi;
    home := HomePcgs( G );
    Hp := InducedPcgsByGenerators( home, GeneratorsOfGroup( H ) );
    if Length( arg ) = 5  then  candidates := arg[ 5 ];
                          else  candidates := false;     fi;
    
    # Treat the trivial case.
    if IsTrivial( G )  then
        if mode = 4  then  # test conjugacy of two elements
            return One( U );
        elif mode mod 2 = 1  then  # rational classes
            cl := RationalClass( G, One( G ) );
            SetStabilizerOfExternalSet( cl, G );
            SetGaloisGroup( cl, GroupByPrimeResidues( [  ], 1 ) );
            GaloisGroup( cl )!.type := 3;
            GaloisGroup( cl )!.operators := [  ];
            if mode mod 4 = 3  then  # construct the power tree
                cl!.power           := RationalClass( G, One( G ) );
                cl!.power!.operator := One( G );
                cl!.power!.exponent := 1;
            fi;
        else
            cl := ConjugacyClass( H, One( H ) );
            SetStabilizerOfExternalSet( cl, H );
        fi;
        cl!.isCentral := true;
        if IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
            cls := List( candidates, c -> cl );
        else
            cls := [ cl ];
        fi;
        return cls;
    fi;
    
    # Calculate a (central) elementary abelian series.
    if IsPrimePowerInt( Size( G ) )  then
        p := FactorsInt( Size( G ) )[ 1 ];
        eas := PCentralSeries( G, p );
        cent := ReturnTrue;
    elif mode mod 2 = 1  then  # rational classes
        Error( "<G> must be a p-group" );
    else
        eas := ElementaryAbelianSeries( G );
        cent := function( cl, N, L )
            return ForAll( N, k -> ForAll
                           ( Pcgs( StabilizerOfExternalSet( cl ) )
                             {[1..Length(Pcgs(StabilizerOfExternalSet(cl)))
                               -Length(InducedPcgsWrtHomePcgs(L))]},
                             c -> Comm( k, c ) in L ) );
        end;
    fi;

    # Initialize the algorithm for the trivial group.
    step := 1;
    while IsSubset( eas[ step + 1 ], U )  do
        step := step + 1;
    od;
    L  := eas[ step ];
    Lp := InducedPcgsWrtHomePcgs( L );
    if not IsIdentical( G, H )  then
        LcapH := NormalIntersectionPcgs( home, Hp, Lp );
    fi;
    if    mode mod 2 = 1  # rational classes
       or IsIdentical( FamilyObj( G ), FamilyObj( candidates ) ) then
        mL := ModuloPcgsByPcSequenceNC( home, Pcgs( U ), Lp );
    fi;
    if     candidates <> false  # centralizer calculation
       and not IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
        cl := ConjugacyClass( U, candidates );
        SetStabilizerOfExternalSet( cl, H );
        SetPcgs( StabilizerOfExternalSet( cl ), Hp );
        tra := One( U );
    elif mode mod 2 = 1  then  # rational classes
        cl := RationalClass( U, One( U ) );
        SetStabilizerOfExternalSet( cl, H );
        SetGaloisGroup( cl, GroupByPrimeResidues( [  ], 1 ) );
        GaloisGroup( cl )!.type := 3;
        GaloisGroup( cl )!.operators := [  ];
        if mode mod 4 = 3  then  # construct the power tree
            cl!.power           := RationalClass( U, One( U ) );
            cl!.power!.operator := One( U );
            cl!.power!.exponent := 1;
            cl!.power!.kernel   := false;
        fi;
    else
        cl := ConjugacyClass( U, One( U ) );
        SetStabilizerOfExternalSet( cl, H );
    fi;
    if IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
        cls := List( candidates, c -> cl );
        tra := List( candidates, c -> One( U ) );
        exp := 0 * [ 1 .. Length( candidates ) ] + 1;
    else
        cls := [ cl ];
    fi;
    
    # Now go back through the factors by all groups in the elementary abelian
    # series.
    for step  in [ step + 1 .. Length( eas ) ]  do
        K  := L;
        Kp := Lp;
        L  := eas[ step ];
        Lp := InducedPcgsWrtHomePcgs( L );
        N  := Kp mod Lp;
        SetFilterObj( N, IsPcgs );
        if not IsIdentical( G, H )  then
            KcapH   := LcapH;
            LcapH   := NormalIntersectionPcgs( home, Hp, Lp );
            N!.capH := KcapH mod LcapH;
        else
            N!.capH := N;
        fi;
        if    mode mod 2 = 1   # rational classes; construct the power tree
           or IsIdentical( FamilyObj( G ), FamilyObj( candidates ) ) then
            mK := mL;
            mL := ModuloPcgsByPcSequenceNC( home, Pcgs( U ), Lp );
        fi;
        
        # Identification of classes.
        if IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
            if     mode = 4  # test conjugacy of two elements
               and not Representative( cls[ 1 ] ) /
                       Representative( cls[ 2 ] ) in K  then
                return fail;
            fi;
            
            blist := BlistList( [ 1 .. Length( cls ) ], [  ] );
            pos := Position( blist, false );
            while pos <> fail  do
                
                # Find a team with same image under <modK>.
                cl := cls[ pos ];
                SetRepresentative( cl, PcElementByExponents( mK,
                        ExponentsOfPcElement( mK, Representative( cl ) ) ) );
                cl!.candidates := [  ];
                team := [  ];
                q := pos;
                while q <> fail  do
                    if Representative( cls[ q ] ) /
                       Representative( cl ) in K  then
                        c := candidates[ q ] ^ tra[ q ];
                        if mode mod 2 = 1  then  # rational classes
                            c := c ^ exp[ q ];
                        fi;
                        i := PositionSorted( cl!.candidates, c );
                        if    i > Length( cl!.candidates )
                           or cl!.candidates[ i ] <> c  then
                            AddSet( cl!.candidates, c );
                            InsertElmList( team, i, [ q ] );
                        else
                            Add( team[ i ], q );
                        fi;
                        blist[ q ] := true;
                    fi;
                    q := Position( blist, false, q );
                od;
                
                if mode mod 2 = 1  then  # rational classes
                    newcls := CentralStepRatClPGroup( U, N, mK, mL, cl );
                elif cent( cl, N, L )  then
                    newcls := CentralStepClEANS( H, U, N, cl );
                else
                    newcls := GeneralStepClEANS( H, U, N, cl );
                fi;
                
                # Update <cls>, <tra> and <exp>.
                for i  in [ 1 .. Length( team ) ]  do
                    for q  in team[ i ]  do
                        cls[ q ] := newcls[ i ];
                        tra[ q ] := tra[ q ] * newcls[ i ]!.operator;
                        if mode mod 2 = 1  then  # rational classes
                            ord := OrderModK( Representative( cls[q] ), mL );
                            if ord <> 1  then
                                exp[ q ] := exp[ q ] /
                                            newcls[ i ]!.exponent mod ord;
                            fi;
                        fi;
                    od;
                od;
                
                pos := Position( blist, false, pos );
            od;

        elif candidates <> false  then  # centralizer calculation
            cls[ 1 ]!.candidates := Representative( cls[ 1 ] );
            if cent( cls[ 1 ], N, L )  then
                cls := CentralStepClEANS( H, U, N, cls[ 1 ] );
            else
                cls := GeneralStepClEANS( H, U, N, cls[ 1 ] );
            fi;
            tra := tra * cls[ 1 ]!.operator;
            
        elif mode mod 2 = 1  then  # rational classes
            newcls := [  ];
            for cl  in cls  do
                if IsBound( cl!.power )  then  # construct the power tree
                    SetRepresentative( cl, PcElementByExponents( mK,
                        ExponentsOfPcElement( mK, Representative( cl ) ) ) );
                    SetRepresentative( cl!.power, PcElementByExponents( mK,
                        ExponentsOfPcElement( mK, Representative(cl!.power))));
                fi;
                new := CentralStepRatClPGroup( U, N, mK, mL, cl );
                ord := OrderModK( Representative( new[ 1 ] ), mL );
                if     ord <= limit.order
                   and (    limit.size = 0
                         or limit.size mod Size( new[ 1 ] ) = 0 )  then
                    if IsBound( cl!.power )  then  # construct the power tree
                      if ord = 1  then
                        power := cl!.power;
                      else
                        cl!.power!.candidates := [ ( Representative(new[1]) ^
                            cl!.power!.operator ) ^ (p*cl!.power!.exponent) ];
                        power := CentralStepRatClPGroup( U, N, mK, mL,
                                         cl!.power )[ 1 ];
                        power!.operator := cl!.power!.operator
                                             * power!.operator;
                        power!.exponent := cl!.power!.exponent
                                             / power!.exponent mod ord;
                      fi;
                      for c  in new  do
                        c!.power := power;
                      od;
                    fi;
                    Append( newcls, new );
                fi;
            od;
            cls := newcls;
            
        else
            newcls := [  ];
            for cl  in cls  do
                if cent( cl, N, L )  then
                    Append( newcls, CentralStepClEANS( H, U, N, cl ) );
                else
                    Append( newcls, GeneralStepClEANS( H, U, N, cl ) );
                fi;
            od;
            cls := newcls;
        fi;
    od;
    
    if mode = 4  then  # test conjugacy of two elements
        if Representative( cls[ 1 ] ) <> Representative( cls[ 2 ] )  then
            return fail;
        else
            return tra[ 1 ] / tra[ 2 ];
        fi;
    elif candidates <> false  # identification of classes
     and IsIdentical( FamilyObj( U ), FamilyObj( candidates ) )  then
        for q  in [ 1 .. Length( cls ) ]  do
            cls[ q ]!.operator := tra[ q ];
            if mode mod 2 = 1  then  # rational classes
                cls[ q ]!.exponent := exp[ q ];
            fi;
        od;
    elif candidates <> false  then  # centralizer calculation
        return ConjugateSubgroup( StabilizerOfExternalSet( cls[ 1 ] ),
                       tra ^ -1 );
    elif mode mod 4 = 3  then  # rational classes and power tree
        for i  in [ 1 .. Length( cls ) ]  do
            cl := cls[ i ];
            if ForAll( GeneratorsOfGroup( ActingDomain( cl ) ),
                       gen -> gen ^ Representative( cl ) = gen )  then
                cl!.isCentral := true;
            fi;
        od;
    fi;
    return cls;
end;

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  claspcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
