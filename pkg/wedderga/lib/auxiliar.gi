#############################################################################
##
#W  auxiliar.gi           The Wedderga package            Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              Ángel del Río
##
#H  $Id: auxiliar.gi,v 1.26 2008/09/18 11:09:15 alexk Exp $
##
#############################################################################


#############################################################################
##
#P IsSemisimpleRationalGroupAlgebra( FG )
##  
## The function checks whether a group ring is a rational group algebra 
## of a finite group
##
InstallImmediateMethod( IsSemisimpleRationalGroupAlgebra,
    IsGroupRing,
    0,
R -> IsRationals(LeftActingDomain(R)) and IsFinite(UnderlyingMagma(R))); 


#############################################################################
##
#P IsSemisimpleZeroCharacteristicGroupAlgebra( FG )
##  
## The function checks whether a group ring is a group algebra 
## of a finite group over the field of characteristic zero
##
InstallImmediateMethod( IsSemisimpleZeroCharacteristicGroupAlgebra,
    IsGroupRing, 
    0,
R -> Characteristic(LeftActingDomain(R))=0 and IsFinite(UnderlyingMagma(R))); 


#############################################################################
##
#P IsCFGroupAlgebra( FG )
##  
## The function checks whether a group ring is a group algebra of a finite
## group over a cyclotomic field
##
InstallImmediateMethod( IsCFGroupAlgebra,
    IsGroupRing, 
    0,
R ->  IsField(LeftActingDomain(R)) and IsCyclotomicField(LeftActingDomain(R)) and IsFinite(UnderlyingMagma(R))); 

#############################################################################
##
#P IsSemisimpleANFGroupAlgebra( FG )
##  
## The function checks whether a group ring is a group algebra of a finite
## group over an abelian number field
##
InstallImmediateMethod( IsSemisimpleANFGroupAlgebra,
    IsGroupRing, 
    0,
R -> IsField(LeftActingDomain(R)) and IsAbelianNumberField(LeftActingDomain(R)) and IsFinite(UnderlyingMagma(R))); 


#############################################################################
##
#P IsSemisimpleFiniteGroupAlgebra( FG )
##  
## The function checks whether a group ring is a semisimple group algebra
## of a finite group over a finite field
##
InstallImmediateMethod( IsSemisimpleFiniteGroupAlgebra,
    IsGroupRing, 
    0,
function( FG )
	local   F,      # Field
    	    G;      # Group

	F := LeftActingDomain( FG );
	G := UnderlyingMagma( FG );
       
	return IsField( F ) and IsFinite( F ) and IsFinite( G ) and 
    	   Gcd( Size( F ), Size( G ) ) = 1;
end); 


#############################################################################
##
#M IsCompleteSetOfPCIs( R, ListPCIs )
##
## The function checks if the sum of given idempotents of a ring R is the
## identity element of R. It is supposed to be used to check if a given 
## list of PCIs of R is complete.
##
InstallMethod( IsCompleteSetOfPCIs,
    "for list of idempotents", 
    true, 
    [ IsRing, IsList ], 
    0,
function( R, ListPCIs )
    local x;
    if not ForAll( ListPCIs, x -> x in R ) then
        Error("Wedderga: An element of <ListPCIs> does not belong to <R>!!!\n");
    else
        return Sum( ListPCIs ) = One( R ) and ForAll( ListPCIs, x -> x=x^2 );
    fi;
end);

#############################################################################
##
#M IsCompleteSetOfOrthogonalIdempotents( R, List )
##
## The function checks if List is a complete set of orthogonal central 
## idempotents of a ring R.
##
InstallMethod( IsCompleteSetOfOrthogonalIdempotents,
    "for list of idempotents", 
    true, 
    [ IsRing, IsList ], 
    0,
function( R, ListPCIs )
    if not ForAll( ListPCIs, x -> x in R ) then
        Error("Wedderga: An element of <ListPCIs> does not belong to <R> !!!\n");
    elif ForAny( ListPCIs, IsZero ) then
        Error("Wedderga: Zero element in  <ListPCIs> !!!\n");
    else
        return Sum( ListPCIs ) = One( R ) and 
                    ForAll( [1..Length(ListPCIs)], i -> 
                        ListPCIs[i]= ListPCIs[i]^2 and 
                        ForAll ( [(i+1)..Length(ListPCIs)], j -> 
                            ListPCIs[i]* ListPCIs[j] = Zero(R) ) ) ;
    fi;
end);




