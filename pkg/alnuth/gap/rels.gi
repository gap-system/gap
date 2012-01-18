#############################################################################
##
#W rels.gi          Alnuth - ALgebraic NUmber THeory         Bjoern Assmann
##

#############################################################################
##
#F RelationLatticeOfTFUnits( F, elms )
##
## The input is a list of elements which generate a free abelian subgroup
## of the unit group of F. The function computes the relation lattice of
## <elms>.
##
InstallGlobalFunction( RelationLatticeOfTFUnits, function( F, elms )
    local exps,rels,l;

    # do a simple check
    if ForAll( elms, x -> x = x^0 ) then 
        return IdentityMat( Length(elms) );
    fi;

    # now compute an additive description
    exps := ExponentsOfUnits( F, elms );
    Info(InfoAlnuth,2,exps);
    Info(InfoAlnuth,2,"exps");

    # the first entry in the vectors of exps corresponds to torsion -
    # mod out
    l := Length( exps[1] );
    exps := exps{[1..Length(exps)]}{[2..l]};

    # compute the relations
    rels := NullspaceIntMat( exps );

    # format results
    if Length(rels) = 0 then 
        return rels; 
    fi;
    return NormalFormIntMat( rels, 2 ).normal; 
end );

#############################################################################
##
#F NullspaceModRank( M, n)
##
NullspaceModRank := function( M, n )
    local  snf, null, nullM, i, gcdex;                                
    snf := NormalFormIntMat( M, 1 + 4 );
    null := IdentityMat( Length( M ) );
    for i  in [ 1 .. snf.rank ]  do
        null[i][i] := n / GcdInt( n, snf.normal[i][i] );
    od;
    nullM := null * snf.rowtrans;
    Assert( 1, ForAll( nullM, function ( v )
            return v * M mod n = 0 * M[1];
        end ) );
    return nullM;
end;

#############################################################################
##
#F RelationLatticeOfUnits( F, elms )
##
## The input is a list of elements which generate a subgroup
## of the unit group of F. The function computes the relation lattice of
## <elms>.
##
InstallGlobalFunction( RelationLatticeOfUnits, function( F, elms )
    local exps,rels,l,record,rank,expsTorsion,rels1,rels2;

    # do a simple check
    if ForAll( elms, x -> x = x^0 ) then 
        return IdentityMat( Length(elms) );
    fi;

    # now compute an additive description
    record := ExponentsOfUnitsWithRank( F, elms );
    exps := record.exps;
    rank := record.rank;

    # the first entry in the vectors of exps corresponds to 
    # the torsion unit
    l := Length( exps[1] );
    expsTorsion :=exps{[1..Length(exps)]}{[1]};
    exps := exps{[1..Length(exps)]}{[2..l]};

    # solve the first system mod rank
    rels1 := NullspaceModRank( expsTorsion, rank );

    #if there are fundamental units solve second
    if l > 1 then
        rels2 := NullspaceIntMat( exps );

        # get rels as the intersection of rels1 and rels2
        rels := LatticeIntersection( rels1, rels2 );
    else
        rels := rels1;
    fi;

    # format results
    if Length(rels) = 0 then 
        return rels; 
    fi;
    return NormalFormIntMat( rels, 2 ).normal; 
end );

#############################################################################
##
#F ExponentsOfFractionalIdealDescription( F, elms )
##
ExponentsOfFractionalIdealDescription:= function( F, elms )
    local base, flat, coef, exps, gens;

    # catch a trivial case
    if IsPrimeField(F) then return List( elms, x -> Norm( F, x ) ); fi;

    # determine exponents
    base := EquationOrderBasis( F );
    coef := List( elms, x -> Coefficients( base, x ) );
    exps := ExponentsOfFractionalIdealDescriptionPari( F, coef );

    # return exponents
    return exps;
end;


