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
               projection     := MutableIdentityMat( r, one ),
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
            Q[ i ] := ListWithIdenticalEntries( r, zero );
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
    local  h,           # preimage of `cl.representative' under <hom>
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
           Q,  v,  r,   # subspace to be projected onto, projection vectors
           k,           # orbit representative in <N>
           gens,  oprs, # generators and operators for new Galois group
           type,        # the type of the Galois group as subgroup of Z_2^r^*
           i, j, l, c,  # loop variables
           C,  cyc,  xset,  opr,  orb;
    
    p   := RelativeOrders( N )[ 1 ];
    h   := cl.representative;
    ohN := OrderModK( h, mK );
    oh  := OrderModK( h, mL );
    
    classes := [  ];
    if oh = 1  then

        # Special case: <h> is trivial.
        Gal := Units( Integers mod 1 );
        gal := GroupByPrimeResidues( [  ], p );
        gal!.type := 3;
        gal!.operators := [  ];
        
        if IsBound( cl.candidates )  then
            for c  in cl.candidates  do
                l := LeadingExponentOfPcElement( N, c );
                if l = fail  then
                    l := 1;
                    c := rec( representative := c,
                                 galoisGroup := TrivialSubgroup( Gal ) );
                    c.galoisGroup!.type := 3;
                    c.galoisGroup!.operators := [  ];
                else
                    c := rec( representative := c ^ ( 1 / l mod p ),
                                 galoisGroup := gal );
                fi;
                c.centralizer := G;
                c.operator    := OneOfPcgs( N );
                c.exponent    := l;
                Add( classes, c );
            od;
        else
            c := rec( representative := One( G ),
                         centralizer := G,
                         galoisGroup := TrivialSubgroup( Gal ) );
            c.galoisGroup!.type := 3;
            c.galoisGroup!.operators := [  ];
            Add( classes, c );
            for v  in OneDimSubspacesTransversal( GF( p ) ^ Length( N ) )  do
                c := rec( representative := PcElementByExponents( N, v ),
                             centralizer := G,
                             galoisGroup := gal );
                Add( classes, c );
            od;
        fi;

    else
        Gal := Units( Integers mod oh );
        if IsBound( cl.kernel )  then
            N := cl.kernel;
        else
            N!.CmodK := InducedPcgsWrtHomePcgs( cl.centralizer ) mod
                        DenominatorOfModuloPcgs( N );
            N!.CmodL := ExtendedPcgs( DenominatorOfModuloPcgs( N ),
                                KernelHcommaC( N, h, N!.CmodK ) );
        fi;
        if IsBound( cl.candidates )  then
            cl.candidates := List( cl.candidates, c ->
                LeftQuotient( h, c ) );
            candexps := List( cl.candidates, c ->
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
                if   cl.galoisGroup!.type = 1  then
                    preimage := [ -1, 5^(ohN/(2*Size(cl.galoisGroup))) ];
                elif cl.galoisGroup!.type = 2  then
                    preimage := [  -( 5^(ohN/(4*Size(cl.galoisGroup)))) ];
                else
                    preimage := [     5^(ohN/(4*Size(cl.galoisGroup))) ];
                fi;
                preimage := GroupByPrimeResidues( preimage, oh );
                preimage!.type := cl.galoisGroup!.type;
                if Length( GeneratorsOfGroup( preimage ) ) =
                   Length( GeneratorsOfGroup( cl.galoisGroup ) )  then
                    preimage!.operators := cl.galoisGroup!.operators;
                else
                    preimage!.operators := Concatenation
                      ( cl.galoisGroup!.operators, [ One( G ) ] );
                fi;
            fi;
            
            # Construct the image of the homomorphism <preimage> -> <K>.
            Q := [  ];
            for i  in [ 1 .. Length( GeneratorsOfGroup( preimage ) ) ]  do
                Add( Q, ExponentsOfPcElement( N, LeftQuotient( h ^
                        Int( GeneratorsOfGroup( preimage )[ i ] ),
                        h ^ preimage!.operators[ i ] ) ) );
            od;
            Q := Q * N!.subspace.projection;
            K := InducedPcgsByPcSequenceNC( N,
                         N{ N!.subspace.baseComplement } );
            K!.subspace := SubspaceVectorSpaceGroup( K, p, Q );
            
            # Project the factors in <N> onto a complement to <Q>.
            if IsBound( cl.candidates )  then
                v := List( candexps, ShallowCopy );
                r := v * K!.subspace.projection;
                reps := [  ];
                exps := [  ];
                conj := [  ];
                if not IsEmpty( K!.subspace.baseComplement )  then
                    v{[1..Length(v)]}{K!.subspace.baseComplement} :=
                      v{[1..Length(v)]}{K!.subspace.baseComplement} + r;
                fi;
                v := v * K!.subspace.inverse;
                for i  in [ 1 .. Length( r ) ]  do
                    reps[ i ] := PcElementByExponents
                        ( K, K{ K!.subspace.baseComplement }, r[ i ] );
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
            cyc := GroupByPrimeResidues( [ PowerModInt
                           ( PrimitiveRootMod( oh ),
                             IndexInParent( cl.galoisGroup ), oh ) ], oh );
            SetSize( cyc, Phi( oh ) / IndexInParent( cl.galoisGroup ) );
            if IsTrivial( cyc )  then
                preimage := One( cyc );
            else
                SetIndependentGeneratorsOfAbelianGroup( cyc,
                        GeneratorsOfGroup( cyc ) );
                preimage := Pcgs( cyc )[ 1 ];
            fi;
            if IsTrivial( cl.galoisGroup )  then
                operator := One( G );
            else
                operator := cl.galoisGroup!.operators[ 1 ];
            fi;
            v := PcElementByExponents( N, N{ N!.subspace.baseComplement },
                 ExponentsOfPcElement( N, LeftQuotient( h ^ Int( preimage ),
                         h ^ operator ) ) * N!.subspace.projection );
            opr := function( k, l )
                return ( v * k ) ^ ( 1 / Int( l ) mod p );
            end;
            xset := ExternalSet( cyc, K, opr );
            
            reps := [  ];
            exps := [  ];
            if IsBound( cl.candidates )  then
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
                oprs := [ operator ^ Int( exps[ l ] ) ];
            fi;
            gal := SubgroupNC( Gal, gens );
            if p = 2  then
                gal!.type := type;
            fi;
            gal!.operators := [  ];
            for i  in [ 1 .. Length( GeneratorsOfGroup( gal ) ) ]  do
                Add( gal!.operators, CentralStepConjugatingElement
                     ( N, h, k, k, Int( GeneratorsOfGroup( gal )[ i ] ),
                       oprs[ i ] ) );
            od;
            
            C := SubgroupNC( G, N!.CmodL );
            SetInducedPcgsWrtHomePcgs( C, N!.CmodL );
            c := rec( representative := h * k,
                         centralizer := C,
                         galoisGroup := gal );
            if IsBound( cl.candidates )  then
                
                # cl.candidates[l] ^ c.operator =
                # c.representative ^ c.exponent (DIFFERS from (c^o^e=r)!)
                c.exponent := Int( exps[ l ] );
                c.operator := CentralStepConjugatingElement
                    ( N, h, cl.candidates[ l ], k, c.exponent, conj[ l ] );
                
                if IsBound( cl.kernel )  then
                    c.kernel := N;
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
           h,          # preimage `cl.representative' under <hom>
           C,  gens,   # preimage `Centralizer( cl )' under <hom>
           exp,  w,    # coefficient vectors for projection along $[h,N]$
           c;          # loop variable
    
    field := GF( RelativeOrders( N )[ 1 ] );
    h := cl.representative;
    N!.CmodK := InducedPcgsWrtHomePcgs( cl.centralizer ) mod
                DenominatorOfModuloPcgs( N!.capH );
    N!.CmodL := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
                        KernelHcommaC( N, h, N!.CmodK ) );
    C := SubgroupNC( H, N!.CmodL );
    SetInducedPcgsWrtHomePcgs( C, N!.CmodL );
    
    classes := [  ];
    if IsBound( cl.candidates )  then
        gens := N!.CmodK{ N!.subspace.needed };
        if IsIdentical( FamilyObj( U ), FamilyObj( cl.candidates ) )  then
            for c  in cl.candidates  do
                exp := ExponentsOfPcElement( N, LeftQuotient( h, c ) );
                MultRowVector( exp, One( field ) );
                w := exp * N!.subspace.projection;
                exp{ N!.subspace.baseComplement } :=
                  w - exp{ N!.subspace.baseComplement };
                c := rec( representative := h * PcElementByExponents
                             ( N, N{ N!.subspace.baseComplement }, w ),
                          centralizer := C,
                          operator := WordVector( gens,
                                  One( cl.centralizer ),
                                  exp * N!.subspace.inverse ) );
                Add( classes, c );
            od;
        else
            c := rec( representative := cl.candidates,
                         centralizer := C,
                            operator := One( H ) );
            Add( classes, c );
        fi;
        
    else
        gens := N{ N!.subspace.baseComplement };
        for w  in field ^ Length( gens )  do
            c := rec( representative := h * PcElementByExponents( N,gens,w ),
                         centralizer := C );
            Add( classes, c );
        od;
    fi;
    return classes;
