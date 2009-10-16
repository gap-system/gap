#############################################################################
##
#W  idempot.gi            The Wedderga package            Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              Ángel del Río
##
#H  $Id: idempot.gi,v 1.15 2008/01/03 14:43:22 alexk Exp $
##
#############################################################################


#############################################################################
##
#M CentralElementBySubgroups( QG, K, H )
##
## The function CentralElementBySubgroups computes e(G,K,H) for H and K, 
## where H and K are subgroups of G such that H is normal in K
##
InstallOtherMethod( CentralElementBySubgroups,
    "for pairs of subgroups", 
    true, 
    [ IsSemisimpleRationalGroupAlgebra, IsGroup, IsGroup ], 
    0,
function( QG, K, H )
local   alpha, 
        G, 
        zero, 
        Eps, 
        Cen, 
        RTCen, 
        nRTCen, 
        i, 
        g, 
        NH;
   
G := UnderlyingMagma( QG );

if not IsSubgroup( G, K ) then
    Error("Wedderga: <K> should be a subgroup of the underlying subgroup of <FG>\n");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("Wedderga: <H> should be a normal subgroup of <K>\n");
fi; 
    
    NH := Normalizer( G, H );
    Eps := IdempotentBySubgroups( QG, K, H );
    if ( IsCyclic(FactorGroup(K,H)) and IsNormal(NH,K) ) then 
        Cen := NH;
    else 
        Cen := Centralizer( G, Eps );
    fi;
    RTCen := RightTransversal( G, Cen ); 
 
return Sum( List( RTCen, g -> Eps^g ) );
end);


#############################################################################
##  
## CentralElementBySubgroups( FqG, K, H, c, ltrace )
##
## The function CentralElementBySubgroups computes e(G, K, H, C) for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## is a cyclotomic class of q=|Fq| modulo n=[K:H] containing generators of K/H.
## The list ltrace contains information about the trace of a n-th roots of 1.  
##
InstallOtherMethod( CentralElementBySubgroups,
    "for pairs of subgroups, one cyclotomic class and trace info", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList, IsList ],
    0,
function( FqG, K, H, c, ltrace )
local   G,      # Group
        N,      # Normalizer of H in G
        epi,    # N -->N/H
        QNH,    # N/H
        QKH,    # K/H
        gq,     # Generator of K/H
        C1,     # Cyclotomic class of q module n in K/H
        St,     # Stabilizer of C in K/H
        N1,     # Set of representatives of St by epi
        GN1,    # Right transversal of N1 in G
        Eps;    # the result of the IdempotentBySubgroups function

G := UnderlyingMagma( FqG );
N := Normalizer( G, H );
epi := NaturalHomomorphismByNormalSubgroup( N, H );
QNH := Image( epi, N );
QKH := Image( epi, K );
# We guarantee that QKH is cyclic so we can randomly obtain its generator
repeat
  gq := Random(QKH);
until Order(gq) = Size(QKH);
C1 := Set( List( c, ii -> gq^ii ) );
St := Stabilizer( QNH, C1, OnSets );
N1 := PreImage( epi, St );
GN1 := RightTransversal( G, N1 );
Eps := IdempotentBySubgroups( FqG, K, H, c, ltrace );

return Sum( List( GN1, g -> Eps^g ) );
end);



#############################################################################
##  
## CentralElementBySubgroups( FqG, K, H, c, ltrace, [epi, gq] )
##
## The function CentralElementBySubgroups computes e(G, K, H, C) for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## is a cyclotomic class of q=|Fq| modulo n=[K:H] containing generators of K/H.
## The list ltrace contains information about the trace of a n-th roots of 1.  
##
InstallMethod( CentralElementBySubgroups,
    "for pairs of subgroups, cyclotomic class and trace info, mapping and group element", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList, IsList, IsList ],
#      IsMapping, IsMultiplicativeElementWithInverse ],
    0,
function( FqG, K, H, c, ltrace, arg6 )
local   G,      # Group
        QNH,    # N/H
        C1,     # Cyclotomic class of q module n in K/H
        St,     # Stabilizer of C in K/H
        N1,     # Set of representatives of St by epi
        GN1,    # Right transversal of N1 in G
        Eps,    # Output of IdempotentBySubgroups 
        epi,    # Extra argument
        gq;     # Extra argument
