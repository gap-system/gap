#############################################################################
##  
#W  laguna.gi                The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  $Id: laguna.gi,v 1.66 2009/09/08 14:24:48 alexk Exp $
##
#############################################################################



#############################################################################
##
## SOME CLASSES OF GROUP RINGS AND THEIR GENERAL ATTRIBUTES
##
#############################################################################


#############################################################################
##
#M  IsGroupAlgebra( <R> )
##  
##  A group ring over the field is called group algebra. This property
##  will be determined automatically for every group ring, created by
##  the function `GroupRing'
InstallImmediateMethod( IsGroupAlgebra,
    IsGroupRing, 0,
    R -> IsField(LeftActingDomain( R ) ) );


#############################################################################
##
#M  IsFModularGroupAlgebra( <R> )
##  
##  A group algebra $FG$ over the field $F$ of characteristic $p$ is called
##  modular, if $p$ devides the order of some element of $G$. This property
##  will be determined automatically for every group ring, created by
##  the function `GroupRing'
InstallImmediateMethod( IsFModularGroupAlgebra,
    IsGroupAlgebra, 0,
    R -> IsFinite(UnderlyingMagma(R)) and 
         Characteristic(LeftActingDomain(R)) <> 0 and 
         Size(UnderlyingMagma(R)) mod Characteristic(LeftActingDomain(R)) = 0 
);    


#############################################################################
##
#P  IsPModularGroupAlgebra( <R> )
##  
##  We define separate property for modular group algebras of finite p-groups.
##  This property will be determined automatically for every group ring, 
##  created by the function `GroupRing'
InstallImmediateMethod( IsPModularGroupAlgebra,
    IsFModularGroupAlgebra, 0,
    R -> IsPGroup(UnderlyingMagma(R)) and
         Characteristic(LeftActingDomain(R)) <> 0 and 
         PrimePGroup(UnderlyingMagma(R)) = 
         Characteristic(LeftActingDomain(R)) 
); 

#############################################################################
##
#M  UnderlyingGroup( <R> )
##  
##  This attribute returns the result of the function `UnderlyingMagma' and
##  was defined for group rings mainly for convenience and teaching purposes
InstallMethod( UnderlyingGroup, [IsGroupRing], UnderlyingMagma );


#############################################################################
##
#M  UnderlyingRing( <R> )
##  
##  This attribute returns the result of the function `LeftActingDomain' and
##  for convenience was defined for group rings mainly for teaching purposes
InstallMethod( UnderlyingRing, [IsGroupRing], LeftActingDomain );


#############################################################################
##
#M  UnderlyingField( <R> )
##  
##  This attribute returns the result of the function `LeftActingDomain' and
##  for convenience was defined for group algebras mainly for teaching purposes
InstallMethod( UnderlyingField, [IsGroupAlgebra], LeftActingDomain );



#############################################################################
##
## GENERAL PROPERTIES AND ATTRIBUTES OF GROUP RING ELEMENTS
##
#############################################################################


#############################################################################
##
#M  Support( <x> )
##  
##  The support of a non-zero element of a group ring $ x = \sum \alpha_g g $ 
##  is a set of elements $g \in G$ for which $\alpha_g$ in not zero.
##  Note that for zero element this function returns an empty list
InstallMethod( Support,
    "LAGUNA: for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    function(elt)
    local i, l;
    l:=CoefficientsAndMagmaElements(elt);
    return List( [ 1 .. Length(l)/2 ], i -> l[ 2*i-1 ] );
    end
    );     


#############################################################################
##
#M  CoefficientsBySupport( <x> )
##  
##  List of coefficients for elements of Support(x) 
InstallMethod( CoefficientsBySupport,
    "LAGUNA: for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    function(elt)
    local i, l;
    l:=CoefficientsAndMagmaElements(elt);
    return List( [ 1 .. Length(l)/2 ], i -> l[ 2*i ] );
    end
    );     


#############################################################################
##
#M  TraceOfMagmaRingElement( <x> )
##  
##  The trace of an element $ x = \sum \alpha_g g $ is $\alpha_1$, i.e.
##  the coefficient of the identity element of a group $G$. 
##  Note that for zero element this function returns zero
InstallMethod( TraceOfMagmaRingElement,
    "LAGUNA: for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    function( elt )
    local c, pos, i;
    c := CoefficientsAndMagmaElements( elt );
    pos := PositionProperty( [1 .. Length(c)/2 ], i-> IsOne( c[2*i-1] ) );
    if pos<>fail then
        return c[pos*2];
    else
        return ZeroCoefficient(elt);
    fi;
    end
    );     


#############################################################################
##
#M  Length( <x> )
##  
##  Length of an element of a group ring is the number of elements in its 
##  support
InstallMethod( Length,
    "LAGUNA: for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    elt -> Length(CoefficientsAndMagmaElements(elt)) / 2 );  


#############################################################################
##
#M  Augmentation( <x> )
##  
##  Augmentation of a group ring element $ x = \sum \alpha_g g $ is the sum 
##  of coefficients $ \sum \alpha_g $
InstallMethod( Augmentation,
    "LAGUNA: for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    elt -> Sum( CoefficientsBySupport( elt ) ) );   


#############################################################################
##
#O  PartialAugmentations( <KG>, <x> )
##  
##  Returns a list of two lists, the first being partial augmentations of x
##  and the second - representatives of corresponding conjugacy classes
InstallMethod( PartialAugmentations,
     "LAGUNA: for a group ring and its element",
     true,
     [IsGroupRing, 
      IsElementOfMagmaRingModuloRelations and 
      IsMagmaRingObjDefaultRep ], 
     0,
function(KG,x)
local G, s, c, part, reps, l, labels, i, j, partsum;
  if not x in KG then
    Error("LAGUNA: PartialAugmentations: x is not in KG");
  fi;
  G := UnderlyingMagma( KG ); 
  s := Support( x );
  c := CoefficientsBySupport( x );
  part := []; 
  reps := [];
  l := Length(s);
  labels := List( [ 1 .. l ], x -> 0 );
  for i in [ 1 .. l ] do
    if labels[i]=0 then # new represenative discovered
      partsum := c[i];
      Add( reps, s[i] );
      labels[i] := 1;
      for j in [ i+1 .. l ] do
        if labels[j]=0 then
          if( IsConjugate( G, s[i], s[j] ) )  then
            partsum := partsum + c[j];
            labels[j] := 1; 
          fi;
        fi;
      od;
      Add(part, partsum);
    fi; 
  od;
  return [ part, reps ];
end);


#############################################################################
##
#M  Involution( <x>, <mapping_f>, <mapping_sigma> )
##
##  Computes the image of the element x = \sum alpha_g g under the mapping
##  \sum alpha_g g  -> \sum alpha_g * f(x) * sigma(g)
## 
InstallMethod( Involution,
    "LAGUNA: for a group ring element, and a group endomapping of order 2 and a mapping from the group to a ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep, 
      IsMapping, IsMapping ], 
    0,
    function(x, f, sigma)
    local i, g, coeffs, supp, e, s;
    if Source(sigma) <> Source(f) then
    	Error("Involution: Source(sigma) <> Source(f)");
    elif Source(sigma) <> Range(sigma) then 
        Error("Involution: Source(sigma) <> Range (sigma)");
    elif Order(sigma) <> 2 then
        Error("Involution: Order(sigma) <> 2");
    else
        e := One(ZeroCoefficient(x));
        for g in GeneratorsOfGroup( Source( f ) ) do    
            s := g^sigma;
            if (g*s)^f <> e then
                Error("Involution: f(g * sigma(g)) <> ", e, " for g = ", g, "\n");
            elif (s*g)^f <> e then
                Error("Involution: f(sigma(g) * g) <> ", e, " for g = ", g, "\n");
            fi;
        od;    
    	coeffs := CoefficientsBySupport(x);
    	supp := Support(x);
        return ElementOfMagmaRing( FamilyObj(x), 
                                   ZeroCoefficient(x), 
                                   List( [ 1 .. Length(coeffs) ], i -> coeffs[i]*supp[i]^f ), 
                                   List( supp, g -> g^sigma ) ) ;
    fi;
    end
    ); 
    
    
#############################################################################
##
#M  Involution( <x>, <mapping_sigma> )
##
##  Computes the image of the element x = \sum alpha_g g under the mapping
##  \sum alpha_g g  -> \sum alpha_g * sigma(g)
## 
InstallOtherMethod( Involution,
    "LAGUNA: for a group ring element and a group endomapping of order 2",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep, 
      IsMapping ], 
    0,
    function(x, sigma)
    local g;
    if Source(sigma) <> Range(sigma) then 
        Error("Involution: Source(sigma) <> Range (sigma)");
    elif Order(sigma) <> 2 then
        Error("Involution: Order(sigma) <> 2");
    else
        return ElementOfMagmaRing( FamilyObj(x), 
                                   ZeroCoefficient(x), 
                                   CoefficientsBySupport(x), 
                                   List(Support(x), g -> g^sigma) ) ;
    fi;
    end
    ); 
        

#############################################################################
##
#M  Involution( <x> )
##
##  Computes the image of the element x = \sum alpha_g g under the classical
##  involution \sum alpha_g g  -> \sum alpha_g * g^-1
## 
InstallOtherMethod( Involution,
    "LAGUNA: classical involution for an element of a group ring ",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    x -> ElementOfMagmaRing( FamilyObj(x), 
                             ZeroCoefficient(x), 
                             CoefficientsBySupport(x), 
                             List(Support(x), g -> g^-1) ) );  


#############################################################################
##
#A  IsSymmetric( <x> )
##
##  An element of a group ring is called symmetric if it is fixed under the
##  classical involution
InstallMethod(IsSymmetric,
    "LAGUNA: for group ring elements",
    true,
    [IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep],
    0,
    x -> x=Involution(x) );  		     

				     
