############################################################################
##  
#W    lag.gi                 The LAG package                     Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods applicable to group rings and their 
##  elements, and to associated Lie algebras of associative algebras, 
##  in particular group algebras.
##



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
    R -> IsFinite(UnderlyingMagma(R)) and Characteristic(LeftActingDomain(R)) <> 0 and 
         Size(UnderlyingMagma(R)) mod Characteristic(LeftActingDomain(R)) = 0 );    


#############################################################################
##
#P  IsPModularGroupAlgebra( <R> )
##  
##  We define separate property for modular group algebras of finite p-groups.
##  This property will be determined automatically for every group ring, 
##  created by the function `GroupRing'
InstallImmediateMethod( IsPModularGroupAlgebra,
    IsFModularGroupAlgebra, 0,
    R -> IsPGroup(UnderlyingMagma(R)) and Characteristic(LeftActingDomain(R)) <> 0 and 
         PrimePGroup(UnderlyingMagma(R)) = Characteristic(LeftActingDomain(R)) ); 


#############################################################################
##
#M  UnderlyingGroup( <R> )
##  
##  This attribute returns the result of the function `UnderlyingMagma' and
##  was defined for group rings mainly for convenience and teaching purposes
InstallMethod( UnderlyingGroup, [IsGroupRing],    UnderlyingMagma  );


#############################################################################
##
#M  UnderlyingRing( <R> )
##  
##  This attribute returns the result of the function `LeftActingDomain' and
##  for convenience was defined for group rings mainly for teaching purposes
InstallMethod( UnderlyingRing,  [IsGroupRing],    LeftActingDomain );


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
    "for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    function(elt)
    local i, l;
    l:=CoefficientsAndMagmaElements(elt);
    return List([ 1 .. Length(l)/2], i -> l[2*i-1]);
    end
    );     