epi:=arg6[1];
gq:=arg6[2];
G := UnderlyingMagma( FqG );
QNH := Range(epi);
C1 := Set( List( c, ii -> gq^ii ) );
St := Stabilizer( QNH, C1, OnSets );
N1 := PreImage( epi, St );
GN1 := RightTransversal( G, N1 );
Eps := IdempotentBySubgroups( FqG, K, H, c, ltrace, [epi,gq] );
return Sum( List( GN1, g -> Eps^g ) );
end);


#############################################################################
##
## CentralElementBySubgroups( FqG, K, H, C )
##
## The function CentralElementBySubgroups computes e( G, K, H, C) for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## is a cyclotomic class of q=|Fq| modulo n=[K:H] containing generators of K/H.
##
InstallOtherMethod( CentralElementBySubgroups,
    "for pairs of subgroups and one cyclotomic class", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList ],
    0,
function( FqG, K, H, C )
local   G,          # Group
        Fq,         # Field
        q,          # Order of field Fq
        n,          # Order of K/H
        N,          # Normalizer of H in G
        epi,        # N -->N/H
        QNH,        # N/H
        QKH,        # K/H
        gq,         # Generator of K/H
        C1,         # Cyclotomic class of q module n in K/H
        St,         # Stabilizer of C in K/H
        N1,         # Set of representatives of St by epi
        GN1,        # Right transversal of N1 in G
        Eps;        # epsilon( G, K, H ) 
        
# Initialization

G := UnderlyingMagma(FqG);
Fq := LeftActingDomain(FqG);
q := Size( Fq );
n := Index( K, H );


# First we check that FqG is a finite group algebra over finite field 
# Then we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( G, K ) then
    Error("Wedderga: <K> should be a subgroup of the underlying subgroup of <FG>\n");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("Wedderga: <H> should be a normal subgroup of <K>\n");
elif not IsCyclic( FactorGroup( K, H ) )then
    Error("Wedderga: <K> over <H> should be be cyclic \n");
elif not IsCyclotomicClass(q,n,C) then
    Error("Wedderga: \n<C> should be a cyclotomic class module the index of <H> on <K>\n");
fi; 

# Program

if K=H then
    return AverageSum( FqG, H );
fi;

N := Normalizer( G, H );
epi := NaturalHomomorphismByNormalSubgroup( N, H );
QNH := Image( epi, N );
QKH := Image( epi, K );
# We guarantee that QKH is cyclic so we can randomly obtain its generator
repeat
  gq := Random(QKH);
until Order(gq) = Size(QKH);
C1 := Set( List( C, ii -> gq^ii ) );
St := Stabilizer( QNH, C1, OnSets );
N1 := PreImage( epi, St );
GN1 := RightTransversal( G, N1);

Eps := IdempotentBySubgroups( FqG, K, H, C );

return Sum( List( GN1, g -> Eps^g ) );
end);


#############################################################################
##
## CentralElementBySubgroups( FqG, K, H, c )
##
## The function CentralElementBySubgroups computes e( G, K, H, C) for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## the q=|Fq|-cyclotomic class modulo n=[K:H] containing c which should be coprime with [K:H]
##
InstallOtherMethod( CentralElementBySubgroups,
    "for pairs of subgroups and one cyclotomic class", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsPosInt ],
    0,
function( FqG, K, H, c )
local   G,          # Group
        Fq,         # Field
        q,          # Order of field Fq
        n,          # Order of K/H
        C,          # The cyclotomic class containing c
        j,          # integer
        N,          # Normalizer of H in G
        epi,        # N -->N/H
        QNH,        # N/H
        QKH,        # K/H
        gq,         # Generator of K/H
        C1,         # Cyclotomic class of q module n in K/H
        St,         # Stabilizer of C in K/H
        N1,         # Set of representatives of St by epi
        GN1,        # Right transversal of N1 in G
        Eps;        # epsilon( G, K, H ) 
        
# Initialization

G := UnderlyingMagma(FqG);
Fq := LeftActingDomain(FqG);
q := Size( Fq );
n := Index( K, H );


# First we check that FqG is a finite group algebra over finite field 
# Then we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( G, K ) then
    Error("Wedderga: <K> should be a subgroup of the underlying subgroup of <FG>\n");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("Wedderga: <H> should be a normal subgroup of <K>\n");
elif not IsCyclic( FactorGroup( K, H ) )then
    Error("Wedderga: <K> over <H> should be be cyclic \n");
fi; 

# Program

if K=H then
    return AverageSum( FqG, H );
fi;

# Here we compute the cyclotomic class containin c

C := [ c mod n];
j:=q*c mod n;
while j <> C[1] do
  Add( C, j );
  j:=j*q mod n;
od;  