#############################################################################
##
#A  IsUnitary( <x> )
##
##  An unit of a group ring is called unitary if x^-1 = Involution(x) * eps,
##  where eps is an invertible element from an underlying ring
InstallMethod(IsUnitary,
    "LAGUNA: for group ring elements",
    true,
    [IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep],
    0,
    function(x)
    local t;
    t:=x*Involution(x);
    return Length(CoefficientsAndMagmaElements(t))=2 and 
           IsOne(CoefficientsAndMagmaElements(t)[1]) and
           IsUnit(CoefficientsAndMagmaElements(t)[2]);
    end); 


#############################################################################
##
#M  IsUnit( <KG>, <elt> )
## 
InstallMethod (IsUnit,
        "LAGUNA: for an element of modular group algebra",
        true,
        [ IsPModularGroupAlgebra, IsElementOfMagmaRingModuloRelations and 
                                  IsMagmaRingObjDefaultRep ],
        0,
        function(KG,elt)
        return not Augmentation( elt ) = Zero( UnderlyingField( KG ) ); 
        end);       

        
#############################################################################
##
#M  IsUnit( <elt> )
## 
InstallOtherMethod (IsUnit,
        "LAGUNA: for an element of modular group algebra",
        true,
        [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ],
        0,
        function( elt )
        
        local S;
	
        if IsZero(elt) then
          return false;
        fi;
	
        # if we have element of the form coefficient*group element
        # we switch to use standart method for magma rings
        
        if Length(CoefficientsAndMagmaElements(elt)) = 2 then
          TryNextMethod();
        else
        
          # generate the support group, and if it appears to be a finite 
          # p-group, we check whether coefficients are from field of 
	        # characteristic p
            
          S:=Group(Support(elt)); 
          if IsPGroup(S) then
            if PrimePGroup(S) mod Characteristic( elt )=0 then
              return not Augmentation( elt ) = ZeroCoefficient( elt ) ;
            else  
              TryNextMethod(); # since our case is not modular               
            fi;
          else        
            TryNextMethod(); # since our case is not modular               
          fi;   
        fi;         
      
      end);
        

#############################################################################
##
#M  InverseOp( <elt> )
## 
InstallOtherMethod( InverseOp,
  "LAGUNA: for an element of modular group algebra",
  true,
  [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ],
  0,
  function( elt )
  local inv, pow, x, u, S, a;
  
  if IsZero( elt ) then
    return fail;  
  fi; 
        
  # if we have element of the form coefficient*group element,
  # or if we work in characteristic zero,
  # we switch to use standart method for magma rings
        
  if Length(CoefficientsAndMagmaElements(elt)) = 2 then
    TryNextMethod();
  elif Characteristic( elt ) = 0 then
    TryNextMethod();
  else
        
  # generate the support group, and if it appears to be a finite p-group
  # we check whether coefficients are from field of characteristic p
            
  S:=Group(Support(elt)); 
    if IsPGroup(S) then
      if PrimePGroup(S) mod Characteristic( elt ) = 0 then
        a:=Augmentation( elt );
        if a = ZeroCoefficient( elt ) then
          return fail; # augmentation zero element is not a unit
        else
          # for a case when elt is not normalised unit, we normalize it
          u:=elt*a^-1;
          x := u - u^0;
          pow := -x;
          inv := x^0;
        
          while not pow = 0*x do
            inv := inv + pow;
            pow := pow * (-x);
          od;

          return a*inv;
        fi; 
      else        
        TryNextMethod(); # since our case is not modular                  
      fi;       
    else        
      TryNextMethod(); # since our case is not modular                  
    fi;   
  fi;   
end);
        

#############################################################################
##
## IDEALS, AUGMENTATION IDEAL AND GROUPS OF UNITS OF GROUP RINGS
##
#############################################################################


#############################################################################
##
#O  LeftIdealBySubgroup( <KG>, <H> )
##
InstallMethod( LeftIdealBySubgroup,
               "LAGUNA: for a group ring and a subgroup of underlying group",
               true,
               [ IsGroupRing, IsGroup ],
               0,
function ( KG, H )
local G, LI, gens, g, r, leftcosreps;
G := UnderlyingMagma( KG );
#
if not IsSubgroup( G, H ) then
  Error("The second argument is not a subgroup of the underlying group!\n");
fi;
#
if G=H then
  Info( LAGInfo, 2, 
    "LAGUNA: Returning augmentation ideal of the group ring");
  return AugmentationIdeal( KG );
fi;
#
leftcosreps := List( RightTransversal( G, H ), g -> g^-1 );
gens := List( AsList( H ), g -> g-One( KG ) );
SubtractSet( gens, [Zero(KG)] );
for r in leftcosreps do
  if r<>One(G) then
    Append( gens, List( gens{[1..Size(H)-1]}, g -> r*g ) );
  fi;
od;
if IsNormal( G, H ) then
  LI := TwoSidedIdeal( KG, gens, "basis" );
  Info( LAGInfo, 2, 
    "LAGUNA: Returning two-sided ideal since the subgroup is normal");
  return LI;
else
  LI := LeftIdeal( KG, gens, "basis" );
  return LI;
fi;  
end);


#############################################################################
##
#O  RightIdealBySubgroup( <KG>, <H> )
##
InstallMethod( RightIdealBySubgroup,
               "LAGUNA: for a group ring and a subgroup of underlying group",
               true,
               [ IsGroupRing, IsGroup ],
               0,
function ( KG, H )
local G, RI, gens, g, r, rightcosreps;
G := UnderlyingMagma( KG );
#
if not IsSubgroup( G, H ) then
  Error("The second argument is not a subgroup of the underlying group!\n");
fi;
#
if G=H then
  Info( LAGInfo, 2, 
    "LAGUNA: Returning augmentation ideal of the group ring");
  return AugmentationIdeal( KG );
fi;
#
rightcosreps:=RightTransversal( G, H );
gens := List( AsList( H ), g -> g-One( KG ) );
SubtractSet( gens, [Zero(KG)] );
for r in rightcosreps do
  if not r<>One(G) then
    Append( gens, List( gens{[1..Size(H)-1]}, g -> g*r ) );
  fi;
od;
if IsNormal( G, H ) then
  RI := TwoSidedIdeal( KG, gens, "basis" );
  Info( LAGInfo, 2, 
    "LAGUNA: Returning two-sided ideal since the subgroup is normal");
  return RI;
else
  RI := RightIdeal( KG, gens, "basis" );
  return RI;
fi;  
end);


#############################################################################
##
#O  TwoSidedIdealBySubgroup( <KG>, <H> )
##
InstallMethod( TwoSidedIdealBySubgroup,
               "LAGUNA: for a group ring and a subgroup of underlying group",
               true,
               [ IsGroupRing, IsGroup ],
               0,
function ( KG, H )
local G, TI, gens, g;
G := UnderlyingMagma( KG );
#
if not IsSubgroup( G, H ) then
  Error("The second argument is not a subgroup of the underlying group!\n");
fi;
#
if G=H then
  Info( LAGInfo, 2, 
    "LAGUNA: Returning augmentation ideal of the group ring");
  return AugmentationIdeal( KG );
fi;
#
if IsNormal( G, H ) then
  # in this case LeftIdealBySubgroup will return two-sided ideal
  return LeftIdealBySubgroup( KG, H );
else
  Info(LAGInfo, 1, 
  "LAGUNA WARNING: two-sided ideals by non-normal subgroup not defined");
  TryNextMethod();
fi;  
end);


#############################################################################
##
#A  RadicalOfAlgebra( <KG> )
## 
InstallMethod( RadicalOfAlgebra,
    "LAGUNA: for modular group algebra of finite p-group",
    true,
    [ IsAlgebra and IsPModularGroupAlgebra ], 
    0,
    KG -> AugmentationIdeal(KG) );  


#############################################################################
##
#A  AugmentationIdeal( <KG> )
## 
InstallMethod( AugmentationIdeal,
    "LAGUNA: for a modular group algebra of a finite group",
    true,
    [ IsFModularGroupAlgebra ], 
    0,
    function(KG)
    local gens, g;
    gens:=List( AsList( UnderlyingMagma(KG) ), g -> g - One(KG) ); 
    SubtractSet( gens, [ Zero( KG ) ] );
    return TwoSidedIdeal(KG, gens, "basis");
    end
    ); 


#############################################################################
##
#A  WeightedBasis( <KG> )
##  
InstallMethod( WeightedBasis,
## KG must be a modular group algebra. The weighted basis is a basis of the 
## fundamental ideal such that each power of the fundamental ideal is 
## spanned by a subset of the basis. Note that this function actually 
## constructs a basis for the *fundamental ideal* and not for KG.
## Returns a record whose basis entry is the basis and the weights entry
## is a list of corresponding weights of basis elements with respect to     
## the fundamental ideal filtration.
## This function uses the Jennings basis of the underlying group.    
    
    "LAGUNA: for modular group algebra of a finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function(KG)
        local G, gens, jb, jw, i, k, wb, wbe, c, emb, weight, weights;
     
        Info(LAGInfo, 2, "LAGInfo: Calculating weighted basis ..." );
         
        G := UnderlyingMagma( KG );
        emb := Embedding( G, KG );
         
            jb := DimensionBasis( G ).dimensionBasis;
            jw := DimensionBasis( G ).weights;
         
            c := Tuples( [ 0 .. PrimePGroup( G ) - 1 ], Length( jb ) );
            RemoveSet( c, List( [ 1 .. Length( jb ) ], x -> 0 ) );
            weights := [];
            wb := [];
            
            Info(LAGInfo, 3, "LAGInfo: Generating ", Length(c), 
	                     " elements of weighted basis");
            
            for i in c do
            
            Info(LAGInfo, 4, Position(c,i) );
            
                wbe := One( KG );
                weight := 0;
                for k in [ 1 .. Length( jb ) ] do
                         wbe := wbe * ( jb[k] - One( KG ) )^i[k];
                         weight := weight + i[k]*jw[k];
                od;
                Add( wb, wbe );
                Add( weights, weight );
            od;
                 
            SortParallel( weights, wb );
                 
            Info(LAGInfo, 2, "LAGInfo: Weighted basis finished !" );
                 
            return rec( weightedBasis := wb, weights := weights );
            
    end
    );
        