#############################################################################
##
#M  CoefficientsBySupport( <x> )
##  
##  List of coefficients for elements of Support(x) 
InstallMethod( CoefficientsBySupport,
    "for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    function(elt)
    local i, l;
    l:=CoefficientsAndMagmaElements(elt);
    return List([ 1 .. Length(l)/2], i -> l[2*i]);
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
    "for an element of a magma ring",
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
##  Length of an element of a group ring is the number of elements in its support
InstallMethod( Length,
    "for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    elt -> Length(CoefficientsAndMagmaElements(elt)) / 2 );  


#############################################################################
##
#M  Augmentation( <x> )
##  
##  Augmentation of a group ring element $ x = \sum \alpha_g g $ is the sum 
## of coefficients $ \sum \alpha_g $
InstallMethod( Augmentation,
    "for an element of a magma ring",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    function(elt)
    if IsZero(elt) then
    	return ZeroCoefficient(elt);
    else
    	return Sum( CoefficientsBySupport( elt ) );
    fi;    
    end
    );   


#############################################################################
##
#M  Involution( <x>, <mapping> )
## 
InstallMethod( Involution,
    "for for an element of a group ring and a group mapping of order 2 onto itself",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep, IsMapping ], 
    0,
    function(x,map)
    local g;
    if Source(map) <> Range(map) then 
    	Error("Involution: Source(map) <> Range (map)");
    elif Order(map) <> 2 then
    	Error("Involution: Order(map) <> 2");
    else
        return ElementOfMagmaRing( FamilyObj(x), 
                                   ZeroCoefficient(x), 
                                   CoefficientsBySupport(x), 
                                   List(Support(x), g -> g^map) ) ;
    fi;
    end
    ); 
    

#############################################################################
##
#M  Involution( <x> )
## 
InstallOtherMethod( Involution,
    "classical involution for an element of a group ring ",
    true,
    [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ], 
    0,
    x -> ElementOfMagmaRing( FamilyObj(x), 
                             ZeroCoefficient(x), 
                             CoefficientsBySupport(x), 
                             List(Support(x), g -> g^-1) ) );  

#############################################################################
##
#M  IsUnit( <R>, <x> )
## 
InstallMethod (IsUnit,
	"for an element of modular group algebra",
	true,
	[ IsPModularGroupAlgebra, IsElementOfMagmaRingModuloRelations and 
                                  IsMagmaRingObjDefaultRep ],
	0,
	function(KG,elt)
	return not Augmentation( elt ) = Zero( UnderlyingField( KG ) ); 
	end)
	;	
	
#############################################################################
##
#M  IsUnit( <x> )
## 
InstallOtherMethod (IsUnit,
	"for an element of modular group algebra",
	true,
	[ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ],
	0,
	function( elt )
	
	local S;
	
	# if we have element of the form coefficient*group element
	# we switch to use standart method for magma rings
	
	if Length(CoefficientsAndMagmaElements(elt)) = 2 then
		TryNextMethod();
	else
	
	    # generate the support group, and if it appears to be a finite p-group
	    # we check whether coefficients are from field of characteristic p
	    
	    S:=Group(Support(elt)); 
	    if IsPGroup(S) then
	    	if PrimePGroup(S) mod Characteristic(ZeroCoefficient(elt)^0) = 0 then
	    	    return not Augmentation( elt ) = ZeroCoefficient( elt ) ;
	    	fi;
	    else        
        	TryNextMethod(); # since our case is not modular        		
    	fi;   
    fi;		
	
	end
	);
	

#############################################################################
##
#M  InverseOp( <x> )
## 
InstallOtherMethod( InverseOp,
  "for an element of modular group algebra",
  true,
  [ IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep ],
  0,
  function( elt )
  local inv, pow, x, u, S, a;
	
  # if we have element of the form coefficient*group element
  # we switch to use standart method for magma rings
	
  if Length(CoefficientsAndMagmaElements(elt)) = 2 then
    TryNextMethod();
  else
	
  # generate the support group, and if it appears to be a finite p-group
  # we check whether coefficients are from field of characteristic p
	    
  S:=Group(Support(elt)); 
    if IsPGroup(S) then
      if PrimePGroup(S) mod Characteristic(ZeroCoefficient(elt)^0) = 0 then
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
      fi;	
    else        
      TryNextMethod(); # since our case is not modular        		
    fi;   
  fi;	
end);
	

#############################################################################
##
## AUGMENTATION IDEAL AND GROUPS OF UNITS OF GROUP RINGS
##
#############################################################################

#############################################################################
##
#A  RadicalOfAlgebra( <KG> )
## 
InstallMethod( RadicalOfAlgebra,
    "for modular group algebra of finite p-group",
    true,
    [ IsAlgebra and IsPModularGroupAlgebra ], 
    0,
    KG -> AugmentationIdeal(KG) );  


#############################################################################
##
#A  AugmentationIdeal( <KG> )
## 
InstallMethod( AugmentationIdeal,
    "for a modular group algebra of a finite group",
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
    
    "for modular group algebra of a finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function(KG)
	local G, gens, jb, jw, i, k, wb, wbe, c, emb, weight, weights;
     
    	Info(LAGInfo, 1, "LAGInfo: Calculating weighted basis ..." );
         
    	G := UnderlyingMagma( KG );
    	emb := Embedding( G, KG );
         
	    jb := DimensionBasis( G ).dimensionBasis;
	    jw := DimensionBasis( G ).weights;
         
	    c := Tuples( [ 0 .. PrimePGroup( G ) - 1 ], Length( jb ) );
	    RemoveSet( c, List( [ 1 .. Length( jb ) ], x -> 0 ) );
	    weights := [];
	    wb := [];
	    
	    Info(LAGInfo, 2, "LAGInfo: Generating ", Length(c), " elements of weighted basis");
	    
	    for i in c do
	    
	    Info(LAGInfo, 3, Position(c,i) );
	    
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
	         
	    Info(LAGInfo, 1, "LAGInfo: Weighted basis finished !" );
	         
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

    "for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
    local c, i, j, f, jb, jw, s;
         
    Info(LAGInfo, 1, "LAGInfo: Computing the augmentation ideal filtration ...");
            
    jb := WeightedBasis( KG ).weightedBasis;
    jw := Collected( WeightedBasis( KG ).weights );
         
    c := [ ];
    
    Info(LAGInfo, 2, "LAGInfo: using ", Length(jw), " element of weighted basis");     
         
    for i in [1..Length( jw )] do
    	f := 1;
        for j in [1..i-1] do
        	f := f+jw[j][2];
        od;
        s := Subalgebra( KG, jb{[f..Length( jb )]}, "basis" );
        Add( c, s );
        Info(LAGInfo, 3, "I^", i);    
    od;
         
    Add( c, Subalgebra( KG, [ ] ) );
         
    Info(LAGInfo, 1, "LAGInfo: Filtration finished !" );
         
    return c;
    end
    );


#############################################################################
##
#A  AugmentationIdealNilpotencyIndex( <R> )
##  
    
InstallMethod( AugmentationIdealNilpotencyIndex,
    "for a modular group algebra of a finite p-group",
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
  		t:=t + m*d[m];
	od;
	return t;
    end
    ); 


#############################################################################
##
#A  AugmentationIdealOfDerivedSubgroupNilpotencyIndex( <R> )
##  

InstallMethod( AugmentationIdealOfDerivedSubgroupNilpotencyIndex,
    "for a modular group algebra of a finite p-group",
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
  		t:=t + m*d[m];
	od;
	return t;
    end
    );  
                             
        
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
	"for modular group algebra of finite p-group",
        true,
        [ IsPModularGroupAlgebra, 
          IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep],
        0,
        function( KG, u )
    local i, j, c, wb, rem, w, f, l, coef, u1, e, cl, z;
    
    if not IsUnit(KG,u) then
    	Error( "The element <u> must be invertible." );
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

#############################################################################
##
#A  NormalizedUnitGroup( <KG> )
##  
InstallMethod( NormalizedUnitGroup,
    "for modular group algebra of a finite p-group",
    true,
    [ IsPModularGroupAlgebra ], 
    0,
    function(KG)
    local U;
    U := Group( List ( WeightedBasis(KG).weightedBasis, x -> One(KG)+x ) );
    SetIsGroupOfUnitsOfMagmaRing(U,true);
    SetIsNormalizedUnitGroupOfGroupRing(U,true);
    SetIsCommutative(U, IsCommutative(UnderlyingMagma(KG)));
    SetIsFinite(U, true);
    SetUnderlyingRing(U,KG);
    return U;
    end
    );   


#############################################################################
##
#A  Size( <U> )
##  
InstallMethod( Size,
    "for normalized unit group of a modular group algebra of a finite p-group",
    true,
    [ IsNormalizedUnitGroupOfGroupRing ],
    0,
    U -> Size(LeftActingDomain(UnderlyingRing(U)))^(Size(UnderlyingMagma(UnderlyingRing(U)))-1) );


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
	"for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG ) 
    local i, j, e, wb, f, rels, fgens, w, coef, k, U, z, p;
         
    Info(LAGInfo, 1, "LAGInfo: Computing the pc normalized unit group ..." );
         
    e := One( KG );
    z := Zero( LeftActingDomain( KG ) );
    p := Characteristic( LeftActingDomain( KG ) );
         
    wb := WeightedBasis( KG );
         
    f := FreeGroup( Length( wb.weightedBasis ));
    fgens := GeneratorsOfGroup( f );
    rels := [ ];
    
    Info(LAGInfo, 2, "LAGInfo: relations for ", Length(wb.weightedBasis), " elements of weighted basis");     
         
    for i in [1..Length(wb.weightedBasis)] do
    	coef := NormalizedUnitCF( KG, (wb.weightedBasis[i]+e)^p );
    	w := One( f );
    	for j in [1..Length(coef)] do
    		if not coef[j]=z then
    			w := w*fgens[j]^IntFFE( coef[j] );
    		fi;
    	od;
    	Add( rels, fgens[i]^p/w );
        Info(LAGInfo, 3, i);
    od;
    
    Info(LAGInfo, 2, "LAGInfo: commutators for ", Length(wb.weightedBasis), " elements of weighted basis");     
         
    for i in [1..Length( wb.weightedBasis )] do
    	for j in [i+1..Length( wb.weightedBasis )] do
    		coef := NormalizedUnitCF( KG,  
                    Comm( wb.weightedBasis[i]+e, wb.weightedBasis[j]+e ));
            w := One( f );
      		for k in [1..Length( coef )] do
            if not coef[k]=z then
                w := w*fgens[k]^IntFFE( coef[k] );
            fi;
            od;
            Add( rels, Comm( fgens[i],fgens[j] )/w );
            Info(LAGInfo, 3, "[ ", i, " , ", j, " ]");
		od;
	od;
         
    Info(LAGInfo, 1, "LAGInfo: finished, converting to PcGroup" );
    
    U:=PcGroupFpGroup( f/rels );
    SetIsGroupOfUnitsOfMagmaRing(U,true);
    SetIsUnitGroupOfGroupRing(U,true);
    SetUnderlyingRing(U,KG);     
    return U;
	end
	);