#############################################################################
##
#F IsStrongShodaPair( G, K, H )
##
## The function IsStrongShodaPair verifies if (H,K) is a SSP of G
##
InstallMethod( IsStrongShodaPair,
    "for a group and two subgroups", 
    true,
    [ IsGroup, IsGroup, IsGroup ], 
    0,
function( G, K, H )
local   QG,
        NH,
        Eps,
        NdK,
        eGKH1,
        RTNH,
        i,
        g,
        RTNdK,
        nRTNdK,
        Epi,
        NHH,
        KH,
		zero;

# First verifies if H, K are subgroups of G and K is a normal subgroup of K
if not ( IsSubgroup( G, K ) and IsSubgroup( K, H ) ) then
    Error("Wedderga: <G> must contain <K> and <K> must contain <H> !!!\n");
fi;

if not IsNormal( K, H ) then
    Info(InfoWedderga, 2, "Wedderga: IsSSP: <H> is not normal in <K>");
    return false;
fi;

# Now, if K/H is the maximal abelian subgroup in N/H,
# where N is the normalizer of H in G

NH:=Normalizer(G,H);

if not(IsNormal( NH, K ) ) then
    Info(InfoWedderga, 2, "Wedderga: IsSSP: <K> is not normal in N_<G>(<H>)");
    return false;
fi;

Epi:=NaturalHomomorphismByNormalSubgroup( NH, H ) ;
NHH:=Image( Epi, NH ); #It is isomorphic to the factor group NH/H.
KH:=Image( Epi, K ); #It is isomorphic to the factor group K/H.

if not(IsCyclic(KH)) then
    Info(InfoWedderga, 2, "Wedderga: IsSSP: <K>/<H> is not cyclic");
    return false;
fi;

if Centralizer( NHH, KH ) <> KH then
    Info(InfoWedderga, 2, "Wedderga: IsSSP: <K>/<H> is not maximal ",
                     "abelian in N_<G>(<H>)");
    return false;
fi;

#Now (SSS3)
QG := GroupRing( Rationals, G );
zero := Zero( QG );
Eps := IdempotentBySubgroups( QG, K, H );
NdK := Normalizer( G, K );

if NdK<>G then
    RTNH := RightTransversal( NdK, NH );
    eGKH1 := Sum( List( RTNH, g -> Eps^g ) ); 
    RTNdK := RightTransversal( G, NdK );
    nRTNdK:=Length(RTNdK);
    for i in [ 2 .. nRTNdK ] do
        g:=RTNdK[i];
        if eGKH1*eGKH1^g <> zero then
            Info(InfoWedderga, 2, 
                 "Wedderga: IsSSP: The conjugates of epsilon are not orthogonal");
            return  false;
        fi;
    od;
fi;

return true;

end);


#############################################################################
##
#M Centralizer( G, a )
##
## The function Centralizer computes the centralizer of an
## element of a group ring in a subgroup of the underlying group
##
InstallMethod( Centralizer,
    "Wedderga: for a subgroup of an underlying group and a group ring element",
    function( F1, F2 )    
      return IsBound( F2!.familyMagma ) and
             IsIdenticalObj( F1, F2!.familyMagma);
    end,  
    [ IsGroup, IsElementOfFreeMagmaRing ], 
    0,
function( G, a ) 
local   C,
        leftover,
        cosrep,
        g, 
        h;

C := TrivialSubgroup( G );
cosrep := [ One(G) ];
leftover := Difference( G, C );
while leftover <> [] do
    g := leftover[1];
    if a^g = a then 
        C := Subgroup( G, Union( GeneratorsOfGroup( C ), [ g ] ) );
    else 
        Add( cosrep, g );
    fi;
    leftover := Difference( leftover, 
    Flat( List ( Set( List( cosrep, h -> RightCoset( C, h ) ) ), AsList ) ) );
od;
return C;
end);


