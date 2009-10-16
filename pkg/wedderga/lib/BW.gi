#############################################################################
##
#W  BW.gi                 The Wedderga package            Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              Ángel del Río
##
#H  $Id: BW.gi,v 1.17 2007/08/29 12:05:09 alexk Exp $
##
#############################################################################


###############################################################################
###############                      BW               #########################
###############################################################################


#############################################################################
##
#O LinCharByKernel( K, H )
##
## Returns a linear character of K with kernel H
##
InstallMethod( LinCharByKernel,
    "for subgroups", 
    true, 
    [ IsGroup , IsGroup ], 
    0,
function(K,H)

local 
cc, Epi, KH, ok, k, elKH, exp, chi;

cc := ConjugacyClasses( K );
Epi := NaturalHomomorphismByNormalSubgroup( K, H ) ;
KH := Image(Epi,K);
ok := Index(K,H);
if ok = 1 then 
  return ClassFunction( K, List( cc, x->1 ) );
else 
  repeat
    k := Random(KH);
  until ok = Order(k);
  elKH := AsSet( KH );
  exp := List( [0..ok-1], x -> Position(elKH,k^x) );
  chi := ClassFunction( K, List( cc, x -> 
    E(ok)^(Position(exp,Position(elKH, Image( Epi, Representative(x))))-1)));
  return chi;
fi;
end);