end;

#############################################################################
##
#F  CorrectConjugacyClass( <H>, <U>, <h>, <n>, <stab>, <N>, <cNh> )  cf. MN89
##
CorrectConjugacyClass := function( H, U, h, n, stab, N, cNh )
    local   cl,  comm,  s,  C;
    
    stab := ShallowCopy( InducedPcgsWrtHomePcgs( stab ) );
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
    stab := ExtendedPcgs( cNh, stab );
    C := SubgroupNC( H, stab );
    SetInducedPcgsWrtHomePcgs( C, stab );
    cl := rec( representative := h * n,
                  centralizer := C );
    return cl;
end;

#############################################################################
##
#F  GeneralStepClEANS( <H>, <U>, <N>, <cl> )  . . . . . . . . . . . . . local
##
GeneralStepClEANS := function( H, U, N, cl )
    local  classes,    # classes to be constructed, the result
           field,      # field over which <N> is a vector space
           h,          # preimage `cl.representative' under <hom>
           cNh,        # centralizer of <h> in <N>
           C,  gens,   # preimage `Centralizer( cl )' under <hom>
           r,          # dimension of <N>
           ran,        # constant range `[ 1 .. r ]'
           aff,        # <N> as affine space
           xset,       # affine operation of <C> on <aff>
           imgs,  M,   # generating matrices for affine operation
           orb,        # orbit of affine operation
           Rep,        # representative function to use for <orb>
           n,  k,      # cf. Mecky--Neub\"user paper
           cls,rep,pos,# set of classes with canonical representatives
           c,  ca,  i; # loop variables
           
    C := cl.centralizer;
    field := GF( RelativeOrders( N )[ 1 ] );
    h := cl.representative;
    
    # Determine the subspace $[h,N]$ and calculate the centralizer of <h>.
    cNh := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
                   KernelHcommaC( N, h, N!.capH ) );
    r := Length( N!.subspace.baseComplement );
    ran := [ 1 .. r ];
    
    # Construct matrices for the affine operation on $N/[h,N]$.
    aff := ExtendedVectors( field ^ r );
    gens := InducedPcgsWrtHomePcgs( C );
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
    if IsBound( cl.candidates )  then
        if IsIdentical( FamilyObj( U ), FamilyObj( cl.candidates ) )  then
            Rep := CanonicalRepresentativeOfExternalSet;
        else
            cl.candidates := [ cl.candidates ];
            Rep := Representative;
        fi;
        cls := [  ];
        for ca  in cl.candidates  do
            n := ExponentsOfPcElement( N, LeftQuotient( h, ca ) ) *
                 One( field );
            k := n * N!.subspace.projection;
            orb := ExternalOrbit( xset, Concatenation( k, [ One( field ) ] ) );
            rep := PcElementByExponents( N, N{ N!.subspace.baseComplement },
                      Rep( orb ){ ran } );
            pos := Position( cls, rep );
            if pos = fail  then
                Add( cls, rep );
                c := StabilizerOfExternalSet( orb );
                if IsIdentical( Rep, CanonicalRepresentativeOfExternalSet )
                   then
                    c := ConjugateSubgroup( c, OperatorOfExternalSet( orb ) );
                fi;
                c := CorrectConjugacyClass( H, U, h, rep, c, N, cNh );
            else
                c := rec( representative := h * rep,
                             centralizer := classes[ pos ].centralizer );
            fi;
            n := ShallowCopy( -n );
            n{ N!.subspace.baseComplement } :=
              k + n{ N!.subspace.baseComplement };
            c.operator := PcElementByExponents( N, N{ N!.subspace.needed },
                                   n * N!.subspace.inverse );
            # Now (h.n)^c.operator = h.k
            if IsIdentical( Rep, CanonicalRepresentativeOfExternalSet )  then
                c.operator := c.operator * OperatorOfExternalSet( orb );
                # Now (h.n)^c.operator = h.rep mod [h,N]
                k := PcElementByExponents( N, N{ N!.subspace.needed },
                     ExponentsOfPcElement( N, LeftQuotient
                             ( c.representative, ca ^ c.operator ) ) *
                             N!.subspace.inverse );
                c.operator := c.operator / k;
                # Now (h.n)^c.operator = h.rep
            fi;
            Add( classes, c );
        od;
        
    else
        for orb  in ExternalOrbitsStabilizers( xset )  do
            rep := PcElementByExponents( N, N{ N!.subspace.baseComplement },
                           Representative( orb ){ ran } );
            c := CorrectConjugacyClass( H, U, h, rep,
                         StabilizerOfExternalSet( orb ), N, cNh );
            Add( classes, c );
        od;
    fi;
    return classes;