#############################################################################
##
#A  AugmentationIdealPowerSeries( <KG> )
##  
InstallMethod( AugmentationIdealPowerSeries,
## KG is a modular group algebra.    
## Returns a list whose elements are the terms of the augmentation ideal    
## filtration of I. That is AugmentationIdealPowerSeries(KG)[k] = I^k,
## where I is the augmentation ideal of KG.

    "LAGUNA: for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
    local c, i, j, f, jb, jw, s;
         
    Info(LAGInfo, 2, "LAGInfo: Computing the augmentation ideal filtration...");
            
    jb := WeightedBasis( KG ).weightedBasis;
    jw := Collected( WeightedBasis( KG ).weights );
         
    c := [ ];
    
    Info(LAGInfo, 3, "LAGInfo: using ", Length(jw), 
                     " element of weighted basis");     
         
    for i in [1..Length( jw )] do
        f := 1;
        for j in [1..i-1] do
                f := f+jw[j][2];
        od;
        s := Subalgebra( KG, jb{[f..Length( jb )]}, "basis" );
        Add( c, s );
        Info(LAGInfo, 4, "I^", i);    
    od;
         
    Add( c, Subalgebra( KG, [ ] ) );
         
    Info(LAGInfo, 2, "LAGInfo: Filtration finished !" );
         
    return c;
    end
    );


#############################################################################
##
#A  AugmentationIdealNilpotencyIndex( <R> )
##  
InstallMethod( AugmentationIdealNilpotencyIndex,
    "LAGUNA: for a modular group algebra of a finite p-group",
    true,
    [ IsPModularGroupAlgebra ], 
    0,
    function(KG)
    local D, d, i, t, m, p;
        p:=Characteristic( LeftActingDomain( KG ) );
        D:=JenningsSeries( UnderlyingMagma( KG ) );
        d:=[ ];
        for i in [1 .. Length(D)-1 ] do
                d[i] := LogInt( Index( D[i], D[i+1]), p );
        od;
        t:=1;
        for m in [ 1 .. Length(d) ] do
                t:=t + (p-1)*m*d[m];
        od;
        return t;
    end
    ); 


#############################################################################
##
#A  AugmentationIdealOfDerivedSubgroupNilpotencyIndex( <R> )
##  
InstallMethod( AugmentationIdealOfDerivedSubgroupNilpotencyIndex,
    "LAGUNA: for a modular group algebra of a finite p-group",
    true,
    [ IsPModularGroupAlgebra ], 
    0,
    function(KG)
    local D, d, i, t, m, p;
        p:=Characteristic( LeftActingDomain( KG ) );   
        D:=JenningsSeries( DerivedSubgroup( UnderlyingMagma( KG ) ) );
        d:=[ ];
        for i in [ 1 .. Length(D)-1 ] do
                d[i] := LogInt( Index( D[i], D[i+1]), p );
        od;
        t:=1;
        for m in [1 .. Length(d) ] do
                t:=t + (p-1)*m*d[m];
        od;
        return t;
    end
    );  
                             
#############################################################################
##
#A  IsGroupOfUnitsOfMagmaRing( <U> )
##  
InstallTrueMethod(IsGroupOfUnitsOfMagmaRing, 
                  IsElementOfMagmaRingModuloRelationsCollection and IsGroup);  
      


###########################################################################
#
# NormalizedUnitCF( KG, u )
#
# KG is a modular group algebra and u is a normalized unit in KG.
# Returns the coefficient vector corresponding to the element u with respect
# to the "natural" polycyclic series of the normalized unit group 
# which corresponds to the augmentation ideal filtration of KG.
InstallMethod( NormalizedUnitCF,
        "LAGUNA: for modular group algebra of finite p-group",
        true,
        [ IsPModularGroupAlgebra, 
          IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep],
        0,
        function( KG, u )
    local i, j, c, wb, rem, w, f, l, coef, u1, e, cl, z;
    
    if not IsUnit(KG,u) then
        Error( "The element <u> must be invertible" );
    fi;
    
    if u = u^0 then
        return [ ];
    fi;
    
    c := AugmentationIdealPowerSeries( KG );
    wb := WeightedBasis( KG );
    e := One( KG );
    z := Zero( LeftActingDomain( KG ) );
    
    rem := u;
    
    cl := [ ];
    
    repeat

      w := 1;
      while rem-e in c[w] do
        w := w+1;
      od;

      w := w-1;
      f := 1;
     
      while Length( wb.weights )>= f and wb.weights[f]<w do
        f := f+1;
      od;
     
      for i in [1..f-Length( cl )-1] do
        Add( cl, z );
      od;
     
      l := f;
      while Length( wb.weights )>= l and wb.weights[l] = w  do
        l := l+1;
      od;
     
      l := l-1;
     
      coef := Coefficients( BasisNC( c[w], 
                wb.weightedBasis{[f..Length( wb.weightedBasis )]}), 
                rem-e );
     
      u1 := One( KG );
      coef := coef{[1..l-f+1]};
     
      for i in [1..l-f+1] do
        Add( cl, coef[i] );
        if not coef[i]=z then
          u1 := u1*(wb.weightedBasis[f+i-1]+e)^IntFFE( coef[i] );
        fi;
      od;

      rem := u1^-1*rem;
     
    until rem = One( KG );
  
  return cl;
 
end );

########################################################################### 
# 
# NormalizedUnitCFmod( KG, u, k ) 
# 
# KG is a modular group algebra and u is a normalized unit in KG. 
# Returns the restricted coefficient vector corresponding to the element u 
# with respect to the "natural" polycyclic series of the normalized unit 
# group which corresponds to the augmentation ideal filtration of KG. 
InstallMethod( NormalizedUnitCFmod, 
        "LAGUNA: for modular group algebra of finite p-group", 
        true, 
        [ IsPModularGroupAlgebra,  
          IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep,
          IsPosInt], 
        0, 
        function( KG, u, k ) 
    local i, j, c, wb, rem, w, f, l, coef, u1, e, cl, z; 
     
    if not IsUnit(KG,u) then 
      Error( "The element <u> must be invertible" ); 
    fi; 
     
    if u = u^0 then 
      return [ ]; 
    fi; 
     
    c := AugmentationIdealPowerSeries( KG ); 
    wb := WeightedBasis( KG ); 
    e := One( KG ); 
    z := Zero( LeftActingDomain( KG ) ); 
     
    rem := u; 
     
    cl := [ ]; 
     
    repeat 
      
      w := 1; 
      while rem-e in c[w] do 
        w := w+1; 
      od; 
      
      w := w-1; 
      
      f := 1; 
      
      while Length( wb.weights )>= f and wb.weights[f]<w do 
        f := f+1; 
      od; 
      
      for i in [1..f-Length( cl )-1] do 
        Add( cl, z ); 
      od; 
      
      l := f; 
      while Length( wb.weights )>= l and wb.weights[l] = w  do 
        l := l+1; 
      od; 
      
      l := l-1; 
      
      coef := Coefficients( BasisNC( c[w],  
              wb.weightedBasis{[f..Length( wb.weightedBasis )]}),  
              rem-e ); 
      
      u1 := One( KG ); 
      coef := coef{[1..l-f+1]}; 
      
      for i in [1..l-f+1] do 
        Add( cl, coef[i] ); 
        if Length(cl) >= k then 
          return cl;
        fi;
        if not coef[i]=z then 
          u1 := u1*(wb.weightedBasis[f+i-1]+e)^IntFFE( coef[i] ); 
        fi; 
      od; 
      
      rem := u1^-1*rem; 
      
    until rem = One( KG ); 
  
  return cl; 
  
end ); 


#############################################################################
##
#A  NormalizedUnitGroup( <KG> )
##  
InstallMethod( NormalizedUnitGroup,
    "LAGUNA: for modular group algebra of a finite p-group",
    true,
    [ IsPModularGroupAlgebra ], 
    0,
    function(KG)
    local U;
    if not IsPrime(Size(LeftActingDomain(KG))) then
      TryNextMethod();
    else
      U := Group( List ( WeightedBasis(KG).weightedBasis, x -> One(KG)+x ) );
      SetIsGroupOfUnitsOfMagmaRing(U,true);
      SetIsNormalizedUnitGroupOfGroupRing(U,true);
      SetIsCommutative(U, IsCommutative(UnderlyingMagma(KG)));
      SetIsFinite(U, true);
      SetSize(U, Size(LeftActingDomain(KG))^(Size(UnderlyingMagma(KG))-1));
      SetIsPGroup(U, true);
      SetUnderlyingGroupRing(U,KG);
      SetPcgs( U, PcgsByPcSequence( FamilyObj(One(KG)), GeneratorsOfGroup(U) ) );
      SetRelativeOrders( Pcgs(U), List( [ 1 .. Dimension(KG)-1 ], x -> Characteristic( LeftActingDomain(KG) ) ) );
      return U;
    fi;  
    end
    );   

InstallTrueMethod( CanEasilyComputePcgs, IsNormalizedUnitGroupOfGroupRing );