#############################################################################
##
#A  Units( <KG> )
##  
InstallMethod( Units,
	"for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
    local K, U;
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
    SetUnderlyingRing(U,KG);
    return U;
    end
    );

#############################################################################
##
#A  Size( <U> )
##  
InstallMethod( Size,
    "for unit group of a modular group algebra of a finite p-group",
    true,
    [ IsUnitGroupOfGroupRing ],
    0,
    U -> Size( Units( LeftActingDomain( UnderlyingRing( U ) ) ) ) * 
         Size( NormalizedUnitGroup( UnderlyingRing( U ) ) ) );


#############################################################################
##
#A  PcUnits( <KG> )
##  
InstallMethod( PcUnits,
	"for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ],
    0,
    function( KG )
    local K, U;
    K := Units( LeftActingDomain( KG ) );
    if Size(K)=1 then 
    	U:=PcNormalizedUnitGroup(KG);
    else
    	U:=DirectProduct( K, PcNormalizedUnitGroup(KG) );
    fi;
    SetIsGroupOfUnitsOfMagmaRing(U,true);
    SetIsUnitGroupOfGroupRing(U,true);
    SetUnderlyingRing(U,KG);
    return U;
    end
    );    

#############################################################################
##
#A  NaturalBijectionToPcNormalizedUnitGroup( <KG> )
##  
InstallMethod( NaturalBijectionToPcNormalizedUnitGroup,
	"for modular group algebra of finite p-group",
	true,
	[ IsPModularGroupAlgebra ],
	0,
	FG -> GroupHomomorphismByFunction( NormalizedUnitGroup( FG ), 
					   PcNormalizedUnitGroup( FG ),
					   PcPresentationOfNormalizedUnit(FG) ) );