end;
    
#############################################################################
##
#F  ClassesSolvableGroup( <H>, <U>, <limit>, <mode> [, <cands> ] )  . . . . .
##
##  In this function  classes    are described by  records  with   components
##  `representative', `centralizer', `galoisGroup' (for rational classes). If
##  <candidates>  are  given,    their   classes  will   have  a    canonical
##  `representative' and additional components `operator' and `exponent' (for
##  rational classes) such that
##      (candidate ^ operator) ^ exponent = representative.         (c^o^e=r)
##
ClassesSolvableGroup := function( arg )
    local  G,  home,    # the supergroup (of <H> and <U>), the home pcgs
           U,           # group in which to find the <H>-classes
	   Upcgs,	# induced Pcgs of U
           H,  Hp,      # group operating on <U>, a pcgs for <H>
           limit,       # limit on order of representatives
           mode,        # LSB: ratCl | power | test :MSB
           candidates,  # candidates to be replaced by their canonical reps.
           eas,         # elementary abelian series in <G> through <U>
           step,        # counter looping over <eas>
           K,    L,     # members of <eas>
           Kp,mK,Lp,mL, # induced and modulo pcgs's
           KcapH,LcapH, # pcgs's of intersections with <H>
           N,   cent,   # elementary abelian factor, for affine action
           cls, newcls, # classes in range/source of homomorphism
	   news,	# new classes obtained in step
           cl,          # class looping over <cls>
           opr, exp,    # (candidates[i]^opr[i])^exp[i]=cls[i].representative
           team,        # team of candidates with same image modulo <K>
           blist,pos,q, # these control grouping of <cls> into <team>s
           p,           # prime dividing $|G|$
           ord,         # order of a rational class modulo <L>
           new, power,  # auxiliary variables for determination of power tree
           c,  i;       # loop variables
    
    # Get the arguments.
    H     := arg[ 1 ];  # the operating group
    U     := arg[ 2 ];  # the group on which <H> acts by conjugation
    if H = U  then  G := H;
              else  G := ClosureGroup( H, U );  fi;
    limit := arg[ 3 ];     # if limit <> true, restricts the classes computed:
    if limit = true  then  # only classes will be output which have
        limit := rec( order := infinity,  # rep. order dividing `order'
                       size := 0 );       # class size dividing `size'
    fi;
    mode  := arg[ 4 ];  # explained below whenever it appears

    # <candidates> is a list  of elements whose classes  will be output  (but
    # with canonical representatives), see comment  above. Or <candidates> is
    # just one element, from whose output class the  centralizer will be read
    # off.
    if Length( arg ) = 5  then  candidates := arg[ 5 ];
                          else  candidates := false;     fi;
    
    # Treat the case of a trivial group.
    if IsTrivial( U )  then
        if mode = 4  then  # test conjugacy of two elements
            return One( U );
        elif mode mod 2 = 1  then  # rational classes
            cl := rec( representative := One( G ),
                          centralizer := G,
                          galoisGroup := GroupByPrimeResidues( [  ], 1 ) );
            cl.galoisGroup!.type := 3;
            cl.galoisGroup!.operators := [  ];
            cl.isCentral := true;
            if mode mod 4 = 3  then  # construct the power tree
                cl.power          := rec( representative := One( G ) );
                cl.power.operator := One( G );
                cl.power.exponent := 1;
            fi;
        else
            cl := rec( representative := One( H ),
                          centralizer := H );
        fi;
        if IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
            cls := List( candidates, c -> cl );
        elif candidates <> false  then
            return cl.centralizer;
        else
            cls := [ cl ];
        fi;
        return cls;
    fi;
    
    # Calculate a (central)  elementary abelian series  with all pcgs induced
    # w.r.t. <home>.
    if not IsPermGroup( G )  then
        HomePcgs( G );
    fi;
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
              ( InducedPcgsWrtHomePcgs( cl.centralizer ),
#T  was: Only those elements form the induced PCGS. The subset seemed to
#T enforce taking only the elements up, but the ordering of the series used
#T may be different then the ordering in the PCGS. So this will fail. AH
#T one might pick the right ones, but this would be almost the same work.
#T { [ 1 .. Length( InducedPcgsWrtHomePcgs( cl.centralizer ) )
#T - Length( InducedPcgsWrtHomePcgs( L ) ) ] },
                   c -> Comm( k, c ) in L ) );
        end;
    fi;
    G := eas[ 1 ];
    home := HomePcgs( G );
    Upcgs:=InducedPcgsByGeneratorsNC(home,GeneratorsOfGroup(U));
    H := AsSubgroup( G, H );
    Hp := InducedPcgsByGeneratorsNC(home, GeneratorsOfGroup(H));

    # Initialize the algorithm for the trivial group.
    step := 1;
    while IsSubset( eas[ step + 1 ], U )  do
        step := step + 1;
    od;
    L  := eas[ step ];
    Lp := InducedPcgsByGeneratorsNC(home,GeneratorsOfGroup( L ));
    if not (G=H)  then
        LcapH := NormalIntersectionPcgs( home, Hp, Lp );
    fi;
    if    mode mod 2 = 1  # rational classes
       or IsIdentical( FamilyObj( G ), FamilyObj( candidates ) ) then
        mL := ModuloPcgsByPcSequenceNC( home, Upcgs, Lp );
    fi;
    if     candidates <> false  # centralizer calculation
       and not IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
        cl := rec( representative := candidates,
                      centralizer := H );
        opr := One( U );
    elif mode mod 2 = 1  then  # rational classes
        cl := rec( representative := One( U ),
                      centralizer := H,
                      galoisGroup := GroupByPrimeResidues( [  ], 1 ) );
        cl.galoisGroup!.type := 3;
        cl.galoisGroup!.operators := [  ];
        if mode mod 4 = 3  then  # construct the power tree
            cl.power          := rec( representative := One( U ) );
            cl.power.operator := One( U );
            cl.power.exponent := 1;
            cl.power.kernel   := false;
        fi;
    else
        cl := rec( representative := One( U ),
                      centralizer := H );
    fi;
    if IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
        cls := List( candidates, c -> cl );
        opr := List( candidates, c -> One( U ) );
        exp := ListWithIdenticalEntries( Length( candidates ), 1 );
    else
        cls := [ cl ];
    fi;
    
    # Now go back through the factors by all groups in the elementary abelian
    # series.
    for step  in [ step + 1 .. Length( eas ) ]  do

        # We apply the homomorphism principle to the homomorphism G/L -> G/K.
        # The  actual   computations  are all    done   in <G>,   factors are
        # represented by modulo pcgs.
        K  := L;
        Kp := Lp;
        L  := eas[ step ];
        Lp := InducedPcgsByGeneratorsNC(home, GeneratorsOfGroup(L) );
        N  := Kp mod Lp;  # modulo pcgs representing the kernel

	#T What is this? Obviously it is needed somewhere, but it is
	#T certainly not good programming style. AH
        SetFilterObj( N, IsPcgs );

        if Size( G ) <> Size( H )  then
            KcapH   := LcapH;
            LcapH   := NormalIntersectionPcgs( home, Hp, Lp );
            N!.capH := KcapH mod LcapH;
	    #T See above
            SetFilterObj( N!.capH, IsPcgs );
        else
            N!.capH := N;
        fi;
        
        # Rational classes or identification of classes.
        if    mode mod 2 = 1
           or IsIdentical( FamilyObj( G ), FamilyObj( candidates ) ) then
            mK := mL;
            mL := ModuloPcgsByPcSequenceNC( home, Upcgs, Lp );
        fi;
        
        # Identification of classes.
        if IsIdentical( FamilyObj( G ), FamilyObj( candidates ) )  then
            if     mode = 4  # test conjugacy of two elements
               and not cls[ 1 ].representative /
                       cls[ 2 ].representative in K  then
                return fail;
            fi;
            
            blist := BlistList( [ 1 .. Length( cls ) ], [  ] );
            pos := Position( blist, false );
            while pos <> fail  do
                
                # Find a team of candidates with same image under <modK>.
                cl := cls[ pos ];
                cl.representative := PcElementByExponents( mK,
                    ExponentsOfPcElement( mK, cl.representative ) );
                cl.candidates := [  ];
                team := [  ];
                q := pos;
                while q <> fail  do
                    if cls[ q ].representative /
                       cl.representative in K  then
                        c := candidates[ q ] ^ opr[ q ];
                        if mode mod 2 = 1  then  # rational classes
                            c := c ^ exp[ q ];
                        fi;
                        i := PositionSorted( cl.candidates, c );
                        if    i > Length( cl.candidates )
                           or cl.candidates[ i ] <> c  then
                            AddSet( cl.candidates, c );
                            InsertElmList( team, i, [ q ] );
                        else
                            Add( team[ i ], q );
                        fi;
                        blist[ q ] := true;
                    fi;
                    q := Position( blist, false, q );
                od;

                # Now   <cl> is   a    class  modulo  <K>  (possibly     with
                # `<cl>.candidates'  a list of  elements  mapping  into  this
                # class modulo <K>). Let <newcls>  be  a list of all  classes
                # modulo <L> that  map to <cl>  modulo <K>  (resp. a list  of
                # classes to which   the list `<cl>.candidates'   maps modulo
                # <K>,  together  with   `operator's and   `exponent's  as in
                # (c^o^e=r)).
                if mode mod 2 = 1  then  # rational classes
                    newcls := CentralStepRatClPGroup( H, N, mK, mL, cl );
                elif cent( cl, N, L )  then
                    newcls := CentralStepClEANS( H, U, N, cl );
                else
                    newcls := GeneralStepClEANS( H, U, N, cl );
                fi;
                
                # Update <cls>, <opr> and <exp>.
                for i  in [ 1 .. Length( team ) ]  do
                    for q  in team[ i ]  do
                        cls[ q ] := newcls[ i ];
                        opr[ q ] := opr[ q ] * newcls[ i ].operator;
                        if mode mod 2 = 1  then  # rational classes
                            ord := OrderModK( cls[ q ].representative, mL );
                            if ord <> 1  then

                                # For  historical  reasons,   the `exponent's
                                # returns by `CentralStepRatClPGroup' are the
                                # inverses of what we need.
                                exp[ q ] := exp[ q ] /
                                            newcls[ i ].exponent mod ord;
                                
                            fi;
                        fi;
                    od;
                od;
                
                pos := Position( blist, false, pos );
            od;

        elif candidates <> false  then  # centralizer calculation
            cls[ 1 ].candidates := cls[ 1 ].representative;
            if cent( cls[ 1 ], N, L )  then
                cls := CentralStepClEANS( H, U, N, cls[ 1 ] );
            else
                cls := GeneralStepClEANS( H, U, N, cls[ 1 ] );
            fi;
            opr := opr * cls[ 1 ].operator;
            
        elif mode mod 2 = 1  then  # rational classes
            newcls := [  ];
            for cl  in cls  do
                if IsBound( cl.power )  then  # construct the power tree
                    cl.representative := PcElementByExponents( mK,
                        ExponentsOfPcElement( mK, cl.representative ) );
                    cl.power.representative := PcElementByExponents( mK,
                        ExponentsOfPcElement( mK, cl.power.representative ) );
                fi;
                new := CentralStepRatClPGroup( H, N, mK, mL, cl );
                ord := OrderModK( new[ 1 ].representative, mL );
                if     ord <= limit.order
                   and (    limit.size = 0
                         or limit.size mod Size( new[ 1 ] ) = 0 )  then
                    if IsBound( cl.power )  then  # construct the power tree
                      if ord = 1  then
                        power := cl.power;
                      else
                        cl.power.candidates := [ ( new[1].representative ^
                            cl.power.operator ) ^ (p*cl.power.exponent) ];
                        power := CentralStepRatClPGroup( H, N, mK, mL,
                                         cl.power )[ 1 ];
                        power.operator := cl.power.operator
                                           * power.operator;
                        power.exponent := cl.power.exponent
                                           / power.exponent mod ord;
                      fi;
                      for c  in new  do
                        c.power := power;
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
		news:=CentralStepClEANS( H, U, N, cl );
	    else
		news:=GeneralStepClEANS( H, U, N, cl );
	    fi;
	    Assert(1,ForAll(news,
	                    i->ForAll(GeneratorsOfGroup(i.centralizer),
			    j->Comm(i.representative,j) in eas[step])));
	    Append(newcls,news);
	  od;
	  cls := newcls;
	fi;
    od;

    if mode = 4  then  # test conjugacy of two elements
        if cls[ 1 ].representative <> cls[ 2 ].representative  then
            return fail;
        else
            return opr[ 1 ] / opr[ 2 ];
        fi;
    elif     candidates <> false
         and not IsIdentical( FamilyObj( U ), FamilyObj( candidates ) )  then
        # centralizer calculation
        return ConjugateSubgroup( cls[ 1 ].centralizer, opr ^ -1 );
    fi;
    
    if candidates <> false  then  # add operators (and exponents)
        for i  in [ 1 .. Length( cls ) ]  do
            cls[ i ].operator := opr[ i ];
            if mode mod 2 = 1  then  # rational classes
                cls[ i ].exponent := exp[ i ];
            fi;
        od;
    fi;
    return cls;
end;

#############################################################################
##

#M  OperatorOfExternalSet( <cl> ) . . . . . . . . . conj. cl. of solv. groups
##
InstallMethod( OperatorOfExternalSet, true,
        [ IsConjugacyClassGroupRep ], 0,
    function( cl )
    local   G,  rep;
    
    G := ActingDomain( cl );
    if not IsPcgsComputable( G )  then
        TryNextMethod();
    fi;
    rep := ClassesSolvableGroup( G, G, true, 0, [ Representative( cl ) ] )
           [ 1 ];
    if not HasStabilizerOfExternalSet( cl )  then
        SetStabilizerOfExternalSet( cl,
                ConjugateSubgroup( rep.centralizer, rep.operator ^ -1 ) );
    fi;
    SetCanonicalRepresentativeOfExternalSet( cl, rep.representative );
    return rep.operator;
end );
        
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
