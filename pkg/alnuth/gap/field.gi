############################################################################
##
#W  field.gi       Alnuth - ALgebraic NUmber THeory           Bettina Eick
#W       					            Bjoern Assmann
#W       					           Andreas Distler
##

#############################################################################
##
#F ListElmPower( range, elm )
#M EquationOrderBasis( F )
##
ListElmPower := function( range, elm )
    local list, i;

    if not IsRange( range ) then
        Error( "<range> has to be a range" );
    fi;

    # trivial cases
    if IsEmpty( range ) then
        return [ ];
    elif Length( range ) = 1 then
        return [ elm ^ range[1] ];
    fi;

    list := [ elm ^ range[1] ];
    elm := elm ^ (range[2] - range[1]);
    for i in [ 1..Length( range ) - 1 ] do
        Add( list, list[i] * elm );
    od;
    return list;
end;   

InstallMethod( EquationOrderBasis, "for number field", true,
[IsNumberField], 0, 
function( F ) 
    return RelativeBasisNC( Basis( F ), 
                            ListElmPower( [ 0..DegreeOverPrimeField( F )-1 ],
                                          IntegerPrimitiveElement( F ) ) ) ;
end );


InstallMethod( IsPrimitiveElementOfNumberField, 
"for number field and algebraic element", true, [ IsNumberField, IsObject ], 0, 
function( F, elm )
    local d, g;

    if not elm in F then
        Info( InfoAlnuth, 1, "Element does not lie in the field." );
        return false;
    fi;

    d := DegreeOverPrimeField( F );
    g := MinimalPolynomial( Rationals, elm );

    return Degree(g) = d;
end );
 

InstallOtherMethod( EquationOrderBasis,
"for number field and primitive element", true, [IsNumberField, IsObject ], 0, 
function( F , elm )
    if not IsPrimitiveElementOfNumberField( F, elm ) then
        return fail;
    fi; 
    return RelativeBasisNC(Basis( F ), 
                           ListElmPower([0..DegreeOverPrimeField(F)-1],elm));
end );


#############################################################################
## 
#M MaximalOrderBasis( F )
##  
InstallMethod(MaximalOrderBasis, "for number field", true,[IsNumberField], 0, 
function( F ) 
    local e, T, b, B;
  
    if DegreeOverPrimeField(F)=1 then
        return EquationOrderBasis(F);
    fi;
    e := EquationOrderBasis(F);
    T := MaximalOrderDescriptionPari(F);
    b := List( T, x -> LinearCombination( e, x ) );
    B := Objectify(NewType(FamilyObj(F), IsFiniteBasisDefault and
                                         IsRelativeBasisDefaultRep),
                           rec());
    SetUnderlyingLeftModule( B, F );
    SetBasisVectors( B, b );
    B!.basis := e;
    B!.basechangeMatrix := Immutable( T^-1 );
    return B;
end );

#############################################################################
##
#F IsIntegerOfNumberField( F, k )
##
IsIntegerOfNumberField := function( F, k )
    local c;
    c := Coefficients( MaximalOrderBasis(F), k );
    return ForAll( c, IsInt );
end;

#############################################################################
##
#M UnitGroup( F )
##
AddNaturalHomomorphismOfUnitGroup := function( G )
    local gens, rels, H, nat;

    # the generators of G are independent and the first one is torsion
    gens := GeneratorsOfGroup(G);
    rels := List( gens, x -> 0 ); rels[1] := Order( gens[1] );
    H := AbelianPcpGroup( Length(rels), rels );
    nat := GroupHomomorphismByImagesNC( G, H, gens, AsList(Pcp(H)) );

    # add infos
    SetIsBijective( nat, true );
    SetIsUnitGroupIsomorphism( nat, true );
    SetIsomorphismPcpGroup( G, nat );
end;

AddUnitGroupOfNumberField := function( F, units )
    local gens, G;

    # check if units are known
    if HasUnitGroup(F) then
        gens := GeneratorsOfGroup(UnitGroup(F));
        if not gens = units then Error("wrong units"); fi;
    fi;

    # otherwise add them
    G := GroupByGenerators( units );
    SetIsUnitGroup( G, true );
    SetFieldOfUnitGroup( G, F );
    AddNaturalHomomorphismOfUnitGroup( G );
    SetUnitGroup( F, G );