#############################################################################
##
#M OnPoints( a, g )
##
## The function OnPoints(a,g) computes the conjugate a^g where a is an 
## element of the group ring FG and g an element of G. You can use the
## notation a^g to compute it as well.
##
InstallMethod( \^,
    "Wedderga: for a group ring element and a group element",
    function( F1, F2 )
      return IsBound( F1!.familyMagma ) and 
             IsIdenticalObj( ElementsFamily( F1!.familyMagma ), F2 );
    end,
    [ IsElementOfFreeMagmaRing, IsMultiplicativeElementWithInverse ], 
    0,
function( a, g )
local   coeffsupp,
        coeff,
        supp,
        lsupp;

coeffsupp := CoefficientsAndMagmaElements(a);
lsupp := Size(coeffsupp)/2;
supp := List( [ 1 .. lsupp ], i -> coeffsupp [ 2*i-1 ]^g );
coeff := List([ 1 .. lsupp ], i -> coeffsupp[2*i] );

return ElementOfMagmaRing( FamilyObj( a ) ,
                                Zero( a ),
                                coeff,
                                supp);
end);


#############################################################################
##
## CyclotomicClasses( q, n )
##
## The function CyclotomicClasses computes the set of the Cyclotomic Classes
## of q module n 
##
InstallMethod( CyclotomicClasses,
    "for pairs of positive integers", 
    true, 
    [ IsPosInt, IsPosInt ], 
    0,
function(q, n)
local   cc,     # List of cyclotomic classes
        ccc,    # Cyclotomic Class
        i,      # Representative of cyclotomic class
        leftover,  # List of integers
        j;      # Integer
        
# Initialization     
if Gcd( q, n ) <> 1 then
    Error("Wedderga: <q> and <n> should be relatively prime"); 
fi;

#Program
cc := [ [0] ];
leftover:=[ 1 .. n-1 ];
while leftover <> [] do
    i := leftover[ 1 ];
    ccc := [ i ];
    j:=q*i mod n;
    while j <> i do
        Add( ccc, j );
        j:=j*q mod n;
    od;
    Add( cc, ccc );
    leftover := Difference( leftover, ccc );
od;
return cc;
end);


#############################################################################
##
## BigPrimitiveRoot( q )
##
## The function BigPrimitiveRoot computes a primitive root of the finite 
## field of order q.
##
InstallMethod( BigPrimitiveRoot,
    "for a prime power", 
    true, 
    [ IsPosInt ], 
    0,
function(q)
local   Fq,      # The finite field of order q
        factors, # prime factors of q
        p,       # The only prime divisor of q
        o,       # q = p^o
        cp,      # The conway polynomial 
        pr;      # A primitive root of Fq 

# Initialization     
if not IsPrimePowerInt( q ) then
    Error("Wedderga: The input must be a prime power!!!"); 
fi;

#Program
if q<=2^16 then
    Fq := GF(q);
    pr := PrimitiveRoot(Fq);
else
    factors := FactorsInt(q);
    p:=factors[1];
    o:=Size(factors);
    # If q^o is too big then gap never finish to compute the ConwayPolynomial.
    # If there is not cheap ConwayPolynomial, random primitive will be enough
    if IsCheapConwayPolynomial(p,o) then
      cp := ConwayPolynomial(p,o);
    else
      cp := RandomPrimitivePolynomial(p,o);  
    fi;  
    Fq := GF(p, cp);
    pr := RootOfDefiningPolynomial(Fq);
fi;
return pr;
end);