#############################################################################
##
#A  NaturalBijectionToNormalizedUnitGroup( <KG> )
##  
InstallMethod( NaturalBijectionToNormalizedUnitGroup,
	"for modular group algebra of finite p-group",
	true,
	[ IsPModularGroupAlgebra ],
	0,
	FG -> GroupHomomorphismByImagesNC( PcNormalizedUnitGroup( FG ),
                                           NormalizedUnitGroup( FG ),
                                           GeneratorsOfGroup( PcNormalizedUnitGroup( FG ) ),
					   GeneratorsOfGroup( NormalizedUnitGroup( FG ) ) ) );


#############################################################################
##
#A  GroupBases( <FG> )
##  
InstallMethod( GroupBases,
##  Calculation of group basises of the modular group algebra
##  of a finite p-group
    "for modular group algebra of finite p-group",
    true,
    [ IsPModularGroupAlgebra ], 0,
    function(FG)
	local G, U, f, cc, c, H, bases, hgens, FH;
	G:=UnderlyingMagma(FG);
	U:=PcNormalizedUnitGroup(FG);
	f:=NaturalBijectionToNormalizedUnitGroup(FG);
	cc:=Filtered( ConjugacyClassesSubgroups( U ), H -> Size(Representative(H))=Size(G) );

	bases:=[];

	Info(LAGInfo, 1, "LAGInfo: testing ", Length(cc), " conjugacy classes of subgroups");     
	
	for c in cc do
		H:=Representative(c);
		if IsomorphismGroups(G,H) <> fail then
			hgens:=List(GeneratorsOfGroup(H), h -> h^f);
			FH:=Subalgebra(FG, hgens);
			if Dimension(FH)=Size(G) then
				Append( bases, [ List(AsList(H), h -> h^f) ] );
				Info(LAGInfo, 2, "LAGInfo: H is a group basis");
			else
				Info(LAGInfo, 2, "LAGInfo: H linearly dependent");
			fi;
		else
			Info(LAGInfo, 3, "LAGInfo: H not isomorphic to G");     
		fi;
	od;
return bases;
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
#+  This method takes an associative algebra as argument, and constructs
#+  its associated Lie algebra.
#+  The user, however, will {\bf never use} this command, but will rather use
#+  LieAlgebra( <A> ), which either returns the Lie algebra in case
#+  it is already constructed, or refers to LieAlgebraByDomain in case 
#+  it is not.
    	
    "for an associative algebra",
    true,
    [ IsAlgebra and IsAssociative ], 0,
    function( A )

       local fam,L;

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
  end );