#############################################################################
##
#O BWNoStMon( G )
##
## Returns a list of 4-tuples:
## First position  = an irreducible not strongly monomial character of G 
##                   (a representative from his rationalized class) 
## Second position = character field of chi
## Third position  = List of strongly Shoda triples with list of primes
## Fourth position = Galois group of CF(exponent(G))/character field of chi
##
InstallMethod( BWNoStMon ,
    "for finite groups", 
    true, 
    [ IsGroup and IsFinite ], 
    0,

function(G)

local 
    irr,        	# irreducible characters
    ratirr,	    	# rational irreducible characters
    classirr,   	# irreducible characters classified into rationalized classes
    chi,	    	  # one irreducible character
    ratchi,       # rationalized of chi
    L,          	# Splitting Field of G
    sspsub,     	# List of pairs [p,SST] where p is a set of primes and SST is a 
    	    	      # strongly Shoda triple such that the simple algebra associated
    	    	      # to SST is the p-part of one Wedderburn component of QG
    control,    	# A list of integers controlling the position in classirr
                	# still not covered by sspsub
    GalList,      # the list of Galois Groups Gal(L/character fields) 
    sylow,      	# the list of Sylow subgroups of the elements in GalList
    primes,     	# a list of lists of primes controlling the p-parts still not covered 
    i,          	# counter
    cf,         	# character field of chi
    Gal,        	# Gal(L/cf)
    d,          	# integer
    pr,         	# prime divisors of d
    sub,        	# Conjugacy Classes of subgroups of G
    nsub,       	# Cardinality of sub
    subcounter, 	# counter for sub
    M,          	# subgroup of G
    ssp,        	# strongly Shoda pairs of M
    m,          	# Size of ssp
    sspcounter, 	# counter for ssp
    K,H,        	# strongly Shoda pair of M
    psi,        	# the strongly monomial character of M given by M
    cfpsi,      	# character field of psi
    gencfpsi,   	# generators of character field of psi
    dropcontrol,	# list to be drop from control
    controlcounter,	# control counter
    dropprimes,	    # list of primes to be drop from primes
    remainingprimes,# counter of remaining primes
    primecounter,   # primes counter
    p,          	# element of primes[controlcounter]
    P,          	# p-Sylow subgroup of GalList[controlcounter]
    genP,       	# set of generators of P
    irrcounter,	  # irreducible characters counter
    sprod;      	# (chi_M,psi)


# Classifying the irreducible characters into rational classes

  irr := Filtered(Irr(G),chi->chi[1]>1);
  ratirr := Difference(
              RationalizedMat( irr ),
              RationalizedMat( List( StrongShodaPairs( G ), x ->
                                     LinCharByKernel( x[1], x[2] )^G ) ) );
  classirr := List(ratirr,x->[]);
  for chi in irr do
      ratchi := RationalizedMat([chi])[1];
      if ratchi in ratirr then 
        Add(classirr[Position(ratirr,ratchi)],chi);
      fi;
  od;

# Initialization of lists

  L := CF(Exponent(G));
  sspsub := [];
  control := [];
  GalList := [];
  sylow := [];
  primes := [];
  for i in [1..Length(ratirr)] do
      chi := classirr[i][1];
      cf := Field( chi );
      Gal := GaloisGroup(AsField(cf,L));
      Add(GalList,Gal);
      d:=Gcd(Size(Gal),chi[1]);
      if  d = 1 then 
          Add(sspsub,[chi,cf]);
          Add(primes,[]);
          Add(sylow,[]);
      else
          Add(sspsub,[chi,cf,[],Gal]);
          pr := Set(FactorsInt(d));
          Add(primes,pr);
          Add(sylow,List(pr,p->SylowSubgroup(Gal,p)));
          Add(control,i);
      fi;    
  od;

sub:=ConjugacyClassesSubgroups(G);
if ForAny( [1 .. Length(sub)-1 ], i -> 
           Size(Representative(sub[i])) > Size(Representative(sub[i+1])) ) then
  sub:=ShallowCopy(ConjugacyClassesSubgroups(G));
  Sort(sub, function(v,w) return Size(Representative(v))<Size(Representative(w)); end);
fi;
nsub := Size(sub);
subcounter := nsub-1;
while Sum(List(primes,Length)) > 0 do
    M:=Representative( sub[ subcounter ] );
    ssp := StrongShodaPairs(M);
    m := Length(ssp);
    sspcounter := 1;
    while sspcounter <= m and Sum(List(primes,Length))> 0 do
        K := ssp[sspcounter][1]; 
        H := ssp[sspcounter][2];
        psi := LinCharByKernel(K,H)^M;
        cfpsi := Field(psi);
        gencfpsi := GeneratorsOfField(cfpsi);
        dropcontrol := [];
        for controlcounter in control do 
            dropprimes := [];
            chi := classirr[controlcounter][1];
            remainingprimes := Length(primes[controlcounter]);
            primecounter := 1;
            while primecounter <= remainingprimes do
                p := primes[controlcounter][primecounter];
                P := sylow[controlcounter][primecounter];
                genP := GeneratorsOfGroup(P);
                if ForAll(Cartesian(genP,gencfpsi), x -> x[2]^x[1]=x[2]) then 
                    irrcounter := 1;
                    while irrcounter <= 
Length(classirr[controlcounter]) and dropprimes <> primes[controlcounter] do
                        chi := classirr[controlcounter][irrcounter];
                        sprod := ScalarProduct( Restricted(chi,M) , psi );
                        if sprod mod p <> 0 then
                            Add(dropprimes,p);
                        fi;
                        irrcounter := irrcounter+1;
                    od;
                fi;
                primecounter := primecounter+1;
            od;
            primes[controlcounter] := Difference(primes[controlcounter],dropprimes);
            if dropprimes <> [] then
            Add(sspsub[controlcounter][3],[M,K,H,dropprimes]);
            fi;
            if primes[controlcounter] = [] then 
                control := Difference(control,[controlcounter]);
            fi;
        od;
    sspcounter := sspcounter + 1;
    od;
    subcounter:=subcounter-1;
od;

return sspsub;

end);


###############################################################################
####################                 cocycle           ########################
###############################################################################


#############################################################################
##
#O ReductionModnZ( n, m )
##
## Projection Zn^* ----> Zm^* for m|n
##
InstallMethod( ReductionModnZ ,
    "for positive integers ", 
    true, 
    [ IsPosInt , IsPosInt ], 
    0,

function(n,m)

local UZn,UZm;

if not IsInt(n/m) then 
  return fail;
fi;
  
UZn := Units( ZmodnZ(n) );
UZm := Units( ZmodnZ(m) );

return MappingByFunction( UZn, UZm,
         function(x) 
           return ZmodnZObj( Int(x), m ); 
         end);
end);


#############################################################################
##
#O GalToInt( G )
##
## Returns an isomorphism Gal(Q(xi_n)/Q)  ---->  Zn^*
##
InstallMethod( GalToInt ,
    "for Galois groups of cyclotomic extensions", 
    true, 
    [ IsGroup ], 
    0,

function(G)

local F,con,genF,powgenF,i,UZcon;

F:=Source(One(G));
con:=Conductor(F);
genF := E(con);
powgenF := [genF];
for i in [1..con-1] do
    Add(powgenF,powgenF[i]*genF);
od;
UZcon := Units(ZmodnZ(con));

return MappingByFunction(G,UZcon,
  function(x)
    return ZmodnZObj(Position(powgenF,E(con)^x),con);
    end);
    
end);


