#############################################################################
##
#W  others.gi              The Wedderga package           Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              Ángel del Río
##
#H  $Id: others.gi,v 1.27 2008/01/08 12:49:41 alexk Exp $
##
#############################################################################


#############################################################################
##
#A ShodaPairsAndIdempotents( QG )
##
## The attribute ShodaPairsAndIdempotents of the rational group algebra QG 
## returns a record with components ShodaPairs and PCIsBySP
## ShodaPairs = list of SP that covers the complete set of primitive 
##       central idempotents of QG realizable by SPs, 
## PCIsBySP = list of PCIs of QG realizable by SPs.
## 
InstallMethod( ShodaPairsAndIdempotents, 
    "for rational group algebra", 
    true, 
    [ IsGroupRing ], 
    0,
function(QG) 

local   G,          #The group
        CCS,        #The conjugacy classes of subgroups
        LCCS,       #The length of CCS
        one,        #1 of QG
        Es,         #The list of primitive central idempotents  
        SEs,        #The sum of the elements of Es
        e,          #Idempotent
        H,          #Subgroup of G
        i,          #Counter
        SearchingKForSP,#Function to search a K for a given H  
        SPs;

#begin of functions 

#The following function search an element K such that 
#(K,H) is a SP
   
    SearchingKForSP:=function( H )
    local   
        NH,         #Normalizer of H in G
        Epi,        #NH --> NH/H        
        NHH,        #NH/H
        L,          #Centre of NHH
        K,          #The subgroup searched
        e,          #a*e(G,K,H) for some of the searched K
                    # and a rational
        KH,         #K/H
        X;          #a subset of NHH

    NH:=Normalizer(G,H);
    Epi:=NaturalHomomorphismByNormalSubgroup( NH, H ) ;
    NHH:=Image(Epi,NH);
    if IsAbelian(NHH) then
        e := PrimitiveCentralIdempotentBySP( QG, NH, H );
        if e=fail then
            return fail; 
        else 
            return [[NH,H],e];
        fi;
    else 
        L:=Centre(NHH);
        if IsCyclic(L) then #This guaranties (S1) and (S2)
            X:=Difference(Elements(NHH),Elements(L));
            while X<>[] do
                KH:=Subgroup(NHH,Union(L,[X[1]]));
                K:=PreImages(Epi,KH);
                e:=PrimitiveCentralIdempotentBySP( QG, K, H ); 
                if e<>fail then
                    return [[K,H],e];
                fi;
                X:=Difference(X,KH);
            od;
        fi;
        return fail;                  
    fi;
    end;     

#end of functions

#PROGRAM
    
#We start checking if QG is a rational group algebra of a finite group

    if not IsSemisimpleRationalGroupAlgebra(QG) then
        Error("Wedderga: The input must be a rational group algebra!!!\n");
    fi;

#Initialization

    G:=UnderlyingMagma(QG);
    CCS:=ConjugacyClassesSubgroups(G);
    # here we dont' take care how CCS is ordered
    LCCS:=Length(CCS);
    one:=One(QG);
    Es:=[ ];
    SPs:=[];
    SEs:=Zero(QG);
    i:=LCCS;   

#Main loop
    if Size(G)=1 then
        return [[ [G,G] , One(QG)] ];
    fi;
    while SEs<>one and i>=1 do 
        H:=Representative(CCS[i]); 
        e:=SearchingKForSP( H ); 
        if e<>fail then
                # if IsZero( SEs*e[2] ) then  # slow
                if not ( e[2] in Es ) then    # fast
                SEs:= SEs + e[2];
                Add(Es,e[2]);
                Add(SPs,e[1] );
            fi;    
        fi;
        i:=i-1;
    od;
    
#Output

  return rec( 
    ShodaPairs := SPs, 
    PCIsBySP := Es);

end);




#############################################################################
##
#F PrimitiveCentralIdempotentsBySP( QG )
##
## The function computes the primitive central idempotents of the form 
## a*e(G,K,H) where a is a rational number and (H,K) is a SP. 
## The sum of the PCIs obtained is 1 if and only if G is monomial
## This function is for rational group algebras (otherwise you will not
## use ShodaPairsAndIdempotents)
##
InstallGlobalFunction(PrimitiveCentralIdempotentsBySP, 
function(QG) 
local G;

G := UnderlyingMagma( QG );
if not(IsMonomial(G)) then 
   Print("Wedderga: Warning!!\nThe output is a NON-COMPLETE list of prim. central idemp.s of the input! \n");
fi;

return ShodaPairsAndIdempotents( QG ).PCIsBySP; 
end);