#############################################################################
##
#A  PcNormalizedUnitGroup( <KG> )
##  
## KG is a modular group algebra. Computes the normalized unit group of 
## KG. The unit group is computed as a polycyclic group given by 
## power-commutator presentation. The generators of the presentation 
## correspond to the weighted basis of KG and the relations are computed 
## using the previous function.
InstallMethod( PcNormalizedUnitGroup,
    "LAGUNA: for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG ) 
    local i, j, e, wb, lwb, f, fgens, w, coef, k, U, z, p, coll;

    if not IsPrime(Size(LeftActingDomain(KG))) then
      TryNextMethod();
    else           
      Info(LAGInfo, 2, "LAGInfo: Computing the pc normalized unit group ..." );
         
      e := One( KG );
      z := Zero( LeftActingDomain( KG ) );
      p := Characteristic( LeftActingDomain( KG ) );
         
      wb := WeightedBasis( KG );
      lwb := Length( wb.weightedBasis );
      
      f := FreeGroup( lwb );
      fgens := GeneratorsOfGroup( f );
      # rels := [ ];
    
      coll:=SingleCollector( f, List( [1 .. lwb ], i -> p ) );
      # TODO: Understand why CombinatorialCollector does not work?
    
      Info(LAGInfo, 3, "LAGInfo: relations for ", lwb,
                       " elements of weighted basis");     
         
      for i in [1..lwb] do
          coef := NormalizedUnitCF( KG, (wb.weightedBasis[i]+e)^p );
          w := One( f );
          for j in [1..Length(coef)] do
                  if not coef[j]=z then
                          w := w*fgens[j]^IntFFE( coef[j] );
                  fi;
          od;
          # Add( rels, fgens[i]^p/w );
          SetPower( coll, i, w );
          Info(LAGInfo, 4, i);
      od;
    
      Info(LAGInfo, 3, "LAGInfo: commutators for ", lwb, 
                       " elements of weighted basis");     

      if IsCommutative(KG) then

        for i in [1..lwb-1] do
          for j in [i+1..lwb] do
            # Add( rels, Comm( fgens[i],fgens[j] ) );
            SetCommutator( coll, j, i, One(f) );
          od;
        od;
      
      else   
     
        for i in [ 1 .. lwb-1 ] do
          for j in [ i+1 .. lwb ] do
            coef := NormalizedUnitCF( KG,  
                      Comm( wb.weightedBasis[i]+e, wb.weightedBasis[j]+e ));
            w := One( f );
            for k in [1..Length( coef )] do
              if not coef[k]=z then
                  w := w*fgens[k]^IntFFE( coef[k] );
              fi;
            od;
            # Add( rels, Comm( fgens[i],fgens[j] )/w );
            SetCommutator( coll, j, i, w^-1);
            Info(LAGInfo, 4, "[ ", i, " , ", j, " ]");
          od;
        od;

      fi;
           
      Info(LAGInfo, 2, "LAGInfo: finished, converting to PcGroup" );

      U:=GroupByRwsNC(coll); # before we used U:=PcGroupFpGroup( f/rels );
      SetIsGroupOfUnitsOfMagmaRing(U,false);
      SetIsNormalizedUnitGroupOfGroupRing(U,true);
      SetIsPGroup(U, true);
      SetUnderlyingGroupRing(U,KG);   
      return U;
    fi;
    end
    );


#############################################################################
##
#O  AugmentationIdealPowerFactorGroupOp( <KG>, <n> )
##  
##  Calculates the pc-presentation of the factor group of the normalized unit
##  group V(KG) over 1+I^n, where I is the augmentation ideal of KG 
InstallMethod( AugmentationIdealPowerFactorGroupOp, 
  "for modular group algebra of finite p-group",
  true,
  [ IsPModularGroupAlgebra, IsPosInt ],
  0,
  function(KG,n)

  local i, j, e, wb, f, rels, fgens, w, coef, cutcoef, k, U, z, p,
        pos, cuttedBasis;

  if n > AugmentationIdealNilpotencyIndex(KG) then
    Print("Warning: calculating V(KG/I^n) for n>t(I), returning V(KG) \n");
  fi;

  if n >= AugmentationIdealNilpotencyIndex(KG) then
    return PcNormalizedUnitGroup(KG);
  fi;
         
  Info(LAGInfo, 2, "LAGInfo: Computing the pc factor group ..." );
         
  e := One( KG );
  z := Zero( LeftActingDomain( KG ) );
  p := Characteristic( LeftActingDomain( KG ) );
         
  wb := WeightedBasis( KG );
  pos:=Position(wb.weights, n)-1;
  cuttedBasis:=wb.weightedBasis{[1 .. pos]};
             
  f := FreeGroup( Length( cuttedBasis ));
  fgens := GeneratorsOfGroup( f );
  rels := [ ];
    
  Info(LAGInfo, 3, "LAGInfo: relations for ", Length(cuttedBasis), 
                   " elements of cutted basis");     
         
  for i in [1..Length(cuttedBasis)] do
    coef := NormalizedUnitCFmod( KG, (cuttedBasis[i]+e)^p, pos);
    cutcoef := coef{[1..Minimum(Length(coef),pos)]};
    w := One( f );
    for j in [1..Length(cutcoef)] do
      if not cutcoef[j]=z then
        w := w*fgens[j]^IntFFE( coef[j] );
      fi;
    od;
    Add( rels, fgens[i]^p/w );
    Info(LAGInfo, 4, i);
  od;
    
  Info(LAGInfo, 3, "LAGInfo: commutators for ", Length(cuttedBasis), 
                   " elements of cutted basis");     
         
  for i in [1..Length(cuttedBasis )] do
    for j in [i+1..Length(cuttedBasis )] do
      coef := NormalizedUnitCFmod( KG, Comm( cuttedBasis[i]+e, 
                                       cuttedBasis[j]+e ), pos);
      cutcoef := coef{[1..Minimum(Length(coef),pos)]};		    
      w := One( f );
      for k in [1..Length( cutcoef )] do
        if not cutcoef[k]=z then
          w := w*fgens[k]^IntFFE( coef[k] );
        fi;
      od;
      Add( rels, Comm( fgens[i],fgens[j] )/w );
      Info(LAGInfo, 4, "[ ", i, " , ", j, " ]");
    od;
  od;
         
Info(LAGInfo, 2, "LAGInfo: finished, converting to PcGroup" );
    
U:=PcGroupFpGroup( f/rels );
SetUnderlyingGroupRing(U,KG);     
return U;
end);


#############################################################################
##
#A  Units( <KG> )
##  
InstallMethod( Units,
    "LAGUNA: for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
    local K, U;
    if not IsPrime(Size(LeftActingDomain(KG))) then
      TryNextMethod();
    else           
      Info(LAGInfo, 1, "LAGUNA package: Computing the unit group ..." );
      K := Units( LeftActingDomain( KG ) );
      if Size(K)=1 then 
          U:=NormalizedUnitGroup(KG);
      else
          U:=DirectProduct( K, NormalizedUnitGroup(KG) );
      fi;
      SetIsGroupOfUnitsOfMagmaRing(U,true);
      SetIsUnitGroupOfGroupRing(U,true);
      SetIsCommutative(U, IsCommutative(UnderlyingMagma(KG)));
      SetIsFinite(U, true);
      SetSize( U, Size(Units(LeftActingDomain(KG))) * 
                  Size(NormalizedUnitGroup(KG)));
      SetUnderlyingGroupRing(U,KG);
      return U;
    fi;
    end
    );


#############################################################################
##
#A  PcUnits( <KG> )
##  
InstallMethod( PcUnits,
    "LAGUNA: for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
    local K, U;
    if not IsPrime(Size(LeftActingDomain(KG))) then
      TryNextMethod();
    else           
      K := Units( LeftActingDomain( KG ) );
      if Size(K)=1 then 
          U:=PcNormalizedUnitGroup(KG);
      else
          U:=DirectProduct( K, PcNormalizedUnitGroup(KG) );
      fi;
      SetIsGroupOfUnitsOfMagmaRing(U,false);
      SetIsUnitGroupOfGroupRing(U,true);
      SetUnderlyingGroupRing(U,KG);
      return U;
    fi;  
    end
    );    


#############################################################################
##
#A  NaturalBijectionToPcNormalizedUnitGroup( <KG> )
##  
InstallMethod( NaturalBijectionToPcNormalizedUnitGroup,
        "LAGUNA: for modular group algebra of finite p-group",
        true,
        [ IsPModularGroupAlgebra ],
        0,
        FG -> GroupHomomorphismByFunction( NormalizedUnitGroup( FG ), 
                                           PcNormalizedUnitGroup( FG ),
                                           PcPresentationOfNormalizedUnit(FG) 
) );


#############################################################################
##
#A  NaturalBijectionToNormalizedUnitGroup( <KG> )
##  
InstallMethod( NaturalBijectionToNormalizedUnitGroup,
        "LAGUNA: for modular group algebra of finite p-group",
        true,
        [ IsPModularGroupAlgebra ],
        0,
        FG -> GroupHomomorphismByImagesNC( 
	           PcNormalizedUnitGroup( FG ),
                   NormalizedUnitGroup( FG ),
                   GeneratorsOfGroup( PcNormalizedUnitGroup( FG ) ),
                   GeneratorsOfGroup( NormalizedUnitGroup( FG ) ) ) );


#############################################################################
##
#O  Embedding( <H>, <V> )
##  
##  Let H be a subgroup of a group G and V be the normalized unit group of 
##  the group algebra KG over the field K. Then Embedding( H, V ) returns 
##  the homomorphism from H to V, which is the composition of the mappings 
##  Embedding( H, KG ) and NaturalBijectionToPcNormalizedUnitGroup( KG ).
##
InstallMethod( Embedding,
    "LAGUNA: from group to pc-presented normalized unit group of group ring",
    true,
    [ IsGroup, IsNormalizedUnitGroupOfGroupRing ], 
      0,
    function( H, V )
    local KG, f, h;
    if IsGroupOfUnitsOfMagmaRing(V) then
      Error("LAGUNA: 2nd argument in Embedding(H,V) must be a pc-group \n",
            "In case you need embedding to KG, use Embedding(H,KG) instead! \n");
    else 
      KG:=UnderlyingGroupRing(V);
      if not IsSubgroup( UnderlyingGroup(KG), H ) then
        Error("LAGUNA: 1st argument in Embedding(H,V) is not a subgroup \n",
              "of the underlying group for the 2nd argument! \n");
      else
        f := NaturalBijectionToPcNormalizedUnitGroup(KG);
        return GroupHomomorphismByImagesNC( 
          H,
          V,
          GeneratorsOfGroup( H ),
          List( GeneratorsOfGroup( H ), h -> ( h^Embedding( H, KG ) )^f ) );
      fi;
    fi;  
    end);