#############################################################################
##
#F RelationLatticeModUnits( F, elms )
##
## The function determines the relation lattice for <elms> modulo the unit
## group of F, i.e. relations rels between elms such that elms^rels is in
## the unitgroup of F.
##
InstallGlobalFunction( RelationLatticeModUnits, function( F, elms )
    local exps,rels,l;

    # do a simple check
    if ForAll( elms, x -> x = x^0 ) then 
        return IdentityMat( Length(elms) );
    fi;

    # now compute an additive description
    exps := ExponentsOfFractionalIdealDescription( F, elms );

    # catch trivial case
    if Length(exps) = 0 then
        return IdentityMat(Length(elms));
    fi;

    # compute the relations
    rels := NullspaceIntMat( exps );

    # format results
    if Length(rels) = 0 then 
        return rels; 
    fi;
    return NormalFormIntMat( rels, 2 ).normal; 
end );

#############################################################################
##
#F RelationLatticeTF( F, elms )
##
## The input is a list of elements which generate a free abelian subgroup
## of F. The function determines the relation lattice for <elms>, i.e. 
## relations rels between <elms> such that elms^rels=1
##
InstallGlobalFunction( RelationLatticeTF, function( F, elms )
  local rul,units,i,rl;

  # calculate the relation unit lattice
  rul := RelationLatticeModUnits( F, elms );

  # calculate corresponding units
  units := [];
  for i in [1..Length(rul)] do
      Add( units, MappedVector( rul[i], elms ));
  od;

  # calculate the relations between the units
  rl := RelationLatticeOfTFUnits( F, units );

  # catch trivial case
  if Length( rl ) = 0 then
      return [];
  fi;

  return NormalFormIntMat( rl * rul, 2).normal; 
end );



#############################################################################
##
#F RelationLatticePol( F, elms )
#M RelationLattice( F, elms )
##
## The input is a list of elements in F. 
## The function determines the relation lattice for <elms>, i.e. 
## relations rels between <elms> such that elms^rels=1
##
RelationLatticePol:= function( F, elms )
  local rul,units,i,rl,F2,x;

  if DegreeOverPrimeField(F)=1 then
      x:=Indeterminate(Rationals);
      F2:=FieldByPolynomial(x^2-2);
  else 
      F2:=F;
  fi;
  # calculate the relation unit lattice
  rul := RelationLatticeModUnits( F2, elms );

  # calculate corresponding units
  units := [];
  for i in [1..Length(rul)] do
      Add( units, MappedVector( rul[i], elms ));
  od;

  # calculate the relations between the units
  rl := RelationLatticeOfUnits( F2, units );

  # catch trivial case
  if Length( rl ) = 0 then
      return [];
  fi;

  return NormalFormIntMat( rl * rul, 2).normal;
end;

RelationLatticeMat:= function( F, elms )
  local rul,units,i,rl,F2,x,c,elms2;

  if DegreeOverPrimeField(F)=1 then
      x:=Indeterminate(Rationals);
      c:=x^2-2;
      F2:=FieldByPolynomial(c);
      elms2 := List( elms, x-> x[1][1]*One(F2) );      
      return RelationLatticePol( F2, elms2 );
  else 
      F2:=F;
  fi;
  # calculate the relation unit lattice
  rul := RelationLatticeModUnits( F2, elms );

  # calculate corresponding units
  units := [];
  for i in [1..Length(rul)] do
      Add( units, MappedVector( rul[i], elms ));
  od;

  # calculate the relations between the units
  rl := RelationLatticeOfUnits( F2, units );

  # catch trivial case
  if Length( rl ) = 0 then
      return [];
  fi;

  return NormalFormIntMat( rl * rul, 2).normal;
end;


InstallMethod( RelationLattice, "for fields by polynomial", true,
[IsNumberField and IsAlgebraicExtension, IsCollection], 0, 
function( F, elms ) return RelationLatticePol( F, elms ); end);

InstallMethod( RelationLattice, "for matrix fields", true,
[IsNumberFieldByMatrices, IsCollection], 0, function( F, elms ) return
RelationLatticeMat( F, elms ); end);