#############################################################################
##
#M PrimitiveCentralIdempotentBySP( QG, K, H )
##
## The function PrimitiveCentralIdempotentBySP checks if (H,K) is a SP of G 
## and in that case compute the primitive central idempotent of the form 
## alpha*e(G,K,H), where alpha is a rational number.
##
InstallMethod( PrimitiveCentralIdempotentBySP,
   "for pairs of subgroups", 
   true, 
   [ IsGroupRing, IsGroup, IsGroup ],
   0,
function(QG,K,H)
local   eGKH,       # Function for eGKH
        K1, H1,     # Subgroups of G
        G,          # The group
        e1,         # eGKH
        e2,         # eGKH^2
        alpha;      # coeff e1 / coeff ce2

#begin of functions    

#The following function computes e(G,K,H)    

    eGKH:=function(K1,H1)
    local   alpha,  # Element of QG   
            Eps,    # \varepsilon(K1,H1), 
            Cen,    # Centralizer of Eps in G
            RTCen,  # Right transversal of Cen in G
            g;      # element of G
        
    Eps := IdempotentBySubgroups( QG, K1, H1 );
    Cen := Centralizer( G, Eps );
    RTCen := RightTransversal( G, Cen );

    return Sum( List( RTCen, g -> Eps^g ) ) ;
    end;
   
#end of functions       

#Program    

    if not IsSemisimpleRationalGroupAlgebra(QG) then
        Error("Wedderga: <QG> must be a rational group algebra!!!\n");
    fi;

    G:=UnderlyingMagma(QG);
  
    if IsShodaPair( G, K, H ) then
        e1:=eGKH(K,H);
        e2:=e1^2;
        alpha := CoefficientsAndMagmaElements(e1)[2] / 
                 CoefficientsAndMagmaElements(e2)[2];        
        if IsOne( alpha ) then
            return e1;
        else    
            return alpha*e1;      
        fi;    
    else
        return fail;
    fi;            
end);        





#############################################################################
##
#M IsShodaPair( G, K, H )
##
## The function IsShodaPair verifies if (H,K) is a SP 
##
InstallMethod( IsShodaPair,
    "for pairs of subgroups", 
    true, 
    [ IsGroup, IsGroup, IsGroup ],
    0,
function( G, K, H )
local       DGK,        # G\K
            ElemK,      # Elements of K
            DKH,        # K\H
            k,          # Element of K
            g,          # Elements of DGK
            NoReady;    # Boolean

# Checking (S1) and (S2)
# First verifies if H, K are subgroups of G and K is a normal subgroup of K
if not ( IsSubgroup( G, K ) and IsSubgroup( K, H ) and IsNormal( K, H ) ) then
    Error("Wedderga: Each input should contain the next one and the last one \n",
          "should be normal in the second!!!\n");
elif not( IsCyclic( FactorGroup( K, H ) ) ) then
    return false;
fi;

#Now, checking (S3)
DGK := Difference( G, K );
ElemK := Elements( K );
DKH := Difference( K, H );
for g in DGK  do
    NoReady := true;
    for k in ElemK do
        if Comm( k, g ) in DKH then
            NoReady := false;
            break;
        fi;
    od;
    if NoReady then
        return false;
    fi;
od;

return true;
end);




 

#############################################################################
##
#F PrimitiveCentralIdempotentsUsingConlon( QG )
##
##  The function PrimitiveCentralIdempotentsUsingConlon uses the function IrrConlon to compute the 
##  primitive central idempotents of QG associated to monomial representations
##  The result is the same as the function PrimitiveCentralIdempotentsBySP but it is slower
##
InstallGlobalFunction(PrimitiveCentralIdempotentsUsingConlon,
function(QG)
local G, zero, one, IrrG, LIrrG, eGKHs, SeGKHs, i, eGKH, K, H; 

    if not IsSemisimpleRationalGroupAlgebra(QG) then
        Error("Wedderga: The input must be a rational group algebra \n");
    fi;
    
    G := UnderlyingMagma( QG );
    zero := Zero( QG );
    one := One( QG );
    
    IrrG := IrrConlon( G );
    LIrrG := Length(IrrG);
    
    eGKHs:=[ IdempotentBySubgroups(QG,G,G) ];
    SeGKHs:=eGKHs[1];
    i:=2;
    while i<=LIrrG do
        #
        # ??? Why sometimes here the component inducedFrom appears ???
        #
        K:=TestMonomial(IrrG[i]).subgroup;
        H:=TestMonomial(IrrG[i]).kernel;
        eGKH:=PrimitiveCentralIdempotentBySP( QG, K, H );    
        # if eGKH*SeGKHs=zero then    # slow
        if not( eGKH in eGKHs ) then  # fast
            SeGKHs:= SeGKHs + eGKH;
            Add(eGKHs,eGKH);
        fi;
        if SeGKHs=one then
            return eGKHs;
        fi;
    i:=i+1;
    od;
    if SeGKHs=one then
        return eGKHs;
    else 
        Print("Warning!!! This is not a complete set of primitive central idempotents !!!\n");
        return eGKHs;
    fi;
end);
  
  
#############################################################################
##
#E
##