end;

UnitGroupOfNumberField := function( F )
    local eqn, uni, gen, G, r, H, nat;

    # determine generators
    eqn := EquationOrderBasis(F);
    uni := UnitGroupDescriptionPari(F);
    if uni=[-1] then
        G:=GroupByGenerators([-1*eqn[1]]);
    else
        gen := List( uni, x -> LinearCombination( eqn, x ) );
        G := GroupByGenerators(gen);
    fi;
    # add info
    SetIsUnitGroup( G, true );
    SetFieldOfUnitGroup( G, F );
    AddNaturalHomomorphismOfUnitGroup( G );

    # return
    return G;
end;

InstallMethod( UnitGroup, "for number field", true,
[IsNumberField], 0, function( F ) return
UnitGroupOfNumberField( F ); end);

#############################################################################
##
#F IsUnitOfNumberField( F, k )
##
InstallGlobalFunction( IsUnitOfNumberField, function( F, k )
    if not IsIntegerOfNumberField( F, k ) then return false; fi;
    return AbsInt(Norm( F, k )) = 1;
end );

#############################################################################
##
#F AL_ExponentsTrivialUnits( unit, one )
#F ExponentsOfUnitsOfNumberField( F, elms )
#M ExponentsOfUnits( F, elms )
##
AL_ExponentsTrivialUnits := function( unit, one ) 
    if unit = one then
        return [ 0 ];
    else
        return [ 1 ];
    fi;
end;

ExponentsOfUnitsOfNumberField := function( F, elms )
    local base, coef, exps, gens;

    # catch a trivial case
    if IsPrimeField(F) then 
        # check whether all elements are units
        if ForAny( elms, x -> not x in [ One( F ), -One( F ) ] ) then
            return fail;
        fi;
        # return [ 0 ] for One( F ) and [ 1 ] for -One( F )
        return List( elms, x -> AL_ExponentsTrivialUnits( x, One( F )));
    fi; 

    # determine exponents
    base := EquationOrderBasis( F );
    coef := List( elms, x -> Coefficients( base, x ) );
    exps := ExponentsOfUnitsDescriptionWithRankPari( F, coef );

    # add unit group if this is not yet known
    gens := List( exps.units, x -> LinearCombination( base, x ) );
    AddUnitGroupOfNumberField( F, gens );

    # return exponents
    if exps.expns = [ ] then 
        return fail;
    else
        return exps.expns;
    fi;
end;

InstallMethod( ExponentsOfUnits, "for number fields", true,
[IsNumberField, IsCollection], 0, function( F, elms )
return ExponentsOfUnitsOfNumberField( F, elms ); end);

#############################################################################
##
#F ExponentsOfUnitsWithRank( F, elms )
##
ExponentsOfUnitsWithRank := function( F, elms )
    local base, flat, coef, exps, gens;

    # determine exponents
    base := EquationOrderBasis( F );
    coef := List( elms, x -> Coefficients( base, x ) );
    exps := ExponentsOfUnitsDescriptionWithRankPari( F, coef );

    # add unit group if this is not yet known
    gens := List( exps.units, x -> LinearCombination( base, x ) );
    AddUnitGroupOfNumberField( F, gens );

    # return exponents
    return rec(exps:=exps.expns, rank:=exps.rank);
end;

#############################################################################
##
#F NormCosetsOfNumberField( F, norm )
##
InstallGlobalFunction( NormCosetsOfNumberField, function( F, norm )
    local base, reps, gens;

    # catch a trivial case
    if IsPrimeField(F) then return [norm*One(F)]; fi;

    # get representatives mod unit group
    base := EquationOrderBasis( F );
    reps := NormCosetsDescriptionPari( F, norm );

    # add unit group if this is not yet known
    gens := List( reps.units, x -> LinearCombination( base, x ) );
    AddUnitGroupOfNumberField( F, gens );

    # translate coset reps
    return List( reps.creps, x -> LinearCombination( base, x ) );
end );

#############################################################################
##
#M IsCyclotomicField( F )
##
InstallMethod( IsCyclotomicField, "for number fields", true,
[IsNumberField], 0, function( F )
    local U, t, o;
    U := UnitGroup(F);
    t := GeneratorsOfGroup(U)[1];
    o := Order(t);
    return Phi(o) = DegreeOverPrimeField(F);
end);