N := Normalizer( G, H );
epi := NaturalHomomorphismByNormalSubgroup( N, H );
QNH := Image( epi, N );
QKH := Image( epi, K );
# We guarantee that QKH is cyclic so we can randomly obtain its generator
repeat
  gq := Random(QKH);
until Order(gq) = Size(QKH);
C1 := Set( List( C, ii -> gq^ii ) );
St := Stabilizer( QNH, C1, OnSets );
N1 := PreImage( epi, St );
GN1 := RightTransversal( G, N1);

Eps := IdempotentBySubgroups( FqG, K, H, c );

return Sum( List( GN1, g -> Eps^g ) );
end);



#############################################################################
##
#M IdempotentBySubgroups( QG, K, H )
##
## The function IdempotentBySubgroups compute epsilon(QG,K,H) for H and K 
## subgroups of G such that H is normal in K. If the additional condition 
## holds that K/H is cyclic, than the faster algorithm is used.
##
InstallOtherMethod( IdempotentBySubgroups,
    "for pairs of subgroups", 
    true, 
    [ IsSemisimpleRationalGroupAlgebra, IsGroup, IsGroup ], 
    0,
function( QG, K, H )
local   L,       # Subgroup of G
        G,       # Group
        Emb,     # Embedding of G in QG
        zero,    # 0 of QG
        Epsilon, # Coefficients of output
        ElemH,   # The elements of H
        OrderH,  # Size of H
        Supp,    # Support of output
        Trans,   # Representatives of Supp module H
        exp,     # Exponent of the elements of Trans as powers of x
        coeff,   # Coefficients of the elements of Trans in Epsilon
        Epi,     # K --> K/H
        KH,      # K/H
        n,       # Order of KH
        y,       # Generator of KH 
        x,       # Representative of preimage of y
        p,       # Set of prime divisors of n
        Lp,      # Length of p
        Comb,    # The direct product [1..p(1)] X [1..p(2)] X .. X [1..[p(Lp)] X H
        i,j,     # Counters
        hatH, 
        MNSKH,   # The set of non trivial minimal normal subgroups of K/H
        q, powersx;

#First we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( UnderlyingMagma( QG ),K ) then
    Error("Wedderga: <K> should be a subgroup of the underlying group of <QG>\n");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("Wedderga: <H> should be a normal subgroup of <K>\n");
fi;

# Initialization
G   := UnderlyingMagma( QG );
Emb := Embedding( G, QG );
Epi := NaturalHomomorphismByNormalSubgroup( K, H ) ;
KH  := Image( Epi, K ); 

if IsCyclic(KH) then

    ElemH:=Elements(H);
    OrderH:=Size(H);
    if K=H then
        for i in [ 1 .. OrderH ] do
            Epsilon := List( [1 .. OrderH ], h -> 1/OrderH );  
            # If H=K then Epsilon = AverageSum( QG, H )
            Supp := ElemH;
        od;
    else
        n := Size( KH );
        y := Product( IndependentGeneratorsOfAbelianGroup( KH ) );
        x := PreImagesRepresentative( Epi, y );
        p := Set( FactorsInt( n ) );
        Lp := Length( p );
        #
        # ??? Cartesian can be expensive - check if this might be optimized ???
        #
        Comb := Cartesian( List( [1..Lp], i -> List( [ 1 .. p[i] ] ) ){[1..Lp]} );
        exp := List( Comb, i -> Sum( List( [1..Lp], j -> n/p[j]*i[j] ) ) );
        coeff := List(Comb, i -> Product( List( [1..Lp], j -> -1/p[j]+Int(i[j]/p[j] ) ) ) );
        Supp := List( Cartesian( exp, ElemH ), i -> (x^i[1])*i[2] );
        Epsilon := List( Cartesian( coeff, [1..OrderH] ), i -> i[1]/OrderH );   
    fi;
    return ElementOfMagmaRing( FamilyObj(Zero(QG)), 0, Epsilon, Supp );
else
    Epsilon := AverageSum( QG, H );
    hatH := Epsilon;
    MNSKH := MinimalNormalSubgroups( KH );
    for i in MNSKH do
        L := PreImage( Epi, i );
        Epsilon := Epsilon * ( hatH - AverageSum( QG, L ) );
    od;
fi;

#Output
return Epsilon; 
end);