#############################################################################
##
#O PrimitiveCentralIdempotentsByCharacterTable( FG )
##
## The function PrimitiveCentralIdempotentsByCharacterTable 
## uses the character table of G to compute the primitive 
## central idempotents of the group algebra FG with the classical method.
## FOR SEMISIMPLE ABELIAN NUMBER FIELD GROUP ALGEBRAS
##
InstallMethod( PrimitiveCentralIdempotentsByCharacterTable, 
"for SemisimpleANFGroupAlgebras", 
    true, 
    [ IsSemisimpleANFGroupAlgebra ], 
    0,
function(FG) 
local G,         # Underlying group of FG
      F,         # Coefficient field of FG
      irr,       # The irreducible characters of G
      galmat,    # the output of the function GaloisMat(irr).galoisfams (the 
                 # fuction GaloisMat computes the complete orbits under the 
                 # operation of the Galois group of the (irrational) entries of 
                 # irr), that is a list, its entries are either 1, 0, -1, or lists
      galirr,    # function which computes for the character chi and the field F, 
                 # the Galois group of the extension 
                 # Field(chi)/Intersection(Field(chi),F);  
      gal,       # List of Galois groups as outputs of galirr for chi in Irr(G)
      cong,      # function with input a list l and a list of Galois groups gal
      posit, # function that computes the positions of galmat in gal
      irrClasses,# the positions of galmat in gal
      coef,      # list of coefficients
      cc,        # Conjugacy classes of G
      idem;      # List of idempotents, the output
      


    
  F := LeftActingDomain(FG);
  G := UnderlyingMagma(FG);

 # Computes the Galois orbit sums
  irr := Irr(G);
  
  Assert( 0, Size(irr)=Size(ConjugacyClasses(G)), 
    "The number of irreducible characters does not equal \nto the number of conjugacy classes of the group !!!\nPlease report this bug to the developers of Wedderga.\n" );

  galmat := GaloisMat(irr).galoisfams;

  galirr:=function(chi,F)
        return GaloisGroup(AsField(Intersection(Field(chi),F),Field(chi)));
        end;
        
  gal := List( irr , x->galirr(x,F) );

# The function cong is used to classified the second component of the entries of
# a list l (whose entries are integers representing an automorphism of a 
# cyclotomic field as the exponent of the action on roots of unity) into 
# congruence classes modulo the Galois group gal

cong := function(l,gal)

  local gn,cond,remainder,length,pos,x,pospar;
  
  gn := Group(List(gal,x->x^GalToInt(gal)));
  cond := Conductor(Source(One(gal)));
  remainder := l[2];
  length := Length(l[2]);
  pos := [];
  while remainder<>[] do
    x:=remainder[1];
    pospar := Filtered([1..length],y->ZmodnZObj(x,cond)*ZmodnZObj(l[2][y],cond)^-1 in gn);
    Add(pos,pospar);
    remainder := Difference(remainder,List(pospar,i->l[2][i]));
  od;
  
  return List(pos,y->List(y,i->l[1][i]));

end;  
     
# Computes the positions corresponding to the classes given by cong applied to
# entries of galmat and gal 
 
posit := function(galmat,gal)

  local posi,i;
  
  posi := [];
  for i in [1..Length(galmat)] do
    if galmat[i] = 1 then 
      Add(posi,[i]);
    elif IsList(galmat[i]) then 
      posi := Concatenation( posi , cong( galmat[i] , gal[i] ) );
    fi;
  od;
  
  return posi;
end;

 # main part of the function
  irrClasses := posit(galmat,gal);
  coef := List(irrClasses,x->Sum(x,y->irr[y]*irr[y][1]));
  cc := ConjugacyClasses(G);
  
  idem := List(coef, chi -> Sum( cc , X -> ElementOfMagmaRing( 
                                          FamilyObj( Zero( FG ) ), 
                                          Zero( F ), 
                                          List(X,x->Representative(X)^chi/Size(G)), 
                                          AsList(X) ) 
                               ) 
              );
  
  return idem;   
end);		       

######################################################################################
# E   



