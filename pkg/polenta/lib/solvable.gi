#############################################################################
##
#W solvalble.gi           POLENTA package                     Bjoern Assmann
##
## Methods for testing if a matrix group
## is solvable or polycyclic
##
#H  @(#)$Id: solvable.gi,v 1.17 2011/09/23 13:36:33 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F POL_IsSolvableRationalMatGroup_infinite( G )
##
POL_IsSolvableRationalMatGroup_infinite := function( G )
    local  p, d, gens_p, bound_derivedLength, pcgs_I_p, gens_K_p,
           homSeries, gens_K_p_m, gens, gens_K_p_mutableCopy, pcgs,
           gensOfBlockAction, pcgs_nue_K_p, pcgs_GU, gens_U_p,  pcgs_U_p;

    # handle trivial case
    if IsAbelian( G ) then
        return true;
    fi;

    # setup
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);

    # determine an admissible prime
    p := DetermineAdmissiblePrime(gens);
    Info( InfoPolenta, 1, "Chosen admissible prime: " , p );
    Info( InfoPolenta, 1, "  " );


    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    # finite part
    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the image under the p-congruence homomorphism ..." );
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    if pcgs_I_p = fail then return false; fi;
    Info( InfoPolenta, 1, "Finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ), "." );
    Info( InfoPolenta, 1, " " );


    # compute the normal the subgroup gens. for the kernel of phi_p
    Info( InfoPolenta, 1,"Compute normal subgroup generators for the kernel\n",
          "    of the p-congruence homomorphism ...");
    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    gens_K_p := Filtered( gens_K_p, x -> not x = IdentityMat(d) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 2,"The normal subgroup generators are" );
    Info( InfoPolenta, 2, gens_K_p );
    Info( InfoPolenta, 1, "  " );


    # homogeneous series
    Info( InfoPolenta, 1, "Compute the homogeneous series ... ");
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    homSeries := POL_HomogeneousSeriesNormalGens( gens,
                                                  gens_K_p_mutableCopy,
                                                  d );
    if homSeries = fail then
        return false;
    else
        Info( InfoPolenta, 1,"finished.");
        Info( InfoPolenta, 1, "The homogeneous series has length ",
                          Length( homSeries ), "." );
        Info( InfoPolenta, 2, "The homogeneous series is" );
        Info( InfoPolenta, 2, homSeries );
        Info( InfoPolenta, 1, " " );
        return true;
    fi;

end;

#############################################################################
##
#F POL_IsSolvableFiniteMatGroup( G )
##
POL_IsSolvableFiniteMatGroup := function( G )
    local gens, d, CPCS, bound_derivedLength;

    # handle trivial case
    if IsAbelian( G ) then
        return true;
    fi;

    # calculate a constructive pc-sequence
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);
    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the finite input group ..." );
    CPCS := CPCS_finite_word( gens, bound_derivedLength );

    if CPCS = fail then
        return false;
    else
        Info(InfoPolenta,1,"finished.");
        return true;
    fi;
end;

#############################################################################
##
#M IsSolvableGroup( G )
##
## G is a matrix group over the rationals.
##
##
InstallMethod( IsSolvableGroup, "for rational matrix groups (Polenta)", true,
               [ IsRationalMatrixGroup ], 0,
               POL_IsSolvableRationalMatGroup_infinite );

## Enforce rationality check for cyclotomic matrix groups
RedispatchOnCondition( IsSolvableGroup, true,
    [ IsCyclotomicMatrixGroup ], [ IsRationalMatrixGroup ],
    RankFilter(IsCyclotomicMatrixGroup) );

#############################################################################
##
#M IsSolvableGroup( G )
##
## G is a matrix group over a finite field.
##
InstallMethod( IsSolvableGroup, "for matrix groups over a finte field (Polenta)",
               true, [ IsFFEMatrixGroup ], 0,
               POL_IsSolvableFiniteMatGroup );

#############################################################################
##
#F POL_IsPolycyclicRationalMatGroup( G )
##
POL_IsPolycyclicRationalMatGroup := function( G )
     local  test;
     if not IsFinitelyGeneratedGroup( G ) then
         return false;
     fi;

     if IsAbelian( G ) then
         return true;
     fi;
     test := CPCS_NonAbelianPRMGroup( G, 0, "testIsPoly" );
     if test=false or test=fail then
        return false;
     else
        return true;
     fi;
end;

#############################################################################
##
#M IsPolycyclicGroup( G )
##
## G is a finitely generated subgroup of GL(n,Z), hence G is polycycylic
## if and only if G is solvable and finitely generated.
##
InstallMethod( IsPolycyclicGroup, "for integer matrix groups (Polenta)", true,
               [ IsIntegerMatrixGroup ], 0,
function( G )
    return IsFinitelyGeneratedGroup( G ) and IsSolvableGroup( G );
end );