#############################################################################
##
#O  Random( <U> )
##  
##  Let U be either a full or normalized unit group of the group algebra KG.
##  Then random( U ) returns its random element taking it from the group 
##  algebra KG (several times, if necessary).
InstallMethod( Random,
    "LAGUNA: for full ot normalized unit group of group ring",
    true,
    [ IsGroupOfUnitsOfMagmaRing ], 
    0,
    function( U )
    local KG, x;
    if IsNormalizedUnitGroupOfGroupRing(U) then
      KG:=UnderlyingGroupRing( U );
      repeat
        x:=Random(KG);
      until IsUnit(KG,x);
      return One(KG) + x - Augmentation( x ) * One(KG);
    elif IsUnitGroupOfGroupRing then
      KG:=UnderlyingGroupRing( U );
      repeat
        x:=Random(KG);
      until IsUnit(KG,x);
      return x;
    else
      TryNextMethod();  
    fi;  
    end);


#############################################################################
##
#A  GroupBases( <FG> )
##  
InstallMethod( GroupBases,
##  Calculation of group basises of the modular group algebra
##  of a finite p-group
  "LAGUNA: for modular group algebra of finite p-group",
  true,
  [ IsPModularGroupAlgebra ], 0,
  function(FG)
  local G, U, f, cc, c, H, bases, hgens, FH;
  G:=UnderlyingMagma(FG);
  U:=PcNormalizedUnitGroup(FG);
  f:=NaturalBijectionToNormalizedUnitGroup(FG);
  cc:=Filtered( ConjugacyClassesSubgroups( U ), H -> 
  Size(Representative(H))=Size(G) );

  bases:=[];

  Info(LAGInfo, 2, "LAGInfo: testing ", Length(cc), 
	                 " conjugacy classes of subgroups");  
      
  for c in cc do
    H:=Representative(c);
    if IsomorphismGroups(G,H) <> fail then
      hgens:=List(GeneratorsOfGroup(H), h -> h^f);
      FH:=Subalgebra(FG, hgens);
      if Dimension(FH)=Size(G) then
        Append( bases, [ List(AsList(H), h -> h^f) ] );
        Info(LAGInfo, 3, "LAGInfo: H is a group basis");
      else
        Info(LAGInfo, 3, "LAGInfo: H linearly dependent");
      fi;
    else
      Info(LAGInfo, 4, "LAGInfo: H not isomorphic to G");    
    fi;
  od;
  return bases;
end);


#############################################################################
##
#O  BassCyclicUnit( <ZG>, <g>, <k> )
#O  BassCyclicUnit( <g>, <k> )
##  
##  Let g be an element of order n of the group G, and 1 < k < n be such that
##  k and n are coprime, then  k^Phi(n) is congruent to 1 modulo n. The unit 
##  b(g,k) = ( \sum_{j=0}^{k-1} g^j )^Phi(n) + ( (1-k^Phi(n))/n ) * Hat(g),
##  where Hat(g) = g + g^2 + ... + g^n, is called a Bass cyclic unit of 
##  the integral group ring ZG.
##  When G is a finite nilpotent group, the group generated by the
##  Bass cyclic units contain a subgroup of finite index in the centre
##  of U(ZG) [E. Jespers, M.M. Parmenter and S.K. Sehgal, Central Units 
##  Of Integral Group Rings Of Nilpotent Groups.
##  Proc. Amer. Math. Soc. 124 (1996), no. 4, 1007--1012].
##
InstallMethod( BassCyclicUnit,
    "for uderlying group element, not embedded into group ring",
    true,
    [ IsGroupRing, IsObject, IsPosInt ],
    0,
    function( ZG, g, k )
    local n, powers, j, bcu, phi, coeff;
    if not IsIntegers( LeftActingDomain( ZG ) ) then
      Error( "LAGUNA : BassCyclicUnit( <ZG>, <g>, <k>  ) : \n",
             " <ZG> must be an integral group ring \n" );
    fi;  
    if not g in UnderlyingGroup( ZG ) then
      Error( "LAGUNA : BassCyclicUnit( <ZG>, <g>, <k>  ) : \n",
             "<g> must be an elements of the UnderlyingGroup(<ZG>) \n" );    
    fi;
    
    n := Order(g);
    
    if k>=n then 
      Error( "LAGUNA : BassCyclicUnit( <ZG>, <g>, <k>  ) : \n",
             "<k> must be smaller than Order(<g>) \n" );    
    fi; 
       
    if not Gcd( n, k )=1 then
      Error( "LAGUNA : BassCyclicUnit( <ZG>, <g>, <k>  ) : \n",
             "Order(<g>) and <k> must be coprime! \n" );    
    fi;    
    
    powers:=[ One(g) ];
    
    for j in [ 2 .. k ] do
      powers[j] := powers[j-1]*g;
    od;   
    
    bcu := ElementOfMagmaRing( FamilyObj( Zero( ZG ) ),
                               0,
                               List( [1..k], i -> 1),
                               powers );
    
    phi := Phi( n ); 
    bcu := bcu^phi;    
    coeff :=  ( 1-k^phi ) / n;       
    
    for j in [ k+1 .. n ] do
      powers[j] := powers[j-1]*g;
    od;                  
                               
    return bcu + ElementOfMagmaRing( FamilyObj( Zero( ZG ) ),
                                     0,
                                     List( [1..n], i -> coeff),
                                     powers );                           
end);


InstallOtherMethod( BassCyclicUnit,
    "for uderlying group element, embedded into group ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep, IsPosInt ],
    0,
    function( g, k )
    local h, n, powers, j, bcu, phi, coeff;
    if not ( Length( CoefficientsAndMagmaElements( g ) ) = 2 and
                     CoefficientsAndMagmaElements( g )[2] = 1 ) then
      Error( "LAGUNA : BassCyclicUnit( <g>, <k> ) : \n",
             "<g> must be group element embedded into integral group ring \n");             
    fi;     
    
    h := CoefficientsAndMagmaElements( g )[1];
    n := Order( g );

    if k>=n then 
      Error( "LAGUNA : BassCyclicUnit( <ZG>, <g>, <k>  ) : \n",
             "<k> must be smaller than Order(<g>) \n" );    
    fi; 
    
    if not Gcd( n, k )=1 then
      Error( "LAGUNA : BassCyclicUnit( <g>, <k>  ) : \n",
             "Order(<g>) and <k> are not coprime! \n" );    
    fi;    
    
    powers:=[ One(h) ];
    
    for j in [ 2 .. k ] do
      powers[j] := powers[j-1]*h;
    od;   
    
    bcu := ElementOfMagmaRing( FamilyObj( Zero( g ) ),
                               0,
                               List( [1..k], i -> 1),
                               powers );
    
    phi := Phi( n ); 
    bcu := bcu^phi;    
    coeff :=  ( 1-k^phi ) / n;       
    
    for j in [ k+1 .. n ] do
      powers[j] := powers[j-1]*h;
    od;                  
                               
    return bcu + ElementOfMagmaRing( FamilyObj( Zero( g ) ),
                                     0,
                                     List( [1..n], i -> coeff),
                                     powers );                           
end);


##########################################################################
##
#O  BicyclicUnitOfType1( <KG>, <a>, <g> )
#O  BicyclicUnitOfType2( <KG>, <a>, <g> )
##
## For elements a and g of the underlying group of a group ring KG,
## returns the bicyclic unit u_(a,g) of the appropriate type.
## If ord a = n, then the bicycle unit of the 1st type is defined as
##
##       u_{a,g} = 1 + (a-1) * g * ( 1 + a + a^2 + ... +a^{n-1} )
##
## and the bicycle unit of the 2nd type is defined as
##
##       v_{a,g} = 1 + ( 1 + a + a^2 + ... +a^{n-1} ) * g * (a-1) 
## 
## u_{a,g} and v_{a,g} may coincide for some a and g, but in general
## this does not hold.
## Note that u_(a,g) is defined when g does not normalize a, but this
## function does not check this.
##
InstallMethod( BicyclicUnitOfType1,
    "for uderlying group elements, not embedded into group ring",
    true,
    [ IsGroupRing, IsObject, IsObject ],
    0,
    function( KG, a, g )
    local i, ap, s, e;
    if not a in UnderlyingGroup( KG ) or not g in UnderlyingGroup( KG ) then
      Error( "LAGUNA : BicyclicUnitOfType1( <KG>, <a>, <g> ) : \n",
             "<a> and <g> must be elements of the UnderlyingGroup(<KG>) \n" );    
    fi;
    a := a^Embedding( UnderlyingGroup(KG), KG);
    g := g^Embedding( UnderlyingGroup(KG), KG);
    e := One(a);
    if IsOne(a) then
      return a;
    fi;
    s := e;
    ap := a;
    while not IsOne(ap) do
      s := s+ap;
      ap := ap*a;
    od;
    return e+(a-e)*g*s;
end);

InstallMethod( BicyclicUnitOfType2,
    "for uderlying group elements, not embedded into group ring",
    true,
    [ IsGroupRing, IsObject, IsObject ],
    0,
    function( KG, a, g )
    local i, ap, s, e;
    if not a in UnderlyingGroup( KG ) or not g in UnderlyingGroup( KG ) then
      Error( "LAGUNA : BicyclicUnitOfType2( <KG>, <a>, <g> ) : \n",
             "<a> and <g> must be elements of the UnderlyingGroup(<KG>) \n" );    
    fi;
    a := a^Embedding( UnderlyingGroup(KG), KG);
    g := g^Embedding( UnderlyingGroup(KG), KG);
    e := One(a);
    if IsOne(a) then
      return a;
    fi;
    s := e;
    ap := a;
    while not IsOne(ap) do
      s := s+ap;
      ap := ap*a;
    od;
    return e+s*g*(a-e);
end);


##########################################################################
##
#O  BicyclicUnitOfType1( <a>, <g> )
#O  BicyclicUnitOfType2( <a>, <g> )
##
## In this form of this function the first argument KG is omitted, and 
## a and g are elements of underlying group, embedded to its group ring.
## Note that u_(a,g) is defined when g does not normalize a, but this
## function does not check this.
##
InstallOtherMethod( BicyclicUnitOfType1,
    "for uderlying group elements, embedded into group ring",
    IsIdenticalObj, # to make sure that they are in the same group ring
    [IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep,
    IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep],
    0,
    function( a, g )
    local i, ap, s, e, x;
    if not ForAll( [a,g], x -> 
                   Length( CoefficientsAndMagmaElements( x ) )=2 and
                   IsOne( CoefficientsAndMagmaElements( x )[2] ) ) then
      Error( "LAGUNA : BicyclicUnitOfType1( <a>, <g> ) : \n",
             "<a> and <g> must be group elements embedded into group ring \n");             
    fi;                
    e := One(a);
    if IsOne(a) then
      return a;
    fi;
    s := e;
    ap := a;
    while not IsOne(ap) do
      s := s+ap;
      ap := ap*a;
    od;
    return e+(a-e)*g*s;
end);