InstallMethod( \in,
  "for a Lie algebra that comes from an associative algebra and a Lie object",
    true,
    [ IsLieObject, IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    function( x, L )

      return x![1] in UnderlyingAssociativeAlgebra( L ); 

end );


InstallMethod( GeneratorsOfLeftOperatorRing,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    function( L )

       return List( BasisVectors( Basis( UnderlyingAssociativeAlgebra( L ) ) ),
                       LieObject );
end); 


InstallMethod( IsFiniteDimensional,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> IsFiniteDimensional( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( Dimension,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> Dimension ( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( IsFinite,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> IsFinite ( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( Size,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> Size ( UnderlyingAssociativeAlgebra( L ) ) );
      

InstallMethod( AsSSortedList,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> List(AsSSortedList(UnderlyingAssociativeAlgebra(L)), LieObject)
);
      

InstallMethod( Representative,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> LieObject(Representative(UnderlyingAssociativeAlgebra( L ) ) ) );


InstallMethod( Random,
    "for a Lie algebra coming from an associative algebra",
    true,
    [ IsLieAlgebra and IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> LieObject(Random(UnderlyingAssociativeAlgebra( L ) ) ) );


#############################################################################
##
#M  CanonicalBasis( <L> )
##  

InstallMethod( CanonicalBasis,
#+  This method transfers the canonical basis of an associative algebra
#+  to its associated Lie algebra $L$.
    "for a Lie algebra coming from an associative algebra",
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
#+  This method directly computes the canonical basis of the Lie algebra
#+  of a group algebra without referring to the group algebra, i.e. by
#+  sending the group elements directly to the Lie algebra.
    "for a Lie algebra of a group algebra",
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
#+  A very fast implementation for calculating the structure constants
#+  of a Lie algebra of a group ring w.r.t. its canonical basis $B$ by
#+  using the special structure of $B$.
   "for a basis of a Lie algebra of a group algebra",
    true,
    [ IsBasis and IsCanonicalBasis and IsBasisOfLieAlgebraOfGroupRing ], 0,
    function(B)
      local L,F,e,o,G,n,X,T,i,j,g,h;
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
    "for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraOfGroupRing ], 0,
    L -> UnderlyingMagma( UnderlyingAssociativeAlgebra( L ) ) );


InstallMethod( NaturalBijectionToLieAlgebra,
    "for an associative algebra",
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
    "for a Lie algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    L->InverseGeneralMapping(NaturalBijectionToLieAlgebra(UnderlyingAssociativeAlgebra(L)))
);


InstallMethod( IsLieAlgebraOfGroupRing,
    "for a Lie algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    L->IsGroupRing(UnderlyingAssociativeAlgebra(L))
);

#############################################################################
##
#O  Embedding( <U>, <L> )
##  
##  Let <U> be a submagma of a group $G$, let $A := FG$ be the group ring of $G$
##  over some field $F$, and let <L> be the associated Lie algebra of $A$.
##  Then `Embedding( <U>, <L> )' returns the obvious mapping $<U> \to <L>$
##  (as the composition of the mappings `Embedding( <U>, <A> )' and
##  `NaturalBijectionToLieAlgebra( <A> )'~).

InstallMethod( Embedding,
    "from a group to the Lie algebra of the group ring",
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
    "for a group ring",
    true,
    [ IsAlgebraWithOne and IsGroupRing ], 0,
    function(FG)
      local G,X,F,e;
      G:=UnderlyingMagma(FG);
      X:=GeneratorsOfMagmaWithOne(G);
      F:=LeftActingDomain(FG);
      e:=Embedding(G,FG);
      return AlgebraHomomorphismByImages(
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
#+  The (Lie) derived subalgebra of a Lie algebra of a group ring can
#+  be calculated very fast by considering the conjugacy classes of the group.
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
    "for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    function(L)
      local G, CC, t, B, C, s, K, j, i, x;
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
      return Subalgebra(L, B, "basis");
    end);


#############################################################################
##
#M  LieCentre( <L> )
##  

InstallMethod( LieCentre,
#+  The (Lie) centre of a Lie algebra of a group ring corresponds to the
#+  centre of the underlying group ring, and it can
#+  be calculated very fast by considering the conjugacy classes
#+  of the group.
#+  Since the corresponding method for the centre of the group ring
#+  does just that, it is being referred to by the method at hand.
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
#+  This is particularly important for the command LieCentre.
    "for a Lie algebra of a group ring",
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
#+  The Lie algebra $L$ of an associative algebra  $A$ is Lie abelian,
#+  if and only if $A$ is abelian, so this method refers
#+  to IsAbelian( <A> ).
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
#+  This is particularly important for the command IsLieAbelian.
    "for a Lie algebra of an associative algebra",
    true,
    [ IsLieAlgebraByAssociativeAlgebra ], 0,
    L -> IsAbelian( UnderlyingAssociativeAlgebra( L ) ) );


#############################################################################
##
#M  IsLieSolvable( <L> )
##  

InstallMethod( IsLieSolvable,
#+  In `Lie solvable group rings', Canad. J. Math. 25, No. 4 (1973), 748-757, 
#+  Passi-Passman-Sehgal have classified all groups $G$ such that the
#+  associated
#+  Lie algebra $L$ of the group ring is (Lie) solvable. This method uses
#+  their classification, making it considerably faster than
#+  the more elementary method which just calculates Lie commutators.
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
    "for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    
    function(L)
      local p,s;
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
#+  In `Lie solvable group rings', Canad. J. Math. 25, No. 4 (1973), 748-757, 
#+  Passi-Passman-Sehgal have classified all groups $G$ such that the
#+  associated
#+  Lie algebra $L$ of the group ring is (Lie) nilpotent. This method uses
#+  their classification, making it considerably faster than
#+  the more elementary method which just calculates Lie commutators.
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
    "for a Lie algebra of a group ring",
    true,
    [ IsLieAlgebraByAssociativeAlgebra and IsLieAlgebraOfGroupRing ], 0,
    
    function(L)
      local p,G;
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
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra], 0,
    L->(0=Dimension(LieDerivedSubalgebra(LieDerivedSubalgebra(L))))
);


#############################################################################
##
#M  IsLieMetabelian( <L> )
##  

InstallMethod( IsLieMetabelian,
#+  In `Lie metabelian group rings', Group and semigroup rings, North-Holland, 
#+  1986, 153-161, Levin and Rosenberger have classified all groups $G$ 
#+  such that the associated
#+  Lie algebra $L$ of the group ring is (Lie) metabelian. This method uses
#+  their classification, making it considerably faster than
#+  the more elementary method which just calculates Lie commutators.
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
    "for a Lie algebra of a group ring",
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
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra and HasLieDerivedSeries ], 0,
    L->IsSubset(LieCentre(L), LieDerivedSeries(L)[3]));


InstallMethod( IsLieCentreByMetabelian,
    "for a Lie algebra",
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
#+  In various papers,
#+  K\"ulshammer, Sahai, Sharma, Srivastava and the author of the share
#+  package have classified all groups $G$ 
#+  such that the associated
#+  Lie algebra $L$ of the group ring is (Lie) centre-by-metabelian. 
#+  (The most general result to date may be found in the preprint
#+  `Lie centre-by-metabelian group algebras over commutative rings',
#+  available on the authors' WWW pages under
#+  http://www.mathematik.uni-jena.de/algebra/skripten/{\#}rossmanith.)
#+  This method uses
#+  the classification, making it considerably faster than
#+  the more elementary method which just calculates Lie commutators.
#+  
#+  Note that he prefix `Lie' is consistently used to
#+  distinguish properties of Lie algebras from the analogous properties
#+  of groups (or of general algebras). Not using this prefix may
#+  result in error messages, or even in wrong results without warning.
    "for a Lie algebra of a group ring",
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


InstallMethod( LieUpperNilpotencyIndex,
	"for modular group algebra of finite p-group",
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


InstallMethod( LieLowerNilpotencyIndex,
  "for modular group algebra of finite p-group",
  true,
  [ IsPModularGroupAlgebra ],
  0,
  KG -> Length( LieLowerCentralSeries( LieAlgebra( KG ) ) ) );



#############################################################################
##
## SOME IMPORTANT GROUP-THEORETICAL ATTRIBUTES
##
#############################################################################


InstallMethod( SubgroupsOfIndexTwo,
    "for a group",
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
        return List
                 (
                   subs,
                   M->Subgroup
                        ( G,
                          PreImagesSet( f,
                                        GeneratorsOfMagmaWithInverses(M)
                                      )
                        )
                 );
      else
        return [];
      fi;
    end);


InstallMethod( SubgroupsOfIndexTwo,
    "for a group",
    true,
    [ IsGroup and HasMaximalSubgroupClassReps ], 0,
    G -> Filtered(MaximalSubgroupClassReps(G), M->(2=Index(G,M))));


InstallMethod( SubgroupsOfIndexTwo,
    "for a group",
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
    "for a group",
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
		    return LogInt(Maximum(sizes),2)-1; # at least non-trivial case
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
    "for a finite p-group",	
	true,
    [ IsGroup ],
    0,
    function( g )
    	local i, j, w, b, n, gens, x;
 
     	Info(LAGInfo, 1, "LAGInfo: Calculating Jennings basis ..." );

     	j := JenningsSeries( g );
        b := [];
        w := [];
      
        for i in [ 1 .. Length(j)-1 ] do	
            n:= NaturalHomomorphismByNormalSubgroup( j[i], j[i+1] );
            gens := Filtered( GeneratorsOfGroup( Image( n )), x -> not IsOne(x) );
            if Length(gens) > 0 then
                Info(LAGInfo, 2, i," ", List(gens,Order) );
                Append( w, List( gens, x->i ));
                Append( b, List( gens, x->PreImagesRepresentative( n, x )));
            fi;
        od;
     
     	Info(LAGInfo, 1, "LAGInfo: Jennings basis finished !" );
     
     	return rec( dimensionBasis := b, weights := w );
 	
 	end 
 	);            
 	

#############################################################################
##
#A  LieDimensionSubgroups( <G> )
##  
InstallMethod( LieDimensionSubgroups,
	"for a finite p-group",
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



############################################################################
##
#E
##