#############################################################################
##
## BigTrace( o, Fq, a )
##
## The function BigTrace returns the trace of the element a in the field 
## extension Fq^o/Fq.
##
InstallMethod( BigTrace,
    "for elements of finite fields", 
    true, 
    [ IsPosInt, IsField, IsObject ], 
    0,
function( o, Fq, a )
local   q,      # The order of the field Fq
        t, y,   # Elements of finite field
        i;      # Integer
        
# Program               
q := Size(Fq);
t := a;
y := a;
for i in [ 1 .. o-1 ] do
    y := y^q;
    t := t + y;
od;
if not(IsFFE(t)) then
    t := ExtRepOfObj(t)[1];
fi;
  return t;
end);


#############################################################################
##
#P IsStronglyMonomial( G )
## ## The function checks whether a group is strongly monomial
##
InstallMethod( IsStronglyMonomial,
    "for finite groups",
    true,
  [ IsGroup ],
  0,
function( G )

local QG ;
 if IsFinite(G) then
#  if IsSupersolvable(G) or IsAbelian(DerivedSubgroup(G)) then
   if IsAbelian(SupersolvableResiduum(G)) then
      return true;
  elif IsMonomial(G) then
      QG := GroupRing( Rationals, G );
#     return IsCompleteSetOfPCIs( QG ,
#            StrongShodaPairsAndIdempotents( QG ).PrimitiveCentralIdempotents );
      return Sum( StrongShodaPairsAndIdempotents( QG ).PrimitiveCentralIdempotents ) = One( QG );
  else
      return false;
  fi;
else
  Error("Wedderga: The input should be a finite group\n");
fi;
end);


#############################################################################
##
#M IsCyclotomicClass( q, n, C )
##
## The function IsCyclotomicClass checks if C is a q-cyclotomic class module n
##
InstallMethod( IsCyclotomicClass,
	"for two coprime positive integers and a list of integers", 
	true, 
	[ IsPosInt, IsPosInt, IsList ], 
	0,
function( q, n, C )
    local c,C1,j;

c:=C[1];

if n=1 then 
    return C=[0];
elif Gcd(q,n)<> 1 then
    Error("Wedderga: <q> and <n> should be coprime");
elif c >= n then
    return false;
else 
    C1:=[c];
    j:=q*c mod n;
    while j <> c do
      Add( C1, j );
      j:=j*q mod n;
    od;  
    return Set(C)=Set(C1);
fi;

end);


#############################################################################
##
#P IsCyclGroupAlgebra( FG )
##  
## The function checks whether a group is strongly monomial
##
InstallMethod( IsCyclGroupAlgebra, 
    "for semisimple group algebras", 
    true, 
    [ IsGroupRing ], 
    0,
function( FG )

local G ;

G := UnderlyingMagma(FG);

if not(IsSemisimpleFiniteGroupAlgebra(FG) or IsSemisimpleZeroCharacteristicGroupAlgebra(FG)) then 
  Error("Wedderga: The input should be a semisimple group algebra \n",
        "over a finite or a zero characteristic field \n");
fi;

if IsSemisimpleFiniteGroupAlgebra(FG) or 
   IsStronglyMonomial(G) or 
   ForAll( WeddDecomp(FG), x-> not IsList(x) ) then 
    return true;
else
    return false;
fi;
end);


#############################################################################
##
## SizeOfSplittingField( char, p )  
##
## The function SizeOfSplittingField returns the SizeOfFieldOfDefinition 
## for the character char and the prime p
##
InstallMethod( SizeOfSplittingField,
    "for character of finite group and prime number", 
    true, 
    [ IsCharacter, IsPosInt ], 
    0,
function( char, p )

local size,    #  The power of p
      cc,      #  Conjugacy Classes
      value,   #  Element in ValuesOfClassFunction(char)
      m,       #  counter
      image;   #  Galois Group

size := 1;
cc := ConjugacyClasses( UnderlyingCharacterTable( char ) );
for value in ValuesOfClassFunction(char) do
   m:= 1;
   image:= GaloisCyc( value, p );
   while image <> value do
       m:= m+1;
       image:= GaloisCyc( image, p );
   od;      
   size := Lcm( size , m );
od;

return p^size;

end);


#############################################################################
##
#E
##