InstallOtherMethod( BicyclicUnitOfType2,
    "for uderlying group elements, embedded into group ring",
    IsIdenticalObj, # to make sure that they are in the same group ring
    [IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep,
    IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep],
    0,
    function( a, g )
    local i, ap, s, e, x;
    if not ForAll( [a,g], x -> 
                   Length( CoefficientsAndMagmaElements( x ) )=2 and
                   IsOne( CoefficientsAndMagmaElements( x )[2] ) ) then
      Error( "LAGUNA : BicyclicUnitOfType1( <a>, <g> ) : \n",
             "<a> and <g> must be group elements embedded into group ring \n");             
    fi; 
    e := One(a);
    if IsOne(a) then
      return a;
    fi;
    s := e;
    ap := a;
    while not IsOne(ap) do
      s := s+ap;
      ap := ap*a;
    od;
    return e+s*g*(a-e);
end);


###########################################################################
##
#A  BicyclicUnitGroup( <V(KG)> )
##
##  KG is a modular group algebra and V(KG) is its normalized unit group.
##  Returns the subgroup of V(KG) generated by all bicyclic units u_{g,h}
##  and v_{g,h}, where g and h run over the elements of the underlying
##  group, and h do not belongs to the normalizer of <g> in G.
InstallMethod( BicyclicUnitGroup,
    "for the normalized unit group in natural representation",
    true,
    [ IsNormalizedUnitGroupOfGroupRing ],
    0,
    function( V )
    local KG, G, elts, emb, gens, g, N, nh, h, x, elt, i;
    if not IsGroupOfUnitsOfMagmaRing(V) then
      TryNextMethod();
    fi;  
    KG := UnderlyingGroupRing( V );
    G := UnderlyingGroup( KG );
    elts := Elements( G );
    emb := Embedding(G, KG);
    gens := [];
    for i in [ 1 .. Length(elts) ] do
      Info(LAGInfo, 4, i);    
      g:=elts[i];
      N:=Normalizer ( G, Subgroup( G, [g] ));
      nh := Filtered( elts, x -> not x in N);
      for h in nh do
        elt := BicyclicUnitOfType1( g^emb, h^emb);
        AddSet( gens, elt );
        elt := BicyclicUnitOfType2( g^emb, h^emb);
        AddSet( gens, elt );
      od;
    od;
    return Subgroup( V, gens );
end);

InstallMethod( BicyclicUnitGroup,
    "for the normalized unit group in pc-presentation",
    true,
    [ IsNormalizedUnitGroupOfGroupRing ],
    0,
    function( V )
    local KG, G, elts, emb, gens, g, N, nh, h, x, elt, i, f;
    if IsGroupOfUnitsOfMagmaRing(V) then
      TryNextMethod();
    fi;  
    KG := UnderlyingGroupRing( V );
    G := UnderlyingGroup( KG );
    elts := Elements( G );
    emb := Embedding(G, KG);
    gens := [];
    f:=NaturalBijectionToPcNormalizedUnitGroup( KG );
    for i in [ 1 .. Length(elts) ] do
      Info(LAGInfo, 4, i);    
      g:=elts[i];
      N:=Normalizer ( G, Subgroup( G, [g] ));
      nh := Filtered( elts, x -> not x in N);
      for h in nh do
        elt := BicyclicUnitOfType1( g^emb, h^emb)^f;
        AddSet( gens, elt );
        elt := BicyclicUnitOfType2( g^emb, h^emb)^f;
        AddSet( gens, elt );
      od;
    od;
    return Subgroup( V, gens );
end);


###########################################################################
##
#A  UnitarySubgroup( <V(KG)> )
##
InstallMethod( UnitarySubgroup,
    "for the normalized unit group in natural representation",
    true,
    [ IsNormalizedUnitGroupOfGroupRing ],
    0,
    function( V )
    local KG, W, f, x, U, gens;
    if not IsGroupOfUnitsOfMagmaRing(V) then
      TryNextMethod();
    fi;  
    KG := UnderlyingGroupRing( V );
    W  := PcNormalizedUnitGroup( KG );
    f  := NaturalBijectionToNormalizedUnitGroup( KG );
    U  := Subgroup( W, Filtered( W, x -> IsUnitary(x^f) ) );
    gens := MinimalGeneratingSet( U );
    return Subgroup( V, List( gens, x -> x^f ) );
end);

InstallMethod( UnitarySubgroup,
    "for the normalized unit group in pc-presentation",
    true,
    [ IsNormalizedUnitGroupOfGroupRing ],
    0,
    function( V )
    local KG, f, x, U, gens;
    if IsGroupOfUnitsOfMagmaRing(V) then
      TryNextMethod();
    fi;  
    KG := UnderlyingGroupRing( V );
    f  := NaturalBijectionToNormalizedUnitGroup( KG );
    U  := Subgroup( V, Filtered( V, x -> IsUnitary(x^f) ) );
    gens := MinimalGeneratingSet( U );
    return Subgroup( V, gens );
end);



#############################################################################
##
## LIE PROPERTIES OF GROUP ALGEBRAS
##
#############################################################################

 
#############################################################################
##
#M  LieAlgebraByDomain( <A> )
##  

InstallMethod( LieAlgebraByDomain,
##  This method takes a group algebra, and constructs its associated Lie 
##  algebra, in which the product is the bracket operation: [a,b]=ab-ba.
##  The user, however, will {\bf never use} this command, but will rather 
##  use LieAlgebra( <A> ), which either returns the Lie algebra in case
##  it is already constructed, or refers to LieAlgebraByDomain in case 
##  it is not.
        
    "LAGUNA: for an associative algebra",
    true,
    [ IsAlgebra and IsAssociative ], 0,
    function( A )

       local fam,L;

       if HasIsGroupAlgebra( A ) then
         if IsGroupAlgebra( A ) then

           Info(LAGInfo, 1, "LAGUNA package: Constructing Lie algebra ..." );

           fam:= LieFamily( ElementsFamily( FamilyObj( A ) ) );

           L:= Objectify( NewType( CollectionsFamily( fam ) ,
                            IsLieAlgebraByAssociativeAlgebra and 
                            IsLieObjectsModule and
                            IsAttributeStoringRep ),
                          rec() );

           # Set the necessary attributes.
           SetLeftActingDomain( L, LeftActingDomain( A ) );
           SetUnderlyingAssociativeAlgebra( L, A );
       
           # Test for inherited properties from A and set them where appropriate:
         
           if HasIsGroupRing(A) then
             SetIsLieAlgebraOfGroupRing(L, IsGroupRing(A));
           fi;

           if HasIsFiniteDimensional(A) then 
             SetIsFiniteDimensional(L, IsFiniteDimensional(A));
           fi;

           if HasDimension(A) then 
             SetDimension(L, Dimension(A));
           fi;

           if HasIsFinite(A) then 
             SetDimension(L, IsFinite(A));
           fi;

           if HasSize(A) then 
             SetDimension(L, Size(A));
           fi;
     
           return L;
	 else # if not IsGroupAlgebra(A)
	   TryNextMethod();  
         fi;
       else # if not HasIsGroupAlgebra(A) 
         TryNextMethod();
       fi;
  end );