#############################################################################
##
#O PrimitiveCentralIdempotentsByCharacterTable( FG )
##
## The function PrimitiveCentralIdempotentsByCharacterTable 
## uses the character table of G to compute the primitive 
## central idempotents of the group algebra FG with the classical method.
## FOR SEMISIMPLE FINITE GROUP ALGEBRAS
##
InstallMethod( PrimitiveCentralIdempotentsByCharacterTable, 
"for SemisimpleFiniteGroupAlgebras", 
    true, 
    [ IsSemisimpleFiniteGroupAlgebra ], 
    0,
function(FG) 
local G,         # Underlying group of FG
      F,         # Coefficient field of FG
      p,         # Characteristic 
      irr,       # The irreducible characters of G
      irrp,      # irr module p
      cfs,       # character fields
      galirr,    # Galois groups
      remainder, # remaining positions
      SumIrrClass, # F-Characters 
      i,         # counter
      oneclass,  # List of Galois groups as outputs of galirr for chi in Irr(G)
      positions, # positions of Galois conjugate irreducible characters
      cc,        # Conjugacy classes of G
      idem;      # List of idempotents, the output
      


    
  F := LeftActingDomain(FG);
  p := Characteristic(F);
  G := UnderlyingMagma(FG);

 # Computes the Galois orbit sums
  irr := Irr(G);
  
  Assert( 0, Size(irr)=Size(ConjugacyClasses(G)), 
    "The number of irreducible characters does not equal \nto the number of conjugacy classes of the group !!!\nPlease report this bug to the developers of Wedderga.\n" );
    
  irrp := List( irr , x -> Character(G , List( x, y -> FrobeniusCharacterValue(  y , p ) ) ) );
  cfs := List( irrp , x -> Field(x) );
  galirr := List( cfs , x -> GaloisGroup( AsField( Intersection( F , x ) , x ) ) );
  
  remainder := [1..Length(irrp)];
  SumIrrClass := [];
  
  while remainder <> [] do
    i := remainder[1];
    oneclass := List( galirr[i] , x -> Character( G , List( irrp[i] , y -> y^x )) );
    Add( SumIrrClass , irr[i][1]*Sum( oneclass ) );
    positions := List( oneclass, x -> Position( irrp , x ) );
    remainder := Difference( remainder , positions );
  od;
  
 # Compute idempotents 
  cc := ConjugacyClasses(G);
  
  idem := List(SumIrrClass, chi -> Sum( cc , X -> ElementOfMagmaRing( 
                                          FamilyObj( Zero( FG ) ), 
                                          Zero( F ), 
                                          List(X,x->Representative(X)^chi/Size(G)), 
                                          AsList(X) ) 
                               ) 
              );
  
  return idem;   
end);		       

######################################################################################
# E   






#############################################################################
##
#F PrimitiveCentralIdempotentsByCharacterTable( QG ) (RATIONAL VERSION)
##
## The function PrimitiveCentralIdempotentsByCharacterTable 
## uses the character table of G to compute the primitive 
## central idempotents of QG with the classical method.
##
# InstallGlobalFunction( PrimitiveCentralIdempotentsByCharacterTable, 
# function(QG) 
# local G,      # The group
#       OrderG, # Order of G
#       zero,   # Zero of QG
#       I,      # The irreducible characters of G
#       rat,    # rational irreducible characters (Galois orbit sums)
#       norms,  # norms of the orbit sums
#       Id,     # The list of primitive central idempotents of QG computed
#       nccl,
#       i,
#       chi,    # one entry in `rat'
#       eC,     # one primitive central idempotent of QG
#       j,      # loop over class positions
#       F, c, elms, val, k, tbl, fusions, deg;
# 
#     # First check if `QG' is a rational group algebra of a finite group.
#     if not ( IsFreeMagmaRing( QG ) and IsGroup( UnderlyingMagma( QG ) )
#              and IsRationals( LeftActingDomain( QG ) ) ) then
#       Error( "The input must be a rational group algebra" );
#     fi;
# 
#     # Initialization
#     G:= UnderlyingMagma( QG );
#     elms:= Elements( G );
#     OrderG:= Size( G );
#     zero:= Zero( QG );
# 		       
#     # Compute the irreducible characters.
#     IsSupersolvable( G );
#     tbl:= CharacterTable( G );
#     I:= List( Irr( G ), ValuesOfClassFunction );
# 
#     # Compute the Galois orbit sums.
#     rat:= RationalizedMat( I );
#     norms:= List( rat, x -> ScalarProduct( tbl, x, x ) );
# 
#     # Compute the PCIs of QG.
#     F:= FamilyObj( zero );
#     fusions:= List( ConjugacyClasses( tbl ),
#                     c -> List( Elements( c ),
#                                x -> PositionSorted( elms, x ) ) );
#     Id:= [];
#     nccl:= Length( I );    
#     for i in [ 1 .. Length( rat ) ] do
#       chi:= rat[i];
#       deg:= chi[1] / norms[i];
#       eC:= 0 * [ 1 .. OrderG ] + 1;
#       for j in [ 1 .. nccl ] do
#         val:= chi[j] * deg / OrderG;
#         for k in fusions[j] do
#           eC[k]:= val;
#         od;
#       od;
#       Add( Id, ElementOfMagmaRing( F, 0, eC, elms ) );
#     od;
# 
#     return Id;
# end);