###############################################################################
##
#O CocycleByData( exp, Gal, cf, M, K, H, div)
##
## Returns a pair formed by a positive integer cond and 
## the (additive) twisting for a crossed product algebra over 
## Gal=Galcf(Q(cond)/cf) associated to the triple (M,K,H) to the div power
##
InstallGlobalFunction(CocycleByData,function( exp, Gal, cf, M, K, H, div)

local   

out,        # output, a cocycle of Galcf with coefficients in <E(cond)>
N,          # Normalizer of H in M
ok;         # Order of K/H
#cond;       # Lcm(Conductor(cf),ok)

ok := Index(K,H);
# cond:=Lcm(Conductor(cf),ok);

N := Normalizer(M,H);


if N=K then

  ok := 1;
  out:=function(a,b) return 0; end;

else # if N_M(H) <> K    
 
  out:=function(a,b) # returns the twisting for the croosed product 
                     # algebra over Galcf given by the triple (M,K,H)
  local
  
    Epi,        # N --> N/H
    NH,         # NH/H
    KH,         # K/H
    k,          # Generator of K/H
    bij,bijunit, pow,
    i,          # Loop controller
    Epi2,       # NH --> NH/KH
    NdK,        # N/K
    coc,        # Twisting for the crossed product over NdK
    Uok,        # Units(ZmodnZ(ok))
    funNdK,     # Embedding of NdK in Uok,
    GalSSP,     # Subgroup(Uok,Image(funNdK))
    cocSSP,     # cocycle in Z^2(GalSSP,<E(ok)>)
    Galcf,      # Subgroup(Uok,Image(GalToInt(Galcf)));
    Galcomp,    # Intersection(GalSSP,Galcf);
    T;          # Right Transversal of Galcomp in Galcf 
    
    
    Epi := NaturalHomomorphismByNormalSubgroup( N, H ) ;
    NH  := Image(Epi,N);
    KH  := Image(Epi,K);
    repeat
        k  := Random(KH);
    until Order(k) = ok;
    Epi2:=NaturalHomomorphismByNormalSubgroup( NH, KH ) ;
    NdK:=Image(Epi2,NH);
    bij := MappingByFunction(ZmodnZ(ok),KH,i->k^Int(i));
    

    # The cocycle in Z^2(NdK,<E(ok)>)
    
       
    coc := function(a,b)
       return PreImagesRepresentative(bij,
                              PreImagesRepresentative(Epi2,a*b)^-1 *
                              PreImagesRepresentative(Epi2,a) *
                              PreImagesRepresentative(Epi2,b) );
       end;   
          
#########################################################################

    # The cocycle in Z^2(GalSSP,<E(ok)>)

    Uok:=Units(ZmodnZ(ok));
    bijunit := MappingByFunction(Uok,KH,i->k^Int(i));

    funNdK := MappingByFunction(NdK,Uok,
        function(n) 
            return PreImagesRepresentative(bij,
                                 k^PreImagesRepresentative( Epi2 , n ) );
              end
              );
                      
    GalSSP := Subgroup(Uok,Image(funNdK));

    cocSSP := function(a,b)
                return 
coc(PreImagesRepresentative(funNdK,a),PreImagesRepresentative(funNdK,b));
                end;
    
#########################################################################
    
    # The cocycle in Z^2(Galcf,<E(cond)>)
    
    Galcf:=Subgroup(Uok,Image(ReductionModnZ(exp,ok),Gal));
    
    if IsSubset(GalSSP,Galcf) then
      return cocSSP(a,b);
    else
      Galcomp := Intersection(GalSSP,Galcf);
      pow := 1/Index(Galcf,Galcomp) mod div;
      T := 
      List(RightTransversal(Galcf,Galcomp),i->CanonicalRightCosetElement(Galcomp,i));
           
      return
        Sum(T,t-> cocSSP(t*a*CanonicalRightCosetElement(Galcomp,t*a)^-1,
        CanonicalRightCosetElement(Galcomp,t*a)*b*
        CanonicalRightCosetElement(Galcomp,t*a*b)^-1)*t^-1
            )*pow;
    fi;  
  end;
fi;

return [ok,out];

end);


#############################################################################
##
#E
##