InstallMethod( \in,
  "LAGUNA: for a Lie algebra that comes from an associative algebra and a Lie object",
    true,
    [ IsLieObject, IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    function( x, L )

      return x![1] in UnderlyingAssociativeAlgebra( L ); 

end );


InstallMethod( GeneratorsOfLeftOperatorRing,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    function( L )

    return List( BasisVectors( Basis( UnderlyingAssociativeAlgebra( L ) ) ),
                 LieObject );
end); 


InstallMethod( IsFiniteDimensional,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> IsFiniteDimensional( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( Dimension,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> Dimension ( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( IsFinite,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> IsFinite ( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( Size,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> Size ( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( AsSSortedList,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> List(AsSSortedList(UnderlyingAssociativeAlgebra(L)), LieObject)
);
      

InstallMethod( Representative,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> LieObject(Representative(UnderlyingAssociativeAlgebra( L ) ) ) );


InstallMethod( Random,
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> LieObject(Random(UnderlyingAssociativeAlgebra( L ) ) ) );


#############################################################################
##
#M  CanonicalBasis( <L> )
##  

InstallMethod( CanonicalBasis,
##  This method transfers the canonical basis of an associative algebra
##  to its associated Lie algebra $L$.
    "LAGUNA: for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    function(L)
      local A,B,t;
      
      A:=UnderlyingAssociativeAlgebra(L);
      t:=NaturalBijectionToLieAlgebra(A);
      B:=BasisNC(L, List(AsSSortedList(CanonicalBasis(A)), x -> x^t));
      SetIsCanonicalBasis(B, true);
      return B;
    end);


#############################################################################
##
#M  CanonicalBasis( <L> )
##  

InstallMethod( CanonicalBasis,
##  This method directly computes the canonical basis of the Lie algebra
##  of a group algebra without referring to the group algebra, i.e. by
##  sending the group elements directly to the Lie algebra.
    "LAGUNA: for a Lie algebra of a group algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    function(L)
      local G,t,B;
      
      G:=UnderlyingGroup(L);
      t:=Embedding(G,L);
      B:=BasisNC(L, List(AsSSortedList(G), x -> x^t));
      SetIsCanonicalBasis(B, true);
      SetIsBasisOfLieAlgebraOfGroupRing(B, true);
      return B;
    end);


#############################################################################
##
#M  StructureConstantsTable( <B> )
##  

InstallMethod( StructureConstantsTable,
##  A very fast implementation for calculating the structure constants
##  of a Lie algebra of a group ring w.r.t. its canonical basis $B$ by
##  using the special structure of $B$.
    "LAGUNA: for a basis of a Lie algebra of a group algebra",
    true,
    [ IsBasis and IsCanonicalBasis and IsBasisOfLieAlgebraOfGroupRing ], 0,
    function(B)
      local L,F,e,o,G,n,X,T,i,j,g,h;
      Info(LAGInfo, 1, "LAGUNA package: Computing the structure constants table ..." );
      L:=UnderlyingLeftModule(B);
      F:=LeftActingDomain(L);
      e:=One(F);
      o:=Zero(F);
      G:=UnderlyingGroup(L);
      n:=Size(G);
      X:=AsSSortedList(G);
      T:=EmptySCTable(n,o,"antisymmetric");
      for i in [1..n-1] do
        for j in [i+1..n] do
          g:=X[i]*X[j];
          h:=X[j]*X[i];
          if g<>h then
            SetEntrySCTable(T,i,j,[e,Position(X,g),-e,Position(X,h)]);
          fi;
        od;
      od;
      return T;
    end);


InstallMethod( UnderlyingGroup,
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraOfGroupRing ], 0,
    L -> UnderlyingMagma( UnderlyingAssociativeAlgebra( L ) ) );


InstallMethod( NaturalBijectionToLieAlgebra,
    "LAGUNA: for an associative algebra",
    true,
    [ IsAlgebra and IsAssociative ], 0,
    function( A )
      local map;

      map:= MappingByFunction( A,  LieAlgebra( A ),
                               LieObject,
                               y -> y![1] );
      SetIsLeftModuleGeneralMapping( map, true );

      return map;
    end );


InstallMethod( NaturalBijectionToAssociativeAlgebra,
    "LAGUNA: for a Lie algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    
    L -> InverseGeneralMapping( NaturalBijectionToLieAlgebra( 
                             UnderlyingAssociativeAlgebra(L)))
);


InstallMethod( IsLieAlgebraOfGroupRing,
    "LAGUNA: for a Lie algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    L->IsGroupRing(UnderlyingAssociativeAlgebra(L))
);

#############################################################################
##
#O  Embedding( <U>, <L> )
##  
##  Let <U> be a submagma of a group $G$, $A:=FG$ be the group ring of $G$
##  over some field $F$, and let <L> be the associated Lie algebra of $A$.
##  Then `Embedding( <U>, <L> )' returns the obvious mapping $<U> \to <L>$
##  (as the composition of the mappings `Embedding( <U>, <A> )' and
##  `NaturalBijectionToLieAlgebra( <A> )'~).

InstallMethod( Embedding,
    "LAGUNA: from a group to the Lie algebra of the group ring",
    true,
    [ IsMagma,
      IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    function( U, L )
      local A;
      A:=UnderlyingAssociativeAlgebra(L);
      return Embedding(U,A)*NaturalBijectionToLieAlgebra(A);
    end
);


InstallMethod( AugmentationHomomorphism,
    "LAGUNA: for a group ring",
    true,
    [ IsAlgebraWithOne and IsGroupRing ], 0,
    function(FG)
      local G,X,F,e,x;
      G:=UnderlyingMagma(FG);
      X:=GeneratorsOfMagmaWithOne(G);
      F:=LeftActingDomain(FG);
      e:=Embedding(G,FG);
      return AlgebraHomomorphismByImagesNC(
               FG,
               F,
               List(X, x -> x^e),
               ListWithIdenticalEntries(Length(X), One(F))
             );
      end);


#############################################################################
##
#M  LieDerivedSubalgebra( <L> )
##  

InstallMethod( LieDerivedSubalgebra,
##  The (Lie) derived subalgebra of a Lie algebra of a group ring can
##  be calculated very fast by considering the conjugacy classes of the 
##  group. Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    function(L)
      local G, CC, t, B, C, s, K, j, i, x, S;
      Info(LAGInfo, 1, "LAGUNA package: Computing the Lie derived subalgebra ..." );
      G:=UnderlyingGroup(L);
      CC:=ConjugacyClasses(G);
      t:=Embedding(G,L);
      B:=[ ];               # This list will collect the basis elements
      for C in CC do
        s:=Size(C);
        if s>1 then         # no need to consider central elements
          K:=AsSSortedList(C);   # Need to have all elements of C
          x:=K[s]^t;        # shift last element in C into Lie algebra L
          j:=Length(B);     # remember length to add more elements
          for i in [1..s-1] do   # commutators in L are just differences of
            B[j+i]:= K[i]^t - x; # conjugate elements of G (shifted into
          od;                    # the Lie algebra L via the map t). (The
        fi;                      # construction mimicks a matrix with 1's on
      od;                        # the diag and -1's in the last column.)
      S := Subalgebra(L, B, "basis");
      Setter( IsTwoSidedIdealInParent )( S, true ); 
      return S;
    end);


#############################################################################
##
#M  LieCentre( <L> )
##  

InstallMethod( LieCentre,
##  The (Lie) centre of a Lie algebra of a group ring corresponds to the
##  centre of the underlying group ring, and it can
##  be calculated very fast by considering the conjugacy classes
##  of the group.
##  Since the corresponding method for the centre of the group ring
##  does just that, it is being referred to by the method at hand.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
##  This is particularly important for the command LieCentre.
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    function(L)
      local A;
      A:=UnderlyingAssociativeAlgebra(L);
      return Subalgebra(L,
                        ImagesSet(NaturalBijectionToLieAlgebra(A),
                                  Basis(Centre(A))
                                 ),
                        "basis"
                       );
    end);


#############################################################################
##
#M  IsLieAbelian( <L> )
##  

InstallMethod( IsLieAbelian,
##  The Lie algebra $L$ of an associative algebra  $A$ is Lie abelian,
##  if and only if $A$ is abelian, so this method refers
##  to IsAbelian( <A> ).
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
##  This is particularly important for the command IsLieAbelian.
    "LAGUNA: for a Lie algebra of an associative algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> IsAbelian( UnderlyingAssociativeAlgebra( L ) ) );


#############################################################################
##
#M  IsLieSolvable( <L> )
##  

InstallMethod( IsLieSolvable,
##  In `Lie solvable group rings', Canad. J. Math. 25, No. 4 (1973), 748-757, 
##  Passi-Passman-Sehgal have classified all groups $G$ such that the
##  associated
##  Lie algebra $L$ of the group ring is (Lie) solvable. This method uses
##  their classification, making it considerably faster than
##  the more elementary method which just calculates Lie commutators.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    
    function(L)
      local p,s;
      Info(LAGInfo, 1, "LAGUNA package: Checking Lie solvability ..." );
      p:=Characteristic(L);
      if p=0 then
        return IsLieAbelian(L);
      fi;
      s:= (   [ p ]
            = Set(Factors(Size(DerivedSubgroup(UnderlyingGroup(L)))))
          );
      if s or p>2 then
        return s;
      else
        return ForAny(SubgroupsOfIndexTwo(UnderlyingGroup(L)),
                      M -> [2]=Set(Factors(Size(DerivedSubgroup(M))))
                     );
      fi;
    end);


#############################################################################
##
#M  IsLieNilpotent( <L> )
##  

InstallMethod( IsLieNilpotent,
##  In `Lie solvable group rings', Canad. J. Math. 25, No. 4 (1973), 748-757, 
##  Passi-Passman-Sehgal have classified all groups $G$ such that the
##  associated
##  Lie algebra $L$ of the group ring is (Lie) nilpotent. This method uses
##  their classification, making it considerably faster than
##  the more elementary method which just calculates Lie commutators.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    
    function(L)
      local p,G;
      Info(LAGInfo, 1, "LAGUNA package: Checking Lie nilpotency ..." );
      p:=Characteristic(L);
      if p=0 then
        return IsLieAbelian(L);
      fi;
      G:=UnderlyingGroup(L);
      return
        [p]=Set(Factors(Size(DerivedSubgroup(G))))
        and IsNilpotent(G);
    end);


InstallMethod( IsLieMetabelian,
    "LAGUNA: for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra], 0,
    L->(0=Dimension(LieDerivedSubalgebra(LieDerivedSubalgebra(L))))
);


#############################################################################
##
#M  IsLieMetabelian( <L> )
##  

InstallMethod( IsLieMetabelian,
##  In `Lie metabelian group rings', Group and semigroup rings, North-Holland, 
##  1986, 153-161, Levin and Rosenberger have classified all groups $G$ 
##  such that the associated
##  Lie algebra $L$ of the group ring is (Lie) metabelian. This method uses
##  their classification, making it considerably faster than
##  the more elementary method which just calculates Lie commutators.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    
    function(L)
      local p,G,D;
      if IsLieAbelian(L) then
        return true;
      fi;
      p:=Characteristic(L);
      G:=UnderlyingGroup(L);
      D:=DerivedSubgroup(G);
      return
        (p=3 and Size(D)=3 and IsSubset(Centre(G),D))
         or
        (p=2 and Size(D)<=4 and Exponent(D)=2 and IsSubset(Centre(G),D));
    end
);


InstallMethod( IsLieCentreByMetabelian,
    "LAGUNA: for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra and HasLieDerivedSeries ], 0,
    L->IsSubset(LieCentre(L), LieDerivedSeries(L)[3]));


InstallMethod( IsLieCentreByMetabelian,
    "LAGUNA: for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function(L)
      local C,B,d,i,j;
      C:=LieCentre(L);
      B:=Filtered(AsSSortedList(Basis(LieDerivedSubalgebra(L))),
                  x -> not (x in C)
                 );
      d:=Length(B);
      for i in [1..d-1] do
        for j in [i+1..d] do
          if not (B[i]*B[j] in C) then
            return false;
          fi;
        od;
      od;
      return true;
    end);


#############################################################################
##
#M  IsLieCentreByMetabelian( <L> )
##  

InstallMethod( IsLieCentreByMetabelian,
##  In various papers,
##  K\"ulshammer, Sahai, Sharma, Srivastava and the 3rd author of the 
##  present package have classified all groups $G$ 
##  such that the associated
##  Lie algebra $L$ of the group ring is (Lie) centre-by-metabelian. 
##  (The most general result to date may be found in the preprint
##  `Lie centre-by-metabelian group algebras over commutative rings',
##  available on the authors' WWW pages under
##  http://www.mathematik.uni-jena.de/algebra/skripten/{\#}rossmanith.)
##  This method uses
##  the classification, making it considerably faster than
##  the more elementary method which just calculates Lie commutators.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
    "LAGUNA: for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    
    function(L)
      local p,G,D,C,a;
      if IsLieAbelian(L) then
        return true;
      fi;
      G:=UnderlyingGroup(L);
      D:=DerivedSubgroup(G);
      if not IsAbelian(D) then
        return false;
      fi;                      # now we have a nonabelian, metabelian group
      p:=Characteristic(L);
      if p=2 then                   # The checks for the p=2 case could
        if (Size(D) in [2,4]) then  # be formulated more compactly, however
          return true;              # this turns out to be the fastest way.
        else
          C:=Centralizer(G,D);
          if Size(D)=8 and C=G and Exponent(D)=2 then
            return true;
          elif Index(G,C)=2 then
            if IsAbelian(C) then
              return true;
            else
              a:=First(GeneratorsOfGroup(G), x -> not (x in C));
              if Size(D)=8 and Exponent(D)=4       # D = C2xC4
                and DerivedSubgroup(C)=Agemo(D,2)
                and ForAll(GeneratorsOfGroup(D), x -> (x^a=x^-1) )
              then
                return true;
              fi;
            fi;
          elif (G=C) then 
            if ForAny(SubgroupsOfIndexTwo(G), IsAbelian) then
              return true;
            fi;
          fi;
        fi;
        return false;
      elif p=3 then
        return Size(D)=3;
      else
        return false;
      fi;
    end);
    

#############################################################################
##
#M  LieUpperNilpotencyIndex( <R> )
##  
InstallMethod( LieUpperNilpotencyIndex,
    "LAGUNA: for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
                local lds, d, i, t, m, p;
                p:=Characteristic( LeftActingDomain( KG ) );
                lds:=LieDimensionSubgroups(UnderlyingMagma(KG));

                d:=[ ];
                for i in [1 .. Length(lds)-1 ] do
                        d[i] := LogInt( Index( lds[i], lds[i+1]), p );
                od;

                t:=0;
                for m in [ 1 .. (Length(d)-1) ] do
                        t:=t+m*d[m+1];
                od;
                t := 2 + ( PrimePGroup( UnderlyingMagma(KG) ) - 1 ) * t;
                
                return t;
                end

                );

#############################################################################
##
#M  LieLowerNilpotencyIndex( <R> )
##  
InstallMethod( LieLowerNilpotencyIndex,
  "LAGUNA: for modular group algebra of finite p-group",
  true,
  [ IsPModularGroupAlgebra ],
  0,
  KG -> NilpotencyClassOfGroup(PcNormalizedUnitGroup(KG))+1 );


#############################################################################
##
#A  LieDerivedLength( <L> )
##  
InstallMethod( LieDerivedLength,
    "LAGUNA: for a Lie algebra",
    true,
    [ IsLieAlgebra ], 
    0,
    L -> Length( LieDerivedSeries( L ) ) -1 );


#############################################################################
##
## SOME IMPORTANT GROUP-THEORETICAL ATTRIBUTES
##
#############################################################################


InstallMethod( SubgroupsOfIndexTwo,
    "LAGUNA: for a group",
    true,
    [ IsGroup ], 0,
    function(G)
      local D,i,f,A,subs;
      D:=DerivedSubgroup(G);
      i:=Index(G,D);
      if i=2 then
        return [D];
      elif 0=(i mod 2) then
        f:=NaturalHomomorphismByNormalSubgroup(G,D);
        A:=ImagesSource(f);
        SetIsAbelian(A, true);
        subs:=Filtered(MaximalSubgroups(A), M->(2=Index(A,M)));
        return List( subs, M -> PreImagesSet(f,M) );
      else
        return [];
      fi;
    end);


InstallMethod( SubgroupsOfIndexTwo,
    "LAGUNA: for a group",
    true,
    [ IsGroup and HasMaximalSubgroupClassReps ], 0,
    G -> Filtered(MaximalSubgroupClassReps(G), M->(2=Index(G,M))));


InstallMethod( SubgroupsOfIndexTwo,
    "LAGUNA: for a group",
    true,
    [ IsGroup and HasMaximalNormalSubgroups ], 0,
    G -> Filtered(MaximalNormalSubgroups(G), M->(2=Index(G,M))));


#############################################################################
##
#A  DihedralDepth( <G> )
##  
InstallMethod( DihedralDepth,
##  The dihedral depth of a finite 2-group $G$ is equal to $d$, if the maximal
##  size of the dihedral subgroup contained in a group $G$ is $2^(d+1)$
    "LAGUNA: for a group",
    true,
    [ IsGroup ], 0,
    function(G)
        local o2, cc, x, sizes, i, j, a, b;
        if IsTrivial(G) then       # we formally put d=-1 for trival group
            return -1;           
        elif PrimePGroup(G)<>2 then 
            Error("G is not a finite 2-group");
        elif IsAbelian(G) then     # first we check abelian case
            o2:=Size(Omega(G,2,1));
            if o2=2 then           # if there is only one involution 
                return 0;
            elif o2>2 then         # if there are more involutions
                return 1;
            fi;
        else                       # it remains to consider non-abelian case
            cc:=ConjugacyClasses(G);
            # since G is non-abelian, there are non-trivial classes,
            # but it might be possible that all elements of order 2 are central
            cc:=Filtered(cc, x -> Size(x) > 1 and Order(Representative(x))=2);
            if Length(cc)=0 then   # if this is the case, we consider the center
                return DihedralDepth(Center(G));
            elif Length(cc)=1 then # if we have only one such class, we may take
                                   # another element from the center, which is
                                   # non-trivial, and generate C_2 \times C_2 
                return 1;
            else                   # if we have more than one such class
                sizes:=[];
                for i in [1 .. Length(cc)-1] do
                    for j in [2 .. Length(cc)] do
                        a:=Representative(cc[i]); # up to conjugacy we need 
                                                  # only one representative
                                                  # from the 1st class but
                                                  # we will use every element
                                                  # from the 2nd class  
                        for b in AsList(cc[j]) do
                            if a*b<>b*a then
                                AddSet(sizes, Size(Subgroup(G,[a,b])));
                            fi;    
                        od;
                    od;
                od;
                if Length(sizes)=0 then
                    return 1; # this means that all involutions commute, 
                              # but there are at least two of them
                else 
		    # at least non-trivial cas
                    return LogInt(Maximum(sizes),2)-1; 
                fi;             
            fi;
        fi;
        end);

                             
###########################################################################
#
# DimensionBasis( G )
#
# Computes the Jennings basis (aka dimension basis) for a p-group G. 
# The Jennings basis is a polycyclic generating set {a_i} such that 
# all terms J_k of the Jennings series can be written as <a_j | j>=i_k>/
InstallMethod( DimensionBasis,
    "LAGUNA: for a finite p-group",     
        true,
    [ IsGroup ],
    0,
    function( g )
        local i, j, w, b, n, gens, x;
 
        Info(LAGInfo, 2, "LAGInfo: Calculating dimension basis ..." );

        j := JenningsSeries( g );
        b := [];
        w := [];
      
        for i in [ 1 .. Length(j)-1 ] do        
            n:= NaturalHomomorphismByNormalSubgroup( j[i], j[i+1] );
            gens := Filtered( MinimalGeneratingSet( Image( n )), 
	                                        x -> not IsOne(x) );
            if Length(gens) > 0 then
                Info(LAGInfo, 3, i," ", List(gens,Order) );
                Append( w, List( gens, x->i ));
                Append( b, List( gens, x->PreImagesRepresentative( n, x )));
            fi;
        od;
     
        Info(LAGInfo, 2, "LAGInfo: dimension basis finished !" );
     
        return rec( dimensionBasis := b, weights := w );
        
        end 
        );            
        

#############################################################################
##
#A  LieDimensionSubgroups( <G> )
##  
InstallMethod( LieDimensionSubgroups,
    "LAGUNA: for a finite p-group",
    true,
    [ IsGroup ],
    0,
    function( G )
                local lds, j, m;
                lds:=[ G ];
                j:=JenningsSeries(G);
                m:=0;
                while Size( lds[m+1] ) <> 1 do
                m:=m+1; 
                        lds[m+1] := CommutatorSubgroup(j[m],G);
                od;     
        return lds;
        end
        );


#############################################################################
##
#A  LieUpperCodimensionSeries( <KG> )
#A  LieUpperCodimensionSeries( <G> )
##  
InstallMethod( LieUpperCodimensionSeries,
    "LAGUNA: for a modular group algebra of a finite p-group using V(KG)",
    true,
    [ IsGroupRing ],
    0,
    function( KG )
    local G, V, ucs, f, g, H;
    if not HasLieUpperCodimensionSeries( UnderlyingGroup(KG) ) then
      # We compute Lie upper codimension series by computing
      # the V(KG) and its upper central series at the first step
      # and then taking their intersection with the group G
      G  := UnderlyingGroup( KG );
      V  := PcNormalizedUnitGroup( KG );
      ucs:= UpperCentralSeries( V );
      f  := Embedding( G, V );
      H  := Image( f, G );
      SetLieUpperCodimensionSeries( UnderlyingGroup(KG),
        List( ucs, g -> PreImage( f, Intersection( H, g ) ) ) );
    fi;
    return LieUpperCodimensionSeries( UnderlyingGroup(KG) );
    end);

InstallMethod( LieUpperCodimensionSeries,
    "LAGUNA: for a p-group - underlying group of its modular group algebra",
    true,
    [ IsGroup ],
    0,
    function( G )
    if HasLieUpperCodimensionSeries( G ) then
      return LieUpperCodimensionSeries( G );
    else
      Error("LAGUNA: first you need compute LieUpperCodimensionSeries \n",
            "for a modular group algebra of G !!! \n");
    fi;
    end);


############################################################################
##
#E
##