#############################################################################
##
#M IsPolycyclicGroup( G )
##
## G is a matrix group over the rationals
##
InstallMethod( IsPolycyclicGroup, "for rational matrix groups (Polenta)", true,
               [ IsRationalMatrixGroup ], 0,
function( G )
    if IsIntegerMatrixGroup(G) then
        return IsFinitelyGeneratedGroup( G ) and IsSolvableGroup( G );
    fi;
    return POL_IsPolycyclicRationalMatGroup( G );
end );

## Enforce rationality check for cyclotomic matrix groups
RedispatchOnCondition( IsPolycyclicGroup, true,
    [ IsCyclotomicMatrixGroup ], [ IsRationalMatrixGroup ],
    RankFilter(IsCyclotomicMatrixGroup) );

#############################################################################
##
#M IsPolycyclicGroup( G )
##
## G is a matrix group over a finite field
##
InstallMethod( IsPolycyclicGroup,
               "for matrix groups over a finite field (Polenta)", true,
               [ IsFFEMatrixGroup ], 0,
function( G )
    local F;
     if not IsFinitelyGeneratedGroup( G ) then
         return false;
     fi;
    if IsAbelian( G ) then
        return true;
    fi;
    return IsSolvableGroup( G );
end );

#############################################################################
##
#M IsPolycyclicMatGroup( G )
##
## G is a matrix group, test whether it is polycyclic.
##
## TODO: Mark this as deprecated and eventually remove it; code using it
## should be changed to use IsPolycyclicGroup.
##
InstallMethod( IsPolycyclicMatGroup, [ IsMatrixGroup ], IsPolycyclicGroup);

#############################################################################
##
#F POL_IsTriangularizableRationalMatGroup_infinite( G )
##
POL_IsTriangularizableRationalMatGroup_infinite := function( G )
  local   p, d, gens_p, bound_derivedLength, pcgs_I_p, gens_K_p,
            gens_K_p_m, gens, gens_K_p_mutableCopy, pcgs,
            gensOfBlockAction, pcgs_nue_K_p, pcgs_GU, gens_U_p, pcgs_U_p,
            radSeries, comSeries, recordSeries, isTriang;
    if IsAbelian( G ) then
        return true;
    fi;
    # setup
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);

    # determine an admissible prime or take the wished one
    #if Length( arg ) = 2 then
    #   p := arg[2];
    #else
        p := DetermineAdmissiblePrime(gens);
    #fi;
    Info( InfoPolenta, 1, "Chosen admissible prime: " , p );
    Info( InfoPolenta, 1, "  " );

    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    # finite part
    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the image under the p-congruence homomorphism ..." );
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    if pcgs_I_p = fail then return false; fi;
    Info(InfoPolenta,1,"finished.");
    Info( InfoPolenta, 1, "Finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ), "." );
    Info( InfoPolenta, 1, " " );

    # compute the normal the subgroup gens. for the kernel of phi_p
    Info( InfoPolenta, 1,"Compute normal subgroup generators for the kernel\n",
          "    of the p-congruence homomorphism ...");
    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    gens_K_p := Filtered( gens_K_p, x -> not x = IdentityMat(d) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 2,"The normal subgroup generators are" );
    Info( InfoPolenta, 2, gens_K_p );
    Info( InfoPolenta, 1, "  " );

    # radical series
    Info( InfoPolenta, 1, "Compute the radical series ...");
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    recordSeries := POL_RadicalSeriesNormalGensFullData( gens,
                                                      gens_K_p_mutableCopy,
                                                      d );
    if recordSeries=fail then return false; fi;
    radSeries := recordSeries.sers;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, "The radical series has length ",
                          Length( radSeries ), "." );
    Info( InfoPolenta, 2, "The radical series is" );
    Info( InfoPolenta, 2, radSeries );
    Info( InfoPolenta, 1, " " );

    # test if G is unipotent by abelian
    isTriang := POL_TestIsUnipotenByAbelianGroupByRadSeries( gens, radSeries );

    return isTriang;

end;

#############################################################################
##
#M IsTriangularizableMatGroup( G )
##
##
InstallMethod( IsTriangularizableMatGroup, "for matrix groups over Q (Polenta)", true,
               [ IsRationalMatrixGroup ], 0,
               POL_IsTriangularizableRationalMatGroup_infinite );

## Enforce rationality check for cyclotomic matrix groups
RedispatchOnCondition( IsTriangularizableMatGroup, true,
    [ IsCyclotomicMatrixGroup ], [ IsRationalMatrixGroup ],
    RankFilter(IsCyclotomicMatrixGroup) );

#############################################################################
##
#E