#############################################################################
##
#M IdempotentBySubgroups( FqG, K, H, C, ltrace )
##
## The function IdempotentBySubgroups computes epsilon(K, H, C), for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## is a cyclotomic class of q=|Fq| modulo n=[K:H] containing generators of K/H.
## The list ltrace contains information about the traces of the n-th roots of 1.   
##
InstallOtherMethod( IdempotentBySubgroups,
    "for pairs of subgroups, one cyclotomic class and traces", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList, IsList ], 
    0,
function( FqG, K, H, c, ltrace )
local   G,      # Group
        Fq,     # Field
        q,      # Order of field Fq
        N,      # Normalizer of H in G
        epi,    # N --> N/H
        QKH,    # K/H
        n,      # Order of K/H
        gq,     # Generator of K/H
        cc,     # Set of cyclotomic classes of q module n
        d,      # Cyclotomic class of q module n   
        tr,     # Element of ltrace
        coeff,  # Coefficients of the output
        supp;   # Coefficients of the output
    
# In this case the conditions are not necesary because this function
# is used as local function of PCIs

# Program
G := UnderlyingMagma( FqG );
Fq := LeftActingDomain( FqG );
q := Size( Fq );
n := Index( K, H );
cc := CyclotomicClasses( q, n );
N := Normalizer( G, H );
epi := NaturalHomomorphismByNormalSubgroup( N, H );
QKH := Image( epi, K );
# We guarantee that QKH is cyclic so we can randomly obtain its generator
repeat
  gq := Random(QKH);
until Order(gq) = Size(QKH);
supp := [];
coeff := [];
for d in cc do
    tr := ltrace[ 1+(-c[1]*d[1] mod n) ];
    Append( supp, PreImages( epi, List( d, x -> gq^x ) ) );
    Append( coeff, List( [ 1 .. Size( H ) * Size( d ) ], x -> tr ) );    
od;
coeff:=Inverse(Size(K)*One(Fq))*coeff;

# Output
return ElementOfMagmaRing( FamilyObj(Zero(FqG)), Zero(Fq), coeff, supp );
end);


#############################################################################
##
#M IdempotentBySubgroups( FqG, K, H, c, ltrace, [ epi, gq ] )
##
## The function IdempotentBySubgroups computes epsilon(K, H, C), for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## is a cyclotomic class of q=|Fq| modulo n=[K:H] containing generators of K/H.
## The list ltrace contains information about the traces of the n-th roots of 1.   
##
InstallMethod( IdempotentBySubgroups,
    "for pairs of subgroups, one cyclotomic class and traces, mapping and group element", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList, IsList, IsList ],
#     IsMapping, IsMultiplicativeElementWithInverse ], 
    0,
function( FqG, K, H, c, ltrace, arg6 )
local   Fq,     # Field
        q,      # Order of field Fq
        n,      # Order of K/H
        cc,     # Set of cyclotomic classes of q module n
        supp,   # Support of the output
        coeff,  # Coefficients of the output
        d,      # Cyclotomic class of q module n   
        tr,     # Element of ltrace
        epi,    # Extra argument
        gq;     # Extra argument

# In this case the conditions are not necesary because this function
# is used as local function of PCIs

# Program
epi:=arg6[1];
gq:=arg6[2];
Fq := LeftActingDomain( FqG );
q := Size( Fq );
n := Index( K, H );
cc := CyclotomicClasses( q, n );
supp := [];
coeff := [];
for d in cc do
    tr := ltrace[ 1+(-c[1]*d[1] mod n) ];
    Append( supp, PreImages( epi, List( d, x -> gq^x ) ) );
    Append( coeff, List( [ 1 .. Size( H ) * Size( d ) ], x -> tr ) );    
od;
coeff:=Inverse(Size(K)*One(Fq))*coeff;
return ElementOfMagmaRing( FamilyObj(Zero(FqG)), Zero(Fq), coeff, supp );
end);


#############################################################################
##
#M IdempotentBySubgroups( FqG, K, H, C )
##
## The function IdempotentBySubgroups computes epsilon( K, H, C ) for H and K
## subgroups of G such that H is normal in K and K/H is cyclic group, and C 
## is the q=|Fq|-cyclotomic class modulo n=[K:H] containing c
##
InstallOtherMethod( IdempotentBySubgroups,
    "for pairs of subgroups and one cyclotomic class", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsList ], 
    0,
function( FqG, K, H, C )
local   G,      # Group
        Fq,     # Field
        q,      # Order of field Fq
        N,      # Normalizer of H in G
        epi,    # N -->N/H
        QKH,    # K/H
        n,      # Order of K/H
        gq,     # Generator of K/H
        g,      # Representative of the preimage of gq by epi
        cc,     # Set of cyclotomic classes of q module n
        a,      # Primitive n-th root of 1 in an extension of Fq
        d,      # Cyclotomic class of q module n
        tr,     # Trace
        coeff,  # Coefficients of the output
        supp,   # Coefficients of the output
        o;      # The  multiplicative order of q module n

# Initialization
G := UnderlyingMagma(FqG);
Fq := LeftActingDomain(FqG);
q := Size(Fq);
n := Index(K,H);

# First we check that FqG is a finite group algebra over field finite
# Then we check if K is subgroup of G, H is a normal subgroup of K

if not IsSubgroup( G, K ) then
    Error("Wedderga: <K> should be a subgroup of the underlying group of <FG>\n");
elif not( IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("Wedderga: <H> should be a normal subgroup of <K>\n");
elif not IsCyclic( FactorGroup( K, H ) )then
    Error("Wedderga: <K> over <H> should be be cyclic \n");
elif not IsCyclotomicClass(q,n,C) then
    Error("Wedderga: \n <C> should be a cyclotomic class module the index of <H> on <K>\n");
fi; 


cc := CyclotomicClasses(q,n);

# Program

if K=H then
    return AverageSum( FqG, H );
fi;
N := Normalizer( G, H );
epi := NaturalHomomorphismByNormalSubgroup( N, H );
QKH := Image( epi, K );
# We guarantee that QKH is cyclic so we can randomly obtain its generator
repeat
  gq := Random(QKH);
until Order(gq) = Size(QKH);
o := Size( cc[2] );
a := BigPrimitiveRoot(q^o)^((q^o-1)/n);
supp := [];
coeff := []; 
for d in cc do
    tr := BigTrace(o, Fq, a^(-C[1]*d[1]) );
    Append( supp, PreImages( epi, List( d, x -> gq^x ) ) );
    Append( coeff, List( [ 1 .. Size( H ) * Size( d ) ], x -> tr ) );    
od;
coeff:=Inverse(Size(K)*One(Fq))*coeff;

# Output
return ElementOfMagmaRing(FamilyObj(Zero(FqG)), Zero(Fq), coeff, supp);
end);


#############################################################################
##
#M IdempotentBySubgroups( FqG, K, H, c ) 
##
## The function SimpleAlgebraByStrongSP verifies if ( H, K ) is a SSP of G and
## c is an integer coprime with n=[K:H]. 
## If the answer is positive then returns SimpleAlgebraByStrongSP(FqG, K, H, C) where
## C is the cyclotomic class of q=|Fq| module n=[K:H] containing c.
##
InstallOtherMethod( IdempotentBySubgroups, 
    "for semisimple finite group algebras", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra, IsGroup, IsGroup, IsPosInt ], 
    0,
function( FqG, K, H, c )
local   G,      # Group
        n,      # Index of H in K
        q,      # Size of Fq
        j,      # integer module n
        C;      # q-cyclotomic class module [K,H] containing c

G := UnderlyingMagma( FqG );
n := Index( K, H );
q:=Size( LeftActingDomain( FqG ) );
C := [ c mod n];
j:=q*c mod n;
while j <> C[1] do
  Add( C, j );
  j:=j*q mod n;
od;  
    return IdempotentBySubgroups( FqG, K, H, C );
end);



#############################################################################
##
## AverageSum( FG, X )
##
## The function AverageSum computes the element of FG defined by 
## ( 1/|X| )* sum_{x\in X} x 
##
InstallMethod( AverageSum,
    "for subset", 
    true, 
    [ IsGroupRing, IsObject ], 
    0,
function(FG,X)
local   G,      # Group
        n,      # Size of the set X
        F,      # Field
        one,    # One of F
        quo;    # n^-1 in F

# Initialization        
if not IsFinite( X ) then
  Error("Wedderga: <X> must be a finite set !!!\n"); 
fi;
G := UnderlyingMagma( FG );
if not IsSubset( G, X ) then
  Error("Wedderga: The group algebra <FG> does not correspond to <X>!!!\n"); 
fi;
F := LeftActingDomain( FG );
one := One( F );
n := Size( X );
# Program
quo := Inverse( n * one );
if quo=fail then
  Error("Wedderga: The order of <X> must be a unit of the ring of coefficients!!!\n"); 
else
  return ElementOfMagmaRing( FamilyObj( Zero( FG ) ),
                             Zero( F ),
                             List( [1..n] , i -> quo),
                             AsList(X) );
fi;                             
end);


#############################################################################
##
#E
##
